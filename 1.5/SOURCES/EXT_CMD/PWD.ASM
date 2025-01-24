* BW-DOS Command PWD dx:

* System equates
         icl '_SYSEQU.ICL'

PIDX     equ $80
CIDX     equ $81
LSTD     equ $82
NOSPC    equ $83
FRSTDIR  equ $84

         blk dos $3000
         icl '_TSTBW15.ICL'

         lda #$0b
         sta $342
         ldx #0
         stx $348
         stx $349
         lda #$9b
         jsr CIOV

next     jsr BW_CRNAME

         lda #$9b
         sta PBUF+PBUFL
         sta BW_COMFNAM+3
         lda #$03
         sta CIDX
         sta FRSTDIR
         lda <PBUFL-1
         sta PIDX

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
         bmi scrnout
         lda #$00
         sta FRSTDIR

* dir input
         lda #$07 ;$05
         sta $352
         lda <LBUF
         sta $354
         lda >LBUF
         sta $355
         lda <LBUFL
         sta $358
         lda #0
         sta $359
         ldx #$10
         jsr CIOV
         bmi error

         ldy PIDX
         lda #'>'
         sta PBUF,Y
         dey

         lda #$00
         sta NOSPC
         ldx $358
         dex
         dex
lchar    lda LBUF,X
         cmp #' '
         beq nxtlchar
         inc NOSPC
         sta PBUF,Y
         dey
nxtlchar dex
         cpx <LBUFL-4-1
         bne nxt2char
         pha
         lda NOSPC
         beq nonospc
         lda #'.'
         sta PBUF,Y
         dey
nonospc  pla
nxt2char cpx <LBUFL-13-1
         bcs lchar
         sty PIDX

* close dir
         jsr close1

         ldx CIDX
         lda #'<'
         sta BW_COMFNAM,X
         inx
         stx CIDX
         lda #$9b
         sta BW_COMFNAM,X

         jmp d_open

par_err  ldy #$9C
error    tya
         jmp (BW_FAIL)

* screen output
scrnout  jsr close1
         lda FRSTDIR
         bne error

         inc PIDX
         ldx PIDX
         lda #' '
         sta PBUF,X
         inx
         ldy #$00
nxtdchar lda BW_COMFNAM,Y
         sta PBUF,X
         inx
         iny
         cpy #$03
         bne nxtdchar

         inc PIDX
         lda #$09
         sta $342
         clc
         lda <PBUF
         adc PIDX
         sta $344
         lda >PBUF
         adc #$00
         sta $345
         lda #$ff
         sta $348
         lda #$00
         sta $349
         ldx #$00
         jsr CIOV
         bmi error

         ldx BW_BUFOFF
         lda #$9b
         cmp BW_LBUF,X
         beq *+5
         jmp next

         rts

close1   lda #$0C
         sta $352
         ldx #$10
         jmp CIOV

LBUFL    equ 41
PBUFL    equ $80

LBUF     equ *
PBUF     equ LBUF+LBUFL

         end
