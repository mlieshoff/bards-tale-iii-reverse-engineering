; 1541 code; static flow only, runtime targets remain data.
!cpu 6502
* = $0300
l_0300:
    sei ; $0300  78
l_0301:
    ldx #$45 ; $0301  a2 45
l_0303:
    txs ; $0303  9a
l_0304:
    jsr l_03f2 ; $0304  20 f2 03
l_0307:
    lda #$00 ; $0307  a9 00
l_0309:
    sta $d2 ; $0309  85 d2
l_030b:
    lda $0e ; $030b  a5 0e
l_030d:
    jsr l_049e ; $030d  20 9e 04
l_0310:
    lda $d1 ; $0310  a5 d1
l_0312:
    cmp #$03 ; $0312  c9 03
l_0314:
    beq l_0363 ; $0314  f0 4d
l_0316:
    cmp #$02 ; $0316  c9 02
l_0318:
    beq l_0338 ; $0318  f0 1e
l_031a:
    lda #$02 ; $031a  a9 02
l_031c:
    sta $06c4 ; $031c  8d c4 06
l_031f:
    jsr l_044d ; $031f  20 4d 04
l_0322:
    bcc l_032f ; $0322  90 0b
l_0324:
    dec $06c4 ; $0324  ce c4 06
l_0327:
    beq l_032f ; $0327  f0 06
l_0329:
    jsr l_055a ; $0329  20 5a 05
l_032c:
    jmp l_031f ; $032c  4c 1f 03
l_032f:
    jsr l_0624 ; $032f  20 24 06
l_0332:
    jsr l_03ba ; $0332  20 ba 03
l_0335:
    jmp l_0300 ; $0335  4c 00 03
l_0338:
    jsr l_0492 ; $0338  20 92 04
l_033b:
    jsr $f5e9 ; $033b  20 e9 f5
l_033e:
    sta $3a ; $033e  85 3a
l_0340:
    jsr $f78f ; $0340  20 8f f7
l_0343:
    lda #$02 ; $0343  a9 02
l_0345:
    sta $06c4 ; $0345  8d c4 06
l_0348:
    jsr l_05c2 ; $0348  20 c2 05
l_034b:
    bcc l_0358 ; $034b  90 0b
l_034d:
    dec $06c4 ; $034d  ce c4 06
l_0350:
    beq l_0358 ; $0350  f0 06
l_0352:
    jsr l_055a ; $0352  20 5a 05
l_0355:
    jmp l_0348 ; $0355  4c 48 03
l_0358:
    jsr l_0624 ; $0358  20 24 06
l_035b:
    lda $d2 ; $035b  a5 d2
l_035d:
    jsr l_03ca ; $035d  20 ca 03
l_0360:
    jmp l_0300 ; $0360  4c 00 03
l_0363:
    lda #$01 ; $0363  a9 01
l_0365:
    pha ; $0365  48
l_0366:
    jsr l_049e ; $0366  20 9e 04
l_0369:
    jsr l_062a ; $0369  20 2a 06
l_036c:
    pla ; $036c  68
l_036d:
    clc ; $036d  18
l_036e:
    adc #$01 ; $036e  69 01
l_0370:
    cmp #$24 ; $0370  c9 24
l_0372:
    bcc l_0365 ; $0372  90 f1
l_0374:
    lda #$23 ; $0374  a9 23
l_0376:
    pha ; $0376  48
l_0377:
    jsr l_049e ; $0377  20 9e 04
l_037a:
    jsr l_06a2 ; $037a  20 a2 06
l_037d:
    pla ; $037d  68
l_037e:
    sec ; $037e  38
l_037f:
    sbc #$01 ; $037f  e9 01
l_0381:
    bne l_0376 ; $0381  d0 f3
l_0383:
    jsr l_0624 ; $0383  20 24 06
l_0386:
    lda #$00 ; $0386  a9 00
l_0388:
    jsr l_03ca ; $0388  20 ca 03
l_038b:
    jmp l_0300 ; $038b  4c 00 03
l_038e:
    ldy #$04 ; $038e  a0 04
l_0390:
    lda #$00 ; $0390  a9 00
l_0392:
    sta $1800 ; $0392  8d 00 18
