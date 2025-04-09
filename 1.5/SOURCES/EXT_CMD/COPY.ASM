* COPY 1.3 for BW-DOS

            icl '_SYSEQU.ICL'

* offset of file name in path
SRCIX    equ $80
DSTIX    equ $81
* temporar variables
ZTEMP    equ $82
QFLAG    equ $83
DSTAUX1  equ $84
ENDFLG   equ $85 ; flag end of file at copy
NOFLAG   equ $86 ; no match flag
OPNIF    equ $87
OPNOF    equ $88
DIRENDF  equ $89 ; disk copy all entries of dir finished
RFLAG    equ $8A ; recursive copy
RIDX     equ $8B ; recursive stack index

SRCPTH   equ $500
DSTPTH   equ $580
DIRBUF   equ $600
SRCMSK   equ $680
DSTMSK   equ $690
SRCPAT   equ $6A0
RSTACK   equ $6C0 ; recursive stack, 20*3 bytes -> $6FC

opc_BIT  equ $2c

starta   equ $3000
         blk dos starta
         icl '_TSTBW15.ICL'

* check for parameters
         ldx BW_BUFOFF
         lda BW_LBUF,X
         cmp #$9b
         bne start3
         jsr _print
         dta b($9B)
         dta c'COPY for BW-DOS 1.5'
         dta b($9B)
         dta c'Use: COPY [/RQ] src [dst[/A]]'
         dta b($9B,$00)
         rts

parmerr  ldy #$9C
         jmp error

* init
start3   jsr close123
* clear zpage variables
         lda #$00
         ldx #$0B
         sta $80,X
         dex
         bpl *-3

* check options
         jsr BW_CRNAME
         lda BW_COMFNAM+3
         cmp #'/'
         bne start4

         ldx #$03
nxtOpt   inx
         lda BW_COMFNAM,X

         cmp #'R'
         bne optQuite
         ror RFLAG
         bmi nxtOpt

optQuite cmp #'Q'
         bne optEOL
         ror QFLAG
         bmi nxtOpt

optEOL   cmp #$9B
         bne parmerr


nxtParm  ldx BW_BUFOFF
         lda BW_LBUF,X
         cmp #$9b
         beq parmerr
         jsr BW_CRNAME

* set SRCPTH and SRCIX
start4   ldx #$00
         jsr getpath
         sta SRCIX
* set DSTPTH and DSTIX
         jsr BW_CRNAME
         ldx <DSTPTH-SRCPTH
         jsr getpath
         sta DSTIX

* check /R only if src and dst are D
         lda RFLAG
         bpl start41
         lda #'D'
         cmp SRCPTH
         bne parmerr
         cmp DSTPTH
         bne parmerr

* search source for wildcards
start41  ldx SRCIX
nxt_fn1c lda SRCPTH,X
         inx
         cmp #'?'
         beq dcop1b
         cmp #'*'
         beq dcop1b
         cmp #$9B
         bne nxt_fn1c

* check for disk copy
         lda SRCPTH
         cmp #'D'
         beq dcop1

* onyl one file to copy
         jsr srcstar
         jsr dststar
         ldx SRCIX
         jsr getmsk

         ldx #$0A
nxt_dmsk lda DSTMSK,X
         sta DIRBUF+6,X
         dex
         bpl nxt_dmsk

         ldx DSTIX
         jsr getmsk

         jsr renamit

         ldx DSTIX
         jsr dc2dget
         bcs starter

         lda #$00
         sta BW_TDOVER
         jsr copy23
         jmp exitdos

starter  ldy #$A5 ; bad file name
         jmp error

* set path end to *.*, if no file name
srcstar  ldx SRCIX
         dta b(opc_BIT)
dststar  ldx DSTIX
         lda SRCPTH,X
         cmp #$9B
         bne nosstar
         ldy #$03
nxt_sstr lda BW_STDPAT-1,Y
         sta SRCPTH,X
         inx
         dey
         bpl nxt_sstr
nosstar  rts

* disk copy
dcop1    jsr srcstar
dcop1b   jsr dststar

* store source pattern
         ldx SRCIX
         ldy #$00
ssrcpat  lda SRCPTH,X
         sta SRCPAT,Y
         cmp #$9B
         beq setmask
         inx
         iny
         bne ssrcpat

* masks and aux
setmask  ldx SRCIX
         jsr getmsk

         ldx #$0F
cpymask  lda DSTMSK,X
         sta SRCMSK,X
         dex
         bpl cpymask

         ldx DSTIX
         jsr getmsk

