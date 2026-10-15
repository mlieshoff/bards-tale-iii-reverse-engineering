; Bard's Tale III (Boot Disk).d64: physical track 12, 21 sectors.
; Sector bytes are retained verbatim; no code/data assumptions.
!cpu 6510
* = $0000

track_12_sector_00: ; D64 offset $0e700
    !binary "build/game/splash64.bin", 256, 13056

track_12_sector_01: ; D64 offset $0e800
    !binary "build/game/splash64.bin", 256, 13568

track_12_sector_02: ; D64 offset $0e900
    !binary "build/game/splash64.bin", 256, 14080

track_12_sector_03: ; D64 offset $0ea00
    !binary "build/game/splash64.bin", 256, 14592

track_12_sector_04: ; D64 offset $0eb00
    !binary "build/game/splash64.bin", 256, 15104

track_12_sector_05: ; D64 offset $0ec00
    !binary "build/game/splash64.bin", 256, 15616

track_12_sector_06: ; D64 offset $0ed00
    !binary "build/game/splash64.bin", 256, 16128

track_12_sector_07: ; D64 offset $0ee00
    !binary "build/game/splash64.bin", 256, 16640

track_12_sector_08: ; D64 offset $0ef00
    !binary "build/game/splash64.bin", 256, 17152

track_12_sector_09: ; D64 offset $0f000
    !binary "build/game/splash64.bin", 256, 17664

track_12_sector_10: ; D64 offset $0f100
    !binary "build/game/splash64.bin", 256, 18176

track_12_sector_11: ; D64 offset $0f200
    !binary "build/game/splash64.bin", 256, 13312

track_12_sector_12: ; D64 offset $0f300
    !binary "build/game/splash64.bin", 256, 13824

track_12_sector_13: ; D64 offset $0f400
    !binary "build/game/splash64.bin", 256, 14336

track_12_sector_14: ; D64 offset $0f500
    !binary "build/game/splash64.bin", 256, 14848

track_12_sector_15: ; D64 offset $0f600
    !binary "build/game/splash64.bin", 256, 15360

track_12_sector_16: ; D64 offset $0f700
    !binary "build/game/splash64.bin", 256, 15872

track_12_sector_17: ; D64 offset $0f800
    !binary "build/game/splash64.bin", 256, 16384

track_12_sector_18: ; D64 offset $0f900
    !binary "build/game/splash64.bin", 256, 16896

track_12_sector_19: ; D64 offset $0fa00
    !binary "build/game/splash64.bin", 256, 17408

track_12_sector_20: ; D64 offset $0fb00
    !binary "build/game/splash64.bin", 256, 17920
