* Print Current Date time
        icl '_SYSEQU'
        blk dos $3000
        jsr _chkbwdos14
        jsr GETTD
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
itdtr   dta b($00)      ; iter for DATER
itprn   dta b($00)      ; iter for print
GETTD   jmp (BW_GETTD)
CONVDC  jmp (BW_CONVDC)
        icl '_CHKBWD14'
        icl '_PRINT'
        end

