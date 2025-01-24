
UPDBK   DEX
        CPX #$FF
        BEQ UPDNO
        RTS
UPDNO   JMP TABLP

UPDIR   LDX #0
UPD1    LDA P,X
        CMP #155
        BEQ UPD2

        INX
        BNE UPD1

UPD2    JSR UPDBK

UPD2B   JSR UPDBK
        LDA P,X
        CMP #'>'
        BNE UPD2B

        TXA
        PHA
        LDY #0
UPD2C   LDA P+1,X
        CMP #155
        BEQ UPD2CB
        STA DATB,Y
        INX
        INY
        BNE UPD2C

UPD2CB  STA DATB-1,Y
        PLA
        TAX

        LDA #155
        STA P+1,X

        JSR CONVFNM
        LDX #10
UPD2D   LDA F,X
        STA UPDNAM,X
        DEX
        BPL UPD2D

        JSR SAMETST

        JSR NEWDIR

        LDX #10
UPD2E   LDA UPDNAM,X
        STA F,X
        DEX
        BPL UPD2E
        STX PTTP
        JSR SELDSR
        LDA #0
        BCS UPD2F
        LDA PTTP

UPD2F   JSR PLACE

GOTAB   JMP TABLP

MKDIR   JSR CLLIN

        LDA <MDTX
        LDX >MDTX
        LDY #20
        JSR INIS2S

        LDX #16
        LDY #20
        LDA #12
        JSR EDIT

        TAX
        BMI GOTAB

        JSR CONVFNM

        JSR SAMETST

        LDA #42
        JSR BXIO
        BMI MKDER

        JMP NEWLP
MKDER   JMP ERR

SRCH    INC EXP

SRCHOD  LDA EXP
        CMP DIRPOC
        BCC SRCH2

        LDA #255
        RTS
SRCH2   JSR DIRADR
        LDY #0
        LDA (MT1),Y
        AND #8
        BNE SRCH

        RTS

EXE     STY EXEJP+1
        STX EXEJP+2
        STA EXF

        JSR ZEROL
        JSR SAMETST
        JSR CLLIN

        LDA #$FF
        STA EXP

        JSR SRCH
        BMI EXENE

EXE2    LDA EXP
        JSR EXEN2
        BCC EXE2B

        LDA EXP
        JSR ODOZN

EXE2B   JSR SRCH
        BPL EXE2
        BMI EXE3
EXENE   LDA MDP
        JSR EXEN2
EXE3    LDA EXF
        BPL GOTAB
EXE4    JSR NEWLP

EXEN2   STA EXP
        JSR COPPLC2

EXEJP   JSR $E474
        BMI EXEN2E
        RTS
EXEN2E  JMP ERR


GETNAME LDY #6

EXEN2B  LDA (MT1),Y
        STA F-6,Y
        INY
        CPY #17
        BCC EXEN2B

        RTS

DLDIR   LDY <RDLD
        LDX >RDLD
        LDA #255
        JMP EXE

RDLD    LDY #0
        LDA (MT1),Y
        AND #32
        BEQ RDENE
        LDA #43
        BNE RER2

RERA    LDY #0
        LDA (MT1),Y
        AND #32
        BNE RDENE

        LDA #33
RER2    JSR BXIO
        SEC
        RTS

RDENE   CLC
        RTS


ERASEC  LDY <RERA
        LDX >RERA
        LDA #255
        JMP EXE

PROTEC  LDY <RPRO
        LDX >RPRO
        LDA #0
        JMP EXE

UNPROTC LDY <RUNPR
        LDX >RUNPR
        LDA #0
        JMP EXE

RPRO    LDX #35
        LDA #1
        BNE RPRUN
RUNPR   LDX #36
        LDA #0

RPRUN   LDY #0
        STA PTTI
        LDA (MT1),Y
        AND #254
        ORA PTTI
        STA (MT1),Y

        TXA
        JMP RER2

RENAMEC JSR CLLIN

        LDA <RNTX
        LDX >RNTX
        LDY #20
        JSR INIS2S

        LDX #11
        LDY #20
        LDA #12
        JSR EDIT

        TAX
        BPL RNM2
        JMP TABLP
RNM2    JSR CONVFNM

        LDX #10
RNM3    LDA F,X
        STA $4C0,X
        DEX
        BPL RNM3

        LDY <RRNM
        LDX >RRNM
        LDA #128
        JMP EXE


RRNM    LDY #0
        LDA (MT1),Y
        AND #32
        BEQ RRNM1
        CLC
        RTS

