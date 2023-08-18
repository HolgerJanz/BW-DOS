FGPUT   cpx #$08
        bcc FGP2
        bit L1C47+1
        bpl FGP3
        cpx #$0B
        bcs FGP3
FGP2    sta SRCHNAM,X
        inx
FGP3    rts

FGETNM   ldy #$00
        sty L1AE9+1
        inc FGETNM+1
        lda #$0E
        sta L1C47+1
        ldx #$00
        beq L1A3E

L1A34   lda #$3F
        jsr FGPUT
        bcc L1A34

L1A3B   jsr FGPUT
L1A3E   iny
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

L1A61   sec
        ror L1C47+1
L1A65   lda #' '
        jsr FGPUT
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
        ror OPNJ1A+1
        iny
        iny
L1A84   cpy FGETNM+1
L1A87   sty FGETNM+1
        php
        beq L1A8E
        clc
L1A8E   ror L1AFD+1
        lda (ICBALZ),Y
        plp
        rts

* CD
L1A95   jsr MOV_CAL
L1A95V  equ L1A95-1
  dta h(MC_jsr+L1A9F),l(L1A9F)
  dta h(MC_jsr+L1AFA),l(L1AFA)
  dta b(MC_cpyE+2,FCB1ST-DAT_BUF,L0E6D-DAT_BUF)

L1A9F   ldy #$02
L1AA1   lda (ICBALZ),Y
        cmp #':'
        beq L1A87
        dey
        bne L1AA1

L1AAA   jsr RETERRS
        dta b($96)

L1AAE   jsr L1A9F
        sty L1AE7+1
L1AB4   lsr OPNJ1A+1

        jsr MOV_CAL
  dta b(MC_cpy+2,L0E6D-DAT_BUF,FCB1ST-DAT_BUF)
  dta h(MC_jsrE+FGETNM),l(FGETNM)

        bne L1AF4
        cmp #'>'
        bne L1AE0

        jsr MOV_CAL
  dta b(MC_cpyE+2,DCBMAIN-DAT_BUF,FCB1ST-DAT_BUF)

        beq L1AEF
L1ACD   jsr OPNDRD
        jsr L1B0C
        lda FCB1ST
        ora FCB1ST+1
        beq L1AAA
        jsr FGETNM
        bne L1AF4
L1AE0   cmp #'<'
        beq L1ACD

L1AE4   lsr OPNJ1A+1
L1AE7   ldy #$00
L1AE9   cpy #$00
        rts

L1AEC   jsr L1B01
L1AEF   jsr FGETNM
        beq L1AE4

L1AF4   cmp #'>'
        beq L1AEC
        bne L1AE7
L1AFA   jsr L1AB4
L1AFD   lda #$00
        bmi L1B12
L1B01   lsr OPNJ1A+1
        jsr OPNDRD
        jsr L1DC5
        bmi L1AAA

L1B0C   jsr MOV_CAL
  dta b(MC_cpyE+2,DIRBUF+1-DAT_BUF,FCB1ST-DAT_BUF)

L1B12   rts

* call SIO
SIO_W_BUF   lda BUFDRIV,X
        bpl L1B12
        and #$7F
        sta BUFDRIV,X
        tay
        jsr ZAJADR
        lda L0F46,X
        pha
        lda L0F43,X
        tax
        pla
        sec
SIO_RW  sty DUNIT
        stx DAUX1
        sta DAUX2
        dex
        bne L1B3B
        tax
        bne L1B3B
        tay
L1B3B   ldx #'R'
        lda #$40
        bcc L1B45
        ldx WRTCMD
        asl @
L1B45   stx DCOMND
        sta DSTATS
        lda SECSIZ,Y
        sta DBYTLO
        asl @
        rol @
        eor #$01
        sta DBYTHI

        jsr MOV_CAL
  dta h(MC_mov+L1B6F+1),l(L1B6F+1),h(MC_1+DTIMLO),l(DTIMLO)
  dta h(MC_mov+K31+1),l(K31+1),h(MC_1+DDEVIC),l(DDEVIC)
  dta h(MC_mov+L0043),l(L0043),h(MC_2+DBUFLO),l(DBUFLO)
  dta h(MC_jsrE+SSIOV),l(SSIOV)

        bmi L1BE2
