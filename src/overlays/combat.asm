; COMBAT -- resource 0; identical payload on character and dungeon disks.
!cpu 6510
* = $9b00

; Combat overlay: resource 0, shared by all three data disks, at $9b00.
; Battle menus, party/enemy actions, spell/item dispatch, and rewards.
; Preserve action state, request music command $81, and wait for the
; IRQ-driven player to consume it before continuing the game loop.
; Resident helpers live in BARDSUBS1/BARDSUBS2; other overlays can
; replace this address range, so a runtime memory map is still required.
combat_overlay:
    lda $96 ; $9b00  a5 96
    sta $98 ; $9b02  85 98
    lda #$00 ; $9b04  a9 00
    sta $96 ; $9b06  85 96
    lda #$81 ; $9b08  a9 81
    sta $ba ; $9b0a  85 ba
l_9b0c:
    jsr $92f6 ; $9b0c  20 f6 92
    lda $ba ; $9b0f  a5 ba
    bmi l_9b0c ; $9b11  30 f9
    jsr l_a171 ; $9b13  20 71 a1
    jsr l_b20c ; $9b16  20 0c b2
    jsr l_b2cc ; $9b19  20 cc b2
    jsr l_b346 ; $9b1c  20 46 b3
    jmp l_9b3d ; $9b1f  4c 3d 9b
l_9b22:
    jsr l_b2cc ; $9b22  20 cc b2
    jsr $740a ; $9b25  20 0a 74

; Packed text: 'You still face '
    !byte $f5,$df,$40,$ca,$6a,$63,$02,$71,$10,$c1,$00 ; $9b28 retained data / unresolved code
    jsr l_b23d ; $9b33  20 3d b2
    jsr l_b346 ; $9b36  20 46 b3
    lda $81 ; $9b39  a5 81
    bne l_9b47 ; $9b3b  d0 0a
l_9b3d:
    jsr choose_battle_strategy ; $9b3d  20 14 a3
    lda $8a ; $9b40  a5 8a
    beq l_9b47 ; $9b42  f0 03
    jmp l_9c25 ; $9b44  4c 25 9c
l_9b47:
    jsr l_b3df ; $9b47  20 df b3
l_9b4a:
    jsr l_a6b6 ; $9b4a  20 b6 a6
    stx $83 ; $9b4d  86 83
    sty $9b63 ; $9b4f  8c 63 9b
    jsr l_a6c9 ; $9b52  20 c9 a6
    cpy $9b63 ; $9b55  cc 63 9b
    bcc l_9b62 ; $9b58  90 08
    beq l_9b62 ; $9b5a  f0 06
    jsr dispatch_enemy_action ; $9b5c  20 0c 9f
    jmp l_9b4a ; $9b5f  4c 4a 9b
l_9b62:
    ldy #$00 ; $9b62  a0 00
    beq l_9b6e ; $9b64  f0 08
    ldx $83 ; $9b66  a6 83
    jsr dispatch_party_action ; $9b68  20 4f 9c
    jmp l_9b4a ; $9b6b  4c 4a 9b
l_9b6e:
    lda #$00 ; $9b6e  a9 00
    sta $0321 ; $9b70  8d 21 03
    jsr l_b1ad ; $9b73  20 ad b1
    lda $80 ; $9b76  a5 80
    bne l_9bca ; $9b78  d0 50
    ldx #$03 ; $9b7a  a2 03
l_9b7c:
    jsr $f9df ; $9b7c  20 df f9
    bne l_9b86 ; $9b7f  d0 05
    dex ; $9b81  ca
    bpl l_9b7c ; $9b82  10 f8
    bmi l_9bca ; $9b84  30 44
l_9b86:
    ldx #$00 ; $9b86  a2 00
l_9b88:
    lda $d522,x ; $9b88  bd 22 d5
    sta $49 ; $9b8b  85 49
    lda $d523,x ; $9b8d  bd 23 d5
    sta $4a ; $9b90  85 4a
    ldy #$00 ; $9b92  a0 00
    lda ($49),y ; $9b94  b1 49
    beq l_9ba0 ; $9b96  f0 08
    ldy #$29 ; $9b98  a0 29
    lda ($49),y ; $9b9a  b1 49
    cmp #$0e ; $9b9c  c9 0e
    beq l_9ba8 ; $9b9e  f0 08
l_9ba0:
    inx ; $9ba0  e8
    inx ; $9ba1  e8
    cpx #$0e ; $9ba2  e0 0e
    bcc l_9b88 ; $9ba4  90 e2
    bcs l_9bca ; $9ba6  b0 22
l_9ba8:
    lda #$00 ; $9ba8  a9 00
    sta $5c ; $9baa  85 5c
    lda #$80 ; $9bac  a9 80
    sta $5d ; $9bae  85 5d
    jsr $eb52 ; $9bb0  20 52 eb
    bcs l_9bca ; $9bb3  b0 15
    inc $80 ; $9bb5  e6 80
    jsr $740a ; $9bb7  20 0a 74

; Packed text: 'They disbelieve!<$0d><$0d>'
    !byte $f4,$d2,$6b,$84,$aa,$90,$cc,$c5,$1a,$a6,$e7,$7a,$00 ; $9bba retained data / unresolved code
    jsr $8f5b ; $9bc7  20 5b 8f
l_9bca:
    jsr $90bf ; $9bca  20 bf 90
    jsr $900c ; $9bcd  20 0c 90
    lda $9c4e ; $9bd0  ad 4e 9c
    beq l_9bdf ; $9bd3  f0 0a
l_9bd5:
    pha ; $9bd5  48
    jsr $9082 ; $9bd6  20 82 90
    pla ; $9bd9  68
    sec ; $9bda  38
    sbc #$01 ; $9bdb  e9 01
    bne l_9bd5 ; $9bdd  d0 f6
l_9bdf:
    jsr l_a787 ; $9bdf  20 87 a7
    jsr $fb81 ; $9be2  20 81 fb
    jsr $6f5e ; $9be5  20 5e 6f
    bcc l_9bed ; $9be8  90 03
    jmp $7936 ; $9bea  4c 36 79
l_9bed:
    ldx #$03 ; $9bed  a2 03
l_9bef:
    jsr $f9df ; $9bef  20 df f9
    bne l_9c1f ; $9bf2  d0 2b
    dex ; $9bf4  ca
    bpl l_9bef ; $9bf5  10 f8
    jsr l_b385 ; $9bf7  20 85 b3
    bcs l_9c1f ; $9bfa  b0 23
    lda $61 ; $9bfc  a5 61
    beq l_9c22 ; $9bfe  f0 22
    jsr $740a ; $9c00  20 0a 74

; Packed text: 'Do you wish to continue?<$0d>'
    !byte $f1,$5e,$1b,$be,$81,$b2,$a4,$90,$cd,$e1,$23,$dd,$35,$3a,$86,$ff ; $9c03 retained data / unresolved code
    !byte $1d,$00 ; $9c13 retained data / unresolved code
    jsr $7e10 ; $9c15  20 10 7e
    bcs l_9c25 ; $9c18  b0 0b
    jsr $740a ; $9c1a  20 0a 74

; Packed text: '<$0d><$0d>'
    !byte $ef,$40 ; $9c1d retained data / unresolved code
l_9c1f:
    jmp l_9b22 ; $9c1f  4c 22 9b
l_9c22:
    jsr l_aeaa ; $9c22  20 aa ae
l_9c25:
    jsr l_a29b ; $9c25  20 9b a2
    jsr $8673 ; $9c28  20 73 86
    lda #$00 ; $9c2b  a9 00
    sta $61 ; $9c2d  85 61
    sta $62 ; $9c2f  85 62
    lda $98 ; $9c31  a5 98
    beq l_9c3d ; $9c33  f0 08
    lda #$01 ; $9c35  a9 01
    sta $96 ; $9c37  85 96
    lda #$82 ; $9c39  a9 82
    bne l_9c42 ; $9c3b  d0 05
l_9c3d:
    jsr $78ba ; $9c3d  20 ba 78
    lda #$80 ; $9c40  a9 80
l_9c42:
    sta $ba ; $9c42  85 ba
l_9c44:
    jsr $92f6 ; $9c44  20 f6 92
    lda $ba ; $9c47  a5 ba
    bmi l_9c44 ; $9c49  30 f9
    jmp $fb81 ; $9c4b  4c 81 fb
    !byte $00 ; $9c4e retained data / unresolved code

; Party action dispatcher. X selects a party slot; get its record
; through $d522/$d523, check presence/status, then dispatch using
; action code at $032a,X or the record action fields.
; The exact names of all action values are not yet established.
dispatch_party_action:
    lda #$00 ; $9c4f  a9 00
    sta $03b7,x ; $9c51  9d b7 03
    stx $5c ; $9c54  86 5c
    txa ; $9c56  8a
    asl ; $9c57  0a
    tay ; $9c58  a8
    lda $d522,y ; $9c59  b9 22 d5
    sta $36 ; $9c5c  85 36
    sta $38 ; $9c5e  85 38
    lda $d523,y ; $9c60  b9 23 d5
    sta $37 ; $9c63  85 37
    sta $39 ; $9c65  85 39
    ldy #$00 ; $9c67  a0 00
    lda ($36),y ; $9c69  b1 36
    beq l_9c75 ; $9c6b  f0 08
    ldy #$2d ; $9c6d  a0 2d
    lda ($36),y ; $9c6f  b1 36
    and #$1c ; $9c71  29 1c
    beq l_9c76 ; $9c73  f0 01
l_9c75:
    rts ; $9c75  60
l_9c76:
    ldy #$29 ; $9c76  a0 29
    lda ($36),y ; $9c78  b1 36
    cmp #$0d ; $9c7a  c9 0d
    bcs l_9c81 ; $9c7c  b0 03
    jmp l_9d7a ; $9c7e  4c 7a 9d
l_9c81:
    cmp #$0e ; $9c81  c9 0e
    bne l_9c89 ; $9c83  d0 04
    lda $80 ; $9c85  a5 80
    bne l_9c75 ; $9c87  d0 ec
l_9c89:
    jsr $ff3e ; $9c89  20 3e ff
    and #$06 ; $9c8c  29 06
    clc ; $9c8e  18
    adc #$54 ; $9c8f  69 54
    tay ; $9c91  a8
    lda ($36),y ; $9c92  b1 36
    sta $03c9 ; $9c94  8d c9 03
    pha ; $9c97  48
    iny ; $9c98  c8
    lda ($36),y ; $9c99  b1 36
    sta $03ca ; $9c9b  8d ca 03
    pla ; $9c9e  68
    cmp #$80 ; $9c9f  c9 80
    bcc l_9cbd ; $9ca1  90 1a
    sec ; $9ca3  38
    sbc #$f0 ; $9ca4  e9 f0
    cmp #$10 ; $9ca6  c9 10
    bcc l_9cac ; $9ca8  90 02
    sbc #$80 ; $9caa  e9 80
l_9cac:
    pha ; $9cac  48
    asl ; $9cad  0a
    tax ; $9cae  aa
    lda $9cf0,x ; $9caf  bd f0 9c
    sta $12 ; $9cb2  85 12
    lda $9cf1,x ; $9cb4  bd f1 9c
    sta $13 ; $9cb7  85 13
    pla ; $9cb9  68
    jmp ($0012) ; $9cba  6c 12 00
l_9cbd:
    sta $58 ; $9cbd  85 58
    tax ; $9cbf  aa
    lda $03ca ; $9cc0  ad ca 03
    sta $fc ; $9cc3  85 fc
    lda $ed2a,x ; $9cc5  bd 2a ed
    and #$20 ; $9cc8  29 20
    bne l_9ce5 ; $9cca  d0 19
    ldx #$00 ; $9ccc  a2 00
    ldy #$68 ; $9cce  a0 68
    lda ($36),y ; $9cd0  b1 36
    bne l_9cdb ; $9cd2  d0 07
    jsr $f9df ; $9cd4  20 df f9
    beq l_9d36 ; $9cd7  f0 5d
    bne $9ce9 ; $9cd9  d0 0e
l_9cdb:
    jsr $ae48 ; $9cdb  20 48 ae
    bcs l_9ce4 ; $9cde  b0 04
    cmp $5c ; $9ce0  c5 5c
    bne l_9ceb ; $9ce2  d0 07
l_9ce4:
    rts ; $9ce4  60
l_9ce5:
    jsr l_ae45 ; $9ce5  20 45 ae
    !byte $2c,$a9,$80 ; $9ce8 retained data / unresolved code
l_9ceb:
    sta $5d ; $9ceb  85 5d
    jmp $e981 ; $9ced  4c 81 e9

; Special party-action handler address table (19 little-endian pointers).
    !byte $16,$9d,$16,$9d,$16,$9d,$16,$9d,$16,$9d,$16,$9d,$16,$9d,$16,$9d ; $9cf0 retained data / unresolved code
    !byte $16,$9d,$16,$9d,$36,$9d,$36,$9d,$36,$9d,$36,$9d,$36,$9d,$36,$9d ; $9d00 retained data / unresolved code
    !byte $40,$9d,$37,$9d,$79,$9d ; $9d10 retained data / unresolved code
    and #$0f ; $9d16  29 0f
    sta $03c8 ; $9d18  8d c8 03
    ldy #$68 ; $9d1b  a0 68
    lda ($36),y ; $9d1d  b1 36
    beq l_9d29 ; $9d1f  f0 08
    jsr $ae48 ; $9d21  20 48 ae
    bcs l_9d36 ; $9d24  b0 10
    jmp l_9d31 ; $9d26  4c 31 9d
l_9d29:
    lda $83 ; $9d29  a5 83
    cmp #$04 ; $9d2b  c9 04
    bcs l_9d36 ; $9d2d  b0 07
    lda #$80 ; $9d2f  a9 80
l_9d31:
    sta $5d ; $9d31  85 5d
    jmp l_9e0d ; $9d33  4c 0d 9e
l_9d36:
    rts ; $9d36  60
    jsr $7520 ; $9d37  20 20 75
    lda $03ca ; $9d3a  ad ca 03
    jmp l_b122 ; $9d3d  4c 22 b1
    ldy #$68 ; $9d40  a0 68
    lda ($36),y ; $9d42  b1 36
    bne l_9d4f ; $9d44  d0 09
    ldx #$00 ; $9d46  a2 00
    jsr $f9df ; $9d48  20 df f9
    beq l_9d36 ; $9d4b  f0 e9
    bne $9d53 ; $9d4d  d0 04
l_9d4f:
    jsr $ae48 ; $9d4f  20 48 ae
    !byte $2c,$a9,$80 ; $9d52 retained data / unresolved code
    sta $5d ; $9d55  85 5d
    jsr $7520 ; $9d57  20 20 75
    ldy #$5c ; $9d5a  a0 5c
    lda ($36),y ; $9d5c  b1 36
    jsr l_a768 ; $9d5e  20 68 a7
    ldx #$06 ; $9d61  a2 06
l_9d63:
    lda $a780,x ; $9d63  bd 80 a7
    sta $f5,x ; $9d66  95 f5
    dex ; $9d68  ca
    bpl l_9d63 ; $9d69  10 f8
    ldy #$5d ; $9d6b  a0 5d
    lda ($36),y ; $9d6d  b1 36
    sta $5b ; $9d6f  85 5b
    lda $03ca ; $9d71  ad ca 03
    sta $f9 ; $9d74  85 f9
    jmp $efa1 ; $9d76  4c a1 ef
    rts ; $9d79  60
l_9d7a:
    lda $032a,x ; $9d7a  bd 2a 03
    asl ; $9d7d  0a
    tay ; $9d7e  a8
    lda $9d8c,y ; $9d7f  b9 8c 9d
    sta $12 ; $9d82  85 12
    lda $9d8d,y ; $9d84  b9 8d 9d
    sta $13 ; $9d87  85 13
    jmp ($0012) ; $9d89  6c 12 00

; Party command handler address table (9 little-endian pointers).
    !byte $36,$9d,$f7,$9d,$36,$9d,$9e,$9d,$ab,$9d,$b9,$9e,$f3,$b0,$f7,$9d ; $9d8c retained data / unresolved code
    !byte $ce,$9d ; $9d9c retained data / unresolved code
    lda $03b0,x ; $9d9e  bd b0 03
    sta $58 ; $9da1  85 58
    lda $0332,x ; $9da3  bd 32 03
    sta $5d ; $9da6  85 5d
    jmp $e981 ; $9da8  4c 81 e9
    lda $0332,x ; $9dab  bd 32 03
    sta $58 ; $9dae  85 58
    lda $03a2,x ; $9db0  bd a2 03
    sta $5d ; $9db3  85 5d
    ldy $03a9,x ; $9db5  bc a9 03
    sty $d0 ; $9db8  84 d0
    lda ($36),y ; $9dba  b1 36
    sta $021e ; $9dbc  8d 1e 02
    iny ; $9dbf  c8
    lda ($36),y ; $9dc0  b1 36
    sta $53 ; $9dc2  85 53
    dey ; $9dc4  88
    jsr $70ca ; $9dc5  20 ca 70
    jsr $e97f ; $9dc8  20 7f e9
    jmp $711e ; $9dcb  4c 1e 71
    ldy #$2d ; $9dce  a0 2d
    lda ($36),y ; $9dd0  b1 36
    and #$40 ; $9dd2  29 40
    beq l_9ddd ; $9dd4  f0 07
    jsr $ff3e ; $9dd6  20 3e ff
    and #$01 ; $9dd9  29 01
    bne l_9de1 ; $9ddb  d0 04
l_9ddd:
    ldy #$68 ; $9ddd  a0 68
    lda ($36),y ; $9ddf  b1 36
l_9de1:
    cmp #$00 ; $9de1  c9 00
    beq l_9deb ; $9de3  f0 06
    jsr $ae48 ; $9de5  20 48 ae
    jmp l_9dfa ; $9de8  4c fa 9d
l_9deb:
    ldx #$00 ; $9deb  a2 00
    jsr $f9df ; $9ded  20 df f9
    bne l_9df3 ; $9df0  d0 01
    rts ; $9df2  60
l_9df3:
    lda #$80 ; $9df3  a9 80
    bne l_9dfa ; $9df5  d0 03
    lda $0332,x ; $9df7  bd 32 03
l_9dfa:
    sta $5d ; $9dfa  85 5d
    bmi l_9e0d ; $9dfc  30 0f
    jsr $f9d5 ; $9dfe  20 d5 f9
    bcc l_9e0d ; $9e01  90 0a
    cmp #$0d ; $9e03  c9 0d
    bne l_9e0d ; $9e05  d0 06
    ldy #$68 ; $9e07  a0 68
    lda #$01 ; $9e09  a9 01
    sta ($49),y ; $9e0b  91 49
