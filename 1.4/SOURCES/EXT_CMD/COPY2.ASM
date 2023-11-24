*************************************
*                                   *
*       C O P Y   PRO BW-DOS 1.4    *
*                                   *
*************************************

        ICL '_SYSEQU.ICL'

SRCIX   EQU $80
DSTIX   EQU $81
TMP     EQU $82
FFLAG   EQU $83
DSTAUX1 EQU $84
ENDFLG  EQU $85
NOFLAG  EQU $86
OPNIF   EQU $87
OPNOF   EQU $88
DIRENDF EQU $89

COPLEN  EQU $8A ;$8A-$8D
DIRBUF  EQU $8E ;64 bytes, up to $CD
DSTMSK  EQU $CE ;12 bytes, up to $DA

SRC     EQU $500
DST     EQU $540

        BLK DOS $3000

* Check BW-DOS
START   LDA $700
        CMP #'S'
        BEQ START2
        JSR PRINT
        DTA B($9b,$fd)
        DTA C'Incorrect DOS version'
        DTA B($9b,0)
        JMP (DOSVEC)

* get CRNAME
START2  LDA DOSVEC
        CLC
        ADC #3
        STA GETNAME+1
        LDA DOSVEC+1
        ADC #$00
        STA GETNAME+2
* No parameters?
        LDY #$0A
        LDA (DOSVEC),Y  ;BUFOFF
        CLC
        ADC #63
        TAY
        LDA #$9B
        CMP (DOSVEC),Y ;LBUF+BUFOFF
        BNE START2A
* Show help
        JSR PRINT
        DTA B($9b)
        DTA C'BW-DOS COPY 1.4D'
        DTA B($9b)
        DTA C'Syntax: COPY source destination[/A]'
        DTA B($9b,0)
        JMP (DOSVEC)

* A=$9B  ;LDA #$9B
START2A JSR PRT1
        JSR CLOSES

        LDA #0
        JSR GETPAR
        STA SRCIX

        LDA #DST-SRC
        JSR GETPAR
        STA DSTIX

* Source with wild-card -> use DIR
        LDX SRCIX
STRT3   LDA SRC,X
        INX
        CMP #'?'
        BEQ DCOP1
        CMP #'*'
        BEQ DCOP1
        CMP #$9B
        BNE STRT3

* For "D:", use DIR to preserve DATE/TIME
        LDA SRC
        CMP #'D'
        BEQ DCOP1

* Copy only 1 file!
        JSR ADDSTAR
        LDY SRCIX
        JSR GETMASK
        LDX #11
STRT4   LDA DSTMSK,X
        STA DIRBUF,X
        DEX
        BPL STRT4

* Get mask and set AUX
        JSR GDMASK
        JSR RENAMIT
        BCS STRT4E
        JSR COPY1
        JMP ERR5
STRT4E  LDY #165 ; illegal file name
        JMP ERROR

* Adds "*.*" at the end of path if no file name
ADDSTAR LDX SRCIX ;Add to SRC
        JSR STAR1
        LDX DSTIX ;Add to DST
STAR1   LDA SRC,X
        CMP #$9B
        BNE DCOP1AX
        LDY #3
DCOP1A  LDA STARS,Y
        STA SRC,X
        INX
        DEY
        BPL DCOP1A
DCOP1AX RTS

* Disk copy
DCOP1   JSR ADDSTAR

* Get dest mask and set AUX
        JSR GDMASK

* Open directory
        LSR NOFLAG
        LSR DIRENDF

        JSR DIROPEN
        JMP COPY3T

* Disk copy loop
DC2ERR  JSR GETDIRP
        JMP COPY3T

DCOP2D  LDY SRCIX
        JSR DC2DGET
        BCS DC2ERR
        JSR RENAMIT
        BCS DC2ERR

* TIME/DATE
        LDA #0
        BIT FFLAG
        BPL DCOP2EB

        LDY #19
        LDX #20
