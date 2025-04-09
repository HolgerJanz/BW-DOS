* BW-DOS Command DIR path

         icl '_SYSEQU.ICL'

         blk dos $580
         icl '_TSTBW15.ICL'
         jsr BW_CRNAME
* check for pattern
nxt_dir  lda BW_COMFNAM-1,X
         cmp #$38
         beq d_open
         and #$F9
         cmp #$38
         bne d_open
         cpx #24
         bcs d_open
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
         lda #$80
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
         lda #39
         sta $348
         lda #0
         sta $349
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
* close
         lda #$0C
         sta $352
         ldx #$10
         jsr CIOV
         bmi error
         ldx BW_BUFOFF
         lda BW_LBUF,X
         cmp #$9b
         beq end_exit
         jsr BW_CRNAME
         jmp nxt_dir
end_exit rts

error    tya
         jmp (BW_FAIL)

LBUF     equ *

         end