l_9e0d:
    lda $5d ; $9e0d  a5 5d
    jsr $f9f0 ; $9e0f  20 f0 f9
    bcs l_9e1d ; $9e12  b0 09
    ldy #$2d ; $9e14  a0 2d
    lda ($49),y ; $9e16  b1 49
    and #$0c ; $9e18  29 0c
    beq l_9e26 ; $9e1a  f0 0a
    rts ; $9e1c  60
l_9e1d:
    ldy #$15 ; $9e1d  a0 15
    lda ($49),y ; $9e1f  b1 49
    and #$1f ; $9e21  29 1f
    bne l_9e26 ; $9e23  d0 01
    rts ; $9e25  60
l_9e26:
    jsr $7520 ; $9e26  20 20 75
    jsr $8489 ; $9e29  20 89 84
    lda #$01 ; $9e2c  a9 01
    jsr $78f9 ; $9e2e  20 f9 78
    ldx #$00 ; $9e31  a2 00
    bcc l_9e46 ; $9e33  90 11
    ldx #$04 ; $9e35  a2 04
    ldy #$29 ; $9e37  a0 29
    lda ($36),y ; $9e39  b1 36
    cmp #$0d ; $9e3b  c9 0d
    bcc l_9e46 ; $9e3d  90 07
    ldy #$5e ; $9e3f  a0 5e
    lda ($36),y ; $9e41  b1 36
    asl ; $9e43  0a
    asl ; $9e44  0a
    tax ; $9e45  aa
l_9e46:
    jsr $ff3e ; $9e46  20 3e ff
    and #$02 ; $9e49  29 02
    jsr l_ad05 ; $9e4b  20 05 ad
    ldy $b4e1,x ; $9e4e  bc e1 b4
    lda $b4e0,x ; $9e51  bd e0 b4
    tax ; $9e54  aa
    jsr $7419 ; $9e55  20 19 74
    jsr $8489 ; $9e58  20 89 84
    jsr l_ad9b ; $9e5b  20 9b ad
    jsr l_aaec ; $9e5e  20 ec aa
    ldx $83 ; $9e61  a6 83
    lda #$00 ; $9e63  a9 00
    sta $03be,x ; $9e65  9d be 03
    bcc l_9e79 ; $9e68  90 0f
    jsr $740a ; $9e6a  20 0a 74

; Packed text: ', but misses!<$0d><$0d>'
    !byte $d8,$47,$49,$85,$aa,$94,$8d,$2e,$77,$a0 ; $9e6d retained data / unresolved code
    bcc l_9eab ; $9e77  90 32
l_9e79:
    lda $03cb ; $9e79  ad cb 03
    jsr l_a70e ; $9e7c  20 0e a7
    lda $5d ; $9e7f  a5 5d
    jsr l_a8bd ; $9e81  20 bd a8
    bcs l_9e92 ; $9e84  b0 0c
    lda $95 ; $9e86  a5 95
    bne l_9e92 ; $9e88  d0 08
    jsr $740a ; $9e8a  20 0a 74

; Packed text: '.<$0d><$0d>'
    !byte $c7,$7a,$00 ; $9e8d retained data / unresolved code
    bcc l_9eab ; $9e90  90 19
l_9e92:
    lda $95 ; $9e92  a5 95
    asl ; $9e94  0a
    tax ; $9e95  aa
    ldy $d997,x ; $9e96  bc 97 d9
    lda $d996,x ; $9e99  bd 96 d9
    tax ; $9e9c  aa
    jsr $7419 ; $9e9d  20 19 74
    lda $5d ; $9ea0  a5 5d
    jsr $ecb8 ; $9ea2  20 b8 ec
    jsr $740a ; $9ea5  20 0a 74

; Packed text: '!<$0d><$0d>'
    !byte $e7,$7a,$00 ; $9ea8 retained data / unresolved code
l_9eab:
    jsr $fb81 ; $9eab  20 81 fb
    jsr $6f5e ; $9eae  20 5e 6f
    bcc l_9eb6 ; $9eb1  90 03
    jmp $7936 ; $9eb3  4c 36 79
l_9eb6:
    jmp $8f5b ; $9eb6  4c 5b 8f
    jsr $7520 ; $9eb9  20 20 75
    jsr $740a ; $9ebc  20 0a 74

; Packed text: ' jumps into the shadows, '
    !byte $0f,$c0,$a3,$61,$20,$a9,$d3,$78,$66,$93,$06,$49,$11,$5f,$69,$6c ; $9ebf retained data / unresolved code
    !byte $20 ; $9ecf retained data / unresolved code
    ldx $83 ; $9ed0  a6 83
    lda #$06 ; $9ed2  a9 06
    jsr $6f83 ; $9ed4  20 83 6f
    ldx $83 ; $9ed7  a6 83
    bcc l_9ee4 ; $9ed9  90 09
    jsr $ff3e ; $9edb  20 3e ff
    ldy #$66 ; $9ede  a0 66
    cmp ($36),y ; $9ee0  d1 36
    bcs l_9ef5 ; $9ee2  b0 11
l_9ee4:
    inc $03be,x ; $9ee4  fe be 03
    jsr $740a ; $9ee7  20 0a 74

; Packed text: 'and succeeds!<$0d><$0d>'
    !byte $13,$8a,$19,$50,$84,$31,$8b,$2e,$77,$a0 ; $9eea retained data / unresolved code
    rts ; $9ef4  60
l_9ef5:
    lda #$00 ; $9ef5  a9 00
    sta $03be,x ; $9ef7  9d be 03
    jsr $740a ; $9efa  20 0a 74

; Packed text: 'but is discovered!<$0d><$0d>'
    !byte $1d,$26,$15,$48,$25,$54,$88,$fa,$9a,$26,$2f,$3b,$d0,$00 ; $9efd retained data / unresolved code
    rts ; $9f0b  60

; Enemy action dispatcher. Select a combatant record through
; $cd48/$cd4c; use action descriptors and the $9f71 jump table.
; Do not decode that pointer table as executable instructions.
dispatch_enemy_action:
    sta $86 ; $9f0c  85 86
    ora #$80 ; $9f0e  09 80
    sta $5c ; $9f10  85 5c
    txa ; $9f12  8a
    tay ; $9f13  a8
    ldx $86 ; $9f14  a6 86
    lda $cd48,x ; $9f16  bd 48 cd
    sta $12 ; $9f19  85 12
    lda $cd4c,x ; $9f1b  bd 4c cd
    sta $13 ; $9f1e  85 13
    lda #$00 ; $9f20  a9 00
    sta $4f ; $9f22  85 4f
    sta ($12),y ; $9f24  91 12
    ldx $86 ; $9f26  a6 86
    jsr $f9df ; $9f28  20 df f9

; Choose one of four monster actions at record offsets $16..$1d.
; First byte is spell ID (<$80) or special/physical opcode; second byte
; is action-dependent. $f0..$f9 use it as damage dice ($ad83/$fa5a).
    jsr $ff3e ; $9f2b  20 3e ff
    and #$06 ; $9f2e  29 06
    clc ; $9f30  18
    adc #$16 ; $9f31  69 16
    tay ; $9f33  a8
    lda ($49),y ; $9f34  b1 49
    sta $03c9 ; $9f36  8d c9 03
    pha ; $9f39  48
    iny ; $9f3a  c8
    lda ($49),y ; $9f3b  b1 49
    sta $03ca ; $9f3d  8d ca 03
    pla ; $9f40  68
    cmp #$80 ; $9f41  c9 80
    bcc l_9f5f ; $9f43  90 1a
    sec ; $9f45  38
    sbc #$f0 ; $9f46  e9 f0
    cmp #$10 ; $9f48  c9 10
    bcc l_9f4e ; $9f4a  90 02
    sbc #$80 ; $9f4c  e9 80
l_9f4e:
    pha ; $9f4e  48
    asl ; $9f4f  0a
    tax ; $9f50  aa
    lda $9f71,x ; $9f51  bd 71 9f
    sta $12 ; $9f54  85 12
    lda $9f72,x ; $9f56  bd 72 9f
    sta $13 ; $9f59  85 13
    pla ; $9f5b  68
    jmp ($0012) ; $9f5c  6c 12 00
l_9f5f:
    sta $58 ; $9f5f  85 58
    ldx $49 ; $9f61  a6 49
    ldy $4a ; $9f63  a4 4a
    stx $36 ; $9f65  86 36
    sty $37 ; $9f67  84 37
    jsr $ae48 ; $9f69  20 48 ae
    sta $5d ; $9f6c  85 5d
    jmp $e97f ; $9f6e  4c 7f e9

; Special enemy-action handler address table (20 little-endian pointers).
    !byte $4e,$a0,$4e,$a0,$4e,$a0,$4e,$a0,$4e,$a0,$4e,$a0,$4e,$a0,$4e,$a0 ; $9f71 retained data / unresolved code
    !byte $4e,$a0,$4e,$a0,$c4,$9f,$46,$a0,$46,$a0,$46,$a0,$46,$a0,$46,$a0 ; $9f81 retained data / unresolved code
    !byte $99,$9f,$46,$a0,$46,$a0,$47,$a0 ; $9f91 retained data / unresolved code
    jsr $ae48 ; $9f99  20 48 ae
    sta $5d ; $9f9c  85 5d
    ldx $49 ; $9f9e  a6 49
    ldy $4a ; $9fa0  a4 4a
    jsr $751c ; $9fa2  20 1c 75
    ldy #$1e ; $9fa5  a0 1e
    lda ($49),y ; $9fa7  b1 49
    jsr l_a768 ; $9fa9  20 68 a7
    ldx #$06 ; $9fac  a2 06
l_9fae:
    lda $a780,x ; $9fae  bd 80 a7
    sta $f5,x ; $9fb1  95 f5
    dex ; $9fb3  ca
    bpl l_9fae ; $9fb4  10 f8
    ldy #$1f ; $9fb6  a0 1f
    lda ($49),y ; $9fb8  b1 49
    sta $5b ; $9fba  85 5b
    lda $03ca ; $9fbc  ad ca 03
    sta $f9 ; $9fbf  85 f9
    jmp $efa1 ; $9fc1  4c a1 ef
    ldx $49 ; $9fc4  a6 49
    ldy $4a ; $9fc6  a4 4a
    jsr $751c ; $9fc8  20 1c 75
    jsr $740a ; $9fcb  20 0a 74

; Packed text: ' summons help and '
    !byte $0c,$a8,$d6,$bd,$d2,$0a,$4c,$c8,$04,$4e,$28,$40 ; $9fce retained data / unresolved code
    jsr $ff3e ; $9fda  20 3e ff
    cmp $03ca ; $9fdd  cd ca 03
    bcc l_9ff2 ; $9fe0  90 10
l_9fe2:
    jsr $740a ; $9fe2  20 0a 74

; Packed text: 'none appears...<$0d><$0d>'
    !byte $73,$dc,$60,$8a,$10,$30,$a3,$2c,$63,$1d,$e8,$00 ; $9fe5 retained data / unresolved code
    rts ; $9ff1  60
l_9ff2:
    ldy #$15 ; $9ff2  a0 15
    lda ($49),y ; $9ff4  b1 49
    tax ; $9ff6  aa
    and #$1f ; $9ff7  29 1f
    cmp #$1f ; $9ff9  c9 1f
    beq l_9fe2 ; $9ffb  f0 e5
    lda $7f ; $9ffd  a5 7f
    and #$02 ; $9fff  29 02
    bne l_9fe2 ; $a001  d0 df
    inx ; $a003  e8
    txa ; $a004  8a
    sta ($49),y ; $a005  91 49
    and #$1f ; $a007  29 1f
    tay ; $a009  a8
    ldx $86 ; $a00a  a6 86
    lda $cd48,x ; $a00c  bd 48 cd
    sta $36 ; $a00f  85 36
    lda $cd4c,x ; $a011  bd 4c cd
    sta $37 ; $a014  85 37
    lda #$00 ; $a016  a9 00
    sta ($36),y ; $a018  91 36
    lda $cd38,x ; $a01a  bd 38 cd
    sta $36 ; $a01d  85 36
    lda $cd3c,x ; $a01f  bd 3c cd
    sta $37 ; $a022  85 37
    tya ; $a024  98
    asl ; $a025  0a
    tay ; $a026  a8
    jsr $fa3b ; $a027  20 3b fa
    iny ; $a02a  c8
    sta ($36),y ; $a02b  91 36
    dey ; $a02d  88
    txa ; $a02e  8a
    sta ($36),y ; $a02f  91 36
    jsr $740a ; $a031  20 0a 74

; Packed text: 'another joins the fray!<$0d><$0d>'
    !byte $13,$9f,$34,$9a,$21,$f8,$0f,$53,$a4,$19,$a4,$c1,$3c,$45,$7e,$77 ; $a034 retained data / unresolved code
    !byte $a0 ; $a044 retained data / unresolved code
    rts ; $a045  60
    rts ; $a046  60
    ldx #$07 ; $a047  a2 07
    lda #$02 ; $a049  a9 02
    jmp $667d ; $a04b  4c 7d 66
    and #$0f ; $a04e  29 0f
    sta $03c8 ; $a050  8d c8 03

; Monster offset $13 packs distance in 10-foot units: low nibble
; is current distance; high nibble is the amount advanced ($a0af).
    ldy #$13 ; $a053  a0 13
    lda ($49),y ; $a055  b1 49
    and #$0f ; $a057  29 0f
    cmp #$02 ; $a059  c9 02
    bcc l_a0d2 ; $a05b  90 75
    ldy #$14 ; $a05d  a0 14
    lda ($49),y ; $a05f  b1 49
    and #$c0 ; $a061  29 c0
    cmp #$c0 ; $a063  c9 c0
    beq l_a074 ; $a065  f0 0d
    ldy #$15 ; $a067  a0 15
    lda ($49),y ; $a069  b1 49
    and #$1f ; $a06b  29 1f
    cmp #$02 ; $a06d  c9 02
    bcs l_a078 ; $a06f  b0 07
    jsr l_a14f ; $a071  20 4f a1
l_a074:
    lda #$00 ; $a074  a9 00
    beq l_a081 ; $a076  f0 09
l_a078:
    jsr $740a ; $a078  20 0a 74

; Packed text: 'The '
    !byte $f4,$d2,$60,$80 ; $a07b retained data / unresolved code
    lda #$01 ; $a07f  a9 01
l_a081:
    sta $4f ; $a081  85 4f
    ldx $49 ; $a083  a6 49
    ldy $4a ; $a085  a4 4a
    jsr $751c ; $a087  20 1c 75
    jsr $740a ; $a08a  20 0a 74

; Packed text: ' advance/s\\\\!<$0d><$0d>'
    !byte $08,$8b,$51,$38,$86,$fe,$92,$fe,$bf,$d7,$9d,$e8,$00 ; $a08d retained data / unresolved code
    ldx $86 ; $a09a  a6 86
    lda $cd48,x ; $a09c  bd 48 cd
    sta $12 ; $a09f  85 12
    lda $cd4c,x ; $a0a1  bd 4c cd
    sta $13 ; $a0a4  85 13
    ldy #$1f ; $a0a6  a0 1f
    lda #$00 ; $a0a8  a9 00
l_a0aa:
    sta ($12),y ; $a0aa  91 12
    dey ; $a0ac  88
    bpl l_a0aa ; $a0ad  10 fb
    ldy #$13 ; $a0af  a0 13
    lda ($49),y ; $a0b1  b1 49
    lsr ; $a0b3  4a
    lsr ; $a0b4  4a
    lsr ; $a0b5  4a
    lsr ; $a0b6  4a
    sta $12 ; $a0b7  85 12
    lda ($49),y ; $a0b9  b1 49
    and #$0f ; $a0bb  29 0f
    sec ; $a0bd  38
    sbc $12 ; $a0be  e5 12
    bcc l_a0c5 ; $a0c0  90 03
    tax ; $a0c2  aa
    bne l_a0c7 ; $a0c3  d0 02
l_a0c5:
    lda #$01 ; $a0c5  a9 01
l_a0c7:
    eor ($49),y ; $a0c7  51 49
    and #$0f ; $a0c9  29 0f
    eor ($49),y ; $a0cb  51 49
    sta ($49),y ; $a0cd  91 49
    jmp l_a141 ; $a0cf  4c 41 a1
l_a0d2:
    jsr l_a14f ; $a0d2  20 4f a1
    lda #$00 ; $a0d5  a9 00
    sta $4f ; $a0d7  85 4f
    ldx $49 ; $a0d9  a6 49
    ldy $4a ; $a0db  a4 4a
    jsr $751c ; $a0dd  20 1c 75
    jsr $8489 ; $a0e0  20 89 84
    ldy #$24 ; $a0e3  a0 24
    lda ($49),y ; $a0e5  b1 49
    and #$0f ; $a0e7  29 0f
    asl ; $a0e9  0a
    asl ; $a0ea  0a
    tax ; $a0eb  aa
    jsr $ff3e ; $a0ec  20 3e ff
    and #$02 ; $a0ef  29 02
    jsr l_ad05 ; $a0f1  20 05 ad
    ldy $b4e1,x ; $a0f4  bc e1 b4
    lda $b4e0,x ; $a0f7  bd e0 b4
    tax ; $a0fa  aa
    jsr $7419 ; $a0fb  20 19 74
    jsr $8489 ; $a0fe  20 89 84
    jsr $ae4b ; $a101  20 4b ae
    sta $5d ; $a104  85 5d
    jsr l_ad9b ; $a106  20 9b ad
    jsr l_ad1e ; $a109  20 1e ad
    bcc l_a11c ; $a10c  90 0e
    jsr $740a ; $a10e  20 0a 74

; Packed text: ', but misses'
    !byte $d8,$47,$49,$85,$aa,$94,$8d,$20,$00 ; $a111 retained data / unresolved code
    bcc l_a13b ; $a11a  90 1f
l_a11c:
    lda #$00 ; $a11c  a9 00
    jsr l_a70e ; $a11e  20 0e a7
    lda $5d ; $a121  a5 5d
    jsr l_a8bd ; $a123  20 bd a8
    bcc l_a13b ; $a126  90 13
    lda $95 ; $a128  a5 95
    asl ; $a12a  0a
    tax ; $a12b  aa
    ldy $d997,x ; $a12c  bc 97 d9
    lda $d996,x ; $a12f  bd 96 d9
    tax ; $a132  aa
    jsr $7419 ; $a133  20 19 74
    lda $5d ; $a136  a5 5d
    jsr $ecb8 ; $a138  20 b8 ec
l_a13b:
    jsr $740a ; $a13b  20 0a 74

; Packed text: '!<$0d><$0d>'
    !byte $e7,$7a,$00 ; $a13e retained data / unresolved code
