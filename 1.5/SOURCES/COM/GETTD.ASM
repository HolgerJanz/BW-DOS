; Print Current Date time
        icl '_SYSEQU.ICL'

        blk dos $580
        icl '_TSTBW15.ICL'
        jsr GETTD

        lda #0
        sta BW_DECIN+1
        sta BW_DECIN+2

; day, year, hour, minute, second
        ldx <idxprn-idxtd-1
        stx itdtr
nxtout  ldx itdtr
        ldy idxtd,X
        lda BW_DATER,Y
        sta BW_DECIN
        jsr CONVDC
        ldx itdtr
        ldy idxprn,X
        lda BW_DECOUT+6
        cmp #' '
        bne *+4
        lda #'0'
        sta td_out,Y
        lda BW_DECOUT+7
        sta td_out+1,Y
        dec itdtr
        bpl nxtout

; weekday
        lda BW_DATER+2
        lsr @
        lsr @
        clc
        adc BW_DATER+2
        adc #6-1 ; 01.01.00 Saturday
        adc BW_DATER
        ldx BW_DATER+1
        adc monthOf-1,X
        sta weekDay
; no leap year
        lda BW_DATER+2
        and #$03
        bne noLeap
; before March
        cpx #$03
        bcc bfMrch
noLeap  inc weekDay
; mod 8
bfMrch  lda weekDay
mod7lp  cmp #$08
        bcc wdReady
        sbc #$07
        bcs mod7lp
wdReady tax
        lda day1-1,X
        sta td_out+1
        lda day2-1,X
        sta td_out+2
        lda day3-1,X
        sta td_out+3

; month
        ldx BW_DATER+1
        lda month1-1,X
        sta td_out+8
        lda month2-1,X
        sta td_out+9
        lda month3-1,X
        sta td_out+10

; print
        lda #$0B
        sta IOCB0+ICCOM
        lda <td_out
        sta IOCB0+ICBAL
        lda >td_out
        sta IOCB0+ICBAH
        lda <idxtd-td_out
        sta IOCB0+ICBLL
        ldx #$00
        stx IOCB0+ICBLH
        jmp CIOV

td_out  dta b($9b),c'ddd dd-mmm-20yy hh:mm:ss',b($9b)
idxtd   dta b(00,02,03,04,05)
idxprn  dta b(05,14,17,20,23)

itdtr   dta b($00)

monthOf dta b($00,$03,$03,$06,$01,$04)
        dta b($06,$02,$05,$00,$03,$05)

month1  dta c'JFMAMJJASOND'
month2  dta c'aeapauuuecoe'
month3  dta c'nbrrynlgptvc'

weekDay dta b(0)

day1    dta c'MTWTFSS'
day2    dta c'ouehrau'
day3    dta c'neduitn'

GETTD   jmp (BW_GETTD)
CONVDC  jmp (BW_CONVDC)

        end

