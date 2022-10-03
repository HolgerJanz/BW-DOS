* Cold Start

* OS equates
        icl '_SYSEQU'

        blk dos $2800
        jsr _chkbwdos14
* stop batch and hard copy
        ldy #$00
        jsr XDIVIO
        ldy #$01
        jsr XDIVIO
* jump cold start
        jmp COLDSV 

XDIVIO  jmp (BW_XDIVIO)

        icl '_PRINT'
        icl '_CHKBWD14'

        end