l_a141:
    jsr $fb81 ; $a141  20 81 fb
    jsr $6f5e ; $a144  20 5e 6f
    bcc l_a14c ; $a147  90 03
    jmp $7936 ; $a149  4c 36 79
l_a14c:
    jmp $8f5b ; $a14c  4c 5b 8f
l_a14f:
    lda #$c1 ; $a14f  a9 c1
    jsr $848e ; $a151  20 8e 84
    ldy #$00 ; $a154  a0 00
    lda ($49),y ; $a156  b1 49
l_a158:
    cmp $a16c,y ; $a158  d9 6c a1
    beq l_a164 ; $a15b  f0 07
    iny ; $a15d  c8
    cpy #$05 ; $a15e  c0 05
    bcc l_a158 ; $a160  90 f6
    bcs l_a169 ; $a162  b0 05
l_a164:
    lda #$ee ; $a164  a9 ee
    jsr $848e ; $a166  20 8e 84
l_a169:
    jmp $8489 ; $a169  4c 89 84
    !byte $c1,$c5,$c9,$cf,$d5 ; $a16c retained data / unresolved code
l_a171:
    jsr l_a29b ; $a171  20 9b a2
    inc $5e ; $a174  e6 5e
    lda $98 ; $a176  a5 98
    beq l_a1a7 ; $a178  f0 2d
    lda $99 ; $a17a  a5 99
    jsr $91e2 ; $a17c  20 e2 91
    ldy #$1e ; $a17f  a0 1e
    lda ($12),y ; $a181  b1 12
    bne l_a191 ; $a183  d0 0c
    dey ; $a185  88
    lda ($12),y ; $a186  b1 12
    lsr ; $a188  4a
    lsr ; $a189  4a
    clc ; $a18a  18
    adc #$01 ; $a18b  69 01
    cmp #$0f ; $a18d  c9 0f
    bcc l_a193 ; $a18f  90 02
l_a191:
    lda #$0f ; $a191  a9 0f
l_a193:
    tay ; $a193  a8
    lda $9a ; $a194  a5 9a
    asl ; $a196  0a
    tax ; $a197  aa
    lda $a272,x ; $a198  bd 72 a2
    sta $a1a5 ; $a19b  8d a5 a1
    lda $a273,x ; $a19e  bd 73 a2
    sta $a1a6 ; $a1a1  8d a6 a1

; RAM IRQ vector high / unpatched operand placeholder
    jsr $ffff ; $a1a4  20 ff ff
l_a1a7:
    ldx #$ff ; $a1a7  a2 ff
    lda $61 ; $a1a9  a5 61
    beq l_a1b0 ; $a1ab  f0 03
    jmp l_a25e ; $a1ad  4c 5e a2
l_a1b0:
    lda #$00 ; $a1b0  a9 00
    sta $50 ; $a1b2  85 50
    lda $62 ; $a1b4  a5 62
    bne l_a1c7 ; $a1b6  d0 0f
l_a1b8:
    jsr $ff3e ; $a1b8  20 3e ff
    and #$03 ; $a1bb  29 03
    sta $89 ; $a1bd  85 89
    cmp $29 ; $a1bf  c5 29
    bcc l_a1c7 ; $a1c1  90 04
    beq l_a1c7 ; $a1c3  f0 02
    bcs l_a1b8 ; $a1c5  b0 f1
l_a1c7:
    lda $62 ; $a1c7  a5 62
    beq l_a1e2 ; $a1c9  f0 17
    ldx $50 ; $a1cb  a6 50
    jsr $f9df ; $a1cd  20 df f9
    ldy #$00 ; $a1d0  a0 00
    lda ($49),y ; $a1d2  b1 49
    asl ; $a1d4  0a
    tax ; $a1d5  aa
    lda $d53e,x ; $a1d6  bd 3e d5
    sta $38 ; $a1d9  85 38
    lda $d53f,x ; $a1db  bd 3f d5
    sta $39 ; $a1de  85 39
    bne l_a1fd ; $a1e0  d0 1b
l_a1e2:
    ldx #$00 ; $a1e2  a2 00
    ldy #$17 ; $a1e4  a0 17
    jsr $8dce ; $a1e6  20 ce 8d
    asl ; $a1e9  0a
    tax ; $a1ea  aa
    lda $d53e,x ; $a1eb  bd 3e d5
    sta $38 ; $a1ee  85 38
    lda $d53f,x ; $a1f0  bd 3f d5
    sta $39 ; $a1f3  85 39
    ldy #$24 ; $a1f5  a0 24
    lda ($38),y ; $a1f7  b1 38
    and #$20 ; $a1f9  29 20
    bne l_a1e2 ; $a1fb  d0 e5
l_a1fd:
    ldx $50 ; $a1fd  a6 50
    jsr $f9df ; $a1ff  20 df f9
    ldy #$2f ; $a202  a0 2f
l_a204:
    lda ($38),y ; $a204  b1 38
    cpy #$15 ; $a206  c0 15
    beq l_a20c ; $a208  f0 02
    sta ($49),y ; $a20a  91 49
l_a20c:
    dey ; $a20c  88
    bpl l_a204 ; $a20d  10 f5
    ldy #$15 ; $a20f  a0 15
    lda ($49),y ; $a211  b1 49
    pha ; $a213  48
    lda ($38),y ; $a214  b1 38
    sta ($49),y ; $a216  91 49
    pla ; $a218  68
    ldx $62 ; $a219  a6 62
    bne l_a22b ; $a21b  d0 0e
    lda ($38),y ; $a21d  b1 38
    and #$1f ; $a21f  29 1f
    bne l_a225 ; $a221  d0 02
    lda #$01 ; $a223  a9 01
l_a225:
    ldx #$01 ; $a225  a2 01
    tay ; $a227  a8
    jsr $8dce ; $a228  20 ce 8d
l_a22b:
    ldy #$15 ; $a22b  a0 15
    eor ($49),y ; $a22d  51 49
    and #$1f ; $a22f  29 1f
    eor ($49),y ; $a231  51 49
    sta ($49),y ; $a233  91 49
    ldx $50 ; $a235  a6 50
    lda $cd38,x ; $a237  bd 38 cd
    sta $38 ; $a23a  85 38
    lda $cd3c,x ; $a23c  bd 3c cd
    sta $39 ; $a23f  85 39
    ldy #$00 ; $a241  a0 00
l_a243:
    jsr $fa3b ; $a243  20 3b fa
    pha ; $a246  48
    txa ; $a247  8a
    sta ($38),y ; $a248  91 38
    iny ; $a24a  c8
    pla ; $a24b  68
    sta ($38),y ; $a24c  91 38
    iny ; $a24e  c8
    cpy #$40 ; $a24f  c0 40
    bcc l_a243 ; $a251  90 f0
    ldx $50 ; $a253  a6 50
    cpx $89 ; $a255  e4 89
    bcs l_a25e ; $a257  b0 05
    inc $50 ; $a259  e6 50
    jmp l_a1c7 ; $a25b  4c c7 a1
l_a25e:
    inx ; $a25e  e8
    cpx #$04 ; $a25f  e0 04
    bcs l_a271 ; $a261  b0 0e
    jsr $f9df ; $a263  20 df f9
    ldy #$2f ; $a266  a0 2f
    lda #$00 ; $a268  a9 00
l_a26a:
    sta ($49),y ; $a26a  91 49
    dey ; $a26c  88
    bpl l_a26a ; $a26d  10 fb
    bmi l_a25e ; $a26f  30 ed
l_a271:
    rts ; $a271  60
    !byte $82,$a2,$8c,$a2,$8c,$a2,$92,$a2,$96,$a2,$8c,$a2,$8d,$a2,$8c,$a2 ; $a272 retained data / unresolved code
    !byte $a9,$ff,$85,$97,$a9,$02,$05,$7f,$85,$7f,$60,$a9,$ff,$85,$fe,$60 ; $a282 retained data / unresolved code
    !byte $8c,$4e,$9c,$60,$a9,$01,$85,$7c,$60 ; $a292 retained data / unresolved code
l_a29b:
    lda $cd48 ; $a29b  ad 48 cd
    sta $12 ; $a29e  85 12
    lda $cd4c ; $a2a0  ad 4c cd
    sta $13 ; $a2a3  85 13
    lda $cd38 ; $a2a5  ad 38 cd
    sta $15 ; $a2a8  85 15
    lda $cd3c ; $a2aa  ad 3c cd
    sta $16 ; $a2ad  85 16
    ldy #$00 ; $a2af  a0 00
    tya ; $a2b1  98
l_a2b2:
    sta ($15),y ; $a2b2  91 15
    cpy #$80 ; $a2b4  c0 80
    bcs l_a2ba ; $a2b6  b0 02
    sta ($12),y ; $a2b8  91 12
l_a2ba:
    iny ; $a2ba  c8
    bne l_a2b2 ; $a2bb  d0 f5
    ldx #$06 ; $a2bd  a2 06
l_a2bf:
    sta $03be,x ; $a2bf  9d be 03
    sta $0300,x ; $a2c2  9d 00 03
    sta $0307,x ; $a2c5  9d 07 03
    sta $030e,x ; $a2c8  9d 0e 03
    cpx #$04 ; $a2cb  e0 04
    bcs l_a2e2 ; $a2cd  b0 13
    sta $0325,x ; $a2cf  9d 25 03
    sta $0315,x ; $a2d2  9d 15 03
    sta $0319,x ; $a2d5  9d 19 03
    sta $031d,x ; $a2d8  9d 1d 03
    cpx #$03 ; $a2db  e0 03
    bcs l_a2e2 ; $a2dd  b0 03
    sta $03c5,x ; $a2df  9d c5 03
l_a2e2:
    dex ; $a2e2  ca
    bpl l_a2bf ; $a2e3  10 da
    sta $0321 ; $a2e5  8d 21 03
    sta $7d ; $a2e8  85 7d
    sta $76 ; $a2ea  85 76
    sta $77 ; $a2ec  85 77
    sta $7a ; $a2ee  85 7a
    sta $7b ; $a2f0  85 7b
    sta $81 ; $a2f2  85 81
    sta $79 ; $a2f4  85 79
    sta $80 ; $a2f6  85 80
    sta $7f ; $a2f8  85 7f
    sta $7e ; $a2fa  85 7e
    sta $5e ; $a2fc  85 5e
    sta $9c4e ; $a2fe  8d 4e 9c
    sta $8d ; $a301  85 8d
    sta $7c ; $a303  85 7c
    sta $97 ; $a305  85 97
    sta $fe ; $a307  85 fe
l_a309:
    ldx #$06 ; $a309  a2 06
    lda #$02 ; $a30b  a9 02
l_a30d:
    sta $032a,x ; $a30d  9d 2a 03
    dex ; $a310  ca
    bpl l_a30d ; $a311  10 fa
    rts ; $a313  60

; Battle strategy menu. Packed prompts offer Fight bravely,
; Advance ahead, and Run away. Input processing selects the next battle phase.
choose_battle_strategy:
    lda #$00 ; $a314  a9 00
    sta $8a ; $a316  85 8a
    lda $61 ; $a318  a5 61
    bne l_a32e ; $a31a  d0 12
    ldx #$00 ; $a31c  a2 00
    jsr $f9df ; $a31e  20 df f9
    ldy #$15 ; $a321  a0 15
    lda ($49),y ; $a323  b1 49
    and #$1f ; $a325  29 1f
    bne l_a331 ; $a327  d0 08
    jsr l_b385 ; $a329  20 85 b3
    bcc l_a331 ; $a32c  90 03
l_a32e:
    jmp l_a3dc ; $a32e  4c dc a3
l_a331:
    jsr $740a ; $a331  20 0a 74

; Packed text: 'Will your gallant band choose to:<$0d>Fight bravely'
    !byte $f5,$94,$c6,$06,$ef,$a4,$42,$81,$31,$82,$74,$c2,$31,$38,$a1,$22 ; $a334 retained data / unresolved code
    !byte $5e,$f9,$18,$33,$7f,$fb,$ef,$dd,$52,$13,$30,$8e,$22,$a9,$99,$70 ; $a344 retained data / unresolved code
    !byte $00 ; $a354 retained data / unresolved code
    jsr l_a698 ; $a355  20 98 a6
    bcs $a36b ; $a358  b0 11
    jsr $740a ; $a35a  20 0a 74

; Packed text: '<$0d>Advance ahead'
    !byte $ef,$d8,$2d,$44,$e2,$18,$22,$49,$84,$50,$00 ; $a35d retained data / unresolved code
    lda #$c1 ; $a368  a9 c1
    !byte $2c,$a9,$80 ; $a36a retained data / unresolved code
    sta $a385 ; $a36d  8d 85 a3
    jsr $740a ; $a370  20 0a 74

; Packed text: '<$0d>Run away'
    !byte $ef,$e9,$a3,$82,$2b,$0a,$e0 ; $a373 retained data / unresolved code
    jsr $8b0f ; $a37a  20 0f 8b

; Inline input flags: $42, $20; following variable filter table remains unresolved
    !byte $42,$20,$c6,$dc,$a3,$d2,$b5,$a3,$c1,$89,$a3,$ff,$a2,$03,$20,$df ; $a37d retained data / unresolved code
    !byte $f9,$f0,$09,$a0,$13,$b1,$49,$38,$e9,$01,$91,$49,$ca,$10,$ef,$20 ; $a38d retained data / unresolved code
    !byte $09,$a3,$20,$0a,$74,$ef,$7d,$34,$98,$30,$14,$67,$70,$88,$b5,$13 ; $a39d retained data / unresolved code
    !byte $88,$69,$73,$bd,$00,$e6,$81,$60,$a5,$97,$d0,$0e,$20,$16,$6f,$ca ; $a3ad retained data / unresolved code
    !byte $a3,$90,$07,$20,$3e,$ff,$c9,$c0,$b0,$15,$e6,$8a,$60,$f0,$fd,$8a ; $a3bd retained data / unresolved code
    !byte $4a,$aa,$a9,$07,$20,$83,$6f,$b0,$04,$d0,$02,$68,$68,$18,$60 ; $a3cd retained data / unresolved code
l_a3dc:
    lda #$00 ; $a3dc  a9 00
    sta $88 ; $a3de  85 88
l_a3e0:
    jsr $8673 ; $a3e0  20 73 86
    lda $88 ; $a3e3  a5 88
    asl ; $a3e5  0a
    tax ; $a3e6  aa
    lda $d522,x ; $a3e7  bd 22 d5
    sta $36 ; $a3ea  85 36
    sta $38 ; $a3ec  85 38
    lda $d523,x ; $a3ee  bd 23 d5
    sta $37 ; $a3f1  85 37
    sta $39 ; $a3f3  85 39
    lda #$80 ; $a3f5  a9 80
    sta $a52e ; $a3f7  8d 2e a5
    sta $a53d ; $a3fa  8d 3d a5
    sta $a534 ; $a3fd  8d 34 a5
    sta $a53a ; $a400  8d 3a a5
    ldy #$00 ; $a403  a0 00
    lda ($36),y ; $a405  b1 36
    bne l_a40c ; $a407  d0 03
    jmp l_a675 ; $a409  4c 75 a6
l_a40c:
    ldy #$29 ; $a40c  a0 29
    lda ($36),y ; $a40e  b1 36
    cmp #$0d ; $a410  c9 0d
    bcs l_a429 ; $a412  b0 15
    ldy #$2d ; $a414  a0 2d
    lda ($36),y ; $a416  b1 36
    and #$1c ; $a418  29 1c
    bne l_a429 ; $a41a  d0 0d
    lda ($36),y ; $a41c  b1 36
    and #$60 ; $a41e  29 60
    beq l_a42c ; $a420  f0 0a
    ldx $88 ; $a422  a6 88
    lda #$08 ; $a424  a9 08
    sta $032a,x ; $a426  9d 2a 03
l_a429:
    jmp l_a658 ; $a429  4c 58 a6
l_a42c:
    lda $88 ; $a42c  a5 88
    jsr $fb90 ; $a42e  20 90 fb
    jsr $7520 ; $a431  20 20 75
    jsr $740a ; $a434  20 0a 74

; Packed text: ' has these options this battle round:<$0d><$0d>'
    !byte $0a,$45,$20,$cd,$26,$91,$82,$f8,$4d,$4f,$74,$83,$34,$aa,$41,$18 ; $a437 retained data / unresolved code
    !byte $a7,$36,$18,$31,$7d,$1c,$5f,$f7,$de,$80 ; $a447 retained data / unresolved code
    lda $61 ; $a451  a5 61
    bne l_a49d ; $a453  d0 48
    ldx #$00 ; $a455  a2 00
    jsr $f9df ; $a457  20 df f9
    beq l_a49d ; $a45a  f0 41
    ldy #$00 ; $a45c  a0 00
    lda ($49),y ; $a45e  b1 49
    beq l_a49d ; $a460  f0 3b
    ldx $88 ; $a462  a6 88
    lda $03be,x ; $a464  bd be 03
    bne $a470 ; $a467  d0 07
    cpx #$04 ; $a469  e0 04
    bcs l_a49d ; $a46b  b0 30
    lda #$00 ; $a46d  a9 00
    !byte $2c,$a9,$01 ; $a46f retained data / unresolved code
    sta $4f ; $a472  85 4f
    jsr $740a ; $a474  20 0a 74

; Packed text: 'Attack foes /<$0d>'
    !byte $fb,$13,$98,$88,$b0,$9d,$e6,$90,$7f,$a7,$40 ; $a477 retained data / unresolved code
    lda $4f ; $a482  a5 4f
    beq l_a498 ; $a484  f0 12
    ldx $88 ; $a486  a6 88
    lda $03be,x ; $a488  bd be 03
    clc ; $a48b  18
    adc #$b1 ; $a48c  69 b1
    jsr $848e ; $a48e  20 8e 84
    jsr $740a ; $a491  20 0a 74

; Packed text: "0'<$0d>"
    !byte $f8,$9a,$e8,$00 ; $a494 retained data / unresolved code
l_a498:
    lda #$c1 ; $a498  a9 c1
    sta $a52e ; $a49a  8d 2e a5
l_a49d:
    jsr $740a ; $a49d  20 0a 74

; Packed text: 'Defend<$0d>Party attack<$0d>'
    !byte $fb,$66,$39,$9c,$5e,$fe,$71,$46,$77,$08,$a7,$31,$11,$7d,$00 ; $a4a0 retained data / unresolved code
    ldy #$25 ; $a4af  a0 25
    lda ($36),y ; $a4b1  b1 36
    iny ; $a4b3  c8
    ora ($36),y ; $a4b4  11 36
    beq l_a4ca ; $a4b6  f0 12
    jsr $740a ; $a4b8  20 0a 74

