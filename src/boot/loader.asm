; Reconstructed from boot disk file 2.0
!cpu 6510
* = $bffe
    !word $c000 ; PRG load address
    !byte $00,$80,$20,$a0,$40,$c0,$60,$e0,$10,$90,$30,$b0,$50,$d0,$70,$f0 ; $c000 data
    !byte $08,$88,$28,$a8,$48,$c8,$68,$e8,$18,$98,$38,$b8,$58,$d8,$78,$f8 ; $c010 data
    !byte $02,$82,$22,$a2,$42,$c2,$62,$e2,$12,$92,$32,$b2,$52,$d2,$72,$f2 ; $c020 data
    !byte $0a,$8a,$2a,$aa,$4a,$ca,$6a,$ea,$1a,$9a,$3a,$ba,$5a,$da,$7a,$fa ; $c030 data
    !byte $04,$84,$24,$a4,$44,$c4,$64,$e4,$14,$94,$34,$b4,$54,$d4,$74,$f4 ; $c040 data
    !byte $0c,$8c,$2c,$ac,$4c,$cc,$6c,$ec,$1c,$9c,$3c,$bc,$5c,$dc,$7c,$fc ; $c050 data
    !byte $06,$86,$26,$a6,$46,$c6,$66,$e6,$16,$96,$36,$b6,$56,$d6,$76,$f6 ; $c060 data
    !byte $0e,$8e,$2e,$ae,$4e,$ce,$6e,$ee,$1e,$9e,$3e,$be,$5e,$de,$7e,$fe ; $c070 data
    !byte $01,$81,$21,$a1,$41,$c1,$61,$e1,$11,$91,$31,$b1,$51,$d1,$71,$f1 ; $c080 data
    !byte $09,$89,$29,$a9,$49,$c9,$69,$e9,$19,$99,$39,$b9,$59,$d9,$79,$f9 ; $c090 data
    !byte $03,$83,$23,$a3,$43,$c3,$63,$e3,$13,$93,$33,$b3,$53,$d3,$73,$f3 ; $c0a0 data
    !byte $0b,$8b,$2b,$ab,$4b,$cb,$6b,$eb,$1b,$9b,$3b,$bb,$5b,$db,$7b,$fb ; $c0b0 data
    !byte $05,$85,$25,$a5,$45,$c5,$65,$e5,$15,$95,$35,$b5,$55,$d5,$75,$f5 ; $c0c0 data
    !byte $0d,$8d,$2d,$ad,$4d,$cd,$6d,$ed,$1d,$9d,$3d,$bd,$5d,$dd,$7d,$fd ; $c0d0 data
    !byte $07,$87,$27,$a7,$47,$c7,$67,$e7,$17,$97,$37,$b7,$57,$d7,$77,$f7 ; $c0e0 data
    !byte $0f,$8f,$2f,$af,$4f,$cf,$6f,$ef,$1f,$9f,$3f,$bf,$5f,$df,$7f,$ff ; $c0f0 data
    !byte $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f ; $c100 data
    !byte $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f ; $c110 data
    !byte $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f ; $c120 data
    !byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00,$0f,$0f,$0f,$0f,$0f,$0f,$00,$00 ; $c130 data
    !byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00,$0f,$0f,$0f,$0f,$0f,$0f,$00,$00 ; $c140 data
    !byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00,$0f,$0f,$0f,$0f,$0f,$0f,$00,$00 ; $c150 data
    !byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00,$0f,$0f,$0f,$0f,$0f,$0f,$00,$00 ; $c160 data
    !byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00,$0f,$0f,$0f,$0f,$0f,$0f,$00,$00 ; $c170 data
    !byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00,$0f,$0f,$0f,$0f,$0f,$0f,$00,$00 ; $c180 data
    !byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00,$0f,$0f,$0f,$0f,$0f,$0f,$00,$00 ; $c190 data
    !byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00,$0f,$0f,$0f,$0f,$0f,$0f,$00,$00 ; $c1a0 data
    !byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00,$0f,$0f,$0f,$0f,$0f,$0f,$00,$00 ; $c1b0 data
    !byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00,$0f,$0f,$0f,$0f,$0f,$0f,$00,$00 ; $c1c0 data
    !byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00,$0f,$0f,$0f,$0f,$0f,$0f,$00,$00 ; $c1d0 data
    !byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00,$0f,$0f,$0f,$0f,$0f,$0f,$00,$00 ; $c1e0 data
    !byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00,$0f,$0f,$0f,$0f,$0f,$0f,$00,$00 ; $c1f0 data
    !byte $0f,$0f,$0f,$0f,$0f,$0f,$00,$00,$4c,$54,$c3,$4c,$00,$c5,$4c,$cf ; $c200 data
    !byte $c4,$4c,$da,$c2,$00,$00,$00 ; $c210 data
