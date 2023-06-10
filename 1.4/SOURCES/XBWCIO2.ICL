
* GETBYTE
L128D       ldx L0E48
L128DV      equ L128D-1
            cpx #$16
            beq L1283
            lda #$00
            dta b(op_BIT_abs)
* PUBYTE
L1296       lda #$FF
L1296V      equ L1296-1
            sta L0048
            and #$0C
            eor #$07
            cmp ICCOMZ
            bne L12DF
L12A2       lda #$00
            cmp #$E4
            bcc L12DF
            ldy ICBLHZ
            bne L12B1
            iny
            cpy ICBLLZ
            bcs L12DF

L12B1       jsr MOVE_CALL
  dta h(MC_mov+ICBALZ),l(ICBALZ),h(MC_2+L1426+1),l(L1426+1)
  dta h(MC_mov+ICBLLZ),l(ICBLLZ),h(MC_2+L0E51),l(L0E51)
  dta h(MC_jsrE+L136A),l(L136A)

            php

            jsr MOVE_CALL
  dta h(MC_mov+L1426+1),l(L1426+1),h(MC_2+ICBALZ),l(ICBALZ)
  dta h(MC_movE+L0E51),l(L0E51),h(MC_2+ICBLLZ),l(ICBLLZ)

            plp
            bmi L12EE

            jsr SBC_1
            dta a(ICBALZ)

            lda (ICBALZ-1,X)
            inc ICBLLZ
L12D6       sta L10DB+1
L12D9       jsr L14BF
            beq L12F0
            rts

L12DF       jsr MOVE_CALL
  dta h(MC_mov+L12D6+1),l(L12D6+1),h(MC_2+L1426+1),l(L1426+1)
  dta b(MC_cpyE+2,L0E08-DAT_BUF,L0E51-DAT_BUF)

L12E9       jsr L136A
L12E9V      equ L12E9-1
            bpl L12D9
L12EE       lda #$8B
L12F0       eor #$03
            sta L10BA+1
            rts

L12F6       jsr L0F4C
            iny
            iny
            sty L0E3F
            cpy L0045
            bne L1345
            jsr L0F4C
            ldy #$00
            lda (L0043),Y
            tax
            iny
            ora (L0043),Y
            bne L1335
            jsr L1B6C
            ldy #$02
L1314       lda L0E3B,Y
            sta (L0043),Y
            iny
            cpy #$04
            bcc L1314
            jsr L0F4C
            ldy #$01
L1323       lda L0DE5,Y
            sta (L0043),Y
            dey
            bpl L1323

            jsr MOVE_CALL
  dta h(MC_jsr+L1C2B),l(L1C2B)
  dta b(MC_cpyE+2,L0DE5-DAT_BUF,L0E3D-DAT_BUF)

            beq L133D
L1335       lda (L0043),Y
            sta L0E3E
            stx L0E3D
L133D       jsr L0F4C
            ldy #$04
            sty L0E3F
L1345       lda (L0043),Y
            sta L0E3A
            iny
            lda (L0043),Y
            sta L0E3B
            ora L0E3A
            rts

L1354       sec
            ldx #$FD
L1357       lda L0E45-$FD,X
            sbc L0E40-$FD,X
            inx
            bne L1357
            bcs L1369

            jsr MOVE_CALL
  dta b(MC_cpyE+3,L0E40-DAT_BUF,L0E45-DAT_BUF)

            clc
L1369       rts

L136A       lda L0E48
            ldy #$83
            bit L0048
            bpl L1376
            lsr @
            ldy #$87
L1376       and #$04
            bne L13BF
            jmp RET_ERRY

* CLOSE
L137D       lda L0E48
L137DV      equ L137D-1
            cmp #$16
            bne L1387
            lsr L0E53
L1387       and #$08
            beq L1369

            jsr MOVE_CALL
  dta b(MC_cpy+3,L0E45-DAT_BUF,L0E16-DAT_BUF)
  dta b(MC_cpy+2,L0E49-DAT_BUF,L0E43-DAT_BUF)
  dta h(MC_jsr+L150C),l(L150C)
  dta h(MC_jsr+L139E),l(L139E)
  dta b(MC_cpyE+3,L0E16-DAT_BUF,L0E24-DAT_BUF)

L139B       lda #$FF
            dta b(op_BIT_abs)
L139E       lda #$00
            pha

            jsr MOVE_CALL
  dta b(MC_cpy+2,L0E4B-DAT_BUF,L0DEE-DAT_BUF)
  dta b(MC_cpy+1,L0E00-DAT_BUF,L0DF0-DAT_BUF)
  dta h(MC_jsrE+L143E),l(L143E)

            pla
            dta b(op_BIT_abs)
