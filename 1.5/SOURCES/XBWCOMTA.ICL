* COMTAB page $700

        dta c'S'       ;$700 the character "S" for SpartaDOS
        dta b($32)     ;$701 version, compatible with SpartaDOS 3.2
        dta b($00)     ;$702 subversion e.g. SDX 4.49 => $09
        dta c'BW'      ;$703 "BW", if BW-DOS is installed
        dta b($15)     ;$705 BW-DOS version 1.5 
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
SMEMLO  dta a(END_ADR) ; +30 start up MEMLO
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
DOSDRV  dta b(1)
EXT_BAT dta c'.BAT'
        dta b($9B)
EXT_COM dta c'.COM'
        dta b($9B)
STD_PAT dta c'*.*'
        dta b($9B)

* default TD
INTDATE dta b(INI_DAY,INI_MONTH,INI_YEAR)
        dta b(INI_HOUR,INI_MINUTE,INI_SECOND)

ETAB    dta a(0,0)
EGETV   dta a(0)
EPUTV   dta a(0)
        dta a(0,0)

* $7CB DFMSDH entry point for HATAB for D:
DTABLE  dta a(DOPEN_V)
        dta a(DCLOSE_V)
        dta a(DGET_V)
        dta a(DPUT_V)
        dta a(DSTAT_V)
        dta a(DSPEC_V)
RINIT   jmp (DOSINI)
        dta b(0)
* HATAB entry for disk drive device
RESITAB dta c'D',a(DTABLE)

        dta b(0,0) ; spare bytes

* $7E0 DINT initialize BW-DOS
        jmp RESET

DAT_BUF equ *
DIRVOL  dta b($9B)
        dta c'Volume'
PERIOD  dta c':'
DIRNAM  dta c'           '      ; 11 Bytes
DIBUF   dta c'                '
        dta c'                '
        dta c'         ' ; 41 Bytes

DLDIR   dta b($9B)
        dta c'Dir:'
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
        dta c'BW-DOS 1.5 by JB/HJX 06-11-2024 ',b(BW_DK1,BW_DK2)
        dta b($9B)
T6BUF   equ *

* buffer addresses $0E0B-$0F4B ($141 Bytes)
SRCHNAM equ DAT_DEF
RENNAM  equ SRCHNAM+11
DIRBUF  equ RENNAM+11

FCBIOCB equ DAT_DEF+$2D
FCBDRIV equ DAT_DEF+$2E
FCBSECT equ DAT_DEF+$2F
FCBIX   equ DAT_DEF+$31
FCBMAP  equ DAT_DEF+$32
FCBMAPX equ DAT_DEF+$34
FCBPOS  equ DAT_DEF+$35
FCB1ST  equ DAT_DEF+$38
FCBLEN  equ DAT_DEF+$3A
FCBAUX1 equ DAT_DEF+$3D
FCBDIR1 equ DAT_DEF+$3E
FCBDIRP equ DAT_DEF+$40
LDSALEN equ DAT_DEF+$46
DLOPF   equ DAT_DEF+$48
DCBDRIV equ DAT_DEF+$4A
DCBMAIN equ DAT_DEF+$4B
DCBFREE equ DAT_DEF+$4F
DCBMAP1 equ DAT_DEF+$52
DCBDAT  equ DAT_DEF+$54
DCBDIR  equ DAT_DEF+$56
DCBVOL  equ DAT_DEF+$58
DCBSEQ  equ DAT_DEF+$60
DCBWD   equ DAT_DEF+$62
FCBS    equ DAT_DEF+$CC

BUFDRIV equ DAT_DEF+$135
BUFSECL equ DAT_DEF+$138
BUFSECH equ DAT_DEF+$13B
BUFTIME equ DAT_DEF+$13E
