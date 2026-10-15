; Bard's Tale III (Boot Disk).d64: physical track 10, 21 sectors.
; Sector bytes are retained verbatim; no code/data assumptions.
!cpu 6510
* = $0000

track_10_sector_00: ; D64 offset $0bd00
    !binary "build/game/splash64.bin", 256, 2304

track_10_sector_01: ; D64 offset $0be00
    !binary "build/game/splash64.bin", 256, 2816

track_10_sector_02: ; D64 offset $0bf00
    !binary "build/game/splash64.bin", 256, 3328

track_10_sector_03: ; D64 offset $0c000
    !binary "build/game/splash64.bin", 256, 3840

track_10_sector_04: ; D64 offset $0c100
    !binary "build/game/splash64.bin", 256, 4352

track_10_sector_05: ; D64 offset $0c200
    !binary "build/game/splash64.bin", 256, 4864

track_10_sector_06: ; D64 offset $0c300
    !binary "build/game/splash64.bin", 256, 5376

track_10_sector_07: ; D64 offset $0c400
    !binary "build/game/splash64.bin", 256, 5888

track_10_sector_08: ; D64 offset $0c500
    !binary "build/game/splash64.bin", 256, 6400

track_10_sector_09: ; D64 offset $0c600
    !binary "build/game/splash64.bin", 256, 6912

track_10_sector_10: ; D64 offset $0c700
    !binary "build/game/splash64.bin", 256, 7424

track_10_sector_11: ; D64 offset $0c800
    !binary "build/game/splash64.bin", 256, 2560

track_10_sector_12: ; D64 offset $0c900
    !binary "build/game/splash64.bin", 256, 3072

track_10_sector_13: ; D64 offset $0ca00
    !binary "build/game/splash64.bin", 256, 3584

track_10_sector_14: ; D64 offset $0cb00
    !binary "build/game/splash64.bin", 256, 4096

track_10_sector_15: ; D64 offset $0cc00
    !binary "build/game/splash64.bin", 256, 4608

track_10_sector_16: ; D64 offset $0cd00
    !binary "build/game/splash64.bin", 256, 5120

track_10_sector_17: ; D64 offset $0ce00
    !binary "build/game/splash64.bin", 256, 5632

track_10_sector_18: ; D64 offset $0cf00
    !binary "build/game/splash64.bin", 256, 6144

track_10_sector_19: ; D64 offset $0d000
    !binary "build/game/splash64.bin", 256, 6656

track_10_sector_20: ; D64 offset $0d100
    !binary "build/game/splash64.bin", 256, 7168
