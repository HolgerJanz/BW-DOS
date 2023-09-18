*************************************
*      BW-DOS 1.4 RAMDISK           *
* Original: Jiri Bernasek           *
* MADS version: dmsc on GitHub      *
*               see dmsc/bwdos-mads *
*************************************

SRCHADR equ $80
SIOADR  equ $82
DNUMB   equ $84
XFLAG   equ $85
FFLAG   equ $86
NBANKS  equ $87
LDFLG   equ $88
MAXSECT equ $89
MAPS    equ $8B
MSAVE   equ $8C
MIX     equ $8D
MKONEC  equ $8E
TEMP1   equ $90

BUFF    equ $500
SWTAB   equ $480

BIT_abs equ $2C

        icl '_SYSEQU.ICL'

        blk DOS $3000

        jsr _print
        dta B(155)
        dta C'BW-DOS 1.4 RAMDISK 15-09-2023'
        dta B(155,0)

        jsr _chkbwdos14

        lda <BW_LSIO
        sta SIOADR
        lda >BW_LSIO
        sta SIOADR+1

* check extended and set PORTB or Axlon
        jsr SWPORTB
        jsr RAMTEST ; can switch to Axlon

* first parameter
        jsr BW_CRNAME

* check for OFF
        ldy #SD_COMFNAM+3
        lda (DOSVEC),Y
        cmp #'O'
        bne START4

        iny
        lda #'F'
        cmp (DOSVEC),Y
        bne STRTHLP

        iny
        cmp (DOSVEC),Y
        bne STRTHLP

        iny
        lda (DOSVEC),Y
        cmp #$9B
        beq JREMOVE

        cmp #'A'
        bne STRTHLP

        iny
        lda (DOSVEC),Y
        cmp #$9B
        bne STRTHLP
        jsr SWAXLON

JREMOVE jmp REMOVE

* help
STRTHLP jsr _print
        dta C'Use:'
        dta B(155)
        dta C' RAMDISK.SYS (n[F][E][A] [file])|OFF[A]'
        dta B(155,0)
        jmp (DOSVEC)

START4  lda #0
        sta XFLAG
        sta FFLAG

STRT4A  sta DNUMB
        sta STDRIV

STRT4B  lda (DOSVEC),Y
        iny
        cmp #$9B
        beq START5

        cmp #'F'
        bne STRT4C
        sta FFLAG
        beq STRT4B

STRT4C  cmp #'E'
        bne STRT4E
        sta XFLAG
        beq STRT4B

STRT4E  cmp #'A'
        bne STRT4D
        lda BNKOFF
        beq STRT4B
        tya
        pha
        jsr SWAXLON
        jsr RAMTEST
        pla
        tay
        jmp STRT4B

STRT4D  eor #'0'
        beq STRTHLP
        cmp #5
        bcc STRT4A
        cmp #8
        beq STRT4A
        bne STRTHLP

START5  lda DNUMB
        beq STRTHLP

* second parameter
        jsr BW_CRNAME

* check for CONFIG file
        ldy #SD_COMFNAM+3
        lda (DOSVEC),Y
        cmp #$9B
        beq ST5A
        jmp CONFIG1

* check for extended memory
ST5A    lda NBANKS
        beq ST5NO
* no E option for Axlon
        ldx BNKOFF
        beq START6J
* check option E for PRTB
        ldx XFLAG
        beq START6J
* if option E then substract 4
        sec
        sbc #4
        sta NBANKS
        beq ST5MALO
        bcs START6J
*  no extra banks left
ST5MALO jsr _print
        dta C'Only 130XE banks available'
        dta B(155,0)
ST5AB   jsr _print
        dta C'Operation aborted'
        dta B(155,0)
        jmp (DOSVEC)
* everything OK, start ini process
START6J jmp START6
* no extra memory at all
ST5NO   jsr _print
        dta C'No extra memory available'
        dta B(155,0)
        jmp ST5AB

