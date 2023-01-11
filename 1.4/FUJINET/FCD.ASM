* FujiNet FCD Set Slot Path
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
* parse parameter
_bufoff ldx $ffff
        jsr trim
        cmp #$9b
        beq prnuse
* check for slot number
        cmp #'1'
        bcc badpara
        cmp #'9'
        bcs badpara
* set slot number
        and #$0F
        sec
        sbc #$01
        sta fcdslt
        jsr trim
* if / first char then reset path
        cmp #'/'
        bne chkpth
        txa
        pha
        jsr do_fcd
        pla
        tax
        dex
        jmp spth
* check path
chkpth  dex
        jmp spth

* bad parameter print usage
badpara jsr prnuse
        ldy #$9C ; Bad Parameter
        jmp SD_FAIL
prnuse  jsr _print
        dta b($9b),c'Usage: FCD slot# [path]',b($9b,$00)
        rts

* set path in buffer for CD
spth    ldy #$00
nxtlbuf jsr getlbuf
        cmp #$9b
        beq do_fcd
        sta buffer,Y
        iny
        jmp nxtlbuf
* set slot path
do_fcd  ldx <fcd
        ldy >fcd
        jsr do_sio
        rts

* get next char from command line
getlbuf lda $ffff,X
        inx
        rts

* trim spaces
trim    jsr getlbuf
        cmp #' '
        beq *-5
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

* DCB data for Fuji SET SLOT PREFIX (PATH)
fcd     dta b($70,$01)  ; FujiNet device and unit
        dta b($E1)      ; Command SET SLOT PREFIX
        dta b($80)      ; status
        dta a(buffer)   ; path buffer
        dta b($10)      ; time out
        dta b($00)      ; unused
        dta a($100)     ; buffer size
fcdslt  dta b($00)      ; AUX1 slot number
        dta b($00)      ; AUX2

        icl '_CHKSDOS.ICL'
        icl '_SDFAIL.ICL'
        icl '_SDLSIO.ICL'
        icl '_PRINT.ICL'

* device slots buffer
buffer  equ *

        end
