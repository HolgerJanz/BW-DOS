*************************************
*       RAM-DISK FOR BW-DOS         *
* Original: Jiri Bernasek           *
* MADS version: dmsc on GitHub      *
*               see dmsc/bwdos-mads *
*************************************

SRCHADR EQU 128
SIOADR  EQU 130
DNUMB   EQU 132
XFLAG   EQU 133
FFLAG   EQU 134
NBANKS  EQU 135
LDFLG   EQU 136
MAXSECT EQU 137
MAPS    EQU 139
MSAVE   EQU 140
MIX     EQU 141
MKONEC  EQU 142
TEMP1   EQU 144

BUFF    EQU $500
SWTAB   EQU $480

LDA_zp  EQU $A5
STA_zp  EQU $85
STAX_zp EQU $95
LDX_zp  EQU $A6
STX_zp  EQU $86
ROR_zp  EQU $66

        BLK DOS $3700

        JSR _chkbwdos

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

        JSR _print
        DTA B(155)
        DTA C'BW-DOS RAMDISK 1.5D'
        DTA B(155,0)

        JSR GETNAME

        LDY #36
        LDA (10),Y

        CMP #'O'
        BNE START4

        INY
        LDA #'F'
        CMP (10),Y
        BNE STRTHLP
        INY
        CMP (10),Y
        BNE STRTHLP

        INY
        LDA (10),Y
        CMP #$9B
        BNE STRTHLP

        JMP REMOVE

* HELP
STRTHLP JSR _print
        DTA C'Use: RAMDISK drive#[F][E] [conf_file]'
        DTA B(155)
        DTA C'RAMDISK OFF'
        DTA B(155,0)
        JMP (10)

START4  LDA #0
        STA XFLAG
        STA FFLAG

STRT4A  STA DNUMB
        STA STDRIV

STRT4B  LDA (10),Y
        INY
        CMP #$9B
        BEQ START5

        CMP #'N' ;Ignored for compatibility
        BEQ STRT4B

        CMP #'F'
        BNE STRT4C
        STA FFLAG
        BEQ STRT4B

STRT4C  CMP #'E'
        BNE STRT4D
        STA XFLAG
        BEQ STRT4B

STRT4D  EOR #'0'
        BEQ STRTHLP
        CMP #10
        BCS STRTHLP
        BCC STRT4A

START5  LDA DNUMB
        BEQ STRTHLP

* Check for CONFIG file
        JSR GETNAME

        LDY #36
        LDA (10),Y
        CMP #$9B
        BEQ ST5A

        JMP CONFIG1

* No CONFIG file, create default table
ST5A    LDX #63

        LDA #1
        CLC

ST5B    STA SWTAB+1,X
        DEX
        BMI ST5C
        ADC #4
        STA TEMP1
        AND #$10
        ADC TEMP1
        BCC ST5B
        ADC #1
        BNE ST5B

ST5C    STX SWTAB

        JSR RAMTEST

        LDA NBANKS
        BEQ ST5NO

        LDX XFLAG
        BEQ START6J

        SEC
        SBC #4
        STA NBANKS
        BEQ ST5MALO
        BCS START6J

ST5MALO JSR _print
        DTA B(155)
        DTA C'Only 130XE banks available!'
        DTA B(155,0)

ST5AB   JSR _print
        DTA C'Operation aborted.'
        DTA B(155,253,0)

        JMP (10)

START6J JMP START6

ST5NO   JSR _print
        DTA B(155)
        DTA C'No extra memory available!'
        DTA B(155,0)
        JMP ST5AB

CLOSE1  LDA #12
CIO1    LDX #$10
        STA $342,X
        JMP $E456

CONFIG1 LDA #$FF
        LDX #64

CONF1B  STA SWTAB,X
        DEX
        BPL CONF1B

        INX
        STX LDFLG ;#0

        JSR CLOSE1

* Open CONFIG file
        LDA 10
        CLC
        ADC #33
        STA $344+$10
        LDA 11
        ADC #0
        STA $345+$10

        LDA #4
        STA $34A+$10
        LDA #0
        STA $34B+$10

        LDA #3
        JSR CIO1
        BPL CONFIG2

CONFERR JSR CLOSE1

        JSR _print
        DTA B(155)
        DTA C'Cannot read'
        DTA B(0)

