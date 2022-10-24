* Fuji APE Clock red-only driver

        icl '_SYSEQU'
        blk dos $3000

reabeg  equ *
* start and new DOSINI
VDOSINI jsr start
real001 lda #<reaend
        sta MEMLO
reah001 lda #>reaend
        sta MEMLO+1
        rts
* set DCB and call SIO
GETTD   ldx #$0b
nxtsiod lda siodata,X
        sta DDEVIC,X
        dex
        bpl nxtsiod
        jmp BW_SIO
* DCB data for Fuji APE GETTIME
siodata dta b($45,$01)  ; APETIME device and unit
        dta b($93)      ; Command GETTIME
        dta b($40)      ; status
        dta a(BW_DATER) ; buffer for date time
        dta b($0f)      ; time out 15s
        dta b($00)      ; unused
        dta a($06)      ; buffer size
itdtr   dta b($00)      ; AUX1 and iter for DATER
itprn   dta b($00)      ; AUX2 and iter for print
reaend  equ *

start   jsr _print
        dta c'APE TD 1.0 ',b($00)
        jsr _chkbwdos14
* clear DECIN
        lda #$00
        ldx #$03
clrdcin sta BW_DECIN,X
        dex
        bpl clrdcin
* get date time
        jsr GETTD
        bpl realloc
* error no response
        sty BW_DECIN
        jsr CONVDC
        ldx #$02
nxterrc lda BW_DECOUT+5,X
        sta errcode,X
        dex
        bpl nxterrc
        jsr _print
        dta c'no response',b($9b,$9b)
        dta c'ERROR '
errcode dta c'xxx',b($9b,$00)
        jmp BW_COMTAB
* realloc driver
* set old DOSINI call back
realloc lda DOSINI
        sta VDOSINI+1
        lda DOSINI+1
        sta VDOSINI+2
* set new DOSINI and MEMLO
        clc
        lda MEMLO
        sta DOSINI
        sta reaadr+1
        adc <reaend-reabeg
        sta real001+1
        lda MEMLO+1
        sta DOSINI+1
        sta reaadr+2
        adc #$00
        sta reah001+1
* set GETTD
        clc
        lda MEMLO
        adc <GETTD-reabeg
        sta BW_GETTD
        lda MEMLO+1
        adc #$00
        sta BW_GETTD+1
* realloc siodata
        clc
        lda MEMLO
        adc <siodata-reabeg
        sta nxtsiod+1
        lda MEMLO+1
        adc #$00
        sta nxtsiod+2
* copy driver to MEMLO
        ldx <reaend-reabeg
nxtreal lda VDOSINI,X
reaadr  sta $FFFF,X
        dex
        bpl nxtreal
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
td_out  dta c'dd-mm-yy hh:mm:ss',b($9b,$00)
        rts

* vector for CONVDC
CONVDC  jmp (BW_CONVDC)
        icl '_PRINT'
        icl '_CHKBWD14'
        end