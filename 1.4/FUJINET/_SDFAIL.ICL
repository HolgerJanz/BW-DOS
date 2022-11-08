* print error
SD_FAIL     tya
            pha
            jsr _print
            dta b($9B)
            dta c'Error '
            dta b($00)
* output error number in decimal
            pla
            jsr SD_PUTDEC
            lda #$9B
            jsr _putc
* stop batch
            ldy #SD_XDIVIO
            lda (DOSVEC),Y
            sta _fxdivio+1
            iny
            lda (DOSVEC),Y
            sta _fxdivio+2
            ldy #$01
_fxdivio    jsr $ffff
            jmp (DOSVEC)

SD_PUTDEC   ldx #$02
_dec_loop   ldy #$00
_sbc_loop   cmp _decimal,X
            bcc _next_dec
            sbc _decimal,X
            iny
            bne _sbc_loop
_next_dec   pha
            txa
            pha
            tya
            ora #$30
            jsr _putc
            pla
            tax
            pla
            dex
            bpl _dec_loop
            rts

* array with decimals
_decimal    dta b(1,10,100)

