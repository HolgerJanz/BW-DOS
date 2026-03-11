* BW-DOS command XFSIO.SYS
* XF-551 High Speed SIO

        ICL '_SYSEQU.ICL'

SRCHADR EQU 128
REFLAG  EQU 130
SIOADR  EQU 131

        BLK DOS $3000
        JMP START

PRINT   PLA
        STA PRINT3+1
        PLA
        STA PRINT3+2

PRINT2  INC PRINT3+1
        BNE PRINT3
        INC PRINT3+2

PRINT3  LDA $FFFF
        BEQ PRINT4

        JSR PRT1
        JMP PRINT2

PRINT4  LDA PRINT3+2
        PHA
        LDA PRINT3+1
        PHA

PRTEX   RTS

PRT1    TAY

        LDA #0
        TAX
        STA $348,X
        STA $349,X

        LDA #11
        STA $342,X

        TYA
        JMP $E456

GETNAME JMP PRTEX

DTAB    DTA A(0,0)

START   EQU *
        ICL '_TSTBW15.ICL'

        LDA 10
        CLC
        ADC #3
        STA GETNAME+1
        LDA 11
        ADC #0
        STA GETNAME+2

        LDA 10
        SEC
        SBC #10
        STA SIOADR
        LDA 11
        SBC #0
        STA SIOADR+1

        LDA #0
        LDX #3
STRT3   STA DTAB,X
        DEX
        BPL STRT3

        JSR GETNAME

        LDY #36
        LDA (10),Y
        CMP #'O'
        BNE STRT4

        LDA #'F'
        INY
        CMP (10),Y
        BNE STRT4
        INY
        CMP (10),Y
        BNE STRT4

        LDA #$9B
        INY
        CMP (10),Y
        BNE STRT4

        JMP DISABLE

HELP    JSR PRINT
        DTA B(155)
        DTA C'Syntax: XFSIO drive_number(s)'
        DTA B(155)
        DTA C'        XFSIO OFF'
        DTA B(155,0)

        JMP (10)

SYNTAX  JSR PRINT
        DTA B(155)
        DTA C'Syntax Error'
        DTA B(155,0)
* XDIV
        LDY #8
        LDA (10),Y
        STA ERR5Y+1
        INY
        LDA (10),Y
        STA ERR5Y+2
        LDY #1
ERR5Y   JSR $E474

        JMP (10)

STRT4   LDY #36
        LDA (10),Y
        CMP #$9B
        BEQ HELP

STRT5   LDA (10),Y
        CMP #$9B
        BEQ STRT6

        SEC
        SBC #'1'
        CMP #4
        BCS SYNTAX

        TAX
        INY

        LDA #$FF
        STA DTAB,X
        BNE STRT5

STRT6   LDA #0
        STA REFLAG

STRT6A  LDY REFLAG
        LDA DTAB,Y
        BPL STRT6C

        LDX #11
STRT6B  LDA DRITST,X
        STA $300,X
        DEX
        BPL STRT6B

        INY
        STY $301

        LDA $20A
        STA ST6IQJ+1
        PHA
        LDA $20B
        STA ST6IQJ+2
        PHA

        LDA <ST6IRQ
        STA $20A
        LDA >ST6IRQ
        STA $20B

        JSR $E459

        PLA
        STA $20B
        PLA
        STA $20A

        TYA
        BPL STRT6C

        JSR PRINT
        DTA B(155)
        DTA C'Drive '
        DTA B(0)

        LDY REFLAG
        LDA #0
        STA DTAB,Y

        TYA
        CLC
        ADC #'1'
        JSR PRT1

        JSR PRINT
        DTA C' is not XF 551.'
        DTA b(0)

STRT6C  INC REFLAG
        LDA REFLAG
        CMP #4
        BCC STRT6A
        BCS STRT6D

ST6IRQ  LDA #$10
        STA $D204
ST6IQJ  JMP $FFFF

DRITST  DTA B($31,0,$CE,$40)
        DTA A($500)
        DTA B(7,0)
        DTA A(12,1)

STRT6D  LDA #255
        STA REFLAG

        JSR SRCHRUT
        BCS STRT7

* install
        INC REFLAG

        LDA 743
        STA SRCHADR
        CLC
        ADC <RESLEN
        STA 743
        STA R01+1

        LDA 744
        STA SRCHADR+1
        ADC #0
        STA 744
        STA R02+1
* relok
        LDA <RESTAB-RESID
        CLC
        ADC SRCHADR
        STA R03+1
        LDA #0
        ADC SRCHADR+1
        STA R03+2

        LDA <IRQ-RESID
        CLC
        ADC SRCHADR
        STA R04+1
        LDA #0
        ADC SRCHADR+1
        STA R05+1

        LDY #1

INSTL1  LDA (SIOADR),Y
        STA PUVSIO+1,Y

        LDA $20A,Y
        STA IRQJP+1,Y

        DEY
        BPL INSTL1

        LDY <RESLEN

