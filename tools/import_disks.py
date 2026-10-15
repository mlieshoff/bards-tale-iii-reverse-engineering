#!/usr/bin/env python3
"""Explicit regeneration from local originals; normal builds do not use originals."""
import hashlib
import json
from pathlib import Path
from d64 import Disk, SECTORS, SIZE, offset
from disasm import render, reachable_ranges
from game_analysis import analyze_engine, annotated_source, module_source, BASES
from resources import read_resources
from gamefs import directory as game_directory, read_file, block as game_block, physical_sector

ROOT = Path(__file__).resolve().parents[1]
DISKS = [('boot', "Bard's Tale III (Boot Disk).d64"),
         ('character', "Bard's Tale III (Character Disk).d64"),
         ('dungeon-a', "Bard's Tale III (Dungeon Disk side 1).d64"),
         ('dungeon-b', "Bard's Tale III (Dungeon Disk side 2).d64")]
RANGES = [(0xc217,0xc3b2),(0xc3d5,0xc3f9),(0xc450,0xc4a0),
          (0xc4cf,0xc4f2),(0xc500,0xc608),(0xc622,0xc672)]
NAMES = {0xc217:'send_byte',0xc24e:'begin_transfer',0xc287:'receive_byte',
         0xc2bd:'handshake',0xc2da:'transfer_sector',0xc354:'transfer_block',
         0xc369:'block_to_track_sector',0xc3d5:'interleave_sector',
         0xc450:'initialize_hardware',0xc4cf:'boot_entry',0xc500:'load_named_file',
         0xc622:'read_block_or_reset',0xc62f:'initialize_drive',0xc651:'open_drive_command',
         0xc65e:'open_drive_data'}


def byte_lines(data):
    return '\n'.join('    !byte ' + ','.join(f'${b:02x}' for b in data[i:i+16])
                     for i in range(0,len(data),16)) + '\n'


