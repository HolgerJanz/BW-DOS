* BW-DOS command MENU Part 3

DJDN    LDX #0

        LDA #'D'
        JSR DJ1
        LDA DRIVNUM
        ORA #$30
        JSR DJ1
        LDA #':'

        DTA B($2C)
DJEOL   LDA #155
        DTA B($2C)
DJHVE   LDA #'*'

DJ1     STA DAB,X
        INX

        RTS

DNEOL   JSR DJDN
        JMP DJEOL


DJFNM   LDY <F
        LDA >F
        BNE DJF2
DJFNM2  LDY <F2
        LDA >F2

DJF2    STY T
        STA T+1
        STX DJF2A+1

        LDY #0
        LDA #8
        JSR DJFSUB

        LDA #'.'
        JSR DJ1

        LDY #8
        LDA #11
        JSR DJFSUB

        LDA DAB-1,X
        CMP #'.'
        BNE DJF2B
        DEX
DJF2A   CPX #0
        BNE DJF2B
        INX
DJF2B   RTS

DJFSUB  STA DJF3+1
        JMP DJF3

DJF3B   JSR DJ1
DJF3    CPY #8
        BCS DJF3X

        LDA (T),Y
        INY
        CMP #32
        BNE DJF3B

DJF3X   RTS


DJPTH   LDY <P
        LDA >P
        BNE DJP2
DJPTH2  LDY <P2
        LDA >P2

DJP2    STY T
        STA T+1

        LDY #0
        LDA (T),Y
        CMP #155
        BNE DJP2B

        RTS
DJP2C   JSR DJ1
DJP2B   LDA (T),Y
        INY
        CMP #155
        BNE DJP2C

        LDA DAB-1,X
        CMP #'>'
        BEQ DJF3X
        CMP #'<'
        BEQ DJF3X

        LDA #'>'
        JMP DJ1

BERR    LDX BSS
        TXS

        TYA
        PHA
        JSR CLOSE
        PLA
        TAY

        RTS


BCHKDSK TSX
        STX BSS

RDCHK   JSR CLOSE
        JSR DNEOL
        JSR AUXS0

        LDA <DSKST2
        STA $348,X
        LDA >DSKST2
        STA $349,X

        LDA #47
        JSR CIODAB
        BPL RCHX
        CPY #148
        BEQ RCH2
RCHER   JMP BERR
RCH2    LDA RWA
        PHA
        LDA RWA+1
        PHA

        LDA <DSKST2
        STA RWA
        LDA >DSKST2
        STA RWA+1
        JSR CHKDSK

        PLA
        STA RWA+1
        PLA
        STA RWA

        TYA
        BMI RCHER

RCHX    LDY #1
        RTS

BTEST   TSX
        STX BSS

        JSR RDCHK

        LDX #15

BTST2   CPX #4
        BEQ BTST3
        CPX #5
        BEQ BTST3
        CPX #14
        BEQ BTST3

        LDA DSKSTAT,X
        CMP DSKST2,X
        BNE BTSTER

BTST3   DEX
        BPL BTST2

        LDY #1
        RTS
BTSTER  LDA #'>'
        STA P
        LDA #155
        STA P+1

        LDX #16
        LDA #0
BTSTE2  STA DSKSTAT,X
        DEX
        BPL BTSTE2

        LDY #150
        RTS

BDIR    TSX
        STX BSS

        JSR RDCHK

        LDX #16
BDIR1   LDA DSKST2,X
        STA DSKSTAT,X
        DEX
        BPL BDIR1

        LDA DSKST2
        BNE BDIR2
        JMP READDIR
*CWD

BDIR2   JSR DJDN
        JSR DJPTH
        JSR DJEOL

        JSR AUXS0
        LDA #44
        JSR CIODAB
        BMI BERJ1
*OPN
        JSR DJDN
        JSR DJHVE
        LDA #'.'

        JSR DJ1
        JSR DJHVE
        JSR DJEOL

        JSR AUXS0
        LDA #$14
        STA $34A,X
        LDA #3
        JSR CIODAB
        BMI BERJ1

        LDA #0
        STA RWL
        STA RWL+1
        BEQ BDIR3
BERJ1   JMP BERR

