; BARDSUBS2 -- resident engine: code, packed text, tables, and state.
; Semantic names are inferred; see docs/game-code-and-assets.md.
; Raw bytes may include unresolved code or overlapping entry points.
!cpu 6510
* = $cd00

; Tables/data begin this module; $cd00 is NOT an execution entry.
; BARDSUBS2 occupies RAM beneath I/O/ROM. A $dxxx reference can refer
; to these tables when $01=$34; do not automatically label it a VIC/SID access.
    !byte $00,$10,$20,$30,$40,$50,$60,$70,$02,$03,$00,$01,$a0,$fc,$de,$bf ; $cd00 retained data / unresolved code
    !byte $01,$11,$21,$31,$41,$51,$61,$71,$00,$00,$00,$00,$00,$00,$00,$00 ; $cd10 retained data / unresolved code
    !byte $02,$12,$22,$32,$42,$52,$62,$72,$60,$90,$c0,$f0,$b7,$b7,$b7,$b7 ; $cd20 retained data / unresolved code
    !byte $03,$13,$23,$33,$43,$53,$63,$73,$20,$60,$a0,$e0,$b8,$b8,$b8,$b8 ; $cd30 retained data / unresolved code
    !byte $04,$14,$24,$34,$44,$54,$64,$74

; Low-byte enemy/combat record pointers, indexed by combatant group.
; The corresponding high bytes are at $cd4c; used by combat dispatch.
    !byte $20,$40,$60,$80,$b9,$b9,$b9,$b9 ; $cd48 retained data / unresolved code
    !byte $05,$15,$25,$35,$45,$55,$65,$75,$80,$40,$20,$10,$08,$04,$02,$01 ; $cd50 retained data / unresolved code
    !byte $06,$16,$26,$36,$46,$56,$66,$76,$01,$03,$07,$0f,$1f,$3f,$7f,$ff ; $cd60 retained data / unresolved code
    !byte $07,$17,$27,$37,$47,$57,$67,$77,$00,$00,$00,$00,$00,$00,$00,$00 ; $cd70 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$ff,$c0,$c0,$c0,$c0,$c0,$c0,$c0 ; $cd80 retained data / unresolved code
    !byte $ff,$03,$03,$03,$03,$03,$03,$03,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$ff ; $cd90 retained data / unresolved code
    !byte $03,$03,$03,$03,$03,$03,$03,$ff,$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0 ; $cda0 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$3f,$3f,$00,$00,$00,$00,$00,$00,$00 ; $cdb0 retained data / unresolved code
    !byte $30,$30,$30,$30,$30,$30,$30,$30,$c0,$c1,$c3,$c7,$c7,$c1,$c1,$c0 ; $cdc0 retained data / unresolved code
    !byte $03,$c3,$e3,$f3,$f3,$c3,$c3,$03,$c0,$c1,$c1,$c7,$c7,$c3,$c1,$c0 ; $cdd0 retained data / unresolved code
    !byte $03,$c3,$c3,$f3,$f3,$e3,$c3,$03,$03,$03,$03,$03,$03,$03,$03,$03 ; $cde0 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$ff,$ff,$00,$00,$00,$00,$00,$00,$00 ; $cdf0 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$30,$30,$30,$30,$00,$30,$30,$00 ; $ce00 retained data / unresolved code
    !byte $cc,$cc,$00,$00,$00,$00,$00,$00,$cc,$cc,$fc,$cc,$fc,$cc,$cc,$00 ; $ce10 retained data / unresolved code
    !byte $30,$3c,$f0,$30,$0c,$f0,$30,$00,$c0,$c0,$0c,$30,$c0,$0c,$0c,$00 ; $ce20 retained data / unresolved code
    !byte $00,$00,$30,$fc,$30,$00,$00,$00,$30,$30,$00,$00,$00,$00,$00,$00 ; $ce30 retained data / unresolved code
    !byte $0c,$30,$c0,$c0,$c0,$30,$0c,$00,$c0,$30,$0c,$0c,$0c,$30,$c0,$00 ; $ce40 retained data / unresolved code
    !byte $00,$00,$cc,$30,$cc,$00,$00,$00,$00,$30,$30,$fc,$30,$30,$00,$00 ; $ce50 retained data / unresolved code
    !byte $00,$00,$00,$00,$30,$30,$c0,$00,$00,$00,$00,$fc,$00,$00,$00,$00 ; $ce60 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$30,$30,$00,$00,$00,$0c,$30,$c0,$00,$00,$00 ; $ce70 retained data / unresolved code
    !byte $78,$cc,$cc,$cc,$cc,$cc,$78,$00,$70,$f0,$30,$30,$30,$30,$30,$00 ; $ce80 retained data / unresolved code
    !byte $78,$cc,$0c,$0c,$38,$c0,$fc,$00,$78,$cc,$0c,$30,$0c,$cc,$78,$00 ; $ce90 retained data / unresolved code
    !byte $cc,$cc,$cc,$fc,$0c,$0c,$0c,$00,$fc,$c0,$c0,$f8,$0c,$0c,$f8,$00 ; $cea0 retained data / unresolved code
    !byte $78,$cc,$c0,$f8,$cc,$cc,$78,$00,$fc,$0c,$0c,$0c,$0c,$0c,$0c,$00 ; $ceb0 retained data / unresolved code
    !byte $78,$cc,$cc,$30,$cc,$cc,$78,$00,$78,$cc,$cc,$7c,$0c,$0c,$f8,$00 ; $cec0 retained data / unresolved code
    !byte $00,$00,$30,$00,$30,$00,$00,$00,$00,$00,$30,$00,$30,$30,$c0,$00 ; $ced0 retained data / unresolved code
    !byte $00,$0c,$30,$c0,$30,$0c,$00,$00,$00,$00,$fc,$00,$fc,$00,$00,$00 ; $cee0 retained data / unresolved code
    !byte $00,$c0,$30,$0c,$30,$c0,$00,$00,$78,$cc,$0c,$38,$00,$30,$30,$00 ; $cef0 retained data / unresolved code
    !byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$78,$cc,$cc,$fc,$cc,$cc,$cc,$00 ; $cf00 retained data / unresolved code
    !byte $f8,$cc,$cc,$f0,$cc,$cc,$f8,$00,$78,$cc,$c0,$c0,$c0,$cc,$78,$00 ; $cf10 retained data / unresolved code
    !byte $f8,$cc,$cc,$cc,$cc,$cc,$f8,$00,$fc,$c0,$c0,$f0,$c0,$c0,$fc,$00 ; $cf20 retained data / unresolved code
    !byte $fc,$c0,$c0,$f0,$c0,$c0,$c0,$00,$78,$cc,$c0,$c0,$cc,$cc,$78,$00 ; $cf30 retained data / unresolved code
    !byte $cc,$cc,$cc,$fc,$cc,$cc,$cc,$00,$fc,$30,$30,$30,$30,$30,$fc,$00 ; $cf40 retained data / unresolved code
    !byte $0c,$0c,$0c,$0c,$cc,$cc,$78,$00,$cc,$cc,$dc,$f0,$dc,$cc,$cc,$00 ; $cf50 retained data / unresolved code
    !byte $c0,$c0,$c0,$c0,$c0,$c0,$fc,$00,$cc,$fc,$cc,$cc,$cc,$cc,$cc,$00 ; $cf60 retained data / unresolved code
    !byte $f8,$cc,$cc,$cc,$cc,$cc,$cc,$00,$78,$cc,$cc,$cc,$cc,$cc,$78,$00 ; $cf70 retained data / unresolved code
    !byte $f8,$cc,$cc,$f8,$c0,$c0,$c0,$00,$78,$cc,$cc,$cc,$cc,$cc,$7c,$07 ; $cf80 retained data / unresolved code
    !byte $f8,$cc,$cc,$f0,$cc,$cc,$cc,$00,$7c,$c0,$c0,$78,$0c,$0c,$f8,$00 ; $cf90 retained data / unresolved code
    !byte $fc,$30,$30,$30,$30,$30,$30,$00,$cc,$cc,$cc,$cc,$cc,$cc,$78,$00 ; $cfa0 retained data / unresolved code
    !byte $cc,$cc,$cc,$cc,$cc,$78,$30,$00,$cc,$cc,$cc,$cc,$cc,$fc,$cc,$00 ; $cfb0 retained data / unresolved code
    !byte $cc,$cc,$cc,$30,$cc,$cc,$cc,$00,$cc,$cc,$cc,$78,$30,$30,$30,$00 ; $cfc0 retained data / unresolved code
    !byte $fc,$0c,$1c,$78,$e0,$c0,$fc,$00,$f0,$c0,$c0,$c0,$c0,$c0,$f0,$00 ; $cfd0 retained data / unresolved code
    !byte $30,$cc,$c0,$f0,$c0,$c0,$fc,$00,$f0,$30,$30,$30,$30,$30,$f0,$00 ; $cfe0 retained data / unresolved code
    !byte $30,$fc,$30,$30,$30,$30,$30,$00,$00,$00,$0c,$ff,$0c,$00,$00,$00 ; $cff0 retained data / unresolved code
    !byte $cc,$cc,$00,$00,$00,$00,$00,$00,$00,$00,$38,$0c,$7c,$cc,$7c,$00 ; $d000 retained data / unresolved code
    !byte $00,$c0,$c0,$f8,$cc,$cc,$f8,$00,$00,$00,$78,$cc,$c0,$cc,$78,$00 ; $d010 retained data / unresolved code
    !byte $00,$0c,$0c,$7c,$cc,$cc,$7c,$00,$00,$00,$78,$cc,$fc,$c0,$7c,$00 ; $d020 retained data / unresolved code
    !byte $00,$78,$cc,$c0,$f0,$c0,$c0,$00,$00,$00,$78,$cc,$cc,$7c,$0c,$38 ; $d030 retained data / unresolved code
    !byte $00,$c0,$c0,$f8,$cc,$cc,$cc,$00,$00,$30,$00,$30,$30,$30,$30,$00 ; $d040 retained data / unresolved code
    !byte $00,$0c,$00,$0c,$0c,$0c,$cc,$78,$00,$c0,$c0,$cc,$f0,$cc,$cc,$00 ; $d050 retained data / unresolved code
    !byte $00,$30,$30,$30,$30,$30,$30,$00,$00,$00,$cc,$fc,$cc,$cc,$cc,$00 ; $d060 retained data / unresolved code
    !byte $00,$00,$f8,$cc,$cc,$cc,$cc,$00,$00,$00,$78,$cc,$cc,$cc,$78,$00 ; $d070 retained data / unresolved code
    !byte $00,$00,$78,$cc,$cc,$f8,$c0,$c0,$00,$00,$78,$cc,$cc,$7c,$0c,$0c ; $d080 retained data / unresolved code
    !byte $00,$00,$78,$cc,$c0,$c0,$c0,$00,$00,$00,$7c,$c0,$78,$0c,$f8,$00 ; $d090 retained data / unresolved code
    !byte $00,$30,$fc,$30,$30,$30,$30,$00,$00,$00,$cc,$cc,$cc,$cc,$78,$00 ; $d0a0 retained data / unresolved code
    !byte $00,$00,$cc,$cc,$cc,$78,$30,$00,$00,$00,$cc,$cc,$cc,$fc,$cc,$00 ; $d0b0 retained data / unresolved code
    !byte $00,$00,$cc,$cc,$30,$cc,$cc,$00,$00,$00,$cc,$cc,$cc,$7c,$0c,$38 ; $d0c0 retained data / unresolved code
    !byte $00,$00,$fc,$0c,$30,$c0,$fc,$00,$3f,$c0,$cf,$cc,$cf,$c0,$3f,$00 ; $d0d0 retained data / unresolved code
    !byte $f0,$0c,$cc,$0c,$cc,$0c,$f0,$00,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c ; $d0e0 retained data / unresolved code
    !byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$c0,$c0,$f0,$f0,$fc,$fc,$ff ; $d0f0 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$0f,$0f,$00,$01,$02,$03,$04,$05,$00,$00 ; $d100 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$0f,$0f,$10,$11,$12,$13,$14,$15,$10,$10 ; $d110 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$0f,$0f,$20,$21,$22,$23,$24,$25,$20,$20 ; $d120 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$0f,$0f,$30,$31,$32,$33,$34,$35,$30,$30 ; $d130 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$0f,$0f,$40,$41,$42,$43,$44,$45,$40,$40 ; $d140 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$0f,$0f,$50,$51,$52,$53,$54,$55,$50,$50 ; $d150 retained data / unresolved code
    !byte $f0,$f0,$f0,$f0,$f0,$f0,$ff,$ff,$00,$01,$02,$03,$04,$05,$00,$00 ; $d160 retained data / unresolved code
    !byte $f0,$f0,$f0,$f0,$f0,$f0,$ff,$ff,$00,$01,$02,$03,$04,$05,$00,$00 ; $d170 retained data / unresolved code
    !byte $00,$01,$02,$03,$04,$05,$06,$07,$40,$41,$42,$43,$44,$45,$46,$47 ; $d180 retained data / unresolved code
    !byte $80,$81,$82,$83,$84,$85,$86,$87,$c0,$c1,$c2,$c3,$c4,$c5,$c6,$c7 ; $d190 retained data / unresolved code
    !byte $00,$01,$02,$03,$04,$05,$06,$07,$40,$41,$42,$43,$44,$45,$46,$47 ; $d1a0 retained data / unresolved code
    !byte $80,$81,$82,$83,$84,$85,$86,$87,$c0,$c1,$c2,$c3,$c4,$c5,$c6,$c7 ; $d1b0 retained data / unresolved code
    !byte $00,$01,$02,$03,$04,$05,$06,$07,$40,$41,$42,$43,$44,$45,$46,$47 ; $d1c0 retained data / unresolved code
    !byte $80,$81,$82,$83,$84,$85,$86,$87,$c0,$c1,$c2,$c3,$c4,$c5,$c6,$c7 ; $d1d0 retained data / unresolved code
    !byte $00,$01,$02,$03,$04,$05,$06,$07,$40,$41,$42,$43,$44,$45,$46,$47 ; $d1e0 retained data / unresolved code
    !byte $80,$81,$82,$83,$84,$85,$86,$87,$c0,$c1,$c2,$c3,$c4,$c5,$c6,$c7 ; $d1f0 retained data / unresolved code
    !byte $00,$01,$02,$03,$04,$05,$06,$07,$40,$41,$42,$43,$44,$45,$46,$47 ; $d200 retained data / unresolved code
    !byte $80,$81,$82,$83,$84,$85,$86,$87,$c0,$c1,$c2,$c3,$c4,$c5,$c6,$c7 ; $d210 retained data / unresolved code
    !byte $00,$01,$02,$03,$04,$05,$06,$07,$40,$41,$42,$43,$44,$45,$46,$47 ; $d220 retained data / unresolved code
    !byte $80,$81,$82,$83,$84,$85,$86,$87,$c0,$c1,$c2,$c3,$c4,$c5,$c6,$c7 ; $d230 retained data / unresolved code
    !byte $00,$01,$02,$03,$04,$05,$06,$07,$20,$20,$20,$20,$20,$20,$20,$20 ; $d240 retained data / unresolved code
    !byte $21,$21,$21,$21,$21,$21,$21,$21,$22,$22,$22,$22,$22,$22,$22,$22 ; $d250 retained data / unresolved code
    !byte $23,$23,$23,$23,$23,$23,$23,$23,$25,$25,$25,$25,$25,$25,$25,$25 ; $d260 retained data / unresolved code
    !byte $26,$26,$26,$26,$26,$26,$26,$26,$27,$27,$27,$27,$27,$27,$27,$27 ; $d270 retained data / unresolved code
    !byte $28,$28,$28,$28,$28,$28,$28,$28,$2a,$2a,$2a,$2a,$2a,$2a,$2a,$2a ; $d280 retained data / unresolved code
    !byte $2b,$2b,$2b,$2b,$2b,$2b,$2b,$2b,$2c,$2c,$2c,$2c,$2c,$2c,$2c,$2c ; $d290 retained data / unresolved code
    !byte $2d,$2d,$2d,$2d,$2d,$2d,$2d,$2d,$2f,$2f,$2f,$2f,$2f,$2f,$2f,$2f ; $d2a0 retained data / unresolved code
    !byte $30,$30,$30,$30,$30,$30,$30,$30,$31,$31,$31,$31,$31,$31,$31,$31 ; $d2b0 retained data / unresolved code
    !byte $32,$32,$32,$32,$32,$32,$32,$32,$34,$34,$34,$34,$34,$34,$34,$34 ; $d2c0 retained data / unresolved code
    !byte $35,$35,$35,$35,$35,$35,$35,$35,$36,$36,$36,$36,$36,$36,$36,$36 ; $d2d0 retained data / unresolved code
    !byte $37,$37,$37,$37,$37,$37,$37,$37,$39,$39,$39,$39,$39,$39,$39,$39 ; $d2e0 retained data / unresolved code
    !byte $3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b ; $d2f0 retained data / unresolved code
    !byte $3c,$3c,$3c,$3c,$3c,$3c,$3c,$3c,$02,$02,$02,$02,$02,$02,$02,$02 ; $d300 retained data / unresolved code
    !byte $00,$00,$00,$00,$08,$08,$08,$08,$10,$10,$10,$10,$18,$18,$18,$18 ; $d310 retained data / unresolved code
    !byte $20,$20,$20,$20,$28,$28,$28,$28,$30,$30,$30,$30,$38,$38,$38,$38 ; $d320 retained data / unresolved code
    !byte $40,$40,$40,$40,$48,$48,$48,$48,$50,$50,$50,$50,$58,$58,$58,$58 ; $d330 retained data / unresolved code
    !byte $60,$60,$60,$60,$68,$68,$68,$68,$70,$70,$70,$70,$78,$78,$78,$78 ; $d340 retained data / unresolved code
    !byte $80,$80,$80,$80,$88,$88,$88,$88,$90,$90,$90,$90,$98,$98,$98,$98 ; $d350 retained data / unresolved code
    !byte $a0,$a0,$a0,$a0,$a8,$a8,$a8,$a8,$b0,$b0,$b0,$b0,$b8,$b8,$b8,$b8 ; $d360 retained data / unresolved code
    !byte $c0,$c0,$c0,$c0,$c8,$c8,$c8,$c8,$d0,$d0,$d0,$d0,$d8,$d8,$d8,$d8 ; $d370 retained data / unresolved code
    !byte $e0,$e0,$e0,$e0,$e8,$e8,$e8,$e8,$f0,$f0,$f0,$f0,$f8,$f8,$f8,$f8 ; $d380 retained data / unresolved code
    !byte $00,$00,$00,$00,$08,$08,$08,$08,$10,$10,$10,$10,$18,$18,$18,$18 ; $d390 retained data / unresolved code
    !byte $20,$20,$20,$20,$28,$28,$28,$28,$30,$30,$30,$30,$38,$38,$38,$38 ; $d3a0 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $d3b0 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $d3c0 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $d3d0 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $d3e0 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $d3f0 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $d400 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $d410 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $d420 retained data / unresolved code
    !byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01 ; $d430 retained data / unresolved code
    !byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01 ; $d440 retained data / unresolved code
    !byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01 ; $d450 retained data / unresolved code
    !byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01 ; $d460 retained data / unresolved code
    !byte $00,$17,$2e,$45,$5c,$73,$8a,$a1,$b8,$cf,$e6,$fd,$14,$2b,$42,$59 ; $d470 retained data / unresolved code
    !byte $70,$87,$9e,$b5,$cc,$e3,$fa,$11,$28,$3f,$56,$6d,$84,$9b,$b2,$c9 ; $d480 retained data / unresolved code
    !byte $e0,$f7,$0e,$25,$3c,$53,$6a,$81,$98,$af,$c6,$dd,$f4,$0b,$22,$39 ; $d490 retained data / unresolved code
    !byte $50,$67,$7e,$95,$ac,$c3,$da,$f1,$08,$1f,$36,$4d,$64,$7b,$92,$a9 ; $d4a0 retained data / unresolved code
    !byte $c0,$d7,$ee,$05,$1c,$33,$4a,$61,$78,$8f,$a6,$bd,$d4,$eb,$02,$19 ; $d4b0 retained data / unresolved code
    !byte $30,$47,$5e,$75,$8c,$a3,$ba,$d1,$e8,$08,$08,$08,$08,$08,$08,$08 ; $d4c0 retained data / unresolved code
    !byte $08,$08,$08,$08,$08,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09 ; $d4d0 retained data / unresolved code
    !byte $0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0b,$0b,$0b,$0b,$0b ; $d4e0 retained data / unresolved code
    !byte $0b,$0b,$0b,$0b,$0b,$0b,$0c,$0c,$0c,$0c,$0c,$0c,$0c,$0c,$0c,$0c ; $d4f0 retained data / unresolved code
    !byte $0c,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0e,$0e,$0e,$0e ; $d500 retained data / unresolved code
    !byte $0e,$0e,$0e,$0e,$0e,$0e,$0e,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f ; $d510 retained data / unresolved code
    !byte $0f,$0f

