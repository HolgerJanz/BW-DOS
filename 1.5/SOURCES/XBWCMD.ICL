* execute commands

* command PRINT
CPPRT   bne DIVIO0
CPPRT_V equ CPPRT-1
        lda COMFNAM
        cmp PROMPTD
        bne DIVIO0

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
DIVIO0   ldy #$00
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

* vector tab for commands called via RTS opcode
CPACMDL dta l(CPCAR_V,CPRUN_V,CPPRT_V,CPTYP_V)
        dta l(CPDIR_V,CPDIRS_V,CPBAS_V)
CPACMDH dta h(CPCAR_V,CPRUN_V,CPPRT_V,CPTYP_V)
        dta h(CPDIR_V,CPDIRS_V,CPBAS_V)


EXE2    jsr EXE2B
* begin statement table
*  called via CIO command:
        dta c'RE',b($CE)       ; 32
        dta c'DE',b($CC)       ; 33
        dta b($9B)
        dta c'PRO',b($D4)      ; 35
        dta c'UNPRO',b($D4)    ; 36
ERRTX   dta b($9B)
ENAME   dta c'Error',b($9B)
        dta b($9B)
DIO2T3  dta b($90)
        dta b($94)
        dta c'M',b($C4)        ; 42
        dta c'R',b($C4)        ; 43
        dta c'C',b($C4)        ; 44
        dta c'LOA',b($C4)
*  called via CPACMDH/L
        dta c'CA',b($D2)
        dta c'RU',b($CE)
        dta c'PRIN',b($D4)
        dta c'TYP',b($C5)
        dta c'DI',b($D2)
        dta c'DIR',b($D3)
        dta c'BASI',b($C3)
        dta b($00)

        jsr NULDW
* standard execute *.com
        ldy <EXT_COM-LBUF
        jsr CROUTI
        clc
EXELD   lda #$04 
        rol @
        sta EXELD2
        jsr CPC4
EXELD2  dta b($08,$28)
        dta a(COMFNAM,28)
EXE9RTS rts

* execute internal commands
EXE2B   ldx #$FF
        stx L0043
EXE3    ldx #$00
        ldy #$00
        inc L0043
EXE4    jsr GETSTK
        pha
        eor COMFNAM+3,Y
        asl @
        beq EXE5
        dex
EXE5    iny
        pla
        beq EXE9RTS
        bpl EXE4
        txa
        bmi EXE3
        lda COMFNAM+3,Y
        cmp #$9B
        bne EXE3
* A=$9B
        pla
        pla
        lda #$0D
        cmp L0043
        bcc EXE8
        php
        lda #$9b
        jsr CRNM00
        plp
        beq EXELD
* C=1
        lda L0043
        ora #$20
        sta EXE7B
        jsr CPC4
        dta b($00)
EXE7B   dta b($00)
        dta a(COMFNAM,28)
        rts

EXE8    ldy L0043
        lda CPACMDH-14,Y
        pha
        lda CPACMDL-14,Y
        pha
        jmp _CRNAME

* commannd DIR/S
CPDIR   lda #$0D
CPDIR_V equ CPDIR-1
        dta b(op_BIT_abs)
CPDIRS  lda #$0C
CPDIRS_V equ CPDIRS-1
        pha
        lda COMFNAM-1,X
        cmp #$38
        beq CPDIRS2
        and #$F9
        cmp #$38
        bne CPDIRS2
* standard *.*
        ldy <STD_PAT-LBUF
        jsr CROUTI
CPDIRS2 pla
        dta b(op_BIT_abs)

* command TYPE
CPTYP   lda #$08
CPTYP_V equ CPTYP-1
        sta CPD2
        jsr CPC4
CPD2    dta b($08,$03)
        dta a(COMFNAM,28)
CPD3    jsr CPCIO
        dta b($44,$07)
        dta a(LBUF)
        dta a(64)
        php

        jsr MOV_CAL
  dta h(MC_movE+IOCB1+ICBLL),l(IOCB1+ICBLL),h(MC_2+CPD3L),l(CPD3L)

        jsr CPCIO
        dta b($40,$0B)
        dta a(LBUF)
CPD3L   dta a(64)

        plp
        bpl CPD3
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

* command RUN
CPRUN   bne CPR1
CPRUN_V equ CPRUN-1
CPRUN2  jmp (RUNLOC)

CPR1    jsr MOV_CAL
  dta h(MC_movE+NULY),l(NULY),h(MC_2+RUNLOC),l(RUNLOC)

CPR2    lda COMFNAM+3,X
        inx
        sec
        sbc #$30
        cmp #$0A
        bcc CPR3
        sbc #$07
        cmp #$10
        bcs CPRUN2
CPR3    asl @
        asl @
        asl @
        asl @
        ldy #$04
CPR4    asl @
        rol RUNLOC
        rol RUNLOC+1
        dey
        bne CPR4
        beq CPR2

* Command CAR
CPCAR   lda CARTFG
CPCAR_V equ CPCAR-1
        inc CARTFG
        cmp CARTFG
        sta CARTFG
        bne CPERR
        ldx CART
        bne CPERR
        lda DWARM
        sta WARMST
        stx INCMND
        dex
        stx DWARM
        jmp (CARTCS)

* toggle BASIC
CPBAS2  sta BASICF
        php
* close editor screen
        jsr CPC192
        dta b($0C)
DIO2T1  dta b($10,$08)
DIO2T2  dta b($40,$50)
* prevent garbage screen
        ldx RTCLOK3
        cpx RTCLOK3
        beq *-2
        sta DMACTL
* set PORTB
        lda PORTB
        ror @
        ror @
        plp
        rol @
        rol @
        sta PORTB
* check RAM, maybe external cartridge
* TRIG3 cannot be used => OS A/B
        ldx #$CF
CPBAS2B txa
        sec
        sbc #$10
        tax
        stx L0044
        eor (L0043),Y
        sta (L0043),Y
        eor (L0043),Y
        bne CPBAS2B
        inx
        stx RAMSIZ
        stx RAMTOP
* reopen editor screen
        jsr CPCIO
        dta b($80,$18,$03)
        dta a(ENAME)
DIOAPUT dta a(0)
* set status (take over from CPCIO above)
NULDW   ldx #$00
        stx DWARM
UNISCH  sta UNIA+1
        php
        pla
        sta UNIOBN+1
        rts

* Command BASIC
CPBAS   lda COMFNAM+3
CPBAS_V equ CPBAS-1
        cmp #'O'
        bne CPERR
        lda COMFNAM+4
        cmp #'F'
        beq CPBAS2
        clc
        eor #'N'
        beq CPBAS2
* cartridge error
CPERR   lda #$9C
* print error and exit to CP
        jmp CPER2
