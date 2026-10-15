# Game code and assets

The files contain a mixture of instructions, pictures, music-player data,
compressed text, lookup tables, and mutable state. A `.bin` extension does not
mean “asset,” and a `.asm` extension does not mean every byte is code. The
classifications below come from local loader calls, control flow, data accesses,
and two successfully decoded picture previews. No game execution has been
observed in an emulator during this pass.

## Where to start reading

| Source | What is established |
| --- | --- |
| `src/game/bardsubs1.asm` | Resident engine at `$6600`: resource loading, text/input helpers, decompression, party-record access, and other logic. Contains inline compressed strings, tables, state, and unresolved code too. |
| `src/game/bardsubs2.asm` | Mixed resident tables and logic at `$CD00`. Startup at `$FF5B`, raster IRQ at `$FD8A`, keyboard scanning, timers, and further game routines. `$CD00` itself is data. |
| `src/overlays/combat.asm` | Resource 0, loaded at `$9B00`: combat menus, party/enemy action dispatch, hit/miss text, spell/item paths, battle rewards. Identical bytes on all three resource disks. |
| `src/game/bard3-pic64.asm` | Main interface frame: bitmap plus screen/color planes. No executable code identified. |
| `src/game/mainpic64.asm` | Compressed bard illustration read by the intro's picture decoder. No executable code identified. |
| `src/game/splash64.asm` | Intro program at `$4000`, with executable display/animation/input code, fonts/tables, and other presentation data. Not just an image. |
| `src/game/music64.asm` | SID player plus music data, loaded at `$4800` and copied to `$C480`. Five JMP vectors lead into executable player code. |
| `src/game/dmusic64.asm` | SID player plus music data at `$E000`, called by the intro. Not a sampled audio file. |
| `src/game/util64.asm` | Executable utility module at `$2000`, called by startup. Detailed menu/record responsibilities remain unresolved. |
| `src/game/bard-system.asm` | Apple II-oriented system payload with `$C000/$C082` I/O references. Preserved separately; not classified as C64 engine code. |

These are reconstructed names and roles, not original source symbols. Each
instruction retains its address and bytes. Comments describe inputs, outputs,
important state, self-modification, and remaining uncertainty. Branch labels are
kept; ordinary fall-through instructions no longer each have a separate label.
Unresolved bytes remain `!byte`, including overlapping instruction tricks.

## BARDSUBS1 reading guide

Start at `enter_engine` (`$6600`), then `load_resource_by_id` (`$668D`). Engine
modes select resource IDs and cache some choices in zero page. Exits through
`restart_overlay_with_clean_stack` reset SP to `$FF` and jump to `$9B00`; these
are deliberate overlay transitions rather than normal subroutine returns.
`load_cached_overlay_x` (`$667D`) similarly loads a resource and jumps to `$9300`.

Resource loading scans a size index at `$4000`, sums earlier payload sizes into
a 24-bit stream offset, selects an output address, and either copies bytes or
expands a compressed resource. Its important state is:

| Address | Role established from code |
| --- | --- |
| `$35`, `$6AD2` | Resource ID low/high bytes |
| `$BE4B/$BE4C` | Destination pointer |
| `$BE4D/$BE4E` | Resource byte count |
| `$BE55/$BE56/$BE57` | Stream byte offset, low to high |
| `$BA00/$BB00` | 512-byte block staging area |
| `$46/$47` | Logical block number passed to loader |
| `$44/$45` | Block transfer buffer address |
| `$67AE/$67AF` | Patched operand of `write_resource_byte`'s STA |
| `$833C/$833D` | Patched source operand of resource bit reader |
| `$7503/$7504` | Packed-text input cursor / patched operand |

`read_resource_bytes` (`$6917`) turns a stream byte offset into a 512-byte block
number and adds one. Partial first/last blocks use staging RAM; full blocks can
be read straight into their destination. `$6AAC` calls the `$BE7A` wrapper,
which reaches the boot loader's `$C208` block API.

### Inline data that looks like instructions

Three calling conventions must be recognized to read this engine correctly:

```asm
    jsr print_inline_packed_text    ; $7407, or $740a without display reset
    !byte ...                      ; packed text bits, NOT executable code
    ; execution resumes at the byte after the packed terminator

    jsr for_each_party_member_inline ; $6f16
    !word callback                 ; NOT instructions
    ; helper calls callback for seven party slots

    jsr read_input_with_inline_flags ; $8b0f
    !byte flags_1, flags_2
    ; some flag combinations also introduce a variable filter table
```

