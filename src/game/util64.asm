; UTIL64 -- static code/data classification; unresolved bytes retained.
!cpu 6510
* = $2000

; Executable utility module loaded at $2000 and called by startup.
; Contains code and embedded data; remaining routine roles need analysis.
; The entry saves the current stack pointer at $22eb and invokes $25ab.
run_utility_module:
    tsx ; $2000  ba
    stx $22eb ; $2001  8e eb 22
    pha ; $2004  48
    jsr l_25ab ; $2005  20 ab 25
    lda #$41 ; $2008  a9 41
    sta $034e ; $200a  8d 4e 03
    pla ; $200d  68
    bne l_2012 ; $200e  d0 02
    clc ; $2010  18
    rts ; $2011  60
l_2012:
    lda #$35 ; $2012  a9 35

; 6510 memory mapping
    sta $01 ; $2014  85 01
    lda #$07 ; $2016  a9 07

; VIC display control 2 (I/O only when $01 exposes it)
    sta $d016 ; $2018  8d 16 d0
    lda #$16 ; $201b  a9 16

; VIC screen/bitmap base selection (I/O only when $01 exposes it)
    sta $d018 ; $201d  8d 18 d0
    lda #$17 ; $2020  a9 17

; VIC display control 1 (I/O only when $01 exposes it)
    sta $d011 ; $2022  8d 11 d0
    ldy #$00 ; $2025  a0 00
    lda #$01 ; $2027  a9 01
l_2029:
    sta $d800,y ; $2029  99 00 d8
    sta $d900,y ; $202c  99 00 d9
    sta $da00,y ; $202f  99 00 da
    sta $db00,y ; $2032  99 00 db
    iny ; $2035  c8
    bne l_2029 ; $2036  d0 f1
    lda #$06 ; $2038  a9 06

; VIC background color (I/O only when $01 exposes it)
    sta $d021 ; $203a  8d 21 d0
    lda #$34 ; $203d  a9 34

; 6510 memory mapping
    sta $01 ; $203f  85 01
    ldx $22eb ; $2041  ae eb 22
    txs ; $2044  9a
    jsr l_25ae ; $2045  20 ae 25
    jsr l_22a6 ; $2048  20 a6 22
    !byte $07,$00,$c2,$c1,$d2,$c4,$a7,$d3,$a0,$d4,$c1,$cc,$c5,$a0,$c9,$c9 ; $204b retained data / unresolved code
    !byte $c9,$a0,$d5,$d4,$c9,$cc,$c9,$d4,$c9,$c5,$d3,$00,$20,$a6,$22,$00 ; $205b retained data / unresolved code
    !byte $01,$ad,$ad,$ad,$ad,$ad,$ad,$ad,$ad,$ad,$ad,$ad,$ad,$ad,$ad,$ad ; $206b retained data / unresolved code
    !byte $ad,$ad,$ad,$ad,$ad,$ad,$ad,$ad,$ad,$ad,$ad,$ad,$ad,$ad,$ad,$ad ; $207b retained data / unresolved code
    !byte $ad,$ad,$ad,$ad,$ad,$ad,$ad,$ad,$ad,$00,$20,$a6,$22,$0b,$06,$c2 ; $208b retained data / unresolved code
    !byte $a9,$c1,$c3,$cb,$d5,$d0,$a0,$c1,$a0,$c4,$c1,$d4,$c1,$a0,$c4,$c9 ; $209b retained data / unresolved code
    !byte $d3,$cb,$00,$20,$a6,$22,$0a,$08,$d4,$a9,$d2,$c1,$ce,$d3,$c6,$c5 ; $20ab retained data / unresolved code
    !byte $d2,$a0,$a0,$c3,$c8,$c1,$d2,$c1,$c3,$d4,$c5,$d2,$d3,$00,$20,$a6 ; $20bb retained data / unresolved code
    !byte $22,$0a,$0a,$d0,$a9,$cc,$c1,$d9,$a0,$c2,$c1,$d2,$c4,$a7,$d3,$a0 ; $20cb retained data / unresolved code
    !byte $d4,$c1,$cc,$c5,$a0,$c9,$c9,$c9,$00,$20,$a6,$22,$09,$0c,$d2,$a9 ; $20db retained data / unresolved code
    !byte $c5,$d4,$d5,$d2,$ce,$a0,$d4,$cf,$a0,$c9,$ce,$d4,$d2,$cf,$c4,$d5 ; $20eb retained data / unresolved code
    !byte $c3,$d4,$c9,$cf,$ce,$00,$20,$90,$28,$a0,$03,$d9,$20,$21,$f0,$05 ; $20fb retained data / unresolved code
    !byte $88,$10,$f8,$30,$f1,$98,$0a,$a8,$b9,$24,$21,$85,$36,$b9,$25,$21 ; $210b retained data / unresolved code
    !byte $85,$37,$6c,$36,$00,$c2,$d4,$d0,$d2,$55,$21,$df,$28,$52,$21,$2c ; $211b retained data / unresolved code
    !byte $21,$38,$08,$20,$14,$38,$20,$ab,$25,$a9,$35,$85,$01,$a9,$18,$8d ; $212b retained data / unresolved code
    !byte $16,$d0,$a9,$18,$8d,$18,$d0,$a9,$07,$8d,$11,$d0,$a9,$00,$8d,$21 ; $213b retained data / unresolved code
    !byte $d0,$a9,$34,$85,$01,$28,$60,$18,$90,$d8,$20,$08,$22,$a9,$00,$8d ; $214b retained data / unresolved code
    !byte $f0,$22,$8d,$f1,$22,$20,$ae,$21,$20,$5c,$26,$20,$b1,$21,$ad,$f0 ; $215b retained data / unresolved code
    !byte $22,$0d,$f1,$22,$d0,$03,$20,$bf,$28,$20,$c4,$26,$b0,$0a,$ad,$15 ; $216b retained data / unresolved code
    !byte $22,$cd,$16,$22,$f0,$df,$d0,$e0,$20,$ae,$25,$20,$c5,$22,$8d,$c2 ; $217b retained data / unresolved code
    !byte $c1,$c3,$cb,$d5,$d0,$a0,$c1,$ce,$cf,$d4,$c8,$c5,$d2,$a0,$c4,$c9 ; $218b retained data / unresolved code
    !byte $d3,$cb,$bf,$a0,$a8,$d9,$af,$ce,$a9,$a0,$00,$20,$58,$22,$90,$aa ; $219b retained data / unresolved code
    !byte $4c,$12,$20,$a9,$00,$2c,$a9,$01,$48,$20,$ae,$25,$20,$c5,$22,$8d ; $21ab retained data / unresolved code
    !byte $d0,$cc,$c5,$c1,$d3,$c5,$a0,$c9,$ce,$d3,$c5,$d2,$d4,$a0,$d4,$c8 ; $21bb retained data / unresolved code
    !byte $c5,$a0,$00,$68,$d0,$0d,$20,$c5,$22,$d3,$cf,$d5,$d2,$c3,$c5,$00 ; $21cb retained data / unresolved code
    !byte $4c,$ed,$21,$20,$c5,$22,$c4,$c5,$d3,$d4,$c9,$ce,$c1,$d4,$c9,$cf ; $21db retained data / unresolved code
    !byte $ce,$00,$20,$c5,$22,$8d,$c4,$c9,$d3,$cb,$a0,$c9,$ce,$a0,$d4,$c8 ; $21eb retained data / unresolved code
    !byte $c5,$a0,$c4,$d2,$c9,$d6,$c5,$ae,$00,$20,$83,$22,$60,$20,$ae,$25 ; $21fb retained data / unresolved code
    !byte $a9,$e0,$8d,$15,$22,$8d,$16,$22,$60,$00,$00,$00,$00,$00,$00,$00 ; $220b retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $221b retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $222b retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $223b retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$6e,$82,$22 ; $224b retained data / unresolved code
    !byte $20,$90,$28,$c9,$8d,$f0,$19,$c9,$ce,$f0,$0d,$c9,$d9,$d0,$f1,$20 ; $225b retained data / unresolved code
    !byte $c5,$22,$d9,$c5,$d3,$00,$18,$60,$20,$c5,$22,$ce,$cf,$00,$38,$60 ; $226b retained data / unresolved code
    !byte $2e,$82,$22,$90,$ea,$b0,$f1,$00,$20,$a6,$22,$0d,$17,$d0,$d2,$c5 ; $227b retained data / unresolved code
    !byte $d3,$d3,$a0,$c1,$ce,$d9,$a0,$cb,$c5,$d9,$00,$20,$a9,$28,$20,$90 ; $228b retained data / unresolved code
    !byte $28,$c9,$9b,$d0,$03,$4c,$12,$20,$4c,$ae,$25 ; $229b retained data / unresolved code
l_22a6:
    pla ; $22a6  68
    sta $36 ; $22a7  85 36
    pla ; $22a9  68
    sta $37 ; $22aa  85 37
    ldy #$01 ; $22ac  a0 01
    lda ($36),y ; $22ae  b1 36
    sta $20 ; $22b0  85 20
    iny ; $22b2  c8
    lda ($36),y ; $22b3  b1 36
    sta $22 ; $22b5  85 22
    clc ; $22b7  18
    lda $36 ; $22b8  a5 36
    adc #$02 ; $22ba  69 02
    tax ; $22bc  aa
    lda $37 ; $22bd  a5 37
    adc #$00 ; $22bf  69 00
    tay ; $22c1  a8
    jmp l_22c9 ; $22c2  4c c9 22
    !byte $68,$aa,$68,$a8 ; $22c5 retained data / unresolved code
l_22c9:
    stx $22d8 ; $22c9  8e d8 22
    sty $22d9 ; $22cc  8c d9 22
l_22cf:
    inc $22d8 ; $22cf  ee d8 22
    bne l_22d7 ; $22d2  d0 03
    inc $22d9 ; $22d4  ee d9 22

; RAM IRQ vector high / unpatched operand placeholder
l_22d7:
    lda $ffff ; $22d7  ad ff ff
    beq l_22e2 ; $22da  f0 06
    jsr l_25d0 ; $22dc  20 d0 25
    jmp l_22cf ; $22df  4c cf 22
