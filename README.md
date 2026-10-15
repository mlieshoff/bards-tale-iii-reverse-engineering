# bards-tale-iii-reverse-engineering

Reverse engineering The Bard's Tale III for the Commodore 64, including the
6502/6510 engine, 1541 fast loader, and disk formats.

All four supplied D64 images can now be rebuilt **byte-for-byte with ACME**.
The boot chain, resident engine routines, combat overlay, intro, and SID
players have commented instruction-level assembly. Unknown code and assets
remain explicit `!byte` data. This is a reproducible
reconstruction and an initial reverse engineering pass, not a fully understood
game engine. See [the disk/boot notes](docs/reverse-engineering.md) and
[the game code and asset guide](docs/game-code-and-assets.md).

Requires Python 3.10+ and the free [ACME assembler](https://sourceforge.net/projects/acme-crossass/).
No paid services, GitHub Actions, or other hosted jobs are needed.

```sh
make                  # assemble all programs and the four D64s
make verify           # additionally compare every track, file, and disk to recorded hashes
make test             # geometry, decoder, code/data-boundary, and integration checks
make inspect          # resource catalog, exact payloads, decoded text, picture previews
```

If ACME is not on PATH, use `ACME=/path/to/acme make verify`. The build also
recognizes a project-local executable at `.tools/acme/usr/bin/acme`.
Outputs are `build/boot.d64`, `build/character.d64`, `build/dungeon-a.d64`, and
`build/dungeon-b.d64`, plus boot PRGs, extracted game binaries, and drive code.
Normal builds do **not** read `original/` and do not download anything.

- `src/boot/`: boot PRGs, including the C64 fast loader at `$C000`.
- `src/drive/`: 1541 bootstrap and four-sector loader.
- `src/game/`: commented engine, music, intro, and ten hidden boot-disk files.
- `src/overlays/`: commented combat overlay recovered from the resource disks.
- `src/disks/`: physical track sources preserving directories, free space, and slack.
- `manifest.json`: original SHA-256 hashes, sector geometry, and file metadata.
- `tools/`: D64 reader, logical block reader, source importer, disassembler, and builder.

Edit the assembly under `src/` and run `make`. Program payloads are incorporated
into the boot disk by its track sources. Keep output sizes fixed: directory,
index, and allocation metadata are preserved, not automatically reallocated.
`make verify` deliberately fails after changes to original bytes.

`make import` regenerates sources and the manifest from the four local images
in `original/`. **It overwrites source edits**; use it only to repeat the initial
import. Neither originals nor generated build outputs, downloaded tools, or IDE
settings are tracked. Original files are never modified by these tools.
