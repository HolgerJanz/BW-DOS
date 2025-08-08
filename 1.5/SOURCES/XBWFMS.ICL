FGPUT   cpx #$08
        bcc FGP2
        bit ZAJBEST+1
        bpl FGP3
        cpx #$0B
        bcs FGP3
FGP2    sta SRCHNAM,X
        inx
FGP3    rts

FGETNM  ldy #$00
        sty SRDIR3C+1
        inc FGETNM+1
        lda #$0E
        sta ZAJBEST+1
        ldx #$00
        beq FGETN2

FGETN2A lda #'?'
        jsr FGPUT
        bcc FGETN2A

FGETN1  jsr FGPUT
FGETN2  iny
        lda (ICBALZ),Y
        cmp #'*'
        beq FGETN2A
        cmp #'?'
        beq FGETN1
        cmp #'_'
        beq FGETN1
        cmp #'.'
        beq FGETN4
        cmp #'0'
        bcc FGETN3
        cmp #':'
        bcc FGETN1
        cmp #'A'
        bcc FGETN3
        cmp #'['
        bcc FGETN1

FGETN3  sec
        ror ZAJBEST+1
FGETN4  lda #' '
        jsr FGPUT
        bcc FGETN4

        ror ZAJBEST+1
        bcc FGETN2
        lda (ICBALZ),Y
        cmp #'/'
        bne FGETN5
        iny
        lda (ICBALZ),Y
        dey
        cmp #'A'
        bne FGETN5
        ror OPNJ1A+1
        iny
        iny
FGETN5  cpy FGETNM+1
SRDIR2  sty FGETNM+1
        php
        beq FGTN6
        clc
FGTN6   ror GODR2+1
        lda (ICBALZ),Y
        plp
        rts

* CD
CWD     jsr MOV_CAL
CWDV    equ CWD-1
  dta h(MC_jsr+SRDDVOJ),l(SRDDVOJ)
  dta h(MC_jsr+GODIR),l(GODIR)
  dta b(MC_cpyE+2,FCB1ST-DAT_BUF,DCBWD-DAT_BUF)

SRDDVOJ ldy #$02
SRDIR1  lda (ICBALZ),Y
        cmp #':'
        beq SRDIR2
        dey
        bne SRDIR1

SRDE2   jsr RETERRS
        dta b($96)

SRCHDIR jsr SRDDVOJ
        sty SRDIR3B+1
SRD2    lsr OPNJ1A+1

        jsr MOV_CAL
  dta b(MC_cpy+2,DCBWD-DAT_BUF,FCB1ST-DAT_BUF)
  dta h(MC_jsrE+FGETNM),l(FGETNM)

        bne SRDIR4B
        cmp #'>'
        bne SRD2B

        jsr MOV_CAL
  dta b(MC_cpyE+2,DCBMAIN-DAT_BUF,FCB1ST-DAT_BUF)

        beq SRDIR4
SRD2BB  jsr OPNDRD
        jsr GDR9
        lda FCB1ST
        ora FCB1ST+1
        beq SRDE2
        jsr FGETNM
        bne SRDIR4B
SRD2B   cmp #'<'
        beq SRD2BB

SRDIR3  lsr OPNJ1A+1
SRDIR3B ldy #$00
SRDIR3C cpy #$00
        rts

SRDIR4A jsr GOTODIR
SRDIR4  jsr FGETNM
        beq SRDIR3

SRDIR4B cmp #'>'
        beq SRDIR4A
        bne SRDIR3B
GODIR   jsr SRD2
GODR2   lda #$00
        bmi UVOLNX
GOTODIR lsr OPNJ1A+1
        jsr OPNDRD
        jsr SRCHIT0
        bmi SRDE2

GDR9    jsr MOV_CAL
  dta b(MC_cpyE+2,DIRBUF+1-DAT_BUF,FCB1ST-DAT_BUF)

UVOLNX   rts

