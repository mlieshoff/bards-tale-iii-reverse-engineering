; BARDSUBS1 -- resident engine: code, packed text, tables, and state.
; Semantic names are inferred; see docs/game-code-and-assets.md.
; Raw bytes may include unresolved code or overlapping entry points.
!cpu 6510
* = $6600

; Engine re-entry. Clears bit 0 of $d3; A selects mode/resource.
; A=$fe/$ff take the special resource path; $08 caches ordinary modes.
; Several exits reset SP and JMP $9b00: this is an overlay transition, not RTS.
enter_engine:
    lsr $d3 ; $6600  46 d3
    cmp #$fe ; $6602  c9 fe
    bcc l_661e ; $6604  90 18
    sta $07 ; $6606  85 07
    pha ; $6608  48
    lda #$00 ; $6609  a9 00
    sta $35 ; $660b  85 35
    jsr load_resource_by_id ; $660d  20 8d 66
    jsr $9b00 ; $6610  20 00 9b
    jsr load_current_mode_resource ; $6613  20 54 66
    pla ; $6616  68
    lsr ; $6617  4a
    bcs l_661b ; $6618  b0 01
    rts ; $661a  60
l_661b:
    jmp restart_overlay_with_clean_stack ; $661b  4c 7a 68
l_661e:
    sta $08 ; $661e  85 08
    cmp #$01 ; $6620  c9 01
    bne l_6628 ; $6622  d0 04
    clc ; $6624  18
    jsr load_area_resources ; $6625  20 80 68
l_6628:
    jsr load_current_mode_resource ; $6628  20 54 66
    lda $08 ; $662b  a5 08
    bne l_661b ; $662d  d0 ec

; Mode zero: derive resource ID from $0c + $1d. Cache it in $03.
; $1053/$1054 choose additional resources; field meanings remain unverified.
    lda $0c ; $662f  a5 0c
    clc ; $6631  18
    adc #$1d ; $6632  69 1d
    cmp $03 ; $6634  c5 03
    sta $03 ; $6636  85 03
    beq l_663f ; $6638  f0 05
    sta $35 ; $663a  85 35
    jsr load_resource_by_id ; $663c  20 8d 66
l_663f:
    ldx $1053 ; $663f  ae 53 10
    jsr load_cached_resource_x ; $6642  20 5c 66
    lda $1054 ; $6645  ad 54 10
    rol ; $6648  2a
    rol ; $6649  2a
    rol ; $664a  2a
    and #$03 ; $664b  29 03
    tax ; $664d  aa
    jsr load_cached_variant_x ; $664e  20 b9 68
    jmp restart_overlay_with_clean_stack ; $6651  4c 7a 68

; Translate cached mode $08 to resource ID (mode + 1).
load_current_mode_resource:
    ldx $08 ; $6654  a6 08
    inx ; $6656  e8
    stx $35 ; $6657  86 35
    jmp load_resource_by_id ; $6659  4c 8d 66

; Skip reload if X matches $04. Otherwise load resource X+$69,
; then pad with $20 until the self-modifying output pointer reaches $4780.
load_cached_resource_x:
    cpx $04 ; $665c  e4 04
    beq l_667c ; $665e  f0 1c
    stx $04 ; $6660  86 04
    txa ; $6662  8a
    clc ; $6663  18
    adc #$69 ; $6664  69 69
    sta $35 ; $6666  85 35
    jsr load_resource_by_id ; $6668  20 8d 66
l_666b:
    lda #$20 ; $666b  a9 20
    jsr write_resource_byte ; $666d  20 ad 67
    lda $67ae ; $6670  ad ae 67
    cmp #$80 ; $6673  c9 80
    lda $67af ; $6675  ad af 67
    sbc #$47 ; $6678  e9 47
    bcc l_666b ; $667a  90 ef
l_667c:
    rts ; $667c  60

; Cache X in $06, load resource X while preserving A, then JMP $9300.
; $9300 is outside this module and is an overlay execution address.
load_cached_overlay_x:
    cpx $06 ; $667d  e4 06
    beq l_668a ; $667f  f0 09
    stx $06 ; $6681  86 06
    stx $35 ; $6683  86 35
    pha ; $6685  48
    jsr load_resource_by_id ; $6686  20 8d 66
    pla ; $6689  68
l_668a:
    jmp $9300 ; $668a  4c 00 93

; Resource lookup. Input: 16-bit ID $6ad2:$35 (high:low).
; Scan 16-bit size entries at $4000. Sum preceding sizes into the
; 24-bit byte offset $be57:$be56:$be55, initially $000300.
; A high size byte $ff marks a disk-change record rather than payload.
; $be4b/$be4c = destination; $be4d/$be4e = byte count. Carry reports failure.
load_resource_by_id:
    ldx #$00 ; $668d  a2 00
    stx $be55 ; $668f  8e 55 be
    stx $be57 ; $6692  8e 57 be
    lda #$03 ; $6695  a9 03
    sta $be56 ; $6697  8d 56 be
    stx $9b ; $669a  86 9b
    lda #$40 ; $669c  a9 40
    sta $9c ; $669e  85 9c
    lda $35 ; $66a0  a5 35
    sta $9d ; $66a2  85 9d
    lda $6ad2 ; $66a4  ad d2 6a
    sta $9e ; $66a7  85 9e
    ldy #$01 ; $66a9  a0 01
l_66ab:
    lda $9d ; $66ab  a5 9d
    ora $9e ; $66ad  05 9e
    beq l_66e2 ; $66af  f0 31
    lda ($9b),y ; $66b1  b1 9b
    cmp #$ff ; $66b3  c9 ff
    beq l_66cf ; $66b5  f0 18
    clc ; $66b7  18
    lda ($9b,x) ; $66b8  a1 9b
    adc $be55 ; $66ba  6d 55 be
    sta $be55 ; $66bd  8d 55 be
    lda ($9b),y ; $66c0  b1 9b
    adc $be56 ; $66c2  6d 56 be
    sta $be56 ; $66c5  8d 56 be
    txa ; $66c8  8a
    adc $be57 ; $66c9  6d 57 be
    sta $be57 ; $66cc  8d 57 be
l_66cf:
    inc $9b ; $66cf  e6 9b
    inc $9b ; $66d1  e6 9b
    bne l_66d7 ; $66d3  d0 02
    inc $9c ; $66d5  e6 9c
l_66d7:
    lda $9d ; $66d7  a5 9d
    bne l_66dd ; $66d9  d0 02
    dec $9e ; $66db  c6 9e
l_66dd:
    dec $9d ; $66dd  c6 9d
    jmp l_66ab ; $66df  4c ab 66
l_66e2:
    lda ($9b,x) ; $66e2  a1 9b
    sta $be4d ; $66e4  8d 4d be
    lda ($9b),y ; $66e7  b1 9b
    sta $be4e ; $66e9  8d 4e be
    ora $be4d ; $66ec  0d 4d be
    sec ; $66ef  38
    beq l_6739 ; $66f0  f0 47
    lda ($9b),y ; $66f2  b1 9b
    cmp #$ff ; $66f4  c9 ff
    bne l_6700 ; $66f6  d0 08
    lda ($9b,x) ; $66f8  a1 9b
    jsr require_disk_id ; $66fa  20 b9 67
    jmp load_resource_by_id ; $66fd  4c 8d 66

; Classify resource ID, then select its load/decode destination.
; The address table at $678f is DATA, not executable instructions.
l_6700:
    jsr resource_destination_class ; $6700  20 5c 68
    tya ; $6703  98
    pha ; $6704  48
    asl ; $6705  0a
    tax ; $6706  aa
    ldy $678f,x ; $6707  bc 8f 67
    lda $6790,x ; $670a  bd 90 67
    sty $be4b ; $670d  8c 4b be
    sta $be4c ; $6710  8d 4c be
    sty $67ae ; $6713  8c ae 67
    sta $67af ; $6716  8d af 67
    pla ; $6719  68
    tay ; $671a  a8
    cpy #$04 ; $671b  c0 04
    bcc l_6728 ; $671d  90 09
    cpy #$07 ; $671f  c0 07
    bne l_673f ; $6721  d0 1c
    lda $6ad3 ; $6723  ad d3 6a
    bne l_673f ; $6726  d0 17
l_6728:
    ldy $678f,x ; $6728  bc 8f 67
    lda $6790,x ; $672b  bd 90 67
    sty $be4b ; $672e  8c 4b be
    sta $be4c ; $6731  8d 4c be
    jsr read_resource_bytes ; $6734  20 17 69
    bcs l_67a7 ; $6737  b0 6e
l_6739:
    lda #$00 ; $6739  a9 00
    sta $6ad2 ; $673b  8d d2 6a
    rts ; $673e  60

; Compressed path: stage compressed bytes immediately below the
; final buffer end, initialize the bit decoder, and expand using decode_resource_byte.
l_673f:
    sec ; $673f  38
    lda $6797,x ; $6740  bd 97 67
    sta $6ad4 ; $6743  8d d4 6a
    sbc $be4d ; $6746  ed 4d be
    sta $be4b ; $6749  8d 4b be
    sta $6ad6 ; $674c  8d d6 6a
    lda $6798,x ; $674f  bd 98 67
    sta $6ad5 ; $6752  8d d5 6a
    sbc $be4e ; $6755  ed 4e be
    sta $be4c ; $6758  8d 4c be
    sta $6ad7 ; $675b  8d d7 6a
    jsr read_resource_bytes ; $675e  20 17 69
    bcs l_67a7 ; $6761  b0 44
    ldx $6ad6 ; $6763  ae d6 6a
    ldy $6ad7 ; $6766  ac d7 6a
    jsr initialize_resource_decoder ; $6769  20 99 82

; Decode and emit until the compressed source pointer reaches its limit.
; Two final decoder calls follow; their format role is not established.
l_676c:
    jsr decode_resource_byte ; $676c  20 b8 82
    jsr write_resource_byte ; $676f  20 ad 67
    lda $833c ; $6772  ad 3c 83
    cmp $6ad4 ; $6775  cd d4 6a
    lda $833d ; $6778  ad 3d 83
    sbc $6ad5 ; $677b  ed d5 6a
    bcc l_676c ; $677e  90 ec
    jsr decode_resource_byte ; $6780  20 b8 82
    jsr write_resource_byte ; $6783  20 ad 67
    jsr decode_resource_byte ; $6786  20 b8 82
    jsr write_resource_byte ; $6789  20 ad 67
    clc ; $678c  18
    bcc l_6739 ; $678d  90 aa

; Eight little-endian resource destinations: $9b00,$9300,$a800,$ad00,
; $1040,$4780,$4300,$0800. The next four words give end limits
; $1f80,$6600,$4780,$1040 for compressed classes 4..7.
    !byte $00,$9b,$00,$93,$00,$a8,$00,$ad,$40,$10,$80,$47,$00,$43,$00,$08 ; $678f retained data / unresolved code
    !byte $80,$1f,$00,$66,$80,$47,$40,$10 ; $679f retained data / unresolved code
l_67a7:
    jsr prompt_for_disk ; $67a7  20 fb 67
    jmp load_resource_by_id ; $67aa  4c 8d 66

; Self-modifying output cursor. $67ae/$67af are the operand bytes
; of this STA, patched before entry. Emit A and advance the 16-bit pointer.
write_resource_byte:
    sta $ffff ; $67ad  8d ff ff
    inc $67ae ; $67b0  ee ae 67
    bne l_67b8 ; $67b3  d0 03
    inc $67af ; $67b5  ee af 67
l_67b8:
    rts ; $67b8  60

; Complement a disk marker to obtain expected disk ID. Repeatedly
; check the disk and prompt until its ID matches. Do not assume this returns normally.
require_disk_id:
    eor #$ff ; $67b9  49 ff
    sta $6ad8 ; $67bb  8d d8 6a
l_67be:
    jsr check_disk_and_read_index ; $67be  20 c7 67
    jsr prompt_for_disk ; $67c1  20 fb 67
    jmp l_67be ; $67c4  4c be 67

; Read/check block zero, compare $bbff with expected disk ID at $6ad8.
; On a match, read $0300 bytes into $4000 (the resource-size index).
; The success path discards one return address using two PLA instructions.
check_disk_and_read_index:
    ldx #$00 ; $67c7  a2 00
    ldy #$00 ; $67c9  a0 00
    jsr l_6a70 ; $67cb  20 70 6a
    bcs l_67fa ; $67ce  b0 2a
    lda $bbff ; $67d0  ad ff bb
    cmp $6ad8 ; $67d3  cd d8 6a
    bne l_67fa ; $67d6  d0 22
    ldy #$00 ; $67d8  a0 00
    sty $be55 ; $67da  8c 55 be
    sty $be56 ; $67dd  8c 56 be
    sty $be57 ; $67e0  8c 57 be
    sty $be4d ; $67e3  8c 4d be
    lda #$03 ; $67e6  a9 03
    sta $be4e ; $67e8  8d 4e be
    sty $be4b ; $67eb  8c 4b be
    lda #$40 ; $67ee  a9 40
    sta $be4c ; $67f0  8d 4c be
    jsr read_resource_bytes ; $67f3  20 17 69
    bcs l_67fa ; $67f6  b0 02
    pla ; $67f8  68
    pla ; $67f9  68
l_67fa:
    rts ; $67fa  60

; Print an inline packed disk-insertion prompt, select a disk name
; through the pointer table at $6821, then request input and reset the text area.
prompt_for_disk:
    jsr print_inline_packed_text ; $67fb  20 07 74

; Packed text: 'Please insert your '
    !byte $f4,$18,$61,$48,$c1,$53,$a4,$68,$cc,$37,$7d,$22,$10,$00 ; $67fe retained data / unresolved code
    lda $6ad8 ; $680c  ad d8 6a
    asl ; $680f  0a
    tax ; $6810  aa
    lda $6821,x ; $6811  bd 21 68
    ldy $6822,x ; $6814  bc 22 68
    tax ; $6817  aa
    jsr print_packed_text_xy ; $6818  20 19 74
    jsr l_6f0d ; $681b  20 0d 6f
    jmp l_8673 ; $681e  4c 73 86

; Four disk-name pointers: Boot, Character, Dungeon A, Dungeon B.
; These point to packed strings at $6829,$6831,$683c,$684c.
    !byte $29,$68,$31,$68,$3c,$68,$4c,$68,$f0,$de,$f9,$84,$aa,$92,$f0,$00 ; $6821 retained data / unresolved code
    !byte $f1,$12,$28,$88,$93,$34,$42,$55,$49,$78,$00,$f1,$68,$e4,$19,$ee ; $6831 retained data / unresolved code
    !byte $0f,$8a,$a9,$2c,$3e,$92,$8a,$60,$f8,$58,$00,$f1,$68,$e4,$19,$ee ; $6841 retained data / unresolved code
    !byte $0f,$8a,$a9,$2c,$3e,$92,$8a,$60,$f8,$78,$00 ; $6851 retained data / unresolved code

; Choose one of eight resource classes using ID thresholds at $686e.
; Nonzero high ID byte selects class 7 directly.
resource_destination_class:
    ldy #$07 ; $685c  a0 07
    lda $6ad2 ; $685e  ad d2 6a
    bne l_686d ; $6861  d0 0a
    lda $35 ; $6863  a5 35
l_6865:
    cmp $686e,y ; $6865  d9 6e 68
    bcs l_686d ; $6868  b0 03
    dey ; $686a  88
    bpl l_6865 ; $686b  10 f8
l_686d:
    rts ; $686d  60

; Resource-class thresholds: 0,4,13,23,29,100,105,146. IDs below
; 29 select code overlays; later classes select compressed resource buffers.
    !byte $00,$04,$0d,$17,$1d,$64,$69,$92,$18,$20,$80,$68 ; $686e retained data / unresolved code

; Discard the entire current call chain (SP=$ff), then execute overlay $9b00.
restart_overlay_with_clean_stack:
    ldx #$ff ; $687a  a2 ff
    txs ; $687c  9a
    jmp $9b00 ; $687d  4c 00 9b

; Load resource ($35+$27) if changed, select variant using $1050,
; and another resource using $105d. Saved carry controls coordinate adjustments.
load_area_resources:
    php ; $6880  08
    lda $35 ; $6881  a5 35
    clc ; $6883  18
    adc #$27 ; $6884  69 27
    cmp $03 ; $6886  c5 03
    sta $03 ; $6888  85 03
    beq l_6891 ; $688a  f0 05
    sta $35 ; $688c  85 35
    jsr load_resource_by_id ; $688e  20 8d 66
l_6891:
    lda $1050 ; $6891  ad 50 10
    rol ; $6894  2a
    rol ; $6895  2a
    rol ; $6896  2a
    and #$03 ; $6897  29 03
    clc ; $6899  18
    adc #$03 ; $689a  69 03
    tax ; $689c  aa
    jsr load_cached_variant_x ; $689d  20 b9 68
    ldx $105d ; $68a0  ae 5d 10
    jsr load_cached_resource_x ; $68a3  20 5c 66
    plp ; $68a6  28
    bcc l_68b8 ; $68a7  90 0f
    lda $09 ; $68a9  a5 09
    sbc $1061 ; $68ab  ed 61 10
    sta $09 ; $68ae  85 09
    sec ; $68b0  38
    lda $0a ; $68b1  a5 0a
    sbc $1060 ; $68b3  ed 60 10
    sta $0a ; $68b6  85 0a
l_68b8:
    rts ; $68b8  60

; Variant cache $05; map X to resource X+$64.
load_cached_variant_x:
    cpx $05 ; $68b9  e4 05
    beq l_68c8 ; $68bb  f0 0b
    stx $05 ; $68bd  86 05
    txa ; $68bf  8a
    clc ; $68c0  18
    adc #$64 ; $68c1  69 64
    sta $35 ; $68c3  85 35
    jmp load_resource_by_id ; $68c5  4c 8d 66
l_68c8:
    rts ; $68c8  60

; X is picture index: base resource=146+2*X, companion=147+2*X.
; Draw base via $8232, decompress companion to $0800, initialize four
; XOR animation tracks via $8352. X >= $fe clears the portrait.
load_picture_pair:
    cpx $02 ; $68c9  e4 02
    beq l_68c8 ; $68cb  f0 fb
    stx $02 ; $68cd  86 02
    cpx #$fe ; $68cf  e0 fe
    bcs l_6914 ; $68d1  b0 41
    txa ; $68d3  8a
    asl ; $68d4  0a
    clc ; $68d5  18
    adc #$92 ; $68d6  69 92
    sta $35 ; $68d8  85 35
    bcc l_68df ; $68da  90 03
    inc $6ad2 ; $68dc  ee d2 6a
l_68df:
    lda $6ad2 ; $68df  ad d2 6a
    pha ; $68e2  48
    lda #$00 ; $68e3  a9 00
    sta $6ad3 ; $68e5  8d d3 6a
    jsr load_resource_by_id ; $68e8  20 8d 66
    bcs l_690e ; $68eb  b0 21
    jsr l_8232 ; $68ed  20 32 82
    dec $6ad3 ; $68f0  ce d3 6a
    ldx #$0f ; $68f3  a2 0f
    lda #$00 ; $68f5  a9 00
l_68f7:
    sta $0800,x ; $68f7  9d 00 08
    dex ; $68fa  ca
    bpl l_68f7 ; $68fb  10 fa
    pla ; $68fd  68
    sta $6ad2 ; $68fe  8d d2 6a
    inc $35 ; $6901  e6 35
    bne l_6908 ; $6903  d0 03
    inc $6ad2 ; $6905  ee d2 6a
l_6908:
    jsr load_resource_by_id ; $6908  20 8d 66
    jmp l_8352 ; $690b  4c 52 83
l_690e:
    pla ; $690e  68
    lda #$00 ; $690f  a9 00
    sta $6ad2 ; $6911  8d d2 6a
l_6914:
    jmp l_81ca ; $6914  4c ca 81

; Read a byte range from the game resource stream, not a DOS file.
; Convert 24-bit byte offset to 512-byte block number (+1), copy partial
; first/last blocks through $ba00/$bb00, transfer full blocks directly.
; Uses $be4b..$be4e and $be55..$be57; saves/restores zero-page workspace.
read_resource_bytes:
    jsr save_loader_workspace ; $6917  20 40 6a
    lda $be57 ; $691a  ad 57 be
    lsr ; $691d  4a
    sta $47 ; $691e  85 47
    lda $be56 ; $6920  ad 56 be
    ror ; $6923  6a
    sta $46 ; $6924  85 46
    inc $46 ; $6926  e6 46
    bne l_692c ; $6928  d0 02
    inc $47 ; $692a  e6 47
l_692c:
    jsr read_block_to_staging ; $692c  20 a4 6a
    bcs l_69a7 ; $692f  b0 76
    lda $be4b ; $6931  ad 4b be
    sta $44 ; $6934  85 44
    lda $be4c ; $6936  ad 4c be
    sta $45 ; $6939  85 45
    sec ; $693b  38
    lda #$00 ; $693c  a9 00
    sbc $be55 ; $693e  ed 55 be
    sta $30 ; $6941  85 30
    lda $be56 ; $6943  ad 56 be
    and #$01 ; $6946  29 01
    sta $31 ; $6948  85 31
    lda #$02 ; $694a  a9 02
    sbc $31 ; $694c  e5 31
    sta $31 ; $694e  85 31
    lda $30 ; $6950  a5 30
    cmp $be4d ; $6952  cd 4d be
    lda $31 ; $6955  a5 31
    sbc $be4e ; $6957  ed 4e be
    bcc l_695f ; $695a  90 03
    jmp l_69fc ; $695c  4c fc 69
l_695f:
    ldx $be55 ; $695f  ae 55 be
    ldy #$00 ; $6962  a0 00
    lda $be56 ; $6964  ad 56 be
    lsr ; $6967  4a
    bcs l_6976 ; $6968  b0 0c
l_696a:
    lda $ba00,x ; $696a  bd 00 ba
    sta ($44),y ; $696d  91 44
    iny ; $696f  c8
    inx ; $6970  e8
    bne l_696a ; $6971  d0 f7
    jsr l_6a5a ; $6973  20 5a 6a
l_6976:
    lda $bb00,x ; $6976  bd 00 bb
    sta ($44),y ; $6979  91 44
    iny ; $697b  c8
    inx ; $697c  e8
    bne l_6976 ; $697d  d0 f7
    jsr l_6a5a ; $697f  20 5a 6a
    sec ; $6982  38
    lda $be4d ; $6983  ad 4d be
    sbc $30 ; $6986  e5 30
    sta $be4d ; $6988  8d 4d be
    lda $be4e ; $698b  ad 4e be
    sbc $31 ; $698e  e5 31
    sta $be4e ; $6990  8d 4e be
l_6993:
    lda $be4b ; $6993  ad 4b be
    sta $44 ; $6996  85 44
    lda $be4c ; $6998  ad 4c be
    sta $45 ; $699b  85 45
    lda $be4e ; $699d  ad 4e be
    cmp #$02 ; $69a0  c9 02
    bcc l_69b7 ; $69a2  90 13
    jsr transfer_next_block ; $69a4  20 ac 6a
l_69a7:
    bcs l_69f9 ; $69a7  b0 50
    inc $be4c ; $69a9  ee 4c be
    inc $be4c ; $69ac  ee 4c be
    dec $be4e ; $69af  ce 4e be
    dec $be4e ; $69b2  ce 4e be
    bne l_6993 ; $69b5  d0 dc
l_69b7:
    jsr read_block_to_staging ; $69b7  20 a4 6a
    lda $be4b ; $69ba  ad 4b be
    sta $44 ; $69bd  85 44
    lda $be4c ; $69bf  ad 4c be
    sta $45 ; $69c2  85 45
    ldy #$00 ; $69c4  a0 00
    lda $be4e ; $69c6  ad 4e be
    beq l_69e8 ; $69c9  f0 1d
l_69cb:
    lda $ba00,y ; $69cb  b9 00 ba
    sta ($44),y ; $69ce  91 44
    iny ; $69d0  c8
    bne l_69cb ; $69d1  d0 f8
    inc $45 ; $69d3  e6 45
    ldy $be4d ; $69d5  ac 4d be
    beq l_69e5 ; $69d8  f0 0b
    dey ; $69da  88
l_69db:
    lda $bb00,y ; $69db  b9 00 bb
    sta ($44),y ; $69de  91 44
    dey ; $69e0  88
    cpy #$ff ; $69e1  c0 ff
    bne l_69db ; $69e3  d0 f6
l_69e5:
    clc ; $69e5  18
    bcc l_69f9 ; $69e6  90 11
l_69e8:
    ldy $be4d ; $69e8  ac 4d be
    beq l_69e5 ; $69eb  f0 f8
    dey ; $69ed  88
l_69ee:
    lda $ba00,y ; $69ee  b9 00 ba
    sta ($44),y ; $69f1  91 44
    dey ; $69f3  88
    cpy #$ff ; $69f4  c0 ff
    bne l_69ee ; $69f6  d0 f6
    clc ; $69f8  18
l_69f9:
    jmp restore_loader_workspace ; $69f9  4c 4b 6a
l_69fc:
    clc ; $69fc  18
    lda $be55 ; $69fd  ad 55 be
    adc $be4d ; $6a00  6d 4d be
    sta $32 ; $6a03  85 32
    lda $be56 ; $6a05  ad 56 be
    and #$01 ; $6a08  29 01
    adc $be4e ; $6a0a  6d 4e be
    adc #$ba ; $6a0d  69 ba
    sta $33 ; $6a0f  85 33
    lda $be55 ; $6a11  ad 55 be
    sta $34 ; $6a14  85 34
    lda $be56 ; $6a16  ad 56 be
    and #$01 ; $6a19  29 01
    clc ; $6a1b  18
    adc #$ba ; $6a1c  69 ba
    sta $35 ; $6a1e  85 35
    ldy #$00 ; $6a20  a0 00
    ldx #$00 ; $6a22  a2 00
l_6a24:
    lda ($34,x) ; $6a24  a1 34
    sta ($44),y ; $6a26  91 44
    iny ; $6a28  c8
    bne l_6a2d ; $6a29  d0 02
    inc $45 ; $6a2b  e6 45
l_6a2d:
    inc $34 ; $6a2d  e6 34
    bne l_6a33 ; $6a2f  d0 02
    inc $35 ; $6a31  e6 35
