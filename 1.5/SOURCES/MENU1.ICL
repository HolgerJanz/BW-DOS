* BW-DOS command MENU Part 1

RWST1   DTA C'"'
        DTA C'!ONSWRP'

RWST2   DTA B(64,64,128,64)
        DTA B(64,128,64,128)

RWST3   DTA B(0,0,12,12)
        DTA B(4,0,0,0)

RWST4   DTA B(255,255,7,7)
        DTA B(7,7,7,7)

RWSECTX STY $304
        STX $305

        LDY #$31
        STY $300
        LDY DRIVNUM
        STY $301

        STA $302

        LDX #7

RWS1    CMP RWST1,X
        BEQ RWS2

        DEX
        BPL RWS1

        LDY #168
        RTS

RWS2    LDA RWST2,X
        STA $303

        LDA RWST4,X
        STA $306

        LDY #0
        LDA RWST3,X
        BNE RWS3

        LDA #128
        LDX $30B
        BNE RWS2B
        LDX $30A
        CPX #4
        BCC RWS3

RWS2B   LDA SL
        LDY SL+1
        BNE RWS3
        CMP #0
        BNE RWS3

        STA $303

RWS3    STA $308
        STY $309

        JMP (SIOADR)

RWSECT  JSR RWSECTX
        BMI RWSER
        RTS

RWSER   JMP ERROR

INIT25  LDA 10
        STA SL
        LDA 11
        STA SL+1
        DEC SL+1

        LDY <256-10
        LDA (SL),Y
        STA SIOADR
        INY
        LDA (SL),Y
        STA SIOADR+1

        LDY <256-2
        LDA (SL),Y
        STA WRTCMD

        LDA #255
        STA DSECT
        STA DTS
        STA DTS+1

        RTS

DENSTST LDA #0
        STA SL
        STA SL+1
        STA $30B
        LDA #4
        STA $30A

        LDA #'R'
        LDX >DAB
        LDY <DAB
        JSR RWSECTX

        LDY #$10
DNST3   STA $D40A
        DEX
        BNE DNST3
        DEY
        BNE DNST3

        LDA #'S'
        LDX >DAB
        LDY <DAB
        JSR RWSECT

        LDA DAB
        AND #32
        EOR #32
        ASL @
        ASL @
        STA SL
        ASL @
        ROL @
        EOR #1
        STA SL+1

        LDA #255
        STA DSECT

        RTS

CLMAPB  LDA #0
        TAX

RDVT1   STA MAPB,X
        DEX
        BNE RDVT1

        RTS

RDVTOC  JSR CLMAPB

        LDX #0
        STX MEDFLG

        INX
        LDY #$68
        LDA #'R'
        JSR RWMAPB

        LDA SL
        BPL RDVTX

        LDA MAPB+2
        CMP #3
        BCC RDVTX

        LDA #4
        STA $30B
        LDA #0
        STA $30A

        LDA #'R'
        LDX >MAPB+128
        LDY <MAPB+128
        JSR RWSECT

        LDX <128+$54

RDVT2   LDA MAPB,X
        STA MAPB-$70,X

        INX
        BNE RDVT2

        DEC MEDFLG

RDVTX   RTS

WRVTOC  LDA MEDFLG
        BPL WRVT2

        LDA #4
        STA $30B
        LDA #0
        STA $30A

        LDA WRTCMD
        LDX >MAPB+$10
        LDY <MAPB+$10
        JSR RWSECT

        LDA #0
        LDX #$64

WRVT1   STA MAPB,X

        INX
        BNE WRVT1

WRVT2   LDX #1
        LDY #$68

WRMAPB  LDA WRTCMD

RWMAPB  STY $30A
        STX $30B

        LDX >MAPB
        LDY <MAPB
        JMP RWSECT

SETDP   LDA DPOS
        TAY

        AND #7
        ASL @
        ASL @
        ASL @
        ASL @
        STA DOFF

        TYA
        LSR @
        LSR @
        LSR @

        CMP DSECT
        BEQ SDRPX

        STA DSECT

        LDX #'R'
        BNE RWDS

SDRPX   RTS


WRDER   LDY #168
        JMP ERROR

WRD     LDA DSECT
        BMI WRDER
        LDX WRTCMD

RWDS    CLC
        ADC #$69
        STA $30A
        LDA #1
        STA $30B

        TXA
        LDX >DIRB
        LDY <DIRB
        JMP RWSECT

SRCHD   LDA #255
        STA DPOS

