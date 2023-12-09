* COMTAB page $700

        dta c'S'       ;$700 the character "S" for SpartaDOS
        dta b($32)     ;$701 version, compatible with SpartaDOS 3.2
        dta b($00)     ;$702 subversion e.g. SDX 4.49 => $09
        dta c'BW'      ;$703 "BW", if BW-DOS is installed
        dta b($14)     ;$705 BW-DOS version 1.4 
GETTDV  dta a(GETTD)   ;$706 Adress of the "GETTD" routine
SETTDV  dta a(SETTD)   ;$708 Adress of the "SETTD" routine
        dta a(CONVDC)  ;$70A Adress CONVDC
BW_SIO  jmp SSIOV      ;$70C jmp LSIO
BW_FAIL dta a(CPER2)   ;$70F print error A and DOSVEC
* Start of COMTAB
* static, can be used absolut (not only relative to DOSVEC)
DWARM   dta b($FF)     ; -21
        dta b($80)     ; -20 ???
DECOUT  dta b($20,$20,$20,$20) ; -19
        dta b($20,$20,$20,$20)
SSIOV   dta b(op_JMP_abs) ; -13 jmp SIO
LSIO    dta a(SIOV)    ; -10
ECHOFLG dta b($FF)     ; -8
BATFLG  dta b($FF)     ; -7
DECIN   dta b($00,$00,$00,$00) ; -6
WRTCMD  dta c'P'       ; -2 W($57)=verify P($50)=no verify
SWARMST dta b($FF)     ; -1 00 in CP, $FF trap errors
* DOSVEC
COMTAB  jmp CP         ; COMTAB Jump to DOS CP
CRNAME  jmp _CRNAME    ; +3
DIVIO   dta a(R_DIVIO) ; +6
XDIVIO  dta a(R_XDIVIO) ; +8
BUFOFF  dta b($00)     ; +10
ZORIG   dta a(BW_BGN)  ; +11
DATER   dta b(INI_DAY,INI_MONTH,INI_YEAR) ; +13
TIMER   dta b(INI_HOUR,INI_MINUTE,INI_SECOND) ; +16
ODATER  dta b(INI_DAY,INI_MONTH,INI_YEAR) ; +19
OTIMER  dta b(INI_HOUR,INI_MINUTE,INI_SECOND) ; +22
TDOVER  dta b($00)     ; +25
TRUN    dta a(RET)     ; +26
        dta a(SIO_BUF) ; +28 3x256 Bytes SIO buffer
TMEMLO  dta a(END_ADR) ; +30 start up MEMLO
INCMND  dta b($00)     ; +32 Reset $00-CP $FF-Cart
COMFNAM dta c'D1:STARTUP.BAT'  ; +33 28 Bytes
        dta b($9B)
        dta c'             '
RUNLOC  dta a(RET)     ; +61 address for RUN
* start code to check for STARTUP.BAT
LBUF    jsr RESINI     ; +63 comman line buffer 64 Bytes
        lda #$FF
        sta L0047
        ldy #$01
        jsr R_DIVIO
        jsr NULDW
        stx COLDST
        lda BOOT
        ora #$01
        sta BOOT
        jmp CP
        dta c'                          '
        dta c'           '

PROMPT  dta b($9B)
PROMPTD dta c'D1:'
        dta b($9B)
EXT_BAT dta c'.BAT'
        dta b($9B)
EXT_COM dta c'.COM'
        dta b($9B)
STD_PAT dta c'*.*'

DAT_BUF equ *
DIRVOL  dta b($9B)
        dta c'Volume'
PERIOD  dta c':'
DIRNAM  dta c'           '      ; 11 Bytes
DIBUF   dta c'                '
        dta c'                '
        dta c'         ' ; 41 Bytes

DLDIR   dta b($9B)
        dta c'Directory:'
