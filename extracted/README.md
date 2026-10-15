# Extracted game data and media

Generated from the rebuilt D64/module files with `make extract`. The tools read
`build/`, never modify `original/`, and perform no downloads or hosted jobs.

The current export contains **575 monster records in 41 banks** (406 readable
names, 528 distinct complete records), **255 items**, **72 inline strings**,
**85 distinct portrait PNGs**, two other pictures, and two SID music files.
There are 131 portrait references across disks; identical images share a file.

## Data: JSON

| File | Contents |
| --- | --- |
| `data/monsters.json` | Monster banks, names, HP dice/bonus/range, initial group-count bits, four action descriptors, and all 48 original bytes per record. |
| `data/items.json` | 255 decoded item names, packed name bytes/addresses, and seven raw property values per item. Property arrays are keyed by memory address until their meanings are established. |
| `data/text.json` | Decoded inline strings with start/end addresses; actual text rather than Python-quoted representations. |
| `data/engine-tables.json` | Resource destinations, dice masks, party/monster record pointers, packed-text character map. |
| `data/resources.json` | Every index entry from each resource disk: ID, size, address, stream offset, disk reference, payload hash, and decoded classification when available. |
| `data/resource-payloads.json` | Exact stored bytes of present resources 29–383 as hexadecimal strings, including unresolved areas and paired animation streams. |
| `data/pictures.json` | Portrait-to-resource/file mapping, dimensions, palette byte, animation companion ID, and palette RGB values. |
| `data/music.json` | SID files, sequence/subtune-to-command mapping, native sequence addresses, export settings, and optional WAV preview metadata. |

JSON documents have `schema_version: 1`. Numbers are integers; memory addresses
use `$`-prefixed strings. Stored resource bytes use `stored_hex`. Monster
`raw_bytes` are integer arrays, so exact original record bytes can be recovered.

A monster's key is **disk + resource_id + slot**, not its name. Banks can repeat
names with different statistics. `name_template` retains the game's conditional
singular/plural syntax (`/` and `\`); `name` is its readable prefix. HP fields
follow the `$FA3B/$FA5A` calculation: `(low5 + 1)` dice, sides selected by the high
three bits, plus the little-endian bonus at offsets `$11/$12`, saturating at
65,535. Other statistics remain raw rather than receiving guessed names.

Monster banks decode to variable numbers of 48-byte records. The export stops
at the longest prefix decodable without reading outside the payload, requires
all compressed bytes to be consumed, validates complete record boundaries and
names, and omits the runtime loader's unverified final out-of-payload reads.

## Media: PNG, SID, and WAV

- `media/pictures/game-interface.png`: 320×192 main interface frame.
- `media/pictures/intro-bard.png`: 320×200 bard illustration.
- `media/pictures/portraits/`: 88×88 static portrait/scene images. Filenames use
  picture IDs and content hashes; use `data/pictures.json` to locate originals.
- `media/music/music64.sid` and `dmusic64.sid`: original player code and sequence
  data in PSID v2NG containers, with 17 selectable sequences each. Duplicate
  sequence pointers remain selectable to preserve the command mapping.
- `media/music/*.wav`: optional rendered previews of subtune 1, not full albums.
  See `data/music.json` for their measured durations and sample rates.

PNG is lossless. The RGB palette is illustrative; original color indexes and
source payloads are preserved. Portrait PNGs show the base frame; the paired
animation streams have not been decoded, so these are not fabricated GIFs.

SID is used instead of a lossy MIDI transcription. A small init/play adapter
selects original command IDs 4–20; the original 2,168-byte player remains intact.
Export settings use PAL video-frame timing, unknown SID chip model, and initial
instrument 1 (the observed intro default). These choices allow standalone
playback but do not reproduce every instrument/context selection from gameplay.
The format is checked against [libsidplayfp's PSID implementation](https://github.com/libsidplayfp/libsidplayfp/blob/master/src/sidtune/PSID.cpp).

The optional WAV previews use local sidplayfp emulation, mono 16-bit PCM at
22,050 Hz. The current previews measure 22 seconds for a requested 20-second
play interval. They are not recordings of a complete game session, and no
musical titles are inferred from command IDs.

## Regeneration and verification

```sh
make extract          # rebuild and export JSON, PNG, SID; Python + ACME only
make extract-audio    # also render WAV previews; requires local sidplayfp
make verify           # compare every rebuilt module, track and disk to originals' hashes
make test             # decoder, record, picture, SID and export integrity tests
```

The audio exporter recognizes `sidplayfp` on PATH or the project-local executable
`.tools/sidplayfp/usr/bin/sidplayfp`. Configuration/cache paths for this subprocess
are kept inside the project. Nothing is downloaded by either export command.

These commands overwrite generated filenames; keep manual annotations outside
them. Running without audio rendering leaves any existing WAV files on disk,
but the current manifest only lists files produced by the requested export.
`manifest.json` records source hashes, counts, generated file sizes, and SHA-256
hashes. The manifest does not hash itself or this manually maintained guide.

Individual item bitfields, map/area records, portrait animations, complete sound
effect coverage, and some monster fields still need further reverse engineering.
Their stored bytes are retained explicitly for that work.