BDIR4   LDA DAB
        BEQ BDIRX

        AND #8
        BEQ BDIR3

        LDY #22
BDIR4B  LDA DAB,Y
        STA (RWA),Y
        DEY
        BPL BDIR4B

        JSR RDDNXT
BDIR3   LDX RWA+1
        INX
        CPX $2E6
        BCS BDIRX

        LDX #$10
        LDA #0
        STA $349,X
        LDA #23
        STA $348,X
        LDA #7
        JSR CIODAB
        BPL BDIR4

        CPY #136
        BNE BERJ1
BDIRX   JSR CLOSE
        LDY #1
        RTS

BREAD   TSX
        STX BSS

        LDA DSKST2
        BNE BREAD1
        JMP READ

BREAD1  JSR DJDN
        JSR DJPTH
        JSR DJFNM
        JSR DJEOL

        JSR AUXS0
        LDA #4
        STA $34A,X
        LDA #3
        JSR CIODAB
        BMI BERJ2
        LDA POS
        ORA POS+1
        ORA POS+2
        BEQ BREAD2
        JSR DNEOL

        LDX #$10
        LDA POS
        STA $34C,X
        LDA POS+1
        STA $34D,X
        LDA POS+2
        STA $34E,X
        LDA #37
        JSR CIODAB
        BPL BREAD2

BERJ2   JMP BERR

BREAD2  LDA #7

RWSPOL  LDX #$10
        STA $342,X

        LDA RWA
        STA $344,X
        LDA RWA+1
        STA $345,X

        LDA RWL
        STA $348,X
        LDA RWL+1
        STA $349,X

        ORA RWL
        BEQ BREAD3

        JSR $E456
        DTA B($2C)
BREAD3  LDY #1

        TYA
        PHA

        LDX #$10
        LDA $348,X
        STA RWL
        LDA $349,X
        STA RWL+1
        JSR DNEOL

        LDX #$10
        LDA #38
        JSR CIODAB
        BMI BERJ2

        LDX #$10
        LDA $34C,X
        STA POS
        LDA $34D,X
        STA POS+1
        LDA $34E,X
        STA POS+2

        JSR CLOSE
        BMI BERJ2

        PLA
        TAY
        RTS

BWRITE  TSX
        STX BSS

        LDA DSKST2
        BNE BWRI1
        JMP WRITE

BWRI1   JSR DJDN
        JSR DJPTH2
        JSR DJFNM
        JSR DJEOL

        JSR AUXS0
        LDA #8
        STA $34A,X
        LDA POS
        ORA POS+1
        ORA POS+2
        BEQ BWRI2

        INC $34A,X

BWRI2   LDA #3
        JSR CIODAB
        BMI BERJ3
        LDA #11
        JMP RWSPOL

BXIO    TSX
        STX BSS

        PHA

        LDA DSKST2
        BNE BXIO1
        PLA
        CMP #33
        BEQ BXER
        CMP #35
        BEQ BXPR
        CMP #36
        BEQ BXUN

        LDY #148
        RTS
BXER    JMP ERASE
BXPR    JMP PROTECT
BXUN    JMP UNPROT

BXIO1   JSR DJDN
        JSR DJFNM
        JSR DJEOL

        JSR AUXS0
        PLA
        JSR CIODAB
        BMI BERJ3
        RTS
BERJ3   JMP BERR


BRENAME TSX
        STX BSS

        LDA DSKST2
        BNE RENAM1
        JMP RENAME

RENAM1  JSR DJDN
        JSR DJFNM
        LDA #','

        JSR DJ1
        JSR DJFNM2
        JSR DJEOL

        JSR AUXS0
        LDA #32
        JSR CIODAB
        BMI BERJ3

        RTS

CLS     LDA 88
        STA PADR
        STA PSAD
        LDX 89
        INX
        STX PADR+1
        INX
        STX PSAD+1

        LDA #0
        TAY
CLS1    STA (88),Y
        STA (PADR),Y
        STA (PSAD),Y
        DEY
        BNE CLS1

        INC PSAD+1
        LDY #$C0

CLS2    DEY
        STA (PSAD),Y
        CPY #0
        BNE CLS2
        LDX #0

