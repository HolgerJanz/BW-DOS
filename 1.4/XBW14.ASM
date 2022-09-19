* BW-DOS 1.31 22-05-31
* use Fast Assembler
* https://github.com/HolgerJanz/FastAssembler

* System equates
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

WARMST      equ $08
BOOT        equ $09
DOSVEC      equ $0A
DOSINI      equ $0C

ICHIDZ      equ $20
ICDNOZ      equ $21
ICCOMZ      equ $22
ICSTAZ      equ $23
ICBALZ      equ $24
ICBLLZ      equ $28
ICBLHZ      equ $29
ICAX1Z      equ $2A
ICAX2Z      equ $2B
ICAX5Z      equ $2E

LMARGN      equ $52

RAMTOP      equ $6A

COLDST      equ $244
RUNAD       equ $2E0
INITAD      equ $2E2
RAMSIZ      equ $2E4
MEMTOP      equ $2E5
MEMLO       equ $2E7

DDEVIC      equ $300
DUNIT       equ $301
DCOMND      equ $302
DSTATS      equ $303
DBUFLO      equ $304
DTIMLO      equ $306
DBYTLO      equ $308
DBYTHI      equ $309
DAUX1       equ $30A
DAUX2       equ $30B

HATABS      equ $31A
IOCB0       equ $340
IOCB1       equ $350
IOCB5       equ $390

BASICF      equ $3F8

CARTCS      equ $BFFA
CART        equ $BFFC
CARTFG      equ $BFFD

PORTB       equ $D301

CIOV        equ $E456
SIOV        equ $E459
SELFSV      equ $E471

* DOS zero page
L0043       equ $0043
L0044       equ $0044
L0045       equ $0045
L0046       equ $0046
L0047       equ $0047
L0048       equ $0048
L0049       equ $0049

STACK       equ $0100

* 6502 opcodes
op_ADC_imd  equ $69
op_AND_abs  equ $29
op_BIT_abs  equ $2C
op_BIT_zp   equ $24
op_JMP_abs  equ $4C
op_SBC_imd  equ $E9

* MOVE_CALL commands
*  jsr subroutine
MC_jsr      equ $0000
*  copy inside buffer by offset
MC_cpy      equ $20
*  move from address to address
MC_mov      equ $4000
*  like MC_jsr and end
MC_jsrE     equ $8000
*  like MC_cpy and end
MC_cpyE     equ $A0
*  like MC_mov and end
MC_movE     equ $C000
* length in bytes for move
MC_1        equ $2000
MC_2        equ $4000
MC_3        equ $6000
MC_4        equ $8000
MC_5        equ $A000
MC_6        equ $C000
MC_7        equ $E000

* date and time initial value
INI_DAY     equ 04
INI_MONTH   equ 09
INI_YEAR    equ 22
INI_HOUR    equ 14
INI_MINUTE  equ 41
INI_SECOND  equ 45

* begin address of BW-DOS
BW_BEGIN    equ $0700

            blk dos BW_BEGIN

            dta c'S'       ;$700 the character "S" for SpartaDOS
            dta b($32)     ;$701 compatibility with SpartaDOS 3.2
            dta b($00)     ;$702 ??? 
            dta c'BW'      ;$703 "BW" when BW-DOS is installed
            dta b($14)     ;$705 BW-DOS version 1.4 
GETTDV      dta a(GETTD)   ;$706 Adress of the "GETTD" routine
SETTDV      dta a(SETTD)   ;$708 Adress of the "SETTD" routine
            dta a(CONVDC)  ;$70A Adress CONVDC
            jmp SSIOV      ;$70C jmp LSIO 4C EE 0C

* code for command line interpreter
            icl 'XBWCMD.ASM'

* Start of COMTAB
DWARM       dta b($FF)             ; -21
            dta b($80)             ; -20 ???
DECOUT      dta b($20,$20,$20,$20) ; -19
            dta b($20,$20,$20,$20)
