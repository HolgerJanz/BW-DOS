L0F4C       ldx L0E3D
            lda L0E3E
            jsr L1BE9
            ldy L0E3F
            rts

JSR_SIO     lda L0F78-$20,Y
            and #$1F
            pha
            lda L0F66-$20,Y
            pha
            ldx L0046
            rts

* internal CIO code/vectortab
* low
*           REN,   DEL,   OPEN,  PROTECT
L0F66 dta l(L1CD1V,L1CD1V,L1597V,L1CD1V) ; $20-$23
*           UNPROTECT,POINT,NOTE,GETFLEN
      dta l(L1CD1V,L1432V,L16E9V,L16ECV) ; $24-$27
*           LOAD,  SAVE,  MD,    RD
      dta l(L1E22V,L1590V,L158AV,L1D1AV) ; $28-$2B
*           CD,    CLOSE, ???,   CHKDSK
      dta l(L1A95V,L137DV,L12E9V,L1154V) ; $2C-$2F
*           GETBYTE,PUTBYTE
      dta l(L128DV,L1296V)               ; $30-$31
* high
*           REN,         DEL,         OPEN,        PROTECT
L0F78 dta h($E000+L1CD1V,$E000+L1CD1V,$8000+L1597V,$E000+L1CD1V) ; $20-$23
*           UNPROTECT,   POINT,       NOTE,        GETFLEN
      dta h($E000+L1CD1V,$2000+L1432V,$2000+L16E9V,$2000+L16ECV) ; $24-$27
*           LOAD,        SAVE,        MD,          RD
      dta h($2000+L1E22V,$C000+L1590V,$E000+L158AV,$E000+L1D1AV) ; $28-$2B
*           CD,          CLOSE,       ???,   CHKDSK
      dta h($E000+L1A95V,$4000+L137DV,L12E9V,$E000+L1154V) ; $2C-$2F
*           GETBYTE,PUTBYTE
      dta h(L128DV,L1296V) ; $30-$31

* CIO D: routines
SPECIAL     ldy ICCOMZ
SPECIAL_V   equ SPECIAL-1
            sta L10DB+1
            tya
            and #$F0
            cmp #$20
            bne L0F9B
            and L0F78-$20,Y
            bne L0FAF
L0F9B       ldy #$A8 ; not implemented
L0F9D       rts

OPEN        ldy #$22
OPEN_V      equ OPEN-1
            dta b(op_BIT_abs)
CLOSE       ldy #$2D
CLOSE_V     equ CLOSE-1
            dta b(op_BIT_abs)
GETBYTE     ldy #$30
GETBYTE_V   equ GETBYTE-1
            dta b(op_BIT_abs)
PUTBYTE     ldy #$31
PUTBYTE_V   equ PUTBYTE-1
            dta b(op_BIT_abs)
GETSTAT     ldy #$29
GETSTAT_V   equ GETSTAT-1
L0FAC       sta L10DB+1
L0FAF       cld
            stx L0046
            lda #$01
            sta L10BA+1
            cpy #$28
            bne L0FC4
            jsr JSR_SIO
            dta b(op_BIT_abs)
L0FBF       ldy #$A1
L0FC1       jmp L10DB
L0FC4       tsx
            stx RET_ERRY+1
            inx
            inx
            lda STACK,X
            sta L12A2+1
            sty L109B+1
            lda L0F78-$20,Y
            and #$C0
            sta L0FEB+1
            ldx L0046
            jsr L1121
            bne L0FEB
            bit L0FEB+1
            bpl L1000
            ldy #$81
            bne L0FC1
L0FEB       lda #$00
            bpl L1023
            ldx #$FF
            jsr L1121
            bne L0FBF
            lda L0046
            sta L0ED7,Y
            lda ICDNOZ
            sta L0ED8,Y
L1000       sty L10CC+1
            ldx #$EB
L1005       lda L0ED7,Y
            sta L0E38-$EB,X
            iny
            inx
            bne L1005
            ldy #$68
L1011       lda L0E55,Y
            cmp L0E39
            beq L102F
            tya
            sec
            sbc #$1A
            tay
            bcs L1011
            jsr RET_ERRS
            dta b($A0) ; drive number error

L1023       ldy #$85
            lda L109B+1
            cmp #$2D
            bne L0FC1
            jmp L10BA