CLS3    TXA
        AND #$9F
        STA PMSK

        TXA
        LSR @
        LSR @
        LSR @
        LSR @
        LSR @
        AND #3
        TAY

        LDA CLS3TB,Y
        ORA PMSK
        STA $500,X

        DEX
        BNE CLS3

        RTS
CLS3TB  DTA B(64,0,32,96)
PTB     DTA A(0,40,80,120,160,200)
        DTA A(240,280,320,360,400)
        DTA A(440,480,520,560,600)
        DTA A(640,680,720,760,800)
        DTA A(840,880,920)

PEDIT   LDA <DAB
        STA PADR
        LDA >DAB
        STA PADR+1

PED2    LDY EDY
        LDX EDX
        LDA #0

PRINT   CPY #24
        BCS P1EX
        CPX #40
        BCC P1
P1EX    RTS

P1      AND #128
        STA PMSK

        TYA
        ASL @
        TAY

        LDA PTB,Y
        CLC
        ADC 88
        STA PSAD
        LDA PTB+1,Y
        ADC 89
        STA PSAD+1

        TXA
        CLC
        ADC PSAD
        STA PSAD
        BCC P2LAB
        INC PSAD+1
P2LAB   LDY #0

P3      LDA (PADR),Y
        CMP #155
        BEQ P1EX

        TAX
        LDA $500,X

        EOR PMSK
        STA (PSAD),Y
        INY
        BNE P3

        RTS

MEN1S   STA MEN1S2+1
        STX MEN1S2+2

        LDX #0

MEN1S1  LDA (PADR),Y
        INY
MEN1S2  STA DIRB,X
        INX

        CPX EDMAX
        BCC MEN1S1

        RTS

MENBEL  SEC
        DTA b($90)
MENU    CLC
        ROR MBF

        STY PADR
        STX PADR+1

        LDY #0
        STY EDPOS
        LDA (PADR),Y
        STA EDMAX
* X,Y
        INY
        LDA (PADR),Y
        STA EDX
        INY
        LDA (PADR),Y
        STA EDY
        INY
* POS
        LDX >MAPB
        LDA <MAPB
        JSR MEN1S
* LEN
        LDX >MAPB+128
        LDA <MAPB+128
        JSR MEN1S
* KEYS
        LDX >DIRB
        LDA <DIRB
        JSR MEN1S
* TXT
        LDX #0

MEN3    LDA (PADR),Y
        INY
        STA DAB,X
        INX

        CMP #155
        BNE MEN3
* ZOBR

MEN4    LDX #0

MEN4B   LDA DAB,X
        CMP #155
        BEQ MEN4C

        AND #127
        STA DAB,X
        INX
        BNE MEN4B
MEN4C   LDX EDPOS
        LDA MAPB+128,X
        TAY
        LDA MAPB,X
        TAX

MEN4D   LDA DAB,X
        ORA #128
        STA DAB,X

        INX
        DEY
        BNE MEN4D
        JSR PEDIT
MEN5    BIT MBF
        BPL MEN5A

        LSR MBF
        JSR GETKB
        JMP MEN5AB

MEN5A   JSR GETKEY
MEN5AB  CMP #27
        BEQ MEN5ESC
        CMP #155
        BEQ MEN5RET

        CMP #$1E
        BEQ MEN5L
        CMP #$1F
        BEQ MEN5R

        AND #127

        CMP #'+'
        BEQ MEN5L
        CMP #'*'
        BEQ MEN5R

        LDX EDMAX
        DEX

MEN5B   CMP DIRB,X
        BEQ MEN5C

        DEX
        BPL MEN5B
        BMI MEN5
MEN5C   TXA
        RTS
MEN5ESC LDA MBF
        BEQ MENABRT
        ASL @
        RTS

MENABRT PLA
        PLA
        JMP TABLP
MEN5RET LDA EDPOS
        RTS
MEN5L   LDX EDPOS
        BNE MEN5L2

        LDX EDMAX

MEN5L2  DEX
MEN5L3  STX EDPOS
        JMP MEN4
MEN5R   LDX EDPOS
        INX

        CPX EDMAX
        BCC MEN5L3

        LDX #0
        BEQ MEN5L3

EDCLIT  PHA
        TXA
        PHA

        LDA #32
        LDX #0
EDIT0A  STA DAB,X
        DEX
        BNE EDIT0A

        PLA
        TAX
        PLA

        RTS