DLG3TX  dta b($C4,$C9,$D2) ; DIR inverse
DLG3DT  dta c'<DIR>'
DLFREE  dta c'free sectors'
* temp last alloc/delete sector
VTOCSEC dta b($00,$00)
SRCHTMP dta b($00,$00)
* bytes per sec of disk, $80=128 $00=256
* D0: used for sec 1 always 128
SECSIZ  dta b($80) ;D0: for sec 1
        dta b($00,$00,$00,$00) ;D1-4:
POSTMP  dta b($00,$00,$00)
        dta b($00) ;DSKSECSIZ D8:
KFFFF   dta a($FFFF)
DOSNAM  dta c'DOS       '
RDPUTST dta c' !'
NULY    dta b($00,$00,$00)
K0002   dta a($02)
K1C     dta b($1C)
K0017   dta a($17)
K0001   dta a($0001)
DASH    dta c'-'

DAT_DEF equ *
* start of initialization after loading
* after start it is used for buffers $141 bytes
START   ldx #$1A
* search for E:
T2      lda DDEVIC,X
        cmp #'E'
        beq T3
        inx
        inx
        inx
        cpx #$3B
        bcc T2
* E: not found => Self Test
        jmp SELFSV
* update HATABS access
T3      inx
        stx DIORA1+1
        stx DIORA2+3
        stx DIORA3+3
        inx
        stx DIOREP+1
* move KRESET to DOSINI
        jsr MOV_CAL
  dta h(MC_movE+KRESET),l(KRESET),h(MC_2+DOSINI),l(DOSINI)
* print BW-DOS version
        jsr CPC192
        dta b($0B)
        dta a(TNADP,T6BUF-TNADP)
* execute STARTUP.BAT
        jmp LBUF
KRESET  dta a(RESET)
TNADP   dta b($9B)
        dta c'BW-DOS 1.4',l(BW_DOSK),c' BEWESOFT 09-12-2023'
        dta b($9B)
T6BUF   equ *

* buffer addresses $0E0B-$0F4B ($141 Bytes)
SRCHNAM equ DAT_DEF
RENNAM  equ SRCHNAM+11
DIRBUF  equ RENNAM+11
L0E26   equ DAT_DEF+$1B
L0E32   equ DAT_DEF+$27
FCBIOCB equ DAT_DEF+$2D
FCBDRIV equ DAT_DEF+$2E
FCBSECT equ DAT_DEF+$2F
L0E3B   equ DAT_DEF+$30
FCBIX   equ DAT_DEF+$31
FCBMAP  equ DAT_DEF+$32
FCBMAPX equ DAT_DEF+$34
FCBPOS  equ DAT_DEF+$35
L0E41   equ DAT_DEF+$36
L0E42   equ DAT_DEF+$37
FCB1ST  equ DAT_DEF+$38
FCBLEN  equ DAT_DEF+$3A
FCBAUX1 equ DAT_DEF+$3D
FCBDIR1 equ DAT_DEF+$3E
FCBDIRP equ DAT_DEF+$40
L0E4D   equ DAT_DEF+$42
L0E51   equ DAT_DEF+$46
L0E52   equ DAT_DEF+$47
DLOPF   equ DAT_DEF+$48
DCBDRIV equ DAT_DEF+$4A
DCBMAIN equ DAT_DEF+$4B
L0E58   equ DAT_DEF+$4D
DCBFREE equ DAT_DEF+$4F
L0E5D   equ DAT_DEF+$52
L0E5F   equ DAT_DEF+$54
L0E61   equ DAT_DEF+$56
DCBVOL  equ DAT_DEF+$58
L0E67   equ DAT_DEF+$5C
DCBSEQ  equ DAT_DEF+$60
L0E6D   equ DAT_DEF+$62
FCBS    equ DAT_DEF+$CC
L0ED8   equ DAT_DEF+$CD

L0F15   equ DAT_DEF+$10A
L0F38   equ DAT_DEF+$12D
BUFDRIV equ DAT_DEF+$135
L0F43   equ DAT_DEF+$138
L0F46   equ DAT_DEF+$13B
L0F49   equ DAT_DEF+$13E
