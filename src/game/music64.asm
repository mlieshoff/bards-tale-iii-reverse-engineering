; MUSIC64 -- static code/data classification; unresolved bytes retained.
!cpu 6510
* = $c480

; SID player plus music data, not a sampled sound file.
; Five JMP vectors lead into executable player code.
; MUSIC64 is copied from $4800 to $c480 by startup; DMUSIC64 runs at $e000.
music_vector_0:
    jmp request_music_command_zero ; $c480  4c 90 c4
music_vector_1:
    jmp request_music_command_zero ; $c483  4c 90 c4
music_vector_2:
    jmp music_noop ; $c486  4c 8f c4
music_vector_3:
    jmp music_noop ; $c489  4c 8f c4
music_tick_vector:
    jmp process_music_frame ; $c48c  4c 97 c4
music_noop:
    rts ; $c48f  60

; Store $80 in command mailbox $ba: command zero with request bit set.
request_music_command_zero:
    lda #$80 ; $c490  a9 80
    sta $ba ; $c492  85 ba
    jmp process_music_frame ; $c494  4c 97 c4

; Preserve interrupt flags and stack state; apply volume from $33,
; consume command mailbox $ba, advance player state, and update SID registers.
; Engine raster IRQ calls vector +12 once per acknowledged raster interrupt.
process_music_frame:
    php ; $c497  08
    sei ; $c498  78
    tsx ; $c499  ba
    stx $c83c ; $c49a  8e 3c c8
    lda #$0f ; $c49d  a9 0f
    bit $33 ; $c49f  24 33
    bmi l_c4a5 ; $c4a1  30 02
    lda #$00 ; $c4a3  a9 00

; SID volume/filter mode (I/O only when $01 exposes it)
l_c4a5:
    sta $d418 ; $c4a5  8d 18 d4
    lda $ba ; $c4a8  a5 ba
    bmi l_c4af ; $c4aa  30 03
    jmp l_c54c ; $c4ac  4c 4c c5
l_c4af:
    and #$7f ; $c4af  29 7f
    sta $ba ; $c4b1  85 ba
    bne l_c4c0 ; $c4b3  d0 0b
l_c4b5:
    lda #$00 ; $c4b5  a9 00
    sta $c82b ; $c4b7  8d 2b c8
    sta $c81a ; $c4ba  8d 1a c8
    jmp l_c544 ; $c4bd  4c 44 c5
l_c4c0:
    cmp #$02 ; $c4c0  c9 02
    bne l_c4f3 ; $c4c2  d0 2f
    ldx $c81a ; $c4c4  ae 1a c8
    beq l_c4b5 ; $c4c7  f0 ec
    dex ; $c4c9  ca
    dex ; $c4ca  ca
    dex ; $c4cb  ca
    dex ; $c4cc  ca
    stx $c81a ; $c4cd  8e 1a c8
    lda $c81b,x ; $c4d0  bd 1b c8
    sta $c819 ; $c4d3  8d 19 c8
    sta $ba ; $c4d6  85 ba
    jsr l_c55e ; $c4d8  20 5e c5
    ldx $c81a ; $c4db  ae 1a c8
    lda $c81c,x ; $c4de  bd 1c c8
    sta $c80e ; $c4e1  8d 0e c8
    lda $c81d,x ; $c4e4  bd 1d c8
    sta $c80f ; $c4e7  8d 0f c8
    lda $c81e,x ; $c4ea  bd 1e c8
    sta $c82b ; $c4ed  8d 2b c8
    jmp l_c54c ; $c4f0  4c 4c c5
l_c4f3:
    cmp #$01 ; $c4f3  c9 01
    bne l_c51d ; $c4f5  d0 26
    ldx $c81a ; $c4f7  ae 1a c8
    lda $c819 ; $c4fa  ad 19 c8
    sta $c81b,x ; $c4fd  9d 1b c8
    lda $c80e ; $c500  ad 0e c8
    sta $c81c,x ; $c503  9d 1c c8
    lda $c80f ; $c506  ad 0f c8
    sta $c81d,x ; $c509  9d 1d c8
    lda $c82b ; $c50c  ad 2b c8
    sta $c81e,x ; $c50f  9d 1e c8
    inx ; $c512  e8
    inx ; $c513  e8
    inx ; $c514  e8
    inx ; $c515  e8
    stx $c81a ; $c516  8e 1a c8
    lda #$01 ; $c519  a9 01
    bne l_c544 ; $c51b  d0 27
