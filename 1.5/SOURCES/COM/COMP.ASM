; COMP 1.5 for BW-DOS

            icl '_SYSEQU.ICL'

SRCIX    equ $80
DSTIX    equ $81
ZTEMP    equ $82
EFLAG    equ $83 ; flag exit on error
DSTAUX1  equ $84
ENDFLG   equ $85 ; flag end of file at comp
NOFLAG   equ $86 ; no match flag
QFLAG    equ $87 ; quite flag
DIRENDF  equ $89 ; disk comp all entries of dir finished
RFLAG    equ $8A ; recursive comp
RIDX     equ $8B ; recursive stack index
FINDX    equ $8C ; index in buffer
FUSED    equ $8D ; min of F1BUS and F2BUS
F1BUS    equ $8E ; used buffer of file 1
F2BUS    equ $8F ; used buffer of file 2
FBCNT    equ $90 ; buffer count of file (16bit)
RDITIX   equ $92 ; readit index 0 or 1
RDITIC   equ $93 ; readit IOCB $x0

SRCPTH   equ $500
DSTPTH   equ $580
DIRBUF   equ $600
SRCMSK   equ $680
DSTMSK   equ $690
SRCPAT   equ $6A0
RSTACK   equ $6C0 ; recursive stack, 20*3 bytes -> $6FC

opc_BIT  equ $2c

         blk dos $2800
         icl '_TSTBW15.ICL'

         ldx BW_BUFOFF
         lda BW_LBUF,X
         cmp #$9b
         bne start3
         jsr _print
         dta b($9B)
         dta c'COMP for BW-DOS 1.5'
         dta b($9B)
         dta c'Use: COMP [/REQ] source1 [source2]'
         dta b($9B,$00)
         rts

parmerr  ldy #$9C
         jmp error

start3   jsr close123

         lda #$00
         ldx #$20
         sta $80,X
         dex
         bpl *-3

         jsr BW_CRNAME
         ldx #$03
         lda BW_COMFNAM,X
         cmp #'/'
         bne start4

optLoop  inx
         lda BW_COMFNAM,X

         cmp #'R'
         bne vbsError
         sec
         ror RFLAG
         bne optLoop

vbsError cmp #'Q'
         bne optError
         sec
         ror QFLAG
         bne optLoop

optError cmp #'E'
         bne optEOL
         sec
         ror EFLAG
         bne optLoop

optEOL   cmp #$9B
         bne parmerr

         ldx BW_BUFOFF
         lda BW_LBUF,X
         cmp #$9b
         beq parmerr
         jsr BW_CRNAME

start4   ldx #$00
         jsr getpath
         sta SRCIX

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
         beq dcmp1b
         cmp #'*'
         beq dcmp1b
         cmp #$9B
         bne nxt_fn1c

* check for disk comp
         lda SRCPTH
         cmp #'D'
         beq dcmp1

* onyl one file to comp
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

         jsr comp23
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

* disk comp
dcmp1    jsr srcstar
dcmp1b   jsr dststar

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
         bpl *+5
         jmp error
         jmp comp3t

* disk comp loop
dcmp2d   ldx SRCIX
         jsr dc2dget
         bcs comp3t

         jsr checkit
         bcs comp3t

         jsr renamit

         ldx DSTIX
         jsr dc2dget
         bcs comp3t

* comp file
* print file name and comp file
         lda NOFLAG
         bmi cmp31
         lda #$9b
         jsr _putc

cmp31    lda QFLAG
         bmi *+5
         jsr prnCmpng

* compare
         sec
         ror NOFLAG
         jsr comp23

* get next dir entry
comp3t   jsr getdirp

* check for error
         lda DIRENDF
         bmi comp3x
         jmp dcmp2d

comp3x   lda NOFLAG
         bpl dc2xer
         jmp exitdos

prnCmpng jsr _print
         dta c'Comparing '
         dta b($00)
         bmi jmpError
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
         bmi jmpError
         rts

dc2xer   ldy #$AA ; File not found
jmpError jmp error

; comp file IOCB 2 to 3
comp23   jsr close23

         lda #$00
         jsr openit
         bmi cmp23err

         lda #$01
         jsr openit
         bpl cmp3
         cpy #$AA ; file does not exist
         beq cmp23msg
         cpy #$96 ; dir does not exist
         beq cmp23msg
cmp23err jmp error

cmp23msg lda QFLAG
         bpl *+5
         jsr prnCmpng
         jsr _print
         dta c'  file does not exist',b($9b,0)
         lda EFLAG
         bpl _rts3
         ldy #$FF
         bmi cmp23err