* call SIO
SIO_W_BUF lda BUFDRIV,X
        bpl UVOLNX
        and #$7F
        sta BUFDRIV,X
        tay
        jsr ZAJADR
        lda BUFSECH,X
        pha
        lda BUFSECL,X
        tax
        pla
        sec
SIO_RW  sty DUNIT
        stx DAUX1
        sta DAUX2
        dex
        bne RWS2
        tax
        bne RWS2
        tay
RWS2    ldx #'R'
        lda #$40
        bcc RWSC3
        ldx WRTCMD
        asl @
RWSC3   stx DCOMND
        sta DSTATS
        lda SECSIZ,Y
        sta DBYTLO
        asl @
        rol @
        eor #$01
        sta DBYTHI

        jsr MOV_CAL
  dta h(MC_mov+K16+1),l(K16+1),h(MC_1+DTIMLO),l(DTIMLO)
  dta h(MC_mov+K31+1),l(K31+1),h(MC_1+DDEVIC),l(DDEVIC)
  dta h(MC_mov+L0043),l(L0043),h(MC_2+DBUFLO),l(DBUFLO)
  dta h(MC_jsrE+SSIOV),l(SSIOV)

        bmi SIOERRJ
SIORTS  rts

PRIDEL  lda FCBAUX1
K16     cmp #$10
        bcs PRID3A
        ldy #$00
        dta b(op_BIT_abs)
PRID3A  ldy #$02
        tya
        pha

        ldx #$FE
PRID3BX lda DCBDAT,Y
        sta VTOCSEC-$FE,X
        iny
        inx
        bne PRID3BX

        jsr PRID3T
        jsr ZMENEN1

        jsr SBC_1
        dta a(VTOCSEC)

PRID3D  jsr SETBPOS
        tax
        and (L0043),Y
        bne PRID3C
        jsr PRID3T
        bcc PRID3D

PRID3C  txa
        eor (L0043),Y
        sta (L0043),Y
        jsr ZMENEN

        jsr SBC_1
        dta a(DCBFREE)

        clc
        bcc PRID3B

PRID3T  jsr ADC_1
        dta a(VTOCSEC)

        lda VTOCSEC
        cmp DCBMAIN+2
        lda VTOCSEC+1
        sbc DCBMAIN+3
        bcc SIORTS

        jsr SBC_1
        dta a(VTOCSEC)

        pla
        pla
        sec

* Preserves C

PRID3B  pla
        tay
        ldx #$FE
PRID3E  lda VTOCSEC-$FE,X
        sta DCBDAT,Y
        iny
        inx
        bne PRID3E

        ldx VTOCSEC
        bcc ZAJIST0
        dey
        dey
        beq PRID3A
        ldy #$A2
SIOERRJ jmp RETERRY

ZAJIST1 lda #$00
        ldx #$01
ZAJIST  sec
ZAJIST0 stx ZSL+1
        sta ZSH+1
        php
        ldx #$02
ZAJ1    lda BUFTIME,X
        beq ZAJ2
        dec BUFTIME,X
ZAJ2    dex
        bpl ZAJ1

* Search in buffers

        ldx #$02
ZAJ3    jsr NASLI
        bne ZAJ4
        lda BUFSECL,X
        tay
        cmp ZSL+1
        bne ZAJ4
        lda BUFSECH,X
        cmp ZSH+1
        bne ZAJ4
        dey
        bne ZAJ3Z
        tay
        beq ZAJ9
ZAJ3Z   jsr ZAJADR
        plp
        bcs ZAJ3B
ZAJ30   ldy L0045
        lda #$00
ZAJ3A   dey
        sta (L0043),Y
        bne ZAJ3A

ZMENEN  ldx #$00
        asl BUFDRIV,X
        sec
        ror BUFDRIV,X
ZAJ3B   rts

ZAJ4    dex
        bpl ZAJ3
        stx ZAJBEST+1
        inx
        stx ZAJBUF+1