l_6a33:
    lda $34 ; $6a33  a5 34
    cmp $32 ; $6a35  c5 32
    lda $35 ; $6a37  a5 35
    sbc $33 ; $6a39  e5 33
    bcc l_6a24 ; $6a3b  90 e7
    clc ; $6a3d  18
    bcc l_69f9 ; $6a3e  90 b9
save_loader_workspace:
    ldx #$1f ; $6a40  a2 1f
l_6a42:
    lda $30,x ; $6a42  b5 30
    sta $02e0,x ; $6a44  9d e0 02
    dex ; $6a47  ca
    bpl l_6a42 ; $6a48  10 f8
    rts ; $6a4a  60
restore_loader_workspace:
    ldx #$1f ; $6a4b  a2 1f
    php ; $6a4d  08
    pha ; $6a4e  48
l_6a4f:
    lda $02e0,x ; $6a4f  bd e0 02
    sta $30,x ; $6a52  95 30
    dex ; $6a54  ca
    bpl l_6a4f ; $6a55  10 f8
    pla ; $6a57  68
    plp ; $6a58  28
    rts ; $6a59  60
l_6a5a:
    dey ; $6a5a  88
    tya ; $6a5b  98
    sec ; $6a5c  38
    adc $44 ; $6a5d  65 44
    sta $44 ; $6a5f  85 44
    sta $be4b ; $6a61  8d 4b be
    lda #$00 ; $6a64  a9 00
    adc $45 ; $6a66  65 45
    sta $45 ; $6a68  85 45
    sta $be4c ; $6a6a  8d 4c be
    ldy #$00 ; $6a6d  a0 00
    rts ; $6a6f  60
l_6a70:
    txa ; $6a70  8a
    pha ; $6a71  48
    tya ; $6a72  98
    pha ; $6a73  48
    jsr save_loader_workspace ; $6a74  20 40 6a
    pla ; $6a77  68
    sta $47 ; $6a78  85 47
    pla ; $6a7a  68
    sta $46 ; $6a7b  85 46
    jsr read_block_to_staging ; $6a7d  20 a4 6a
    jmp restore_loader_workspace ; $6a80  4c 4b 6a
    !byte $8a,$48,$98,$48,$20,$40,$6a,$68,$85,$47,$68,$85,$46,$a9,$02,$8d ; $6a83 retained data / unresolved code
    !byte $ad,$6a,$20,$a4,$6a,$08,$48,$a9,$01,$8d,$ad,$6a,$68,$28,$4c,$4b ; $6a93 retained data / unresolved code
    !byte $6a ; $6aa3 retained data / unresolved code

; Set staging buffer to $ba00; continue into next-block transfer.
read_block_to_staging:
    lda #$00 ; $6aa4  a9 00
    sta $44 ; $6aa6  85 44
    lda #$ba ; $6aa8  a9 ba
    sta $45 ; $6aaa  85 45

; Set read command $42=1 and call the $be7a wrapper, which invokes
; the boot loader block API at $c208. Advance block number $46/$47.
transfer_next_block:
    lda #$01 ; $6aac  a9 01
    sta $42 ; $6aae  85 42
    jsr $be7a ; $6ab0  20 7a be
    inc $46 ; $6ab3  e6 46
    bne l_6ab9 ; $6ab5  d0 02
    inc $47 ; $6ab7  e6 47
l_6ab9:
    rts ; $6ab9  60
    !byte $48,$20,$e2,$91,$85,$37,$a5,$12,$85,$36,$a0,$00,$b1,$36,$d0,$02 ; $6aba retained data / unresolved code
    !byte $68,$60,$a2,$04,$68,$4c,$7d,$66

; Mutable loader state: ID high byte, load/decode mode, output end,
; staging start, and required disk ID. These bytes are not instructions.
    !byte $00,$00,$00,$00,$00,$00,$00,$a2 ; $6ad2 retained data / unresolved code
    !byte $9b,$a5,$2f,$c9,$ff,$f0,$02,$a2,$80,$8e,$04,$6b,$a2,$7b,$a5,$08 ; $6ada retained data / unresolved code
    !byte $d0,$07,$ad,$52,$10,$4a,$b0,$01,$ca,$8e,$f9,$6a,$20,$0f,$8b,$7b ; $6aea retained data / unresolved code
    !byte $20,$02,$4b,$6b,$d0,$4e,$6b,$01,$59,$6b,$9b,$61,$6b,$c3,$69,$6b ; $6afa retained data / unresolved code
    !byte $c2,$8e,$6b,$d5,$87,$6d,$d6,$ee,$6c,$93,$eb,$6c,$c4,$f6,$6c,$00 ; $6b0a retained data / unresolved code
    !byte $1c,$6b,$48,$a2,$00,$ad,$4e,$03,$29,$01,$f0,$02,$a2,$07,$a0,$00 ; $6b1a retained data / unresolved code
    !byte $68,$dd,$3d,$6b,$f0,$08,$e8,$c8,$c0,$07,$90,$f5,$18,$60,$98,$09 ; $6b2a retained data / unresolved code
    !byte $80,$d0,$1f,$a1,$c0,$a3,$a4,$a5,$de,$a6,$a1,$a2,$a3,$a4,$a5,$a6 ; $6b3a retained data / unresolved code
    !byte $a7,$a9,$00,$2c,$a9,$01,$85,$61,$a9,$fe,$20,$00,$66,$38,$60,$38 ; $6b4a retained data / unresolved code
    !byte $e9,$b1,$20,$ba,$6a,$38,$60,$20,$73,$86,$20,$20,$91,$38,$60,$20 ; $6b5a retained data / unresolved code
    !byte $5d,$6e,$b0,$f9,$c9,$04,$b0,$13,$48,$20,$07,$74,$f1,$05,$29,$84 ; $6b6a retained data / unresolved code
    !byte $53,$08,$00,$68,$20,$ab,$fa,$b0,$e4,$85,$5d,$20,$73,$86,$20,$81 ; $6b7a retained data / unresolved code
    !byte $e9,$4c,$0d,$6f,$20,$07,$74,$f5,$92,$f0,$d9,$4c,$60,$60,$c1,$5f ; $6b8a retained data / unresolved code
    !byte $fc,$00,$20,$37,$8f,$b0,$c6,$84,$36,$85,$37,$a0,$2d,$b1,$36,$29 ; $6b9a retained data / unresolved code
    !byte $1c,$d0,$ba,$8a,$4a,$8d,$ea,$6c,$a0,$29,$b1,$36,$c9,$06,$f0,$0f ; $6baa retained data / unresolved code
    !byte $20,$07,$74,$f3,$9f,$30,$88,$23,$14,$4b,$c0,$00,$4c,$0d,$6f,$ae ; $6bba retained data / unresolved code
    !byte $ea,$6c,$20,$bb,$6f,$90,$1a,$20,$07,$74,$f5,$df,$40,$8a,$26,$76 ; $6bca retained data / unresolved code
    !byte $a6,$1a,$49,$4e,$40,$44,$e0,$a9,$d2,$9c,$68,$d3,$3a,$7c,$00,$90 ; $6bda retained data / unresolved code
    !byte $db,$ae,$ea,$6c,$a9,$05,$20,$83,$6f,$90,$1d,$a0,$64,$b1,$36,$d0 ; $6bea retained data / unresolved code
    !byte $13,$20,$07,$74,$f5,$df,$48,$86,$69,$8b,$c5,$30,$aa,$41,$2c,$6f ; $6bfa retained data / unresolved code
    !byte $c0,$00,$90,$b8,$e9,$01,$91,$36,$18,$24,$38,$6e,$e9,$6c,$20,$73 ; $6c0a retained data / unresolved code
    !byte $86,$a9,$31,$8d,$2f,$6c,$a2,$00,$8e,$5a,$6c,$a0,$65,$b1,$36,$3d ; $6c1a retained data / unresolved code
    !byte $58,$cd,$f0,$29,$a9,$31,$20,$8e,$84,$a9,$a9,$20,$8e,$84,$20,$89 ; $6c2a retained data / unresolved code
    !byte $84,$8a,$48,$0a,$aa,$bd,$04,$da,$bc,$05,$da,$aa,$20,$19,$74,$20 ; $6c3a retained data / unresolved code
    !byte $8c,$84,$68,$aa,$ad,$2f,$6c,$09,$80,$ee,$2f,$6c,$2c,$a9,$80,$a0 ; $6c4a retained data / unresolved code
    !byte $00,$99,$8b,$6c,$c8,$c8,$c8,$8c,$5a,$6c,$e8,$e0,$08,$90,$bc,$a9 ; $6c5a retained data / unresolved code
    !byte $80,$2c,$e9,$6c,$30,$13,$20,$0a,$74,$fd,$53,$7c,$03,$06,$0a,$ea ; $6c6a retained data / unresolved code
    !byte $72,$02,$20,$c9,$ee,$40,$00,$a9,$d3,$8d,$a3,$6c,$20,$0f,$8b,$42 ; $6c7a retained data / unresolved code
    !byte $a0,$b1,$aa,$6c,$b2,$ad,$6c,$b3,$b0,$6c,$b4,$b3,$6c,$b5,$b6,$6c ; $6c8a retained data / unresolved code
    !byte $b6,$b9,$6c,$b7,$bc,$6c,$b8,$bf,$6c,$d3,$c8,$6c,$9b,$d0,$6c,$ff ; $6c9a retained data / unresolved code
    !byte $a9,$00,$2c,$a9,$01,$2c,$a9,$02,$2c,$a9,$03,$2c,$a9,$04,$2c,$a9 ; $6caa retained data / unresolved code
    !byte $05,$2c,$a9,$06,$2c,$a9,$07,$2c,$e9,$6c,$10,$0c,$18,$60,$20,$73 ; $6cba retained data / unresolved code
    !byte $86,$a5,$99,$20,$2a,$92,$38,$60,$48,$20,$c8,$6c,$68,$85,$9a,$ad ; $6cca retained data / unresolved code
    !byte $ea,$6c,$85,$99,$aa,$a5,$9a,$20,$19,$92,$20,$7f,$92,$38,$60,$00 ; $6cda retained data / unresolved code
    !byte $00,$a9,$40,$2c,$a9,$80,$45,$33,$85,$33,$38,$60,$20,$07,$74,$f5 ; $6cea retained data / unresolved code
    !byte $92,$f0,$d9,$4c,$60,$6e,$fa,$04,$b1,$7c,$3f,$c0,$00,$20,$0f,$8b ; $6cfa retained data / unresolved code
    !byte $52,$a0,$01,$13,$6d,$9b,$57,$6b,$ff,$38,$e9,$b1,$20,$e2,$91,$a0 ; $6d0a retained data / unresolved code
    !byte $29,$b1,$12,$c9,$0d,$b0,$1a,$20,$07,$74,$f5,$df,$40,$90,$4e,$d4 ; $6d1a retained data / unresolved code
    !byte $c2,$58,$be,$01,$10,$60,$28,$ce,$e1,$69,$9a,$33,$47,$00,$4c,$0d ; $6d2a retained data / unresolved code
    !byte $6f,$8a,$20,$44,$6d,$20,$81,$fb,$38,$60 ; $6d3a retained data / unresolved code
    pha ; $6d44  48
    lsr ; $6d45  4a
    cmp $99 ; $6d46  c5 99
    bcc l_6d54 ; $6d48  90 0a
    beq l_6d4e ; $6d4a  f0 02
    bcs l_6d56 ; $6d4c  b0 08
l_6d4e:
    jsr l_922a ; $6d4e  20 2a 92
    jmp l_6d56 ; $6d51  4c 56 6d
l_6d54:
    dec $99 ; $6d54  c6 99
l_6d56:
    pla ; $6d56  68
    cmp #$0c ; $6d57  c9 0c
    bcs l_6d77 ; $6d59  b0 1c
    tax ; $6d5b  aa
l_6d5c:
    jsr party_member_pointer_x ; $6d5c  20 e4 91
    sta $45 ; $6d5f  85 45
    lda $12 ; $6d61  a5 12
    sta $44 ; $6d63  85 44
    inx ; $6d65  e8
    inx ; $6d66  e8
    jsr party_member_pointer_x ; $6d67  20 e4 91
    ldy #$77 ; $6d6a  a0 77
l_6d6c:
    lda ($12),y ; $6d6c  b1 12
    sta ($44),y ; $6d6e  91 44
    dey ; $6d70  88
    bpl l_6d6c ; $6d71  10 f9
    cpx #$0c ; $6d73  e0 0c
    bcc l_6d5c ; $6d75  90 e5
l_6d77:
    ldx #$0c ; $6d77  a2 0c
    jsr party_member_pointer_x ; $6d79  20 e4 91
    ldy #$77 ; $6d7c  a0 77
    lda #$00 ; $6d7e  a9 00
l_6d80:
    sta ($12),y ; $6d80  91 12
    dey ; $6d82  88
    bpl l_6d80 ; $6d83  10 fb
    sec ; $6d85  38
    rts ; $6d86  60
    !byte $20,$07,$74,$f5,$92,$f0,$d9,$4c,$60,$69,$23,$04,$4e,$0a,$a6,$66 ; $6d87 retained data / unresolved code
    !byte $ff,$80,$00,$20,$0f,$8b,$52,$a0,$01,$a6,$6d,$9b,$57,$6b,$ff,$38 ; $6d97 retained data / unresolved code
    !byte $e9,$b1,$85,$5c,$20,$e2,$91,$85,$37,$a5,$12,$85,$36,$a0,$2d,$b1 ; $6da7 retained data / unresolved code
    !byte $36,$29,$1c,$d0,$4d,$20,$07,$74,$f5,$92,$a2,$24,$2a,$99,$9b,$fe ; $6db7 retained data / unresolved code
    !byte $00,$a9,$00,$20,$6f,$87,$b0,$3a,$aa,$bc,$73,$e9,$84,$d0,$b1,$36 ; $6dc7 retained data / unresolved code
    !byte $8d,$1e,$02,$c8,$b1,$36,$20,$19,$6e,$b0,$29,$c9,$04,$b0,$12,$48 ; $6dd7 retained data / unresolved code
    !byte $20,$07,$74,$f5,$24,$60,$bd,$c1,$00,$68,$20,$ab,$fa,$85,$5d,$b0 ; $6de7 retained data / unresolved code
    !byte $11,$20,$73,$86,$a4,$d0,$20,$ca,$70,$20,$7f,$e9,$20,$1e,$71,$4c ; $6df7 retained data / unresolved code
    !byte $0d,$6f,$38,$60,$20,$07,$74,$f4,$1f,$63,$45,$86,$94,$b0,$00,$4c ; $6e07 retained data / unresolved code
    !byte $0d,$6f,$85,$53,$aa,$88,$b1,$36,$29,$03,$c9,$02,$f0,$36,$bd,$73 ; $6e17 retained data / unresolved code
    !byte $e8,$c9,$ff,$f0,$2f,$85,$58,$c8,$c8,$b1,$36,$88,$88,$c9,$00,$f0 ; $6e27 retained data / unresolved code
    !byte $23,$bd,$73,$e5,$29,$0f,$c9,$0c,$d0,$11,$8a,$48,$98,$48,$a6,$5c ; $6e37 retained data / unresolved code
    !byte $a9,$0b,$20,$f9,$78,$68,$a8,$68,$aa,$b0,$09,$a6,$58,$bd,$2a,$ed ; $6e47 retained data / unresolved code
    !byte $29,$07,$18,$60,$38,$60,$38,$90,$18,$90,$3b,$20,$07,$74,$f5,$92 ; $6e57 retained data / unresolved code
    !byte $f0,$d9,$4c,$60,$48,$29,$4c,$22,$0c,$a0,$66,$33,$fc,$00,$20,$0f ; $6e67 retained data / unresolved code
    !byte $8b,$52,$a0,$9b,$a4,$6e,$01,$81,$6e,$ff,$08,$38,$e9,$b1,$85,$5c ; $6e77 retained data / unresolved code
    !byte $20,$e2,$91,$85,$37,$a5,$12,$85,$36,$a0,$2d,$b1,$36,$29,$1c,$c9 ; $6e87 retained data / unresolved code
    !byte $01,$2a,$28,$6a,$b0,$07,$50,$07,$20,$14,$6f,$90,$1b,$38,$60,$20 ; $6e97 retained data / unresolved code
    !byte $07,$74,$f4,$a0,$66,$30,$33,$78,$48,$29,$4f,$fd,$f7,$a0,$20,$1a ; $6ea7 retained data / unresolved code
    !byte $73,$b0,$ea,$20,$03,$f6,$b0,$07,$a5,$58,$20,$40,$ef,$d0,$17,$20 ; $6eb7 retained data / unresolved code
    !byte $07,$74,$f5,$df,$40,$95,$ee,$d4,$c2,$b7,$3e,$c1,$9a,$45,$30,$ca ; $6ec7 retained data / unresolved code
    !byte $06,$63,$38,$00,$90,$30,$20,$5b,$ec,$a0,$25,$38,$b1,$36,$e5,$93 ; $6ed7 retained data / unresolved code
    !byte $c8,$b1,$36,$e9,$00,$b0,$16,$20,$07,$74,$f3,$9f,$30,$99,$cf,$a2 ; $6ee7 retained data / unresolved code
    !byte $12,$19,$40,$cc,$60,$60,$f5,$3a,$72,$e0,$00,$90,$09,$a6,$58,$bd ; $6ef7 retained data / unresolved code
    !byte $2a,$ed,$29,$07,$18,$60 ; $6f07 retained data / unresolved code
l_6f0d:
    jsr read_input_with_inline_flags ; $6f0d  20 0f 8b

; Inline input flags: $06, $a2
    !byte $06,$a2 ; $6f10 retained data / unresolved code
    sec ; $6f12  38
    rts ; $6f13  60
    !byte $38,$60 ; $6f14 retained data / unresolved code

; Inline callback convention: JSR followed by a little-endian routine address.
; Remove return address, advance it by two argument bytes, and put it back.
; Loop X=0,2,...,12 over seven party slots via $91e4; call the inline
; callback using the patched JSR at $6f3e. $12/$13 points to the member.
for_each_party_member_inline:
    clc ; $6f16  18
    pla ; $6f17  68
    sta $12 ; $6f18  85 12
    adc #$02 ; $6f1a  69 02
    tay ; $6f1c  a8
    pla ; $6f1d  68
    sta $13 ; $6f1e  85 13
    adc #$00 ; $6f20  69 00
    pha ; $6f22  48
    tya ; $6f23  98
    pha ; $6f24  48
    ldy #$01 ; $6f25  a0 01
    lda ($12),y ; $6f27  b1 12
    sta $6f3f ; $6f29  8d 3f 6f
    iny ; $6f2c  c8
    lda ($12),y ; $6f2d  b1 12
    sta $6f40 ; $6f2f  8d 40 6f
    ldx #$00 ; $6f32  a2 00
l_6f34:
    jsr party_member_pointer_x ; $6f34  20 e4 91
    stx $6f42 ; $6f37  8e 42 6f
    ldy #$00 ; $6f3a  a0 00
    lda ($12),y ; $6f3c  b1 12

; RAM IRQ vector high / unpatched operand placeholder
    jsr $ffff ; $6f3e  20 ff ff
    ldx #$00 ; $6f41  a2 00
    inx ; $6f43  e8
    inx ; $6f44  e8
    cpx #$0e ; $6f45  e0 0e
    bcc l_6f34 ; $6f47  90 eb
    rts ; $6f49  60
    jsr for_each_party_member_inline ; $6f4a  20 16 6f

; Inline party callback: $6f50
    !byte $50,$6f ; $6f4d retained data / unresolved code
l_6f4f:
    rts ; $6f4f  60
    bne l_6f4f ; $6f50  d0 fd
    lda $12 ; $6f52  a5 12
    sta $36 ; $6f54  85 36
    lda $13 ; $6f56  a5 13
    sta $37 ; $6f58  85 37
    pla ; $6f5a  68
    pla ; $6f5b  68
    clc ; $6f5c  18
    rts ; $6f5d  60
l_6f5e:
    ldx #$0c ; $6f5e  a2 0c
l_6f60:
    jsr party_member_pointer_x ; $6f60  20 e4 91
    ldy #$00 ; $6f63  a0 00
    lda ($12),y ; $6f65  b1 12
    beq l_6f77 ; $6f67  f0 0e
    ldy #$67 ; $6f69  a0 67
    lda ($12),y ; $6f6b  b1 12
    bne l_6f77 ; $6f6d  d0 08
    ldy #$2d ; $6f6f  a0 2d
    lda ($12),y ; $6f71  b1 12
    and #$1c ; $6f73  29 1c
    beq l_6f7f ; $6f75  f0 08
l_6f77:
    dex ; $6f77  ca
    dex ; $6f78  ca
    bpl l_6f60 ; $6f79  10 e5
    lda #$00 ; $6f7b  a9 00
    sec ; $6f7d  38
    rts ; $6f7e  60
l_6f7f:
    txa ; $6f7f  8a
    lsr ; $6f80  4a
    clc ; $6f81  18
    rts ; $6f82  60
l_6f83:
    sta $6fa4 ; $6f83  8d a4 6f
    txa ; $6f86  8a
    asl ; $6f87  0a
    tay ; $6f88  a8
    lda $d522,y ; $6f89  b9 22 d5
    sta $3c ; $6f8c  85 3c
    lda $d523,y ; $6f8e  b9 23 d5
    sta $3d ; $6f91  85 3d
    ldy #$00 ; $6f93  a0 00
    lda ($3c),y ; $6f95  b1 3c
    beq l_6fb7 ; $6f97  f0 1e
    ldy #$31 ; $6f99  a0 31
l_6f9b:
    lda ($3c),y ; $6f9b  b1 3c
    tax ; $6f9d  aa
    lda $e773,x ; $6f9e  bd 73 e7
    and #$0f ; $6fa1  29 0f
    cmp #$00 ; $6fa3  c9 00
    bne l_6fb0 ; $6fa5  d0 09
    dey ; $6fa7  88
    lda ($3c),y ; $6fa8  b1 3c
    and #$03 ; $6faa  29 03
    cmp #$01 ; $6fac  c9 01
    clc ; $6fae  18
    rts ; $6faf  60
l_6fb0:
    iny ; $6fb0  c8
    iny ; $6fb1  c8
    iny ; $6fb2  c8
    cpy #$54 ; $6fb3  c0 54
    bcc l_6f9b ; $6fb5  90 e4
l_6fb7:
    sec ; $6fb7  38
    lda #$ff ; $6fb8  a9 ff
    rts ; $6fba  60
l_6fbb:
    txa ; $6fbb  8a
    jsr party_member_pointer_a ; $6fbc  20 e2 91
    ldy #$31 ; $6fbf  a0 31
l_6fc1:
    lda ($12),y ; $6fc1  b1 12
    tax ; $6fc3  aa
    lda $e573,x ; $6fc4  bd 73 e5
    and #$0f ; $6fc7  29 0f
    cmp #$06 ; $6fc9  c9 06
    bne l_6fde ; $6fcb  d0 11
    dey ; $6fcd  88
    lda ($12),y ; $6fce  b1 12
    and #$03 ; $6fd0  29 03
    cmp #$01 ; $6fd2  c9 01
    bne l_6fdd ; $6fd4  d0 07
    lda $e773,x ; $6fd6  bd 73 e7
    and #$0f ; $6fd9  29 0f
    clc ; $6fdb  18
    rts ; $6fdc  60
l_6fdd:
    iny ; $6fdd  c8
l_6fde:
    iny ; $6fde  c8
    iny ; $6fdf  c8
    iny ; $6fe0  c8
    cpy #$54 ; $6fe1  c0 54
    bcc l_6fc1 ; $6fe3  90 dc
    rts ; $6fe5  60
    ldx $53 ; $6fe6  a6 53
    bit $55 ; $6fe8  24 55
    bpl l_6ffd ; $6fea  10 11
    lda $e573,x ; $6fec  bd 73 e5
    and #$0f ; $6fef  29 0f
    asl ; $6ff1  0a
    tax ; $6ff2  aa
    lda $7009,x ; $6ff3  bd 09 70
    ldy $700a,x ; $6ff6  bc 0a 70
    tax ; $6ff9  aa
    jmp print_packed_text_xy ; $6ffa  4c 19 74
l_6ffd:
    dex ; $6ffd  ca
    txa ; $6ffe  8a
    ldx #$74 ; $6fff  a2 74
    ldy #$da ; $7001  a0 da
    jsr l_706f ; $7003  20 6f 70
    jmp print_packed_text_xy ; $7006  4c 19 74
    !byte $27,$70,$2b,$70,$30,$70,$35,$70,$3a,$70,$3e,$70,$43,$70,$4b,$70 ; $7009 retained data / unresolved code
    !byte $52,$70,$56,$70,$5a,$70,$5e,$70,$62,$70,$68,$70,$35,$70,$f2,$a6 ; $7019 retained data / unresolved code
    !byte $66,$80,$f5,$8c,$28,$3d,$c0,$f4,$92,$a3,$30,$a0,$f0,$a2,$d7,$c4 ; $7029 retained data / unresolved code
    !byte $00,$f2,$4c,$c6,$80,$f2,$18,$fa,$9a,$40,$f2,$9d,$29,$c6,$8d,$33 ; $7039 retained data / unresolved code
    !byte $a6,$00,$f1,$d4,$8a,$45,$4e,$30,$00,$f4,$54,$e4,$00,$f5,$84,$e2 ; $7049 retained data / unresolved code
    !byte $80,$f2,$a6,$66,$80,$f0,$df,$60,$00,$f7,$c1,$a2,$aa,$68,$80,$f1 ; $7059 retained data / unresolved code
    !byte $1e,$e9,$89,$4e,$34,$40 ; $7069 retained data / unresolved code
l_706f:
    cpx $ba00 ; $706f  ec 00 ba
    bne l_7079 ; $7072  d0 05
    cpy $ba01 ; $7074  cc 01 ba
    beq l_707e ; $7077  f0 05
l_7079:
    pha ; $7079  48
    jsr l_7092 ; $707a  20 92 70
    pla ; $707d  68