CFGE2   JSR _print
        DTA C' configuration file!'
        DTA B(155,0)

        JMP ST5AB

CONFIG2 LDA #0
        STA $348+$10
        STA $349+$10

        LDA #7
        JSR CIO1
        BMI CONFIG3

CONF2B  INC LDFLG
        LDX LDFLG
        CPX #65
        BCS CONFBAD

        STA SWTAB,X
        BCC CONFIG2

CONFBAD JSR CLOSE1

        JSR _print
        DTA B(155)
        DTA C'Invalid'
        DTA B(0)

        JMP CFGE2

CONFIG3 CPY #136
        BNE CONFERR

        JSR CLOSE1

        LDA LDFLG
        BEQ CONFBAD

        JSR RAMTEST

        LDA LDFLG
        CMP NBANKS
        BNE CONFBAD

* Memory test OK
* NBANKS and RBTAB hold extended RAM info
START6  JSR SRCHRUT
        BCC STRT6B

* Resident handler already installed, we need to get old SIO
* address using original code bank, in case banks need to change.
        JSR DISINT
        PHA
        LDY <[R03-RESID]+1  ;Get code bank from low memory handler
        LDA (SRCHADR),Y
        STA $D301

        LDY #1
STRT6A  LDA JSIO+1+RESO,Y
        STA JSIO+1,Y
        DEY
        BPL STRT6A
        PLA
        JSR ENINT
        BNE START7

* Install resident part
STRT6B  LDA 743
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

* Setup SIO and RESET handler
        LDY #1
STRT6D  LDA (SIOADR),Y
        STA JSIO+1,Y
        LDA 12,Y
        STA RESID+1,Y
        LDX SRCHADR,Y
        STX 12,Y
        DEY
        BPL STRT6D

        INY
        LDA <RDSIO-RESID
        CLC
        ADC SRCHADR
        STA (SIOADR),Y
        TYA
        INY
        ADC SRCHADR+1
        STA (SIOADR),Y

* Copy low-memory handler
        LDY <RESLEN
STRT6C  DEY
        LDA RESID,Y
        STA (SRCHADR),Y
        TYA
        BNE STRT6C

* Resident handler installed,
* configure and install code in extended RAM
START7  LDA DNUMB
        STA RR1+1

* Setup MAXSECT
        LDA NBANKS
        LSR @
        STA MAXSECT+1
        LDA #0
        ROR @
        STA MAXSECT

        JSR DECMAXS
        JSR DECMAXS

        LDA MAXSECT
        STA RR5+1
        LDA MAXSECT+1
        STA RR6+1

        JSR DECMAXS

* Setup code bank
        JSR DISINT
        PHA

        LDA RBTAB
        LDY <R03-RESID+1
        STA (SRCHADR),Y
        STA R04+1
        STA R05+1

        STA $D301

        LDX >RES2LEN-1
        LDY <RES2LEN-1

STRT7C  DEY
        LDA RES2+[[RES2LEN-1]&$FF00],Y
        STA $4000+[[RES2LEN-1]&$FF00],Y

        CPY #0
        BNE STRT7C
        DEC STRT7C+3
        DEC STRT7C+6
        DEX
        BPL STRT7C

        PLA
        JSR ENINT

* FORMATOVANI

        LDA FFLAG
        BNE FORM1

        LDA #1
        LDX #'R'
        LDY #64
        JSR RWRD

        LDA BUFF+11
        CMP MAXSECT
        BNE FORM1
        LDA BUFF+12
        CMP MAXSECT+1
        BNE FORM1

        LDA #$80
        CMP BUFF+7
        BNE FORM1
        CMP BUFF+31
        BNE FORM1

        LDA BUFF+32
        CMP #$22
        BNE FORM1
        JMP FORMEND

* #MAPS

FORM1   LDA MAXSECT+1
        LSR @
        LSR @
        TAX
        INX
        STX MAPS
* DIR
        JSR CLBUF

        LDX MAPS
        INX
        INX
        TXA
        INX
        STX BUFF+4

        JSR WRRD

        JSR CLBUF

        LDX #13
FORM1B  LDA VZDIR,X
        STA BUFF+3,X
        DEX
        BPL FORM1B

        LDA MAPS
        CLC
        ADC #3
        JSR WRRD