INSTL2  DEY
        LDA RESID,Y
        STA (SRCHADR),Y

        TYA
        BNE INSTL2

        LDY #2
INSTL3  LDA 11,Y
        STA (SRCHADR),Y

        LDA SRCHADR-1,Y
        STA 11,Y

        DEY
        BNE INSTL3

        LDA SRCHADR
        CLC
        ADC <XFSIO-RESID
        STA (SIOADR),Y
        INY
        LDA SRCHADR+1
        ADC #0
        STA (SIOADR),Y

STRT7   LDY <RESTAB-RESID+3
        LDX #3

STRT8   LDA DTAB,X
        STA (SRCHADR),Y
        DEY
        DEX
        BPL STRT8

        LDA REFLAG
        BMI REINTXT

        JSR PRINT
        DTA B(155)
        DTA C'XF 551 SIO: Installed.'
        DTA B(155,0)

        JMP (10)

REINTXT JSR PRINT
        DTA B(155)
        DTA C"XF 551 SIO: Configuration changed."
        DTA B(155,0)

        JMP (10)

DISABL1 JMP DISABL2

DISABLE JSR SRCHRUT
        BCS DISABL1

        JSR PRINT
        DTA B(155)
        DTA C'XF 551 SIO: Not Installed!'
        DTA B(155,0)

        JMP DISERR2

DISCANT JSR PRINT
        DTA B(155)
        DTA C'XF 551 SIO: Is not the last handler!'
        DTA B(155,0)

DISERR2 JSR PRINT
        DTA C'Cannot be removed.'
        DTA B(155,0)

        JMP (10)

DISABL2 LDA 743
        SEC
        SBC SRCHADR
        TAY
        LDA 744
        SBC SRCHADR+1
        BNE DISCANT

        CPY <RESLEN
        BNE DISCANT

* remove
        LDY #2

DISBL2  LDA (SRCHADR),Y
        STA 11,Y

        LDA SRCHADR-1,Y
        STA 743-1,Y

        DEY
        BNE DISBL2

        LDY <PUVSIO-RESID+1
        LDA (SRCHADR),Y
        TAX
        INY
        LDA (SRCHADR),Y

        LDY #1
        STA (SIOADR),Y
        DEY
        TXA
        STA (SIOADR),Y

        JSR PRINT
        DTA B(155)
        DTA C'XF 551 SIO: Removed.'
        DTA B(155,0)

        JMP (10)

SRCHRUT LDA 743
        SEC
        SBC <RESLEN
        STA SRCHADR
        LDA 744
        SBC #0
        STA SRCHADR+1

SRCHR1  LDY <R03-RESID

SRCHR2  LDA (SRCHADR),Y
        CMP RESID,Y
        BNE SRCHNXT

        DEY
        CPY <TST1-RESID
        BNE SRCHR2

        LDY <R04-RESID

SRCHR3  LDA (SRCHADR),Y
        CMP RESID,Y
        BNE SRCHNXT

        DEY
        CPY <XFSIO2-RESID
        BNE SRCHR3

        LDY <IRQJP-RESID

SRCHR4  LDA (SRCHADR),Y
        CMP RESID,Y
        BNE SRCHNXT

        DEY
        CPY <TST2-RESID
        BNE SRCHR4

        RTS

SRCHNXT LDA SRCHADR
        BNE SNXT2
        DEC SRCHADR+1
SNXT2   DEC SRCHADR


        LDA SRCHADR+1
        CMP BW_SMEMLO+1
        BCC SNXT3
        BNE SRCHR1
        LDA SRCHADR
        CMP BW_SMEMLO
        BCS SRCHR1

SNXT3   RTS

RESID   JSR $FFFF

R01     LDA #$22
        STA 743
R02     LDA #$22
TST1    STA 744

        RTS

XFSIO   LDA $300
        CMP #$31
        BNE PUVSIO

        LDX $301
        DEX
        CPX #4
        BCS PUVSIO

R03     LDA RESTAB,X
        BMI XFSIO2

PUVSIO  JMP $FFFF

XFSIO2  LDA $20A
        PHA
        LDA $20B
        PHA

        LDA $302
        PHA

        BMI XFSIO3
        CMP #$23
        BCC XFSIO3

        ORA #$80
        STA $302

R04     LDA <IRQ
        STA $20A
R05     LDA >IRQ
TST2    STA $20B

XFSIO3  LDA $10
        PHA
        AND #$80
        STA $10
        STA $D20E

        JSR $E459

        PLA
        STA $10
        STA $D20E

        PLA
        STA $302

        PLA
        STA $20B
        PLA
        STA $20A

        TYA
        RTS

IRQ     LDA #$10
        STA $D204

IRQJP   JMP $FFFF

RESTAB  DTA A(0,0)

RESLEN  EQU *-RESID

        END