def main():
    boot_disk = Disk(ROOT / 'original' / DISKS[0][1])
    payloads = {e['name'].lower().replace('.','-'):read_file(boot_disk,e) for e in game_directory(boot_disk)}
    combat = read_resources(Disk(ROOT / 'original' / DISKS[1][1]))[0].payload
    engine_payloads = {s:payloads[s] for s in ('bardsubs1','bardsubs2')}
    engine_payloads['combat'] = combat
    engine_analysis = analyze_engine(engine_payloads)
    overlay_out = ROOT / 'src/overlays'
    overlay_out.mkdir(parents=True,exist_ok=True)
    (overlay_out / 'combat.asm').write_text(annotated_source(combat,0x9b00,engine_analysis,
        '; COMBAT -- resource 0; identical payload on character and dungeon disks.'))
    manifest = {'format':'35-track D64, 683 sectors, no error map', 'disks':{}, 'programs':{}, 'modules':{}, 'drive':{}, 'overlays':{'combat':{'size':len(combat),'sha256':hashlib.sha256(combat).hexdigest()}}}
    for slug, filename in DISKS:
        disk = Disk(ROOT / 'original' / filename)
        entries = list(disk.directory())
        substitutions = {}
        if slug == 'boot':
            for entry, stem in zip(entries, ('prodos','loader')):
                chain = list(disk.chain(entry['track'],entry['sector']))
                prg = b''.join(b for _,_,b in chain)
                base = int.from_bytes(prg[:2],'little')
                ranges = [(0x02d4,0x0300)] if stem == 'prodos' else RANGES
                names = {0x02d4:'bootstrap'} if stem == 'prodos' else NAMES
                text = '; Reconstructed from boot disk file '+entry['name']+'\n!cpu 6510\n* = $%04x\n    !word $%04x ; PRG load address\n' % (base-2,base)
                text += render(prg[2:],base,ranges,names)
                (ROOT / 'src' / 'boot' / (stem+'.asm')).write_text(text)
                consumed = 0
                for t,s,b in chain:
                    substitutions[t,s] = (stem,consumed,len(b))
                    consumed += len(b)
                manifest['programs'][stem] = dict(size=len(prg),sha256=hashlib.sha256(prg).hexdigest(),load_address=base,chain=[[t,s] for t,s,_ in chain])
        if slug == 'boot':
            game_out = ROOT / 'src/game'
            game_out.mkdir(parents=True,exist_ok=True)
            for entry in game_directory(disk):
                payload = read_file(disk,entry)
                stem = entry['name'].lower().replace('.','-')
                base = entry['load_address']
                if stem == 'bard64-system':
                    first = payload[:47]
                    relocated = payload[47:]
                    text = '; Startup code copies the remainder from $202f to $1800.\n!cpu 6510\n* = $2000\n'
                    text += render(first,0x2000,reachable_ranges(first,0x2000,[0x2000]),{})
                    text += '!pseudopc $1800 {\n'
                    text += render(relocated,0x1800,reachable_ranges(relocated,0x1800,[0x1800]),{})
                    text += '}\n'
                elif stem in ('bardsubs1','bardsubs2'):
                    text = annotated_source(payload,BASES[stem],engine_analysis,
                        '; '+entry['name']+' -- resident engine: code, packed text, tables, and state.\n'
                        '; Semantic names are inferred; see docs/game-code-and-assets.md.\n'
                        '; Raw bytes may include unresolved code or overlapping entry points.')
                elif stem in ('music64','dmusic64','splash64','util64'):
                    text = module_source(stem,payload)
                elif stem == 'bard3-pic64':
                    text = ('; BARD3.PIC64 -- main game interface picture, no code identified.\n'
                            '; 40x24 multicolor cells, 320x192 displayed pixels; background index 0.\n'
                            '; Startup copies screen from $3e00 and color bytes from $41c0.\n'
                            '!cpu 6510\n* = $2000\nbitmap_pixels:\n')
                    text += byte_lines(payload[:7680])
                    text += '\nscreen_color_pairs: ; $3e00, high/low nibbles for multicolor pixels 01/10\n'
                    text += byte_lines(payload[7680:8640])
                    text += '\ncell_colors: ; $41c0, low nibble for multicolor pixels 11\n'
                    text += byte_lines(payload[8640:])
                else:
                    text = '; '+entry['name']+'; directory auxiliary address $%04x.\n' % base
                    text += ('; Packed intro image consumed as data by SPLASH64 $480b.\n' if stem == 'mainpic64' else '; Apple II-oriented system payload; references $c000/$c082, not C64 engine code.\n')
                    text += '; Payload retained as data until runtime mapping is established.\n!cpu 6510\n* = $0000\n'
                    text += byte_lines(payload)
                (game_out / (stem+'.asm')).write_text(text)
                manifest['modules'][stem] = dict(entry, size=len(payload),sha256=hashlib.sha256(payload).hexdigest())
                # Replace only file payload bytes; retain original slack and index blocks.
                index = game_block(disk,entry['key_block']) if entry['storage'] == 2 else None
                for pos in range(0,len(payload),256):
                    n, half = divmod(pos//256,2)
                    number = (index[n] | index[n+256] << 8) if index is not None else entry['key_block']
                    if not number:
                        continue
                    sector = physical_sector(number*2+half)
                    if sector in substitutions:
                        raise ValueError('overlapping reconstructed files')
                    substitutions[sector] = ('game/'+stem,pos,min(256,len(payload)-pos))
            drive_out = ROOT / 'src/drive'
            drive_out.mkdir(parents=True,exist_ok=True)
            for stem, base, sectors in [('bootstrap',0x0700,[13]),('loader',0x0300,[14,15,16,17])]:
                payload = b''.join(disk.sector(18,s) for s in sectors)
                text = '; 1541 code; static flow only, runtime targets remain data.\n!cpu 6502\n* = $%04x\n' % base
                text += render(payload,base,reachable_ranges(payload,base,[base]),{})
                (drive_out / (stem+'.asm')).write_text(text)
                manifest['drive'][stem] = dict(size=len(payload),sha256=hashlib.sha256(payload).hexdigest())
                for n, sector in enumerate(sectors):
                    substitutions[18,sector] = ('drive/'+stem,n*256,256)
        if slug in ('character','dungeon-a','dungeon-b'):
            resource = read_resources(disk)[0]
            if resource.payload != combat:
                raise ValueError('combat overlay differs between disks')
            for pos in range(0,len(combat),256):
                logical = (512+resource.stream_offset+pos)//256
                substitutions[physical_sector(logical)] = ('overlays/combat',pos,min(256,len(combat)-pos))
        out = ROOT / 'src' / 'disks' / slug
        out.mkdir(parents=True,exist_ok=True)
        tracks = []
        for t, count in enumerate(SECTORS,1):
            lines = [f'; {filename}: physical track {t}, {count} sectors.',
                     '; Sector bytes are retained verbatim; no code/data assumptions.',
                     '!cpu 6510','* = $0000']
            for s in range(count):
                block = disk.sector(t,s)
                lines += [f'\ntrack_{t:02d}_sector_{s:02d}: ; D64 offset ${offset(t,s):05x}']
                if (t,s) in substitutions:
                    stem,skip,size = substitutions[t,s]
                    if '/' in stem:
                        prefix, name = stem.split('/')
                        lines += [f'    !binary "build/{prefix}/{name}.bin", {size}, {skip}']
                        if size < 256:
                            lines += [byte_lines(block[size:]).rstrip()]
                    else:
                        lines += [byte_lines(block[:2]).rstrip(),
                                  f'    !binary "build/boot/{stem}.prg", {size}, {skip}']
                        if size < 254:
                            lines += [byte_lines(block[2+size:]).rstrip()]
                else:
                    lines += [byte_lines(block).rstrip()]
            (out / f'track-{t:02d}.asm').write_text('\n'.join(lines)+'\n')
            raw = disk.data[offset(t,0):offset(t,0)+count*256]
            tracks.append(dict(track=t,sectors=count,sha256=hashlib.sha256(raw).hexdigest()))
        manifest['disks'][slug] = dict(original=filename,size=SIZE,sha256=hashlib.sha256(disk.data).hexdigest(),directory=entries,tracks=tracks)
    (ROOT / 'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')

if __name__ == '__main__':
    main()