EDIT    JSR EDCLIT

EDIT0   STY EDY
        STX EDX
        STA EDMAX

        TAX

EDIT0B  DEX
        CPX #$FF
        BEQ EDIT0C
        LDA DAB,X
        CMP #32
        BEQ EDIT0B

EDIT0C  INX
        STX EDPOS

        LDA #0
        STA EDSPOS
* ZOBR

EDIT1   LDX EDMAX
        LDA #155
        STA DAB,X

        LDX EDPOS
        LDA DAB,X
        ORA #128
        STA DAB,X
* VYSEC
        LDA #40
        SEC
        SBC EDX
        STA PSAD

        LDA EDPOS
        SEC
        SBC EDSPOS
        BCC ED1B
        CMP #2
        BCS ED1C

ED1B    LDA EDPOS
        SEC
        SBC #2
        BCS ED1F
        LDA #0
        BEQ ED1F

ED1C    STA PSAD+1
        LDA PSAD
        SEC
        SBC PSAD+1
        BCC ED1D
        CMP #2
        BCS ED1G

ED1D    LDA EDPOS
        CLC
        ADC #2
        CMP EDMAX
        BCC ED1E
        LDA EDMAX
ED1E    SEC
        SBC PSAD
        BCS ED1F
        LDA #0

ED1F    STA EDSPOS

ED1G    LDA EDSPOS
        CLC
        ADC <DAB
        STA PADR
        LDA #0
        ADC >DAB
        STA PADR+1

        LDA EDSPOS
        CLC
        ADC PSAD
        STA ED1H+1
        TAX

        LDA DAB,X
        STA ED1I+1
        LDA #155
        STA DAB,X

        JSR PED2

ED1H    LDX #0
ED1I    LDA #0
        STA DAB,X

        LDX EDPOS
        LDA DAB,X
        AND #127
        STA DAB,X
EDIT2   JSR GETKEY
        CMP #27
        BEQ ED2ESC
        CMP #155
        BEQ ED2RETQ
        CMP #$1E
        BEQ ED2L
        CMP #$1F
        BEQ ED2R
        CMP #$7D
        BEQ ED2CLR
        CMP #$7E
        BEQ ED2DEL
        CMP #$FE
        BEQ ED2CTD
        CMP #$FF
        BEQ ED2CTI
        AND #127

        CMP #'*'
        BEQ ED2B
        CMP #'.'
        BEQ ED2B
        CMP #'>'
        BEQ ED2B
        CMP #'<'
        BEQ ED2B
        CMP #'?'
        BEQ ED2B
        CMP #'_'
        BEQ ED2B

        CMP #$30
        BCC EDIT2
        CMP #$3A
        BCC ED2B

        AND #$5F

        CMP #$41
        BCC EDIT2
        CMP #$5B
        BCS EDIT2

ED2B    LDX EDPOS
        STA DAB,X
ED2R    INC EDPOS
        LDA EDPOS
        CMP EDMAX
        BCC EDIT1J
ED2L    LDA EDPOS
        BEQ EDIT1J

        DEC EDPOS

EDIT1J  JMP EDIT1
ED2RETQ BEQ ED2RET
ED2ESC  LDA #255
        RTS
ED2CLR  JSR EDCLIT
        LDA #0
        STA EDPOS
        BEQ EDIT1J
ED2DEL  LDX EDPOS
        BEQ EDIT1J

        DEX
        STX EDPOS
ED2D2   LDA #32
        STA DAB,X
        BNE EDIT1J
ED2CTD  LDX EDPOS
ED2CD2  LDA DAB+1,X
        STA DAB,X
        INX
        CPX EDMAX
        BCC ED2CD2

        DEX
        JMP ED2D2
ED2CTI  LDX EDMAX
ED2CI2  DEX
        LDA DAB-1,X
        STA DAB,X
        CPX EDPOS
        BNE ED2CI2
        BEQ ED2D2
ED2RET  LDX EDMAX

ED2RT2  DEX
        CPX #$FF
        BEQ ED2RT3
        LDA DAB,X
        CMP #32
        BEQ ED2RT2

ED2RT3  INX
        LDA #155
        STA DAB,X

        LDA #0
        RTS
