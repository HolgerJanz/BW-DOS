* System equates
ICHID   equ $00
ICDNO   equ $01
ICCOM   equ $02
ICSTA   equ $03
ICBAL   equ $04
ICBAH   equ $05
ICPTL   equ $06
ICPTH   equ $07
ICBLL   equ $08
ICBLH   equ $09
ICAX1   equ $0A
ICAX2   equ $0B
ICAX3   equ $0C
ICAX4   equ $0D
ICAX5   equ $0E
ICAX6   equ $0F

WARMST  equ $08
BOOT    equ $09
DOSVEC  equ $0A
DOSINI  equ $0C
RTCLOK3 equ $14

ICHIDZ  equ $20
ICDNOZ  equ $21
ICCOMZ  equ $22
ICSTAZ  equ $23
ICBALZ  equ $24
ICBLLZ  equ $28
ICBLHZ  equ $29
ICAX1Z  equ $2A
ICAX2Z  equ $2B
ICAX5Z  equ $2E

LMARGN  equ $52

RAMTOP  equ $6A

COLDST  equ $244
RUNAD   equ $2E0
INITAD  equ $2E2
RAMSIZ  equ $2E4
MEMTOP  equ $2E5
MEMLO   equ $2E7

DDEVIC  equ $300
DUNIT   equ $301
DCOMND  equ $302
DSTATS  equ $303
DBUFLO  equ $304
DTIMLO  equ $306
DBYTLO  equ $308
DBYTHI  equ $309
DAUX1   equ $30A
DAUX2   equ $30B

HATABS  equ $31A
IOCB0   equ $340
IOCB1   equ $350
IOCB5   equ $390

BASICF  equ $3F8

CARTCS  equ $BFFA
CART    equ $BFFC
CARTFG  equ $BFFD

PORTB   equ $D301

DMACTL  equ $D400

CIOV    equ $E456
SIOV    equ $E459
SELFSV  equ $E471

* DOS zero page
L0043   equ $0043 ; B
L0044   equ $0044
L0045   equ $0045 ; MYLEN
CIOIOCB equ $0046
L0047   equ $0047
RWFLG   equ $0048
MYA1    equ $0049

STACK   equ $0100

* 6502 opcodes
op_ADC_imd equ $69
op_AND_abs equ $29
op_BIT_abs equ $2C
op_BIT_zp  equ $24
op_JMP_abs equ $4C
op_SBC_imd equ $E9

* MOVE_CALL commands
*  jsr subroutine
MC_jsr  equ $0000
*  copy inside buffer by offset
MC_cpy  equ $20
*  move from address to address
MC_mov  equ $4000
*  like MC_jsr and end
MC_jsrE equ $8000
*  like MC_cpy and end
MC_cpyE equ $A0
*  like MC_mov and end
MC_movE equ $C000
* length in bytes for move
MC_1    equ $2000
MC_2    equ $4000
MC_3    equ $6000
MC_4    equ $8000
MC_5    equ $A000
MC_6    equ $C000
MC_7    equ $E000

* date and time initial value
INI_DAY    equ 31
INI_MONTH  equ 05
INI_YEAR   equ 25
INI_HOUR   equ 08
INI_MINUTE equ 05
INI_SECOND equ 45

* begin address of BW-DOS
BW_BGN  equ $0700