; Packed text: 'Cast a spell<$0d>'
    !byte $fb,$42,$94,$c2,$20,$ca,$06,$63,$3a,$00 ; $a4bb retained data / unresolved code
    lda #$c3 ; $a4c5  a9 c3
    sta $a534 ; $a4c7  8d 34 a5
l_a4ca:
    jsr $740a ; $a4ca  20 0a 74

; Packed text: 'Use an item<$0d>'
    !byte $fd,$92,$30,$44,$e0,$aa,$66,$6f,$40 ; $a4cd retained data / unresolved code
    ldy #$29 ; $a4d6  a0 29
    lda ($36),y ; $a4d8  b1 36
    cmp #$05 ; $a4da  c9 05
    bne l_a4fd ; $a4dc  d0 1f
    ldx $88 ; $a4de  a6 88
    lda $03be,x ; $a4e0  bd be 03
    cmp #$08 ; $a4e3  c9 08
    bcs l_a519 ; $a4e5  b0 32
    jsr $740a ; $a4e7  20 0a 74

; Packed text: 'Hide in shadows<$0d>'
    !byte $fb,$ea,$29,$82,$a7,$06,$49,$11,$5f,$69,$74,$00 ; $a4ea retained data / unresolved code
    lda #$c8 ; $a4f6  a9 c8
    sta $a53a ; $a4f8  8d 3a a5
    bne l_a519 ; $a4fb  d0 1c
l_a4fd:
    cmp #$06 ; $a4fd  c9 06
    bne l_a519 ; $a4ff  d0 18
    ldx $88 ; $a501  a6 88
    jsr $6fbb ; $a503  20 bb 6f
    bcs l_a519 ; $a506  b0 11
    jsr $740a ; $a508  20 0a 74

; Packed text: 'Bard Song<$0d>'
    !byte $fb,$22,$89,$43,$e9,$3d,$c8,$e8,$00 ; $a50b retained data / unresolved code
    lda #$c2 ; $a514  a9 c2
    sta $a53d ; $a516  8d 3d a5
l_a519:
    jsr $740a ; $a519  20 0a 74

; Packed text: '<$0d>Select an option.'
    !byte $ef,$a4,$66,$18,$93,$08,$9c,$17,$c2,$6a,$7b,$b0,$00 ; $a51c retained data / unresolved code
    jsr $8b0f ; $a529  20 0f 8b

; Inline input flags: $42, $20; following variable filter table remains unresolved
    !byte $42,$20,$c1,$44,$a5,$c4,$47,$a5,$c3,$56,$a5,$d5,$4a,$a5,$c8,$4d ; $a52c retained data / unresolved code
    !byte $a5,$c2,$50,$a5,$d0,$53,$a5,$ff,$a0,$01,$2c,$a0,$02,$2c,$a0,$04 ; $a53c retained data / unresolved code
    !byte $2c,$a0,$05,$2c,$a0,$06,$2c,$a0,$07,$2c,$a0,$03,$08,$68,$85,$12 ; $a54c retained data / unresolved code
    !byte $a6,$88,$98,$9d,$2a,$03,$c9,$04,$f0,$03,$4c,$d6,$a5,$20,$07,$74 ; $a55c retained data / unresolved code
    !byte $f5,$92,$a2,$24,$2a,$99,$9b,$fe,$00,$a5,$88,$85,$5c,$a9,$00,$20 ; $a56c retained data / unresolved code
    !byte $6f,$87,$b0,$53,$aa,$bc,$73,$e9,$c8,$b1,$36,$20,$19,$6e,$b0,$30 ; $a57c retained data / unresolved code
    !byte $48,$a6,$88,$a5,$58,$9d,$32,$03,$98,$9d,$a9,$03,$68,$c9,$04,$b0 ; $a58c retained data / unresolved code
    !byte $17,$48,$20,$73,$86,$20,$e2,$ad,$20,$0a,$74,$ef,$a9,$23,$05,$ee ; $a59c retained data / unresolved code
    !byte $08,$00,$68,$20,$ab,$fa,$b0,$1f,$a6,$88,$9d,$a2,$03,$4c,$58,$a6 ; $a5ac retained data / unresolved code
    !byte $20,$07,$74,$f5,$df,$40,$90,$4e,$d4,$c3,$49,$18,$33,$48,$a6,$15 ; $a5bc retained data / unresolved code
    !byte $4c,$cd,$c0,$00,$20,$0d,$6f,$4c,$e0,$a3,$c9,$03,$f0,$03,$4c,$12 ; $a5cc retained data / unresolved code
    !byte $a6,$a5,$88,$85,$5c,$24,$12,$a9,$08,$20,$5f,$6e,$b0,$e9,$c9,$04 ; $a5dc retained data / unresolved code
    !byte $b0,$17,$48,$20,$73,$86,$20,$e2,$ad,$20,$0a,$74,$ef,$88,$29,$4c ; $a5ec retained data / unresolved code
    !byte $22,$98,$40,$68,$20,$ab,$fa,$b0,$ce,$a6,$88,$9d,$32,$03,$a5,$58 ; $a5fc retained data / unresolved code
    !byte $9d,$b0,$03,$4c,$58,$a6,$c9,$01,$d0,$28,$a9,$02,$48,$a2,$01,$20 ; $a60c retained data / unresolved code
    !byte $df,$f9,$f0,$10,$20,$73,$86,$20,$e2,$ad,$20,$0a,$74,$ef,$85,$39 ; $a61c retained data / unresolved code
    !byte $88,$8b,$08,$00,$68,$20,$ab,$fa,$b0,$11,$a6,$88,$9d,$32,$03,$4c ; $a62c retained data / unresolved code
    !byte $58,$a6,$c9,$07,$d0,$08,$a9,$01,$48,$d0,$d9,$4c,$e0,$a3,$c9,$06 ; $a63c retained data / unresolved code
    !byte $d0,$0a,$20,$14,$6c,$b0,$f4,$a6,$88,$9d,$32,$03 ; $a64c retained data / unresolved code
l_a658:
    ldy #$67 ; $a658  a0 67
    lda ($36),y ; $a65a  b1 36
    beq l_a665 ; $a65c  f0 07
    ldx $88 ; $a65e  a6 88
    lda #$08 ; $a660  a9 08
    sta $032a,x ; $a662  9d 2a 03
l_a665:
    lda $88 ; $a665  a5 88
    jsr $fb93 ; $a667  20 93 fb
    inc $88 ; $a66a  e6 88
    lda $88 ; $a66c  a5 88
    cmp #$07 ; $a66e  c9 07
    bcs l_a675 ; $a670  b0 03
    jmp l_a3e0 ; $a672  4c e0 a3
l_a675:
    jsr $7407 ; $a675  20 07 74

; Packed text: 'Use these commands?<$0d><$0d>'
    !byte $f5,$24,$60,$cd,$26,$91,$82,$47,$b5,$a2,$71,$65,$fe,$3b,$d0,$00 ; $a678 retained data / unresolved code
    jsr $7e10 ; $a688  20 10 7e
    bcc l_a690 ; $a68b  90 03
    jmp l_a3dc ; $a68d  4c dc a3
l_a690:
    jsr $8673 ; $a690  20 73 86
    lda #$55 ; $a693  a9 55
    sta $22 ; $a695  85 22
    rts ; $a697  60
l_a698:
    ldx #$03 ; $a698  a2 03
l_a69a:
    jsr $f9df ; $a69a  20 df f9
    sta $12 ; $a69d  85 12
    beq l_a6ab ; $a69f  f0 0a
    ldy #$13 ; $a6a1  a0 13
    lda ($49),y ; $a6a3  b1 49
    and #$0f ; $a6a5  29 0f
    cmp #$02 ; $a6a7  c9 02
    bcc l_a6b4 ; $a6a9  90 09
l_a6ab:
    dex ; $a6ab  ca
    bpl l_a69a ; $a6ac  10 ec
    lda $12 ; $a6ae  a5 12
    beq l_a6b4 ; $a6b0  f0 02
    clc ; $a6b2  18
    rts ; $a6b3  60
l_a6b4:
    sec ; $a6b4  38
    rts ; $a6b5  60
l_a6b6:
    ldy #$06 ; $a6b6  a0 06
    lda #$00 ; $a6b8  a9 00
l_a6ba:
    cmp $03b7,y ; $a6ba  d9 b7 03
    bcs l_a6c4 ; $a6bd  b0 05
    tya ; $a6bf  98
    tax ; $a6c0  aa
    lda $03b7,y ; $a6c1  b9 b7 03
l_a6c4:
    dey ; $a6c4  88
    bpl l_a6ba ; $a6c5  10 f3
    tay ; $a6c7  a8
    rts ; $a6c8  60
l_a6c9:
    lda $0321 ; $a6c9  ad 21 03
    bne l_a70b ; $a6cc  d0 3d
    ldx #$00 ; $a6ce  a2 00
    stx $86 ; $a6d0  86 86
    stx $8b ; $a6d2  86 8b
l_a6d4:
    ldx $86 ; $a6d4  a6 86
    jsr $f9df ; $a6d6  20 df f9
    beq l_a6fc ; $a6d9  f0 21
    sta $15 ; $a6db  85 15
    lda $cd48,x ; $a6dd  bd 48 cd
    sta $12 ; $a6e0  85 12
    lda $cd4c,x ; $a6e2  bd 4c cd
    sta $13 ; $a6e5  85 13
    ldy #$00 ; $a6e7  a0 00
l_a6e9:
    lda ($12),y ; $a6e9  b1 12
    and #$fe ; $a6eb  29 fe
    cmp $8b ; $a6ed  c5 8b
    bcc l_a6f7 ; $a6ef  90 06
    sta $8b ; $a6f1  85 8b
    sty $16 ; $a6f3  84 16
    stx $3c ; $a6f5  86 3c
l_a6f7:
    iny ; $a6f7  c8
    cpy $15 ; $a6f8  c4 15
    bcc l_a6e9 ; $a6fa  90 ed
l_a6fc:
    inc $86 ; $a6fc  e6 86
    lda $86 ; $a6fe  a5 86
    cmp #$04 ; $a700  c9 04
    bcc l_a6d4 ; $a702  90 d0
    lda $3c ; $a704  a5 3c
    ldx $16 ; $a706  a6 16
    ldy $8b ; $a708  a4 8b
    rts ; $a70a  60
l_a70b:
    ldy #$00 ; $a70b  a0 00
    rts ; $a70d  60
l_a70e:
    sta $9b ; $a70e  85 9b
    tax ; $a710  aa
    beq l_a734 ; $a711  f0 21
    inc $9b ; $a713  e6 9b
    lda #$00 ; $a715  a9 00
    sta $9c ; $a717  85 9c
    jsr $740a ; $a719  20 0a 74

; Packed text: ', and hits '
    !byte $d8,$44,$e2,$85,$2a,$9c,$82,$00 ; $a71c retained data / unresolved code
    jsr $7285 ; $a724  20 85 72
    jsr $740a ; $a727  20 0a 74

; Packed text: ' times for '
    !byte $0c,$d4,$d3,$48,$27,$7c,$42,$00 ; $a72a retained data / unresolved code
    bcc l_a741 ; $a732  90 0d
l_a734:
    jsr $740a ; $a734  20 0a 74

; Packed text: ', and hits for '
    !byte $d8,$44,$e2,$85,$2a,$9c,$82,$77,$c4,$20 ; $a737 retained data / unresolved code
l_a741:
    lda $93 ; $a741  a5 93
    sta $4f ; $a743  85 4f
    dec $4f ; $a745  c6 4f
    sta $9b ; $a747  85 9b
    lda $94 ; $a749  a5 94
    beq l_a74f ; $a74b  f0 02
    inc $4f ; $a74d  e6 4f
l_a74f:
    sta $9c ; $a74f  85 9c
    jsr $7285 ; $a751  20 85 72
    jsr $740a ; $a754  20 0a 74

; Packed text: ' point/\\s\\ of damage'
    !byte $0c,$1e,$a7,$4f,$fa,$7f,$59,$7f,$50,$bc,$e1,$28,$9a,$24,$18,$00 ; $a757 retained data / unresolved code
    rts ; $a767  60
l_a768:
    asl ; $a768  0a
    sta $f7 ; $a769  85 f7
    eor #$14 ; $a76b  49 14
    sta $4f ; $a76d  85 4f
    jsr $740a ; $a76f  20 0a 74

; Packed text: ' /fir\\breath\\es '
    !byte $0f,$f4,$3a,$a3,$fd,$47,$13,$0a,$69,$fe,$a6,$90,$40 ; $a772 retained data / unresolved code
    rts ; $a77f  60
    !byte $00,$00,$00,$00,$00,$41,$01 ; $a780 retained data / unresolved code
l_a787:
    jsr l_a309 ; $a787  20 09 a3
    lda $80 ; $a78a  a5 80
    beq l_a793 ; $a78c  f0 05
    jsr $6f16 ; $a78e  20 16 6f

; Inline party callback: $a8aa
    !byte $aa,$a8 ; $a791 retained data / unresolved code
l_a793:
    lda #$00 ; $a793  a9 00
    sta $88 ; $a795  85 88
    sta $80 ; $a797  85 80
    jsr $6f5e ; $a799  20 5e 6f
    bcc l_a79f ; $a79c  90 01
    rts ; $a79e  60
l_a79f:
    adc #$01 ; $a79f  69 01
    sta $12 ; $a7a1  85 12
l_a7a3:
    lda $88 ; $a7a3  a5 88
    asl ; $a7a5  0a
    tax ; $a7a6  aa
    lda $d522,x ; $a7a7  bd 22 d5
    sta $36 ; $a7aa  85 36
    lda $d523,x ; $a7ac  bd 23 d5
    sta $37 ; $a7af  85 37
    ldy #$2d ; $a7b1  a0 2d
    lda ($36),y ; $a7b3  b1 36
    and #$1c ; $a7b5  29 1c
    bne l_a7c4 ; $a7b7  d0 0b
    inc $88 ; $a7b9  e6 88
    lda $88 ; $a7bb  a5 88
    cmp $12 ; $a7bd  c5 12
    bcc l_a7a3 ; $a7bf  90 e2
    jmp l_a82b ; $a7c1  4c 2b a8
l_a7c4:
    ldy $88 ; $a7c4  a4 88
    cpy $99 ; $a7c6  c4 99
    bne l_a7ce ; $a7c8  d0 04
    lda #$00 ; $a7ca  a9 00
    sta $98 ; $a7cc  85 98
l_a7ce:
    bcs l_a7d2 ; $a7ce  b0 02
    dec $99 ; $a7d0  c6 99
l_a7d2:
    cpy #$06 ; $a7d2  c0 06
    beq l_a7f3 ; $a7d4  f0 1d
l_a7d6:
    lda $0301,y ; $a7d6  b9 01 03
    sta $0300,y ; $a7d9  99 00 03
    lda $0308,y ; $a7dc  b9 08 03
    sta $0307,y ; $a7df  99 07 03
    lda $030f,y ; $a7e2  b9 0f 03
    sta $030e,y ; $a7e5  99 0e 03
    lda $03bf,y ; $a7e8  b9 bf 03
    sta $03be,y ; $a7eb  99 be 03
    iny ; $a7ee  c8
    cpy #$06 ; $a7ef  c0 06
    bcc l_a7d6 ; $a7f1  90 e3
l_a7f3:
    lda #$00 ; $a7f3  a9 00
    sta $0300,y ; $a7f5  99 00 03
    sta $0307,y ; $a7f8  99 07 03
    sta $030e,y ; $a7fb  99 0e 03
    sta $03be,y ; $a7fe  99 be 03
    ldy #$77 ; $a801  a0 77
l_a803:
    lda ($36),y ; $a803  b1 36
    sta $ba00,y ; $a805  99 00 ba
    dey ; $a808  88
    bpl l_a803 ; $a809  10 f8
    txa ; $a80b  8a
    jsr $6d44 ; $a80c  20 44 6d
    lda $ba29 ; $a80f  ad 29 ba
    cmp #$0e ; $a812  c9 0e
    beq l_a828 ; $a814  f0 12
    lda $ba67 ; $a816  ad 67 ba
    bne l_a828 ; $a819  d0 0d
    jsr $6f4a ; $a81b  20 4a 6f
    ldy #$77 ; $a81e  a0 77
l_a820:
    lda $ba00,y ; $a820  b9 00 ba
    sta ($36),y ; $a823  91 36
    dey ; $a825  88
    bpl l_a820 ; $a826  10 f8
l_a828:
    jmp l_a793 ; $a828  4c 93 a7
l_a82b:
    ldx #$03 ; $a82b  a2 03
l_a82d:
    jsr $f9df ; $a82d  20 df f9
    bne l_a837 ; $a830  d0 05
    dex ; $a832  ca
    bpl l_a82d ; $a833  10 f8
    clc ; $a835  18
    rts ; $a836  60
l_a837:
    stx $89 ; $a837  86 89
l_a839:
    jsr $f9df ; $a839  20 df f9
    beq l_a843 ; $a83c  f0 05
    dex ; $a83e  ca
    bpl l_a839 ; $a83f  10 f8
    clc ; $a841  18
    rts ; $a842  60
l_a843:
    stx $12 ; $a843  86 12
l_a845:
    lda $cd38,x ; $a845  bd 38 cd
    sta $36 ; $a848  85 36
    lda $cd3c,x ; $a84a  bd 3c cd
    sta $37 ; $a84d  85 37
    inx ; $a84f  e8
    cpx #$04 ; $a850  e0 04
    bcs l_a86b ; $a852  b0 17
    lda $cd38,x ; $a854  bd 38 cd
    sta $38 ; $a857  85 38
    lda $cd3c,x ; $a859  bd 3c cd
    sta $39 ; $a85c  85 39
    ldy #$00 ; $a85e  a0 00
l_a860:
    lda ($38),y ; $a860  b1 38
    sta ($36),y ; $a862  91 36
    iny ; $a864  c8
    cpy #$40 ; $a865  c0 40
    bcc l_a860 ; $a867  90 f7
    bcs l_a845 ; $a869  b0 da
l_a86b:
    ldy #$00 ; $a86b  a0 00
    tya ; $a86d  98
l_a86e:
    sta ($36),y ; $a86e  91 36
    iny ; $a870  c8
    cpy #$40 ; $a871  c0 40
    bcc l_a86e ; $a873  90 f9
    ldx $12 ; $a875  a6 12
l_a877:
    lda $cd28,x ; $a877  bd 28 cd
    sta $36 ; $a87a  85 36
    lda $cd2c,x ; $a87c  bd 2c cd
    sta $37 ; $a87f  85 37
    inx ; $a881  e8
    cpx #$04 ; $a882  e0 04
    bcs l_a89d ; $a884  b0 17
    lda $cd28,x ; $a886  bd 28 cd
    sta $38 ; $a889  85 38
    lda $cd2c,x ; $a88b  bd 2c cd
    sta $39 ; $a88e  85 39
    ldy #$00 ; $a890  a0 00