* BITMAPS
        JSR CLBUF

        LDA MAXSECT
        STA MKONEC
        LDA MAXSECT+1
        LSR @
        ROR MKONEC
        LSR @
        ROR MKONEC
        LSR MKONEC

        LDX #2
        STX MSAVE
        DEX
        STX MIX

* X=1
        LDA MAPS
        ASL @
        TAY
        LDA MPSTB,Y
        STA BUFF-1,X
        LDA MPSTB+1,Y

        DTA B($2C) ;BIT

FORM1C  LDA #$FF
        STA BUFF,X

        LDA MIX
        CMP MAPS
        BEQ FORM1D

FORM1CB INX
        BPL FORM1C

        LDA MSAVE
        JSR WRRD

        JSR CLBUF

        INC MIX
        INC MSAVE

        LDX #0
        BEQ FORM1C

FORM1D  CPX MKONEC
        BNE FORM1CB

        LDA #$FC
        STA BUFF,X

        LDA MSAVE
        JSR WRRD

* BOOT SECTOR

        JSR CLBUF

        LDX #32

FORM1E  LDA VZBOOT,X
        STA BUFF,X
        DEX
        BPL FORM1E

        LDA MAPS
        STA BUFF+15
        CLC
        ADC #2
        STA BUFF+9

        LDA MAXSECT
        STA BUFF+11
        SEC
        SBC MAPS
        TAY
        LDA MAXSECT+1
        STA BUFF+12
        SBC #0
        TAX

        TYA
        SEC
        SBC #4
        STA BUFF+13
        TXA
        SBC #0
        STA BUFF+14

        LDA $D20A
        STA BUFF+39

        LDA #1
        JSR WRRD

        JSR _print
        DTA C'RAM-Disk formatted.'
        DTA B(155)
        DTA B(0)

FORMEND LDA DNUMB
        ORA #$30
        STA PRDNUM
        JSR _print
        DTA C'RAM-Disk is D'
PRDNUM  DTA C'0'
        DTA C': (Size: '
        DTA B(0)

* PRINT SIZE

        LDA #0
        STA MAXSECT+1

        LDA NBANKS
        LDX #3

PRTSZ1  ASL @
        ROL MAXSECT+1
        DEX
        BPL PRTSZ1

        STA MAXSECT

* Divide by 10
        LDX #3
DIV0    STX DIVI+1

        LDX #16
        LDA #0
        CLV

DIV1    CMP #5
        BCC DIV2
        SBC #$85
        SEC

DIV2    ROL MAXSECT
        ROL MAXSECT+1
        ROL @
        DEX
        BNE DIV1

        ORA #$30
DIVI    LDX #0
        STA PRNUM,X
        DEX
        BVS DIV0

        JSR _print
PRNUM   DTA C'    '
        DTA C' kB)'
        DTA B(155,0)

        JMP (10)

MPSTB   DTA A($FF0F,$FF07,$FF03,$FF01)
        DTA A($FF00,$7F00,$3F00,$1F00)
        DTA A($0F00)

VZBOOT  DTA C'S'
        DTA B(3,0,48,$E0,7)
        JMP $3080
        DTA A(0,0,0)
        DTA B(0,2,0,32,0,4,0)
        DTA C'RAM-DISK'
        DTA B(0,128,$22)

VZDIR   DTA B(23,0,0)
        DTA C'MAIN       '

CLBUF   LDX #127
        LDA #0

CLBF2   STA BUFF,X
        DEX
        BPL CLBF2

        RTS

WRRD    LDX #'W'
        LDY #128

RWRD    STX STCMD
        STY STSTAT
        STA STAUX

        LDX #11
RWRD2   LDA STAB,X
        STA $300,X
        DEX
        BPL RWRD2

        LDA 10
        SEC
        SBC #10
        STA SIOJMP+1
        LDA 11
        SBC #0
        STA SIOJMP+2

        JSR SIOJMP
        BMI SIOERR

        RTS

SIOJMP  JMP ($FFFF)

STAB    DTA B($31)
STDRIV  DTA B(0)
STCMD   DTA B(0)
STSTAT  DTA B(0)
        DTA A(BUFF)
        DTA B(7,0)
        DTA A(128)
STAUX   DTA A(0)

SIOERR  JSR _print
        DTA B(155,253)
        DTA C'Internal Error!'
        DTA B(155,0)

        JMP (10)

DECMAXS LDA MAXSECT
        BNE STRT7B
        DEC MAXSECT+1
