L1A11       cpx #$08
            bcc L1A1E
            bit L1C47+1
            bpl L1A22
            cpx #$0B
            bcs L1A22
L1A1E       sta L0E0B,X
            inx
L1A22       rts

L1A23       ldy #$00
            sty L1AE9+1
            inc L1A23+1
            lda #$0E
            sta L1C47+1
            ldx #$00
            beq L1A3E

L1A34       lda #$3F
            jsr L1A11
            bcc L1A34

L1A3B       jsr L1A11
L1A3E       iny
            lda (ICBALZ),Y
            cmp #'*'
            beq L1A34
            cmp #'?'
            beq L1A3B
            cmp #'_'
            beq L1A3B
            cmp #'.'
            beq L1A65
            cmp #'0'
            bcc L1A61
            cmp #':'
            bcc L1A3B
            cmp #'A'
            bcc L1A61
            cmp #'['
            bcc L1A3B

L1A61       sec
            ror L1C47+1
L1A65       lda #' '
            jsr L1A11
            bcc L1A65

            ror L1C47+1
            bcc L1A3E
            lda (ICBALZ),Y
            cmp #'/'
            bne L1A84
            iny
            lda (ICBALZ),Y
            dey
            cmp #'A'
            bne L1A84
            ror L16AC+1
            iny
            iny
L1A84       cpy L1A23+1
L1A87       sty L1A23+1
            php
            beq L1A8E
            clc
L1A8E       ror L1AFD+1
            lda (ICBALZ),Y
            plp
            rts

* CD
L1A95       jsr MOVE_CALL
L1A95V      equ L1A95-1
  dta h(MC_jsr+L1A9F),l(L1A9F)
  dta h(MC_jsr+L1AFA),l(L1AFA)
  dta b(MC_cpyE+2,L0E43-DAT_BUF,L0E6D-DAT_BUF)

L1A9F       ldy #$02
L1AA1       lda (ICBALZ),Y
            cmp #':'
            beq L1A87
            dey
            bne L1AA1

L1AAA       jsr RET_ERRS
            dta b($96)

L1AAE       jsr L1A9F
            sty L1AE7+1
L1AB4       lsr L16AC+1

            jsr MOVE_CALL
  dta b(MC_cpy+2,L0E6D-DAT_BUF,L0E43-DAT_BUF)
  dta h(MC_jsrE+L1A23),l(L1A23)

            bne L1AF4
            cmp #'>'
            bne L1AE0

            jsr MOVE_CALL
  dta b(MC_cpyE+2,L0E56-DAT_BUF,L0E43-DAT_BUF)

            beq L1AEF
L1ACD       jsr L150C
            jsr L1B0C
            lda L0E43
            ora L0E43+1
            beq L1AAA
            jsr L1A23
            bne L1AF4
L1AE0       cmp #'<'
            beq L1ACD

L1AE4       lsr L16AC+1
L1AE7       ldy #$00
L1AE9       cpy #$00
            rts

L1AEC       jsr L1B01
L1AEF       jsr L1A23
            beq L1AE4

L1AF4       cmp #'>'
            beq L1AEC
            bne L1AE7
L1AFA       jsr L1AB4
L1AFD       lda #$00
            bmi L1B12
L1B01       lsr L16AC+1
            jsr L150C
            jsr L1DC5
            bmi L1AAA

L1B0C       jsr MOVE_CALL
  dta b(MC_cpyE+2,L0E22-DAT_BUF,L0E43-DAT_BUF)

L1B12       rts

L1B13       lda L0F40,X
            bpl L1B12
            and #$7F
            sta L0F40,X
            tay
            jsr L16FE
            lda L0F46,X
            pha
            lda L0F43,X
            tax
            pla
            sec
L1B2B       sty DUNIT
            stx DAUX1
            sta DAUX2
            dex
            bne L1B3B
            tax
            bne L1B3B
            tay
L1B3B       ldx #'R'
            lda #$40
            bcc L1B45
            ldx WRTCMD
            asl @