l_a892:
    lda ($38),y ; $a892  b1 38
    sta ($36),y ; $a894  91 36
    iny ; $a896  c8
    cpy #$30 ; $a897  c0 30
    bcc l_a892 ; $a899  90 f7
    bcs l_a877 ; $a89b  b0 da
l_a89d:
    ldy #$00 ; $a89d  a0 00
    tya ; $a89f  98
l_a8a0:
    sta ($36),y ; $a8a0  91 36
    iny ; $a8a2  c8
    cpy #$30 ; $a8a3  c0 30
    bcc l_a8a0 ; $a8a5  90 f9
    jmp l_a82b ; $a8a7  4c 2b a8
    beq l_a8bc ; $a8aa  f0 10
    ldy #$29 ; $a8ac  a0 29
    lda ($12),y ; $a8ae  b1 12
    cmp #$0e ; $a8b0  c9 0e
    bne l_a8bc ; $a8b2  d0 08
    ldy #$2d ; $a8b4  a0 2d
    lda #$04 ; $a8b6  a9 04
    ora ($12),y ; $a8b8  11 12
    sta ($12),y ; $a8ba  91 12
l_a8bc:
    rts ; $a8bc  60
l_a8bd:
    ora #$00 ; $a8bd  09 00
    bmi l_a8c4 ; $a8bf  30 03
    jmp l_a98d ; $a8c1  4c 8d a9
l_a8c4:
    and #$7f ; $a8c4  29 7f
    sta $8c ; $a8c6  85 8c
    tax ; $a8c8  aa
    jsr $f9df ; $a8c9  20 df f9
    ldy $8c ; $a8cc  a4 8c
    lda $cd48,y ; $a8ce  b9 48 cd
    sta $3c ; $a8d1  85 3c
    lda $cd4c,y ; $a8d3  b9 4c cd
    sta $3d ; $a8d6  85 3d
    ldy #$15 ; $a8d8  a0 15
    lda ($49),y ; $a8da  b1 49
    and #$1f ; $a8dc  29 1f
    beq l_a933 ; $a8de  f0 53
    sta $15 ; $a8e0  85 15
    asl ; $a8e2  0a
    sta $16 ; $a8e3  85 16
    ldy #$00 ; $a8e5  a0 00
l_a8e7:
    lda ($3c),y ; $a8e7  b1 3c
    lsr ; $a8e9  4a
    bcs l_a8fb ; $a8ea  b0 0f
    iny ; $a8ec  c8
    cpy $15 ; $a8ed  c4 15
    bcc l_a8e7 ; $a8ef  90 f6
l_a8f1:
    dey ; $a8f1  88
    lda ($3c),y ; $a8f2  b1 3c
    ora #$01 ; $a8f4  09 01
    sta ($3c),y ; $a8f6  91 3c
    tya ; $a8f8  98
    bne l_a8f1 ; $a8f9  d0 f6
l_a8fb:
    lda ($3c),y ; $a8fb  b1 3c
    and #$fe ; $a8fd  29 fe
    sta ($3c),y ; $a8ff  91 3c
    sty $8b ; $a901  84 8b
    lda $cd38,x ; $a903  bd 38 cd
    sta $12 ; $a906  85 12
    lda $cd3c,x ; $a908  bd 3c cd
    sta $13 ; $a90b  85 13
    tya ; $a90d  98
    asl ; $a90e  0a
    tay ; $a90f  a8
    lda $95 ; $a910  a5 95
    cmp #$08 ; $a912  c9 08
    bcs l_a91a ; $a914  b0 04
    cmp #$06 ; $a916  c9 06
    bcs l_a935 ; $a918  b0 1b
l_a91a:
    lda #$00 ; $a91a  a9 00
    sta $95 ; $a91c  85 95
    lda ($12),y ; $a91e  b1 12
    sec ; $a920  38
    sbc $93 ; $a921  e5 93
    sta ($12),y ; $a923  91 12
    iny ; $a925  c8
    lda ($12),y ; $a926  b1 12
    sbc $94 ; $a928  e5 94
    sta ($12),y ; $a92a  91 12
    bcc l_a936 ; $a92c  90 08
    dey ; $a92e  88
    ora ($12),y ; $a92f  11 12
    beq l_a935 ; $a931  f0 02
l_a933:
    clc ; $a933  18
    rts ; $a934  60
l_a935:
    iny ; $a935  c8
l_a936:
    iny ; $a936  c8
    lda ($12),y ; $a937  b1 12
    tax ; $a939  aa
    iny ; $a93a  c8
    lda ($12),y ; $a93b  b1 12
    dey ; $a93d  88
    dey ; $a93e  88
    sta ($12),y ; $a93f  91 12
    txa ; $a941  8a
    dey ; $a942  88
    sta ($12),y ; $a943  91 12
    iny ; $a945  c8
    iny ; $a946  c8
    cpy $16 ; $a947  c4 16
    bcc l_a935 ; $a949  90 ea
    ldy $8b ; $a94b  a4 8b
l_a94d:
    iny ; $a94d  c8
    lda ($3c),y ; $a94e  b1 3c
    dey ; $a950  88
    sta ($3c),y ; $a951  91 3c
    iny ; $a953  c8
    cpy $15 ; $a954  c4 15
    bcc l_a94d ; $a956  90 f5
    ldy #$15 ; $a958  a0 15
    lda ($49),y ; $a95a  b1 49
    sec ; $a95c  38
    sbc #$01 ; $a95d  e9 01
    sta ($49),y ; $a95f  91 49
    and #$1f ; $a961  29 1f
    bne l_a96d ; $a963  d0 08
    ldy #$24 ; $a965  a0 24
    lda ($49),y ; $a967  b1 49
    and #$ef ; $a969  29 ef
    sta ($49),y ; $a96b  91 49
l_a96d:
    ldy #$21 ; $a96d  a0 21
    ldx #$00 ; $a96f  a2 00
    clc ; $a971  18
l_a972:
    lda ($49),y ; $a972  b1 49
    adc $03c5,x ; $a974  7d c5 03
    sta $03c5,x ; $a977  9d c5 03
    iny ; $a97a  c8
    inx ; $a97b  e8
    txa ; $a97c  8a
    eor #$03 ; $a97d  49 03
    bne l_a972 ; $a97f  d0 f1
    bcc l_a98b ; $a981  90 08
    lda #$ff ; $a983  a9 ff
l_a985:
    sta $03c4,x ; $a985  9d c4 03
    dex ; $a988  ca
    bne l_a985 ; $a989  d0 fa
l_a98b:
    sec ; $a98b  38
    rts ; $a98c  60
l_a98d:
    sta $8c ; $a98d  85 8c
    asl ; $a98f  0a
    tax ; $a990  aa
    lda $d522,x ; $a991  bd 22 d5
    sta $38 ; $a994  85 38
    lda $d523,x ; $a996  bd 23 d5
    sta $39 ; $a999  85 39
    ldy #$00 ; $a99b  a0 00
    lda ($38),y ; $a99d  b1 38
    beq l_a98b ; $a99f  f0 ea
    ldy #$2d ; $a9a1  a0 2d
    lda ($38),y ; $a9a3  b1 38
    and #$04 ; $a9a5  29 04
    beq l_a9b1 ; $a9a7  f0 08
    lda $95 ; $a9a9  a5 95
    cmp #$05 ; $a9ab  c9 05
    beq l_a9ce ; $a9ad  f0 1f
    bne l_a98b ; $a9af  d0 da
l_a9b1:
    lda ($38),y ; $a9b1  b1 38
    and #$08 ; $a9b3  29 08
    bne l_a98b ; $a9b5  d0 d4
    ldy #$21 ; $a9b7  a0 21
    sec ; $a9b9  38
    lda ($38),y ; $a9ba  b1 38
    sbc $93 ; $a9bc  e5 93
    sta ($38),y ; $a9be  91 38
    iny ; $a9c0  c8
    lda ($38),y ; $a9c1  b1 38
    sbc $94 ; $a9c3  e5 94
    sta ($38),y ; $a9c5  91 38
    bcc l_a9f3 ; $a9c7  90 2a
    dey ; $a9c9  88
    ora ($38),y ; $a9ca  11 38
    beq l_a9f3 ; $a9cc  f0 25
l_a9ce:
    lda $95 ; $a9ce  a5 95
    asl ; $a9d0  0a
    tax ; $a9d1  aa
    lda $a9df,x ; $a9d2  bd df a9
    sta $12 ; $a9d5  85 12
    lda $a9e0,x ; $a9d7  bd e0 a9
    sta $13 ; $a9da  85 13
    jmp ($0012) ; $a9dc  6c 12 00
    !byte $28,$aa,$0c,$aa,$2e,$aa,$09,$aa,$6e,$aa,$a0,$aa,$f9,$a9,$f6,$a9 ; $a9df retained data / unresolved code
    !byte $c2,$aa,$e1,$aa ; $a9ef retained data / unresolved code
l_a9f3:
    jsr l_aa28 ; $a9f3  20 28 aa
    ldx #$04 ; $a9f6  a2 04
    bit $08a2 ; $a9f8  2c a2 08
    ldy #$21 ; $a9fb  a0 21
    lda #$00 ; $a9fd  a9 00
    sta ($38),y ; $a9ff  91 38
    iny ; $aa01  c8
    sta ($38),y ; $aa02  91 38
    ldy #$68 ; $aa04  a0 68
    sta ($38),y ; $aa06  91 38
    bit $40a2 ; $aa08  2c a2 40
    bit $01a2 ; $aa0b  2c a2 01
    txa ; $aa0e  8a
    ldy #$2d ; $aa0f  a0 2d
    ora ($38),y ; $aa11  11 38
    sta ($38),y ; $aa13  91 38
    and #$1c ; $aa15  29 1c
    beq l_aa1e ; $aa17  f0 05
    lda $8c ; $aa19  a5 8c
    jsr $922a ; $aa1b  20 2a 92
l_aa1e:
    jsr $6f5e ; $aa1e  20 5e 6f
    bcs l_aa25 ; $aa21  b0 02
    sec ; $aa23  38
    rts ; $aa24  60
l_aa25:
    jmp $7936 ; $aa25  4c 36 79
l_aa28:
    lda #$00 ; $aa28  a9 00
    sta $95 ; $aa2a  85 95
    clc ; $aa2c  18
    rts ; $aa2d  60
    !byte $a0,$29,$b1,$38,$c9,$0d,$b0,$f2,$a0,$1e,$b1,$38,$d0,$07,$88,$b1 ; $aa2e retained data / unresolved code
    !byte $38,$c9,$01,$f0,$e5,$a0,$1d,$b1,$38,$38,$e9,$01,$91,$38,$85,$4b ; $aa3e retained data / unresolved code
    !byte $c8,$b1,$38,$e9,$00,$91,$38,$85,$4c,$a5,$4b,$38,$e9,$01,$85,$4b ; $aa4e retained data / unresolved code
    !byte $b0,$02,$c6,$4c,$a0,$29,$b1,$38,$20,$16,$76,$20,$37,$72,$38,$60 ; $aa5e retained data / unresolved code
    !byte $a0,$29,$b1,$38,$c9,$0d,$b0,$b2,$a0,$2d,$b1,$38,$29,$02,$d0,$aa ; $aa6e retained data / unresolved code
    !byte $a5,$38,$18,$69,$5a,$85,$3c,$a5,$39,$69,$00,$85,$3d,$a0,$10,$a2 ; $aa7e retained data / unresolved code
    !byte $05,$b1,$38,$91,$3c,$a9,$01,$91,$38,$c8,$ca,$d0,$f4,$a2,$02,$4c ; $aa8e retained data / unresolved code
    !byte $0e,$aa,$a0,$21,$a9,$64,$91,$38,$c8,$a9,$00,$91,$38,$a0,$2d,$b1 ; $aa9e retained data / unresolved code
    !byte $38,$29,$fb,$91,$38,$a5,$5c,$10,$06,$a0,$68,$a9,$01,$91,$38,$a2 ; $aaae retained data / unresolved code
    !byte $20,$4c,$0e,$aa,$a0,$30,$8c,$ce,$aa,$b1,$38,$aa,$20,$24,$79,$a0 ; $aabe retained data / unresolved code
    !byte $00,$c9,$01,$d0,$06,$b1,$38,$29,$fc,$91,$38,$c8,$c8,$c8,$c0,$54 ; $aace retained data / unresolved code
    !byte $90,$e4,$60,$a0,$25,$a9,$00,$91,$38,$c8,$91,$38,$38,$60 ; $aade retained data / unresolved code
l_aaec:
    lda #$00 ; $aaec  a9 00
    sta $95 ; $aaee  85 95
    lda $5d ; $aaf0  a5 5d
    bmi l_aafe ; $aaf2  30 0a
    jsr $91e2 ; $aaf4  20 e2 91
    ldy #$2e ; $aaf7  a0 2e
    lda ($12),y ; $aaf9  b1 12
    jmp l_ab53 ; $aafb  4c 53 ab
l_aafe:
    tax ; $aafe  aa
    jsr $f9df ; $aaff  20 df f9
    ldy #$13 ; $ab02  a0 13
    lda ($49),y ; $ab04  b1 49
    and #$0f ; $ab06  29 0f
    beq l_ab18 ; $ab08  f0 0e
    sec ; $ab0a  38
    sbc #$01 ; $ab0b  e9 01
    ldx $83 ; $ab0d  a6 83
    cmp $03be,x ; $ab0f  dd be 03
    beq l_ab18 ; $ab12  f0 04
    bcc l_ab18 ; $ab14  90 02
    sec ; $ab16  38
    rts ; $ab17  60
l_ab18:
    ldy #$14 ; $ab18  a0 14
    lda ($49),y ; $ab1a  b1 49
    and #$3f ; $ab1c  29 3f
    tax ; $ab1e  aa
    ldy #$24 ; $ab1f  a0 24
    lda ($49),y ; $ab21  b1 49
    rol ; $ab23  2a
    rol ; $ab24  2a
    rol ; $ab25  2a
    and #$03 ; $ab26  29 03
    tay ; $ab28  a8
    lda $abfe,y ; $ab29  b9 fe ab
    jsr l_ad12 ; $ab2c  20 12 ad
    ldy #$13 ; $ab2f  a0 13
    lda ($49),y ; $ab31  b1 49
    lsr ; $ab33  4a
    lsr ; $ab34  4a
    lsr ; $ab35  4a
    lsr ; $ab36  4a
    tay ; $ab37  a8
    lda $ac02,y ; $ab38  b9 02 ac
    jsr l_ad12 ; $ab3b  20 12 ad
    ldy $5d ; $ab3e  a4 5d
    lda $029d,y ; $ab40  b9 9d 02
    bmi l_ab4b ; $ab43  30 06
    jsr l_acf8 ; $ab45  20 f8 ac
    jmp l_ab53 ; $ab48  4c 53 ab
l_ab4b:
    eor #$ff ; $ab4b  49 ff
    clc ; $ab4d  18
    adc #$01 ; $ab4e  69 01
    jsr l_ad12 ; $ab50  20 12 ad
l_ab53:
    sta $8c ; $ab53  85 8c
    lda #$00 ; $ab55  a9 00
    sta $ac7f ; $ab57  8d 7f ac
    lda #$01 ; $ab5a  a9 01
    jsr $78f9 ; $ab5c  20 f9 78
    bcs l_ab79 ; $ab5f  b0 18
    jsr $7924 ; $ab61  20 24 79
    lsr ; $ab64  4a
    lsr ; $ab65  4a
    lsr ; $ab66  4a
    lsr ; $ab67  4a
    sta $95 ; $ab68  85 95
    tya ; $ab6a  98
    lsr ; $ab6b  4a
    lsr ; $ab6c  4a
    lsr ; $ab6d  4a
    lsr ; $ab6e  4a
    sta $ac7f ; $ab6f  8d 7f ac
    ldx $8c ; $ab72  a6 8c
    jsr l_acf8 ; $ab74  20 f8 ac
    sta $8c ; $ab77  85 8c
l_ab79:
    ldx $8c ; $ab79  a6 8c
    lda $7d ; $ab7b  a5 7d
    jsr l_ad05 ; $ab7d  20 05 ad
    ldy #$29 ; $ab80  a0 29
    lda ($36),y ; $ab82  b1 36
    cmp #$0d ; $ab84  c9 0d
    bcc l_ab9d ; $ab86  90 15
    txa ; $ab88  8a
    pha ; $ab89  48
    ldy #$60 ; $ab8a  a0 60
    lda ($36),y ; $ab8c  b1 36
    tax ; $ab8e  aa
    iny ; $ab8f  c8
    lda ($36),y ; $ab90  b1 36
    tay ; $ab92  a8
    jsr $8dce ; $ab93  20 ce 8d
    tay ; $ab96  a8
    pla ; $ab97  68
    tax ; $ab98  aa
    tya ; $ab99  98
    jmp l_abbc ; $ab9a  4c bc ab
l_ab9d:
    ldy #$1d ; $ab9d  a0 1d
    lda ($36),y ; $ab9f  b1 36
    sta $9b ; $aba1  85 9b
    iny ; $aba3  c8
    lda ($36),y ; $aba4  b1 36
    lsr ; $aba6  4a
    ror $9b ; $aba7  66 9b
    lsr ; $aba9  4a
    ror $9b ; $abaa  66 9b
    asl ; $abac  0a
    bne $abb2 ; $abad  d0 03
    lda $9b ; $abaf  a5 9b
    !byte $2c,$a9,$ff ; $abb1 retained data / unresolved code
    jsr l_acf8 ; $abb4  20 f8 ac
    ldy #$10 ; $abb7  a0 10
    lda ($36),y ; $abb9  b1 36
    lsr ; $abbb  4a
l_abbc:
    jsr l_acf8 ; $abbc  20 f8 ac
    jsr $ff3e ; $abbf  20 3e ff
    and #$07 ; $abc2  29 07
    jsr l_acf8 ; $abc4  20 f8 ac
    jsr $ff3e ; $abc7  20 3e ff
    and #$07 ; $abca  29 07
    jsr l_acf8 ; $abcc  20 f8 ac
    lda #$02 ; $abcf  a9 02
    jsr l_acf8 ; $abd1  20 f8 ac
    ldy #$29 ; $abd4  a0 29
    lda ($36),y ; $abd6  b1 36
    tay ; $abd8  a8
    lda $abf1,y ; $abd9  b9 f1 ab
    jsr l_acf8 ; $abdc  20 f8 ac
    lda $7a ; $abdf  a5 7a
    jsr l_acf8 ; $abe1  20 f8 ac
    ldy $83 ; $abe4  a4 83
    lda $0307,y ; $abe6  b9 07 03
    jsr l_acf8 ; $abe9  20 f8 ac
    txa ; $abec  8a
    beq l_ac0c ; $abed  f0 1d
    sec ; $abef  38
    rts ; $abf0  60
    !byte $03,$01,$01,$01,$01,$00,$00,$03,$03,$04,$01,$01,$04,$03,$02,$00 ; $abf1 retained data / unresolved code
    !byte $fe,$ff,$ff,$ff,$00,$00,$00,$00,$00,$01,$01 ; $ac01 retained data / unresolved code