STRT7B  DEC MAXSECT

        RTS

REMNOT  JSR _print
        DTA B(155)
        DTA C'RAM-Disk not installed!'
        DTA B(155,0)

REMCANT JSR _print
        DTA C'Cannot remove.'
        DTA B(155,253,0)

        JMP (10)

REM2LST JSR _print
        DTA B(155)
        DTA C'RAM-Disk is not the last'
        DTA B(155)
        DTA C'handler installed!'
        DTA B(155,0)

        JMP REMCANT

REMOVE  JSR SRCHRUT
        BCC REMNOT

* Remove handler
REMOV2  LDA 743
        SEC
        SBC SRCHADR
        TAY
        LDA 744
        SBC SRCHADR+1
        BNE REM2LST

        CPY <RESLEN
        BNE REM2LST

* Enable code bank to get old SIO
        JSR DISINT
        PHA
        LDY <R03-RESID+1
        LDA (SRCHADR),Y
        STA $D301

        LDY #1

REM3    INY
        LDA (SRCHADR),Y
        DEY
        STA 12,Y

        LDA SRCHADR,Y
        STA 743,Y

        LDA JSIO+1+RESO,Y
        STA (SIOADR),Y

        DEY
        BPL REM3

* Re-enable original bank and exit
        PLA
        JSR ENINT

        JSR _print
        DTA B(155)
        DTA C'RAM-Disk removed.'
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

        RTS

SRCHNXT LDA SRCHADR
        BNE SNXT2
        DEC SRCHADR+1
SNXT2   DEC SRCHADR

        LDA SRCHADR+1
        CMP #$19
        BCS SRCHR1

        RTS

RAMTEST LDX #63
        LDA #$FF
RT0A    STA RBTAB,X
        DEX
        BPL RT0A

        JSR DISINT
        PHA

* SAVE OLD

        LDX #64

RT0     JSR RSWITCH

        LDA $4080
        STA BUFF,X
        LDA $5032
        STA BUFF+65,X
        LDA $7FFE
        STA BUFF+130,X

        DEX
        BPL RT0

* SET NEW

        LDX #64

RT1     JSR RSWITCH

        STX $4080
        STX $5032
        STX $7FFE

        DEX
        BPL RT1

* TEST

        LDY #0
        LDX #64

RT2     JSR RSWITCH
        CPX $4080
        BNE RT3
        CPX $5032
        BNE RT3
        CPX $7FFE
        BNE RT3

        LDA SWTAB,X
        STA RBTAB,Y
        INY

RT3     DEX
        BNE RT2

        STY NBANKS

* RESTORE OLD

        LDX #64

RT4     JSR RSWITCH

        LDA BUFF,X
        STA $4080
        LDA BUFF+65,X
        STA $5032
        LDA BUFF+130,X
        STA $7FFE

        DEX
        BPL RT4

* END
        PLA

ENINT   STA $D301
        LDA #$40
        STA 54286
        CLI

        RTS

DISINT  LDA #0
        STA 54286
        SEI
        LDA $D301
        RTS

RSWITCH LDA SWTAB,X
        STA $D301

_RTS    RTS

        ICL '_CHKBWD.ICL'
        ICL '_PRINT.ICL'

GETNAME JMP _RTS




* Resident handler in low memory
RESID   JSR $FFFF

R01     LDA #$22
        STA 743
R02     LDA #$22
TST1    STA 744

        RTS

RDSIO   LDA $D301   ;Save original PORTB
        LDY #0
        STY 54286   ;Disable NMI
        SEI         ;Disable IRQ
R03     LDY #$FF
        STY $D301   ;Disable ROM
        JMP $4000

RESLEN  EQU *-RESID





* High memory part, process SIO call
RES2    PHA
        STA WBNK+1+RESO
        LDA $300
        CMP #$31
        BNE STDSIO

        LDA $301
RR1     CMP #0
        BEQ RDS2

* Exit trough stub to standard SIO
STDSIO  LDY <SIOST+10-RES2
        JMP CSTUB+RESO





* Setup read/write address and stub
RDS2    LDX <COPYLEN-1
RDS3    CPX #$11
        BCC RDS3A
        LDA $30,X   ;Save ZP locations >= $41
        PHA
RDS3A   LDA COPYST+RESO,X
        STA $30,X
        DEX
        BPL RDS3

