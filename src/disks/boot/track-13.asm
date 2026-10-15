; Bard's Tale III (Boot Disk).d64: physical track 13, 21 sectors.
; Sector bytes are retained verbatim; no code/data assumptions.
!cpu 6510
* = $0000

track_13_sector_00: ; D64 offset $0fc00
    !binary "build/game/splash64.bin", 256, 18432

track_13_sector_01: ; D64 offset $0fd00
    !binary "build/game/splash64.bin", 256, 18944

track_13_sector_02: ; D64 offset $0fe00
    !binary "build/game/splash64.bin", 256, 19456

track_13_sector_03: ; D64 offset $0ff00
    !binary "build/game/splash64.bin", 256, 19968

track_13_sector_04: ; D64 offset $10000
    !binary "build/game/splash64.bin", 256, 20480

track_13_sector_05: ; D64 offset $10100
    !binary "build/game/splash64.bin", 256, 20992

track_13_sector_06: ; D64 offset $10200
    !binary "build/game/splash64.bin", 256, 21504

track_13_sector_07: ; D64 offset $10300
    !binary "build/game/splash64.bin", 256, 22016

track_13_sector_08: ; D64 offset $10400
    !binary "build/game/splash64.bin", 256, 22528

track_13_sector_09: ; D64 offset $10500
    !binary "build/game/splash64.bin", 256, 23040

track_13_sector_10: ; D64 offset $10600
    !binary "build/game/splash64.bin", 256, 23552

track_13_sector_11: ; D64 offset $10700
    !binary "build/game/splash64.bin", 256, 18688

track_13_sector_12: ; D64 offset $10800
    !binary "build/game/splash64.bin", 256, 19200

track_13_sector_13: ; D64 offset $10900
    !binary "build/game/splash64.bin", 256, 19712

track_13_sector_14: ; D64 offset $10a00
    !binary "build/game/splash64.bin", 256, 20224

track_13_sector_15: ; D64 offset $10b00
    !binary "build/game/splash64.bin", 256, 20736

track_13_sector_16: ; D64 offset $10c00
    !binary "build/game/splash64.bin", 256, 21248

track_13_sector_17: ; D64 offset $10d00
    !binary "build/game/splash64.bin", 256, 21760

track_13_sector_18: ; D64 offset $10e00
    !binary "build/game/splash64.bin", 256, 22272

track_13_sector_19: ; D64 offset $10f00
    !binary "build/game/splash64.bin", 256, 22784

track_13_sector_20: ; D64 offset $11000
    !binary "build/game/splash64.bin", 256, 23296