* dir open
         lsr NOFLAG
         lsr DIRENDF
         jsr diropen
         jmp copy3t

* disk copy loop
dcop2d   ldx SRCIX
         jsr dc2dget
         bcs copy3t

         jsr checkit
         bcs copy3t

         jsr renamit

         ldx DSTIX
         jsr dc2dget
         bcs copy3t

* set date and time
         jsr settd

* copy file
         lda SRCPTH
         cmp #'D' 
         bne cop3
         ldx #$FF
* check selfcopy
cop2     inx
         lda SRCPTH,X
         cmp DSTPTH,X
         bne cop3
         cmp #$9B
         bne cop2
         ldy #$97 ; File already exists
         jmp error

* print file name and copy file
cop3     lda NOFLAG
         bmi cop31
         lda #$9b
         jsr _putc

cop31    jsr prnFname

* copy
         sec
         ror NOFLAG
         jsr copy23

* add prot if src is prot
         lda DSTPTH
         cmp #'D'
         bne copy3t
         lda #1
         bit DIRBUF
         beq copy3t
         ldx #$30
         jsr dstprot

* get next dir entry
copy3t   jsr getdirp

* check for error
         lda DIRENDF
         bmi copy3x
         jmp dcop2d

copy3x   lda NOFLAG
         bpl dc2xer
         jmp exitdos

dc2xer   ldy #$AA ; File not found
         jmp error

prnFname lda QFLAG
         bmi prnFnEnd
         jsr _print
         dta c'Copying '
         dta b($00)
         bpl *+5
jmpErr   jmp error

         ldx #$00
         lda <SRCPTH
         sta IOCB0+ICBAL,X
         lda >SRCPTH
         sta IOCB0+ICBAH,X
         lda #$40
         sta IOCB0+ICBLL,X
         lda #$00
         sta IOCB0+ICBLH,X
         lda #$09 ; put record
         sta IOCB0+ICCOM,X
         jsr CIOV
         bmi jmpErr
prnFnEnd rts

* set date/time
settd    ldx #$05
settd2   lda DIRBUF+17,X
         sta BW_ODATER,X
         dex
         bpl settd2
* set date/time over
         lda #$FF
         sta BW_TDOVER
         rts

* copy file IOCB 1 to 2
copy23   jsr close23

         lsr OPNIF
         lsr OPNOF

cop4     ldx #$03

cop4b    lda #$00
         sta COPLEN,X
         lda MEMTOP,X
         sta COPEND2,X
         dex
         bpl cop4b

         lda #$00 
         sta ENDFLG
         jsr readit
         bmi cop4c

         lda #$02
         jsr readit
         bpl cop4d

cop4c    dec ENDFLG
         jsr close2

cop4d    lda #$00
         jsr writeit

         lda #$02
         jsr writeit

         lda ENDFLG
         beq cop4

         jmp close23

COPEND   dta a(starta)
COPEND2  dta a($8000)

COPADD   dta a($5000)
         dta a(enda)

COPLEN   dta a($0000)
         dta a($0000)

* read 
readit   pha
         lda OPNIF
         bmi readit2

         sec
         ror OPNIF

         ldx #$20
         lda #$04
         ldy <SRCPTH
         jsr open

readit2  pla
         tay

         ldx #$20

         lda COPADD,Y
         sta IOCB0+ICBAL,X
         lda COPADD+1,Y
         sta IOCB0+ICBAH,X

         lda COPEND,Y
         sec
         sbc COPADD,Y
         sta IOCB0+ICBLL,X
         lda COPEND+1,Y
         sbc COPADD+1,Y
         sta IOCB0+ICBLH,X

         lda #$07 ; get chars
         sta IOCB0+ICCOM,X

         tya
         pha

         jsr CIOV
         sty ZTEMP

         pla
         tay

         lda IOCB0+ICBLL,X
         sta COPLEN,Y
         lda IOCB0+ICBLH,X
         sta COPLEN+1,Y

         ldy ZTEMP
         bpl readitx
         cpy #$88 ; End of file
         bne errorj

readitx  tya
         rts

* write 
writeit  pha
         lda OPNOF
         bmi writeit2

         sec
         ror OPNOF

         ldx #$30
         lda DSTAUX1
         ldy <DSTPTH
         jsr open

