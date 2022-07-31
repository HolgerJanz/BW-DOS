ICHID       equ $00
ICDNO       equ $01
ICCOM       equ $02
ICSTA       equ $03
ICBAL       equ $04
ICBAH       equ $05
ICPTL       equ $06
ICPTH       equ $07
ICBLL       equ $08
ICBLH       equ $09
ICAX1       equ $0A
ICAX2       equ $0B
ICAX3       equ $0C
ICAX4       equ $0D
ICAX5       equ $0E
ICAX6       equ $0F

DOSVEC      equ $0A

MEMTOP      equ $2E5
SDMCTL      equ $22F
DDEVIC      equ $300
IOCB0       equ $340

sparta_flag equ $700

* BW-DOS offsets
BW_LSIO     equ $0A
BW_XDIVIO   equ $08
BW_BUFOFF   equ $0a
BW_ODATER   equ $13
BW_OTIMER   equ $16
BW_TDOVER   equ $19
BW_LBUF     equ $3f
BW_COMFNAM  equ $21

DMACTL      equ $D400 
NMIEN       equ $D40E

CIOV        equ $E456
WARMSV      equ $E474
COLDSV      equ $E477