l_0395:
    lda #$04 ; $0395  a9 04
l_0397:
    bit $1800 ; $0397  2c 00 18
l_039a:
    beq l_0397 ; $039a  f0 fb
l_039c:
    lda $1800 ; $039c  ad 00 18
l_039f:
    lsr ; $039f  4a
l_03a0:
    rol $14 ; $03a0  26 14
l_03a2:
    lda #$04 ; $03a2  a9 04
l_03a4:
    bit $1800 ; $03a4  2c 00 18
l_03a7:
    bne l_03a4 ; $03a7  d0 fb
l_03a9:
    lda $1800 ; $03a9  ad 00 18
l_03ac:
    lsr ; $03ac  4a
l_03ad:
    rol $14 ; $03ad  26 14
l_03af:
    dey ; $03af  88
l_03b0:
    bne l_0395 ; $03b0  d0 e3
l_03b2:
    lda #$08 ; $03b2  a9 08
l_03b4:
    sta $1800 ; $03b4  8d 00 18
l_03b7:
    lda $14 ; $03b7  a5 14
l_03b9:
    rts ; $03b9  60
l_03ba:
    ldy #$00 ; $03ba  a0 00
l_03bc:
    lda $0200,y ; $03bc  b9 00 02
l_03bf:
    jsr l_03ca ; $03bf  20 ca 03
l_03c2:
    iny ; $03c2  c8
l_03c3:
    bne l_03bc ; $03c3  d0 f7
l_03c5:
    lda $d2 ; $03c5  a5 d2
l_03c7:
    jmp l_03ca ; $03c7  4c ca 03
l_03ca:
    pha ; $03ca  48
l_03cb:
    lsr ; $03cb  4a
l_03cc:
    lsr ; $03cc  4a
l_03cd:
    lsr ; $03cd  4a
l_03ce:
    lsr ; $03ce  4a
l_03cf:
    tax ; $03cf  aa
l_03d0:
    lda #$01 ; $03d0  a9 01
l_03d2:
    sta $1800 ; $03d2  8d 00 18
l_03d5:
    bit $1800 ; $03d5  2c 00 18
l_03d8:
    bne l_03d5 ; $03d8  d0 fb
l_03da:
    stx $1800 ; $03da  8e 00 18
l_03dd:
    txa ; $03dd  8a
l_03de:
    asl ; $03de  0a
l_03df:
    and #$0f ; $03df  29 0f
l_03e1:
    sta $1800 ; $03e1  8d 00 18
l_03e4:
    pla ; $03e4  68
l_03e5:
    and #$0f ; $03e5  29 0f
l_03e7:
    sta $1800 ; $03e7  8d 00 18
l_03ea:
    asl ; $03ea  0a
l_03eb:
    and #$0f ; $03eb  29 0f
l_03ed:
    nop ; $03ed  ea
l_03ee:
    sta $1800 ; $03ee  8d 00 18
l_03f1:
    rts ; $03f1  60
l_03f2:
    lda $1c00 ; $03f2  ad 00 1c
l_03f5:
    and #$f7 ; $03f5  29 f7
l_03f7:
    sta $1c00 ; $03f7  8d 00 1c
l_03fa:
    lda #$ee ; $03fa  a9 ee
l_03fc:
    sta $1c0c ; $03fc  8d 0c 1c
l_03ff:
    lda #$08 ; $03ff  a9 08
l_0401:
    sta $1800 ; $0401  8d 00 18
l_0404:
    lda #$0a ; $0404  a9 0a
l_0406:
    sta $d0 ; $0406  85 d0
l_0408:
    ldx #$00 ; $0408  a2 00
l_040a:
    ldy #$00 ; $040a  a0 00
l_040c:
    dex ; $040c  ca
l_040d:
    bne l_0421 ; $040d  d0 12
l_040f:
    dey ; $040f  88
l_0410:
    bne l_0421 ; $0410  d0 0f
l_0412:
    dec $d0 ; $0412  c6 d0
l_0414:
    bne l_0421 ; $0414  d0 0b
l_0416:
    lda $1c00 ; $0416  ad 00 1c
l_0419:
    and #$fb ; $0419  29 fb