writeit2 pla
         tay

         ldx #$30

         lda COPADD,Y
         sta IOCB0+ICBAL,X
         lda COPADD+1,Y

         sta IOCB0+ICBAH,X
         lda COPLEN,Y
         sta IOCB0+ICBLL,X
         lda COPLEN+1,Y
         sta IOCB0+ICBLH,X

         ora COPLEN,Y
         beq readitx

         lda #$0B ; put chars
         sta IOCB0+ICCOM,X

         jsr CIOV
         bpl readitx

errorj   jmp error

* get file mask
getmsk   ldy #$00
         lda #$06
         sta ZTEMP
         bne dc1b1b

dc1bhve  lda #'?'
         jsr dc1bput
         bcc dc1bhve
dc1bzn   jsr dc1bput

dc1b1    inx
dc1b1b   lda SRCPTH,X
         cmp #'*'
         beq dc1bhve
         cmp #'.'
         beq dc1btec
         jsr charok
         bcc dc1bzn
         ror ZTEMP

dc1btec  lda #$20
         jsr dc1bput
         bcc dc1btec
         ror ZTEMP
         bcc dc1b1

         lda #$08
         sta DSTAUX1
         lda SRCPTH,X
         cmp #'/'
         bne dcop1bx

         lda SRCPTH+1,X
         cmp #'A'
         bne dcop1bx

         inc DSTAUX1
dcop1bx  rts

dc1bput  cpy #$08
         bcc dc1bp2
         bit ZTEMP
         bpl dc1bp1
         cpy #$0B 
         bcc dc1bp2
dc1bp1   rts

dc1bp2   sta DSTMSK,Y
         iny
         rts

* open directory
diropen  ldx #$10
         lda #$04+16
         sta IOCB0+ICAX1,X

         lda #$00
         sta IOCB0+ICAX2,X

         ldy <SRCPTH
         jsr open2
_rts2    rts

* prepare dir entry
getdirp  jsr dirget
         bmi dirpop
* common file
         lda #%00100000 ; directory
         bit DIRBUF
         beq _rts2
* check recursive
         ldy RFLAG
         bpl getdirp
         jmp dirpsh

* exit recursive dir loop
dcop2ex  sec
         ror DIRENDF
close1   ldx #$10
         jmp close

* pop directory
dirpop   ldx RIDX
         beq dcop2ex
* close current dir
         jsr close1
* remove one dir
         ldx SRCIX
         ldy DSTIX
dirpop1  dex
         dey
         lda SRCPTH-1,X
         cmp #'>'
         beq dirpop4
         cmp #':'
         bne dirpop1
dirpop4  stx SRCIX
         sty DSTIX
* add pattern
         ldy #$00
dirpop2  lda SRCPAT,Y
         sta SRCPTH,X
         inx
         iny
         cmp #$9B
         bne dirpop2
* reopen dir
         jsr diropen
* get position from stack
         ldx #$00
         ldy RIDX
dirpop3  dey
         lda RSTACK,Y
         sta IOCB0+ICAX3+$10,X
         inx
         cpx #$03
         bcc dirpop3
         sty RIDX
* seek
         ldx #$10
         jsr srcseek
* get next entry
         jmp getdirp

* push directory
dirpsh   ldx RIDX
* check stack
         cpx #60
         bcc dirpsh1
dirpshe  ldy #$B6 ; Path too long
         jmp error
* tell current dir position
dirpsh1  ldx #$10
         jsr srctell
* store position on stack
         ldx #$02
         ldy RIDX
dirpsh2  lda IOCB0+ICAX3+$10,X
         sta RSTACK,Y
         iny
         dex
         bpl dirpsh2
         sty RIDX
* close current dir
         jsr close1
* source get new dir name and add pattern
         ldx SRCIX
         jsr dc2dget
         cpx #127-14
         bcs dirpshe
         stx SRCIX
* add pattern
         ldx SRCIX
         lda #'>'
         sta SRCPTH,X
         inx
         stx SRCIX
         ldy #$00
dirpsh3  lda SRCPAT,Y
         sta SRCPTH,X
         cmp #$9B
         beq dirpsh4
         inx
         iny
         bpl dirpsh3
* destination add new dir
dirpsh4  ldx DSTIX
         jsr dc2dget
         cpx #255-14
         bcs dirpshe
         stx DSTIX
* make dir, if not exists
         jsr settd
         ldx #$10
         jsr dstmd
* add prot if src is prot
         lda #1
         bit DIRBUF
         beq dirpsh5
         ldx #$10
         jsr dstprot
