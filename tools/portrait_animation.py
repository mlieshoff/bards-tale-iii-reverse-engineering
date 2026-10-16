"""Bounded translation of BARDSUBS1 $8352..$8488 portrait animation.

No CPU emulation or reads past decoded resource bytes. Timing is an illustrative
PAL preview: scheduler calls can also be forced by game code.
"""
import struct
import zlib


def animation_steps(data, bitmap, address, max_ticks=256):
    """Return (bitmap, duration-in-scheduler-ticks) snapshots and playback metadata."""
    def byte(offset):
        if not 0 <= offset < len(data):
            raise ValueError(f'animation read outside decoded resource: {offset}')
        return data[offset]

    def word(offset):
        return byte(offset) | byte(offset+1) << 8

    starts = [word(i*2) for i in range(4)]
    cursors = starts[:]
    waits = [int(bool(p)) for p in starts]
    active = [bool(p) for p in starts]
    bitmap = bytearray(bitmap)
    frames = [[bytes(bitmap), 1]]
    seen = {}
    loop_start = None
    patch_count = 0
    for tick in range(max_ticks):
        state = (tuple(cursors), tuple(waits), bytes(bitmap))
        if state in seen:
            loop_start = seen[state]
            break
        seen[state] = tick
        for track in range(3, -1, -1):
            if not active[track]:
                continue
            if waits[track]:
                waits[track] -= 1
                if waits[track]:
                    continue
            cursor = cursors[track]
            patch = word(cursor)
            cursor += 2
            col, line = 3, 6
            # $842e scans column first, then pixel scanline, across 11x88 bytes.
            for _ in range(4096):
                value = byte(patch)
                patch += 1
                if value == 0:
                    col = byte(patch)
                    patch += 1
                    if col == 255:
                        # $8468 reads a final X byte, but $846c discards it when
                        # Y=$ff. Some resources end here: no invented padding.
                        break
                    line = byte(patch)
                    patch += 1
                else:
                    if not (0 <= col < 40 and 0 <= line < 200):
                        raise ValueError(f'animation coordinate outside bitmap: {col}, {line}')
                    target = address(col, line)
                    if not 0 <= target < len(bitmap):
                        raise ValueError('animation write outside bitmap')
                    bitmap[target] ^= value
                    line += 1
                    if line >= 94:
                        line = 6
                        col += 1
                        if col > 13:
                            break
            else:
                raise ValueError('animation patch did not terminate')
            patch_count += 1
            delay = byte(cursor)
            cursor += 1
            if delay == 0:
                delay = byte(cursor)
                cursor = starts[track]
            cursors[track], waits[track] = cursor, delay
        current = bytes(bitmap)
        if current == frames[-1][0]:
            frames[-1][1] += 1
        else:
            frames.append([current, 1])
    return frames, dict(active_tracks=sum(active), scheduler_ticks=sum(f[1] for f in frames),
                        patch_applications=patch_count, loop_start_tick=loop_start,
                        truncated=loop_start is None and any(active),
                        timing_note='Illustrative PAL timing: 6 video frames per scheduler tick (120 ms); game polling/forced updates can differ.')


def apng_rgb(path, width, height, frames):
    """Write RGB APNG using stdlib only; play bounded preview once."""
    def chunk(kind, data):
        return struct.pack('>I', len(data))+kind+data+struct.pack('>I', zlib.crc32(kind+data)&0xffffffff)

    output = bytearray(b'\x89PNG\r\n\x1a\n')
    output += chunk(b'IHDR', struct.pack('>IIBBBBB', width,height,8,2,0,0,0))
    output += chunk(b'acTL', struct.pack('>II',len(frames),1))
    sequence = 0
    for index, (pixels, ticks) in enumerate(frames):
        if len(pixels) != width*height*3:
            raise ValueError('invalid animation RGB frame size')
        output += chunk(b'fcTL', struct.pack('>IIIIIHHBB',sequence,width,height,0,0,ticks*6,50,0,0))
        sequence += 1
        rows = b''.join(b'\0'+pixels[y*width*3:(y+1)*width*3] for y in range(height))
        compressed = zlib.compress(rows)
        if index == 0:
            output += chunk(b'IDAT',compressed)
        else:
            output += chunk(b'fdAT',struct.pack('>I',sequence)+compressed)
            sequence += 1
    output += chunk(b'IEND',b'')
    path.write_bytes(output)