; Seven party-record pointers: $3e00,$3e80,$3f00,$3f80,$bf00,$bf80,$1f80.
; Resident helper $91e4 loads one of these into $12/$13.
; Startup clears 120 bytes per record, although the records are spaced by 128.
    !byte $00,$3e,$80,$3e,$00,$3f,$80,$3f,$00,$bf,$80,$bf,$80,$1f ; $d522 retained data / unresolved code
    !byte $00,$ba,$80,$ba,$00,$bb,$80,$bb,$00,$bc,$80,$bc,$00,$bd,$00,$43 ; $d530 retained data / unresolved code
    !byte $30,$43,$60,$43,$90,$43,$c0,$43,$f0,$43,$20,$44,$50,$44,$80,$44 ; $d540 retained data / unresolved code
    !byte $b0,$44,$e0,$44,$10,$45,$40,$45,$70,$45,$a0,$45,$d0,$45,$00,$46 ; $d550 retained data / unresolved code
    !byte $30,$46,$60,$46,$90,$46,$c0,$46,$f0,$46,$20,$47,$50,$47,$76,$d5 ; $d560 retained data / unresolved code
    !byte $98,$d5,$ba,$d5,$dc,$d5,$02,$10,$00,$40,$01,$00,$00,$40,$00,$50 ; $d570 retained data / unresolved code
    !byte $01,$50,$01,$54,$01,$54,$05,$dc,$05,$d4,$07,$74,$15,$d7,$1d,$55 ; $d580 retained data / unresolved code
    !byte $05,$77,$15,$7d,$05,$ff,$0f,$f7,$02,$10,$00,$00,$00,$00,$00,$04 ; $d590 retained data / unresolved code
    !byte $00,$14,$00,$14,$00,$50,$01,$51,$01,$74,$05,$dc,$07,$75,$05,$55 ; $d5a0 retained data / unresolved code
    !byte $05,$77,$15,$ff,$1d,$fd,$07,$f5,$0f,$5f,$02,$10,$00,$00,$00,$00 ; $d5b0 retained data / unresolved code
    !byte $00,$00,$01,$40,$01,$50,$00,$74,$04,$7c,$01,$5c,$05,$54,$05,$dc ; $d5c0 retained data / unresolved code
    !byte $17,$ff,$17,$df,$1f,$57,$1d,$f4,$0f,$74,$05,$dc,$02,$10,$00,$00 ; $d5d0 retained data / unresolved code
    !byte $00,$00,$04,$40,$0d,$00,$07,$00,$01,$40,$05,$40,$05,$c0,$1d,$d0 ; $d5e0 retained data / unresolved code
    !byte $1f,$70,$1d,$54,$15,$d5,$17,$7d,$15,$dd,$07,$77,$05,$54,$08,$d6 ; $d5f0 retained data / unresolved code
    !byte $08,$d6,$42,$d6,$7c,$d6,$b6,$d6,$04,$0e,$00,$00,$15,$54,$00,$00 ; $d600 retained data / unresolved code
    !byte $40,$04,$00,$00,$45,$44,$00,$01,$15,$c4,$00,$01,$37,$10,$00,$04 ; $d610 retained data / unresolved code
    !byte $5d,$10,$00,$04,$55,$10,$00,$11,$55,$10,$00,$13,$57,$10,$00,$4d ; $d620 retained data / unresolved code
    !byte $dc,$40,$00,$47,$74,$40,$01,$1d,$54,$40,$01,$00,$00,$40,$05,$55 ; $d630 retained data / unresolved code
    !byte $55,$40,$04,$0e,$00,$00,$15,$54,$00,$00,$40,$04,$00,$00,$45,$44 ; $d640 retained data / unresolved code
    !byte $00,$01,$15,$c4,$00,$01,$37,$10,$00,$04,$5d,$10,$00,$51,$54,$10 ; $d650 retained data / unresolved code
    !byte $01,$1d,$51,$10,$01,$77,$71,$00,$01,$1d,$d1,$00,$04,$75,$51,$00 ; $d660 retained data / unresolved code
    !byte $04,$00,$01,$00,$01,$55,$55,$00,$00,$00,$00,$00,$04,$0e,$00,$00 ; $d670 retained data / unresolved code
    !byte $15,$54,$00,$00,$40,$04,$00,$00,$45,$44,$00,$04,$dc,$50,$00,$11 ; $d680 retained data / unresolved code
    !byte $74,$40,$00,$45,$51,$00,$00,$45,$51,$00,$00,$4d,$51,$00,$00,$13 ; $d690 retained data / unresolved code
    !byte $53,$00,$00,$4d,$dc,$40,$00,$47,$74,$40,$01,$1d,$54,$40,$01,$00 ; $d6a0 retained data / unresolved code
    !byte $00,$40,$05,$55,$55,$40,$04,$0e,$00,$00,$55,$50,$00,$01,$00,$10 ; $d6b0 retained data / unresolved code
    !byte $00,$01,$15,$10,$00,$04,$57,$10,$00,$05,$dc,$40,$00,$04,$5c,$40 ; $d6c0 retained data / unresolved code
    !byte $00,$04,$55,$10,$00,$11,$55,$10,$00,$13,$57,$10,$00,$4d,$dc,$40 ; $d6d0 retained data / unresolved code
    !byte $00,$47,$74,$40,$01,$1d,$54,$40,$01,$00,$00,$40,$05,$55,$55,$40 ; $d6e0 retained data / unresolved code
    !byte $f8,$d6,$32,$d7,$6c,$d7,$a6,$d7,$04,$0e,$00,$00,$20,$00,$00,$00 ; $d6f0 retained data / unresolved code
    !byte $88,$00,$00,$02,$52,$00,$00,$09,$54,$80,$00,$25,$55,$20,$00,$95 ; $d700 retained data / unresolved code
    !byte $55,$48,$02,$01,$54,$0a,$02,$a9,$54,$aa,$00,$a9,$54,$a8,$00,$28 ; $d710 retained data / unresolved code
    !byte $00,$a0,$00,$0a,$aa,$80,$00,$02,$aa,$00,$00,$00,$a8,$00,$00,$00 ; $d720 retained data / unresolved code
    !byte $20,$00,$04,$0e,$00,$00,$20,$00,$00,$00,$88,$00,$00,$02,$92,$00 ; $d730 retained data / unresolved code
    !byte $00,$0a,$94,$80,$00,$28,$15,$20,$00,$a9,$55,$48,$02,$a9,$55,$52 ; $d740 retained data / unresolved code
    !byte $02,$a9,$55,$52,$00,$a9,$55,$48,$00,$28,$15,$20,$00,$0a,$94,$80 ; $d750 retained data / unresolved code
    !byte $00,$02,$92,$00,$00,$00,$88,$00,$00,$00,$20,$00,$04,$0e,$00,$00 ; $d760 retained data / unresolved code
    !byte $20,$00,$00,$00,$a8,$00,$00,$02,$aa,$00,$00,$0a,$aa,$80,$00,$28 ; $d770 retained data / unresolved code
    !byte $00,$a0,$00,$a9,$54,$a8,$02,$a9,$54,$aa,$02,$81,$54,$0a,$00,$95 ; $d780 retained data / unresolved code
    !byte $55,$48,$00,$25,$55,$20,$00,$09,$54,$80,$00,$02,$52,$00,$00,$00 ; $d790 retained data / unresolved code
    !byte $88,$00,$00,$00,$20,$00,$04,$0e,$00,$00,$20,$00,$00,$00,$88,$00 ; $d7a0 retained data / unresolved code
    !byte $00,$02,$4a,$00,$00,$09,$4a,$80,$00,$25,$40,$a0,$00,$95,$54,$a8 ; $d7b0 retained data / unresolved code
    !byte $02,$55,$54,$aa,$02,$55,$54,$aa,$00,$95,$54,$a8,$00,$25,$40,$a0 ; $d7c0 retained data / unresolved code
    !byte $00,$09,$4a,$80,$00,$02,$4a,$00,$00,$00,$88,$00,$00,$00,$20,$00 ; $d7d0 retained data / unresolved code
    !byte $ec,$d7,$1a,$d8,$ec,$d7,$48,$d8,$76,$d8,$48,$d8,$04,$0b,$00,$0a ; $d7e0 retained data / unresolved code
    !byte $a8,$00,$00,$2a,$aa,$00,$00,$80,$00,$80,$02,$10,$74,$20,$02,$d0 ; $d7f0 retained data / unresolved code
    !byte $05,$a0,$02,$d4,$15,$a0,$02,$75,$56,$20,$00,$9d,$58,$80,$00,$27 ; $d800 retained data / unresolved code
    !byte $e2,$00,$00,$08,$08,$00,$00,$02,$a0,$00,$04,$0b,$00,$0a,$a8,$00 ; $d810 retained data / unresolved code
    !byte $00,$2a,$aa,$00,$00,$aa,$aa,$80,$02,$80,$70,$a0,$02,$34,$00,$20 ; $d820 retained data / unresolved code
    !byte $02,$f5,$04,$20,$02,$7d,$54,$a0,$00,$9f,$52,$80,$00,$27,$ea,$00 ; $d830 retained data / unresolved code
    !byte $00,$0a,$a8,$00,$00,$02,$a0,$00,$04,$0b,$00,$0a,$a8,$00,$00,$2a ; $d840 retained data / unresolved code
    !byte $aa,$00,$00,$aa,$aa,$80,$02,$aa,$aa,$a0,$02,$a0,$00,$a0,$02,$10 ; $d850 retained data / unresolved code
    !byte $04,$20,$02,$b4,$16,$a0,$00,$ad,$5a,$80,$00,$2a,$aa,$00,$00,$0a ; $d860 retained data / unresolved code
    !byte $a8,$00,$00,$02,$a0,$00,$04,$0b,$00,$0a,$a8,$00,$00,$2a,$aa,$00 ; $d870 retained data / unresolved code
    !byte $00,$aa,$aa,$80,$02,$aa,$aa,$a0,$02,$aa,$aa,$a0,$02,$2a,$aa,$20 ; $d880 retained data / unresolved code
    !byte $02,$80,$00,$a0,$00,$aa,$aa,$80,$00,$2a,$aa,$00,$00,$0a,$a8,$00 ; $d890 retained data / unresolved code
    !byte $00,$02,$a0,$00,$03,$10,$03,$fa,$a0,$0c,$00,$08,$0c,$af,$c8,$0c ; $d8a0 retained data / unresolved code
    !byte $af,$c8,$0c,$af,$c8,$0c,$af,$c8,$0c,$af,$c8,$0c,$af,$c8,$0c,$af ; $d8b0 retained data / unresolved code
    !byte $c8,$0c,$af,$c8,$0c,$af,$c8,$03,$2f,$88,$03,$8f,$28,$00,$e0,$a0 ; $d8c0 retained data / unresolved code
    !byte $00,$3a,$80,$00,$0a,$00,$02,$0e,$00,$c0,$00,$e0,$00,$f8,$00,$fe ; $d8d0 retained data / unresolved code
    !byte $00,$c0,$00,$c0,$00,$c0,$00,$c0,$00,$c0,$00,$c0,$0f,$c0,$1f,$c0 ; $d8e0 retained data / unresolved code
    !byte $1f,$80,$0f,$00,$12,$d9,$18,$d9,$1e,$d9,$25,$d9,$2c,$d9,$33,$d9 ; $d8f0 retained data / unresolved code
    !byte $38,$d9,$3c,$d9,$42,$d9,$47,$d9,$4b,$d9,$52,$d9,$5b,$d9,$62,$d9 ; $d900 retained data / unresolved code
    !byte $68,$d9,$f5,$85,$18,$a9,$f1,$00,$f5,$95,$f0,$c5,$12,$80,$f4,$9f ; $d910 retained data / unresolved code
    !byte $12,$1a,$26,$88,$00,$f1,$1e,$ef,$81,$48,$9a,$20,$f3,$44,$85,$11 ; $d920 retained data / unresolved code
    !byte $42,$70,$00,$f4,$5e,$8a,$18,$00,$f0,$c5,$12,$80,$f4,$04,$c1,$15 ; $d930 retained data / unresolved code
    !byte $4e,$00,$f2,$68,$e9,$9a,$20,$f3,$5e,$e5,$80,$f0,$a2,$44,$b4,$48 ; $d940 retained data / unresolved code
    !byte $30,$00,$f1,$13,$17,$b9,$ed,$13,$88,$68,$80,$f2,$0c,$f6,$89,$c4 ; $d950 retained data / unresolved code
    !byte $34,$40,$f3,$5e,$e9,$4c,$d1,$00,$f2,$98,$ca,$49,$4f,$70,$00,$77 ; $d960 retained data / unresolved code
    !byte $d9,$7b,$d9,$7f,$d9,$83,$d9,$73,$e3,$34,$80,$30,$a5,$30,$00,$93 ; $d970 retained data / unresolved code
    !byte $e9,$34,$80,$b1,$a5,$30,$00,$80,$40,$40,$40,$40,$10,$08,$04,$02 ; $d980 retained data / unresolved code
    !byte $01,$20,$60,$e0,$00,$00,$aa,$d9,$b1,$d9,$ba,$d9,$c2,$d9,$ca,$d9 ; $d990 retained data / unresolved code
    !byte $d3,$d9,$dc,$d9,$e3,$d9,$f1,$d9,$fc,$d9,$d8,$56,$a6,$31,$4e,$40 ; $d9a0 retained data / unresolved code
    !byte $40,$d8,$60,$f5,$49,$ee,$53,$90,$10,$00,$d8,$4b,$11,$29,$ca,$72 ; $d9b0 retained data / unresolved code
    !byte $02,$00,$d8,$49,$11,$7c,$35,$39,$01,$00,$d8,$6c,$a9,$a4,$d1,$53 ; $d9c0 retained data / unresolved code
    !byte $90,$10,$00,$d8,$60,$f9,$48,$d2,$92,$9c,$80,$80,$d8,$65,$37,$b9 ; $d9d0 retained data / unresolved code
    !byte $4e,$40,$40,$d8,$49,$15,$4d,$44,$13,$19,$70,$a5,$53,$9a,$9c,$80 ; $d9e0 retained data / unresolved code
    !byte $80,$d8,$65,$33,$09,$8a,$72,$02,$78,$bd,$a1,$00,$d8,$60,$91,$7c ; $d9f0 retained data / unresolved code
    !byte $35,$39,$01,$00,$14,$da,$21,$da,$2a,$da,$36,$da,$44,$da,$50,$da ; $da00 retained data / unresolved code
    !byte $5c,$da,$68,$da,$f4,$95,$10,$fa,$2f,$1a,$9d,$a9,$07,$d3,$a3,$8c ; $da10 retained data / unresolved code
    !byte $00,$f4,$84,$73,$4e,$e1,$f4,$9e,$e4,$00,$f4,$84,$e2,$4e,$82,$8d ; $da20 retained data / unresolved code
    !byte $c3,$e9,$11,$f1,$30,$00,$f0,$e2,$a7,$20,$51,$7d,$1c,$50,$f8,$62 ; $da30 retained data / unresolved code
    !byte $63,$04,$50,$00,$f4,$53,$76,$98,$2f,$38,$7c,$5a,$3e,$6a,$69,$80 ; $da40 retained data / unresolved code
    !byte $f5,$85,$32,$26,$cf,$79,$43,$e6,$99,$8f,$2d,$c0,$f3,$54,$e9,$4e ; $da50 retained data / unresolved code
    !byte $26,$60,$7d,$24,$a8,$cc,$28,$00,$f2,$d4,$66,$6a,$41,$f3,$ea,$68 ; $da60 retained data / unresolved code
    !byte $ce,$91,$30,$00,$f4,$df,$12,$24,$00,$f3,$04,$d8,$00,$f0,$e2,$f1 ; $da70 retained data / unresolved code
    !byte $16,$56,$7c,$4a,$00,$f4,$92,$f8,$cc,$3e,$95,$9f,$12,$80,$f1,$44 ; $da80 retained data / unresolved code
    !byte $84,$1a,$20,$f5,$85,$10,$f8,$5f,$08,$c0,$f2,$44,$c1,$8a,$25,$00 ; $da90 retained data / unresolved code
    !byte $f3,$1e,$e4,$07,$c3,$7d,$80,$f4,$a6,$23,$9c,$00,$f0,$e8,$45,$b0 ; $daa0 retained data / unresolved code
    !byte $d1,$00,$f4,$df,$63,$44,$3e,$92,$54,$66,$14,$00,$f3,$0c,$29,$a4 ; $dab0 retained data / unresolved code
    !byte $d1,$0f,$85,$16,$be,$20,$f1,$12,$25,$38,$3e,$68,$94,$c0,$00,$f4 ; $dac0 retained data / unresolved code
    !byte $88,$26,$18,$3e,$14,$5a,$f8,$80,$f4,$18,$29,$98,$3e,$14,$5a,$f8 ; $dad0 retained data / unresolved code
    !byte $80,$f4,$5e,$33,$48,$00,$f2,$4c,$c6,$80,$f3,$0c,$29,$a4,$d1,$0f ; $dae0 retained data / unresolved code
    !byte $90,$c7,$d4,$d2,$00,$f2,$05,$47,$4d,$86,$9c,$80,$f3,$44,$e2,$bd ; $daf0 retained data / unresolved code
    !byte $8a,$70,$00,$f4,$a0,$61,$44,$00,$f0,$a3,$17,$da,$40,$f3,$66,$98 ; $db00 retained data / unresolved code
    !byte $87,$d2,$b3,$e2,$50,$00,$f3,$66,$98,$87,$d2,$4a,$8c,$c2,$80,$f3 ; $db10 retained data / unresolved code
    !byte $66,$98,$87,$c4,$48,$94,$e0,$00,$f3,$66,$98,$87,$d2,$20,$98,$60 ; $db20 retained data / unresolved code
    !byte $00,$f2,$14,$27,$4c,$3e,$3a,$1c,$00,$f3,$66,$98,$87,$c3,$88,$88 ; $db30 retained data / unresolved code
    !byte $68,$c8,$00,$f0,$c5,$12,$ca,$cf,$89,$40,$f1,$d5,$13,$07,$c9,$7c ; $db40 retained data / unresolved code
    !byte $5c,$00,$f3,$15,$33,$58,$4e,$28,$00,$f3,$66,$98,$87,$c5,$12,$10 ; $db50 retained data / unresolved code
    !byte $68,$80,$f3,$66,$98,$87,$c9,$33,$1a,$00,$f3,$66,$98,$87,$c8,$63 ; $db60 retained data / unresolved code
    !byte $ea,$69,$00,$f3,$66,$98,$87,$c2,$f8,$46,$00,$f4,$93,$48,$a9,$66 ; $db70 retained data / unresolved code
    !byte $70,$00,$f3,$66,$98,$87,$d0,$60,$a6,$60,$00,$f3,$5e,$c9,$99,$c1 ; $db80 retained data / unresolved code
    !byte $f1,$d0,$e0,$00,$f4,$a0,$66,$30,$3e,$94,$0c,$28,$80,$f4,$92,$a3 ; $db90 retained data / unresolved code
    !byte $30,$a1,$f4,$54,$e4,$00,$f1,$d4,$ed,$48,$3e,$3b,$29,$33,$00,$f2 ; $dba0 retained data / unresolved code
    !byte $c4,$66,$6a,$41,$f0,$be,$11,$80,$f3,$66,$98,$87,$c2,$8c,$5f,$69 ; $dbb0 retained data / unresolved code
    !byte $00,$f1,$45,$71,$b0,$45,$30,$00,$f4,$92,$a3,$30,$a1,$f4,$a6,$23 ; $dbc0 retained data / unresolved code
    !byte $9c,$00,$f1,$98,$70,$f8,$8c,$78,$96,$00,$f2,$45,$65,$8d,$82,$29 ; $dbd0 retained data / unresolved code
    !byte $80,$f0,$8a,$d9,$87,$d2,$b3,$e2,$50,$00,$f0,$8a,$d9,$87,$d2,$4a ; $dbe0 retained data / unresolved code
    !byte $8c,$c2,$80,$f0,$8a,$d9,$87,$c9,$33,$1a,$00,$f0,$8a,$d9,$87,$c8 ; $dbf0 retained data / unresolved code
    !byte $63,$ea,$69,$00,$f4,$29,$13,$0d,$82,$29,$80,$f0,$de,$f6,$9a,$22 ; $dc00 retained data / unresolved code
    !byte $72,$00,$f0,$98,$ad,$48,$3e,$20,$a3,$03,$4c,$00,$f3,$28,$45,$c9 ; $dc10 retained data / unresolved code
    !byte $2a,$33,$0a,$00,$f1,$5f,$f0,$cd,$10,$f8,$e8,$70,$00,$f0,$8a,$d9 ; $dc20 retained data / unresolved code
    !byte $87,$c4,$48,$94,$e0,$00,$f1,$4c,$29,$a4,$3e,$94,$c5,$19,$00,$f0 ; $dc30 retained data / unresolved code
    !byte $8a,$d9,$87,$d0,$60,$a6,$60,$00,$f0,$8a,$d9,$87,$c3,$88,$88,$68 ; $dc40 retained data / unresolved code
    !byte $c8,$00,$f4,$98,$2b,$9a,$21,$f1,$d0,$e0,$00,$f4,$29,$13,$07,$d2 ; $dc50 retained data / unresolved code
    !byte $4a,$8c,$c2,$80,$f3,$44,$83,$07,$d2,$98,$8e,$70,$00,$f5,$85,$10 ; $dc60 retained data / unresolved code
    !byte $fa,$53,$11,$ce,$00,$f4,$d2,$a3,$1c,$3e,$28,$90,$83,$44,$00,$f4 ; $dc70 retained data / unresolved code
    !byte $9f,$46,$07,$cd,$11,$0c,$00,$f3,$d1,$13,$58,$4e,$28,$00,$f2,$c5 ; $dc80 retained data / unresolved code
    !byte $37,$ea,$41,$1c,$44,$43,$44,$00,$f4,$9f,$12,$1a,$32,$98,$8e,$70 ; $dc90 retained data / unresolved code
    !byte $00,$f2,$04,$c9,$ea,$41,$f1,$d9,$49,$98,$00,$f1,$e2,$f9,$4c,$3e ; $dca0 retained data / unresolved code
    !byte $4b,$e2,$e0,$00,$f0,$91,$a9,$07,$c2,$8c,$5f,$69,$00,$f1,$5a,$e2 ; $dcb0 retained data / unresolved code
    !byte $87,$d2,$4a,$8c,$c2,$80,$f0,$c5,$12,$87,$c3,$7d,$80,$f1,$5a,$e2 ; $dcc0 retained data / unresolved code
    !byte $87,$c9,$33,$1a,$00,$f1,$98,$70,$f8,$6f,$7c,$e4,$00,$f5,$44,$ef ; $dcd0 retained data / unresolved code
    !byte $83,$45,$49,$26,$88,$7c,$74,$38,$00,$f1,$1e,$ef,$81,$48,$ca,$62 ; $dce0 retained data / unresolved code
    !byte $39,$c0,$f4,$a6,$23,$9c,$2f,$38,$7c,$c7,$c4,$00,$f1,$d8,$26,$98 ; $dcf0 retained data / unresolved code
    !byte $3e,$95,$9f,$12,$80,$f4,$1f,$63,$46,$53,$11,$ce,$00,$f0,$e2,$61 ; $dd00 retained data / unresolved code
    !byte $4d,$21,$f4,$54,$e4,$00,$f1,$62,$24,$3d,$d2,$4a,$8c,$c2,$80,$f1 ; $dd10 retained data / unresolved code
    !byte $5a,$e2,$87,$d0,$60,$a6,$60,$00,$f5,$85,$14,$31,$f5,$34,$80,$f5 ; $dd20 retained data / unresolved code
    !byte $95,$f0,$d2,$66,$34,$00,$f1,$62,$24,$3d,$d6,$13,$8a,$00,$f1,$4c ; $dd30 retained data / unresolved code
    !byte $29,$a6,$2a,$72,$00,$f1,$23,$79,$4c,$4c,$0f,$a5,$67,$c4,$a0,$f4 ; $dd40 retained data / unresolved code
    !byte $a0,$63,$14,$6f,$7c,$e4,$00,$f1,$d8,$26,$98,$3e,$4b,$e2,$e0,$00 ; $dd50 retained data / unresolved code
    !byte $f7,$c3,$33,$83,$e1,$46,$2f,$b4,$80,$f1,$4c,$29,$a4,$b1,$a3,$40 ; $dd60 retained data / unresolved code
    !byte $f4,$15,$03,$48,$2f,$38,$7d,$01,$38,$00,$f4,$1f,$63,$44,$3e,$8a ; $dd70 retained data / unresolved code
    !byte $9c,$80,$00,$f4,$9e,$e4,$07,$c2,$f8,$46,$00,$f4,$e2,$a2,$2c,$3e ; $dd80 retained data / unresolved code
    !byte $1c,$54,$45,$80,$f1,$62,$24,$3d,$c1,$f1,$d0,$e0,$00,$f3,$44,$83 ; $dd90 retained data / unresolved code
    !byte $07,$c7,$43,$80,$f4,$e2,$f6,$30,$3e,$8a,$9c,$80,$00,$f0,$a2,$26 ; $dda0 retained data / unresolved code
    !byte $ea,$41,$f2,$dc,$a3,$98,$00,$f0,$9c,$88,$8b,$52,$0f,$8d,$73,$00 ; $ddb0 retained data / unresolved code
    !byte $f2,$4d,$11,$87,$c7,$43,$80,$f3,$45,$29,$9a,$21,$f5,$84,$e2,$80 ; $ddc0 retained data / unresolved code
    !byte $f0,$e2,$f9,$a4,$d1,$90,$7c,$74,$38,$00,$f1,$6e,$e1,$35,$53,$30 ; $ddd0 retained data / unresolved code
    !byte $00,$f4,$d2,$f8,$ea,$41,$f2,$44,$d6,$9a,$20,$f4,$a6,$f7,$18,$6c ; $dde0 retained data / unresolved code
    !byte $11,$4c,$00,$f2,$5e,$cb,$87,$c9,$13,$8a,$88,$99,$c2,$29,$80,$f3 ; $ddf0 retained data / unresolved code
    !byte $45,$29,$9a,$2b,$35,$c0,$f3,$9f,$28,$29,$c1,$f4,$54,$e4,$00,$f1 ; $de00 retained data / unresolved code
    !byte $23,$79,$4c,$4c,$0f,$98,$67,$48,$00,$f4,$9a,$f5,$9a,$e1,$f3,$0c ; $de10 retained data / unresolved code
    !byte $e9,$00,$f0,$d8,$22,$2c,$3e,$61,$9d,$20,$00,$f4,$a0,$93,$44,$c1 ; $de20 retained data / unresolved code
    !byte $79,$c3,$e6,$09,$c2,$9a,$a2,$00,$f5,$84,$e2,$85,$e7,$0f,$a0,$fb ; $de30 retained data / unresolved code
    !byte $1a,$20,$f0,$88,$f8,$b8,$00,$f5,$94,$e3,$49,$6a,$70,$00,$f3,$94 ; $de40 retained data / unresolved code
    !byte $84,$ce,$50,$30,$a2,$00,$f4,$e4,$c7,$cd,$22,$d4,$83,$e4,$98,$45 ; $de50 retained data / unresolved code
    !byte $00,$f4,$e4,$c7,$cd,$22,$d4,$83,$e4,$98,$51,$98,$00,$f0,$a2,$63 ; $de60 retained data / unresolved code
    !byte $bd,$8a,$10,$00,$f5,$44,$c1,$45,$42,$76,$a4,$1f,$0d,$f6,$00,$f0 ; $de70 retained data / unresolved code
    !byte $a3,$69,$05,$e7,$0f,$98,$a3,$98,$00,$f1,$04,$e9,$98,$ce,$00,$f4 ; $de80 retained data / unresolved code
    !byte $d5,$31,$38,$3e,$83,$05,$33,$00,$f4,$d5,$31,$38,$3e,$92,$54,$66 ; $de90 retained data / unresolved code
    !byte $14,$00,$f4,$d5,$31,$38,$3e,$49,$98,$d0,$00,$f1,$d5,$13,$07,$d2 ; $dea0 retained data / unresolved code
    !byte $81,$85,$10,$00,$f5,$94,$c6,$3e,$c1,$f1,$d9,$49,$98,$00,$f1,$d5 ; $deb0 retained data / unresolved code
    !byte $13,$0e,$22,$71,$40,$f2,$5e,$cb,$87,$d2,$b3,$e2,$50,$00,$f5,$84 ; $dec0 retained data / unresolved code
    !byte $e2,$85,$e7,$0f,$8f,$48,$dc,$00,$f3,$14,$84,$ce,$53,$14,$40,$f1 ; $ded0 retained data / unresolved code
    !byte $22,$fb,$38,$2f,$38,$7d,$38,$d2,$69,$00,$f0,$cc,$c9,$85,$e7,$0f ; $dee0 retained data / unresolved code
    !byte $84,$c6,$2a,$2a,$10,$00,$f1,$23,$79,$4c,$4c,$0f,$96,$6b,$80,$f4 ; $def0 retained data / unresolved code
    !byte $c4,$f0,$fa,$2a,$72,$00,$f4,$a6,$61,$32,$69,$0f,$85,$18,$be,$d2 ; $df00 retained data / unresolved code
    !byte $00,$f5,$cc,$c6,$3e,$c1,$f4,$a6,$23,$9c,$00,$f4,$a6,$61,$16,$e1 ; $df10 retained data / unresolved code
    !byte $f1,$ae,$60,$00,$f1,$55,$55,$38,$c1,$f2,$44,$c1,$8a,$25,$00,$f2 ; $df20 retained data / unresolved code
    !byte $9c,$43,$3a,$46,$00,$f2,$bf,$e9,$12,$a7,$20,$00,$f5,$92,$a9,$98 ; $df30 retained data / unresolved code
    !byte $3e,$8b,$e4,$60,$00,$f0,$d9,$43,$07,$d1,$7c,$8c,$00,$f4,$4c,$50 ; $df40 retained data / unresolved code
    !byte $fa,$2f,$91,$80,$f5,$cc,$c6,$3e,$c1,$f4,$5f,$23,$00,$f4,$44,$a7 ; $df50 retained data / unresolved code
    !byte $0d,$f6,$0f,$a2,$f9,$18,$00,$f3,$44,$85,$10,$3e,$9c,$54,$27,$21 ; $df60 retained data / unresolved code
    !byte $86,$00,$f8,$40,$f2,$44,$d6,$9a,$21,$79,$c3,$eb,$44,$53,$48,$00 ; $df70 retained data / unresolved code
    !byte $f1,$cd,$17,$9d,$52,$9e,$a4,$1f,$24,$cc,$68,$00,$f8,$40,$f8,$40 ; $df80 retained data / unresolved code
    !byte $f2,$4c,$c6,$85,$e7,$0f,$be,$05,$25,$35,$10,$c0,$f4,$88,$61,$16 ; $df90 retained data / unresolved code
    !byte $9a,$90,$7c,$46,$3c,$4b,$00,$f4,$92,$22,$99,$82,$71,$0c,$00,$f0 ; $dfa0 retained data / unresolved code
    !byte $d8,$22,$2c,$3e,$14,$62,$fb,$48,$00,$f5,$8d,$18,$8b,$52,$0f,$a4 ; $dfb0 retained data / unresolved code
    !byte $95,$19,$85,$00,$f4,$a7,$15,$1c,$d2,$81,$85,$10,$00,$f4,$92,$63 ; $dfc0 retained data / unresolved code
    !byte $4d,$b4,$92,$88,$00,$f4,$54,$84,$cc,$3e,$59,$ae,$00,$f3,$0c,$79 ; $dfd0 retained data / unresolved code
    !byte $87,$cb,$35,$c0,$f3,$0d,$53,$44,$00,$f3,$a9,$30,$00,$f0,$de,$c9 ; $dfe0 retained data / unresolved code
    !byte $80,$f4,$a0,$27,$38,$d1,$00,$f4,$92,$22,$be,$c1,$f3,$1e,$45,$80 ; $dff0 retained data / unresolved code
    !byte $f4,$92,$22,$be,$c1,$f1,$5e,$f8,$80,$f3,$55,$23,$45,$44,$7c,$4a ; $e000 retained data / unresolved code
    !byte $60,$00,$f2,$5e,$cb,$87,$c2,$a9,$9c,$83,$44,$00,$f4,$92,$22,$be ; $e010 retained data / unresolved code
    !byte $d2,$4a,$aa,$00,$f2,$c4,$c5,$6a,$41,$f2,$05,$18,$be,$66,$00,$f1 ; $e020 retained data / unresolved code
    !byte $d8,$26,$98,$3e,$5b,$94,$73,$00,$f4,$4c,$5d,$48,$3e,$94,$d4,$c3 ; $e030 retained data / unresolved code
    !byte $4e,$6f,$00,$f2,$4c,$28,$ce,$46,$32,$cd,$10,$00,$f8,$40,$f8,$40 ; $e040 retained data / unresolved code
    !byte $f8,$40,$f1,$5a,$e2,$87,$d2,$20,$98,$60,$00,$f2,$5e,$cb,$87,$d3 ; $e050 retained data / unresolved code
    !byte $f3,$bd,$30,$00,$f1,$a6,$68,$b8,$4c,$0f,$a6,$f8,$91,$20,$f3,$e4 ; $e060 retained data / unresolved code
    !byte $47,$bb,$52,$0f,$a5,$31,$1c,$e0,$f0,$9c,$83,$33,$52,$0f,$a2,$a7 ; $e070 retained data / unresolved code
    !byte $20,$00,$f1,$4c,$29,$a5,$2f,$8b,$80,$f4,$a6,$23,$9c,$2f,$38,$7c ; $e080 retained data / unresolved code
    !byte $d1,$39,$02,$88,$00,$f4,$cd,$26,$08,$3e,$8a,$9c,$80,$00,$f1,$5a ; $e090 retained data / unresolved code
    !byte $e2,$87,$c3,$88,$88,$68,$c8,$00,$f1,$4c,$29,$a4,$3e,$3a,$1c,$00 ; $e0a0 retained data / unresolved code
    !byte $f4,$d3,$47,$14,$d1,$0f,$a5,$67,$c4,$a0,$f4,$1e,$a9,$3d,$c1,$f1 ; $e0b0 retained data / unresolved code
    !byte $44,$84,$1a,$20,$f4,$a0,$28,$ac,$3e,$1b,$04,$53,$00,$f2,$04,$ca ; $e0c0 retained data / unresolved code
    !byte $89,$ca,$20,$7c,$f1,$bc,$c0,$f2,$45,$16,$bd,$ca,$20,$7c,$83,$34 ; $e0d0 retained data / unresolved code
    !byte $00,$f4,$e8,$e4,$07,$d2,$4a,$8c,$c2,$80,$f4,$e8,$e4,$07,$d0,$60 ; $e0e0 retained data / unresolved code
    !byte $a6,$60,$00,$f3,$54,$e9,$4e,$26,$64,$83,$e4,$31,$f5,$30,$00,$f2 ; $e0f0 retained data / unresolved code
    !byte $68,$e9,$9a,$32,$0f,$88,$c7,$89,$60,$f1,$4c,$29,$a4,$3e,$48,$9a ; $e100 retained data / unresolved code
    !byte $d3,$44,$00,$f0,$d8,$f7,$94,$3e,$69,$a4,$90,$fa,$2f,$19,$80,$f4 ; $e110 retained data / unresolved code
    !byte $9e,$f9,$a5,$4e,$40,$7c,$31,$31,$a0,$f3,$44,$83,$48,$3e,$23,$1e ; $e120 retained data / unresolved code
    !byte $25,$80,$f1,$c4,$d5,$31,$42,$88,$7c,$74,$38,$00,$f2,$5f,$48,$a1 ; $e130 retained data / unresolved code
    !byte $82,$94,$80,$f4,$d2,$a3,$54,$d2,$0f,$92,$f7,$94,$00,$f4,$a9,$13 ; $e140 retained data / unresolved code
    !byte $24,$4e,$28,$7c,$26,$d1,$86,$98,$00,$f4,$d2,$a3,$54,$d2,$0f,$8a ; $e150 retained data / unresolved code
    !byte $28,$cc,$00,$f4,$93,$15,$31,$81,$f1,$d9,$49,$98,$00,$f0,$9c,$83 ; $e160 retained data / unresolved code
    !byte $33,$52,$0f,$92,$28,$c0,$00,$f4,$d2,$60,$f8,$6f,$7a,$c0,$f4,$e2 ; $e170 retained data / unresolved code
    !byte $f9,$a4,$3e,$60,$9c,$43,$00,$f1,$5a,$e2,$87,$d2,$a2,$a6,$00,$f1 ; $e180 retained data / unresolved code
    !byte $5a,$e2,$87,$c7,$60,$94,$c0,$00,$f4,$29,$18,$30,$c1,$f2,$4c,$28 ; $e190 retained data / unresolved code
    !byte $cc,$00,$f4,$d5,$31,$38,$3e,$1c,$44,$43,$46,$40,$f1,$8c,$c9,$2d ; $e1a0 retained data / unresolved code
    !byte $4e,$0f,$a7,$47,$28,$80,$f4,$9f,$12,$1a,$26,$8e,$a4,$1f,$25,$ef ; $e1b0 retained data / unresolved code
    !byte $28,$00,$f1,$5a,$e2,$87,$d2,$98,$8e,$70,$00,$f1,$23,$79,$4c,$4c ; $e1c0 retained data / unresolved code
    !byte $0f,$90,$66,$80,$f5,$84,$e2,$85,$e7,$0f,$8e,$f8,$90,$c0,$f1,$18 ; $e1d0 retained data / unresolved code
    !byte $a0,$f9,$97,$89,$80,$f5,$df,$49,$a4,$3e,$83,$e6,$a7,$b8,$00,$f8 ; $e1e0 retained data / unresolved code
    !byte $40,$f8,$40,$f8,$40,$f8,$40,$f8,$40,$f8,$40,$f8,$40,$f8,$40,$f8 ; $e1f0 retained data / unresolved code
    !byte $40,$f8,$40,$f8,$40,$f8,$40,$f8,$40,$f8,$40,$f8,$40,$f8,$40,$f3 ; $e200 retained data / unresolved code
    !byte $66,$98,$87,$d2,$a2,$a6,$00,$f4,$d5,$31,$38,$3e,$95,$15,$30,$00 ; $e210 retained data / unresolved code
    !byte $f3,$44,$83,$48,$3e,$43,$1f,$53,$00,$f1,$d8,$28,$98,$3e,$24,$6f ; $e220 retained data / unresolved code
    !byte $29,$89,$80,$f2,$5e,$cb,$87,$cd,$54,$a4,$a6,$18,$00,$f2,$1e,$59 ; $e230 retained data / unresolved code
    !byte $68,$3e,$1b,$04,$53,$00,$f2,$68,$e9,$9a,$21,$f0,$d8,$22,$98,$00 ; $e240 retained data / unresolved code
    !byte $f4,$a6,$23,$9c,$2f,$38,$7c,$87,$96,$40,$f2,$5f,$17,$05,$e7,$0f ; $e250 retained data / unresolved code
    !byte $90,$f2,$c8,$00,$f8,$40,$f8,$40,$f8,$40,$f8,$40,$f8,$40,$f8,$40 ; $e260 retained data / unresolved code
    !byte $f8,$40,$00,$ff,$01,$01,$ff,$ff,$ff,$01,$ff,$ff,$ff,$ff,$ff,$ff ; $e270 retained data / unresolved code
    !byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$01,$18,$ff,$ff,$ff,$ff,$01,$ff ; $e280 retained data / unresolved code
    !byte $ff,$32,$50,$ff,$ff,$ff,$01,$01,$ff,$01,$01,$ff,$ff,$01,$0a,$50 ; $e290 retained data / unresolved code
    !byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$32,$ff,$01,$ff,$04,$ff,$ff ; $e2a0 retained data / unresolved code
    !byte $01,$ff,$ff,$ff,$ff,$ff,$58,$ff,$50,$58,$41,$0a,$ff,$ff,$ff,$ff ; $e2b0 retained data / unresolved code
    !byte $01,$ff,$23,$ff,$33,$ff,$14,$ff,$ff,$19,$23,$40,$ff,$ff,$3c,$0a ; $e2c0 retained data / unresolved code
    !byte $0a,$ff,$11,$ff,$1e,$01,$01,$ff,$1e,$07,$01,$0b,$01,$01,$ff,$ff ; $e2d0 retained data / unresolved code
    !byte $01,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$01,$0a,$ff,$ff,$ff,$01,$ff,$18 ; $e2e0 retained data / unresolved code
    !byte $0a,$ff,$ff,$ff,$01,$05,$ff,$ff,$0a,$01,$ff,$ff,$ff,$ff,$18,$ff ; $e2f0 retained data / unresolved code
    !byte $ff,$ff,$03,$19,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff ; $e300 retained data / unresolved code
    !byte $ff,$ff,$18,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff ; $e310 retained data / unresolved code
    !byte $ff,$ff,$14,$ff,$ff,$ff,$ff,$ff,$ff,$02,$ff,$0a,$ff,$1e,$ff,$19 ; $e320 retained data / unresolved code
    !byte $ff,$01,$ff,$ff,$ff,$05,$01,$ff,$ff,$ff,$ff,$ff,$ff,$05,$0a,$ff ; $e330 retained data / unresolved code
    !byte $02,$ff,$ff,$01,$05,$05,$04,$ff,$ff,$ff,$0a,$ff,$ff,$ff,$ff,$03 ; $e340 retained data / unresolved code
    !byte $0a,$0f,$0a,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff ; $e350 retained data / unresolved code
    !byte $ff,$ff,$ff,$ff,$ff,$ff,$05,$01,$ff,$ff,$0a,$19,$ff,$ff,$ff,$ff ; $e360 retained data / unresolved code
    !byte $ff,$ff,$ff,$00,$00,$00,$21,$40,$00,$21,$60,$00,$40,$00,$00,$00 ; $e370 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$40,$00,$21,$00,$00,$00,$00,$00 ; $e380 retained data / unresolved code
    !byte $41,$00,$00,$00,$00,$00,$21,$00,$00,$00,$60,$00,$00,$24,$00,$42 ; $e390 retained data / unresolved code
    !byte $60,$00,$42,$21,$00,$00,$00,$62,$00,$00,$00,$00,$00,$00,$00,$00 ; $e3a0 retained data / unresolved code
    !byte $00,$00,$42,$43,$34,$41,$00,$00,$22,$00,$00,$21,$00,$00,$00,$00 ; $e3b0 retained data / unresolved code
    !byte $00,$22,$24,$62,$42,$61,$00,$00,$00,$00,$00,$00,$62,$00,$00,$00 ; $e3c0 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$21,$00,$00,$00,$00,$00,$63,$00 ; $e3d0 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$64,$00,$00,$00,$00,$00 ; $e3e0 retained data / unresolved code
    !byte $00,$00,$00,$00,$63,$00,$48,$63,$00,$00,$00,$00,$00,$00,$00,$26 ; $e3f0 retained data / unresolved code
    !byte $00,$48,$00,$00,$00,$00,$00,$00,$00,$00,$00,$63,$00,$00,$00,$00 ; $e400 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$a5,$87 ; $e410 retained data / unresolved code
    !byte $62,$89,$69,$a7,$20,$00,$00,$00,$00,$00,$00,$43,$00,$00,$63,$00 ; $e420 retained data / unresolved code
    !byte $00,$00,$63,$62,$63,$00,$00,$00,$00,$00,$00,$63,$00,$00,$00,$00 ; $e430 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$87,$00,$81,$00,$00,$00,$00,$27,$00 ; $e440 retained data / unresolved code
    !byte $63,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $e450 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$89,$a9,$29,$00,$00,$00,$00,$00 ; $e460 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$02 ; $e470 retained data / unresolved code
    !byte $03,$04,$05,$01,$01,$01,$01,$00,$00,$00,$20,$03,$04,$05,$00,$04 ; $e480 retained data / unresolved code
    !byte $40,$00,$00,$20,$02,$02,$20,$00,$06,$00,$20,$02,$02,$20,$00,$10 ; $e490 retained data / unresolved code
    !byte $12,$03,$10,$40,$04,$03,$03,$00,$00,$02,$03,$00,$05,$00,$07,$06 ; $e4a0 retained data / unresolved code
    !byte $00,$05,$02,$00,$10,$30,$00,$00,$32,$00,$00,$60,$05,$02,$04,$00 ; $e4b0 retained data / unresolved code
    !byte $00,$22,$10,$11,$10,$10,$04,$08,$04,$03,$00,$01,$10,$00,$00,$00 ; $e4c0 retained data / unresolved code
    !byte $02,$02,$00,$03,$00,$00,$00,$00,$40,$00,$00,$00,$00,$00,$20,$30 ; $e4d0 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$25,$33,$00,$00,$30,$00,$00,$00,$04,$20 ; $e4e0 retained data / unresolved code
    !byte $00,$0a,$16,$05,$30,$02,$41,$42,$11,$00,$0a,$00,$00,$25,$02,$24 ; $e4f0 retained data / unresolved code
    !byte $04,$31,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$27,$00,$00,$09 ; $e500 retained data / unresolved code
    !byte $1c,$00,$00,$08,$50,$00,$00,$00,$00,$00,$00,$00,$00,$00,$73,$54 ; $e510 retained data / unresolved code
    !byte $10,$31,$21,$42,$52,$00,$00,$00,$07,$00,$00,$33,$02,$00,$24,$02 ; $e520 retained data / unresolved code
    !byte $08,$00,$42,$31,$32,$00,$00,$17,$0c,$07,$28,$51,$04,$00,$04,$00 ; $e530 retained data / unresolved code
    !byte $00,$04,$00,$00,$02,$02,$00,$51,$0f,$50,$00,$0a,$14,$03,$21,$00 ; $e540 retained data / unresolved code
    !byte $20,$05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $e550 retained data / unresolved code
    !byte $00,$00,$00,$0a,$0f,$04,$00,$00,$55,$53,$32,$00,$00,$00,$00,$00 ; $e560 retained data / unresolved code
    !byte $00,$00,$00