ZAJ5    lda BUFDRIV,X
        beq ZAJBEST
        lda BUFTIME,X
ZAJBEST cmp #$FF
        bcs ZAJ7
        sta ZAJBEST+1
        stx ZAJBUF+1
ZAJ7    inx
        cpx #$03
        bcc ZAJ5
ZAJBUF  ldx #$00
        jsr SIO_W_BUF
        ldx ZAJBUF+1
ZAJ9    jsr ZAJADR
        lda FCBDRIV
        sta BUFDRIV,X
        tay
ZSL     lda #$00
        sta BUFSECL,X
ZSH     lda #$00
        sta BUFSECH,X
        plp
        bcc ZAJ30

* READ
* A=ZSH+1
* Y=FCBDRIV

        ldx ZSL+1
* read sector Y=unit, XA=sec
        clc
        jmp SIO_RW

ERA1    jsr MOV_CAL
  dta b(MC_cpy+2,FCBSECT-DAT_BUF,VTOCSEC-DAT_BUF)
  dta h(MC_jsrE+SETBPOS),l(SETBPOS)

        ora (L0043),Y
        sta (L0043),Y

        jsr MOV_CAL
  dta h(MC_jsr+ZMENEN),l(ZMENEN)
  dta b(MC_cpy+2,K0002-DAT_BUF,DCBDIR-DAT_BUF)
* set last alloc to last deleted (VTOCSEC)
  dta b(MC_cpyE+2,VTOCSEC-DAT_BUF,DCBDAT-DAT_BUF)

        jsr ADC_1
        dta a(DCBFREE)

ZMENEN1 ldx FCBDRIV
        sec
        ror FCBDIRP+1,x
ZMERET  rts

RENRUT  ldx #$0A
RIT2    lda RENNAM,X
        cmp #'?'
        beq RIT3
        sta DIRBUF+6,X
RIT3    dex
        bpl RIT2
        rts

PROTRUT sec
        dta b(op_BIT_zp)
UNPRUT  clc
        php
        lsr DIRBUF
        plp
        rol DIRBUF
NONE    rts

RDPUTL  dta l(RENRUT,ERARUT,NONE,PROTRUT,UNPRUT)
RDPUTH  dta h(RENRUT,ERARUT,NONE,PROTRUT,UNPRUT)

* REN, DEL, PROTECT, UNPROTECT
RDEPRU  tya
RDEPRUV equ RDEPRU-1
        and #$07
        pha
        tay
        lda RDPUTL,Y
        sta RDPUJ+1
        lda RDPUTH,Y
        sta RDPUJ+2
        lda RDPUTST,Y
        sta RDPU2+1
        jsr OPEN014
        pla
        bne RDPU1

        jsr MOV_CAL
  dta b(MC_cpy+11,SRCHNAM-DAT_BUF,DIRBUF-DAT_BUF)
  dta h(MC_jsr+FGETNM),l(FGETNM)
  dta b(MC_cpy+11,SRCHNAM-DAT_BUF,RENNAM-DAT_BUF)
  dta b(MC_cpyE+11,DIRBUF-DAT_BUF,SRCHNAM-DAT_BUF)

RDPU1   jsr SRCHRDP
        bne ERANOT
RDPUJ   jsr ZMERET
        jsr SADIR
        jsr SRCHRDP
        beq RDPUJ
        rts

SRCHRDP jsr SRCHCOK
        bne SRRDPX
RDPU2   lda #$00
        and DIRBUF
        bne SRCHRDP
SRRDPX  rts

* RD
DELDIR  lda #$24
DELDIRV equ DELDIR-1
        jsr OPEN0
        ldx #$0A
        lda #'?'
DLDR2   sta SRCHNAM,X
        dex
        bpl DLDR2
        jsr SRCHCOK
        beq DLDRER
        jsr OPEN014
        jsr SRCHIT0

ERARUT  lda DIRBUF
        lsr @
        bcc ERAR2
        ldy #$A4
        dta b(op_BIT_abs)