SSIOV       dta b(op_JMP_abs)      ; -13 jmp SIO
LSIO        dta a(SIOV)            ; -10
ECHOFLG     dta b($FF)             ; -8
BATFLG      dta b($FF)             ; -7
DECIN       dta b($00,$00,$00,$00) ; -6
WRTCMD      dta c'P'               ; -2 W($57)=verify P($50)=no verify
SWARMST     dta b($FF)             ; -1 00 in CP, $FF trap errors
* DOSVEC => $0cf9
COMTAB      jmp _COMTAB            ; COMTAB Jump to DOS CP
CRNAME      jmp _CRNAME            ; +3
DIVIO       dta a(R_DIVIO)         ; +6
XDIVIO      dta a(R_XDIVIO)        ; +8
BUFOFF      dta b($00)             ; +10
ZORIG       dta a(BW_BEGIN)        ; +11
DATER       dta b(INI_DAY,INI_MONTH,INI_YEAR) ; +13
TIMER       dta b(INI_HOUR,INI_MINUTE,INI_SECOND) ; +16
ODATER      dta b(INI_DAY,INI_MONTH,INI_YEAR) ; +19
OTIMER      dta b(INI_HOUR,INI_MINUTE,INI_SECOND) ; +22
TDOVER      dta b($00)             ; +25
TRUN        dta a(_RTS)            ; +26
            dta a(CIO_BUF)         ; +28 ??? buffer address ???
SMEMLO      dta a(END_ADDR)        ; +30 start up MEMLO
INCMND      dta b($00)             ; +32 Reset $00-CP $FF-Cart
COMFNAM     dta c'D1:STARTUP.BAT'  ; +33 28 Bytes
            dta b($9B)
            dta c'             '
RUNLOC      dta a(_RTS)            ; +61 address for RUN
* start code to check for STARTUP.BAT
LBUF        jsr L07F2              ; +63 comman line buffer 64 Bytes
            lda #$FF
            sta L0047
            ldy #$01
            jsr R_DIVIO
            jsr L0A71
            stx COLDST
            lda BOOT
            ora #$01
            sta BOOT
            jmp _COMTAB
            clc
            rts
            dta c'                          '
            dta c'         '
L0D43       equ LBUF+$0B
L0D48       equ LBUF+$10
PROMPT      dta b($9B)
PROMPTD     dta c'D1:'
            dta b($9B)
EXT_BAT     dta c'.BAT'
            dta b($9B)
EXT_COM     dta c'.COM'
            dta b($9B)
STD_PAT     dta c'*.*'
DAT_BUF     equ *
TXT_VOLU    dta b($9B)
            dta c'Volume'
TXT_PERI    dta c':'
L0D92       dta c'          '

TXT_BUF     dta c' '
L0D9D       dta c'  '
L0D9F       dta c'  '
L0DA1       dta c'   '
L0DA4       dta c'  '
L0DA6       dta c' '
L0DA7       dta c'  '
L0DA9       dta c' '
L0DAA       dta c' '
L0DAB       dta c'  '
            dta c'    '
L0DB1       dta c'  '
L0DB3       dta c'   '
L0DB6       dta c'      '
L0DBC       dta c' '
L0DBD       dta c'        '
L0DC5       dta c' '

TXT_DIRY    dta b($9B)
            dta c'Directory:'
TXT_DIRI    dta b($C4,$C9,$D2) ; DIR inverse
TXT_DIRL    dta c'<DIR>'
TXT_FREE    dta c'free sectors'
L0DE5       dta b($00,$00)
L0DE7       dta b($00,$00)
L0DE9       dta b($80)
            dta c'    '
L0DEE       dta c' '
L0DEF       dta c' '
L0DF0       dta c'  '
INIFLAGS    dta b($FF,$FF)
L0DF4       dta c'DOS       '
L0DFE       dta c' !'
L0E00       dta b($00,$00,$00)
L0E03       dta b($02)
            dta b($00)
