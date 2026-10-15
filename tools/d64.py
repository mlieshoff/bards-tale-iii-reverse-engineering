"""Strict, read-only parsing of 35-track Commodore 1541 D64 images."""
from pathlib import Path

SECTORS = tuple(21 if t <= 17 else 19 if t <= 24 else 18 if t <= 30 else 17
                for t in range(1, 36))
SIZE = sum(SECTORS) * 256


def offset(track, sector):
    if not 1 <= track <= 35 or not 0 <= sector < SECTORS[track - 1]:
        raise ValueError(f'invalid sector {track}/{sector}')
    return (sum(SECTORS[:track - 1]) + sector) * 256


class Disk:
    def __init__(self, path):
        self.path = Path(path)
        self.data = self.path.read_bytes()
        if len(self.data) != SIZE:
            raise ValueError(f'{path}: expected {SIZE} bytes, got {len(self.data)}')

    def sector(self, track, sector):
        start = offset(track, sector)
        return self.data[start:start + 256]

    def chain(self, track, sector):
        seen = set()
        while track:
            if (track, sector) in seen:
                raise ValueError(f'cyclic chain at {track}/{sector}')
            seen.add((track, sector))
            block = self.sector(track, sector)
            if block[0] == 0 and block[1] == 0:
                raise ValueError(f'invalid final sector length at {track}/{sector}')
            count = 254 if block[0] else block[1] - 1
            yield track, sector, block[2:2 + count]
            track, sector = block[:2]

    def directory(self):
        track, sector = self.sector(18, 0)[:2]
        seen = set()
        while track:
            if (track, sector) in seen:
                raise ValueError('cyclic directory')
            seen.add((track, sector))
            block = self.sector(track, sector)
            for slot in range(8):
                entry = block[slot * 32:(slot + 1) * 32]
                if entry[2]:
                    yield dict(type=entry[2], track=entry[3], sector=entry[4],
                               name=entry[5:21].rstrip(b'\xa0').decode('ascii', 'replace'),
                               blocks=int.from_bytes(entry[30:32], 'little'))
            track, sector = block[:2]