; Indexed item/rule bytes referenced by resident game logic.
; Low nibble is tested against type values such as 6 and 12.
; Full field and table extent are not yet established.
    !byte $00,$00,$00,$01,$01,$01,$01,$01,$0b,$01,$02,$02,$03 ; $e573 retained data / unresolved code
    !byte $03,$03,$03,$03,$04,$05,$05,$06,$01,$0c,$01,$02,$03,$03,$07,$03 ; $e580 retained data / unresolved code
    !byte $01,$06,$0a,$01,$04,$05,$01,$0a,$03,$07,$01,$08,$06,$11,$0c,$01 ; $e590 retained data / unresolved code
    !byte $01,$0e,$01,$01,$02,$04,$05,$01,$0a,$0a,$02,$07,$03,$01,$03,$03 ; $e5a0 retained data / unresolved code
    !byte $07,$02,$01,$01,$01,$51,$09,$0a,$01,$06,$06,$0c,$02,$0b,$04,$0a ; $e5b0 retained data / unresolved code
    !byte $07,$01,$01,$01,$01,$08,$02,$03,$05,$04,$09,$08,$01,$0a,$06,$0c ; $e5c0 retained data / unresolved code
    !byte $06,$06,$08,$01,$0a,$07,$07,$08,$01,$0a,$07,$09,$07,$0a,$01,$61 ; $e5d0 retained data / unresolved code
    !byte $0a,$0a,$08,$00,$00,$00,$0a,$09,$0a,$0d,$01,$0a,$0a,$0a,$0b,$0c ; $e5e0 retained data / unresolved code
    !byte $0d,$03,$02,$04,$01,$06,$51,$01,$09,$0a,$04,$0a,$0a,$08,$0c,$01 ; $e5f0 retained data / unresolved code
    !byte $0a,$01,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$01,$04,$0a,$0a,$04 ; $e600 retained data / unresolved code
    !byte $03,$01,$0a,$02,$71,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$01,$01 ; $e610 retained data / unresolved code
    !byte $01,$01,$01,$01,$71,$0a,$0a,$0a,$03,$0a,$0a,$11,$08,$06,$51,$08 ; $e620 retained data / unresolved code
    !byte $03,$07,$01,$11,$01,$06,$0a,$02,$03,$05,$03,$01,$03,$0a,$03,$07 ; $e630 retained data / unresolved code
    !byte $0a,$04,$0a,$0a,$06,$06,$0a,$01,$0e,$01,$0a,$03,$06,$04,$01,$0a ; $e640 retained data / unresolved code
    !byte $09,$06,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a ; $e650 retained data / unresolved code
    !byte $0a,$0a,$0a,$03,$03,$05,$0a,$01,$01,$01,$01,$06,$0a,$0a,$0a,$0a ; $e660 retained data / unresolved code
    !byte $0a,$0a,$0a,$00,$ff,$ff,$8f,$9f,$ff,$8f,$87,$9f,$ff,$9f,$8e,$9f ; $e670 retained data / unresolved code
    !byte $8f,$8e,$86,$ff,$9f,$ff,$86,$08,$9f,$9f,$9e,$9e,$8f,$9e,$ff,$70 ; $e680 retained data / unresolved code
    !byte $08,$08,$60,$ff,$9f,$8c,$8f,$9b,$86,$ff,$9f,$ff,$08,$8e,$9f,$8e ; $e690 retained data / unresolved code
    !byte $ff,$71,$8e,$9e,$9e,$9e,$84,$04,$99,$ff,$9e,$ff,$8e,$02,$86,$70 ; $e6a0 retained data / unresolved code
    !byte $ff,$04,$60,$ff,$10,$8e,$60,$70,$60,$08,$08,$86,$8e,$08,$86,$ff ; $e6b0 retained data / unresolved code
    !byte $08,$60,$61,$86,$fc,$ff,$9e,$8c,$84,$60,$60,$86,$8e,$9f,$08,$9f ; $e6c0 retained data / unresolved code
    !byte $08,$08,$62,$08,$60,$ff,$ff,$ff,$86,$6c,$ff,$60,$ff,$ff,$84,$86 ; $e6d0 retained data / unresolved code
    !byte $ff,$ff,$ff,$ff,$ff,$ff,$60,$60,$ff,$ff,$9f,$ff,$ff,$ff,$9f,$9f ; $e6e0 retained data / unresolved code
    !byte $ff,$84,$8c,$86,$9f,$08,$9e,$04,$60,$02,$86,$ff,$ff,$01,$02,$60 ; $e6f0 retained data / unresolved code
    !byte $02,$87,$01,$01,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$84,$86,$ff,$ff,$10 ; $e700 retained data / unresolved code
    !byte $10,$86,$9f,$8e,$8e,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$10,$04 ; $e710 retained data / unresolved code
    !byte $10,$10,$10,$10,$10,$ff,$ff,$ff,$8e,$ff,$ff,$60,$ff,$08,$20,$60 ; $e720 retained data / unresolved code
    !byte $70,$ff,$08,$10,$80,$08,$60,$8c,$84,$08,$02,$80,$60,$ff,$20,$20 ; $e730 retained data / unresolved code
    !byte $60,$10,$10,$10,$08,$08,$04,$86,$84,$84,$ff,$70,$02,$60,$20,$60 ; $e740 retained data / unresolved code
    !byte $60,$08,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff ; $e750 retained data / unresolved code
    !byte $ff,$ff,$ff,$86,$80,$60,$60,$9f,$84,$02,$60,$08,$ff,$ff,$ff,$ff ; $e760 retained data / unresolved code
    !byte $ff,$ff,$ff,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $e770 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $e780 retained data / unresolved code
    !byte $05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $e790 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$06,$00,$00,$00,$00,$00 ; $e7a0 retained data / unresolved code
    !byte $00,$00,$02,$00,$08,$00,$00,$09,$00,$00,$00,$00,$00,$00,$00,$00 ; $e7b0 retained data / unresolved code
    !byte $00,$04,$00,$00,$00,$0a,$00,$00,$00,$00,$00,$00,$00,$07,$00,$00 ; $e7c0 retained data / unresolved code
    !byte $00,$00,$00,$05,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$01,$00 ; $e7d0 retained data / unresolved code
    !byte $00,$0b,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $e7e0 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$02 ; $e7f0 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$08 ; $e800 retained data / unresolved code
    !byte $00,$00,$00,$0a,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $e810 retained data / unresolved code
    !byte $06,$08,$00,$00,$0a,$00,$00,$00,$00,$00,$00,$0d,$0e,$06,$04,$00 ; $e820 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0d ; $e830 retained data / unresolved code
    !byte $00,$08,$06,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0e,$0d,$00 ; $e840 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $e850 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0c,$00,$00,$00,$00,$00 ; $e860 retained data / unresolved code
    !byte $00,$00,$00,$ff,$7e,$7f,$ff,$ff,$ff,$83,$ff,$ff,$ff,$ff,$ff,$ff ; $e870 retained data / unresolved code
    !byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$83,$83,$ff,$ff,$ff,$ff,$84,$ff ; $e880 retained data / unresolved code
    !byte $ff,$85,$06,$ff,$ff,$ff,$83,$83,$ff,$84,$83,$ff,$ff,$83,$83,$06 ; $e890 retained data / unresolved code
    !byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$83,$0e,$ff,$84,$ff,$83,$ff,$ff ; $e8a0 retained data / unresolved code
    !byte $84,$ff,$ff,$ff,$ff,$ff,$33,$ff,$31,$36,$85,$83,$ff,$ff,$ff,$ff ; $e8b0 retained data / unresolved code
    !byte $84,$ff,$22,$ff,$42,$ff,$85,$ff,$ff,$45,$85,$40,$ff,$ff,$85,$83 ; $e8c0 retained data / unresolved code
    !byte $23,$0b,$37,$83,$24,$84,$84,$ff,$83,$49,$3f,$4b,$4d,$4e,$83,$ff ; $e8d0 retained data / unresolved code
    !byte $4e,$ff,$ff,$82,$82,$82,$82,$43,$80,$81,$83,$ff,$82,$7a,$82,$83 ; $e8e0 retained data / unresolved code
    !byte $81,$ff,$ff,$ff,$83,$45,$ff,$0b,$85,$83,$ff,$82,$82,$07,$83,$ff ; $e8f0 retained data / unresolved code
    !byte $ff,$ff,$0f,$15,$82,$82,$82,$82,$82,$82,$ff,$82,$82,$ff,$ff,$ff ; $e900 retained data / unresolved code
    !byte $82,$4b,$83,$82,$5b,$82,$82,$82,$82,$82,$82,$82,$82,$82,$0b,$0b ; $e910 retained data / unresolved code
    !byte $ff,$ff,$3d,$47,$ff,$ff,$ff,$ff,$ff,$4e,$7e,$25,$ff,$85,$ff,$45 ; $e920 retained data / unresolved code
    !byte $ff,$84,$0b,$ff,$0c,$45,$86,$ff,$ff,$ff,$ff,$ff,$ff,$0f,$49,$84 ; $e930 retained data / unresolved code
    !byte $57,$2d,$ff,$85,$11,$0f,$3e,$ff,$ff,$ff,$22,$ff,$ff,$37,$ff,$86 ; $e940 retained data / unresolved code
    !byte $63,$85,$5f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff ; $e950 retained data / unresolved code
    !byte $ff,$ff,$ff,$ff,$ff,$ff,$86,$83,$ff,$ff,$78,$85,$ff,$ff,$ff,$ff ; $e960 retained data / unresolved code
    !byte $ff,$ff,$ff,$30,$33,$36,$39,$3c,$3f,$42,$45,$48,$4b,$4e,$51 ; $e970 retained data / unresolved code
    sec ; $e97f  38
    !byte $24,$18 ; $e980 retained data / unresolved code
    php ; $e982  08
    ldx $36 ; $e983  a6 36
    ldy $37 ; $e985  a4 37
    jsr $751c ; $e987  20 1c 75
    jsr $8489 ; $e98a  20 89 84
    lda $58 ; $e98d  a5 58
    cmp #$7e ; $e98f  c9 7e
    bcs l_e9a0 ; $e991  b0 0d
    jsr $740a ; $e993  20 0a 74

