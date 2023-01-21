* call local SD SIO
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

* set DCB and call SIO
_dosio      stx _nxtsiod+1
            sty _nxtsiod+2
            ldx #$0b
_nxtsiod    lda $FFFF,X
            sta DDEVIC,X
            dex
            bpl _nxtsiod
            jsr SD_SIO
            bpl *+5
            jmp _fail
            rts
