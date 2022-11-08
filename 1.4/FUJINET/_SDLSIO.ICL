_lsioset    dta b($00)
SD_SIO      lda _lsioset
            bne _jsr_lsio
            lda DOSVEC
            sec
            sbc #SD_LSIO
            sta _jsr_lsio+1
            lda DOSVEC+1
            sbc #$00
            sta _jsr_lsio+2
            lda #$ff
            sta _lsioset
_jsr_lsio   jmp ($ffff)
