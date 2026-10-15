; Reconstructed from boot disk file PRODOS
!cpu 6510
* = $02ba
    !word $02bc ; PRG load address
    !byte $12,$08,$0a,$00,$93,$20,$22,$50,$52,$4f,$44,$4f,$53,$22,$2c,$38 ; $02bc data
    !byte $2c,$31,$00,$00,$00,$32,$2e,$30 ; $02cc data
bootstrap:
    lda #$00 ; $02d4  a9 00
l_02d6:
    sta $d011 ; $02d6  8d 11 d0
l_02d9:
    sta $d020 ; $02d9  8d 20 d0
l_02dc:
    lda #$02 ; $02dc  a9 02
l_02de:
    ldx #$08 ; $02de  a2 08
l_02e0:
    ldy #$01 ; $02e0  a0 01
l_02e2:
    jsr $ffba ; $02e2  20 ba ff
l_02e5:
    lda #$03 ; $02e5  a9 03
l_02e7:
    ldx #$d1 ; $02e7  a2 d1
l_02e9:
    ldy #$02 ; $02e9  a0 02
l_02eb:
    jsr $ffbd ; $02eb  20 bd ff
l_02ee:
    lda #$00 ; $02ee  a9 00
l_02f0:
    jsr $ffd5 ; $02f0  20 d5 ff
l_02f3:
    lda #$36 ; $02f3  a9 36
l_02f5:
    sta $01 ; $02f5  85 01
l_02f7:
    lda #$2f ; $02f7  a9 2f
l_02f9:
    sta $00 ; $02f9  85 00
l_02fb:
    lda #$00 ; $02fb  a9 00
l_02fd:
    jmp $c20e ; $02fd  4c 0e c2
    !byte $d4,$02,$d4,$02 ; $0300 data