L1B6B   rts

L1B6C   lda FCBAUX1
L1B6F   cmp #$10
        bcs L1B76
        ldy #$00
        dta b(op_BIT_abs)
L1B76   ldy #$02
        tya
        pha

        ldx #$FE
L1B7C   lda L0E5F,Y
        sta VTOCSEC-$FE,X
        iny
        inx
        bne L1B7C

        jsr L1BAE
        jsr L1CA3

        jsr SBC_1
        dta a(VTOCSEC)

L1B91   jsr L1D8A
        tax
        and (L0043),Y
        bne L1B9E
        jsr L1BAE
        bcc L1B91

L1B9E   txa
        eor (L0043),Y
        sta (L0043),Y
        jsr L1C2B

        jsr SBC_1
        dta a(DCBFREE)

        clc
        bcc L1BC9

L1BAE   jsr ADC_1
        dta a(VTOCSEC)

        lda VTOCSEC
        cmp L0E58
        lda VTOCSEC+1
        sbc L0E58+1
        bcc L1B6B

        jsr SBC_1
        dta a(VTOCSEC)

        pla
        pla
        sec
L1BC9   pla
        tay
        ldx #$FE
L1BCD   lda VTOCSEC-$FE,X
        sta L0E5F,Y
        iny
        inx
        bne L1BCD

        ldx VTOCSEC
        bcc L1BEA
        dey
        dey
        beq L1B76
        ldy #$A2
L1BE2   jmp RETERRY

L1BE5   lda #$00
        ldx #$01
ZAJIST  sec
L1BEA   stx L1C68+1
        sta L1C6D+1
        php
        ldx #$02
L1BF3   lda L0F49,X
        beq L1BFB
        dec L0F49,X
L1BFB   dex
        bpl L1BF3

        ldx #$02
L1C00   jsr NASLI
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
L1C1C   jsr ZAJADR
        plp
        bcs L1C34
L1C22   ldy L0045
        lda #$00
L1C26   dey
        sta (L0043),Y
        bne L1C26

L1C2B   ldx #$00
        asl BUFDRIV,X
        sec
        ror BUFDRIV,X
L1C34   rts

L1C35   dex
        bpl L1C00
        stx L1C47+1
        inx
        stx L1C56+1
L1C3F   lda BUFDRIV,X
L1C42   beq L1C47
        lda L0F49,X
L1C47   cmp #$FF
        bcs L1C51
        sta L1C47+1
        stx L1C56+1
L1C51   inx
        cpx #$03
        bcc L1C3F
L1C56   ldx #$00
        jsr SIO_W_BUF
        ldx L1C56+1
L1C5E   jsr ZAJADR
        lda FCBDRIV
        sta BUFDRIV,X
        tay
L1C68   lda #$00
        sta L0F43,X
L1C6D   lda #$00
        sta L0F46,X
        plp
        bcc L1C22
        ldx L1C68+1
* read sector Y=unit, XA=sec
        clc
        jmp SIO_RW

L1C7C   jsr MOV_CAL
  dta b(MC_cpy+2,FCBSECT-DAT_BUF,VTOCSEC-DAT_BUF)
  dta h(MC_jsrE+L1D8A),l(L1D8A)

        ora (L0043),Y
        sta (L0043),Y

        jsr MOV_CAL
  dta h(MC_jsr+L1C2B),l(L1C2B)
  dta b(MC_cpy+2,K0002-DAT_BUF,L0E61-DAT_BUF)
* set last alloc to last deleted (VTOCSEC)
  dta b(MC_cpyE+2,VTOCSEC-DAT_BUF,L0E5F-DAT_BUF)

* increment disk seq number
        jsr ADC_1
        dta a(DCBFREE)

L1CA3   ldx FCBDRIV
        sec
        ror FCBDIRP+1,x
L1CAA   rts

L1CAB   ldx #$0A
L1CAD   lda RENNAM,X
        cmp #'?'
        beq L1CB7
        sta DIRBUF+6,X
L1CB7   dex
        bpl L1CAD
        rts

