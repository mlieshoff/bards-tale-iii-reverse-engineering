; Bard's Tale III (Boot Disk).d64: physical track 3, 21 sectors.
; Sector bytes are retained verbatim; no code/data assumptions.
!cpu 6510
* = $0000

track_03_sector_00: ; D64 offset $02a00
    !binary "build/game/bard3-pic64.bin", 256, 5120

track_03_sector_01: ; D64 offset $02b00
    !binary "build/game/bard3-pic64.bin", 256, 5632

track_03_sector_02: ; D64 offset $02c00
    !binary "build/game/bard3-pic64.bin", 256, 6144

track_03_sector_03: ; D64 offset $02d00
    !binary "build/game/bard3-pic64.bin", 256, 6656

track_03_sector_04: ; D64 offset $02e00
    !binary "build/game/bard3-pic64.bin", 256, 7168

track_03_sector_05: ; D64 offset $02f00
    !binary "build/game/bard3-pic64.bin", 256, 7680

track_03_sector_06: ; D64 offset $03000
    !binary "build/game/bard3-pic64.bin", 256, 8192

track_03_sector_07: ; D64 offset $03100
    !binary "build/game/bard3-pic64.bin", 256, 8704

track_03_sector_08: ; D64 offset $03200
    !binary "build/game/bard3-pic64.bin", 256, 9216

track_03_sector_09: ; D64 offset $03300
    !binary "build/game/bardsubs1.bin", 256, 0

track_03_sector_10: ; D64 offset $03400
    !byte $1e,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$2a,$2b,$2c,$2d,$2e
    !byte $2f,$30,$31,$32,$33,$34,$35,$00,$00,$00,$00,$00,$00,$00,$00,$00
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

track_03_sector_11: ; D64 offset $03500
    !binary "build/game/bard3-pic64.bin", 256, 5376

track_03_sector_12: ; D64 offset $03600
    !binary "build/game/bard3-pic64.bin", 256, 5888

track_03_sector_13: ; D64 offset $03700
    !binary "build/game/bard3-pic64.bin", 256, 6400

track_03_sector_14: ; D64 offset $03800
    !binary "build/game/bard3-pic64.bin", 256, 6912

track_03_sector_15: ; D64 offset $03900
    !binary "build/game/bard3-pic64.bin", 256, 7424

track_03_sector_16: ; D64 offset $03a00
    !binary "build/game/bard3-pic64.bin", 256, 7936

track_03_sector_17: ; D64 offset $03b00
    !binary "build/game/bard3-pic64.bin", 256, 8448

track_03_sector_18: ; D64 offset $03c00
    !binary "build/game/bard3-pic64.bin", 256, 8960

track_03_sector_19: ; D64 offset $03d00
    !binary "build/game/bard3-pic64.bin", 128, 9472
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

track_03_sector_20: ; D64 offset $03e00
    !binary "build/game/bardsubs1.bin", 256, 256
