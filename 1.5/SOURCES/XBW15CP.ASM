* BW-DOS 1.5 CP
* use Fast Assembler
* https://github.com/HolgerJanz/FastAssembler
        icl 'XBWEQU.ICL'

* DOS kind command processor only, no internal commands
BW_DK1  equ 'C'
BW_DK2  equ 'P'

        blk dos BW_BGN
        icl 'XBWCOMTA.ICL'

        blk dos DAT_DEF+$141
* command line interpreter
        icl 'XBWCP.ICL'
        icl 'XBWCMDC.ICL'
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