The printer pulls the caller's return address, advances through packed text,
and jumps to the updated cursor. Packed symbols use five bits, MSB first:
0 terminates, 30 requests a case shift, and 31 introduces a six-bit escape.
The translation table is at `$749A`. `$AF/$DC` character delimiters select
conditional text according to `$4F`; exported strings preserve these markers
as `/` and `\` rather than guessing which alternative is displayed.

The party callback helper skips the inline address on the stack, patches a
JSR, and visits X=0,2,...,12. `$91E4` obtains party-record pointers from `$D522`.
The actual pointer values are `$3E00,$3E80,$3F00,$3F80,$BF00,$BF80,$1F80`.
Startup clears 120 bytes in each record. Individual gameplay field names are
not yet established well enough to apply broadly.

The input helper always consumes two flag bytes; flag bit `$40` can introduce
additional filtering data. Static discovery stops that fall-through path until
the variable table is understood, rather than turning it into invented code.

## Resource disks and overlays

The resource disks have IDs 1 (character), 2 (dungeon A), and 3 (dungeon B) in
the last byte of logical block zero. Their game stream starts at logical block
1. The first `$300` bytes are 384 little-endian size entries. Ordinary payloads
follow consecutively; size `$0000` means absent data, and `$FFxx` is a reference
to disk ID `~xx`, not a 65KB payload. This explains the empty DOS directories:
the engine does not use them for its resources.

The index describes these resource classes, using the tables at `$678F` and
`$686E` in BARDSUBS1:

| IDs | Address selected | Classification |
| --- | --- | --- |
| 0–3 | `$9B00` | Executable overlays with embedded data; 0 is combat |
| 4–12 | `$9300` | Executable overlays with embedded data |
| 13–22 | `$A800` | Executable overlays with embedded data |
| 23–28 | `$AD00` | Executable overlays with embedded data |
| 29–99 | `$1040` | Compressed game/area resource buffers; record fields not decoded |
| 100–104 | `$4780` | Compressed resource buffers; precise asset semantics unresolved |
| 105–145 | `$4300` | Compressed resource buffers; precise asset semantics unresolved |
| 146–383 | `$0800` | Picture-related resources; the engine can load pairs and change whether decoding is applied |

For compressed classes the address is the final destination, not necessarily
the temporary address where compressed bytes are staged. Classification is
based on loader behavior. It does not prove that all data in a compressed
resource is graphics, nor that a code overlay contains only instructions.

| Disk | Present code overlays | Present later resources | Disk references | Empty entries |
| --- | --- | --- | --- | --- |
| Character | 21 | 96 | 106 | 161 |
| Dungeon A | 13 | 139 | 77 | 155 |
| Dungeon B | 14 | 139 | 93 | 138 |

The standalone combat source is included in all three disk rebuilds, so edits
to it propagate to all three copies. Other resources are exported individually
by `make inspect`; their original track sources remain authoritative. Code
can share addresses across different overlays, so analysis must keep the
resource ID and current resident memory map in mind.

## Pictures and sound

`BARD3.PIC64` has 40×24 multicolor cells, or 320×192 display pixels. Its 9,600
bytes split into 7,680 bitmap bytes, 960 screen bytes (two color nibbles per
cell), and 960 color RAM bytes (low nibble used). Startup's source addresses
`$3E00` and `$41C0` establish the plane offsets. The decoded image shows the
main interface borders and labels. Background index zero comes from display
initialization; preview RGB colors use an illustrative C64 palette.

`MAINPIC64` is the bard illustration. SPLASH64 `$480B` reads a 20-byte dictionary
then variable-length dictionary, literal, and repeat tokens. The caller XORs
each decoded byte with the previous output and plots through its address
tables. Its embedded rectangle specifies 6,048 writes. The implemented decoder
consumes all 3,099 compressed bytes and produces a recognizable bard image.
The token reader resembles BARDSUBS1 `$82B8`; XOR prediction belongs to the
picture plotting caller and must not be assumed for every resource.

The music modules write SID voice frequency, pulse width, waveform/gate,
envelope, filter, and volume registers. `$BA` is a command mailbox: its high
bit marks a pending command. The engine raster IRQ at `$FD8A` calls the player
vector at `$C48C`, while the intro calls `$E00C`. Comments identify these
hardware writes. Song/instrument table formats and the complete sound-effect
system remain unresolved; no WAV/audio rendering is claimed.

BARDSUBS2 extends through RAM beneath the I/O and KERNAL windows. A `$Dxxx`
access while `$01=$34` accesses RAM tables rather than VIC/SID/CIA registers.
The IRQ temporarily exposes I/O for device accesses and restores the old
mapping. Address alone is insufficient to classify a table as sound data.

## Reproduce and inspect

```sh
make verify       # exact PRG/module/overlay/track/disk hash comparisons
make test         # 11 geometry, decoder, code/data-boundary and integration checks
make inspect      # rebuild; export catalog, exact resources, strings and previews
```

The exports are under `build/inspection/`:

- `resources.json`: all 384 entries for each resource disk, destinations, disk
  references, sizes, offsets, payload hashes, and extracted file paths.
- `character/`, `dungeon-a/`, `dungeon-b/`: exact present resource binaries.
- `inline-text.json`: 72 decoded inline strings with source and end addresses.
- `code-coverage.json`: number of bytes represented as identified instructions.
- `bard3-pic64.png`: main interface frame.
- `mainpic64.png`: intro bard illustration.

Static discovery currently represents 5,647 of BARDSUBS1's 11,511 bytes, 2,193 of
BARDSUBS2's 13,000 bytes, and 4,940 of combat's 7,205 bytes as instructions.
**The remainder is not a measurement of asset size:** it includes confirmed
tables/strings, unresolved executable code, and overlapping entry points.
These counts describe the current analysis, not a complete code census.

The knowledge and comments live in `tools/game_analysis.py` and are applied
by `make import`, so regenerating from the originals retains these annotations.
Import still overwrites manual source edits; update the analysis knowledge as
well when promoting a routine's interpretation. Runtime verification, fuller
input-filter decoding, the other overlays, map/character record fields, and
music sequencing remain the main open areas.
