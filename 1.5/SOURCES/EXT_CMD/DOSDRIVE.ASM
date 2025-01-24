* BW-DOS Command DOSDRIVE number

* System equates
         icl '_SYSEQU.ICL'

         blk dos $580
         icl '_TSTBW15.ICL'
         jsr BW_CRNAME
* no parameter, just print dos drive
         beq prtdrv
* max one parameter
         lda #$9b
         ldx BW_BUFOFF
         cmp BW_LBUF,X
         bne par_err
* check parameter OFF
         ldx BW_COMFNAM+3
         cpx #'O'
         bne chkdnr
         ldx #'F'
         cpx BW_COMFNAM+4
         bne par_err
         cpx BW_COMFNAM+5
         bne par_err
         cmp BW_COMFNAM+6
         bne par_err
         lda #$00 ; dos drive off
         beq setdrv0
* check parameter 0(=OFF),1-4,8
chkdnr   cmp BW_COMFNAM+4
         bne par_err
         lda BW_COMFNAM+3
         cmp #'0'
         bcc par_err
         cmp #'4'+1
         bcc setdrv
         cmp #'8'
         bne par_err
* set dos drive
setdrv   and #$0F
setdrv0  sta BW_DOSDRV
prtdrv   lda BW_DOSDRV
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

txtdrv   dta b($9b),c'DOS drive is '
txtoff   dta c'D'
txtdrvn  dta c'x:',b($9b)
txtdrve  equ *

         end
