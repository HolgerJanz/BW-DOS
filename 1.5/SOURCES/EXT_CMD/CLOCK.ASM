* BW-DOS command CLOCK.SYS ON|OFF

        ICL '_SYSEQU.ICL'

SRCHADR EQU 128
RELZP   EQU 130

        ORG $3000
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
        JMP CIOV

GETNAME JMP PRTEX

START   EQU *
        ICL '_TSTBW15.ICL'

        LDA 10
        CLC
        ADC #3
        STA GETNAME+1
        LDA 11
        ADC #0
        STA GETNAME+2
        JSR GETNAME

        LDY #36
        LDA BW_COMTAB,Y
        CMP #'O'
        BNE SYNTAX

        INY
        LDA BW_COMTAB,Y
        CMP #'N'
        BEQ ST2ON
        CMP #'F'
        BNE SYNTAX
* OFF?
        INY
        CMP BW_COMTAB,Y
        BNE SYNTAX

        INY
        LDA BW_COMTAB,Y
        CMP #$9B
        BNE SYNTAX
        JMP DISABLE
* ON?
ST2ON   INY
        LDA BW_COMTAB,Y
        CMP #$9B
        BEQ START3

SYNTAX  JSR PRINT
        DTA B(155)
        DTA C'Syntax: CLOCK ON|OFF'
        DTA B(155,0)

        JMP BW_COMTAB

* already installed?
START3  JSR SRCHRUT
        BCC START4
* yes!
        JSR PRINT
        DTA B(155)
        DTA C'Clock already installed!'
        DTA B(155,0)
        JMP BW_COMTAB

* install
START4  LDA MEMLO
        STA SRCHADR
        CLC
        ADC <RESLEN
        STA MEMLO
        STA R01+1

        LDA MEMLO+1
        STA SRCHADR+1
        ADC #0
        STA MEMLO+1
        STA R02+1

* PAL or NTSC

* PAL
        LDX #8
        LDA PAL
        AND #$0E
        BEQ PALNT2
* NTSC
        LDX #17

PALNT2  LDY #8

PALNT3  LDA TDPMLTO,X
        STA TDPMLT,Y

        DEX
        DEY
        BPL PALNT3
        BMI RLK0

* PAL
TDPMLTO DTA B(0,0,50)
        DTA B(0,11,$B8)
        DTA B(2,$BF,32)
* NTSC
        DTA B(0,0,60)
        DTA B(0,14,$10)
        DTA B(3,$4B,$C0)

* reloc

RLK0    LDX #0

RLK1    LDA RELOKT,X
        STA RELZP
        LDA RELOKT+1,X
        STA RELZP+1

        ORA RELZP
        BEQ INSTAL2

        LDA RELOKT+2,X
        SEC
        SBC <RESID
        TAY
        LDA RELOKT+3,X
        SBC >RESID
        PHA

        TYA
        LDY #1

        CLC
        ADC SRCHADR
        STA (RELZP),Y
        INY
        PLA
        ADC SRCHADR+1
        STA (RELZP),Y

        INX
        INX
        INX
        INX

        JMP RLK1

GETTDJ  JMP (BW_GETTD)
SETTDJ  JMP (BW_SETTD)


INSTAL2 JSR GETTDJ

        LDX #3
INST2B  LDA BW_GETTD,X
        STA OLDADR,X
        DEX
        BPL INST2B

        LDY <RESLEN

INSTL2  DEY
        LDA RESID,Y
        STA (SRCHADR),Y

        TYA
        BNE INSTL2

        LDY #2
INSTL3  LDA DOSINI-1,Y
        STA (SRCHADR),Y
        LDA SRCHADR-1,Y
        STA DOSINI-1,Y

        DEY
        BNE INSTL3

        LDX #3
INSTL4  LDA NEWADR,X
        STA BW_GETTD,X
        DEX
        BPL INSTL4

        JSR SETTDJ

        JSR PRINT
        DTA B(155)
        DTA C'Clock installed.'
        DTA B(155,0)

        JMP BW_COMTAB

DISABLE JSR SRCHRUT
        BCS DISABL2

        JSR PRINT
        DTA B(155)
        DTA C'Clock not installed!'
        DTA B(155,0)

        JMP DISERR2

DISCANT JSR PRINT
        DTA B(155)
        DTA C'Clock is not the last installed handler!'
        DTA B(0)

DISERR2 JSR PRINT
        DTA C'Can''t be removed.'
        DTA B(155,0)

        JMP BW_COMTAB

DISABL2 LDA MEMLO
        SEC
        SBC SRCHADR
        TAY
        LDA MEMLO+1
        SBC SRCHADR+1
        BNE DISCANT

        CPY <RESLEN
        BNE DISCANT

* remove
        LDY #2

DISBL2  LDA (SRCHADR),Y
        STA DOSINI-1,Y
        LDA SRCHADR-1,Y
        STA MEMLO-1,Y

        DEY
        BNE DISBL2

        LDY <OLDADR-RESID
        LDX #0