CLOSE1  lda #12
CIO1    ldx #$10
        sta $342,X
        jmp CIOV

* load config file
CONFIG1 lda BNKOFF
        ldx #64
CONF1B  sta SWTAB,X
        dex
        bpl CONF1B

        inx
        stx LDFLG ;#0

        jsr CLOSE1

* open config file
        lda <BW_COMFNAM
        sta $344+$10
        lda >BW_COMFNAM
        sta $345+$10
        lda #4
        sta $34A+$10
        lda #0
        sta $34B+$10
        lda #3
        jsr CIO1
        bpl CONFIG2

CONFERR jsr CLOSE1
        jsr _print
        dta C'Cannot read'
        dta B(0)
CFGE2   jsr _print
        dta C' configuration file'
        dta B(155,0)
        jmp ST5AB

* read config file
CONFIG2 lda #0
        sta $348+$10
        sta $349+$10
        lda #7
        jsr CIO1
        bmi CONFIG3
* check max length of conf file
        inc LDFLG
        ldx LDFLG
        cpx #65
        bcs CONFBAD
        sta SWTAB,X
        bcc CONFIG2

CONFBAD jsr CLOSE1
        jsr _print
        dta C'Invalid'
        dta B(0)
        jmp CFGE2

CONFIG3 cpy #136
        bne CONFERR

        jsr CLOSE1

* check for empty config file
        lda LDFLG
        beq CONFBAD

        jsr RAMTEST

* check length against bank count
        lda LDFLG
        cmp NBANKS
        bne CONFBAD

* memory test OK,
* NBANKS and RBTAB hold extended RAM info
START6  jsr SRCHRUT
        bcc STRT6B

* Resident handler already installed, we need to get old SIO
* address using original code bank, in case banks need to change.
        jsr DISINT
        pha
        ldy <[R03-RESID]+1  ;Get code bank from low memory handler
        lda (SRCHADR),Y
        jsr SAPORTB

        ldy #1
STRT6A  lda JSIO+1+RESO,Y
        sta JSIO+1,Y
        dey
        bpl STRT6A
        pla
        jsr ENINT
        bne START7

* Install resident part
STRT6B  lda MEMLO
        sta SRCHADR
        clc
        adc <RESLEN
        sta MEMLO
        sta R01+1

        lda MEMLO+1
        sta SRCHADR+1
        adc #0
        sta MEMLO+1
        sta R02+1

* Setup SIO and RESET handler
        ldy #1
STRT6D  lda (SIOADR),Y
        sta JSIO+1,Y
        lda 12,Y
        sta RESID+1,Y
        ldx SRCHADR,Y
        stx 12,Y
        dey
        bpl STRT6D

        iny
        lda <RDSIO-RESID
        clc
        adc SRCHADR
        sta (SIOADR),Y
        tya
        iny
        adc SRCHADR+1
        sta (SIOADR),Y

* Copy low-memory handler
        ldy <RESLEN
STRT6C  dey
        lda RESID,Y
        sta (SRCHADR),Y
        tya
        bne STRT6C

* Resident handler installed,
* configure and install code in extended RAM
START7  lda DNUMB
        sta RR1+1

* Setup MAXSECT
        lda NBANKS
        lsr @
        sta MAXSECT+1
        lda #0
        ror @
        sta MAXSECT

        jsr DECMAXS
        jsr DECMAXS

        lda MAXSECT
        sta RR5+1
        lda MAXSECT+1
        sta RR6+1

        jsr DECMAXS

* Setup code bank
        jsr DISINT
        pha

        lda RBTAB
        ldy <R03-RESID+1
        sta (SRCHADR),Y
        sta R04+1
        sta R05+1

        jsr SAPORTB

        ldx >RES2LEN-1
        ldy <RES2LEN-1

