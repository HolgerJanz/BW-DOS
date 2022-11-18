* FujiNet FPWD Print Slot Path
        icl '_SYSEQU.ICL'
        icl '_FNEQU.ICL'

        blk dos $3000
        jsr _chksdos
* clear buffer
        ldx #$00
        txa
clr_buf sta buffer,X
        inx
        bne clr_buf
* parse parameter
* get BUFOFF
        clc
        lda DOSVEC
        adc #SD_BUFOFF
        sta _bufoff+1
        lda DOSVEC+1
        adc #$00
        sta _bufoff+2
* get LBUF
        clc
        lda DOSVEC
        adc #SD_LBUF
        sta getlbuf+1
        lda DOSVEC+1
        adc #$00
        sta getlbuf+2
* parse
_bufoff ldx $ffff
        jsr getlbuf
        cmp #' '
        beq *-5
* check for slot number
        cmp #'1'
        bcc badpara
        cmp #'9'
        bcs badpara
        tay
        jsr getlbuf
        cmp #$9b
        beq sslt
badpara jsr _print
        dta b($9b),c'Usage: FPWD <slot#1..8>',b($9b,$00)
        ldy #$9C ; Bad Parameter
        jmp SD_FAIL
* set slot
sslt    dey
        tya
        and #$0F
        sta fpwdslt
* get host slot path
do_fcd  ldx <fpwd
        ldy >fpwd
        jsr do_sio
* print host slot path
        jsr prneol
        lda #'/'
        jsr _putc
        ldx #$00
        stx iter1
nxtchar lda buffer,X
        beq prneol
        jsr _putc
        inc iter1
        ldx iter1
        cpx #$00
        bne nxtchar
* print EOL
prneol  lda #$9b
        jmp _putc

* get next char from command line
getlbuf lda $ffff,X
        inx
        rts

* set DCB and call SIO
do_sio  stx nxtsiod+1
        sty nxtsiod+2
        ldx #$0b
nxtsiod lda $FFFF,X
        sta DDEVIC,X
        dex
        bpl nxtsiod
        jsr SD_SIO
        bpl *+5
        jmp SD_FAIL
        rts

* DCB data for Fuji GET SLOT PREFIX (PATH)
fpwd    dta b($70,$01)  ; FujiNet device and unit
        dta b($E0)      ; Command GET SLOT PREFIX
        dta b($40)      ; status
        dta a(buffer)   ; path buffer
        dta b($10)      ; time out
        dta b($00)      ; unused
        dta a($100)     ; buffer size
fpwdslt dta b($00)      ; AUX1 slot number
        dta b($00)      ; AUX2

        icl '_CHKSDOS.ICL'
        icl '_SDFAIL.ICL'
        icl '_SDLSIO.ICL'
        icl '_PRINT.ICL'

iter1   equ *
* device slots buffer
buffer  equ iter1+1

        end