; Packed text: 'casts a spell<$0d>'
    !byte $20,$a5,$39,$04,$41,$94,$0c,$c6,$74,$00 ; $e996 retained data / unresolved code
l_e9a0:
    plp ; $e9a0  28
    bcs l_e9be ; $e9a1  b0 1b
    jsr l_ec30 ; $e9a3  20 30 ec
    bcc l_e9be ; $e9a6  90 16
l_e9a8:
    jsr $740a ; $e9a8  20 0a 74

; Packed text: 'but it fizzled!<$0d><$0d>'
    !byte $1d,$26,$15,$4c,$27,$57,$c3,$f8,$6c,$31,$79,$de,$80 ; $e9ab retained data / unresolved code
    jsr l_fb81 ; $e9b8  20 81 fb
    jmp $8f5b ; $e9bb  4c 5b 8f
l_e9be:
    lda $58 ; $e9be  a5 58
    cmp #$15 ; $e9c0  c9 15
    beq l_e9ce ; $e9c2  f0 0a
    lda $73 ; $e9c4  a5 73
    beq l_e9ce ; $e9c6  f0 06
    lda $58 ; $e9c8  a5 58
    cmp #$7e ; $e9ca  c9 7e
    bcc l_e9a8 ; $e9cc  90 da
l_e9ce:
    lda $5e ; $e9ce  a5 5e
    bne l_e9da ; $e9d0  d0 08
    jsr $799c ; $e9d2  20 9c 79
    bcc l_e9da ; $e9d5  90 03
    jmp l_fb81 ; $e9d7  4c 81 fb
l_e9da:
    ldy $58 ; $e9da  a4 58
    lda $edb2,y ; $e9dc  b9 b2 ed
    sta $59 ; $e9df  85 59
    lda $ee3a,y ; $e9e1  b9 3a ee
    sta $5b ; $e9e4  85 5b
    lda $ed2a,y ; $e9e6  b9 2a ed
    sta $5a ; $e9e9  85 5a
    ldx $5e ; $e9eb  a6 5e
    beq l_e9f5 ; $e9ed  f0 06
    and #$08 ; $e9ef  29 08
    beq l_e9a8 ; $e9f1  f0 b5
    lda #$10 ; $e9f3  a9 10
l_e9f5:
    and #$10 ; $e9f5  29 10
    beq l_e9a8 ; $e9f7  f0 af
    cpy #$7e ; $e9f9  c0 7e
    bcc l_ea19 ; $e9fb  90 1c
    cpy #$80 ; $e9fd  c0 80
    bcc l_ea07 ; $e9ff  90 06
    jsr l_f609 ; $ea01  20 09 f6
    jmp l_fb81 ; $ea04  4c 81 fb
l_ea07:
    jsr $740a ; $ea07  20 0a 74

; Packed text: 'makes a light'
    !byte $68,$96,$69,$04,$41,$62,$90,$99,$80 ; $ea0a retained data / unresolved code
    jsr l_f57e ; $ea13  20 7e f5
    jmp l_fb81 ; $ea16  4c 81 fb
l_ea19:
    tya ; $ea19  98
    asl ; $ea1a  0a
    tax ; $ea1b  aa
    lda $ea31,x ; $ea1c  bd 31 ea
    sta $12 ; $ea1f  85 12
    lda $ea32,x ; $ea21  bd 32 ea
    sta $13 ; $ea24  85 13
    tya ; $ea26  98
    tax ; $ea27  aa
    jsr l_ea2e ; $ea28  20 2e ea
    jmp l_fb81 ; $ea2b  4c 81 fb
l_ea2e:
    jmp ($0012) ; $ea2e  6c 12 00
    !byte $7e,$f5,$92,$ef,$79,$f7,$f3,$f4,$ae,$f5,$88,$f3,$7e,$f5,$b8,$f5 ; $ea31 retained data / unresolved code
    !byte $92,$ef,$10,$f6,$88,$f3,$7e,$f5,$92,$ef,$88,$f3,$b8,$f5,$88,$f3 ; $ea41 retained data / unresolved code
    !byte $fa,$f5,$5c,$f8,$10,$f6,$70,$f5,$88,$f3,$06,$f6,$92,$ef,$70,$f5 ; $ea51 retained data / unresolved code
    !byte $c6,$f5,$dc,$f5,$53,$f5,$92,$ef,$92,$ef,$92,$ef,$1e,$f6,$53,$f5 ; $ea61 retained data / unresolved code
    !byte $8f,$f4,$dc,$f5,$88,$f3,$92,$ef,$92,$ef,$88,$f3,$92,$ef,$13,$f5 ; $ea71 retained data / unresolved code
    !byte $c6,$f5,$35,$f7,$10,$f6,$2d,$f5,$10,$f6,$13,$f5,$c6,$f5,$7e,$f5 ; $ea81 retained data / unresolved code
    !byte $10,$f6,$35,$f7,$92,$ef,$10,$f6,$c6,$f5,$92,$ef,$10,$f6,$92,$ef ; $ea91 retained data / unresolved code
    !byte $35,$f7,$10,$f6,$92,$ef,$10,$f6,$92,$ef,$92,$ef,$88,$f3,$10,$f6 ; $eaa1 retained data / unresolved code
    !byte $92,$ef,$28,$f6,$92,$ef,$10,$f6,$88,$f3,$92,$ef,$92,$ef,$bb,$f4 ; $eab1 retained data / unresolved code
    !byte $40,$f8,$1f,$f8,$e2,$f8,$92,$ef,$88,$f3,$10,$f6,$92,$ef,$88,$f3 ; $eac1 retained data / unresolved code
    !byte $a8,$e9,$a8,$e9,$92,$ef,$92,$ef,$a8,$e9,$a8,$e9,$92,$ef,$92,$ef ; $ead1 retained data / unresolved code
    !byte $a8,$e9,$a8,$e9,$17,$f6,$92,$ef,$a8,$e9,$a8,$e9,$8a,$f9,$88,$f3 ; $eae1 retained data / unresolved code
    !byte $a8,$e9,$a8,$e9,$1f,$f8,$1f,$f8,$a8,$e9,$a8,$e9,$dc,$f5,$92,$ef ; $eaf1 retained data / unresolved code
    !byte $a8,$e9,$a8,$e9,$92,$ef,$9d,$f7,$9d,$f7,$92,$ef,$10,$f6,$8f,$f4 ; $eb01 retained data / unresolved code
    !byte $92,$ef,$9d,$f7,$9d,$f7,$5c,$f8,$9d,$f7,$92,$ef,$9d,$f7,$92,$ef ; $eb11 retained data / unresolved code
    !byte $92,$ef,$00,$f9,$de,$f4,$a3,$f8,$92,$ef,$de,$f4,$a5,$5c,$10,$21 ; $eb21 retained data / unresolved code
    !byte $a9,$00,$85,$5d,$20,$52,$eb,$b0,$15,$a9,$01,$20,$e2,$91,$a0,$00 ; $eb31 retained data / unresolved code
    !byte $b1,$12,$f0,$07,$e6,$5d,$20,$52,$eb,$b0,$03,$18,$a9,$00,$60 ; $eb41 retained data / unresolved code
l_eb50:
    sec ; $eb50  38
    !byte $24,$18 ; $eb51 retained data / unresolved code
    php ; $eb53  08
    lsr $ec2f ; $eb54  4e 2f ec
    lda $5c ; $eb57  a5 5c
    jsr l_eb8b ; $eb59  20 8b eb
    sta $16 ; $eb5c  85 16
    lda #$00 ; $eb5e  a9 00
    sta $fc ; $eb60  85 fc
    plp ; $eb62  28
    ror $ec2f ; $eb63  6e 2f ec
    lda $5d ; $eb66  a5 5d
    jsr l_eb8b ; $eb68  20 8b eb
    lsr $ec2f ; $eb6b  4e 2f ec
    clc ; $eb6e  18
    adc $7e ; $eb6f  65 7e
    bcc l_eb75 ; $eb71  90 02
    lda #$ff ; $eb73  a9 ff
l_eb75:
    ldx #$00 ; $eb75  a2 00
    stx $7e ; $eb77  86 7e
    sec ; $eb79  38
    sbc $16 ; $eb7a  e5 16
    bcs l_eb80 ; $eb7c  b0 02
    sec ; $eb7e  38
    rts ; $eb7f  60
l_eb80:
    cmp #$04 ; $eb80  c9 04
    bcs l_eb87 ; $eb82  b0 03
    lda #$01 ; $eb84  a9 01
    rts ; $eb86  60
l_eb87:
    lda #$00 ; $eb87  a9 00
    clc ; $eb89  18
l_eb8a:
    rts ; $eb8a  60
l_eb8b:
    eor #$80 ; $eb8b  49 80
    bmi l_ebb1 ; $eb8d  30 22
    tax ; $eb8f  aa
    lda $cd28,x ; $eb90  bd 28 cd
    sta $12 ; $eb93  85 12
    lda $cd2c,x ; $eb95  bd 2c cd
    sta $13 ; $eb98  85 13
    ldy #$25 ; $eb9a  a0 25
    bit $ec2f ; $eb9c  2c 2f ec
    bpl l_eba3 ; $eb9f  10 02
    ldy #$2e ; $eba1  a0 2e
l_eba3:
    lda $fc ; $eba3  a5 fc
    bne l_eb8a ; $eba5  d0 e3
    lda ($12),y ; $eba7  b1 12
    tax ; $eba9  aa
    iny ; $ebaa  c8
    lda ($12),y ; $ebab  b1 12
    tay ; $ebad  a8
    jmp $8dce ; $ebae  4c ce 8d
l_ebb1:
    and #$7f ; $ebb1  29 7f
    sta $ebe1 ; $ebb3  8d e1 eb
    jsr $91e2 ; $ebb6  20 e2 91
    ldy #$29 ; $ebb9  a0 29
    lda ($12),y ; $ebbb  b1 12
    cmp #$0d ; $ebbd  c9 0d
    bcc l_ebd0 ; $ebbf  90 0f
    ldy #$15 ; $ebc1  a0 15
    bit $ec2f ; $ebc3  2c 2f ec
    bpl l_ebca ; $ebc6  10 02
    ldy #$62 ; $ebc8  a0 62
