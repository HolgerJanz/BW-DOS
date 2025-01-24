* Cold Start

* OS equates
        icl '_SYSEQU.ICL'

        blk dos $580
        icl '_TSTBW14.ICL'
* stop batch and hard copy
        ldy #$00
        jsr XDIVIO
        ldy #$01
        jsr XDIVIO
* jump cold start
        jmp COLDSV 

XDIVIO  jmp (BW_XDIVIO)

        icl '_PRINT.ICL'

        end