SRDNEXT LDA #255
        STA T

SRD1    INC DPOS
        LDA DPOS
        CMP #64
        BCS SRD1B

        JSR SETDP

        LDX DOFF
        LDA DIRB,X
        BNE SRD2

        CLC

SRD1B   LDA T
        BMI SRD1C

        STA DPOS
        JSR SETDP

        CLC

SRD1C   LDY #255
        RTS

SRD2    CMP #$80
        BNE SRD2B

        LDA T
        BPL SRD1

        LDA DPOS
        STA T
        JMP SRD1


SRD2B   AND <255-32

        CMP #$42
        BEQ SRD3
        CMP #3
        BNE SRD1

SRD3    LDY #0

SRD3B   LDA F,Y
        CMP #'?'
        BEQ SRD3C

        CMP DIRB+5,X
        BNE SRD1

SRD3C   INX
        INY
        CPY #11
        BCC SRD3B

        LDY #1
        CLC
        RTS


NAMTST  LDY #11
        JSR NAMTST2
        LDY #8

NAMTST2 DEY
        BMI NAMTSX
        CPY #7
        BEQ NAMTSX

        LDA F,Y
        CMP #32
        BEQ NAMTST2

NAMTS3  LDA F,Y

        CMP #'*'
        BEQ NAMWIL
        CMP #'?'
        BEQ NAMWIL

        CMP #'_'
        BEQ NAMTS4

        CMP #$30
        BCC NAMBAD
        CMP #$3A
        BCC NAMTS4

        CMP #'A'
        BCC NAMBAD
        CMP #'['
        BCS NAMBAD

NAMTS4  DEY
        BMI NAMTSX
        CPY #7
        BNE NAMTS3

NAMTSX  RTS

NAMWIL  LDY #163
        DTA B($2C)
NAMBAD  LDY #165
        JMP ERROR

READDIR TSX
        STX SSAVE

        LDA #0
        STA RWL
        STA RWL+1

        JSR INIT25
        JSR DENSTST

        LDY #10
        LDA #'?'
RDD2A   STA F,Y
        DEY
        BPL RDD2A

        JSR SRCHD
        BMI RDDX

RDD3    LDX DOFF
        LDY #0

        LDA DIRB,X
        AND #32
        CMP #32
        LDA #4
        ROL @

        STA (RWA),Y
        INY

        LDA #0
        STA (RWA),Y
        INY
        STA (RWA),Y
        INY

        STA T
        LDA DIRB+1,X
        STA T+1
        LDA DIRB+2,X
        STA T+2

        LDA SL
        BPL RDD3B

        LSR T+2
        ROR T+1
        ROR T

RDD3B   JSR RDD3BSB
        JSR RDD3BSB
        JSR RDD3BSB

RDD3C   LDA T-3,Y
        STA (RWA),Y
        INY
        CPY #6
        BCC RDD3C

RDD3D   LDA DIRB+5,X
        STA (RWA),Y
        INX
        INY
        CPY #17
        BCC RDD3D

        LDA #0
RDD3E   STA (RWA),Y
        INY
        CPY #23
        BCC RDD3E

        JSR RDDNXT

        JSR SRDNEXT
        BPL RDD3

RDDX    LDY #1
        RTS


RDD3BSB LDA T
        SEC
        SBC DIRB+1,X
        STA T

        LDA T+1
        SBC DIRB+2,X
        STA T+1

        BCS RDD3BS2
        DEC T+2

RDD3BS2 RTS

RDDNXT  LDA #23
        CLC
        ADC RWA
        STA RWA
        BCC RDD3F
        INC RWA+1

RDD3F   LDA #23
        CLC
        ADC RWL
        STA RWL
        BCC RDD3G
        INC RWL+1

RDD3G   RTS

ERROR   LDX SSAVE
        TXS

        TYA
        RTS

PROTECT SEC
        DTA b($24)
UNPROT  CLC

        TSX
        STX SSAVE

        PHP

        JSR INIT25
        JSR NAMTST
        JSR DENSTST
        JSR SRCHD
        BPL UNPR2

UNPNOTF LDY #170
        JMP ERROR

UNPR2   LDX DOFF
        LDA DIRB,X

        PLP
        BCC UNPR2B

        ORA #32
        BNE UNPR3

UNPR2B  AND <255-32

UNPR3   STA DIRB,X

        JSR WRD

        LDY #1
        RTS

RENAME  TSX
        STX SSAVE

        JSR INIT25
        JSR NAMTST
        JSR DENSTST
        JSR SRCHD
        BMI UNPNOTF

        LDX #10