* Convert two ASCII digits to number.
* Assume that all digits $30 to $39.
DCOP2E  LDA DIRBUF,X
        ASL @
        ASL @
        ADC DIRBUF,X
        ASL @
        CLC
        ADC DIRBUF+1,X
        SEC
        SBC #16
        STA (DOSVEC),Y
        INX
        INX
        INX
        INY
        CPY #24
        BNE DCOP2E

        LDA #0
        STA (DOSVEC),Y
        LDA #$FF

DCOP2EB LDY #25     ;TDOVER
        STA (DOSVEC),Y

        JSR GETDIRP

* Same file? (Only for "D:")
        LDA SRC
        CMP #'D'
        BNE COP3

        LDX #$FF
COP2    INX
        LDA SRC,X
        CMP DST,X
        BNE COP3
        CMP #$9B
        BNE COP2

        JSR PRINT
        DTA B($9b)
        DTA C'Can''t copy a file to itself!'
        DTA B($9b,0)
        JMP ERR5X

* Print source
COP3    JSR PRINT
        DTA C'Copying '
        DTA b(0)
* A=0
*       LDA #0
        STA $349
        TAX
* <SRC = 0
*       LDY <SRC
        TAY
        LDA #64
        STA $348
        LDA >SRC
        STA $345
        LDA #9
        JSR CIOCMD

        SEC
        ROR NOFLAG
        JSR COPY1

COPY3T  LDA DIRENDF
        BMI COPY3X
        JMP DCOP2D

COPY3X  LDA NOFLAG
        BPL DC2XER
        JMP ERR5

* Copy 1 file
COPY1   JSR CLOSE23
        LDA #$80
        STA OPNIF
        STA OPNOF
        STA ENDFLG

* Copy
COP4    LDX #3
* Set COPEND2 to MEMTOP and COPAD to MEMLO
COP4B   LDA MEMTOP,X
        STA COPEND2,X
        LDA #0
        STA COPLEN,X
        DEX
        BPL COP4B
* A=0
        JSR READIT
        BEQ COP4C
        LDA #2
        JSR READIT
        BNE COP4D

COP4C   ASL ENDFLG
        JSR CLOSE2

COP4D   LDA #0
        JSR WRITEIT
        LDA #2
        JSR WRITEIT
        BIT ENDFLG
        BMI COP4
        JMP CLOSE23

* Error: File not found
DC2XER  LDY #170
        BNE ERRORJ

* keep together, accessed by index
COPEND  DTA A(START)
COPEND2 DTA A($8000)
COPAD   DTA A($5000,ENDC)

* Read file
READIT  ASL OPNIF   ;Need OPEN?
        BCC RDIT2

        PHA
        LDX #$20    ;OPEN!
        LDA #4
        LDY <SRC
        JSR OPEN    ;C=1
        PLA

RDIT2   TAY
        PHA

        LDA COPEND,Y
        SEC
        SBC COPAD,Y
        STA $348+$20
        LDA COPEND+1,Y
        SBC COPAD+1,Y
        STA $349+$20

        LDX #$20
        LDA #7
        JSR RDWR

        PLA
        TAX

        LDA $348+$20
        STA COPLEN,X
        LDA $349+$20
        STA COPLEN+1,X

        TYA
        BPL RDITEX
        CPY #136 ; End of file
        BNE ERRORJ
* Z=1 on EOF
RDITEX  RTS

* Write file
WRITEIT ASL OPNOF   ;Need OPEN?
        BCC WRIT2

        PHA
        LDX #$30    ;OPEN!
        LDA DSTAUX1
        LDY <DST
        JSR OPEN    ;C=1
        PLA

WRIT2   TAX
        TAY

        LDA COPLEN,X
        STA $348+$30
        LDA COPLEN+1,X
        STA $349+$30

        ORA COPLEN,X
        BEQ RDITEX

        LDX #$30
        LDA #11
        JSR RDWR
        BPL RDITEX