L1B45       stx DCOMND
            sta DSTATS
            lda L0DE9,Y
            sta DBYTLO
            asl @
            rol @
            eor #$01
            sta DBYTHI

            jsr MOVE_CALL
  dta h(MC_mov+L1B6F+1),l(L1B6F+1),h(MC_1+DTIMLO),l(DTIMLO)
  dta h(MC_mov+L07AD+1),l(L07AD+1),h(MC_1+DDEVIC),l(DDEVIC)
  dta h(MC_mov+L0043),l(L0043),h(MC_2+DBUFLO),l(DBUFLO)
  dta h(MC_jsrE+SSIOV),l(SSIOV)

            bmi L1BE2
L1B6B       rts

L1B6C       lda L0E48
L1B6F       cmp #$10
            bcs L1B76
            ldy #$00
            dta b(op_BIT_abs)
L1B76       ldy #$02
            tya
            pha

            ldx #$FE
L1B7C       lda L0E5F,Y
            sta L0DE5-$FE,X
            iny
            inx
            bne L1B7C

            jsr L1BAE
            jsr L1CA3

            jsr SBC_1
            dta a(L0DE5)

L1B91       jsr L1D8A
            tax
            and (L0043),Y
            bne L1B9E
            jsr L1BAE
            bcc L1B91

L1B9E       txa
            eor (L0043),Y
            sta (L0043),Y
            jsr L1C2B

            jsr SBC_1
            dta a(L0E5A)

            clc
            bcc L1BC9

L1BAE       jsr ADC_1
            dta a(L0DE5)

            lda L0DE5
            cmp L0E58
            lda L0DE5+1
            sbc L0E58+1
            bcc L1B6B

            jsr SBC_1
            dta a(L0DE5)

            pla
            pla
            sec
L1BC9       pla
            tay
            ldx #$FE
L1BCD       lda L0DE5-$FE,X
            sta L0E5F,Y
            iny
            inx
            bne L1BCD

            ldx L0DE5
            bcc L1BEA
            dey
            dey
            beq L1B76
            ldy #$A2
L1BE2       jmp RET_ERRY

L1BE5       lda #$00
            ldx #$01
L1BE9       sec
L1BEA       stx L1C68+1
            sta L1C6D+1
            php
            ldx #$02
L1BF3       lda L0F49,X
            beq L1BFB
            dec L0F49,X
L1BFB       dex
            bpl L1BF3

            ldx #$02
L1C00       jsr L110C
            bne L1C35
            lda L0F43,X
            tay
            cmp L1C68+1
            bne L1C35
            lda L0F46,X
            cmp L1C6D+1
            bne L1C35
            dey
            bne L1C1C
            tay
            beq L1C5E
L1C1C       jsr L16FE
            plp
            bcs L1C34
L1C22       ldy L0045
            lda #$00
L1C26       dey
            sta (L0043),Y
            bne L1C26

L1C2B       ldx #$00
            asl L0F40,X
            sec
            ror L0F40,X
L1C34       rts

L1C35       dex
            bpl L1C00
            stx L1C47+1
            inx
            stx L1C56+1
L1C3F       lda L0F40,X
L1C42       beq L1C47
            lda L0F49,X
L1C47       cmp #$FF
            bcs L1C51
            sta L1C47+1
            stx L1C56+1
L1C51       inx
            cpx #$03
            bcc L1C3F
L1C56       ldx #$00
            jsr L1B13
            ldx L1C56+1
L1C5E       jsr L16FE
            lda L0E39
            sta L0F40,X
            tay
L1C68       lda #$00
            sta L0F43,X
L1C6D       lda #$00
            sta L0F46,X
            plp
            bcc L1C22
            ldx L1C68+1
            clc
            jmp L1B2B

L1C7C       jsr MOVE_CALL
  dta b(MC_cpy+2,L0E3A-DAT_BUF,L0DE5-DAT_BUF)
  dta h(MC_jsrE+L1D8A),l(L1D8A)

            ora (L0043),Y
            sta (L0043),Y

            jsr MOVE_CALL
  dta h(MC_jsr+L1C2B),l(L1C2B)
  dta b(MC_cpy+2,L0E03-DAT_BUF,L0E61-DAT_BUF)
  dta b(MC_cpyE+2,L0E58-DAT_BUF,L0E5F-DAT_BUF)

            ldy #$04
L1C95       lsr L0E5F+1
            ror L0E5F
            dey
            bne L1C95

            jsr ADC_1
            dta a(L0E5A)

L1CA3       ldx L0E39
            sec
            ror L0E4C,x