RENM1   LDA F2,X
        STA F,X
        DEX
        BPL RENM1

        JSR NAMTST

        LDX DOFF
        LDY #0

RENM2   LDA F,Y
        STA DIRB+5,X

        INX
        INY
        CPY #11
        BCC RENM2

        JSR WRD

        LDY #1
        RTS

CHKDSK  TSX
        STX SSAVE

        JSR INIT25
        JSR DENSTST
        JSR RDVTOC

        LDA #0
        LDY #16
CHKD2   STA (RWA),Y
        DEY
        BPL CHKD2

        LDY #1
        LDA SL
        STA (RWA),Y

        INY
        LDA MAPB+1
        STA (RWA),Y
        INY
        LDA MAPB+2
        STA (RWA),Y

        INY
        LDX MAPB+4
        LDA MAPB+3

        BIT MEDFLG
        BPL CHKD3

        CLC
        ADC MAPB+$8A
        PHA
        TXA
        ADC MAPB+$8B
        TAX
        PLA

CHKD3   STA (RWA),Y
        INY
        TXA
        STA (RWA),Y

        LDX #0

CHKD4   INY
        LDA CHKDNAM,X
        STA (RWA),Y

        INX
        CPX #8
        BCC CHKD4

        LDY #1
        RTS

CHKDNAM DTA C'AtariDOS'

RDDATS  STY $30A
        STX $30B
        STY DTS
        STX DTS+1

        LDX >DAB
        LDY <DAB
        LDA #'R'
        JSR RWSECT

        LDX SL
        DEX
        DEX
        DEX

        LDA DAB,X
        LSR @
        LSR @
        CMP DPOS
        BNE RDDTSE

        RTS

RDDTSE  LDY #166
        JMP ERROR

ERADTA  JSR RDVTOC

        LDX DOFF
        LDA DIRB+3,X
        TAY
        LDA DIRB+4,X
        TAX

ERADT2  TYA
        BNE ERADT3
        TXA
        BNE ERADT3

        JMP WRVTOC

ERADT3  LSR T+2

        CPY #$D0
        TXA
        SBC #2
        BCC ERADT4

        LDA MEDFLG
        BPL RDDTSE

        CPX #4
        BCS RDDTSE

        SEC
        ROR T+2

ERADT4  TYA
        PHA
        TXA
        PHA

        JSR RDDATS

        PLA
        STA T+1
        PLA
        STA T
        PHA

        LDY #3
ERADT5  LSR T+1
        ROR T
        DEY
        BNE ERADT5

        LDA T
        CLC
        ADC <MAPB+10
        STA T
        LDA T+1
        ADC >MAPB+10
        STA T+1

        PLA
        AND #7
        TAY
        LDA #0
        SEC
ERADT6  ROR @
        DEY
        BPL ERADT6

        INY
        ORA (T),Y
        CMP (T),Y
        STA (T),Y

        BEQ ERADT8

        LDX #3
        LDA T+2
        BPL ERADT7
        LDX #$8A

ERADT7  INC MAPB,X
        BNE ERADT8
        INC MAPB+1,X

ERADT8  LDX SL
        DEX
        DEX
        LDA DAB,X
        TAY
        DEX
        LDA DAB,X
        AND #3
        TAX

        JMP ERADT2

ERASE   TSX
        STX SSAVE

        JSR INIT25
        JSR NAMTST
        JSR DENSTST
        JSR SRCHD
        BPL ERASE2

        LDY #170
        DTA B($2C)
ERAPROT LDY #164
        JMP ERROR

ERASE2  LDX DOFF
        LDA DIRB,X
        AND #32
        BNE ERAPROT

        JSR ERADTA

        LDX DOFF
        LDA #$80
        STA DIRB,X

        JSR WRD

        LDY #1
        RTS

PRIDEL  LSR T+2
        LDX #0

PRID2   LDA MAPB+10,X
        BNE PRID3

        INX
        CPX #$5A
        BCC PRID2

        LDA MEDFLG
        BPL PRID2E
        STA T+2

        CPX #$80
        BCC PRID2

PRID2E  LDA #0
        TAX
        TAY
        RTS

PRID3   LDY #0

PRID3B  ASL @
        BCS PRID4
        INY
        BCC PRID3B

PRID4   STY T

        LDA #255
        CLC
PRID4A  ROR @
        DEY
        BPL PRID4A

        AND MAPB+10,X
        STA MAPB+10,X

        INY
        STY T+1

        TXA
        LDY #3
