; Bard's Tale III (Boot Disk).d64: physical track 2, 21 sectors.
; Sector bytes are retained verbatim; no code/data assumptions.
!cpu 6510
* = $0000

track_02_sector_00: ; D64 offset $01500
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

track_02_sector_01: ; D64 offset $01600
    !binary "build/game/bard3-pic64.bin", 256, 256

track_02_sector_02: ; D64 offset $01700
    !binary "build/game/bard3-pic64.bin", 256, 768

track_02_sector_03: ; D64 offset $01800
    !binary "build/game/bard3-pic64.bin", 256, 1280

track_02_sector_04: ; D64 offset $01900
    !binary "build/game/bard3-pic64.bin", 256, 1792

track_02_sector_05: ; D64 offset $01a00
    !binary "build/game/bard3-pic64.bin", 256, 2304

track_02_sector_06: ; D64 offset $01b00
    !binary "build/game/bard3-pic64.bin", 256, 2816

track_02_sector_07: ; D64 offset $01c00
    !binary "build/game/bard3-pic64.bin", 256, 3328

track_02_sector_08: ; D64 offset $01d00
    !binary "build/game/bard3-pic64.bin", 256, 3840

track_02_sector_09: ; D64 offset $01e00
    !binary "build/game/bard3-pic64.bin", 256, 4352

track_02_sector_10: ; D64 offset $01f00
    !binary "build/game/bard3-pic64.bin", 256, 4864

track_02_sector_11: ; D64 offset $02000
    !binary "build/game/bard3-pic64.bin", 256, 0

track_02_sector_12: ; D64 offset $02100
    !binary "build/game/bard3-pic64.bin", 256, 512

track_02_sector_13: ; D64 offset $02200
    !binary "build/game/bard3-pic64.bin", 256, 1024

track_02_sector_14: ; D64 offset $02300
    !binary "build/game/bard3-pic64.bin", 256, 1536

track_02_sector_15: ; D64 offset $02400
    !binary "build/game/bard3-pic64.bin", 256, 2048

track_02_sector_16: ; D64 offset $02500
    !binary "build/game/bard3-pic64.bin", 256, 2560

track_02_sector_17: ; D64 offset $02600
    !binary "build/game/bard3-pic64.bin", 256, 3072

track_02_sector_18: ; D64 offset $02700
    !binary "build/game/bard3-pic64.bin", 256, 3584

track_02_sector_19: ; D64 offset $02800
    !binary "build/game/bard3-pic64.bin", 256, 4096

track_02_sector_20: ; D64 offset $02900
    !binary "build/game/bard3-pic64.bin", 256, 4608
