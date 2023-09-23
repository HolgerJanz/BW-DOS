* Executable of BW-DOS 1.4
RUNAD equ $2E0
INIAD equ $2E2

ZSEGCUR equ $F0
ZSEGEND equ ZSEGCUR+2
ZCURSOR equ $F4

     blk dos $2000

strt lda <_rts
     sta RUNAD
     sta INIAD
     lda >_rts
     sta RUNAD+1
     sta INIAD+1
     lda <cbgn
     sta ZCURSOR
     lda >cbgn
     sta ZCURSOR+1
     ldx #$00
     ldy #$00   ;32

loop lda (ZCURSOR),Y
     cpx #$04
     bcs stor   ;6

     sta ZSEGCUR,X
     inx
     cpx #$02
     bne endl
     lda ZSEGCUR
     and ZSEGCUR+1
     cmp #$ff
     bne endl
     ldx #$00
     beq endl  ;19

stor sta (ZSEGCUR),Y

     lda ZSEGCUR+1
     cmp ZSEGEND+1
     bcc incz
     lda ZSEGCUR
     cmp ZSEGEND
     bcc incz ;14

     jsr jini
     ldx #$00
     ldy #$00
     lda <_rts
     sta INIAD
     lda >_rts
     sta INIAD+1  ;19

incz inc ZSEGCUR
     bne *+4
     Inc ZSEGCUR+1   ;6

endl inc ZCURSOR
     bne *+4
     inc ZCURSOR+1
     lda ZCURSOR+1
     cmp >cend
     bcc loop
     lda ZCURSOR
     cmp <cend
     bcc loop
     jmp (RUNAD)  ;21

jini jmp (INIAD)  ;3

_rts rts ;1

cbgn equ *
     ins 'XBW14.DOS'
cend equ *

     blk dos RUNAD
     dta a(strt)

     end