l_707e:
    asl ; $707e  0a
    tax ; $707f  aa
    bcs l_708a ; $7080  b0 08
    lda $ba00,x ; $7082  bd 00 ba
    ldy $ba01,x ; $7085  bc 01 ba
    tax ; $7088  aa
    rts ; $7089  60
l_708a:
    lda $bb00,x ; $708a  bd 00 bb
    ldy $bb01,x ; $708d  bc 01 bb
    tax ; $7090  aa
    rts ; $7091  60
l_7092:
    stx $7503 ; $7092  8e 03 75
    sty $7504 ; $7095  8c 04 75
    lda #$00 ; $7098  a9 00
    sta $70bf ; $709a  8d bf 70
    lda #$ba ; $709d  a9 ba
    sta $70c0 ; $709f  8d c0 70
l_70a2:
    lda $7503 ; $70a2  ad 03 75
    jsr l_70be ; $70a5  20 be 70
    lda $7504 ; $70a8  ad 04 75
    jsr l_70be ; $70ab  20 be 70
    jsr reset_text_bit_reader ; $70ae  20 65 74
    jsr decode_text_character ; $70b1  20 6f 74
    beq l_70bd ; $70b4  f0 07
l_70b6:
    jsr decode_text_character ; $70b6  20 6f 74
    bne l_70b6 ; $70b9  d0 fb
    beq l_70a2 ; $70bb  f0 e5
l_70bd:
    rts ; $70bd  60

; RAM IRQ vector high / unpatched operand placeholder
l_70be:
    sta $ffff ; $70be  8d ff ff
    inc $70bf ; $70c1  ee bf 70
    bne l_70c9 ; $70c4  d0 03
    inc $70c0 ; $70c6  ee c0 70
l_70c9:
    rts ; $70c9  60
    iny ; $70ca  c8
    iny ; $70cb  c8
    lda ($36),y ; $70cc  b1 36
    cmp #$ff ; $70ce  c9 ff
    beq l_70db ; $70d0  f0 09
    sec ; $70d2  38
    sbc #$01 ; $70d3  e9 01
    sta ($36),y ; $70d5  91 36
    bcc l_70de ; $70d7  90 05
    beq l_70de ; $70d9  f0 03
l_70db:
    dey ; $70db  88
    dey ; $70dc  88
l_70dd:
    rts ; $70dd  60
l_70de:
    lda #$00 ; $70de  a9 00
    sta ($36),y ; $70e0  91 36
    dey ; $70e2  88
    tya ; $70e3  98
    pha ; $70e4  48
    lda ($36),y ; $70e5  b1 36
    tay ; $70e7  a8
    lda $e273,y ; $70e8  b9 73 e2
    tay ; $70eb  a8
    pla ; $70ec  68
    cpy #$01 ; $70ed  c0 01
    php ; $70ef  08
    tay ; $70f0  a8
    dey ; $70f1  88
    plp ; $70f2  28
    bne l_70dd ; $70f3  d0 e8
l_70f5:
    tya ; $70f5  98
    pha ; $70f6  48
    txa ; $70f7  8a
    pha ; $70f8  48
l_70f9:
    cpy #$51 ; $70f9  c0 51
    bcs l_710f ; $70fb  b0 12
    ldx #$03 ; $70fd  a2 03
l_70ff:
    iny ; $70ff  c8
    iny ; $7100  c8
    iny ; $7101  c8
    lda ($36),y ; $7102  b1 36
    dey ; $7104  88
    dey ; $7105  88
    dey ; $7106  88
    sta ($36),y ; $7107  91 36
    iny ; $7109  c8
    dex ; $710a  ca
    bne l_70ff ; $710b  d0 f2
    beq l_70f9 ; $710d  f0 ea
l_710f:
    ldx #$03 ; $710f  a2 03
    lda #$00 ; $7111  a9 00
l_7113:
    sta ($36),y ; $7113  91 36
    iny ; $7115  c8
    dex ; $7116  ca
    bne l_7113 ; $7117  d0 fa
    pla ; $7119  68
    tax ; $711a  aa
    pla ; $711b  68
    tay ; $711c  a8
    rts ; $711d  60
    lda $36 ; $711e  a5 36
    pha ; $7120  48
    lda $37 ; $7121  a5 37
    pha ; $7123  48
    jsr for_each_party_member_inline ; $7124  20 16 6f

; Inline party callback: $7130
    !byte $30,$71 ; $7127 retained data / unresolved code
    pla ; $7129  68
    sta $37 ; $712a  85 37
    pla ; $712c  68
    sta $36 ; $712d  85 36
    rts ; $712f  60
    lda $12 ; $7130  a5 12
    sta $36 ; $7132  85 36
    lda $13 ; $7134  a5 13
    sta $37 ; $7136  85 37
l_7138:
    ldy #$31 ; $7138  a0 31
l_713a:
    lda ($36),y ; $713a  b1 36
    cmp #$76 ; $713c  c9 76
    beq l_7144 ; $713e  f0 04
    cmp #$7d ; $7140  c9 7d
    bne l_7153 ; $7142  d0 0f
l_7144:
    iny ; $7144  c8
    lda ($36),y ; $7145  b1 36
    dey ; $7147  88
    cmp #$00 ; $7148  c9 00
    bne l_7153 ; $714a  d0 07
    dey ; $714c  88
    jsr l_70f5 ; $714d  20 f5 70
    jmp l_7138 ; $7150  4c 38 71
l_7153:
    iny ; $7153  c8
    iny ; $7154  c8
    iny ; $7155  c8
    cpy #$54 ; $7156  c0 54
    bcc l_713a ; $7158  90 e0
    rts ; $715a  60
    asl ; $715b  0a
    tax ; $715c  aa
    lda $d522,x ; $715d  bd 22 d5
    sta $42 ; $7160  85 42
    lda $d523,x ; $7162  bd 23 d5
    sta $43 ; $7165  85 43
    ldy #$00 ; $7167  a0 00
    lda ($42),y ; $7169  b1 42
    beq l_717c ; $716b  f0 0f
    ldy #$31 ; $716d  a0 31
l_716f:
    lda ($42),y ; $716f  b1 42
    beq l_717e ; $7171  f0 0b
    iny ; $7173  c8
    iny ; $7174  c8
    iny ; $7175  c8
    cpy #$54 ; $7176  c0 54
    bcc l_716f ; $7178  90 f5
    lda #$01 ; $717a  a9 01
l_717c:
    sec ; $717c  38
    rts ; $717d  60
l_717e:
    dey ; $717e  88
    sty $7197 ; $717f  8c 97 71
    ldy #$29 ; $7182  a0 29
    lda ($42),y ; $7184  b1 42
    tay ; $7186  a8
    ldx $53 ; $7187  a6 53
    lda $e673,x ; $7189  bd 73 e6
    and $d987,y ; $718c  39 87 d9
    bne $7194 ; $718f  d0 03
    lda #$02 ; $7191  a9 02
    !byte $2c,$a9,$00 ; $7193 retained data / unresolved code
    ldy #$00 ; $7196  a0 00
    ora $55 ; $7198  05 55
    sta ($42),y ; $719a  91 42
    iny ; $719c  c8
    lda $53 ; $719d  a5 53
    sta ($42),y ; $719f  91 42
    iny ; $71a1  c8
    lda $56 ; $71a2  a5 56
    sta ($42),y ; $71a4  91 42
    clc ; $71a6  18
    rts ; $71a7  60
    !byte $98,$48,$20,$c6,$71,$68,$a8,$98,$48,$38,$a2,$00,$b1,$36,$f5,$ab ; $71a8 retained data / unresolved code
    !byte $c8,$e8,$8a,$49,$04,$d0,$f5,$68,$a8,$6a,$49,$80,$0a,$60,$a9,$00 ; $71b8 retained data / unresolved code
    !byte $85,$ab,$85,$ac,$85,$ad,$85,$ae,$8a,$29,$07,$a8,$8a,$4a,$4a,$4a ; $71c8 retained data / unresolved code
    !byte $aa,$f0,$2c,$18,$b9,$ef,$72,$65,$ab,$85,$ab,$b9,$f9,$72,$65,$ac ; $71d8 retained data / unresolved code
    !byte $85,$ac,$b9,$03,$73,$65,$ad,$85,$ad,$b9,$0d,$73,$65,$ae,$85,$ae ; $71e8 retained data / unresolved code
    !byte $90,$0a,$a9,$ff,$85,$ab,$85,$ac,$85,$ad,$85,$ae,$ca,$d0,$d4,$60 ; $71f8 retained data / unresolved code
    !byte $a2,$00,$38,$b1,$36,$f5,$ab,$91,$36,$c8,$e8,$8a,$49,$04,$d0,$f3 ; $7208 retained data / unresolved code
    !byte $60,$a2,$00,$38,$b5,$ab,$f1,$36,$95,$ab,$c8,$e8,$8a,$49,$04,$d0 ; $7218 retained data / unresolved code
    !byte $f3,$60,$a0,$1c,$a2,$03,$b1,$36,$95,$ab,$88,$ca,$10,$f8,$60,$a0 ; $7228 retained data / unresolved code
    !byte $18,$a2,$03,$b5,$ab,$91,$38,$88,$ca,$10,$f8,$60,$a2,$00,$b1,$36 ; $7238 retained data / unresolved code
    !byte $95,$9b,$c8,$e8,$e0,$04,$90,$f6,$6e,$ee,$72,$4c,$8e,$72,$a2,$03 ; $7248 retained data / unresolved code
    !byte $b5,$ab,$95,$9b,$ca,$10,$f9,$4c,$8e,$72 ; $7258 retained data / unresolved code
    sec ; $7262  38
    ror $72ee ; $7263  6e ee 72
    lda $9b ; $7266  a5 9b
    cmp #$0f ; $7268  c9 0f
    lda $9c ; $726a  a5 9c
    sbc #$27 ; $726c  e9 27
    bcc l_7278 ; $726e  90 08
    lda #$0f ; $7270  a9 0f
    sta $9b ; $7272  85 9b
    lda #$27 ; $7274  a9 27
    sta $9c ; $7276  85 9c
l_7278:
    lda #$c5 ; $7278  a9 c5
    sta $72db ; $727a  8d db 72
    lda #$85 ; $727d  a9 85
    sta $72dc ; $727f  8d dc 72
    ldx #$03 ; $7282  a2 03
    !byte $2c,$a2,$04 ; $7284 retained data / unresolved code
    lda #$00 ; $7287  a9 00
    sta $9d ; $7289  85 9d
    sta $9e ; $728b  85 9e
    !byte $2c,$a2,$09 ; $728d retained data / unresolved code
    stx $b1 ; $7290  86 b1
l_7292:
    ldy #$b0 ; $7292  a0 b0
l_7294:
    lda $9b ; $7294  a5 9b
    cmp $72ef,x ; $7296  dd ef 72
    lda $9c ; $7299  a5 9c
    sbc $72f9,x ; $729b  fd f9 72
    lda $9d ; $729e  a5 9d
    sbc $7303,x ; $72a0  fd 03 73
    lda $9e ; $72a3  a5 9e
    sbc $730d,x ; $72a5  fd 0d 73
    bcc l_72c4 ; $72a8  90 1a
    sta $9e ; $72aa  85 9e
    lda $9b ; $72ac  a5 9b
    sbc $72ef,x ; $72ae  fd ef 72
    sta $9b ; $72b1  85 9b
    lda $9c ; $72b3  a5 9c
    sbc $72f9,x ; $72b5  fd f9 72
    sta $9c ; $72b8  85 9c
    lda $9d ; $72ba  a5 9d
    sbc $7303,x ; $72bc  fd 03 73
    sta $9d ; $72bf  85 9d
    iny ; $72c1  c8
    bne l_7294 ; $72c2  d0 d0
l_72c4:
    cpx #$00 ; $72c4  e0 00
    beq l_72d9 ; $72c6  f0 11
    cpy #$b0 ; $72c8  c0 b0
    beq l_72ce ; $72ca  f0 02
    sty $b1 ; $72cc  84 b1
l_72ce:
    bit $b1 ; $72ce  24 b1
    bmi l_72d9 ; $72d0  30 07
    bit $72ee ; $72d2  2c ee 72
    bpl l_72dd ; $72d5  10 06
    ldy #$a0 ; $72d7  a0 a0
l_72d9:
    tya ; $72d9  98
    jsr output_text_character ; $72da  20 8e 84
l_72dd:
    dex ; $72dd  ca
    bpl l_7292 ; $72de  10 b2
    lda #$8e ; $72e0  a9 8e
    sta $72db ; $72e2  8d db 72
    lda #$84 ; $72e5  a9 84
    sta $72dc ; $72e7  8d dc 72
    lsr $72ee ; $72ea  4e ee 72
    rts ; $72ed  60
    !byte $00,$01,$0a,$64,$e8,$10,$a0,$40,$80,$00,$00,$00,$00,$00,$03,$27 ; $72ee retained data / unresolved code
    !byte $86,$42,$96,$e1,$ca,$00,$00,$00,$00,$00,$01,$0f,$98,$f5,$9a,$00 ; $72fe retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$05,$3b,$a9,$10,$2c,$a9,$00,$8d,$37 ; $730e retained data / unresolved code
    !byte $73,$20,$20,$85,$a2,$0f,$a9,$ff,$9d,$00,$02,$ca,$10,$fa,$20,$84 ; $731e retained data / unresolved code
    !byte $73,$a2,$00,$8a,$48,$20,$0f,$8b,$80,$10,$a8,$68,$aa,$98,$c9,$af ; $732e retained data / unresolved code
    !byte $f0,$f1,$c9,$dc,$f0,$ed,$c9,$ff,$f0,$25,$c9,$88,$f0,$21,$c9,$8d ; $733e retained data / unresolved code
    !byte $f0,$0f,$c9,$a0,$90,$dd,$9d,$00,$02,$20,$84,$73,$e8,$e0,$0f,$90 ; $734e retained data / unresolved code
    !byte $d2,$20,$82,$73,$38,$8a,$f0,$01,$18,$08,$20,$8c,$84,$28,$60,$e0 ; $735e retained data / unresolved code
    !byte $00,$f0,$c0,$ca,$a9,$ff,$9d,$00,$02,$20,$84,$73,$a9,$a0,$20,$c5 ; $736e retained data / unresolved code
    !byte $85,$4c,$31,$73,$38,$24,$18,$08,$8a,$48,$a9,$22,$85,$20,$a9,$bc ; $737e retained data / unresolved code
    !byte $20,$c5,$85,$a9,$12,$85,$20,$a9,$ba,$20,$c5,$85,$a2,$00,$bd,$00 ; $738e retained data / unresolved code
    !byte $02,$c9,$ff,$f0,$08,$20,$c5,$85,$e8,$e0,$10,$90,$f1,$68,$aa,$28 ; $739e retained data / unresolved code
    !byte $a9,$a0,$b0,$02,$a9,$fe,$4c,$c5,$85,$a0,$00,$84,$a1,$84,$a2,$84 ; $73ae retained data / unresolved code
    !byte $a3,$84,$a4,$84,$a0,$a9,$0a,$85,$9f,$b9,$00,$02,$c8,$49,$b0,$c9 ; $73be retained data / unresolved code
    !byte $0a,$b0,$2c,$48,$98,$48,$20,$5d,$91,$68,$a8,$68,$18,$65,$9b,$85 ; $73ce retained data / unresolved code
    !byte $a1,$a5,$9c,$69,$00,$85,$a2,$a5,$9d,$69,$00,$85,$a3,$a5,$9e,$69 ; $73de retained data / unresolved code
    !byte $00,$85,$a4,$90,$d4,$a2,$03,$a9,$ff,$95,$ab,$ca,$10,$fb,$60,$a2 ; $73ee retained data / unresolved code
    !byte $03,$b5,$a1,$95,$ab,$ca,$10,$f9,$60 ; $73fe retained data / unresolved code

; Inline packed-string convention: text bits immediately follow the JSR.
; Pull the caller return address, start decoding at the next byte,
; then JMP through the advanced text cursor at $7503 after the terminator.
; The packed bytes after callers of this routine are DATA, not instructions.
print_inline_packed_text:
    jsr l_8673 ; $7407  20 73 86

; Alternate packed-text entry: skip the $8673 display reset and
; continue with the same inline string / continuation convention as $7407.
print_inline_text_without_reset:
    pla ; $740a  68
    tax ; $740b  aa
    pla ; $740c  68
    tay ; $740d  a8
    inx ; $740e  e8
    bne l_7412 ; $740f  d0 01
    iny ; $7411  c8
l_7412:
    jsr print_packed_text_xy ; $7412  20 19 74
    clc ; $7415  18
    jmp ($7503) ; $7416  6c 03 75

; Input X/Y = compressed text address (low/high). Decode symbols
; and send characters to $848e. $af/$dc delimit conditional text sections
; selected by $4f. Return X/Y points past consumed compressed bytes.
print_packed_text_xy:
    stx $7503 ; $7419  8e 03 75
    sty $7504 ; $741c  8c 04 75
    jsr reset_text_bit_reader ; $741f  20 65 74
l_7422:
    jsr decode_text_character ; $7422  20 6f 74
    beq l_745d ; $7425  f0 36
    cmp #$af ; $7427  c9 af
    beq l_7431 ; $7429  f0 06
    jsr output_text_character ; $742b  20 8e 84
    jmp l_7422 ; $742e  4c 22 74
l_7431:
    lda #$80 ; $7431  a9 80
    ldx $4f ; $7433  a6 4f
    beq l_7439 ; $7435  f0 02
    lda #$00 ; $7437  a9 00
l_7439:
    sta $7464 ; $7439  8d 64 74
l_743c:
    jsr decode_text_character ; $743c  20 6f 74
    beq l_745d ; $743f  f0 1c
    cmp #$dc ; $7441  c9 dc
    beq l_7450 ; $7443  f0 0b
    bit $7464 ; $7445  2c 64 74
    bpl l_743c ; $7448  10 f2
    jsr output_text_character ; $744a  20 8e 84
    jmp l_743c ; $744d  4c 3c 74
l_7450:
    lda $7464 ; $7450  ad 64 74
    eor #$81 ; $7453  49 81
    sta $7464 ; $7455  8d 64 74
    lsr ; $7458  4a
    bcs l_743c ; $7459  b0 e1
    bcc l_7422 ; $745b  90 c5
l_745d:
    ldx $7503 ; $745d  ae 03 75
    ldy $7504 ; $7460  ac 04 75
    rts ; $7463  60
    !byte $00 ; $7464 retained data / unresolved code

; Mark packed input byte empty ($b7=$ff), clear one-character case state $b9.
reset_text_bit_reader:
    ldx #$ff ; $7465  a2 ff
    stx $b7 ; $7467  86 b7
    inx ; $7469  e8
    stx $b9 ; $746a  86 b9
    rts ; $746c  60
l_746d:
    ror $b9 ; $746d  66 b9

; Read a 5-bit symbol, MSB first. 0 ends the string; 30 shifts case;
; 31 reads six more bits and adds 30. Translate using the table at $749a.
; The pending case bit uppercases the next lowercase character.
decode_text_character:
    jsr $74fa ; $746f  20 fa 74
    ora #$00 ; $7472  09 00
    beq l_7498 ; $7474  f0 22
    cmp #$1e ; $7476  c9 1e
    beq l_746d ; $7478  f0 f3
    cmp #$1f ; $747a  c9 1f
    bne l_7484 ; $747c  d0 06
    jsr read_six_text_bits ; $747e  20 f7 74
    sec ; $7481  38
    adc #$1d ; $7482  69 1d
l_7484:
    tax ; $7484  aa
    lda l_749a,x ; $7485  bd 9a 74
    lsr $b9 ; $7488  46 b9
    bit $b9 ; $748a  24 b9
    bvc l_7498 ; $748c  50 0a
    cmp #$e1 ; $748e  c9 e1
    bcc l_7498 ; $7490  90 06
    cmp #$fb ; $7492  c9 fb
    bcs l_7498 ; $7494  b0 02
    and #$df ; $7496  29 df
l_7498:
    ora #$00 ; $7498  09 00
l_749a:
    rts ; $749a  60

; Character translation table for packed text (base is $749a).
; Five-bit symbols cover common characters; symbol 31 escapes to six bits.
    !byte $a0,$e1,$e2,$e3,$e4,$e5,$e6,$e7,$e8,$e9,$eb,$ec,$ed,$ee,$ef,$f0 ; $749b retained data / unresolved code
    !byte $f2,$f3,$f4,$f5,$f6,$f7,$f9,$ae,$a2,$a7,$ac,$a1,$8d,$ea,$f1,$f8 ; $74ab retained data / unresolved code
    !byte $fa,$b0,$b1,$b2,$b3,$b4,$b5,$b6,$b7,$b8,$b9,$30,$31,$32,$33,$34 ; $74bb retained data / unresolved code
    !byte $35,$36,$37,$38,$39,$41,$42,$43,$44,$45,$46,$47,$48,$49,$4a,$4b ; $74cb retained data / unresolved code
    !byte $4c,$4d,$4e,$4f,$50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$5a,$a8 ; $74db retained data / unresolved code
    !byte $a9,$af,$dc,$a3,$aa,$bf,$bc,$be,$ba,$bb,$ad,$a5 ; $74eb retained data / unresolved code

; Overlapping entry points: read_six_text_bits uses LDY #6 and
; BIT $05a0 to skip LDY #5 at $74fa. Shared bit-reader starts at $74fc.
; The five overlapping bytes are deliberately emitted with !byte.
read_six_text_bits:
    ldy #$06 ; $74f7  a0 06
    !byte $2c,$a0,$05 ; $74f9 retained data / unresolved code
    lda #$00 ; $74fc  a9 00
l_74fe:
    bit $b7 ; $74fe  24 b7
    bpl l_7513 ; $7500  10 11

; RAM IRQ vector high / unpatched operand placeholder
    ldx $ffff ; $7502  ae ff ff
    inc $7503 ; $7505  ee 03 75
    bne l_750d ; $7508  d0 03
    inc $7504 ; $750a  ee 04 75
l_750d:
    stx $b8 ; $750d  86 b8
    ldx #$07 ; $750f  a2 07
    stx $b7 ; $7511  86 b7
l_7513:
    asl $b8 ; $7513  06 b8
    rol ; $7515  2a
    dec $b7 ; $7516  c6 b7
    dey ; $7518  88
    bne l_74fe ; $7519  d0 e3
    rts ; $751b  60

; Unpacked character-string printer. Input X/Y is source pointer;
; $ff terminates. Handles the same conditional $af/$dc delimiters.
print_unpacked_text_xy:
    stx $38 ; $751c  86 38
    sty $39 ; $751e  84 39
    ldy #$00 ; $7520  a0 00
    sty $753f ; $7522  8c 3f 75
l_7525:
    lda ($38),y ; $7525  b1 38
    cmp #$ff ; $7527  c9 ff
    beq l_753e ; $7529  f0 13
    cmp #$af ; $752b  c9 af
    beq l_7540 ; $752d  f0 11
    cmp #$dc ; $752f  c9 dc
    beq $7543 ; $7531  f0 10
    bit $753f ; $7533  2c 3f 75
    bmi l_753b ; $7536  30 03
    jsr output_text_character ; $7538  20 8e 84
l_753b:
    iny ; $753b  c8
    bne l_7525 ; $753c  d0 e7
l_753e:
    rts ; $753e  60
    !byte $00 ; $753f retained data / unresolved code
l_7540:
    lda #$00 ; $7540  a9 00
    !byte $2c,$a9,$80 ; $7542 retained data / unresolved code
    ldx $4f ; $7545  a6 4f
    beq l_754b ; $7547  f0 02
    eor #$80 ; $7549  49 80
l_754b:
    sta $753f ; $754b  8d 3f 75
    jmp l_753b ; $754e  4c 3b 75
    lda $22 ; $7551  a5 22
    pha ; $7553  48
    lda $20 ; $7554  a5 20
    pha ; $7556  48
    lda #$00 ; $7557  a9 00
    sta $24 ; $7559  85 24
    lda #$64 ; $755b  a9 64
    sta $22 ; $755d  85 22
    lda #$02 ; $755f  a9 02
    sta $20 ; $7561  85 20
    ldy #$00 ; $7563  a0 00
    ldx #$00 ; $7565  a2 00
l_7567:
    lda ($38),y ; $7567  b1 38
    cmp #$ff ; $7569  c9 ff
    beq l_757e ; $756b  f0 11
    cmp #$dc ; $756d  c9 dc
    beq l_757e ; $756f  f0 0d
    cmp #$af ; $7571  c9 af
    beq l_75bc ; $7573  f0 47
    sta $0211,x ; $7575  9d 11 02
    inx ; $7578  e8
l_7579:
    iny ; $7579  c8
    cpx #$0d ; $757a  e0 0d
    bcc l_7567 ; $757c  90 e9
l_757e:
    stx $b1 ; $757e  86 b1
    lda #$0d ; $7580  a9 0d
    sta $b0 ; $7582  85 b0
    sec ; $7584  38
    sbc $b1 ; $7585  e5 b1
    lsr ; $7587  4a
    tax ; $7588  aa
l_7589:
    cpx #$00 ; $7589  e0 00
    beq l_7598 ; $758b  f0 0b
    dex ; $758d  ca
    dec $b0 ; $758e  c6 b0
    lda #$a0 ; $7590  a9 a0
    jsr l_85c5 ; $7592  20 c5 85
    jmp l_7589 ; $7595  4c 89 75
l_7598:
    ldx #$00 ; $7598  a2 00
l_759a:
    lda $0211,x ; $759a  bd 11 02
    jsr l_85c5 ; $759d  20 c5 85
    inx ; $75a0  e8
    cpx $b1 ; $75a1  e4 b1
    bcc l_759a ; $75a3  90 f5
l_75a5:
    cpx $b0 ; $75a5  e4 b0
    beq l_75b1 ; $75a7  f0 08
    lda #$a0 ; $75a9  a9 a0
    jsr l_85c5 ; $75ab  20 c5 85
    inx ; $75ae  e8
    bne l_75a5 ; $75af  d0 f4
l_75b1:
    pla ; $75b1  68
    sta $20 ; $75b2  85 20
    pla ; $75b4  68
    sta $22 ; $75b5  85 22
    lda #$ff ; $75b7  a9 ff
    sta $24 ; $75b9  85 24
    rts ; $75bb  60
