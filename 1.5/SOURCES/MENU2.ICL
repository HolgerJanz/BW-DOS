* BW-DOS command MENU Part 2

START0  LDA $700
        CMP #'S'
        BNE START0E
        JMP START

START0E LDX #0
        LDA #11
        STA $342,X

        LDA <STERT
        STA $344,X
        LDA >STERT
        STA $345,X

        LDA <STERL
        STA $348,X
        LDA >STERL
        STA $349,X

        JSR $E456

        JMP (10)

STERT   DTA B(155,155)
        DTA C'Incorrect DOS version !!!'
        DTA B(253,253,253,253,155)

STERL   EQU *-STERT

LOOPTX  DTA C'  BW-DOS MENU 1.5 by JB&HJX 04-03-2024  '
        DTA B(155)

ERRTX   DTA C'Error    !'
        DTA B(155)

SRTM    DTA B(5,0,20)
        DTA B(9,16,24,29,37)
        DTA B(6,7,4,7,2)
        DTA C'ENSD0'
        DTA C'Sorting: Ext+N. Name+E. Size Date+T. No'
        DTA B(155)

NDSKT   DTA C'New disk: Drive:'
        DTA B(155)

NDSKM   DTA B(5,17,20)
        DTA B(0,3,6,9,12)
        DTA B(3,3,3,3,3)
        DTA C'12348'
        DTA C' 1  2  3  4  8 '
PRESSK  DTA B(155)

WKTX    DTA C'Press a key...'
        DTA B(160,155)

SELTX   DTA C'S'
        DTA B(155)
DESTX   DTA C'Des'
        DTA B(155)
SDTX    DTA C'elect group:'
        DTA B(155)

DIT1    DTA C'Volume:'
DIT2    DTA C'Bytes/sector:'
DIT3    DTA C'Total bytes:'
DIT4    DTA C'Bytes free:'

DI1     DTA B($11,$12,$12,$12,$12,$12,$12,$12,$12,$12)
        DTA B($12,$12,$12,$12,$12,$12,$12,$12,$12,$12)
        DTA B($12,$12,$12,$12,$12,$12,$12,$12,$12,$12)
        DTA B($12,$05,$9B)

DI2     DTA C'|          Disk info:          |'
        DTA B(155)

DI3     DTA B($01,$12,$12,$12,$12,$12,$12,$12,$12,$12)
        DTA B($12,$12,$12,$12,$12,$12,$12,$12,$12,$12)
        DTA B($12,$12,$12,$12,$12,$12,$12,$12,$12,$12)
        DTA B($12,$04,$9B)

DI4     DTA B($1A,$12,$12,$12,$12,$12,$12,$12,$12,$12)
        DTA B($12,$12,$12,$12,$12,$12,$12,$12,$12,$12)
        DTA B($12,$12,$12,$12,$12,$12,$12,$12,$12,$12)
        DTA B($12,$03,$9B)

NOTSAM  DTA C'Disk changed!'
        DTA B(155)

MDTX    DTA C'Directory name:'
        DTA B(155)

RNTX    DTA C'Rename to:'
        DTA B(155)

AINM    DTA B(4,0,20)
        DTA B(26,29,32,35)
        DTA B(3,3,3,3)
        DTA C'1234'
        DTA C'Format Atari disk: '
        DTA C'Drive: '
        DTA C' 1  2  3  4 '
        DTA B(155)

AINS    DTA B(2,19,20)
        DTA B(14,17)
        DTA B(2,3)
        DTA C'NY'
        DTA C'Are you sure? '
        DTA C'No Yes'
        DTA B(155)

AIND    DTA B(3,19,20)
        DTA B(0,7,14)
        DTA B(6,6,6)
        DTA C'SMD'
        DTA C'Single Medium Double'
        DTA B(155)

FRMTNG  DTA C'Formatting...'
        DTA B(160,155)

MTTX    DTA C'Filename:'
        DTA B(155)

COPTX1  DTA C'  Copy to drive:'
        DTA B(155)

COPMEN  DTA B(2,0,20)
        DTA B(11,15)
        DTA B(3,2)
        DTA C'YN'
        DTA C'Same disk? Yes No'
        DTA B(155)

COPTX2  DTA C'Dest. path:'
        DTA B(155)

SRCTX   DTA C'Insert source disk...'
        DTA B(160,155)

DSTTX   DTA C'Insert destination disk...'
        DTA B(160,155)

BELLMEN DTA B(2,0,20)
        DTA B(6,10)
        DTA B(3,2)
        DTA C'YN'
        DTA C'Bell: Yes No'
        DTA B(155)