L13AE       lda #$00
            dta b(op_BIT_abs)
L13B1       lda #$FF
            sta L0048

            jsr MOVE_CALL
  dta h(MC_mov+L11DB+1),l(L11DB+1),h(MC_2+L1426+1),l(L1426+1)
  dta b(MC_cpyE+2,L0E06-DAT_BUF,L0E51-DAT_BUF)

L13BF       lda L0045
            sec
            sbc L0E3C
            bne L13C9
            lda #$FF
L13C9       sta L1488+1
            lda L0E52
            bne L13D9
            lda L0E51
            beq L13F5
            jsr L14F5
L13D9       jsr L14BF
            beq L13F4
            jsr L14F5
            lda L0E3A
            ora L0E3B
            bne L140E
            lda L0E48
            and #$08
            bne L13F6
L13F0       jsr RET_ERRS
            dta b($A6)
L13F4       dex
L13F5       rts

L13F6       jsr MOVE_CALL
  dta h(MC_jsr+L1B6C),l(L1B6C)
  dta b(MC_cpy+2,L0DE5-DAT_BUF,L0E3A-DAT_BUF)
  dta h(MC_jsrE+L0F4C),l(L0F4C)

            lda L0DE5
            sta (L0043),y
            iny
            lda L0DE5+1
            sta (L0043),Y
            jsr L1C2B
L140E       ldx L0E3A
L1411       lda L0E3B

            jsr MOVE_CALL
  dta h(MC_jsr+L1BE9),l(L1BE9)
  dta h(MC_movE+L1426+1),l(L1426+1),h(MC_2+L1481+1),l(L1481+1)

            ldy L0E3C
            bit L0048
            bmi L1481
L1424       lda (L0043),Y
L1426       sta $FFFF,X
            iny
            inx
            cpx L1488+1
            bne L1424
            beq L148F

* POINT
L1432       ldy #$FD
L1432V      equ L1432-1
L1434       lda IOCB0+ICAX3,X
            sta L0DEE-$FD,Y
            inx
            iny
            bne L1434
L143E       lda L0DF0
            bmi L13F0

            jsr MOVE_CALL
  dta b(MC_CPY+1,L0E03-DAT_BUF,L0E3F-DAT_BUF)
  dta b(MC_CPY+2,L0E43-DAT_BUF,L0E3D-DAT_BUF)
  dta b(MC_CPY+3,L0DEE-DAT_BUF,L0E40-DAT_BUF)
  dta h(MC_jsrE+L1354),l(L1354)

            bcs L145A
            lda L0E48
            and #$08
            beq L13F0
L145A       lda L0DEE
            ldx L0DEF
            ldy L0DF0
            jsr L14FD
            sta L0E3C
            stx L0DEE
            sty L0DEF

L146F       jsr L12F6
            lda L0DEE
            ora L0DEF
            beq L14D9
            jsr SBC_1
            dta a(L0DEE)
            bcs L146F

L1481       lda $FFFF,X
            sta (L0043),Y
            iny
            inx
L1488       cpx #$00
            bne L1481
            jsr L1C2B
L148F       lda L1488+1

            jsr SBC_A
            dta a(L0E51)

            jsr ADC_L
            dta a(L1426+1)

            jsr ADC_L
            dta a(L0E40)

            bcc L14A6
            inc L0E42
L14A6       jsr L1354
L14A9       lda L0E3C
            clc
            adc L1488+1
            cmp L0045
            bne L14B9
            jsr L12F6
            lda #$00
L14B9       sta L0E3C
            jmp L13BF
L14BF       ldx #$FD
            sec
L14C2       lda L0D48,X
            sbc L0D43,X
            sta L0DEE-$FD,X
            inx
            bne L14C2
            bit L0048
            bmi L14D7
            ora L0DEF
            beq L14F1
L14D7       lda #$FF
L14D9       rts

CLR_TXT_BUF jsr INC_PC
            sta L1283+1
            asl @
            lsr @
            tax
            lda #$9B
            tay
L14E6       sta TXT_BUF,X
            lda #$20
            dex
            bne L14E6
            stx L1277+1
L14F1       lda L0DEE
            rts

L14F5       cmp L1488+1
            bcs L14D9
            sta L1488+1
L14FD       bit L0045
            bpl L150B
            asl @
            pha
            txa
            rol @
            tax
            tya
            rol @
            tay
            pla
            lsr @
L150B       rts

L150C       lda #$14
            dta b(op_BIT_abs)
