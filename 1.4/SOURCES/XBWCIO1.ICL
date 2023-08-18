ZAJMAP  ldx FCBMAP
        lda FCBMAP+1
        jsr ZAJIST
        ldy FCBMAPX
        rts

JSR_SIO lda XIOADH-$20,Y
        and #$1F
        pha
        lda XIOADL-$20,Y
        pha
        ldx CIOIOCB
        rts

* internal CIO code/vectortab
* low
*           REN,   DEL,   OPEN,  PROT
XIOADL dta l(L1CD1V,L1CD1V,OPENV,L1CD1V) ; $20-$23
*           UNPROT,POINT, NOTE,  GETFLEN
       dta l(L1CD1V,POINTV,NOTEV,GETLENV) ; $24-$27
*           LOAD,  SAVE,  MD,    RD
       dta l(L1E22V,STATV,CREDIRV,L1D1AV) ; $28-$2B
*           CD,    CLOSE, ???,   CHKDSK
       dta l(L1A95V,CLOSEV,BLOCKV,CHKDSKV) ; $2C-$2F
*           GETBYTE,PUTBYTE
       dta l(GETV,PUTV)               ; $30-$31
* high
*           REN,         DEL,         OPEN,        PROTECT
XIOADH dta h($E000+L1CD1V,$E000+L1CD1V,$8000+OPENV,$E000+L1CD1V) ; $20-$23
*           UNPROTECT,   POINT,       NOTE,        GETFLEN
       dta h($E000+L1CD1V,$2000+POINTV,$2000+NOTEV,$2000+GETLENV) ; $24-$27
*           LOAD,        SAVE,        MD,          RD
       dta h($2000+L1E22V,$C000+STATV,$E000+CREDIRV,$E000+L1D1AV) ; $28-$2B
*           CD,          CLOSE,       ???,   CHKDSK
       dta h($E000+L1A95V,$4000+CLOSEV,BLOCKV,$E000+CHKDSKV) ; $2C-$2F
*           GETBYTE,PUTBYTE
       dta h(GETV,PUTV) ; $30-$31

* CIO D: routines
DSPEC   ldy ICCOMZ
DSPEC_V equ DSPEC-1
        sta CIODTA+1
        tya
        and #$F0
        cmp #$20
        bne DSPER
        and XIOADH-$20,Y
        bne XIO01
DSPER   ldy #$A8 ; not implemented
        rts

DOPEN   ldy #$22
DOPEN_V equ DOPEN-1
        dta b(op_BIT_abs)
DCLOSE  ldy #$2D
DCLOSE_V equ DCLOSE-1
        dta b(op_BIT_abs)
DGET    ldy #$30
DGET_V  equ DGET-1
        dta b(op_BIT_abs)
DPUT    ldy #$31
DPUT_V  equ DPUT-1
        dta b(op_BIT_abs)
DSTAT   ldy #$29
DSTAT_V equ DSTAT-1

XIO     sta CIODTA+1
XIO01   cld
        stx CIOIOCB
        lda #$01
        sta XOK+1
        cpy #$28
        bne XIO2
* load
        jsr JSR_SIO
        dta b(op_BIT_abs)
XTOOOPN ldy #$A1
XJCD    jmp CIODTA

XIO2    tsx
        stx RETERRY+1
        inx
        inx
        lda STACK,X
        sta RTAD+1
        sty XIO8+1
* FCB
        lda XIOADH-$20,Y
        and #$C0
        sta XIO4+1
        ldx CIOIOCB
        jsr XIOSRCH
        bne XIO4
        bit XIO4+1
        bpl XIO5
        ldy #$81
        bne XJCD

XIO4    lda #$00
        bpl XNOTOP
        ldx #$FF
        jsr XIOSRCH
        bne XTOOOPN
        lda CIOIOCB
        sta FCBS,Y
        lda ICDNOZ
        sta L0ED8,Y

XIO5    sty XIOFCB+1
        ldx #$EB

XIO5B   lda FCBS,Y
        sta FCBIOCB-$EB,X
        iny
        inx
        bne XIO5B
* DCB
        ldy #$68
XIO6    lda DCBDRIV,Y
        cmp FCBDRIV
        beq XIO7
        tya
        sec
        sbc #$1A
        tay
        bcs XIO6
* it must be open (otherwise the wrong drive
* would not be entered again), so the error
* cancels the FCB
        jsr RETERRS
        dta b($A0) ; drive number error

XNOTOP  ldy #$85
        lda XIO8+1
        cmp #$2D
        bne XJCD
        jmp XOK