CLTBT   DTA A(CTN,CTM,CTP,CTP)
        DTA A(CTP,CTP,CTP,CTP)
        DTA A(CTP,CTP,CTP,CTP)
        DTA A(CTP,CTP,CTP,CTP)
        DTA A(CTP,CTP,CTD)

CTN     DTA C'|  Filename  |P|  Size  |  Date  |Time |'
        DTA B(155)

CTM     DTA B($01,$12,$12,$12,$12,$12,$12,$12,$12,$17)
        DTA B($12,$12,$12,$13,$12,$13,$12,$12,$12,$12)
        DTA B($12,$12,$12,$12,$13,$12,$12,$12,$12,$12)
        DTA B($12,$12,$12,$13,$12,$12,$12,$12,$12,$04)
        DTA B($9B)

CTP     DTA C'|        |   | |        |        |     |'
        DTA B(155)

CTD     DTA B($1A,$12,$12,$12,$12,$12,$12,$12,$12,$18)
        DTA B($12,$12,$12,$18,$12,$18,$12,$12,$12,$12)
        DTA B($12,$12,$12,$12,$18,$12,$12,$12,$12,$12)
        DTA B($12,$12,$12,$18,$12,$12,$12,$12,$12,$03)
        DTA B($9B)

CMDS    DTA C'ChangeDr',B($F6)     ; 'ChangeDrv' V
        DTA B(155)
        DTA C'Chec',B($EB),C'Disk' ; 'CheckDisk' K
        DTA B(155)
        DTA C'C',B($E8),C'angeDir' ; 'ChangeDir' H
        DTA B(155)
        DTA C'ParentD',B($E9),C'r' ; 'ParentDir' I
        DTA B(155)
        DTA C' ',B($CD),C'akeDir ' ; ' MakeDir ' M
        DTA B(155)
        DTA B($D2),C'emoveDir'     ; 'RemoveDir' R
        DTA B(155)
        DTA C'  ',B($C3),C'opy   ' ; '  Copy   ' C
        DTA B(155)
        DTA C' ',B($C4),C'elete  ' ; ' Delete  ' D
        DTA B(155)
        DTA C' Re',B($EE),C'ame  ' ; ' Rename  ' N
        DTA B(155)
        DTA C' ',B($D0),C'rotect ' ; ' Protect ' P
        DTA B(155)
        DTA B($D5),C'nprotect'     ; 'Unprotect' U
        DTA B(155)
        DTA B($D4),C'ypeFile '     ; 'TypeFile ' T
        DTA B(155)
        DTA C' New',B($C6),C'ile ' ; ' NewFile ' F
        DTA B(155)
        DTA B($C1),C'tariInit'     ; 'AtariInit' A
        DTA B(155)
        DTA C'  E',B($F8),c'it   ' ; '  Exit   ' X
        DTA B(155)
        DTA C'  ',B($D3),C'etup  ' ; '  Setup  ' S
        DTA B(155)
        DTA C' Se',B($EC),C'ect  ' ; ' Select  ' L
        DTA B(155)
        DTA C'D',B($E5),C'select ' ; 'Deselect ' E
        DTA B(155)

RAMPH   DTA B($12,$12,$12,$12,$12,$12,$12,$12,$12,$12)
        DTA B($17,$12,$12,$12,$12,$12,$12,$12,$12,$12)
        DTA B($17,$12,$12,$12,$12,$12,$12,$12,$12,$12)
        DTA B($17,$12,$12,$12,$12,$12,$12,$12,$12,$12)
        DTA B($9B)

RAMPM   DTA C'          |         |         |         '
        DTA B(155)

RAMPL   DTA B($12,$12,$12,$12,$12,$12,$12,$12,$12,$12)
        DTA B($18,$12,$12,$12,$12,$12,$12,$12,$12,$12)
        DTA B($18,$12,$12,$12,$12,$12,$12,$12,$12,$12)
        DTA B($18,$12,$12,$12,$12,$12,$12,$12,$12,$12)
        DTA B($9B)

RDD3T   DTA A(SRTB0,SRTB1,SRTB2,SRTB3)

SRTB0   DTA B(14,15,16)
        DTA B(6,7,8,9,10,11,12,13)
        DTA B(255)

SRTB1   DTA B(6,7,8,9,10,11,12,13)
        DTA B(14,15,16)
        DTA B(255)

SRTB2   DTA B(5,4,3)
        DTA B(255)

SRTB3   DTA B(19,18,17,20,21,22)
        DTA B(255)

QMEN    DTA B(2,0,20)
        DTA B(24,28)
        DTA B(3,2)
        DTA C'YN'
        DTA C'Question for overwrite: Yes No'
        DTA B(155)

* PRO B

AUXS0   LDX #$10
        LDA #0
        STA $34A,X
        STA $34B,X
        RTS