l_22e2:
    lda $22d9 ; $22e2  ad d9 22
    pha ; $22e5  48
    lda $22d8 ; $22e6  ad d8 22
    pha ; $22e9  48
    rts ; $22ea  60
    !byte $00,$03,$60,$00,$ba,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $22eb retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$48,$20,$28,$23,$68,$85,$42,$ad,$ee ; $22fb retained data / unresolved code
    !byte $22,$85,$44,$ad,$ef,$22,$85,$45,$ad,$f0,$22,$85,$46,$ad,$f1,$22 ; $230b retained data / unresolved code
    !byte $85,$47,$20,$08,$c2,$48,$20,$33,$23,$68,$c9,$01,$60,$a2,$1f,$b5 ; $231b retained data / unresolved code
    !byte $30,$9d,$3e,$23,$ca,$10,$f8,$60,$a2,$1f,$bd,$3e,$23,$95,$30,$ca ; $232b retained data / unresolved code
    !byte $10,$f8,$60,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $233b retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $234b retained data / unresolved code
    !byte $00,$00,$00,$8d,$a0,$24,$86,$27,$84,$28,$4a,$b0,$06,$a9,$00,$85 ; $235b retained data / unresolved code
    !byte $25,$85,$26,$20,$55,$25,$a2,$00,$8a,$48,$20,$ce,$25,$a9,$a1,$20 ; $236b retained data / unresolved code
    !byte $d0,$25,$a9,$1b,$85,$20,$a9,$a1,$20,$d0,$25,$68,$48,$aa,$bd,$35 ; $237b retained data / unresolved code
    !byte $25,$20,$d0,$25,$bd,$45,$25,$20,$d0,$25,$a9,$a1,$20,$d0,$25,$68 ; $238b retained data / unresolved code
    !byte $aa,$e8,$e0,$10,$90,$d2,$20,$55,$25,$a9,$04,$85,$22,$a9,$00,$48 ; $239b retained data / unresolved code
    !byte $18,$65,$26,$20,$7e,$24,$e6,$22,$68,$18,$69,$01,$c9,$10,$90,$ef ; $23ab retained data / unresolved code
    !byte $20,$90,$28,$a0,$00,$d9,$da,$23,$f0,$05,$c8,$c0,$06,$90,$f6,$98 ; $23bb retained data / unresolved code
    !byte $0a,$a8,$b9,$e0,$23,$85,$12,$b9,$e1,$23,$85,$13,$6c,$12,$00,$8a ; $23cb retained data / unresolved code
    !byte $8b,$95,$88,$9b,$8d,$ee,$23,$19,$24,$ee,$23,$19,$24,$66,$24,$3b ; $23db retained data / unresolved code
    !byte $24,$38,$24,$a5,$25,$18,$69,$01,$b0,$1a,$a0,$00,$d1,$27,$b0,$14 ; $23eb retained data / unresolved code
    !byte $85,$25,$38,$e5,$26,$c9,$10,$90,$05,$e6,$26,$20,$e7,$24,$a6,$25 ; $23fb retained data / unresolved code
    !byte $ca,$4c,$30,$24,$a2,$8c,$a0,$06,$20,$aa,$25,$4c,$bb,$23,$a5,$25 ; $240b retained data / unresolved code
    !byte $f0,$f2,$c6,$25,$a5,$25,$38,$e5,$26,$c9,$10,$90,$05,$c6,$26,$20 ; $241b retained data / unresolved code
    !byte $0e,$25,$a6,$25,$e8,$a4,$25,$20,$6d,$24,$4c,$bb,$23,$4c,$0f,$24 ; $242b retained data / unresolved code
    !byte $a5,$25,$20,$4e,$24,$a0,$0f,$b1,$44,$99,$00,$02,$88,$10,$f8,$a5 ; $243b retained data / unresolved code
    !byte $25,$18,$60,$e6,$27,$0a,$90,$02,$e6,$28,$a8,$b1,$27,$85,$44,$c8 ; $244b retained data / unresolved code
    !byte $b1,$27,$85,$45,$90,$02,$c6,$28,$c6,$27,$60,$a9,$ff,$8d,$00,$02 ; $245b retained data / unresolved code
    !byte $38,$60,$98,$48,$20,$74,$24,$68,$aa,$8a,$38,$e5,$26,$18,$69,$04 ; $246b retained data / unresolved code
    !byte $85,$22,$8a,$a2,$01,$86,$20,$a2,$1b,$8e,$e3,$24,$a0,$00,$d1,$27 ; $247b retained data / unresolved code
    !byte $90,$03,$4c,$d9,$24,$c5,$25,$d0,$05,$a0,$3f,$8c,$18,$26,$48,$20 ; $248b retained data / unresolved code
    !byte $4e,$24,$68,$a8,$a9,$00,$4a,$4a,$4a,$4a,$29,$0e,$aa,$bd,$b5,$24 ; $249b retained data / unresolved code
    !byte $85,$12,$bd,$b6,$24,$85,$13,$6c,$12,$00,$b7,$24,$a0,$00,$b1,$44 ; $24ab retained data / unresolved code
    !byte $c9,$ff,$f0,$1a,$2c,$18,$26,$30,$0a,$c9,$e1,$90,$06,$c9,$fb,$b0 ; $24bb retained data / unresolved code
    !byte $02,$29,$df,$20,$d0,$25,$c8,$a5,$20,$cd,$e3,$24,$90,$e0,$20,$e2 ; $24cb retained data / unresolved code
    !byte $24,$a9,$ff,$8d,$18,$26,$60,$a9,$00,$4c,$47,$26,$a2,$04,$bd,$7b ; $24db retained data / unresolved code
    !byte $25,$85,$15,$bd,$93,$25,$85,$16,$bd,$7a,$25,$85,$12,$bd,$92,$25 ; $24eb retained data / unresolved code
    !byte $85,$13,$a0,$01,$b1,$15,$91,$12,$c8,$c0,$1b,$90,$f7,$e8,$e0,$13 ; $24fb retained data / unresolved code
    !byte $90,$dc,$60,$a2,$12,$bd,$7b,$25,$85,$12,$bd,$93,$25,$85,$13,$bd ; $250b retained data / unresolved code
    !byte $7a,$25,$85,$15,$bd,$92,$25,$85,$16,$a0,$01,$b1,$15,$91,$12,$c8 ; $251b retained data / unresolved code
    !byte $c0,$1b,$90,$f7,$ca,$e0,$03,$b0,$dc,$60,$a0,$a0,$a0,$a0,$a0,$a0 ; $252b retained data / unresolved code
    !byte $a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0 ; $253b retained data / unresolved code
    !byte $a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$20,$c5,$22,$8d,$ab,$ad ; $254b retained data / unresolved code
    !byte $ad,$ad,$ad,$ad,$ad,$ad,$ad,$ad,$ad,$ad,$ad,$ad,$ad,$ad,$ad,$ad ; $255b retained data / unresolved code
    !byte $ad,$ad,$ad,$ad,$ad,$ad,$ad,$ad,$ad,$ab,$ad,$ad,$ab,$00,$60,$00 ; $256b retained data / unresolved code
    !byte $28,$50,$78,$a0,$c8,$f0,$18,$40,$68,$90,$b8,$e0,$08,$30,$58,$80 ; $257b retained data / unresolved code
    !byte $a8,$d0,$f8,$20,$48,$70,$98,$04,$04,$04,$04,$04,$04,$04,$05,$05 ; $258b retained data / unresolved code
    !byte $05,$05,$05,$05,$06,$06,$06,$06,$06,$06,$06,$07,$07,$07,$07,$60 ; $259b retained data / unresolved code
l_25ab:
    ldx #$00 ; $25ab  a2 00
    !byte $2c ; $25ad retained data / unresolved code
l_25ae:
    ldx #$02 ; $25ae  a2 02
    stx $22 ; $25b0  86 22
l_25b2:
    lda $257a,x ; $25b2  bd 7a 25
    sta $12 ; $25b5  85 12
    lda $2592,x ; $25b7  bd 92 25
    sta $13 ; $25ba  85 13
    ldy #$27 ; $25bc  a0 27
    lda #$20 ; $25be  a9 20
l_25c0:
    sta ($12),y ; $25c0  91 12
    dey ; $25c2  88
    bpl l_25c0 ; $25c3  10 fb
    inx ; $25c5  e8
    cpx #$18 ; $25c6  e0 18
    bcc l_25b2 ; $25c8  90 e8
    iny ; $25ca  c8
    sty $20 ; $25cb  84 20
    rts ; $25cd  60
    !byte $a9,$8d ; $25ce retained data / unresolved code
l_25d0:
    sta $25e7 ; $25d0  8d e7 25
    pha ; $25d3  48
    txa ; $25d4  8a
    pha ; $25d5  48
    tya ; $25d6  98
    pha ; $25d7  48
    ldx $22 ; $25d8  a6 22
    lda $257a,x ; $25da  bd 7a 25
    sta $12 ; $25dd  85 12
    lda $2592,x ; $25df  bd 92 25
    sta $13 ; $25e2  85 13
    ldy $20 ; $25e4  a4 20
    lda #$00 ; $25e6  a9 00
    cmp #$8d ; $25e8  c9 8d
    beq l_2601 ; $25ea  f0 15
    cmp #$e0 ; $25ec  c9 e0
    bcc l_25f2 ; $25ee  90 02
    and #$9f ; $25f0  29 9f
l_25f2:
    and $2618 ; $25f2  2d 18 26
    eor #$80 ; $25f5  49 80
    sta ($12),y ; $25f7  91 12
    inc $20 ; $25f9  e6 20
    lda $20 ; $25fb  a5 20
    cmp #$28 ; $25fd  c9 28
    bcc l_2612 ; $25ff  90 11
l_2601:
    lda #$00 ; $2601  a9 00
    sta $20 ; $2603  85 20
    inc $22 ; $2605  e6 22
    lda $22 ; $2607  a5 22
    cmp #$18 ; $2609  c9 18
    bcc l_2612 ; $260b  90 05
    dec $22 ; $260d  c6 22
    jsr l_2619 ; $260f  20 19 26