L150F       lda #$0C
L1511       sta L0E48
            pha

            jsr MOVE_CALL
  dta b(MC_cpy+3,L0E00-DAT_BUF,L0DEE-DAT_BUF)
  dta h(MC_jsrE+L143E),l(L143E)

            pla
            cmp #$10
            bcc L152D

            jsr MOVE_CALL
  dta b(MC_cpy+1,L0E06-DAT_BUF,L0E45-DAT_BUF)
  dta h(MC_jsr+L13AE),l(L13AE)
  dta b(MC_cpyE+3,L0E24-DAT_BUF,L0E45-DAT_BUF)

L152D       rts

L152E       jsr MOVE_CALL
  dta b(MC_cpy+11,L0E0B-DAT_BUF,L0E27-DAT_BUF)
  dta b(MC_cpy+3,L0E00-DAT_BUF,L0E24-DAT_BUF)
  dta h(MC_movE+DATER),l(DATER),h(MC_6+L0E32),l(L0E32)

            bit TDOVER
            bpl L1547

            jsr MOVE_CALL
  dta h(MC_movE+ODATER),l(ODATER),h(MC_6+L0E32),l(L0E32)

L1547       lda L0049
            sta L0E48
            and #$20
            ora #$08
            sta L0E21
            rts

L1554       bit L0E53
            bmi L15C4
            lda #$16
            sta L0049

            jsr MOVE_CALL
  dta h(MC_jsr+L1600),l(L1600)
  dta b(MC_cpyE+11,L0E0B-DAT_BUF,L0D92-DAT_BUF)

            stx L1283+1
            lda ICAX2Z
            sta L11BD+1
            bpl L1585

            jsr CLR_TXT_BUF
            dta b($2A)

            sty L0DC5

            jsr MOVE_CALL
  dta b(MC_cpy+8,TXT_VOLU-DAT_BUF,L0D9D-DAT_BUF)
  dta b(MC_cpy+8,L0E63-DAT_BUF,L0DA9-DAT_BUF)
  dta b(MC_cpy+11,TXT_DIRY-DAT_BUF,L0DB1-DAT_BUF)
  dta b(MC_cpyE+8,L0E27-DAT_BUF,L0DBD-DAT_BUF)

L1585       sec
            ror L0E53
            rts

* MD
L158A       lda #$28
L158AV      equ L158A-1
            ldx #$09
            bne L15A0
* SAVE
L1590       lda ICAX1Z
L1590V      equ L1590-1
            and #$F0
            ora #$04
            dta b(op_BIT_abs)
L1597       lda $2A
L1597V      equ L1597-1
            and #$3F
            dta b(op_BIT_abs)
L159C       lda #$14
L159E       ldx #op_AND_abs
L15A0       stx L1684
            cmp #$06
            beq L1554
            cmp #$20
            bcc L15AD
            and #$EF
L15AD       sta L0049
            and #$0F
            lsr @
            bcc L15B8
            cmp #$04
            bne L15BB
L15B8       lsr @
L15B9       bcc L1600

L15BB       ldy #$A8
            dta b(op_BIT_abs)
L15BE       ldy #$A3
            dta b(op_BIT_abs)
L15C1       ldy #$A9
            dta b(op_BIT_abs)
L15C4       ldy #$A1
            jmp RET_ERRY

L15C9       ldx #$0A
L15CB       lda L0E0B,X
            cmp #'?'
            beq L15BE
            dex
            bpl L15CB
            jmp (GETTDV)

L15D8       lda #$00
            bpl ERR_170

            jsr MOVE_CALL
  dta b(MC_cpy+11,L0E0B-DAT_BUF,L0E16-DAT_BUF)
  dta b(MC_cpy+11,L0DF4-DAT_BUF,L0E0B-DAT_BUF)
  dta b(MC_cpy+2,L0E56-DAT_BUF,L0E43-DAT_BUF)
  dta h(MC_jsr+L150C),l(L150C)
  dta h(MC_jsrE+L1DC5),l(L1DC5)

            bne ERR_170

            jsr MOVE_CALL
  dta b(MC_cpy+11,L0E16-DAT_BUF,L0E0B-DAT_BUF)
  dta b(MC_cpy+2,L0E22-DAT_BUF,L0E43-DAT_BUF)
  dta h(MC_jsr+L150C),l(L150C)
  dta h(MC_jsrE+L1DC2),l(L1DC2)

            bne ERR_170
            jmp L16B2

L1600       jsr L1AAE
            php
            pla
            ror @
            ror @
            ror L15D8+1
            lda L0049
            and #$10
            bne L167D
            jsr L150C
            jsr L1DBF
            beq L167F