l_041b:
    sta $1c00 ; $041b  8d 00 1c
l_041e:
    lsr $06c5 ; $041e  4e c5 06
l_0421:
    lda $1800 ; $0421  ad 00 18
l_0424:
    lsr ; $0424  4a
l_0425:
    bcc l_040c ; $0425  90 e5
l_0427:
    jsr l_038e ; $0427  20 8e 03
l_042a:
    sta $d1 ; $042a  85 d1
l_042c:
    jsr l_038e ; $042c  20 8e 03
l_042f:
    sta $0e ; $042f  85 0e
l_0431:
    jsr l_038e ; $0431  20 8e 03
l_0434:
    sta $0f ; $0434  85 0f
l_0436:
    lda $1c00 ; $0436  ad 00 1c
l_0439:
    ora #$0c ; $0439  09 0c
l_043b:
    sta $1c00 ; $043b  8d 00 1c
l_043e:
    bit $06c5 ; $043e  2c c5 06
l_0441:
    bmi l_044c ; $0441  30 09
l_0443:
    sec ; $0443  38
l_0444:
    ror $06c5 ; $0444  6e c5 06
l_0447:
    ldx #$c0 ; $0447  a2 c0
l_0449:
    jmp l_06c6 ; $0449  4c c6 06
l_044c:
    rts ; $044c  60
l_044d:
    lda #$03 ; $044d  a9 03
l_044f:
    sta $c4 ; $044f  85 c4
l_0451:
    jsr l_0569 ; $0451  20 69 05
l_0454:
    bcs l_0488 ; $0454  b0 32
l_0456:
    jsr l_05a3 ; $0456  20 a3 05
l_0459:
    bcs l_0488 ; $0459  b0 2d
l_045b:
    ldy #$00 ; $045b  a0 00
l_045d:
    bvc l_045d ; $045d  50 fe
l_045f:
    clv ; $045f  b8
l_0460:
    lda $1c01 ; $0460  ad 01 1c
l_0463:
    sta ($30),y ; $0463  91 30
l_0465:
    iny ; $0465  c8
l_0466:
    bne l_045d ; $0466  d0 f5
l_0468:
    ldy #$ba ; $0468  a0 ba
l_046a:
    bvc l_046a ; $046a  50 fe
l_046c:
    clv ; $046c  b8
l_046d:
    lda $1c01 ; $046d  ad 01 1c
l_0470:
    sta $0100,y ; $0470  99 00 01
l_0473:
    iny ; $0473  c8
l_0474:
    bne l_046a ; $0474  d0 f4
l_0476:
    jsr $f8e0 ; $0476  20 e0 f8
l_0479:
    lda $38 ; $0479  a5 38
l_047b:
    cmp $47 ; $047b  c5 47
l_047d:
    bne l_0488 ; $047d  d0 09
l_047f:
    jsr $f5e9 ; $047f  20 e9 f5
l_0482:
    cmp $3a ; $0482  c5 3a
l_0484:
    bne l_0488 ; $0484  d0 02
l_0486:
    clc ; $0486  18
l_0487:
    rts ; $0487  60
l_0488:
    dec $c4 ; $0488  c6 c4
l_048a:
    bne l_0451 ; $048a  d0 c5
l_048c:
    lda #$27 ; $048c  a9 27
l_048e:
    sta $d2 ; $048e  85 d2
l_0490:
    sec ; $0490  38
l_0491:
    rts ; $0491  60
l_0492:
    ldx #$00 ; $0492  a2 00
l_0494:
    jsr l_038e ; $0494  20 8e 03
l_0497:
    sta $0200,x ; $0497  9d 00 02
l_049a:
    inx ; $049a  e8
l_049b:
    bne l_0494 ; $049b  d0 f7
l_049d:
    rts ; $049d  60
l_049e:
    pha ; $049e  48
l_049f:
    sec ; $049f  38
l_04a0:
    sbc $22 ; $04a0  e5 22
l_04a2:
    beq l_04da ; $04a2  f0 36
l_04a4:
    ldx #$01 ; $04a4  a2 01
l_04a6:
    bcs l_04ae ; $04a6  b0 06
l_04a8:
    ldx #$ff ; $04a8  a2 ff
