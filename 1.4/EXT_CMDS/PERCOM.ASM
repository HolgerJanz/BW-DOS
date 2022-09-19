* PERCOM for SpartaDOS 16k

* System equates
            icl '_SYSEQU.ASM'

* PERCOM buffer layout
PC_SIDES    equ PERCOM_BUF+4 ; Sides-1
PC_TRACKS   equ PERCOM_BUF+0 ; Tracks/side
PC_SECTORS  equ PERCOM_BUF+2 ; Sectors/track
PC_BYTES    equ PERCOM_BUF+6 ; Bytes/sector
PC_STEPPING equ PERCOM_BUF+1 ; Stepping rate

PC_FLAGS    equ PERCOM_BUF+5 ; Flags byte
PC_CONTROL  equ PERCOM_BUF+8 ; Control byte
PC_MISC     equ PERCOM_BUF+9 ; Misc bytes

* Code equates
DECOUT_V    equ $0080
ZP_CNT      equ $0082

* Start of code
            blk dos $2800
            jsr _chkbwdos
* set CRNAME
            lda DOSVEC
            clc
            adc #BW_CRNAME
            sta CRNAME+1
            lda DOSVEC+1
            adc #$00
            sta CRNAME+2
* set DECOUT
            lda DOSVEC
            sec
            sbc #BW_DECOUT
            sta DECOUT_V
            lda DOSVEC+1
            sbc #$00
            sta DECOUT_V+1
* set LSIO
            lda DOSVEC
            sec
            sbc #BW_LSIO
            sta LSIO+1
            lda DOSVEC+1
            sbc #$00
            sta LSIO+2
* get parameter
            jsr CRNAME

* call PERCOM read
            lda #$31
            sta DDEVIC
            ldy #BW_COMFNAM+1
            lda (DOSVEC),Y
            and #$0F
            sta DUNIT
            lda #'N'
            sta DCMND
            lda #$40
            sta DSTATS
            lda <PERCOM_BUF
            sta DBUFA
            lda >PERCOM_BUF
            sta DBUFA+1
            lda #$05
            sta DTIMLO
            lda #12
            sta DBYT
            lda #$00
            sta DBYT+1
            sta DAUX1
            sta DAUX2
            jsr LSIO
            bpl percom_ok
            jmp error_exit

* print PERCOM buffer
percom_ok   jsr _print
            dta b($9b)
            dta c' Num of sides: '
            dta b($00)
            ldx PC_SIDES
            inx
            txa
            jsr prn_deca

            jsr _print
            dta b($9b)
            dta c'  Tracks/side: '
            dta b($00)
            lda PC_TRACKS
            jsr prn_deca

            jsr _print
            dta b($9b)
            dta c'Sectors/track: '
            dta b($00)
            ldx PC_SECTORS
            lda PC_SECTORS+1
            jsr prn_decax

            jsr _print
            dta b($9b)
            dta c' Bytes/sector: '
            dta b($00)
            ldx PC_BYTES
            lda PC_BYTES+1
            jsr prn_decax

            jsr _print
            dta b($9b)
            dta c'Stepping rate: '
            dta b($00)
            lda PC_STEPPING
            jsr prn_deca

            lda #$9b
            jsr _putc

            jsr _print
            dta b($9b)
            dta c'    Flag byte: '
            dta b($00)
            lda PC_FLAGS
            jsr prn_hexa

            jsr _print
            dta b($9b)
            dta c' Control byte: '
            dta b($00)
            lda PC_CONTROL
            jsr prn_hexa

            jsr _print
            dta b($9b)
            dta c'   Misc bytes: '
            dta b($00)
            ldx #$00
            stx ZP_CNT
nxt_byte    lda PC_MISC,X
            jsr prn_hexa
            lda #' '
            jsr _putc
            inc ZP_CNT
            ldx ZP_CNT
            cpx #$03
            bne nxt_byte

            lda #$9b
            jsr _putc

            jmp exit

* BW-DOS Convert Decimal
CONVDC      jmp (BW_CONVDC)

* print decimals
prn_deca    ldx #$00
prn_decax   ldy #$0D ; DECIN
            sta (DECOUT_V),Y
            iny
            txa
            sta (DECOUT_V),Y
            iny
            lda #$00
            sta (DECOUT_V),Y
            jsr CONVDC

            ldy #$00
            sty ZP_CNT
nxt_digit   lda (DECOUT_V),Y
            cmp #' '
            beq no_space
            jsr _putc
no_space    inc ZP_CNT
            ldy ZP_CNT
            cpy #8
            bne nxt_digit
            rts

* print haxedecimals
prn_hexa    pha
            lsr @
            lsr @
            lsr @
            lsr @
            sed
            clc
            adc #$90
            adc #$40
            cld
            jsr _putc
            sed
            pla
            and #$0f
            clc
            adc #$90
            adc #$40
            cld
            jsr _putc
_rts        rts

* error exit routine
error_exit  tya
            pha
* print error number
            jsr _print
            dta b($9B)
            dta c'Error '
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
exit        jmp (DOSVEC)

* call CRNAME
CRNAME      jmp _rts

* call LSIO
LSIO        jmp ($FFFF)

            icl '_PRINT.ASM'
            icl '_CHKBWD.ASM'

* buffer for PERCOM (12 Bytes)
PERCOM_BUF  equ *

            end