_rts3    rts

; init index and count for files
cmp3     lda #$00 
         sta ENDFLG
         sta FINDX
         lda #$FF
         sta FBCNT
         sta FBCNT+1

; compare loop
cmp4     inc FBCNT ; inc buffer count
         bne *+4
         inc FBCNT+1

         lda #$00 ; read file 1
         sta FUSED
         jsr readit
         bpl cmp41
         lda ENDFLG
         ora #$01
         sta ENDFLG

cmp41    lda #$01 ; read file 2
         jsr readit
         bpl cmp42
         lda ENDFLG
         ora #$02
         sta ENDFLG

; check read lengths
cmp42    ldx F1BUS
         lda ENDFLG
         beq cmp5 ; both not finished
         cmp #$03
         bne cmp43
         cpx F2BUS ; both finished, take smaller used
         bcc cmp5
         ldx F2BUS
         bcs cmp5

cmp43    and #$01
         bne cmp5  ; file 1 finished
         ldx F2BUS ; file 2 finished

; compare
cmp5     stx FUSED
         ldx #$00
cmp51    lda rd_buff1,X
         cmp rd_buff2,X
         bne cmpErr
         inx
         stx FINDX
         cpx FUSED
         bne cmp51

; read next
         lda ENDFLG
         beq cmp4
         cmp #$03
         bne cmpErr ; different file length
         lda F1BUS
         cmp F2BUS
         beq cmpOK

; compare Error
cmpErr   lda FBCNT+1
         jsr _convh2a
         stx offset
         sty offset+1
         lda FBCNT
         jsr _convh2a
         stx offset+2
         sty offset+3
         lda FINDX
         jsr _convh2a
         stx offset+4
         sty offset+5

         lda QFLAG
         bpl *+5
         jsr prnCmpng
         jsr _print
         dta c'  files differ at offset '
offset   dta c'XXXXXX',b($9b,0)

         lda EFLAG
         bpl cmpOK
         ldy #$FF
         jmp error

; compare OK -> leave
cmpOK    jmp close23


; open
openit   tax
         ldy PATADD,X
         lda RDIOCB,X
         tax
         lda #$04
         jmp open

; read 
readit   sta RDITIX
         tay
         ldx RDIOCB,Y
         stx RDITIC
         asl @
         tay

         lda BUFADD,Y
         sta IOCB0+ICBAL,X
         lda BUFADD+1,Y
         sta IOCB0+ICBAH,X

         lda 0 
         sta IOCB0+ICBLL,X
         lda 1 ; 256 bytes
         sta IOCB0+ICBLH,X

         lda #$07 ; get chars
         sta IOCB0+ICCOM,X

         jsr CIOV
         bpl readitx
         cpy #$88 ; End of file
         beq readitx
         jmp error

readitx  ldx RDITIC
         lda IOCB0+ICBLL,X
         ldx RDITIX
         sta F1BUS,X
         tya
         rts

RDIOCB   dta b($20,$30)

PATADD   dta l(SRCPTH,DSTPTH)

BUFADD   dta a(rd_buff1)
         dta a(rd_buff2)

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
         bne dcmp1bx

         lda SRCPTH+1,X
         cmp #'A'
         bne dcmp1bx

         inc DSTAUX1
dcmp1bx  rts

dc1bput  cpy #$08
         bcc dc1bp2
         bit ZTEMP
         bpl dc1bp1
         cpy #$0B 
         bcc dc1bp2
dc1bp1   rts

dc1bp2   sta DSTMSK,Y
         iny
_rts2    rts

* open directory
diropen  ldx #$10
         lda #$04+16
         sta IOCB0+ICAX1,X

         lda #$00
         sta IOCB0+ICAX2,X

         ldy <SRCPTH
         jmp open2

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
dcmp2ex  sec
         ror DIRENDF
close1   ldx #$10
         jmp close

* pop directory
dirpop   ldx RIDX
         beq dcmp2ex
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
         bpl *+5
         jmp error
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
         bpl *+5
         jmp error
         jmp getdirp

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
dcmp2db  lda DSTMSK,X
         cmp #'?'
         beq dcmp2dc
         sta DIRBUF+6,X
dcmp2dc  dex
         bpl dcmp2db
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
         jmp CIOV

dgetex   tya
         rts

* error message and handling
error    tya
         pha
         jsr close123
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

exitdos  jsr close123
         jmp (DOSVEC)

         icl '_PRINT.ICL'
         icl '_CONVH2A.ICL'

* read buffers 
rd_buff1 equ *
rd_buff2 equ *+256

         end
