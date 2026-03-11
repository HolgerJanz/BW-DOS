* test BW-DOS 1.5, inline include
         lda BW_SPARTA
         cmp #'S'
         bne _tstbw_e
         lda BW_DOS
         cmp #'B'
         bne _tstbw_e
         lda BW_DOS+1
         cmp #'W'
         bne _tstbw_e
         lda BW_VERS
         cmp #$15
         bcs _tstbw_f
_tstbw_e lda #$0B
         sta $342
         lda <_tstbw_t
         sta $344
         lda >_tstbw_t
         sta $345
         lda <_tstbw_f-_tstbw_t
         sta $348
         ldx #$00
         stx $349
         jsr CIOV
         jmp ($000A)
_tstbw_t dta b($9B,$FD)
         dta c'Error: no BW-DOS 1.5'
         dta b($9B)
_tstbw_f equ *