send_byte:
    cli ; $c217  58
l_c218:
    sei ; $c218  78
l_c219:
    bit $dd00 ; $c219  2c 00 dd
l_c21c:
    bvc send_byte ; $c21c  50 f9
l_c21e:
    sta $3a ; $c21e  85 3a
l_c220:
    ldy #$04 ; $c220  a0 04
l_c222:
    nop ; $c222  ea
l_c223:
    nop ; $c223  ea
l_c224:
    nop ; $c224  ea
l_c225:
    lda #$17 ; $c225  a9 17
l_c227:
    asl $3a ; $c227  06 3a
l_c229:
    bcc l_c22d ; $c229  90 02
l_c22b:
    lda #$37 ; $c22b  a9 37
l_c22d:
    sta $dd00 ; $c22d  8d 00 dd
l_c230:
    nop ; $c230  ea
l_c231:
    nop ; $c231  ea
l_c232:
    nop ; $c232  ea
l_c233:
    nop ; $c233  ea
l_c234:
    lda #$07 ; $c234  a9 07
l_c236:
    asl $3a ; $c236  06 3a
l_c238:
    bcc l_c23c ; $c238  90 02
l_c23a:
    lda #$27 ; $c23a  a9 27
l_c23c:
    sta $dd00 ; $c23c  8d 00 dd
l_c23f:
    nop ; $c23f  ea
l_c240:
    nop ; $c240  ea
l_c241:
    nop ; $c241  ea
l_c242:
    nop ; $c242  ea
l_c243:
    nop ; $c243  ea
l_c244:
    dey ; $c244  88
l_c245:
    bne l_c222 ; $c245  d0 db
l_c247:
    lda #$27 ; $c247  a9 27
l_c249:
    sta $dd00 ; $c249  8d 00 dd
l_c24c:
    cli ; $c24c  58
l_c24d:
    rts ; $c24d  60
begin_transfer:
    lda $d011 ; $c24e  ad 11 d0
l_c251:
    and #$07 ; $c251  29 07
l_c253:
    eor #$07 ; $c253  49 07
l_c255:
    sta $3b ; $c255  85 3b
l_c257:
    lda #$c1 ; $c257  a9 c1
l_c259:
    sta $3c ; $c259  85 3c
l_c25b:
    lda #$27 ; $c25b  a9 27
l_c25d:
    sta $dd00 ; $c25d  8d 00 dd
l_c260:
    lda $dd00 ; $c260  ad 00 dd
l_c263:
    lsr ; $c263  4a
l_c264:
    lsr ; $c264  4a
l_c265:
    and #$03 ; $c265  29 03
l_c267:
    eor $dd00 ; $c267  4d 00 dd
l_c26a:
    and #$0f ; $c26a  29 0f
l_c26c:
    eor #$ff ; $c26c  49 ff
l_c26e:
    sta $39 ; $c26e  85 39
l_c270:
    lda $42 ; $c270  a5 42
l_c272:
    jsr send_byte ; $c272  20 17 c2
l_c275:
    lda $c215 ; $c275  ad 15 c2
l_c278:
    jsr send_byte ; $c278  20 17 c2
l_c27b:
    lda $c216 ; $c27b  ad 16 c2
l_c27e:
    jsr send_byte ; $c27e  20 17 c2
l_c281:
    lda #$c7 ; $c281  a9 c7
l_c283:
    sta $dd00 ; $c283  8d 00 dd
l_c286:
    rts ; $c286  60
receive_byte:
    cli ; $c287  58
l_c288:
    sei ; $c288  78
l_c289:
    ldy $d012 ; $c289  ac 12 d0
l_c28c:
    lda ($3b),y ; $c28c  b1 3b
l_c28e:
    beq receive_byte ; $c28e  f0 f7
l_c290:
    and $dd00 ; $c290  2d 00 dd
l_c293:
    sta $dd00 ; $c293  8d 00 dd
l_c296:
    ora #$20 ; $c296  09 20
l_c298:
    tay ; $c298  a8
l_c299:
    nop ; $c299  ea
l_c29a:
    nop ; $c29a  ea
l_c29b:
    nop ; $c29b  ea
l_c29c:
    nop ; $c29c  ea
