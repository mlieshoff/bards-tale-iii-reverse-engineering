; Bard's Tale III (Boot Disk).d64: physical track 15, 21 sectors.
; Sector bytes are retained verbatim; no code/data assumptions.
!cpu 6510
* = $0000

track_15_sector_00: ; D64 offset $12600
    !binary "build/game/util64.bin", 256, 1024

track_15_sector_01: ; D64 offset $12700
    !binary "build/game/util64.bin", 256, 1536

track_15_sector_02: ; D64 offset $12800
    !binary "build/game/util64.bin", 256, 2048

track_15_sector_03: ; D64 offset $12900
    !binary "build/game/util64.bin", 256, 2560

track_15_sector_04: ; D64 offset $12a00
    !binary "build/game/util64.bin", 256, 3072

track_15_sector_05: ; D64 offset $12b00
    !binary "build/game/util64.bin", 256, 3584

track_15_sector_06: ; D64 offset $12c00
    !binary "build/game/util64.bin", 256, 4096

track_15_sector_07: ; D64 offset $12d00
    !binary "build/game/util64.bin", 256, 4608

track_15_sector_08: ; D64 offset $12e00
    !binary "build/game/util64.bin", 256, 5120

track_15_sector_09: ; D64 offset $12f00
    !binary "build/game/util64.bin", 256, 5632

track_15_sector_10: ; D64 offset $13000
    !binary "build/game/util64.bin", 256, 6144

track_15_sector_11: ; D64 offset $13100
    !binary "build/game/util64.bin", 256, 1280

track_15_sector_12: ; D64 offset $13200
    !binary "build/game/util64.bin", 256, 1792

track_15_sector_13: ; D64 offset $13300
    !binary "build/game/util64.bin", 256, 2304

track_15_sector_14: ; D64 offset $13400
    !binary "build/game/util64.bin", 256, 2816

track_15_sector_15: ; D64 offset $13500
    !binary "build/game/util64.bin", 256, 3328

track_15_sector_16: ; D64 offset $13600
    !binary "build/game/util64.bin", 256, 3840

track_15_sector_17: ; D64 offset $13700
    !binary "build/game/util64.bin", 256, 4352

track_15_sector_18: ; D64 offset $13800
    !binary "build/game/util64.bin", 256, 4864

track_15_sector_19: ; D64 offset $13900
    !binary "build/game/util64.bin", 256, 5376

track_15_sector_20: ; D64 offset $13a00
    !binary "build/game/util64.bin", 256, 5888
