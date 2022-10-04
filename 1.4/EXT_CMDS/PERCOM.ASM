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
ZP_CNT      equ $0080

* Start of code
            blk dos $2800
            jsr _chkbwdos14
* get parameter
            jsr BW_CRNAME
* call PERCOM read
            lda #$31
            sta DDEVIC
            lda BW_COMFNAM+1
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
            jsr BW_SIO
            bpl percom_ok
            tya
            jmp (BW_FAIL)

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

            jmp (DOSVEC)

* print decimals
prn_deca    ldx #$00
prn_decax   ldy #$00 
            sta BW_DECIN,Y
            iny
            txa
            sta BW_DECIN,Y
            iny
            lda #$00
            sta BW_DECIN,Y
            jsr CONVDC
            ldy #$00
            sty ZP_CNT
nxt_digit   lda BW_DECOUT,Y
            cmp #' '
            beq is_space
            jsr _putc
is_space    inc ZP_CNT
            ldy ZP_CNT
            cpy #8
            bne nxt_digit
            rts
CONVDC      jmp (BW_CONVDC)

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
            rts

            icl '_PRINT.ASM'
            icl '_CHKBWD14.ASM'

* buffer for PERCOM (12 Bytes)
PERCOM_BUF  equ *

            end