l_c29d:
    lda $dd00 ; $c29d  ad 00 dd
l_c2a0:
    lsr ; $c2a0  4a
l_c2a1:
    lsr ; $c2a1  4a
l_c2a2:
    nop ; $c2a2  ea
l_c2a3:
    eor $dd00 ; $c2a3  4d 00 dd
l_c2a6:
    lsr ; $c2a6  4a
l_c2a7:
    lsr ; $c2a7  4a
l_c2a8:
    nop ; $c2a8  ea
l_c2a9:
    eor $dd00 ; $c2a9  4d 00 dd
l_c2ac:
    lsr ; $c2ac  4a
l_c2ad:
    lsr ; $c2ad  4a
l_c2ae:
    nop ; $c2ae  ea
l_c2af:
    eor $dd00 ; $c2af  4d 00 dd
l_c2b2:
    sty $dd00 ; $c2b2  8c 00 dd
l_c2b5:
    eor $39 ; $c2b5  45 39
l_c2b7:
    tay ; $c2b7  a8
l_c2b8:
    lda $c000,y ; $c2b8  b9 00 c0
l_c2bb:
    cli ; $c2bb  58
l_c2bc:
    rts ; $c2bc  60
handshake:
    lda $dd00 ; $c2bd  ad 00 dd
l_c2c0:
    and #$0f ; $c2c0  29 0f
l_c2c2:
    ora #$20 ; $c2c2  09 20
l_c2c4:
    sta $dd00 ; $c2c4  8d 00 dd
l_c2c7:
    jsr l_c2d9 ; $c2c7  20 d9 c2
l_c2ca:
    lda #$40 ; $c2ca  a9 40
l_c2cc:
    cli ; $c2cc  58
l_c2cd:
    sei ; $c2cd  78
l_c2ce:
    bit $dd00 ; $c2ce  2c 00 dd
l_c2d1:
    beq l_c2cc ; $c2d1  f0 f9
l_c2d3:
    ldx #$14 ; $c2d3  a2 14
l_c2d5:
    dex ; $c2d5  ca
l_c2d6:
    bne l_c2d5 ; $c2d6  d0 fd
l_c2d8:
    cli ; $c2d8  58
l_c2d9:
    rts ; $c2d9  60
transfer_sector:
    lda $01 ; $c2da  a5 01
l_c2dc:
    pha ; $c2dc  48
l_c2dd:
    lda #$35 ; $c2dd  a9 35
l_c2df:
    sta $01 ; $c2df  85 01
l_c2e1:
    lda $d015 ; $c2e1  ad 15 d0
l_c2e4:
    pha ; $c2e4  48
l_c2e5:
    lda #$00 ; $c2e5  a9 00
l_c2e7:
    sta $d015 ; $c2e7  8d 15 d0
l_c2ea:
    lda $44 ; $c2ea  a5 44
l_c2ec:
    sta $c333 ; $c2ec  8d 33 c3
l_c2ef:
    sta $c30e ; $c2ef  8d 0e c3
l_c2f2:
    lda $45 ; $c2f2  a5 45
l_c2f4:
    sta $c334 ; $c2f4  8d 34 c3
l_c2f7:
    sta $c30f ; $c2f7  8d 0f c3
l_c2fa:
    jsr begin_transfer ; $c2fa  20 4e c2
l_c2fd:
    lda $42 ; $c2fd  a5 42
l_c2ff:
    cmp #$03 ; $c2ff  c9 03
l_c301:
    beq l_c31a ; $c301  f0 17
l_c303:
    cmp #$02 ; $c303  c9 02
l_c305:
    bne l_c326 ; $c305  d0 1f
l_c307:
    ldx #$00 ; $c307  a2 00
l_c309:
    ldy #$34 ; $c309  a0 34
l_c30b:
    sty $01 ; $c30b  84 01
l_c30d:
    lda $ffff,x ; $c30d  bd ff ff
l_c310:
    ldy #$35 ; $c310  a0 35
l_c312:
    sty $01 ; $c312  84 01
l_c314:
    jsr send_byte ; $c314  20 17 c2
l_c317:
    inx ; $c317  e8
l_c318:
    bne l_c309 ; $c318  d0 ef
l_c31a:
    jsr handshake ; $c31a  20 bd c2
l_c31d:
    jsr receive_byte ; $c31d  20 87 c2
l_c320:
    sta $c214 ; $c320  8d 14 c2
l_c323:
    jmp l_c342 ; $c323  4c 42 c3
l_c326:
    jsr handshake ; $c326  20 bd c2
