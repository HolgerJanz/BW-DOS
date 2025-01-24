* command processor and lib

* convert hex to dec
CONV_A  sta DECIN
        lda #$00
        sta DECIN+1
CONV_16 lda #$00
        sta DECIN+2
CONVDC  ldx #$07
COND0   stx CONDI+1
        ldx #$18
        lda #$00
COND1   asl DECIN
        rol DECIN+1
        rol DECIN+2
        rol @
        cmp #$0A
        bcc COND2
        sbc #$0A
        inc DECIN
COND2   dex
        bne COND1
        ora #$30
CONDI   ldx #$00
COND3   sta DECOUT,X
        dex
        bmi RET3
        lda DECIN
        ora DECIN+1
        ora DECIN+2
        bne COND0
        lda #$20
        bne COND3

* crunch name
CRNM2   inc BUFOFF
        dta b(op_BIT_abs)
_CRNAME lda #$20
CRNM00  ldy BUFOFF
        ldx LBUF,Y
        cpx #$20
        beq CRNM2
        sta CRODDE+1
        lda #$00
        sta CROUTI+1
        cpx #$9B
        beq CRNM3
        lda LBUF+1,Y
        cmp #$9B
        beq CRNM3
        cmp #':'
        beq CRNM5
        lda LBUF+2,Y
        cmp #':'
        beq CRNM4
CRNM3   ldy <PROMPTD-LBUF
        jsr CROUTI
CRNM4   ldy BUFOFF
        jsr CROUTI
        sty BUFOFF
CRNMX   cpx #$03
RET3    rts

CRNM5   inc CROUTI+1
        jsr CRNM4
        lda COMFNAM+1
        sta COMFNAM
K31     lda #'1'
        sta COMFNAM+1
        bne CRNMX
CRO1    sta COMFNAM,X
        cpx #$1B
        bcs CRO1B
        inx
CRO1B   iny
        dta b(op_BIT_abs)
CROUTI  ldx #$00
        lda LBUF,Y
        cmp #$9B
        beq CRO3 
CRODDE  cmp #$20
        bne CRO1
CRO3    lda #$9B
        sta COMFNAM,X
        stx CROUTI+1
        rts

RESET   cld
        lda L0047
        bne RESINI
        dec L0047
        bit INCMND
        bpl RESINI
        jsr RINIT
CMTAD   jmp COMTAB

RESINI  jsr MOV_CAL
  dta h(MC_mov+SMEMLO),l(SMEMLO),h(MC_2+MEMLO),l(MEMLO)
  dta h(MC_mov+CMTAD+1),l(CMTAD+1),h(MC_2+DOSVEC),l(DOSVEC)
  dta h(MC_movE+KFFFF),l(KFFFF),h(MC_2+ECHOFLG),l(ECHOFLG)

* MAZE - LAST1 FCBIOCB (never mind)
*      - SEC1CHG
*      - DCBs
*      - FCBs = $FF
*      - BUFDRIV - BUFTIME

* X=0
        txa
RESI1   sta FCBDIRP+1,X
        cpx #$97
        bcc RESI1B
        dec FCBMAPX+1,X
RESI1B  inx
        bne RESI1
* drive# do DCB (A=0, X=0)
        tay
        dta b(op_BIT_abs)
RESI3   ldy #$07
RESI4   iny
        tya
        sta DCBDRIV,X
        txa
        clc
        adc #$1A
        tax
        cpy #$04
        bcc RESI4
        beq RESI3
* A=5*26=130 (->MI)
        ldy #$1E
RESI5   ldx HATABS,Y
        bne RESI6
        tya
RESI6   cpx #'D'
        beq RESI7
        dey
        dey
        dey
        bpl RESI5
        tay
        bmi RET2
RESI7   ldx #$FD
RESI8   lda RESITAB-$FD,X
        sta HATABS,Y
        iny
        inx
        bne RESI8
RET2    rts

* set time date
SETTD   jsr MOV_CAL
  dta h(MC_movE+DATER),l(DATER),h(MC_6+INTDATE),l(INTDATE)