l_c51d:
    cmp $c819 ; $c51d  cd 19 c8
    beq l_c544 ; $c520  f0 22
    ldx $c819 ; $c522  ae 19 c8
    beq l_c544 ; $c525  f0 1d
    pha ; $c527  48
    ldx $c82b ; $c528  ae 2b c8
    lda $c819 ; $c52b  ad 19 c8
    sta $c82c,x ; $c52e  9d 2c c8
    lda $c80e ; $c531  ad 0e c8
    sta $c82d,x ; $c534  9d 2d c8
    lda $c80f ; $c537  ad 0f c8
    sta $c82e,x ; $c53a  9d 2e c8
    inx ; $c53d  e8
    inx ; $c53e  e8
    inx ; $c53f  e8
    stx $c82b ; $c540  8e 2b c8
    pla ; $c543  68
l_c544:
    sta $c819 ; $c544  8d 19 c8
    sta $ba ; $c547  85 ba
    jsr l_c55e ; $c549  20 5e c5
l_c54c:
    lda $ba ; $c54c  a5 ba
    beq l_c557 ; $c54e  f0 07
    cmp #$01 ; $c550  c9 01
    beq l_c557 ; $c552  f0 03
    jsr l_c5a3 ; $c554  20 a3 c5
l_c557:
    ldx $c83c ; $c557  ae 3c c8
    txs ; $c55a  9a
    plp ; $c55b  28
    clc ; $c55c  18
    rts ; $c55d  60
l_c55e:
    lda #$00 ; $c55e  a9 00

; SID voice control (I/O only when $01 exposes it)
    sta $d404 ; $c560  8d 04 d4

; SID voice 2 control (I/O only when $01 exposes it)
    sta $d40b ; $c563  8d 0b d4

; SID voice 3 control (I/O only when $01 exposes it)
    sta $d412 ; $c566  8d 12 d4
    lda $ba ; $c569  a5 ba
    asl ; $c56b  0a
    tax ; $c56c  aa
    beq l_c573 ; $c56d  f0 04
    cmp #$02 ; $c56f  c9 02
    bne l_c574 ; $c571  d0 01
l_c573:
    rts ; $c573  60
l_c574:
    lda $c579,x ; $c574  bd 79 c5
    sta $c80e ; $c577  8d 0e c8
l_c57a:
    lda l_c57a,x ; $c57a  bd 7a c5
    sta $c80f ; $c57d  8d 0f c8
    rts ; $c580  60
    !byte $59,$c8,$0d,$c9,$b1,$c9,$33,$ca,$c2,$ca,$49,$cb,$c8,$cb,$6c,$cc ; $c581 retained data / unresolved code
    !byte $d4,$c8,$d4,$c8,$d4,$c8,$d4,$c8,$d4,$c8,$d4,$c8,$d4,$c8,$d4,$c8 ; $c591 retained data / unresolved code
    !byte $2e,$ca ; $c5a1 retained data / unresolved code
l_c5a3:
    dec $bf ; $c5a3  c6 bf
    lda $bf ; $c5a5  a5 bf
    cmp #$03 ; $c5a7  c9 03
    bne l_c5cd ; $c5a9  d0 22
    lda $bd ; $c5ab  a5 bd
    asl ; $c5ad  0a
    asl ; $c5ae  0a
    asl ; $c5af  0a
    tax ; $c5b0  aa
    lda $c79f,x ; $c5b1  bd 9f c7
    and #$fe ; $c5b4  29 fe
    tax ; $c5b6  aa
    lda $c74a ; $c5b7  ad 4a c7
    ora $c74b ; $c5ba  0d 4b c7
    beq l_c5c2 ; $c5bd  f0 03

; SID voice control (I/O only when $01 exposes it)
    stx $d404 ; $c5bf  8e 04 d4
l_c5c2:
    lda $c74c ; $c5c2  ad 4c c7
    ora $c74d ; $c5c5  0d 4d c7
    beq l_c5cd ; $c5c8  f0 03

; SID voice 2 control (I/O only when $01 exposes it)
    stx $d40b ; $c5ca  8e 0b d4
l_c5cd:
    lda $bf ; $c5cd  a5 bf
    bmi l_c5d4 ; $c5cf  30 03
    beq l_c5d4 ; $c5d1  f0 01
    rts ; $c5d3  60