l_c329:
    ldx #$00 ; $c329  a2 00
l_c32b:
    jsr receive_byte ; $c32b  20 87 c2
l_c32e:
    ldy #$34 ; $c32e  a0 34
l_c330:
    sty $01 ; $c330  84 01
l_c332:
    sta $ffff,x ; $c332  9d ff ff
l_c335:
    ldy #$35 ; $c335  a0 35
l_c337:
    sty $01 ; $c337  84 01
l_c339:
    inx ; $c339  e8
l_c33a:
    bne l_c32b ; $c33a  d0 ef
l_c33c:
    jsr receive_byte ; $c33c  20 87 c2
l_c33f:
    sta $c214 ; $c33f  8d 14 c2
l_c342:
    lda #$c7 ; $c342  a9 c7
l_c344:
    sta $dd00 ; $c344  8d 00 dd
l_c347:
    pla ; $c347  68
l_c348:
    sta $d015 ; $c348  8d 15 d0
l_c34b:
    pla ; $c34b  68
l_c34c:
    sta $01 ; $c34c  85 01
l_c34e:
    lda $c214 ; $c34e  ad 14 c2
l_c351:
    cmp #$01 ; $c351  c9 01
l_c353:
    rts ; $c353  60
transfer_block:
    clc ; $c354  18
l_c355:
    jsr block_to_track_sector ; $c355  20 69 c3
l_c358:
    jsr transfer_sector ; $c358  20 da c2
l_c35b:
    bcs l_c368 ; $c35b  b0 0b
l_c35d:
    sec ; $c35d  38
l_c35e:
    jsr block_to_track_sector ; $c35e  20 69 c3
l_c361:
    inc $45 ; $c361  e6 45
l_c363:
    jsr transfer_sector ; $c363  20 da c2
l_c366:
    dec $45 ; $c366  c6 45
l_c368:
    rts ; $c368  60
block_to_track_sector:
    lda $46 ; $c369  a5 46
l_c36b:
    rol ; $c36b  2a
l_c36c:
    sta $c216 ; $c36c  8d 16 c2
l_c36f:
    lda $47 ; $c36f  a5 47
l_c371:
    rol ; $c371  2a
l_c372:
    sta $c215 ; $c372  8d 15 c2
l_c375:
    ldx #$00 ; $c375  a2 00
l_c377:
    sec ; $c377  38
l_c378:
    lda $c216 ; $c378  ad 16 c2
l_c37b:
    sbc $c3b2,x ; $c37b  fd b2 c3
l_c37e:
    tay ; $c37e  a8
l_c37f:
    lda $c215 ; $c37f  ad 15 c2
l_c382:
    sbc #$00 ; $c382  e9 00
l_c384:
    bcc l_c38f ; $c384  90 09
l_c386:
    inx ; $c386  e8
l_c387:
    sta $c215 ; $c387  8d 15 c2
l_c38a:
    sty $c216 ; $c38a  8c 16 c2
l_c38d:
    bcs l_c377 ; $c38d  b0 e8
l_c38f:
    inx ; $c38f  e8
l_c390:
    cpx #$23 ; $c390  e0 23
l_c392:
    beq l_c39f ; $c392  f0 0b
l_c394:
    cpx #$12 ; $c394  e0 12
l_c396:
    bcc l_c399 ; $c396  90 01
l_c398:
    inx ; $c398  e8
l_c399:
    stx $c215 ; $c399  8e 15 c2
l_c39c:
    jmp interleave_sector ; $c39c  4c d5 c3
l_c39f:
    lda #$12 ; $c39f  a9 12
l_c3a1:
    sta $c215 ; $c3a1  8d 15 c2
l_c3a4:
    sec ; $c3a4  38
l_c3a5:
    sbc $c216 ; $c3a5  ed 16 c2
l_c3a8:
    cmp #$ff ; $c3a8  c9 ff
l_c3aa:
    bne l_c3ae ; $c3aa  d0 02
l_c3ac:
    lda #$00 ; $c3ac  a9 00
l_c3ae:
    sta $c216 ; $c3ae  8d 16 c2
l_c3b1:
    rts ; $c3b1  60
    !byte $15,$15,$15,$15,$15,$15,$15,$15,$15,$15,$15,$15,$15,$15,$15,$15 ; $c3b2 data
    !byte $15,$13,$13,$13,$13,$13,$13,$12,$12,$12,$12,$12,$12,$11,$11,$11 ; $c3c2 data
    !byte $11,$11,$ff ; $c3d2 data
