#!/usr/bin/env python3
"""Read the game resource index used by BARDSUBS1 ($668d/$6917)."""
from dataclasses import dataclass
from gamefs import block
from game_analysis import BitReader

THRESHOLDS = (0,4,13,23,29,100,105,146)
DESTINATIONS = (0x9b00,0x9300,0xa800,0xad00,0x1040,0x4780,0x4300,0x0800)
TOKEN_CODES = (0,1,4,5,6,7,8,9,10,22,23,24,25,26,27,28,29,60,61,62)


@dataclass(frozen=True)
class Resource:
    number: int
    size: int
    stream_offset: int
    destination: int
    kind: str
    disk_id: int | None
    payload: bytes


def read_resources(disk):
    disk_id = block(disk,0)[-1]
    if disk_id not in (1,2,3):
        raise ValueError('not a character/dungeon resource disk')
    # The engine adds one to the block derived from its byte stream offset.
    stream = b''.join(block(disk,n) for n in range(1,341))
    offset = 0x300
    result = []
    for n in range(384):
        size = int.from_bytes(stream[n*2:n*2+2],'little')
        category = max(i for i,start in enumerate(THRESHOLDS) if n>=start)
        destination = DESTINATIONS[category]
        if size >> 8 == 0xff:
            result.append(Resource(n,size,offset,destination,'disk-reference',(~size)&255,b''))
            continue
        if offset+size > len(stream):
            raise ValueError(f'resource {n}: data extends beyond supported block stream')
        kind = 'empty' if size==0 else 'code-overlay' if category<4 else 'compressed-resource'
        result.append(Resource(n,size,offset,destination,kind,None,stream[offset:offset+size]))
        offset += size
    return result


def decode_resource_bytes(data, count):
    """Translate the shared dictionary/run token reader; bound output explicitly.

SPLASH64 supplies a plotting rectangle rather than an in-band end marker.
The resident engine uses a different source-cursor stop rule; do not infer
its final output length from this helper alone.
"""
    if not 0 <= count <= 65536:
        raise ValueError('invalid decompressed output size')
    bits = BitReader(data)
    dictionary = [bits.read(8) for _ in range(20)]
    repeat, value = 0, 0

    def next_byte():
        nonlocal repeat,value
        if repeat:
            repeat -= 1
            return value
        if bits.read(1)==0:
            return bits.read(8)
        code = bits.read(3)
        for width in range(3,7):
            indices = range(0,2) if width==3 else range(2,9) if width==4 else range(9,17) if width==5 else range(17,20)
            for i in indices:
                if code==TOKEN_CODES[i]:
                    return dictionary[i]
            if width<6:
                code=code*2+bits.read(1)
        repeat=(bits.read(8) or 256)-1
        value=bits.read(8)
        return value

    return bytes(next_byte() for _ in range(count)), bits.end