RRNM1   LDX #10

RRNM2   LDA $4C0,X
        CMP #'?'
        BNE RRNM3
        LDA F,X

RRNM3   STA F2,X

        DEX
        BPL RRNM2

        LDA #255
        STA PTTP

RRNM4C  INC PTTP
        LDA PTTP
        CMP DIRPOC
        BCS RRNM5

        JSR DIRADR

        LDY #6
RRNM4B  LDA (MT1),Y
        CMP F2-6,Y
        BNE RRNM4C

        INY
        CPY #17
        BCC RRNM4B

        LDA PTTP
        CMP EXP
        BEQ RRNM4C

        LDY #151
        JMP ERR
RRNM5   LDA EXP
        JSR DIRADR

        LDY #6
RRNM6   LDA F2-6,Y
        STA (MT1),Y
        INY
        CPY #17
        BCC RRNM6

        JSR BRENAME
        SEC
        RTS

VIEWER  JMP TABLP
VIEWTX  JSR ZEROL

        LDA MDP
        JSR DIRADR

        LDY #0
        LDA (MT1),Y
        AND #32
        BNE VIEWER

        JSR GETNAME

        LDX #0
        LDY #255
        BNE MKT2

MAKETX  JSR CLLIN

        LDA <MTTX
        LDX >MTTX
        LDY #20
        JSR INIS2S

        LDX #10
        LDY #20
        LDA #12
        JSR EDIT

        TAX
        BMI VIEWER

        JSR CONVFNM

        LDX #$E8
MKT2A   DEX
        LDA P,X
        STA P2,X
        TXA
        BNE MKT2A
        DEX
        STX COPPDRV
        LDY #0
MKT2    STX INFLG
        STY OUTFLG
        JSR SAMETST
        JSR REOPNS

        LDA OUTFLG
        STA $2FE

        LDA #0
        STA POS
        STA POS+1
        STA POS+2
        STA COPTOP

* in
MKT3    LDY #0
        STY INPOS
        STY INPOS+1
        STY OUTPOS
        STY OUTPOS+1

        LDA $2E7
        STA RWA
        LDA $2E8
        STA RWA+1

        LDX #$40
        JSR MKTIN

        STY INPOS
        STX INPOS+1

        LDA COPTOP
        BMI MKT4

        LDA MEM2
        STA RWA
        LDA MEM2+1
        STA RWA+1

        LDY $2E5
        LDX $2E6
        JSR MKTIN

        STY OUTPOS
        STX OUTPOS+1

* out
MKT4    LDA $2E7
        STA RWA
        LDA $2E8
        STA RWA+1

        LDY INPOS
        LDX INPOS+1
        JSR MKTOUT

        LDA MEM2
        STA RWA
        LDA MEM2+1
        STA RWA+1

        LDY OUTPOS
        LDX OUTPOS+1
        BNE MKT4B
        TYA
        BEQ MKT4C

MKT4B   JSR MKTOUT
MKT4C   LDA COPTOP
        BPL MKT3
        LDA OUTFLG
        BPL MKT5
        LDA <PRESSK
        STA RWA
        LDA >PRESSK
        STA RWA+1

        LDY #15
        LDX #0
        JSR MKTOUT

        JSR GETKEY


MKT5    JSR INISCR
        JMP NEWLP

MKTIN   TYA
        SEC
        SBC RWA
        STA RWL
        TXA
        SBC RWA+1
        STA RWL+1

        LDA INFLG
        BMI MKTINE

        JSR BREAD
        JMP MKTIN2

MKTINE  LDA #7
        JSR MKTEDIO

MKTIN2  TYA

        LDY RWL
        LDX RWL+1

        CMP #128
        BCC MKTIN3
        CMP #136
        BEQ MKTINEF

        TAY
        JMP ERR
MKTINEF STA COPTOP

MKTIN3  RTS
MKTEDIO LDX #0
        STA $342,X

        LDA RWA
        STA $344,X
        LDA RWA+1
        STA $345,X

        LDA RWL
        STA $348,X
        LDA RWL+1
        STA $349,X

        LDY #1
        ORA RWL
        BEQ MKTENUL

        JSR $E456

MKTENUL LDX #0
        LDA $348,X
        STA RWL
        LDA $349,X
        STA RWL+1

MKTOX   RTS

MKTOUT  STY RWL
        STX RWL+1

        LDA OUTFLG
        BMI MKTOE

        JSR CLTDOV
        JSR OVERTST
        BCS MKTOAB1

        JSR BWRITE
        JMP MKTO2