l_04aa:
    eor #$ff ; $04aa  49 ff
l_04ac:
    adc #$01 ; $04ac  69 01
l_04ae:
    asl ; $04ae  0a
l_04af:
    sta $c1 ; $04af  85 c1
l_04b1:
    stx $c2 ; $04b1  86 c2
l_04b3:
    clc ; $04b3  18
l_04b4:
    lda $1c00 ; $04b4  ad 00 1c
l_04b7:
    adc $c2 ; $04b7  65 c2
l_04b9:
    and #$03 ; $04b9  29 03
l_04bb:
    sta $c3 ; $04bb  85 c3
l_04bd:
    lda $1c00 ; $04bd  ad 00 1c
l_04c0:
    and #$fc ; $04c0  29 fc
l_04c2:
    ora $c3 ; $04c2  05 c3
l_04c4:
    sta $1c00 ; $04c4  8d 00 1c
l_04c7:
    lda #$94 ; $04c7  a9 94
l_04c9:
    sta $1805 ; $04c9  8d 05 18
l_04cc:
    bit $1805 ; $04cc  2c 05 18
l_04cf:
    bmi l_04cc ; $04cf  30 fb
l_04d1:
    dec $c1 ; $04d1  c6 c1
l_04d3:
    bne l_04b3 ; $04d3  d0 de
l_04d5:
    ldx #$40 ; $04d5  a2 40
l_04d7:
    jsr l_06c6 ; $04d7  20 c6 06
l_04da:
    pla ; $04da  68
l_04db:
    sta $22 ; $04db  85 22
l_04dd:
    jsr $f24b ; $04dd  20 4b f2
l_04e0:
    sta $c5 ; $04e0  85 c5
l_04e2:
    txa ; $04e2  8a
l_04e3:
    asl ; $04e3  0a
l_04e4:
    asl ; $04e4  0a
l_04e5:
    asl ; $04e5  0a
l_04e6:
    asl ; $04e6  0a
l_04e7:
    asl ; $04e7  0a
l_04e8:
    sta $c2 ; $04e8  85 c2
l_04ea:
    lda $1c00 ; $04ea  ad 00 1c
l_04ed:
    and #$9f ; $04ed  29 9f
l_04ef:
    ora $c2 ; $04ef  05 c2
l_04f1:
    sta $1c00 ; $04f1  8d 00 1c
l_04f4:
    lda $c5 ; $04f4  a5 c5
l_04f6:
    sta $43 ; $04f6  85 43
l_04f8:
    lda #$00 ; $04f8  a9 00
l_04fa:
    sta $bc ; $04fa  85 bc
l_04fc:
    tax ; $04fc  aa
l_04fd:
    tay ; $04fd  a8
l_04fe:
    lda $39 ; $04fe  a5 39
l_0500:
    sta $0700,y ; $0500  99 00 07
l_0503:
    lda $bc ; $0503  a5 bc
l_0505:
    sta $0702,y ; $0505  99 02 07
l_0508:
    lda $22 ; $0508  a5 22
l_050a:
    sta $0703,y ; $050a  99 03 07
l_050d:
    lda #$50 ; $050d  a9 50
l_050f:
    sta $0704,y ; $050f  99 04 07
l_0512:
    lda #$49 ; $0512  a9 49
l_0514:
    sta $0705,y ; $0514  99 05 07
l_0517:
    lda #$0f ; $0517  a9 0f
l_0519:
    sta $0706,y ; $0519  99 06 07
l_051c:
    sta $0707,y ; $051c  99 07 07
l_051f:
    lda $0702,y ; $051f  b9 02 07
l_0522:
    eor $0703,y ; $0522  59 03 07
l_0525:
    eor $0704,y ; $0525  59 04 07
l_0528:
    eor $0705,y ; $0528  59 05 07
l_052b:
    sta $0701,y ; $052b  99 01 07
l_052e:
    clc ; $052e  18
l_052f:
    tya ; $052f  98
l_0530:
    adc #$08 ; $0530  69 08
l_0532:
    tay ; $0532  a8
l_0533:
    inc $bc ; $0533  e6 bc
l_0535:
    lda $bc ; $0535  a5 bc