XIO7    ldx #$E6
XIO7B   lda DCBDRIV-$E6,X
        pha
        lda DCBDRIV,Y
        sta DCBDRIV-$E6,X
        pla
        sta DCBDRIV,Y
        iny
        inx
        bne XIO7B
        bit XIO4+1
        bpl XIO8A
* open
        jsr L1BE5
        ldy #$07
        lda (L0043),Y
        cmp #$80
        bne BGNOPNE
        lda #$1F
        tay
        iny
        cmp (L0043),Y
        bcc BGO30
BGNOPNE jsr RETERRS
        dta b($94)

BGO30   ldy #$16
BGNOPN3 lda L0E4D,Y
        cmp (L0043),Y
        bne BGNOPN4
        iny
        cpy #$1E
        bcc BGNOPN3

        ldy #$26
BGO31   lda FCBLEN,Y
        cmp (L0043),Y
        bne BGNOPN4
        iny
        cpy #$28
        bcc BGO31
        bcs XIO8A
* other DSK
BGNOPN4 lda #$99
        jsr ENDCSUB
        iny
        lda (L0043),Y
        ldy FCBDRIV
        sta SECSIZ,Y

        jsr MOV_CAL
  dta b(MC_cpy+2),l(DCBMAIN-DAT_BUF,L0E6D-DAT_BUF)
  dta h(MC_jsrE+DRIVNEP),l(DRIVNEP)

XIO8A   ldy FCBDRIV
        lda SECSIZ,Y
        sta L0045
XIO8    ldy #$00
        jsr JSR_SIO
        bit XIO4+1
        bvc XIO9
* end close
        jsr ODKLID
        stx FCBIOCB
XIO9    ldy XIOFCB+1
        ldx #$EB
XIO9B   lda FCBIOCB-$EB,X
        sta FCBS,Y
        iny
        inx
        bne XIO9B
XOK     ldy #$01
        bne CIODTA

* Error code on stack
RETERRS jsr GETSTK
        tay
* Error code in Y
RETERRY ldx #$00
        txs
        tya
        pha
* open/close ?
        lda XIO4+1
        beq ERR1B
XIOFCB  ldy #$00
        lda #$FF
        sta FCBS,Y
ERR1B   jsr ODKLID
        jsr DRIVNEP
        pla
        tay
CIODTA  lda #$00
        ldx CIOIOCB
        cpy #$00
        rts

ODKLID  ldx FCBDRIV
        lda FCBDIRP+1,X
        bpl ENDCLO2
        lsr FCBDIRP+1,X
        jsr L1BE5
        jsr L1C2B
        inc DCBSEQ
        lda #$B9
        jsr ENDCSUB
ENDCLO2 ldx #$03
ENDCLO3 dex
        bmi ENDCLX
        jsr NASLI
        bne ENDCLO3
        bcc ENDCLO3
        jsr SIO_W_BUF
* always valid
        bpl ENDCLO2

NASLI   lda BUFDRIV,X
        eor FCBDRIV
        asl @
ENDCLX  rts

DRIVNEP ldx #$02
DRNP2   jsr NASLI
        bne DRNP3
        sta BUFDRIV,X
DRNP3   dex
        bpl DRNP2
* RTS omitted - never mind
XIOSRCH ldy #$54
XIOS3   txa
        cmp FCBS,Y
        beq XIOS4
        tya
        sec
        sbc #$15
        tay
        bcs XIOS3
XIOS4   rts

ENDCSUB sta ENDCL1X
        sta BGO40BX
        ldy #$26
BGO40B  lda (L0043),Y
BGO40BX sta FCBLEN,Y
        sta (L0043),Y
        iny
        cpy #$28
        bcc BGO40B
        ldy #$09
ENDCL1  lda (L0043),Y
ENDCL1X lda L0E4D,Y
        sta (L0043),Y
        iny
        cpy #$1E
        bcc ENDCL1
        rts

* CHKDSK
CHKDSK  jsr MOV_CAL
CHKDSKV equ CHKDSK-1
  dta h(MC_movE+ICBLLZ),l(ICBLLZ),h(MC_2+CHKP2+1),l(CHKP2+1)
* X=0
        ldy #$20
        jsr CHKP
        ldy #$1F
        jsr CHKP
        ldy #$0B
CHKD2   jsr CHKP
        cpy #$0F
        bcc CHKD2
        ldy #$16
CHKD3   jsr CHKP
        cpy #$1E
        bcc CHKD3
        ldy #$26
        jsr CHKP
        jsr CHKP
        lda #$00

        dta b(op_BIT_abs)
CHKP    lda (L0043),Y

        iny
CHKP2   sta $FFFF,X
        inx
        rts

