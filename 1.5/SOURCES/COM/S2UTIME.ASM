* Set Clock Using SIO2USB Clock
        icl '_SYSEQU.ICL'

        blk dos $500
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
        bpl convclk
* error no response
        tya
        jmp (BW_FAIL)
* check buffer
        lda siobuf
        cmp #6
        bne siober
        lda siobuf+7
        cmp #$FF
        beq convclk
siober  lda #$91 ; verify error
        jmp (BW_FAIL)
* conv clock
convclk ldx #5
convLp  ldy RMAP,X
        lda siobuf+1,Y
        pha
        lsr @
        lsr @
        lsr @
        lsr @
        tay
        pla
        and #$0F
        clc
        adc HEX2DEC,Y
        sta BW_DATER,X
        dex
        bpl convLp
* set clock
        jsr SETTD
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
        dta b($9b),c'SIO2USB Time 1.5 '
td_out  dta c'dd-mm-yy hh:mm:ss',b($9b,$00)
        rts
* vector for CONVDC
CONVDC  jmp (BW_CONVDC)
* vector set date/time
SETTD   jmp (BW_SETTD)

RMAP    dta b($03,$04,$05,$02,$01,$00)
HEX2DEC dta b(0,10,20,30,40,50,60,70,80,90)

        icl '_PRINT.ICL'

* DCB data for Fuji APE GETTIME
siodata dta b($71,$00)  ; SIO2USB device and unit
        dta b($02)      ; Command GETTIME
        dta b($40)      ; status
        dta a(siobuf)   ; buffer for date time
        dta b($07)      ; time out 15s
        dta b($00)      ; unused
        dta a($80)      ; buffer size
        dta b($00)      ; AUX1
        dta b($00)      ; AUX2
itdtr   dta b($00)      ; iter for DATER
itprn   dta b($00)      ; iter for print

siobuf  equ *           ; SIO buffer 128 bytes

        end