* Jump error
ERRORJ  JMP ERROR

* Read Write
RDWR    STA $342,X
        LDA COPAD+1,Y
        STA $345,X
        LDA COPAD,Y
        JMP CIOBAL

* Get mask
GDMASK  LDY DSTIX
GETMASK LDX #0
        LDA #6
        STA TMP
        BNE DC1B1B

DC1BSTR LDA #'?'
        JSR DC1BPUT
        BCC DC1BSTR

DC1BZN  JSR DC1BPUT

DC1B1   INY

DC1B1B  LDA SRC,Y
        CMP #'*'
        BEQ DC1BSTR

        CMP #'.'
        BEQ DC1BTEC

        JSR JELIPL
        BCC DC1BZN

* Invalid filename (C=1)
        ROR TMP

DC1BTEC LDA #$20
        JSR DC1BPUT
        BCC DC1BTEC
* C=1
        ROR TMP
        BCC DC1B1
* END
        LDA #8
        STA DSTAUX1

        LDA SRC,Y
        CMP #'/'
        BNE DCOP1BX

        LDA SRC+1,Y
        CMP #'A'
        BNE DCOP1BX

        INC DSTAUX1

DCOP1BX RTS

DC1BPUT CPX #8
        BCC DC1BP2

        BIT TMP
        BPL DC1BP1

        CPX #11
        BCC DC1BP3

DC1BP1  RTS

DC1BP2  STA DSTMSK,X
DC1BP3  INX
        STA DSTMSK,X
        RTS

* Directory open error
DIROPE  LDY #148    ;Bad DIR.
        BNE ERRORJ

* Directory open
DIROPEN LSR FFLAG

        LDA SRC
        EOR #'D'
        CMP #1      ;C=0 if SRC="D*"
        LDA #6
        LDY <SRC
        LDX #$10
        JSR OPEN

        JSR DIRGET
        BMI DIROPE

        LDA DIRBUF
        CMP #$9B    ;Blank line
        BNE GETDP2

        JSR DIRGET
        BMI DIROPE

        LDA DIRBUF+1
        CMP #'o'    ;"Volume"
        BNE GETDP2

        JSR DIRGET  ;"Directory"
        BMI DIROPE
        JSR DIRGET  ;Blank line
        BMI DIROPE

        SEC
        ROR FFLAG

* Prepare directory entry
GETDIRP JSR DIRGET
        BMI DCOP2EX ;C=1 on EOF

GETDP2  LDA FFLAG
        BMI DCOP2C

* Short directory entries
        LDA DIRBUF
        CMP #$30    ;End of dir (free sectors)
        BCS DCOP2EX

        LDA DIRBUF+10
        BMI GETDIRP ;Ignore directories

* Reformat name simulating long entry
        LDX     #2
        LDY     #0
DCOP2BC LDA DIRBUF,X
        STA DIRBUF,Y
        INX
        INY
        CPX #10
        BNE DCOP2BD
        INY
DCOP2BD CPX #13
        BCC DCOP2BC
DIROP2  RTS

* Long directory entries
DCOP2C  LDA DIRBUF+17
        CMP #$3A    ;Number or SPACE?
        BCC DIROP2

        CMP #$40
        BCC GETDIRP ;"<DIR>", skip

* EOF (C=1)  ;SEC
DCOP2EX ROR DIRENDF

CLOSE1  LDX #$10
        BNE CLOS3

* PRINT string from code
PRINT   TSX
        INC     $101,X
        BNE     PRINT2
        INC     $102,X
PRINT2  LDA     $102,X
        STA     PRINT3+2
        LDY     $101,X
PRINT3  LDA     $FF00,Y
        BEQ     PRTEX
        JSR     PRT1
        BPL     PRINT
* Returns with A=0
PRTEX   RTS

