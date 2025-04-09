ICHID  equ $00
ICDNO  equ $01
ICCOM  equ $02
ICSTA  equ $03
ICBAL  equ $04
ICBAH  equ $05
ICPTL  equ $06
ICPTH  equ $07
ICBLL  equ $08
ICBLH  equ $09
ICAX1  equ $0A
ICAX2  equ $0B
ICAX3  equ $0C
ICAX4  equ $0D
ICAX5  equ $0E
ICAX6  equ $0F

WARMST equ $08
DOSVEC equ $0A
DOSINI equ $0C
RTCLOK equ $12
CRITIC equ $42
LMARGN equ $52
RMARGN equ $53
RAMTOP equ $6a


SHPDVS equ $248
PCOLR0 equ $2C0
NOCLIK equ $2DB
RUNAD  equ $2E0
INITAD equ $2E2
RAMSIZ equ $2e4
MEMTOP equ $2e5
MEMLO  equ $2e7
SDMCTL equ $22F
CH     equ $2FC

DDEVIC equ $300
DUNIT  equ $301
DCMND  equ $302
DSTATS equ $303
DBUFA  equ $304
DTIMLO equ $306
DUNUSE equ $307
DBYT   equ $308
DAUX1  equ $30A
DAUX2  equ $30B

IOCB0  equ $340

BASICF equ $3F8

* static BW-DOS variables
BW_SPARTA  equ $700 ;SpartaDOS flag 'S'
BW_SVERS   equ $701 ;SparataDOS version
BW_SSVERS  equ $702 ;SparataDOS sub version
BW_DOS     equ $703 ;BW-DOS flag 'BW'
BW_VERS    equ $705 ;BW-DOS version
BW_GETTD   equ $706 ;address to get date/time
BW_SETTD   equ $708 ;address to set date/time
BW_CONVDC  equ $70A ;address conv 24bit binary to ascii vector
BW_BBSIO   equ $70C ;jump to SIO for compatibility with BiboDOS
BW_FAIL    equ $70F ;fail vector
BW_DWARM   equ $711 ;flag memory was externally changed 
BW_DECOUT  equ $713 ;output buffer for CONVDC
BW_SIO     equ $71B ;SIO vector
BW_LSIO    equ $71C ;address to used SIO, after boot $E456
BW_ECHOFLG equ $71E ;HATABS index for hard copy, $FF no hard copy
BW_BATFLG  equ $71F ;HATABS index for batch, $FF no batch
BW_DECIN   equ $720 ;Input for BW_CONVDC
BW_WRTCMD  equ $724 ;Write command P without verify, W with verify
BW_COMTAB  equ $726 ;Jump to command processor
BW_CRNAME  equ $729 ;Jump to CRNAME
BW_DIVIO   equ $72C ;address of DIVIO
BW_XDIVIO  equ $72E ;address of XDIVIO
BW_BUFOFF  equ $730 ;current offset in BW_LBUF
BW_DATER   equ $733 ;date for GETTD and SETTD
BW_TIMER   equ $736 ;time for GETTD and SETTD
BW_ODATER  equ $739 ;time for TDOVER
BW_TDOVER  equ $73F ;flag TDOVER
BW_SECBUF  equ $742 ;address for sector bufffers 3*256
BW_SMEMLO  equ $744 ;startup MEMLO
BW_INCMND  equ $746 ;start CP ?
BW_COMFNAM equ $747 ;result from BW_CRNAME
BW_RUNLOC  equ $763 ;last run address
BW_LBUF    equ $765 ;command line buffer
BW_CURDRV  equ $7A6 ;current drive in Dx:<EOL>
BW_DOSDRV  equ $7AA ;drive number for command search
BW_EXTBAT  equ $7AB ;batch extension .BAT<EOL>
BW_EXTCOM  equ $7B0 ;executable extension .COM<EOL>
BW_STDPAT  equ $7B5 ;standard file pattern *.*<EOL>

* dynamic SpartaDOS variables (relative to DOSVEC)
* substract
SD_DECOUT  equ $13
* add
SD_CRNAME  equ $03
SD_LSIO    equ $0A
SD_XDIVIO  equ $08
SD_BUFOFF  equ $0a
SD_ODATER  equ $13
SD_OTIMER  equ $16
SD_TDOVER  equ $19
SD_LBUF    equ $3f
SD_COMFNAM equ $21

CARTCS     equ $BFFA
CART       equ $BFFC
CARTFG     equ $BFFD

CHKSUM1    equ $c000

AXLON      equ $CFFF

PAL        equ $D014

CONSOL     equ $D01F
PDVS       equ $D1FF

RANDOM     equ $D20A

PORTB      equ $D301

DMACTL     equ $D400 
WSYNC      equ $D40A
VCOUNT     equ $D40B
NMIEN      equ $D40E

CIOV       equ $E456
WARMSV     equ $E474
COLDSV     equ $E477

REVDAT     equ $ffee
XLXEOP     equ $fff1
PATNUM     equ $fff2
REVNUM     equ $fff7
CHKSUM2    equ $fff8
