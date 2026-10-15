; Bard's Tale III (Boot Disk).d64: physical track 7, 21 sectors.
; Sector bytes are retained verbatim; no code/data assumptions.
!cpu 6510
* = $0000

track_07_sector_00: ; D64 offset $07e00
    !binary "build/game/bardsubs2.bin", 256, 4096

track_07_sector_01: ; D64 offset $07f00
    !binary "build/game/bardsubs2.bin", 256, 4608

track_07_sector_02: ; D64 offset $08000
    !binary "build/game/bardsubs2.bin", 256, 5120

track_07_sector_03: ; D64 offset $08100
    !binary "build/game/bardsubs2.bin", 256, 5632

track_07_sector_04: ; D64 offset $08200
    !binary "build/game/bardsubs2.bin", 256, 6144

track_07_sector_05: ; D64 offset $08300
    !binary "build/game/bardsubs2.bin", 256, 6656

track_07_sector_06: ; D64 offset $08400
    !binary "build/game/bardsubs2.bin", 256, 7168

track_07_sector_07: ; D64 offset $08500
    !binary "build/game/bardsubs2.bin", 256, 7680

track_07_sector_08: ; D64 offset $08600
    !binary "build/game/bardsubs2.bin", 256, 8192

track_07_sector_09: ; D64 offset $08700
    !binary "build/game/bardsubs2.bin", 256, 8704

track_07_sector_10: ; D64 offset $08800
    !binary "build/game/bardsubs2.bin", 256, 9216

track_07_sector_11: ; D64 offset $08900
    !binary "build/game/bardsubs2.bin", 256, 4352

track_07_sector_12: ; D64 offset $08a00
    !binary "build/game/bardsubs2.bin", 256, 4864

track_07_sector_13: ; D64 offset $08b00
    !binary "build/game/bardsubs2.bin", 256, 5376

track_07_sector_14: ; D64 offset $08c00
    !binary "build/game/bardsubs2.bin", 256, 5888

track_07_sector_15: ; D64 offset $08d00
    !binary "build/game/bardsubs2.bin", 256, 6400

track_07_sector_16: ; D64 offset $08e00
    !binary "build/game/bardsubs2.bin", 256, 6912

track_07_sector_17: ; D64 offset $08f00
    !binary "build/game/bardsubs2.bin", 256, 7424

track_07_sector_18: ; D64 offset $09000
    !binary "build/game/bardsubs2.bin", 256, 7936

track_07_sector_19: ; D64 offset $09100
    !binary "build/game/bardsubs2.bin", 256, 8448

track_07_sector_20: ; D64 offset $09200
    !binary "build/game/bardsubs2.bin", 256, 8960