interleave_sector:
    lda $c215 ; $c3d5  ad 15 c2
l_c3d8:
    ldx #$04 ; $c3d8  a2 04
l_c3da:
    cmp l_c3f8,x ; $c3da  dd f8 c3
l_c3dd:
    dex ; $c3dd  ca
l_c3de:
    bcs l_c3da ; $c3de  b0 fa
l_c3e0:
    txa ; $c3e0  8a
l_c3e1:
    asl ; $c3e1  0a
l_c3e2:
    tax ; $c3e2  aa
l_c3e3:
    lda $c3fd,x ; $c3e3  bd fd c3
l_c3e6:
    sta $c3f3 ; $c3e6  8d f3 c3
l_c3e9:
    lda $c3fe,x ; $c3e9  bd fe c3
l_c3ec:
    sta $c3f4 ; $c3ec  8d f4 c3
l_c3ef:
    ldy $c216 ; $c3ef  ac 16 c2
l_c3f2:
    lda $ffff,y ; $c3f2  b9 ff ff
l_c3f5:
    sta $c216 ; $c3f5  8d 16 c2
l_c3f8:
    rts ; $c3f8  60
    !byte $24,$1f,$19,$12,$3f,$c4,$2d,$c4,$1a,$c4,$05,$c4,$00,$0b,$01,$0c ; $c3f9 data
    !byte $02,$0d,$03,$0e,$04,$0f,$05,$10,$06,$11,$07,$12,$08,$13,$09,$14 ; $c409 data
    !byte $0a,$00,$0b,$03,$0e,$06,$11,$09,$01,$0c,$04,$0f,$07,$12,$0a,$02 ; $c419 data
    !byte $0d,$05,$10,$08,$00,$0b,$04,$0f,$08,$01,$0c,$05,$10,$09,$02,$0d ; $c429 data
    !byte $06,$11,$0a,$03,$0e,$07,$00,$0b,$05,$10,$0a,$04,$0f,$09,$03,$0e ; $c439 data
    !byte $08,$02,$0d,$07,$01,$0c,$06 ; $c449 data
initialize_hardware:
    lda #$7f ; $c450  a9 7f
l_c452:
    sta $dc0d ; $c452  8d 0d dc
l_c455:
    sta $dd0d ; $c455  8d 0d dd
l_c458:
    lda $dc0d ; $c458  ad 0d dc
l_c45b:
    lda $dd0d ; $c45b  ad 0d dd
l_c45e:
    ldx #$00 ; $c45e  a2 00
l_c460:
    lda #$01 ; $c460  a9 01
l_c462:
    sta $d800,x ; $c462  9d 00 d8
l_c465:
    sta $d900,x ; $c465  9d 00 d9
l_c468:
    sta $da00,x ; $c468  9d 00 da
l_c46b:
    sta $db00,x ; $c46b  9d 00 db
l_c46e:
    lda #$86 ; $c46e  a9 86
l_c470:
    sta $0400,x ; $c470  9d 00 04
l_c473:
    sta $0500,x ; $c473  9d 00 05
l_c476:
    sta $0600,x ; $c476  9d 00 06
l_c479:
    sta $0700,x ; $c479  9d 00 07
l_c47c:
    cpx #$2e ; $c47c  e0 2e
l_c47e:
    bcs l_c48f ; $c47e  b0 0f
l_c480:
    lda $c4a0,x ; $c480  bd a0 c4
l_c483:
    sta $d000,x ; $c483  9d 00 d0
l_c486:
    cpx #$1d ; $c486  e0 1d
l_c488:
    bcs l_c48f ; $c488  b0 05
l_c48a:
    lda #$00 ; $c48a  a9 00
l_c48c:
    sta $d400,x ; $c48c  9d 00 d4
l_c48f:
    inx ; $c48f  e8
l_c490:
    bne l_c460 ; $c490  d0 ce
l_c492:
    lda $dd00 ; $c492  ad 00 dd
l_c495:
    ora #$03 ; $c495  09 03
l_c497:
    sta $dd00 ; $c497  8d 00 dd
l_c49a:
    lda #$3f ; $c49a  a9 3f
l_c49c:
    sta $dd02 ; $c49c  8d 02 dd
l_c49f:
    rts ; $c49f  60
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c4a0 data
    !byte $00,$07,$00,$00,$00,$00,$18,$00,$18,$00,$00,$00,$00,$00,$00,$00 ; $c4b0 data
    !byte $00,$00,$02,$03,$04,$00,$01,$07,$08,$09,$0a,$0b,$0c,$0d,$0e ; $c4c0 data
