* BW-DOS command MENU Part 4

CLDATB  LDA #32
        LDX #0
CLDTB2  STA DAB,X
        DEX
        BNE CLDTB2
        RTS

PP      JSR CLDATB

        LDA #'D'
        STA DAB
        LDA DRIVE
        ORA #$30
        STA DAB+1
        LDA #':'
        STA DAB+2

        LDX #0

PPT2    LDA P,X
        CMP #155
        BEQ PPT4

        CPX #37
        BCS PPT3

        STA DAB+3,X
        INX
        BNE PPT2
* NE

PPT3    INX
        LDA P,X
        CMP #155
        BNE PPT3

        TXA
        SEC
        SBC #35
        TAX

PPT3B   INX
        LDA P,X
        CMP #'>'
        BNE PPT3B

        LDA #'.'
        STA DAB+3
        STA DAB+4
        STA DAB+5

        LDY #0
PPT3C   LDA P,X
        CMP #155
        BEQ PPT3D

        STA DAB+6,Y
        INX
        INY
        BNE PPT3C
PPT3D   CPY #34
        BCS PPT4

        LDA #32
        STA DAB+6,Y
        INY
        BNE PPT3D

PPT4    LDY #0
        LDX #0
        LDA #128
        JMP PDAB

CLTAB   JSR PP

        LDA #18
        STA MT1

CLTB2   LDA MT1
        TAY
        INY

        ASL @
        TAX
        LDA CLTBT,X
        PHA
        LDA CLTBT+1,X

        TAX
        PLA
        JSR INIS2S

        DEC MT1
        BPL CLTB2

        RTS

CLLIN   JSR CLDATB
        LDY #20
        LDX #0
        TXA
PDAB    PHA

        LDA #155
        STA DAB+40

        LDA <DAB
        STA PADR
        LDA >DAB
        STA PADR+1

        PLA
        JMP PRINT

INIS2S  STA PADR
        STX PADR+1

        LDX #0
        TXA
        JMP PRINT

INISCR  JSR CLS
        JSR CLTAB
        JSR CLLIN
        LDY #21
        LDX >RAMPH
        LDA <RAMPH
        JSR INIS2S

        LDY #22
        LDX >RAMPM
        LDA <RAMPM
        JSR INIS2S

        LDY #23
        LDX >RAMPL
        LDA <RAMPL
        JSR INIS2S
        LDX #0
        LDA #$30
        TAY

INIS00  STA $600,X
        PHA
        TYA
        STA $680,X
        PLA

        CLC
        ADC #1
        CMP #$3A
        BCC INIS00B

        LDA #$30
        INY
        CPY #$3A
        BCC INIS00B
        TAY

INIS00B INX
        BPL INIS00

PRTCMD  LDA CMDSPOS
        STA MT1
        LDA #1
        STA MT1+1

PCM2    LDA MT1
        TAY
        ASL @
        ASL @
        CLC
        ADC MT1
        ASL @
* 10
        CLC
        ADC <CMDS
        STA PADR
        LDA #0
        ADC >CMDS
        STA PADR+1

        LDA #128
        CPY CMDPOS
        BEQ PCM3
        LSR @

PCM3    LDX MT1+1
        LDY #22
        JSR PRINT

        INC MT1
        LDA MT1
        CMP #18
        BCC PCM4
        LDA #0
        STA MT1

PCM4    LDA MT1+1
        CLC
        ADC #10
        STA MT1+1

        CMP #40
        BCC PCM2

        RTS

DIRADR  STA MT1
        LDY #0
        STY MT1+1

        ASL @
        ROL MT1+1
        ASL @
        ROL MT1+1
* 4
        CLC
        ADC MT1
        BCC DIRAD2
        INC MT1+1
* 5
DIRAD2  ASL @
        ROL MT1+1
* 10
        CLC
        ADC MT1
        BCC DIRAD3
        INC MT1+1
* 11
DIRAD3  ASL @
        ROL MT1+1
* 22
        CLC
        ADC MT1
        BCC DIRAD4
        INC MT1+1
* 23
DIRAD4  CLC
        ADC <MEMB
        STA MT1

        LDA MT1+1
        ADC >MEMB
        STA MT1+1

        RTS

