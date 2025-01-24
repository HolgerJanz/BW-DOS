* BW-DOS command MENU Part 5

COPDNUM LDA DRIVE
        STA DRIVNUM
        RTS

START   LDX #0
        STX CMDPOS
        STX CMDSPOS
        STX BELLFLG
        STX QFLG
        LDA #4
        STA SORTM
        LDA 10
        CLC
        ADC #3
        STA ST0PAR+1
        LDA 11
        ADC #0
        STA ST0PAR+2
ST0PAR  JSR $E474

        LDY #34
        LDA (10),Y
        AND #15
        STA DRIVE

        LDY #36
ST0P2   LDA (10),Y
        CMP #'/'
        BNE ST0PX

        INY
        LDA (10),Y
        TAX
        INY
        LDA (10),Y
        INY
        CPX #'S'
        BEQ ST0P2S
        CPX #'Q'
        BEQ ST0P2Q
        CPX #'B'
        BNE ST0PX

        LDX #0
        CMP #'Y'
        BEQ ST0P2B
        INX
        CMP #'N'
        BNE ST0PX

ST0P2B  STX BELLFLG
        JMP ST0P2

ST0P2U  STX SORTM
        JMP ST0P2

ST0P2Q  LDX #0
        CMP #'Y'
        BEQ ST0P2W
        INX
        CMP #'N'
        BNE ST0PX

ST0P2W  STX QFLG
        JMP ST0P2

ST0PTB  DTA C'ENSD0'

ST0P2S  LDX #4
ST0P2T  CMP ST0PTB,X
        BEQ ST0P2U
        DEX
        BPL ST0P2T

ST0PX   JSR PCL
        JSR CLTDOV

        JSR REOPNS
        JSR INISCR


        LDA DRIVE

DIRLPP  LDX DRIVE
        STX COPPDRV
        STA DRIVE

        LDX #$E8
DIRL2   LDA P-1,X
        STA P2-1,X
        DEX
        BNE DIRL2

DIRLP   JSR GETP

        LDA #0
        STA CERRF

NEWLP   LDA CERRF
        BNE DIRLP

        JSR NEWDIR
TABLP   JSR PRTTAB
        JMP LP0
CMDLP   JSR PRTCMD

LP0     LDX #$FF
        TXS

        LDA <LOOPTX
        LDX >LOOPTX
        LDY #20
        JSR INIS2S

LP1     JSR GETKEY

        CMP #155
        BEQ LPRETQ

        CMP #$1E
        BEQ LPL
        CMP #$1F
        BEQ LPR
        CMP #$1C
        BEQ LPU
        CMP #$1D
        BEQ LPDQ

        AND #127

        CMP #'+'
        BEQ LPL
        CMP #'*'
        BEQ LPR
        CMP #'-'
        BEQ LPU
        CMP #'='
        BEQ LPDQ

        CMP #32
        BEQ LPSPCQ
        LDX #17
LP2     CMP LOP2T,X
        BEQ LP3
        DEX
        BPL LP2
        BMI LP1
LP3     STX CMDPOS
        DEX
        BPL LP3B
        LDX #17
LP3B    STX CMDSPOS

        JMP CMDLP

LPL     LDX CMDPOS
        TXA

        DEX
        BPL LPL2
        LDX #17

LPL2    STX CMDPOS
        CMP CMDSPOS
        BNE CMDLJ2

        STX CMDSPOS

CMDLJ2  JMP CMDLP
LPRETQ  BEQ LPRET
LPSPCQ  BEQ LPSPC
LPDQ    BEQ LPD
LPR     LDA CMDPOS
        JSR LPRS
        STA CMDPOS

        SEC
        SBC CMDSPOS
        BCS LPR2
        ADC #18
LPR2    CMP #4
        BCC CMDLJ2

        LDA CMDSPOS
        JSR LPRS
        STA CMDSPOS

        JMP CMDLP
LPU     LDA MDP
        BNE LPU2

        LDA DIRPOC
        STA MDP

        SEC
        SBC #15
        BCS LPU1
        LDA #0

LPU1    STA DIRSPOS

LPU2    DEC MDP

        LDA DIRSPOS
        CMP MDP
        BCC TABLJ1

        LDA MDP
        SBC #1
        BCS LPU3
        LDA #0