CIODAB  STA $342,X
        LDA <DAB
        STA $344,X
        LDA >DAB
        STA $345,X

        JMP $E456

CLOSE2  LDX #$20
        DTA B($2C)
CLOSE0  LDX #0
        DTA B($2C)
CLOSE   LDX #$10
        LDA #12
        STA $342,X
        JMP $E456

REOPNS  LDX #$07
        LDA $2C0,X
        STA COLBUF,X
        DEX
        BPL *-7

        JSR CLOSE0

        LDX #0
        STX $2FE
        LDA #3
        STA $342,X

        LDA <ENAM
        STA $344,X
        LDA >ENAM
        STA $345,X

        LDA #12
        STA $34A,X
        TXA
        STA $34B,X

        JSR $E456

        LDX #$07
        LDA COLBUF,X
        STA $2C0,X
        DEX
        BPL *-7

        RTS

ENAM    DTA C'E:'
        DTA B(155)

KNAM    DTA C'K:'
        DTA B(155)

WAITKEY LDA #0
        DTA B($2C)
WAITKB  LDA #$FF
        PHA

        LDA <WKTX
        STA PADR
        LDA >WKTX
        STA PADR+1
        LDY #20
        LDA #0
        JSR PRINT

        PLA
        DTA B($2C)
GETKB   LDA #$FF
        ASL @
        BPL GETKEY
        LDA BELLFLG
        BNE GETKEY
* BELL!
        LDX #15

        LDA #3
        STA $D20F
        LDA #0
        STA $D208

        LDA #72
        STA $D200

GKB1A   TXA
        ORA #$A0
        STA $D201

        LDY 20
        INY
        INY
        INY

GKB1B   LDA 764
        CMP #$FF
        BNE GKB1C
        CPY 20
        BNE GKB1B

        DEX
        BNE GKB1A

GKB1C   LDA #0
        STA $D201

GETKEY  JSR CLOSE2

        LDX #$20
        LDA #3
        STA $342,X

        LDA #4
        STA $34A,X
        LDA #0
        STA $34B,X

        LDA <KNAM
        STA $344,X
        LDA >KNAM
        STA $345,X

        JSR $E456

        LDA #0
        STA $2B6
        LDA #$40
        STA $2BE

GETK2   LDX #$20
        LDA #7
        STA $342,X
        LDA #0
        STA $348,X
        STA $349,X

        JSR $E456
        BMI GETK2

        PHA
        JSR CLOSE2
        PLA

        RTS

CONVDC  STY T
        STX T+1
        STA T+2

        LDA #0
        LDX #8
COND1   STA DAB-1,X
        DEX
        BNE COND1

COND2   LDA T
        SEC
        SBC CDT3,X
        STA PRTMSK

        LDA T+1
        SBC CDT2,X
        TAY

        LDA T+2
        SBC CDT1,X
        BCC COND3

        STA T+2
        STY T+1
        LDA PRTMSK
        STA T

        INC DAB,X
        BNE COND2

COND3   INX
        CPX #8
        BCC COND2

        LDX #0
        LDY #$20

COND4   CPX #7
        BEQ COND4B
        LDA DAB,X
        BEQ COND5
COND4B  LDY #$30

COND5   TYA
        ORA DAB,X
        STA DAB,X

        INX
        CPX #8
        BCC COND4

        RTS

CDT1    DTA B($98,$0F,$01,0,0,0,0,0)
CDT2    DTA B($96,$42,$86,$27,3,0,0,0)
CDT3    DTA B($80,$40,$A0,$10,$E8,100,10,1)

CONVFNM LDX #0
        LDY #0
        LDA #8
        JSR CF2

        CMP #'.'
        BEQ CF1

        CMP #155
        BNE CFE
        DEX

CF1     LDA #11
        JSR CF2

        CMP #155
        BNE CFE
        RTS

CFE     LDY #165
        JMP ERR

CF2     STA MT1

CF3     LDA DAB,X
        INX
        CPY MT1
        BEQ CF3C

        CMP #'*'
        BEQ CF3H

        CMP #'?'
        BEQ CF3B
        CMP #'_'
        BEQ CF3B
        CMP #$30
        BCC CF3C
        CMP #$3A
        BCC CF3B
        CMP #$41
        BCC CF3C
        CMP #$5B
        BCS CF3C

CF3B    STA F,Y
        INY
        BNE CF3

CF3H    LDA DAB,X
        INX

        PHA
        LDA #'?'
        BNE CF3D

CF3C    PHA
        LDA #32

CF3D    CPY MT1
        BCC CF3E

        PLA
        RTS

CF3E    STA F,Y
        INY
        BNE CF3D
