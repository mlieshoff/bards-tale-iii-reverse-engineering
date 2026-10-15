; Startup code copies the remainder from $202f to $1800.
!cpu 6510
* = $2000
l_2000:
    jmp l_2004 ; $2000  4c 04 20
    !byte $20 ; $2003 data
l_2004:
    lda $2003 ; $2004  ad 03 20
l_2007:
    sta $034e ; $2007  8d 4e 03
l_200a:
    cld ; $200a  d8
l_200b:
    ldx #$ff ; $200b  a2 ff
l_200d:
    txs ; $200d  9a
l_200e:
    lda #$36 ; $200e  a9 36
l_2010:
    sta $01 ; $2010  85 01
l_2012:
    lda #$2f ; $2012  a9 2f
l_2014:
    sta $00 ; $2014  85 00
l_2016:
    ldx #$08 ; $2016  a2 08
l_2018:
    ldy #$00 ; $2018  a0 00
l_201a:
    lda $202f,y ; $201a  b9 2f 20
l_201d:
    sta $1800,y ; $201d  99 00 18
l_2020:
    iny ; $2020  c8
l_2021:
    bne l_201a ; $2021  d0 f7
l_2023:
    inc $201c ; $2023  ee 1c 20
l_2026:
    inc $201f ; $2026  ee 1f 20
l_2029:
    dex ; $2029  ca
l_202a:
    bne l_201a ; $202a  d0 ee
l_202c:
    jmp $1800 ; $202c  4c 00 18
