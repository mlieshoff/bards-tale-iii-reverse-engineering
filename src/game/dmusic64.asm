; DMUSIC64 -- static code/data classification; unresolved bytes retained.
!cpu 6510
* = $e000

; SID player plus music data, not a sampled sound file.
; Five JMP vectors lead into executable player code.
; MUSIC64 is copied from $4800 to $c480 by startup; DMUSIC64 runs at $e000.
music_vector_0:
    jmp request_music_command_zero ; $e000  4c 10 e0
music_vector_1:
    jmp request_music_command_zero ; $e003  4c 10 e0
music_vector_2:
    jmp music_noop ; $e006  4c 0f e0
music_vector_3:
    jmp music_noop ; $e009  4c 0f e0
music_tick_vector:
    jmp process_music_frame ; $e00c  4c 17 e0
music_noop:
    rts ; $e00f  60

; Store $80 in command mailbox $ba: command zero with request bit set.
request_music_command_zero:
    lda #$80 ; $e010  a9 80
    sta $ba ; $e012  85 ba
    jmp process_music_frame ; $e014  4c 17 e0

; Preserve interrupt flags and stack state; apply volume from $33,
; consume command mailbox $ba, advance player state, and update SID registers.
; Engine raster IRQ calls vector +12 once per acknowledged raster interrupt.
process_music_frame:
    php ; $e017  08
    sei ; $e018  78
    tsx ; $e019  ba
    stx $e3bc ; $e01a  8e bc e3
    lda #$0f ; $e01d  a9 0f
    bit $33 ; $e01f  24 33
    bmi l_e025 ; $e021  30 02
    lda #$00 ; $e023  a9 00

; SID volume/filter mode (I/O only when $01 exposes it)
l_e025:
    sta $d418 ; $e025  8d 18 d4
    lda $ba ; $e028  a5 ba
    bmi l_e02f ; $e02a  30 03
    jmp l_e0cc ; $e02c  4c cc e0
l_e02f:
    and #$7f ; $e02f  29 7f
    sta $ba ; $e031  85 ba
    bne l_e040 ; $e033  d0 0b
l_e035:
    lda #$00 ; $e035  a9 00
    sta $e3ab ; $e037  8d ab e3
    sta $e39a ; $e03a  8d 9a e3
    jmp l_e0c4 ; $e03d  4c c4 e0
l_e040:
    cmp #$02 ; $e040  c9 02
    bne l_e073 ; $e042  d0 2f
    ldx $e39a ; $e044  ae 9a e3
    beq l_e035 ; $e047  f0 ec
    dex ; $e049  ca
    dex ; $e04a  ca
    dex ; $e04b  ca
    dex ; $e04c  ca
    stx $e39a ; $e04d  8e 9a e3
    lda $e39b,x ; $e050  bd 9b e3
    sta $e399 ; $e053  8d 99 e3
    sta $ba ; $e056  85 ba
    jsr l_e0de ; $e058  20 de e0
    ldx $e39a ; $e05b  ae 9a e3
    lda $e39c,x ; $e05e  bd 9c e3
    sta $e38e ; $e061  8d 8e e3
    lda $e39d,x ; $e064  bd 9d e3
    sta $e38f ; $e067  8d 8f e3
    lda $e39e,x ; $e06a  bd 9e e3
    sta $e3ab ; $e06d  8d ab e3
    jmp l_e0cc ; $e070  4c cc e0
l_e073:
    cmp #$01 ; $e073  c9 01
    bne l_e09d ; $e075  d0 26
    ldx $e39a ; $e077  ae 9a e3
    lda $e399 ; $e07a  ad 99 e3
    sta $e39b,x ; $e07d  9d 9b e3
    lda $e38e ; $e080  ad 8e e3
    sta $e39c,x ; $e083  9d 9c e3
    lda $e38f ; $e086  ad 8f e3
    sta $e39d,x ; $e089  9d 9d e3
    lda $e3ab ; $e08c  ad ab e3
    sta $e39e,x ; $e08f  9d 9e e3
    inx ; $e092  e8
    inx ; $e093  e8
    inx ; $e094  e8
    inx ; $e095  e8
    stx $e39a ; $e096  8e 9a e3
    lda #$01 ; $e099  a9 01
    bne l_e0c4 ; $e09b  d0 27