* get time data
GETTD   jsr MOV_CAL
  dta h(MC_movE+INTDATE),l(INTDATE),h(MC_6+DATER),l(DATER)
RET     rts

ADC_L   lda LDSA7C+1
        dta b(op_BIT_abs)
ADC_1   lda #$01
        ldx #op_ADC_imd
        bne DIC2
SBC_1   lda #$01
SBC_A   ldx #op_SBC_imd
DIC2    sta DIC6+1
        stx DIC6
        ldx #$FE
DIC3    jsr GETSTK
        sta DIC5+1-$FE,X
        sta DIC7+1-$FE,X
        inx
        bne DIC3
        lda DIC6
        asl @
        dex
DIC4    inx
DIC5    lda $FFFF,X
DIC6    adc #$00
DIC7    sta $FFFF,X
        stx DIC6+1
        txa
        beq DIC4
        rts

* get parameter from stack
GETSTK  stx GST4+1
        sty GST5+1
        tsx
        inc $103,X
        ldy $103,X
        bne GST2
        inc $104,X
GST2    lda $104,X
        sta GST3+2
GST3    lda $FF00,Y
GST4    ldx #$00
GST5    ldy #$00
        rts

UNIUC2  jsr GETSTK
        ldx #$03
        dta b(op_BIT_abs)
UNIUC   ldx #$00
        pha
        and #$1F
        sta UNIUCL+2,X
        pla
        lsr @
        lsr @
        lsr @
        lsr @
        lsr @
        sta UNIUC1+1
        jsr GETSTK
        sta UNIUCL+1,X
        txa
        beq UNIUC2
UNIUC1  ldx #$00
UNIUC3  dex
UNIUCL  lda $FFFF,X
        sta $FFFF,X
        txa
        bne UNIUC3
        tya
        bmi UNIUCE

MOV_CAL jsr UNISCH
UNI1    jsr GETSTK
        tay
        asl @
        asl @
        php
        tya
        and #$1F
        plp
        bcs UNIUC
        bmi UNIUCS
        sta UNI1CL+2
        jsr GETSTK
        sta UNI1CL+1
        tya
        pha
        jsr UNIOBN
UNI1CL  jsr UNIRTS
        jsr UNISCH
        pla
        bpl UNI1
UNIOBN  lda #$00
        pha
UNIA    lda #$00
        plp
UNIRTS  rts

UNIUCS  sta UNIA+1
        sty UNIUCS3+1
        jsr GETSTK
        tax
        jsr GETSTK
        tay
UNIUCS2 lda DAT_BUF,X
        sta DAT_BUF,Y
        inx
        iny
        dec UNIA+1
        bne UNIUCS2
UNIUCS3 lda #$00
        bpl MOV_CAL
UNIUCE  ldx #$00
        rts

* prepare and call CIO
CPCIO   jsr GETSTK
        dta b(op_BIT_abs)
CPC192  lda #$C0
        dta b(op_BIT_abs)
CPC4    lda #$04
CPCIO1  sta L0044
        asl @
        asl @
        tax
        tay
        bcs CPCIO2
* AUXs
        jsr GETSTK
        lsr @
        sta IOCB0+ICAX1,X
        lda #$00
        ror @
        sta IOCB0+ICAX2,X
CPCIO2  lda #$67
        sta L0043
CPCIO3  jsr GETSTK
        sta IOCB0+ICCOM,Y
CPCIO4  iny
        asl L0043
        bcc CPCIO4
        bne CPCIO3
        lda L0044
        pha
        lda #$20
        jsr CIOV
        pla
        tax
        tya
        bpl CPCIOX
        cmp #$88
        beq CPCIOX
* ERR
        pha
        txa
        pha
        and #$1C
        beq CPCIO8
        ora #$C0
        jsr CPCIO1
        dta b($0C)
DIOAPUV dta a(0,0)
CPCIO8  pla
        bpl CPCER
        pla
CPCIOX  tay
        rts