* Asume a READ operation, writes to buffer
        LDA $304
*        STA WADR
        DTA L(STA_zp,WADR)
        LDA $305
*        STA WADR+1
        DTA L(STA_zp,WADR+1)

* Setup length
        LDA $302
        LDY $308
        LDX $309
        BNE R2NAK

        CMP #'S'
        BEQ SSTAT

* Read/Write
R2RW    CPY #128
        BNE R2NAK

* Verify sector number
        LDX $30B
        LDY $30A
        BNE RDS4
        DEX
RDS4    DEY

RR5     CPY #0 ;MAXSECT
        TXA
RR6     SBC #0 ;MAXSECT+1
        BCS R2NAK

        TYA
        ADC #3 ; Reserve 3 sectors at start of RAMDISK
        BCC RR6B
        INX
RR6B    TAY
        ORA #$80
        LSR @
*        STA RADR+1
        DTA L(STA_zp,RADR+1)
*        ROR RADR
        DTA L(ROR_zp,RADR)

        TYA
        ASL @
        TXA
        ROL @
        TAY ; Y = (SECTOR+1)/128 = BANK#
        LDX RBTAB+RESO,Y

        LDY #127    ;Copy length
        LDA $302
        CMP #'R'
        BEQ SREAD
        CMP #'W'
        BEQ SWRITE
        CMP #'P'
        BEQ SWRITE

* SIO error
R2NAK   LDY #139
        BNE R2XIT

* Write operation, should swap buffers
SWRITE  LDA WBNK+1+RESO
        STX WBNK+1+RESO
*        STA RBNK
        DTA L(STA_zp,RBNK)
*        LDA RADR
        DTA L(LDA_zp,RADR)
*        LDX WADR
        DTA L(LDX_zp,WADR)
*        STA WADR
        DTA L(STA_zp,WADR)
*        STX RADR
        DTA L(STX_zp,RADR)
*        LDA RADR+1
        DTA L(LDA_zp,RADR+1)
*        LDX WADR+1
        DTA L(LDX_zp,WADR+1)
*        STA WADR+1
        DTA L(STA_zp,WADR+1)
*        STX RADR+1
        DTA L(STX_zp,RADR+1)

        LDA #$80
        BNE R2CPY

* STATUS - read from pre-defined area
SSTAT   LDA <[RDSTAT+RESO]
*        STA RADR
        DTA L(STA_zp,RADR)
        LDA >[RDSTAT+RESO]
*        STA RADR+1
        DTA L(STA_zp,RADR+1)

        CPY #4
        BNE R2NAK

R05     LDX #$FF
        DEY
        BEQ R2NAK

* SREAD   STX RBNK
SREAD   DTA L(STX_zp,RBNK)
        LDA #$40
R2CPY   CMP $303
        BNE R2NAK
WBNK    LDX #$FF
        JSR $30
        LDY #1

R2XIT   STY $303
* Restore ZP
        LDX <$100-[COPYLEN-$11]
RZP     PLA
*        STA $30+COPYLEN,X
        DTA L(STAX_zp,$30+COPYLEN)
        INX
        BNE RZP
        LDY <[EXTST+10-RES2]
* Fall through

* Copy STUB to low memory and jump
CSTUB   LDX #10
CST1    LDA $4000,Y
        STA $30,X
        DEY
        DEX
        BPL CST1
        PLA
        LDX #$40
        JMP $0030

* Exit jumping to standard SIO
SIOST   STA $D301
        CLI
        STX 54286
JSIO    JMP $FFFF

* Exit with Y=status
EXTST   STA $D301
        CLI
        STX 54286
        LDY $303
        RTS


* Copy from one bank to another
COPYST  LDA #$FF
RBNK    EQU *-1-COPYST+$30
        STA $D301   ; SRC BANK
RADR    EQU *+1-COPYST+$30
        LDA $4000,Y
        STX $D301   ; DST BANK
WADR    EQU *+1-COPYST+$30
        STA $FF00,Y
        DEY
        BPL COPYST
R04     LDA #$FF
        STA $D301   ; CODE BANK
        RTS
COPYLEN EQU *-COPYST


RDSTAT  DTA B($10,$FF,$FF,$FF)

RBTAB   EQU *

RESO    EQU $4000-RES2
RES2LEN EQU RBTAB+64-RES2