l_e09d:
    cmp $e399 ; $e09d  cd 99 e3
    beq l_e0c4 ; $e0a0  f0 22
    ldx $e399 ; $e0a2  ae 99 e3
    beq l_e0c4 ; $e0a5  f0 1d
    pha ; $e0a7  48
    ldx $e3ab ; $e0a8  ae ab e3
    lda $e399 ; $e0ab  ad 99 e3
    sta $e3ac,x ; $e0ae  9d ac e3
    lda $e38e ; $e0b1  ad 8e e3
    sta $e3ad,x ; $e0b4  9d ad e3
    lda $e38f ; $e0b7  ad 8f e3
    sta $e3ae,x ; $e0ba  9d ae e3
    inx ; $e0bd  e8
    inx ; $e0be  e8
    inx ; $e0bf  e8
    stx $e3ab ; $e0c0  8e ab e3
    pla ; $e0c3  68
l_e0c4:
    sta $e399 ; $e0c4  8d 99 e3
    sta $ba ; $e0c7  85 ba
    jsr l_e0de ; $e0c9  20 de e0
l_e0cc:
    lda $ba ; $e0cc  a5 ba
    beq l_e0d7 ; $e0ce  f0 07
    cmp #$01 ; $e0d0  c9 01
    beq l_e0d7 ; $e0d2  f0 03
    jsr l_e123 ; $e0d4  20 23 e1
l_e0d7:
    ldx $e3bc ; $e0d7  ae bc e3
    txs ; $e0da  9a
    plp ; $e0db  28
    clc ; $e0dc  18
    rts ; $e0dd  60
l_e0de:
    lda #$00 ; $e0de  a9 00

; SID voice control (I/O only when $01 exposes it)
    sta $d404 ; $e0e0  8d 04 d4

; SID voice 2 control (I/O only when $01 exposes it)
    sta $d40b ; $e0e3  8d 0b d4

; SID voice 3 control (I/O only when $01 exposes it)
    sta $d412 ; $e0e6  8d 12 d4
    lda $ba ; $e0e9  a5 ba
    asl ; $e0eb  0a
    tax ; $e0ec  aa
    beq l_e0f3 ; $e0ed  f0 04
    cmp #$02 ; $e0ef  c9 02
    bne l_e0f4 ; $e0f1  d0 01
l_e0f3:
    rts ; $e0f3  60
l_e0f4:
    lda $e0f9,x ; $e0f4  bd f9 e0
    sta $e38e ; $e0f7  8d 8e e3
l_e0fa:
    lda l_e0fa,x ; $e0fa  bd fa e0
    sta $e38f ; $e0fd  8d 8f e3
    rts ; $e100  60
    !byte $d9,$e3,$8d,$e4,$31,$e5,$b3,$e5,$42,$e6,$c9,$e6,$48,$e7,$ec,$e7 ; $e101 retained data / unresolved code
    !byte $54,$e4,$54,$e4,$54,$e4,$54,$e4,$54,$e4,$54,$e4,$54,$e4,$54,$e4 ; $e111 retained data / unresolved code
    !byte $ae,$e5 ; $e121 retained data / unresolved code
l_e123:
    dec $bf ; $e123  c6 bf
    lda $bf ; $e125  a5 bf
    cmp #$03 ; $e127  c9 03
    bne l_e14d ; $e129  d0 22
    lda $bd ; $e12b  a5 bd
    asl ; $e12d  0a
    asl ; $e12e  0a
    asl ; $e12f  0a
    tax ; $e130  aa
    lda $e31f,x ; $e131  bd 1f e3
    and #$fe ; $e134  29 fe
    tax ; $e136  aa
    lda $e2ca ; $e137  ad ca e2
    ora $e2cb ; $e13a  0d cb e2
    beq l_e142 ; $e13d  f0 03

; SID voice control (I/O only when $01 exposes it)
    stx $d404 ; $e13f  8e 04 d4
l_e142:
    lda $e2cc ; $e142  ad cc e2
    ora $e2cd ; $e145  0d cd e2
    beq l_e14d ; $e148  f0 03

; SID voice 2 control (I/O only when $01 exposes it)
    stx $d40b ; $e14a  8e 0b d4
l_e14d:
    lda $bf ; $e14d  a5 bf
    bmi l_e154 ; $e14f  30 03
    beq l_e154 ; $e151  f0 01
    rts ; $e153  60