DISABL3 LDA (SRCHADR),Y
        STA BW_GETTD,X
        INY
        INX
        CPX #4
        BCC DISABL3

        JSR PRINT
        DTA B(155)
        DTA C'Clock removed.'
        DTA B(155,0)

        JMP BW_COMTAB

SRCHRUT LDA MEMLO
        SEC
        SBC <RESLEN
        STA SRCHADR
        LDA MEMLO+1
        SBC #0
        STA SRCHADR+1

SRCHR1  LDY <S1-RESID

SRCHR2  LDA (SRCHADR),Y
        CMP RESID,Y
        BNE SRCHNXT

        DEY
        CPY <TST1-RESID
        BNE SRCHR2

        LDY <TDPLMI-RESID

SRCHR3  LDA (SRCHADR),Y
        CMP RESID,Y
        BNE SRCHNXT

        DEY
        CPY <TST2-RESID
        BNE SRCHR3

        LDY <S19-RESID

SRCHR4  LDA (SRCHADR),Y
        CMP RESID,Y
        BNE SRCHNXT

        DEY
        CPY <TST3-RESID
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
        STA MEMLO
R02     LDA #$22
TST1    STA MEMLO+1

TDINI   LDA VCOUNT
        CMP #$60
        BCS TDINI

        SEC
        LDX #2

TDIN2   LDA RTCLOK,X
        PHA

S1      SBC TDOLDS,X
S2      STA TDDIF,X

        PLA
S3      STA TDOLDS,X

        DEX
        BPL TDIN2

        RTS

OLDADR  DTA A(0,0)

SETTD   LDY #18

STD5    LDX TDPOR-13,Y
        LDA BW_COMTAB,Y
S5      STA TDOLDT,X

TST2    DEY
        CPY #13
        BCS STD5
        BCC TDINI

TDPLMI  STA TDPLMC

TDPLIX  LDY #0
S7      LDX TDPMIT,Y

        LDY #2

TDPLM2  LDA TDDIF,Y
TDPLMC  SBC TDPMLT,X
S10     STA TDDIF,Y

        DEX
        DEY
        BPL TDPLM2

        RTS

TDPMIT  DTA B(2,5,8)

TDPOR   DTA B(3,4,5,2,1)

TDPMLT  DTA B(0,0,50)
        DTA B(0,11,$B8)
        DTA B(2,$BF,32)

TDMAX   DTA B(60,60,24,32,13,100)

TDDIF   DTA B(0,0,0)
TDOLDS  DTA B(0,0,0)

* DEFAULT TD
TDOLDT  DTA B(15,12,42)
        DTA B(15,2,24)

GETTD   JSR TDINI

        LDA #2
S12     STA TDPLIX+1

GTD1    LDA #$FD
        SEC
S13     JSR TDPLMI
        BCC GTD4

S14     LDY TDPLIX+1
GTD2    LDA TDOLDT,Y
        ADC #0

        CPY #6
        BCS GTD1

S16     CMP TDMAX,Y
        BCC GTD3

S17     LDA TDMIN,Y

GTD3    STA TDOLDT,Y
TST3    INY

        BCS GTD2
        BCC GTD1

GTD4    LDA #$7D
S19     JSR TDPLMI

S20     DEC TDPLIX+1
        BPL GTD1

        LDY #13

GTD5    LDX TDPOR-13,Y
S22     LDA TDOLDT,X
        STA BW_COMTAB,Y

        INY
        CPY #19
        BCC GTD5

        LDY #2

GTD6    LDA TDOLDS,Y
S24     SBC TDDIF,Y
S25     STA TDOLDS,Y

        DEY
        BPL GTD6

RET     RTS

TDMIN   DTA B(0,0,0,1,1,0)

RESLEN  EQU *-RESID

NEWADR  DTA A(0,0)

RELOKT  DTA A(S1,TDOLDS)
        DTA A(S2,TDDIF)
        DTA A(S3,TDOLDS)
        DTA A(STD5,TDPOR-13)
        DTA A(S5,TDOLDT)
        DTA A(TDPLMI,TDPLMC)
        DTA A(S7,TDPMIT)
        DTA A(TDPLM2,TDDIF)
        DTA A(TDPLMC,TDPMLT)
        DTA A(S10,TDDIF)
        DTA A(GETTD,TDINI)
        DTA A(S12,TDPLIX+1)
        DTA A(S13,TDPLMI)
        DTA A(S14,TDPLIX+1)
        DTA A(GTD2,TDOLDT)
        DTA A(S16,TDMAX)
        DTA A(S17,TDMIN)
        DTA A(GTD3,TDOLDT)
        DTA A(S19,TDPLMI)
        DTA A(S20,TDPLIX+1)
        DTA A(GTD5,TDPOR-13)
        DTA A(S22,TDOLDT)
        DTA A(GTD6,TDOLDS)
        DTA A(S24,TDDIF)
        DTA A(S25,TDOLDS)

        DTA A(NEWADR-1,GETTD)
        DTA A(NEWADR+1,SETTD)

        DTA A(0,0)

        END