l_75bc:
    lda $4f ; $75bc  a5 4f
    beq l_7579 ; $75be  f0 b9
    iny ; $75c0  c8
l_75c1:
    lda ($38),y ; $75c1  b1 38
    cmp #$dc ; $75c3  c9 dc
    beq l_7579 ; $75c5  f0 b2
    iny ; $75c7  c8
    bne l_75c1 ; $75c8  d0 f7
    ldy #$10 ; $75ca  a0 10
    ldx #$00 ; $75cc  a2 00
    stx $0347 ; $75ce  8e 47 03
l_75d1:
    lda ($36),y ; $75d1  b1 36
    sta $0342,x ; $75d3  9d 42 03
    iny ; $75d6  c8
    inx ; $75d7  e8
    cpx #$05 ; $75d8  e0 05
    bcc l_75d1 ; $75da  90 f5
    rts ; $75dc  60
    !byte $20,$16,$6f,$e3,$75,$60,$f0,$fd,$a5,$36,$c5,$12,$d0,$06,$a5,$37 ; $75dd retained data / unresolved code
    !byte $c5,$13,$f0,$f1,$a0,$19,$18,$b1,$12,$71,$36,$91,$36,$a9,$00,$91 ; $75ed retained data / unresolved code
    !byte $12,$c8,$98,$49,$1d,$d0,$f0,$90,$dc,$a0,$19,$a9,$ff,$91,$36,$c8 ; $75fd retained data / unresolved code
    !byte $c0,$1d,$90,$f9,$60,$a0,$29,$b1,$36,$0a,$a8,$b9,$95,$76,$85,$12 ; $760d retained data / unresolved code
    !byte $b9,$96,$76,$85,$13,$a9,$00,$85,$ab,$85,$ac,$85,$ad,$85,$ae,$a5 ; $761d retained data / unresolved code
    !byte $4b,$c9,$0d,$a5,$4c,$e9,$00,$90,$29,$a5,$4b,$38,$e9,$0c,$85,$9f ; $762d retained data / unresolved code
    !byte $a5,$4c,$e9,$00,$85,$a0,$a9,$80,$85,$a1,$a9,$1a,$85,$a2,$a9,$06 ; $763d retained data / unresolved code
    !byte $85,$a3,$a9,$00,$85,$a4,$20,$5d,$91,$a2,$03,$b5,$9b,$95,$ab,$ca ; $764d retained data / unresolved code
    !byte $10,$f9,$a5,$4c,$d0,$07,$a6,$4b,$ca,$e0,$0c,$90,$02,$a2,$0b,$bc ; $765d retained data / unresolved code
    !byte $88,$76,$a2,$00,$18,$b1,$12,$75,$ab,$95,$ab,$c8,$e8,$8a,$49,$03 ; $766d retained data / unresolved code
    !byte $d0,$f3,$90,$02,$e6,$ae,$a0,$15,$4c,$af,$71,$00,$03,$06,$09,$0c ; $767d retained data / unresolved code
    !byte $0f,$12,$15,$18,$1b,$1e,$21,$24,$af,$76,$d3,$76,$f7,$76,$1b,$77 ; $768d retained data / unresolved code
    !byte $1b,$77,$af,$76,$af,$76,$af,$76,$af,$76,$1b,$77,$3f,$77,$3f,$77 ; $769d retained data / unresolved code
    !byte $63,$77,$d0,$07,$00,$a0,$0f,$00,$58,$1b,$00,$10,$27,$00,$98,$3a ; $76ad retained data / unresolved code
    !byte $00,$20,$4e,$00,$30,$75,$00,$50,$c3,$00,$80,$38,$01,$b0,$ad,$01 ; $76bd retained data / unresolved code
    !byte $f0,$49,$02,$40,$0d,$03,$20,$4e,$00,$50,$c3,$00,$80,$38,$01,$c0 ; $76cd retained data / unresolved code
    !byte $d4,$01,$00,$71,$02,$40,$0d,$03,$90,$d0,$03,$e0,$93,$04,$80,$1a ; $76dd retained data / unresolved code
    !byte $06,$c0,$27,$09,$a0,$bb,$0d,$20,$d6,$13,$58,$1b,$00,$98,$3a,$00 ; $76ed retained data / unresolved code
    !byte $a8,$61,$00,$40,$9c,$00,$60,$ea,$00,$80,$38,$01,$a0,$86,$01,$d0 ; $76fd retained data / unresolved code
    !byte $fb,$01,$10,$98,$02,$60,$5b,$03,$e0,$93,$04,$80,$1a,$06,$08,$07 ; $770d retained data / unresolved code
    !byte $00,$a0,$0f,$00,$70,$17,$00,$10,$27,$00,$b0,$36,$00,$38,$4a,$00 ; $771d retained data / unresolved code
    !byte $48,$71,$00,$50,$c3,$00,$90,$5f,$01,$c0,$d4,$01,$10,$98,$02,$70 ; $772d retained data / unresolved code
    !byte $82,$03,$70,$11,$01,$e0,$22,$02,$80,$a9,$03,$20,$30,$05,$60,$3d ; $773d retained data / unresolved code
    !byte $08,$a0,$4a,$0b,$40,$42,$0f,$c0,$5c,$15,$40,$77,$1b,$c0,$91,$21 ; $774d retained data / unresolved code
    !byte $40,$ac,$27,$c0,$c6,$2d,$a0,$86,$01,$e8,$6e,$03,$80,$1a,$06,$10 ; $775d retained data / unresolved code
    !byte $eb,$09,$f0,$7e,$0e,$c0,$5c,$15,$40,$77,$1b,$c0,$91,$21,$40,$ac ; $776d retained data / unresolved code
    !byte $27,$c0,$c6,$2d,$40,$e1,$33,$c0,$fb,$39,$38,$24,$18,$6e,$d0,$77 ; $777d retained data / unresolved code
    !byte $a9,$00,$48,$aa,$0a,$a8,$bd,$f5,$77,$85,$20,$8d,$63,$85,$b9,$e9 ; $778d retained data / unresolved code
    !byte $77,$20,$8e,$84,$b9,$ea,$77,$20,$8e,$84,$a9,$ba,$20,$8e,$84,$bd ; $779d retained data / unresolved code
    !byte $42,$03,$c9,$0a,$b0,$03,$20,$89,$84,$bd,$42,$03,$c9,$64,$90,$02 ; $77ad retained data / unresolved code
    !byte $a9,$63,$85,$9b,$a9,$00,$85,$9c,$20,$85,$72,$20,$20,$85,$68,$18 ; $77bd retained data / unresolved code
    !byte $69,$01,$a2,$00,$10,$04,$c9,$05,$f0,$0f,$c9,$06,$f0,$0b,$c9,$03 ; $77cd retained data / unresolved code
    !byte $d0,$b0,$20,$8c,$84,$a9,$03,$d0,$a9,$4c,$8c,$84,$d3,$f4,$c9,$d1 ; $77dd retained data / unresolved code
    !byte $c4,$f8,$c3,$ee,$cc,$eb,$c8,$d0,$12,$19,$20,$12,$19,$20 ; $77ed retained data / unresolved code
l_77fb:
    bit $034e ; $77fb  2c 4e 03
    bvs l_7806 ; $77fe  70 06
    lda $ba ; $7800  a5 ba
    cmp #$03 ; $7802  c9 03
    bcs l_780b ; $7804  b0 05
l_7806:
    lda $fe07 ; $7806  ad 07 fe
    bne l_7829 ; $7809  d0 1e
l_780b:
    lda #$09 ; $780b  a9 09
    sta $fe07 ; $780d  8d 07 fe
    lda $68 ; $7810  a5 68
    beq l_7817 ; $7812  f0 03
    jsr l_782c ; $7814  20 2c 78
l_7817:
    lda $64 ; $7817  a5 64
    beq l_781e ; $7819  f0 03
    jsr l_784d ; $781b  20 4d 78
l_781e:
    lda $66 ; $781e  a5 66
    beq l_7829 ; $7820  f0 07
    dec $6b ; $7822  c6 6b
    bne l_7829 ; $7824  d0 03
    jsr l_7871 ; $7826  20 71 78
l_7829:
    jmp l_92be ; $7829  4c be 92
l_782c:
    inc $63 ; $782c  e6 63
    lda $63 ; $782e  a5 63
    and #$03 ; $7830  29 03
    sta $63 ; $7832  85 63
    clc ; $7834  18
    !byte $24,$38 ; $7835 retained data / unresolved code
    php ; $7837  08
    lda $63 ; $7838  a5 63
    asl ; $783a  0a
    tax ; $783b  aa
    lda $d56e,x ; $783c  bd 6e d5
    sta $3c ; $783f  85 3c
    lda $d56f,x ; $7841  bd 6f d5
    sta $3d ; $7844  85 3d
    ldx #$1e ; $7846  a2 1e
    ldy #$60 ; $7848  a0 60
    jmp l_78f0 ; $784a  4c f0 78
l_784d:
    ldx $6c ; $784d  a6 6c
    inx ; $784f  e8
    cpx #$05 ; $7850  e0 05
    bcc l_7856 ; $7852  90 02
    ldx #$00 ; $7854  a2 00
l_7856:
    stx $6c ; $7856  86 6c
    clc ; $7858  18
    !byte $24,$38 ; $7859 retained data / unresolved code
    php ; $785b  08
    lda $6c ; $785c  a5 6c
    asl ; $785e  0a
    tax ; $785f  aa
    lda $d5fe,x ; $7860  bd fe d5
    sta $3c ; $7863  85 3c
    lda $d5ff,x ; $7865  bd ff d5
    sta $3d ; $7868  85 3d
    ldx #$20 ; $786a  a2 20
    ldy #$62 ; $786c  a0 62
    jmp l_78f0 ; $786e  4c f0 78
l_7871:
    ldx $6a ; $7871  a6 6a
    inx ; $7873  e8
    cpx #$06 ; $7874  e0 06
    bcc l_787a ; $7876  90 02
    ldx #$00 ; $7878  a2 00
l_787a:
    stx $6a ; $787a  86 6a
    lda $789a,x ; $787c  bd 9a 78
    sta $6b ; $787f  85 6b
    clc ; $7881  18
    !byte $24,$38 ; $7882 retained data / unresolved code
    php ; $7884  08
    lda $6a ; $7885  a5 6a
    asl ; $7887  0a
    tax ; $7888  aa
    lda $d7e0,x ; $7889  bd e0 d7
    sta $3c ; $788c  85 3c
    lda $d7e1,x ; $788e  bd e1 d7
    sta $3d ; $7891  85 3d
    ldx #$17 ; $7893  a2 17
    ldy #$65 ; $7895  a0 65
    jmp l_78f0 ; $7897  4c f0 78
    !byte $10,$10,$10,$01,$01,$01 ; $789a retained data / unresolved code
l_78a0:
    lda #$00 ; $78a0  a9 00
    sta $75 ; $78a2  85 75
    jsr $fb81 ; $78a4  20 81 fb
    sec ; $78a7  38
    bit $18 ; $78a8  24 18
    php ; $78aa  08
    lda #$a4 ; $78ab  a9 a4
    sta $3c ; $78ad  85 3c
    lda #$d8 ; $78af  a9 d8
    sta $3d ; $78b1  85 3d
    ldx #$1b ; $78b3  a2 1b
    ldy #$62 ; $78b5  a0 62
    jmp l_78f0 ; $78b7  4c f0 78
l_78ba:
    sec ; $78ba  38
    bit $18 ; $78bb  24 18
    php ; $78bd  08
    lda #$d6 ; $78be  a9 d6
    sta $3c ; $78c0  85 3c
    lda #$d8 ; $78c2  a9 d8
    sta $3d ; $78c4  85 3d
    ldx #$24 ; $78c6  a2 24
    ldy #$63 ; $78c8  a0 63
    jmp l_78f0 ; $78ca  4c f0 78
    !byte $18,$a5,$65,$d0,$0b,$a5,$96,$f0,$06,$a5,$9a,$49,$07,$f0,$01 ; $78cd retained data / unresolved code
l_78dc:
    sec ; $78dc  38
    php ; $78dd  08
    lda $0b ; $78de  a5 0b
    asl ; $78e0  0a
    tax ; $78e1  aa
    lda $d6f0,x ; $78e2  bd f0 d6
    sta $3c ; $78e5  85 3c
    lda $d6f1,x ; $78e7  bd f1 d6
    sta $3d ; $78ea  85 3d
    ldx #$13 ; $78ec  a2 13
    ldy #$63 ; $78ee  a0 63
l_78f0:
    plp ; $78f0  28
    bcs l_78f6 ; $78f1  b0 03
    jmp $8566 ; $78f3  4c 66 85
l_78f6:
    jmp l_8564 ; $78f6  4c 64 85
    sta $b2 ; $78f9  85 b2
    ldy #$31 ; $78fb  a0 31
l_78fd:
    lda ($36),y ; $78fd  b1 36
    tax ; $78ff  aa
    lda $e573,x ; $7900  bd 73 e5
    and #$0f ; $7903  29 0f
    cmp $b2 ; $7905  c5 b2
    bne l_791c ; $7907  d0 13
    dey ; $7909  88
    lda ($36),y ; $790a  b1 36
    iny ; $790c  c8
    and #$03 ; $790d  29 03
    cmp #$01 ; $790f  c9 01
    beq l_7919 ; $7911  f0 06
    lda $b2 ; $7913  a5 b2
    cmp #$01 ; $7915  c9 01
    beq l_791c ; $7917  f0 03
l_7919:
    txa ; $7919  8a
    clc ; $791a  18
    rts ; $791b  60
l_791c:
    iny ; $791c  c8
    iny ; $791d  c8
    iny ; $791e  c8
    cpy #$54 ; $791f  c0 54
    bcc l_78fd ; $7921  90 da
    rts ; $7923  60

; Load item properties: X=item ID on entry. Returns A=type/effect,
; X=damage dice, Y=armor/damage bonus, $57=usable-class mask.
    ldy $e473,x ; $7924  bc 73 e4
    lda $e673,x ; $7927  bd 73 e6
    sta $57 ; $792a  85 57
    lda $e573,x ; $792c  bd 73 e5
    pha ; $792f  48
    lda $e373,x ; $7930  bd 73 e3
    tax ; $7933  aa
    pla ; $7934  68
    rts ; $7935  60
l_7936:
    jsr l_8520 ; $7936  20 20 85
    jsr $fb81 ; $7939  20 81 fb
    lda #$0a ; $793c  a9 0a
    jsr l_8f6b ; $793e  20 6b 8f
    ldx #$ff ; $7941  a2 ff
    stx $2f ; $7943  86 2f
    txs ; $7945  9a
    ldx #$64 ; $7946  a2 64
    ldy #$79 ; $7948  a0 79
    jsr l_7acc ; $794a  20 cc 7a
    lda #$0c ; $794d  a9 0c
    sta $09 ; $794f  85 09
    lda #$0f ; $7951  a9 0f
    sta $0a ; $7953  85 0a
    lda #$00 ; $7955  a9 00
    sta $0c ; $7957  85 0c
    sta $0b ; $7959  85 0b
    sta $5e ; $795b  85 5e
    sta $61 ; $795d  85 61
    sta $62 ; $795f  85 62
    jmp enter_engine ; $7961  4c 00 66
    !byte $87,$39,$88,$d3,$ef,$f2,$f2,$f9,$ac,$a0,$c2,$f5,$e4,$ff,$85,$f0 ; $7964 retained data / unresolved code
    !byte $98,$29,$6c,$37,$7d,$22,$18,$0a,$33,$b8,$52,$29,$04,$df,$0a,$0a ; $7974 retained data / unresolved code
    !byte $89,$8b,$b0,$8e,$93,$0a,$1e,$e3,$06,$6f,$08,$8b,$53,$3a,$74,$89 ; $7984 retained data / unresolved code
    !byte $a2,$14,$98,$55,$33,$b0,$00,$09 ; $7994 retained data / unresolved code
    lda #$80 ; $799c  a9 80
    bit+2 $00a9 ; $799e  2c a9 00
    sta $79d3 ; $79a1  8d d3 79
    lsr $7a0c ; $79a4  4e 0c 7a
    lda $1062 ; $79a7  ad 62 10
    ldx $1063 ; $79aa  ae 63 10
    ldy $08 ; $79ad  a4 08
    bne l_79b7 ; $79af  d0 06
    lda $1055 ; $79b1  ad 55 10
    ldx $1056 ; $79b4  ae 56 10
l_79b7:
    clc ; $79b7  18
    adc #$40 ; $79b8  69 40
    sta $12 ; $79ba  85 12
    txa ; $79bc  8a
    adc #$10 ; $79bd  69 10
    sta $13 ; $79bf  85 13
    ldy #$00 ; $79c1  a0 00
    lda ($12),y ; $79c3  b1 12
    beq l_7a08 ; $79c5  f0 41
    tax ; $79c7  aa
    inc $12 ; $79c8  e6 12
    bne l_79ce ; $79ca  d0 02
    inc $13 ; $79cc  e6 13
l_79ce:
    ldy #$00 ; $79ce  a0 00
    lda ($12),y ; $79d0  b1 12
    eor #$00 ; $79d2  49 00
    cmp #$7f ; $79d4  c9 7f
    beq l_79dc ; $79d6  f0 04
    cmp $09 ; $79d8  c5 09
    bne l_79fa ; $79da  d0 1e
l_79dc:
    iny ; $79dc  c8
    lda ($12),y ; $79dd  b1 12
    cmp #$ff ; $79df  c9 ff
    beq l_79e7 ; $79e1  f0 04
    cmp $0a ; $79e3  c5 0a
    bne l_79fa ; $79e5  d0 13
l_79e7:
    lda $13 ; $79e7  a5 13
    pha ; $79e9  48
    lda $12 ; $79ea  a5 12
    pha ; $79ec  48
    txa ; $79ed  8a
    pha ; $79ee  48
    jsr l_7a0d ; $79ef  20 0d 7a
    pla ; $79f2  68
    tax ; $79f3  aa
    pla ; $79f4  68
    sta $12 ; $79f5  85 12
    pla ; $79f7  68
    sta $13 ; $79f8  85 13
l_79fa:
    clc ; $79fa  18
    lda $12 ; $79fb  a5 12
    adc #$04 ; $79fd  69 04
    sta $12 ; $79ff  85 12
    bcc l_7a05 ; $7a01  90 02
    inc $13 ; $7a03  e6 13
l_7a05:
    dex ; $7a05  ca
    bne l_79ce ; $7a06  d0 c6
l_7a08:
    asl $7a0c ; $7a08  0e 0c 7a
    rts ; $7a0b  60
    !byte $00 ; $7a0c retained data / unresolved code
l_7a0d:
    ldy #$02 ; $7a0d  a0 02
    clc ; $7a0f  18
    lda ($12),y ; $7a10  b1 12
    adc #$40 ; $7a12  69 40
    sta $d1 ; $7a14  85 d1
    iny ; $7a16  c8
    lda ($12),y ; $7a17  b1 12
    adc #$10 ; $7a19  69 10
    sta $d2 ; $7a1b  85 d2
l_7a1d:
    jsr l_7ae9 ; $7a1d  20 e9 7a
    cmp #$ff ; $7a20  c9 ff
    beq l_7a3d ; $7a22  f0 19
    asl ; $7a24  0a
    tay ; $7a25  a8
    ror $7ae8 ; $7a26  6e e8 7a
    lda $7a3e,y ; $7a29  b9 3e 7a
    sta $7a36 ; $7a2c  8d 36 7a
    lda $7a3f,y ; $7a2f  b9 3f 7a
    sta $7a37 ; $7a32  8d 37 7a

; RAM IRQ vector high / unpatched operand placeholder
    jsr $ffff ; $7a35  20 ff ff
    bit $7ae8 ; $7a38  2c e8 7a
    bmi l_7a1d ; $7a3b  30 e0
l_7a3d:
    rts ; $7a3d  60
    !byte $f4,$7a,$f7,$7a,$7f,$7b,$af,$7b,$f5,$7b,$3a,$7c,$4b,$7c,$61,$7c ; $7a3e retained data / unresolved code
    !byte $68,$7c,$0d,$6f,$73,$86,$71,$7c,$6e,$7c,$ad,$7c,$f0,$7c,$f2,$7c ; $7a4e retained data / unresolved code
    !byte $16,$7d,$1e,$7d,$3d,$7c,$7a,$81,$25,$7d,$37,$7d,$c0,$7d,$c3,$7d ; $7a5e retained data / unresolved code
    !byte $ef,$7d,$05,$7e,$97,$7c,$f3,$7b,$00,$7e,$2f,$7e,$38,$7e,$5f,$7e ; $7a6e retained data / unresolved code
    !byte $69,$7e,$92,$7e,$9c,$7e,$a6,$7e,$ee,$7e,$18,$7f,$28,$7f,$4c,$7f ; $7a7e retained data / unresolved code
    !byte $65,$7f,$68,$7f,$84,$7f,$1a,$73,$8a,$7f,$b4,$7f,$ce,$7f,$dc,$7f ; $7a8e retained data / unresolved code
    !byte $17,$80,$40,$80,$50,$80,$60,$80,$70,$80,$77,$80,$85,$80,$90,$80 ; $7a9e retained data / unresolved code
    !byte $95,$80,$b7,$80,$24,$7c,$fb,$7d,$e6,$80,$ff,$80,$02,$81,$23,$81 ; $7aae retained data / unresolved code
    !byte $25,$81,$56,$81,$87,$81,$96,$81,$bf,$81,$27,$7c,$ac,$7b ; $7abe retained data / unresolved code
l_7acc:
    lda $d1 ; $7acc  a5 d1
    pha ; $7ace  48
    lda $d2 ; $7acf  a5 d2
    pha ; $7ad1  48
    lda $7ae8 ; $7ad2  ad e8 7a
    pha ; $7ad5  48
    stx $d1 ; $7ad6  86 d1
    sty $d2 ; $7ad8  84 d2
    jsr l_7a1d ; $7ada  20 1d 7a
    pla ; $7add  68
    sta $7ae8 ; $7ade  8d e8 7a
    pla ; $7ae1  68
    sta $d2 ; $7ae2  85 d2
    pla ; $7ae4  68
    sta $d1 ; $7ae5  85 d1
    rts ; $7ae7  60
    !byte $00 ; $7ae8 retained data / unresolved code
l_7ae9:
    ldy #$00 ; $7ae9  a0 00
    lda ($d1),y ; $7aeb  b1 d1
    inc $d1 ; $7aed  e6 d1
    bne l_7af3 ; $7aef  d0 02
    inc $d2 ; $7af1  e6 d2
