#!/usr/bin/env python3
"""Reproducible JSON/PNG/SID exports from rebuilt game images, never originals."""
import argparse
import ast
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import struct
import subprocess
import wave

from d64 import Disk
from game_analysis import analyze_engine, packed_text
from inspect_assets import PALETTE, picture_rgb, intro_picture, multicolor_rgb, png_rgb
from resources import read_resources, decode_resource_bytes, THRESHOLDS, DESTINATIONS

ROOT = Path(__file__).resolve().parents[1]
DISKS = ('character', 'dungeon-a', 'dungeon-b')


# C64 table layout; see docs/item-and-monster-fields.md for reference comparisons.
ITEM_TABLES = {
    'maximum_charges': 0xe273,
    'melee_damage_dice': 0xe373,
    'armor_and_damage_bonus': 0xe473,
    'type_and_attack_effect': 0xe573,
    'usable_classes_mask': 0xe673,
    'equipped_effect': 0xe773,
    'use_effect_id': 0xe873,
}
ITEM_TYPES = ('item', 'weapon', 'shield', 'armor', 'helm', 'gloves',
              'instrument', 'figurine', 'ring', 'wand', 'item', 'bow',
              'quiver', 'container', 'armor')


def dice_range(value, masks):
    """The common C64 $fa5a roll: low five bits count, high three bits sides."""
    count, sides = (value & 31) + 1, masks[value >> 5] + 1
    return dict(dice_count=count, dice_sides=sides, minimum=count, maximum=count*sides)


def monster_action(opcode, parameter, masks):
    action = dict(opcode=opcode, parameter=parameter)
    if opcode < 0x80:
        action['kind'] = 'spell'
        action['spell_id'] = opcode
    elif 0xf0 <= opcode <= 0xf9:
        action['kind'] = 'physical_attack'
        action['attack_effect_code'] = opcode - 0xf0
        action['damage'] = dice_range(parameter, masks)
    else:
        action['kind'] = 'special'
    return action


def digest(data):
    return hashlib.sha256(data).hexdigest()


def decoded_prefix(data, limit):
    """Longest strictly decodable prefix, with no reads past payload or invented padding.

The resident caller's two final decoder calls can read past the resource.
Those calls are intentionally not reproduced without runtime memory evidence.
"""
    low, high = 0, limit
    while low < high:
        mid = (low + high + 1) // 2
        try:
            decode_resource_bytes(data, mid)
            low = mid
        except ValueError as error:
            if str(error) != 'truncated bit stream':
                raise
            high = mid - 1
    result, consumed = decode_resource_bytes(data, low)
    return result, consumed