l_e154:
    jsr l_e38d ; $e154  20 8d e3
    cmp #$00 ; $e157  c9 00
    bne l_e18a ; $e159  d0 2f
    ldx $e3ab ; $e15b  ae ab e3
    beq l_e185 ; $e15e  f0 25
    dex ; $e160  ca
    dex ; $e161  ca
    dex ; $e162  ca
    stx $e3ab ; $e163  8e ab e3
    lda $e3ac,x ; $e166  bd ac e3
    sta $ba ; $e169  85 ba
    sta $e399 ; $e16b  8d 99 e3
    jsr l_e0de ; $e16e  20 de e0
    ldx $e3ab ; $e171  ae ab e3
    lda $e3ad,x ; $e174  bd ad e3
    sta $e38e ; $e177  8d 8e e3
    lda $e3ae,x ; $e17a  bd ae e3
    sta $e38f ; $e17d  8d 8f e3
    pla ; $e180  68
    pla ; $e181  68
    jmp l_e0cc ; $e182  4c cc e0
l_e185:
    lda #$80 ; $e185  a9 80
    sta $ba ; $e187  85 ba
    rts ; $e189  60
l_e18a:
    cmp #$01 ; $e18a  c9 01
    bne l_e19e ; $e18c  d0 10
    ldx #$00 ; $e18e  a2 00
l_e190:
    jsr l_e38d ; $e190  20 8d e3
    sta $e3be,x ; $e193  9d be e3
    inx ; $e196  e8
    cpx #$0b ; $e197  e0 0b
    bcc l_e190 ; $e199  90 f5
    jmp l_e154 ; $e19b  4c 54 e1
l_e19e:
    cmp #$02 ; $e19e  c9 02
    bne l_e1b2 ; $e1a0  d0 10
    jsr l_e38d ; $e1a2  20 8d e3
    tax ; $e1a5  aa
    jsr l_e38d ; $e1a6  20 8d e3
    sta $e38f ; $e1a9  8d 8f e3
    stx $e38e ; $e1ac  8e 8e e3
    jmp l_e154 ; $e1af  4c 54 e1
l_e1b2:
    cmp #$03 ; $e1b2  c9 03
    bne l_e1dd ; $e1b4  d0 27
    jsr l_e38d ; $e1b6  20 8d e3
    pha ; $e1b9  48
    jsr l_e38d ; $e1ba  20 8d e3
    pha ; $e1bd  48
    ldx $e3ab ; $e1be  ae ab e3
    lda $e38f ; $e1c1  ad 8f e3
    sta $e3ac,x ; $e1c4  9d ac e3
    lda $e38e ; $e1c7  ad 8e e3
    sta $e3ad,x ; $e1ca  9d ad e3
    inx ; $e1cd  e8
    inx ; $e1ce  e8
    stx $e3ab ; $e1cf  8e ab e3
    pla ; $e1d2  68
    sta $e38f ; $e1d3  8d 8f e3
    pla ; $e1d6  68
    sta $e38e ; $e1d7  8d 8e e3
    jmp l_e154 ; $e1da  4c 54 e1
l_e1dd:
    cmp #$04 ; $e1dd  c9 04
    bne l_e1f8 ; $e1df  d0 17
    ldx $e3ab ; $e1e1  ae ab e3
    dex ; $e1e4  ca
    dex ; $e1e5  ca
    stx $e3ab ; $e1e6  8e ab e3
    lda $e3ad,x ; $e1e9  bd ad e3
    sta $e38e ; $e1ec  8d 8e e3
    lda $e3ac,x ; $e1ef  bd ac e3
    sta $e38f ; $e1f2  8d 8f e3
    jmp l_e154 ; $e1f5  4c 54 e1
l_e1f8:
    cmp #$05 ; $e1f8  c9 05
    bne l_e21c ; $e1fa  d0 20
    jsr l_e38d ; $e1fc  20 8d e3
    pha ; $e1ff  48
    ldx $e3ab ; $e200  ae ab e3
    lda $e38f ; $e203  ad 8f e3
    sta $e3ac,x ; $e206  9d ac e3
    lda $e38e ; $e209  ad 8e e3
    sta $e3ad,x ; $e20c  9d ad e3
    pla ; $e20f  68
    sta $e3ae,x ; $e210  9d ae e3
    inx ; $e213  e8
    inx ; $e214  e8
    inx ; $e215  e8
    stx $e3ab ; $e216  8e ab e3
    jmp l_e154 ; $e219  4c 54 e1
l_e21c:
    cmp #$06 ; $e21c  c9 06
    bne l_e240 ; $e21e  d0 20
    ldx $e3ab ; $e220  ae ab e3
    dex ; $e223  ca
    dex ; $e224  ca
    dex ; $e225  ca
    dec $e3ae,x ; $e226  de ae e3
    beq l_e23a ; $e229  f0 0f
    lda $e3ac,x ; $e22b  bd ac e3
    sta $e38f ; $e22e  8d 8f e3
    lda $e3ad,x ; $e231  bd ad e3
    sta $e38e ; $e234  8d 8e e3
    jmp l_e154 ; $e237  4c 54 e1