l_7af3:
    rts ; $7af3  60
    !byte $a9,$00,$2c,$a9,$10,$a6,$2c,$f0,$01,$60,$e6,$2c,$48,$4d,$50,$10 ; $7af4 retained data / unresolved code
    !byte $29,$10,$85,$4f,$20,$07,$74,$f4,$d2,$68,$98,$22,$89,$83,$29,$89 ; $7b04 retained data / unresolved code
    !byte $51,$90,$52,$68,$9b,$61,$43,$d4,$e4,$07,$fa,$52,$1f,$d4,$af,$b3 ; $7b14 retained data / unresolved code
    !byte $bf,$ae,$03,$e2,$bc,$37,$7d,$03,$65,$49,$21,$9b,$c3,$31,$2c,$c1 ; $7b24 retained data / unresolved code
    !byte $9a,$4c,$df,$f1,$de,$80,$20,$10,$7e,$90,$02,$68,$60,$20,$00,$7e ; $7b34 retained data / unresolved code
    !byte $68,$f0,$1d,$e6,$0d,$a6,$0d,$bd,$52,$10,$85,$35,$18,$a5,$09,$6d ; $7b44 retained data / unresolved code
    !byte $61,$10,$85,$09,$18,$a5,$0a,$6d,$60,$10,$85,$0a,$38,$4c,$77,$68 ; $7b54 retained data / unresolved code
    !byte $c6,$0d,$30,$03,$4c,$49,$7b,$ad,$5a,$10,$85,$09,$ad,$5b,$10,$85 ; $7b64 retained data / unresolved code
    !byte $0a,$ad,$5c,$10,$85,$0c,$a9,$00,$4c,$00,$66,$46,$d3,$20,$e9,$7a ; $7b74 retained data / unresolved code
    !byte $18,$69,$0d,$a6,$08,$f0,$02,$69,$0a,$85,$35,$20,$8d,$66,$a6,$08 ; $7b84 retained data / unresolved code
    !byte $d0,$06,$20,$00,$a8,$4c,$9f,$7b,$20,$00,$ad,$e6,$2d,$a9,$40,$85 ; $7b94 retained data / unresolved code
    !byte $38,$a9,$10,$85,$39,$4c,$51,$75,$20,$fd,$81,$20,$00,$7e,$20,$e9 ; $7ba4 retained data / unresolved code
    !byte $7a,$85,$09,$20,$e9,$7a,$85,$0a,$20,$e9,$7a,$a6,$08,$d0,$15,$a8 ; $7bb4 retained data / unresolved code
    !byte $30,$09,$c5,$0c,$f0,$23,$85,$0c,$4c,$2f,$66,$29,$7f,$85,$35,$a9 ; $7bc4 retained data / unresolved code
    !byte $01,$4c,$00,$66,$a8,$30,$0d,$a6,$0d,$dd,$52,$10,$f0,$0b,$85,$35 ; $7bd4 retained data / unresolved code
    !byte $18,$4c,$77,$68,$29,$7f,$4c,$78,$7b,$a2,$ff,$9a,$4c,$00,$9b,$e6 ; $7be4 retained data / unresolved code
    !byte $d4,$20,$e9,$7a,$aa,$ca,$86,$89,$8a,$48,$aa,$20,$df,$f9,$20,$e9 ; $7bf4 retained data / unresolved code
    !byte $7a,$91,$49,$20,$e9,$7a,$a0,$15,$91,$49,$68,$38,$e9,$01,$10,$e9 ; $7c04 retained data / unresolved code
    !byte $e6,$62,$a9,$00,$85,$61,$a9,$fe,$20,$00,$66,$a5,$8a,$4c,$83,$7c ; $7c14 retained data / unresolved code
    !byte $20,$73,$86,$20,$e9,$7a,$18,$69,$40,$aa,$20,$e9,$7a,$69,$10,$a8 ; $7c24 retained data / unresolved code
    !byte $20,$19,$74,$e6,$2d,$60,$20,$73,$86,$a6,$d1,$a4,$d2,$20,$19,$74 ; $7c34 retained data / unresolved code
    !byte $86,$d1,$84,$d2,$e6,$2d,$60,$20,$e9,$7a,$18,$69,$40,$85,$12,$20 ; $7c44 retained data / unresolved code
    !byte $e9,$7a,$69,$10,$85,$13,$a0,$00,$a9,$ff,$91,$12,$60,$20,$e9,$7a ; $7c54 retained data / unresolved code
    !byte $aa,$4c,$c9,$68,$20,$ef,$80,$4c,$51,$75,$a9,$ff,$2c,$a9,$00,$85 ; $7c64 retained data / unresolved code
    !byte $12,$20,$09,$7d,$b9,$c0,$00,$45,$12,$3d,$58,$cd,$dd,$58,$cd,$f0 ; $7c74 retained data / unresolved code
    !byte $0d,$2c,$e8,$7a,$10,$1d,$20,$e9,$7a,$4c,$e9,$7a,$f0,$f3,$2c,$e8 ; $7c84 retained data / unresolved code
    !byte $7a,$10,$11,$20,$e9,$7a,$18,$69,$40,$aa,$20,$e9,$7a,$69,$10,$85 ; $7c94 retained data / unresolved code
    !byte $d2,$86,$d1,$60,$38,$6e,$e8,$7a,$60,$20,$e9,$7a,$48,$20,$e9,$7a ; $7ca4 retained data / unresolved code
    !byte $aa,$20,$e9,$7a,$85,$12,$68,$a8,$a5,$12,$48,$20,$6e,$a2,$68,$48 ; $7cb4 retained data / unresolved code
    !byte $29,$0f,$85,$12,$0a,$0a,$0a,$0a,$05,$12,$85,$12,$68,$4a,$4a,$4a ; $7cc4 retained data / unresolved code
    !byte $4a,$aa,$98,$18,$7d,$e8,$7c,$a8,$b1,$42,$45,$12,$3d,$ec,$7c,$51 ; $7cd4 retained data / unresolved code
    !byte $42,$91,$42,$60,$ff,$ff,$00,$00,$f0,$0f,$f0,$0f,$38,$24,$18,$08 ; $7ce4 retained data / unresolved code
    !byte $20,$09,$7d,$bd,$58,$cd,$49,$ff,$39,$c0,$00,$28,$90,$03,$1d,$58 ; $7cf4 retained data / unresolved code
    !byte $cd,$99,$c0,$00,$60,$20,$e9,$7a,$48,$29,$07,$aa,$68,$4a,$4a,$4a ; $7d04 retained data / unresolved code
    !byte $a8,$60,$20,$e9,$7a,$45,$58,$4c,$83,$7c,$38,$6e,$0c,$7a,$4c,$81 ; $7d14 retained data / unresolved code
    !byte $fb,$20,$e9,$7a,$85,$12,$a4,$d0,$b1,$36,$4a,$4a,$29,$0f,$c5,$12 ; $7d24 retained data / unresolved code
    !byte $4c,$83,$7c,$20,$e9,$7a,$85,$55,$20,$e9,$7a,$85,$53,$20,$e9,$7a ; $7d34 retained data / unresolved code
    !byte $85,$56,$20,$07,$74,$f5,$92,$f0,$d8,$4e,$9c,$83,$37,$85,$06,$98 ; $7d44 retained data / unresolved code
    !byte $66,$93,$04,$00,$20,$e6,$6f,$a9,$bf,$20,$8e,$84,$20,$37,$8f,$b0 ; $7d54 retained data / unresolved code
    !byte $34,$8a,$4a,$20,$5b,$71,$90,$33,$20,$07,$74,$f4,$9f,$18,$dc,$23 ; $7d64 retained data / unresolved code
    !byte $a4,$c2,$00,$a6,$42,$a4,$43,$20,$1c,$75,$20,$0a,$74,$09,$04,$ed ; $7d74 retained data / unresolved code
    !byte $4c,$24,$14,$63,$70,$89,$d7,$0b,$5f,$13,$05,$53,$33,$65,$80,$00 ; $7d84 retained data / unresolved code
    !byte $20,$0d,$6f,$b0,$ad,$20,$73,$86,$4c,$85,$7c,$20,$73,$86,$a6,$42 ; $7d94 retained data / unresolved code
    !byte $a4,$43,$20,$1c,$75,$20,$0a,$74,$0a,$1f,$30,$cd,$26,$08,$00,$20 ; $7da4 retained data / unresolved code
    !byte $e6,$6f,$a9,$ae,$20,$8e,$84,$e6,$2d,$4c,$92,$7c,$a9,$00,$2c,$a9 ; $7db4 retained data / unresolved code
    !byte $80,$85,$93,$20,$e9,$7a,$85,$b2,$20,$16,$6f,$d9,$7d,$a9,$00,$6a ; $7dc4 retained data / unresolved code
    !byte $45,$93,$4c,$83,$7c,$f0,$0f,$a0,$31,$b1,$12,$c5,$b2,$f0,$08,$c8 ; $7dd4 retained data / unresolved code
    !byte $c8,$c8,$c0,$54,$90,$f3,$60,$68,$68,$18,$60,$a5,$2c,$d0,$05,$e6 ; $7de4 retained data / unresolved code
    !byte $2c,$4c,$92,$7c,$4c,$85,$7c,$a5,$31,$4c,$90,$7c,$a9,$00,$85,$2c ; $7df4 retained data / unresolved code
    !byte $60,$20,$10,$7e,$90,$03,$4c,$85,$7c,$4c,$92,$7c ; $7e04 retained data / unresolved code
    jsr print_inline_text_without_reset ; $7e10  20 0a 74

; Packed text: 'Yes<$0d>No'
    !byte $fe,$06,$97,$7f,$2b,$c0 ; $7e13 retained data / unresolved code
    jsr read_input_with_inline_flags ; $7e19  20 0f 8b

; Inline input flags: $42, $20; following variable filter table remains unresolved
    !byte $42,$20,$ce,$25,$7e,$d9,$2a,$7e,$ff,$20,$73,$86,$38,$60,$20,$73 ; $7e1c retained data / unresolved code
    !byte $86,$18,$60,$20,$f8,$8d,$20,$00,$8e,$4c,$ed,$7b,$20,$e9,$7a,$85 ; $7e2c retained data / unresolved code
    !byte $b2,$20,$16,$6f,$43,$7e,$60,$f0,$0f,$a0,$31,$b1,$12,$c5,$b2,$f0 ; $7e3c retained data / unresolved code
    !byte $08,$c8,$c8,$c8,$c0,$54,$90,$f3,$60,$88,$20,$89,$7e,$20,$f5,$70 ; $7e4c retained data / unresolved code
    !byte $68,$68,$60,$20,$75,$7e,$f6,$d5,$d0,$02,$f6,$d6,$60,$20,$75,$7e ; $7e5c retained data / unresolved code
    !byte $b5,$d5,$d0,$02,$d6,$d6,$d6,$d5,$60,$20,$e9,$7a,$0a,$aa,$60,$20 ; $7e6c retained data / unresolved code
    !byte $75,$7e,$20,$e9,$7a,$85,$12,$20,$e9,$7a,$85,$13,$60,$a5,$12,$85 ; $7e7c retained data / unresolved code
    !byte $36,$a5,$13,$85,$37,$60,$20,$75,$7e,$b5,$d5,$15,$d6,$4c,$83,$7c ; $7e8c retained data / unresolved code
    !byte $20,$75,$7e,$b5,$d5,$15,$d6,$4c,$90,$7c,$20,$e9,$7a,$85,$93,$20 ; $7e9c retained data / unresolved code
    !byte $e9,$7a,$85,$94,$20,$16,$6f,$bd,$7e,$20,$5e,$6f,$90,$33,$4c,$36 ; $7eac retained data / unresolved code
    !byte $79,$f0,$2e,$8a,$48,$a0,$21,$38,$b1,$12,$e5,$93,$91,$12,$aa,$c8 ; $7ebc retained data / unresolved code
    !byte $b1,$12,$e5,$94,$91,$12,$90,$05,$d0,$12,$8a,$d0,$0f,$a9,$00,$91 ; $7ecc retained data / unresolved code
    !byte $12,$88,$91,$12,$a0,$2d,$b1,$12,$09,$04,$91,$12,$68,$4a,$4c,$93 ; $7edc retained data / unresolved code
    !byte $fb,$60,$a2,$00,$20,$e9,$7a,$95,$9b,$e8,$e0,$04,$90,$f6,$a5,$09 ; $7eec retained data / unresolved code
    !byte $c5,$9b,$90,$15,$c5,$9d,$f0,$02,$b0,$0f,$a5,$0a,$c5,$9c,$90,$09 ; $7efc retained data / unresolved code
    !byte $c5,$9e,$f0,$02,$b0,$03,$4c,$92,$7c,$4c,$85,$7c,$20,$e9,$7a,$0a ; $7f0c retained data / unresolved code
    !byte $0a,$a4,$d0,$51,$36,$29,$3c,$51,$36,$91,$36,$60,$20,$e9,$7a,$85 ; $7f1c retained data / unresolved code
    !byte $12,$a4,$d0,$c8,$b1,$36,$aa,$c8,$b1,$36,$18,$65,$12,$b0,$04,$c9 ; $7f2c retained data / unresolved code
    !byte $fe,$90,$02,$a9,$fe,$dd,$73,$e2,$90,$03,$bd,$73,$e2,$91,$36,$60 ; $7f3c retained data / unresolved code
    !byte $20,$e9,$7a,$85,$12,$a4,$d0,$c8,$c8,$b1,$36,$c9,$ff,$f0,$07,$38 ; $7f4c retained data / unresolved code
    !byte $e5,$12,$b0,$02,$a9,$00,$91,$36,$60,$a9,$79,$2c,$a9,$f9,$8d,$77 ; $7f5c retained data / unresolved code
    !byte $7f,$0a,$08,$20,$7b,$7e,$a0,$00,$28,$b5,$d5,$79,$12,$00,$95,$d5 ; $7f6c retained data / unresolved code
    !byte $e8,$c8,$98,$49,$02,$d0,$f2,$60,$20,$e9,$7a,$85,$0b,$60,$20,$ef ; $7f7c retained data / unresolved code
    !byte $80,$a2,$00,$86,$12,$a0,$00,$b1,$38,$c9,$ff,$f0,$09,$dd,$00,$02 ; $7f8c retained data / unresolved code
    !byte $d0,$07,$e8,$c8,$d0,$f1,$4c,$92,$7c,$a6,$12,$bd,$00,$02,$c9,$ff ; $7f9c retained data / unresolved code
    !byte $f0,$03,$e8,$d0,$de,$4c,$85,$7c,$20,$b7,$73,$20,$75,$7e,$a5,$ad ; $7fac retained data / unresolved code
    !byte $05,$ae,$f0,$05,$a9,$ff,$a8,$d0,$04,$a5,$ab,$a4,$ac,$95,$d5,$94 ; $7fbc retained data / unresolved code
    !byte $d6,$60,$20,$37,$8f,$b0,$06,$84,$36,$85,$37,$90,$3b,$4c,$85,$7c ; $7fcc retained data / unresolved code
    !byte $20,$75,$7e,$b5,$d5,$85,$ab,$b5,$d6,$85,$ac,$a9,$00,$85,$ad,$85 ; $7fdc retained data / unresolved code
    !byte $ae,$a0,$19,$20,$af,$71,$90,$1b,$20,$07,$74,$f5,$df,$40,$95,$ee ; $7fec retained data / unresolved code
    !byte $d4,$c2,$91,$54,$c1,$33,$9f,$44,$24,$28,$7b,$0b,$80,$00,$20,$0d ; $7ffc retained data / unresolved code
    !byte $6f,$b0,$ca,$a0,$19,$20,$08,$72,$4c,$92,$7c,$20,$75,$7e,$a0,$19 ; $800c retained data / unresolved code
    !byte $18,$b1,$36,$75,$d5,$91,$36,$e8,$c8,$98,$49,$1b,$d0,$f3,$71,$36 ; $801c retained data / unresolved code
    !byte $91,$36,$c8,$98,$49,$1c,$f0,$f6,$90,$09,$a9,$ff,$88,$91,$36,$c0 ; $802c retained data / unresolved code
    !byte $19,$d0,$f9,$60,$20,$7b,$7e,$b5,$d5,$c5,$12,$b5,$d6,$e5,$13,$90 ; $803c retained data / unresolved code
    !byte $20,$4c,$85,$7c,$20,$7b,$7e,$b5,$d5,$c5,$12,$d0,$04,$b5,$d6,$c5 ; $804c retained data / unresolved code
    !byte $13,$4c,$83,$7c,$20,$7b,$7e,$a5,$12,$d5,$d5,$a5,$13,$f5,$d6,$b0 ; $805c retained data / unresolved code
    !byte $e0,$4c,$92,$7c,$20,$e9,$7a,$a8,$4c,$72,$ef,$20,$75,$7e,$20,$e9 ; $806c retained data / unresolved code
    !byte $7a,$95,$d5,$20,$e9,$7a,$95,$d6,$60,$20,$e9,$7a,$a4,$d0,$c8,$d1 ; $807c retained data / unresolved code
    !byte $36,$4c,$83,$7c,$a4,$d0,$4c,$f5,$70,$20,$e9,$7a,$48,$20,$4a,$6f ; $808c retained data / unresolved code
    !byte $68,$b0,$15,$0a,$aa,$bd,$3e,$d5,$85,$49,$bd,$3f,$d5,$85,$4a,$20 ; $809c retained data / unresolved code
    !byte $66,$f6,$20,$81,$fb,$4c,$92,$7c,$4c,$85,$7c,$20,$ef,$80,$20,$16 ; $80ac retained data / unresolved code
    !byte $6f,$c3,$80,$b0,$f3,$90,$ee,$a0,$29,$b1,$12,$49,$0d,$d0,$1a,$a8 ; $80bc retained data / unresolved code
    !byte $b1,$12,$d1,$38,$d0,$13,$c9,$ff,$f0,$05,$c8,$c0,$10,$90,$f1,$68 ; $80cc retained data / unresolved code
    !byte $68,$20,$89,$7e,$8a,$4a,$85,$83,$18,$60,$a5,$83,$0a,$20,$44,$6d ; $80dc retained data / unresolved code
    !byte $4c,$81,$fb,$a5,$d1,$85,$38,$a5,$d2,$85,$39,$20,$e9,$7a,$c9,$ff ; $80ec retained data / unresolved code
    !byte $d0,$f9,$60,$a9,$f0,$2c,$a9,$d0,$8d,$1d,$81,$20,$47,$81,$20,$16 ; $80fc retained data / unresolved code
    !byte $6f,$15,$81,$6a,$29,$80,$4c,$83,$7c,$f0,$0b,$a4,$16,$b1,$12,$25 ; $810c retained data / unresolved code
    !byte $15,$f0,$03,$68,$68,$18,$60,$18,$24,$38,$66,$93,$20,$47,$81,$20 ; $811c retained data / unresolved code
    !byte $16,$6f,$31,$81,$60,$f0,$fd,$a4,$16,$a5,$15,$24,$93,$30,$05,$11 ; $812c retained data / unresolved code
    !byte $12,$91,$12,$60,$49,$ff,$31,$12,$91,$12,$60,$20,$09,$7d,$bd,$58 ; $813c retained data / unresolved code
    !byte $cd,$85,$15,$98,$18,$69,$72,$85,$16,$60,$20,$e9,$7a,$85,$15,$20 ; $814c retained data / unresolved code
    !byte $16,$6f,$68,$81,$6a,$29,$80,$49,$80,$4c,$83,$7c,$f0,$0f,$a0,$1d ; $815c retained data / unresolved code
    !byte $b1,$12,$c5,$15,$c8,$b1,$12,$e9,$00,$b0,$02,$68,$68,$60,$a5,$08 ; $816c retained data / unresolved code
    !byte $d0,$06,$20,$25,$a0,$4c,$75,$9c,$4c,$ea,$a0,$20,$a5,$81,$85,$12 ; $817c retained data / unresolved code
    !byte $20,$e9,$7a,$45,$12,$29,$0f,$4c,$83,$7c,$20,$a5,$81,$98,$48,$20 ; $818c retained data / unresolved code
    !byte $e9,$7a,$aa,$68,$a8,$8a,$91,$12,$60,$20,$00,$8e,$a6,$0a,$a4,$09 ; $819c retained data / unresolved code
    !byte $20,$08,$a1,$98,$48,$20,$f8,$8d,$20,$00,$8e,$20,$f8,$8d,$68,$a8 ; $81ac retained data / unresolved code
    !byte $b1,$12,$60,$20,$e9,$7a,$a0,$29,$d1,$36,$4c,$83,$7c ; $81bc retained data / unresolved code
l_81c9:
    rts ; $81c9  60
l_81ca:
    ldx #$06 ; $81ca  a2 06
l_81cc:
    ldy #$0c ; $81cc  a0 0c
    clc ; $81ce  18
    lda $d180,x ; $81cf  bd 80 d1
    adc $d310,y ; $81d2  79 10 d3
    sta $12 ; $81d5  85 12
    lda $d248,x ; $81d7  bd 48 d2
    adc $d3b0,y ; $81da  79 b0 d3
    sta $13 ; $81dd  85 13
    ldy #$50 ; $81df  a0 50
l_81e1:
    lda #$00 ; $81e1  a9 00
    sta ($12),y ; $81e3  91 12
    tya ; $81e5  98
    sec ; $81e6  38
    sbc #$08 ; $81e7  e9 08
    tay ; $81e9  a8
    cpy #$f8 ; $81ea  c0 f8
    bne l_81e1 ; $81ec  d0 f3
    inx ; $81ee  e8
    cpx #$5e ; $81ef  e0 5e
    bcc l_81cc ; $81f1  90 d9
    ldx #$00 ; $81f3  a2 00
    stx $2e ; $81f5  86 2e
    stx $1f ; $81f7  86 1f
    dex ; $81f9  ca
    stx $02 ; $81fa  86 02
    rts ; $81fc  60
    !byte $a9,$08,$85,$50,$a2,$06,$a0,$0c,$18,$bd,$80,$d1,$79,$10,$d3,$85 ; $81fd retained data / unresolved code
    !byte $12,$bd,$48,$d2,$79,$b0,$d3,$85,$13,$a0,$50,$b1,$12,$38,$6a,$91 ; $820d retained data / unresolved code
    !byte $12,$98,$38,$e9,$08,$a8,$c0,$f8,$d0,$f1,$e8,$e0,$5e,$90,$d7,$c6 ; $821d retained data / unresolved code
    !byte $50,$d0,$d1,$f0,$c1 ; $822d retained data / unresolved code
l_8232:
    ldx #$01 ; $8232  a2 01
    ldy #$08 ; $8234  a0 08
    lda $0800 ; $8236  ad 00 08
    pha ; $8239  48
    jsr initialize_resource_decoder ; $823a  20 99 82
    pla ; $823d  68
    jsr l_8ae6 ; $823e  20 e6 8a
    lda #$00 ; $8241  a9 00
    sta $18 ; $8243  85 18
    ldy $8283 ; $8245  ac 83 82
l_8248:
    sty $1c ; $8248  84 1c
    ldx $8281 ; $824a  ae 81 82
l_824d:
    stx $1a ; $824d  86 1a
    tya ; $824f  98
    asl ; $8250  0a
    asl ; $8251  0a
    tay ; $8252  a8
    lda $d180,x ; $8253  bd 80 d1
    adc $d310,y ; $8256  79 10 d3
    sta $12 ; $8259  85 12
    lda $d248,x ; $825b  bd 48 d2
    adc $d3b0,y ; $825e  79 b0 d3
    sta $13 ; $8261  85 13
    jsr decode_resource_byte ; $8263  20 b8 82
    eor $18 ; $8266  45 18
    sta $18 ; $8268  85 18
    ldy #$00 ; $826a  a0 00
    sta ($12),y ; $826c  91 12
    ldy $1c ; $826e  a4 1c
    ldx $1a ; $8270  a6 1a
    inx ; $8272  e8
    cpx $8282 ; $8273  ec 82 82
    bcc l_824d ; $8276  90 d5
    iny ; $8278  c8
    cpy $8284 ; $8279  cc 84 82
    bcc l_8248 ; $827c  90 ca
    beq l_8248 ; $827e  f0 c8
    rts ; $8280  60
    !byte $06,$5e,$03,$0d,$00,$01,$04,$05,$06,$07,$08,$09,$0a,$16,$17,$18 ; $8281 retained data / unresolved code
    !byte $19,$1a,$1b,$1c,$1d,$3c,$3d,$3e ; $8291 retained data / unresolved code

; Input X/Y = compressed resource stream. Reset run/bit state,
; then read a 20-byte literal dictionary into $021f..$0232.
initialize_resource_decoder:
    stx $833c ; $8299  8e 3c 83
    sty $833d ; $829c  8c 3d 83
    ldx #$00 ; $829f  a2 00
    stx $15 ; $82a1  86 15
    stx $b2 ; $82a3  86 b2
    dex ; $82a5  ca
    stx $16 ; $82a6  86 16
    ldy #$00 ; $82a8  a0 00
l_82aa:
    ldx #$08 ; $82aa  a2 08
    jsr read_resource_bits ; $82ac  20 30 83
    sta $021f,y ; $82af  99 1f 02
    iny ; $82b2  c8
    cpy #$14 ; $82b3  c0 14
    bcc l_82aa ; $82b5  90 f3
    rts ; $82b7  60

; Return next decompressed byte in A. An active run repeats $19.
; Otherwise a leading zero reads an 8-bit literal; leading one decodes
; a variable-length dictionary token or a run (8-bit count + value).
decode_resource_byte:
    lda $15 ; $82b8  a5 15
    beq l_82c1 ; $82ba  f0 05
    dec $15 ; $82bc  c6 15
    lda $19 ; $82be  a5 19
    rts ; $82c0  60
l_82c1:
    ldx #$01 ; $82c1  a2 01
    jsr read_resource_bits ; $82c3  20 30 83
    lsr ; $82c6  4a
    bcs l_82ce ; $82c7  b0 05
    ldx #$08 ; $82c9  a2 08
    jmp read_resource_bits ; $82cb  4c 30 83
l_82ce:
    ldx #$03 ; $82ce  a2 03
    jsr read_resource_bits ; $82d0  20 30 83
    tay ; $82d3  a8
    beq l_831b ; $82d4  f0 45
    cpy #$01 ; $82d6  c0 01
    beq l_831b ; $82d8  f0 41
    pha ; $82da  48
    ldx #$01 ; $82db  a2 01
    jsr read_resource_bits ; $82dd  20 30 83
    lsr ; $82e0  4a
    pla ; $82e1  68
    rol ; $82e2  2a
    ldy #$08 ; $82e3  a0 08
l_82e5:
    cmp $8285,y ; $82e5  d9 85 82
    beq l_831b ; $82e8  f0 31
    dey ; $82ea  88
    cpy #$01 ; $82eb  c0 01
    bne l_82e5 ; $82ed  d0 f6
    pha ; $82ef  48
    ldx #$01 ; $82f0  a2 01
    jsr read_resource_bits ; $82f2  20 30 83
    lsr ; $82f5  4a
    pla ; $82f6  68
    rol ; $82f7  2a
    ldy #$10 ; $82f8  a0 10
l_82fa:
    cmp $8285,y ; $82fa  d9 85 82
    beq l_831b ; $82fd  f0 1c
    dey ; $82ff  88
    cpy #$08 ; $8300  c0 08
    bne l_82fa ; $8302  d0 f6
    pha ; $8304  48
    ldx #$01 ; $8305  a2 01
    jsr read_resource_bits ; $8307  20 30 83
    lsr ; $830a  4a
    pla ; $830b  68
    rol ; $830c  2a
    ldy #$13 ; $830d  a0 13
l_830f:
    cmp $8285,y ; $830f  d9 85 82
    beq l_831b ; $8312  f0 07
    dey ; $8314  88
    cpy #$10 ; $8315  c0 10
    bne l_830f ; $8317  d0 f6
    beq l_831f ; $8319  f0 04
l_831b:
    lda $021f,y ; $831b  b9 1f 02
    rts ; $831e  60
l_831f:
    ldx #$08 ; $831f  a2 08
    jsr read_resource_bits ; $8321  20 30 83
    sta $15 ; $8324  85 15
    dec $15 ; $8326  c6 15
    ldx #$08 ; $8328  a2 08
    jsr read_resource_bits ; $832a  20 30 83
    sta $19 ; $832d  85 19
    rts ; $832f  60

; Read X bits MSB first into A. Source is a self-modifying LDA
; whose operand is $833c/$833d. $16 counts buffered bits; $b2 holds input.
read_resource_bits:
    lda #$00 ; $8330  a9 00
l_8332:
    bit $16 ; $8332  24 16
    bpl l_8349 ; $8334  10 13
    pha ; $8336  48
    lda #$07 ; $8337  a9 07
    sta $16 ; $8339  85 16

; RAM IRQ vector high / unpatched operand placeholder
    lda $ffff ; $833b  ad ff ff
    inc $833c ; $833e  ee 3c 83
    bne l_8346 ; $8341  d0 03
    inc $833d ; $8343  ee 3d 83
l_8346:
    sta $b2 ; $8346  85 b2
    pla ; $8348  68
l_8349:
    asl $b2 ; $8349  06 b2
    rol ; $834b  2a
    dec $16 ; $834c  c6 16
    dex ; $834e  ca
    bne l_8332 ; $834f  d0 e1
    rts ; $8351  60

; Initialize four animation tracks from little-endian offsets at $0800.
; Offsets are relative to $0800; zero disables a track; countdown starts at 1.
l_8352:
    lda #$00 ; $8352  a9 00
    sta $2e ; $8354  85 2e
    ldx #$03 ; $8356  a2 03
l_8358:
    txa ; $8358  8a
    pha ; $8359  48
    lda #$01 ; $835a  a9 01
    jsr l_8365 ; $835c  20 65 83
    pla ; $835f  68
    tax ; $8360  aa
    dex ; $8361  ca
    bpl l_8358 ; $8362  10 f4
    rts ; $8364  60