l_c5d4:
    jsr l_c80d ; $c5d4  20 0d c8
    cmp #$00 ; $c5d7  c9 00
    bne l_c60a ; $c5d9  d0 2f
    ldx $c82b ; $c5db  ae 2b c8
    beq l_c605 ; $c5de  f0 25
    dex ; $c5e0  ca
    dex ; $c5e1  ca
    dex ; $c5e2  ca
    stx $c82b ; $c5e3  8e 2b c8
    lda $c82c,x ; $c5e6  bd 2c c8
    sta $ba ; $c5e9  85 ba
    sta $c819 ; $c5eb  8d 19 c8
    jsr l_c55e ; $c5ee  20 5e c5
    ldx $c82b ; $c5f1  ae 2b c8
    lda $c82d,x ; $c5f4  bd 2d c8
    sta $c80e ; $c5f7  8d 0e c8
    lda $c82e,x ; $c5fa  bd 2e c8
    sta $c80f ; $c5fd  8d 0f c8
    pla ; $c600  68
    pla ; $c601  68
    jmp l_c54c ; $c602  4c 4c c5
l_c605:
    lda #$80 ; $c605  a9 80
    sta $ba ; $c607  85 ba
    rts ; $c609  60
l_c60a:
    cmp #$01 ; $c60a  c9 01
    bne l_c61e ; $c60c  d0 10
    ldx #$00 ; $c60e  a2 00
l_c610:
    jsr l_c80d ; $c610  20 0d c8
    sta $c83e,x ; $c613  9d 3e c8
    inx ; $c616  e8
    cpx #$0b ; $c617  e0 0b
    bcc l_c610 ; $c619  90 f5
    jmp l_c5d4 ; $c61b  4c d4 c5
l_c61e:
    cmp #$02 ; $c61e  c9 02
    bne l_c632 ; $c620  d0 10
    jsr l_c80d ; $c622  20 0d c8
    tax ; $c625  aa
    jsr l_c80d ; $c626  20 0d c8
    sta $c80f ; $c629  8d 0f c8
    stx $c80e ; $c62c  8e 0e c8
    jmp l_c5d4 ; $c62f  4c d4 c5
l_c632:
    cmp #$03 ; $c632  c9 03
    bne l_c65d ; $c634  d0 27
    jsr l_c80d ; $c636  20 0d c8
    pha ; $c639  48
    jsr l_c80d ; $c63a  20 0d c8
    pha ; $c63d  48
    ldx $c82b ; $c63e  ae 2b c8
    lda $c80f ; $c641  ad 0f c8
    sta $c82c,x ; $c644  9d 2c c8
    lda $c80e ; $c647  ad 0e c8
    sta $c82d,x ; $c64a  9d 2d c8
    inx ; $c64d  e8
    inx ; $c64e  e8
    stx $c82b ; $c64f  8e 2b c8
    pla ; $c652  68
    sta $c80f ; $c653  8d 0f c8
    pla ; $c656  68
    sta $c80e ; $c657  8d 0e c8
    jmp l_c5d4 ; $c65a  4c d4 c5
l_c65d:
    cmp #$04 ; $c65d  c9 04
    bne l_c678 ; $c65f  d0 17
    ldx $c82b ; $c661  ae 2b c8
    dex ; $c664  ca
    dex ; $c665  ca
    stx $c82b ; $c666  8e 2b c8
    lda $c82d,x ; $c669  bd 2d c8
    sta $c80e ; $c66c  8d 0e c8
    lda $c82c,x ; $c66f  bd 2c c8
    sta $c80f ; $c672  8d 0f c8
    jmp l_c5d4 ; $c675  4c d4 c5
l_c678:
    cmp #$05 ; $c678  c9 05
    bne l_c69c ; $c67a  d0 20
    jsr l_c80d ; $c67c  20 0d c8
    pha ; $c67f  48
    ldx $c82b ; $c680  ae 2b c8
    lda $c80f ; $c683  ad 0f c8
    sta $c82c,x ; $c686  9d 2c c8
    lda $c80e ; $c689  ad 0e c8
    sta $c82d,x ; $c68c  9d 2d c8
    pla ; $c68f  68
    sta $c82e,x ; $c690  9d 2e c8
    inx ; $c693  e8
    inx ; $c694  e8
    inx ; $c695  e8
    stx $c82b ; $c696  8e 2b c8
    jmp l_c5d4 ; $c699  4c d4 c5
l_c69c:
    cmp #$06 ; $c69c  c9 06
    bne l_c6c0 ; $c69e  d0 20
    ldx $c82b ; $c6a0  ae 2b c8
    dex ; $c6a3  ca
    dex ; $c6a4  ca
    dex ; $c6a5  ca
    dec $c82e,x ; $c6a6  de 2e c8
    beq l_c6ba ; $c6a9  f0 0f
    lda $c82c,x ; $c6ab  bd 2c c8
    sta $c80f ; $c6ae  8d 0f c8
    lda $c82d,x ; $c6b1  bd 2d c8
    sta $c80e ; $c6b4  8d 0e c8
    jmp l_c5d4 ; $c6b7  4c d4 c5