NUMMOD  ldx #$FD
NUMMD1  lda DECOUT+4
        cmp #$20
        bne NUMMD2
        lda DECOUT+5-$FD,X

        dta b(op_BIT_abs)
NUMMD2  lda #$39

        ora #$30
        sta DECOUT+5-$FD,X
        inx
        bne NUMMD1
        rts

DLG01A  jsr DLCLRS
        dta b($91)

        jsr MOV_CAL
  dta h(MC_jsr+NUMMOD),l(NUMMOD)
  dta h(MC_mov+DECOUT+5),l(DECOUT+5),h(MC_3+DIBUF),l(DIBUF)
  dta b(MC_cpyE+12,DLFREE-DAT_BUF,DIBUF+4-DAT_BUF)

        beq DLG1EQ

DLG02   jsr MOV_CAL
  dta h(MC_mov+DCBFREE),l(DCBFREE),h(MC_2+DECIN),l(DECIN)
  dta h(MC_jsrE+CONV_16),l(CONV_16)

DTYPE   ldx #$00
        bpl DLG01A

        jsr DLCLRS
        dta b($94)

        jsr MOV_CAL
  dta h(MC_mov+DECOUT+2),l(DECOUT+2),h(MC_6+DIBUF),l(DIBUF)
  dta b(MC_cpyE+12,DLFREE-DAT_BUF,DIBUF+7-DAT_BUF)

        beq DLG1EQ

DLG01BA jsr DLCLRS
        dta b($12)

        jsr MOV_CAL
  dta b(MC_cpyE+11,DIRBUF+6-DAT_BUF,DIBUF+2-DAT_BUF)

DIRBAD  lda DIRBUF
        lsr @
        bcc DLG01B
        ldx #$2A
        stx DIBUF
DLG01B  and #$10
        beq DLG01C

        jsr MOV_CAL
  dta b(MC_cpyE+3,DLG3TX-DAT_BUF,DIBUF+10-DAT_BUF)

DLG01C  lda DIRBUF+3
        ldx DIRBUF+4
        ldy L0E26
        jsr L14FD
        cmp #$00
        beq DLG01D
        inx
        bne DLG01D
        iny
DLG01D  stx DECIN
        sty DECIN+1

        jsr MOV_CAL
  dta h(MC_jsr+CONV_16),l(CONV_16)
  dta h(MC_jsr+NUMMOD),l(NUMMOD)
  dta h(MC_movE+DECOUT+5),l(DECOUT+5),h(MC_3+DIBUF+14),l(DIBUF+14)

DLG1EQ  beq DLG1

DLG01   jsr MOV_CAL
  dta b(MC_cpy+11,DIRNAM-DAT_BUF,SRCHNAM-DAT_BUF)
  dta h(MC_jsrE+L1DBF),l(L1DBF)

        bne DLG02
        bit DTYPE+1
        bpl DLG01BA

        jsr DLCLRS
        dta b($24)

        jsr MOV_CAL
  dta b(MC_cpy+8,DIRBUF+6-DAT_BUF,DIBUF-DAT_BUF)
  dta b(MC_cpy+3,DIRBUF+14-DAT_BUF,DIBUF+9-DAT_BUF)
  dta b(MC_cpy+5,DLG3DT-DAT_BUF,DIBUF+13-DAT_BUF)
  dta b(MC_cpy+1,DASH-DAT_BUF,DIBUF+22-DAT_BUF)
  dta b(MC_cpy+1,DASH-DAT_BUF,DIBUF+25-DAT_BUF)
  dta b(MC_cpyE+1,PERIOD-DAT_BUF,DIBUF+31-DAT_BUF)

        lda DIRBUF
        and #$20
        bne DLG03B

        jsr MOV_CAL
  dta h(MC_mov+DIRBUF+3),l(DIRBUF+3),h(MC_3+DECIN),l(DECIN)
  dta h(MC_jsr+CONVDC),l(CONVDC)
  dta h(MC_movE+DECOUT+1),l(DECOUT+1),h(MC_7+DIBUF+12),l(DIBUF+12)

DLG03B  ldy #$FB
* X=0
DLG03C  txa
        pha
        lda L0E32-$FB,Y
        jsr CONV_A
        jsr NUMMOD
        pla
        tax
        lda DECOUT+6
        sta DIBUF+20,X
        lda DECOUT+7
        sta DIBUF+21,X
        inx
        inx
        inx
        iny
        bne DLG03C

DLG1    dec DLG0+1
DLBX    ldx #$00
        lda DIBUF,X
        inc DLBX+1
        sta CIODTA+1
        rts

DLG0    lda #$00
        asl @
        bne DLG1
        bcs PTA4
        jmp DLG01
