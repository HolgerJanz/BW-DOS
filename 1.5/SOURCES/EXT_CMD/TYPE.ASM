* BW-DOS Command TYPE file

* System equates
         icl '_SYSEQU.ICL'

         blk dos $580
         icl '_TSTBW14.ICL'
         jsr BW_CRNAME
         bne *+5
         jmp par_err
* open
next     lda #$03
         sta $352
         lda <BW_COMFNAM
         sta $354
         lda >BW_COMFNAM
         sta $355
         lda #28
         sta $358
         lda #0
         sta $359
         lda #$04
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
* input
         lda #$07
         sta $352
         lda <LBUF
         sta $354
         lda >LBUF
         sta $355
* line loop
lloop    lda #$40
         sta $358
         lda #0
         sta $359
         ldx #$10
         jsr CIOV
         php
         lda $358
         ora $359
         beq chkioer ; 0 char read
         lda $358
         sta $348
         lda $359
         sta $349
         ldx #$00
         jsr CIOV
         bmi error
chkioer  plp
         bpl lloop
* close
         lda #$0C
         sta $352
         ldx #$10
         jsr CIOV
* next
         jsr BW_CRNAME
         beq *+5
         jmp next
         rts

par_err  ldy #$9C ; parameter error
error    tya
         jmp (BW_FAIL)

LBUF     equ *

         end