l_e23a:
    stx $e3ab ; $e23a  8e ab e3
    jmp l_e154 ; $e23d  4c 54 e1
l_e240:
    cmp #$07 ; $e240  c9 07
    bne l_e258 ; $e242  d0 14
    jsr l_e38d ; $e244  20 8d e3
    pha ; $e247  48
    lsr ; $e248  4a
    lsr ; $e249  4a
    lsr ; $e24a  4a
    lsr ; $e24b  4a
    sta $e3c9 ; $e24c  8d c9 e3
    pla ; $e24f  68
    and #$0f ; $e250  29 0f
    sta $e3ca ; $e252  8d ca e3
    jmp l_e154 ; $e255  4c 54 e1
l_e258:
    cmp #$13 ; $e258  c9 13
    bcs l_e26e ; $e25a  b0 12
    sec ; $e25c  38
    sbc #$08 ; $e25d  e9 08
    sta $e3bd ; $e25f  8d bd e3
    lda #$0a ; $e262  a9 0a
    sec ; $e264  38
    sbc $e3bd ; $e265  ed bd e3
    sta $e3bd ; $e268  8d bd e3
l_e26b:
    jmp l_e154 ; $e26b  4c 54 e1
l_e26e:
    cmp #$13 ; $e26e  c9 13
    bne l_e27f ; $e270  d0 0d
    ldx #$0d ; $e272  a2 0d
l_e274:
    lda $e3bd,x ; $e274  bd bd e3
    sta $e3cb,x ; $e277  9d cb e3
    dex ; $e27a  ca
    bpl l_e274 ; $e27b  10 f7
    bmi l_e26b ; $e27d  30 ec
l_e27f:
    cmp #$14 ; $e27f  c9 14
    bne l_e290 ; $e281  d0 0d
    ldx #$0d ; $e283  a2 0d
l_e285:
    lda $e3cb,x ; $e285  bd cb e3
    sta $e3bd,x ; $e288  9d bd e3
    dex ; $e28b  ca
    bpl l_e285 ; $e28c  10 f7
    bmi l_e26b ; $e28e  30 db
l_e290:
    pha ; $e290  48
    and #$3f ; $e291  29 3f
    jsr l_e33d ; $e293  20 3d e3
    stx $e2ca ; $e296  8e ca e2
    sty $e2cb ; $e299  8c cb e2
    pla ; $e29c  68
    and #$c0 ; $e29d  29 c0
    eor #$40 ; $e29f  49 40
    beq l_e2a6 ; $e2a1  f0 03
    jsr l_e38d ; $e2a3  20 8d e3
l_e2a6:
    jsr l_e33d ; $e2a6  20 3d e3
    stx $e2cc ; $e2a9  8e cc e2
    sty $e2cd ; $e2ac  8c cd e2
    ldx $e3bd ; $e2af  ae bd e3
    lda $e3be,x ; $e2b2  bd be e3
    lsr ; $e2b5  4a
    clc ; $e2b6  18
    adc $e3be,x ; $e2b7  7d be e3
    sta $bf ; $e2ba  85 bf
    ldx #$00 ; $e2bc  a2 00
    ldy #$00 ; $e2be  a0 00
    jsr l_e2ce ; $e2c0  20 ce e2
    ldx #$02 ; $e2c3  a2 02
    ldy #$07 ; $e2c5  a0 07
    jmp l_e2ce ; $e2c7  4c ce e2
    !byte $00,$00,$00,$00 ; $e2ca retained data / unresolved code
l_e2ce:
    lda $e2ca,x ; $e2ce  bd ca e2
    ora $e2cb,x ; $e2d1  1d cb e2
    bne l_e2da ; $e2d4  d0 04

; SID voice control (I/O only when $01 exposes it)
    sta $d404,y ; $e2d6  99 04 d4
    rts ; $e2d9  60
l_e2da:
    lda $e2ca,x ; $e2da  bd ca e2

; SID voice frequency low (+Y voice offset) (I/O only when $01 exposes it)
    sta $d400,y ; $e2dd  99 00 d4
    lda $e2cb,x ; $e2e0  bd cb e2

; SID voice frequency high (I/O only when $01 exposes it)
    sta $d401,y ; $e2e3  99 01 d4
    lda $bd ; $e2e6  a5 bd
    asl ; $e2e8  0a
    asl ; $e2e9  0a
    asl ; $e2ea  0a
    tax ; $e2eb  aa
    lda $e322,x ; $e2ec  bd 22 e3