* print error and exit to CP
CPER2   pha
* print error number
CPCER   jsr CPC192
        dta b($0B)
        dta a(ERRTX,6)
        pla
        jsr CONV_A
        jsr CPC192
        dta b($0B)
        dta a(DECOUT+4,4)
        jsr CPC192
        dta b($0B)
        dta a(ERRTX,1)
        jsr XDIVIO1

* command processor
CP      cld
        jsr DIOREP
* X=0
        stx LMARGN
        stx TDOVER
        stx BUFOFF
        dex
        stx INCMND
        txs
* close IOCB1
        jsr CPCIO
        dta b($C4,$0C)
DIOANEW dta a(EGET_V,EPUT_V)
* print prompt
        jsr CPC192
        dta b($0B)
        dta a(PROMPT,4)
* get command line
        jsr CPCIO
        dta b($40,$05)
        dta a(LBUF,$40)
* execute
        jsr EXECUTE
        jmp CP


EGETP   jmp (DIOAPUV)
EPUTP   jmp (DIOAPUV+2)

EGEE    jsr XDIVIO1
EGET    txa
EGET_V  equ EGET-1
        bne EGETP
        bit BATFLG
        bpl EGE2
        jsr EGETP
        cpy #$00
        bpl EPU2
        rts

EGE2    ldy #$01
        ldx #$05
        jsr DIVHND
        cpy #$00
        bmi EGEE
        ldx #$00
EPUT    cpx #$00
EPUT_V  equ EPUT-1
        bne EPUTP
        pha
        jsr EPUTP
        pla
EPU2    bit ECHOFLG
        bmi EPUTY
        pha
        ldy #$00
        ldx #$07
        jsr DIVHND
        cpy #$00 
        bpl EPUTX
        jsr XDIVIO0
EPUTX   pla
DIO2X0  ldy #$01
EPUTY   ldx #$00
        cpy #$00
DIO2EX  rts

* disable
DIORDIS jsr MOV_CAL
* $ff is updated at start with offset for E:
DIORA3 dta h(MC_mov+DIOR2+1),l(DIOR2+1),h(MC_2+HATABS),b($FF)
       dta h(MC_movE+DIOAPUT),l(DIOAPUT),h(MC_2+IOCB0+ICPTL),l(IOCB0+ICPTL)

DIO2X0EQ beq DIO2X0
R_DIVIO  jsr R_XDIVIO
DIO2    ldy #$00
        lda DIO2T1,Y
        sta DIO3
        lda DIO2T3,Y

        jsr CPCIO1
DIO3    dta b($08,$03)
        dta a(COMFNAM,$1C)

        bmi DIO2EX
        lda #$00
DIO3B   ldy DIO2+1
        ldx DIO2T2,Y
        ora IOCB0,X
        sta ECHOFLG,Y
        lda #$FF
        sta IOCB0,X
DIOREP  lda HATABS+2
        cmp >ETAB
        beq DIOR4

        jsr MOV_CAL
* $ff is updated at start with offset for E:
DIORA1 dta h(MC_movE+HATABS),b($FF),h(MC_2+DIOR2+1),l(DIOR2+1)

        ldx #$0B
DIOR2   lda $FFFF,X
DIOR3   sta ETAB,X
        dex
        bpl DIOR2

        jsr MOV_CAL
  dta h(MC_mov+EGETV),l(EGETV),h(MC_4+DIOAPUV),l(DIOAPUV)
  dta h(MC_mov+EPUTV),l(EPUTV),h(MC_2+DIOAPUT),l(DIOAPUT)
  dta h(MC_movE+DIOANEW),l(DIOANEW),h(MC_4+EGETV),l(EGETV)

        jsr ADC_1
        dta a(DIOAPUV)

        jsr ADC_1
        dta a(DIOAPUV+2)

DIOR4   lda ECHOFLG
        and BATFLG
        bmi DIORDIS

        jsr MOV_CAL
* $ff is updated at start with offset for E:
DIORA2  dta h(MC_mov+DIOR3+1),l(DIOR3+1),h(MC_2+HATABS),b($FF)
        dta h(MC_movE+EPUTV),l(EPUTV),h(MC_2+IOCB0+ICPTL),l(IOCB0+ICPTL)

        beq DIO2X0EQ
