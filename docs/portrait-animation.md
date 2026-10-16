# Portrait animation format

The static PNG is only the base image. BARDSUBS1 `$68c9` takes a **picture
index** in X and loads resources `146 + 2*X` (base image) and `147 + 2*X`
(animation). The base is drawn by `$8232` with cumulative XOR decoding.
The companion is decompressed separately into `$0800` using the normal
resource token decoder. It is not another complete picture.

The first eight decoded companion bytes are four little-endian track offsets,
relative to `$0800`. Zero disables a track. `$8352/$8365` initialize tracks
with a one-update countdown; `$83af/$83d7` update tracks in order 3, 2, 1, 0.
Each track stores a cursor and countdown. When its countdown reaches zero:

1. Read a two-byte patch offset, relative to `$0800`.
2. Apply the patch using `$842e`.
3. Read a delay byte. Nonzero saves the next cursor and delay. Zero reads
   another delay byte and restarts at the track's original offset.

A patch starts at byte-column 3, pixel-scanline 6. Each nonzero byte is XORed
into the bitmap using the `$d180/$d248` scanline and `$d310/$d3b0` column
address tables. Scanlines advance first, wrapping at 94 to scanline 6 of the
next column, ending after column 13. A zero byte introduces two coordinates:
column, scanline. Column 255 terminates the patch. Some patches address bytes
just outside the portrait crop; the decoder preserves those bitmap writes.

The native code reads a scanline byte even after column 255, then discards it.
Some stored streams end immediately after the 255. The exporter stops on that
marker without fabricating the unused byte or reading beyond the resource.
All meaningful pointers, coordinates, and command reads are checked.

`$83af` normally uses a six-IRQ countdown at `$fe05`, decremented by `$fdba`.
However, game callers can bypass/force timing (`$83aa`, `$8f91`) and polling
can delay updates. APNG previews assume PAL 50 Hz, or 120 ms per scheduler
update; this is illustrative timing, not a recorded gameplay cadence.

## Exports

Open `extracted/animations.html` in a browser. `data/pictures.json` retains
static `file` paths and adds `animation.file`, `frame_count`, track count,
resource hash, decoded size, timing, loop detection, and truncation metadata.
There are 125 animated references sharing 80 unique APNG files; six references
have empty companions. Animations can share a base image but differ in tracks,
so animation deduplication includes the companion data.

Previews play once, ending on the last frame. Reload to replay. They are bounded
to 256 scheduler updates (about 31 seconds) or stop when the **entire** state
repeats, including all four cursors, countdowns, and bitmap bytes. Tracks can
have long combined periods; `truncated: true` means the preview ended before
a complete combined cycle was established. This is not a claim that the game's
animation ends. The first APNG frame is the original base image.

`make extract` regenerates the files with Python's standard library, without
Pillow or an image converter. Tests cover XOR, delays, restarts, coordinate
changes, short end markers, invalid pointers, and APNG structure/CRCs.