L102F       ldx #$E6
L1031       lda L0E55-$E6,X
            pha
            lda L0E55,Y
            sta L0E55-$E6,X
            pla
            sta L0E55,Y
            iny
            inx
            bne L1031
            bit L0FEB+1
            bpl L1093
            jsr L1BE5
            ldy #$07
            lda (L0043),Y
            cmp #$80
            bne L105B
            lda #$1F
            tay
            iny
            cmp (L0043),Y
            bcc L105F
L105B       jsr RET_ERRS
            dta b($94)
L105F       ldy #$16
L1061       lda L0E4D,Y
            cmp (L0043),Y
            bne L107D
            iny
            cpy #$1E
            bcc L1061
            ldy #$26
L106F       lda L0E45,Y
            cmp (L0043),Y
            bne L107D
            iny
            cpy #$28
            bcc L106F
            bcs L1093
L107D       lda #$99
            jsr L1131
            iny
            lda (L0043),Y
            ldy L0E39
L1088       sta DSKSECSIZ,Y

            jsr MOVE_CALL
  dta b(MC_cpy+2),l(L0E56-DAT_BUF,L0E6D-DAT_BUF)
  dta h(MC_jsrE+L1114),l(L1114)

L1093       ldy L0E39
            lda DSKSECSIZ,Y
            sta L0045
L109B       ldy #$00
            jsr JSR_SIO
            bit L0FEB+1
            bvc L10AB
            jsr L10E2
            stx L0E38
L10AB       ldy L10CC+1
            ldx #$EB
L10B0       lda L0E38-$EB,X
            sta L0ED7,Y
            iny
            inx
            bne L10B0
L10BA       ldy #$01
            bne L10DB

* Error code on stack
RET_ERRS    jsr INC_PC
            tay
* Error code in Y
RET_ERRY    ldx #$00
            txs
            tya
            pha
            lda L0FEB+1
            beq L10D3
L10CC       ldy #$00
            lda #$FF
            sta L0ED7,Y
L10D3       jsr L10E2
            jsr L1114
            pla
            tay
L10DB       lda #$00
            ldx L0046
            cpy #$00
            rts

L10E2       ldx L0E39
            lda L0E4C,X
            bpl L10FB
            lsr L0E4C,X
            jsr L1BE5
            jsr L1C2B
            inc L0E6B
            lda #$B9
            jsr L1131
L10FB       ldx #$03
L10FD       dex
            bmi L1113
            jsr L110C
            bne L10FD
            bcc L10FD
L1107       jsr SIO_W_BUF
            bpl L10FB
L110C       lda L0F40,X
            eor L0E39
            asl @
L1113       rts

L1114       ldx #$02
L1116       jsr L110C
            bne L111E
            sta L0F40,X
L111E       dex
            bpl L1116
L1121       ldy #$54
L1123       txa
            cmp L0ED7,Y
            beq L1130
            tya
            sec
            sbc #$15
            tay
            bcs L1123
L1130       rts

L1131       sta L1149
            sta L113B
            ldy #$26
L1139       lda (L0043),Y
L113B       sta L0E45,Y
            sta (L0043),Y
            iny
            cpy #$28
            bcc L1139
            ldy #$09
L1147       lda (L0043),Y
L1149       lda L0E4D,Y
            sta (L0043),Y
            iny
            cpy #$1E
            bcc L1147
            rts

* CHKDSK
L1154       jsr MOVE_CALL
L1154V      equ L1154-1
  dta h(MC_movE+ICBLLZ),l(ICBLLZ),h(MC_2+L1185+1),l(L1185+1)

            ldy #$20
            jsr L1182
            ldy #$1F
            jsr L1182
            ldy #$0B
L1167       jsr L1182
            cpy #$0F
            bcc L1167
            ldy #$16
L1170       jsr L1182
            cpy #$1E
            bcc L1170
            ldy #$26
            jsr L1182
            jsr L1182
            lda #$00

            dta b(op_BIT_abs)
L1182       lda (L0043),Y

            iny
L1185       sta $FFFF,X
            inx
            rts

SET_TO_9    ldx #$FD
L118C       lda DECOUT+4
            cmp #$20
            bne L1197
            lda DECOUT+5-$FD,X

            dta b(op_BIT_abs)
