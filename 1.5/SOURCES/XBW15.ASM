* BW-DOS 1.5
* use Fast Assembler
* https://github.com/HolgerJanz/FastAssembler
        icl 'XBWEQU.ICL'

* DOS kind normal = space
BW_DK1  equ ' '
BW_DK2  equ ' '

        blk dos BW_BGN
        icl 'XBWCOMTA.ICL'

        blk dos DAT_DEF+$141
* command line interpreter
        icl 'XBWCP.ICL'
        icl 'XBWCMD.ICL'
* CIO implementation
        icl 'XBWCIO1.ICL'
        icl 'XBWCIO2.ICL'

SIO_BUF equ *

        blk dos SIO_BUF+$300
* cfile management system
        icl 'XBWFMS.ICL'

END_ADR equ *

        blk dos RUNAD
        dta a(START)
