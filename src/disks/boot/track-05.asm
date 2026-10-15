; Bard's Tale III (Boot Disk).d64: physical track 5, 21 sectors.
; Sector bytes are retained verbatim; no code/data assumptions.
!cpu 6510
* = $0000

track_05_sector_00: ; D64 offset $05400
    !binary "build/game/bardsubs1.bin", 256, 5632

track_05_sector_01: ; D64 offset $05500
    !binary "build/game/bardsubs1.bin", 256, 6144

track_05_sector_02: ; D64 offset $05600
    !binary "build/game/bardsubs1.bin", 256, 6656

track_05_sector_03: ; D64 offset $05700
    !binary "build/game/bardsubs1.bin", 256, 7168

track_05_sector_04: ; D64 offset $05800
    !binary "build/game/bardsubs1.bin", 256, 7680

track_05_sector_05: ; D64 offset $05900
    !binary "build/game/bardsubs1.bin", 256, 8192

track_05_sector_06: ; D64 offset $05a00
    !binary "build/game/bardsubs1.bin", 256, 8704

track_05_sector_07: ; D64 offset $05b00
    !binary "build/game/bardsubs1.bin", 256, 9216

track_05_sector_08: ; D64 offset $05c00
    !binary "build/game/bardsubs1.bin", 256, 9728

track_05_sector_09: ; D64 offset $05d00
    !binary "build/game/bardsubs1.bin", 256, 10240

track_05_sector_10: ; D64 offset $05e00
    !binary "build/game/bardsubs1.bin", 256, 10752

track_05_sector_11: ; D64 offset $05f00
    !binary "build/game/bardsubs1.bin", 256, 5888

track_05_sector_12: ; D64 offset $06000
    !binary "build/game/bardsubs1.bin", 256, 6400

track_05_sector_13: ; D64 offset $06100
    !binary "build/game/bardsubs1.bin", 256, 6912

track_05_sector_14: ; D64 offset $06200
    !binary "build/game/bardsubs1.bin", 256, 7424

track_05_sector_15: ; D64 offset $06300
    !binary "build/game/bardsubs1.bin", 256, 7936

track_05_sector_16: ; D64 offset $06400
    !binary "build/game/bardsubs1.bin", 256, 8448

track_05_sector_17: ; D64 offset $06500
    !binary "build/game/bardsubs1.bin", 256, 8960

track_05_sector_18: ; D64 offset $06600
    !binary "build/game/bardsubs1.bin", 256, 9472

track_05_sector_19: ; D64 offset $06700
    !binary "build/game/bardsubs1.bin", 256, 9984

track_05_sector_20: ; D64 offset $06800
    !binary "build/game/bardsubs1.bin", 256, 10496