l_c6ba:
    stx $c82b ; $c6ba  8e 2b c8
    jmp l_c5d4 ; $c6bd  4c d4 c5
l_c6c0:
    cmp #$07 ; $c6c0  c9 07
    bne l_c6d8 ; $c6c2  d0 14
    jsr l_c80d ; $c6c4  20 0d c8
    pha ; $c6c7  48
    lsr ; $c6c8  4a
    lsr ; $c6c9  4a
    lsr ; $c6ca  4a
    lsr ; $c6cb  4a
    sta $c849 ; $c6cc  8d 49 c8
    pla ; $c6cf  68
    and #$0f ; $c6d0  29 0f
    sta $c84a ; $c6d2  8d 4a c8
    jmp l_c5d4 ; $c6d5  4c d4 c5
l_c6d8:
    cmp #$13 ; $c6d8  c9 13
    bcs l_c6ee ; $c6da  b0 12
    sec ; $c6dc  38
    sbc #$08 ; $c6dd  e9 08
    sta $c83d ; $c6df  8d 3d c8
    lda #$0a ; $c6e2  a9 0a
    sec ; $c6e4  38
    sbc $c83d ; $c6e5  ed 3d c8
    sta $c83d ; $c6e8  8d 3d c8
l_c6eb:
    jmp l_c5d4 ; $c6eb  4c d4 c5
l_c6ee:
    cmp #$13 ; $c6ee  c9 13
    bne l_c6ff ; $c6f0  d0 0d
    ldx #$0d ; $c6f2  a2 0d
l_c6f4:
    lda $c83d,x ; $c6f4  bd 3d c8
    sta $c84b,x ; $c6f7  9d 4b c8
    dex ; $c6fa  ca
    bpl l_c6f4 ; $c6fb  10 f7
    bmi l_c6eb ; $c6fd  30 ec
l_c6ff:
    cmp #$14 ; $c6ff  c9 14
    bne l_c710 ; $c701  d0 0d
    ldx #$0d ; $c703  a2 0d
l_c705:
    lda $c84b,x ; $c705  bd 4b c8
    sta $c83d,x ; $c708  9d 3d c8
    dex ; $c70b  ca
    bpl l_c705 ; $c70c  10 f7
    bmi l_c6eb ; $c70e  30 db
l_c710:
    pha ; $c710  48
    and #$3f ; $c711  29 3f
    jsr l_c7bd ; $c713  20 bd c7
    stx $c74a ; $c716  8e 4a c7
    sty $c74b ; $c719  8c 4b c7
    pla ; $c71c  68
    and #$c0 ; $c71d  29 c0
    eor #$40 ; $c71f  49 40
    beq l_c726 ; $c721  f0 03
    jsr l_c80d ; $c723  20 0d c8
l_c726:
    jsr l_c7bd ; $c726  20 bd c7
    stx $c74c ; $c729  8e 4c c7
    sty $c74d ; $c72c  8c 4d c7
    ldx $c83d ; $c72f  ae 3d c8
    lda $c83e,x ; $c732  bd 3e c8
    lsr ; $c735  4a
    clc ; $c736  18
    adc $c83e,x ; $c737  7d 3e c8
    sta $bf ; $c73a  85 bf
    ldx #$00 ; $c73c  a2 00
    ldy #$00 ; $c73e  a0 00
    jsr l_c74e ; $c740  20 4e c7
    ldx #$02 ; $c743  a2 02
    ldy #$07 ; $c745  a0 07
    jmp l_c74e ; $c747  4c 4e c7
    !byte $00,$00,$00,$00 ; $c74a retained data / unresolved code
l_c74e:
    lda $c74a,x ; $c74e  bd 4a c7
    ora $c74b,x ; $c751  1d 4b c7
    bne l_c75a ; $c754  d0 04

; SID voice control (I/O only when $01 exposes it)
    sta $d404,y ; $c756  99 04 d4
    rts ; $c759  60
l_c75a:
    lda $c74a,x ; $c75a  bd 4a c7

; SID voice frequency low (+Y voice offset) (I/O only when $01 exposes it)
    sta $d400,y ; $c75d  99 00 d4
    lda $c74b,x ; $c760  bd 4b c7

; SID voice frequency high (I/O only when $01 exposes it)
    sta $d401,y ; $c763  99 01 d4
    lda $bd ; $c766  a5 bd
    asl ; $c768  0a
    asl ; $c769  0a
    asl ; $c76a  0a
    tax ; $c76b  aa
    lda $c7a2,x ; $c76c  bd a2 c7

; SID filter cutoff low (I/O only when $01 exposes it)
    sta $d415 ; $c76f  8d 15 d4
    lda $c7a3,x ; $c772  bd a3 c7