l_ac0c:
    ldy #$29 ; $ac0c  a0 29
    lda ($36),y ; $ac0e  b1 36
    cmp #$0d ; $ac10  c9 0d
    bcc l_ac1f ; $ac12  90 0b
    lda $03c8 ; $ac14  ad c8 03
    sta $95 ; $ac17  85 95
    lda $03ca ; $ac19  ad ca 03
    jmp l_ac4c ; $ac1c  4c 4c ac
l_ac1f:
    lda #$01 ; $ac1f  a9 01
    jsr $78f9 ; $ac21  20 f9 78
    bcc l_ac48 ; $ac24  90 22
    ldy #$29 ; $ac26  a0 29
    lda ($36),y ; $ac28  b1 36
    cmp #$09 ; $ac2a  c9 09
    bne l_ac44 ; $ac2c  d0 16
    ldy #$1e ; $ac2e  a0 1e
    lda ($36),y ; $ac30  b1 36
    bne l_ac3c ; $ac32  d0 08
    dey ; $ac34  88
    lda ($36),y ; $ac35  b1 36
    lsr ; $ac37  4a
    cmp #$10 ; $ac38  c9 10
    bcc l_ac3e ; $ac3a  90 02
l_ac3c:
    lda #$0f ; $ac3c  a9 0f
l_ac3e:
    tax ; $ac3e  aa
    lda $b4d0,x ; $ac3f  bd d0 b4
    bne l_ac4c ; $ac42  d0 08
l_ac44:
    lda #$20 ; $ac44  a9 20
    bne l_ac4c ; $ac46  d0 04
l_ac48:
    jsr $7924 ; $ac48  20 24 79
    txa ; $ac4b  8a
l_ac4c:
    sta $ac73 ; $ac4c  8d 73 ac
    lda #$00 ; $ac4f  a9 00
    sta $93 ; $ac51  85 93
    sta $94 ; $ac53  85 94
    ldy #$29 ; $ac55  a0 29
    lda ($36),y ; $ac57  b1 36
    cmp #$05 ; $ac59  c9 05
    bne l_ac64 ; $ac5b  d0 07
    ldy $83 ; $ac5d  a4 83
    lda $03be,y ; $ac5f  b9 be 03
    beq l_ac68 ; $ac62  f0 04
l_ac64:
    ldy #$69 ; $ac64  a0 69
    lda ($36),y ; $ac66  b1 36
l_ac68:
    clc ; $ac68  18
    adc $7c ; $ac69  65 7c
    sta $8b ; $ac6b  85 8b
    sta $03cb ; $ac6d  8d cb 03
    inc $8b ; $ac70  e6 8b
l_ac72:
    lda #$00 ; $ac72  a9 00
    jsr $fa5a ; $ac74  20 5a fa
    ldx $12 ; $ac77  a6 12
    ldy $13 ; $ac79  a4 13
    jsr l_ace4 ; $ac7b  20 e4 ac
    ldx #$00 ; $ac7e  a2 00
    ldy #$00 ; $ac80  a0 00
    jsr l_ace4 ; $ac82  20 e4 ac
    ldx $7b ; $ac85  a6 7b
    jsr l_ace4 ; $ac87  20 e4 ac
    ldx $83 ; $ac8a  a6 83
    lda $0307,x ; $ac8c  bd 07 03
    tax ; $ac8f  aa
    jsr l_ace4 ; $ac90  20 e4 ac
    ldx $83 ; $ac93  a6 83
    lda $030e,x ; $ac95  bd 0e 03
    beq l_acab ; $ac98  f0 11
l_ac9a:
    pha ; $ac9a  48
    jsr $ff3e ; $ac9b  20 3e ff
    and #$03 ; $ac9e  29 03
    tax ; $aca0  aa
    inx ; $aca1  e8
    jsr l_ace4 ; $aca2  20 e4 ac
    pla ; $aca5  68
    sec ; $aca6  38
    sbc #$01 ; $aca7  e9 01
    bne l_ac9a ; $aca9  d0 ef
l_acab:
    lda $93 ; $acab  a5 93
    sec ; $acad  38
    sbc $7d ; $acae  e5 7d
    sta $93 ; $acb0  85 93
    lda $94 ; $acb2  a5 94
    sbc #$00 ; $acb4  e9 00
    sta $94 ; $acb6  85 94
    bcs l_acc0 ; $acb8  b0 06
    lda #$00 ; $acba  a9 00
    sta $93 ; $acbc  85 93
    sta $94 ; $acbe  85 94
l_acc0:
    dec $8b ; $acc0  c6 8b
    bne l_ac72 ; $acc2  d0 ae
    ldx $83 ; $acc4  a6 83
    ldy #$66 ; $acc6  a0 66
    lda $03be,x ; $acc8  bd be 03
    bne l_acd7 ; $accb  d0 0a
    ldy #$29 ; $accd  a0 29
    lda ($36),y ; $accf  b1 36
    cmp #$08 ; $acd1  c9 08
    bne l_ace2 ; $acd3  d0 0d
    ldy #$64 ; $acd5  a0 64
l_acd7:
    jsr $ff3e ; $acd7  20 3e ff
    cmp ($36),y ; $acda  d1 36
    bcs l_ace2 ; $acdc  b0 04
    lda #$07 ; $acde  a9 07
    sta $95 ; $ace0  85 95
l_ace2:
    clc ; $ace2  18
    rts ; $ace3  60
l_ace4:
    clc ; $ace4  18
    txa ; $ace5  8a
    adc $93 ; $ace6  65 93
    sta $93 ; $ace8  85 93
    tya ; $acea  98
    adc $94 ; $aceb  65 94
    sta $94 ; $aced  85 94
    bcc l_acf7 ; $acef  90 06
    lda #$ff ; $acf1  a9 ff
    sta $93 ; $acf3  85 93
    sta $94 ; $acf5  85 94
l_acf7:
    rts ; $acf7  60
l_acf8:
    sta $acfe ; $acf8  8d fe ac
    txa ; $acfb  8a
    sec ; $acfc  38
    sbc #$00 ; $acfd  e9 00
    bcs l_ad03 ; $acff  b0 02
    lda #$00 ; $ad01  a9 00
l_ad03:
    tax ; $ad03  aa
    rts ; $ad04  60
l_ad05:
    sta $ad0b ; $ad05  8d 0b ad
    txa ; $ad08  8a
    clc ; $ad09  18
    adc #$00 ; $ad0a  69 00
    bcc l_ad10 ; $ad0c  90 02
    lda #$ff ; $ad0e  a9 ff
l_ad10:
    tax ; $ad10  aa
    rts ; $ad11  60
l_ad12:
    ora #$00 ; $ad12  09 00
    bpl l_ad05 ; $ad14  10 ef
    eor #$ff ; $ad16  49 ff
    clc ; $ad18  18
    adc #$01 ; $ad19  69 01
    jmp l_acf8 ; $ad1b  4c f8 ac
l_ad1e:
    lda #$00 ; $ad1e  a9 00
    sta $95 ; $ad20  85 95
    ldy $5d ; $ad22  a4 5d
    tya ; $ad24  98
    asl ; $ad25  0a
    tax ; $ad26  aa
    lda $d522,x ; $ad27  bd 22 d5
    sta $12 ; $ad2a  85 12
    lda $d523,x ; $ad2c  bd 23 d5
    sta $13 ; $ad2f  85 13
    lda $03be,y ; $ad31  b9 be 03
    bne l_ad62 ; $ad34  d0 2c
    ldy #$2e ; $ad36  a0 2e
    lda ($12),y ; $ad38  b1 12
    ldx $86 ; $ad3a  a6 86
    clc ; $ad3c  18
    adc $0315,x ; $ad3d  7d 15 03
    cmp #$3f ; $ad40  c9 3f
    bcc l_ad46 ; $ad42  90 02
    lda #$3f ; $ad44  a9 3f
l_ad46:
    sta $ad5f ; $ad46  8d 5f ad
    jsr $f9df ; $ad49  20 df f9
    ldy #$2c ; $ad4c  a0 2c
    lda ($49),y ; $ad4e  b1 49
    tax ; $ad50  aa
    iny ; $ad51  c8
    lda ($49),y ; $ad52  b1 49
    tay ; $ad54  a8
    jsr $8dce ; $ad55  20 ce 8d
    ldx $86 ; $ad58  a6 86
    clc ; $ad5a  18
    adc $0325,x ; $ad5b  7d 25 03
    cmp #$00 ; $ad5e  c9 00
    bcs l_ad64 ; $ad60  b0 02
l_ad62:
    sec ; $ad62  38
    rts ; $ad63  60
l_ad64:
    lda $03c8 ; $ad64  ad c8 03
    cmp #$08 ; $ad67  c9 08
    beq l_ad6f ; $ad69  f0 04
    cmp #$05 ; $ad6b  c9 05
    bne l_ad81 ; $ad6d  d0 12
l_ad6f:
    ldx $29 ; $ad6f  a6 29
    cpx #$07 ; $ad71  e0 07
    bcs l_ad81 ; $ad73  b0 0c
    pha ; $ad75  48
    jsr $ff3e ; $ad76  20 3e ff
    tax ; $ad79  aa
    pla ; $ad7a  68
    cpx #$c0 ; $ad7b  e0 c0
    bcs l_ad81 ; $ad7d  b0 02
    lda #$00 ; $ad7f  a9 00
l_ad81:
    sta $95 ; $ad81  85 95
    lda $03ca ; $ad83  ad ca 03
    jsr $fa5a ; $ad86  20 5a fa
    ldx $86 ; $ad89  a6 86
    lda $12 ; $ad8b  a5 12
    clc ; $ad8d  18
    adc $0325,x ; $ad8e  7d 25 03
    sta $93 ; $ad91  85 93
    lda $13 ; $ad93  a5 13
    adc #$00 ; $ad95  69 00
    sta $94 ; $ad97  85 94
    clc ; $ad99  18
    rts ; $ad9a  60
l_ad9b:
    lda $5d ; $ad9b  a5 5d
    bmi l_adab ; $ad9d  30 0c
    asl ; $ad9f  0a
    tax ; $ada0  aa
    ldy $d523,x ; $ada1  bc 23 d5
    lda $d522,x ; $ada4  bd 22 d5
    tax ; $ada7  aa
    jmp $751c ; $ada8  4c 1c 75
l_adab:
    lda #$e1 ; $adab  a9 e1
    jsr $848e ; $adad  20 8e 84
    lda $5d ; $adb0  a5 5d
    and #$7f ; $adb2  29 7f
    tax ; $adb4  aa
    lda $cd28,x ; $adb5  bd 28 cd
    sta $38 ; $adb8  85 38
    lda $cd2c,x ; $adba  bd 2c cd
    sta $39 ; $adbd  85 39
    ldy #$00 ; $adbf  a0 00
    sty $4f ; $adc1  84 4f
    lda ($38),y ; $adc3  b1 38
l_adc5:
    cmp $a16c,y ; $adc5  d9 6c a1
    beq l_add1 ; $adc8  f0 07
    iny ; $adca  c8
    cpy #$05 ; $adcb  c0 05
    bcc l_adc5 ; $adcd  90 f6
    bcs l_add6 ; $adcf  b0 05
l_add1:
    lda #$ee ; $add1  a9 ee
    jsr $848e ; $add3  20 8e 84
l_add6:
    lda #$a0 ; $add6  a9 a0
    jsr $848e ; $add8  20 8e 84
    ldx $38 ; $addb  a6 38
    ldy $39 ; $addd  a4 39
    jmp $751c ; $addf  4c 1c 75
    !byte $a2,$00,$20,$df,$f9,$f0,$59,$a2,$00,$8a,$48,$18,$69,$41,$20,$8e ; $ade2 retained data / unresolved code
    !byte $84,$a9,$a9,$20,$8e,$84,$68,$48,$aa,$20,$df,$f9,$85,$8c,$85,$9b ; $adf2 retained data / unresolved code
    !byte $a9,$00,$85,$9c,$20,$85,$72,$20,$89,$84,$68,$48,$aa,$20,$df,$f9 ; $ae02 retained data / unresolved code
    !byte $a6,$49,$a4,$4a,$a5,$8c,$85,$4f,$c6,$4f,$20,$1c,$75,$20,$89,$84 ; $ae12 retained data / unresolved code
    !byte $a0,$13,$b1,$49,$29,$0f,$18,$69,$b0,$20,$8e,$84,$20,$0a,$74,$f8 ; $ae22 retained data / unresolved code
    !byte $9a,$e8,$00,$68,$aa,$e8,$e0,$04,$f0,$05,$20,$df,$f9,$d0,$aa,$60 ; $ae32 retained data / unresolved code
    !byte $4c,$8c,$84 ; $ae42 retained data / unresolved code
l_ae45:
    lda #$87 ; $ae45  a9 87
    !byte $2c,$a9,$07,$2c,$a9,$03 ; $ae47 retained data / unresolved code
    sta $ae58 ; $ae4d  8d 58 ae
    lda #$07 ; $ae50  a9 07
    sta $8b ; $ae52  85 8b
    jsr $ff3e ; $ae54  20 3e ff
    and #$07 ; $ae57  29 07
    and #$7f ; $ae59  29 7f
    tax ; $ae5b  aa
    cpx #$07 ; $ae5c  e0 07
    bne l_ae62 ; $ae5e  d0 02
l_ae60:
    ldx #$00 ; $ae60  a2 00
l_ae62:
    txa ; $ae62  8a
    asl ; $ae63  0a
    tay ; $ae64  a8
    lda $d522,y ; $ae65  b9 22 d5
    sta $3c ; $ae68  85 3c
    lda $d523,y ; $ae6a  b9 23 d5
    sta $3d ; $ae6d  85 3d
    ldy #$00 ; $ae6f  a0 00
    lda ($3c),y ; $ae71  b1 3c
    beq l_ae96 ; $ae73  f0 21
    bit $ae58 ; $ae75  2c 58 ae
    bmi l_ae93 ; $ae78  30 19
    ldy #$29 ; $ae7a  a0 29
    lda ($3c),y ; $ae7c  b1 3c
    cmp #$0e ; $ae7e  c9 0e
    bne l_ae86 ; $ae80  d0 04
    lda $80 ; $ae82  a5 80
    bne l_ae96 ; $ae84  d0 10
l_ae86:
    lda $03be,x ; $ae86  bd be 03
    bne l_ae96 ; $ae89  d0 0b
    ldy #$2d ; $ae8b  a0 2d
    lda ($3c),y ; $ae8d  b1 3c
    and #$0c ; $ae8f  29 0c
    bne l_ae96 ; $ae91  d0 03
l_ae93:
    txa ; $ae93  8a
    clc ; $ae94  18
    rts ; $ae95  60
l_ae96:
    inx ; $ae96  e8
    dec $8b ; $ae97  c6 8b
    beq l_aea6 ; $ae99  f0 0b
    txa ; $ae9b  8a
    and $ae58 ; $ae9c  2d 58 ae
    tax ; $ae9f  aa
    cpx #$07 ; $aea0  e0 07
    bcs l_ae60 ; $aea2  b0 bc
    bcc l_ae62 ; $aea4  90 bc
l_aea6:
    lda #$00 ; $aea6  a9 00
    sec ; $aea8  38
    rts ; $aea9  60
l_aeaa:
    jsr $8f5b ; $aeaa  20 5b 8f
    lda #$00 ; $aead  a9 00
    sta $91 ; $aeaf  85 91
    lda $08 ; $aeb1  a5 08
    beq l_aebe ; $aeb3  f0 09
    lda $5f ; $aeb5  a5 5f
    beq l_aebe ; $aeb7  f0 05
    ldx #$08 ; $aeb9  a2 08
    jsr $667d ; $aebb  20 7d 66
l_aebe:
    ldx #$dd ; $aebe  a2 dd
    ldy #$af ; $aec0  a0 af
    jsr $7acc ; $aec2  20 cc 7a
    jsr l_affc ; $aec5  20 fc af
    lda #$15 ; $aec8  a9 15
    jsr l_b010 ; $aeca  20 10 b0
    jsr $728e ; $aecd  20 8e 72
    jsr $740a ; $aed0  20 0a 74

; Packed text: ' experience points for valor and battle knowledge, and '
    !byte $09,$be,$14,$0d,$15,$19,$c4,$30,$60,$f5,$3a,$72,$09,$df,$10,$d4 ; $aed3 retained data / unresolved code
    !byte $4c,$7c,$42,$27,$14,$23,$14,$e6,$c3,$05,$6e,$7d,$98,$62,$a0,$db ; $aee3 retained data / unresolved code
    !byte $08,$9c,$50,$80 ; $aef3 retained data / unresolved code
    lda $91 ; $aef7  a5 91
    bne l_af0a ; $aef9  d0 0f
    jsr l_affc ; $aefb  20 fc af
    sta $a0 ; $aefe  85 a0
    lda #$05 ; $af00  a9 05
    sta $9f ; $af02  85 9f
    jsr $919c ; $af04  20 9c 91
    jmp l_af14 ; $af07  4c 14 af
l_af0a:
    lda #$00 ; $af0a  a9 00
    sta $9b ; $af0c  85 9b
    sta $9c ; $af0e  85 9c
    sta $9d ; $af10  85 9d
    sta $9e ; $af12  85 9e
l_af14:
    lda #$19 ; $af14  a9 19
    jsr l_b010 ; $af16  20 10 b0
    jsr $728e ; $af19  20 8e 72
    jsr $740a ; $af1c  20 0a 74

; Packed text: ' in gold.<$0d><$0d>'
    !byte $0a,$9c,$14,$3d,$85,$c7,$7a,$00 ; $af1f retained data / unresolved code
    lda #$04 ; $af27  a9 04
    sta $88 ; $af29  85 88
l_af2b:
    ldx #$00 ; $af2b  a2 00
    lda #$09 ; $af2d  a9 09
    sec ; $af2f  38
    sbc $29 ; $af30  e5 29
    tay ; $af32  a8
    jsr $8dce ; $af33  20 ce 8d
    cmp #$00 ; $af36  c9 00
    beq l_af3d ; $af38  f0 03
l_af3a:
    jmp l_afd1 ; $af3a  4c d1 af