l_0537:
    cmp $43 ; $0537  c5 43
l_0539:
    bcc l_04fe ; $0539  90 c3
l_053b:
    tya ; $053b  98
l_053c:
    pha ; $053c  48
l_053d:
    lda #$07 ; $053d  a9 07
l_053f:
    sta $31 ; $053f  85 31
l_0541:
    jsr $fe30 ; $0541  20 30 fe
l_0544:
    pla ; $0544  68
l_0545:
    tay ; $0545  a8
l_0546:
    dey ; $0546  88
l_0547:
    lda $0700,y ; $0547  b9 00 07
l_054a:
    sta $0745,y ; $054a  99 45 07
l_054d:
    dey ; $054d  88
l_054e:
    cpy #$ff ; $054e  c0 ff
l_0550:
    bne l_0547 ; $0550  d0 f5
l_0552:
    jsr $fdf5 ; $0552  20 f5 fd
l_0555:
    lda #$02 ; $0555  a9 02
l_0557:
    sta $31 ; $0557  85 31
l_0559:
    rts ; $0559  60
l_055a:
    rts ; $055a  60
    !byte $a9,$28,$85,$22,$a9,$01,$20,$9e,$04,$a5,$0e,$4c,$9e,$04 ; $055b data
l_0569:
    lda #$fe ; $0569  a9 fe
l_056b:
    sta $c7 ; $056b  85 c7
l_056d:
    lda $0f ; $056d  a5 0f
l_056f:
    asl ; $056f  0a
l_0570:
    asl ; $0570  0a
l_0571:
    asl ; $0571  0a
l_0572:
    clc ; $0572  18
l_0573:
    adc $0f ; $0573  65 0f
l_0575:
    adc $0f ; $0575  65 0f
l_0577:
    tay ; $0577  a8
l_0578:
    jsr l_05a3 ; $0578  20 a3 05
l_057b:
    bcs l_0599 ; $057b  b0 1c
l_057d:
    ldx #$00 ; $057d  a2 00
l_057f:
    bvc l_057f ; $057f  50 fe
l_0581:
    clv ; $0581  b8
l_0582:
    lda $1c01 ; $0582  ad 01 1c
l_0585:
    eor $0700,y ; $0585  59 00 07
l_0588:
    and $059b,x ; $0588  3d 9b 05
l_058b:
    bne l_0595 ; $058b  d0 08
l_058d:
    iny ; $058d  c8
l_058e:
    inx ; $058e  e8
l_058f:
    cpx #$08 ; $058f  e0 08
l_0591:
    bne l_057f ; $0591  d0 ec
l_0593:
    clc ; $0593  18
l_0594:
    rts ; $0594  60
l_0595:
    dec $c7 ; $0595  c6 c7
l_0597:
    bne l_056d ; $0597  d0 d4
l_0599:
    sec ; $0599  38
l_059a:
    rts ; $059a  60
    !byte $ff,$c0,$0f,$ff,$ff,$00,$00,$0f ; $059b data
l_05a3:
    lda #$05 ; $05a3  a9 05
l_05a5:
    sta $c9 ; $05a5  85 c9
l_05a7:
    lda #$ff ; $05a7  a9 ff
l_05a9:
    sta $1805 ; $05a9  8d 05 18
l_05ac:
    bit $1805 ; $05ac  2c 05 18
l_05af:
    bpl l_05bc ; $05af  10 0b
l_05b1:
    bit $1c00 ; $05b1  2c 00 1c
l_05b4:
    bmi l_05ac ; $05b4  30 f6
l_05b6:
    clv ; $05b6  b8
l_05b7:
    lda $1c01 ; $05b7  ad 01 1c
l_05ba:
    clc ; $05ba  18
l_05bb:
    rts ; $05bb  60
l_05bc:
    dec $c9 ; $05bc  c6 c9
l_05be:
    bne l_05a7 ; $05be  d0 e7
l_05c0:
    sec ; $05c0  38
l_05c1:
    rts ; $05c1  60
l_05c2:
    lda #$02 ; $05c2  a9 02
l_05c4:
    sta $c4 ; $05c4  85 c4
l_05c6:
    lda $1c00 ; $05c6  ad 00 1c