* PRINT 1 CHARACTER IN A
PRT1    LDY     #11
        LDX     #0
        STX     $348
CIOXY0  STX     $349
        STY     $342
        JMP     $E456

* Get parameter
GETPAR  PHA
GETNAME JSR GETNAME
        PLA
        TAX
        LDY #33
GTPAR0  STX TMP
GTPAR1  LDA (10),Y
        STA SRC,X
        INX
        INY
        CMP #':'
        BEQ GTPAR0
        CMP #'>'
        BEQ GTPAR0
        CMP #'<'
        BEQ GTPAR0
        CMP #$9B
        BNE GTPAR1
        LDA TMP
        RTS

* close all
CLOSES  LDY #25     ;TDOVER
        LDA #0
        STA (DOSVEC),Y
        JSR CLOSE1
CLOSE23 LDX #$30
        JSR CLOS3
CLOSE2  LDX #$20
CLOS3   LDA #12
        JSR CIOCMD
        BMI ERROR
        RTS

* Constant for *.*
STARS   DTA B($9b)
        DTA C'*.*'

* open 
OPEN    STA $34A,X
        LDA #0
        ROR @
        EOR #$80
        STA $34B,X
        LDA >SRC
        STA $345,X
        LDA #3
        JSR CIOCMD
        BMI ERROR
* Command OK
DGETOK  TYA
        RTS

CIOCMD  STA $342,X
        TYA
CIOBAL  STA $344,X
        JMP $E456
***

* Get directory
DIRGET  LDY <DIRBUF
        LDA >DIRBUF
        STA $345+$10
* A=0
*       LDA #0
        STA $349+$10
        LDA #64
        STA $348+$10

        LDX #$10
        LDA #5
        JSR CIOCMD
        BPL DGETOK

        CPY #136
        BEQ DGETOK

* Show ERROR and number
ERROR   TYA
        LDX #$FD
ERR2    SEC
ERR4    SBC ERRTAB-$FD,X
        INC ERR4N-$FD,X
        BCS ERR4
        ADC ERRTAB-$FD,X
        INX
        BNE ERR2

        JSR PRINT
        DTA B($9B)
        DTA C"Error "
ERR4N   DTA C"///"
        DTA B($9B,0)

* Stop batch
ERR5X   LDY #8
        LDA (10),Y
        STA ERR5Y+1
        INY
        LDA (10),Y
        STA ERR5Y+2
        LDY #1
ERR5Y   JSR $E474
* Close all and exit to DOS
ERR5    JSR CLOSES
        JMP (DOSVEC)

* Decimals for hex-dec conversion
ERRTAB  DTA B(100,10,1)

* Rename
RENAMIT LDX #11

DCOP2DB LDA DSTMSK,X
        CMP #'?'
        BEQ DCOP2DC
        STA DIRBUF,X
DCOP2DC DEX
        BPL DCOP2DB
* After renaming destination, converts into file.ext
        LDY DSTIX
* Copy expanded name in DIRBUF to name.ext in SRC/DST
DC2DGET LDA #' '
        STA DIRBUF+12
        STA DIRBUF+8

        LDX #255
        BMI DC2DG2B

DC2DG2  JSR JELIPL
        BCS DC2DG5

DC2DG2A STA SRC,Y
        INY

DC2DG2B INX
        LDA DIRBUF,X
        CMP #' '
        BNE DC2DG2

        LDA #'.'
        CPX #9
        LDX #8
        BCC DC2DG2A

        LDA #$9B
        STA SRC,Y

JLPP    CLC
DC2DG5  RTS

* Check valid char for file name
JELIPL  CMP #'?'
        BEQ JLPP

        CMP #'_'
        BEQ JLPP

        CMP #'0'
        BCC JLPM
        CMP #'9'+1
        BCC JLPP
        CMP #'A'
        BCC JLPM
        CMP #'Z'+1
        RTS

JLPM    SEC
        RTS

ENDC    EQU *

        END
