* Print Current Date time
        icl '_SYSEQU.ICL'

        blk dos $580
        icl '_TSTBW15.ICL'
        jsr GETTD

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
        jsr _print
        dta b($9b)
td_out  dta c'dd-mm-yy hh:mm:ss',b($9b,$00)
        rts

itdtr   dta b($00)
itprn   dta b($00)

GETTD   jmp (BW_GETTD)
CONVDC  jmp (BW_CONVDC)

        icl '_PRINT.ICL'

        end