LPU3    STA DIRSPOS

TABLJ1  JMP TABLP
LPSPC   LDA MDP
        JSR DIRADR

        LDY #0
        LDA (MT1),Y
        EOR #8
        STA (MT1),Y
LPD     INC MDP
        LDA MDP
        CMP DIRPOC
        BCC LPD2

        LDA #0
        STA MDP
        STA DIRSPOS

LPD2    SEC
        SBC DIRSPOS
        CMP #15
        BCC TABLJ1

        LDA MDP
        SEC
        SBC #14
        STA DIRSPOS
        JMP TABLP
LPRET   LDA CMDPOS
        ASL @
        TAX

        LDA LPRTTB,X
        STA MT1
        LDA LPRTTB+1,X
        STA MT1+1

        JMP (MT1)

LPRTTB  DTA A(NDSK,DSKINFO,SUBDIR)
        DTA A(UPDIR,MKDIR,DLDIR,COPY)
        DTA A(ERASEC,RENAMEC,PROTEC)
        DTA A(UNPROTC,VIEWTX,MAKETX)
        DTA A(AINIT,EXIT,SETUP)
        DTA A(SELECT,DESEL)

LOP2T   DTA C'VKHIMRCDNPUTFAXSLE'

LPRS    CLC
        ADC #1
        CMP #18
        BCC LPRS2
        SBC #18
LPRS2   RTS


EXIT    JSR CLTDOV
        JSR REOPNS
        JMP (10)

ERR     TYA
        PHA

        JSR INISCR

        LDY #20
        LDX >ERRTX
        LDA <ERRTX
        JSR INIS2S

        PLA
        TAY
        LDA #0
        TAX
        JSR CONVDC

        LDA #155
        STA DATB+8
        LDA <DATB+5
        STA PRTADR
        LDA >DATB+5
        STA PRTADR+1
        LDY #20
        LDX #6
        LDA #0
        JSR PRINT

        LDX #11
        JSR WAITKB

        JMP NEWLP

NDSK    JSR CLLIN

        LDA <NDSKT
        LDX >NDSKT
        LDY #20
        JSR INIS2S

        JSR DRIVMEN
* A=DRIVE
        JMP DIRLPP

SETUP   JSR CLLIN

        LDY <SRTM
        LDX >SRTM
        JSR MENU

        STA SORTM
        JSR RESORT
        JSR CLLIN

        LDY <BELLMEN
        LDX >BELLMEN
        JSR MENU

        STA BELLFLG
        JSR CLLIN
        LDY <QMEN
        LDX >QMEN
        JSR MENU

        STA QFLG

ABORT1  JMP TABLP

DRIVMEN LDY <NDSKM
        LDX >NDSKM
        JSR MENU

        TAX
        INX
        CPX #5
        BCC NDSK2
        LDX #8

NDSK2   TXA
ZEROLX  RTS

ZEROL   LDA DIRPOC
        BEQ ABORT1
        RTS

SELECT  JSR CLLIN

        LDA <SELTX
        LDX >SELTX
        LDY #20
        JSR INIS2S

        LDX #1
        LDA #0
        BEQ SELDS2
DESEL   JSR CLLIN

        LDA <DESTX
        LDX >DESTX
        LDY #20
        JSR INIS2S

        LDX #3
        LDA #8
SELDS2  STA PTTI
        STX PTTP

        JSR ZEROL

        LDA <SDTX
        STA PRTADR
        LDA >SDTX
        STA PRTADR+1
        LDY #20
        LDA #0
        JSR PRINT
        JSR CLDATB
        LDA #'*'
        STA DATB
        STA DATB+2
        LDA #'.'
        STA DATB+1

        LDA PTTP
        CLC
        ADC #13
        TAX
        LDY #20
        LDA #12
        JSR EDIT0

        TAX
        BMI ABORT1

        JSR CONVFNM

        LDA #$FF
        STA PTTP

SELD4   JSR SELDSR
        BCS ABORT1

        LDY #0
        LDA (MT1),Y
        AND #255-8
        ORA PTTI
        STA (MT1),Y
        JMP SELD4

SELDSR  INC PTTP
        LDA PTTP
        CMP DIRPOC
        BCS SELD5X

        JSR DIRADR

        LDY #6