STRT7C  dey
STRT7C1 lda RES2+[[RES2LEN-1]&$FF00],Y
STRT7C2 sta $4000+[[RES2LEN-1]&$FF00],Y
        cpy #0
        bne STRT7C
        dec STRT7C1+2
        dec STRT7C2+2
        dex
        bpl STRT7C

        pla
        jsr ENINT

* FORMATOVANI

        lda FFLAG
        bne FORM1

        lda #1
        ldx #'R'
        ldy #64
        jsr RWRD

        lda BUFF+11
        cmp MAXSECT
        bne FORM1
        lda BUFF+12
        cmp MAXSECT+1
        bne FORM1

        lda #$80
        cmp BUFF+7
        bne FORM1
        cmp BUFF+31
        bne FORM1

        lda BUFF+32
        cmp #$22
        bne FORM1
        jmp FORMEND

FORM1   jsr _print
        dta C'Format Ramdisk'
        dta B(155)
        dta B(0)

* #MAPS
        lda MAXSECT+1
        lsr @
        lsr @
        tax
        inx
        stx MAPS
* DIR
        jsr CLBUF

        ldx MAPS
        inx
        inx
        txa
        inx
        stx BUFF+4

        jsr WRRD

        jsr CLBUF

        ldx #13
FORM1B  lda VZDIR,X
        sta BUFF+3,X
        dex
        bpl FORM1B

        lda MAPS
        clc
        adc #3
        jsr WRRD

* BITMAPS
        jsr CLBUF

        lda MAXSECT
        sta MKONEC
        lda MAXSECT+1
        lsr @
        ror MKONEC
        lsr @
        ror MKONEC
        lsr MKONEC

        ldx #2
        stx MSAVE
        dex
        stx MIX

* X=1
        lda MAPS
        asl @
        tay
        lda MPSTB,Y
        sta BUFF-1,X
        lda MPSTB+1,Y

        dta B(BIT_abs)

FORM1C  lda #$FF
        sta BUFF,X

        lda MIX
        cmp MAPS
        beq FORM1D

FORM1CB inx
        bpl FORM1C

        lda MSAVE
        jsr WRRD

        jsr CLBUF

        inc MIX
        inc MSAVE

        ldx #0
        beq FORM1C

FORM1D  cpx MKONEC
        bne FORM1CB

        lda #$FC
        sta BUFF,X

        lda MSAVE
        jsr WRRD

* BOOT secTOR

        jsr CLBUF

        ldx #32

FORM1E  lda VZBOOT,X
        sta BUFF,X
        dex
        bpl FORM1E

        lda MAPS
        sta BUFF+15
        clc
        adc #2
        sta BUFF+9

        lda MAXSECT
        sta BUFF+11
        sec
        sbc MAPS
        tay
        lda MAXSECT+1
        sta BUFF+12
        sbc #0
        tax

        tya
        sec
        sbc #4
        sta BUFF+13
        txa
        sbc #0
        sta BUFF+14

        lda RANDOM
        sta BUFF+39

        lda #1
        jsr WRRD

FORMEND lda DNUMB
        ora #$30
        sta PRDNUM
        jsr _print
        dta C'Ramdisk D'
PRDNUM  dta C'0: '
        dta B(0)

* print size
        lda #0
        sta BW_DECIN+1
        lda NBANKS
        ldx #3
PRTSZ1  asl @
        rol BW_DECIN+1
        dex
        bpl PRTSZ1
        sta BW_DECIN

        jsr CONVDC

        ldx #$03
PRTSZ2  lda BW_DECOUT+4,X
        sta PRNUM,X
        dex
        bpl PRTSZ2

        jsr _print
PRNUM   dta C'0000'
        dta C'kB '
        dta b(0)
        lda BNKOFF
        bne PPORTB
        jsr _print
        dta c'AXLON'
        dta B(155,0)
        jmp (DOSVEC)
PPORTB  jsr _print
        dta c'PORTB'
        dta B(155,0)
        jmp (DOSVEC)