* add path end 
dirpsh5  ldx DSTIX
         lda #'>'
         sta SRCPTH,X
         inx
         lda #$9b
         sta SRCPTH,X
         stx DSTIX
* open new dir and go on
         jsr diropen
         jmp getdirp

* prot dir
dstprot  lda #$23
         sta IOCB0+ICCOM,X
         bne dstmd2

* make dir
dstmd    lda #$2A
         sta IOCB0+ICCOM,X
dstmd2   lda <DSTPTH
         sta IOCB0+ICBAL,X
         lda >DSTPTH
         sta IOCB0+ICBAH,X
         jsr CIOV
         bpl _rts
         cpy #$97 ; File already exists
         beq _rts
         jmp error
* tell
srctell  lda #$26
         bne srcseek1
* seek
srcseek  lda #$25
srcseek1 sta IOCB0+ICCOM,X
         jsr CIOV
         bpl _rts
         jmp error

* check file
checkit  ldx #10
checkit1 lda SRCMSK,X
         cmp #'?'
         beq checkit2
         cmp DIRBUF+6,X
         bne checkit3
checkit2 dex
         bpl checkit1
         clc
         rts
checkit3 sec
         rts

* rename file
renamit  ldx #10
dcop2db  lda DSTMSK,X
         cmp #'?'
         beq dcop2dc
         sta DIRBUF+6,X
dcop2dc  dex
         bpl dcop2db
         rts

* get parameter set path
* >A start offset $00 or $40
* A> contains offset of file name
getpath  ldy #0
getpath0 stx ZTEMP
getpath1 lda BW_COMFNAM,Y
         sta SRCPTH,X
         inx
         iny
         cmp #':'
         beq getpath0
         cmp #'>'
         beq getpath0
         cmp #'<'
         beq getpath0
         cmp #$9B
         bne getpath1
         lda ZTEMP
_rts     rts

* close IOCBs
close123 jsr close1
close23  ldx #$30
         jsr close
close2   ldx #$20
close    lda #$0C
         sta IOCB0+ICCOM,X
         jsr CIOV
         bpl _rts
         jmp error

* open IOCB number X, mode A, ladd Y
open     sta IOCB0+ICAX1,X
         lda #$00
         sta IOCB0+ICAX2,X
open2    tya
         sta IOCB0+ICBAL,X
         lda >SRCPTH
         sta IOCB0+ICBAH,X
         lda #$03
         sta IOCB0+ICCOM,X
         jsr CIOV
         bmi error
dgetex   tya
         rts

* error message and handling
error    tya
         pha
         jsr resetcls
         pla
         jmp (BW_FAIL)

* get next directory entry
dirget   ldx #$10
         lda #$07
         sta IOCB0+ICCOM,X
         lda <DIRBUF
         sta IOCB0+ICBAL,X
         lda >DIRBUF
         sta IOCB0+ICBAH,X
         lda #23
         sta IOCB0+ICBLL,X
         lda #$00
         sta IOCB0+ICBLH,X
         jsr CIOV
         bmi dgetex

         ldy #$88
         lda DIRBUF
         beq dgetex

         lda #%00001000 ; unused
         bit DIRBUF
         beq dirget
         
         ldy #$01
         bpl dgetex

dc2dget  ldy #$00
dc2dg2   lda DIRBUF+6,Y
         iny
         cmp #' '
         beq dc2dg3
         jsr charok
         bcs dc2dg5
         sta SRCPTH,X
         inx
         cpy #8
         beq dc2dg6
         cpy #11
         bcc dc2dg2
         bne dc2dg3
         
dc2dg3   cpy #9
         bcs dc2dg4
dc2dg6   lda #'.'
         sta SRCPTH,X
         inx
         ldy #8
         jmp dc2dg2

dc2dg4   lda SRCPTH-1,X
         cmp #'.'
         bne *+3
         dex
         lda #$9B
         sta SRCPTH,X
clc_rts  clc
dc2dg5   rts

* check for valid character
charok   cmp #'?'
         beq clc_rts
         cmp #'_'
         beq clc_rts
         cmp #'0'
         bcc sec_rts
         cmp #':'
         bcc clc_rts
         cmp #'A'
         bcc sec_rts
         cmp #'['
         bcc clc_rts
sec_rts  sec
         rts

resetcls jsr close123
* reset date time override flag
         lda #$00
         sta BW_TDOVER
         rts

exitdos  jsr resetcls
         jmp (DOSVEC)

         icl '_PRINT.ICL'
* buffer 2 
enda     equ *

         end
