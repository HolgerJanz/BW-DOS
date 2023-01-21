* iterator for LBUF parsing
* register X contains current offset

* init iterartor
_lbinit  clc
         lda DOSVEC
         adc #SD_BUFOFF
         sta _bufoff+1
         lda DOSVEC+1
         adc #$00
         sta _bufoff+2
* get LBUF
         clc
         lda DOSVEC
         adc #SD_LBUF
         sta _lbget+1
         lda DOSVEC+1
         adc #$00
         sta _lbget+2
_bufoff  ldx $ffff
         rts

* get next char from command line
_lbget   lda $ffff,X
         inx
         rts

* trim spaces and get
_lbtrim  jsr _lbget
         cmp #' '
         beq *-5
         rts

