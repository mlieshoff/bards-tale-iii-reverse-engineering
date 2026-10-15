#!/usr/bin/env python3
"""Export a resource catalog, exact payloads, and a boot-picture preview.

Reads rebuilt files only. All exports go under build/inspection/.
"""
import hashlib
import json
from pathlib import Path
import struct
import zlib
from d64 import Disk
from resources import read_resources, decode_resource_bytes
from game_analysis import analyze_engine, BASES

ROOT=Path(__file__).resolve().parents[1]
# Illustrative C64 palette; colors vary with display/emulation, bytes do not.
PALETTE=['000000','ffffff','813338','75cec8','8e3c97','56ac4d','2e2c9b','edf171',
         '8e5029','553800','c46c71','4a4a4a','7b7b7b','a9ff9f','706deb','b2b2b2']


def picture_rgb(payload):
    """40x24 multicolor cells: 7680 bitmap + 960 screen + 960 color bytes."""
    return multicolor_rgb(payload[:7680],payload[7680:8640],payload[8640:],24)


def multicolor_rgb(bitmap, screen, color, cell_rows):
    if len(bitmap)!=cell_rows*320 or len(screen)!=cell_rows*40 or len(color)!=cell_rows*40:
        raise ValueError('incorrect multicolor plane sizes')
    pixels=bytearray()
    palette=[bytes.fromhex(s) for s in PALETTE]
    for y in range(cell_rows*8):
        row,line=divmod(y,8)
        for x in range(40):
            cell=row*40+x
            colors=[0,screen[cell]>>4,screen[cell]&15,color[cell]&15]
            value=bitmap[cell*8+line]
            for shift in (6,4,2,0):
                rgb=palette[colors[(value>>shift)&3]]
                pixels.extend(rgb*2)
    return bytes(pixels)


def intro_picture(mainpic, splash):
    """Reproduce $480b plotting: byte coordinates and address tables from SPLASH64."""
    left,right,top,bottom=splash[0x7df:0x7e3]
    decoded, consumed=decode_resource_bytes(mainpic,(right-left)*(bottom-top+1))
    bitmap=bytearray(8000)
    previous=0
    n=0
    for y in range(top,bottom+1):
        for x in range(left,right):
            address=(splash[0x929+x] | splash[0x9f1+x]<<8)
            address+=(splash[0xab9+y*4] | splash[0xb59+y*4]<<8)
            previous ^= decoded[n]
            n+=1
            if not 0x2000<=address<0x3f40:
                raise ValueError('intro plot outside bitmap')
            bitmap[address-0x2000]=previous
    return bytes(bitmap),consumed


def png_rgb(path,width,height,pixels):
    if len(pixels)!=width*height*3:
        raise ValueError('incorrect RGB buffer size')
    def chunk(kind,data):
        return struct.pack('>I',len(data))+kind+data+struct.pack('>I',zlib.crc32(kind+data)&0xffffffff)
    rows=b''.join(b'\0'+pixels[y*width*3:(y+1)*width*3] for y in range(height))
    path.write_bytes(b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',width,height,8,2,0,0,0))+
                     chunk(b'IDAT',zlib.compress(rows))+chunk(b'IEND',b''))


def main():
    out=ROOT/'build/inspection'
    out.mkdir(parents=True,exist_ok=True)
    catalog={}
    payloads={s:(ROOT/f'build/game/{s}.bin').read_bytes() for s in ('bardsubs1','bardsubs2')}
    for slug in ('character','dungeon-a','dungeon-b'):
        folder=out/slug
        folder.mkdir(exist_ok=True)
        records=[]
        for r in read_resources(Disk(ROOT/f'build/{slug}.d64')):
            item=dict(id=r.number,kind=r.kind,size=r.size,stream_offset=r.stream_offset,
                      destination=f'${r.destination:04x}',required_disk=r.disk_id)
            if r.payload:
                path=folder/f'resource-{r.number:03d}.bin'
                path.write_bytes(r.payload)
                item['sha256']=hashlib.sha256(r.payload).hexdigest()
                item['file']=str(path.relative_to(ROOT))
            records.append(item)
            if slug=='character' and r.number==0:
                payloads['combat']=r.payload
        catalog[slug]=records
    analysis=analyze_engine(payloads)
    texts=[dict(address=f'${a:04x}',end=f'${z:04x}',text=note.removeprefix('Packed text: '))
           for a,(z,note) in sorted(analysis.inline.items()) if note.startswith('Packed text: ')]
    (out/'resources.json').write_text(json.dumps(catalog,indent=2)+'\n')
    (out/'inline-text.json').write_text(json.dumps(texts,indent=2)+'\n')
    summary={stem:dict(bytes=len(data),instruction_bytes=sum(len(info[3]) for pc,info in analysis.code.items()
                     if BASES[stem]<=pc<BASES[stem]+len(data))) for stem,data in payloads.items()}
    (out/'code-coverage.json').write_text(json.dumps(summary,indent=2)+'\n')
    png_rgb(out/'bard3-pic64.png',320,192,picture_rgb((ROOT/'build/game/bard3-pic64.bin').read_bytes()))
    intro,consumed=intro_picture((ROOT/'build/game/mainpic64.bin').read_bytes(),
                                  (ROOT/'build/game/splash64.bin').read_bytes())
    png_rgb(out/'mainpic64.png',320,200,multicolor_rgb(intro,bytes([0x86])*1000,bytes([1])*1000,25))
    print(f'Intro picture: {consumed} compressed bytes consumed, 6048 bitmap writes')
    print(f'Exported resource catalog, {len(texts)} inline strings, and picture preview to {out.relative_to(ROOT)}')
    for slug,records in catalog.items():
        print(slug+': '+', '.join(f'{sum(r["kind"]==k for r in records)} {k}' for k in
                                  ('code-overlay','compressed-resource','disk-reference','empty')))

if __name__=='__main__':
    main()