l_8365:
    sta $12 ; $8365  85 12
    txa ; $8367  8a
    asl ; $8368  0a
    sta $847e ; $8369  8d 7e 84
    lda #$08 ; $836c  a9 08
    sta $847f ; $836e  8d 7f 84
    jsr l_847d ; $8371  20 7d 84
    pha ; $8374  48
    jsr l_847d ; $8375  20 7d 84
    clc ; $8378  18
    adc #$08 ; $8379  69 08
    sta $847f ; $837b  8d 7f 84
    pla ; $837e  68
    sta $847e ; $837f  8d 7e 84
    bne l_838b ; $8382  d0 07
    lda $847f ; $8384  ad 7f 84
    cmp #$08 ; $8387  c9 08
    beq $838e ; $8389  f0 03
l_838b:
    lda $12 ; $838b  a5 12
    !byte $2c,$a9,$00 ; $838d retained data / unresolved code
    sta $8426,x ; $8390  9d 26 84
    sta $842a,x ; $8393  9d 2a 84
    ora $2e ; $8396  05 2e
    sta $2e ; $8398  85 2e
l_839a:
    txa ; $839a  8a
    asl ; $839b  0a
    tay ; $839c  a8
    lda $847e ; $839d  ad 7e 84
    sta $841e,y ; $83a0  99 1e 84
    lda $847f ; $83a3  ad 7f 84
    sta $841f,y ; $83a6  99 1f 84
l_83a9:
    rts ; $83a9  60
l_83aa:
    lda #$00 ; $83aa  a9 00
    sta $fe05 ; $83ac  8d 05 fe

; Update portrait animation tracks 3..0, normally gated by six IRQs
; at $fe05. Some callers bypass the timing gate. See docs/portrait-animation.md.
l_83af:
    lda $034e ; $83af  ad 4e 03
    and #$40 ; $83b2  29 40
    bne l_83bc ; $83b4  d0 06
    lda $ba ; $83b6  a5 ba
    cmp #$03 ; $83b8  c9 03
    bcs l_83c1 ; $83ba  b0 05
l_83bc:
    lda $fe05 ; $83bc  ad 05 fe
    bne l_83a9 ; $83bf  d0 e8
l_83c1:
    lda $2e ; $83c1  a5 2e
    beq l_83a9 ; $83c3  f0 e4
    ldx #$03 ; $83c5  a2 03
l_83c7:
    txa ; $83c7  8a
    pha ; $83c8  48
    jsr l_83d7 ; $83c9  20 d7 83
    pla ; $83cc  68
    tax ; $83cd  aa
    dex ; $83ce  ca
    bpl l_83c7 ; $83cf  10 f6
    lda #$06 ; $83d1  a9 06
    sta $fe05 ; $83d3  8d 05 fe
l_83d6:
    rts ; $83d6  60

; Track step: decrement delay; read patch offset, XOR patch, read next
; delay. A zero delay reads a restart delay and resets to the track start.
l_83d7:
    txa ; $83d7  8a
    asl ; $83d8  0a
    tay ; $83d9  a8
    lda $842a,x ; $83da  bd 2a 84
    beq l_83d6 ; $83dd  f0 f7
    lda $8426,x ; $83df  bd 26 84
    beq l_83e9 ; $83e2  f0 05
    dec $8426,x ; $83e4  de 26 84
    bne l_83d6 ; $83e7  d0 ed
l_83e9:
    lda $841e,y ; $83e9  b9 1e 84
    sta $847e ; $83ec  8d 7e 84
    lda $841f,y ; $83ef  b9 1f 84
    sta $847f ; $83f2  8d 7f 84
    jsr l_847d ; $83f5  20 7d 84
    sta $8472 ; $83f8  8d 72 84
    jsr l_847d ; $83fb  20 7d 84
    clc ; $83fe  18
    adc #$08 ; $83ff  69 08
    sta $8473 ; $8401  8d 73 84
    txa ; $8404  8a
    pha ; $8405  48
    jsr l_842e ; $8406  20 2e 84
    pla ; $8409  68
    tax ; $840a  aa
    jsr l_847d ; $840b  20 7d 84
    ora #$00 ; $840e  09 00
    bne l_8418 ; $8410  d0 06
    jsr l_847d ; $8412  20 7d 84
    jmp l_8365 ; $8415  4c 65 83
l_8418:
    sta $8426,x ; $8418  9d 26 84
    jmp l_839a ; $841b  4c 9a 83
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $841e retained data / unresolved code

; Apply an XOR patch: scan column 3..13, line 6..93. Nonzero bytes
; XOR the bitmap; zero introduces column/line coordinates. Column $ff
; ends the patch; the following line byte is read but discarded.
l_842e:
    ldy #$03 ; $842e  a0 03
l_8430:
    ldx #$06 ; $8430  a2 06
l_8432:
    sty $1c ; $8432  84 1c
    tya ; $8434  98
    asl ; $8435  0a
    asl ; $8436  0a
    tay ; $8437  a8
    lda $d180,x ; $8438  bd 80 d1
    adc $d310,y ; $843b  79 10 d3
    sta $12 ; $843e  85 12
    lda $d248,x ; $8440  bd 48 d2
    adc $d3b0,y ; $8443  79 b0 d3
    sta $13 ; $8446  85 13
    jsr l_8471 ; $8448  20 71 84
    cmp #$00 ; $844b  c9 00
    beq l_8464 ; $844d  f0 15
    ldy #$00 ; $844f  a0 00
    eor ($12),y ; $8451  51 12
    sta ($12),y ; $8453  91 12
    ldy $1c ; $8455  a4 1c
    inx ; $8457  e8
    cpx #$5e ; $8458  e0 5e
    bcc l_8432 ; $845a  90 d6
    iny ; $845c  c8
    cpy #$0d ; $845d  c0 0d
    bcc l_8430 ; $845f  90 cf
    beq l_8430 ; $8461  f0 cd
    rts ; $8463  60
l_8464:
    jsr l_8471 ; $8464  20 71 84
    tay ; $8467  a8
    jsr l_8471 ; $8468  20 71 84
    tax ; $846b  aa
    cpy #$ff ; $846c  c0 ff
    bne l_8432 ; $846e  d0 c2
    rts ; $8470  60

; RAM IRQ vector high / unpatched operand placeholder
l_8471:
    lda $ffff ; $8471  ad ff ff
    inc $8472 ; $8474  ee 72 84
    bne l_847c ; $8477  d0 03
    inc $8473 ; $8479  ee 73 84
l_847c:
    rts ; $847c  60

; RAM IRQ vector high / unpatched operand placeholder
l_847d:
    lda $ffff ; $847d  ad ff ff
    inc $847e ; $8480  ee 7e 84
    bne l_8488 ; $8483  d0 03
    inc $847f ; $8485  ee 7f 84
l_8488:
    rts ; $8488  60
    lda #$a0 ; $8489  a9 a0
    !byte $2c,$a9,$8d ; $848b retained data / unresolved code

; Character output entry used by packed and unpacked text printers.
; Detailed layout/control-code behavior remains to be traced.
output_text_character:
    pha ; $848e  48
    sta $851f ; $848f  8d 1f 85
    txa ; $8492  8a
    pha ; $8493  48
    tya ; $8494  98
    pha ; $8495  48
    lda $851f ; $8496  ad 1f 85
    jsr l_84a2 ; $8499  20 a2 84
    pla ; $849c  68
    tay ; $849d  a8
    pla ; $849e  68
    tax ; $849f  aa
    pla ; $84a0  68
    rts ; $84a1  60
l_84a2:
    ldx $853a ; $84a2  ae 3a 85
    sta $853b,x ; $84a5  9d 3b 85
    inc $853a ; $84a8  ee 3a 85
    cmp #$8d ; $84ab  c9 8d
    bne l_84b2 ; $84ad  d0 03
    jmp l_8520 ; $84af  4c 20 85
l_84b2:
    clc ; $84b2  18
    lda $8563 ; $84b3  ad 63 85
    adc $853a ; $84b6  6d 3a 85
    cmp #$27 ; $84b9  c9 27
    bcs l_84be ; $84bb  b0 01
    rts ; $84bd  60
l_84be:
    dec $853a ; $84be  ce 3a 85
    beq l_84d0 ; $84c1  f0 0d
    ldx $853a ; $84c3  ae 3a 85
l_84c6:
    lda $853b,x ; $84c6  bd 3b 85
    cmp #$a0 ; $84c9  c9 a0
    beq l_84e7 ; $84cb  f0 1a
    dex ; $84cd  ca
    bpl l_84c6 ; $84ce  10 f6
l_84d0:
    jsr l_8520 ; $84d0  20 20 85
    lda #$8d ; $84d3  a9 8d
    jsr l_85c5 ; $84d5  20 c5 85
    lda $20 ; $84d8  a5 20
    sta $8563 ; $84da  8d 63 85
    lda $851f ; $84dd  ad 1f 85
    sta $853b ; $84e0  8d 3b 85
    ldx #$01 ; $84e3  a2 01
    bne l_851b ; $84e5  d0 34
l_84e7:
    stx $84f4 ; $84e7  8e f4 84
    ldx #$00 ; $84ea  a2 00
l_84ec:
    lda $853b,x ; $84ec  bd 3b 85
    jsr l_85c5 ; $84ef  20 c5 85
    inx ; $84f2  e8
    cpx #$00 ; $84f3  e0 00
    bcc l_84ec ; $84f5  90 f5
    lda #$8d ; $84f7  a9 8d
    jsr l_85c5 ; $84f9  20 c5 85
    lda $20 ; $84fc  a5 20
    sta $8563 ; $84fe  8d 63 85
    txa ; $8501  8a
    tay ; $8502  a8
    iny ; $8503  c8
    ldx #$00 ; $8504  a2 00
    inc $853a ; $8506  ee 3a 85
    cpy $853a ; $8509  cc 3a 85
    bcs l_851b ; $850c  b0 0d
l_850e:
    lda $853b,y ; $850e  b9 3b 85
    sta $853b,x ; $8511  9d 3b 85
    iny ; $8514  c8
    inx ; $8515  e8
    cpy $853a ; $8516  cc 3a 85
    bcc l_850e ; $8519  90 f3
l_851b:
    stx $853a ; $851b  8e 3a 85
    rts ; $851e  60
    !byte $00 ; $851f retained data / unresolved code
l_8520:
    ldy $853a ; $8520  ac 3a 85
    beq l_8534 ; $8523  f0 0f
    ldx #$00 ; $8525  a2 00
l_8527:
    lda $853b,x ; $8527  bd 3b 85
    jsr l_85c5 ; $852a  20 c5 85
    inx ; $852d  e8
    dey ; $852e  88
    bne l_8527 ; $852f  d0 f6
    sty $853a ; $8531  8c 3a 85
l_8534:
    lda $20 ; $8534  a5 20
    sta $8563 ; $8536  8d 63 85
    rts ; $8539  60
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $853a retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $854a retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $855a retained data / unresolved code
l_8564:
    sec ; $8564  38
    !byte $24,$18 ; $8565 retained data / unresolved code
    stx $1a ; $8567  86 1a
    sty $1c ; $8569  84 1c
    lda $3c ; $856b  a5 3c
    sta $8472 ; $856d  8d 72 84
    lda $3d ; $8570  a5 3d
    sta $8473 ; $8572  8d 73 84
    lda #$20 ; $8575  a9 20
    ldx #$71 ; $8577  a2 71
    ldy #$84 ; $8579  a0 84
    bcc l_8583 ; $857b  90 06
    lda #$a9 ; $857d  a9 a9
    ldx #$00 ; $857f  a2 00
    ldy #$ea ; $8581  a0 ea
l_8583:
    sta l_85b1 ; $8583  8d b1 85
    stx $85b2 ; $8586  8e b2 85
    sty $85b3 ; $8589  8c b3 85
    jsr l_8471 ; $858c  20 71 84
    sta $15 ; $858f  85 15
    jsr l_8471 ; $8591  20 71 84
    sta $16 ; $8594  85 16
l_8596:
    ldy $1c ; $8596  a4 1c
    lda $1a ; $8598  a5 1a
    asl ; $859a  0a
    asl ; $859b  0a
    tax ; $859c  aa
    lda $d180,y ; $859d  b9 80 d1
    adc $d310,x ; $85a0  7d 10 d3
    sta $12 ; $85a3  85 12
    lda $d248,y ; $85a5  b9 48 d2
    adc $d3b0,x ; $85a8  7d b0 d3
    sta $13 ; $85ab  85 13
    ldx $15 ; $85ad  a6 15
    ldy #$00 ; $85af  a0 00
l_85b1:
    jsr l_8471 ; $85b1  20 71 84
    sta ($12),y ; $85b4  91 12
    tya ; $85b6  98
    clc ; $85b7  18
    adc #$08 ; $85b8  69 08
    tay ; $85ba  a8
    dex ; $85bb  ca
    bne l_85b1 ; $85bc  d0 f3
    inc $1c ; $85be  e6 1c
    dec $16 ; $85c0  c6 16
    bne l_8596 ; $85c2  d0 d2
    rts ; $85c4  60
l_85c5:
    pha ; $85c5  48
    sta $23 ; $85c6  85 23
    txa ; $85c8  8a
    pha ; $85c9  48
    tya ; $85ca  98
    pha ; $85cb  48
    lda $23 ; $85cc  a5 23
    bmi l_85f8 ; $85ce  30 28
    lda $22 ; $85d0  a5 22
    sec ; $85d2  38
    sbc #$05 ; $85d3  e9 05
    bcc l_85f6 ; $85d5  90 1f
    lsr ; $85d7  4a
    lsr ; $85d8  4a
    lsr ; $85d9  4a
    cmp #$0b ; $85da  c9 0b
    bcs l_85f6 ; $85dc  b0 18
    tax ; $85de  aa
    lda $23 ; $85df  a5 23
    sta $8cb8,x ; $85e1  9d b8 8c
    lda #$ff ; $85e4  a9 ff
    sta $8cad,x ; $85e6  9d ad 8c
    sta $24 ; $85e9  85 24
    lda $23 ; $85eb  a5 23
    jsr l_860b ; $85ed  20 0b 86
    lda #$ff ; $85f0  a9 ff
    sta $24 ; $85f2  85 24
    bne l_8605 ; $85f4  d0 0f
l_85f6:
    lda $23 ; $85f6  a5 23
l_85f8:
    cmp #$8d ; $85f8  c9 8d
    bne l_8602 ; $85fa  d0 06
    jsr l_865c ; $85fc  20 5c 86
    jmp l_8605 ; $85ff  4c 05 86
l_8602:
    jsr l_860b ; $8602  20 0b 86
l_8605:
    pla ; $8605  68
    tay ; $8606  a8
    pla ; $8607  68
    tax ; $8608  aa
    pla ; $8609  68
    rts ; $860a  60
l_860b:
    and #$7f ; $860b  29 7f
    asl ; $860d  0a
    asl ; $860e  0a
    rol $13 ; $860f  26 13
    asl ; $8611  0a
    rol $13 ; $8612  26 13
    clc ; $8614  18
    adc #$00 ; $8615  69 00
    sta $863e ; $8617  8d 3e 86
    lda $13 ; $861a  a5 13
    and #$03 ; $861c  29 03
    adc #$cd ; $861e  69 cd
    sta $863f ; $8620  8d 3f 86
    ldx $22 ; $8623  a6 22
    lda $20 ; $8625  a5 20
    asl ; $8627  0a
    asl ; $8628  0a
    tay ; $8629  a8
l_862a:
    clc ; $862a  18
    lda $d180,x ; $862b  bd 80 d1
    adc $d310,y ; $862e  79 10 d3
    sta $8643 ; $8631  8d 43 86
    lda $d248,x ; $8634  bd 48 d2
    adc $d3b0,y ; $8637  79 b0 d3
    sta $8644 ; $863a  8d 44 86

; RAM IRQ vector high / unpatched operand placeholder
    lda $ffff ; $863d  ad ff ff
    eor $24 ; $8640  45 24

; RAM IRQ vector high / unpatched operand placeholder
    sta $ffff ; $8642  8d ff ff
    inx ; $8645  e8
    inc $863e ; $8646  ee 3e 86
    lda $863e ; $8649  ad 3e 86
    and #$07 ; $864c  29 07
    bne l_862a ; $864e  d0 da
    inc $20 ; $8650  e6 20
    rts ; $8652  60
l_8653:
    rts ; $8653  60
    !byte $bd,$5a,$86,$85,$24,$60,$ff,$00 ; $8654 retained data / unresolved code
l_865c:
    lda #$12 ; $865c  a9 12
    sta $20 ; $865e  85 20
    lda $22 ; $8660  a5 22
    clc ; $8662  18
    adc #$08 ; $8663  69 08
    cmp #$55 ; $8665  c9 55
    bcc l_8670 ; $8667  90 07
    beq l_8670 ; $8669  f0 05
    jsr l_86b2 ; $866b  20 b2 86
    lda $22 ; $866e  a5 22
l_8670:
    sta $22 ; $8670  85 22
    rts ; $8672  60
l_8673:
    jsr l_8c10 ; $8673  20 10 8c
    ldx #$05 ; $8676  a2 05
l_8678:
    ldy #$48 ; $8678  a0 48
    clc ; $867a  18
    lda $d180,x ; $867b  bd 80 d1
    adc $d310,y ; $867e  79 10 d3
    sta $12 ; $8681  85 12
    lda $d248,x ; $8683  bd 48 d2
    adc $d3b0,y ; $8686  79 b0 d3
    sta $13 ; $8689  85 13
    ldy #$98 ; $868b  a0 98
l_868d:
    lda #$ff ; $868d  a9 ff
    sta ($12),y ; $868f  91 12
    tya ; $8691  98
    sec ; $8692  38
    sbc #$08 ; $8693  e9 08
    tay ; $8695  a8
    cpy #$f8 ; $8696  c0 f8
    bne l_868d ; $8698  d0 f3
    inx ; $869a  e8
    cpx #$5e ; $869b  e0 5e
    bcc l_8678 ; $869d  90 d9
    lda #$12 ; $869f  a9 12
    sta $20 ; $86a1  85 20
    sta $8563 ; $86a3  8d 63 85
    lda #$05 ; $86a6  a9 05
    sta $22 ; $86a8  85 22
    lda #$00 ; $86aa  a9 00
    sta $853a ; $86ac  8d 3a 85
    sta $2d ; $86af  85 2d
    rts ; $86b1  60
l_86b2:
    ldx #$00 ; $86b2  a2 00
l_86b4:
    lda $8cae,x ; $86b4  bd ae 8c
    sta $8cad,x ; $86b7  9d ad 8c
    lda $8cb9,x ; $86ba  bd b9 8c
    sta $8cb8,x ; $86bd  9d b8 8c
    inx ; $86c0  e8
    cpx #$0a ; $86c1  e0 0a
    bcc l_86b4 ; $86c3  90 ef
    lda #$00 ; $86c5  a9 00
    sta $8cb7 ; $86c7  8d b7 8c
    sta $8cc2 ; $86ca  8d c2 8c
    ldx $32 ; $86cd  a6 32
    lda $874e,x ; $86cf  bd 4e 87
    lsr ; $86d2  4a
    lsr ; $86d3  4a
    lsr ; $86d4  4a
    lsr ; $86d5  4a
    sta $86fa ; $86d6  8d fa 86
    lda $874e,x ; $86d9  bd 4e 87
    and #$0f ; $86dc  29 0f
    sta $874d ; $86de  8d 4d 87
l_86e1:
    ldx #$05 ; $86e1  a2 05
l_86e3:
    ldy #$48 ; $86e3  a0 48
    clc ; $86e5  18
    lda $d180,x ; $86e6  bd 80 d1
    adc $d310,y ; $86e9  79 10 d3
    sta $12 ; $86ec  85 12
    lda $d248,x ; $86ee  bd 48 d2
    adc $d3b0,y ; $86f1  79 b0 d3
    sta $13 ; $86f4  85 13
    txa ; $86f6  8a
    pha ; $86f7  48
    clc ; $86f8  18
    adc #$00 ; $86f9  69 00
    cmp #$5e ; $86fb  c9 5e
    bcc l_8701 ; $86fd  90 02
    lda #$5d ; $86ff  a9 5d
l_8701:
    tax ; $8701  aa
    clc ; $8702  18
    lda $d180,x ; $8703  bd 80 d1
    adc $d310,y ; $8706  79 10 d3
    sta $15 ; $8709  85 15
    lda $d248,x ; $870b  bd 48 d2
    adc $d3b0,y ; $870e  79 b0 d3
    sta $16 ; $8711  85 16
    ldy #$98 ; $8713  a0 98
l_8715:
    lda ($15),y ; $8715  b1 15
    sta ($12),y ; $8717  91 12
    tya ; $8719  98
    sec ; $871a  38
    sbc #$08 ; $871b  e9 08
    tay ; $871d  a8
    cpy #$f8 ; $871e  c0 f8
    bne l_8715 ; $8720  d0 f3
    pla ; $8722  68
    tax ; $8723  aa
    inx ; $8724  e8
    cpx #$5e ; $8725  e0 5e
    bcc l_86e3 ; $8727  90 ba
    lda $874d ; $8729  ad 4d 87
    sec ; $872c  38
    sbc #$01 ; $872d  e9 01
    beq l_8735 ; $872f  f0 04
    cmp #$04 ; $8731  c9 04
    bne l_873b ; $8733  d0 06
l_8735:
    jsr l_77fb ; $8735  20 fb 77
    jsr l_83aa ; $8738  20 aa 83
l_873b:
    ldx $32 ; $873b  a6 32
    ldy $875e,x ; $873d  bc 5e 87
    cpy #$01 ; $8740  c0 01
    beq l_8747 ; $8742  f0 03
    jsr l_8f52 ; $8744  20 52 8f
