* Set Clock Using APE Clock
        icl '_SYSEQU.ICL'

        blk dos $580
        icl '_TSTBW15.ICL'
* clear DECIN
        lda #$00
        ldx #$03
clrdcin sta BW_DECIN,X
        dex
        bpl clrdcin
* set DCB and call SIO
        ldx #$0b
nxtsiod lda siodata,X
        sta DDEVIC,X
        dex
        bpl nxtsiod
        jsr BW_SIO
        bpl setclck
* error no response
        tya
        jmp (BW_FAIL)
* set clock
setclck jsr SETTD
* print current date time
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
        dta b($9b),c'APE Time 1.3 '
td_out  dta c'dd-mm-yy hh:mm:ss',b($9b,$00)
        rts
* vector for CONVDC
CONVDC  jmp (BW_CONVDC)
* vector set date/time
SETTD   jmp (BW_SETTD)

        icl '_PRINT.ICL'

* DCB data for Fuji APE GETTIME
siodata dta b($45,$01)  ; APETIME device and unit
        dta b($93)      ; Command GETTIME
        dta b($40)      ; status
        dta a(BW_DATER) ; buffer for date time
        dta b($0f)      ; time out 15s
        dta b($00)      ; unused
        dta a($06)      ; buffer size
        dta b($EE)      ; AUX1
        dta b($A0)      ; AUX2
itdtr   dta b($00)      ; iter for DATER
itprn   dta b($00)      ; iter for print

        end