!pseudopc $1800 {
l_1800:
    jsr l_1977 ; $1800  20 77 19
l_1803:
    ldx #$00 ; $1803  a2 00
l_1805:
    lda $1a1e,x ; $1805  bd 1e 1a
l_1808:
    sta $be00,x ; $1808  9d 00 be
l_180b:
    inx ; $180b  e8
l_180c:
    bne l_1805 ; $180c  d0 f7
l_180e:
    ldx #$6d ; $180e  a2 6d
l_1810:
    ldy #$19 ; $1810  a0 19
l_1812:
    jsr $be02 ; $1812  20 02 be
l_1815:
    bcs l_1873 ; $1815  b0 5c
l_1817:
    ldx #$5b ; $1817  a2 5b
l_1819:
    ldy #$19 ; $1819  a0 19
l_181b:
    jsr $be02 ; $181b  20 02 be
l_181e:
    bcs l_1873 ; $181e  b0 53
l_1820:
    ldx #$64 ; $1820  a2 64
l_1822:
    ldy #$19 ; $1822  a0 19
l_1824:
    jsr $be02 ; $1824  20 02 be
l_1827:
    bcs l_1873 ; $1827  b0 4a
l_1829:
    jsr $4000 ; $1829  20 00 40
l_182c:
    pha ; $182c  48
l_182d:
    lda #$35 ; $182d  a9 35
l_182f:
    sta $01 ; $182f  85 01
l_1831:
    lda #$07 ; $1831  a9 07
l_1833:
    sta $d011 ; $1833  8d 11 d0
l_1836:
    lda #$34 ; $1836  a9 34
l_1838:
    sta $01 ; $1838  85 01
l_183a:
    ldx #$4c ; $183a  a2 4c
l_183c:
    ldy #$19 ; $183c  a0 19
l_183e:
    jsr $be02 ; $183e  20 02 be
l_1841:
    bcs l_1873 ; $1841  b0 30
l_1843:
    pla ; $1843  68
l_1844:
    jsr $2000 ; $1844  20 00 20
l_1847:
    bcs l_180e ; $1847  b0 c5
l_1849:
    ldx #$2c ; $1849  a2 2c
l_184b:
    ldy #$19 ; $184b  a0 19
l_184d:
    jsr $be02 ; $184d  20 02 be
l_1850:
    bcs l_1873 ; $1850  b0 21
l_1852:
    ldx #$53 ; $1852  a2 53
l_1854:
    ldy #$19 ; $1854  a0 19
l_1856:
    jsr $be02 ; $1856  20 02 be
l_1859:
    bcs l_1873 ; $1859  b0 18
l_185b:
    ldx #$42 ; $185b  a2 42
l_185d:
    ldy #$19 ; $185d  a0 19
l_185f:
    jsr $be02 ; $185f  20 02 be
l_1862:
    bcs l_1873 ; $1862  b0 0f
l_1864:
    ldx #$38 ; $1864  a2 38
l_1866:
    ldy #$19 ; $1866  a0 19
l_1868:
    jsr $be02 ; $1868  20 02 be
l_186b:
    bcs l_1873 ; $186b  b0 06
l_186d:
    jsr l_187a ; $186d  20 7a 18
l_1870:
    jmp l_18ee ; $1870  4c ee 18
l_1873:
    lda #$37 ; $1873  a9 37
l_1875:
    sta $01 ; $1875  85 01
l_1877:
    jmp ($fffc) ; $1877  6c fc ff
l_187a:
    lda #$35 ; $187a  a9 35
l_187c:
    sta $01 ; $187c  85 01
l_187e:
    ldx #$00 ; $187e  a2 00
l_1880:
    lda $3e00,x ; $1880  bd 00 3e
l_1883:
    sta $0400,x ; $1883  9d 00 04
l_1886:
    lda $3f00,x ; $1886  bd 00 3f
l_1889:
    sta $0500,x ; $1889  9d 00 05
l_188c:
    lda $4000,x ; $188c  bd 00 40
l_188f:
    sta $0600,x ; $188f  9d 00 06
l_1892:
    lda $4100,x ; $1892  bd 00 41
l_1895:
    sta $0700,x ; $1895  9d 00 07
l_1898:
    lda $41c0,x ; $1898  bd c0 41
l_189b:
    sta $d800,x ; $189b  9d 00 d8
l_189e:
    lda $42c0,x ; $189e  bd c0 42
l_18a1:
    sta $d900,x ; $18a1  9d 00 d9
l_18a4:
    lda $43c0,x ; $18a4  bd c0 43
l_18a7:
    sta $da00,x ; $18a7  9d 00 da
l_18aa:
    lda $44c0,x ; $18aa  bd c0 44
l_18ad:
    sta $db00,x ; $18ad  9d 00 db
l_18b0:
    lda $4800,x ; $18b0  bd 00 48
l_18b3:
    sta $c480,x ; $18b3  9d 80 c4
l_18b6:
    lda $4900,x ; $18b6  bd 00 49
l_18b9:
    sta $c580,x ; $18b9  9d 80 c5
l_18bc:
    lda $4a00,x ; $18bc  bd 00 4a
l_18bf:
    sta $c680,x ; $18bf  9d 80 c6
l_18c2:
    lda $4b00,x ; $18c2  bd 00 4b
l_18c5:
    sta $c780,x ; $18c5  9d 80 c7
l_18c8:
    lda $4c00,x ; $18c8  bd 00 4c
l_18cb:
    sta $c880,x ; $18cb  9d 80 c8
l_18ce:
    lda $4d00,x ; $18ce  bd 00 4d
l_18d1:
    sta $c980,x ; $18d1  9d 80 c9
l_18d4:
    lda $4e00,x ; $18d4  bd 00 4e
l_18d7:
    sta $ca80,x ; $18d7  9d 80 ca
l_18da:
    lda $4f00,x ; $18da  bd 00 4f
l_18dd:
    sta $cb80,x ; $18dd  9d 80 cb
l_18e0:
    lda $4f80,x ; $18e0  bd 80 4f
l_18e3:
    sta $cc00,x ; $18e3  9d 00 cc
l_18e6:
    inx ; $18e6  e8
l_18e7:
    bne l_1880 ; $18e7  d0 97
l_18e9:
    lda #$34 ; $18e9  a9 34
l_18eb:
    sta $01 ; $18eb  85 01
l_18ed:
    rts ; $18ed  60
l_18ee:
    ldx #$00 ; $18ee  a2 00
l_18f0:
    txa ; $18f0  8a
l_18f1:
    lsr ; $18f1  4a
l_18f2:
    lda #$ff ; $18f2  a9 ff
l_18f4:
    bcs l_18f8 ; $18f4  b0 02
l_18f6:
    lda #$fe ; $18f6  a9 fe
l_18f8:
    sta $4000,x ; $18f8  9d 00 40
l_18fb:
    sta $4100,x ; $18fb  9d 00 41
l_18fe:
    sta $4200,x ; $18fe  9d 00 42
l_1901:
    cpx #$fe ; $1901  e0 fe
l_1903:
    bcs l_1910 ; $1903  b0 0b
l_1905:
    lda #$00 ; $1905  a9 00
l_1907:
    sta $02,x ; $1907  95 02
l_1909:
    cpx #$e0 ; $1909  e0 e0
l_190b:
    bcs l_1910 ; $190b  b0 03
l_190d:
    sta $0300,x ; $190d  9d 00 03
l_1910:
    inx ; $1910  e8
l_1911:
    bne l_18f0 ; $1911  d0 dd
l_1913:
    lda #$41 ; $1913  a9 41
l_1915:
    sta $034e ; $1915  8d 4e 03
l_1918:
    dex ; $1918  ca
l_1919:
    txs ; $1919  9a
l_191a:
    cli ; $191a  58
l_191b:
    cld ; $191b  d8
l_191c:
    lda #$35 ; $191c  a9 35
l_191e:
    sta $01 ; $191e  85 01
l_1920:
    lda #$37 ; $1920  a9 37
l_1922:
    sta $d011 ; $1922  8d 11 d0
l_1925:
    lda #$34 ; $1925  a9 34
l_1927:
    sta $01 ; $1927  85 01
l_1929:
    jmp $ff5b ; $1929  4c 5b ff
    !byte $0b,$c2,$c1,$d2,$c4,$b3,$ae,$d0,$c9,$c3,$b6,$b4,$09,$c2,$c1,$d2 ; $192c data
    !byte $c4,$d3,$d5,$c2,$d3,$b1,$09,$c2,$c1,$d2,$c4,$d3,$d5,$c2,$d3,$b2 ; $193c data
    !byte $06,$d5,$d4,$c9,$cc,$b6,$b4,$07,$cd,$d5,$d3,$c9,$c3,$b6,$b4,$08 ; $194c data
    !byte $c4,$cd,$d5,$d3,$c9,$c3,$b6,$b4,$08,$d3,$d0,$cc,$c1,$d3,$c8,$b6 ; $195c data
    !byte $b4,$09,$cd,$c1,$c9,$ce,$d0,$c9,$c3,$b6,$b4 ; $196c data
l_1977:
    sei ; $1977  78
l_1978:
    lda #$35 ; $1978  a9 35
l_197a:
    sta $01 ; $197a  85 01
l_197c:
    lda #$2f ; $197c  a9 2f
l_197e:
    sta $00 ; $197e  85 00
l_1980:
    ldx #$00 ; $1980  a2 00
l_1982:
    ldy #$18 ; $1982  a0 18
l_1984:
    stx $fffc ; $1984  8e fc ff
l_1987:
    sty $fffd ; $1987  8c fd ff
l_198a:
    ldx #$1d ; $198a  a2 1d
l_198c:
    ldy #$1a ; $198c  a0 1a
l_198e:
    stx $fffa ; $198e  8e fa ff
l_1991:
    sty $fffb ; $1991  8c fb ff
l_1994:
    stx $fffe ; $1994  8e fe ff
l_1997:
    sty $ffff ; $1997  8c ff ff
l_199a:
    lda #$7f ; $199a  a9 7f
l_199c:
    sta $dc0d ; $199c  8d 0d dc
l_199f:
    sta $dd0d ; $199f  8d 0d dd
l_19a2:
    lda $dc0d ; $19a2  ad 0d dc
l_19a5:
    lda $dd0d ; $19a5  ad 0d dd
l_19a8:
    ldx #$00 ; $19a8  a2 00
l_19aa:
    lda #$01 ; $19aa  a9 01
l_19ac:
    sta $d800,x ; $19ac  9d 00 d8
l_19af:
    sta $d900,x ; $19af  9d 00 d9
l_19b2:
    sta $da00,x ; $19b2  9d 00 da
l_19b5:
    sta $db00,x ; $19b5  9d 00 db
l_19b8:
    lda #$86 ; $19b8  a9 86
l_19ba:
    sta $0400,x ; $19ba  9d 00 04
l_19bd:
    sta $0500,x ; $19bd  9d 00 05
l_19c0:
    sta $0600,x ; $19c0  9d 00 06
l_19c3:
    sta $0700,x ; $19c3  9d 00 07
l_19c6:
    cpx #$2e ; $19c6  e0 2e
l_19c8:
    bcs l_19d9 ; $19c8  b0 0f
l_19ca:
    lda $19ee,x ; $19ca  bd ee 19
l_19cd:
    sta $d000,x ; $19cd  9d 00 d0
l_19d0:
    cpx #$1d ; $19d0  e0 1d
l_19d2:
    bcs l_19d9 ; $19d2  b0 05
l_19d4:
    lda #$00 ; $19d4  a9 00
l_19d6:
    sta $d400,x ; $19d6  9d 00 d4
l_19d9:
    inx ; $19d9  e8
l_19da:
    bne l_19aa ; $19da  d0 ce
l_19dc:
    lda $dd00 ; $19dc  ad 00 dd
l_19df:
    ora #$03 ; $19df  09 03
l_19e1:
    sta $dd00 ; $19e1  8d 00 dd
l_19e4:
    lda #$3f ; $19e4  a9 3f
l_19e6:
    sta $dd02 ; $19e6  8d 02 dd
l_19e9:
    lda #$34 ; $19e9  a9 34
l_19eb:
    sta $01 ; $19eb  85 01
l_19ed:
    rts ; $19ed  60
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $19ee data
    !byte $00,$07,$00,$00,$00,$00,$18,$00,$18,$00,$00,$00,$00,$00,$00,$00 ; $19fe data
    !byte $00,$00,$02,$03,$04,$00,$01,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$40 ; $1a0e data
    !byte $18,$60,$8e,$22,$be,$a2,$1f,$b5,$30,$9d,$23,$be,$ca,$10,$f8,$ae ; $1a1e data
    !byte $22,$be,$20,$0b,$c2,$08,$a2,$1f,$bd,$23,$be,$95,$30,$ca,$10,$f8 ; $1a2e data
    !byte $28,$60,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $1a3e data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $1a4e data
    !byte $00,$00,$00,$03,$7e,$be,$00,$ba,$00,$04,$00,$00,$00,$00,$00,$00 ; $1a5e data
    !byte $00,$01,$00,$02,$00,$00,$00,$00,$0a,$7e,$be,$c3,$06,$00,$00,$00 ; $1a6e data
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$60,$00,$ba,$00,$00 ; $1a7e data
    !byte $01,$7e,$be,$04,$00,$00,$00,$00,$00,$00,$20,$08,$c2,$60 ; $1a8e data
}