; SID filter cutoff low (I/O only when $01 exposes it)
    sta $d415 ; $e2ef  8d 15 d4
    lda $e323,x ; $e2f2  bd 23 e3

; SID filter cutoff high (I/O only when $01 exposes it)
    sta $d416 ; $e2f5  8d 16 d4
    lda $e324,x ; $e2f8  bd 24 e3

; SID filter routing/resonance (I/O only when $01 exposes it)
    sta $d417 ; $e2fb  8d 17 d4
    lda $e320,x ; $e2fe  bd 20 e3

; SID pulse width low (I/O only when $01 exposes it)
    sta $d402,y ; $e301  99 02 d4
    lda $e321,x ; $e304  bd 21 e3

; SID pulse width high (I/O only when $01 exposes it)
    sta $d403,y ; $e307  99 03 d4
    lda $e31d,x ; $e30a  bd 1d e3

; SID attack/decay (I/O only when $01 exposes it)
    sta $d405,y ; $e30d  99 05 d4
    lda $e31e,x ; $e310  bd 1e e3

; SID sustain/release (I/O only when $01 exposes it)
    sta $d406,y ; $e313  99 06 d4
    lda $e31f,x ; $e316  bd 1f e3

; SID voice control (I/O only when $01 exposes it)
    sta $d404,y ; $e319  99 04 d4
    rts ; $e31c  60
    !byte $79,$74,$11,$00,$00,$00,$00,$00,$09,$00,$11,$00,$00,$00,$00,$00 ; $e31d retained data / unresolved code
    !byte $1f,$00,$21,$00,$00,$00,$00,$00,$08,$00,$81,$00,$00,$00,$00,$b0 ; $e32d retained data / unresolved code
l_e33d:
    cmp #$00 ; $e33d  c9 00
    beq l_e36e ; $e33f  f0 2d
    clc ; $e341  18
    adc #$18 ; $e342  69 18
    ldy #$07 ; $e344  a0 07
l_e346:
    cmp #$0c ; $e346  c9 0c
    bcc l_e34f ; $e348  90 05
    dey ; $e34a  88
    sbc #$0c ; $e34b  e9 0c
    bne l_e346 ; $e34d  d0 f7
l_e34f:
    sty $e374 ; $e34f  8c 74 e3
    asl ; $e352  0a
    tay ; $e353  a8
    lda $e375,y ; $e354  b9 75 e3
    sta $e373 ; $e357  8d 73 e3
    lda $e376,y ; $e35a  b9 76 e3
l_e35d:
    dec $e374 ; $e35d  ce 74 e3
    bmi l_e369 ; $e360  30 07
    lsr ; $e362  4a
    ror $e373 ; $e363  6e 73 e3
    jmp l_e35d ; $e366  4c 5d e3
l_e369:
    tay ; $e369  a8
    ldx $e373 ; $e36a  ae 73 e3
    rts ; $e36d  60
l_e36e:
    ldx #$00 ; $e36e  a2 00
    ldy #$00 ; $e370  a0 00
    rts ; $e372  60
    !byte $00,$00,$49,$86,$18,$8e,$8b,$96,$7e,$9f,$fa,$a8,$06,$b3,$ac,$bd ; $e373 retained data / unresolved code
    !byte $f3,$c8,$e6,$d4,$8f,$e1,$f8,$ee,$2e,$fd ; $e383 retained data / unresolved code

; RAM IRQ vector high / unpatched operand placeholder
l_e38d:
    lda $ffff ; $e38d  ad ff ff
    inc $e38e ; $e390  ee 8e e3
    bne l_e398 ; $e393  d0 03
    inc $e38f ; $e395  ee 8f e3
