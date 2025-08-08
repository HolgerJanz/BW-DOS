; BW-DOS Command DOSCONFIG [/Q] dos [dosdrv] [dosdir] [startup] [curdrv]

         icl '_SYSEQU.ICL'

         blk dos $2800
         icl '_TSTBW15.ICL'
; check for parameters
         jsr parend
         bne *+5
         jmp prtuse
; read dos file
         jsr BW_CRNAME
         jsr chkquite
         bcc readfile
         jsr parend
         bne *+5
         jmp par_err
         jsr BW_CRNAME
readfile lda #4
         jsr open
         jsr read
         jsr close
; check dos file is bw-dos 1.5
         jsr chkdos
; check for config parameters
         jsr parend
         beq prntxt2
; open dos file for update
         lda #12
         jsr open
; get dos drive
         jsr BW_CRNAME
         lda #'0'
         jsr chkdrv
         jsr setdrv
; get dos directory
         jsr parend
         beq wrtcnf
         jsr BW_CRNAME
         jsr getchkdd
; get startup batch
         jsr parend
         beq wrtcnf
         jsr BW_CRNAME
         jsr setbat
; get current drive
         jsr parend
         beq wrtcnf
         jsr BW_CRNAME
         lda #'1'
         jsr chkdrv
         jsr setcur
; check end of parameters
         jsr parend
         beq wrtcnf
         jmp par_err
; print config, ask for upadte
wrtcnf   jsr askupd
         bcs _rts
         jsr write
         jsr close
         jsr _print
         dta c'Done',b($9b)
         dta b(0)
_rts     rts

prntxt2  lda quite
         bpl *+5
         jmp par_err
prntxt   ldx #10
         lda dosdir,X
         sta txtdir,X
         dex
         bpl *-7

         lda dosdrv
         beq ddoff
         ora #'0'
         sta txtdrv
         bne getbat
ddoff    lda #'o'
         sta txtoff
         lda #'f'
         sta txtoff+1
         sta txtoff+2

getbat   ldx #0
gcurlp   lda dosbat,X
         cmp #$9b
         beq getcur
         sta txtbat,X
         inx
         bne gcurlp

getcur   lda doscur+1
         sta txtcur

txtprt   jsr _print
         dta b($9b)
         dta c'DOS drive '
txtoff   dta c'D'
txtdrv   dta c'x:',b($9b)
         dta c'DOS directory '
txtdir   dta c'12345678123',b($9b)
         dta c'Startup '
txtbat   dta c'                            ',b($9b)
         dta c'Current drive D'
txtcur   dta c'x:',b($9b)
         dta b(0)
         rts

askupd   lda quite
         bmi askupok
         jsr prntxt
         jsr _print
         dta c'Update configuration for DOS file? (Y)'
         dta b(0)
         jsr getKey
         and #$DF ; upper or lower
         pha
         jsr _putc
         pla
         cmp #'Y'
         beq askupok
         jsr _print
         dta b($9b),c'Abort',b($9b)
         dta b($0)
         sec
         rts
askupok  jsr _print
         dta b($9b),c'Update DOS file ... '
         dta b($0)
         clc
         rts

getkey   jsr close2
         ldx #$20
         lda #3
         sta $362
         lda #4
         sta $36a
         lda #0
         sta $36b
         lda <knam
         sta $364
         lda >knam
         sta $365
         jsr CIOV

         ldx #$20
         lda #7
         sta $362
         lda #0
         sta $368
         sta $369
         jsr CIOV

         pha
         jsr close2
         pla
         rts
            
close2   ldx #$20
         lda #12
         sta $362
         jmp CIOV

knam     dta c'K:'
         dta b($9b)


chkdos   ldx #5
spartl   lda dosstart,X
         cmp dosspart,X
         bne ferror
         dex
         bpl spartl

         lda #$ff
         cmp dosdir-2
         bne ferror
         cmp dosdir-1
         bne ferror

         ldx #9
nullyl   lda dosnul,X
         cmp dosnully,X
         bne ferror
         dex
         bpl nullyl
         rts
ferror   lda #$98
         jmp (BW_FAIL)


parend   lda #$9b
         ldx BW_BUFOFF
         cmp BW_LBUF,X
         rts

chkdrv   sta _chkdrv+1
         lda #$9b
         cmp BW_COMFNAM+4
         bne par_err
         lda BW_COMFNAM+3
_chkdrv  cmp #'0'
         bcc par_err
         cmp #'4'+1
         bcc _chkdrve
         cmp #'8'
         bne par_err
_chkdrve rts

quite    dta b(0)
chkquite lsr quite
         lda BW_COMFNAM+3
         cmp #'/'
         clc
         bne chkquend
         lda BW_COMFNAM+4
         cmp #'Q'
         bne par_err
         lda BW_COMFNAM+5
         cmp #$9b
         bne par_err
         sec
         ror quite
         sec
chkquend rts

; parameter error
par_err  lda #$9C
         jmp (BW_FAIL)

getchkdd ldx #0
         ldy #0
dirl     lda BW_COMFNAM+3,X
         cmp #$9b
         bne chkdot
         lda #' '
         bne yonly
chkdot   cmp #'.'
         bne yandx
         lda #' '
         cpy #9
         bcs par_err
         cpy #8
         bcc yonly
         inx
         bne dirl

yandx    inx
yonly    sta dosdir,Y
         iny
         cpy #11
         bne dirl

         lda BW_COMFNAM+3,X
         cmp #$9b
         bne par_err
         rts

; set dos drive
setdrv   lda BW_COMFNAM+3
         and #$0F
         sta dosdrv
         rts

; set current drive
setcur   lda BW_COMFNAM+3
         sta doscur+1
         rts

; set startup batch
setbat   ldx #0
setbatlp lda BW_COMFNAM,X
         sta dosbat,X
         inx
         cmp #$9b
         bne setbatlp
         rts

; read/update dos file
open     sta $35A
         lda #0
         sta $35B
         lda <BW_COMFNAM
         sta $354
         lda >BW_COMFNAM
         sta $355
         lda #3
         bne _ciov
read     lda #7
         bne _buff
write    lda #11
_buff    ldx <buffer
         stx $354
         ldx >buffer
         stx $355
         ldx #0
         stx $358
         ldx #2
         stx $359
         bne _ciov
close    lda #12
_ciov    sta $352
         ldx #$10
         jsr CIOV
         bpl *+6
         tya
         jmp (BW_FAIL)
         rts

prtuse   jsr _print
         dta b($9B)
         dta c'DOSCONF for BW-DOS 1.5'
         dta b($9B)
         dta c'Use: DOSCONF [/Q] df [d] [r] [s] [c]'
         dta b($9B,$00)
         rts

         icl '_PRINT.ICL'

dosspart dta c'S',b($32,$00),c'BW',b($15)
dosnully dta b(0,0,0,2,0,$1c,23,0,1,0),c'-'

buffer   equ *
dosstart equ buffer+$93
dosdrv   equ dosstart+BW_DOSDRV-$700
dosdir   equ dosstart+BW_DOSDIR-$700
dosbat   equ dosstart+BW_COMFNAM-$700
doscur   equ dosstart+BW_CURDRV-$700
dosnul   equ dosstart+$150

         end