* ====================================
* subroutines

CONVDC  jmp (BW_CONVDC)

MPSTB   dta A($FF0F,$FF07,$FF03,$FF01)
        dta A($FF00,$7F00,$3F00,$1F00)
        dta A($0F00)

VZBOOT  dta C'S'
        dta B(3,0,48,$E0,7)
        jmp $3080
        dta A(0,0,0)
        dta B(0,2,0,32,0,4,0)
        dta C'RAMDISK'
KNAME   dta C'B'
        dta B(0,128,$22)

VZDIR   dta B(23,0,0)
        dta C'MAIN       '

CLBUF   ldx #127
        lda #0

CLBF2   sta BUFF,X
        dex
        bpl CLBF2

        rts

WRRD    ldx #'W'
        ldy #128

RWRD    stx STCMD
        sty STSTAT
        sta STAUX

        ldx #11
RWRD2   lda STAB,X
        sta $300,X
        dex
        bpl RWRD2

        jsr BW_SIO
        bpl _RTS
        tya
        jmp (BW_FAIL)
_RTS    rts

STAB    dta B($31)
STDRIV  dta B(0)
STCMD   dta B(0)
STSTAT  dta B(0)
        dta A(BUFF)
        dta B(10,0)
        dta A(128)
STAUX   dta A(0)

DECMAXS lda MAXSECT
        bne STRT7B
        dec MAXSECT+1
STRT7B  dec MAXSECT

        rts

REMNOT  jsr _print
        dta C'Ramdisk not installed'
        dta B(155,0)

REMCANT jsr _print
        dta C'Cannot remove'
        dta B(155,0)

        jmp (10)

REM2LST jsr _print
        dta C'Ramdisk is not the last handler'
        dta B(155,0)

        jmp REMCANT

REMOVE  jsr SRCHRUT
        bcc REMNOT

* Remove handler
        lda MEMLO
        sec
        sbc SRCHADR
        tay
        lda MEMLO+1
        sbc SRCHADR+1
        bne REM2LST

        cpy <RESLEN
        bne REM2LST

* Enable code bank to get old SIO
        jsr DISINT
        pha
        ldy <R03-RESID+1
        lda (SRCHADR),Y
        jsr SAPORTB

        ldy #1

REM3    iny
        lda (SRCHADR),Y
        dey
        sta 12,Y

        lda SRCHADR,Y
        sta MEMLO,Y

        lda JSIO+1+RESO,Y
        sta (SIOADR),Y

        dey
        bpl REM3

* Re-enable original bank and exit
        pla
        jsr ENINT

        jsr _print
        dta C'Ramdisk removed'
        dta B(155,0)

        jmp (DOSVEC)

* search resident handler
* between MEMLO and startup MEMLO
SRCHRUT lda MEMLO
        sec
        sbc <RESLEN-1
        sta SRCHADR
        lda MEMLO+1
        sbc #0
        sta SRCHADR+1
* increase search address
SRCHNXT lda SRCHADR
        bne SNXT2
        dec SRCHADR+1
SNXT2   dec SRCHADR
* check search address is greater
* than startup MEMLO
        lda SRCHADR+1
        cmp BW_SMEMLO+1
        beq SRCHL
        bcs SRCHR1
        rts
SRCHL   lda SRCHADR
        cmp BW_SMEMLO
        bcs SRCHR1
        rts
* serach handler pattern
SRCHR1  ldy <R03-RESID
SRCHR2  lda (SRCHADR),Y
        cmp RESID,Y
        bne SRCHNXT
        dey
        cpy <TST1-RESID
        bne SRCHR2
        rts

* Check Extended Memory
RAMTEST jsr DISINT
        pha

DACAPO  lda #$00
        sta $3000 ; would collide with $7000

* clear banking tab
        ldx #63
        lda BNKOFF
RT0A    sta RBTAB,X
        dex
        bpl RT0A

* save
        ldx #64