l_2612:
    pla ; $2612  68
    tay ; $2613  a8
    pla ; $2614  68
    tax ; $2615  aa
    pla ; $2616  68
    rts ; $2617  60
    !byte $ff ; $2618 retained data / unresolved code
l_2619:
    ldx #$02 ; $2619  a2 02
l_261b:
    lda $257b,x ; $261b  bd 7b 25
    sta $15 ; $261e  85 15
    lda $2593,x ; $2620  bd 93 25
    sta $16 ; $2623  85 16
    lda $257a,x ; $2625  bd 7a 25
    sta $12 ; $2628  85 12
    lda $2592,x ; $262a  bd 92 25
    sta $13 ; $262d  85 13
    ldy #$27 ; $262f  a0 27
l_2631:
    lda ($15),y ; $2631  b1 15
    sta ($12),y ; $2633  91 12
    dey ; $2635  88
    bpl l_2631 ; $2636  10 f9
    inx ; $2638  e8
    cpx #$17 ; $2639  e0 17
    bcc l_261b ; $263b  90 de
    ldy #$27 ; $263d  a0 27
    lda #$20 ; $263f  a9 20
l_2641:
    sta ($15),y ; $2641  91 15
    dey ; $2643  88
    bpl l_2641 ; $2644  10 fb
    rts ; $2646  60
    !byte $85,$b2,$a5,$20,$c5,$b2,$b0,$08,$a9,$a0,$20,$d0,$25,$4c,$49,$26 ; $2647 retained data / unresolved code
    !byte $a5,$b2,$85,$20,$60,$20,$ae,$25,$20,$c5,$22,$8d,$d2,$c5,$c1,$c4 ; $2657 retained data / unresolved code
    !byte $c9,$ce,$c7,$ae,$ae,$ae,$00,$ad,$f0,$22,$8d,$bf,$26,$ad,$f1,$22 ; $2667 retained data / unresolved code
    !byte $8d,$c0,$26,$ad,$15,$22,$8d,$ed,$22,$a9,$00,$8d,$ee,$22,$a9,$48 ; $2677 retained data / unresolved code
    !byte $8d,$ef,$22,$a9,$01,$20,$02,$23,$b0,$30,$ee,$ef,$22,$ee,$ef,$22 ; $2687 retained data / unresolved code
    !byte $ee,$f0,$22,$d0,$03,$ee,$f1,$22,$ad,$f0,$22,$c9,$56,$ad,$f1,$22 ; $2697 retained data / unresolved code
    !byte $e9,$01,$b0,$07,$ad,$ef,$22,$c9,$b8,$90,$d8,$ad,$bf,$26,$8d,$f0 ; $26a7 retained data / unresolved code
    !byte $22,$ad,$c0,$26,$8d,$f1,$22,$60,$00,$00,$4c,$7f,$2b,$20,$ae,$25 ; $26b7 retained data / unresolved code
    !byte $20,$c5,$22,$8d,$d7,$d2,$c9,$d4,$c9,$ce,$c7,$ae,$ae,$ae,$00,$ad ; $26c7 retained data / unresolved code
    !byte $16,$22,$8d,$ed,$22,$a9,$00,$8d,$ee,$22,$a9,$48,$8d,$ef,$22,$a9 ; $26d7 retained data / unresolved code
    !byte $02,$20,$02,$23,$b0,$23,$ee,$ef,$22,$ee,$ef,$22,$ee,$f0,$22,$d0 ; $26e7 retained data / unresolved code
    !byte $03,$ee,$f1,$22,$ad,$f0,$22,$c9,$56,$ad,$f1,$22,$e9,$01,$b0,$08 ; $26f7 retained data / unresolved code
    !byte $ad,$ef,$22,$c9,$b8,$90,$d8,$18,$60,$4c,$7f,$2b,$a2,$0f,$a9,$ff ; $2707 retained data / unresolved code
    !byte $9d,$00,$02,$ca,$10,$fa,$20,$73,$27,$a2,$00,$8a,$48,$20,$90,$28 ; $2717 retained data / unresolved code
    !byte $a8,$68,$aa,$98,$c9,$af,$f0,$f3,$c9,$dc,$f0,$ef,$c9,$ff,$f0,$25 ; $2727 retained data / unresolved code
    !byte $c9,$88,$f0,$21,$c9,$8d,$f0,$0f,$c9,$a0,$90,$df,$9d,$00,$02,$20 ; $2737 retained data / unresolved code
    !byte $73,$27,$e8,$e0,$0f,$90,$d4,$20,$71,$27,$38,$8a,$f0,$01,$18,$08 ; $2747 retained data / unresolved code
    !byte $20,$ce,$25,$28,$60,$e0,$00,$f0,$c2,$ca,$a9,$ff,$9d,$00,$02,$20 ; $2757 retained data / unresolved code
    !byte $73,$27,$a9,$a0,$20,$d0,$25,$4c,$22,$27,$38,$24,$18,$08,$8a,$48 ; $2767 retained data / unresolved code
    !byte $a9,$10,$85,$20,$a9,$bc,$20,$d0,$25,$a9,$00,$85,$20,$a9,$ba,$20 ; $2777 retained data / unresolved code
    !byte $d0,$25,$a2,$00,$bd,$00,$02,$c9,$ff,$f0,$08,$20,$d0,$25,$e8,$e0 ; $2787 retained data / unresolved code
    !byte $10,$90,$f1,$68,$aa,$28,$a9,$a0,$b0,$02,$a9,$60,$4c,$d0,$25,$98 ; $2797 retained data / unresolved code
    !byte $d1,$95,$a0,$b2,$00,$9b,$b1,$bf,$00,$bd,$00,$00,$bb,$aa,$00,$ac ; $27a7 retained data / unresolved code
    !byte $c0,$ba,$ae,$ad,$cc,$d0,$ab,$ce,$cf,$cb,$cd,$b0,$ca,$c9,$b9,$d6 ; $27b7 retained data / unresolved code
    !byte $d5,$c8,$c2,$b8,$c7,$d9,$b7,$d8,$d4,$c6,$c3,$b6,$c4,$d2,$b5,$00 ; $27c7 retained data / unresolved code
    !byte $c5,$d3,$da,$b4,$c1,$d7,$b3,$88,$00,$00,$00,$00,$95,$8d,$88,$a5 ; $27d7 retained data / unresolved code
    !byte $b5,$30,$1a,$ad,$80,$28,$f0,$15,$ad,$81,$28,$85,$b5,$a2,$00,$bd ; $27e7 retained data / unresolved code
    !byte $82,$28,$9d,$81,$28,$e8,$e0,$0e,$d0,$f5,$ce,$80,$28,$60,$a9,$00 ; $27f7 retained data / unresolved code
    !byte $8d,$03,$dc,$a9,$ff,$8d,$02,$dc,$a2,$07,$a9,$fe,$8d,$7e,$28,$ad ; $2807 retained data / unresolved code
    !byte $7e,$28,$8d,$00,$dc,$ad,$01,$dc,$cd,$01,$dc,$d0,$f2,$1d,$6e,$28 ; $2817 retained data / unresolved code
    !byte $dd,$76,$28,$d0,$08,$38,$2e,$7e,$28,$ca,$10,$e3,$60,$c9,$ff,$d0 ; $2827 retained data / unresolved code
    !byte $05,$9d,$76,$28,$f0,$ef,$8d,$7f,$28,$bd,$76,$28,$c9,$ff,$d0,$e5 ; $2837 retained data / unresolved code
    !byte $8a,$0a,$0a,$0a,$a8,$ad,$7f,$28,$9d,$76,$28,$88,$0a,$c8,$b0,$fc ; $2847 retained data / unresolved code
    !byte $b9,$a6,$27,$10,$11,$ee,$80,$28,$ae,$80,$28,$e0,$10,$90,$04,$ca ; $2857 retained data / unresolved code
    !byte $8e,$80,$28,$9d,$80,$28,$60,$04,$10,$00,$00,$00,$00,$80,$00,$ff ; $2867 retained data / unresolved code
    !byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$fe,$00,$00,$00,$00,$00,$00,$00,$00 ; $2877 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$a9,$35,$85,$01,$20,$05,$28 ; $2887 retained data / unresolved code
    !byte $20,$e6,$27,$a9,$34,$85,$01,$a5,$b5,$10,$ee,$48,$a9,$00,$85,$b5 ; $2897 retained data / unresolved code
    !byte $68,$60,$a9,$35,$85,$01,$20,$05,$28,$20,$e6,$27,$a9,$34,$85,$01 ; $28a7 retained data / unresolved code
    !byte $a9,$00,$85,$b5,$8d,$80,$28,$60,$20,$ae,$25,$20,$c5,$22,$8d,$c6 ; $28b7 retained data / unresolved code
    !byte $cf,$d2,$cd,$c1,$d4,$d4,$c9,$ce,$c7,$ae,$ae,$ae,$00,$a9,$03,$20 ; $28c7 retained data / unresolved code
    !byte $02,$23,$90,$03,$4c,$7f,$2b,$60,$20,$ae,$25,$20,$c5,$22,$8d,$8d ; $28d7 retained data / unresolved code
    !byte $c4,$cf,$a0,$d9,$cf,$d5,$a0,$d7,$c9,$d3,$c8,$a0,$d4,$cf,$a0,$d4 ; $28e7 retained data / unresolved code
    !byte $d2,$c1,$ce,$d3,$c6,$c5,$d2,$8d,$c3,$c8,$c1,$d2,$c1,$c3,$d4,$c5 ; $28f7 retained data / unresolved code
    !byte $d2,$d3,$a0,$c6,$d2,$cf,$cd,$ae,$ae,$ae,$ae,$8d,$8d,$c1,$a9,$c2 ; $2907 retained data / unresolved code
    !byte $c1,$d2,$c4,$a7,$d3,$a0,$d4,$c1,$cc,$c5,$a0,$c9,$a0,$ba,$a0,$d4 ; $2917 retained data / unresolved code
    !byte $c1,$cc,$c5,$d3,$a0,$cf,$c6,$a0,$d4,$c8,$c5,$a0,$d5,$ce,$cb,$ce ; $2927 retained data / unresolved code
    !byte $cf,$d7,$ce,$8d,$c2,$a9,$c2,$c1,$d2,$c4,$a7,$d3,$a0,$d4,$c1,$cc ; $2937 retained data / unresolved code
    !byte $c5,$a0,$c9,$c9,$a0,$ba,$a0,$d4,$c8,$c5,$a0,$c4,$c5,$d3,$d4,$c9 ; $2947 retained data / unresolved code
    !byte $ce,$d9,$a0,$cb,$ce,$c9,$c7,$c8,$d4,$8d,$c3,$a9,$c2,$c1,$d2,$c4 ; $2957 retained data / unresolved code
    !byte $a7,$d3,$a0,$d4,$c1,$cc,$c5,$a0,$c9,$c9,$c9,$a0,$ba,$a0,$d4,$c8 ; $2967 retained data / unresolved code
    !byte $c5,$a0,$d4,$c8,$c9,$c5,$c6,$a0,$cf,$c6,$a0,$c6,$c1,$d4,$c5,$8d ; $2977 retained data / unresolved code
    !byte $8d,$c3,$c8,$cf,$cf,$d3,$c5,$a0,$a8,$c1,$ad,$c3,$a9,$a0,$cf,$d2 ; $2987 retained data / unresolved code
    !byte $a0,$bc,$ad,$ad,$a0,$c6,$cf,$d2,$a0,$cd,$c1,$c9,$ce,$a0,$cd,$c5 ; $2997 retained data / unresolved code
    !byte $ce,$d5,$00,$20,$90,$28,$c9,$9b,$d0,$03,$4c,$12,$20,$c9,$c1,$90 ; $29a7 retained data / unresolved code
    !byte $f2,$c9,$c4,$b0,$ee,$38,$e9,$c1,$8d,$14,$22,$20,$08,$22,$20,$ae ; $29b7 retained data / unresolved code
    !byte $21,$20,$9b,$30,$20,$3d,$31,$20,$b1,$21,$20,$63,$37,$20,$dd,$29 ; $29c7 retained data / unresolved code
    !byte $20,$66,$37,$4c,$df,$28,$20,$d6,$2d,$90,$56,$20,$ae,$25,$20,$c5 ; $29d7 retained data / unresolved code
    !byte $22,$d4,$c8,$c5,$d2,$c5,$a0,$c9,$d3,$a0,$ce,$cf,$a0,$d2,$cf,$cf ; $29e7 retained data / unresolved code
    !byte $cd,$a0,$c6,$cf,$d2,$a0,$c1,$ce,$d9,$a0,$cd,$cf,$d2,$c5,$8d,$c3 ; $29f7 retained data / unresolved code
    !byte $c8,$c1,$d2,$c1,$c3,$d4,$c5,$d2,$d3,$ae,$8d,$8d,$c4,$c5,$cc,$c5 ; $2a07 retained data / unresolved code
    !byte $d4,$c5,$a0,$d3,$cf,$cd,$c5,$a0,$cf,$cc,$c4,$a0,$c3,$c8,$c1,$d2 ; $2a17 retained data / unresolved code
    !byte $c1,$c3,$d4,$c5,$d2,$d3,$a0,$c6,$c9,$d2,$d3,$d4,$ae,$00,$4c,$83 ; $2a27 retained data / unresolved code
    !byte $22,$20,$45,$2d,$20,$ae,$25,$ad,$00,$ba,$d0,$25,$20,$c5,$22,$d4 ; $2a37 retained data / unresolved code
    !byte $e8,$e5,$f2,$e5,$a0,$e1,$f2,$e5,$a0,$ee,$ef,$a0,$e3,$e8,$e1,$f2 ; $2a47 retained data / unresolved code
    !byte $e1,$e3,$f4,$e5,$f2,$f3,$a0,$ec,$e5,$e6,$f4,$ae,$00,$4c,$83,$22 ; $2a57 retained data / unresolved code
    !byte $60,$20,$c5,$22,$d7,$e8,$e9,$e3,$e8,$a0,$ef,$ee,$e5,$bf,$00,$a9 ; $2a67 retained data / unresolved code
    !byte $00,$a2,$00,$a0,$ba,$20,$5e,$23,$b0,$e6,$0a,$a8,$b9,$01,$ba,$8d ; $2a77 retained data / unresolved code
    !byte $7d,$2b,$b9,$02,$ba,$8d,$7e,$2b,$20,$7a,$2d,$20,$92,$2d,$b0,$03 ; $2a87 retained data / unresolved code
    !byte $4c,$55,$2b,$20,$ae,$25,$20,$c5,$22,$d3,$cf,$d2,$d2,$d9,$ac,$a0 ; $2a97 retained data / unresolved code
    !byte $c2,$d5,$d4,$a0,$d4,$c8,$c5,$d2,$c5,$a7,$d3,$a0,$c1,$a0,$c3,$c8 ; $2aa7 retained data / unresolved code
    !byte $c1,$d2,$c1,$c3,$d4,$c5,$d2,$a0,$d7,$c9,$d4,$c8,$8d,$d4,$c8,$c1 ; $2ab7 retained data / unresolved code
    !byte $d4,$a0,$ce,$c1,$cd,$c5,$a0,$c1,$cc,$d2,$c5,$c1,$c4,$d9,$ae,$8d ; $2ac7 retained data / unresolved code
    !byte $8d,$c4,$cf,$a0,$d9,$cf,$d5,$ae,$ae,$ae,$ae,$8d,$8d,$d2,$a9,$c5 ; $2ad7 retained data / unresolved code
    !byte $ce,$c1,$cd,$c5,$a0,$c9,$d4,$8d,$c4,$a9,$c5,$d3,$d4,$d2,$cf,$d9 ; $2ae7 retained data / unresolved code
    !byte $a0,$d4,$c8,$c5,$a0,$cf,$cc,$c4,$a0,$c3,$c8,$c1,$d2,$c1,$c3,$d4 ; $2af7 retained data / unresolved code
    !byte $c5,$d2,$00,$20,$90,$28,$c9,$9b,$f0,$0a,$c9,$d2,$f0,$07,$c9,$c4 ; $2b07 retained data / unresolved code
    !byte $f0,$36,$d0,$ef,$60,$20,$ae,$25,$20,$c5,$22,$d7,$c8,$c1,$d4,$a0 ; $2b17 retained data / unresolved code
    !byte $c9,$d3,$a0,$00,$a2,$00,$a0,$02,$20,$32,$2d,$20,$c5,$22,$a7,$d3 ; $2b27 retained data / unresolved code
    !byte $a0,$ce,$c5,$d7,$a0,$ce,$c1,$cd,$c5,$bf,$8d,$8d,$00,$20,$13,$27 ; $2b37 retained data / unresolved code
    !byte $b0,$03,$4c,$8f,$2a,$4c,$df,$28,$20,$92,$2d,$4c,$58,$2b,$20,$d6 ; $2b47 retained data / unresolved code
    !byte $2d,$ad,$7d,$2b,$85,$12,$ad,$7e,$2b,$85,$13,$a0,$77,$b1,$12,$91 ; $2b57 retained data / unresolved code
    !byte $44,$88,$10,$f9,$a0,$0f,$b9,$00,$02,$91,$44,$88,$10,$f8,$a9,$00 ; $2b67 retained data / unresolved code
    !byte $a8,$91,$12,$4c,$dd,$29,$00,$00,$48,$20,$ae,$25,$68,$a0,$10,$d9 ; $2b77 retained data / unresolved code
    !byte $cd,$2b,$f0,$2f,$88,$10,$f8,$48,$20,$c5,$22,$d0,$d2,$cf,$c4,$cf ; $2b87 retained data / unresolved code
    !byte $d3,$a0,$c5,$d2,$d2,$cf,$d2,$a0,$a3,$a4,$00,$68,$20,$1c,$2d,$20 ; $2b97 retained data / unresolved code
    !byte $c5,$22,$a0,$c8,$c1,$d3,$a0,$cf,$c3,$c3,$d5,$d2,$c5,$c4,$a1,$00 ; $2ba7 retained data / unresolved code
    !byte $4c,$c7,$2b,$98,$0a,$a8,$be,$de,$2b,$b9,$df,$2b,$a8,$20,$32,$2d ; $2bb7 retained data / unresolved code
    !byte $20,$83,$22,$4c,$12,$20,$27,$28,$2b,$2e,$2f,$40,$44,$45,$46,$47 ; $2bc7 retained data / unresolved code
    !byte $48,$49,$4a,$4e,$52,$57,$58,$00,$2c,$0a,$2c,$1e,$2c,$2e,$2c,$3e ; $2bd7 retained data / unresolved code
    !byte $2c,$4f,$2c,$67,$2c,$78,$2c,$8b,$2c,$9a,$2c,$ae,$2c,$b8,$2c,$c7 ; $2be7 retained data / unresolved code
    !byte $2c,$da,$2c,$e6,$2c,$f8,$2c,$09,$2d,$c9,$af,$cf,$a0,$c5,$d2,$d2 ; $2bf7 retained data / unresolved code
    !byte $cf,$d2,$ff,$ce,$cf,$a0,$c4,$c5,$d6,$c9,$c3,$c5,$a0,$c3,$cf,$ce ; $2c07 retained data / unresolved code
    !byte $ce,$c5,$c3,$d4,$c5,$c4,$ff,$d7,$d2,$c9,$d4,$c5,$a0,$d0,$d2,$cf ; $2c17 retained data / unresolved code
    !byte $d4,$c5,$c3,$d4,$c5,$c4,$ff,$d6,$cf,$cc,$d5,$cd,$c5,$a0,$d3,$d7 ; $2c27 retained data / unresolved code
    !byte $c9,$d4,$c3,$c8,$c5,$c4,$ff,$ce,$cf,$a0,$c4,$c9,$d3,$cb,$a0,$c9 ; $2c37 retained data / unresolved code
    !byte $ce,$a0,$c4,$d2,$c9,$d6,$c5,$ff,$c9,$ce,$d6,$c1,$cc,$c9,$c4,$a0 ; $2c47 retained data / unresolved code
    !byte $d0,$c1,$d4,$c8,$ce,$c1,$cd,$c5,$a0,$d3,$d9,$ce,$d4,$c1,$d8,$ff ; $2c57 retained data / unresolved code
    !byte $ce,$cf,$ce,$c5,$d8,$c9,$d3,$d4,$c1,$ce,$d4,$a0,$d0,$c1,$d4,$c8 ; $2c67 retained data / unresolved code
    !byte $ff,$d6,$cf,$cc,$d5,$cd,$c5,$a0,$ce,$cf,$d4,$a0,$cd,$cf,$d5,$ce ; $2c77 retained data / unresolved code
    !byte $d4,$c5,$c4,$ff,$c6,$c9,$cc,$c5,$a0,$ce,$cf,$d4,$a0,$c6,$cf,$d5 ; $2c87 retained data / unresolved code
    !byte $ce,$c4,$ff,$c4,$d5,$d0,$cc,$c9,$c3,$c1,$d4,$c5,$a0,$c6,$c9,$cc ; $2c97 retained data / unresolved code
    !byte $c5,$a0,$ce,$c1,$cd,$c5,$ff,$c4,$c9,$d3,$cb,$a0,$c6,$d5,$cc,$cc ; $2ca7 retained data / unresolved code
    !byte $ff,$c4,$c9,$d2,$c5,$c3,$d4,$cf,$d2,$d9,$a0,$c6,$d5,$cc,$cc,$ff ; $2cb7 retained data / unresolved code
    !byte $c2,$c1,$c4,$a0,$d0,$d2,$cf,$c4,$cf,$d3,$a0,$d6,$c5,$d2,$d3,$c9 ; $2cc7 retained data / unresolved code
    !byte $cf,$ce,$ff,$c6,$c9,$cc,$c5,$a0,$cc,$cf,$c3,$cb,$c5,$c4,$ff,$ce ; $2cd7 retained data / unresolved code
    !byte $cf,$d4,$a0,$c1,$a0,$d0,$d2,$cf,$c4,$cf,$d3,$a0,$c4,$c9,$d3,$cb ; $2ce7 retained data / unresolved code
    !byte $ff,$c4,$d5,$d0,$cc,$c9,$c3,$c1,$d4,$c5,$a0,$d6,$cf,$cc,$d5,$cd ; $2cf7 retained data / unresolved code
    !byte $c5,$ff,$c2,$c1,$c4,$a0,$d6,$cf,$cc,$d5,$cd,$c5,$a0,$c2,$c9,$d4 ; $2d07 retained data / unresolved code
    !byte $a0,$cd,$c1,$d0,$ff,$48,$4a,$4a,$4a,$4a,$20,$25,$2d,$68,$29,$0f ; $2d17 retained data / unresolved code
    !byte $09,$b0,$c9,$ba,$90,$02,$69,$06,$4c,$d0,$25,$86,$38,$84,$39,$a0 ; $2d27 retained data / unresolved code
    !byte $00,$b1,$38,$c9,$ff,$f0,$06,$20,$d0,$25,$c8,$d0,$f4,$60,$a9,$00 ; $2d37 retained data / unresolved code
    !byte $85,$12,$a9,$48,$85,$13,$a0,$20,$84,$15,$a0,$00,$a2,$00,$b1,$12 ; $2d47 retained data / unresolved code
    !byte $f0,$0c,$a5,$12,$9d,$01,$ba,$a5,$13,$9d,$02,$ba,$e8,$e8,$a5,$12 ; $2d57 retained data / unresolved code
    !byte $18,$69,$80,$85,$12,$90,$02,$e6,$13,$c6,$15,$d0,$e1,$8a,$4a,$8d ; $2d67 retained data / unresolved code
    !byte $00,$ba,$60,$a0,$00,$b9,$00,$02,$c9,$ff,$f0,$06,$c8,$c0,$10,$90 ; $2d77 retained data / unresolved code
    !byte $f4,$60,$99,$00,$02,$c8,$c0,$10,$90,$f8,$60,$a9,$00,$85,$51,$a5 ; $2d87 retained data / unresolved code
    !byte $51,$0a,$a8,$b9,$3a,$2e,$85,$44,$b9,$3b,$2e,$85,$45,$a0,$00,$b9 ; $2d97 retained data / unresolved code
    !byte $00,$02,$c9,$ff,$f0,$19,$d1,$44,$f0,$0e,$c9,$c1,$90,$17,$c9,$db ; $2da7 retained data / unresolved code
    !byte $b0,$13,$09,$20,$d1,$44,$d0,$0d,$c8,$c0,$0f,$90,$e2,$38,$60,$b1 ; $2db7 retained data / unresolved code
    !byte $44,$c9,$ff,$f0,$f8,$e6,$51,$a5,$51,$c9,$20,$d0,$c2,$18,$60,$a9 ; $2dc7 retained data / unresolved code
    !byte $00,$85,$51,$a5,$51,$0a,$a8,$b9,$3a,$2e,$85,$44,$b9,$3b,$2e,$85 ; $2dd7 retained data / unresolved code
    !byte $45,$a0,$00,$b1,$44,$f0,$0a,$e6,$51,$a5,$51,$c9,$20,$d0,$e4,$38 ; $2de7 retained data / unresolved code
    !byte $60,$18,$60,$00,$48,$80,$48,$00,$49,$80,$49,$00,$4a,$80,$4a,$00 ; $2df7 retained data / unresolved code
    !byte $4b,$80,$4b,$00,$4c,$80,$4c,$00,$4d,$80,$4d,$00,$4e,$80,$4e,$00 ; $2e07 retained data / unresolved code
    !byte $4f,$80,$4f,$00,$50,$80,$50,$00,$51,$80,$51,$00,$52,$80,$52,$00 ; $2e17 retained data / unresolved code
    !byte $53,$80,$53,$00,$54,$80,$54,$00,$55,$80,$55,$00,$56,$80,$56,$00 ; $2e27 retained data / unresolved code
    !byte $57,$80,$57,$00,$58,$80,$58,$00,$59,$80,$59,$00,$5a,$80,$5a,$00 ; $2e37 retained data / unresolved code
    !byte $5b,$80,$5b,$00,$5c,$80,$5c,$00,$5d,$80,$5d,$00,$5e,$80,$5e,$00 ; $2e47 retained data / unresolved code
    !byte $5f,$80,$5f,$00,$60,$80,$60,$00,$61,$80,$61,$00,$62,$80,$62,$00 ; $2e57 retained data / unresolved code
    !byte $63,$80,$63,$00,$64,$80,$64,$00,$65,$80,$65,$00,$66,$80,$66,$00 ; $2e67 retained data / unresolved code
    !byte $67,$80,$67,$00,$59,$40,$59,$80,$59,$c0,$59,$00,$5a,$40,$5a,$80 ; $2e77 retained data / unresolved code
    !byte $5a,$c0,$5a,$00,$5b,$40,$5b,$80,$5b,$c0,$5b,$00,$5c,$40,$5c,$80 ; $2e87 retained data / unresolved code
    !byte $5c,$c0,$5c,$00,$5d,$40,$5d,$80,$5d,$c0,$5d,$21,$30,$36,$37,$36 ; $2e97 retained data / unresolved code
    !byte $37,$36,$37,$36,$37,$21,$30,$21,$30,$21,$30,$21,$30,$21,$30,$36 ; $2ea7 retained data / unresolved code
    !byte $37,$36,$37,$36,$37,$a0,$29,$b1,$36,$0a,$a8,$b9,$41,$2f,$85,$12 ; $2eb7 retained data / unresolved code
    !byte $b9,$42,$2f,$85,$13,$a9,$00,$85,$ab,$85,$ac,$85,$ad,$85,$ae,$a5 ; $2ec7 retained data / unresolved code
    !byte $4b,$05,$4c,$f0,$57,$a5,$4b,$c9,$0d,$a5,$4c,$e9,$00,$90,$29,$a5 ; $2ed7 retained data / unresolved code
    !byte $4b,$38,$e9,$0c,$85,$9f,$a5,$4c,$e9,$00,$85,$a0,$a9,$80,$85,$a1 ; $2ee7 retained data / unresolved code
    !byte $a9,$1a,$85,$a2,$a9,$06,$85,$a3,$a9,$00,$85,$a4,$20,$5c,$30,$a2 ; $2ef7 retained data / unresolved code
    !byte $03,$b5,$9b,$95,$ab,$ca,$10,$f9,$a5,$4c,$d0,$07,$a6,$4b,$ca,$e0 ; $2f07 retained data / unresolved code
    !byte $0c,$90,$02,$a2,$0b,$bc,$34,$2f,$a2,$00,$18,$b1,$12,$75,$ab,$95 ; $2f17 retained data / unresolved code
    !byte $ab,$c8,$e8,$8a,$49,$03,$d0,$f3,$90,$02,$e6,$ae,$60,$00,$03,$06 ; $2f27 retained data / unresolved code
    !byte $09,$0c,$0f,$12,$15,$18,$1b,$1e,$21,$24,$5b,$2f,$7f,$2f,$a3,$2f ; $2f37 retained data / unresolved code
    !byte $c7,$2f,$c7,$2f,$5b,$2f,$5b,$2f,$5b,$2f,$5b,$2f,$c7,$2f,$eb,$2f ; $2f47 retained data / unresolved code
    !byte $eb,$2f,$0f,$30,$d0,$07,$00,$a0,$0f,$00,$58,$1b,$00,$10,$27,$00 ; $2f57 retained data / unresolved code
    !byte $98,$3a,$00,$20,$4e,$00,$30,$75,$00,$50,$c3,$00,$80,$38,$01,$b0 ; $2f67 retained data / unresolved code
    !byte $ad,$01,$f0,$49,$02,$40,$0d,$03,$20,$4e,$00,$50,$c3,$00,$80,$38 ; $2f77 retained data / unresolved code
    !byte $01,$c0,$d4,$01,$00,$71,$02,$40,$0d,$03,$90,$d0,$03,$e0,$93,$04 ; $2f87 retained data / unresolved code
    !byte $80,$1a,$06,$c0,$27,$09,$a0,$bb,$0d,$20,$d6,$13,$58,$1b,$00,$98 ; $2f97 retained data / unresolved code
    !byte $3a,$00,$a8,$61,$00,$40,$9c,$00,$60,$ea,$00,$80,$38,$01,$a0,$86 ; $2fa7 retained data / unresolved code
    !byte $01,$d0,$fb,$01,$10,$98,$02,$60,$5b,$03,$e0,$93,$04,$80,$1a,$06 ; $2fb7 retained data / unresolved code
    !byte $08,$07,$00,$a0,$0f,$00,$70,$17,$00,$10,$27,$00,$b0,$36,$00,$38 ; $2fc7 retained data / unresolved code
    !byte $4a,$00,$48,$71,$00,$50,$c3,$00,$90,$5f,$01,$c0,$d4,$01,$10,$98 ; $2fd7 retained data / unresolved code
    !byte $02,$70,$82,$03,$70,$11,$01,$e0,$22,$02,$80,$a9,$03,$20,$30,$05 ; $2fe7 retained data / unresolved code
    !byte $60,$3d,$08,$a0,$4a,$0b,$40,$42,$0f,$c0,$5c,$15,$40,$77,$1b,$c0 ; $2ff7 retained data / unresolved code
    !byte $91,$21,$40,$ac,$27,$c0,$c6,$2d,$a0,$86,$01,$e8,$6e,$03,$80,$1a ; $3007 retained data / unresolved code
    !byte $06,$10,$eb,$09,$f0,$7e,$0e,$c0,$5c,$15,$40,$77,$1b,$c0,$91,$21 ; $3017 retained data / unresolved code
    !byte $40,$ac,$27,$c0,$c6,$2d,$40,$e1,$33,$c0,$fb,$39,$a0,$1d,$b1,$36 ; $3027 retained data / unresolved code
    !byte $85,$9f,$c8,$b1,$36,$85,$a0,$a9,$e8,$85,$a1,$a9,$03,$85,$a2,$a9 ; $3037 retained data / unresolved code
    !byte $00,$85,$a3,$85,$a4,$20,$5c,$30,$a0,$19,$b9,$82,$00,$91,$36,$c8 ; $3047 retained data / unresolved code
    !byte $c0,$1d,$90,$f6,$60,$a5,$9f,$85,$a9,$a5,$a0,$85,$aa,$a9,$00,$85 ; $3057 retained data / unresolved code
    !byte $9b,$85,$9c,$85,$9d,$85,$9e,$a0,$10,$06,$9b,$26,$9c,$26,$9d,$26 ; $3067 retained data / unresolved code
    !byte $9e,$06,$a9,$26,$aa,$90,$19,$18,$a5,$a1,$65,$9b,$85,$9b,$a5,$a2 ; $3077 retained data / unresolved code
    !byte $65,$9c,$85,$9c,$a5,$a3,$65,$9d,$85,$9d,$a5,$a4,$65,$9e,$85,$9e ; $3087 retained data / unresolved code
    !byte $88,$d0,$d6,$60,$a9,$00,$8d,$ee,$22,$a9,$58,$8d,$ef,$22,$ad,$14 ; $3097 retained data / unresolved code
    !byte $22,$0a,$a8,$b9,$b7,$30,$85,$12,$b9,$b8,$30,$85,$13,$6c,$12,$00 ; $30a7 retained data / unresolved code
    !byte $1a,$31,$ec,$30,$bd,$30,$a9,$10,$8d,$f0,$22,$a9,$01,$8d,$f1,$22 ; $30b7 retained data / unresolved code
    !byte $a9,$01,$20,$02,$23,$90,$03,$4c,$7f,$2b,$ee,$ef,$22,$ee,$ef,$22 ; $30c7 retained data / unresolved code
    !byte $ee,$f0,$22,$d0,$03,$ee,$f1,$22,$ad,$f0,$22,$c9,$18,$ad,$f1,$22 ; $30d7 retained data / unresolved code
    !byte $e9,$01,$90,$dc,$60,$a9,$02,$8d,$15,$c2,$a9,$00,$8d,$16,$c2,$a9 ; $30e7 retained data / unresolved code
    !byte $01,$85,$42,$ad,$ee,$22,$85,$44,$ad,$ef,$22,$85,$45,$20,$11,$c2 ; $30f7 retained data / unresolved code
    !byte $90,$03,$4c,$7f,$2b,$ee,$ef,$22,$ee,$16,$c2,$ad,$16,$c2,$c9,$10 ; $3107 retained data / unresolved code
    !byte $90,$dd,$60,$a2,$10,$a0,$00,$a9,$00,$85,$12,$a9,$58,$85,$13,$98 ; $3117 retained data / unresolved code
    !byte $91,$12,$c8,$d0,$fb,$e6,$13,$ca,$d0,$f6,$a2,$38,$a0,$31,$4c,$20 ; $3127 retained data / unresolved code
    !byte $39,$ce,$cd,$b0,$b0,$00,$ad,$14,$22,$0a,$18,$6d,$14,$22,$aa,$bd ; $3137 retained data / unresolved code
    !byte $82,$31,$8d,$77,$31,$bd,$83,$31,$8d,$78,$31,$bd,$84,$31,$0a,$8d ; $3147 retained data / unresolved code
    !byte $73,$31,$a0,$00,$b9,$fa,$2d,$85,$36,$b9,$fb,$2d,$85,$37,$98,$48 ; $3157 retained data / unresolved code
    !byte $a0,$00,$98,$91,$36,$c8,$10,$fb,$68,$48,$a8,$c0,$40,$b0,$03,$20 ; $3167 retained data / unresolved code
    !byte $ff,$ff,$68,$a8,$c8,$c8,$c0,$40,$90,$da,$60,$8b,$31,$1e,$b2,$31 ; $3177 retained data / unresolved code
    !byte $1e,$06,$35,$20,$20,$75,$33,$b0,$1c,$a0,$51,$84,$8b,$a4,$8b,$b1 ; $3187 retained data / unresolved code
    !byte $12,$aa,$bd,$75,$32,$f0,$03,$20,$1a,$35,$e6,$8b,$e6,$8b,$a5,$8b ; $3197 retained data / unresolved code
    !byte $c9,$60,$90,$e9,$60,$a0,$00,$98,$91,$36,$60,$98,$aa,$18,$69,$04 ; $31a7 retained data / unresolved code
    !byte $a8,$b9,$3a,$2e,$85,$12,$b9,$3b,$2e,$85,$13,$a0,$00,$b1,$12,$f0 ; $31b7 retained data / unresolved code
    !byte $e4,$b1,$12,$59,$f5,$31,$91,$12,$c8,$10,$f6,$8a,$a8,$20,$75,$33 ; $31c7 retained data / unresolved code
    !byte $b0,$d3,$a0,$51,$84,$8b,$a4,$8b,$b1,$12,$aa,$bd,$f5,$32,$f0,$03 ; $31d7 retained data / unresolved code
    !byte $20,$1a,$35,$e6,$8b,$e6,$8b,$a5,$8b,$c9,$60,$90,$e9,$60,$7f,$7e ; $31e7 retained data / unresolved code
    !byte $7d,$7c,$7b,$7a,$79,$78,$77,$76,$75,$74,$73,$72,$71,$70,$f2,$d6 ; $31f7 retained data / unresolved code
    !byte $48,$31,$9a,$ac,$c3,$4e,$77,$28,$31,$10,$dc,$c4,$46,$7a,$f8,$66 ; $3207 retained data / unresolved code
    !byte $23,$89,$93,$92,$91,$90,$87,$84,$33,$a5,$c4,$c5,$6c,$72,$29,$63 ; $3217 retained data / unresolved code
    !byte $44,$10,$01,$01,$35,$72,$47,$23,$03,$8f,$f3,$77,$42,$40,$3f,$3e ; $3227 retained data / unresolved code
    !byte $3d,$42,$74,$73,$98,$71,$f4,$f5,$35,$34,$02,$d6,$d3,$44,$97,$85 ; $3237 retained data / unresolved code
    !byte $63,$33,$73,$45,$46,$49,$48,$47,$93,$bd,$b7,$42,$01,$30,$63,$1f ; $3247 retained data / unresolved code
    !byte $29,$88,$56,$63,$19,$18,$17,$16,$54,$77,$f2,$f0,$11,$70,$96,$82 ; $3257 retained data / unresolved code
    !byte $35,$44,$ad,$c5,$48,$53,$5a,$42,$70,$09,$ff,$33,$00,$00,$00,$01 ; $3267 retained data / unresolved code
    !byte $02,$03,$04,$05,$06,$07,$06,$09,$0a,$0b,$0c,$0d,$0e,$0f,$10,$11 ; $3277 retained data / unresolved code
    !byte $12,$13,$14,$14,$14,$17,$18,$19,$1a,$00,$1c,$1d,$1e,$1f,$20,$21 ; $3287 retained data / unresolved code
    !byte $22,$23,$00,$25,$00,$00,$28,$00,$29,$2a,$00,$2c,$2d,$2e,$2f,$30 ; $3297 retained data / unresolved code
    !byte $31,$00,$32,$33,$00,$00,$34,$00,$36,$00,$37,$1b,$39,$00,$3b,$3c ; $32a7 retained data / unresolved code
    !byte $00,$3e,$3f,$40,$41,$42,$00,$45,$00,$00,$46,$47,$59,$49,$00,$4b ; $32b7 retained data / unresolved code
    !byte $00,$00,$4e,$00,$4f,$51,$00,$53,$54,$55,$00,$57,$00,$5a,$5b,$00 ; $32c7 retained data / unresolved code
    !byte $00,$5e,$5f,$58,$00,$00,$00,$00,$43,$00,$62,$00,$64,$64,$00,$59 ; $32d7 retained data / unresolved code
    !byte $6c,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01 ; $32e7 retained data / unresolved code
    !byte $02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$10,$11 ; $32f7 retained data / unresolved code
    !byte $12,$13,$14,$15,$16,$17,$18,$19,$1a,$1b,$1c,$1d,$1e,$1f,$20,$21 ; $3307 retained data / unresolved code
    !byte $22,$23,$24,$25,$26,$27,$28,$29,$2a,$2b,$2c,$2d,$2e,$2f,$30,$31 ; $3317 retained data / unresolved code
    !byte $32,$33,$34,$35,$36,$37,$38,$39,$3a,$3b,$3c,$3d,$3e,$3f,$40,$41 ; $3327 retained data / unresolved code
    !byte $42,$43,$44,$45,$46,$47,$48,$49,$4a,$4b,$4c,$4d,$4e,$4f,$50,$51 ; $3337 retained data / unresolved code
    !byte $52,$53,$54,$55,$56,$57,$58,$59,$5a,$5b,$5c,$5d,$5e,$5f,$60,$61 ; $3347 retained data / unresolved code
    !byte $62,$63,$64,$65,$66,$67,$68,$69,$6a,$6b,$6c,$6d,$6e,$6f,$00,$00 ; $3357 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$98,$18 ; $3367 retained data / unresolved code
    !byte $69,$04,$a8,$b9,$3a,$2e,$85,$12,$b9,$3b,$2e,$85,$13,$a0,$00,$b1 ; $3377 retained data / unresolved code
    !byte $12,$d0,$02,$38,$60,$a0,$0f,$b1,$12,$91,$36,$88,$10,$f9,$a0,$10 ; $3387 retained data / unresolved code
    !byte $b1,$12,$4a,$4a,$4a,$a0,$10,$91,$36,$a0,$10,$b1,$12,$0a,$0a,$29 ; $3397 retained data / unresolved code
    !byte $1c,$85,$15,$c8,$b1,$12,$2a,$2a,$2a,$29,$03,$05,$15,$a0,$11,$91 ; $33a7 retained data / unresolved code
    !byte $36,$a0,$11,$b1,$12,$29,$1f,$a0,$12,$91,$36,$a0,$12,$b1,$12,$4a ; $33b7 retained data / unresolved code
    !byte $4a,$4a,$a0,$13,$91,$36,$a0,$12,$b1,$12,$0a,$0a,$29,$1c,$85,$15 ; $33c7 retained data / unresolved code
    !byte $c8,$b1,$12,$2a,$2a,$2a,$29,$03,$05,$15,$a0,$14,$91,$36,$a0,$21 ; $33d7 retained data / unresolved code
    !byte $b1,$12,$a0,$1d,$91,$36,$a0,$1f,$91,$36,$a0,$20,$b1,$12,$a0,$1e ; $33e7 retained data / unresolved code
    !byte $91,$36,$a0,$20,$91,$36,$a0,$39,$b1,$12,$a0,$2a,$91,$36,$a0,$38 ; $33f7 retained data / unresolved code
    !byte $b1,$12,$c9,$0b,$90,$01,$60,$a0,$29,$91,$36,$c9,$05,$f0,$2b,$c9 ; $3407 retained data / unresolved code
    !byte $06,$f0,$42,$c9,$07,$f0,$5c,$c9,$08,$f0,$4d,$c9,$09,$f0,$54,$a0 ; $3417 retained data / unresolved code
    !byte $35,$b1,$12,$a0,$25,$91,$36,$a0,$27,$91,$36,$a0,$34,$b1,$12,$a0 ; $3427 retained data / unresolved code
    !byte $26,$91,$36,$a0,$28,$91,$36,$4c,$82,$34,$a0,$44,$b1,$12,$a0,$64 ; $3437 retained data / unresolved code
    !byte $91,$36,$a0,$45,$b1,$12,$a0,$65,$91,$36,$a0,$46,$b1,$12,$a0,$66 ; $3447 retained data / unresolved code
    !byte $91,$36,$4c,$82,$34,$a0,$49,$b1,$12,$a0,$64,$91,$36,$a0,$65,$a9 ; $3457 retained data / unresolved code
    !byte $fc,$11,$36,$91,$36,$4c,$82,$34,$a0,$48,$b1,$12,$a0,$64,$91,$36 ; $3467 retained data / unresolved code
    !byte $4c,$82,$34,$a0,$4f,$b1,$12,$a0,$69,$91,$36,$20,$33,$30,$a0,$40 ; $3477 retained data / unresolved code
    !byte $b1,$12,$a2,$02,$20,$cf,$38,$a0,$41,$b1,$12,$a2,$03,$20,$cf,$38 ; $3487 retained data / unresolved code
    !byte $a0,$42,$b1,$12,$a2,$04,$20,$cf,$38,$a0,$43,$b1,$12,$a2,$01,$20 ; $3497 retained data / unresolved code
    !byte $cf,$38,$a0,$64,$b1,$12,$a2,$0a,$20,$cf,$38,$a0,$31,$b1,$12,$a0 ; $34a7 retained data / unresolved code
    !byte $21,$91,$36,$a0,$23,$91,$36,$a0,$30,$b1,$12,$a0,$22,$91,$36,$a0 ; $34b7 retained data / unresolved code
    !byte $24,$91,$36,$a0,$1d,$b1,$36,$38,$e9,$01,$85,$4b,$c8,$b1,$36,$e9 ; $34c7 retained data / unresolved code
    !byte $00,$85,$4c,$a5,$13,$48,$a5,$12,$48,$20,$bc,$2e,$68,$85,$12,$68 ; $34d7 retained data / unresolved code
    !byte $85,$13,$a0,$15,$a2,$00,$b5,$ab,$91,$36,$c8,$e8,$e0,$04,$90,$f6 ; $34e7 retained data / unresolved code
    !byte $18,$a0,$29,$b1,$36,$2a,$aa,$bd,$a2,$2e,$a0,$2c,$91,$36,$60,$b9 ; $34f7 retained data / unresolved code
    !byte $3a,$2e,$85,$12,$b9,$3b,$2e,$85,$13,$a0,$00,$b1,$12,$91,$36,$c8 ; $3507 retained data / unresolved code
    !byte $10,$f9,$60,$85,$53,$aa,$a0,$31,$b1,$36,$f0,$0b,$c8,$c8,$c8,$c0 ; $3517 retained data / unresolved code
    !byte $54,$90,$f5,$a9,$01,$38,$60,$8a,$91,$36,$c8,$bd,$63,$36,$91,$36 ; $3527 retained data / unresolved code
    !byte $88,$88,$8c,$4f,$35,$a0,$29,$b1,$36,$a8,$b9,$54,$35,$3d,$63,$35 ; $3537 retained data / unresolved code
    !byte $d0,$03,$a9,$02,$2c,$a9,$00,$a0,$00,$91,$36,$18,$60,$80,$40,$40 ; $3547 retained data / unresolved code
    !byte $40,$40,$10,$08,$04,$02,$01,$20,$60,$e0,$00,$00,$00,$ff,$ff,$8f ; $3557 retained data / unresolved code
    !byte $9f,$ff,$8f,$87,$9f,$ff,$9f,$8e,$9f,$8f,$8e,$86,$ff,$9f,$ff,$86 ; $3567 retained data / unresolved code
    !byte $08,$9f,$9f,$9e,$9e,$8f,$9e,$ff,$70,$08,$08,$60,$ff,$9f,$8c,$8f ; $3577 retained data / unresolved code
    !byte $9b,$86,$ff,$9f,$ff,$08,$8e,$9f,$8e,$ff,$71,$8e,$9e,$9e,$9e,$84 ; $3587 retained data / unresolved code
    !byte $04,$99,$ff,$9e,$ff,$8e,$02,$86,$70,$ff,$04,$60,$ff,$10,$8e,$60 ; $3597 retained data / unresolved code
    !byte $70,$60,$08,$08,$86,$8e,$08,$86,$ff,$08,$60,$61,$86,$fc,$ff,$9e ; $35a7 retained data / unresolved code
    !byte $8c,$84,$60,$60,$86,$8e,$9f,$08,$9f,$08,$08,$62,$08,$60,$ff,$ff ; $35b7 retained data / unresolved code
    !byte $ff,$86,$6c,$ff,$60,$ff,$ff,$84,$86,$ff,$ff,$ff,$ff,$ff,$ff,$60 ; $35c7 retained data / unresolved code
    !byte $60,$ff,$ff,$9f,$ff,$ff,$ff,$9f,$9f,$ff,$84,$8c,$86,$9f,$08,$9e ; $35d7 retained data / unresolved code
    !byte $04,$60,$02,$86,$ff,$ff,$01,$02,$60,$02,$87,$01,$01,$ff,$ff,$ff ; $35e7 retained data / unresolved code
    !byte $ff,$ff,$ff,$ff,$84,$86,$ff,$ff,$10,$10,$86,$9f,$8e,$8e,$ff,$ff ; $35f7 retained data / unresolved code
    !byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$10,$04,$10,$10,$10,$10,$10,$ff,$ff ; $3607 retained data / unresolved code
    !byte $ff,$8e,$ff,$ff,$60,$ff,$08,$20,$60,$70,$ff,$08,$10,$80,$08,$60 ; $3617 retained data / unresolved code
    !byte $8c,$84,$08,$02,$80,$60,$ff,$20,$20,$60,$10,$10,$10,$08,$08,$04 ; $3627 retained data / unresolved code
    !byte $86,$84,$84,$ff,$70,$02,$60,$20,$60,$60,$08,$ff,$ff,$ff,$ff,$ff ; $3637 retained data / unresolved code
    !byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$86,$80,$60,$60 ; $3647 retained data / unresolved code
    !byte $9f,$84,$02,$60,$08,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$01,$01,$ff ; $3657 retained data / unresolved code
    !byte $ff,$ff,$01,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff ; $3667 retained data / unresolved code
    !byte $ff,$01,$0a,$ff,$ff,$ff,$ff,$01,$ff,$ff,$32,$50,$ff,$ff,$ff,$01 ; $3677 retained data / unresolved code
    !byte $01,$ff,$01,$01,$ff,$ff,$01,$0a,$80,$ff,$ff,$ff,$ff,$ff,$ff,$ff ; $3687 retained data / unresolved code
    !byte $ff,$ff,$32,$ff,$01,$ff,$04,$ff,$ff,$01,$ff,$ff,$ff,$ff,$ff,$58 ; $3697 retained data / unresolved code
    !byte $ff,$50,$58,$41,$0a,$ff,$ff,$ff,$ff,$01,$ff,$23,$ff,$33,$ff,$14 ; $36a7 retained data / unresolved code
    !byte $ff,$ff,$19,$23,$40,$ff,$ff,$3c,$0a,$0a,$ff,$11,$ff,$1e,$01,$01 ; $36b7 retained data / unresolved code
    !byte $ff,$1e,$07,$01,$0b,$01,$01,$ff,$ff,$01,$ff,$ff,$ff,$ff,$ff,$ff ; $36c7 retained data / unresolved code
    !byte $ff,$01,$0a,$ff,$ff,$ff,$01,$ff,$ff,$0a,$ff,$ff,$ff,$01,$05,$ff ; $36d7 retained data / unresolved code
    !byte $ff,$0a,$01,$ff,$ff,$ff,$ff,$18,$ff,$ff,$ff,$03,$19,$ff,$ff,$ff ; $36e7 retained data / unresolved code
    !byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff ; $36f7 retained data / unresolved code
    !byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff ; $3707 retained data / unresolved code
    !byte $ff,$ff,$02,$ff,$0a,$ff,$1e,$ff,$19,$ff,$01,$ff,$ff,$ff,$05,$01 ; $3717 retained data / unresolved code
    !byte $ff,$ff,$ff,$ff,$ff,$ff,$05,$0a,$01,$02,$ff,$ff,$01,$05,$05,$04 ; $3727 retained data / unresolved code
    !byte $ff,$ff,$ff,$0a,$ff,$ff,$ff,$ff,$03,$0a,$0f,$0a,$ff,$ff,$ff,$ff ; $3737 retained data / unresolved code
    !byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$05 ; $3747 retained data / unresolved code
    !byte $01,$ff,$ff,$0a,$19,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$a9,$01,$2c,$a9 ; $3757 retained data / unresolved code
    !byte $02,$8d,$83,$37,$20,$9d,$37,$a9,$10,$8d,$f0,$22,$a9,$01,$8d,$f1 ; $3767 retained data / unresolved code
    !byte $22,$a9,$00,$8d,$ee,$22,$a9,$58,$8d,$ef,$22,$a9,$01,$20,$02,$23 ; $3777 retained data / unresolved code
    !byte $b0,$11,$ee,$ef,$22,$ee,$ef,$22,$ee,$f0,$22,$ad,$f0,$22,$c9,$18 ; $3787 retained data / unresolved code
    !byte $90,$e9,$60,$4c,$7f,$2b,$a9,$0e,$8d,$f0,$22,$a9,$01,$8d,$f1,$22 ; $3797 retained data / unresolved code
    !byte $a9,$00,$8d,$ee,$22,$a9,$ba,$8d,$ef,$22,$a9,$01,$20,$02,$23,$b0 ; $37a7 retained data / unresolved code
    !byte $e2,$a0,$05,$b9,$0e,$38,$d9,$00,$ba,$d0,$04,$88,$10,$f5,$60,$20 ; $37b7 retained data / unresolved code
    !byte $ae,$25,$20,$c5,$22,$d3,$cf,$d2,$d2,$d9,$ac,$a0,$c2,$d5,$d4,$a0 ; $37c7 retained data / unresolved code
    !byte $d4,$c8,$c9,$d3,$a0,$c9,$d3,$a0,$ce,$cf,$d4,$a0,$d9,$cf,$d5,$d2 ; $37d7 retained data / unresolved code
    !byte $a0,$c2,$c1,$d2,$c4,$a7,$d3,$8d,$d4,$c1,$cc,$c5,$a0,$c9,$c9,$c9 ; $37e7 retained data / unresolved code
    !byte $a0,$c3,$c8,$c1,$d2,$c1,$c3,$d4,$c5,$d2,$a0,$c4,$c9,$d3,$cb,$ae ; $37f7 retained data / unresolved code
    !byte $00,$20,$83,$22,$4c,$9d,$37,$c2,$d5,$d2,$c7,$c5,$d2,$a9,$02,$8d ; $3807 retained data / unresolved code
    !byte $f0,$22,$a9,$00,$8d,$f1,$22,$a9,$00,$8d,$ee,$22,$a9,$ba,$8d,$ef ; $3817 retained data / unresolved code
    !byte $22,$a9,$01,$20,$02,$23,$b0,$0e,$a0,$0e,$b9,$7a,$38,$d9,$04,$ba ; $3827 retained data / unresolved code
    !byte $d0,$07,$88,$10,$f5,$60,$4c,$7f,$2b,$20,$ae,$25,$20,$c5,$22,$d0 ; $3837 retained data / unresolved code
    !byte $cc,$c5,$c1,$d3,$c5,$a0,$c9,$ce,$d3,$c5,$d2,$d4,$a0,$d9,$cf,$d5 ; $3847 retained data / unresolved code
    !byte $d2,$a0,$c2,$c1,$d2,$c4,$a7,$d3,$a0,$d4,$c1,$cc,$c5,$a0,$c9,$c9 ; $3857 retained data / unresolved code
    !byte $c9,$8d,$c2,$cf,$cf,$d4,$a0,$c4,$c9,$d3,$cb,$ae,$00,$20,$83,$22 ; $3867 retained data / unresolved code
    !byte $4c,$14,$38,$fe,$42,$41,$52,$44,$53,$2e,$54,$41,$4c,$45,$33,$2e ; $3877 retained data / unresolved code
    !byte $36,$34,$00,$03,$00,$06,$00,$09,$00,$0b,$00,$0d,$00,$0f,$00,$13 ; $3887 retained data / unresolved code
    !byte $13,$03,$13,$06,$13,$09,$13,$0b,$13,$0d,$13,$0f,$13,$13,$26,$03 ; $3897 retained data / unresolved code
    !byte $26,$06,$26,$09,$26,$0b,$26,$0d,$26,$0f,$26,$13,$39,$02,$39,$04 ; $38a7 retained data / unresolved code
    !byte $39,$06,$39,$08,$39,$0a,$39,$0c,$39,$0e,$47,$02,$47,$03,$47,$04 ; $38b7 retained data / unresolved code
    !byte $47,$05,$47,$06,$47,$07,$47,$08,$38,$e9,$01,$90,$20,$0a,$18,$7d ; $38c7 retained data / unresolved code
    !byte $f5,$38,$b0,$19,$c9,$ff,$f0,$15,$a8,$b9,$89,$38,$be,$8a,$38,$86 ; $38d7 retained data / unresolved code
    !byte $8b,$48,$20,$04,$39,$68,$18,$69,$01,$c6,$8b,$d0,$f4,$60,$ff,$2a ; $38e7 retained data / unresolved code
    !byte $1c,$00,$0e,$ff,$ff,$ff,$ff,$ff,$38,$46,$54,$ff,$ff,$48,$29,$07 ; $38f7 retained data / unresolved code
    !byte $aa,$68,$4a,$4a,$4a,$18,$69,$54,$a8,$b1,$36,$1d,$18,$39,$91,$36 ; $3907 retained data / unresolved code
    !byte $60,$80,$40,$20,$10,$08,$04,$02,$01,$8e,$d7,$39,$8c,$d8,$39,$a9 ; $3917 retained data / unresolved code
    !byte $12,$8d,$15,$c2,$a9,$00,$8d,$16,$c2,$20,$e7,$39,$ad,$00,$ba,$8d ; $3927 retained data / unresolved code
    !byte $15,$c2,$ad,$01,$ba,$8d,$16,$c2,$ad,$15,$c2,$d0,$02,$38,$60,$20 ; $3937 retained data / unresolved code
    !byte $e7,$39,$a9,$00,$48,$68,$48,$20,$c7,$39,$90,$0b,$68,$18,$69,$01 ; $3947 retained data / unresolved code
    !byte $c9,$08,$90,$f2,$4c,$33,$39,$68,$0a,$0a,$0a,$0a,$0a,$aa,$bd,$03 ; $3957 retained data / unresolved code
    !byte $ba,$8d,$15,$c2,$bd,$04,$ba,$8d,$16,$c2,$a9,$fe,$8d,$bc,$39,$a9 ; $3967 retained data / unresolved code
    !byte $58,$8d,$bd,$39,$ad,$15,$c2,$f0,$17,$20,$e7,$39,$20,$99,$39,$ad ; $3977 retained data / unresolved code
    !byte $00,$ba,$8d,$15,$c2,$ad,$01,$ba,$8d,$16,$c2,$ad,$15,$c2,$d0,$e9 ; $3987 retained data / unresolved code
    !byte $18,$60,$ad,$00,$ba,$f0,$0c,$a0,$02,$b9,$00,$ba,$20,$bb,$39,$c8 ; $3997 retained data / unresolved code
    !byte $d0,$f7,$60,$a0,$02,$b9,$00,$ba,$20,$bb,$39,$cc,$01,$ba,$f0,$f2 ; $39a7 retained data / unresolved code
    !byte $c8,$d0,$f2,$60,$8d,$ff,$ff,$ee,$bc,$39,$d0,$03,$ee,$bd,$39,$60 ; $39b7 retained data / unresolved code
    !byte $0a,$0a,$0a,$0a,$0a,$a8,$b9,$02,$ba,$d0,$02,$38,$60,$a2,$00,$bd ; $39c7 retained data / unresolved code
    !byte $ff,$ff,$f0,$0a,$59,$05,$ba,$0a,$d0,$f1,$c8,$e8,$d0,$f1,$18,$60 ; $39d7 retained data / unresolved code
    !byte $a9,$01,$85,$42,$a9,$00,$85,$44,$a9,$ba,$85,$45,$20,$11,$c2,$90 ; $39e7 retained data / unresolved code
    !byte $03,$4c,$7f,$2b,$60 ; $39f7 retained data / unresolved code
