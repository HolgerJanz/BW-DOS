* IDE+2 get and set PBI ID

        icl '_SYSEQU.ICL'

* PBI ROM check sum
PDCKSM  equ $D800
* IDE+2 = 'RTC'
PIDERTC equ $D840
* IDE+2 control
IDECTRL equ $D1FA

        blk dos $3000
        jsr _chkbwdos14
* check for IDE+2
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
        beq prnid
nextid  inc pbi_id
        asl
        bne loopid
* IDE+2 not found, restore PBI
        lda SHPDVS
        sta PDVS
        jsr _print
        dta b($9b),c'IDE+2 not found',b($9b,$00)
        rts

* IDE+2 found, restore PBI
prnid   lda SHPDVS
        sta PDVS
        jsr _print
        dta b($9b),c'IDE+2 on PBI#'
pbi_id  dta c'0',b($9b,$00)
* check parameter
        ldx BW_BUFOFF
        lda BW_LBUF,X
        lda #$9b
        cmp BW_LBUF,X
        beq finish
        cmp BW_LBUF+2,X
        bne parerr
        lda BW_LBUF+1,X
        cmp #'0'-1
        bcc parerr
        cmp #'7'+1
        bcs parerr
        and #$07
        sta setid+1
        clc
        adc #'0'
        sta new_id
* question
        jsr _print
        dta c'Set PBI#'
new_id  dta c'0 ? (Y/N)',b($9b,$00)
        lda CH
        cmp #$FF
        beq *-5
        cmp #$2B
        bne finish
* set PBI ID
        sei
        lda #$00
        sta NMIEN
        lda IDECTRL
        and #$78
setid   ora #$04
        ldx #$80
        stx WSYNC
        stx IDECTRL
        sta IDECTRL
        lda #$40
        sta NMIEN
        cli
        jmp COLDSV
finish  lda #$FF
        sta CH
        rts

parerr  jsr _print
        dta b($9b),c'Vers 06-02-2023',b($9b)
        dta c'Usage: IDESETID [0-7]',b($9b,$00)
        lda #$9c
        jmp (BW_FAIL)

        icl '_PRINT.ICL'
        icl '_CHKBW14.ICL'

        end
