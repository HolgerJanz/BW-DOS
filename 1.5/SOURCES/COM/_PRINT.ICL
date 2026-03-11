* print string to console
_print      lda #$01
            sta _print_ldy+1
            pla
            sta _print_lda+1
            pla
            sta _print_lda+2
_print_loop inc _print_lda+1
            bne _print_lda
            inc _print_lda+2
_print_lda  lda $FFFF
            beq _print_lend
_print_putc jsr _putc
            bpl _print_loop
            sty _print_ldy+1
            bmi _print_putc
_print_lend lda _print_lda+2
            pha
            lda _print_lda+1
            pha
_print_ldy  ldy #$01
            rts

* put char to console
_putc tay
      lda #$00
      tax
      sta $340+$08,X
      sta $340+$09,X
      lda #$0B
      sta $340+$02,X
      tya
      jmp $E456