MKTOAB1 JMP OVRAB


MKTOE   LDA #11
        JSR MKTEDIO

MKTO2   TYA
        BPL MKTOX

        JMP ERR
COPPLAC PHA
        JSR OZNAC
        PLA

COPPLC2 PHA
        JSR PLACE
        PLA
        JSR DIRADR
        JMP GETNAME
OZNAC   CLC
        DTA B($24)
ODOZN   SEC

        PHP
        JSR DIRADR
        LDY #0
        LDA (MT1),Y
        PLP
        BCC OZN2

        ORA #8
        BNE OZN3

OZN2    AND #255-8
OZN3    STA (MT1),Y

CD2XWT  RTS

CD1T    DTA B(16,33)

CD2WT   LDA COPSAME
        BNE CD2XWT

        JSR CLLIN
        LDA <SRCTX
        LDX >SRCTX

        LDY CRA
        BEQ COP2CB
        LDA <DSTTX
        LDX >DSTTX

COP2CB  LDY #20
        JSR INIS2S

        JSR GETKB
        CMP #27
        BNE CD2XWT
        JMP NEWLP

COPDISK STA CRA
        LDY DRIVE
        TAX
        BEQ COPD1
        LDY COPDSTD

COPD1   STY DRIVNUM

        LDA IN1ST,X
        BNE COP2B
        INC IN1ST,X

        TXA
        BEQ COPD1B
        JSR CD2WT

COPD1B  JSR BCHKDSK
        BMI CD2ER

        LDX CRA
        LDY CD1T,X
        LDX #16

COP2A   LDA DSKST2,X
        STA TFST1,Y
        DEY
        DEX
        BPL COP2A
        BMI COP2X
COP2B   JSR CD2WT
        JSR BCHKDSK
        BMI CD2ER

        LDX CRA
        LDY CD1T,X
        LDX #16

COP2D   CPX #14
        BEQ COP2E
        CPX #4
        BEQ COP2E
        CPX #5
        BEQ COP2E

        LDA DSKST2,X
        CMP TFST1,Y
        BNE COP2B

COP2E   DEY
        DEX
        BPL COP2D

COP2X   JMP CLLIN
CD2ER   JMP ERR
COPY    JSR ZEROL

        JSR CLLIN
        LDA <COPTX1
        LDX >COPTX1
        LDY #20
        JSR INIS2S

        JSR DRIVMEN
        STA COPDSTD

        EOR DRIVE
        BNE COPY1

        JSR CLLIN
        LDY <COPMEN
        LDX >COPMEN
        JSR MENU

        EOR #1

COPY1   STA COPSAME

        JSR CLLIN
        LDA <COPTX2
        LDX >COPTX2
        LDY #20
        JSR INIS2S

        LDX #$E8
        LDA #$20
COP1A1  STA DATB-1,X
        DEX
        BNE COP1A1

        LDA COPDSTD
        CMP COPPDRV
        BNE COP1A3

COP1A2  LDA P2,X
        CMP #155
        BEQ COP1A3
        STA DATB,X
        INX
        CPX #$E7
        BCC COP1A2

COP1A3  LDY #20
        LDX #12
        LDA #$E7
        JSR EDIT0

        TAX
        BPL COPOK
        JMP TABLP

COPOK   LDX #$E8
CPY1A   LDA DATB-1,X
        STA P2-1,X
        DEX
        BNE CPY1A

        LDA COPDSTD
        STA COPPDRV

        JSR SAMETST

        LDA #0
        STA OUTFLG
        STA COPNEWF
        STA OUTPOS
        STA OUTPOS+1
        STA OUTPOS+2
        STA IN1ST
        STA OUT1ST
        STA COPENDF

        STA EXP
        JSR SRCHOD
        BPL COP1C

        LDA MDP
        JSR OZNAC

COP1C   LDA #$FF
        STA EXP
        STA CERRF
COPY2   LDA #0
        STA COPTOP
        JSR COPDISK

        LDA $2E7
        STA CRA
        LDA $2E8
        STA CRA+1

        LDX #2
COP2T   LDA INPOS,X
        STA POS,X
        DEX
        BPL COP2T
        BMI COPY3
COP3X   SEC
        ROR COPENDF
COPYWJ  JMP COPYW
COPY3   LDA COPNEWF
        BNE COPY4

        STA POS
        STA POS+1
        STA POS+2
        INC COPNEWF

COP3A   JSR SRCH
        BMI COP3X

        LDA EXP
        JSR DIRADR
        LDY #0
        LDA (MT1),Y
        AND #32
        BNE COP3A
