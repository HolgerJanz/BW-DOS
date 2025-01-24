* test BW-DOS 1.4, inline include
            lda BW_SPARTA
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
            bcs _chkbw14_f

_chkbw14_e  lda #$0B
            sta $342
            lda <_chkbw14_t
            sta $344
            lda >_chkbw14_t
            sta $345
            lda <_chkbw14_f-_chkbw14_t
            sta $348
            ldx #$00
            stx $349
            jsr CIOV
            jmp ($000A)
_chkbw14_t  dta b($9B,$FD)
            dta c'Error: no BW-DOS 1.4'
            dta b($9B)
_chkbw14_f  equ *
