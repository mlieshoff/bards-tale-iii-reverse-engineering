#!/usr/bin/env python3
"""Assemble standalone PRGs and physical tracks, then join tracks into D64s."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verify',action='store_true',help='compare complete outputs to recorded SHA-256 hashes')
    args = parser.parse_args()
    os.chdir(ROOT)
    acme = os.environ.get('ACME') or shutil.which('acme')
    local = ROOT / '.tools/acme/usr/bin/acme'
    if not acme and local.is_file():
        acme = str(local)
    if not acme:
        raise SystemExit('ACME is required. Install the free ACME assembler or set ACME=/path/to/acme.')
    manifest = json.loads((ROOT / 'manifest.json').read_text())
    failures = []

    def check(path, expected):
        data = path.read_bytes()
        digest = hashlib.sha256(data).hexdigest()
        if len(data) != expected['size'] or digest != expected['sha256']:
            failures.append(str(path))
        else:
            print(f'OK {path}: {len(data)} bytes, SHA-256 {digest}')

    def assemble(source, output):
        output.parent.mkdir(parents=True,exist_ok=True)
        subprocess.run([acme,'-f','plain','-o',str(output),str(source)],check=True)

    for stem, entry in manifest['programs'].items():
        target = Path('build/boot') / (stem+'.prg')
        assemble(Path('src/boot') / (stem+'.asm'),target)
        if args.verify:
            check(target,entry)
    for group, folder in [('modules','game'),('drive','drive'),('overlays','overlays')]:
        for stem, entry in manifest[group].items():
            target = Path('build') / folder / (stem+'.bin')
            assemble(Path('src') / folder / (stem+'.asm'),target)
            if args.verify:
                check(target,entry)
    for slug, entry in manifest['disks'].items():
        chunks = []
        for track in entry['tracks']:
            stem = f"track-{track['track']:02d}"
            target = Path('build/tracks') / slug / (stem+'.bin')
            assemble(Path('src/disks') / slug / (stem+'.asm'),target)
            data = target.read_bytes()
            if len(data) != track['sectors']*256:
                raise SystemExit(f'{target}: changed track size; cannot create valid D64')
            if args.verify and hashlib.sha256(data).hexdigest() != track['sha256']:
                failures.append(str(target))
            chunks.append(data)
        target = Path('build') / (slug+'.d64')
        target.write_bytes(b''.join(chunks))
        if args.verify:
            check(target,entry)
        else:
            print(f'Built {target}')
    if failures:
        raise SystemExit('Original-byte verification failed: '+', '.join(failures))

if __name__ == '__main__':
    main()
