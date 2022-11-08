* Cold Start

* OS equates
        icl '_SYSEQU.ICL'

        blk dos $3000
        jsr _chkbwdos14
* stop batch and hard copy
        ldy #$00
        jsr XDIVIO
        ldy #$01
        jsr XDIVIO
* jump cold start
        jmp COLDSV 

XDIVIO  jmp (BW_XDIVIO)

        icl '_PRINT.ICL'
        icl '_CHKBW14.ICL'

        end