ERANOT  ldy #$AA
        dta b(op_BIT_abs)
DLDRER  ldy #$A7
        jmp RETERRY

ERAR2   lda #$10 
        sta DIRBUF
        jsr SADIR

ERASDT  jsr MOV_CAL
  dta b(MC_cpy+2,FCB1ST-DAT_BUF,FCBDIR1-DAT_BUF)
  dta b(MC_cpy+2,DIRBUF+1-DAT_BUF,FCB1ST-DAT_BUF)
  dta h(MC_jsr+OPNINT1),l(OPNINT1)
  dta b(MC_cpyE+1,K0002-DAT_BUF,FCBMAPX-DAT_BUF)

ERADT2  jsr NXTDAT
        beq ERADT3
        jsr ERA1
ERADT3  ldy L0045
        dey
        dey
        cpy FCBMAPX
        bne ERADT2

        jsr MOV_CAL
  dta b(MC_cpy+2,FCBMAP-DAT_BUF,FCBSECT-DAT_BUF)
  dta h(MC_jsr+ERA1),l(ERA1)
  dta h(MC_jsrE+ZAJMAP),l(ZAJMAP)

        ldy #$00
        lda (L0043),Y
        iny
        ora (L0043),Y
        bne ERADT2

        jsr MOV_CAL
  dta b(MC_cpy+2,FCBDIR1-DAT_BUF,FCB1ST-DAT_BUF)
  dta h(MC_jsrE+OPNDRD),l(OPNDRD)

        jmp LDDIR

SETBPOS lda VTOCSEC
        ldx VTOCSEC+1
        ldy #$03
SETBP1  pha
        txa
        lsr @
        tax
        pla
        ror @
        dey
        bne SETBP1
POSCMPA jsr POSCMP
        sta SETBP2+1
        txa
        clc
        adc DCBMAP1
        tax
        lda #$00
        adc DCBMAP1+1
        jsr ZAJIST
        lda VTOCSEC
        and #$07
        tay
        lda #$00
        sec
SETBP1B ror @
        dey
        bpl SETBP1B
SETBP2  ldy #$00
        rts

SRCHCOK lda #$80
        dta b(op_BIT_abs)
SRCHIT  lda MYA1
        dta b(op_BIT_abs)
SRCHIT0 lda #$20
        sta SRIT3+1

        jsr MOV_CAL
  dta b(MC_cpyE+2,KFFFF-DAT_BUF,FCBDIRP-DAT_BUF)

SRIT2   jsr MOV_CAL
  dta b(MC_cpyE+2,FCBPOS-DAT_BUF,SRCHTMP-DAT_BUF)

        bit FCBPOS+1
        bmi SRITEND
        jsr LDDIRN
        bmi SRITEND
        lda DIRBUF
        beq SRITEND
        and #$08
        bne SRIT3
        bit FCBDIRP+1
        bpl SRIT2
        jsr SRIT6
        beq SRIT2

SRIT3   lda #$00
        bmi SRIT3B
        eor DIRBUF
        and #$20
        bne SRIT2
* FNM
SRIT3B  ldx #$0B
SRIT4   lda DASH,X
        cmp #'?'
        beq SRIT5
        cmp DIRBUF+5,X
        bne SRIT2

SRIT5   dex
        bne SRIT4
        txa
SRIT6   pha

        jsr MOV_CAL
  dta b(MC_cpyE+2,SRCHTMP-DAT_BUF,FCBDIRP-DAT_BUF)

        pla
        rts

SRITEND lda #$FF
        bit FCBDIRP+1
        bmi SRIT6
        tax
        rts

* LOAD
LOAD    stx LOSIT3+1
LOADV   equ LOAD-1

* check for path
        ldy #$00
LOADLP  lda (ICBALZ),Y
        iny
        and #$FD
        cmp #'<' ;< OR >
        beq LOAD1
