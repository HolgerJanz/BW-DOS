* IDE+2 Clock driver

        icl '_SYSEQU.ICL'

* init with 0
RFLAG   equ $80 ;flag read-only
SFLAG   equ $81 ;flag use startup MEMLO
ITDTR   equ $82 ;iterator for DATER
ITPRN   equ $83 ;iterator for print

OMEML   equ $84 ;old MENLO
NMEML   equ $86 ;new MEMLO
AGETT   equ $88 ;address GETTD
ASETT   equ $8A ;address SETTD
LDRVP   equ $8C ; length of driver part (without init part)

PDCKSM  equ $D800 ;PBI ROM check sum
PIDERTC equ $D840 ;IDE+2 = 'RTC'

* init IDE clock
IDETDIN equ $D843
* get IDE time date
IDEGTD  equ $D84C
* set IDE time date
IDESTD  equ $D84F

        blk dos $3000
        jsr _print
        dta b($9b),c'IDE+2 TD 1.4 ',b($00)
        jsr _chkbwdos14
* init variables
        lda #$00
        ldx #$03
        sta RFLAG,X
        dex
        bpl *-3
        lda #'M'
        sta sta_dyn
* check parameter
        jsr BW_CRNAME
        beq paramok
        ldx #$02
parchk  lda BW_COMFNAM+3,X
        cmp PARAM,X
        bne paramer
        dex
        bpl parchk
        lda #$ff
        sta RFLAG
        jsr BW_CRNAME
        beq paramok
paramer lda #$9c ; Parameter error
        bne errext
* clear DECIN
paramok lda #$00
        ldx #$03
        sta BW_DECIN,X
        dex
        bpl *-4
* check PBI for IDE+2 clock
        lda #$01
loopid  sta PDVS
        ldx PDCKSM
        cpx #$28
        bne nextid
        ldx PDCKSM+1
        cpx #$07
        bne nextid
        ldx PIDERTC
        cpx #'R'
        bne nextid
        ldx PIDERTC+1
        cpx #'T'
        bne nextid
        ldx PIDERTC+2
        cpx #'C'
        bne nextid
        beq initrtc
nextid  inc pbi_nr
        asl @
        bne loopid
* IDE+2 not found
        lda SHPDVS
        sta PDVS
        lda #$8A ; Device does not respond

* error handler
errext  pha
        lda #$9b
        jsr _putc
        pla
        jmp (BW_FAIL)

* init clock and read
initrtc sta setpbi1+1 ; set PBID
        sta setpbi2+1
        jsr IDETDIN
        lda <BW_DATER
        ldx >BW_DATER
        jsr IDEGTD
        lda SHPDVS
        sta PDVS
* check for start up MEMLO and use stat or dyn hdl
        lda BW_SMEMLO
        cmp MEMLO
        bne insdrv
        lda BW_SMEMLO+1
        cmp MEMLO+1
        bne insdrv
        lda #$ff
        sta SFLAG
        lda #'S'
        sta sta_dyn

* install driver
* set old OMEML and init NMEML
insdrv  lda MEMLO
        sta OMEML
        sta NMEML
        lda MEMLO+1
        sta OMEML+1
        sta NMEML+1
* check for ini part
        lda SFLAG
        bne noini
        clc
        lda NMEML
        adc <reainie-reainib
        sta NMEML
        lda NMEML+1
        adc #$00
        sta NMEML+1
* set AGETT/ASETT
noini   lda NMEML
        sta AGETT
        sta ASETT
        lda NMEML+1
        sta AGETT+1
        sta ASETT+1
        clc
        lda ASETT
        adc <SETTD-GETTD
        sta ASETT
        lda ASETT+1
        adc #$00
        sta ASETT+1
* set NMEML
        lda RFLAG
        beq *+6
        lda <rearode-rearodb
        bne *+4
        lda <reawrde-reawrdb
        sta LDRVP
        clc
        lda NMEML
        adc LDRVP
        sta NMEML
        lda NMEML+1
        adc #$00
        sta NMEML+1
* set init part (maybe not needed)
        lda DOSINI
        sta VDOSINI+1
        lda DOSINI+1
        sta VDOSINI+2
        lda NMEML
        sta nmemlol+1
        lda NMEML+1
        sta nmemloh+1
* now copy ini driver
        ldy #$00
        lda SFLAG
        bne noinid
nextinp lda reainib,Y
        sta (OMEML),Y
        iny
        cpy <reainie-reainib
        bcc nextinp
* now copy set(get) driver
noinid  ldx #$00
        lda RFLAG
        bne cprop
nextwrp lda reawrdb,X
        sta (OMEML),Y
        iny
        inx
        cpx <reawrde-reawrdb
        bcc nextwrp
        bcs setini
cprop   lda rearodb,X
        sta (OMEML),Y
        iny
        inx
        cpx <rearode-rearodb
        bcc cprop
* set DOSINI or BW_MEMLO
setini  lda SFLAG
        bne setbwme
        lda OMEML
        sta DOSINI
        lda OMEML+1
        sta DOSINI+1
        jmp setmeml
setbwme lda NMEML
        sta BW_SMEMLO
        lda NMEML+1
        sta BW_SMEMLO+1
* set MEMLO to new MEMLO
setmeml lda NMEML
        sta MEMLO
        lda NMEML+1
        sta MEMLO+1
* set GETTD (SETTD)
        lda AGETT
        sta BW_GETTD
        lda AGETT+1
        sta BW_GETTD+1
        lda RFLAG
        bne nxtout
        lda ASETT
        sta BW_SETTD
        lda ASETT+1
        sta BW_SETTD+1

* print current date time
* convert date time to atascii
nxtout  ldx ITDTR
        lda BW_DATER,X
        sta BW_DECIN
        jsr CONVDC
        ldx ITPRN
        lda BW_DECOUT+6
        cmp #' '
        bne *+4
        lda #'0'
        sta td_out,X
        inx
        lda BW_DECOUT+7
        sta td_out,X
        inx
        inx
        stx ITPRN
        inc ITDTR
        cpx #$12
        bcc nxtout
* print date time
        jsr _print
        dta c'PBI#'
pbi_nr  dta c'0 '
td_out  dta c'dd-mm-yy hh:mm:ss '
sta_dyn dta c'x',b($9b,$00)
        rts

* vector for CONVDC
CONVDC  jmp (BW_CONVDC)

PARAM   dta c'/R',b($9b)

* reloc driver
reainib equ *
* set MEMLO and DOSINI
VDOSINI jsr COLDSV
nmemlol lda #$FF
        sta MEMLO
nmemloh lda #$FF
        sta MEMLO+1
        rts
reainie equ *

* Read-Only Driver
rearodb equ *
setpbi1 equ *
        lda #$00
        sta PDVS
        lda <BW_DATER
        ldx >BW_DATER
        jsr IDEGTD
        lda SHPDVS
        sta PDVS
        rts
rearode equ *

* Read-Write Driver
reawrdb equ *
GETTD   clc
        dta b($24) ; BIT zp
SETTD   sec
setpbi2 lda #$00
        sta PDVS
        lda <BW_DATER
        ldx >BW_DATER
        bcs *+7
        jsr IDEGTD
*        clc IDEGTD returns with C cleared
        bcc *+5
        jsr IDESTD
        lda SHPDVS
        sta PDVS
        rts
reawrde equ *

        icl '_PRINT.ICL'
        icl '_CHKBW14.ICL'

        end