l_af3d:
    lda $91 ; $af3d  a5 91
    bne l_af3a ; $af3f  d0 f9
    lda #$0f ; $af41  a9 0f
    jsr $8f6b ; $af43  20 6b 8f
    ldy $29 ; $af46  a4 29
l_af48:
    jsr $ff3e ; $af48  20 3e ff
    cmp #$e0 ; $af4b  c9 e0
    bcc l_af55 ; $af4d  90 06
    cmp #$f0 ; $af4f  c9 f0
    bcs l_af55 ; $af51  b0 02
    lda #$c3 ; $af53  a9 c3
l_af55:
    tax ; $af55  aa
    lda $b569,x ; $af56  bd 69 b5
    and $cd58,y ; $af59  39 58 cd
    beq l_af48 ; $af5c  f0 ea
    stx $53 ; $af5e  86 53
    lda $e273,x ; $af60  bd 73 e2
    cmp #$ff ; $af63  c9 ff
    beq l_af71 ; $af65  f0 0a
    cmp #$01 ; $af67  c9 01
    beq l_af71 ; $af69  f0 06
    tay ; $af6b  a8
    ldx #$01 ; $af6c  a2 01
    jsr $8dce ; $af6e  20 ce 8d
l_af71:
    sta $56 ; $af71  85 56
    ldx #$00 ; $af73  a2 00
    jsr $ff3e ; $af75  20 3e ff
    and #$07 ; $af78  29 07
    bne l_af7e ; $af7a  d0 02
    ldx #$80 ; $af7c  a2 80
l_af7e:
    stx $55 ; $af7e  86 55
    jsr $ae48 ; $af80  20 48 ae
    sta $8b ; $af83  85 8b
    ldx #$06 ; $af85  a2 06
    stx $87 ; $af87  86 87
l_af89:
    lda $8b ; $af89  a5 8b
    jsr $f9d5 ; $af8b  20 d5 f9
    bcs l_af97 ; $af8e  b0 07
    lda $8b ; $af90  a5 8b
    jsr $715b ; $af92  20 5b 71
    bcc l_afb2 ; $af95  90 1b
l_af97:
    dec $87 ; $af97  c6 87
    bmi l_afd1 ; $af99  30 36
    dec $8b ; $af9b  c6 8b
    lda $8b ; $af9d  a5 8b
    bpl l_afa5 ; $af9f  10 04
    lda #$06 ; $afa1  a9 06
    sta $8b ; $afa3  85 8b
l_afa5:
    jsr $f9d5 ; $afa5  20 d5 f9
    ldy #$2d ; $afa8  a0 2d
    lda ($49),y ; $afaa  b1 49
    and #$1c ; $afac  29 1c
    bne l_af97 ; $afae  d0 e7
    beq l_af89 ; $afb0  f0 d7
l_afb2:
    lda $8b ; $afb2  a5 8b
    jsr $f9d5 ; $afb4  20 d5 f9
    ldx $49 ; $afb7  a6 49
    ldy $4a ; $afb9  a4 4a
    jsr $751c ; $afbb  20 1c 75
    jsr $740a ; $afbe  20 0a 74

; Packed text: ' found a '
    !byte $09,$df,$47,$14,$22,$08,$00 ; $afc1 retained data / unresolved code
    jsr $6fe6 ; $afc8  20 e6 6f
    jsr $740a ; $afcb  20 0a 74

; Packed text: '.<$0d><$0d>'
    !byte $c7,$7a,$00 ; $afce retained data / unresolved code
l_afd1:
    dec $88 ; $afd1  c6 88
    beq l_afd8 ; $afd3  f0 03
    jmp l_af2b ; $afd5  4c 2b af
l_afd8:
    lda #$14 ; $afd8  a9 14
    jmp $8f6b ; $afda  4c 6b 8f
    !byte $87,$34,$88,$d4,$f2,$e5,$e1,$f3,$f5,$f2,$e5,$a1,$ff,$05,$f1,$84 ; $afdd retained data / unresolved code
    !byte $44,$84,$89,$14,$44,$49,$9a,$21,$89,$88,$65,$54,$d2,$08,$00 ; $afed retained data / unresolved code
l_affc:
    lda $03c5 ; $affc  ad c5 03
    sta $9b ; $afff  85 9b
    lda $03c6 ; $b001  ad c6 03
    sta $9c ; $b004  85 9c
    lda $03c7 ; $b006  ad c7 03
    sta $9d ; $b009  85 9d
    lda #$00 ; $b00b  a9 00
    sta $9e ; $b00d  85 9e
    rts ; $b00f  60
l_b010:
    sta $b067 ; $b010  8d 67 b0
    jsr $6f5e ; $b013  20 5e 6f
    clc ; $b016  18
    adc #$01 ; $b017  69 01
    sta $9f ; $b019  85 9f
    lda #$00 ; $b01b  a9 00
    sta $a0 ; $b01d  85 a0
    jsr $919c ; $b01f  20 9c 91
    inc $9b ; $b022  e6 9b
    bne l_b030 ; $b024  d0 0a
    inc $9c ; $b026  e6 9c
    bne l_b030 ; $b028  d0 06
    inc $9d ; $b02a  e6 9d
    bne l_b030 ; $b02c  d0 02
    inc $9e ; $b02e  e6 9e
l_b030:
    lda $9b ; $b030  a5 9b
    cmp #$a0 ; $b032  c9 a0
    lda $9c ; $b034  a5 9c
    sbc #$86 ; $b036  e9 86
    lda $9d ; $b038  a5 9d
    sbc #$01 ; $b03a  e9 01
    lda $9e ; $b03c  a5 9e
    sbc #$00 ; $b03e  e9 00
    bcc l_b052 ; $b040  90 10
    lda #$a0 ; $b042  a9 a0
    sta $9b ; $b044  85 9b
    lda #$86 ; $b046  a9 86
    sta $9c ; $b048  85 9c
    lda #$01 ; $b04a  a9 01
    sta $9d ; $b04c  85 9d
    lda #$00 ; $b04e  a9 00
    sta $9e ; $b050  85 9e
l_b052:
    jsr $6f16 ; $b052  20 16 6f

; Inline party callback: $b058
    !byte $58,$b0 ; $b055 retained data / unresolved code
l_b057:
    rts ; $b057  60
    beq l_b057 ; $b058  f0 fd
    ldy #$2d ; $b05a  a0 2d
    lda ($12),y ; $b05c  b1 12
    and #$1c ; $b05e  29 1c
    bne l_b057 ; $b060  d0 f5
    ldy #$29 ; $b062  a0 29
    lda ($12),y ; $b064  b1 12
    ldy #$00 ; $b066  a0 00
    cmp #$0d ; $b068  c9 0d
    bcc l_b072 ; $b06a  90 06
    bne l_b057 ; $b06c  d0 e9
    cpy #$19 ; $b06e  c0 19
    bne l_b057 ; $b070  d0 e5
l_b072:
    ldx #$00 ; $b072  a2 00
    clc ; $b074  18
l_b075:
    lda $9b,x ; $b075  b5 9b
    adc ($12),y ; $b077  71 12
    sta ($12),y ; $b079  91 12
    iny ; $b07b  c8
    inx ; $b07c  e8
    txa ; $b07d  8a
    eor #$04 ; $b07e  49 04
    bne l_b075 ; $b080  d0 f3
    bcc l_b057 ; $b082  90 d3
    dey ; $b084  88
    lda #$ff ; $b085  a9 ff
l_b087:
    sta ($12),y ; $b087  91 12
    dey ; $b089  88
    dex ; $b08a  ca
    bne l_b087 ; $b08b  d0 fa
    rts ; $b08d  60
    !byte $a5,$37,$48,$a5,$36,$48,$20,$4a,$6f,$a5,$36,$85,$42,$a5,$37,$85 ; $b08e retained data / unresolved code
    !byte $43,$68,$85,$36,$68,$85,$37,$90,$01,$60,$20,$48,$ae,$b0,$fa,$a0 ; $b09e retained data / unresolved code
    !byte $77,$b1,$3c,$91,$42,$88,$10,$f9,$20,$3e,$ff,$4a,$90,$08,$a5,$3c ; $b0ae retained data / unresolved code
    !byte $85,$42,$a5,$3d,$85,$43,$a6,$86,$20,$df,$f9,$a9,$00,$91,$49,$a0 ; $b0be retained data / unresolved code
    !byte $67,$a9,$01,$91,$42,$a0,$68,$91,$42,$20,$0a,$74,$0f,$c0,$a3,$61 ; $b0ce retained data / unresolved code
    !byte $20,$a9,$d3,$78,$6e,$fa,$44,$30,$14,$67,$7e,$77,$a0,$20,$81,$fb ; $b0de retained data / unresolved code
    !byte $20,$5b,$8f,$18,$60 ; $b0ee retained data / unresolved code
    jsr $7520 ; $b0f3  20 20 75
    lda #$05 ; $b0f6  a9 05
    jsr $6f83 ; $b0f8  20 83 6f
    bcc l_b122 ; $b0fb  90 25
    ldy #$64 ; $b0fd  a0 64
    lda ($36),y ; $b0ff  b1 36
    bne l_b11d ; $b101  d0 1a
    jsr $740a ; $b103  20 0a 74

; Packed text: ' lost '
    !byte $0b,$1f,$29,$84,$00 ; $b106 retained data / unresolved code
    lda $83 ; $b10b  a5 83
    jsr $ecb5 ; $b10d  20 b5 ec
    jsr $740a ; $b110  20 0a 74

; Packed text: ' voice!<$0d><$0d>'
    !byte $0d,$5e,$a2,$1b,$9d,$e8,$00 ; $b113 retained data / unresolved code
    jmp $8f5b ; $b11a  4c 5b 8f
l_b11d:
    sec ; $b11d  38
    sbc #$01 ; $b11e  e9 01
    sta ($36),y ; $b120  91 36
l_b122:
    ldx $83 ; $b122  a6 83
    lda $0332,x ; $b124  bd 32 03
    pha ; $b127  48
    jsr $740a ; $b128  20 0a 74

; Packed text: ' plays...<$0d><$0d>'
    !byte $0c,$18,$2b,$cb,$18,$c7,$7a,$00 ; $b12b retained data / unresolved code
    pla ; $b133  68
    pha ; $b134  48
    ldx $83 ; $b135  a6 83
    jsr $91ef ; $b137  20 ef 91
    pla ; $b13a  68
    asl ; $b13b  0a
    tay ; $b13c  a8
    lda $b169,y ; $b13d  b9 69 b1
    sta $12 ; $b140  85 12
    lda $b16a,y ; $b142  b9 6a b1
    sta $13 ; $b145  85 13
    ldy #$29 ; $b147  a0 29
    lda ($36),y ; $b149  b1 36
    cmp #$0d ; $b14b  c9 0d
    bcs $b164 ; $b14d  b0 15
    ldy #$1e ; $b14f  a0 1e
    lda ($36),y ; $b151  b1 36
    bne l_b161 ; $b153  d0 0c
    dey ; $b155  88
    lda ($36),y ; $b156  b1 36
    lsr ; $b158  4a
    lsr ; $b159  4a
    clc ; $b15a  18
    adc #$01 ; $b15b  69 01
    cmp #$0f ; $b15d  c9 0f
    bcc l_b166 ; $b15f  90 05
l_b161:
    lda #$0f ; $b161  a9 0f
    !byte $2c,$a9,$01 ; $b163 retained data / unresolved code
l_b166:
    jmp ($0012) ; $b166  6c 12 00
    !byte $79,$b1,$84,$b1,$85,$b1,$8d,$b1,$95,$b1,$97,$b1,$98,$b1,$a0,$b1 ; $b169 retained data / unresolved code
    !byte $a9,$ff,$85,$97,$a9,$02,$05,$7f,$85,$7f,$60,$60,$18,$65,$76,$85 ; $b179 retained data / unresolved code
    !byte $76,$4c,$81,$fb,$18,$6d,$4e,$9c,$8d,$4e,$9c,$60,$e6,$7c,$60,$20 ; $b189 retained data / unresolved code
    !byte $85,$b1,$a9,$ff,$85,$fe,$60,$a5,$83,$85,$5c,$a9,$80,$85,$5d,$a9 ; $b199 retained data / unresolved code
    !byte $ed,$4c,$17,$fa ; $b1a9 retained data / unresolved code
l_b1ad:
    lda #$83 ; $b1ad  a9 83
    sta $84 ; $b1af  85 84
l_b1b1:
    lda $84 ; $b1b1  a5 84
    and #$0f ; $b1b3  29 0f
    tax ; $b1b5  aa
    jsr $f9df ; $b1b6  20 df f9
    beq l_b201 ; $b1b9  f0 46
    ldy #$24 ; $b1bb  a0 24
    lda ($49),y ; $b1bd  b1 49
    and #$10 ; $b1bf  29 10
    beq l_b201 ; $b1c1  f0 3e
    lda $7f ; $b1c3  a5 7f
    and #$81 ; $b1c5  29 81
    bne l_b1da ; $b1c7  d0 11
    lda #$80 ; $b1c9  a9 80
    sta $5c ; $b1cb  85 5c
    lda #$00 ; $b1cd  a9 00
    sta $5d ; $b1cf  85 5d
    jsr $eb52 ; $b1d1  20 52 eb
    bcs l_b201 ; $b1d4  b0 2b
    cmp #$00 ; $b1d6  c9 00
    bne l_b201 ; $b1d8  d0 27
l_b1da:
    ldy #$15 ; $b1da  a0 15
    lda #$01 ; $b1dc  a9 01
    sta ($49),y ; $b1de  91 49
    lda #$06 ; $b1e0  a9 06
    sta $95 ; $b1e2  85 95
    lda $84 ; $b1e4  a5 84
    jsr l_a8bd ; $b1e6  20 bd a8
    jsr $740a ; $b1e9  20 0a 74

; Packed text: 'The party disbelieves...<$0d><$0d>'
    !byte $f4,$d2,$60,$c0,$51,$9d,$c2,$55,$48,$66,$62,$8d,$53,$4b,$18,$c7 ; $b1ec retained data / unresolved code
    !byte $7a,$00 ; $b1fc retained data / unresolved code
    jsr $8f5b ; $b1fe  20 5b 8f
l_b201:
    dec $84 ; $b201  c6 84
    bmi l_b1b1 ; $b203  30 ac
    lda $7f ; $b205  a5 7f
    and #$fe ; $b207  29 fe
    sta $7f ; $b209  85 7f
    rts ; $b20b  60
l_b20c:
    ldx #$00 ; $b20c  a2 00
    lda $d4 ; $b20e  a5 d4
    stx $d4 ; $b210  86 d4
    bne l_b23d ; $b212  d0 29
    jsr $8673 ; $b214  20 73 86
    ldx #$03 ; $b217  a2 03
l_b219:
    jsr $f9df ; $b219  20 df f9
    bne l_b225 ; $b21c  d0 07
    dex ; $b21e  ca
    bpl l_b219 ; $b21f  10 f8
    lda #$00 ; $b221  a9 00
    beq l_b22d ; $b223  f0 08
l_b225:
    ldx #$01 ; $b225  a2 01
    ldy #$06 ; $b227  a0 06
    jsr $8dce ; $b229  20 ce 8d
    asl ; $b22c  0a
l_b22d:
    tay ; $b22d  a8
    pha ; $b22e  48
    ldx $b669,y ; $b22f  be 69 b6
    lda $b66a,y ; $b232  b9 6a b6
    tay ; $b235  a8
    jsr $7419 ; $b236  20 19 74
    pla ; $b239  68
    bne l_b23d ; $b23a  d0 01
    rts ; $b23c  60
l_b23d:
    ldx #$00 ; $b23d  a2 00
    jsr $f9df ; $b23f  20 df f9
    bne l_b258 ; $b242  d0 14
    jsr $740a ; $b244  20 0a 74

; Packed text: 'hostile party members!<$0d><$0d>'
    !byte $4b,$e5,$35,$30,$c1,$80,$a3,$3b,$85,$a6,$68,$cd,$19,$73,$bd,$00 ; $b247 retained data / unresolved code
    rts ; $b257  60
l_b258:
    lda #$00 ; $b258  a9 00
    sta $50 ; $b25a  85 50
l_b25c:
    ldx $50 ; $b25c  a6 50
    beq l_b27f ; $b25e  f0 1f
    cpx #$03 ; $b260  e0 03
    beq $b270 ; $b262  f0 0c
    inx ; $b264  e8
    jsr $f9df ; $b265  20 df f9
    dex ; $b268  ca
    cmp #$00 ; $b269  c9 00
    beq $b270 ; $b26b  f0 03
    lda #$00 ; $b26d  a9 00
    !byte $2c,$a9,$01 ; $b26f retained data / unresolved code
    sta $4f ; $b272  85 4f
    jsr $740a ; $b274  20 0a 74

; Packed text: ', /\\and '
    !byte $d8,$7f,$a7,$f5,$13,$8a,$10,$00 ; $b277 retained data / unresolved code
l_b27f:
    ldx $50 ; $b27f  a6 50
    jsr $f9df ; $b281  20 df f9
    beq l_b2c5 ; $b284  f0 3f
    pha ; $b286  48
    sta $9b ; $b287  85 9b
    lda #$00 ; $b289  a9 00
    sta $9c ; $b28b  85 9c
    jsr $7285 ; $b28d  20 85 72
    jsr $8489 ; $b290  20 89 84
    ldy $4a ; $b293  a4 4a
    ldx $49 ; $b295  a6 49
    pla ; $b297  68
    sta $4f ; $b298  85 4f
    dec $4f ; $b29a  c6 4f
    jsr $751c ; $b29c  20 1c 75
    jsr $740a ; $b29f  20 0a 74

; Packed text: ' ('
    !byte $0f,$f2,$00 ; $b2a2 retained data / unresolved code
    ldy #$13 ; $b2a5  a0 13
    lda ($49),y ; $b2a7  b1 49
    and #$0f ; $b2a9  29 0f
    clc ; $b2ab  18
    adc #$b0 ; $b2ac  69 b0
    jsr $848e ; $b2ae  20 8e 84
    jsr $740a ; $b2b1  20 0a 74

; Packed text: "0')"
    !byte $f8,$9a,$fe,$60 ; $b2b4 retained data / unresolved code
    inc $50 ; $b2b8  e6 50
    ldx $50 ; $b2ba  a6 50
    cpx #$04 ; $b2bc  e0 04
    beq l_b2c5 ; $b2be  f0 05
    jsr $f9df ; $b2c0  20 df f9
    bne l_b25c ; $b2c3  d0 97
l_b2c5:
    jsr $740a ; $b2c5  20 0a 74

; Packed text: '.<$0d><$0d>'
    !byte $c7,$7a,$00 ; $b2c8 retained data / unresolved code
    rts ; $b2cb  60