l_ebca:
    jsr l_eba3 ; $ebca  20 a3 eb
    jmp l_ec14 ; $ebcd  4c 14 ec
l_ebd0:
    ldy #$1e ; $ebd0  a0 1e
    lda ($12),y ; $ebd2  b1 12
    lsr ; $ebd4  4a
    bne $ebdc ; $ebd5  d0 05
    dey ; $ebd7  88
    lda ($12),y ; $ebd8  b1 12
    ror ; $ebda  6a
    !byte $2c,$a9,$ff ; $ebdb retained data / unresolved code
    sta $15 ; $ebde  85 15
    ldx #$00 ; $ebe0  a2 00
    lda #$06 ; $ebe2  a9 06
    jsr $6f83 ; $ebe4  20 83 6f
    bcs l_ebee ; $ebe7  b0 05
    lda #$02 ; $ebe9  a9 02
    jsr l_ec18 ; $ebeb  20 18 ec
l_ebee:
    ldy #$29 ; $ebee  a0 29
    lda ($12),y ; $ebf0  b1 12
    tax ; $ebf2  aa
    lda $ec22,x ; $ebf3  bd 22 ec
    jsr l_ec18 ; $ebf6  20 18 ec
    ldy #$14 ; $ebf9  a0 14
    lda ($12),y ; $ebfb  b1 12
    lsr ; $ebfd  4a
    jsr l_ec18 ; $ebfe  20 18 ec
    jsr mix_random_byte ; $ec01  20 3e ff
    and #$07 ; $ec04  29 07
    jsr l_ec18 ; $ec06  20 18 ec
    jsr mix_random_byte ; $ec09  20 3e ff
    and #$07 ; $ec0c  29 07
    clc ; $ec0e  18
    adc #$02 ; $ec0f  69 02
    jsr l_ec18 ; $ec11  20 18 ec
l_ec14:
    sta $15 ; $ec14  85 15
    lda $79 ; $ec16  a5 79
l_ec18:
    clc ; $ec18  18
    adc $15 ; $ec19  65 15
    bcc l_ec1f ; $ec1b  90 02
    lda #$ff ; $ec1d  a9 ff
l_ec1f:
    sta $15 ; $ec1f  85 15
    rts ; $ec21  60
    !byte $00,$0a,$0a,$05,$05,$00,$00,$05,$00,$00,$11,$11,$16,$00 ; $ec22 retained data / unresolved code
l_ec30:
    lda $5c ; $ec30  a5 5c
    bmi l_ec57 ; $ec32  30 23
    jsr $91e2 ; $ec34  20 e2 91
    ldy #$29 ; $ec37  a0 29
    lda ($12),y ; $ec39  b1 12
    cmp #$0d ; $ec3b  c9 0d
    bcs l_ec57 ; $ec3d  b0 18
    jsr l_ec5b ; $ec3f  20 5b ec
    ldy #$25 ; $ec42  a0 25
    sec ; $ec44  38
    lda ($12),y ; $ec45  b1 12
    sbc $93 ; $ec47  e5 93
    tax ; $ec49  aa
    iny ; $ec4a  c8
    lda ($12),y ; $ec4b  b1 12
    sbc #$00 ; $ec4d  e9 00
    bcc l_ec59 ; $ec4f  90 08
    sta ($12),y ; $ec51  91 12
    txa ; $ec53  8a
    dey ; $ec54  88
    sta ($12),y ; $ec55  91 12
l_ec57:
    clc ; $ec57  18
    rts ; $ec58  60
l_ec59:
    sec ; $ec59  38
    rts ; $ec5a  60
l_ec5b:
    ldx $58 ; $ec5b  a6 58
    lda $eec2,x ; $ec5d  bd c2 ee
    sta $93 ; $ec60  85 93
    ldx $5c ; $ec62  a6 5c
    lda #$0c ; $ec64  a9 0c
    jsr $6f83 ; $ec66  20 83 6f
    bne l_ec6f ; $ec69  d0 04
    lsr $93 ; $ec6b  46 93
    lsr $93 ; $ec6d  46 93
l_ec6f:
    ldx $5c ; $ec6f  a6 5c
    lda #$04 ; $ec71  a9 04
    jsr $6f83 ; $ec73  20 83 6f
    bne l_ec7a ; $ec76  d0 02
    lsr $93 ; $ec78  46 93
l_ec7a:
    rts ; $ec7a  60
l_ec7b:
    ldx #$00 ; $ec7b  a2 00
    stx $16 ; $ec7d  86 16
    ora #$00 ; $ec7f  09 00
    bpl l_ec87 ; $ec81  10 04
    asl ; $ec83  0a
    sta $16 ; $ec84  85 16
    lsr ; $ec86  4a
l_ec87:
    sta $15 ; $ec87  85 15
    ldx $5d ; $ec89  a6 5d
    bmi l_ec91 ; $ec8b  30 04
    ldx $5c ; $ec8d  a6 5c
    bpl l_ecb3 ; $ec8f  10 22
l_ec91:
    lda $cca8,x ; $ec91  bd a8 cc
    sta $12 ; $ec94  85 12
    lda $ccac,x ; $ec96  bd ac cc
    sta $13 ; $ec99  85 13
    ldy #$13 ; $ec9b  a0 13
    lda ($12),y ; $ec9d  b1 12
    and #$0f ; $ec9f  29 0f
    cmp $15 ; $eca1  c5 15
    bcc l_ecb3 ; $eca3  90 0e
    beq l_ecb3 ; $eca5  f0 0c
    ldx #$00 ; $eca7  a2 00
    cmp $16 ; $eca9  c5 16
    bcc l_ecb0 ; $ecab  90 03
    beq l_ecb0 ; $ecad  f0 01
    inx ; $ecaf  e8
l_ecb0:
    txa ; $ecb0  8a
    sec ; $ecb1  38
    rts ; $ecb2  60
l_ecb3:
    clc ; $ecb3  18
    rts ; $ecb4  60
    ldy #$0c ; $ecb5  a0 0c
    !byte $2c,$a0,$06 ; $ecb7 retained data / unresolved code
    bit+2 $00a0 ; $ecba  2c a0 00
    sty $b3 ; $ecbd  84 b3
    ldy #$00 ; $ecbf  a0 00
    sty $4f ; $ecc1  84 4f
    tay ; $ecc3  a8
    bmi l_ecd9 ; $ecc4  30 13
    asl ; $ecc6  0a
    tay ; $ecc7  a8
    lda $d522,y ; $ecc8  b9 22 d5
    sta $3e ; $eccb  85 3e
    lda $d523,y ; $eccd  b9 23 d5
    sta $3f ; $ecd0  85 3f
    ldy #$2b ; $ecd2  a0 2b
    lda ($3e),y ; $ecd4  b1 3e
    jmp l_ecea ; $ecd6  4c ea ec
l_ecd9:
    lda $cca8,y ; $ecd9  b9 a8 cc
    sta $3e ; $ecdc  85 3e
    lda $ccac,y ; $ecde  b9 ac cc
    sta $3f ; $ece1  85 3f
    ldy #$14 ; $ece3  a0 14
    lda ($3e),y ; $ece5  b1 3e
    rol ; $ece7  2a
    rol ; $ece8  2a
    rol ; $ece9  2a
l_ecea:
    and #$03 ; $ecea  29 03
    cmp #$03 ; $ecec  c9 03
    beq l_ecfe ; $ecee  f0 0e
    asl ; $ecf0  0a
    adc $b3 ; $ecf1  65 b3
    tax ; $ecf3  aa
    lda $ed05,x ; $ecf4  bd 05 ed
    ldy $ed06,x ; $ecf7  bc 06 ed
    tax ; $ecfa  aa
    jmp $7419 ; $ecfb  4c 19 74
l_ecfe:
    ldx $3e ; $ecfe  a6 3e
    ldy $3f ; $ed00  a4 3f
    jmp $751c ; $ed02  4c 1c 75
    !byte $17,$ed,$19,$ed,$1c,$ed,$1e,$ed,$21,$ed,$1c,$ed,$24,$ed,$21,$ed ; $ed05 retained data / unresolved code
    !byte $27,$ed,$49,$80,$92,$4c,$00,$54,$c0,$4a,$9a,$00,$49,$a2,$00,$4a ; $ed15 retained data / unresolved code
    !byte $a4,$00,$54,$e4,$00

; Indexed action/property flags used by resident and combat code.
; Masks $07 and $20 occur in callers; full format is not yet established.
    !byte $1c,$0b,$14,$0a,$1c,$38,$1c,$1c,$0a,$1c,$38 ; $ed2a retained data / unresolved code
    !byte $1c,$0a,$3c,$1c,$38,$14,$0a,$1c,$28,$38,$14,$0b,$28,$1c,$1c,$28 ; $ed35 retained data / unresolved code
    !byte $0a,$0b,$0a,$0c,$2c,$14,$1c,$3c,$0b,$0a,$38,$0b,$0c,$1c,$0c,$1c ; $ed45 retained data / unresolved code
    !byte $0a,$1c,$0c,$1c,$1c,$1c,$0c,$0c,$1c,$1c,$0c,$1c,$0a,$fc,$1c,$0a ; $ed55 retained data / unresolved code
    !byte $1c,$0b,$0a,$38,$1c,$08,$0a,$0b,$1c,$38,$0a,$0a,$0c,$0a,$1c,$0c ; $ed65 retained data / unresolved code
    !byte $0a,$1c,$1c,$0c,$38,$1c,$1c,$0a,$0a,$1c,$1c,$0a,$0c,$1c,$1c,$0c ; $ed75 retained data / unresolved code
    !byte $0b,$1c,$1c,$14,$38,$1c,$1c,$38,$0a,$1c,$1c,$1c,$0c,$1c,$1c,$0a ; $ed85 retained data / unresolved code
    !byte $14,$14,$0c,$1c,$14,$0b,$14,$14,$0a,$14,$0b,$14,$0a,$0c,$0a,$14 ; $ed95 retained data / unresolved code
    !byte $fc,$0c,$1c,$1c,$1c,$1c,$1c,$1c,$0b,$1c,$0a,$1c,$0c,$00,$b6,$00 ; $eda5 retained data / unresolved code
    !byte $02,$20,$04,$01,$04,$2a,$00,$0a,$02,$31,$0a,$ff,$fd,$00,$04,$01 ; $edb5 retained data / unresolved code
    !byte $02,$fe,$00,$69,$04,$04,$04,$07,$38,$a8,$3f,$02,$0a,$00,$ff,$fd ; $edc5 retained data / unresolved code
    !byte $af,$70,$00,$bd,$01,$04,$01,$82,$01,$83,$04,$06,$03,$84,$80,$00 ; $edd5 retained data / unresolved code
    !byte $85,$ff,$15,$86,$77,$40,$07,$46,$08,$c4,$4d,$00,$09,$e0,$00,$cb ; $ede5 retained data / unresolved code
    !byte $0a,$00,$54,$7e,$00,$00,$00,$00,$5b,$fd,$0b,$07,$ff,$00,$00,$62 ; $edf5 retained data / unresolved code
    !byte $85,$00,$00,$8c,$ee,$00,$00,$08,$d2,$00,$00,$00,$00,$00,$00,$06 ; $ee05 retained data / unresolved code
    !byte $09,$00,$00,$ff,$1c,$00,$00,$93,$06,$00,$a1,$0c,$80,$d9,$08,$04 ; $ee15 retained data / unresolved code
    !byte $06,$02,$e7,$0a,$9a,$0e,$00,$00,$05,$23,$00,$04,$05,$00,$00,$00 ; $ee25 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$01,$00,$0a,$00,$00,$00,$00,$02,$00,$01 ; $ee35 retained data / unresolved code
    !byte $00,$83,$81,$00,$01,$00,$00,$00,$00,$00,$00,$01,$00,$01,$02,$00 ; $ee45 retained data / unresolved code
    !byte $84,$07,$83,$00,$01,$00,$02,$81,$01,$05,$02,$84,$00,$00,$00,$00 ; $ee55 retained data / unresolved code
    !byte $00,$00,$00,$02,$00,$00,$00,$83,$00,$02,$04,$00,$0a,$0a,$00,$01 ; $ee65 retained data / unresolved code
    !byte $00,$03,$03,$03,$00,$00,$00,$07,$00,$04,$05,$85,$00,$00,$00,$00 ; $ee75 retained data / unresolved code
    !byte $06,$86,$00,$0a,$00,$00,$00,$02,$08,$00,$00,$08,$05,$00,$00,$00 ; $ee85 retained data / unresolved code
    !byte $03,$00,$00,$00,$05,$00,$00,$00,$00,$00,$00,$04,$0a,$00,$00,$84 ; $ee95 retained data / unresolved code
    !byte $00,$00,$0a,$00,$00,$06,$00,$00,$00,$00,$0a,$00,$85,$0a,$05,$00 ; $eea5 retained data / unresolved code
    !byte $0a,$0a,$00,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$02,$03,$02 ; $eeb5 retained data / unresolved code
    !byte $03,$03,$04,$05,$04,$05,$06,$06,$07,$07,$09,$08,$0c,$0f,$12,$0c ; $eec5 retained data / unresolved code
    !byte $03,$03,$02,$04,$05,$05,$06,$06,$06,$08,$07,$08,$0a,$0a,$0a,$19 ; $eed5 retained data / unresolved code
    !byte $10,$0b,$14,$03,$02,$02,$04,$05,$04,$06,$06,$06,$07,$0c,$08,$0a ; $eee5 retained data / unresolved code
    !byte $0b,$0b,$14,$10,$28,$32,$0a,$0b,$0e,$0b,$0e,$0c,$0d,$0e,$10,$0d ; $eef5 retained data / unresolved code
    !byte $16,$12,$10,$19,$0f,$14,$1c,$1a,$1e,$32,$3c,$50,$0c,$0a,$0a,$14 ; $ef05 retained data / unresolved code
    !byte $14,$0f,$0f,$19,$1e,$14,$14,$2d,$32,$19,$19,$3c,$3c,$1e,$1e,$41 ; $ef15 retained data / unresolved code
    !byte $46,$23,$23,$3c,$64,$32,$32,$05,$05,$08,$0a,$0f,$0f,$12,$14,$14 ; $ef25 retained data / unresolved code
    !byte $19,$1e,$28,$28,$32,$3c,$50,$0a,$fa,$96,$01,$86,$12,$84,$13,$c9 ; $ef35 retained data / unresolved code
    !byte $68,$90,$1d,$c9,$6a,$b0,$19,$48,$a0,$29,$b1,$36,$c9,$0b,$d0,$0d ; $ef45 retained data / unresolved code
    !byte $a0,$73,$b1,$36,$29,$08,$f0,$05,$68,$48,$20,$76,$ef,$68,$a4,$13 ; $ef55 retained data / unresolved code
    !byte $20,$83,$ef,$3d,$58,$cd,$a6,$12,$a4,$13,$09,$00,$60,$86,$12,$84 ; $ef65 retained data / unresolved code
    !byte $13,$20,$83,$ef,$1d,$58,$cd,$91,$36,$a6,$12,$a4,$13,$60,$48,$29 ; $ef75 retained data / unresolved code
    !byte $07,$aa,$68,$4a,$4a,$4a,$18,$69,$54,$a8,$b1,$36,$60,$a4,$59,$a2 ; $ef85 retained data / unresolved code
    !byte $00,$b9,$93,$f2,$95,$f5,$c8,$e8,$e0,$07,$90,$f5 ; $ef95 retained data / unresolved code
    lda $fb ; $efa1  a5 fb
    bne l_efbe ; $efa3  d0 19
    ldx $5c ; $efa5  a6 5c
    bmi $efbc ; $efa7  30 13
    txa ; $efa9  8a
    jsr l_f9f0 ; $efaa  20 f0 f9
    bcs $efbc ; $efad  b0 0d
    ldy #$1e ; $efaf  a0 1e
    lda ($49),y ; $efb1  b1 49
    bne $efb9 ; $efb3  d0 04
    dey ; $efb5  88
    lda ($49),y ; $efb6  b1 49
    !byte $2c,$a9,$ff,$2c,$a9,$01 ; $efb8 retained data / unresolved code
l_efbe:
    sta $fb ; $efbe  85 fb
    ldx #$ff ; $efc0  a2 ff
    stx $034f ; $efc2  8e 4f 03
    inx ; $efc5  e8
    stx $0350 ; $efc6  8e 50 03
    lda $fa ; $efc9  a5 fa
    bpl l_efdb ; $efcb  10 0e
    ldx $5c ; $efcd  a6 5c
    bpl l_efd7 ; $efcf  10 06
    and #$7f ; $efd1  29 7f
    sta $fa ; $efd3  85 fa
    bpl l_efdb ; $efd5  10 04
l_efd7:
    lda #$80 ; $efd7  a9 80
    sta $5d ; $efd9  85 5d
l_efdb:
    lda $5c ; $efdb  a5 5c
    ora $5d ; $efdd  05 5d
    bmi l_efea ; $efdf  30 09
    bit $fa ; $efe1  24 fa
    bvc l_efea ; $efe3  50 05
    lda $5c ; $efe5  a5 5c
    sta $034f ; $efe7  8d 4f 03
l_efea:
    lda $5d ; $efea  a5 5d
    bmi l_f02d ; $efec  30 3f
    bit $fa ; $efee  24 fa
    bvc l_eff4 ; $eff0  50 02
    lda #$06 ; $eff2  a9 06
l_eff4:
    sta $87 ; $eff4  85 87
    jsr $740a ; $eff6  20 0a 74

; Packed text: 'at the party...<$0d><$0d>'
    !byte $14,$c3,$34,$98,$30,$14,$67,$7c,$63,$1d,$e8,$00 ; $eff9 retained data / unresolved code
    inc $0350 ; $f005  ee 50 03
    lda $5b ; $f008  a5 5b
    jsr l_ec7b ; $f00a  20 7b ec
    bcc l_f074 ; $f00d  90 65
    beq l_f074 ; $f00f  f0 63
    jsr $740a ; $f011  20 0a 74

; Packed text: 'But the party was too far away!<$0d><$0d>'
    !byte $f0,$e9,$30,$cd,$26,$0c,$05,$19,$dc,$36,$14,$83,$37,$bc,$27,$14 ; $f014 retained data / unresolved code
    !byte $42,$2b,$0a,$fc,$ef,$40 ; $f024 retained data / unresolved code
    jmp $8f5b ; $f02a  4c 5b 8f
l_f02d:
    ldx $5d ; $f02d  a6 5d
    jsr l_f9df ; $f02f  20 df f9
    bne l_f03e ; $f032  d0 0a
    bit $fa ; $f034  24 fa
    bpl l_f03b ; $f036  10 03
    jmp l_f224 ; $f038  4c 24 f2
l_f03b:
    jmp l_f592 ; $f03b  4c 92 f5
l_f03e:
    sec ; $f03e  38
    sbc #$01 ; $f03f  e9 01
    bit $fa ; $f041  24 fa
    bvs l_f047 ; $f043  70 02
    lda #$00 ; $f045  a9 00
l_f047:
    sta $87 ; $f047  85 87
    inc $0350 ; $f049  ee 50 03
    jsr $740a ; $f04c  20 0a 74

; Packed text: 'at '
    !byte $14,$c2,$00 ; $f04f retained data / unresolved code
    lda $87 ; $f052  a5 87
    sta $4f ; $f054  85 4f
    jsr $740a ; $f056  20 0a 74

; Packed text: '/a \\some '
    !byte $fe,$82,$0f,$f5,$93,$da,$60,$80 ; $f059 retained data / unresolved code
    ldx $5d ; $f061  a6 5d
    ldy $ccac,x ; $f063  bc ac cc
    lda $cca8,x ; $f066  bd a8 cc
    tax ; $f069  aa
    jsr $751c ; $f06a  20 1c 75
    jsr $740a ; $f06d  20 0a 74

; Packed text: '...<$0d><$0d>'
    !byte $c6,$31,$de,$80 ; $f070 retained data / unresolved code
l_f074:
    lda #$00 ; $f074  a9 00
    sta $93 ; $f076  85 93
    sta $94 ; $f078  85 94
    lda $fb ; $f07a  a5 fb
l_f07c:
    pha ; $f07c  48
    lda $f9 ; $f07d  a5 f9
    jsr l_fa5a ; $f07f  20 5a fa
    clc ; $f082  18
    lda $12 ; $f083  a5 12
    adc $93 ; $f085  65 93
    sta $93 ; $f087  85 93
    lda $13 ; $f089  a5 13
    adc $94 ; $f08b  65 94
    sta $94 ; $f08d  85 94
    pla ; $f08f  68
    bcs l_f098 ; $f090  b0 06
    sbc #$00 ; $f092  e9 00
    bne l_f07c ; $f094  d0 e6
    beq l_f09e ; $f096  f0 06
l_f098:
    lda #$ff ; $f098  a9 ff
    sta $93 ; $f09a  85 93
    sta $94 ; $f09c  85 94
l_f09e:
    lda $5d ; $f09e  a5 5d
    bpl l_f0ab ; $f0a0  10 09
    jsr $740a ; $f0a2  20 0a 74

; Packed text: 'One '
    !byte $f3,$dc,$60,$80 ; $f0a5 retained data / unresolved code
    bcc l_f110 ; $f0a9  90 65
l_f0ab:
    ldx $87 ; $f0ab  a6 87
    cpx $034f ; $f0ad  ec 4f 03
    beq l_f0e0 ; $f0b0  f0 2e
    lda $03be,x ; $f0b2  bd be 03
    bne l_f0e0 ; $f0b5  d0 29
    txa ; $f0b7  8a
    asl ; $f0b8  0a
    tax ; $f0b9  aa
    lda $d522,x ; $f0ba  bd 22 d5
    sta $42 ; $f0bd  85 42
    sta $38 ; $f0bf  85 38
    lda $d523,x ; $f0c1  bd 23 d5
    sta $43 ; $f0c4  85 43
    sta $39 ; $f0c6  85 39
    ldy #$00 ; $f0c8  a0 00
    lda ($42),y ; $f0ca  b1 42
    beq l_f0e0 ; $f0cc  f0 12
    ldy #$2d ; $f0ce  a0 2d
    lda ($42),y ; $f0d0  b1 42
    and #$0c ; $f0d2  29 0c
    beq l_f0e3 ; $f0d4  f0 0d
    and #$08 ; $f0d6  29 08
    bne l_f0e0 ; $f0d8  d0 06
    lda $f5 ; $f0da  a5 f5
    cmp #$05 ; $f0dc  c9 05
    beq l_f0e3 ; $f0de  f0 03