l_e398:
    rts ; $e398  60
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $e399 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $e3a9 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $e3b9 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $e3c9 retained data / unresolved code
    !byte $03,$71,$e4,$07,$13,$05,$20,$0e,$a1,$15,$0c,$a6,$1a,$0e,$66,$0c ; $e3d9 retained data / unresolved code
    !byte $a6,$1a,$0e,$a8,$15,$a9,$1a,$0c,$66,$a6,$1a,$0e,$a8,$15,$a9,$1a ; $e3e9 retained data / unresolved code
    !byte $0c,$66,$a8,$1a,$0e,$a5,$15,$0a,$a6,$0e,$0c,$a6,$1a,$0e,$66,$66 ; $e3f9 retained data / unresolved code
    !byte $a9,$18,$ab,$1d,$0c,$ad,$11,$0e,$ad,$1d,$ad,$1d,$ad,$1d,$ad,$1a ; $e409 retained data / unresolved code
    !byte $0c,$ab,$18,$0e,$ab,$18,$b0,$1a,$af,$1c,$af,$1d,$0a,$91,$2d,$0e ; $e419 retained data / unresolved code
    !byte $6d,$6f,$0c,$b0,$1d,$0e,$70,$70,$af,$21,$ad,$1d,$0c,$ab,$18,$0e ; $e429 retained data / unresolved code
    !byte $6b,$6b,$6d,$6f,$0c,$b0,$1d,$0e,$70,$b0,$1d,$af,$1c,$ad,$1a,$0c ; $e439 retained data / unresolved code
    !byte $ab,$18,$0e,$6b,$0b,$6b,$03,$5f,$e4,$06,$00,$13,$03,$71,$e4,$07 ; $e449 retained data / unresolved code
    !byte $13,$03,$5f,$e4,$14,$00,$0b,$a9,$1a,$ab,$1c,$ad,$1d,$0e,$ad,$1d ; $e459 retained data / unresolved code
    !byte $a9,$1c,$a9,$1a,$0a,$ab,$18,$04,$01,$01,$02,$03,$05,$07,$0b,$0f ; $e469 retained data / unresolved code
    !byte $17,$1f,$2f,$3e,$04,$01,$01,$02,$03,$05,$07,$0a,$0e,$15,$1c,$2a ; $e479 retained data / unresolved code
    !byte $38,$07,$11,$04,$03,$7e,$e4,$05,$1a,$0c,$9a,$09,$0e,$8e,$21,$91 ; $e489 retained data / unresolved code
    !byte $1f,$0c,$8e,$1d,$98,$0c,$0e,$5f,$5c,$0c,$a4,$13,$8c,$1f,$0e,$a4 ; $e499 retained data / unresolved code
    !byte $18,$a6,$16,$a4,$15,$9d,$11,$0a,$90,$1f,$0e,$a4,$0c,$a2,$0e,$a1 ; $e4a9 retained data / unresolved code
    !byte $10,$9f,$13,$0c,$9d,$11,$0e,$a1,$05,$9d,$07,$9f,$09,$9d,$0a,$0c ; $e4b9 retained data / unresolved code
    !byte $8c,$1c,$0e,$9a,$0a,$9c,$0c,$9d,$11,$a6,$16,$a2,$0e,$a4,$15,$0c ; $e4c9 retained data / unresolved code
    !byte $91,$1d,$9c,$0c,$0a,$85,$1d,$0e,$91,$29,$90,$28,$8e,$26,$95,$21 ; $e4d9 retained data / unresolved code
    !byte $8e,$21,$61,$4e,$55,$4e,$66,$8d,$25,$95,$21,$8e,$26,$61,$90,$28 ; $e4e9 retained data / unresolved code
    !byte $95,$21,$49,$61,$8c,$2d,$90,$2b,$91,$29,$0c,$85,$24,$0e,$91,$2d ; $e4f9 retained data / unresolved code
    !byte $90,$2b,$8e,$29,$0c,$8c,$28,$0e,$93,$26,$91,$24,$0c,$8a,$26,$0e ; $e509 retained data / unresolved code
    !byte $93,$24,$91,$22,$0c,$89,$24,$0e,$96,$1f,$95,$1c,$90,$1f,$91,$21 ; $e519 retained data / unresolved code
    !byte $0c,$91,$21,$0a,$89,$1a,$06,$00,$03,$7e,$e4,$05,$22,$0e,$a1,$0e ; $e529 retained data / unresolved code
    !byte $9d,$09,$9a,$0e,$9c,$10,$0c,$9d,$11,$0e,$9f,$10,$a1,$0e,$9f,$0c ; $e539 retained data / unresolved code
    !byte $9d,$07,$9c,$0c,$9a,$0e,$0c,$9c,$10,$98,$0c,$0e,$96,$0e,$9a,$0c ; $e549 retained data / unresolved code
    !byte $9d,$0a,$9c,$05,$0c,$9d,$0e,$9a,$0a,$0e,$99,$09,$95,$04,$95,$05 ; $e559 retained data / unresolved code
    !byte $96,$02,$0c,$95,$04,$0e,$9d,$09,$9f,$0d,$a1,$0e,$a4,$11,$a1,$0e ; $e569 retained data / unresolved code
    !byte $9f,$09,$0c,$a1,$02,$0e,$a8,$10,$a9,$11,$ab,$10,$a8,$05,$a8,$07 ; $e579 retained data / unresolved code
    !byte $a6,$0a,$0c,$a4,$0c,$9f,$00,$0e,$a6,$0a,$a4,$05,$a2,$07,$9d,$09 ; $e589 retained data / unresolved code
    !byte $0c,$a2,$0a,$0e,$a6,$0e,$a8,$10,$a9,$11,$a6,$0e,$a4,$0c,$a9,$0a ; $e599 retained data / unresolved code
    !byte $0a,$a9,$11,$06,$00,$05,$01,$02,$b5,$e5,$05,$18,$03,$7e,$e4,$0e ; $e5a9 retained data / unresolved code
    !byte $4e,$50,$0c,$91,$05,$0e,$5d,$5f,$0c,$a1,$15,$0e,$49,$4a,$0c,$8c ; $e5b9 retained data / unresolved code
    !byte $00,$0e,$5c,$5d,$0c,$5f,$9c,$13,$9a,$0e,$0e,$9a,$11,$9c,$10,$0c ; $e5c9 retained data / unresolved code
    !byte $9d,$0e,$0e,$9d,$10,$9f,$11,$0c,$a4,$0c,$0e,$5c,$5d,$5f,$5d,$5c ; $e5d9 retained data / unresolved code
    !byte $5f,$0c,$a1,$0e,$0e,$66,$68,$0c,$a9,$1d,$0e,$49,$4a,$0c,$8c,$00 ; $e5e9 retained data / unresolved code
    !byte $0e,$68,$66,$0c,$a4,$18,$0e,$68,$64,$0c,$a2,$1a,$0e,$47,$49,$0c ; $e5f9 retained data / unresolved code
    !byte $96,$0a,$0e,$64,$66,$0c,$a8,$1f,$0e,$a8,$1f,$a6,$1d,$a4,$1c,$9f ; $e609 retained data / unresolved code
    !byte $18,$a4,$1c,$a8,$1f,$0c,$a9,$26,$0e,$5a,$5c,$0c,$9d,$11,$0e,$49 ; $e619 retained data / unresolved code
    !byte $4a,$0c,$8c,$00,$0e,$5c,$5d,$5f,$5d,$5c,$5f,$0c,$a1,$1a,$9d,$15 ; $e629 retained data / unresolved code
    !byte $9a,$11,$96,$07,$0a,$98,$0c,$06,$00,$03,$7e,$e4,$05,$1a,$0c,$a6 ; $e639 retained data / unresolved code
    !byte $1a,$a6,$15,$0e,$a6,$0e,$a8,$0e,$a9,$11,$ab,$11,$a4,$10,$9f,$10 ; $e649 retained data / unresolved code
    !byte $a6,$11,$9f,$11,$0c,$a8,$13,$a4,$10,$0e,$a2,$0e,$a4,$0e,$a6,$11 ; $e659 retained data / unresolved code
    !byte $a8,$11,$a6,$16,$a4,$16,$a2,$11,$9f,$11,$a1,$15,$9c,$15,$9f,$10 ; $e669 retained data / unresolved code
    !byte $9c,$10,$0a,$a1,$09,$0e,$a9,$0e,$a8,$0e,$a6,$11,$a5,$11,$a6,$10 ; $e679 retained data / unresolved code
    !byte $a8,$10,$a9,$0e,$ab,$0e,$a8,$0c,$a6,$0c,$a4,$0e,$9f,$0e,$a4,$10 ; $e689 retained data / unresolved code
    !byte $a6,$10,$a8,$13,$a4,$13,$56,$58,$5a,$5c,$5d,$5f,$61,$62,$4a,$4c ; $e699 retained data / unresolved code
    !byte $4e,$50,$51,$53,$55,$56,$99,$09,$9c,$0a,$9d,$0d,$a2,$0e,$a1,$10 ; $e6a9 retained data / unresolved code
    !byte $a5,$13,$a9,$22,$a8,$21,$0a,$a6,$1d,$0c,$a2,$1a,$a1,$19,$06,$00 ; $e6b9 retained data / unresolved code
    !byte $03,$7e,$e4,$05,$20,$0c,$a8,$24,$0e,$5f,$5c,$5f,$61,$0c,$a6,$22 ; $e6c9 retained data / unresolved code
    !byte $0e,$5d,$5a,$62,$5d,$0c,$a1,$1d,$0e,$a1,$1d,$9c,$18,$9a,$16,$9d ; $e6d9 retained data / unresolved code
    !byte $1a,$0c,$9c,$18,$0e,$9c,$18,$9a,$16,$98,$15,$95,$11,$0c,$9d,$16 ; $e6e9 retained data / unresolved code
    !byte $0e,$9d,$16,$a2,$1f,$a1,$1d,$9f,$1c,$98,$15,$a2,$1f,$a4,$21,$a2 ; $e6f9 retained data / unresolved code
    !byte $1f,$a4,$21,$a6,$22,$9a,$16,$a6,$22,$a4,$1d,$a6,$22,$a2,$1d,$a6 ; $e709 retained data / unresolved code
    !byte $22,$a8,$24,$9c,$16,$a2,$1d,$a8,$24,$9c,$18,$a4,$21,$0c,$a6,$22 ; $e719 retained data / unresolved code
    !byte $a2,$1d,$9d,$1a,$98,$11,$a1,$1d,$a4,$1c,$a2,$1a,$0e,$9c,$18,$9f ; $e729 retained data / unresolved code
    !byte $1c,$9d,$1a,$a4,$21,$0a,$a2,$1a,$0e,$a2,$1d,$a6,$22,$06,$00,$03 ; $e739 retained data / unresolved code
    !byte $7e,$e4,$05,$1a,$0e,$9f,$13,$5a,$5a,$5a,$5a,$5a,$5a,$5a,$9e,$15 ; $e749 retained data / unresolved code
    !byte $5a,$5a,$5a,$5a,$5a,$5a,$5a,$9f,$13,$5a,$a1,$15,$5a,$a2,$16,$5a ; $e759 retained data / unresolved code
    !byte $9f,$13,$5a,$a1,$1e,$5a,$5a,$5b,$5a,$58,$56,$5a,$93,$0e,$5a,$55 ; $e769 retained data / unresolved code
    !byte $5a,$92,$0e,$5a,$55,$5a,$93,$0e,$5a,$96,$13,$98,$15,$5a,$5e,$5f ; $e779 retained data / unresolved code
    !byte $61,$a2,$1f,$5a,$a2,$1f,$5a,$a4,$21,$5a,$a4,$21,$5a,$a6,$22,$9f ; $e789 retained data / unresolved code
    !byte $1a,$9f,$1a,$a1,$1a,$a2,$1a,$95,$11,$9a,$16,$a1,$1d,$9f,$1b,$9f ; $e799 retained data / unresolved code
    !byte $1b,$9f,$1b,$9d,$1a,$9b,$18,$61,$5f,$5b,$9d,$1a,$a2,$1d,$9d,$1a ; $e7a9 retained data / unresolved code
    !byte $9b,$18,$9a,$16,$58,$56,$58,$9e,$1a,$9e,$1a,$9e,$1a,$9e,$1a,$9e ; $e7b9 retained data / unresolved code
    !byte $1a,$10,$a6,$22,$a8,$24,$a6,$22,$a4,$21,$a2,$1f,$a1,$1d,$9f,$1b ; $e7c9 retained data / unresolved code
    !byte $0e,$9f,$1a,$93,$0e,$9f,$1a,$93,$0e,$9f,$1a,$93,$0e,$9f,$1a,$9f ; $e7d9 retained data / unresolved code
    !byte $1a,$06,$00,$03,$7e,$e4,$05,$18,$0c,$54,$0e,$94,$0d,$99,$0f,$9c ; $e7e9 retained data / unresolved code
    !byte $10,$a0,$14,$0c,$59,$0e,$a0,$14,$9c,$12,$a0,$14,$59,$0c,$9c,$15 ; $e7f9 retained data / unresolved code
    !byte $a1,$12,$9b,$12,$9c,$14,$48,$48,$94,$0d,$0e,$9c,$14,$9b,$12,$99 ; $e809 retained data / unresolved code
    !byte $10,$97,$0f,$0c,$95,$0d,$99,$12,$9c,$15,$9c,$19,$0e,$9c,$19,$9e ; $e819 retained data / unresolved code
    !byte $18,$9e,$16,$9b,$18,$0a,$9c,$19,$0e,$48,$48,$0c,$90,$0d,$94,$10 ; $e829 retained data / unresolved code
    !byte $99,$14,$0e,$a0,$14,$9e,$14,$9c,$14,$9e,$14,$0c,$a0,$14,$a1,$17 ; $e839 retained data / unresolved code
    !byte $9c,$17,$9e,$15,$0a,$9b,$08,$0e,$a0,$14,$a4,$14,$0c,$a5,$0d,$0e ; $e849 retained data / unresolved code
    !byte $a0,$0d,$a0,$0f,$9e,$10,$9e,$12,$0c,$9c,$14,$a0,$0d,$a5,$14,$a8 ; $e859 retained data / unresolved code
    !byte $08,$0e,$a8,$0f,$a7,$0f,$a5,$14,$a4,$14,$09,$a5,$11,$06,$00 ; $e869 retained data / unresolved code