L1CAA       rts

L1CAB       ldx #$0A
L1CAD       lda L0E16,X
            cmp #'?'
            beq L1CB7
            sta L0E27,X
L1CB7       dex
            bpl L1CAD
            rts

L1CBB       sec
            dta b(op_BIT_zp)
L1CBD       clc
            php
            lsr L0E21
            plp
            rol L0E21
L1CC6       rts

L1CC7       dta l(L1CAB,L1D34,L1CC6,L1CBB,L1CBD)
L1CCC       dta h(L1CAB,L1D34,L1CC6,L1CBB,L1CBD)

* REN, DEL, PROTECT, UNPROTECT
L1CD1       tya
L1CD1V      equ L1CD1-1
            and #$07
            pha
            tay
            lda L1CC7,Y
            sta L1D01+1
L1CDC       lda L1CCC,Y
            sta L1D01+2
            lda L0DFE,Y
            sta L1D12+1
            jsr L159C
            pla
            bne L1CFC

            jsr MOVE_CALL
  dta b(MC_cpy+11,L0E0B-DAT_BUF,L0E21-DAT_BUF)
  dta h(MC_jsr+L1A23),l(L1A23)
  dta b(MC_cpy+11,L0E0B-DAT_BUF,L0E16-DAT_BUF)
  dta b(MC_cpyE+11,L0E21-DAT_BUF,L0E0B-DAT_BUF)

L1CFC       jsr L1D0D
            bne L1D3D
L1D01       jsr L1CAA
            jsr L139B
            jsr L1D0D
            beq L1D01
            rts

L1D0D       jsr L1DBF
            bne L1D19
L1D12       lda #$00
            and L0E21
            bne L1D0D
L1D19       rts

* RD
L1D1A       lda #$24
L1D1AV      equ L1D1A-1
L1D1C       jsr L159E
            ldx #$0A
            lda #'?'
L1D23       sta L0E0B,X
            dex
            bpl L1D23
            jsr L1DBF
            beq L1D40
            jsr L159C
            jsr L1DC5

L1D34       lda L0E21
            lsr @
            bcc L1D45
            ldy #$A4
            dta b(op_BIT_abs)
L1D3D       ldy #$AA
            dta b(op_BIT_abs)
L1D40       ldy #$A7
            jmp RET_ERRY

L1D45       lda #$10 
            sta L0E21
            jsr L139B

L1D4D       jsr MOVE_CALL
  dta b(MC_cpy+2,L0E43-DAT_BUF,L0E49-DAT_BUF)
  dta b(MC_cpy+2,L0E22-DAT_BUF,L0E43-DAT_BUF)
  dta h(MC_jsr+L150F),l(L150F)
  dta b(MC_cpyE+1,L0E03-DAT_BUF,L0E3F-DAT_BUF)

L1D5B       jsr L12F6
            beq L1D63
            jsr L1C7C
L1D63       ldy L0045
            dey
            dey
            cpy L0E3F
            bne L1D5B

            jsr MOVE_CALL
  dta b(MC_cpy+2,L0E3D-DAT_BUF,L0E3A-DAT_BUF)
  dta h(MC_jsr+L1C7C),l(L1C7C)
  dta h(MC_jsrE+L0F4C),l(L0F4C)

            ldy #$00
            lda (L0043),Y
            iny
            ora (L0043),Y
            bne L1D5B

            jsr MOVE_CALL
  dta b(MC_cpy+2,L0E49-DAT_BUF,L0E43-DAT_BUF)
  dta h(MC_jsrE+L150C),l(L150C)

            jmp L139E

L1D8A       lda L0DE5
L1D8D       ldx L0DE5+1
            ldy #$03
L1D92       pha
            txa
            lsr @
            tax
            pla
            ror @
            dey
            bne L1D92
L1D9B       jsr L14FD
            sta L1DBC+1
            txa
            clc
            adc L0E5D
            tax
            lda #$00
            adc L0E5D+1
            jsr L1BE9
            lda L0DE5
            and #$07
            tay
            lda #$00
            sec
L1DB8       ror @
            dey
            bpl L1DB8
L1DBC       ldy #$00
            rts

L1DBF       lda #$80
            dta b(op_BIT_abs)
L1DC2       lda L0049
            dta b(op_BIT_abs)
