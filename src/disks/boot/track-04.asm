; Bard's Tale III (Boot Disk).d64: physical track 4, 21 sectors.
; Sector bytes are retained verbatim; no code/data assumptions.
!cpu 6510
* = $0000

track_04_sector_00: ; D64 offset $03f00
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

track_04_sector_01: ; D64 offset $04000
    !binary "build/game/bardsubs1.bin", 256, 768

track_04_sector_02: ; D64 offset $04100
    !binary "build/game/bardsubs1.bin", 256, 1280

track_04_sector_03: ; D64 offset $04200
    !binary "build/game/bardsubs1.bin", 256, 1792

track_04_sector_04: ; D64 offset $04300
    !binary "build/game/bardsubs1.bin", 256, 2304

track_04_sector_05: ; D64 offset $04400
    !binary "build/game/bardsubs1.bin", 256, 2816

track_04_sector_06: ; D64 offset $04500
    !binary "build/game/bardsubs1.bin", 256, 3328

track_04_sector_07: ; D64 offset $04600
    !binary "build/game/bardsubs1.bin", 256, 3840

track_04_sector_08: ; D64 offset $04700
    !binary "build/game/bardsubs1.bin", 256, 4352

track_04_sector_09: ; D64 offset $04800
    !binary "build/game/bardsubs1.bin", 256, 4864

track_04_sector_10: ; D64 offset $04900
    !binary "build/game/bardsubs1.bin", 256, 5376

track_04_sector_11: ; D64 offset $04a00
    !binary "build/game/bardsubs1.bin", 256, 512

track_04_sector_12: ; D64 offset $04b00
    !binary "build/game/bardsubs1.bin", 256, 1024

track_04_sector_13: ; D64 offset $04c00
    !binary "build/game/bardsubs1.bin", 256, 1536

track_04_sector_14: ; D64 offset $04d00
    !binary "build/game/bardsubs1.bin", 256, 2048

track_04_sector_15: ; D64 offset $04e00
    !binary "build/game/bardsubs1.bin", 256, 2560

track_04_sector_16: ; D64 offset $04f00
    !binary "build/game/bardsubs1.bin", 256, 3072

track_04_sector_17: ; D64 offset $05000
    !binary "build/game/bardsubs1.bin", 256, 3584

track_04_sector_18: ; D64 offset $05100
    !binary "build/game/bardsubs1.bin", 256, 4096

track_04_sector_19: ; D64 offset $05200
    !binary "build/game/bardsubs1.bin", 256, 4608

track_04_sector_20: ; D64 offset $05300
    !binary "build/game/bardsubs1.bin", 256, 5120