COPY4   LDA CRA
        CMP $2E5
        LDA CRA+1
        SBC $2E6
        BCS COPYWJ

        LDA COPTOP
        CMP #18
        BCS COPYWJ
        LDA EXP
        JSR COPPLAC
        LDA CRA+1
        CMP #$40
        BNE COP4B

        LDA MEM2
        STA CRA
        LDA MEM2+1
        STA CRA+1
COP4B   LDA CRA
        STA RWA
        LDA CRA+1
        STA RWA+1

        LDY #0
        LDX #$40
        CMP #$40
        BCC COP4C
        LDY $2E5
        LDX $2E6

COP4C   TYA
        SEC
        SBC RWA
        STA RWL
        TXA
        SBC RWA+1
        STA RWL+1

        JSR BREAD
        BPL COP4D

        TYA
        EOR #136
        BNE COPERJ

        STA COPNEWF

COP4D   LDX COPTOP
        LDA CRA
        STA TFADRL,X
        LDA CRA+1
        STA TFADRH,X

        LDA RWL
        STA TFLENL,X
        CLC
        ADC CRA
        STA CRA
        LDA RWL+1
        STA TFLENH,X
        ADC CRA+1
        STA CRA+1

        LDA EXP
        STA TFF,X

        INC COPTOP
        JMP COPY3
COPERJ  JMP ERR

COPYW   LDX #2
COP4E   LDA POS,X
        STA INPOS,X
        DEX
        BPL COP4E
        INX
        STX COPIX
        CPX COPTOP
        BNE CW2
CWEX    LDA COPENDF
        BEQ CWEX2
        JMP NEWLP
CWEX2   JMP COPY2
CW2     LDA #1
        JSR COPDISK

        LDX #2
CW2B    LDA OUTPOS,X
        STA POS,X
        DEX
        BPL CW2B

CW3     LDX COPIX
        CPX COPTOP
        BEQ CWEX
        LDA TFF,X
        CMP OUTFLG
        BEQ CW3B

CW3A    LDY #0
        STY POS
        STY POS+1
        STY POS+2

CW3B    STA OUTFLG
        JSR COPPLAC
        LDA #0
        STA INFLG

        LDY #17

CW3BB   LDA (MT1),Y
        INY
        INY
        STA (10),Y
        ORA INFLG
        STA INFLG

        DEY
        CPY #23
        BCC CW3BB

        LDA INFLG
        BEQ CW3BC
        LDA #$FF
CW3BC   JSR CLTDOV2
        LDX COPIX
        LDA TFADRL,X
        STA RWA
        LDA TFADRH,X
        STA RWA+1
        LDA TFLENL,X
        STA RWL
        LDA TFLENH,X
        STA RWL+1
        JSR OVERTST
        BCC CW3BD
* skip
        JSR CLTDOV

CW3BF   INC COPIX

        LDX COPIX
        CPX COPTOP
        BNE CW3BE

        LDA #0
        STA COPNEWF
        BEQ CWEX

CW3BE   LDA TFF,X
        CMP OUTFLG
        BEQ CW3BF
        BNE CW3A

CW3BD   JSR BWRITE
        BMI COPERJ2

        JSR CLTDOV

        LDA OUTFLG
        JSR ODOZN

        LDX #2
CW4B    LDA POS,X
        STA OUTPOS,X
        DEX
        BPL CW4B
        INC COPIX

        JMP CW3
COPERJ2 JMP ERR

CLTDOV  LDA #0

CLTDOV2 LDY #25
        STA (10),Y
        RTS

OVERTST LDA POS
        ORA POS+1
        ORA POS+2
        ORA QFLG
        BNE OVTX

        JSR TEXIST
        BMI OVTO

        JSR CLLIN

        LDY <QUEST
        LDX >QUEST
        JSR MENBEL

        PHA
        JSR CLLIN
        PLA

        TAX
        BMI OVRAB
        BEQ OVTO
        DEX
        BNE OVRAB

        SEC
        DTA B($24)
OVTO    CLC

        LDA #0
        STA POS
        STA POS+1
        STA POS+2

        RTS

OVTX    CLC
        RTS

OVRAB   JSR INISCR
        JMP NEWLP

QUEST   DTA B(3,0,20)
        DTA B(16,26,31)
        DTA B(9,4,5)
        DTA C'OSA'
        DTA C' File exists !'
        DTA C'  Overwrite Skip'
        DTA C' Abort'
        DTA B(155)