L1DC5       lda #$20
            sta L1DF3+1

            jsr MOVE_CALL
  dta b(MC_cpyE+2,INIFLAGS-DAT_BUF,L0E4B-DAT_BUF)

L1DD0       jsr MOVE_CALL
  dta b(MC_cpyE+2,L0E40-DAT_BUF,L0DE7-DAT_BUF)

            bit L0E41
            bmi L1E19
            jsr L13AE
            bmi L1E19
            lda L0E21
            beq L1E19
            and #$08
            bne L1DF3
            bit L0E4C
            bpl L1DD0
            jsr L1E10
            beq L1DD0

L1DF3       lda #$00
            bmi L1DFE
            eor L0E21
            and #$20
            bne L1DD0
L1DFE       ldx #$0B
L1E00       lda TXT_DASH,X
            cmp #'?'
            beq L1E0C
            cmp L0E26,X
            bne L1DD0

L1E0C       dex
            bne L1E00
            txa
L1E10       pha

            jsr MOVE_CALL
  dta b(MC_cpyE+2,L0DE7-DAT_BUF,L0E4B-DAT_BUF)

            pla
            rts

L1E19       lda #$FF
            bit L0E4C
            bmi L1E10
            tax
            rts

* LOAD
L1E22       stx L1ED5+1
L1E22V      equ L1E22-1
            lda ICAX2Z
            sta L1EDA+1
            ldy #$22
            jsr L1ED1
            bmi L1E61
            lda ICHIDZ
            sta IOCB0,X
            jsr L1E7D
            bmi L1E5C
            ldy #$98
            bcc L1E5C
            ror L1E49+1
L1E42       jsr L1E7D
            bmi L1E5C
            bcs L1E42
L1E49       lda #$00 
            bpl L1E57
            lsr L1E49+1

            jsr MOVE_CALL
  dta h(MC_movE+L1185+1),l(L1185+1),h(MC_2+RUNAD),l(RUNAD)

L1E57       jsr L1E92
            bpl L1E42

L1E5C       lda #$FF
            sta IOCB0,X
L1E61       tya
            pha
            ldy #$2D
            jsr L1ED1
            pla
            tay
            cpy #$88
            bne L1E91

            jsr MOVE_CALL
  dta h(MC_mov+RUNAD),l(RUNAD),h(MC_2+TRUN),l(TRUN)
  dta h(MC_movE+TRUN),l(TRUN),h(MC_2+RUNLOC),l(RUNLOC)

            lda #$E0
            bne L1EC2

L1E7D       jsr MOVE_CALL
  dta h(MC_mov+L1E88+1),l(L1E88+1),h(MC_2+L1426+1),l(L1426+1)
  dta h(MC_jsrE+L1EC9),l(L1EC9)

            bmi L1E91
L1E88       lda L1185+1
            and L1185+2
            cmp #$FF
            tya
L1E91       rts

L1E92       jsr MOVE_CALL
  dta h(MC_mov+L1D9B+1),l(L1D9B+1),h(MC_2+INITAD),l(INITAD)
  dta h(MC_mov+L1CAD+1),l(L1CAD+1),h(MC_2+L1426+1),l(L1426+1)
  dta h(MC_jsrE+L1EC9),l(L1EC9)

            bmi L1E91
            sec
            ldx #$FE
L1EA4       lda L0E16-$FE,X
            sbc L1185+1-$FE,X
            sta L0E51-$FE,X
            inx
            bne L1EA4

            jsr ADC_1
            dta a(L0E51)

            jsr MOVE_CALL
  dta h(MC_mov+L1185+1),l(L1185+1),h(MC_2+L1426+1),l(L1426+1)
  dta h(MC_jsrE+L1ECF),l(L1ECF)

            bmi L1E91
            lda #$E2
L1EC2       jsr L1EDA
            cld
            ldy #$01
            rts

L1EC9       jsr MOVE_CALL
  dta b(MC_cpyE+2,L0E03-DAT_BUF,L0E51-DAT_BUF)

L1ECF       ldy #$2E
L1ED1       ldx #$00
            stx L0048
L1ED5       ldx #$00
            jmp L0FAC

L1EDA       ldx #$00
            bmi L1E91
            sta L1EE1+1
L1EE1       jmp (RUNAD)