L1CBB   sec
        dta b(op_BIT_zp)
L1CBD   clc
        php
        lsr DIRBUF
        plp
        rol DIRBUF
L1CC6   rts

L1CC7   dta l(L1CAB,L1D34,L1CC6,L1CBB,L1CBD)
L1CCC   dta h(L1CAB,L1D34,L1CC6,L1CBB,L1CBD)

* REN, DEL, PROTECT, UNPROTECT
L1CD1   tya
L1CD1V  equ L1CD1-1
        and #$07
        pha
        tay
        lda L1CC7,Y
        sta L1D01+1
L1CDC   lda L1CCC,Y
        sta L1D01+2
        lda RDPUTST,Y
        sta L1D12+1
        jsr OPEN014
        pla
        bne L1CFC

        jsr MOV_CAL
  dta b(MC_cpy+11,SRCHNAM-DAT_BUF,DIRBUF-DAT_BUF)
  dta h(MC_jsr+FGETNM),l(FGETNM)
  dta b(MC_cpy+11,SRCHNAM-DAT_BUF,RENNAM-DAT_BUF)
  dta b(MC_cpyE+11,DIRBUF-DAT_BUF,SRCHNAM-DAT_BUF)

L1CFC   jsr L1D0D
        bne L1D3D
L1D01   jsr L1CAA
        jsr SADIR
        jsr L1D0D
        beq L1D01
        rts

L1D0D   jsr L1DBF
        bne L1D19
L1D12   lda #$00
        and DIRBUF
        bne L1D0D
L1D19   rts

* RD
L1D1A   lda #$24
L1D1AV  equ L1D1A-1
L1D1C   jsr OPEN0
        ldx #$0A
        lda #'?'
L1D23   sta SRCHNAM,X
        dex
        bpl L1D23
        jsr L1DBF
        beq L1D40
        jsr OPEN014
        jsr L1DC5

L1D34   lda DIRBUF
        lsr @
        bcc L1D45
        ldy #$A4
        dta b(op_BIT_abs)
L1D3D   ldy #$AA
        dta b(op_BIT_abs)
L1D40   ldy #$A7
        jmp RETERRY

L1D45   lda #$10 
        sta DIRBUF
        jsr SADIR

L1D4D   jsr MOV_CAL
  dta b(MC_cpy+2,FCB1ST-DAT_BUF,FCBDIR1-DAT_BUF)
  dta b(MC_cpy+2,DIRBUF+1-DAT_BUF,FCB1ST-DAT_BUF)
  dta h(MC_jsr+OPNINT1),l(OPNINT1)
  dta b(MC_cpyE+1,K0002-DAT_BUF,FCBMAPX-DAT_BUF)

L1D5B   jsr NXTDAT
        beq L1D63
        jsr L1C7C
L1D63   ldy L0045
        dey
        dey
        cpy FCBMAPX
        bne L1D5B

        jsr MOV_CAL
  dta b(MC_cpy+2,FCBMAP-DAT_BUF,FCBSECT-DAT_BUF)
  dta h(MC_jsr+L1C7C),l(L1C7C)
  dta h(MC_jsrE+ZAJMAP),l(ZAJMAP)

        ldy #$00
        lda (L0043),Y
        iny
        ora (L0043),Y
        bne L1D5B

        jsr MOV_CAL
  dta b(MC_cpy+2,FCBDIR1-DAT_BUF,FCB1ST-DAT_BUF)
  dta h(MC_jsrE+OPNDRD),l(OPNDRD)

        jmp LDDIR

L1D8A   lda VTOCSEC
L1D8D   ldx VTOCSEC+1
        ldy #$03
L1D92   pha
        txa
        lsr @
        tax
        pla
        ror @
        dey
        bne L1D92
L1D9B   jsr L14FD
        sta L1DBC+1
        txa
        clc
        adc L0E5D
        tax
        lda #$00
        adc L0E5D+1
        jsr ZAJIST
        lda VTOCSEC
        and #$07
        tay
        lda #$00
        sec
L1DB8   ror @
        dey
        bpl L1DB8
L1DBC   ldy #$00
        rts

L1DBF   lda #$80
        dta b(op_BIT_abs)