def monster_records(data, masks):
    if not data or len(data) % 48:
        raise ValueError('monster payload does not contain complete 48-byte records')
    result = []
    for index in range(len(data) // 48):
        record = data[index * 48:(index + 1) * 48]
        name_bytes = record[:16].split(b'\xff', 1)[0]
        if not name_bytes or any(not 32 <= (b & 127) < 127 for b in name_bytes):
            raise ValueError(f'invalid monster name in record {index}')
        template = ''.join(chr(b & 127) for b in name_bytes)
        # $fa5a: (low five bits + 1) rolls of (mask[high three bits] + 1).
        dice = record[16]
        rolls = (dice & 31) + 1
        sides = masks[dice >> 5] + 1
        bonus = int.from_bytes(record[17:19], 'little')
        result.append(dict(slot=index, runtime_address=f'${0x4300 + index * 48:04x}',
                           name=re.split(r'[/\\]', template)[0], name_template=template,
                           hit_points=dict(dice_count=rolls, dice_sides=sides, bonus=bonus,
                                           minimum=min(65535, rolls + bonus),
                                           maximum=min(65535, rolls * sides + bonus)),
                           initial_group_count_low5=record[21] & 31,
                           distance=dict(current_10_feet=record[19] & 15,
                                         advance_10_feet=record[19] >> 4),
                           portrait_resource_id=record[32],
                           actions=[monster_action(record[n], record[n+1], masks)
                                    for n in range(22,30,2)],
                           action_descriptors=[list(record[n:n + 2]) for n in range(22,30,2)],
                           raw_bytes=list(record)))
    return result


def item_records(subs1, subs2):
    charset = subs1[0x749a - 0x6600:0x74f7 - 0x6600]
    offset = 0xda74 - 0xcd00
    result = []
    for item_id in range(1, 256):
        text, end = packed_text(subs2, offset, charset)
        if not text:
            raise ValueError(f'item-name list ends at {item_id}')
        properties = {name: subs2[table - 0xcd00 + item_id]
                      for name, table in ITEM_TABLES.items()}
        masks = subs2[0xcd68 - 0xcd00:0xcd70 - 0xcd00]
        damage = dice_range(properties['melee_damage_dice'], masks)
        damage['bonus'] = properties['armor_and_damage_bonus'] >> 4
        damage['minimum'] += damage['bonus']
        damage['maximum'] += damage['bonus']
        type_code = properties['type_and_attack_effect'] & 15
        result.append(dict(id=item_id, name=text, name_address=f'${offset + 0xcd00:04x}',
                           packed_name_hex=subs2[offset:end].hex(),
                           properties=properties,
                           item_type=ITEM_TYPES[type_code] if type_code < len(ITEM_TYPES) else 'unknown',
                           item_type_code=type_code,
                           armor_class_reduction=properties['armor_and_damage_bonus'] & 15,
                           attack_effect_code=properties['type_and_attack_effect'] >> 4,
                           melee_damage=damage if type_code == 1 else None))
        offset = end
    text, _ = packed_text(subs2, offset, charset)
    if text or offset + 0xcd00 != 0xe272:
        raise ValueError('item-name list boundary changed')
    return result


def portrait_rgb(payload, subs1, subs2, frame):
    """Replicate $8232 plotting and $8ae6 screen colors; retain frame color RAM."""
    left, right, top, bottom = subs1[0x8281-0x6600:0x8285-0x6600]
    decoded, consumed = decode_resource_bytes(payload[1:], (right-left)*(bottom-top+1))
    bitmap = bytearray(8000)
    previous = 0
    index = 0
    for col in range(top, bottom+1):
        for line in range(left, right):
            address = (subs2[0xd180-0xcd00+line] | subs2[0xd248-0xcd00+line] << 8)
            address += (subs2[0xd310-0xcd00+col*4] | subs2[0xd3b0-0xcd00+col*4] << 8)
            previous ^= decoded[index]
            index += 1
            if not 0x2000 <= address < 0x3f40:
                raise ValueError('portrait write outside bitmap')
            bitmap[address-0x2000] = previous
    screen = bytearray(1000)
    colors = bytearray(1000)
    screen[:960] = frame[7680:8640]
    colors[:960] = frame[8640:]
    for row in range(1,12):
        for col in range(3,14):
            screen[row*40+col] = payload[0]
    rgb = multicolor_rgb(bitmap, screen, colors, 25)
    width, height = (bottom-top+1)*8, right-left
    cropped = b''.join(rgb[(y*320+top*8)*3:(y*320+top*8+width)*3] for y in range(left,right))
    return width, height, cropped, consumed+1


def sid_file(payload, base, title):
    """PSID v2NG: original player plus small command-mailbox init/play adapter.

Subtunes 1..17 select observed sequence table commands 4..20. PAL VBI timing
is an explicit export choice, not a recovered platform setting.
"""
    if len(payload) != 2168:
        raise ValueError('unexpected SID module size')
    pointers = [int.from_bytes(payload[0xf9+n*2:0xfb+n*2], 'little') for n in range(4,21)]
    if any(not base <= address < base+len(payload) for address in pointers):
        raise ValueError('SID sequence pointer outside original module')
    load = base-128
    tick = base+12
    jsr_tick = bytes([0x20,tick & 255,tick >> 8])
    # Save A (zero-based subtune), expose I/O while retaining RAM at $e000,
    # enable volume, choose instrument 1 (intro startup default), reset player.
    init = bytes.fromhex('48 a9 35 85 01 a9 ff 85 33 a9 01 85 bd a9 00 85 bf a9 80 85 ba')
    init += jsr_tick
    init += bytes.fromhex('68 18 69 84 85 ba')+jsr_tick+bytes([0x60])
    play = bytes([0xa9,0x35,0x85,0x01,0x4c,tick & 255,tick >> 8])
    adapter = init + bytes(64-len(init)) + play + bytes(64-len(play))
    header = bytearray(124)
    header[:4] = b'PSID'
    struct.pack_into('>7HI',header,4,2,124,load,load,load+64,17,1,0)
    header[22:54] = title.encode('ascii')[:32].ljust(32,b'\0')
    header[54:86] = b'Unknown / original game'.ljust(32,b'\0')
    header[86:118] = b'The Bard\'s Tale III'.ljust(32,b'\0')
    struct.pack_into('>H',header,118,4)  # PAL; SID model left unknown.
    return bytes(header)+adapter+payload


def render_wav(player, sid, target, seconds, config_dir):
    env = dict(os.environ)
    env['XDG_CONFIG_HOME'] = str(config_dir)
    env['XDG_DATA_HOME'] = str(config_dir/'data')
    local_lib = ROOT/'.tools/sidplayfp/usr/lib/x86_64-linux-gnu'
    if local_lib.is_dir() and Path(player).resolve() == (ROOT/'.tools/sidplayfp/usr/bin/sidplayfp').resolve():
        env['LD_LIBRARY_PATH'] = str(local_lib)+(':'+env['LD_LIBRARY_PATH'] if env.get('LD_LIBRARY_PATH') else '')
    config_dir.mkdir(parents=True,exist_ok=True)
    result = subprocess.run([str(player),'-q2','-os1',f'-t{seconds}','-f22050','-m',
                             '-p16',f'-w{target}',str(sid)],env=env,capture_output=True,text=True,timeout=120)
    if result.returncode:
        raise ValueError('SID rendering failed: '+result.stdout+result.stderr)
    with wave.open(str(target),'rb') as audio:
        pcm = audio.readframes(audio.getnframes())
        if not any(pcm):
            raise ValueError('SID preview is silent')
        return dict(seconds=audio.getnframes()/audio.getframerate(),
                    sample_rate=audio.getframerate(),channels=audio.getnchannels(),
                    subtune=1,engine='sidplayfp',note='Preview only; complete player/sequence data is in the SID file.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--wav-seconds', type=int, default=0,
                        help='also render subtune 1 previews with a locally installed sidplayfp (1..120 seconds)')
    args = parser.parse_args()
    if not 0 <= args.wav_seconds <= 120:
        parser.error('--wav-seconds must be 0..120')
    out = ROOT/'extracted'
    data_dir, media_dir = out/'data', out/'media'
    data_dir.mkdir(parents=True, exist_ok=True)
    media_dir.mkdir(parents=True, exist_ok=True)
    exported = []

    def json_out(path, value):
        path = out/path
        path.parent.mkdir(parents=True,exist_ok=True)
        path.write_text(json.dumps(value,indent=2,ensure_ascii=False)+'\n')
        exported.append(path)

    def picture(path, width, height, pixels):
        path = media_dir/path
        path.parent.mkdir(parents=True,exist_ok=True)
        png_rgb(path,width,height,pixels)
        exported.append(path)

    modules = {p.stem:p.read_bytes() for p in (ROOT/'build/game').glob('*.bin')}
    subs1, subs2 = modules['bardsubs1'], modules['bardsubs2']
    masks = list(subs2[0xcd68-0xcd00:0xcd70-0xcd00])
    resources = {slug:read_resources(Disk(ROOT/f'build/{slug}.d64')) for slug in DISKS}
    monsters, catalog, portrait_index, raw_resources = [], {}, [], []
    portrait_hashes = {}
    for slug, records in resources.items():
        catalog[slug] = []
        for r in records:
            entry = dict(id=r.number,kind=r.kind,stored_size=r.size,stream_offset=r.stream_offset,
                         destination=f'${r.destination:04x}',required_disk=r.disk_id)
            if r.payload:
                entry['sha256'] = digest(r.payload)
            catalog[slug].append(entry)
            if not r.payload:
                continue
            if 105 <= r.number < 146:
                decoded, consumed = decoded_prefix(r.payload,1152)
                if len(decoded) == 1152 or consumed != len(r.payload):
                    raise ValueError(f'{slug}/{r.number}: ambiguous monster-bank endpoint')
                bank = dict(disk=slug,resource_id=r.number,stored_sha256=digest(r.payload),
                            decoded_size=len(decoded),decoded_sha256=digest(decoded),
                            endpoint='longest strict prefix; all bytes consumed; complete 48-byte records',
                            records=monster_records(decoded,masks))
                monsters.append(bank)
                entry['decoded_as'] = 'monster-bank'
            elif r.number >= 146 and r.number % 2 == 0:
                width,height,rgb,consumed = portrait_rgb(r.payload,subs1,subs2,modules['bard3-pic64'])
                if consumed != len(r.payload):
                    raise ValueError(f'{slug}/{r.number}: portrait has unexplained trailing data')
                key = digest(struct.pack('>HH',width,height)+rgb)
                if key not in portrait_hashes:
                    path = Path('pictures/portraits')/f'picture-{(r.number-146)//2:03d}-{key[:10]}.png'
                    picture(path,width,height,rgb)
                    portrait_hashes[key] = 'media/'+path.as_posix()
                portrait_index.append(dict(disk=slug,resource_id=r.number,picture_id=(r.number-146)//2,
                                           file=portrait_hashes[key],width=width,height=height,
                                           palette_byte=r.payload[0],stored_sha256=digest(r.payload),
                                           animation_resource_id=r.number+1,
                                           animation_status='paired stream not animated; static base image exported'))
                entry['decoded_as'] = 'static-picture'
            if r.number >= 29:
                raw_resources.append(dict(disk=slug,resource_id=r.number,stored_hex=r.payload.hex(),
                                          note='Exact stored resource, before decompression. See catalog for classification.'))
    json_out(Path('data/monsters.json'),dict(schema_version=2,record_size=48,
        field_evidence=dict(name='first 16 bytes; $ff padding/termination; unpacked printer',
                            hit_points='$fa3b/$fa5a: byte $10 dice plus little-endian $11/$12 bonus; saturates at 65535',
                            initial_group_count_low5='$a20f..$a233 and $f9df; low five bits of $15',
                            action_descriptors='$9f2b..$9f3d: four opcode/parameter pairs at $16..$1d',
                            actions='$9f40..$9f6e: spell IDs below $80; $f0..$f9 physical attack effect and damage dice via $ad83/$fa5a',
                            distance='$a053/$a0af: $13 low nibble current distance, high nibble advance, in 10-foot units',
                            portrait_resource_id='$b377..$b37c: byte $20 passed to picture-pair loader $68c9'),
        notes=['Names retain conditional singular/plural syntax in name_template.',
               'name is the readable prefix, not a guaranteed complete grammatical singular.',
               'Unresolved statistics remain in raw_bytes; see docs/item-and-monster-fields.md.',
               'Banks are context-specific; repeated names can have different values.'],banks=monsters))
    json_out(Path('data/items.json'),dict(schema_version=2,names_source='$da74..$e272 in BARDSUBS2',
        properties_note='Named C64 property bytes; packed fields retain all bits. See docs/item-and-monster-fields.md. Zero damage bytes are dice encodings, not absence of damage; melee_damage is only exposed for weapons.',
        property_sources={name: f'${address:04x}' for name, address in ITEM_TABLES.items()},
        field_notes=dict(maximum_charges='255 means unlimited/nondepleting; finite loot charges may be randomized; zero remains raw',
                         armor_and_damage_bonus='low nibble AC reduction; high nibble melee damage bonus',
                         type_and_attack_effect='low nibble item category; high nibble attack effect code',
                         usable_classes_mask='shared class bits; tested against class-mask table at $d987, not one bit per class',
                         equipped_effect='low nibble equipped-effect selector; upper bits retained, unresolved',
                         use_effect_id='spell/special-use effect ID; 255 is no use effect'),
        records=item_records(subs1,subs2)))
    analysis = analyze_engine(dict(bardsubs1=subs1,bardsubs2=subs2,combat=resources['character'][0].payload))
    json_out(Path('data/text.json'),dict(schema_version=1,strings=[
        dict(address=f'${address:04x}',end=f'${end:04x}',text=ast.literal_eval(note.removeprefix('Packed text: ')))
        for address,(end,note) in sorted(analysis.inline.items()) if note.startswith('Packed text: ')]))
    json_out(Path('data/resources.json'),dict(schema_version=1,disks=catalog))
    json_out(Path('data/resource-payloads.json'),dict(schema_version=1,encoding='hex',resources=raw_resources))
    json_out(Path('data/pictures.json'),dict(schema_version=1,palette_rgb=PALETTE,
        background_index=0,portraits=portrait_index,
        notes=['RGB palette is illustrative; source color indices are retained.',
               'Animations are not decoded; PNG files show base images only.']))
    json_out(Path('data/engine-tables.json'),dict(schema_version=1,tables=[
        dict(name='resource_classes',source='$686e/$678f',values=[dict(first_id=n,destination=f'${d:04x}')
            for n,d in zip(THRESHOLDS,DESTINATIONS)]),
        dict(name='random_dice_masks',source='$cd68',values=masks),
        dict(name='party_record_pointers',source='$d522',values=[int.from_bytes(subs2[n-0xcd00:n-0xcd00+2],'little')
            for n in range(0xd522,0xd530,2)]),
        dict(name='monster_record_pointers',source='$d53e',values=[int.from_bytes(subs2[n-0xcd00:n-0xcd00+2],'little')
            for n in range(0xd53e,0xd56e,2)]),
        dict(name='packed_text_character_map',source='$749a',values=list(subs1[0x749a-0x6600:0x74f7-0x6600]))]))
    picture(Path('pictures/game-interface.png'),320,192,picture_rgb(modules['bard3-pic64']))
    intro,consumed = intro_picture(modules['mainpic64'],modules['splash64'])
    picture(Path('pictures/intro-bard.png'),320,200,multicolor_rgb(intro,bytes([0x86])*1000,bytes([1])*1000,25))
    music = []
    player = shutil.which('sidplayfp')
    local_player = ROOT/'.tools/sidplayfp/usr/bin/sidplayfp'
    if not player and local_player.exists():
        player = str(local_player)
    if args.wav_seconds and not player:
        raise SystemExit('WAV requested but sidplayfp is unavailable; install it locally. No downloads are performed.')
    for stem,base in [('music64',0xc480),('dmusic64',0xe000)]:
        payload = modules[stem]
        path = media_dir/'music'/f'{stem}.sid'
        path.parent.mkdir(parents=True,exist_ok=True)
        path.write_bytes(sid_file(payload,base,f"Bard's Tale III - {stem}"))
        exported.append(path)
        item = dict(module=stem,file='media/music/'+path.name,original_sha256=digest(payload),
                    format='PSID v2NG',clock='PAL VBI (export choice)',initial_instrument=1,
                    note='Native player/data preserved. Command IDs 4..20; duplicate sequence addresses retained.',
                    subtunes=[dict(subtune=n-3,command=n,sequence_address=f'${int.from_bytes(payload[0xf9+n*2:0xfb+n*2],"little"):04x}')
                              for n in range(4,21)])
        if args.wav_seconds:
            wav_path = path.with_suffix('.wav')
            item['preview'] = dict(file='media/music/'+wav_path.name,
                **render_wav(player,path,wav_path,args.wav_seconds,ROOT/'.tools/sidplayfp/config'))
            exported.append(wav_path)
        music.append(item)
    json_out(Path('data/music.json'),dict(schema_version=1,modules=music,
        note='SID chosen instead of lossy MIDI conversion. WAV files, when requested, are finite previews of subtune 1.'))
    summary = dict(schema_version=1,source='ACME-rebuilt D64/module files',
                   source_disks={slug:digest((ROOT/f'build/{slug}.d64').read_bytes()) for slug in ('boot',*DISKS)},
                   source_modules={name:digest(payload) for name,payload in sorted(modules.items())},
                   counts=dict(monster_banks=len(monsters),monster_records=sum(len(b['records']) for b in monsters),
                               distinct_monster_names=len({r['name'] for b in monsters for r in b['records']}),
                               distinct_monster_records=len({bytes(r['raw_bytes']) for b in monsters for r in b['records']}),
                               items=255,inline_strings=sum(n.startswith('Packed text: ') for _,n in analysis.inline.values()),
                               portrait_references=len(portrait_index),unique_portrait_pngs=len(portrait_hashes),sid_files=2),
                   files=[dict(path=str(p.relative_to(out)),size=p.stat().st_size,sha256=digest(p.read_bytes()))
                          for p in sorted(exported)])
    (out/'manifest.json').write_text(json.dumps(summary,indent=2)+'\n')
    print(json.dumps(summary['counts'],indent=2))
    print('Exported JSON data and PNG/SID media to extracted/.')


if __name__ == '__main__':
    main()