* heuristic saves 2 bytes
        cmp #$99 ; EOL or inverse left stroke
        bne LOADLP
* check for explicitly given drive
        lda PROMPTD+1
        and #$0F
        cmp ICDNOZ
        bne LOAD1
* check for DOSDRIVE
        ldy DOSDRV
        beq LOAD1  ; DOS drive 0 = off
        cpy ICDNOZ
        beq LOAD1  ; DOS drive is current
* load from DOSDRIVE
        lda ICDNOZ
        pha
        sty ICDNOZ
        jsr LOAD1
        pla
        sta ICDNOZ
        tya
        bpl LOSER3

* load from current drive
LOAD1   lda ICAX2Z
        sta LDRUN+1
        ldy #$22
        jsr LOSIT2
        bmi LOSER2B
* after XIO, X=IOCB#
        lda ICHIDZ
        sta IOCB0,X
        jsr LOSAD
        bmi LOSER2
        ldy #$98 ; no binary file
        bcc LOSER2
* C=1
        ror LOS2T+1
LOS2    jsr LOSAD
        bmi LOSER2
        bcs LOS2
LOS2T   lda #$00 
        bpl LOS2B
        lsr LOS2T+1

        jsr MOV_CAL
  dta h(MC_movE+CHKP2+1),l(CHKP2+1),h(MC_2+RUNAD),l(RUNAD)

LOS2B   jsr LOSSGMD
        bpl LOS2
* Error: always after XIO -> X=IOCB#
LOSER2  lda #$FF
        sta IOCB0,X
LOSER2B tya
        pha
        ldy #$2D
        jsr LOSIT2
        pla
        tay
        cpy #$88 ; EOF error
        bne LOSER31 ; set N and Z again

        jsr MOV_CAL
  dta h(MC_mov+RUNAD),l(RUNAD),h(MC_2+TRUN),l(TRUN)
  dta h(MC_movE+TRUN),l(TRUN),h(MC_2+RUNLOC),l(RUNLOC)

        lda <RUNAD
        bne LOSOK

LOSAD   jsr MOV_CAL
  dta h(MC_mov+LOSADAD+1),l(LOSADAD+1),h(MC_2+LDSA7B+1),l(LDSA7B+1)
  dta h(MC_jsrE+LOSDVA),l(LOSDVA)

        bmi LOSER3
LOSADAD lda CHKP2+1
        and CHKP2+2
        cmp #$FF
LOSER31 tya
LOSER3  rts

LOSSGMD jsr MOV_CAL
  dta h(MC_mov+POSCMPA+1),l(POSCMPA+1),h(MC_2+INITAD),l(INITAD)
  dta h(MC_mov+RIT2+1),l(RIT2+1),h(MC_2+LDSA7B+1),l(LDSA7B+1)
  dta h(MC_jsrE+LOSDVA),l(LOSDVA)

        bmi LOSER3
        sec
        ldx #$FE
LOSS3   lda RENNAM-$FE,X
        sbc CHKP2+1-$FE,X
        sta LDSALEN-$FE,X
        inx
        bne LOSS3

        jsr ADC_1
        dta a(LDSALEN)

        jsr MOV_CAL
  dta h(MC_mov+CHKP2+1),l(CHKP2+1),h(MC_2+LDSA7B+1),l(LDSA7B+1)
  dta h(MC_jsrE+LOSIT),l(LOSIT)

        bmi LOSER3
        lda <INITAD
LOSOK   jsr LDRUN
        cld
        ldy #$01
        rts

LOSDVA  jsr MOV_CAL
  dta b(MC_cpyE+2,K0002-DAT_BUF,LDSALEN-DAT_BUF)

LOSIT   ldy #$2E
LOSIT2  ldx #$00
        stx RWFLG
LOSIT3  ldx #$00
        jmp XIO

LDRUN   ldx #$00
        bmi LOSER3
        sta DORUN+1
DORUN   jmp (RUNAD)