L1197       lda #$39

            ora #$30
            sta DECOUT+5-$FD,X
            inx
            bne L118C
            rts

L11A2       jsr CLR_TXT_BUF
            dta b($91)

            jsr MOVE_CALL
  dta h(MC_jsr+SET_TO_9),l(SET_TO_9)
  dta h(MC_mov+DECOUT+5),l(DECOUT+5),h(MC_3+L0D9D),l(L0D9D)
  dta b(MC_cpyE+12,TXT_FREE-DAT_BUF,L0DA1-DAT_BUF)

            beq L1215

L11B4       jsr MOVE_CALL
  dta h(MC_mov+L0E5A),l(L0E5A),h(MC_2+DECIN),l(DECIN)
  dta h(MC_jsrE+CONV_16),l(CONV_16)

L11BD       ldx #$00
            bpl L11A2

            jsr CLR_TXT_BUF
            dta b($94)

            jsr MOVE_CALL
  dta h(MC_mov+DECOUT+2),l(DECOUT+2),h(MC_6+L0D9D),l(L0D9D)
  dta b(MC_cpyE+12,TXT_FREE-DAT_BUF,L0DA4-DAT_BUF)

            beq L1215

L11D1       jsr CLR_TXT_BUF
            dta b($12)

            jsr MOVE_CALL
  dta b(MC_cpyE+11,L0E27-DAT_BUF,L0D9F-DAT_BUF)

L11DB       lda L0E21
            lsr @
            bcc L11E6
            ldx #$2A
            stx L0D9D
L11E6       and #$10
            beq L11F0

            jsr MOVE_CALL
  dta b(MC_cpyE+3,TXT_DIRI-DAT_BUF,L0DA7-DAT_BUF)

L11F0       lda L0E21+3
            ldx L0E21+4
            ldy L0E26
            jsr L14FD
            cmp #$00
            beq L1204
            inx
            bne L1204
            iny
L1204       stx DECIN
            sty DECIN+1

            jsr MOVE_CALL
  dta h(MC_jsr+CONV_16),l(CONV_16)
  dta h(MC_jsr+SET_TO_9),l(SET_TO_9)
  dta h(MC_movE+DECOUT+5),l(DECOUT+5),h(MC_3+L0DAB),l(L0DAB)

L1215       beq L1274

L1217       jsr MOVE_CALL
  dta b(MC_cpy+11,L0D92-DAT_BUF,L0E0B-DAT_BUF)
  dta h(MC_jsrE+L1DBF),l(L1DBF)

            bne L11B4
            bit L11BD+1
            bpl L11D1

            jsr CLR_TXT_BUF
            dta b($24)

            jsr MOVE_CALL
  dta b(MC_cpy+8,L0E27-DAT_BUF,L0D9D-DAT_BUF)
  dta b(MC_cpy+3,L0E2F-DAT_BUF,L0DA6-DAT_BUF)
  dta b(MC_cpy+5,TXT_DIRL-DAT_BUF,L0DAA-DAT_BUF)
  dta b(MC_cpy+1,TXT_DASH-DAT_BUF,L0DB3-DAT_BUF)
  dta b(MC_cpy+1,TXT_DASH-DAT_BUF,L0DB6-DAT_BUF)
  dta b(MC_cpyE+1,TXT_PERI-DAT_BUF,L0DBC-DAT_BUF)

            lda L0E21
            and #$20
            bne L1253

            jsr MOVE_CALL
  dta h(MC_mov+L0E24),l(L0E24),h(MC_3+DECIN),l(DECIN)
  dta h(MC_jsr+CONVDC),l(CONVDC)
  dta h(MC_movE+DECOUT+1),l(DECOUT+1),h(MC_7+L0DA9),l(L0DA9)

L1253       ldy #$FB
L1255       txa
            pha
            lda L0E32-$FB,Y
            jsr CONV_A
            jsr SET_TO_9
            pla
            tax
            lda DECOUT+6
            sta L0DB1,X
            lda DECOUT+7
            sta L0DB1+1,X
            inx
            inx
            inx
            iny
            bne L1255

L1274       dec L1283+1
L1277       ldx #$00
            lda L0D9D,X
            inc L1277+1
            sta L10DB+1
            rts

L1283       lda #$00
            asl @
            bne L1274
            bcs L12EE
            jmp L1217