boot_entry:
    sei ; $c4cf  78
l_c4d0:
    jsr initialize_hardware ; $c4d0  20 50 c4
l_c4d3:
    ldx #$ff ; $c4d3  a2 ff
l_c4d5:
    txs ; $c4d5  9a
l_c4d6:
    jsr initialize_drive ; $c4d6  20 2f c6
l_c4d9:
    ldx #$14 ; $c4d9  a2 14
l_c4db:
    cpx $d012 ; $c4db  ec 12 d0
l_c4de:
    bne l_c4db ; $c4de  d0 fb
l_c4e0:
    dex ; $c4e0  ca
l_c4e1:
    bne l_c4db ; $c4e1  d0 f8
l_c4e3:
    ldx #$f2 ; $c4e3  a2 f2
l_c4e5:
    ldy #$c4 ; $c4e5  a0 c4
l_c4e7:
    jsr load_named_file ; $c4e7  20 00 c5
l_c4ea:
    bcs l_c4ef ; $c4ea  b0 03
l_c4ec:
    jmp $2000 ; $c4ec  4c 00 20
l_c4ef:
    jmp l_c4ef ; $c4ef  4c ef c4
    !byte $0d,$c2,$c1,$d2,$c4,$b6,$b4,$ae,$d3,$d9,$d3,$d4,$c5,$cd ; $c4f2 data
load_named_file:
    stx $33 ; $c500  86 33
l_c502:
    sty $34 ; $c502  84 34
l_c504:
    lda #$01 ; $c504  a9 01
l_c506:
    sta $42 ; $c506  85 42
l_c508:
    lda #$00 ; $c508  a9 00
l_c50a:
    sta $44 ; $c50a  85 44
l_c50c:
    lda #$ba ; $c50c  a9 ba
l_c50e:
    sta $45 ; $c50e  85 45
l_c510:
    lda #$02 ; $c510  a9 02
l_c512:
    sta $46 ; $c512  85 46
l_c514:
    lda #$00 ; $c514  a9 00
l_c516:
    sta $47 ; $c516  85 47
l_c518:
    jsr read_block_or_reset ; $c518  20 22 c6
l_c51b:
    ldx #$00 ; $c51b  a2 00
l_c51d:
    clc ; $c51d  18
l_c51e:
    lda #$00 ; $c51e  a9 00
l_c520:
    adc $c608,x ; $c520  7d 08 c6
l_c523:
    sta $31 ; $c523  85 31
l_c525:
    lda #$ba ; $c525  a9 ba
l_c527:
    adc $c615,x ; $c527  7d 15 c6
l_c52a:
    sta $32 ; $c52a  85 32
l_c52c:
    ldy #$00 ; $c52c  a0 00
l_c52e:
    lda ($31),y ; $c52e  b1 31
l_c530:
    and #$f0 ; $c530  29 f0
l_c532:
    beq l_c549 ; $c532  f0 15
l_c534:
    lda ($31),y ; $c534  b1 31
l_c536:
    and #$0f ; $c536  29 0f
l_c538:
    cmp ($33),y ; $c538  d1 33
l_c53a:
    bne l_c549 ; $c53a  d0 0d
l_c53c:
    tay ; $c53c  a8
l_c53d:
    lda ($33),y ; $c53d  b1 33
l_c53f:
    eor ($31),y ; $c53f  51 31
l_c541:
    asl ; $c541  0a
l_c542:
    bne l_c549 ; $c542  d0 05
l_c544:
    dey ; $c544  88
l_c545:
    bne l_c53d ; $c545  d0 f6
l_c547:
    beq l_c55f ; $c547  f0 16
l_c549:
    inx ; $c549  e8
l_c54a:
    cpx #$0d ; $c54a  e0 0d
l_c54c:
    bcc l_c51d ; $c54c  90 cf
l_c54e:
    lda $ba02 ; $c54e  ad 02 ba
l_c551:
    sta $46 ; $c551  85 46
l_c553:
    lda $ba03 ; $c553  ad 03 ba
l_c556:
    sta $47 ; $c556  85 47
l_c558:
    ora $46 ; $c558  05 46
l_c55a:
    bne l_c518 ; $c55a  d0 bc
l_c55c:
    lda #$ff ; $c55c  a9 ff
l_c55e:
    rts ; $c55e  60
l_c55f:
    ldy #$15 ; $c55f  a0 15
l_c561:
    lda ($31),y ; $c561  b1 31
l_c563:
    sta $37 ; $c563  85 37