l_f0e0:
    jmp l_f215 ; $f0e0  4c 15 f2
l_f0e3:
    jsr $7520 ; $f0e3  20 20 75
    jsr $8489 ; $f0e6  20 89 84
    lda $fa ; $f0e9  a5 fa
    lsr ; $f0eb  4a
    bcc l_f10c ; $f0ec  90 1e
    ldx $87 ; $f0ee  a6 87
    lda #$0a ; $f0f0  a9 0a
    jsr $6f83 ; $f0f2  20 83 6f
    bcs l_f10c ; $f0f5  b0 15
l_f0f7:
    jsr $740a ; $f0f7  20 0a 74

; Packed text: 'repelled the attack!<$0d><$0d>'
    !byte $89,$a0,$66,$30,$c5,$0c,$d2,$60,$8a,$73,$11,$17,$ce,$f4,$00 ; $f0fa retained data / unresolved code
    jmp l_f212 ; $f109  4c 12 f2
l_f10c:
    lda $87 ; $f10c  a5 87
    sta $5d ; $f10e  85 5d
l_f110:
    lda $f8 ; $f110  a5 f8
    beq l_f125 ; $f112  f0 11
    lda $5d ; $f114  a5 5d
    jsr l_f9f0 ; $f116  20 f0 f9
    ldy #$71 ; $f119  a0 71
    bcc l_f11f ; $f11b  90 02
    ldy #$2b ; $f11d  a0 2b
l_f11f:
    lda ($42),y ; $f11f  b1 42
    and $f8 ; $f121  25 f8
    beq l_f0f7 ; $f123  f0 d2
l_f125:
    lda $5b ; $f125  a5 5b
    jsr l_ec7b ; $f127  20 7b ec
    bcc l_f132 ; $f12a  90 06
    bne l_f148 ; $f12c  d0 1a
    lda #$04 ; $f12e  a9 04
    sta $7e ; $f130  85 7e
l_f132:
    lda $fa ; $f132  a5 fa
    and #$02 ; $f134  29 02
    beq l_f13e ; $f136  f0 06
    jsr l_eb50 ; $f138  20 50 eb
    jmp l_f141 ; $f13b  4c 41 f1
l_f13e:
    jsr $eb52 ; $f13e  20 52 eb
l_f141:
    bcs l_f15e ; $f141  b0 1b
    tax ; $f143  aa
    bne l_f15b ; $f144  d0 15
    beq l_f0f7 ; $f146  f0 af
l_f148:
    jsr $740a ; $f148  20 0a 74

; Packed text: 'was too far away!<$0d><$0d>'
    !byte $b0,$a4,$19,$bd,$e1,$38,$a2,$11,$58,$57,$e7,$7a,$00 ; $f14b retained data / unresolved code
    jmp l_f212 ; $f158  4c 12 f2
l_f15b:
    jsr l_faa6 ; $f15b  20 a6 fa
l_f15e:
    lda $fa ; $f15e  a5 fa
    and #$03 ; $f160  29 03
    beq l_f16f ; $f162  f0 0b
    lda $5d ; $f164  a5 5d
    bmi l_f16f ; $f166  30 07
    lda $fe ; $f168  a5 fe
    beq l_f16f ; $f16a  f0 03
    jsr l_faa6 ; $f16c  20 a6 fa
l_f16f:
    lda $5d ; $f16f  a5 5d
    jsr l_f9f0 ; $f171  20 f0 f9
    ldy #$6f ; $f174  a0 6f
    bcc l_f17a ; $f176  90 02
    ldy #$29 ; $f178  a0 29
l_f17a:
    lda ($49),y ; $f17a  b1 49
    and $f6 ; $f17c  25 f6
    ldx #$07 ; $f17e  a2 07
l_f180:
    lsr ; $f180  4a
    bcc l_f186 ; $f181  90 03
    jsr l_faa6 ; $f183  20 a6 fa
l_f186:
    dex ; $f186  ca
    bpl l_f180 ; $f187  10 f7
    iny ; $f189  c8
    lda ($49),y ; $f18a  b1 49
    and $f6 ; $f18c  25 f6
    ldx #$07 ; $f18e  a2 07
l_f190:
    lsr ; $f190  4a
    bcc l_f196 ; $f191  90 03
    jsr l_fa97 ; $f193  20 97 fa
l_f196:
    dex ; $f196  ca
    bpl l_f190 ; $f197  10 f7
    lda $93 ; $f199  a5 93
    ora $94 ; $f19b  05 94
    bne l_f1a6 ; $f19d  d0 07
    lda $f5 ; $f19f  a5 f5
    bne l_f1a6 ; $f1a1  d0 03
    jmp l_f0f7 ; $f1a3  4c f7 f0
l_f1a6:
    jsr $740a ; $f1a6  20 0a 74

; Packed text: 'is '
    !byte $54,$82,$00 ; $f1a9 retained data / unresolved code
    ldx $f7 ; $f1ac  a6 f7
    ldy $f250,x ; $f1ae  bc 50 f2
    lda $f24f,x ; $f1b1  bd 4f f2
    tax ; $f1b4  aa
    jsr $7419 ; $f1b5  20 19 74
    jsr $740a ; $f1b8  20 0a 74

; Packed text: ' for '
    !byte $09,$df,$10,$80 ; $f1bb retained data / unresolved code
    lda $93 ; $f1bf  a5 93
    sta $4f ; $f1c1  85 4f
    dec $4f ; $f1c3  c6 4f
    sta $9b ; $f1c5  85 9b
    lda $94 ; $f1c7  a5 94
    beq l_f1cd ; $f1c9  f0 02
    inc $4f ; $f1cb  e6 4f
l_f1cd:
    sta $9c ; $f1cd  85 9c
    jsr $7285 ; $f1cf  20 85 72
    jsr $740a ; $f1d2  20 0a 74

; Packed text: ' point/\\s\\ of damage'
    !byte $0c,$1e,$a7,$4f,$fa,$7f,$59,$7f,$50,$bc,$e1,$28,$9a,$24,$18,$00 ; $f1d5 retained data / unresolved code
    lda $f5 ; $f1e5  a5 f5
    sta $95 ; $f1e7  85 95
    lda $5d ; $f1e9  a5 5d
    jsr $a8bd ; $f1eb  20 bd a8
    bcs l_f1f9 ; $f1ee  b0 09
    jsr $740a ; $f1f0  20 0a 74

; Packed text: '.<$0d><$0d>'
    !byte $c7,$7a,$00 ; $f1f3 retained data / unresolved code
    jmp l_f215 ; $f1f6  4c 15 f2
l_f1f9:
    lda $95 ; $f1f9  a5 95
    asl ; $f1fb  0a
    tax ; $f1fc  aa
    ldy $d997,x ; $f1fd  bc 97 d9
    lda $d996,x ; $f200  bd 96 d9
    tax ; $f203  aa
    jsr $7419 ; $f204  20 19 74
    lda $5d ; $f207  a5 5d
    jsr $ecb8 ; $f209  20 b8 ec
    jsr $740a ; $f20c  20 0a 74

; Packed text: '!<$0d><$0d>'
    !byte $e7,$7a,$00 ; $f20f retained data / unresolved code
l_f212:
    jsr $8f5b ; $f212  20 5b 8f
l_f215:
    bit $fa ; $f215  24 fa
    bvc l_f224 ; $f217  50 0b
    dec $87 ; $f219  c6 87
    lda $87 ; $f21b  a5 87
    cmp #$ff ; $f21d  c9 ff
    beq l_f224 ; $f21f  f0 03
    jmp l_f074 ; $f221  4c 74 f0
l_f224:
    bit $fa ; $f224  24 fa
    bpl l_f244 ; $f226  10 1c
l_f228:
    inc $5d ; $f228  e6 5d
    ldx $5d ; $f22a  a6 5d
    cpx #$84 ; $f22c  e0 84
    beq l_f244 ; $f22e  f0 14
    jsr l_f9df ; $f230  20 df f9
    beq l_f228 ; $f233  f0 f3
    lda $0350 ; $f235  ad 50 03
    beq l_f241 ; $f238  f0 07
    jsr $740a ; $f23a  20 0a 74

; Packed text: 'And '
    !byte $f0,$9c,$50,$80 ; $f23d retained data / unresolved code
l_f241:
    jmp l_efea ; $f241  4c ea ef
l_f244:
    lda $0350 ; $f244  ad 50 03
    bne l_f24c ; $f247  d0 03
    jmp l_f592 ; $f249  4c 92 f5
l_f24c:
    jmp $8f5b ; $f24c  4c 5b 8f
    !byte $65,$f2,$69,$f2,$6f,$f2,$74,$f2,$79,$f2,$7d,$f2,$82,$f2,$87,$f2 ; $f24f retained data / unresolved code
    !byte $8c,$f2,$8f,$f2,$8c,$f2,$3c,$54,$62,$80,$3c,$5f,$f0,$cc,$e0,$00 ; $f25f retained data / unresolved code
    !byte $92,$5e,$45,$98,$a0,$2c,$44,$a7,$18,$a0,$1d,$22,$e9,$80,$22,$5e ; $f26f retained data / unresolved code
    !byte $b3,$14,$00,$94,$cc,$26,$98,$a0,$1b,$05,$29,$98,$a0,$4a,$a6,$00 ; $f27f retained data / unresolved code
    !byte $75,$16,$62,$80,$00,$0c,$04,$00,$38,$c0,$01,$00,$04,$00,$00,$38 ; $f28f retained data / unresolved code
    !byte $c0,$08,$00,$0c,$04,$00,$38,$c0,$10,$00,$14,$02,$00,$58,$c0,$01 ; $f29f retained data / unresolved code
    !byte $00,$04,$10,$00,$3d,$c0,$0d,$00,$04,$12,$00,$5f,$c0,$10,$00,$0c ; $f2af retained data / unresolved code
    !byte $04,$00,$24,$40,$01,$00,$0c,$04,$00,$2e,$40,$01,$00,$0c,$04,$00 ; $f2bf retained data / unresolved code
    !byte $29,$40,$01,$00,$84,$08,$00,$47,$40,$01,$00,$04,$10,$00,$38,$40 ; $f2cf retained data / unresolved code
    !byte $01,$00,$84,$08,$00,$35,$40,$01,$00,$0c,$04,$00,$38,$40,$02,$00 ; $f2df retained data / unresolved code
    !byte $14,$02,$00,$38,$40,$04,$04,$04,$06,$00,$1d,$40,$0a,$00,$24,$06 ; $f2ef retained data / unresolved code
    !byte $80,$25,$00,$01,$00,$14,$02,$00,$33,$40,$01,$00,$04,$0a,$20,$3d ; $f2ff retained data / unresolved code
    !byte $40,$02,$00,$04,$10,$40,$13,$40,$0a,$00,$14,$02,$00,$58,$40,$02 ; $f30f retained data / unresolved code
    !byte $00,$24,$0e,$00,$2b,$40,$05,$00,$24,$00,$00,$38,$40,$08,$00,$84 ; $f31f retained data / unresolved code
    !byte $08,$00,$3d,$40,$0a,$00,$04,$00,$00,$2e,$c0,$0a,$04,$04,$06,$00 ; $f32f retained data / unresolved code
    !byte $2e,$00,$01,$07,$04,$10,$00,$00,$00,$01,$00,$84,$08,$00,$20,$00 ; $f33f retained data / unresolved code
    !byte $00,$00,$0c,$04,$00,$21,$00,$00,$00,$84,$08,$40,$38,$00,$04,$00 ; $f34f retained data / unresolved code
    !byte $24,$06,$00,$38,$00,$02,$07,$04,$10,$00,$00,$00,$01,$06,$04,$10 ; $f35f retained data / unresolved code
    !byte $00,$00,$00,$01,$05,$04,$10,$00,$00,$00,$01,$00,$14,$02,$00,$38 ; $f36f retained data / unresolved code
    !byte $00,$10,$00,$0c,$04,$00,$38,$c0,$02,$a5,$5c,$30,$07,$a5,$5b,$30 ; $f37f retained data / unresolved code
    !byte $06,$20,$a3,$f3,$4c,$92,$f5,$a9,$06,$85,$5d,$20,$a3,$f3,$c6,$5d ; $f38f retained data / unresolved code
    !byte $10,$f9,$30,$f0,$a9,$00,$85,$93,$85,$94,$a5,$5c,$20,$f0,$f9,$a6 ; $f39f retained data / unresolved code
    !byte $59,$f0,$19,$e0,$fe,$90,$12,$d0,$06,$a9,$08,$85,$93,$d0,$0d,$a0 ; $f3af retained data / unresolved code
    !byte $1e,$b1,$49,$d0,$04,$88,$b1,$49,$aa,$20,$7f,$fa,$a5,$5d,$20,$f0 ; $f3bf retained data / unresolved code
    !byte $f9,$a5,$59,$c9,$fd,$f0,$20,$a0,$21,$b1,$49,$18,$65,$93,$91,$49 ; $f3cf retained data / unresolved code
    !byte $c8,$b1,$49,$65,$94,$91,$49,$88,$b1,$49,$a0,$23,$d1,$49,$88,$b1 ; $f3df retained data / unresolved code
    !byte $49,$a0,$24,$f1,$49,$90,$10,$a0,$23,$b1,$49,$a0,$21,$91,$49,$a0 ; $f3ef retained data / unresolved code
    !byte $24,$b1,$49,$a0,$22,$91,$49,$a5,$5b,$0a,$aa,$bd,$1b,$f4,$85,$12 ; $f3ff retained data / unresolved code
    !byte $bd,$1c,$f4,$85,$13,$a0,$2d,$b1,$49,$6c,$12,$00,$2d,$f4,$29,$f4 ; $f40f retained data / unresolved code
    !byte $36,$f4,$46,$f4,$3e,$f4,$69,$f4,$2e,$f4,$29,$ae,$91,$49,$60,$29 ; $f41f retained data / unresolved code
    !byte $aa,$91,$49,$a9,$00,$f0,$2e,$29,$08,$f0,$2e,$a9,$f3,$d0,$0e,$29 ; $f42f retained data / unresolved code
    !byte $04,$f0,$26,$a9,$fb,$d0,$06,$29,$20,$f0,$1e,$a9,$db,$31,$49,$91 ; $f43f retained data / unresolved code
    !byte $49,$a0,$22,$b1,$49,$88,$11,$49,$d0,$04,$a9,$01,$91,$49,$a6,$5d ; $f44f retained data / unresolved code
    !byte $a9,$00,$9d,$2a,$03,$a0,$68,$91,$49,$60,$29,$02,$f0,$fb,$a5,$49 ; $f45f retained data / unresolved code
    !byte $18,$69,$5a,$85,$3c,$a5,$4a,$69,$00,$85,$3d,$a0,$10,$a2,$05,$b1 ; $f46f retained data / unresolved code
    !byte $3c,$91,$49,$c8,$ca,$d0,$f8,$a0,$2d,$a9,$fd,$31,$49,$91,$49,$60 ; $f47f retained data / unresolved code
    !byte $a5,$08,$f0,$25,$ad,$69,$03,$29,$f0,$c9,$90,$b0,$1c,$ad,$69,$03 ; $f48f retained data / unresolved code
    !byte $29,$0f,$8d,$69,$03,$24,$59,$10,$0d,$a6,$0a,$a4,$09,$a5,$0b,$0a ; $f49f retained data / unresolved code
    !byte $0a,$0a,$0a,$20,$be,$7c,$4c,$92,$f5,$4c,$a8,$e9,$20,$0d,$fa,$a5 ; $f4af retained data / unresolved code
    !byte $5c,$30,$05,$ee,$21,$03,$d0,$14,$e6,$81,$20,$0a,$74,$13,$8a,$19 ; $f4bf retained data / unresolved code
    !byte $a4,$c1,$80,$a3,$3b,$84,$f1,$31,$be,$19,$a4,$00,$4c,$92,$f5,$20 ; $f4cf retained data / unresolved code
    !byte $0a,$74,$1d,$26,$15,$4c,$29,$11,$42,$e7,$84,$c7,$39,$89,$3e,$77 ; $f4df retained data / unresolved code
    !byte $a0,$4c,$5b,$8f,$20,$0d,$fa,$18,$a5,$59,$a6,$5c,$30,$0f,$a6,$5d ; $f4ef retained data / unresolved code
    !byte $7d,$9d,$02,$9d,$9d,$02,$e6,$7a,$e6,$7a,$4c,$92,$f5,$65,$77,$85 ; $f4ff retained data / unresolved code
    !byte $77,$4c,$92,$f5,$a6,$5c,$30,$0a,$18,$a5,$59,$65,$76,$85,$76,$4c ; $f50f retained data / unresolved code
    !byte $92,$f5,$38,$bd,$9d,$02,$e5,$59,$9d,$9d,$02,$4c,$92,$f5,$20,$0d ; $f51f retained data / unresolved code
    !byte $fa,$18,$a4,$59,$a5,$5c,$10,$08,$98,$65,$7d,$85,$7d,$4c,$92,$f5 ; $f52f retained data / unresolved code
    !byte $a6,$5d,$98,$7d,$95,$02,$9d,$95,$02,$98,$18,$7d,$99,$02,$9d,$99 ; $f53f retained data / unresolved code
    !byte $02,$4c,$92,$f5,$18,$a6,$5c,$10,$0b,$a5,$59,$7d,$a5,$02,$9d,$a5 ; $f54f retained data / unresolved code
    !byte $02,$4c,$92,$f5,$a6,$5d,$a5,$59,$7d,$07,$03,$9d,$07,$03,$4c,$92 ; $f55f retained data / unresolved code
    !byte $f5,$a6,$5d,$18,$a5,$59,$7d,$0e,$03,$9d,$0e,$03,$4c,$92,$f5 ; $f56f retained data / unresolved code
l_f57e:
    ldx $59 ; $f57e  a6 59
    lda $f59c,x ; $f580  bd 9c f5
    sta $6d ; $f583  85 6d
    lda $f5a8,x ; $f585  bd a8 f5
    sta $68 ; $f588  85 68
    lda $f5a2,x ; $f58a  bd a2 f5
    sta $71 ; $f58d  85 71
    jsr $782c ; $f58f  20 2c 78
l_f592:
    jsr $740a ; $f592  20 0a 74

; Packed text: '...<$0d><$0d>'
    !byte $c6,$31,$de,$80 ; $f595 retained data / unresolved code
    jmp $8f5b ; $f599  4c 5b 8f
    !byte $03,$04,$05,$05,$02,$02,$00,$ff,$ff,$00,$00,$00,$04,$0c,$10,$ff ; $f59c retained data / unresolved code
    !byte $04,$08,$a5,$59,$85,$65,$20,$cd,$78,$4c,$92,$f5,$a5,$59,$85,$64 ; $f5ac retained data / unresolved code
    !byte $a9,$00,$85,$6c,$20,$4d,$78,$4c,$92,$f5,$a5,$59,$85,$66,$a5,$5b ; $f5bc retained data / unresolved code
    !byte $85,$69,$a9,$00,$85,$6a,$a9,$08,$85,$6b,$20,$71,$78,$4c,$92,$f5 ; $f5cc retained data / unresolved code
    !byte $a6,$5c,$10,$0c,$38,$bd,$9d,$02,$e5,$5b,$9d,$9d,$02,$4c,$92,$f5 ; $f5dc retained data / unresolved code
    !byte $a5,$59,$85,$67,$a5,$5b,$85,$75,$20,$a9,$78,$4c,$92,$f5,$20,$81 ; $f5ec retained data / unresolved code
    !byte $fb,$20,$92,$f5,$a2,$06,$2c,$a2,$09,$2c,$a2,$05,$2c ; $f5fc retained data / unresolved code