L1618       lda L0049
            cmp #$04
            beq L15D8
            and #$08
            bne L162C

ERR_170     jsr RET_ERRS
            dta b($AA)

L1626       jsr L15C9
            jsr L1D4D
L162C       bit L0E4C
            bmi L15C1

            jsr MOVE_CALL
  dta h(MC_jsr+L15C9),l(L15C9)
  dta h(MC_jsr+L152E),l(L152E)
  dta h(MC_jsr+L1B6C),l(L1B6C)
  dta b(MC_cpy+2,L0DE5-DAT_BUF,L0E22-DAT_BUF)
  dta b(MC_cpy+1,L0E05-DAT_BUF,L0E48-DAT_BUF)
  dta h(MC_jsr+L139B),l(L139B)
  dta b(MC_cpy+2,L0E4B-DAT_BUF,L0DE7-DAT_BUF)
  dta b(MC_cpy+2,L0E00-DAT_BUF,L0E4B-DAT_BUF)
  dta h(MC_jsr+L139E),l(L139E)
  dta b(MC_cpy+3,L0E45-DAT_BUF,L0E24-DAT_BUF)
  dta h(MC_jsr+L139B),l(L139B)
  dta b(MC_cpy+2,L0DE7-DAT_BUF,L0E4B-DAT_BUF)
  dta h(MC_jsrE+L139E),l(L139e)

            lda L0049
            and #$20
            beq L1678
L165A       beq L1618

            jsr MOVE_CALL
  dta b(MC_cpy+2,L0E43-DAT_BUF,L0DE7-DAT_BUF)
  dta b(MC_cpy+2,L0E22-DAT_BUF,L0E43-DAT_BUF)
  dta h(MC_jsr+L150F),l(L150F)
  dta h(MC_jsr+L152E),l(L152E)
  dta b(MC_cpy+1,L0E06-DAT_BUF,L0E24-DAT_BUF)
  dta b(MC_cpy+2,L0DE7-DAT_BUF,L0E22-DAT_BUF)
  dta h(MC_jsr+L13B1),l(L13B1)
  dta b(MC_cpy+2,L0E22-DAT_BUF,L0E43-DAT_BUF)
  dta h(MC_jsr+L150C),l(L150C)
  dta h(MC_jsrE+L139E),l(L139E)

L1678       jmp L16B2

L167B       bpl L1626
L167D       bne L16BB
L167F       lda L0049
            eor L0E21
L1684       and #$20
            beq L1696
            lda L0049
            and #$08
            beq L165A
            ldy #$97
            dta b(op_BIT_abs)
L1691       ldy #$A4
            jmp RET_ERRY
L1696       lda L0049
            and #$08
            beq L16B2
            lda L0E21
            and #$21
            lsr @
            bne L16B2
            bcs L1691
            lda L0049
            cmp #$08
            bne L16B2
L16AC       lda #$00
            bpl L167B
            inc L0049

L16B2       jsr MOVE_CALL
  dta b(MC_cpy+2,L0E43-DAT_BUF,L0E49-DAT_BUF)
  dta b(MC_cpyE+5,L0E22-DAT_BUF,L0E43-DAT_BUF)

L16BB       lda L0049
            jsr L1511
            lda L0049
            cmp #$10
            bcc L16DB

            jsr MOVE_CALL
  dta b(MC_cpy+2,L0E43-DAT_BUF,L0E49-DAT_BUF)
  dta b(MC_cpyE+2,L0E00-DAT_BUF,L0E4B-DAT_BUF)

            lda L0049
            and #$07
            bne L16DB

            jsr MOVE_CALL
  dta b(MC_cpyE+3,L0E40-DAT_BUF,L0E45-DAT_BUF)

L16DB       lda L0049
            lsr @
            bcc L16FD

            jsr MOVE_CALL
  dta b(MC_cpyE+3,L0E45-DAT_BUF,L0DEE-DAT_BUF)

            jmp L143E

* NOTE
L16E9       ldy #$00
L16E9V      equ L16E9-1
            dta b(op_BIT_abs)
* GETFLEN
L16EC       ldy #$05
L16ECV      equ L16EC-1
L16EE       lda L0E40,Y
            sta IOCB0+ICAX3,X
            iny
            inx
            txa
            and #$0F
            cmp #$03
            bcc L16EE
L16FD       rts

SET_SIO_BUF stx L1C2B+1
            lda #$FF
            sta L0F49,X
            txa
            clc
            adc >SIO_BUF
            sta L0044
            lda <SIO_BUF
            sta L0043
            rts