l_c565:
    iny ; $c565  c8
l_c566:
    lda ($31),y ; $c566  b1 31
l_c568:
    sta $38 ; $c568  85 38
l_c56a:
    ldy #$1f ; $c56a  a0 1f
l_c56c:
    lda ($31),y ; $c56c  b1 31
l_c56e:
    sta $35 ; $c56e  85 35
l_c570:
    iny ; $c570  c8
l_c571:
    lda ($31),y ; $c571  b1 31
l_c573:
    sta $36 ; $c573  85 36
l_c575:
    ldy #$11 ; $c575  a0 11
l_c577:
    lda ($31),y ; $c577  b1 31
l_c579:
    sta $46 ; $c579  85 46
l_c57b:
    iny ; $c57b  c8
l_c57c:
    lda ($31),y ; $c57c  b1 31
l_c57e:
    sta $47 ; $c57e  85 47
l_c580:
    ldy #$00 ; $c580  a0 00
l_c582:
    lda ($31),y ; $c582  b1 31
l_c584:
    and #$f0 ; $c584  29 f0
l_c586:
    cmp #$10 ; $c586  c9 10
l_c588:
    beq l_c5c3 ; $c588  f0 39
l_c58a:
    lda #$00 ; $c58a  a9 00
l_c58c:
    sta $44 ; $c58c  85 44
l_c58e:
    lda #$ba ; $c58e  a9 ba
l_c590:
    sta $45 ; $c590  85 45
l_c592:
    jsr read_block_or_reset ; $c592  20 22 c6
l_c595:
    ldx #$00 ; $c595  a2 00
l_c597:
    stx $30 ; $c597  86 30
l_c599:
    ldx $30 ; $c599  a6 30
l_c59b:
    lda $ba00,x ; $c59b  bd 00 ba
l_c59e:
    sta $46 ; $c59e  85 46
l_c5a0:
    lda $bb00,x ; $c5a0  bd 00 bb
l_c5a3:
    sta $47 ; $c5a3  85 47
l_c5a5:
    lda $38 ; $c5a5  a5 38
l_c5a7:
    cmp #$02 ; $c5a7  c9 02
l_c5a9:
    bcc l_c5c3 ; $c5a9  90 18
l_c5ab:
    lda $35 ; $c5ab  a5 35
l_c5ad:
    sta $44 ; $c5ad  85 44
l_c5af:
    lda $36 ; $c5af  a5 36
l_c5b1:
    sta $45 ; $c5b1  85 45
l_c5b3:
    jsr read_block_or_reset ; $c5b3  20 22 c6
l_c5b6:
    inc $36 ; $c5b6  e6 36
l_c5b8:
    inc $36 ; $c5b8  e6 36
l_c5ba:
    dec $38 ; $c5ba  c6 38
l_c5bc:
    dec $38 ; $c5bc  c6 38
l_c5be:
    inc $30 ; $c5be  e6 30
l_c5c0:
    jmp l_c599 ; $c5c0  4c 99 c5
l_c5c3:
    lda #$00 ; $c5c3  a9 00
l_c5c5:
    sta $44 ; $c5c5  85 44
l_c5c7:
    lda #$bc ; $c5c7  a9 bc
l_c5c9:
    sta $45 ; $c5c9  85 45
l_c5cb:
    jsr read_block_or_reset ; $c5cb  20 22 c6
l_c5ce:
    lda $35 ; $c5ce  a5 35
l_c5d0:
    sta $31 ; $c5d0  85 31
l_c5d2:
    lda $36 ; $c5d2  a5 36
l_c5d4:
    sta $32 ; $c5d4  85 32
l_c5d6:
    ldy #$00 ; $c5d6  a0 00
l_c5d8:
    lda $38 ; $c5d8  a5 38
l_c5da:
    beq l_c5f7 ; $c5da  f0 1b
l_c5dc:
    lda $bc00,y ; $c5dc  b9 00 bc
l_c5df:
    sta ($31),y ; $c5df  91 31
l_c5e1:
    iny ; $c5e1  c8
l_c5e2:
    bne l_c5dc ; $c5e2  d0 f8
l_c5e4:
    inc $32 ; $c5e4  e6 32
l_c5e6:
    ldy $37 ; $c5e6  a4 37
l_c5e8:
    beq l_c5f5 ; $c5e8  f0 0b
l_c5ea:
    dey ; $c5ea  88
l_c5eb:
    lda $bd00,y ; $c5eb  b9 00 bd
