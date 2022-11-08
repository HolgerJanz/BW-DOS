_chksdos    lda SD_SPARTA
            cmp #'S'
            beq _chksdos_e
            jsr _print
            dta b($9B)
            dta c'Error: No SpartaDOS'
            dta b($9B,$00)
            jmp (DOSVEC)
_chksdos_e  rts