PSIP    LDX #1

PS1     STA DAB
        LDA #155
        STA DAB+1

        LDA #0
        JMP PDAB

PLACE   STA MDP

        SEC
        SBC DSP
        BCC PLACP
        CMP #16
        BCC PRTTAB

        LDA MDP
        SEC
        SBC #15
        JMP PLAC1
PLACP   LDA MDP
PLAC1   STA DSP


PRTTAB  LDA #3
        STA PTTY

        LDA DIRPOC
        BNE PT0A
        JMP PT8
PT0A    LDX #$12
        LDA DSP
        STA PTTP
        BEQ PT0
        LDX #$9C
PT0     TXA
        LDY #2
        JSR PSIP

PT1     LDA PTTP
        JSR DIRADR

        LDY #0
        LDA (MT1),Y
        AND #8
        ASL @
        ASL @
        ASL @
        ASL @
        EOR #128
        STA PTTI
        LDX #39
PT1B    LDA CTP,X
        STA DIRB,X
        DEX
        BPL PT1B
* NM
        LDX #7
        LDY #6+7
PT2     LDA (MT1),Y
        EOR PTTI
        STA DIRB+1,X
        DEY
        DEX
        BPL PT2
* EXT
        LDX #2
        LDY #6+10
PT3     LDA (MT1),Y
        EOR PTTI
        STA DIRB+10,X
        DEY
        DEX
        BPL PT3
* P
        LDX #' '
        LDY #0
        LDA (MT1),Y
        LSR @
        BCC PT4
        LDX #'*'
PT4     STX DIRB+14
* TD
        LDY #22
        LDX #5
PT4A    LDA (MT1),Y
        STA MAPB,X
        DEY
        DEX
        BPL PT4A
* SIZE
        LDY #0
        LDA (MT1),Y
        AND #32
        BEQ PT4C

        LDX #7
PT4B    LDA SUBDT,X
        STA DIRB+16,X
        DEX
        BPL PT4B
        BMI PT5
PT4C    LDY #5
        LDA (MT1),Y
        PHA
        DEY
        LDA (MT1),Y
        TAX
        DEY
        LDA (MT1),Y
        TAY
        PLA

        JSR CONVDC

        LDX #7
PT4D    LDA DAB,X
        STA DIRB+16,X
        DEX
        BPL PT4D
* TD

PT5     LDA MAPB
        ORA MAPB+1
        ORA MAPB+2
        ORA MAPB+3
        ORA MAPB+4
        ORA MAPB+5
        BEQ PT6
        LDA #4
        STA PTTI

PT5B    LDX PTTI
        LDA MAPB,X
        AND #127
        TAY

        LDA PT5T,X
        TAX

        LDA $680,Y
        STA DIRB,X
        LDA $600,Y
        STA DIRB+1,X

        DEC PTTI
        BPL PT5B
        LDA #'-'
        STA DIRB+27
        STA DIRB+30
        LDA #':'
        STA DIRB+36
PT6     LDA #155
        STA DIRB+40

        LDA <DIRB
        LDX >DIRB
        LDY PTTY
        JSR INIS2S
*NXT
        INC PTTY
        INC PTTP

        LDA PTTP
        CMP DIRPOC
        BEQ PT8

        LDA PTTY
        CMP #19
        BCS PT7

        JMP PT1
* SCR FUL

PT7     LDA #$9D
        BNE PT9
* DIR END

PT8     LDY PTTY
        CPY #19
        BCS PT8B

        LDA <CTP
        LDX >CTP
        JSR INIS2S

        INC PTTY
        BNE PT8

PT8B    LDA #$12

PT9     LDY #19
        JSR PSIP

        LDA DIRPOC
        BNE PT9A

        LDA #$12
        LDY #2
        JMP PSIP
* CURS

PT9A    LDA MDP
        SEC
        SBC DSP

        CMP #16
        BCS PTX

        CLC
        ADC #3
        TAY
        LDX #0
        LDA #255
        JSR PS1

PTX     RTS


PT5T    DTA B(25,28,31,34,37)

