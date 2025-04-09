* BW-DOS Command VERIFY [ON|OFF]

        icl '_SYSEQU.ICL'

        blk dos $580
        icl '_TSTBW15.ICL'
        jsr BW_CRNAME
        beq prntver

        ldy #$03
        lda BW_COMFNAM,Y
        cmp #'O'
        bne badpar

        iny
        lda BW_COMFNAM,Y
        iny

        ldx #'W' ;verify on

        cmp #'N'
        beq veron
        cmp #'F'
        bne badpar
* off?
        cmp BW_COMFNAM,Y
        bne badpar
        iny

        ldx #'P' ;verify off

veron   lda BW_COMFNAM,Y
        cmp #$9b
        bne badpar

        stx BW_WRTCMD

prntver lda BW_WRTCMD
        cmp #'P'
        bne veron2
        lda #'f'
        sta msgx
        sta msgx+1

veron2  lda #$0b
        sta $342
        lda <msg
        sta $344
        lda >msg
        sta $345
        lda <msge-msg
        sta $348
        ldx #$00
        stx $349
        jmp CIOV

badpar  lda #$9C
        jmp (BW_FAIL)

msg     dta b($9b),c'Verify o'
msgx    dta c'n ',b($9b)
msge    equ *

        end
