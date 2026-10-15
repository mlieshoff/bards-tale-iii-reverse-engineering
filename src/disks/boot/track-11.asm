; Bard's Tale III (Boot Disk).d64: physical track 11, 21 sectors.
; Sector bytes are retained verbatim; no code/data assumptions.
!cpu 6510
* = $0000

track_11_sector_00: ; D64 offset $0d200
    !binary "build/game/splash64.bin", 256, 7680

track_11_sector_01: ; D64 offset $0d300
    !binary "build/game/splash64.bin", 256, 8192

track_11_sector_02: ; D64 offset $0d400
    !binary "build/game/splash64.bin", 256, 8704

track_11_sector_03: ; D64 offset $0d500
    !binary "build/game/splash64.bin", 256, 9216

track_11_sector_04: ; D64 offset $0d600
    !binary "build/game/splash64.bin", 256, 9728

track_11_sector_05: ; D64 offset $0d700
    !binary "build/game/splash64.bin", 256, 10240

track_11_sector_06: ; D64 offset $0d800
    !binary "build/game/splash64.bin", 256, 10752

track_11_sector_07: ; D64 offset $0d900
    !binary "build/game/splash64.bin", 256, 11264

track_11_sector_08: ; D64 offset $0da00
    !binary "build/game/splash64.bin", 256, 11776

track_11_sector_09: ; D64 offset $0db00
    !binary "build/game/splash64.bin", 256, 12288

track_11_sector_10: ; D64 offset $0dc00
    !binary "build/game/splash64.bin", 256, 12800

track_11_sector_11: ; D64 offset $0dd00
    !binary "build/game/splash64.bin", 256, 7936

track_11_sector_12: ; D64 offset $0de00
    !binary "build/game/splash64.bin", 256, 8448

track_11_sector_13: ; D64 offset $0df00
    !binary "build/game/splash64.bin", 256, 8960

track_11_sector_14: ; D64 offset $0e000
    !binary "build/game/splash64.bin", 256, 9472

track_11_sector_15: ; D64 offset $0e100
    !binary "build/game/splash64.bin", 256, 9984

track_11_sector_16: ; D64 offset $0e200
    !binary "build/game/splash64.bin", 256, 10496

track_11_sector_17: ; D64 offset $0e300
    !binary "build/game/splash64.bin", 256, 11008

track_11_sector_18: ; D64 offset $0e400
    !binary "build/game/splash64.bin", 256, 11520

track_11_sector_19: ; D64 offset $0e500
    !binary "build/game/splash64.bin", 256, 12032

track_11_sector_20: ; D64 offset $0e600
    !binary "build/game/splash64.bin", 256, 12544
