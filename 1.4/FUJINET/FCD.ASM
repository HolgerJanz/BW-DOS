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
* set slot number
        and #$0F
        sec
        sbc #$01
        sta fcdslt
        jsr _lbtrim
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
        jmp _fail
prnuse  jsr _print
        dta b($9b),c'Vers 19-01-2023',b($9b)
        dta c'Usage: FCD slot# [path]',b($9b,$00)
        rts

* set path in buffer for CD
spth    ldy #$00
nxtlbuf jsr _lbget
        cmp #$9b
        beq do_fcd
        sta buffer,Y
        iny
        jmp nxtlbuf
* set slot path
do_fcd  ldx <fcd
        ldy >fcd
        jsr _dosio
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

        icl '_PRINT.ICL'
        icl '_CHKSDOS.ICL'
        icl '_SDFAIL.ICL'
        icl '_SDLSIO.ICL'
        icl '_SDLBUF.ICL'

* device slots buffer
buffer  equ *

        end
