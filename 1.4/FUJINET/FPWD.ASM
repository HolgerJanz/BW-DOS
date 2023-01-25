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
        jsr _lbinit
        jsr _lbtrim
        cmp #$9b
        beq prnuse
* check for slot number
        cmp #'1'
        bcc badpara
        cmp #'9'
        bcs badpara
        tay
        jsr _lbget
        cmp #$9b
        beq sslt
* Bad Parameter
badpara jsr prnuse
        ldy #$9C
        jmp _fail
prnuse  jsr _print
        dta b($9b),c'Vers 24-01-2023',b($9b)
        dta c'Usage: FPWD slot#',b($9b,$00)
        rts

* set slot
sslt    dey
        tya
        and #$0F
        sta fpwdslt
* get host slot path
do_fcd  ldx <fpwd
        ldy >fpwd
        jsr _dosio
* print host slot path
        jsr prneol
        ldx #$00
        stx iter1
nxtchar lda buffer,X
        beq prneol
        jsr _putc
        inc iter1
        ldx iter1
        bne nxtchar
* print EOL
prneol  lda #$9b
        jmp _putc

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

        icl '_PRINT.ICL'
        icl '_CHKSDOS.ICL'
        icl '_SDLBUF.ICL'
        icl '_SDFAIL.ICL'
        icl '_SDLSIO.ICL'

iter1   equ *
* device slots buffer
buffer  equ iter1+1

        end
