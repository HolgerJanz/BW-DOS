* execute commands

XDIVIO0 ldy #$00
        dta b(op_BIT_abs)
XDIVIO1 ldy #$01
R_XDIVIO tya
        and #$01
        tay
        sty DIO2+1
        lda ECHOFLG,Y
        bmi DIOREP
        ldx #$03
        jsr DIVHND
        lda #$FF
        bmi DIO3B
EXBAT   lda #$20
        jsr CRNM2
* extension *.bat
        ldy <EXT_BAT-LBUF
        jsr CROUTI
        ldy #$01
        dta b(op_BIT_abs)
DIVIO0  ldy #$00
L0BA2   jsr R_DIVIO
        bpl EXEEX
        jmp CPER2

EXECUTE lda LBUF
        cmp #'-'
        beq EXBAT
        cmp #';'
        beq EXEEX
        jsr _CRNAME
        bne EXE2

        jsr MOV_CAL
  dta h(MC_movE+COMFNAM),l(COMFNAM),h(MC_2+PROMPTD),l(PROMPTD)

EXEEX   rts

EXE2    jsr NULDW
* standard execute *.com
        ldy <EXT_COM-LBUF
        jsr CROUTI
        jsr CPC4
        dta b($08,$28)
        dta a(COMFNAM,28)
        rts

DIVHND  sta L0045
        txa
        pha
        ldx ECHOFLG,Y
        lda HATABS+1,X
        sta L0043
        lda HATABS+2,X
        sta L0044
        ldx DIO2T2,Y
        pla
        tay
        lda (L0043),Y
        pha
        dey
        lda (L0043),Y
        pha
        lda L0045
        rts

DIOAPUT dta a(0)

* set status (take over from CPCIO above)
NULDW   ldx #$00
        stx DWARM
UNISCH  sta UNIA+1
        php
        pla
        sta UNIOBN+1
        rts

ERRTX   dta b($9B)
ENAME   dta c'Error'

DIO2T1  dta b($10,$08)
DIO2T2  dta b($40,$50)
DIO2T3  dta b($90,$94)