l_c5ee:
    sta ($31),y ; $c5ee  91 31
l_c5f0:
    dey ; $c5f0  88
l_c5f1:
    cpy #$ff ; $c5f1  c0 ff
l_c5f3:
    bne l_c5eb ; $c5f3  d0 f6
l_c5f5:
    clc ; $c5f5  18
l_c5f6:
    rts ; $c5f6  60
l_c5f7:
    ldy $37 ; $c5f7  a4 37
l_c5f9:
    beq l_c5f5 ; $c5f9  f0 fa
l_c5fb:
    dey ; $c5fb  88
l_c5fc:
    lda $bc00,y ; $c5fc  b9 00 bc
l_c5ff:
    sta ($31),y ; $c5ff  91 31
l_c601:
    dey ; $c601  88
l_c602:
    cpy #$ff ; $c602  c0 ff
l_c604:
    bne l_c5fc ; $c604  d0 f6
l_c606:
    clc ; $c606  18
l_c607:
    rts ; $c607  60
    !byte $04,$2b,$52,$79,$a0,$c7,$ee,$15,$3c,$63,$8a,$b1,$d8,$00,$00,$00 ; $c608 data
    !byte $00,$00,$00,$00,$01,$01,$01,$01,$01,$01 ; $c618 data
read_block_or_reset:
    jsr transfer_block ; $c622  20 54 c3
l_c625:
    bcc l_c62e ; $c625  90 07
l_c627:
    lda #$36 ; $c627  a9 36
l_c629:
    sta $01 ; $c629  85 01
l_c62b:
    jmp ($fffc) ; $c62b  6c fc ff
l_c62e:
    rts ; $c62e  60
initialize_drive:
    lda #$36 ; $c62f  a9 36
l_c631:
    sta $01 ; $c631  85 01
l_c633:
    lda #$2f ; $c633  a9 2f
l_c635:
    sta $00 ; $c635  85 00
l_c637:
    jsr $ffe7 ; $c637  20 e7 ff
l_c63a:
    jsr open_drive_data ; $c63a  20 5e c6
l_c63d:
    jsr open_drive_command ; $c63d  20 51 c6
l_c640:
    sei ; $c640  78
l_c641:
    lda #$67 ; $c641  a9 67
l_c643:
    sta $dd00 ; $c643  8d 00 dd
l_c646:
    bit $dd00 ; $c646  2c 00 dd
l_c649:
    bvs l_c646 ; $c649  70 fb
l_c64b:
    lda #$c7 ; $c64b  a9 c7
l_c64d:
    sta $dd00 ; $c64d  8d 00 dd
l_c650:
    rts ; $c650  60
open_drive_command:
    ldx #$72 ; $c651  a2 72
l_c653:
    ldy #$c6 ; $c653  a0 c6
l_c655:
    lda #$0d ; $c655  a9 0d
l_c657:
    jsr $ffbd ; $c657  20 bd ff
l_c65a:
    lda #$0f ; $c65a  a9 0f
l_c65c:
    bne l_c669 ; $c65c  d0 0b
open_drive_data:
    lda #$01 ; $c65e  a9 01
l_c660:
    ldx #$7f ; $c660  a2 7f
l_c662:
    ldy #$c6 ; $c662  a0 c6
l_c664:
    jsr $ffbd ; $c664  20 bd ff
l_c667:
    lda #$02 ; $c667  a9 02
l_c669:
    tay ; $c669  a8
l_c66a:
    ldx #$08 ; $c66a  a2 08
l_c66c:
    jsr $ffba ; $c66c  20 ba ff
l_c66f:
    jmp $ffc0 ; $c66f  4c c0 ff
    !byte $42,$2d,$45,$20,$32,$20,$30,$20,$31,$38,$20,$31,$33,$23,$00,$00 ; $c672 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c682 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c692 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c6a2 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c6b2 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c6c2 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c6d2 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c6e2 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c6f2 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c702 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c712 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c722 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c732 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c742 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c752 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c762 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c772 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c782 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c792 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c7a2 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c7b2 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c7c2 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c7d2 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c7e2 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c7f2 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c802 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c812 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c822 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c832 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c842 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c852 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c862 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c872 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c882 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c892 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c8a2 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c8b2 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c8c2 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c8d2 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c8e2 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c8f2 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c902 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c912 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c922 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c932 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c942 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c952 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c962 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c972 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c982 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c992 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c9a2 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c9b2 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c9c2 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c9d2 data
    !byte $00,$00,$00,$00,$00,$00,$00,$00 ; $c9e2 data
