* BW-DOS Command DIRS path

* System equates
         icl '_SYSEQU.ICL'

         blk dos $580
         icl '_TSTBW15.ICL'
         jsr BW_CRNAME
* check for pattern
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
         bmi error
* screen output
         lda #$0b
         sta $342
         lda <LBUF
         sta $344
         lda >LBUF
         sta $345
         ldx #0
         stx $348
         stx $349
         lda #$9b
         jsr CIOV
* dir input
         lda #$07
         sta $352
         lda <LBUF
         sta $354
         lda >LBUF
         sta $355
* entry loop
lloop    lda #$20
         sta $358
         lda #0
         sta $359
         ldx #$10
         jsr CIOV
         php
         lda $358
         sta $348
         ora $359
         beq readzero
         lda $359
         sta $349
         ldx #$00
         jsr CIOV
         bmi error
readzero plp
         bpl lloop
* close IOCB 1
         lda #$0c
         sta $352
         ldx #$10
         jsr CIOV
         bmi error
* next parameter
         ldx BW_BUFOFF
         lda BW_LBUF,X
         cmp #$9b
         beq end_exit
         jsr BW_CRNAME
         jmp next
end_exit rts

error    tya
         jmp (BW_FAIL)

LBUF     equ *

         end
