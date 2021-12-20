* print string to console
_print      pla
            sta _print_lda+1
            pla
            sta _print_lda+2
_print_loop inc _print_lda+1
            bne _print_lda
            inc _print_lda+2
_print_lda lda $FFFF
            beq _print_lend
            jsr _putc
            jmp _print_loop
_print_lend lda _print_lda+2
            pha
            lda _print_lda+1
            pha
            rts

* put char to console
_putc       tay
            lda #$00
            tax
            sta $340+ICBLL,X
            sta $340+ICBLH,X
            lda #$0B
            sta $340+ICCOM,X
            tya
            jmp $E456
