* BW-DOS 1.4
* use Fast Assembler
* https://github.com/HolgerJanz/FastAssembler
        icl 'XBWEQU.ICL'

* DOS kind normal = space
BW_DOSK equ ' '

        blk dos BW_BGN
        icl 'XBWCOMTA.ICL'

        blk dos DAT_DEF+$141 ; $0F4C
* command line interpreter
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