PRID4B  ASL @
        ROL T+1
        DEY
        BNE PRID4B

        ORA T
        STA T

        LDX #3
        LDA T+2
        BPL PRID5

        TXA
        LDX DOFF
        STA DIRB,X

        LDX #$8A

PRID5   LDA MAPB,X
        BNE PRID5B
        LDA MAPB+1,X
        BEQ PRID6

        DEC MAPB+1,X
PRID5B  DEC MAPB,X

*

PRID6   LDX DOFF
        INC DIRB+1,X
        BNE PRID7
        INC DIRB+2,X

PRID7   LDY T
        LDX T+1
        LDA #1
        RTS

CLB     LDA #0
        TAX
CLB2    STA DAB,X
        DEX
        BNE CLB2

        RTS

WRDATS  LDX SL
        DEX
        DEX
        DEX
        LDA DAB,X
        AND #3
        STA DAB,X

        LDA DPOS
        ASL @
        ASL @
        ORA DAB,X
        STA DAB,X

        LDA DTS
        STA $30A
        LDA DTS+1
        STA $30B

        LDX >DAB
        LDY <DAB
        LDA WRTCMD
        JMP RWSECT

READ    TSX
        STX SSAVE

        LDA RWA+1
        PHA
        LDA RWA
        PHA

        JSR INIT25
        JSR NAMTST
        JSR DENSTST
        JSR SRCHD
        BPL R2

        LDY #170
        JMP ERROR

R2      LDX DOFF
        LDA DIRB+3,X
        TAY
        LDA DIRB+4,X
        TAX

        LDA POS
        ORA POS+1
        ORA POS+2
        BEQ R2B

        LDA POS
        LDY POS+1
        LDX POS+2

R2B     STA DTAIX

        JSR RDDATS

R3      LDA RWL
        ORA RWL+1
        BNE R3B

        LDY #1
        DTA B($2C)
R3X     LDY #136

        PLA
        STA T
        PLA
        STA T+1

        LDA RWA
        SEC
        SBC T
        STA RWL

        LDA RWA+1
        SBC T+1
        STA RWL+1

        LDA DTAIX
        STA POS
        LDA DTS
        STA POS+1
        LDA DTS+1
        STA POS+2

        TYA
        RTS

R3B     LDX SL
        DEX
        LDA DAB,X
        SEC
        SBC DTAIX
        BNE R3C

        LDA DAB-1,X
        STA T
        TAY
        LDA DAB-2,X
        AND #3
        TAX
        ORA T
        BEQ R3X

        JSR RDDATS

        LDA #0
        STA DTAIX
        BEQ R3

R3C     LDX RWL+1
        BNE R4

        CMP RWL
        BCC R4

        LDA RWL

R4      STA T
        LDY #0
        LDX DTAIX

R4B     LDA DAB,X
        STA (RWA),Y

        INX
        INY
        CPY T
        BCC R4B

        STX DTAIX

        JSR RWNEXT
        JMP R3


RWNEXT  LDA RWA
        CLC
        ADC T
        STA RWA
        BCC R5A
        INC RWA+1

R5A     LDA RWL
        SEC
        SBC T
        STA RWL
        BCS R5B
        DEC RWL+1

R5B     RTS

WRITE   TSX
        STX SSAVE

        JSR INIT25
        JSR NAMTST
        JSR DENSTST
        JSR SRCHD
        BPL WE2

        LDA POS
        ORA POS+1
        ORA POS+2
        BNE WRNOTF

        BCC WE2B

        LDY #169
        DTA B($2C)
WRPROT  LDY #164
        DTA B($2C)
WRNOTF  LDY #170
        DTA B($2C)
WRBADP  LDY #166
        JMP ERROR

WE2     LDA POS
        ORA POS+1
        ORA POS+2
        BNE WE2C

        LDX DOFF
        LDA DIRB,X
        AND #32
        BNE WRPROT

        JSR ERADTA

WE2B    LDX DOFF
        LDA #$42
        STA DIRB,X

        INX
        LDA #0
        LDY #4
W2BB    STA DIRB,X
        INX
        DEY
        BNE W2BB

        LDY #0
W2BC    LDA F,Y
        STA DIRB,X
        INX
        INY
        CPY #11
        BCC W2BC

        JSR RDVTOC
        JSR PRIDEL
        BEQ ER1ST

        TXA
        LDX DOFF

        STA DTS+1
        STA DIRB+4,X
        TYA
        STA DTS
        STA DIRB+3,X

