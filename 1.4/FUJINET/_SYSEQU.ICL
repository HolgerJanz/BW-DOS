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
DOSINI      equ $0C
RTCLOK      equ $12
CRITIC      equ $42
RAMTOP      equ $6a

RAMSIZ      equ $2e4
MEMTOP      equ $2e5
MEMLO       equ $2e7
SDMCTL      equ $22F
CH          equ $2fc

DDEVIC      equ $300
DUNIT       equ $301
DCMND       equ $302
DSTATS      equ $303
DBUFA       equ $304
DTIMLO      equ $306
DUNUSE      equ $307
DBYT        equ $308
DAUX1       equ $30A
DAUX2       equ $30B

IOCB0       equ $340

* dynamic SpartaDOS variables (relative to DOSVEC)
SD_SPARTA   equ $700 ; SpartaDOS flag 'S'
SD_SVERS    equ $701 ; SparataDOS version
SD_SSVERS   equ $702 ; SparataDOS sub version
* substract
SD_LSIO     equ $0A
* add
SD_CRNAME   equ $03
SD_XDIVIO   equ $08
SD_BUFOFF   equ $0a
SD_ODATER   equ $13
SD_OTIMER   equ $16
SD_TDOVER   equ $19
SD_LBUF     equ $3f
SD_COMFNAM  equ $21

AXLON       equ $CFFF

CONSOL      equ $D01F

PORTB       equ $D301

DMACTL      equ $D400 
NMIEN       equ $D40E

CIOV        equ $E456
WARMSV      equ $E474
COLDSV      equ $E477

REVDAT      equ $ffee
XLXEOP      equ $fff1
PATNUM      equ $fff2
REVNUM      equ $fff7
CHKSUM      equ $fff8