RT0     jsr RSWITCH
        lda $7000
        sta BUFF,X
        dex
        bpl RT0

* set
        ldx #64
RT1     jsr RSWITCH
        stx $7000
        dex
        bpl RT1

* check extended
        ldy #0
        ldx #64
RT2     jsr RSWITCH
        cpx $7000
        bne RT3
        lda SWTAB,X
        sta RBTAB,Y
        iny
RT3     dex
        bne RT2

* check main banking => sub 4 banks
        lda $3000
        beq RT31
        tya
        beq RT31
        sec
        sbc #$03
        pha
* skip 3 highest banks,
* one is already skipped
        tax
        ldy #$00
RT32    lda RBTAB+3,Y
        sta RBTAB,Y
        iny
        dex
        bne RT32
        pla
        tay
* save bank count
RT31    sty NBANKS

* restore
        ldx #64
RT4     jsr RSWITCH
        lda BUFF,X
        sta $7000
        dex
        bpl RT4

* if no PORTB banks, try Axlon
        lda NBANKS
        bne RTEND
        lda BNKOFF
        beq RTEND
        jsr SWAXLON
        jmp DACAPO

* finished
RTEND   pla
ENINT   jsr SAPORTB
        lda #$40
        sta NMIEN
        cli
        dec CRITIC
        rts

DISINT  inc CRITIC
* wait for vertical blank interrupt
        lda RTCLOK+2
WAITLP  cmp RTCLOK+2
        beq WAITLP
        lda #0
*        sta DMACTL
        sta NMIEN
        sei
PORTB0  lda PORTB
        rts

RSWITCH lda SWTAB,X
        jsr SAPORTB
        rts

SAPORTB sta PORTB
        rts

* create PORTB table
SWPORTB ldx #63
        lda #1
        clc
ST5B    sta SWTAB+1,X
        dex
        bmi ST5C
        adc #4
        sta TEMP1
        and #$10
        adc TEMP1
        bcc ST5B
        adc #1
        bne ST5B
ST5C    stx SWTAB
        rts

* switch to Axlon
* set all write operations
SWAXLON lda <AXLON
        sta SAPORTB+1
        sta PORTB1+1
        sta SIOST+1
        sta EXTST+1
        sta PORTB2+1
        sta PORTB3+1
        sta PORTB4+1
        lda >AXLON
        sta SAPORTB+2
        sta PORTB1+2
        sta SIOST+2
        sta EXTST+2
        sta PORTB2+2
        sta PORTB3+2
        sta PORTB4+2
* set all read operation
* Axlon register is write only
* => always return 0, banking off
        ldx #$02
NXTAXLR lda RDBNKR,X
        sta PORTB0,X
        sta RDSIO,X
        dex
        bpl NXTAXLR
* built bank tab
        ldx #64
NXTAXLN txa
        sta SWTAB,X
        dex
        bpl NXTAXLN
* set flags
        inc BNKOFF
        lda #'A'
        sta KNAME
        rts

BNKOFF  dta b($FF)

* read Axlon register always 0, it is read only
RDBNKR  lda #$00
        nop

        icl '_CHKBW14.ICL'
        icl '_PRINT.ICL'

* ====================================
* resident handler in low memory
RESID   jsr $FFFF
R01     lda #$22
        sta MEMLO
R02     lda #$22
TST1    sta MEMLO+1
        rts

RDSIO   lda PORTB   ;Save original PORTB
        ldy #0
        sty NMIEN   ;Disable NMI
        sei         ;Disable IRQ
R03     ldy #$FF
PORTB1  sty PORTB   ;Disable ROM
        jmp $4000+[RD4SIO-RES2]

RESLEN  equ *-RESID

* ====================================
* high memory part
RES2    equ *

* Exit jumping to standard SIO
SIOST   sta PORTB
        cli
        stx NMIEN
JSIO    jmp $FFFF

