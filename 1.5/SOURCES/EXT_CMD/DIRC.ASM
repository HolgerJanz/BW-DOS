* BW-DOS Command DIRC path

* System equates
         icl '_SYSEQU.ICL'

         blk dos $500
         icl '_TSTBW15.ICL'
* calc column count
         lda #$00
         sta col_cnt
         sec
         lda RMARGN
         sbc LMARGN
         clc
         adc #$01
         sec
cal_cnt  sbc #13
         bcc chk_par
         inc col_cnt
         bcs cal_cnt
* check for pattern
chk_par  jsr BW_CRNAME
next     lda BW_COMFNAM-1,X
         cmp #$38
         beq d_open
         and #$F9
         cmp #$38
         bne d_open
         ldy #$00
lstd_pat lda BW_STDPAT,Y
         sta BW_COMFNAM,X
         cpx #27
         bcs *+3
         inx
         iny
         cpy #$04
         bcc lstd_pat
* dir open
d_open   lda #$03
         sta $352
         lda <BW_COMFNAM
         sta $354
         lda >BW_COMFNAM
         sta $355
         lda #28
         sta $358
         lda #0
         sta $359
         lda #$06
         sta $35A
         lda #$00
         sta $35B
         ldx #$10
         jsr CIOV
         bmi bmi_err
* screen output
         lda #$0b
         sta $342
         lda <LBUF+1
         sta $344
         lda >LBUF+1
         sta $345
         ldx #0
         stx $348
         stx $349
         lda #$9b
         jsr CIOV
* dir input
         lda #$05
         sta $352
         lda <LBUF
         sta $354
         lda >LBUF
         sta $355
* entry loop
         lda col_cnt
         sta lst_cnt
lloop    lda #39
         sta $358
         lda #0
         sta $359
         ldx #$10
         jsr CIOV
         bmi end_ok
         lda LBUF+13
         cmp #'o'
         beq end_ok
         dec lst_cnt
* check line full
         bne lloop1
         lda col_cnt
         sta lst_cnt
         lda #$9b
         sta LBUF+13
* check protected and dir
lloop1   lda LBUF
         cmp #'*'
         bne lloop2
         ldx LBUF+1
         cpx #':'
         bne *+4
         lda #'#'
         sta LBUF+1
* line output
lloop2   lda #13
         sta $348
         ldx #$00
         jsr CIOV
         bpl lloop
bmi_err  bmi error
end_ok   lda lst_cnt
         cmp col_cnt
         beq loopexit
         ldx #0
         stx $348
         stx $349
         lda #$9b
         jsr CIOV
         bmi error
loopexit lda #$0c
         sta $352
         ldx #$10
         jsr CIOV
         bmi error
         ldx BW_BUFOFF
         lda BW_LBUF,X
         cmp #$9b
         beq end_exit
         jsr BW_CRNAME
         jmp next
end_exit rts

error    tya
         jmp (BW_FAIL)

lst_cnt  dta b(0)
col_cnt  dta b(0)
LBUF     equ *

         end