l_b2cc:
    lda #$03 ; $b2cc  a9 03
    sta $87 ; $b2ce  85 87
    lda #$00 ; $b2d0  a9 00
    sta $83 ; $b2d2  85 83
l_b2d4:
    ldx $87 ; $b2d4  a6 87
    jsr $f9df ; $b2d6  20 df f9
    beq l_b33d ; $b2d9  f0 62
    ldy #$13 ; $b2db  a0 13
    lda ($49),y ; $b2dd  b1 49
    and #$0f ; $b2df  29 0f
    sta $12 ; $b2e1  85 12
    dex ; $b2e3  ca
    jsr $f9df ; $b2e4  20 df f9
    inx ; $b2e7  e8
    ldy #$13 ; $b2e8  a0 13
    lda ($49),y ; $b2ea  b1 49
    and #$0f ; $b2ec  29 0f
    cmp $12 ; $b2ee  c5 12
    beq l_b33d ; $b2f0  f0 4b
    bcc l_b33d ; $b2f2  90 49
    inc $83 ; $b2f4  e6 83
    lda $cd38,x ; $b2f6  bd 38 cd
    sta $36 ; $b2f9  85 36
    lda $cd3c,x ; $b2fb  bd 3c cd
    sta $37 ; $b2fe  85 37
    lda $cd37,x ; $b300  bd 37 cd
    sta $38 ; $b303  85 38
    lda $cd3b,x ; $b305  bd 3b cd
    sta $39 ; $b308  85 39
    lda $cd28,x ; $b30a  bd 28 cd
    sta $12 ; $b30d  85 12
    lda $cd2c,x ; $b30f  bd 2c cd
    sta $13 ; $b312  85 13
    lda $cd27,x ; $b314  bd 27 cd
    sta $15 ; $b317  85 15
    lda $cd2b,x ; $b319  bd 2b cd
    sta $16 ; $b31c  85 16
    ldy #$00 ; $b31e  a0 00
l_b320:
    lda ($38),y ; $b320  b1 38
    tax ; $b322  aa
    lda ($36),y ; $b323  b1 36
    sta ($38),y ; $b325  91 38
    txa ; $b327  8a
    sta ($36),y ; $b328  91 36
    cpy #$30 ; $b32a  c0 30
    bcs l_b338 ; $b32c  b0 0a
    lda ($12),y ; $b32e  b1 12
    tax ; $b330  aa
    lda ($15),y ; $b331  b1 15
    sta ($12),y ; $b333  91 12
    txa ; $b335  8a
    sta ($15),y ; $b336  91 15
l_b338:
    iny ; $b338  c8
    cpy #$40 ; $b339  c0 40
    bcc l_b320 ; $b33b  90 e3
l_b33d:
    dec $87 ; $b33d  c6 87
    bne l_b2d4 ; $b33f  d0 93
    lda $83 ; $b341  a5 83
    bne l_b2cc ; $b343  d0 87
    rts ; $b345  60
l_b346:
    ldx #$00 ; $b346  a2 00
    jsr $f9df ; $b348  20 df f9
    beq l_b353 ; $b34b  f0 06
    ldy #$00 ; $b34d  a0 00
    lda ($49),y ; $b34f  b1 49
    bne l_b362 ; $b351  d0 0f
l_b353:
    lda #$7f ; $b353  a9 7f
    sta $38 ; $b355  85 38
    lda #$b3 ; $b357  a9 b3
    sta $39 ; $b359  85 39
    jsr $7551 ; $b35b  20 51 75
    ldx #$21 ; $b35e  a2 21
    bne l_b37c ; $b360  d0 1a
l_b362:
    ldy #$15 ; $b362  a0 15
    lda ($49),y ; $b364  b1 49
    and #$1f ; $b366  29 1f
    sta $4f ; $b368  85 4f
    lda $49 ; $b36a  a5 49
    sta $38 ; $b36c  85 38
    lda $4a ; $b36e  a5 4a
    sta $39 ; $b370  85 39
    dec $4f ; $b372  c6 4f
    jsr $7551 ; $b374  20 51 75

; Monster record offset $20 is the portrait resource ID, passed
; to load_picture_pair ($68c9). Local monster appearance list can be
; used to compare shared portraits; it does not specify combat stats.
    ldy #$20 ; $b377  a0 20
    lda ($49),y ; $b379  b1 49
    tax ; $b37b  aa
l_b37c:
    jmp $68c9 ; $b37c  4c c9 68
    !byte $d0,$e1,$f2,$f4,$f9,$ff ; $b37f retained data / unresolved code
l_b385:
    lda #$00 ; $b385  a9 00
    sta $b2 ; $b387  85 b2
    jsr $6f16 ; $b389  20 16 6f

; Inline party callback: $b3a1
    !byte $a1,$b3 ; $b38c retained data / unresolved code
    lda $b2 ; $b38e  a5 b2
    bne l_b397 ; $b390  d0 05
    jsr $6f16 ; $b392  20 16 6f

; Inline party callback: $b3ae
    !byte $ae,$b3 ; $b395 retained data / unresolved code
l_b397:
    jsr $6f16 ; $b397  20 16 6f

; Inline party callback: $b3bd
    !byte $bd,$b3 ; $b39a retained data / unresolved code
    ror ; $b39c  6a
    eor #$80 ; $b39d  49 80
    asl ; $b39f  0a
l_b3a0:
    rts ; $b3a0  60
    beq l_b3a0 ; $b3a1  f0 fd
    ldy #$29 ; $b3a3  a0 29
    lda ($12),y ; $b3a5  b1 12
    cmp #$0d ; $b3a7  c9 0d
    bcs l_b3a0 ; $b3a9  b0 f5
    sty $b2 ; $b3ab  84 b2
    rts ; $b3ad  60
    ldy #$68 ; $b3ae  a0 68
    lda #$00 ; $b3b0  a9 00
    sta ($12),y ; $b3b2  91 12
    ldy #$2d ; $b3b4  a0 2d
    lda ($12),y ; $b3b6  b1 12
    and #$9f ; $b3b8  29 9f
    sta ($12),y ; $b3ba  91 12
    rts ; $b3bc  60
    beq l_b3a0 ; $b3bd  f0 e1
    ldy #$2d ; $b3bf  a0 2d
    lda ($12),y ; $b3c1  b1 12
    and #$1c ; $b3c3  29 1c
    bne l_b3a0 ; $b3c5  d0 d9
    ldy #$68 ; $b3c7  a0 68
    lda ($12),y ; $b3c9  b1 12
    beq l_b3a0 ; $b3cb  f0 d3
    ldy #$67 ; $b3cd  a0 67
    lda ($12),y ; $b3cf  b1 12
    bne l_b3db ; $b3d1  d0 08
    ldy #$29 ; $b3d3  a0 29
    lda ($12),y ; $b3d5  b1 12
    cmp #$0d ; $b3d7  c9 0d
    bcc l_b3a0 ; $b3d9  90 c5
l_b3db:
    pla ; $b3db  68
    pla ; $b3dc  68
    clc ; $b3dd  18
    rts ; $b3de  60
l_b3df:
    lda $81 ; $b3df  a5 81
    beq l_b3f2 ; $b3e1  f0 0f
    ldx #$06 ; $b3e3  a2 06
    lda #$00 ; $b3e5  a9 00
l_b3e7:
    sta $03b7,x ; $b3e7  9d b7 03
    dex ; $b3ea  ca
    bpl l_b3e7 ; $b3eb  10 fa
    sta $81 ; $b3ed  85 81
l_b3ef:
    jmp l_b476 ; $b3ef  4c 76 b4
l_b3f2:
    lda #$00 ; $b3f2  a9 00
    sta $88 ; $b3f4  85 88
l_b3f6:
    lda $88 ; $b3f6  a5 88
    asl ; $b3f8  0a
    tax ; $b3f9  aa
    lda $d522,x ; $b3fa  bd 22 d5
    sta $3c ; $b3fd  85 3c
    lda $d523,x ; $b3ff  bd 23 d5
    sta $3d ; $b402  85 3d
    ldy #$00 ; $b404  a0 00
    lda ($3c),y ; $b406  b1 3c
    beq l_b3ef ; $b408  f0 e5
    ldy #$29 ; $b40a  a0 29
    lda ($3c),y ; $b40c  b1 3c
    cmp #$0d ; $b40e  c9 0d
    bcc l_b421 ; $b410  90 0f
    ldy #$17 ; $b412  a0 17
    lda ($3c),y ; $b414  b1 3c
    tax ; $b416  aa
    iny ; $b417  c8
    lda ($3c),y ; $b418  b1 3c
    tay ; $b41a  a8
    jsr $8dce ; $b41b  20 ce 8d
    jmp l_b461 ; $b41e  4c 61 b4
l_b421:
    ldx $88 ; $b421  a6 88
    lda $032a,x ; $b423  bd 2a 03
    cmp #$05 ; $b426  c9 05
    beq $b436 ; $b428  f0 0c
    ldy #$1e ; $b42a  a0 1e
    lda ($3c),y ; $b42c  b1 3c
    lsr ; $b42e  4a
    bne $b436 ; $b42f  d0 05
    dey ; $b431  88
    lda ($3c),y ; $b432  b1 3c
    ror ; $b434  6a
    !byte $2c,$a9,$ff ; $b435 retained data / unresolved code
    tax ; $b438  aa
    ldy #$12 ; $b439  a0 12
    lda ($3c),y ; $b43b  b1 3c
    asl ; $b43d  0a
    jsr l_ad05 ; $b43e  20 05 ad
    jsr $ff3e ; $b441  20 3e ff
    and #$0f ; $b444  29 0f
    jsr l_ad05 ; $b446  20 05 ad
    jsr $ff3e ; $b449  20 3e ff
    and #$0f ; $b44c  29 0f
    jsr l_ad05 ; $b44e  20 05 ad
    lda #$02 ; $b451  a9 02
    jsr l_ad05 ; $b453  20 05 ad
    ldy #$29 ; $b456  a0 29
    lda ($3c),y ; $b458  b1 3c
    tay ; $b45a  a8
    lda $b4c3,y ; $b45b  b9 c3 b4
    jsr l_ad05 ; $b45e  20 05 ad
l_b461:
    ldx $88 ; $b461  a6 88
    tay ; $b463  a8
    bne l_b468 ; $b464  d0 02
    lda #$01 ; $b466  a9 01
l_b468:
    sta $03b7,x ; $b468  9d b7 03
    inc $88 ; $b46b  e6 88
    lda $88 ; $b46d  a5 88
    cmp #$07 ; $b46f  c9 07
    bcs l_b476 ; $b471  b0 03
    jmp l_b3f6 ; $b473  4c f6 b3
l_b476:
    lda #$00 ; $b476  a9 00
    sta $88 ; $b478  85 88
l_b47a:
    ldx $88 ; $b47a  a6 88
    jsr $f9df ; $b47c  20 df f9
    beq l_b4b4 ; $b47f  f0 33
    ldy #$00 ; $b481  a0 00
    lda ($49),y ; $b483  b1 49
    beq l_b4b4 ; $b485  f0 2d
    ldx $88 ; $b487  a6 88
    lda $cd48,x ; $b489  bd 48 cd
    sta $12 ; $b48c  85 12
    lda $cd4c,x ; $b48e  bd 4c cd
    sta $13 ; $b491  85 13
    ldy #$15 ; $b493  a0 15
    lda ($49),y ; $b495  b1 49
    and #$1f ; $b497  29 1f
    tay ; $b499  a8
    dey ; $b49a  88
l_b49b:
    tya ; $b49b  98
    pha ; $b49c  48
    ldy #$27 ; $b49d  a0 27
    lda ($49),y ; $b49f  b1 49
    tax ; $b4a1  aa
    iny ; $b4a2  c8
    lda ($49),y ; $b4a3  b1 49
    tay ; $b4a5  a8
    jsr $8dce ; $b4a6  20 ce 8d
    tax ; $b4a9  aa
    pla ; $b4aa  68
    tay ; $b4ab  a8
    txa ; $b4ac  8a
    ora #$01 ; $b4ad  09 01
    sta ($12),y ; $b4af  91 12
    dey ; $b4b1  88
    bpl l_b49b ; $b4b2  10 e7
l_b4b4:
    lda $88 ; $b4b4  a5 88
    cmp #$04 ; $b4b6  c9 04
    bcs l_b4c2 ; $b4b8  b0 08
    cmp $89 ; $b4ba  c5 89
    bcs l_b4c2 ; $b4bc  b0 04
    inc $88 ; $b4be  e6 88
    bne l_b47a ; $b4c0  d0 b8
l_b4c2:
    rts ; $b4c2  60
    !byte $05,$07,$07,$03,$03,$00,$00,$05,$05,$0a,$0f,$0f,$16,$20,$21,$22 ; $b4c3 retained data / unresolved code
    !byte $23,$24,$25,$26,$27,$68,$69,$6a,$6b,$6c,$6d,$6e,$8f,$00,$b5,$07 ; $b4d3 retained data / unresolved code
    !byte $b5,$0e,$b5,$14,$b5,$1b,$b5,$21,$b5,$27,$b5,$2d,$b5,$33,$b5,$39 ; $b4e3 retained data / unresolved code
    !byte $b5,$40,$b5,$44,$b5,$4b,$b5,$52,$b5,$5c,$b5,$62,$b5,$95,$94,$e4 ; $b4f3 retained data / unresolved code
    !byte $48,$22,$98,$00,$93,$05,$24,$9a,$41,$14,$c0,$5a,$88,$b9,$04,$53 ; $b503 retained data / unresolved code
    !byte $00,$85,$1c,$44,$9a,$41,$14,$c0,$23,$05,$69,$04,$53,$00,$99,$85 ; $b513 retained data / unresolved code
    !byte $19,$04,$53,$00,$1a,$a6,$69,$04,$53,$00,$43,$85,$69,$05,$ee,$00 ; $b523 retained data / unresolved code
    !byte $94,$c4,$39,$04,$53,$00,$93,$14,$43,$48,$22,$98,$00,$93,$04,$d9 ; $b533 retained data / unresolved code
    !byte $00,$94,$e2,$a5,$9a,$41,$14,$c0,$44,$5f,$03,$48,$22,$98,$00,$89 ; $b543 retained data / unresolved code
    !byte $84,$44,$9a,$41,$9b,$ec,$28,$94,$00,$81,$8d,$19,$04,$53,$00,$94 ; $b553 retained data / unresolved code
    !byte $c5,$13,$48,$22,$98,$00,$00,$81,$81,$81,$81,$81,$81,$81,$81,$81 ; $b563 retained data / unresolved code
    !byte $81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$c1,$41,$41,$41 ; $b573 retained data / unresolved code
    !byte $41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41 ; $b583 retained data / unresolved code
    !byte $41,$41,$41,$41,$41,$31,$31,$31,$31,$31,$31,$31,$31,$31,$31,$31 ; $b593 retained data / unresolved code
    !byte $31,$31,$31,$31,$31,$31,$31,$31,$31,$31,$31,$31,$31,$31,$31,$19 ; $b5a3 retained data / unresolved code
    !byte $19,$19,$19,$19,$19,$19,$19,$19,$19,$19,$19,$19,$19,$19,$19,$19 ; $b5b3 retained data / unresolved code
    !byte $19,$19,$19,$19,$19,$19,$19,$19,$19,$19,$19,$19,$19,$19,$19,$19 ; $b5c3 retained data / unresolved code
    !byte $19,$19,$19,$19,$19,$19,$00,$00,$00,$00,$00,$00,$ff,$00,$00,$00 ; $b5d3 retained data / unresolved code
    !byte $00,$00,$00,$ff,$09,$09,$09,$09,$09,$09,$09,$09,$09,$00,$00,$00 ; $b5e3 retained data / unresolved code
    !byte $09,$09,$09,$09,$09,$09,$09,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $b5f3 retained data / unresolved code
    !byte $00,$00,$00,$00,$05,$05,$00,$00,$00,$00,$00,$09,$09,$09,$09,$00 ; $b603 retained data / unresolved code
    !byte $00,$03,$03,$41,$09,$11,$05,$01,$00,$00,$00,$09,$09,$09,$09,$09 ; $b613 retained data / unresolved code
    !byte $09,$09,$09,$09,$09,$09,$09,$09,$09,$7f,$05,$05,$05,$05,$05,$05 ; $b623 retained data / unresolved code
    !byte $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$03,$03,$03,$03,$03 ; $b633 retained data / unresolved code
    !byte $03,$03,$03,$03,$03,$1d,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $b643 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00 ; $b653 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$77,$b6,$8b,$b6,$b1,$b6,$d0,$b6,$ed,$b6 ; $b663 retained data / unresolved code
    !byte $0e,$b7,$0e,$b7,$f1,$55,$29,$19,$d3,$53,$dc,$15,$38,$37,$7d,$22 ; $b673 retained data / unresolved code
    !byte $18,$89,$cb,$96,$31,$8e,$f4,$00,$cf,$ac,$a6,$30,$33,$49,$a2,$60 ; $b683 retained data / unresolved code
    !byte $9a,$a6,$88,$46,$60,$89,$c1,$33,$8a,$19,$bc,$33,$49,$9b,$fe,$32 ; $b693 retained data / unresolved code
    !byte $1b,$be,$81,$92,$5f,$49,$e0,$3e,$bb,$e8,$19,$18,$c1,$00,$cf,$8c ; $b6a3 retained data / unresolved code
    !byte $ef,$80,$fb,$86,$ef,$a4,$42,$e3,$7c,$29,$85,$8a,$39,$b9,$90,$dd ; $b6b3 retained data / unresolved code
    !byte $f4,$0c,$9c,$28,$b3,$01,$f5,$df,$40,$c8,$c6,$08,$00,$f5,$df,$48 ; $b6c3 retained data / unresolved code
    !byte $84,$62,$9c,$d8,$62,$46,$e1,$54,$82,$93,$0a,$25,$08,$ee,$11,$31 ; $b6d3 retained data / unresolved code
    !byte $81,$14,$83,$77,$d0,$27,$11,$0c,$10,$00,$f5,$df,$48,$85,$ee,$93 ; $b6e3 retained data / unresolved code
    !byte $05,$44,$26,$61,$54,$82,$88,$98,$d3,$31,$43,$65,$4d,$21,$60,$a8 ; $b6f3 retained data / unresolved code
    !byte $84,$cc,$d1,$d8,$6e,$fa,$04,$e2,$21,$82,$00,$cf,$9c,$f9,$84,$48 ; $b703 retained data / unresolved code
    !byte $12,$9d,$cc,$86,$ef,$a0,$5a,$f1,$38,$22,$90,$6e,$fa,$04,$e2,$21 ; $b713 retained data / unresolved code
    !byte $82,$00 ; $b723 retained data / unresolved code