l_8747:
    dec $874d ; $8747  ce 4d 87
    bne l_86e1 ; $874a  d0 95
    rts ; $874c  60
    !byte $00,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$24,$24,$42,$42,$81 ; $874d retained data / unresolved code
    !byte $81,$13,$12,$11,$10,$0e,$0d,$08,$05,$03,$01,$03,$01,$03,$01,$03 ; $875d retained data / unresolved code
    !byte $01,$00,$48,$a2,$00,$bc,$73,$e9,$c8,$b1,$36,$f0,$05,$e8,$e0,$0c ; $876d retained data / unresolved code
    !byte $90,$f3,$8e,$6e,$87,$68,$09,$20,$e0,$00,$d0,$2c,$a2,$00,$a0,$29 ; $877d retained data / unresolved code
    !byte $b1,$36,$c9,$0d,$90,$01,$e8,$86,$4f,$20,$0a,$74,$ef,$7f,$a7,$ae ; $878d retained data / unresolved code
    !byte $fa,$47,$fa,$f9,$53,$d4,$bf,$a8,$60,$f2,$2c,$d3,$90,$45,$13,$04 ; $879d retained data / unresolved code
    !byte $cd,$84,$ef,$80,$00,$4c,$0d,$6f,$a2,$6e,$a0,$87,$8d,$18,$89,$86 ; $87ad retained data / unresolved code
    !byte $27,$84,$28,$4a,$b0,$06,$a9,$00,$85,$25,$85,$26,$20,$8c,$84,$a9 ; $87bd retained data / unresolved code
    !byte $96,$20,$c5,$85,$a2,$13,$a9,$9e,$20,$c5,$85,$ca,$d0,$fa,$a9,$8d ; $87cd retained data / unresolved code
    !byte $20,$c5,$85,$a2,$00,$8a,$48,$e0,$04,$d0,$07,$a5,$22,$38,$e9,$04 ; $87dd retained data / unresolved code
    !byte $85,$22,$a9,$98,$20,$c5,$85,$a9,$24,$85,$20,$68,$48,$aa,$bd,$d6 ; $87ed retained data / unresolved code
    !byte $8a,$20,$c5,$85,$bd,$de,$8a,$20,$c5,$85,$a9,$8d,$20,$c5,$85,$68 ; $87fd retained data / unresolved code
    !byte $aa,$e8,$e0,$08,$90,$cf,$a9,$97,$20,$c5,$85,$a2,$13,$a9,$9f,$20 ; $880d retained data / unresolved code
    !byte $c5,$85,$ca,$d0,$fa,$a9,$17,$85,$22,$a9,$00,$48,$18,$65,$26,$20 ; $881d retained data / unresolved code
    !byte $f9,$88,$18,$a5,$22,$69,$08,$85,$22,$68,$18,$69,$01,$c9,$07,$90 ; $882d retained data / unresolved code
    !byte $ea,$a9,$4d,$85,$22,$20,$0f,$8b,$46,$a0,$8a,$5c,$88,$8b,$8c,$88 ; $883d retained data / unresolved code
    !byte $95,$5c,$88,$88,$8c,$88,$9b,$de,$88,$8d,$b3,$88,$00,$b0,$88,$a5 ; $884d retained data / unresolved code
    !byte $25,$18,$69,$01,$b0,$1f,$a0,$00,$d1,$27,$b0,$19,$85,$25,$38,$e5 ; $885d retained data / unresolved code
    !byte $26,$c9,$07,$90,$05,$e6,$26,$20,$60,$8a,$a9,$00,$8d,$0c,$fe,$a6 ; $886d retained data / unresolved code
    !byte $25,$ca,$4c,$a8,$88,$a2,$8c,$a0,$06,$20,$f6,$92,$4c,$3e,$88,$a5 ; $887d retained data / unresolved code
    !byte $25,$f0,$f2,$c6,$25,$a5,$25,$38,$e5,$26,$c9,$07,$90,$05,$c6,$26 ; $888d retained data / unresolved code
    !byte $20,$9b,$8a,$a9,$00,$8d,$0c,$fe,$a6,$25,$e8,$a4,$25,$20,$e5,$88 ; $889d retained data / unresolved code
    !byte $4c,$3e,$88,$4c,$82,$88,$a5,$25,$20,$c6,$88,$a0,$0f,$b1,$44,$99 ; $88ad retained data / unresolved code
    !byte $00,$02,$88,$10,$f8,$a5,$25,$18,$60,$e6,$27,$0a,$90,$02,$e6,$28 ; $88bd retained data / unresolved code
    !byte $a8,$b1,$27,$85,$44,$c8,$b1,$27,$85,$45,$90,$02,$c6,$28,$c6,$27 ; $88cd retained data / unresolved code
    !byte $60,$a9,$ff,$8d,$00,$02,$38,$60,$98,$48,$20,$ec,$88,$68,$aa,$8a ; $88dd retained data / unresolved code
    !byte $38,$e5,$26,$0a,$0a,$0a,$18,$69,$17,$85,$22,$8a,$a2,$13,$86,$20 ; $88ed retained data / unresolved code
    !byte $a2,$24,$8e,$2e,$8a,$a0,$00,$d1,$27,$90,$03,$4c,$03,$8a,$c5,$25 ; $88fd retained data / unresolved code
    !byte $d0,$02,$84,$24,$48,$20,$c6,$88,$68,$a8,$a9,$00,$4a,$4a,$4a,$4a ; $890d retained data / unresolved code
    !byte $29,$0e,$aa,$bd,$2d,$89,$85,$12,$bd,$2e,$89,$85,$13,$6c,$12,$00 ; $891d retained data / unresolved code
    !byte $f0,$89,$3d,$89,$ea,$89,$03,$8a,$03,$8a,$03,$8a,$03,$8a,$b7,$89 ; $892d retained data / unresolved code
    !byte $b9,$73,$e9,$48,$20,$20,$85,$a9,$00,$8d,$63,$85,$68,$48,$a8,$b1 ; $893d retained data / unresolved code
    !byte $36,$85,$55,$10,$06,$29,$03,$d0,$02,$a9,$03,$29,$03,$aa,$bd,$0c ; $894d retained data / unresolved code
    !byte $cd,$20,$8e,$84,$68,$a8,$c8,$b1,$36,$85,$53,$98,$48,$20,$e6,$6f ; $895d retained data / unresolved code
    !byte $68,$a8,$c8,$b1,$36,$c9,$ff,$f0,$1e,$c9,$01,$d0,$0b,$a6,$53,$bd ; $896d retained data / unresolved code
    !byte $73,$e2,$c9,$01,$f0,$11,$a9,$01,$85,$9b,$a9,$00,$85,$9c,$20,$0a ; $897d retained data / unresolved code
    !byte $74,$0f,$f6,$00,$20,$85,$72,$ac,$3a,$85,$a2,$00,$bd,$3b,$85,$20 ; $898d retained data / unresolved code
    !byte $c5,$85,$a5,$20,$cd,$2e,$8a,$b0,$04,$e8,$88,$d0,$ef,$a9,$00,$8d ; $899d retained data / unresolved code
    !byte $3a,$85,$a5,$20,$8d,$63,$85,$4c,$03,$8a,$a9,$1e,$8d,$2e,$8a,$20 ; $89ad retained data / unresolved code
    !byte $33,$8a,$f0,$03,$a9,$a0,$2c,$a9,$de,$85,$12,$8a,$48,$a5,$12,$20 ; $89bd retained data / unresolved code
    !byte $c5,$85,$20,$0b,$8a,$68,$a8,$be,$03,$a8,$20,$a8,$71,$20,$20,$85 ; $89cd retained data / unresolved code
    !byte $20,$56,$72,$20,$20,$85,$a9,$24,$8d,$2e,$8a,$d0,$19,$20,$0b,$8a ; $89dd retained data / unresolved code
    !byte $4c,$03,$8a,$a0,$00,$b1,$44,$c9,$ff,$f0,$0b,$20,$c5,$85,$c8,$a5 ; $89ed retained data / unresolved code
    !byte $20,$cd,$2e,$8a,$90,$ef,$20,$2d,$8a,$a9,$ff,$85,$24,$60,$a6,$44 ; $89fd retained data / unresolved code
    !byte $a4,$45,$8e,$03,$75,$8c,$04,$75,$20,$65,$74,$20,$6f,$74,$f0,$10 ; $8a0d retained data / unresolved code
    !byte $20,$c5,$85,$c8,$a5,$20,$cd,$2e,$8a,$90,$f0,$a5,$20,$8d,$32,$8a ; $8a1d retained data / unresolved code
    !byte $a9,$00,$4c,$4d,$fd,$00,$a9,$00,$85,$12,$a9,$ba,$85,$13,$a0,$00 ; $8a2d retained data / unresolved code
    !byte $a2,$00,$e8,$b1,$12,$c8,$c5,$44,$d0,$06,$b1,$12,$c5,$45,$f0,$07 ; $8a3d retained data / unresolved code
    !byte $c8,$d0,$ef,$e6,$13,$d0,$eb,$a0,$29,$b1,$36,$a8,$bd,$73,$e6,$39 ; $8a4d retained data / unresolved code
    !byte $87,$d9,$60,$a2,$17,$a0,$4c,$18,$bd,$88,$d1,$79,$10,$d3,$85,$15 ; $8a5d retained data / unresolved code
    !byte $bd,$50,$d2,$79,$b0,$d3,$85,$16,$18,$bd,$80,$d1,$79,$10,$d3,$85 ; $8a6d retained data / unresolved code
    !byte $12,$bd,$48,$d2,$79,$b0,$d3,$85,$13,$a0,$80,$b1,$15,$91,$12,$98 ; $8a7d retained data / unresolved code
    !byte $38,$e9,$08,$a8,$c0,$f8,$d0,$f3,$e8,$e0,$46,$90,$c8,$60,$a2,$46 ; $8a8d retained data / unresolved code
    !byte $a0,$4c,$18,$bd,$88,$d1,$79,$10,$d3,$85,$12,$bd,$50,$d2,$79,$b0 ; $8a9d retained data / unresolved code
    !byte $d3,$85,$13,$18,$bd,$80,$d1,$79,$10,$d3,$85,$15,$bd,$48,$d2,$79 ; $8aad retained data / unresolved code
    !byte $b0,$d3,$85,$16,$a0,$80,$b1,$15,$91,$12,$98,$38,$e9,$08,$a8,$c0 ; $8abd retained data / unresolved code
    !byte $f8,$d0,$f3,$ca,$e0,$17,$b0,$c8,$60,$99,$91,$95,$95,$95,$95,$93 ; $8acd retained data / unresolved code
    !byte $9b,$9a,$92,$9d,$9d,$9d,$9d,$94,$9c ; $8add retained data / unresolved code
l_8ae6:
    ldx #$03 ; $8ae6  a2 03
l_8ae8:
    sta $0428,x ; $8ae8  9d 28 04
    sta $0450,x ; $8aeb  9d 50 04
    sta $0478,x ; $8aee  9d 78 04
    sta $04a0,x ; $8af1  9d a0 04
    sta $04c8,x ; $8af4  9d c8 04
    sta $04f0,x ; $8af7  9d f0 04
    sta $0518,x ; $8afa  9d 18 05
    sta $0540,x ; $8afd  9d 40 05
    sta $0568,x ; $8b00  9d 68 05
    sta $0590,x ; $8b03  9d 90 05
    sta $05b8,x ; $8b06  9d b8 05
    inx ; $8b09  e8
    cpx #$0e ; $8b0a  e0 0e
    bcc l_8ae8 ; $8b0c  90 da
    rts ; $8b0e  60

; Inline input convention: two flag bytes follow the JSR.
; Patch the caller return address to skip them; store flags at $8cc3/$8cc4.
; Poll keyboard and selection handling; uppercase conversion depends on flags.
read_input_with_inline_flags:
    jsr l_8520 ; $8b0f  20 20 85
    tsx ; $8b12  ba
    lda $0101,x ; $8b13  bd 01 01
    sta $12 ; $8b16  85 12
    clc ; $8b18  18
    adc #$02 ; $8b19  69 02
    sta $0101,x ; $8b1b  9d 01 01
    lda $0102,x ; $8b1e  bd 02 01
    sta $13 ; $8b21  85 13
    adc #$00 ; $8b23  69 00
    sta $0102,x ; $8b25  9d 02 01
    ldy #$01 ; $8b28  a0 01
    lda ($12),y ; $8b2a  b1 12
    sta $8cc3 ; $8b2c  8d c3 8c
    iny ; $8b2f  c8
    lda ($12),y ; $8b30  b1 12
    sta $8cc4 ; $8b32  8d c4 8c
    bit $8cc3 ; $8b35  2c c3 8c
    bpl l_8b3d ; $8b38  10 03
    jsr l_81c9 ; $8b3a  20 c9 81
l_8b3d:
    bit $8cc4 ; $8b3d  2c c4 8c
    bpl l_8b6c ; $8b40  10 2a
l_8b42:
    lda $22 ; $8b42  a5 22
    cmp #$55 ; $8b44  c9 55
    bcs l_8b4e ; $8b46  b0 06
    jsr $848c ; $8b48  20 8c 84
    jmp l_8b42 ; $8b4b  4c 42 8b
l_8b4e:
    lda $8cc4 ; $8b4e  ad c4 8c
    and #$03 ; $8b51  29 03
    asl ; $8b53  0a
    tax ; $8b54  aa
    lda $8bd1,x ; $8b55  bd d1 8b
    ldy $8bd2,x ; $8b58  bc d2 8b
    tax ; $8b5b  aa
    jsr print_packed_text_xy ; $8b5c  20 19 74
    jsr l_8520 ; $8b5f  20 20 85
    lda #$9b ; $8b62  a9 9b
    sta $8cc2 ; $8b64  8d c2 8c
    lda #$ff ; $8b67  a9 ff
    sta $8cb7 ; $8b69  8d b7 8c
l_8b6c:
    lda $034e ; $8b6c  ad 4e 03
    and #$40 ; $8b6f  29 40
    bne l_8b76 ; $8b71  d0 03
    jsr $ff59 ; $8b73  20 59 ff
l_8b76:
    jsr $ff30 ; $8b76  20 30 ff
    bpl l_8bb1 ; $8b79  10 36
    pha ; $8b7b  48
    lda $8cc4 ; $8b7c  ad c4 8c
    and #$10 ; $8b7f  29 10
    cmp #$10 ; $8b81  c9 10
    pla ; $8b83  68
    bcs l_8b90 ; $8b84  b0 0a
    cmp #$e1 ; $8b86  c9 e1
    bcc l_8b90 ; $8b88  90 06
    cmp #$fb ; $8b8a  c9 fb
    bcs l_8b90 ; $8b8c  b0 02
    and #$df ; $8b8e  29 df
l_8b90:
    cmp #$ce ; $8b90  c9 ce
    bne l_8ba4 ; $8b92  d0 10
    pha ; $8b94  48
    lda $8cc3 ; $8b95  ad c3 8c
    and #$08 ; $8b98  29 08
    cmp #$08 ; $8b9a  c9 08
    pla ; $8b9c  68
    bcc l_8ba4 ; $8b9d  90 05
    jsr l_8cc7 ; $8b9f  20 c7 8c
    lda #$90 ; $8ba2  a9 90
l_8ba4:
    bit $8cc4 ; $8ba4  2c c4 8c
    bpl $8bb7 ; $8ba7  10 0e
    cmp #$a0 ; $8ba9  c9 a0
    bne $8bb7 ; $8bab  d0 0a
    lda #$9b ; $8bad  a9 9b
    bne $8bb7 ; $8baf  d0 06
l_8bb1:
    jsr l_8e16 ; $8bb1  20 16 8e
    bcc l_8b6c ; $8bb4  90 b6
    !byte $24,$18 ; $8bb6 retained data / unresolved code
    clv ; $8bb8  b8
    bvc l_8bbf ; $8bb9  50 04
    bit l_8bcb ; $8bbb  2c cb 8b
    clc ; $8bbe  18
l_8bbf:
    php ; $8bbf  08
    pha ; $8bc0  48
    jsr l_8c1e ; $8bc1  20 1e 8c
    bcs l_8bcc ; $8bc4  b0 06
    jsr l_8c10 ; $8bc6  20 10 8c
    pla ; $8bc9  68
    plp ; $8bca  28
l_8bcb:
    rts ; $8bcb  60
l_8bcc:
    pla ; $8bcc  68
    plp ; $8bcd  28
    jmp l_8b6c ; $8bce  4c 6c 8b
    !byte $d9,$8b,$e6,$8b,$f5,$8b,$02,$8c,$08,$42,$1f,$f3,$ff,$7f,$e8,$66 ; $8bd1 retained data / unresolved code
    !byte $f0,$88,$6f,$8c,$c0,$08,$43,$fe,$7f,$ef,$fd,$0c,$de,$12,$3d,$d3 ; $8be1 retained data / unresolved code
    !byte $53,$a8,$60,$00,$08,$7d,$08,$9a,$52,$08,$9d,$70,$ac,$d7,$c6,$30 ; $8bf1 retained data / unresolved code
    !byte $00,$08,$42,$1f,$f3,$ff,$7f,$e8,$66,$f0,$c4,$d1,$7b,$18,$00 ; $8c01 retained data / unresolved code
l_8c10:
    ldx #$0a ; $8c10  a2 0a
    lda #$00 ; $8c12  a9 00
l_8c14:
    sta $8cad,x ; $8c14  9d ad 8c
    sta $8cb8,x ; $8c17  9d b8 8c
    dex ; $8c1a  ca
    bpl l_8c14 ; $8c1b  10 f7
    rts ; $8c1d  60
l_8c1e:
    lda $8cc3 ; $8c1e  ad c3 8c
    and #$40 ; $8c21  29 40
    beq l_8c3b ; $8c23  f0 16
    tsx ; $8c25  ba
    lda $0105,x ; $8c26  bd 05 01
    sta $15 ; $8c29  85 15
    lda $0106,x ; $8c2b  bd 06 01
    sta $16 ; $8c2e  85 16
    ldy #$01 ; $8c30  a0 01
l_8c32:
    lda ($15),y ; $8c32  b1 15
    beq l_8c9a ; $8c34  f0 64
    cmp #$ff ; $8c36  c9 ff
    bne l_8c3d ; $8c38  d0 03
    rts ; $8c3a  60
l_8c3b:
    clc ; $8c3b  18
    rts ; $8c3c  60
l_8c3d:
    cmp #$02 ; $8c3d  c9 02
    bne l_8c49 ; $8c3f  d0 08
    lda $0104,x ; $8c41  bd 04 01
    lsr ; $8c44  4a
    bcs l_8c9a ; $8c45  b0 53
    bcc l_8c95 ; $8c47  90 4c
l_8c49:
    cmp #$01 ; $8c49  c9 01
    bne l_8c69 ; $8c4b  d0 1c
    lda $0103,x ; $8c4d  bd 03 01
    cmp #$b1 ; $8c50  c9 b1
    bcc l_8c95 ; $8c52  90 41
    cmp #$b8 ; $8c54  c9 b8
    bcs l_8c95 ; $8c56  b0 3d
    sec ; $8c58  38
    sbc #$b1 ; $8c59  e9 b1
    jsr party_member_pointer_a ; $8c5b  20 e2 91
    ldx #$00 ; $8c5e  a2 00
    lda ($12,x) ; $8c60  a1 12
    tsx ; $8c62  ba
    ora #$00 ; $8c63  09 00
    bne l_8c9a ; $8c65  d0 33
    beq l_8c95 ; $8c67  f0 2c
l_8c69:
    cmp #$80 ; $8c69  c9 80
    beq l_8c95 ; $8c6b  f0 28
    cmp #$81 ; $8c6d  c9 81
    bne l_8c74 ; $8c6f  d0 03
    iny ; $8c71  c8
    bne l_8c95 ; $8c72  d0 21
l_8c74:
    ora #$00 ; $8c74  09 00
    bmi l_8c8e ; $8c76  30 16
    iny ; $8c78  c8
    ora #$80 ; $8c79  09 80
    sec ; $8c7b  38
    sbc #$01 ; $8c7c  e9 01
    cmp $0103,x ; $8c7e  dd 03 01
    bcs l_8c95 ; $8c81  b0 12
    lda ($15),y ; $8c83  b1 15
    ora #$80 ; $8c85  09 80
    cmp $0103,x ; $8c87  dd 03 01
    bcc l_8c95 ; $8c8a  90 09
    bcs l_8c9a ; $8c8c  b0 0c
l_8c8e:
    lda ($15),y ; $8c8e  b1 15
    cmp $0103,x ; $8c90  dd 03 01
    beq l_8c9a ; $8c93  f0 05
l_8c95:
    iny ; $8c95  c8
    iny ; $8c96  c8
    iny ; $8c97  c8
    bne l_8c32 ; $8c98  d0 98
l_8c9a:
    iny ; $8c9a  c8
    sec ; $8c9b  38
    lda ($15),y ; $8c9c  b1 15
    sbc #$01 ; $8c9e  e9 01
    sta $0105,x ; $8ca0  9d 05 01
    iny ; $8ca3  c8
    lda ($15),y ; $8ca4  b1 15
    sbc #$00 ; $8ca6  e9 00
    sta $0106,x ; $8ca8  9d 06 01
    clc ; $8cab  18
    rts ; $8cac  60
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $8cad retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$00,$00,$00,$18,$60 ; $8cbd retained data / unresolved code
l_8cc7:
    lda $8cc3 ; $8cc7  ad c3 8c
    sta $8d7a ; $8cca  8d 7a 8d
    lda $8cc4 ; $8ccd  ad c4 8c
    sta $8d7b ; $8cd0  8d 7b 8d
    jsr l_8d98 ; $8cd3  20 98 8d
    cmp #$02 ; $8cd6  c9 02
    bcs l_8cdb ; $8cd8  b0 01
    rts ; $8cda  60
l_8cdb:
    clc ; $8cdb  18
    adc #$b1 ; $8cdc  69 b1
    sta $51 ; $8cde  85 51
    jsr print_inline_packed_text ; $8ce0  20 07 74

; Packed text: 'New Order:<$0d><$0d>1>'
    !byte $f3,$8d,$60,$f9,$f1,$29,$a3,$fe,$fb,$df,$8b,$fe,$80 ; $8ce3 retained data / unresolved code
    lda #$00 ; $8cf0  a9 00
    sta $50 ; $8cf2  85 50
l_8cf4:
    jsr read_input_with_inline_flags ; $8cf4  20 0f 8b

; Inline input flags: $12, $00
    !byte $12,$00 ; $8cf7 retained data / unresolved code
    cmp #$9b ; $8cf9  c9 9b
    beq l_8d7c ; $8cfb  f0 7f
    cmp #$b1 ; $8cfd  c9 b1
    bcc l_8cf4 ; $8cff  90 f3
    cmp $51 ; $8d01  c5 51
    bcs l_8cf4 ; $8d03  b0 ef
    sec ; $8d05  38
    sbc #$b1 ; $8d06  e9 b1
    asl ; $8d08  0a
    tax ; $8d09  aa
    lda $d530,x ; $8d0a  bd 30 d5
    sta $36 ; $8d0d  85 36
    lda $d531,x ; $8d0f  bd 31 d5
    sta $37 ; $8d12  85 37
    ldy #$78 ; $8d14  a0 78
    lda ($36),y ; $8d16  b1 36
    beq l_8cf4 ; $8d18  f0 da
l_8d1a:
    lda $50 ; $8d1a  a5 50
    jsr party_member_pointer_a ; $8d1c  20 e2 91
    ldy #$78 ; $8d1f  a0 78
    lda #$00 ; $8d21  a9 00
    sta ($36),y ; $8d23  91 36
    dey ; $8d25  88
l_8d26:
    lda ($36),y ; $8d26  b1 36
    sta ($12),y ; $8d28  91 12
    dey ; $8d2a  88
    bpl l_8d26 ; $8d2b  10 f9
    ldx $12 ; $8d2d  a6 12
    ldy $13 ; $8d2f  a4 13
    jsr print_unpacked_text_xy ; $8d31  20 1c 75
    jsr $848c ; $8d34  20 8c 84
    dec $52 ; $8d37  c6 52
    beq l_8d68 ; $8d39  f0 2d
    inc $50 ; $8d3b  e6 50
    lda $50 ; $8d3d  a5 50
    clc ; $8d3f  18
    adc #$b1 ; $8d40  69 b1
    jsr output_text_character ; $8d42  20 8e 84
    lda #$be ; $8d45  a9 be
    jsr output_text_character ; $8d47  20 8e 84
    lda $52 ; $8d4a  a5 52
    cmp #$02 ; $8d4c  c9 02
    bcs l_8cf4 ; $8d4e  b0 a4
    ldx #$00 ; $8d50  a2 00
l_8d52:
    lda $d530,x ; $8d52  bd 30 d5
    sta $36 ; $8d55  85 36
    lda $d531,x ; $8d57  bd 31 d5
    sta $37 ; $8d5a  85 37
    ldy #$78 ; $8d5c  a0 78
    lda ($36),y ; $8d5e  b1 36
    bne l_8d1a ; $8d60  d0 b8
    inx ; $8d62  e8
    inx ; $8d63  e8
    cpx #$0e ; $8d64  e0 0e
    bne l_8d52 ; $8d66  d0 ea
l_8d68:
    jsr l_8673 ; $8d68  20 73 86
    lda $8d7a ; $8d6b  ad 7a 8d
    sta $8cc3 ; $8d6e  8d c3 8c
    lda $8d7b ; $8d71  ad 7b 8d
    sta $8cc4 ; $8d74  8d c4 8c
    jmp $fb81 ; $8d77  4c 81 fb
    !byte $00,$00 ; $8d7a retained data / unresolved code
l_8d7c:
    jsr for_each_party_member_inline ; $8d7c  20 16 6f

; Inline party callback: $8d84
    !byte $84,$8d ; $8d7f retained data / unresolved code
    jmp l_8d68 ; $8d81  4c 68 8d
    lda $d530,x ; $8d84  bd 30 d5
    sta $38 ; $8d87  85 38
    lda $d531,x ; $8d89  bd 31 d5
    sta $39 ; $8d8c  85 39
    ldy #$77 ; $8d8e  a0 77
l_8d90:
    lda ($38),y ; $8d90  b1 38
    sta ($12),y ; $8d92  91 12
    dey ; $8d94  88
    bpl l_8d90 ; $8d95  10 f9
    rts ; $8d97  60
l_8d98:
    lda $96 ; $8d98  a5 96
    beq l_8da2 ; $8d9a  f0 06
    jsr l_9238 ; $8d9c  20 38 92
    jsr l_92c7 ; $8d9f  20 c7 92
l_8da2:
    lda #$00 ; $8da2  a9 00
    sta $52 ; $8da4  85 52
    jsr for_each_party_member_inline ; $8da6  20 16 6f

; Inline party callback: $8dac
    !byte $ac,$8d ; $8da9 retained data / unresolved code
    rts ; $8dab  60
    lda $d530,x ; $8dac  bd 30 d5
    sta $38 ; $8daf  85 38
    lda $d531,x ; $8db1  bd 31 d5
    sta $39 ; $8db4  85 39
    ldy #$78 ; $8db6  a0 78
    lda #$ff ; $8db8  a9 ff
    sta ($38),y ; $8dba  91 38
    dey ; $8dbc  88
l_8dbd:
    lda ($12),y ; $8dbd  b1 12
    sta ($38),y ; $8dbf  91 38
    dey ; $8dc1  88
    bpl l_8dbd ; $8dc2  10 f9
    iny ; $8dc4  c8
    lda ($12),y ; $8dc5  b1 12
    beq l_8dcb ; $8dc7  f0 02
    inc $52 ; $8dc9  e6 52
l_8dcb:
    lda $52 ; $8dcb  a5 52
    rts ; $8dcd  60
    stx $a5 ; $8dce  86 a5
    sty $a6 ; $8dd0  84 a6
    tya ; $8dd2  98
    cmp $a5 ; $8dd3  c5 a5
    beq l_8df7 ; $8dd5  f0 20
    sec ; $8dd7  38
    sbc $a5 ; $8dd8  e5 a5
    ldx #$00 ; $8dda  a2 00
l_8ddc:
    cmp $cd68,x ; $8ddc  dd 68 cd
    bcc l_8de6 ; $8ddf  90 05
    beq l_8de6 ; $8de1  f0 03
    inx ; $8de3  e8
    bne l_8ddc ; $8de4  d0 f6
l_8de6:
    jsr $ff3e ; $8de6  20 3e ff
    and $cd68,x ; $8de9  3d 68 cd
    clc ; $8dec  18
    adc $a5 ; $8ded  65 a5
    bcs l_8de6 ; $8def  b0 f5
    cmp $a6 ; $8df1  c5 a6
    bcc l_8df7 ; $8df3  90 02
    bne l_8de6 ; $8df5  d0 ef
l_8df7:
    rts ; $8df7  60
    !byte $a6,$0b,$bd,$08,$cd,$85,$0b,$60,$a6,$0b,$f0,$09,$ca,$f0,$09,$ca ; $8df8 retained data / unresolved code
    !byte $f0,$09,$c6,$0a,$60,$e6,$09,$60,$e6,$0a,$60,$c6,$09,$60 ; $8e08 retained data / unresolved code
l_8e16:
    jsr l_83af ; $8e16  20 af 83
    jsr l_8653 ; $8e19  20 53 86
    jsr l_77fb ; $8e1c  20 fb 77
    jsr l_92f6 ; $8e1f  20 f6 92
    lda $2f ; $8e22  a5 2f
    bne l_8e42 ; $8e24  d0 1c
    jsr for_each_party_member_inline ; $8e26  20 16 6f

; Inline party callback: $8e2e
    !byte $2e,$8e ; $8e29 retained data / unresolved code
    jmp l_7936 ; $8e2b  4c 36 79
    beq l_8e41 ; $8e2e  f0 11
    lda #$04 ; $8e30  a9 04
    ldy #$2d ; $8e32  a0 2d
    ora ($12),y ; $8e34  11 12
    sta ($12),y ; $8e36  91 12
    ldy #$21 ; $8e38  a0 21
    lda #$00 ; $8e3a  a9 00
    sta ($12),y ; $8e3c  91 12
    iny ; $8e3e  c8
    sta ($12),y ; $8e3f  91 12
l_8e41:
    rts ; $8e41  60