CLBWR3  JSR CLB
        BEQ WE3

ER1ST   LDY #162
        JMP ERROR

WE2C    LDY POS+1
        LDX POS+2
        JSR RDDATS

        LDX SL
        DEX
        LDA POS
        CMP DAB,X
        BNE WRBADP

        JSR RDVTOC

WE3     LDA RWL
        ORA RWL+1
        BNE WE3B

        LDA DTS
        STA POS+1
        LDA DTS+1
        STA POS+2

        LDX SL
        DEX
        LDA DAB,X
        STA POS

        JSR WRDATS
        LDA #1

ER2ND   PHA
        JSR WRD
        JSR WRVTOC
        PLA
        TAY
        RTS

WE3B    LDX SL
        DEX
        DEX
        DEX
        TXA
        SEC
        SBC DAB+2,X
        BNE WE3C

        JSR PRIDEL
        PHP

        TYA
        PHA
        TXA
        PHA

        LDX SL
        DEX
        DEX
        STA DAB-1,X
        TYA
        STA DAB,X

        JSR WRDATS

        PLA
        STA DTS+1
        PLA
        STA DTS

        LDA #162
        PLP
        BEQ ER2ND
        BNE CLBWR3

WE3C    LDX RWL+1
        BNE WE4

        CMP RWL
        BCC WE4

        LDA RWL

WE4     STA T
        LDY #0
        LDX SL
        DEX
        LDA DAB,X
        TAX

WE4B    LDA (RWA),Y
        STA DAB,X

        INX
        INY
        CPY T
        BCC WE4B

        TXA
        LDX SL
        DEX
        STA DAB,X

        JSR RWNEXT
        JMP WE3

FMER1   LDY #168
        JMP ERROR

FORMAT  TSX
        STX SSAVE

        JSR INIT25

        LDX RWL
        CPX #3
        BCS FMER1

        LDA FT1,X
        STA SL
        LDA FT2,X
        STA SL+1
        LDA FT3,X
        STA MEDFLG

        LDA #4
        STA $30A
        LDA #0
        STA $30B
        LDX >DAB
        LDY <DAB
        LDA #'N'
        JSR RWSECTX
        BMI FM2

        LDX RWL

        LDA #40
        STA DAB
        LDA #0
        STA DAB+2
        STA DAB+4
        LDA FT4,X
        STA DAB+3
        LDA FT5,X
        STA DAB+5
        LDA FT2,X
        STA DAB+6
        LDA FT1,X
        STA DAB+7

        LDX >DAB
        LDY <DAB
        LDA #'O'
        JSR RWSECT

FM2     LDA #4
        STA $30A
        LDA #0
        STA $30B

        LDA MEDFLG
        ASL @
        LDA #'!'
        ADC #0

        LDX >DAB
        LDY <DAB
        JSR RWSECT

        JSR CLMAPB

        LDA #2
        STA MAPB
        STA MAPB+2
        STA MAPB+4
        LDA #$C3
        STA MAPB+1
        STA MAPB+3

        LDX #$5A
        LDA #$FF
FM3A    STA MAPB+9,X
        DEX
        BNE FM3A

        LSR @
        STA MAPB+$38
        STX MAPB+$37
        LDA #$0F
        STA MAPB+$0A

        LDA MEDFLG
        BPL FM4

        LDX #$25
        LDA #$FF
FM3B    STA MAPB+$64,X
        DEX
        BNE FM3B

        LSR @
        STA MAPB+$64

        INX
        STX MAPB+$8B
        LDA #$2F
        STA MAPB+$8A

        LDA #3
        STA MAPB+2
        LDA #$F2
        STA MAPB+1

FM4     JSR WRVTOC

        JSR CLMAPB

        LDA #$69
        STA T

FM4B    LDX #1
        LDY T
        JSR WRMAPB

        INC T
        LDA T
        CMP #$71
        BCC FM4B

        LDX #7
FM4C    LDA FALBOT-1,X
        STA MAPB,X
        DEX
        BNE FM4C

        LDA $D20A
        STA MAPB
* X=0
        LDY #1
        JSR WRMAPB

        LDY #1
        RTS

FT1     DTA B(128,128,0)
FT2     DTA B(0,0,1)
FT3     DTA B(0,255,0)
FT4     DTA B(18,26,18)
FT5     DTA B(0,4,4)

FALBOT  DTA B(1,0,32,6,32)
        SEC
        RTS