l_05c9:
    and #$10 ; $05c9  29 10
l_05cb:
    beq l_061e ; $05cb  f0 51
l_05cd:
    jsr l_0569 ; $05cd  20 69 05
l_05d0:
    bcs l_0617 ; $05d0  b0 45
l_05d2:
    ldx #$09 ; $05d2  a2 09
l_05d4:
    bvc l_05d4 ; $05d4  50 fe
l_05d6:
    clv ; $05d6  b8
l_05d7:
    dex ; $05d7  ca
l_05d8:
    bne l_05d4 ; $05d8  d0 fa
l_05da:
    lda #$ff ; $05da  a9 ff
l_05dc:
    sta $1c03 ; $05dc  8d 03 1c
l_05df:
    lda $1c0c ; $05df  ad 0c 1c
l_05e2:
    and #$1f ; $05e2  29 1f
l_05e4:
    ora #$c0 ; $05e4  09 c0
l_05e6:
    sta $1c0c ; $05e6  8d 0c 1c
l_05e9:
    lda #$ff ; $05e9  a9 ff
l_05eb:
    ldx #$05 ; $05eb  a2 05
l_05ed:
    sta $1c01 ; $05ed  8d 01 1c
l_05f0:
    clv ; $05f0  b8
l_05f1:
    bvc l_05f1 ; $05f1  50 fe
l_05f3:
    clv ; $05f3  b8
l_05f4:
    dex ; $05f4  ca
l_05f5:
    bne l_05f1 ; $05f5  d0 fa
l_05f7:
    ldy #$bb ; $05f7  a0 bb
l_05f9:
    lda $0100,y ; $05f9  b9 00 01
l_05fc:
    bvc l_05fc ; $05fc  50 fe
l_05fe:
    clv ; $05fe  b8
l_05ff:
    sta $1c01 ; $05ff  8d 01 1c
l_0602:
    iny ; $0602  c8
l_0603:
    bne l_05f9 ; $0603  d0 f4
l_0605:
    lda ($30),y ; $0605  b1 30
l_0607:
    bvc l_0607 ; $0607  50 fe
l_0609:
    clv ; $0609  b8
l_060a:
    sta $1c01 ; $060a  8d 01 1c
l_060d:
    iny ; $060d  c8
l_060e:
    bne l_0605 ; $060e  d0 f5
l_0610:
    bvc l_0610 ; $0610  50 fe
l_0612:
    jsr $fe00 ; $0612  20 00 fe
l_0615:
    clc ; $0615  18
l_0616:
    rts ; $0616  60
l_0617:
    dec $c4 ; $0617  c6 c4
l_0619:
    bne l_05cd ; $0619  d0 b2
l_061b:
    jmp l_048c ; $061b  4c 8c 04
l_061e:
    lda #$2b ; $061e  a9 2b
l_0620:
    sta $d2 ; $0620  85 d2
l_0622:
    clc ; $0622  18
l_0623:
    rts ; $0623  60
l_0624:
    lda #$00 ; $0624  a9 00
l_0626:
    sta $1800 ; $0626  8d 00 18
l_0629:
    rts ; $0629  60
l_062a:
    lda $1c0c ; $062a  ad 0c 1c
l_062d:
    and #$1f ; $062d  29 1f
l_062f:
    ora #$c0 ; $062f  09 c0
l_0631:
    sta $1c0c ; $0631  8d 0c 1c
l_0634:
    lda #$ff ; $0634  a9 ff
l_0636:
    sta $1c03 ; $0636  8d 03 1c
l_0639:
    lda #$55 ; $0639  a9 55
l_063b:
    sta $1c01 ; $063b  8d 01 1c
l_063e:
    ldx #$00 ; $063e  a2 00
l_0640:
    ldy #$28 ; $0640  a0 28
l_0642:
    clv ; $0642  b8
l_0643:
    bvc l_0643 ; $0643  50 fe
l_0645:
    clv ; $0645  b8
l_0646:
    dex ; $0646  ca
l_0647:
    bne l_0643 ; $0647  d0 fa
l_0649:
    dey ; $0649  88
l_064a:
    bpl l_0643 ; $064a  10 f7