l_f609:
    ldx #$07 ; $f609  a2 07
    lda #$00 ; $f60b  a9 00
    jmp $667d ; $f60d  4c 7d 66
    !byte $a2,$07,$a9,$01,$4c,$7d,$66,$18,$a5,$59,$65,$7a,$85,$7a,$18,$a5 ; $f610 retained data / unresolved code
    !byte $59,$65,$79,$85,$79,$4c,$92,$f5,$20,$52,$eb,$b0,$03,$4c,$de,$f4 ; $f620 retained data / unresolved code
    !byte $a5,$5d,$20,$f0,$f9,$b0,$0c,$a0,$68,$a9,$01,$a6,$5c,$30,$01,$4a ; $f630 retained data / unresolved code
    !byte $91,$49,$60,$20,$4a,$6f,$b0,$e5,$a6,$5d,$20,$df,$f9,$f0,$de,$a0 ; $f640 retained data / unresolved code
    !byte $24,$b1,$49,$29,$10,$d0,$d6,$a0,$15,$b1,$49,$38,$e9,$01,$91,$49 ; $f650 retained data / unresolved code
    !byte $20,$66,$f6,$4c,$92,$f5,$a5,$36,$8d,$86,$f6,$a5,$37,$8d,$87,$f6 ; $f660 retained data / unresolved code
    !byte $a0,$77,$a9,$00,$91,$36,$88,$10,$fb,$a8,$aa,$b1,$49,$c9,$af,$f0 ; $f670 retained data / unresolved code
    !byte $08,$c9,$dc,$f0,$09,$9d,$ff,$ff,$e8,$c8,$e0,$0f,$90,$ed,$8a,$a8 ; $f680 retained data / unresolved code
    !byte $a9,$ff,$91,$36,$c8,$c0,$10,$90,$f9,$a2,$15,$bc,$09,$f7,$b1,$49 ; $f690 retained data / unresolved code
    !byte $bc,$1f,$f7,$91,$36,$ca,$10,$f3,$a0,$14,$b1,$49,$48,$29,$3f,$a0 ; $f6a0 retained data / unresolved code
    !byte $2f,$91,$36,$68,$2a,$2a,$2a,$29,$03,$a0,$2b,$91,$36,$a0,$15,$b1 ; $f6b0 retained data / unresolved code
    !byte $49,$4a,$4a,$4a,$4a,$4a,$a0,$69,$91,$36,$a0,$24,$b1,$49,$48,$29 ; $f6c0 retained data / unresolved code
    !byte $0f,$a0,$5e,$91,$36,$68,$2a,$2a,$2a,$48,$29,$03,$a0,$5f,$91,$36 ; $f6d0 retained data / unresolved code
    !byte $68,$2a,$a0,$29,$a9,$0d,$69,$00,$91,$36,$20,$3b,$fa,$a0,$22,$91 ; $f6e0 retained data / unresolved code
    !byte $36,$a0,$24,$91,$36,$8a,$88,$91,$36,$a0,$21,$91,$36,$a0,$72,$a9 ; $f6f0 retained data / unresolved code
    !byte $ff,$91,$36,$c8,$c0,$78,$90,$f9,$60,$25,$26,$27,$28,$20,$16,$17 ; $f700 retained data / unresolved code
    !byte $18,$19,$1a,$1b,$1c,$1d,$1e,$1f,$2c,$2d,$2e,$2f,$29,$2a,$2b,$15 ; $f710 retained data / unresolved code
    !byte $16,$17,$18,$2c,$54,$55,$56,$57,$58,$59,$5a,$5b,$5c,$5d,$60,$61 ; $f720 retained data / unresolved code
    !byte $62,$63,$6f,$70,$71,$a5,$59,$a4,$5c,$10,$10,$29,$40,$f0,$07,$05 ; $f730 retained data / unresolved code
    !byte $7f,$85,$7f,$4c,$92,$f5,$84,$80,$4c,$92,$f5,$05,$7f,$85,$7f,$10 ; $f740 retained data / unresolved code
    !byte $05,$20,$16,$6f,$59,$f7,$4c,$92,$f5,$f0,$10,$a0,$67,$b1,$12,$f0 ; $f750 retained data / unresolved code
    !byte $0a,$a0,$0c,$b9,$6c,$f7,$91,$12,$88,$10,$f8,$60,$c4,$ef,$f0,$f0 ; $f760 retained data / unresolved code
    !byte $ec,$e5,$e7,$e1,$ee,$e7,$e5,$f2,$ff,$a5,$08,$f0,$1d,$a5,$09,$48 ; $f770 retained data / unresolved code
    !byte $a5,$0a,$48,$a9,$04,$85,$88,$20,$b5,$9c,$20,$16,$f8,$20,$46,$9c ; $f780 retained data / unresolved code
    !byte $c6,$88,$d0,$f3,$68,$85,$0a,$68,$85,$09,$4c,$92,$f5,$a5,$08,$f0 ; $f790 retained data / unresolved code
    !byte $3c,$a6,$59,$bd,$e0,$f7,$8d,$bf,$f7,$bd,$e1,$f7,$8d,$c0,$f7,$a5 ; $f7a0 retained data / unresolved code
    !byte $09,$48,$a5,$0a,$48,$a9,$00,$85,$09,$85,$0a,$20,$b5,$9c,$20,$16 ; $f7b0 retained data / unresolved code
    !byte $f8,$e6,$0a,$a5,$0a,$cd,$5e,$10,$90,$f1,$a9,$00,$85,$0a,$e6,$09 ; $f7c0 retained data / unresolved code
    !byte $a5,$09,$cd,$5f,$10,$90,$e4,$68,$85,$0a,$68,$85,$09,$4c,$92,$f5 ; $f7d0 retained data / unresolved code
    !byte $16,$f8,$ec,$f7,$ec,$f7,$ec,$f7,$ec,$f7,$0d,$f8,$a6,$59,$bc,$03 ; $f7e0 retained data / unresolved code
    !byte $f8,$b1,$42,$3d,$04,$f8,$f0,$02,$a9,$04,$a0,$04,$51,$42,$29,$04 ; $f7f0 retained data / unresolved code
    !byte $51,$42,$91,$42,$60,$03,$20,$04,$40,$03,$04,$03,$02,$a0,$04,$b1 ; $f800 retained data / unresolved code
    !byte $42,$09,$01,$91,$42,$60,$a0,$02,$b1,$42,$29,$ef,$91,$42,$60,$a4 ; $f810 retained data / unresolved code
    !byte $59,$98,$48,$b9,$34,$f8,$f0,$08,$20,$17,$fa,$68,$a8,$c8,$d0,$f1 ; $f820 retained data / unresolved code
    !byte $68,$4c,$92,$f5,$0b,$21,$34,$0e,$04,$00,$44,$0f,$00,$d2,$73,$00 ; $f830 retained data / unresolved code
    !byte $20,$0d,$fa,$a6,$5c,$30,$02,$a6,$5d,$20,$df,$f9,$a9,$01,$20,$89 ; $f840 retained data / unresolved code
    !byte $f8,$20,$0a,$74,$23,$1f,$23,$44,$00,$4c,$92,$f5,$20,$0d,$fa,$a6 ; $f850 retained data / unresolved code
    !byte $5c,$30,$02,$a6,$5d,$20,$df,$f9,$a0,$13,$b1,$49,$29,$0f,$18,$65 ; $f860 retained data / unresolved code
    !byte $59,$c9,$0a,$90,$02,$a9,$09,$20,$89,$f8,$20,$0a,$74,$38,$a3,$34 ; $f870 retained data / unresolved code
    !byte $9a,$21,$15,$85,$70,$00,$4c,$92,$f5,$a0,$13,$51,$49,$29,$0f,$51 ; $f880 retained data / unresolved code
    !byte $49,$91,$49,$20,$0a,$74,$13,$8a,$19,$a4,$c1,$3b,$cd,$20,$8a,$26 ; $f890 retained data / unresolved code
    !byte $08,$00,$60,$20,$16,$6f,$cb,$f8,$a9,$22,$20,$17,$fa,$a5,$5e,$f0 ; $f8a0 retained data / unresolved code
    !byte $17,$a9,$14,$85,$76,$85,$79,$85,$7a,$85,$7b,$a9,$08,$85,$7c,$a9 ; $f8b0 retained data / unresolved code
    !byte $80,$85,$5d,$a9,$ce,$4c,$17,$fa,$4c,$92,$f5,$f0,$14,$a0,$29,$b1 ; $f8c0 retained data / unresolved code
    !byte $12,$c9,$0e,$d0,$04,$a9,$0d,$91,$12,$a0,$2d,$a9,$82,$31,$12,$91 ; $f8d0 retained data / unresolved code
    !byte $12,$60,$20,$16,$6f,$ea,$f8,$4c,$92,$f5,$f0,$13,$a0,$2d,$b1,$12 ; $f8e0 retained data / unresolved code
    !byte $d0,$0d,$a0,$68,$b1,$12,$f0,$07,$20,$3e,$ff,$29,$01,$91,$12,$60 ; $f8f0 retained data / unresolved code
    !byte $20,$0d,$fa,$a5,$5d,$20,$f0,$f9,$90,$3f,$a6,$5d,$20,$df,$f9,$f0 ; $f900 retained data / unresolved code
    !byte $4f,$38,$e9,$01,$85,$4f,$b1,$49,$29,$e0,$91,$49,$a6,$5d,$bd,$c8 ; $f910 retained data / unresolved code
    !byte $cc,$85,$36,$bd,$cc,$cc,$85,$37,$a0,$1f,$a9,$00,$91,$36,$88,$10 ; $f920 retained data / unresolved code
    !byte $fb,$20,$63,$f9,$20,$0a,$74,$fe,$82,$0f,$f5,$93,$da,$60,$80,$a6 ; $f930 retained data / unresolved code
    !byte $49,$a4,$4a,$20,$1c,$75,$4c,$92,$f5,$20,$63,$f9,$20,$0a,$74,$9a ; $f940 retained data / unresolved code
    !byte $4c,$18,$0a,$33,$bf,$00,$20,$16,$6f,$78,$f9,$a5,$99,$20,$2a,$92 ; $f950 retained data / unresolved code
    !byte $4c,$92,$f5,$20,$0a,$74,$13,$8a,$19,$a4,$c1,$30,$a3,$34,$86,$56 ; $f960 retained data / unresolved code
    !byte $13,$18,$fb,$48,$34,$80,$40,$60,$a0,$2d,$b1,$12,$09,$04,$91,$12 ; $f970 retained data / unresolved code
    !byte $a0,$21,$a9,$00,$91,$12,$c8,$91,$12,$60,$20,$07,$74,$f5,$92,$a2 ; $f980 retained data / unresolved code
    !byte $24,$2a,$99,$9b,$fe,$00,$a5,$5c,$20,$f0,$f9,$85,$37,$a5,$49,$85 ; $f990 retained data / unresolved code
    !byte $36,$a9,$00,$20,$6f,$87,$90,$0e,$20,$07,$74,$f4,$a0,$66,$30,$22 ; $f9a0 retained data / unresolved code
    !byte $1b,$e3,$33,$17,$00,$60,$aa,$bc,$73,$e9,$b1,$36,$29,$3f,$91,$36 ; $f9b0 retained data / unresolved code
    !byte $20,$07,$74,$f2,$a6,$66,$85,$22,$90,$46,$63,$38,$2a,$29,$9d,$35 ; $f9c0 retained data / unresolved code
    !byte $1d,$46,$2f,$00,$60 ; $f9d0 retained data / unresolved code
    jsr l_f9f0 ; $f9d5  20 f0 f9
    ldy #$29 ; $f9d8  a0 29
    lda ($49),y ; $f9da  b1 49
    cmp #$0d ; $f9dc  c9 0d
    rts ; $f9de  60
l_f9df:
    txa ; $f9df  8a
    ora #$80 ; $f9e0  09 80
    jsr l_f9f0 ; $f9e2  20 f0 f9
    txa ; $f9e5  8a
    and #$7f ; $f9e6  29 7f
    tax ; $f9e8  aa
    ldy #$15 ; $f9e9  a0 15
    lda ($49),y ; $f9eb  b1 49
    and #$1f ; $f9ed  29 1f
    rts ; $f9ef  60
l_f9f0:
    tax ; $f9f0  aa
    bmi l_fa01 ; $f9f1  30 0e
    asl ; $f9f3  0a
    tax ; $f9f4  aa
    lda $d522,x ; $f9f5  bd 22 d5
    sta $49 ; $f9f8  85 49
    lda $d523,x ; $f9fa  bd 23 d5
    sta $4a ; $f9fd  85 4a
    clc ; $f9ff  18
    rts ; $fa00  60
l_fa01:
    lda $cca8,x ; $fa01  bd a8 cc
    sta $49 ; $fa04  85 49
    lda $ccac,x ; $fa06  bd ac cc
    sta $4a ; $fa09  85 4a
    sec ; $fa0b  38
    rts ; $fa0c  60
    !byte $20,$2d,$eb,$b0,$fa,$68,$68,$4c,$de,$f4,$aa,$ad,$8e,$84,$48,$ad ; $fa0d retained data / unresolved code
    !byte $5b,$8f,$48,$8a,$30,$08,$a2,$60,$8e,$8e,$84,$8e,$5b,$8f,$29,$7f ; $fa1d retained data / unresolved code
    !byte $85,$58,$20,$ce,$e9,$68,$8d,$5b,$8f,$68,$8d,$8e,$84,$60 ; $fa2d retained data / unresolved code
    sty $b3 ; $fa3b  84 b3
    ldy #$10 ; $fa3d  a0 10
    lda ($49),y ; $fa3f  b1 49
    jsr l_fa5a ; $fa41  20 5a fa
    ldy #$11 ; $fa44  a0 11
    clc ; $fa46  18
    lda ($49),y ; $fa47  b1 49
    adc $12 ; $fa49  65 12
    tax ; $fa4b  aa
    iny ; $fa4c  c8
    lda ($49),y ; $fa4d  b1 49
    adc $13 ; $fa4f  65 13
    bcc l_fa57 ; $fa51  90 04
    lda #$ff ; $fa53  a9 ff
    ldx #$ff ; $fa55  a2 ff
l_fa57:
    ldy $b3 ; $fa57  a4 b3
    rts ; $fa59  60
l_fa5a:
    pha ; $fa5a  48
    lsr ; $fa5b  4a
    lsr ; $fa5c  4a
    lsr ; $fa5d  4a
    lsr ; $fa5e  4a
    lsr ; $fa5f  4a
    tax ; $fa60  aa
    pla ; $fa61  68
    and #$1f ; $fa62  29 1f
    tay ; $fa64  a8
    iny ; $fa65  c8
    lda #$00 ; $fa66  a9 00
    sta $12 ; $fa68  85 12
    sta $13 ; $fa6a  85 13
l_fa6c:
    jsr mix_random_byte ; $fa6c  20 3e ff
    and $cd68,x ; $fa6f  3d 68 cd
    sec ; $fa72  38
    adc $12 ; $fa73  65 12
    sta $12 ; $fa75  85 12
    bcc l_fa7b ; $fa77  90 02
    inc $13 ; $fa79  e6 13
l_fa7b:
    dey ; $fa7b  88
    bne l_fa6c ; $fa7c  d0 ee
    rts ; $fa7e  60
    !byte $a9,$00,$85,$93,$85,$94,$20,$3e,$ff,$29,$03,$38,$65,$93,$85,$93 ; $fa7f retained data / unresolved code
    !byte $90,$02,$e6,$94,$ca,$d0,$ef,$60 ; $fa8f retained data / unresolved code
l_fa97:
    asl $93 ; $fa97  06 93
    rol $94 ; $fa99  26 94
    bcc l_faa5 ; $fa9b  90 08
    pha ; $fa9d  48
    lda #$ff ; $fa9e  a9 ff
    sta $93 ; $faa0  85 93
    sta $94 ; $faa2  85 94
    pla ; $faa4  68
l_faa5:
    rts ; $faa5  60
l_faa6:
    lsr $94 ; $faa6  46 94
    ror $93 ; $faa8  66 93
    rts ; $faaa  60
    !byte $85,$8b,$a2,$80,$8e,$6f,$fb,$e8,$8e,$72,$fb,$ad,$6a,$fb,$29,$ef ; $faab retained data / unresolved code
    !byte $8d,$6a,$fb,$a5,$8b,$c9,$04,$b0,$5c,$c9,$02,$f0,$3d,$20,$0a,$74 ; $fabb retained data / unresolved code
    !byte $69,$9a,$33,$44,$3f,$db,$f9,$7c,$5f,$fa,$00,$a5,$36,$48,$a5,$37 ; $facb retained data / unresolved code
    !byte $48,$20,$4a,$6f,$8a,$4a,$18,$69,$b0,$20,$8e,$84,$68,$85,$37,$68 ; $fadb retained data / unresolved code
    !byte $85,$36,$a9,$a9,$20,$8e,$84,$a9,$01,$8d,$6f,$fb,$a9,$10,$0d,$6a ; $faeb retained data / unresolved code
    !byte $fb,$8d,$6a,$fb,$a5,$8b,$c9,$03,$d0,$62,$a2,$03,$a5,$5e,$f0,$08 ; $fafb retained data / unresolved code
    !byte $20,$df,$f9,$d0,$05,$ca,$10,$f8,$a2,$ff,$a5,$8b,$c9,$02,$d0,$0f ; $fb0b retained data / unresolved code
    !byte $8a,$30,$06,$d0,$0a,$a9,$80,$18,$60,$a5,$5e,$f0,$f8,$38,$60,$8a ; $fb1b retained data / unresolved code
    !byte $30,$3a,$8d,$55,$fb,$18,$69,$c1,$8d,$5e,$fb,$29,$7f,$8d,$73,$fb ; $fb2b retained data / unresolved code
    !byte $a9,$41,$8d,$72,$fb,$a5,$8b,$c9,$02,$f0,$07,$20,$0a,$74,$0b,$e2 ; $fb3b retained data / unresolved code
    !byte $10,$00,$20,$0a,$74,$fe,$5e,$10,$00,$a9,$00,$f0,$0a,$a9,$ad,$20 ; $fb4b retained data / unresolved code
    !byte $8e,$84,$a9,$c4,$20,$8e,$84,$a9,$a9,$20,$8e,$84,$20,$0f,$8b,$40 ; $fb5b retained data / unresolved code
    !byte $80,$9b,$28,$fb,$01,$7c,$fb,$41,$44,$77,$fb,$ff,$38,$e9,$41,$18 ; $fb6b retained data / unresolved code
    !byte $60,$38,$e9,$b1,$18,$60 ; $fb7b retained data / unresolved code
l_fb81:
    jsr $6f16 ; $fb81  20 16 6f

; Inline party callback: $fb87
    !byte $87,$fb ; $fb84 retained data / unresolved code
    rts ; $fb86  60
    txa ; $fb87  8a
    pha ; $fb88  48
    lsr ; $fb89  4a
    jsr $fb93 ; $fb8a  20 93 fb
    pla ; $fb8d  68
    tax ; $fb8e  aa
    rts ; $fb8f  60
    ldy #$ff ; $fb90  a0 ff
    !byte $2c,$a0,$00 ; $fb92 retained data / unresolved code
    sty $24 ; $fb95  84 24
    tax ; $fb97  aa
    lda $20 ; $fb98  a5 20
    pha ; $fb9a  48
    lda $22 ; $fb9b  a5 22
    pha ; $fb9d  48
    txa ; $fb9e  8a
    asl ; $fb9f  0a
    tax ; $fba0  aa
    asl ; $fba1  0a
    asl ; $fba2  0a
    clc ; $fba3  18
    adc #$82 ; $fba4  69 82
    sta $22 ; $fba6  85 22
    lda #$02 ; $fba8  a9 02
    sta $20 ; $fbaa  85 20
    jsr $91e4 ; $fbac  20 e4 91
    sta $3f ; $fbaf  85 3f
    lda $12 ; $fbb1  a5 12
    sta $3e ; $fbb3  85 3e
    ldy #$00 ; $fbb5  a0 00
    lda ($3e),y ; $fbb7  b1 3e
    bne l_fbbe ; $fbb9  d0 03
    jmp l_fcfb ; $fbbb  4c fb fc
l_fbbe:
    txa ; $fbbe  8a
    lsr ; $fbbf  4a
    tax ; $fbc0  aa
    ldy #$2d ; $fbc1  a0 2d
    lda ($3e),y ; $fbc3  b1 3e
    and #$0c ; $fbc5  29 0c
    beq l_fc05 ; $fbc7  f0 3c
    txa ; $fbc9  8a
    pha ; $fbca  48
    lda #$0e ; $fbcb  a9 0e
    jsr $6f83 ; $fbcd  20 83 6f
    bcs l_fc03 ; $fbd0  b0 31
    bne l_fc03 ; $fbd2  d0 2f
    lda $36 ; $fbd4  a5 36
    pha ; $fbd6  48
    lda $37 ; $fbd7  a5 37
    pha ; $fbd9  48
    lda $3e ; $fbda  a5 3e
    sta $36 ; $fbdc  85 36
    lda $3f ; $fbde  a5 3f
    sta $37 ; $fbe0  85 37
    jsr $70f5 ; $fbe2  20 f5 70
    pla ; $fbe5  68
    sta $37 ; $fbe6  85 37
    pla ; $fbe8  68
    sta $36 ; $fbe9  85 36
    ldy #$2d ; $fbeb  a0 2d
    lda ($3e),y ; $fbed  b1 3e
    and #$d3 ; $fbef  29 d3
    sta ($3e),y ; $fbf1  91 3e
    ldy #$23 ; $fbf3  a0 23
    lda ($3e),y ; $fbf5  b1 3e
    ldy #$21 ; $fbf7  a0 21
    sta ($3e),y ; $fbf9  91 3e
    ldy #$24 ; $fbfb  a0 24
    lda ($3e),y ; $fbfd  b1 3e
    ldy #$22 ; $fbff  a0 22
    sta ($3e),y ; $fc01  91 3e
l_fc03:
    pla ; $fc03  68
    tax ; $fc04  aa
l_fc05:
    ldy #$00 ; $fc05  a0 00
l_fc07:
    lda ($3e),y ; $fc07  b1 3e
    cmp #$ff ; $fc09  c9 ff
    beq l_fc15 ; $fc0b  f0 08
    jsr $85c5 ; $fc0d  20 c5 85
    iny ; $fc10  c8
    cpy #$0f ; $fc11  c0 0f
    bcc l_fc07 ; $fc13  90 f2
l_fc15:
    ldy #$2f ; $fc15  a0 2f
    lda ($3e),y ; $fc17  b1 3e
    sta $12 ; $fc19  85 12
    lda $0300,x ; $fc1b  bd 00 03
    jsr l_fd3f ; $fc1e  20 3f fd
    ldy #$12 ; $fc21  a0 12
    lda ($3e),y ; $fc23  b1 3e
    sec ; $fc25  38
    sbc #$0e ; $fc26  e9 0e
    bcc l_fc31 ; $fc28  90 07
    tay ; $fc2a  a8
    lda $fd2e,y ; $fc2b  b9 2e fd
    jsr l_fd3f ; $fc2e  20 3f fd
l_fc31:
    ldy #$29 ; $fc31  a0 29
    lda ($3e),y ; $fc33  b1 3e
    cmp #$09 ; $fc35  c9 09
    bne l_fc48 ; $fc37  d0 0f
    ldy #$1e ; $fc39  a0 1e
    lda ($3e),y ; $fc3b  b1 3e
    bne $fc43 ; $fc3d  d0 04
    dey ; $fc3f  88
    lda ($3e),y ; $fc40  b1 3e
    !byte $2c,$a9,$ff ; $fc42 retained data / unresolved code
    jsr l_fd3f ; $fc45  20 3f fd
