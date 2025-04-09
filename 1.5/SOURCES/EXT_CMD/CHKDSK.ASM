* CHKDSK for SpartaDOS 16k

* System equates
            icl '_SYSEQU.ICL'

* SparataDOS equates
SD_CONVDC   equ $070A
* CHKDSK buffer layout
CHKBUF_V    equ CHKBUF     ; fs version
CHKBUF_SS   equ CHKBUF+1   ; sector size
CHKBUF_SC   equ CHKBUF+2   ; sector count
CHKBUF_SF   equ CHKBUF+4   ; sector free
CHKBUF_NAM  equ CHKBUF+6   ; volume name
CHKBUF_SN   equ CHKBUF+14  ; sequence number
CHKBUF_RN   equ CHKBUF+15  ; random number

* Code equates
DECOUT_V    equ $0080
CHAR_V      equ $0082
CHAR_CNT    equ $0084

* Start of code
            blk dos $3000
            icl '_TSTBW15.ICL'
* set CRNAME
            lda DOSVEC
            clc
            adc #$03
            sta CRNAME+1
            lda DOSVEC+1
            adc #$00
            sta CRNAME+2
* set DECOUT
            lda DOSVEC
            sec
            sbc #$13
            sta DECOUT_V
            lda DOSVEC+1
            sbc #$00
            sta DECOUT_V+1
* check parameter
next        jsr CRNAME
            jsr close_1
* call CIO chkdsk
            ldx #$10
            lda #$2F ; CHKDSK
            sta IOCB0+ICCOM,X
            lda DOSVEC
            clc
            adc #$21 ; COMFNAM
            sta IOCB0+ICBAL,X
            lda DOSVEC+1
            adc #$00
            sta IOCB0+ICBAH,X
            lda <CHKBUF
            sta IOCB0+ICBLL,X
            lda >CHKBUF
            sta IOCB0+ICBLH,X
            jsr CIOV
            bpl chkdsk_ok
            jmp error_exit
* print CHKDSK data
chkdsk_ok   jsr _print
            dta b($9B)
            dta c'     Volume: '
            dta b($00)
* volume name
            ldy <CHKBUF_NAM
            ldx >CHKBUF_NAM
            lda #$08
            jsr prn_chars
* sequence number
            lda CHKBUF_SN
            jsr convh2a
            stx seq_num
            sty seq_num+1
* random number
            lda CHKBUF_RN
            jsr convh2a
            stx rnd_num
            sty rnd_num+1
* FS version
            lda CHKBUF_V
            jsr convh2a
            stx fs_vers
            sty fs_vers+2
            jsr _print
            dta c' '
seq_num     dta c'xx '
rnd_num     dta c'yy'
            dta b($9B)
            dta c'    Version: '
fs_vers     dta c'x.y'
            dta b($9B)
            dta c'Sector size:'
            dta b($00)
* sector size
            ldx #$00
            lda CHKBUF_SS
            bne ss_not_256
            inx
ss_not_256  jsr prn_decax
* total bytes
            jsr _print
            dta c' bytes',b($9B)
            dta c'   Capacity: '
            dta b($00)
            ldy <CHKBUF_SC-CHKBUF
            jsr prn_decb
* free bytes
            jsr _print
            dta c' bytes',b($9B)
            dta c' Free space: '
            dta b($00)
            ldy <CHKBUF_SF-CHKBUF
            jsr prn_decb
            jsr _print
            dta c' bytes',b($9B,$00)
* finished
            ldx BW_BUFOFF
            lda BW_LBUF,X
            cmp #$9b
            beq *+5
            jmp next
            jmp exit
* print byte size pointed by sectors
* count in CHKBUF,Y
prn_decb    lda #$08
            pha
            lda #$00
            pha
            lda CHKBUF,Y
            tax
            lda CHKBUF+1,Y
            ldy #$00
            bit CHKBUF_SS
            bpl prn_decay
            lsr @
            pha
            txa
            ror @
            tax
            tya
            ror @
            tay
            pla
            jmp prn_decay

* SpartaDOS Convert Decimal
CONVDC      jmp (SD_CONVDC)

* print
prn_deca    ldx #$00
prn_decax   tay
            lda #$04
            pha
            pha
            lda #$00
prn_decay   pha
            tya
            ldy #$0D ; DECIN
            sta (DECOUT_V),Y
            iny
            txa
            sta (DECOUT_V),Y
            iny
            pla
            sta (DECOUT_V),Y
            jsr CONVDC
            pla
            clc
            adc DECOUT_V
            tay
            lda #$00
            adc DECOUT_V+1
            tax
            pla
* print A chars pointed by X/Y
prn_chars   sty CHAR_V
            stx CHAR_V+1
            sta CHAR_CNT
prn_loop    ldy #$00
            lda (CHAR_V),Y
            jsr _putc
            inc CHAR_V
            bne prn_noh
            inc CHAR_V+1
prn_noh     dec CHAR_CNT
            bne prn_loop
exe_rts     rts

* convert hex to atascii A ->XY
convh2a     pha
            lsr @
            lsr @
            lsr @
            lsr @
            sed
            clc
            adc #$90
            adc #$40
            tax
            pla
            and #$0f
            clc
            adc #$90
            adc #$40
            tay
            cld
            rts

* call CRNAME
CRNAME      jmp exe_rts

* error exit routine
error_exit  tya
            pha
* print error number
            jsr _print
            dta b($9B)
            dta c'Error'
            dta b($00)
            pla
            jsr prn_deca
            lda #$9B
            jsr _putc
* set XDIVIO
            ldy #$08
            lda (DOSVEC),Y
            sta XDIVIO+1
            iny
            lda (DOSVEC),Y
            sta XDIVIO+2
* XDIVIO for batch
            ldy #$01
XDIVIO      jsr WARMSV
* exit to DOS
exit        jsr close_1
            jmp (DOSVEC)
* close IOCB 1
close_1     ldx #$10
            lda #$0C ; close
            sta IOCB0+ICCOM,X
            jmp CIOV

            icl '_PRINT.ICL'

* buffer for CIO checkdsk result (17 Bytes)
CHKBUF      equ *

            end
