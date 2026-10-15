# Disk and boot reconstruction

## Evidence and limits

The four input images are each 174,848 bytes: 35 physical tracks, 683 sectors,
256 bytes per sector, no appended error table. Full-image, per-track, and
extracted-file SHA-256 hashes are recorded in `manifest.json`. ACME rebuilds
all bytes, including unused space and sector tails, without the input images.
This verifies binary identity, not execution in a C64/1541 emulator. VICE is
not installed in the current environment; no runtime testing has been done.

Instruction ranges in the C64 loader were identified from its entry vectors,
branches, calls, and surrounding tables. The game startup and drive sources
use static flow traversal from established entry addresses. Indirect jumps,
self-modifying operands, copied code, and runtime-only entry points require
further analysis. Remaining bytes are data directives even where they may
contain executable code. Symbol names describe inferred roles, not original
source symbols.

## Physical layout

Tracks 1–17 have 21 sectors each, 18–24 have 19, 25–30 have 18, and 31–35
have 17. Track 18 sector 0 contains the BAM and volume label. The ordinary
Commodore directory starts at 18/1. Only the boot disk exposes normal files:

| File | Start | Sector chain | PRG load address | PRG bytes |
| --- | --- | --- | --- | --- |
| PRODOS | 18/2 | 18/2 | `$02BC` | 74 |
| 2.0 | 18/3 | 18/3 through 18/12 | `$C000` | 2540 |

The directory entries on the character and dungeon disks are empty. Their
sector contents are preserved but their game-specific records are not yet
decoded. In particular, treating logical block 2 on those disks as the boot
disk's directory produces invalid records; they must not be classified as
empty or unused disks.

## C64 bootstrap

`PRODOS` loads at `$02BC`, overlapping BASIC/KERNAL input state rather than
being an ordinary BASIC program at `$0801`. It contains a tokenized LOAD line
(with a next-line pointer `$0812`) followed by the filename `2.0`. That BASIC
link alone does not establish how the original boot exploit is triggered.
The trailing words are both `$02D4`, which is the machine-code entry address.
The exact mechanism for transferring control there remains to be checked at
runtime.

At `$02D4`, the bootstrap blanks VIC display control `$D011` and border
`$D020`, calls KERNAL SETLFS with logical file 2/device 8/secondary 1, SETNAM
with `2.0` at `$02D1`, and LOAD with A=0. It sets the processor port to `$36`
and its direction register to `$2F`, then jumps to `$C20E`.

The file `2.0` begins with a 256-byte byte permutation table at `$C000`,
followed by raster/handshake data at `$C100`. Do not disassemble these tables
as instructions. The jump vectors are:

| Vector | Target | Inferred role |
| --- | --- | --- |
| `$C208` | `$C354` | transfer a logical 512-byte block |
| `$C20B` | `$C500` | look up and load a named game file |
| `$C20E` | `$C4CF` | initialize and boot |
| `$C211` | `$C2DA` | transfer a physical sector |

The boot entry initializes VIC/CIA state, stack, and drive communications,
then calls `$C500` with the high-bit filename at `$C4F2` (`BARD64.SYSTEM`).
On success it jumps to `$2000`; failure loops at `$C4EF`.

`$C217` sends a byte through CIA2 `$DD00`; `$C287` receives using raster
synchronization and the `$C000` lookup table. `$C2DA` saves the memory mapping
and sprite-enable register, patches transfer buffer operands using zero-page
`$44/$45`, and switches `$01` between `$34/$35` while accessing RAM under I/O.
Its command comes from `$42`. `$C354` transfers the two halves of a block,
using the carry flag to select the half. Block number is in `$46/$47`.

## Logical block filesystem

The loader's `$C369` routine maps `2 * block_number + half` to a sector.
Tracks are visited in physical order with track 18 skipped. Within each
track, the tables at `$C405`, `$C41A`, `$C42D`, and `$C43F` permute sector
numbers for the four track sizes. After the 664 non-directory sectors,
logical sectors 664–682 map to track 18 sectors 18 down to 0.
`tools/gamefs.py` implements this mapping; a test verifies it is a bijection
over every physical sector.

On the boot disk, block 2 begins the volume directory `BARDS.TALE3.64`.
Directory blocks have previous/next pointers in their first four bytes and
thirteen 39-byte records. The loader compares high-bit filenames while
ignoring bit 7. Relevant record fields are storage type/name length at 0,
name at 1, key block at 17, EOF at 21, and load address at 31. Storage type 1
is direct data; type 2 uses a 512-byte index with low pointer bytes in its
first half and high bytes in its second. All ten actual boot files use type 2.
The small extractor supports those two types, not a general ProDOS volume.

| File | Bytes | Directory load address | Key block |
| --- | --- | --- | --- |
| BARD64.SYSTEM | 715 | `$2000` | 8 |
| BARD3.PIC64 | 9600 | `$2000` | 10 |
| BARDSUBS1 | 11511 | `$6600` | 31 |
| BARDSUBS2 | 13000 | `$CD00` | 55 |
| MAINPIC64 | 3099 | `$0800` | 81 |
| SPLASH64 | 27390 | `$4000` | 89 |
| UTIL64 | 6652 | `$2000` | 144 |
| MUSIC64 | 2168 | `$4800` | 158 |
| DMUSIC64 | 2168 | `$E000` | 164 |
| BARD.SYSTEM | 1143 | `$0000` | 171 |

These load addresses are directory metadata, not proof of a module's runtime
address. `MUSIC64`, for example, contains initial JMPs into `$C4xx` despite
its auxiliary address `$4800`. `BARD.SYSTEM` contains Apple II I/O references;
it is preserved as a separate payload without assuming it is C64 code.

`BARD64.SYSTEM` starts at `$2000`, saves a byte from its own `$2003` to `$034E`,
and copies eight pages from `$202F` to `$1800`, then jumps to `$1800`. The file
itself supplies only 668 bytes after that prefix: the copy also reads beyond
the loaded file. Its ACME source uses `!pseudopc $1800` for statically reachable
relocated instructions while retaining the original file layout.

## 1541 drive side

The C64 loader opens channel 2 with `#`, then sends `B-E 2 0 18 13` on command
channel 15. Physical sector 18/13 is the drive bootstrap. It installs an RTS
at `$0300`, uses a JSR and a stack-derived source-page address to copy its
own sector to `$0700`, and jumps to `$0724`. The source uses the relocated
address for this bootstrap; the initial execution buffer address is not
assumed. It prepares four read jobs with tracks/sectors 18/14–18/17 and then
jumps to `$0300`. Those sectors supply the four pages `$0300`–`$06FF`.
The main drive entry starts `SEI; LDX #$45; TXS`. It uses the 1541 VIA registers
in `$1800` and `$1C00` and calls DOS ROM routines. Static disassembly does not
yet establish all timing constraints, write paths, or supported drive models.

## Build arrangement and remaining work

Each physical track is assembled independently at address zero, then joined
in order. This avoids representing a 174,848-byte disk as a single 64K CPU
address space. Boot sectors include slices of the assembled boot PRGs, game
files, and drive binaries. Index blocks, file slack, directories, BAM bytes,
and all other sectors remain explicitly represented in track sources.

The next analysis should trace booting in VICE with true-drive emulation,
identify runtime-only code entries and relocation, label engine APIs in
BARDSUBS1/BARDSUBS2, decode image/music formats, and recover the character and
dungeon disks' record/index structures. Those areas are preserved exactly
but are not semantically reverse engineered by this initial reconstruction.