; SID filter cutoff high (I/O only when $01 exposes it)
    sta $d416 ; $c775  8d 16 d4
    lda $c7a4,x ; $c778  bd a4 c7

; SID filter routing/resonance (I/O only when $01 exposes it)
    sta $d417 ; $c77b  8d 17 d4
    lda $c7a0,x ; $c77e  bd a0 c7

; SID pulse width low (I/O only when $01 exposes it)
    sta $d402,y ; $c781  99 02 d4
    lda $c7a1,x ; $c784  bd a1 c7

; SID pulse width high (I/O only when $01 exposes it)
    sta $d403,y ; $c787  99 03 d4
    lda $c79d,x ; $c78a  bd 9d c7

; SID attack/decay (I/O only when $01 exposes it)
    sta $d405,y ; $c78d  99 05 d4
    lda $c79e,x ; $c790  bd 9e c7

; SID sustain/release (I/O only when $01 exposes it)
    sta $d406,y ; $c793  99 06 d4
    lda $c79f,x ; $c796  bd 9f c7

; SID voice control (I/O only when $01 exposes it)
    sta $d404,y ; $c799  99 04 d4
    rts ; $c79c  60
    !byte $79,$74,$11,$00,$00,$00,$00,$00,$09,$00,$11,$00,$00,$00,$00,$00 ; $c79d retained data / unresolved code
    !byte $1f,$00,$21,$00,$00,$00,$00,$00,$08,$00,$81,$00,$00,$00,$00,$b0 ; $c7ad retained data / unresolved code
l_c7bd:
    cmp #$00 ; $c7bd  c9 00
    beq l_c7ee ; $c7bf  f0 2d
    clc ; $c7c1  18
    adc #$18 ; $c7c2  69 18
    ldy #$07 ; $c7c4  a0 07
l_c7c6:
    cmp #$0c ; $c7c6  c9 0c
    bcc l_c7cf ; $c7c8  90 05
    dey ; $c7ca  88
    sbc #$0c ; $c7cb  e9 0c
    bne l_c7c6 ; $c7cd  d0 f7
l_c7cf:
    sty $c7f4 ; $c7cf  8c f4 c7
    asl ; $c7d2  0a
    tay ; $c7d3  a8
    lda $c7f5,y ; $c7d4  b9 f5 c7
    sta $c7f3 ; $c7d7  8d f3 c7
    lda $c7f6,y ; $c7da  b9 f6 c7
l_c7dd:
    dec $c7f4 ; $c7dd  ce f4 c7
    bmi l_c7e9 ; $c7e0  30 07
    lsr ; $c7e2  4a
    ror $c7f3 ; $c7e3  6e f3 c7
    jmp l_c7dd ; $c7e6  4c dd c7
l_c7e9:
    tay ; $c7e9  a8
    ldx $c7f3 ; $c7ea  ae f3 c7
    rts ; $c7ed  60
l_c7ee:
    ldx #$00 ; $c7ee  a2 00
    ldy #$00 ; $c7f0  a0 00
    rts ; $c7f2  60
    !byte $00,$00,$49,$86,$18,$8e,$8b,$96,$7e,$9f,$fa,$a8,$06,$b3,$ac,$bd ; $c7f3 retained data / unresolved code
    !byte $f3,$c8,$e6,$d4,$8f,$e1,$f8,$ee,$2e,$fd ; $c803 retained data / unresolved code

; RAM IRQ vector high / unpatched operand placeholder
l_c80d:
    lda $ffff ; $c80d  ad ff ff
    inc $c80e ; $c810  ee 0e c8
    bne l_c818 ; $c813  d0 03
    inc $c80f ; $c815  ee 0f c8