L0E05       dta b($1C)
L0E06       dta b($17,$00)
L0E08       dta a($0001)
TXT_DASH    dta c'-'

DAT_DEF     equ *
* start of initialization after loading
* start it is used for buffers $141 bytes
start       ldx #$1A
* search for E:
_srch_e     lda DDEVIC,X
            cmp #'E'
            beq _e_found
            inx
            inx
            inx
            cpx #$3B
            bcc _srch_e
* E: not found => Self Test
            jmp SELFSV
* update HATABS access
_e_found    inx
            stx L0B32+1
            stx L0B65+3
            stx L0AF2+3
            inx
            stx L0B28+1
* move dos_iniv to DOSINI
            jsr MOVE_CALL
  dta h(MC_movE+dos_iniv),l(dos_iniv),h(MC_2+DOSINI),l(DOSINI)
* print BW-DOS version
            jsr DO_CIO_0
            dta b($0B)
            dta a(dos_text,dos_text_e-dos_text)
* execute STARTUP.BAT
            jmp LBUF
dos_iniv    dta a(DOS_INI)
dos_text    dta b($9B)
            dta c'BW-DOS 1.4 BEWESOFT 04-09-2022'
            dta b($9B)
dos_text_e  equ *

* buffer addresses $0E0B-$0F4B ($141 Bytes)
L0E0B       equ DAT_DEF
L0E16       equ DAT_DEF+$0B
L0E21       equ DAT_DEF+$16
L0E22       equ DAT_DEF+$17
L0E24       equ DAT_DEF+$19
L0E26       equ DAT_DEF+$1B
L0E27       equ DAT_DEF+$1C
L0E2F       equ DAT_DEF+$24
L0E32       equ DAT_DEF+$27
L0E38       equ DAT_DEF+$2D
L0E39       equ DAT_DEF+$2E
L0E3A       equ DAT_DEF+$2F
L0E3B       equ DAT_DEF+$30
L0E3C       equ DAT_DEF+$31
L0E3D       equ DAT_DEF+$32
L0E3E       equ DAT_DEF+$33
L0E3F       equ DAT_DEF+$34
L0E40       equ DAT_DEF+$35
L0E41       equ DAT_DEF+$36
L0E42       equ DAT_DEF+$37
L0E43       equ DAT_DEF+$38
L0E45       equ DAT_DEF+$3A
L0E48       equ DAT_DEF+$3D
L0E49       equ DAT_DEF+$3E
L0E4B       equ DAT_DEF+$40
L0E4C       equ DAT_DEF+$41
L0E4D       equ DAT_DEF+$42
L0E51       equ DAT_DEF+$46
L0E52       equ DAT_DEF+$47
L0E53       equ DAT_DEF+$48
L0E55       equ DAT_DEF+$4A
L0E56       equ DAT_DEF+$4B
L0E58       equ DAT_DEF+$4D
L0E5A       equ DAT_DEF+$4F
L0E5D       equ DAT_DEF+$52
L0E5F       equ DAT_DEF+$54
L0E61       equ DAT_DEF+$56
L0E63       equ DAT_DEF+$58
L0E67       equ DAT_DEF+$5C
L0E6B       equ DAT_DEF+$60
L0E6D       equ DAT_DEF+$62
L0ED7       equ DAT_DEF+$CC
L0ED8       equ DAT_DEF+$CD

L0F15       equ DAT_DEF+$10A
L0F38       equ DAT_DEF+$12D
L0F40       equ DAT_DEF+$135
L0F43       equ DAT_DEF+$138
L0F46       equ DAT_DEF+$13B
L0F49       equ DAT_DEF+$13E

            blk dos DAT_DEF+$141 ; $0F4C
* code for CIO D: implementation
            icl 'XBWCIO1.ASM'
            icl 'XBWCIO2.ASM'

CIO_BUF     equ *

            blk dos CIO_BUF+$300
* code for low level file management system
            icl 'XBWFMS.ASM'

END_ADDR    equ *

            blk dos RUNAD
            dta a(start)