* Exit with Y=status
EXTST   sta PORTB
        cli
        stx NMIEN
        ldy DSTATS
        rts

* Copy from one bank to another
COPYST  lda #$FF
RBNK    equ *-1-COPYST+$30
PORTB2  sta PORTB   ; SRC BANK
RADR    equ *+1-COPYST+$30
        lda $4000,Y
PORTB3  stx PORTB   ; DST BANK
WADR    equ *+1-COPYST+$30
        sta $FF00,Y
        dey
        bpl COPYST
R04     lda #$FF
PORTB4  sta PORTB   ; CODE BANK
        rts
COPYLEN equ *-COPYST

* process SIO call
RD4SIO  pha
        sta WBNK+1+RESO
        lda DDEVIC
        cmp #$31
        bne STDSIO

        lda DUNIT
RR1     cmp #0
        beq RDS2

* exit trough stub to standard SIO
STDSIO  ldy <SIOST+10-RES2
        jmp CSTUB+RESO

* setup read/write address and stub
RDS2    ldx <COPYLEN-1
RDS3    cpx #$11
        bcc RDS3A
        lda $30,X   ;Save ZP locations >= $41
        pha
RDS3A   lda COPYST+RESO,X
        sta $30,X
        dex
        bpl RDS3

* asume a read operation, writes to buffer
        lda DBUFA
        sta WADR
        lda DBUFA+1
        sta WADR+1

* setup length
        lda DCMND
        ldy DBYT
        ldx DBYT+1
        bne R2NAK

        cmp #'S'
        beq SSTAT

* read/write
R2RW    cpy #128
        bne R2NAK

* verify sector number
        ldx DAUX2
        ldy DAUX1
        bne RDS4
        dex
RDS4    dey

RR5     cpy #0 ;MAXSECT
        txa
RR6     sbc #0 ;MAXSECT+1
        bcs R2NAK

        tya
        adc #3 ; Reserve 3 sectors at start of RAMDISK
        bcc RR6B
        inx
RR6B    tay
        ora #$80
        lsr @
        sta RADR+1
        ror RADR

        tya
        asl @
        txa
        rol @
        tay ; Y = (SECTOR+1)/128 = BANK#
        ldx RBTAB+RESO,Y

        ldy #127    ;Copy length
        lda DCMND
        cmp #'R'
        beq SREAD
        cmp #'W'
        beq SWRITE
        cmp #'P'
        beq SWRITE

* SIO error
R2NAK   ldy #139
        bne R2XIT

* Write operation, should swap buffers
SWRITE  lda WBNK+1+RESO
        stx WBNK+1+RESO
        sta RBNK
        lda RADR
        ldx WADR
        sta WADR
        stx RADR
        lda RADR+1
        ldx WADR+1
        sta WADR+1
        stx RADR+1

        lda #$80
        bne R2CPY

* STATUS - read from pre-defined area
SSTAT   lda <[RDSTAT+RESO]
        sta RADR
        lda >[RDSTAT+RESO]
        sta RADR+1

        cpy #4
        bne R2NAK

R05     ldx #$FF
        dey
        beq R2NAK

SREAD   stx RBNK
        lda #$40
R2CPY   cmp DSTATS
        bne R2NAK
WBNK    ldx #$FF
        jsr $30
        ldy #1

R2XIT   sty DSTATS
* Restore ZP
        ldx <$100-[COPYLEN-$11]
RZP     pla
        sta $30+COPYLEN,X
        inx
        bne RZP
        ldy <[EXTST+10-RES2]
* Fall through

* Copy STUB to low memory and jump
CSTUB   ldx #10
CST1    lda $4000,Y
        sta $30,X
        dey
        dex
        bpl CST1
        pla
        ldx #$40
        jmp $0030

RDSTAT  dta B($10,$FF,$FF,$FF)

RBTAB   equ *

RESO    equ $4000-RES2
RES2LEN equ RBTAB+64-RES2

        end