L1DC2   lda MYA1
        dta b(op_BIT_abs)
L1DC5   lda #$20
        sta L1DF3+1

        jsr MOV_CAL
  dta b(MC_cpyE+2,KFFFF-DAT_BUF,FCBDIRP-DAT_BUF)

L1DD0   jsr MOV_CAL
  dta b(MC_cpyE+2,FCBPOS-DAT_BUF,SRCHTMP-DAT_BUF)

        bit L0E41
        bmi L1E19
        jsr LDDIRN
        bmi L1E19
        lda DIRBUF
        beq L1E19
        and #$08
        bne L1DF3
        bit FCBDIRP+1
        bpl L1DD0
        jsr L1E10
        beq L1DD0

L1DF3   lda #$00
        bmi L1DFE
        eor DIRBUF
        and #$20
        bne L1DD0
L1DFE   ldx #$0B
L1E00   lda DASH,X
        cmp #'?'
        beq L1E0C
        cmp L0E26,X
        bne L1DD0

L1E0C   dex
        bne L1E00
        txa
L1E10   pha

        jsr MOV_CAL
  dta b(MC_cpyE+2,SRCHTMP-DAT_BUF,FCBDIRP-DAT_BUF)

        pla
        rts

L1E19   lda #$FF
        bit FCBDIRP+1
        bmi L1E10
        tax
        rts

* LOAD
L1E22   stx L1ED5+1
L1E22V  equ L1E22-1
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
L1E42   jsr L1E7D
        bmi L1E5C
        bcs L1E42
L1E49   lda #$00 
        bpl L1E57
        lsr L1E49+1

        jsr MOV_CAL
  dta h(MC_movE+CHKP2+1),l(CHKP2+1),h(MC_2+RUNAD),l(RUNAD)

L1E57   jsr L1E92
        bpl L1E42

L1E5C   lda #$FF
        sta IOCB0,X
L1E61   tya
        pha
        ldy #$2D
        jsr L1ED1
        pla
        tay
        cpy #$88
        bne L1E91

        jsr MOV_CAL
  dta h(MC_mov+RUNAD),l(RUNAD),h(MC_2+TRUN),l(TRUN)
  dta h(MC_movE+TRUN),l(TRUN),h(MC_2+RUNLOC),l(RUNLOC)

        lda #$E0
        bne L1EC2

L1E7D   jsr MOV_CAL
  dta h(MC_mov+L1E88+1),l(L1E88+1),h(MC_2+LDSA7B+1),l(LDSA7B+1)
  dta h(MC_jsrE+L1EC9),l(L1EC9)

        bmi L1E91
L1E88   lda CHKP2+1
        and CHKP2+2
        cmp #$FF
        tya
L1E91   rts

L1E92   jsr MOV_CAL
  dta h(MC_mov+L1D9B+1),l(L1D9B+1),h(MC_2+INITAD),l(INITAD)
  dta h(MC_mov+L1CAD+1),l(L1CAD+1),h(MC_2+LDSA7B+1),l(LDSA7B+1)
  dta h(MC_jsrE+L1EC9),l(L1EC9)

        bmi L1E91
        sec
        ldx #$FE
L1EA4   lda RENNAM-$FE,X
        sbc CHKP2+1-$FE,X
        sta L0E51-$FE,X
        inx
        bne L1EA4

        jsr ADC_1
        dta a(L0E51)

        jsr MOV_CAL
  dta h(MC_mov+CHKP2+1),l(CHKP2+1),h(MC_2+LDSA7B+1),l(LDSA7B+1)
  dta h(MC_jsrE+L1ECF),l(L1ECF)

        bmi L1E91
        lda #$E2
L1EC2   jsr L1EDA
        cld
        ldy #$01
        rts

L1EC9   jsr MOV_CAL
  dta b(MC_cpyE+2,K0002-DAT_BUF,L0E51-DAT_BUF)

L1ECF   ldy #$2E
L1ED1   ldx #$00
        stx RWFLG
L1ED5   ldx #$00
        jmp XIO

L1EDA   ldx #$00
        bmi L1E91
        sta L1EE1+1
L1EE1   jmp (RUNAD)