SUBDT   DTA C'<DIR>   '


NDTX    DTA C'Reading directory...'
        DTA B(155)

RDDIR   JSR CLTAB
        JSR CLLIN

        LDA <NDTX
        STA PADR
        LDA >NDTX
        STA PADR+1
        LDY #20
        LDX #10
        LDA #0
        JSR PRINT

        LDA <MEMB
        STA RWA
        LDA >MEMB
        STA RWA+1
        JSR BDIR
        BPL RDD2
        RTS

RDD2    LDA RWL
        CMP <DIRBUFL
        LDA RWL+1
        SBC >DIRBUFL
        BCC RDD2B

        LDA <DIRBUFL
        STA RWL
        LDA >DIRBUFL
        STA RWL+1

RDD2B   LDA <MEMB
        CLC
        ADC RWL
        STA MEM2
        LDA >MEMB
        ADC RWL+1
        STA MEM2+1
        LDA #0
        STA DIRPOC

RDD2C   LDA RWL
        SEC
        SBC #23
        STA RWL
        LDA RWL+1
        SBC #0
        STA RWL+1
        BCC RESORT

        INC DIRPOC
        BNE RDD2C
* SORT

RESORT  LDA #0
        STA MDP
        STA DSP

        LDA DIRPOC
        CMP #2
        BCC RDD2X

        LDA SORTM
        CMP #4
        BCC RDDB3

RDD2X   LDY #1
        RTS
RDDB3   ASL @
        TAX
        LDA RDD3T,X
        STA SORTA
        LDA RDD3T+1,X
        STA SORTA+1
RDD4    LDA #128
        STA PTTI
        ASL @
        STA PTTP
RDD5    LDA PTTP
        JSR DIRADR

        LDA MT1
        CLC
        ADC #23
        STA MT2
        LDA MT1+1
        ADC #0
        STA MT2+1
        LDX #0

RDD6    TXA
        TAY
        LDA (SORTA),Y
        BMI RDD8
        TAY

        LDA (MT1),Y
        CMP (MT2),Y
        BCC RDD8
        BNE RDD7

        INX
        BNE RDD6
RDD7    LDY #22

RDD7B   LDA (MT1),Y
        TAX
        LDA (MT2),Y
        STA (MT1),Y
        TXA
        STA (MT2),Y

        DEY
        BPL RDD7B

        LSR PTTI
RDD8    INC PTTP

        LDX PTTP
        INX
        CPX DIRPOC
        BCC RDD5
        LDA PTTI
        BPL RDD4

        LDY #1
        RTS


PCL     LDA #'>'
        STA P
        LDA #155
        STA P+1
        RTS

NEWDISK JSR PCL

NEWDIR  JSR COPDNUM
        JSR RDDIR
        BPL NEWD2

        LDA P
        CMP #'>'
        BNE NEWDISK
        LDA P+1
        CMP #155
        BNE NEWDISK

        LDA #0
        STA DIRPOC
        STA MDP
        STA DSP

        LDA <MEMB
        STA MEM2
        LDA >MEMB
        STA MEM2+1

NEWD2   LDA DSKSTAT
        BNE NEWD3

        LDA #155
        STA P
        JSR PP

NEWD3   RTS


AINIT   JSR CLLIN

* DRV
        LDY <AINM
        LDX >AINM
        JSR MENU

        TAX
        INX
        TXA
        PHA
* DENS
        LDY <AIND
        LDX >AIND
        JSR MENU

        PHA
        LDY <AINS
        LDX >AINS
        JSR MENU

        BEQ ABORTA
        JSR CLLIN

        LDA <FRMTNG
        LDX >FRMTNG
        LDY #20
        JSR INIS2S

        PLA
        STA RWL
        PLA
        STA DRIVE

        JSR PCL
        JSR CLTAB
        JSR COPDNUM

        JSR FORMAT
        BMI AINIER

        JMP DIRLP
ABORTA  JMP TABLP
AINIER  JMP ERR


SAMETST JSR COPDNUM
        JSR BTEST
        BMI SAMEER
        RTS