l_fc48:
    ldy #$30 ; $fc48  a0 30
l_fc4a:
    lda ($3e),y ; $fc4a  b1 3e
    and #$03 ; $fc4c  29 03
    cmp #$01 ; $fc4e  c9 01
    bne l_fc5f ; $fc50  d0 0d
    iny ; $fc52  c8
    lda ($3e),y ; $fc53  b1 3e
    tax ; $fc55  aa
    lda $e473,x ; $fc56  bd 73 e4
    and #$0f ; $fc59  29 0f
    jsr l_fd3f ; $fc5b  20 3f fd
    dey ; $fc5e  88
l_fc5f:
    iny ; $fc5f  c8
    iny ; $fc60  c8
    iny ; $fc61  c8
    cpy #$54 ; $fc62  c0 54
    bcc l_fc4a ; $fc64  90 e4
    clc ; $fc66  18
    lda $75 ; $fc67  a5 75
    adc $76 ; $fc69  65 76
    adc $78 ; $fc6b  65 78
    sec ; $fc6d  38
    sbc $77 ; $fc6e  e5 77
    bcs l_fc74 ; $fc70  b0 02
    lda #$00 ; $fc72  a9 00
l_fc74:
    jsr l_fd3f ; $fc74  20 3f fd
    ldy #$2e ; $fc77  a0 2e
    sta ($3e),y ; $fc79  91 3e
    lda #$12 ; $fc7b  a9 12
    jsr l_fd4d ; $fc7d  20 4d fd
    ldx #$a0 ; $fc80  a2 a0
    ldy #$2e ; $fc82  a0 2e
    sec ; $fc84  38
    lda #$0a ; $fc85  a9 0a
    sbc ($3e),y ; $fc87  f1 3e
    bcs l_fc91 ; $fc89  b0 06
    eor #$ff ; $fc8b  49 ff
    adc #$01 ; $fc8d  69 01
    ldx #$ad ; $fc8f  a2 ad
l_fc91:
    sta $9b ; $fc91  85 9b
    lda #$00 ; $fc93  a9 00
    sta $9c ; $fc95  85 9c
    txa ; $fc97  8a
    jsr $85c5 ; $fc98  20 c5 85
    jsr $7278 ; $fc9b  20 78 72
    ldy #$67 ; $fc9e  a0 67
    lda ($3e),y ; $fca0  b1 3e
    beq l_fcaa ; $fca2  f0 06
    ldy #$2e ; $fca4  a0 2e
    lda #$0a ; $fca6  a9 0a
    sta ($3e),y ; $fca8  91 3e
l_fcaa:
    lda #$16 ; $fcaa  a9 16
    jsr l_fd4d ; $fcac  20 4d fd
    ldy #$21 ; $fcaf  a0 21
    lda ($3e),y ; $fcb1  b1 3e
    iny ; $fcb3  c8
    ora ($3e),y ; $fcb4  11 3e
    bne l_fcc0 ; $fcb6  d0 08
    ldy #$2d ; $fcb8  a0 2d
    lda ($3e),y ; $fcba  b1 3e
    ora #$04 ; $fcbc  09 04
    sta ($3e),y ; $fcbe  91 3e
l_fcc0:
    ldy #$2d ; $fcc0  a0 2d
    ldx #$06 ; $fcc2  a2 06
l_fcc4:
    lda ($3e),y ; $fcc4  b1 3e
    and $fd0b,x ; $fcc6  3d 0b fd
    bne l_fcd0 ; $fcc9  d0 05
    dex ; $fccb  ca
    bpl l_fcc4 ; $fccc  10 f6
    bmi l_fce2 ; $fcce  30 12
l_fcd0:
    txa ; $fcd0  8a
    asl ; $fcd1  0a
    asl ; $fcd2  0a
    tax ; $fcd3  aa
    ldy #$04 ; $fcd4  a0 04
l_fcd6:
    lda $fd12,x ; $fcd6  bd 12 fd
    jsr $85c5 ; $fcd9  20 c5 85
    inx ; $fcdc  e8
    dey ; $fcdd  88
    bne l_fcd6 ; $fcde  d0 f6
    beq l_fce7 ; $fce0  f0 05
l_fce2:
    ldy #$23 ; $fce2  a0 23
    jsr l_fd62 ; $fce4  20 62 fd
l_fce7:
    lda #$1c ; $fce7  a9 1c
    jsr l_fd4d ; $fce9  20 4d fd
    ldy #$21 ; $fcec  a0 21
    jsr l_fd62 ; $fcee  20 62 fd
    lda #$22 ; $fcf1  a9 22
    jsr l_fd4d ; $fcf3  20 4d fd
    ldy #$25 ; $fcf6  a0 25
    jsr l_fd62 ; $fcf8  20 62 fd
l_fcfb:
    lda #$26 ; $fcfb  a9 26
    jsr l_fd4d ; $fcfd  20 4d fd
    pla ; $fd00  68
    sta $22 ; $fd01  85 22
    pla ; $fd03  68
    sta $20 ; $fd04  85 20
    lda #$ff ; $fd06  a9 ff
    sta $24 ; $fd08  85 24
    rts ; $fd0a  60
    !byte $02,$01,$40,$20,$10,$04,$08,$cf,$ec,$e4,$a0,$d0,$f3,$ee,$e4,$ce ; $fd0b retained data / unresolved code
    !byte $f5,$f4,$f3,$d0,$ef,$f3,$f3,$d0,$e1,$f2,$e1,$c4,$e5,$e1,$e4,$d3 ; $fd1b retained data / unresolved code
    !byte $f4,$ef,$ee,$01,$01,$02,$02,$03,$03,$03,$04,$04,$04,$04,$04,$05 ; $fd2b retained data / unresolved code
    !byte $05,$05,$05,$05 ; $fd3b retained data / unresolved code
l_fd3f:
    clc ; $fd3f  18
    adc $12 ; $fd40  65 12
    bcs l_fd48 ; $fd42  b0 04
    cmp #$3c ; $fd44  c9 3c
    bcc l_fd4a ; $fd46  90 02
l_fd48:
    lda #$3c ; $fd48  a9 3c
l_fd4a:
    sta $12 ; $fd4a  85 12
    rts ; $fd4c  60
l_fd4d:
    sta $b2 ; $fd4d  85 b2
l_fd4f:
    lda $20 ; $fd4f  a5 20
    cmp $b2 ; $fd51  c5 b2
    bcs l_fd5d ; $fd53  b0 08
    lda #$a0 ; $fd55  a9 a0
    jsr $85c5 ; $fd57  20 c5 85
    jmp l_fd4f ; $fd5a  4c 4f fd
l_fd5d:
    lda $b2 ; $fd5d  a5 b2
    sta $20 ; $fd5f  85 20
    rts ; $fd61  60
l_fd62:
    lda ($3e),y ; $fd62  b1 3e
    sta $9b ; $fd64  85 9b
    iny ; $fd66  c8
    lda ($3e),y ; $fd67  b1 3e
    sta $9c ; $fd69  85 9c
    jmp $7262 ; $fd6b  4c 62 72
    !byte $a9,$35,$85,$01,$a9,$7f,$8d,$0d,$dc,$8d,$0d,$dd,$ad,$0d,$dc,$ad ; $fd6e retained data / unresolved code
    !byte $0d,$dd,$a9,$00,$8d,$1a,$d0,$a9,$34,$85,$01,$60 ; $fd7e retained data / unresolved code

; Preserve A/X/Y and memory mapping, acknowledge VIC raster IRQ.
; Scan keyboard, dequeue input, call relocated MUSIC64 vector $c48c,
; then update timers. Restore mapping and registers before RTI.
raster_irq:
    pha ; $fd8a  48
    txa ; $fd8b  8a
    pha ; $fd8c  48
    tya ; $fd8d  98
    pha ; $fd8e  48
    cld ; $fd8f  d8

; 6510 memory mapping
    lda $01 ; $fd90  a5 01
    pha ; $fd92  48
    lda #$35 ; $fd93  a9 35

; 6510 memory mapping
    sta $01 ; $fd95  85 01

; VIC interrupt status (I/O only when $01 exposes it)
    lda $d019 ; $fd97  ad 19 d0
    lsr ; $fd9a  4a
    bcc l_fdae ; $fd9b  90 11
    lda #$7f ; $fd9d  a9 7f

; VIC interrupt status (I/O only when $01 exposes it)
    sta $d019 ; $fd9f  8d 19 d0
    jsr scan_keyboard_matrix ; $fda2  20 6c fe
    jsr dequeue_keyboard_character ; $fda5  20 4d fe
    jsr $c48c ; $fda8  20 8c c4
    jsr tick_countdowns ; $fdab  20 ba fd
l_fdae:
    lda $dc0d ; $fdae  ad 0d dc
    pla ; $fdb1  68

; 6510 memory mapping
    sta $01 ; $fdb2  85 01
    pla ; $fdb4  68
    tay ; $fdb5  a8
    pla ; $fdb6  68
    tax ; $fdb7  aa
    pla ; $fdb8  68

; NMI vector installed by initialize_engine points directly to this RTI.
nmi_return:
    rti ; $fdb9  40

; Decrement short timers every IRQ; divide by $3c for slower timers.
; This is a frame divider in code, not proof of a real-time second on every video standard.
tick_countdowns:
    lda $fe05 ; $fdba  ad 05 fe
    beq l_fdc2 ; $fdbd  f0 03
    dec $fe05 ; $fdbf  ce 05 fe
l_fdc2:
    lda $fe06 ; $fdc2  ad 06 fe
    beq l_fdca ; $fdc5  f0 03
    dec $fe06 ; $fdc7  ce 06 fe
l_fdca:
    lda $fe07 ; $fdca  ad 07 fe
    beq l_fdd2 ; $fdcd  f0 03
    dec $fe07 ; $fdcf  ce 07 fe
l_fdd2:
    dec $fe03 ; $fdd2  ce 03 fe
    bne l_fe02 ; $fdd5  d0 2b
    lda #$3c ; $fdd7  a9 3c
    sta $fe03 ; $fdd9  8d 03 fe
    lda $70 ; $fddc  a5 70
    beq l_fde2 ; $fdde  f0 02
    dec $70 ; $fde0  c6 70
l_fde2:
    lda $6f ; $fde2  a5 6f
    beq l_fde8 ; $fde4  f0 02
    dec $6f ; $fde6  c6 6f
l_fde8:
    lda $6e ; $fde8  a5 6e
    beq l_fdee ; $fdea  f0 02
    dec $6e ; $fdec  c6 6e
l_fdee:
    dec $fe04 ; $fdee  ce 04 fe
    bne l_fe02 ; $fdf1  d0 0f
    lda #$05 ; $fdf3  a9 05
    sta $fe04 ; $fdf5  8d 04 fe
    lda $2f ; $fdf8  a5 2f
    beq l_fe02 ; $fdfa  f0 06
    cmp #$ff ; $fdfc  c9 ff
    beq l_fe02 ; $fdfe  f0 02
    dec $2f ; $fe00  c6 2f
l_fe02:
    rts ; $fe02  60
    !byte $01,$01,$00,$00,$00 ; $fe03 retained data / unresolved code
    lda #$00 ; $fe08  a9 00
    rts ; $fe0a  60
    !byte $ff,$00,$98,$f1,$00,$a0,$b2,$00,$9b,$b1,$bf,$00,$bd,$00,$00,$bb ; $fe0b retained data / unresolved code
    !byte $aa,$00,$ac,$00,$ba,$ae,$ad,$ec,$f0,$ab,$ee,$ef,$eb,$ed,$b0,$ea ; $fe1b retained data / unresolved code
    !byte $e9,$b9,$f6,$f5,$e8,$e2,$b8,$e7,$f9,$b7,$f8,$f4,$e6,$e3,$b6,$e4 ; $fe2b retained data / unresolved code
    !byte $f2,$b5,$00,$e5,$f3,$fa,$b4,$e1,$f7,$b3,$88,$b5,$b3,$b1,$b7,$95 ; $fe3b retained data / unresolved code
    !byte $8d,$ff ; $fe4b retained data / unresolved code
dequeue_keyboard_character:
    lda $b5 ; $fe4d  a5 b5
    bmi l_fe6b ; $fe4f  30 1a
    lda $fedb ; $fe51  ad db fe
    beq l_fe6b ; $fe54  f0 15
    lda $fedc ; $fe56  ad dc fe
    sta $b5 ; $fe59  85 b5
    ldx #$00 ; $fe5b  a2 00
l_fe5d:
    lda $fedd,x ; $fe5d  bd dd fe
    sta $fedc,x ; $fe60  9d dc fe
    inx ; $fe63  e8
    cpx #$0e ; $fe64  e0 0e
    bne l_fe5d ; $fe66  d0 f5
    dec $fedb ; $fe68  ce db fe
l_fe6b:
    rts ; $fe6b  60

; Drive CIA1 keyboard columns at $dc00; read/debounce rows at $dc01.
; Translate keys through $fe0d and queue character codes at $fedc onward.
scan_keyboard_matrix:
    ldx #$00 ; $fe6c  a2 00
    stx $dc03 ; $fe6e  8e 03 dc
    dex ; $fe71  ca
    stx $dc02 ; $fe72  8e 02 dc
    dex ; $fe75  ca
    stx $feda ; $fe76  8e da fe
    ldx #$07 ; $fe79  a2 07
l_fe7b:
    lda $feda ; $fe7b  ad da fe
    jsr read_keyboard_column ; $fe7e  20 24 ff
    ora $feca,x ; $fe81  1d ca fe
    cmp $fed2,x ; $fe84  dd d2 fe
    bne l_fe91 ; $fe87  d0 08
l_fe89:
    sec ; $fe89  38
    rol $feda ; $fe8a  2e da fe
    dex ; $fe8d  ca
    bpl l_fe7b ; $fe8e  10 eb
    rts ; $fe90  60
l_fe91:
    cmp #$ff ; $fe91  c9 ff
    bne l_fe9a ; $fe93  d0 05
    sta $fed2,x ; $fe95  9d d2 fe
    beq l_fe89 ; $fe98  f0 ef
l_fe9a:
    ldy $fed2,x ; $fe9a  bc d2 fe
    cpy #$ff ; $fe9d  c0 ff
    bne l_fe89 ; $fe9f  d0 e8
    pha ; $fea1  48
    txa ; $fea2  8a
    asl ; $fea3  0a
    asl ; $fea4  0a
    asl ; $fea5  0a
    tay ; $fea6  a8
    pla ; $fea7  68
    sta $fed2,x ; $fea8  9d d2 fe
    dey ; $feab  88
l_feac:
    asl ; $feac  0a
    iny ; $fead  c8
    bcs l_feac ; $feae  b0 fc
    lda $fe0d,y ; $feb0  b9 0d fe
    bpl l_fec9 ; $feb3  10 14
    inc $fedb ; $feb5  ee db fe
    ldx $fedb ; $feb8  ae db fe
    cpx #$10 ; $febb  e0 10
    bcc l_fec3 ; $febd  90 04
    dex ; $febf  ca
    stx $fedb ; $fec0  8e db fe
l_fec3:
    jsr l_feeb ; $fec3  20 eb fe
    sta $fedb,x ; $fec6  9d db fe
l_fec9:
    rts ; $fec9  60
    !byte $04,$10,$00,$00,$00,$00,$80,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff ; $feca retained data / unresolved code
    !byte $fe,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $feda retained data / unresolved code
    !byte $00 ; $feea retained data / unresolved code
l_feeb:
    pha ; $feeb  48
    lda #$fd ; $feec  a9 fd
    jsr read_keyboard_column ; $feee  20 24 ff
    and #$80 ; $fef1  29 80
    beq l_fefe ; $fef3  f0 09
    lda #$bf ; $fef5  a9 bf
    jsr read_keyboard_column ; $fef7  20 24 ff
    and #$10 ; $fefa  29 10
    bne l_ff19 ; $fefc  d0 1b
l_fefe:
    pla ; $fefe  68
    cmp #$b1 ; $feff  c9 b1
    bcc l_ff11 ; $ff01  90 0e
    cmp #$ba ; $ff03  c9 ba
    bcc l_ff12 ; $ff05  90 0b
    cmp #$e1 ; $ff07  c9 e1
    bcc l_ff11 ; $ff09  90 06
    cmp #$fb ; $ff0b  c9 fb
    bcs l_ff11 ; $ff0d  b0 02
    and #$df ; $ff0f  29 df
l_ff11:
    rts ; $ff11  60
l_ff12:
    and #$0f ; $ff12  29 0f
    tay ; $ff14  a8
    lda l_ff1a,y ; $ff15  b9 1a ff
    rts ; $ff18  60
l_ff19:
    pla ; $ff19  68
l_ff1a:
    rts ; $ff1a  60
    !byte $a1,$a2,$a3,$a4,$a5,$a6,$a7,$a8,$a9 ; $ff1b retained data / unresolved code

; CIA1 keyboard column output (I/O only when $01 exposes it)
read_keyboard_column:
    sta $dc00 ; $ff24  8d 00 dc

; CIA1 keyboard row input (I/O only when $01 exposes it)
l_ff27:
    lda $dc01 ; $ff27  ad 01 dc

; CIA1 keyboard row input (I/O only when $01 exposes it)
    cmp $dc01 ; $ff2a  cd 01 dc
    bne l_ff27 ; $ff2d  d0 f8
    rts ; $ff2f  60
consume_key:
    lda $b5 ; $ff30  a5 b5
    bpl l_ff3a ; $ff32  10 06
    pha ; $ff34  48
    lda #$00 ; $ff35  a9 00
    sta $b5 ; $ff37  85 b5
    pla ; $ff39  68
l_ff3a:
    rts ; $ff3a  60
peek_key:
    lda $b5 ; $ff3b  a5 b5
    rts ; $ff3d  60
mix_random_byte:
    lda #$35 ; $ff3e  a9 35

; 6510 memory mapping
    sta $01 ; $ff40  85 01
    lda $ff5a ; $ff42  ad 5a ff

; VIC raster line (I/O only when $01 exposes it)
    adc $d012 ; $ff45  6d 12 d0
    adc $b5 ; $ff48  65 b5
    adc $dd04 ; $ff4a  6d 04 dd
    adc $dc09 ; $ff4d  6d 09 dc
    sta $ff5a ; $ff50  8d 5a ff
    pha ; $ff53  48
    lda #$34 ; $ff54  a9 34

; 6510 memory mapping
    sta $01 ; $ff56  85 01
    pla ; $ff58  68
    rts ; $ff59  60
    !byte $00 ; $ff5a retained data / unresolved code

; Engine startup after resources have loaded. Initialize caches and
; zero-page state; install IRQ=$fd8a and NMI=$fdb9; enable raster IRQs.
; Clear seven party records through the inline callback helper, then
; load overlay $0c at $9300 and enter the main engine at $6600.
initialize_engine:
    sei ; $ff5b  78
    lda #$35 ; $ff5c  a9 35

; 6510 memory mapping
    sta $01 ; $ff5e  85 01
    lda #$2f ; $ff60  a9 2f

; 6510 processor-port direction
    sta $00 ; $ff62  85 00
    lda #$1f ; $ff64  a9 1f
    sta $30 ; $ff66  85 30
    sta $60 ; $ff68  85 60
    ldx #$ff ; $ff6a  a2 ff
    stx $02 ; $ff6c  86 02
    stx $03 ; $ff6e  86 03
    stx $04 ; $ff70  86 04
    stx $05 ; $ff72  86 05
    stx $06 ; $ff74  86 06
    stx $07 ; $ff76  86 07
    stx $33 ; $ff78  86 33
    stx $2f ; $ff7a  86 2f
    stx $24 ; $ff7c  86 24
    txs ; $ff7e  9a
    lda #$09 ; $ff7f  a9 09
    sta $32 ; $ff81  85 32
    ldx #$8a ; $ff83  a2 8a
    ldy #$fd ; $ff85  a0 fd

; RAM IRQ vector low
    stx $fffe ; $ff87  8e fe ff

; RAM IRQ vector high / unpatched operand placeholder
    sty $ffff ; $ff8a  8c ff ff
    ldx #$b9 ; $ff8d  a2 b9
    ldy #$fd ; $ff8f  a0 fd

; RAM NMI vector low
    stx $fffa ; $ff91  8e fa ff

; RAM NMI vector high
    sty $fffb ; $ff94  8c fb ff
    lda #$01 ; $ff97  a9 01

; VIC interrupt enable (I/O only when $01 exposes it)
    sta $d01a ; $ff99  8d 1a d0
    lda #$34 ; $ff9c  a9 34

; 6510 memory mapping
    sta $01 ; $ff9e  85 01
    cli ; $ffa0  58
    jsr $6f16 ; $ffa1  20 16 6f

; Inline party callback: $ffbe
    !byte $be,$ff ; $ffa4 retained data / unresolved code
    ldx #$0c ; $ffa6  a2 0c
    lda #$ff ; $ffa8  a9 ff
    jsr $667d ; $ffaa  20 7d 66
    lda #$0f ; $ffad  a9 0f
    sta $0a ; $ffaf  85 0a
    lda #$0c ; $ffb1  a9 0c
    sta $09 ; $ffb3  85 09
    lda #$00 ; $ffb5  a9 00
    sta $0b ; $ffb7  85 0b
    sta $0c ; $ffb9  85 0c
    jmp $6600 ; $ffbb  4c 00 66
clear_party_record:
    ldy #$77 ; $ffbe  a0 77
    lda #$00 ; $ffc0  a9 00
l_ffc2:
    sta ($12),y ; $ffc2  91 12
    dey ; $ffc4  88
    bpl l_ffc2 ; $ffc5  10 fb
    rts ; $ffc7  60