l_8e42:
    lda $8cc3 ; $8e42  ad c3 8c
    and #$02 ; $8e45  29 02
    beq l_8ec0 ; $8e47  f0 77
    lda $6e ; $8e49  a5 6e
    bne l_8ec0 ; $8e4b  d0 73
    lda #$3c ; $8e4d  a9 3c
    sta $6e ; $8e4f  85 6e
    ldx $30 ; $8e51  a6 30
    dex ; $8e53  ca
    bne l_8e58 ; $8e54  d0 02
    ldx #$1f ; $8e56  a2 1f
l_8e58:
    stx $30 ; $8e58  86 30
    txa ; $8e5a  8a
    lsr ; $8e5b  4a
    lsr ; $8e5c  4a
    lsr ; $8e5d  4a
    lsr ; $8e5e  4a
    and #$01 ; $8e5f  29 01
    eor #$01 ; $8e61  49 01
    sta $31 ; $8e63  85 31
    lda $68 ; $8e65  a5 68
    jsr l_8f2a ; $8e67  20 2a 8f
    sta $68 ; $8e6a  85 68
    bcc l_8e89 ; $8e6c  90 1b
    jsr $7836 ; $8e6e  20 36 78
    lda #$00 ; $8e71  a9 00
    sta $6d ; $8e73  85 6d
    sta $71 ; $8e75  85 71
    lda $08 ; $8e77  a5 08
    beq l_8e89 ; $8e79  f0 0e
    lda $5e ; $8e7b  a5 5e
    bne l_8e89 ; $8e7d  d0 0a
    lda $1050 ; $8e7f  ad 50 10
    and #$20 ; $8e82  29 20
    bne l_8e89 ; $8e84  d0 03
    jsr l_81ca ; $8e86  20 ca 81
l_8e89:
    lda $64 ; $8e89  a5 64
    jsr l_8f2a ; $8e8b  20 2a 8f
    sta $64 ; $8e8e  85 64
    bcc l_8e95 ; $8e90  90 03
    jsr $785a ; $8e92  20 5a 78
l_8e95:
    lda $65 ; $8e95  a5 65
    jsr l_8f2a ; $8e97  20 2a 8f
    sta $65 ; $8e9a  85 65
    bcc l_8ea1 ; $8e9c  90 03
    jsr l_78dc ; $8e9e  20 dc 78
l_8ea1:
    lda $66 ; $8ea1  a5 66
    jsr l_8f2a ; $8ea3  20 2a 8f
    sta $66 ; $8ea6  85 66
    bcc l_8ead ; $8ea8  90 03
    jsr $7883 ; $8eaa  20 83 78
l_8ead:
    lda $67 ; $8ead  a5 67
    jsr l_8f2a ; $8eaf  20 2a 8f
    sta $67 ; $8eb2  85 67
    bcc l_8ec0 ; $8eb4  90 0a
    jsr l_78a0 ; $8eb6  20 a0 78
    lda #$00 ; $8eb9  a9 00
    sta $75 ; $8ebb  85 75
    jsr $fb81 ; $8ebd  20 81 fb
l_8ec0:
    lda $8cc4 ; $8ec0  ad c4 8c
    and #$20 ; $8ec3  29 20
    beq l_8f04 ; $8ec5  f0 3d
    lda $5e ; $8ec7  a5 5e
    bne l_8f04 ; $8ec9  d0 39
    lda $6f ; $8ecb  a5 6f
    bne l_8ef9 ; $8ecd  d0 2a
    lda #$0f ; $8ecf  a9 0f
    sta $6f ; $8ed1  85 6f
    jsr l_900c ; $8ed3  20 0c 90
    lda $72 ; $8ed6  a5 72
    bne l_8ee2 ; $8ed8  d0 08
    lda $08 ; $8eda  a5 08
    bne l_8ee5 ; $8edc  d0 07
    lda $31 ; $8ede  a5 31
    bne l_8ee5 ; $8ee0  d0 03
l_8ee2:
    jsr l_907f ; $8ee2  20 7f 90
l_8ee5:
    lda $96 ; $8ee5  a5 96
    beq l_8ef2 ; $8ee7  f0 09
    lda $9a ; $8ee9  a5 9a
    cmp #$04 ; $8eeb  c9 04
    bne l_8ef2 ; $8eed  d0 03
    jsr l_907f ; $8eef  20 7f 90
l_8ef2:
    lda $34 ; $8ef2  a5 34
    beq l_8ef9 ; $8ef4  f0 03
    jsr $9082 ; $8ef6  20 82 90
l_8ef9:
    lda $70 ; $8ef9  a5 70
    bne l_8f04 ; $8efb  d0 07
    lda #$10 ; $8efd  a9 10
    sta $70 ; $8eff  85 70
    jsr l_90bf ; $8f01  20 bf 90
l_8f04:
    lda $8cc3 ; $8f04  ad c3 8c
    lsr ; $8f07  4a
    bcc l_8f28 ; $8f08  90 1e
    lda $fe06 ; $8f0a  ad 06 fe
    bne l_8f28 ; $8f0d  d0 19
    lda #$1e ; $8f0f  a9 1e
    sta $fe06 ; $8f11  8d 06 fe
    lda $96 ; $8f14  a5 96
    beq l_8f1e ; $8f16  f0 06
    lda $9a ; $8f18  a5 9a
    cmp #$01 ; $8f1a  c9 01
    beq l_8f28 ; $8f1c  f0 0a
l_8f1e:
    jsr $ff3e ; $8f1e  20 3e ff
    bne l_8f28 ; $8f21  d0 05
    jsr $ff3e ; $8f23  20 3e ff
    lsr ; $8f26  4a
    rts ; $8f27  60
l_8f28:
    clc ; $8f28  18
    rts ; $8f29  60
l_8f2a:
    beq l_8f28 ; $8f2a  f0 fc
    cmp #$ff ; $8f2c  c9 ff
    beq l_8f28 ; $8f2e  f0 f8
    sec ; $8f30  38
    sbc #$01 ; $8f31  e9 01
    bne l_8f28 ; $8f33  d0 f3
    sec ; $8f35  38
    rts ; $8f36  60
    !byte $20,$0f,$8b,$52,$a0,$01,$45,$8f,$9b,$43,$8f,$ff,$38,$60,$38,$e9 ; $8f37 retained data / unresolved code
    !byte $b1,$0a,$aa,$bc,$22,$d5,$bd,$23,$d5,$18,$60 ; $8f47 retained data / unresolved code
l_8f52:
    ldx #$80 ; $8f52  a2 80
l_8f54:
    dex ; $8f54  ca
    bne l_8f54 ; $8f55  d0 fd
    dey ; $8f57  88
    bne l_8f54 ; $8f58  d0 fa
    rts ; $8f5a  60
    lda #$ff ; $8f5b  a9 ff
    sta $8fa7 ; $8f5d  8d a7 8f
    ldx $32 ; $8f60  a6 32
    lda $8ff4,x ; $8f62  bd f4 8f
    cmp #$01 ; $8f65  c9 01
    beq l_8f84 ; $8f67  f0 1b
    bne l_8f74 ; $8f69  d0 09
l_8f6b:
    ldx #$00 ; $8f6b  a2 00
    stx $8fa7 ; $8f6d  8e a7 8f
    cmp #$01 ; $8f70  c9 01
    beq l_8f84 ; $8f72  f0 10
l_8f74:
    ldy #$8c ; $8f74  a0 8c
    ldx $96 ; $8f76  a6 96
    beq l_8f7e ; $8f78  f0 04
    ldx #$00 ; $8f7a  a2 00
    ldy #$24 ; $8f7c  a0 24
l_8f7e:
    dex ; $8f7e  ca
    bne l_8f7e ; $8f7f  d0 fd
    dey ; $8f81  88
    bne l_8f7e ; $8f82  d0 fa
l_8f84:
    pha ; $8f84  48
    jsr l_92f6 ; $8f85  20 f6 92
    lda $fe07 ; $8f88  ad 07 fe
    jsr l_9004 ; $8f8b  20 04 90
    sta $fe07 ; $8f8e  8d 07 fe
    lda $fe05 ; $8f91  ad 05 fe
    jsr l_9004 ; $8f94  20 04 90
    sta $fe05 ; $8f97  8d 05 fe
    jsr l_83af ; $8f9a  20 af 83
    jsr l_77fb ; $8f9d  20 fb 77
    jsr $ff3b ; $8fa0  20 3b ff
    tax ; $8fa3  aa
    bpl l_8fed ; $8fa4  10 47
    ldy #$00 ; $8fa6  a0 00
    beq l_8fed ; $8fa8  f0 43
    cpx #$9b ; $8faa  e0 9b
    bne l_8fb7 ; $8fac  d0 09
    jsr $ff30 ; $8fae  20 30 ff
    jsr l_9120 ; $8fb1  20 20 91
    jmp l_8fed ; $8fb4  4c ed 8f
l_8fb7:
    cpx #$88 ; $8fb7  e0 88
    beq l_8fd8 ; $8fb9  f0 1d
    cpx #$95 ; $8fbb  e0 95
    bne l_8fed ; $8fbd  d0 2e
    jsr $ff30 ; $8fbf  20 30 ff
    ldx $32 ; $8fc2  a6 32
    cpx #$0f ; $8fc4  e0 0f
    beq l_8fed ; $8fc6  f0 25
    inc $32 ; $8fc8  e6 32
    jsr print_inline_text_without_reset ; $8fca  20 0a 74

; Packed text: '<Faster><$0d><$0d>'
    !byte $ff,$3e,$38,$a5,$33,$47,$fd,$77,$a0 ; $8fcd retained data / unresolved code
    bcc l_8fed ; $8fd6  90 15
l_8fd8:
    jsr $ff30 ; $8fd8  20 30 ff
    ldx $32 ; $8fdb  a6 32
    beq l_8fed ; $8fdd  f0 0e
    dec $32 ; $8fdf  c6 32
    jsr print_inline_text_without_reset ; $8fe1  20 0a 74

; Packed text: '<Slower><$0d><$0d>'
    !byte $ff,$3e,$93,$1f,$63,$47,$fd,$77,$a0 ; $8fe4 retained data / unresolved code
l_8fed:
    pla ; $8fed  68
    sec ; $8fee  38
    sbc #$01 ; $8fef  e9 01
    bne l_8f74 ; $8ff1  d0 81
    rts ; $8ff3  60
    !byte $18,$14,$10,$0c,$0a,$08,$06,$04,$02,$01,$03,$01,$03,$01,$03,$01 ; $8ff4 retained data / unresolved code
l_9004:
    sec ; $9004  38
    sbc #$03 ; $9005  e9 03
    bcs l_900b ; $9007  b0 02
    lda #$00 ; $9009  a9 00
l_900b:
    rts ; $900b  60
l_900c:
    jsr for_each_party_member_inline ; $900c  20 16 6f

; Inline party callback: $9012
    !byte $12,$90 ; $900f retained data / unresolved code
l_9011:
    rts ; $9011  60
    beq l_9011 ; $9012  f0 fd
    txa ; $9014  8a
    pha ; $9015  48
    lsr ; $9016  4a
    tax ; $9017  aa
    lda #$02 ; $9018  a9 02
    jsr l_6f83 ; $901a  20 83 6f
    bcs l_902f ; $901d  b0 10
    bne l_902f ; $901f  d0 0e
    lda #$25 ; $9021  a9 25
    sta $0329 ; $9023  8d 29 03
    pla ; $9026  68
    pha ; $9027  48
    tax ; $9028  aa
    jsr party_member_pointer_x ; $9029  20 e4 91
    jsr l_908f ; $902c  20 8f 90
l_902f:
    pla ; $902f  68
    pha ; $9030  48
    lsr ; $9031  4a
    tax ; $9032  aa
    lda #$0d ; $9033  a9 0d
    jsr l_6f83 ; $9035  20 83 6f
    bcs l_9053 ; $9038  b0 19
    bne l_9053 ; $903a  d0 17
    lda #$25 ; $903c  a9 25
    sta $0329 ; $903e  8d 29 03
    pla ; $9041  68
    pha ; $9042  48
    tax ; $9043  aa
    jsr party_member_pointer_x ; $9044  20 e4 91
    jsr l_908f ; $9047  20 8f 90
    pla ; $904a  68
    pha ; $904b  48
    tax ; $904c  aa
    jsr party_member_pointer_x ; $904d  20 e4 91
    jsr l_908f ; $9050  20 8f 90
l_9053:
    pla ; $9053  68
    pha ; $9054  48
    lsr ; $9055  4a
    tax ; $9056  aa
    lda $96 ; $9057  a5 96
    beq l_9065 ; $9059  f0 0a
    cpx $99 ; $905b  e4 99
    bne l_9065 ; $905d  d0 06
    lda $9a ; $905f  a5 9a
    cmp #$03 ; $9061  c9 03
    beq l_906e ; $9063  f0 09
l_9065:
    lda #$01 ; $9065  a9 01
    jsr l_6f83 ; $9067  20 83 6f
    bcs l_907c ; $906a  b0 10
    bne l_907c ; $906c  d0 0e
l_906e:
    lda #$21 ; $906e  a9 21
    sta $0329 ; $9070  8d 29 03
    pla ; $9073  68
    pha ; $9074  48
    tax ; $9075  aa
    jsr party_member_pointer_x ; $9076  20 e4 91
    jsr l_908f ; $9079  20 8f 90
l_907c:
    pla ; $907c  68
    tax ; $907d  aa
    rts ; $907e  60
l_907f:
    lda #$25 ; $907f  a9 25
    !byte $2c,$a9,$21 ; $9081 retained data / unresolved code
    sta $0329 ; $9084  8d 29 03
    jsr for_each_party_member_inline ; $9087  20 16 6f

; Inline party callback: $908d
    !byte $8d,$90 ; $908a retained data / unresolved code
l_908c:
    rts ; $908c  60
    beq l_908c ; $908d  f0 fd
l_908f:
    ldy #$2d ; $908f  a0 2d
    lda ($12),y ; $9091  b1 12
    and #$0c ; $9093  29 0c
    bne l_90be ; $9095  d0 27
    ldy $0329 ; $9097  ac 29 03
    lda ($12),y ; $909a  b1 12
    iny ; $909c  c8
    iny ; $909d  c8
    cmp ($12),y ; $909e  d1 12
    dey ; $90a0  88
    lda ($12),y ; $90a1  b1 12
    iny ; $90a3  c8
    iny ; $90a4  c8
    sbc ($12),y ; $90a5  f1 12
    bcs l_90be ; $90a7  b0 15
    ldy $0329 ; $90a9  ac 29 03
    lda ($12),y ; $90ac  b1 12
    adc #$01 ; $90ae  69 01
    sta ($12),y ; $90b0  91 12
    iny ; $90b2  c8
    lda ($12),y ; $90b3  b1 12
    adc #$00 ; $90b5  69 00
    sta ($12),y ; $90b7  91 12
    txa ; $90b9  8a
    lsr ; $90ba  4a
    jmp $fb93 ; $90bb  4c 93 fb
l_90be:
    rts ; $90be  60
l_90bf:
    lda #$00 ; $90bf  a9 00
    sta $b2 ; $90c1  85 b2
    jsr for_each_party_member_inline ; $90c3  20 16 6f

; Inline party callback: $90d5
    !byte $d5,$90 ; $90c6 retained data / unresolved code
    lda $b2 ; $90c8  a5 b2
    beq l_90d4 ; $90ca  f0 08
    jsr l_6f5e ; $90cc  20 5e 6f
    bcc l_90d4 ; $90cf  90 03
    jmp l_7936 ; $90d1  4c 36 79
l_90d4:
    rts ; $90d4  60
    beq l_9117 ; $90d5  f0 40
    ldy #$2d ; $90d7  a0 2d
    lda ($12),y ; $90d9  b1 12
    and #$01 ; $90db  29 01
    beq l_9117 ; $90dd  f0 38
    txa ; $90df  8a
    pha ; $90e0  48
    ldx $29 ; $90e1  a6 29
    ldy #$21 ; $90e3  a0 21
    sec ; $90e5  38
    lda ($12),y ; $90e6  b1 12
    sbc $9118,x ; $90e8  fd 18 91
    sta ($12),y ; $90eb  91 12
    tax ; $90ed  aa
    iny ; $90ee  c8
    lda ($12),y ; $90ef  b1 12
    sbc #$00 ; $90f1  e9 00
    sta ($12),y ; $90f3  91 12
    bcc l_90fc ; $90f5  90 05
    bne l_910f ; $90f7  d0 16
    txa ; $90f9  8a
    bne l_910f ; $90fa  d0 13
l_90fc:
    lda #$00 ; $90fc  a9 00
    sta ($12),y ; $90fe  91 12
    dey ; $9100  88
    sta ($12),y ; $9101  91 12
    ldy #$2d ; $9103  a0 2d
    lda ($12),y ; $9105  b1 12
    and #$fe ; $9107  29 fe
    ora #$04 ; $9109  09 04
    sta ($12),y ; $910b  91 12
    inc $b2 ; $910d  e6 b2
l_910f:
    pla ; $910f  68
    pha ; $9110  48
    lsr ; $9111  4a
    jsr $fb93 ; $9112  20 93 fb
    pla ; $9115  68
    tax ; $9116  aa
l_9117:
    rts ; $9117  60
    !byte $01,$02,$04,$06,$08,$0a,$10,$14 ; $9118 retained data / unresolved code
l_9120:
    jsr print_inline_text_without_reset ; $9120  20 0a 74

; Packed text: '(Pausing)<$0d><$0d><$0d>'
    !byte $fe,$5e,$80,$a9,$25,$39,$1f,$cf,$bd,$e8,$00 ; $9123 retained data / unresolved code
    bit $034e ; $912e  2c 4e 03
    bvc l_9137 ; $9131  50 04
    lda #$81 ; $9133  a9 81
    sta $ba ; $9135  85 ba
l_9137:
    jsr $ff30 ; $9137  20 30 ff
    bmi l_9149 ; $913a  30 0d
    jsr $fe08 ; $913c  20 08 fe
    jsr l_81c9 ; $913f  20 c9 81
    jsr $fe08 ; $9142  20 08 fe
    cmp #$80 ; $9145  c9 80
    bne l_9137 ; $9147  d0 ee
l_9149:
    bit $034e ; $9149  2c 4e 03
    bvc l_9156 ; $914c  50 08
    lda #$82 ; $914e  a9 82
    sta $ba ; $9150  85 ba
l_9152:
    bit $ba ; $9152  24 ba
    bmi l_9152 ; $9154  30 fc
l_9156:
    rts ; $9156  60
    !byte $a9,$00,$85,$a3,$85,$a4,$a5,$9f,$85,$a9,$a5,$a0,$85,$aa,$a9,$00 ; $9157 retained data / unresolved code
    !byte $85,$9b,$85,$9c,$85,$9d,$85,$9e,$a0,$10,$06,$9b,$26,$9c,$26,$9d ; $9167 retained data / unresolved code
    !byte $26,$9e,$06,$a9,$26,$aa,$90,$19,$18,$a5,$a1,$65,$9b,$85,$9b,$a5 ; $9177 retained data / unresolved code
    !byte $a2,$65,$9c,$85,$9c,$a5,$a3,$65,$9d,$85,$9d,$a5,$a4,$65,$9e,$85 ; $9187 retained data / unresolved code
    !byte $9e,$88,$d0,$d6,$60 ; $9197 retained data / unresolved code
    lda #$00 ; $919c  a9 00
    sta $a5 ; $919e  85 a5
    sta $a6 ; $91a0  85 a6
    sta $a7 ; $91a2  85 a7
    sta $a8 ; $91a4  85 a8
    ldy #$20 ; $91a6  a0 20
l_91a8:
    asl $9b ; $91a8  06 9b
    rol $9c ; $91aa  26 9c
    rol $9d ; $91ac  26 9d
    rol $9e ; $91ae  26 9e
    rol $a5 ; $91b0  26 a5
    rol $a6 ; $91b2  26 a6
    rol $a7 ; $91b4  26 a7
    rol $a8 ; $91b6  26 a8
    sec ; $91b8  38
    lda $a5 ; $91b9  a5 a5
    sbc $9f ; $91bb  e5 9f
    sta $a9 ; $91bd  85 a9
    lda $a6 ; $91bf  a5 a6
    sbc $a0 ; $91c1  e5 a0
    sta $aa ; $91c3  85 aa
    lda $a7 ; $91c5  a5 a7
    sbc #$00 ; $91c7  e9 00
    tax ; $91c9  aa
    lda $a8 ; $91ca  a5 a8
    sbc #$00 ; $91cc  e9 00
    bcc l_91de ; $91ce  90 0e
    sta $a8 ; $91d0  85 a8
    stx $a7 ; $91d2  86 a7
    lda $aa ; $91d4  a5 aa
    sta $a6 ; $91d6  85 a6
    lda $a9 ; $91d8  a5 a9
    sta $a5 ; $91da  85 a5
    inc $9b ; $91dc  e6 9b
l_91de:
    dey ; $91de  88
    bne l_91a8 ; $91df  d0 c7
    rts ; $91e1  60

; Party slot in A is doubled before falling into party_member_pointer_x.
party_member_pointer_a:
    asl ; $91e2  0a
    tax ; $91e3  aa

; X indexes low/high pointer pairs. Read pointer from $d522/$d523
; into $12/$13; the caller uses this as the party-record address.
party_member_pointer_x:
    lda $d522,x ; $91e4  bd 22 d5
    sta $12 ; $91e7  85 12
    lda $d523,x ; $91e9  bd 23 d5
    sta $13 ; $91ec  85 13
    rts ; $91ee  60
    tay ; $91ef  a8
    lda $bd ; $91f0  a5 bd
    pha ; $91f2  48
    tya ; $91f3  98
    jsr l_9244 ; $91f4  20 44 92
    clc ; $91f7  18
    adc #$08 ; $91f8  69 08
    sta $ba ; $91fa  85 ba
    pha ; $91fc  48
l_91fd:
    jsr l_83af ; $91fd  20 af 83
    jsr l_8653 ; $9200  20 53 86
    jsr l_77fb ; $9203  20 fb 77
    jsr l_92f6 ; $9206  20 f6 92
    pla ; $9209  68
    pha ; $920a  48
    eor $ba ; $920b  45 ba
    asl ; $920d  0a
    beq l_91fd ; $920e  f0 ed
    pla ; $9210  68
    pla ; $9211  68
    sta $bd ; $9212  85 bd
    lda #$00 ; $9214  a9 00
    sta $96 ; $9216  85 96
    rts ; $9218  60
    !byte $20,$44,$92,$48,$20,$38,$92,$68,$aa,$20,$3a,$92,$a9,$ff,$85,$96 ; $9219 retained data / unresolved code
l_9229:
    rts ; $9229  60
l_922a:
    cmp $99 ; $922a  c5 99
    bne l_9229 ; $922c  d0 fb
    lda $96 ; $922e  a5 96
    beq l_9229 ; $9230  f0 f7
    jsr l_9238 ; $9232  20 38 92
    jmp l_92c7 ; $9235  4c c7 92
l_9238:
    ldx #$80 ; $9238  a2 80
    stx $ba ; $923a  86 ba
l_923c:
    jsr l_92f6 ; $923c  20 f6 92
    ldx $ba ; $923f  a6 ba
    bmi l_923c ; $9241  30 f9
    rts ; $9243  60
l_9244:
    pha ; $9244  48
    jsr l_6fbb ; $9245  20 bb 6f
    bcs l_9255 ; $9248  b0 0b
    txa ; $924a  8a
    ldx #$0e ; $924b  a2 0e
l_924d:
    cmp $9261,x ; $924d  dd 61 92
    beq l_9257 ; $9250  f0 05
    dex ; $9252  ca
    bpl l_924d ; $9253  10 f8
l_9255:
    ldx #$00 ; $9255  a2 00
l_9257:
    lda $9270,x ; $9257  bd 70 92
    sta $bd ; $925a  85 bd
    pla ; $925c  68
    clc ; $925d  18
    adc #$84 ; $925e  69 84
    rts ; $9260  60
    !byte $29,$46,$5e,$82,$c2,$d1,$14,$d2,$de,$1e,$47,$5b,$ba,$f8,$5d,$00 ; $9261 retained data / unresolved code
    !byte $00,$00,$00,$00,$00,$01,$01,$01,$02,$02,$02,$02,$02,$03,$20,$bc ; $9271 retained data / unresolved code
    !byte $78,$a5,$99,$20,$e2,$91,$a6,$29,$a5,$9a,$c9,$02,$f0,$16,$c9,$06 ; $9281 retained data / unresolved code
    !byte $f0,$12,$c9,$05,$f0,$01,$60,$a9,$05,$85,$6d,$a9,$ff,$85,$68,$85 ; $9291 retained data / unresolved code
    !byte $71,$4c,$2c,$78,$a0,$1e,$b1,$12,$d0,$0c,$88,$b1,$12,$4a,$4a,$18 ; $92a1 retained data / unresolved code
    !byte $69,$01,$c9,$0f,$90,$02,$a9,$0f,$85,$78,$4c,$81,$fb ; $92b1 retained data / unresolved code
l_92be:
    lda $96 ; $92be  a5 96
    beq l_92c6 ; $92c0  f0 04
    lda $ba ; $92c2  a5 ba
    beq l_92c7 ; $92c4  f0 01
l_92c6:
    rts ; $92c6  60
l_92c7:
    jsr l_78ba ; $92c7  20 ba 78
    lda #$00 ; $92ca  a9 00
    sta $98 ; $92cc  85 98
    sta $96 ; $92ce  85 96
    ldx $9a ; $92d0  a6 9a
    cpx #$05 ; $92d2  e0 05
    beq l_92df ; $92d4  f0 09
    cpx #$02 ; $92d6  e0 02
    beq l_92f1 ; $92d8  f0 17
    cpx #$06 ; $92da  e0 06
    beq l_92f1 ; $92dc  f0 13
l_92de:
    rts ; $92de  60
l_92df:
    sta $68 ; $92df  85 68
    sta $6d ; $92e1  85 6d
    jsr $7836 ; $92e3  20 36 78
    lda $08 ; $92e6  a5 08
    beq l_92de ; $92e8  f0 f4
    lda $5e ; $92ea  a5 5e
    bne l_92de ; $92ec  d0 f0
    jmp l_81ca ; $92ee  4c ca 81
l_92f1:
    sta $78 ; $92f1  85 78
    jmp $fb81 ; $92f3  4c 81 fb
l_92f6:
    rts ; $92f6  60