SAMEER2 JMP ERR
SAMEER  CPY #150
        BNE SAMEER2
        JSR CLLIN

        LDY #20
        LDX >NOTSAM
        LDA <NOTSAM
        JSR INIS2S

        LDX #14
        JSR WAITKB

        JMP DIRLP

NAMBCK  LDX #0
        JSR DJFNM
        LDA #155
        JMP DJ1


GETP    LDA DRIVE
        STA DRIVNUM

        JSR BCHKDSK
        BMI GETPNE
        LDA DSKST2
        BEQ GETPNE

        JSR INIT25
        LDA DSKST2+1
        STA SECLEN
        ASL @
        ROL @
        EOR #1
        STA SECLEN+1

        LDX #$E8
        LDA #$20
GP1     STA P-1,X
        DEX
        BNE GP1
        JSR PCL

        JSR CLOSE
        BMI GETPNE
        JSR DJDN
        LDA #'*'

        JSR DJ1
        JSR DJEOL
        JSR AUXS0

        LDA #$14
        STA $34A,X
        LDA #3
        JSR CIODAB
        BMI GETPNE

        LDX #$10
        LDA #0
        STA $34C,X
        STA $34D,X
        STA $34E,X
        LDA #37
        JSR CIODAB
        BMI GETPNE

        LDX #$10
        LDA #23
        STA $348,X
        LDA #0
        STA $349,X
        LDA #7
        JSR CIODAB
        BMI GETPNE

GP2     LDA DAB+1
        STA $30A
        LDA DAB+2
        STA $30B
        ORA $30A
        BNE GP3
        RTS
GETPNE  JMP PCL

GP3     LDX #10
GP4     LDA DAB+6,X
        STA F,X
        DEX
        BPL GP4
        JSR NAMBCK
        DEX
        BPL GP6

GP5     LDA DAB,X
        JSR GPINS
        BCS GETPNE

GP6     DEX
        BPL GP5

        LDA #'>'
        JSR GPINS
        BCS GETPNE
        JSR GPRS
        BMI GETPNE
        LDA DAB+4
        STA $30A
        LDA DAB+5
        STA $30B
        ORA $30A
        BEQ GETPNE
        JSR GPRS
        BMI GETPNE
        BPL GP2

GPRS    LDY <DAB
        LDX >DAB
        LDA #'R'
        JMP RWSECTX

GPINS   LDY P+$E7
        CPY #32
        BEQ GPI1

        SEC
        RTS

GPI1    LDY #$E7
        PHA

GPI2    LDA P-1,Y
        STA P,Y
        DEY
        BNE GPI2

        PLA
        STA P

        CLC
        RTS

TXSWP   LDX #$E8
TXS2    LDA P-1,X
        PHA
        LDA P2-1,X
        STA P-1,X
        PLA
        STA P2-1,X
        DEX
        BNE TXS2
        RTS

TEXIST  LDA DSKST2
        BNE TX1

        LDA RWA
        PHA
        LDA RWA+1
        PHA
        LDA RWL
        PHA
        LDA RWL+1
        PHA

        LDA <UPDNAM
        STA RWA
        LDA >UPDNAM
        STA RWA+1
        LDA #1
        STA RWL
        LDA #0
        STA RWL+1

        JSR TXSWP
        JSR READ
        JSR TXSWP

        PLA
        STA RWL+1
        PLA
        STA RWL
        PLA
        STA RWA+1
        PLA
        STA RWA

        JMP TX3
TX1     JSR DJDN
        JSR DJPTH2
        JSR DJFNM
        JSR DJEOL

        JSR AUXS0
        LDA #6
        STA $34A,X

        LDA #3
        JSR CIODAB
        BMI TX2

        LDX #$10
        LDA #40
        STA $348,X
        LDA #0
        STA $349,X

        LDA #5
        JSR CIODAB
        BMI TX2

        LDX #16
TX1B    LDA DAB,X
        CMP #$9B
        BEQ TX1X
        DEX
        BPL TX1B

        CMP #'*'
        BEQ TX2
        CMP #$20
        BEQ TX2

TX1X    LDY #170

TX2     TYA
        PHA
        JSR CLOSE
        PLA
        TAY

TX3     TYA
        RTS
