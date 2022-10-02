* check BW-DOS, needs _print
_chkbwdos14 lda BW_SPARTA
            cmp #'S'
            bne _chkbw14_e
            lda BW_DOS
            cmp #'B'
            bne _chkbw14_e
            lda BW_DOS+1
            cmp #'W'
            bne _chkbw14_e
            lda BW_VERS
            cmp #$14
            bcc _chkbw14_e
            rts

_chkbw14_e  jsr _print
            dta b($9B,$FD)
            dta c'Error: no BW-DOS 1.4'
            dta b($9B,$00)
            jmp ($000A)
