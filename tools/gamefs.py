"""Game block mapping reconstructed from boot loader $c369-$c44f.

This is a ProDOS-derived layout, not a claim of full Apple ProDOS compatibility.
"""
from d64 import SECTORS

INTERLEAVE = {
    21: [0,11,1,12,2,13,3,14,4,15,5,16,6,17,7,18,8,19,9,20,10],
    19: [0,11,3,14,6,17,9,1,12,4,15,7,18,10,2,13,5,16,8],
    18: [0,11,4,15,8,1,12,5,16,9,2,13,6,17,10,3,14,7],
    17: [0,11,5,16,10,4,15,9,3,14,8,2,13,7,1,12,6],
}


def physical_sector(logical):
    if not 0 <= logical < 683:
        raise ValueError(f'invalid logical sector {logical}')
    for track in range(1,36):
        if track == 18:
            continue
        count = SECTORS[track-1]
        if logical < count:
            return track, INTERLEAVE[count][logical]
        logical -= count
    return 18, 18-logical


def block(disk, number):
    return b''.join(disk.sector(*physical_sector(number*2+half)) for half in range(2))


def directory(disk):
    number = 2
    seen = set()
    while number:
        if number in seen:
            raise ValueError('cyclic game directory')
        seen.add(number)
        data = block(disk,number)
        for slot in range(13):
            raw = data[4+slot*39:4+(slot+1)*39]
            storage, length = raw[0] >> 4, raw[0] & 15
            if storage in (0, 0xe, 0xf):
                continue
            yield dict(name=raw[1:1+length].decode('ascii','replace'),storage=storage,
                       file_type=raw[16],key_block=int.from_bytes(raw[17:19],'little'),
                       blocks_used=int.from_bytes(raw[19:21],'little'),
                       eof=int.from_bytes(raw[21:24],'little'),
                       load_address=int.from_bytes(raw[31:33],'little'),
                       directory_block=number,slot=slot)
        number = int.from_bytes(data[2:4],'little')


def read_file(disk, entry):
    storage, key, size = entry['storage'], entry['key_block'], entry['eof']
    if storage == 1:
        if size > 512:
            raise ValueError('seedling file larger than one block')
        return block(disk,key)[:size]
    if storage != 2:
        raise ValueError(f'unsupported storage type {storage}')
    if size > 256*512:
        raise ValueError('sapling file larger than 256 blocks')
    index = block(disk,key)
    data = bytearray()
    for n in range((size+511)//512):
        pointer = index[n] | index[n+256] << 8
        data.extend(block(disk,pointer) if pointer else bytes(512))
    return bytes(data[:size])
