* test BW-DOS 1.5, inline include
            lda BW_SPARTA
            cmp #'S'
            bne _chkbw15_e
            lda BW_DOS
            cmp #'B'
            bne _chkbw15_e
            lda BW_DOS+1
            cmp #'W'
            bne _chkbw15_e
            lda BW_VERS
            cmp #$15
            bcc _chkbw15_e
            bcs _chkbw15_f

_chkbw15_e  lda #$0B
            sta $342
            lda <_chkbw15_t
            sta $344
            lda >_chkbw15_t
            sta $345
            lda <_chkbw15_f-_chkbw15_t
            sta $348
            ldx #$00
            stx $349
            jsr CIOV
            jmp ($000A)
_chkbw15_t  dta b($9B,$FD)
            dta c'Error: no BW-DOS 1.5'
            dta b($9B)
_chkbw15_f  equ *
