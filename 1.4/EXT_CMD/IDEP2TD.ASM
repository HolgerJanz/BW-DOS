* IDE+2 Clock driver

        icl '_SYSEQU.ICL'

* PBI ROM check sum
PDCKSM  equ $D800
* IDE+2 = 'RTC'
PIDERTC equ $D840

* init IDE clock
IDETDIN equ $D843
* get IDE time date
IDEGTD  equ $D84C
* set IDE time date
IDESTD  equ $D84F

        blk dos $3000
        jsr _print
        dta b($9b),c'IDE+2 TD 1.2 ',b($00)
        jsr _chkbwdos14
* clear DECIN
        lda #$00
        ldx #$03
        sta BW_DECIN,X
        dex
        bpl *-4
* check for IDE+2 clock
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
        asl
        bne loopid
* IDE+2 not found
        lda SHPDVS
        sta PDVS
        jsr _print
        dta c'not found',b($9b,$00)
        rts

* init clock and read
initrtc sta setpbid+1 ; set ID
        jsr IDETDIN
        lda <BW_DATER
        ldx >BW_DATER
        jsr IDEGTD
        lda SHPDVS
        sta PDVS
* set old DOSINI call back
        lda DOSINI
        sta VDOSINI+1
        lda DOSINI+1
        sta VDOSINI+2
* set new DOSINI and MEMLO
        clc
        lda MEMLO
        sta DOSINI
        sta reaadr+1
        adc <reaend-reabeg
        sta nmemlol+1
        lda MEMLO+1
        sta DOSINI+1
        sta reaadr+2
        adc #$00
        sta nmemloh+1
* set GETTD
        clc
        lda MEMLO
        adc <GETTD-reabeg
        sta BW_GETTD
        lda MEMLO+1
        adc #$00
        sta BW_GETTD+1
* set SETTD
        clc
        lda MEMLO
        adc <SETTD-reabeg
        sta BW_SETTD
        lda MEMLO+1
        adc #$00
        sta BW_SETTD+1
* copy driver to MEMLO
        ldx <reaend-reabeg
nxtreal lda VDOSINI,X
reaadr  sta $FFFF,X
        dex
        bpl nxtreal
* set new MEMLO
        jsr nmemlol
* print current date time
* convert date time to atascii
nxtout  ldx itdtr
        lda BW_DATER,X
        sta BW_DECIN
        jsr CONVDC
        ldx itprn
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
        stx itprn
        inc itdtr
        cpx #$12
        bcc nxtout
* print date time
        jsr _print
        dta c'PBI#'
pbi_nr  dta c'0 '
td_out  dta c'dd-mm-yy hh:mm:ss',b($9b,$00)
        rts

* iterator for DATER
itdtr   dta b($00)
* iterator for print
itprn   dta b($00)

* reloc driver
reabeg  equ *
* start and new DOSINI
VDOSINI jsr $FFFF
nmemlol lda #$FF
        sta MEMLO
nmemloh lda #$FF
        sta MEMLO+1
        rts
* set DCB and call SIO
GETTD   clc
        bcc *+3
SETTD   sec
setpbid lda #$00
        sta PDVS
        lda <BW_DATER
        ldx >BW_DATER
        bcs *+8
        jsr IDEGTD
        clc
        bcc *+5
        jsr IDESTD
        lda SHPDVS
        sta PDVS
        rts
reaend  equ *

* vector for CONVDC
CONVDC  jmp (BW_CONVDC)

        icl '_PRINT.ICL'
        icl '_CHKBW14.ICL'

        end