l_064c:
    lda #$00 ; $064c  a9 00
l_064e:
    sta $06c3 ; $064e  8d c3 06
l_0651:
    lda #$ff ; $0651  a9 ff
l_0653:
    sta $1c01 ; $0653  8d 01 1c
l_0656:
    ldx #$05 ; $0656  a2 05
l_0658:
    bvc l_0658 ; $0658  50 fe
l_065a:
    clv ; $065a  b8
l_065b:
    dex ; $065b  ca
l_065c:
    bne l_0658 ; $065c  d0 fa
l_065e:
    ldx #$0a ; $065e  a2 0a
l_0660:
    ldy $06c3 ; $0660  ac c3 06
l_0663:
    bvc l_0663 ; $0663  50 fe
l_0665:
    clv ; $0665  b8
l_0666:
    lda $0700,y ; $0666  b9 00 07
l_0669:
    sta $1c01 ; $0669  8d 01 1c
l_066c:
    iny ; $066c  c8
l_066d:
    dex ; $066d  ca
l_066e:
    bne l_0663 ; $066e  d0 f3
l_0670:
    sty $06c3 ; $0670  8c c3 06
l_0673:
    ldx #$09 ; $0673  a2 09
l_0675:
    lda #$55 ; $0675  a9 55
l_0677:
    bvc l_0677 ; $0677  50 fe
l_0679:
    clv ; $0679  b8
l_067a:
    sta $1c01 ; $067a  8d 01 1c
l_067d:
    dex ; $067d  ca
l_067e:
    bne l_0677 ; $067e  d0 f7
l_0680:
    dec $bc ; $0680  c6 bc
l_0682:
    beq l_069c ; $0682  f0 18
l_0684:
    ldx #$50 ; $0684  a2 50
l_0686:
    ldy #$01 ; $0686  a0 01
l_0688:
    lda #$55 ; $0688  a9 55
l_068a:
    bvc l_068a ; $068a  50 fe
l_068c:
    clv ; $068c  b8
l_068d:
    sta $1c01 ; $068d  8d 01 1c
l_0690:
    dex ; $0690  ca
l_0691:
    bne l_068a ; $0691  d0 f7
l_0693:
    dey ; $0693  88
l_0694:
    bpl l_068a ; $0694  10 f4
l_0696:
    bvc l_0696 ; $0696  50 fe
l_0698:
    lda $bc ; $0698  a5 bc
l_069a:
    bne l_0651 ; $069a  d0 b5
l_069c:
    clv ; $069c  b8
l_069d:
    bvc l_069d ; $069d  50 fe
l_069f:
    jmp $fe00 ; $069f  4c 00 fe
l_06a2:
    ldx #$00 ; $06a2  a2 00
l_06a4:
    txa ; $06a4  8a
l_06a5:
    sta $0200,x ; $06a5  9d 00 02
l_06a8:
    inx ; $06a8  e8
l_06a9:
    bne l_06a5 ; $06a9  d0 fa
l_06ab:
    jsr $f5e9 ; $06ab  20 e9 f5
l_06ae:
    sta $3a ; $06ae  85 3a
l_06b0:
    jsr $f78f ; $06b0  20 8f f7
l_06b3:
    lda #$00 ; $06b3  a9 00
l_06b5:
    sta $0f ; $06b5  85 0f
l_06b7:
    jsr l_05c2 ; $06b7  20 c2 05
l_06ba:
    inc $0f ; $06ba  e6 0f
l_06bc:
    lda $0f ; $06bc  a5 0f
l_06be:
    cmp $bc ; $06be  c5 bc
l_06c0:
    bne l_06b7 ; $06c0  d0 f5
l_06c2:
    rts ; $06c2  60
    !byte $00,$00,$00 ; $06c3 data
l_06c6:
    ldy #$00 ; $06c6  a0 00
l_06c8:
    dey ; $06c8  88
l_06c9:
    bne l_06c8 ; $06c9  d0 fd
l_06cb:
    dex ; $06cb  ca
l_06cc:
    bne l_06c8 ; $06cc  d0 fa
l_06ce:
    rts ; $06ce  60
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $06cf data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $06df data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $06ef data
    !byte $00 ; $06ff data