l_c818:
    rts ; $c818  60
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c819 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c829 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c839 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $c849 retained data / unresolved code
    !byte $03,$f1,$c8,$07,$13,$05,$20,$0e,$a1,$15,$0c,$a6,$1a,$0e,$66,$0c ; $c859 retained data / unresolved code
    !byte $a6,$1a,$0e,$a8,$15,$a9,$1a,$0c,$66,$a6,$1a,$0e,$a8,$15,$a9,$1a ; $c869 retained data / unresolved code
    !byte $0c,$66,$a8,$1a,$0e,$a5,$15,$0a,$a6,$0e,$0c,$a6,$1a,$0e,$66,$66 ; $c879 retained data / unresolved code
    !byte $a9,$18,$ab,$1d,$0c,$ad,$11,$0e,$ad,$1d,$ad,$1d,$ad,$1d,$ad,$1a ; $c889 retained data / unresolved code
    !byte $0c,$ab,$18,$0e,$ab,$18,$b0,$1a,$af,$1c,$af,$1d,$0a,$91,$2d,$0e ; $c899 retained data / unresolved code
    !byte $6d,$6f,$0c,$b0,$1d,$0e,$70,$70,$af,$21,$ad,$1d,$0c,$ab,$18,$0e ; $c8a9 retained data / unresolved code
    !byte $6b,$6b,$6d,$6f,$0c,$b0,$1d,$0e,$70,$b0,$1d,$af,$1c,$ad,$1a,$0c ; $c8b9 retained data / unresolved code
    !byte $ab,$18,$0e,$6b,$0b,$6b,$03,$df,$c8,$06,$00,$13,$03,$f1,$c8,$07 ; $c8c9 retained data / unresolved code
    !byte $13,$03,$df,$c8,$14,$00,$0b,$a9,$1a,$ab,$1c,$ad,$1d,$0e,$ad,$1d ; $c8d9 retained data / unresolved code
    !byte $a9,$1c,$a9,$1a,$0a,$ab,$18,$04,$01,$01,$02,$03,$05,$07,$0b,$0f ; $c8e9 retained data / unresolved code
    !byte $17,$1f,$2f,$3e,$04,$01,$01,$02,$03,$05,$07,$0a,$0e,$15,$1c,$2a ; $c8f9 retained data / unresolved code
    !byte $38,$07,$11,$04,$03,$fe,$c8,$05,$1a,$0c,$9a,$09,$0e,$8e,$21,$91 ; $c909 retained data / unresolved code
    !byte $1f,$0c,$8e,$1d,$98,$0c,$0e,$5f,$5c,$0c,$a4,$13,$8c,$1f,$0e,$a4 ; $c919 retained data / unresolved code
    !byte $18,$a6,$16,$a4,$15,$9d,$11,$0a,$90,$1f,$0e,$a4,$0c,$a2,$0e,$a1 ; $c929 retained data / unresolved code
    !byte $10,$9f,$13,$0c,$9d,$11,$0e,$a1,$05,$9d,$07,$9f,$09,$9d,$0a,$0c ; $c939 retained data / unresolved code
    !byte $8c,$1c,$0e,$9a,$0a,$9c,$0c,$9d,$11,$a6,$16,$a2,$0e,$a4,$15,$0c ; $c949 retained data / unresolved code
    !byte $91,$1d,$9c,$0c,$0a,$85,$1d,$0e,$91,$29,$90,$28,$8e,$26,$95,$21 ; $c959 retained data / unresolved code
    !byte $8e,$21,$61,$4e,$55,$4e,$66,$8d,$25,$95,$21,$8e,$26,$61,$90,$28 ; $c969 retained data / unresolved code
    !byte $95,$21,$49,$61,$8c,$2d,$90,$2b,$91,$29,$0c,$85,$24,$0e,$91,$2d ; $c979 retained data / unresolved code
    !byte $90,$2b,$8e,$29,$0c,$8c,$28,$0e,$93,$26,$91,$24,$0c,$8a,$26,$0e ; $c989 retained data / unresolved code
    !byte $93,$24,$91,$22,$0c,$89,$24,$0e,$96,$1f,$95,$1c,$90,$1f,$91,$21 ; $c999 retained data / unresolved code
    !byte $0c,$91,$21,$0a,$89,$1a,$06,$00,$03,$fe,$c8,$05,$22,$0e,$a1,$0e ; $c9a9 retained data / unresolved code
    !byte $9d,$09,$9a,$0e,$9c,$10,$0c,$9d,$11,$0e,$9f,$10,$a1,$0e,$9f,$0c ; $c9b9 retained data / unresolved code
    !byte $9d,$07,$9c,$0c,$9a,$0e,$0c,$9c,$10,$98,$0c,$0e,$96,$0e,$9a,$0c ; $c9c9 retained data / unresolved code
    !byte $9d,$0a,$9c,$05,$0c,$9d,$0e,$9a,$0a,$0e,$99,$09,$95,$04,$95,$05 ; $c9d9 retained data / unresolved code
    !byte $96,$02,$0c,$95,$04,$0e,$9d,$09,$9f,$0d,$a1,$0e,$a4,$11,$a1,$0e ; $c9e9 retained data / unresolved code
    !byte $9f,$09,$0c,$a1,$02,$0e,$a8,$10,$a9,$11,$ab,$10,$a8,$05,$a8,$07 ; $c9f9 retained data / unresolved code
    !byte $a6,$0a,$0c,$a4,$0c,$9f,$00,$0e,$a6,$0a,$a4,$05,$a2,$07,$9d,$09 ; $ca09 retained data / unresolved code
    !byte $0c,$a2,$0a,$0e,$a6,$0e,$a8,$10,$a9,$11,$a6,$0e,$a4,$0c,$a9,$0a ; $ca19 retained data / unresolved code
    !byte $0a,$a9,$11,$06,$00,$05,$01,$02,$35,$ca,$05,$18,$03,$fe,$c8,$0e ; $ca29 retained data / unresolved code
    !byte $4e,$50,$0c,$91,$05,$0e,$5d,$5f,$0c,$a1,$15,$0e,$49,$4a,$0c,$8c ; $ca39 retained data / unresolved code
    !byte $00,$0e,$5c,$5d,$0c,$5f,$9c,$13,$9a,$0e,$0e,$9a,$11,$9c,$10,$0c ; $ca49 retained data / unresolved code
    !byte $9d,$0e,$0e,$9d,$10,$9f,$11,$0c,$a4,$0c,$0e,$5c,$5d,$5f,$5d,$5c ; $ca59 retained data / unresolved code
    !byte $5f,$0c,$a1,$0e,$0e,$66,$68,$0c,$a9,$1d,$0e,$49,$4a,$0c,$8c,$00 ; $ca69 retained data / unresolved code
    !byte $0e,$68,$66,$0c,$a4,$18,$0e,$68,$64,$0c,$a2,$1a,$0e,$47,$49,$0c ; $ca79 retained data / unresolved code
    !byte $96,$0a,$0e,$64,$66,$0c,$a8,$1f,$0e,$a8,$1f,$a6,$1d,$a4,$1c,$9f ; $ca89 retained data / unresolved code
    !byte $18,$a4,$1c,$a8,$1f,$0c,$a9,$26,$0e,$5a,$5c,$0c,$9d,$11,$0e,$49 ; $ca99 retained data / unresolved code
    !byte $4a,$0c,$8c,$00,$0e,$5c,$5d,$5f,$5d,$5c,$5f,$0c,$a1,$1a,$9d,$15 ; $caa9 retained data / unresolved code
    !byte $9a,$11,$96,$07,$0a,$98,$0c,$06,$00,$03,$fe,$c8,$05,$1a,$0c,$a6 ; $cab9 retained data / unresolved code
    !byte $1a,$a6,$15,$0e,$a6,$0e,$a8,$0e,$a9,$11,$ab,$11,$a4,$10,$9f,$10 ; $cac9 retained data / unresolved code
    !byte $a6,$11,$9f,$11,$0c,$a8,$13,$a4,$10,$0e,$a2,$0e,$a4,$0e,$a6,$11 ; $cad9 retained data / unresolved code
    !byte $a8,$11,$a6,$16,$a4,$16,$a2,$11,$9f,$11,$a1,$15,$9c,$15,$9f,$10 ; $cae9 retained data / unresolved code
    !byte $9c,$10,$0a,$a1,$09,$0e,$a9,$0e,$a8,$0e,$a6,$11,$a5,$11,$a6,$10 ; $caf9 retained data / unresolved code
    !byte $a8,$10,$a9,$0e,$ab,$0e,$a8,$0c,$a6,$0c,$a4,$0e,$9f,$0e,$a4,$10 ; $cb09 retained data / unresolved code
    !byte $a6,$10,$a8,$13,$a4,$13,$56,$58,$5a,$5c,$5d,$5f,$61,$62,$4a,$4c ; $cb19 retained data / unresolved code
    !byte $4e,$50,$51,$53,$55,$56,$99,$09,$9c,$0a,$9d,$0d,$a2,$0e,$a1,$10 ; $cb29 retained data / unresolved code
    !byte $a5,$13,$a9,$22,$a8,$21,$0a,$a6,$1d,$0c,$a2,$1a,$a1,$19,$06,$00 ; $cb39 retained data / unresolved code
    !byte $03,$fe,$c8,$05,$20,$0c,$a8,$24,$0e,$5f,$5c,$5f,$61,$0c,$a6,$22 ; $cb49 retained data / unresolved code
    !byte $0e,$5d,$5a,$62,$5d,$0c,$a1,$1d,$0e,$a1,$1d,$9c,$18,$9a,$16,$9d ; $cb59 retained data / unresolved code
    !byte $1a,$0c,$9c,$18,$0e,$9c,$18,$9a,$16,$98,$15,$95,$11,$0c,$9d,$16 ; $cb69 retained data / unresolved code
    !byte $0e,$9d,$16,$a2,$1f,$a1,$1d,$9f,$1c,$98,$15,$a2,$1f,$a4,$21,$a2 ; $cb79 retained data / unresolved code
    !byte $1f,$a4,$21,$a6,$22,$9a,$16,$a6,$22,$a4,$1d,$a6,$22,$a2,$1d,$a6 ; $cb89 retained data / unresolved code
    !byte $22,$a8,$24,$9c,$16,$a2,$1d,$a8,$24,$9c,$18,$a4,$21,$0c,$a6,$22 ; $cb99 retained data / unresolved code
    !byte $a2,$1d,$9d,$1a,$98,$11,$a1,$1d,$a4,$1c,$a2,$1a,$0e,$9c,$18,$9f ; $cba9 retained data / unresolved code
    !byte $1c,$9d,$1a,$a4,$21,$0a,$a2,$1a,$0e,$a2,$1d,$a6,$22,$06,$00,$03 ; $cbb9 retained data / unresolved code
    !byte $fe,$c8,$05,$1a,$0e,$9f,$13,$5a,$5a,$5a,$5a,$5a,$5a,$5a,$9e,$15 ; $cbc9 retained data / unresolved code
    !byte $5a,$5a,$5a,$5a,$5a,$5a,$5a,$9f,$13,$5a,$a1,$15,$5a,$a2,$16,$5a ; $cbd9 retained data / unresolved code
    !byte $9f,$13,$5a,$a1,$1e,$5a,$5a,$5b,$5a,$58,$56,$5a,$93,$0e,$5a,$55 ; $cbe9 retained data / unresolved code
    !byte $5a,$92,$0e,$5a,$55,$5a,$93,$0e,$5a,$96,$13,$98,$15,$5a,$5e,$5f ; $cbf9 retained data / unresolved code
    !byte $61,$a2,$1f,$5a,$a2,$1f,$5a,$a4,$21,$5a,$a4,$21,$5a,$a6,$22,$9f ; $cc09 retained data / unresolved code
    !byte $1a,$9f,$1a,$a1,$1a,$a2,$1a,$95,$11,$9a,$16,$a1,$1d,$9f,$1b,$9f ; $cc19 retained data / unresolved code
    !byte $1b,$9f,$1b,$9d,$1a,$9b,$18,$61,$5f,$5b,$9d,$1a,$a2,$1d,$9d,$1a ; $cc29 retained data / unresolved code
    !byte $9b,$18,$9a,$16,$58,$56,$58,$9e,$1a,$9e,$1a,$9e,$1a,$9e,$1a,$9e ; $cc39 retained data / unresolved code
    !byte $1a,$10,$a6,$22,$a8,$24,$a6,$22,$a4,$21,$a2,$1f,$a1,$1d,$9f,$1b ; $cc49 retained data / unresolved code
    !byte $0e,$9f,$1a,$93,$0e,$9f,$1a,$93,$0e,$9f,$1a,$93,$0e,$9f,$1a,$9f ; $cc59 retained data / unresolved code
    !byte $1a,$06,$00,$03,$fe,$c8,$05,$18,$0c,$54,$0e,$94,$0d,$99,$0f,$9c ; $cc69 retained data / unresolved code
    !byte $10,$a0,$14,$0c,$59,$0e,$a0,$14,$9c,$12,$a0,$14,$59,$0c,$9c,$15 ; $cc79 retained data / unresolved code
    !byte $a1,$12,$9b,$12,$9c,$14,$48,$48,$94,$0d,$0e,$9c,$14,$9b,$12,$99 ; $cc89 retained data / unresolved code
    !byte $10,$97,$0f,$0c,$95,$0d,$99,$12,$9c,$15,$9c,$19,$0e,$9c,$19,$9e ; $cc99 retained data / unresolved code
    !byte $18,$9e,$16,$9b,$18,$0a,$9c,$19,$0e,$48,$48,$0c,$90,$0d,$94,$10 ; $cca9 retained data / unresolved code
    !byte $99,$14,$0e,$a0,$14,$9e,$14,$9c,$14,$9e,$14,$0c,$a0,$14,$a1,$17 ; $ccb9 retained data / unresolved code
    !byte $9c,$17,$9e,$15,$0a,$9b,$08,$0e,$a0,$14,$a4,$14,$0c,$a5,$0d,$0e ; $ccc9 retained data / unresolved code
    !byte $a0,$0d,$a0,$0f,$9e,$10,$9e,$12,$0c,$9c,$14,$a0,$0d,$a5,$14,$a8 ; $ccd9 retained data / unresolved code
    !byte $08,$0e,$a8,$0f,$a7,$0f,$a5,$14,$a4,$14,$09,$a5,$11,$06,$00 ; $cce9 retained data / unresolved code
