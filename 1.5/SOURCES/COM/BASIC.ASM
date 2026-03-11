* BW-DOS Command BASIC ON|OFF

         icl '_SYSEQU.ICL'

         blk dos $580
         icl '_TSTBW15.ICL'
         jsr BW_CRNAME
         bne do_basic
par_err  lda #$9C ; parameter error
         jmp (BW_FAIL)

do_basic lda BW_COMFNAM+3
         cmp #'O'
         bne par_err
         lda BW_COMFNAM+4
         cmp #'F'
         beq tgl_bas
         clc
         eor #'N'
         beq tgl_bas
         bne par_err

* toggle BASIC
tgl_bas  sta BASICF
         php
* save collor register
         ldx #$07
         lda PCOLR0,X
         sta buffer,X
         dex
         bpl *-7
* close editor
         lda #$0C
         sta $342
         ldx #$00
         jsr CIOV
* prevent garbage screen
         ldx RTCLOK+2
         cpx RTCLOK+2
         beq *-2
         ldy #$0
         sty DMACTL
* set PORTB
         lda PORTB
         ror @
         ror @
         plp
         rol @
         rol @
         sta PORTB
* check RAM, maybe external cartridge
* TRIG3 cannot be used => OS A/B
         sty $80
         ldx #$CF
chk_ram  txa
         sec
         sbc #$10
         tax
         stx $81
         eor ($80),Y
         sta ($80),Y
         eor ($80),Y
         bne chk_ram
         inx
         stx RAMSIZ
         stx RAMTOP
* open editor
         lda #$03
         sta $342
         lda <editor
         sta $344
         lda >editor
         sta $345
         ldx #$00
         jsr CIOV
* restore collor register
         ldx #$07
         lda buffer,X
         sta PCOLR0,X
         dex
         bpl *-7
         rts

editor   dta c'E:',b($9b)
buffer   equ *

         end
