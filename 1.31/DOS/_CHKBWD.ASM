* check BW-DOS, needs _print
_chkbwdos   lda $700
            cmp #'S'
            bne _chkbwdos_e
            lda $703
            cmp #'B'
            bne _chkbwdos_e
            lda $704
            cmp #'W'
            bne _chkbwdos_e
            rts
_chkbwdos_e jsr _print
            .byte $9B,$FD
            .byte 'Error: Not BW-DOS'
            .byte $9B,$00
            jmp ($000A)
