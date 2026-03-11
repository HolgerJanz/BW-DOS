* BW-DOS Command DOSDRIVE number dosdir

* System equates
         icl '_SYSEQU.ICL'

         blk dos $580
         icl '_TSTBW15.ICL'
* no parameter, just print dos drive
         lda #$9b
         ldx BW_BUFOFF
         cmp BW_LBUF,X
         bne *+5
         jmp prtdrv
         jsr BW_CRNAME
* check parameter OFF
         ldx BW_COMFNAM+3
         cpx #'O'
         bne chkdnr
         ldx #'F'
         cpx BW_COMFNAM+4
         bne par_err1
         cpx BW_COMFNAM+5
         bne par_err1
         cmp BW_COMFNAM+6
         bne par_err1
         lda #$00 ; dos drive off
         beq setdrv0
* check parameter 0(=OFF),1-4,8
chkdnr   cmp BW_COMFNAM+4
         bne par_err1
         lda BW_COMFNAM+3
         cmp #'0'
         bcc par_err1
         cmp #'4'+1
         bcc setdrv
         cmp #'8'
         bne par_err1
* set dos drive
setdrv   and #$0F
setdrv0  sta dosdrive

         jsr BW_CRNAME
         beq onlydrv
* max two parameter
         lda #$9b
         ldx BW_BUFOFF
         cmp BW_LBUF,X
         bne par_err1

         ldx #0
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
par_err1 bne par_err

; write new drive and directory
         ldx #10
         lda dosdir,X
         sta BW_DOSDIR,X
         dex
         bpl *-7
onlydrv  lda dosdrive
         sta BW_DOSDRV

prtdrv   ldx #10
         lda BW_DOSDIR,X
         sta txtdir,X
         dex
         bpl *-7
         lda BW_DOSDRV
         beq ddoff
         ora #'0'
         sta txtdrvn
         bne prndd
* print off
ddoff    lda #'o'
         sta txtoff
         lda #'f'
         sta txtoff+1
         sta txtoff+2
* print dos drive
prndd    lda <txtdrv
         sta $344
         lda >txtdrv
         sta $345
         lda <txtdrve-txtdrv
         sta $348
         lda #$00
         sta $349
         lda #$0B
         sta $342
         ldx #$00
         jmp CIOV
* parameter error
par_err  lda #$9C
         jmp (BW_FAIL)

dosdrive dta b(0)
dosdir   dta c'           '

txtdrv   dta b($9b)
         dta c'DOS drive '
txtoff   dta c'D'
txtdrvn  dta c'x:',b($9b)
         dta c'DOS directory '
txtdir   dta c'12345678123',b($9b)
txtdrve  equ *

         end