SELD5B  LDA F-6,Y
        CMP #'?'
        BEQ SELD5C

        CMP (MT1),Y
        BNE SELDSR

SELD5C  INY
        CPY #17
        BCC SELD5B

        CLC
SELD5X  RTS


DICLR   LDX #32
        TXA
DICLR1  STA DIRB,X
        DEX
        BPL DICLR1

        LDA #'|'
        STA DIRB
        STA DIRB+31
        LDA #155
        STA DIRB+32
        RTS

DSKINM1 PHA
        LDA #0

        JSR CONVDC

        PLA
        TAX
        LDY #5

DSKINM3 LDA DATB,Y
        STA DIRB,X
        INX
        INY
        CPY #8
        BCC DSKINM3

        RTS

DSKINM2 LDY #0
        BIT DSKST2+1
        BPL DSKINM4

        LSR @
        PHA
        TXA
        ROR @
        TAX
        TYA
        ROR @
        TAY
        PLA

DSKINM4 JSR CONVDC

        LDX #15
        LDY #0
        BEQ DSKINM3

DIPRTDB LDA <DIRB
        LDX >DIRB
DIPRT   STA PRTADR
        STX PRTADR+1

        LDA #0
        LDX #4
        JMP PRINT
DSKIE   JMP ERR
DSKINFO JSR COPDNUM

        JSR BCHKDSK
        BMI DSKIE

        LDY #6
        LDX >DI1
        LDA <DI1
        JSR DIPRT

        LDY #7
        LDX >DI2
        LDA <DI2
        JSR DIPRT

        LDY #8
        LDX >DI3
        LDA <DI3
        JSR DIPRT
        JSR DICLR

        LDA DSKST2
        BEQ DSKI2
        LDX #6
DSKI1A  LDA DIT1,X
        STA DIRB+7,X
        DEX
        BPL DSKI1A
        LDX #7
DSKI1B  LDA DSKST2+6,X
        STA DIRB+15,X
        DEX
        BPL DSKI1B
        LDA #24
        LDY DSKST2+14
        LDX #0
        JSR DSKINM1

        LDA #28
        LDY DSKST2+15
        LDX #0
        JSR DSKINM1
DSKI2   LDY #9
        JSR DIPRTDB
        JSR DICLR

        LDX #12
DSKI3   LDA DIT2,X
        STA DIRB+1,X
        DEX
        BPL DSKI3

        INX
        LDY DSKST2+1
        BNE DSKI3B
        INX

DSKI3B  LDA #15
        JSR DSKINM1

        LDY #10
        JSR DIPRTDB
        JSR DICLR

        LDX #11
DSKI4A  LDA DIT3,X
        STA DIRB+2,X
        DEX
        BPL DSKI4A

        LDX DSKST2+2
        LDA DSKST2+3
        JSR DSKINM2

        LDY #11
        JSR DIPRTDB
        JSR DICLR

        LDX #10
DSKI5A  LDA DIT4,X
        STA DIRB+3,X
        DEX
        BPL DSKI5A

        LDX DSKST2+4
        LDA DSKST2+5
        JSR DSKINM2

        LDY #12
        JSR DIPRTDB
        LDY #13
        LDX >DI4
        LDA <DI4
        JSR DIPRT
        JSR CLLIN

        LDX #0
        JSR WAITKEY
        JMP TABLP

SUBDIR  JSR ZEROL

        LDA MDP
        JSR DIRADR
        LDY #0
        LDA (MT1),Y
        AND #32
        BNE SBD0
        JMP TABLP
SBD0    LDY #6
SBD0B   LDA (MT1),Y
        STA F-6,Y
        INY
        CPY #17
        BCC SBD0B
        JSR NAMBCK

        LDX #0

SBD1    LDA P,X
        CMP #155
        BEQ SBD2

        INX
        CPX #$D8
        BCC SBD1

* path too long
        LDY #165
        JMP ERR

SBD2    LDY #$FF
        BNE SBD2CB

SBD2D   JSR SBD3

SBD2CB  INY
        LDA DATB,Y
        CMP #$9B
        BNE SBD2D

        LDA #'>'
        JSR SBD3
        LDA #155
        JSR SBD3
        JSR SAMETST
        JMP NEWLP

SBD3    STA P,X
        INX
        RTS
