* BW-DOS 1.31
* use Fast Assembler
* https://github.com/HolgerJanz/FastAssembler

* System equates
ICHID       equ $0000
ICDNO       equ $0001
ICCOM       equ $0002
ICSTA       equ $0003
ICBAL       equ $0004
ICBAH       equ $0005
ICPTL       equ $0006
ICPTH       equ $0007
ICBLL       equ $0008
ICBLH       equ $0009
ICAX1       equ $000A
ICAX2       equ $000B
ICAX3       equ $000C
ICAX4       equ $000D
ICAX5       equ $000E
ICAX6       equ $000F

WARMST      equ $0008
BOOT        equ $0009
DOSVEC      equ $000A
DOSINI      equ $000C

ICHIDZ      equ $0020
ICDNOZ      equ $0021
ICCOMZ      equ $0022
ICSTAZ      equ $0023
ICBALZ      equ $0024
ICBLLZ      equ $0028
ICBLHZ      equ $0029
ICAX1Z      equ $002A
ICAX2Z      equ $002B
ICAX5Z      equ $002E

RAMTOP      equ $006A

COLDST      equ $0244
RUNAD       equ $02E0
RAMSIZ      equ $02E4
MEMTOP      equ $02E5
MEMLO       equ $02E7

DDEVIC      equ $0300
DUNIT       equ $0301
DCOMND      equ $0302
DSTATS      equ $0303
DBYTLO      equ $0308
DBYTHI      equ $0309
DAUX1       equ $030A
DAUX2       equ $030B

HATABS      equ $031A
IOCB0       equ $0340
IOCB1       equ $0350
IOCB5       equ $0390

BASICF      equ $03F8

CARTCS      equ $BFFA
CART        equ $BFFC
CARTFG      equ $BFFD

PORTB       equ $D301

CIOV        equ $E456
SIOV        equ $E459
SELFSV      equ $E471

* DOS zero page
L0043       equ $0043
L0044       equ $0044
L0045       equ $0045
L0046       equ $0046
L0047       equ $0047
L0048       equ $0048
L0049       equ $0049

STACK       equ $0100

* 6502 opcodes
op_ADC_imd  equ $69
op_AND_abs  equ $29
op_BIT_abs  equ $2C
op_BIT_zp   equ $24
op_JMP_abs  equ $4C
op_SBC_imd  equ $E9

* MOVE_CALL commands
*  jsr subroutine
MC_jsr      equ $0000
*  copy inside buffer by offset
MC_cpy      equ $20
* move from address to address
MC_mov      equ $4000
*  like MC_jsr and end
MC_jsrE     equ $8000
*  like MC_cpy and end
MC_cpyE     equ $A0
*  like MC_mov and end
MC_movE     equ $C000
* length in bytes for move
MC_1        equ $2000
MC_2        equ $4000
MC_3        equ $6000
MC_4        equ $8000
MC_5        equ $A000
MC_6        equ $C000
MC_7        equ $E000

* begin address of BW-DOS
BW_BEGIN    equ $0700

            blk dos BW_BEGIN

            dta c'S'       ;$700 the character "S" for SpartaDOS
            dta b($32)     ;$701 compatibility with SpartaDOS 3.2
            dta b($00)     ;$702 ??? 
            dta c'BW'      ;$703 "BW" when BW-DOS is installed
            dta b($13)     ;$705 BW-DOS version 1.3x etc.
GETTDV      dta a(GETTD)   ;$706 Adress of the "GETTD" routine
SETTDV      dta a(SETTD)   ;$708 Adress of the "SETTD" routine
            dta a(CONVDC)  ;$70A Adress CONVDC
            jmp SSIOV      ;$70C jmp LSIO 4C EE 0C

* vector tab for commands called via RTS opcode
CMD_TAB_L   dta l(CMD_CAR_V,CMD_RUN_V,CMD_PRINT_V,CMD_TYPE_V)
            dta l(CMD_DIR_V,CMD_DIRS_V,CMD_BASIC_V)
CMD_TAB_H   dta h(CMD_CAR_V,CMD_RUN_V,CMD_PRINT_V,CMD_TYPE_V)
            dta h(CMD_DIR_V,CMD_DIRS_V,CMD_BASIC_V)

CONV_A      sta DECIN
            lda #$00
            sta DECIN+1
CONV_16     lda #$00
            sta DECIN+2
* convert digit to char
CONVDC      ldx #$07
L072C       stx L074B+1
            ldx #$18
            lda #$00
L0733       asl DECIN
            rol DECIN+1
            rol DECIN+2
            rol @
            cmp #$0A
            bcc L0746
            sbc #$0A
            inc DECIN
L0746       dex
L0747       bne L0733
            ora #$30
L074B       ldx #$00
L074D       sta DECOUT,X
            dex
            bmi L07A0
            lda DECIN
            ora DECIN+1
            ora DECIN+2
            bne L072C
            lda #$20
            bne L074D
L0762       inc BUFOFF
            dta b(op_BIT_abs)
* crunch name
_CRNAME     lda #$20
L0768       ldy BUFOFF
            ldx LBUF,Y
            cpx #$20
            beq L0762
            sta L07C7+1
            lda #$00
            sta L07BE+1
            cpx #$9B
            beq L0790
            lda LBUF+1,Y
            cmp #$9B
            beq L0790
            cmp #$3A
            beq L07A1
L0789       lda LBUF+2,Y
            cmp #':'
L078E       beq L0795
L0790       ldy #$41
            jsr L07BE
L0795       ldy BUFOFF
            jsr L07BE
            sty BUFOFF
L079E       cpx #$03
L07A0       rts

L07A1       inc L07BE+1
            jsr L0795
            lda COMFNAM+1
            sta COMFNAM
            lda #$31
            sta COMFNAM+1
            bne L079E
L07B4       sta COMFNAM,X
            cpx #$1B
            bcs L07BC
            inx
L07BC       iny
            dta b(op_BIT_abs)
L07BE       ldx #$00
            lda LBUF,Y
            cmp #$9B
            beq L07CB 
L07C7       cmp #$20
            bne L07B4
L07CB       lda #$9B
            sta COMFNAM,X
            stx L07BE+1
            rts

* HATAB for D:
L07D4       dta a(OPEN_V)
            dta a(CLOSE_V)
            dta a(GETBYTE_V)
            dta a(PUTBYTE_V)
            dta a(GETSTAT_V)
            dta a(SPECIAL_V)

DOS_INI     cld
            lda L0047
            bne L07F2
            dec L0047
            bit INCMND
            bpl L07F2
            jsr L0847
L07EF       jmp COMTAB

L07F2       jsr MOVE_CALL
  dta h(MC_mov+SMEMLO), l(SMEMLO), h(MC_2+MEMLO),  l(MEMLO)
  dta h(MC_mov+L07EF+1),l(L07EF+1),h(MC_2+DOSVEC), l(DOSVEC)
  dta h(MC_movE+L0DF2), l(L0DF2),  h(MC_2+ECHOFLG),l(ECHOFLG)

            txa
L0802       sta L0E4C,X
            cpx #$97
            bcc L080C
            dec L0E3F+1,X
L080C       inx
            bne L0802
            tay
L0810       dta b(op_BIT_abs)
L0811       ldy #$07
L0813       iny
            tya
            sta L0E55,X
            txa
            clc
L081A       adc #$1A
            tax
            cpy #$04
            bcc L0813
            beq L0811
            ldy #$1E
L0825       ldx HATABS,Y
            bne L082B
            tya
L082B       cpx #'D'
            beq L0837
            dey
            dey
            dey
            bpl L0825
            tay
            bmi L0843
L0837       ldx #$FD
L0839       lda L0844-$FD,X
L083C       sta HATABS,Y
            iny
            inx
            bne L0839
L0843       rts

L0844       dta c'D',a(L07D4)

L0847       jmp (DOSINI)

* date time buffer
DATTIMBUF   dta b(28,11,95)
            dta b(22,14,06)

* $850 set time date
SETTD       jsr MOVE_CALL
  dta h(MC_movE+DATER),l(DATER),h(MC_6+DATTIMBUF),l(DATTIMBUF)

* $857 get time data
GETTD       jsr MOVE_CALL
  dta h(MC_movE+DATTIMBUF),l(DATTIMBUF),h(MC_6+DATER),l(DATER)

_rts        rts

ADC_L       lda L1488+1
            dta b(op_BIT_abs)
ADC_1       lda #$01
            ldx #op_ADC_imd
            bne L086D
SBC_1       lda #$01
SBC_A       ldx #op_SBC_imd
L086D       sta L088A+1
            stx L088A
            ldx #$FE
L0875       jsr INC_PC
            sta L0887+1-$FE,X
            sta L088C+1-$FE,X
            inx
            bne L0875
            lda L088A
            asl @
            dex
L0886       inx
L0887       lda $FFFF,X
L088A       adc #$00
L088C       sta $FFFF,X
            stx L088A+1
            txa
            beq L0886
            rts

* command RUN
CMD_RUN     bne L089B
CMD_RUN_V   equ CMD_RUN-1
L0898       jmp (RUNLOC)

L089B       jsr MOVE_CALL
  dta h(MC_movE+L0E00),l(L0E00),h(MC_2+RUNLOC),l(RUNLOC)

L08A2       lda COMFNAM+3,X
            inx
            sec
            sbc #$30
            cmp #$0A
            bcc L08B3
            sbc #$07
            cmp #$10
            bcs L0898
L08B3       asl @
            asl @
            asl @
            asl @
            ldy #$04
L08B9       asl @
            rol RUNLOC
            rol RUNLOC+1
            dey
            bne L08B9
            beq L08A2

INC_PC      stx L08E5+1
            sty L08E7+1
            tsx
            inx
            inx
            inx
            inc $100,X
            lda $100,X
            inx
            tay
            bne L08DC
            inc $100,X
L08DC       lda $100,X
            sta L08E2+2
L08E2       lda $FF00,Y
L08E5       ldx #$00
L08E7       ldy #$00
            rts

L08EA       jsr INC_PC
            ldx #$03
            dta b(op_BIT_abs)
L08F0       ldx #$00
            pha
            and #$1F
            sta L090D+2,X
            pla
            lsr @
            lsr @
            lsr @
            lsr @
            lsr @
            sta L090A+1
            jsr INC_PC
            sta L090D+1,X
            txa
            beq L08EA
L090A       ldx #$00
L090C       dex
L090D       lda $FFFF,X
            sta $FFFF,X
            txa
            bne L090C
            tya
            bmi L0968

MOVE_CALL   jsr L0A76
L091C       jsr INC_PC
            tay
            asl @
            asl @
            php
            tya
            and #$1F
            plp
            bcs L08F0
            bmi L0949
            sta L0939+2
            jsr INC_PC
            sta L0939+1
            tya
            pha
            jsr L0942
L0939       jsr L0948
            jsr L0A76
            pla
            bpl L091C
L0942       lda #$00
            pha
L0945       lda #$00
            plp
L0948       rts

L0949       sta L0945+1
            sty L0964+1
            jsr INC_PC
            tax
            jsr INC_PC
            tay
L0957       lda DAT_BUF,X
            sta DAT_BUF,Y
            inx
            iny
            dec L0945+1
            bne L0957
L0964       lda #$00
            bpl MOVE_CALL
L0968       ldx #$00
            rts

* prepare and call CIO
DO_CIO      jsr INC_PC
            dta b(op_BIT_abs)
DO_CIO_0    lda #$C0
            dta b(op_BIT_abs)
DO_CIO_1    lda #$04
DO_CIO_A    sta L0044
            asl @
            asl @
            tax
            tay
            bcs L0989
            jsr INC_PC
            lsr @
            sta IOCB0+ICAX1,X
            lda #$00
            ror @
            sta IOCB0+ICAX2,X
L0989       lda #$67
            sta L0043
L098D       jsr INC_PC
            sta IOCB0+ICCOM,Y
L0993       iny
            asl L0043
            bcc L0993
            bne L098D
            lda L0044
            pha
            lda #$20
            jsr CIOV
            pla
            tax
            tya
            bpl L09C0
            cmp #$88
            beq L09C0
            pha
            txa
            pha
            and #$1C
            beq L09BC
            ora #$C0
            jsr DO_CIO_A
            dta b($0C)
L09B8       dta a($0000)
L09BA       dta a($0000)
L09BC       pla
            bpl PRN_ERR
            pla
L09C0       tay
            rts

* print error message
PRN_ERR     jsr DO_CIO_0
            dta b($0B)
            dta a(ERROR1,6)
            pla
            jsr CONV_A
            jsr DO_CIO_0
            dta b($0B)
            dta a(DECOUT+4,4)
            jsr DO_CIO_0
            dta b($0B)
            dta a(ERROR1,1)
            jsr L0B7C

* DOS entry
_COMTAB     cld
            jsr ext_init
            stx TDOVER
            stx BUFOFF
            dex
L09EC       stx INCMND
            txs
* close IOCB1
            jsr DO_CIO
            dta b($C4,$0C)
* ???
L09F5       dta a($0AAC,$0AC9)
* print prompt
            jsr DO_CIO_0
            dta b($0B)
            dta a(PROMPT,4)
* get command line
            jsr DO_CIO
            dta b($40,$05)
            dta a(LBUF,$40)
            jsr PARSE_LINE
            jmp _COMTAB

* Command CAR
CMD_CAR     lda CARTFG
CMD_CAR_V   equ CMD_CAR-1
            inc CARTFG
            cmp CARTFG
            sta CARTFG
            bne L0A92
            ldx CART
            bne L0A92
            lda DWARM
            sta WARMST
            stx INCMND
            dex
            stx DWARM
            jmp (CARTCS)

* toggle BASIC
L0A32       sta BASICF
            php
            jsr DO_CIO_0
            dta b($0C)
* ???
L0A3A       dta a(L0810)
L0A3C       dta a($5040)
            lda PORTB
            ror @
            ror @
            plp
L0A44       rol @
            rol @
            sta PORTB
            ldx #$CE
L0A4B       txa
            sec
            sbc #$10
            tax
            stx L0044
            eor (L0043),Y
            sta (L0043),Y
            eor (L0043),Y
            bne L0A4B
            sta MEMTOP
            inx
            inx
            stx RAMSIZ
            stx MEMTOP+1
            stx RAMTOP
            jsr DO_CIO
            dta b($80,$18,$03)
L0A6D       dta a(ERROR2)
L0A6F       dta a(0)
L0A71       ldx #$00
            stx DWARM
L0A76       sta L0945+1
            php
            pla
            sta L0942+1
            rts

* Command BASIC
CMD_BASIC   lda COMFNAM+3
CMD_BASIC_V equ CMD_BASIC-1
            cmp #'O'
            bne L0A92
            lda COMFNAM+4
            cmp #'F'
            beq L0A32
            clc
            eor #'N'
            beq L0A32
* cartridge error
L0A92       lda #$9C
L0A94       pha
            jmp PRN_ERR

L0A98       dta b($00,$00,$00,$00)
L0A9C       dta b($00,$00)
L0A9E       dta b($00,$00)
            dta b($00,$00,$00,$00)

L0AA4       jmp (L09B8)
L0AA7       jmp (L09BA)
L0AAA       jsr L0B7C
            txa
            bne L0AA4
            bit BATFLG
            bpl L0ABD
            jsr L0AA4
            cpy #$00
            bpl L0AD3
            rts

L0ABD       ldy #$01
            ldx #$05
            jsr L0CC4
            cpy #$00
            bmi L0AAA
            ldx #$00
            cpx #$00
            bne L0AA7
            pha
            jsr L0AA7
            pla
L0AD3       bit ECHOFLG
            bmi L0AEA
            pha
            ldy #$00
            ldx #$07
            jsr L0CC4
            cpy #$00 
            bpl L0AE7
            jsr L0B79
L0AE7       pla
L0AE8       ldy #$01
L0AEA       ldx #$00
            cpy #$00
L0AEE       rts

L0AEF       jsr MOVE_CALL
L0AF2 dta h(MC_mov+L0B38+1),l(L0B38+1),h(MC_2+HATABS+2),l(HATABS+2)
      dta h(MC_movE+L0A6D+2),l(L0A6D+2),h(MC_2+IOCB0+ICPTL),l(IOCB0+ICPTL)

L0AFA       beq L0AE8
R_DIVIO     jsr R_XDIVIO
L0AFF       ldy #$00
            lda L0A3A,Y
            sta L0B0D
            lda L0BE9,Y
            jsr DO_CIO_A
L0B0D       dta b($08,$03)
            dta a(COMFNAM,$1C)
            bmi L0AEE
            lda #$00
L0B17       ldy L0AFF+1
            ldx L0A3C,Y
            ora IOCB0,X
            sta ECHOFLG,Y
            lda #$FF
            sta IOCB0,X
L0B28       lda HATABS+2
            cmp #$0A
            beq L0B5A

            jsr MOVE_CALL
L0B32 dta h(MC_movE+HATABS+1),l(HATABS+1),h(MC_2+L0B38+1),l(L0B38+1)

            ldx #$0B
L0B38       lda $FFFF,X
L0B3B       sta L0A98,X
            dex
            bpl L0B38

            jsr MOVE_CALL
  dta h(MC_mov+L0A9C),l(L0A9C),h(MC_4+L09B8),l(L09B8)
  dta h(MC_mov+L0A9E),l(L0A9E),h(MC_2+L0A6F),l(L0A6F)
  dta h(MC_movE+L09F5),l(L09F5),h(MC_4+L0A9C),l(L0A9C)

            jsr ADC_1
            dta a(L09B8)

            jsr ADC_1
            dta a(L09BA)

L0B5A       lda ECHOFLG
            and BATFLG
            bmi L0AEF

            jsr MOVE_CALL
L0B65 dta h(MC_mov+L0B3B+1),l(L0B3B+1),h(MC_2+HATABS+2),l(HATABS+2)
      dta h(MC_movE+L0A9E),l(L0A9E),h(MC_2+IOCB0+ICPTL),l(IOCB0+ICPTL)

            beq L0AFA
CMD_PRINT   bne L0BA0
CMD_PRINT_V equ CMD_PRINT-1
            lda COMFNAM
            cmp PROMPTD
            bne L0BA0
L0B79       ldy #$00
            dta b(op_BIT_abs)
L0B7C       ldy #$01
R_XDIVIO    tya
            and #$01
            tay
            sty L0AFF+1
            lda ECHOFLG,Y
            bmi L0B28
            ldx #$03
            jsr L0CC4
            lda #$FF
            bmi L0B17
L0B93       lda #$20
            jsr L0762
            ldy #$45
            jsr L07BE
            ldy #$01
            dta b(op_BIT_abs)
L0BA0       ldy #$00
L0BA2       jsr R_DIVIO
            bpl L0BC1
            jmp L0A94

PARSE_LINE  lda LBUF
            cmp #'-'
            beq L0B93
            cmp #';'
            beq L0BC1
            jsr _CRNAME
            bne PARSE_CMD

            jsr MOVE_CALL
  dta h(MC_movE+COMFNAM),l(COMFNAM),h(MC_2+PROMPTD),l(PROMPTD)

L0BC1       rts

PARSE_CMD   jsr INT_CMD
* begin statement table
*  called via CIO command:
            dta c'RENAM',b($C5)     ; 32
            dta c'ERAS',b($C5)      ; 33
            dta b($9B)
            dta c'PROTEC',b($D4)    ; 35
            dta c'UNPROTEC',b($D4)  ; 36
ERROR1      dta b($9B)
ERROR2      dta c'Error',b($9B)
            dta b($9B)
L0BE9       dta b($90)
            dta b($94)
            dta c'M',b($C4)         ; 42
            dta c'R',b($C4)         ; 43
            dta c'C',b($C4)         ; 44
            dta c'LOA',b($C4)
*  called via CMD_TAB_H/L
            dta c'CA',b($D2)
            dta c'RU',b($CE)
            dta c'PRIN',b($D4)
            dta c'TYP',b($C5)
            dta c'DI',b($D2)
            dta c'DIR',b($D3)
            dta c'BASI',b($C3)
            dta b($00)
* CHANGE: 9 free bytes, e.g. CREDIR is now MD etc.
* 9 bytes are inserted after rts, just
* to keep all other addresses stable

            jsr L0A71
            ldy #$4A
            jsr L07BE
            clc
L0C23       lda #$04 
            rol @
            sta L0C2C
            jsr DO_CIO_1
L0C2C       dta b($08,$28)
            dta a(COMFNAM,28)
L0C32       rts

* CHANGE: 9 bytes inserted
* we use them to set left margin to 0 at DOS entry
            dta b($00,$00) ; just filler
ext_init    lda #$00
            sta $52    ; left margin 0
            jmp L0B28  ; continue DOS entry
* end of CHANGE

INT_CMD     ldx #$FF
            stx L0043
L0C37       ldx #$00
            ldy #$00
            inc L0043
L0C3D       jsr INC_PC
            pha
            eor COMFNAM+3,Y
            asl @
            beq L0C48
            dex
L0C48       iny
            pla
            beq L0C32
            bpl L0C3D
            txa
            bmi L0C37
            lda COMFNAM+3,Y
            cmp #$9B
            bne L0C37
            jsr L0768
            pla
            pla
            lda L0043
            cmp #$0D
            beq L0C23
            bcs L0C74
            adc #$20
            sta L0C6E
            jsr DO_CIO_1
            dta b($00)
L0C6E       dta b($00)
            dta a(COMFNAM,28)
            rts

L0C74       tay
            lda CMD_TAB_H-14,Y
            pha
            lda CMD_TAB_L-14,Y
            pha
            cpx #$03
            rts

* commannd DIR/S
CMD_DIR     lda #$80
CMD_DIR_V   equ CMD_DIR-1
CMD_DIRS    eor #$12
CMD_DIRS_V  equ CMD_DIRS-1
            pha
            lda COMFNAM-1,X
            cmp #$38
            beq L0C97
            and #$F9
            cmp #$38
            bne L0C97
            ldy #$4F
L0C94       jsr L07BE
L0C97       pla

* command TYPE
CMD_TYPE    eor #$9F
CMD_TYPE_V  equ CMD_TYPE-1
            sta L0CA0
            jsr DO_CIO_1
L0CA0       dta b($08,$03)
            dta a(COMFNAM,28)
L0CA6       jsr DO_CIO
L0CA9       dta b($44,$07)
            dta a(LBUF)
            dta a(64)
            php

            jsr MOVE_CALL
  dta h(MC_movE+IOCB1+ICBLL),l(IOCB1+ICBLL),h(MC_2+L0CBE),l(L0CBE)

            jsr DO_CIO
            dta b($40,$0B)
            dta a(LBUF)
L0CBE       dta a(64)

            plp
            bpl L0CA6
            rts

L0CC4       sta L0045
            txa
            pha
            ldx ECHOFLG,Y
            lda HATABS+1,X
            sta L0043
            lda HATABS+2,X
            sta L0044
            ldx L0A3C,Y
            pla
            tay
            lda (L0043),Y
            pha
            dey
            lda (L0043),Y
            pha
            lda L0045
            rts

* Start of COMTAB
DWARM       dta b($FF)             ; -21
            dta b($80)             ; -20 ???
DECOUT      dta b($20,$20,$20,$20) ; -19
            dta b($20,$20,$20,$20)
SSIOV       dta b(op_JMP_abs)      ; -13 jmp SIO
LSIO        dta a(SIOV)            ; -10
ECHOFLG     dta b($FF)             ; -8
BATFLG      dta b($FF)             ; -7
DECIN       dta b($00,$00,$00,$00) ; -6
WRTCMD      dta c'P'               ; -2 W=verify P=no verify
SWARMST     dta b($FF)             ; -1 00 in CP, $FF trap errors
* DOSVEC => $0cf9
COMTAB      jmp _COMTAB            ; COMTAB Jump to DOS CP
CRNAME      jmp _CRNAME            ; +3
DIVIO       dta a(R_DIVIO)         ; +6
XDIVIO      dta a(R_XDIVIO)        ; +8
BUFOFF      dta b($00)             ; +10
ZORIG       dta a(BW_BEGIN)        ; +11
DATER       dta b(28,11,95)        ; +13
TIMER       dta b(22,14,06)        ; +16
ODATER      dta b(28,11,95)        ; +19
OTIMER      dta b(22,14,06)        ; +22
TDOVER      dta b($00)             ; +25
TRUN        dta a(_rts)            ; +26
            dta a(L1711)           ; +28 ??? buffer address ???
SMEMLO      dta a(END_ADDR)        ; +30 start up MEMLO
INCMND      dta b($00)             ; +32 Reset $00-CP $FF-Cart
COMFNAM     dta c'D1:STARTUP.BAT'  ; +33 28 Bytes
            dta b($9B)
            dta c'             '
RUNLOC      dta a(_rts)            ; +61 address for RUN
* start code to check for STARTUP.BAT
LBUF        jsr L07F2              ; +63 comman line buffer 64 Bytes
            lda #$FF
            sta L0047
            ldy #$01
            jsr R_DIVIO
            jsr L0A71
            stx COLDST
            lda BOOT
            ora #$01
            sta BOOT
            jmp _COMTAB
            clc
            rts
            dta c'                          '
            dta c'         '
L0D43       equ LBUF+$0B
L0D48       equ LBUF+$10
* end of LBUF and COMTAB

PROMPT      dta b($9B)
PROMPTD     dta c'D1:'
            dta b($9B)
            dta c'.BAT'
            dta b($9B)
            dta c'.COM'
            dta b($9B)
            dta c'*.*'

DAT_BUF     equ *
            dta b($9B)
            dta c'Volume'
L0D91       dta c':'
L0D92       dta c'          '
L0D9C       dta c' '
L0D9D       dta c'  '
L0D9F       dta c'  '
L0DA1       dta c'   '
L0DA4       dta c'  '
L0DA6       dta c' '
L0DA7       dta c'  '
L0DA9       dta c' '
L0DAA       dta c' '
L0DAB       dta c'  '
            dta c'    '
L0DB1       dta c'  '
L0DB3       dta c'   '
L0DB6       dta c'      '
L0DBC       dta c'         '
L0DC5       dta c' '
            dta b($9B)
            dta c'Directory:'
L0DD1       dta b($E4,$E9,$F2) ; dir inverse
L0DD4       dta c'<dir>'
L0DD9       dta c'free sectors'
L0DE5       dta b($00,$00)
            dta b($00,$00)
L0DE9       dta b($80)
            dta c'    '
L0DEE       dta c' '
L0DEF       dta c' '
L0DF0       dta c'  '
L0DF2       dta b($FF,$FF)
            dta c'DOS       '
L0DFE       dta c' !'
L0E00       dta b($00,$00,$00,$02)
            dta b($00,$1C)
L0E06       dta b($17,$00)
L0E08       dta a($0001)
L0E0A       dta c'-'

* start of initialization after loading
* after start it is used for buffers $141 bytes
start       ldx #$1A
* search for E:
_srch_e     lda DDEVIC,X
            cmp #'E'
            beq _e_found
            inx
            inx
            inx
            cpx #$3B
            bcc _srch_e
* E: not found => Self Test
            jmp SELFSV
* update HATABS
_e_found    inx
            stx L0B32+1
            stx L0B65+3
            stx L0AF2+3
            inx
            stx L0B28+1
* move dos_iniv to DOSINI
            jsr MOVE_CALL
  dta h(MC_movE+dos_iniv),l(dos_iniv),h(MC_2+DOSINI),l(DOSINI)
* print BW-DOS version
            jsr DO_CIO_0
            dta b($0B)
            dta a(dos_text,dos_text_e-dos_text)
* execute STARTUP.BAT
            jmp LBUF
dos_iniv    dta a(DOS_INI)
dos_text    dta b($9B)
            dta c'BW-DOS 1.31 BEWESOFT 2022-02-20'
            dta b($9B)
dos_text_e  equ *

* buffer addresses $0E0B-$0F4B ($141 Bytes)
L0E0B       equ start
L0E16       equ start+$0B
L0E21       equ start+$16
L0E24       equ start+$19
L0E26       equ start+$1B
L0E27       equ start+$1C
L0E2F       equ start+$24
L0E32       equ start+$27
L0E38       equ start+$2D
L0E39       equ start+$2E
L0E3A       equ start+$2F
L0E3B       equ start+$30
L0E3C       equ start+$31
L0E3D       equ start+$32
L0E3E       equ start+$33
L0E3F       equ start+$34
L0E40       equ start+$35
L0E41       equ start+$36
L0E42       equ start+$37
L0E43       equ start+$38
L0E45       equ start+$3A
L0E48       equ start+$3D
L0E49       equ start+$3E
L0E4B       equ start+$40
L0E4C       equ start+$41
L0E4D       equ start+$42
L0E51       equ start+$46
L0E52       equ start+$47
L0E53       equ start+$48
L0E55       equ start+$4A
L0E56       equ start+$4B
L0E58       equ start+$4D
L0E5A       equ start+$4F
L0E5D       equ start+$52
L0E5F       equ start+$54
L0E6B       equ start+$60
L0E6D       equ start+$62

L0ED7       equ start+$CC
L0ED8       equ start+$CD
L0F15       equ start+$10A
L0F38       equ start+$12D
L0F40       equ start+$135
L0F43       equ start+$138
L0F46       equ start+$13B
L0F49       equ start+$13E

            blk dos start+$141 ; $0F4C

L0F4C       ldx L0E3D
            lda L0E3E
            jsr L1BE9
            ldy L0E3F
            rts

L0F59       lda L0F78-$20,Y
            and #$1F
            pha
            lda L0F66-$20,Y
            pha
            ldx L0046
            rts

* internal CIO code tab
*           RENAME,ERASE,OPEN,PROTECT
L0F66       dta b($D0,$D0,$96,$D0) ; $20-$23
*           UNPROTECT,POINT,NOTE,GETFLEN
            dta b($D0,$31,$E8,$EB) ; $24-$27
*           LOAD,SAVE,MD,RD
            dta b($21,$8F,$89,$19) ; $28-$2B
*           CD,CLOSE,?,CHKDSK
            dta b($94,$7C,$E8,$53) ; $2C-$2F
*           GETBYTER,PUTBYTE
            dta b($8C,$95)         ; $30-$31

L0F78       dta b($FC,$FC,$95,$FC) ; $20-$23
            dta b($FC,$34,$36,$36) ; $24-$27
            dta b($3E,$D5,$F5,$FD) ; $28-$2B
            dta b($FA,$53,$12,$F1) ; $2C-$2F
            dta b($12,$12)         ; $30-$31

* CIO D: routines
SPECIAL     ldy ICCOMZ
SPECIAL_V   equ SPECIAL-1
            sta L10DB+1
            tya
            and #$F0
            cmp #$20
            bne L0F9B
            and L0F78-$20,Y
            bne L0FAF
L0F9B       ldy #$A8 ; not implemented
L0F9D       rts

OPEN        ldy #$22
OPEN_V      equ OPEN-1
            dta b(op_BIT_abs)
CLOSE       ldy #$2D
CLOSE_V     equ CLOSE-1
            dta b(op_BIT_abs)
GETBYTE     ldy #$30
GETBYTE_V   equ GETBYTE-1
            dta b(op_BIT_abs)
PUTBYTE     ldy #$31
PUTBYTE_V   equ PUTBYTE-1
            dta b(op_BIT_abs)
GETSTAT     ldy #$29
GETSTAT_V   equ GETSTAT-1
L0FAC       sta L10DB+1
L0FAF       cld
            stx L0046
            lda #$01
            sta L10BA+1
            cpy #$28
            bne L0FC4
            jsr L0F59
            dta b(op_BIT_abs)
L0FBF       ldy #$A1
L0FC1       jmp L10DB
L0FC4       tsx
            stx RET_ERR2+1
            inx
            inx
            lda STACK,X
            sta L12A2+1
            sty L109B+1
            lda L0F78-$20,Y
            and #$C0
            sta L0FEB+1
            ldx L0046
            jsr L1121
            bne L0FEB
            bit L0FEB+1
            bpl L1000
            ldy #$81
            bne L0FC1
L0FEB       lda #$00
            bpl L1023
            ldx #$FF
            jsr L1121
            bne L0FBF
            lda L0046
            sta L0ED7,Y
            lda ICDNOZ
            sta L0ED8,Y
L1000       sty L10CC+1
            ldx #$EB
L1005       lda L0ED7,Y
            sta L0E38-$EB,X
            iny
            inx
            bne L1005
            ldy #$68
L1011       lda L0E55,Y
            cmp L0E39
            beq L102F
            tya
            sec
            sbc #$1A
            tay
            bcs L1011
            jsr RET_ERR1
*           dta ($A0) from LDY #..
L1023       ldy #$85
            lda L109B+1
            cmp #$2D
            bne L0FC1
            jmp L10BA
L102F       ldx #$E6
L1031       lda L0E55-$E6,X
            pha
            lda L0E55,Y
            sta L0E55-$E6,X
            pla
            sta L0E55,Y
            iny
            inx
            bne L1031
            bit L0FEB+1
            bpl L1093
            jsr L1BE5
            ldy #$07
            lda (L0043),Y
            cmp #$80
            bne L105B
            lda #$1F
            tay
            iny
            cmp (L0043),Y
            bcc L105F
L105B       jsr RET_ERR1
            dta b($94)
L105F       ldy #$16
L1061       lda L0E4D,Y
            cmp (L0043),Y
            bne L107D
            iny
            cpy #$1E
            bcc L1061
            ldy #$26
L106F       lda L0E45,Y
            cmp (L0043),Y
            bne L107D
            iny
            cpy #$28
            bcc L106F
            bcs L1093
L107D       lda #$99
            jsr L1131
            iny
            lda (L0043),Y
            ldy L0E39
L1088       sta L0DE9,Y

            jsr MOVE_CALL
  dta b(MC_cpy+2),l(L0E56-DAT_BUF,L0E6D-DAT_BUF)
  dta h(MC_jsrE+L1114),l(L1114)

L1093       ldy L0E39
            lda L0DE9,Y
            sta L0045
L109B       ldy #$00
            jsr L0F59
            bit L0FEB+1
            bvc L10AB
            jsr L10E2
            stx L0E38
L10AB       ldy L10CC+1
            ldx #$EB
L10B0       lda L0E38-$EB,X
            sta L0ED7,Y
            iny
            inx
            bne L10B0
L10BA       ldy #$01
            bne L10DB

RET_ERR1    jsr INC_PC
            tay
RET_ERR2    ldx #$00
            txs
            tya
            pha
            lda L0FEB+1
            beq L10D3
L10CC       ldy #$00
            lda #$FF
            sta L0ED7,Y
L10D3       jsr L10E2
            jsr L1114
            pla
            tay
L10DB       lda #$00
            ldx L0046
            cpy #$00
            rts

L10E2       ldx L0E39
            lda L0E4C,X
            bpl L10FB
            lsr L0E4C,X
            jsr L1BE5
            jsr L1C2B
            inc L0E6B
            lda #$B9
            jsr L1131
L10FB       ldx #$03
L10FD       dex
            bmi L1113
            jsr L110C
            bne L10FD
            bcc L10FD
L1107       jsr L1B13
            bpl L10FB
L110C       lda L0F40,X
            eor L0E39
            asl @
L1113       rts

L1114       ldx #$02
L1116       jsr L110C
            bne L111E
            sta L0F40,X
L111E       dex
            bpl L1116
L1121       ldy #$54
L1123       txa
            cmp L0ED7,Y
            beq L1130
            tya
            sec
            sbc #$15
            tay
            bcs L1123
L1130       rts

L1131       sta L1149
            sta L113B
            ldy #$26
L1139       lda (L0043),Y
L113B       sta L0E45,Y
            sta (L0043),Y
            iny
            cpy #$28
            bcc L1139
            ldy #$09
L1147       lda (L0043),Y
L1149       lda L0E4D,Y
            sta (L0043),Y
            iny
            cpy #$1E
            bcc L1147
            rts

L1154       jsr MOVE_CALL
  dta h(MC_movE+ICBLLZ),l(ICBLLZ),h(MC_2+L1185+1),l(L1185+1)

            ldy #$20
            jsr L1182
            ldy #$1F
            jsr L1182
            ldy #$0B
L1167       jsr L1182
            cpy #$0F
            bcc L1167
            ldy #$16
L1170       jsr L1182
            cpy #$1E
            bcc L1170
            ldy #$26
            jsr L1182
            jsr L1182
            lda #$00

            dta b(op_BIT_abs)
L1182       lda (L0043),Y

            iny
L1185       sta $FFFF,X
            inx
            rts

SET_TO_9    ldx #$FD
L118C       lda DECOUT+4
            cmp #$20
            bne L1197
            lda DECOUT+5-$FD,X

            dta b(op_BIT_abs)
L1197       lda #$39

            ora #$30
            sta DECOUT+5-$FD,X
            inx
            bne L118C
            rts

L11A2       jsr CLR_TXT_BUF
            dta b($91)

            jsr MOVE_CALL
  dta h(MC_jsr+SET_TO_9),l(SET_TO_9)
  dta h(MC_mov+DECOUT+5),l(DECOUT+5),h(MC_3+L0D9D),l(L0D9D)
  dta b(MC_cpyE+12),l(L0DD9-DAT_BUF),(L0DA1-DAT_BUF)

            beq L1215

L11B4       jsr MOVE_CALL
  dta h(MC_mov+L0E5A),l(L0E5A),h(MC_2+DECIN),l(DECIN)
  dta h(MC_jsrE+CONV_16),l(CONV_16)

L11BD       ldx #$00
            bpl L11A2

            jsr CLR_TXT_BUF
            dta b($94)

            jsr MOVE_CALL
  dta h(MC_mov+DECOUT+2),l(DECOUT+2),h(MC_6+L0D9D),l(L0D9D)
  dta b(MC_cpyE+12),l(L0DD9-DAT_BUF),(L0DA4-DAT_BUF)

            beq L1215

L11D1       jsr CLR_TXT_BUF
            dta b($12)

            jsr MOVE_CALL
  dta b(MC_cpyE+11,L0E27-DAT_BUF,L0D9F-DAT_BUF)

L11DB       lda L0E21
            lsr @
            bcc L11E6
            ldx #$2A
            stx L0D9D
L11E6       and #$10
            beq L11F0

            jsr MOVE_CALL
  dta b(MC_cpyE+3,L0DD1-DAT_BUF,L0DA7-DAT_BUF)

L11F0       lda L0E21+3
            ldx L0E21+4
            ldy L0E26
            jsr L14FD
            cmp #$00
            beq L1204
            inx
            bne L1204
            iny
L1204       stx DECIN
            sty DECIN+1

            jsr MOVE_CALL
  dta h(MC_jsr+CONV_16),l(CONV_16)
  dta h(MC_jsr+SET_TO_9),l(SET_TO_9)
  dta h(MC_movE+DECOUT+5),l(DECOUT+5),h(MC_3+L0DAB),l(L0DAB)

L1215       beq L1274

L1217       jsr MOVE_CALL
  dta b(MC_cpy+11,L0D92-DAT_BUF,L0E0B-DAT_BUF)
  dta h(MC_jsrE+L1DBF),l(L1DBF)

            bne L11B4
            bit L11BD+1
            bpl L11D1

            jsr CLR_TXT_BUF
            dta b($24)

            jsr MOVE_CALL
  dta b(MC_cpy+8,L0E27-DAT_BUF,L0D9D-DAT_BUF)
  dta b(MC_cpy+3,L0E2F-DAT_BUF,L0DA6-DAT_BUF)
  dta b(MC_cpy+5,L0DD4-DAT_BUF,L0DAA-DAT_BUF)
  dta b(MC_cpy+1,L0E0A-DAT_BUF,L0DB3-DAT_BUF)
  dta b(MC_cpy+1,L0E0A-DAT_BUF,L0DB6-DAT_BUF)
  dta b(MC_cpyE+1,L0D91-DAT_BUF,L0DBC-DAT_BUF)

            lda L0E21
            and #$20
            bne L1253

            jsr MOVE_CALL
  dta h(MC_mov+L0E24),l(L0E24),h(MC_3+DECIN),l(DECIN)
  dta h(MC_jsr+CONVDC),l(CONVDC)
  dta h(MC_movE+DECOUT+1),l(DECOUT+1),h(MC_7+L0DA9),l(L0DA9)

L1253       ldy #$FB
L1255       txa
            pha
            lda L0E32-$FB,Y
            jsr CONV_A
            jsr SET_TO_9
            pla
            tax
            lda DECOUT+6
            sta L0DB1,X
            lda DECOUT+7
            sta L0DB1+1,X
            inx
            inx
            inx
            iny
            bne L1255

L1274       dec L1283+1
L1277       ldx #$00
            lda L0D9D,X
            inc L1277+1
            sta L10DB+1
            rts

L1283       lda #$00
            asl @
            bne L1274
            bcs L12EE
            jmp L1217

            ldx L0E48
            cpx #$16
            beq L1283
            lda #$6A
            eor #$6A
            sta L0048
            and #$0C
            eor #$07
            cmp ICCOMZ
            bne L12DF
L12A2       lda #$00
            cmp #$E4
            bcc L12DF
            ldy ICBLHZ
            bne L12B1
            iny
            cpy ICBLLZ
            bcs L12DF

L12B1       jsr MOVE_CALL
  dta h(MC_mov+ICBALZ),l(ICBALZ),h(MC_2+L1426+1),l(L1426+1)
  dta h(MC_mov+ICBLLZ),l(ICBLLZ),h(MC_2+L0E51),l(L0E51)
  dta h(MC_jsrE+L136A),l(L136A)

            php

            jsr MOVE_CALL
  dta h(MC_mov+L1426+1),l(L1426+1),h(MC_2+ICBALZ),l(ICBALZ)
  dta h(MC_movE+L0E51),l(L0E51),h(MC_2+ICBLLZ),l(ICBLLZ)

            plp
            bmi L12EE

            jsr SBC_1
            dta a(ICBALZ)

            lda (ICBALZ-1,X)
            inc ICBLLZ
L12D6       sta L10DB+1
L12D9       jsr L14BF
            beq L12F0
            rts

L12DF       jsr MOVE_CALL
  dta h(MC_mov+L12D6+1),l(L12D6+1),h(MC_2+L1426+1),l(L1426+1)
  dta b(MC_cpyE+2,L0E08-DAT_BUF,L0E51-DAT_BUF)

            jsr L136A
            bpl L12D9
L12EE       lda #$8B
L12F0       eor #$03
            sta L10BA+1
            rts

L12F6       jsr L0F4C
            iny
            iny
            sty L0E3F
            cpy L0045
            bne L1345
            jsr L0F4C
            ldy #$00
            lda (L0043),Y
            tax
            iny
            ora (L0043),Y
            bne L1335
            jsr L1B6C
            ldy #$02
L1314       lda L0E3B,Y
            sta (L0043),Y
            iny
            cpy #$04
            bcc L1314
            jsr L0F4C
            ldy #$01
L1323       lda L0DE5,Y
            sta (L0043),Y
            dey
            bpl L1323

            jsr MOVE_CALL
  dta h(MC_jsr+L1C2B),l(L1C2B)
  dta b(MC_cpyE+2,L0DE5-DAT_BUF,L0E3D-DAT_BUF)

            beq L133D
L1335       lda (L0043),Y
            sta L0E3E
            stx L0E3D
L133D       jsr L0F4C
            ldy #$04
            sty L0E3F
L1345       lda (L0043),Y
            sta L0E3A
            iny
            lda (L0043),Y
            sta L0E3B
            ora L0E3A
            rts

L1354       sec
            ldx #$FD
L1357       lda L0E45-$FD,X
            sbc L0E40-$FD,X
            inx
            bne L1357
            bcs L1369

            jsr MOVE_CALL
  dta b(MC_cpyE+3,L0E40-DAT_BUF,L0E45-DAT_BUF)

            clc
L1369       rts

L136A       lda L0E48
            ldy #$83
            bit L0048
            bpl L1376
            lsr @
            ldy #$87
L1376       and #$04
            bne L13BF
            jmp RET_ERR2
            lda L0E48
            cmp #$16
            bne L1387
            lsr L0E53
L1387       and #$08
            beq L1369

            jsr MOVE_CALL
  dta b(MC_cpy+3,L0E45-DAT_BUF,L0E16-DAT_BUF)
  dta b(MC_cpy+2,L0E49-DAT_BUF,L0E43-DAT_BUF)
  dta h(MC_jsr+L150C),l(L150C)
  dta h(MC_jsr+L139E),l(L139E)
  dta b(MC_cpyE+3,L0E16-DAT_BUF,L0E24-DAT_BUF)

L139B       lda #$FF
            dta b(op_BIT_abs)
L139E       lda #$00
            pha

            jsr MOVE_CALL
  dta b(MC_cpy+2,L0E4B-DAT_BUF,L0DEE-DAT_BUF)
  dta b(MC_cpy+1,L0E00-DAT_BUF,L0DF0-DAT_BUF)
  dta h(MC_jsrE+L143E),l(L143E)

            pla
            dta b(op_BIT_abs)
L13AE       lda #$00
            dta b(op_BIT_abs)
            lda #$FF
            sta L0048

            jsr MOVE_CALL
  dta h(MC_mov+L11DB+1),l(L11DB+1),h(MC_2+L1426+1),l(L1426+1)
  dta b(MC_cpyE+2,L0E06-DAT_BUF,L0E51-DAT_BUF)

L13BF       lda L0045
            sec
            sbc L0E3C
            bne L13C9
            lda #$FF
L13C9       sta L1488+1
            lda L0E52
            bne L13D9
            lda L0E51
            beq L13F5
            jsr L14F5
L13D9       jsr L14BF
            beq L13F4
            jsr L14F5
            lda L0E3A
            ora L0E3B
            bne L140E
            lda L0E48
            and #$08
            bne L13F6
L13F0       jsr RET_ERR1
            dta b($A6)
L13F4       dex
L13F5       rts

L13F6       jsr MOVE_CALL
            dta b($1B,$6C)
            dta b($22,$5B,$B0)
            dta b($8F,$4C)

            lda L0DE5
            sta (L0043),y
            iny
            lda L0DE5+1
            sta (L0043),Y
            jsr L1C2B
L140E       ldx L0E3A
L1411       lda L0E3B

            jsr MOVE_CALL
            dta b($1B,$E9)
            dta b($D4,$27,$54,$82)

            ldy L0E3C
            bit L0048
            bmi L1481
L1424       lda (L0043),Y
L1426       sta $FFFF,X
            iny
            inx
            cpx L1488+1
            bne L1424
            beq L148F
            ldy #$FD
L1434       lda IOCB0+ICAX3,X
            sta L0DEE-$FD,Y
            inx
            iny
            bne L1434
L143E       lda L0DF0
            bmi L13F0

            jsr MOVE_CALL
            dta b($21,$79,$B5)
            dta b($22,$B9,$B3)
            dta b($23,$64,$B6)
            dta b($93,$54)

            bcs L145A
            lda L0E48
            and #$08
            beq L13F0
L145A       lda L0DEE
            ldx L0DEF
            ldy L0DF0
            jsr L14FD
            sta L0E3C
            stx L0DEE
            sty L0DEF

L146F       jsr L12F6
            lda L0DEE
            ora L0DEF
            beq L14D9
            jsr SBC_1
            dta a(L0DEE)
            bcs L146F

L1481       lda $FFFF,X
            sta (L0043),Y
            iny
            inx
L1488       cpx #$00
            bne L1481
            jsr L1C2B
L148F       lda L1488+1

            jsr SBC_A
            dta a(L0E51)

            jsr ADC_L
            dta a(L1426+1)

            jsr ADC_L
            dta a(L0E40)

            bcc L14A6
            inc L0E42
L14A6       jsr L1354
L14A9       lda L0E3C
            clc
            adc L1488+1
            cmp L0045
            bne L14B9
            jsr L12F6
            lda #$00
L14B9       sta L0E3C
            jmp L13BF
L14BF       ldx #$FD
            sec
L14C2       lda L0D48,X
            sbc L0D43,X
            sta L0DEE-$FD,X
            inx
            bne L14C2
            bit L0048
            bmi L14D7
            ora L0DEF
            beq L14F1
L14D7       lda #$FF
L14D9       rts

CLR_TXT_BUF jsr INC_PC
            sta L1283+1
            asl @
            lsr @
            tax
            lda #$9B
            tay
L14E6       sta L0D9C,X
            lda #$20
            dex
            bne L14E6
            stx L1277+1
L14F1       lda L0DEE
            rts

L14F5       cmp L1488+1
            bcs L14D9
            sta L1488+1
L14FD       bit L0045
            bpl L150B
            asl @
            pha
            txa
            rol @
            tax
            tya
            rol @
            tay
            pla
            lsr @
L150B       rts

L150C       lda #$14
            dta b(op_BIT_abs)
            lda #$0C
L1511       sta L0E48
            pha

            jsr MOVE_CALL
            dta b($23,$76,$64)
            dta b($94,$3E)

            pla
            cmp #$10
            bcc L152D

            jsr MOVE_CALL
            dta b($21,$7C,$BB)
            dta b($13,$AE)
            dta b($A3,$9A,$BB)

L152D       rts

            jsr MOVE_CALL
            dta b($2B,$81,$9D)
            dta b($23,$76,$9A)
            dta b($CD,$06,$CE,$32)

            bit TDOVER
            bpl L1547

            jsr MOVE_CALL
            dta b($CD,$0C,$CE,$32)

L1547       lda L0049
            sta L0E48
            and #$20
            ora #$08
            sta L0E21
            rts

L1554       bit L0E53
            bmi L15C4
            lda #$16
            sta L0049

            jsr MOVE_CALL
            dta b($16,$00)
            dta b($AB,$81,$08)

            stx L1283+1
            lda ICAX2Z
            sta L11BD+1
            bpl L1585

            jsr CLR_TXT_BUF
            dta b($2A)

            sty L0DC5

            jsr MOVE_CALL
            dta b($28,$00,$13)
            dta b($28,$D9,$1F)
            dta b($2B,$3C,$27)
            dta b($A8,$9D,$33)

L1585       sec
            ror L0E53
            rts

            lda #$28
            ldx #$09
            bne L15A0
            lda ICAX1Z
            and #$F0
            ora #$04
            dta b(op_BIT_abs)
            lda $2A
            and #$3F
            dta b(op_BIT_abs)
L159C       lda #$14
L159E       ldx #op_AND_abs
L15A0       stx L1684
            cmp #$06
            beq L1554
            cmp #$20
            bcc L15AD
            and #$EF
L15AD       sta L0049
            and #$0F
            lsr @
            bcc L15B8
            cmp #$04
            bne L15BB
L15B8       lsr @
L15B9       bcc L1600

L15BB       ldy #$A8
            dta b(op_BIT_abs)
L15BE       ldy #$A3
            dta b(op_BIT_abs)
L15C1       ldy #$A9
            dta b(op_BIT_abs)
L15C4       ldy #$A1
            jmp RET_ERR2

L15C9       ldx #$0A
L15CB       lda L0E0B,X
            cmp #'?'
            beq L15BE
            dex
            bpl L15CB

            jmp (GETTDV)
L15D8       lda #$00
            bpl L1622

            jsr MOVE_CALL
            dta b($2B,$81,$8C)
            dta b($2B,$6A,$81)
            dta b($22,$CC,$B9)
            dta b($15,$0C)
            dta b($9D,$C5)

            bne L1622

            jsr MOVE_CALL
            dta b($2B,$8C,$81)
            dta b($22,$98,$B9)
            dta b($15,$0C)
            dta b($9D,$C2)

            bne L1622
            jmp L16B2

L1600       jsr L1AAE
            php
            pla
            ror @
            ror @
            ror L15D8+1
            lda L0049
            and #$10
            bne L167D
            jsr L150C
            jsr L1DBF
            beq L167F
L1618       lda L0049
            cmp #$04
            beq L15D8
            and #$08
            bne L162C

L1622       jsr RET_ERR1
            dta b($AA)

L1626       jsr L15C9
            jsr L1D4D
L162C       bit L0E4C
            bmi L15C1

            jsr MOVE_CALL
            dta b($15,$C9)
            dta b($15,$2E)
            dta b($1B,$6C)
            dta b($22,$5B,$98)
            dta b($21,$7B,$BE)
            dta b($13,$9B)
            dta b($22,$C1,$5D)
            dta b($22,$76,$C1)
            dta b($13,$9E)
            dta b($23,$BB,$9A)
            dta b($13,$9B)
            dta b($22,$5D,$C1)
            dta b($93,$9E)

            lda L0049
            and #$20
            beq L1678
L165A       beq L1618

            jsr MOVE_CALL
            dta b($22,$B9,$5D)
            dta b($22,$98,$B9)
            dta b($15,$0F)
            dta b($15,$2E)
            dta b($21,$7C,$9A)
            dta b($22,$5D,$98)
            dta b($13,$B1)
            dta b($22,$98,$B9)
            dta b($15,$0C)
            dta b($93,$9E)

L1678       jmp L16B2

L167B       bpl L1626
L167D       bne L16BB
L167F       lda L0049
            eor L0E21
L1684       and #$20
            beq L1696
            lda L0049
            and #$08
            beq L165A
            ldy #$97
            dta b(op_BIT_abs)
L1691       ldy #$A4
            jmp RET_ERR2
L1696       lda L0049
            and #$08
            beq L16B2
            lda L0E21
            and #$21
            lsr @
            bne L16B2
            bcs L1691
            lda L0049
            cmp #$08
            bne L16B2
L16AC       lda #$00
            bpl L167B
            inc L0049

L16B2       jsr MOVE_CALL
            dta b($22,$B9,$BF)
            dta b($A5,$98,$B9)

L16BB       lda L0049
            jsr L1511
            lda L0049
            cmp #$10
            bcc L16DB

            jsr MOVE_CALL
            dta b($22,$B9,$BF)
            dta b($A2,$76,$C1)

            lda L0049
            and #$07
            bne L16DB

            jsr MOVE_CALL
            dta b($A3,$B6,$BB)

L16DB       lda L0049
            lsr @
            bcc L16FD

            jsr MOVE_CALL
            dta b($A3,$BB,$64)

            jmp L143E

            ldy #$00
            dta b(op_BIT_ABS)
            ldy #$05
L16EE       lda L0E40,Y
            sta IOCB0+ICAX3,X
            iny
            inx
            txa
            and #$0F
            cmp #$03
            bcc L16EE
L16FD       rts

L16FE       stx L1C2B+1
            lda #$FF
            sta L0F49,X
            txa
            clc
            adc #$17
            sta L0044
            lda #$11
            sta L0043
            rts

L1711       equ *

            blk dos L1711+$300

L1A11       cpx #$08
            bcc L1A1E
            bit L1C47+1
            bpl L1A22
            cpx #$0B
            bcs L1A22
L1A1E       sta L0E0B,X
            inx
L1A22       rts

L1A23       ldy #$00
            sty L1AE9+1
            inc L1A23+1
            lda #$0E
            sta L1C47+1
            ldx #$00
            beq L1A3E

L1A34       lda #$3F
            jsr L1A11
            bcc L1A34

L1A3B       jsr L1A11
L1A3E       iny
            lda (ICBALZ),Y
            cmp #'*'
            beq L1A34
            cmp #'?'
            beq L1A3B
            cmp #'_'
            beq L1A3B
            cmp #'.'
            beq L1A65
            cmp #'0'
            bcc L1A61
            cmp #':'
            bcc L1A3B
            cmp #'A'
            bcc L1A61
            cmp #'['
            bcc L1A3B

L1A61       sec
            ror L1C47+1
L1A65       lda #' '
            jsr L1A11
            bcc L1A65

            ror L1C47+1
            bcc L1A3E
            lda (ICBALZ),Y
            cmp #'/'
            bne L1A84
            iny
            lda (ICBALZ),Y
            dey
            cmp #'A'
            bne L1A84
            ror L16AC+1
            iny
            iny
L1A84       cpy L1A23+1
L1A87       sty L1A23+1
            php
            beq L1A8E
            clc
L1A8E       ror L1AFD+1
            lda (ICBALZ),Y
            plp
            rts

            jsr MOVE_CALL
            dta b($1A,$9F)
            dta b($1A,$FA)
            dta b($A2,$B9,$E3)

L1A9F       ldy #$02
L1AA1       lda (ICBALZ),Y
            cmp #':'
            beq L1A87
            dey
            bne L1AA1

L1AAA       jsr RET_ERR1
            dta b($96)

L1AAE       jsr L1A9F
            sty L1AE7+1
L1AB4       lsr L16AC+1

            jsr MOVE_CALL
            dta b($22,$E3,$B9)
            dta b($9A,$23)

            bne L1AF4
            cmp #'>'
            bne L1AE0

            jsr MOVE_CALL
            dta b($A2,$CC,$B9)

            beq L1AEF
L1ACD       jsr L150C
            jsr L1B0C
            lda L0E43
            ora L0E43+1
            beq L1AAA
            jsr L1A23
            bne L1AF4
L1AE0       cmp #'<'
            beq L1ACD

L1AE4       lsr L16AC+1
L1AE7       ldy #$00
L1AE9       cpy #$00
            rts

L1AEC       jsr L1B01
L1AEF       jsr L1A23
            beq L1AE4

L1AF4       cmp #'>'
            beq L1AEC
            bne L1AE7
            jsr L1AB4
L1AFD       lda #$00
            bmi L1B12
L1B01       lsr L16AC+1
            jsr L150C
            jsr L1DC5
            bmi L1AAA

L1B0C       jsr MOVE_CALL
            dta b($A2,$98,$B9) ; MOVE8 L0E22, L0E43, 3

L1B12       rts

L1B13       lda L0F40,X
            bpl L1B12
            and #$7F
            sta L0F40,X
            tay
            jsr L16FE
            lda L0F46,X
            pha
            lda L0F43,X
            tax
            pla
            sec
L1B2B       sty DUNIT
            stx DAUX1
            sta DAUX2
            dex
            bne L1B3B
            tax
            bne L1B3B
            tay
L1B3B       ldx #'R'
            lda #$40
            bcc L1B45
            ldx WRTCMD
            asl @
L1B45       stx DCOMND
            sta DSTATS
            lda L0DE9,Y
            sta DBYTLO
            asl @
            rol @
            eor #$01
            sta DBYTHI

            jsr MOVE_CALL
            dta b($5B,$70,$23,$06)
            dta b($47,$AE,$23,$00)
            dta b($40,$43,$43,$04)
            dta b($8C,$EE)

            bmi L1BE2
L1B6B       rts

L1B6C       lda L0E48
            cmp #$10
            bcs L1B76
            ldy #$00
            dta b(op_BIT_abs)
L1B76       ldy #$02
            tya
            pha

            ldx #$FE
L1B7C       lda L0E5F,Y
            sta L0DE5-$FE,X
            iny
            inx
            bne L1B7C

            jsr L1BAE
            jsr L1CA3

            jsr SBC_1
            dta a(L0DE5)

L1B91       jsr L1D8A
            tax
            and (L0043),Y
            bne L1B9E
            jsr L1BAE
            bcc L1B91

L1B9E       txa
            eor (L0043),Y
            sta (L0043),Y
            jsr L1C2B

            jsr SBC_1
            dta a(L0E5A)

            clc
            bcc L1BC9

L1BAE       jsr ADC_1
            dta a(L0DE5)

            lda L0DE5
            cmp L0E58
            lda L0DE5+1
            sbc L0E58+1
            bcc L1B6B

            jsr SBC_1
            dta a(L0DE5)

            pla
            pla
            sec
L1BC9       pla
            tay
            ldx #$FE
L1BCD       lda L0DE5-$FE,X
            sta L0E5F,Y
            iny
            inx
            bne L1BCD

            ldx L0DE5
            bcc L1BEA
            dey
            dey
            beq L1B76
            ldy #$A2
L1BE2       jmp RET_ERR2

L1BE5       lda #$00
            ldx #$01
L1BE9       sec
L1BEA       stx L1C68+1
            sta L1C6D+1
            php
            ldx #$02
L1BF3       lda L0F49,X
            beq L1BFB
            dec L0F49,X
L1BFB       dex
            bpl L1BF3

            ldx #$02
L1C00       jsr L110C
            bne L1C35
            lda L0F43,X
            tay
            cmp L1C68+1
            bne L1C35
            lda L0F46,X
            cmp L1C6D+1
            bne L1C35
            dey
            bne L1C1C
            tay
            beq L1C5E
L1C1C       jsr L16FE
            plp
            bcs L1C34
L1C22       ldy L0045
            lda #$00
L1C26       dey
            sta (L0043),Y
            bne L1C26

L1C2B       ldx #$00
            asl L0F40,X
            sec
            ror L0F40,X
L1C34       rts

L1C35       dex
            bpl L1C00
            stx L1C47+1
            inx
            stx L1C56+1
L1C3F       lda L0F40,X
L1C42       beq L1C47
            lda L0F49,X
L1C47       cmp #$FF
            bcs L1C51
            sta L1C47+1
            stx L1C56+1
L1C51       inx
            cpx #$03
            bcc L1C3F
L1C56       ldx #$00
            jsr L1B13
            ldx L1C56+1
L1C5E       jsr L16FE
            lda L0E39
            sta L0F40,X
            tay
L1C68       lda #$00
            sta L0F43,X
L1C6D       lda #$00
            sta L0F46,X
            plp
            bcc L1C22
            ldx L1C68+1
            clc
            jmp L1B2B

L1C7C       jsr MOVE_CALL
            dta b($22,$B0,$5B)
            dta b($9D,$8A)

            ora (L0043),Y
            sta (L0043),Y

            jsr MOVE_CALL
            dta b($1C,$2B)
            dta b($22,$79,$D7)
            dta b($A2,$CE,$D5)

            ldy #$04
L1C95       lsr L0E5F+1
            ror L0E5F
            dey
            bne L1C95

            jsr ADC_1
            dta a(L0E5A)

L1CA3       ldx L0E39
            sec
            ror L0E4C,x
L1CAA       rts

L1CAB       ldx #$0A
L1CAD       lda L0E16,X
            cmp #'?'
            beq L1CB7
            sta L0E27,X
L1CB7       dex
            bpl L1CAD
            rts

L1CBB       sec
            dta b(op_BIT_zp)
L1CBD       clc
            php
            lsr L0E21
            plp
            rol L0E21
L1CC6       rts

L1CC7       dta l(L1CAB,L1D34,L1CC6,L1CBB,L1CBD)
L1CCC       dta h(L1CAB,L1D34,L1CC6,L1CBB,L1CBD)

            tya
            and #$07
            pha
            tay
            lda L1CC7,Y
            sta L1D01+1
L1CDC       lda L1CCC,Y
            sta L1D01+2
            lda L0DFE,Y
            sta L1D12+1
            jsr L159C
            pla
            bne L1CFC

            jsr MOVE_CALL
            dta b($2B,$81,$97)
            dta b($1A,$23)
            dta b($2B,$81,$8C)
            dta b($AB,$97,$81)

L1CFC       jsr L1D0D
            bne L1D3D
L1D01       jsr L1CAA
            jsr L139B
            jsr L1D0D
            beq L1D01
            rts

L1D0D       jsr L1DBF
            bne L1D19
L1D12       lda #$00
            and L0E21
            bne L1D0D
L1D19       rts

            lda #$24
L1D1C       jsr L159E
            ldx #$0A
            lda #'?'
L1D23       sta L0E0B,X
            dex
            bpl L1D23
            jsr L1DBF
            beq L1D40
            jsr L159C
            jsr L1DC5

L1D34       lda L0E21
            lsr @
            bcc L1D45
            ldy #$A4
            dta b(op_BIT_abs)
L1D3D       ldy #$AA
            dta b(op_BIT_abs)
L1D40       ldy #$A7
            jmp RET_ERR2

L1D45       lda #$10 
            sta L0E21
            jsr L139B

L1D4D       jsr MOVE_CALL
            dta b($22,$B9,$BF)
            dta b($22,$98,$B9)
            dta b($15,$0F)
            dta b($A1,$79,$B5)

L1D5B       jsr L12F6
            beq L1D63
            jsr L1C7C
L1D63       ldy L0045
            dey
            dey
            cpy L0E3F
            bne L1D5B

            jsr MOVE_CALL
            dta b($22,$B3,$B0)
            dta b($1C,$7C)
            dta b($8F,$4C)

            ldy #$00
            lda (L0043),Y
            iny
            ora (L0043),Y
            bne L1D5B

            jsr MOVE_CALL
            dta b($22,$BF,$B9)
            dta b($95,$0C)

            jmp L139E

L1D8A       lda L0DE5
L1D8D       ldx L0DE5+1
            ldy #$03
L1D92       pha
            txa
            lsr @
            tax
            pla
            ror @
            dey
            bne L1D92
            jsr L14FD
            sta L1DBC+1
            txa
            clc
            adc L0E5D
            tax
            lda #$00
            adc L0E5D+1
            jsr L1BE9
            lda L0DE5
            and #$07
            tay
            lda #$00
            sec
L1DB8       ror @
            dey
            bpl L1DB8
L1DBC       ldy #$00
            rts

L1DBF       lda #$80
            dta b(op_BIT_abs)
            lda L0049
            dta b(op_BIT_abs)
L1DC5       lda #$20
            sta L1DF3+1

            jsr MOVE_CALL
            dta b($A2,$68,$C1)

L1DD0       jsr MOVE_CALL
            dta b($A2,$B6,$5D)

            bit L0E41
            bmi L1E19
            jsr L13AE
            bmi L1E19
            lda L0E21
            beq L1E19
            and #$08
            bne L1DF3
            bit L0E4C
            bpl L1DD0
            jsr L1E10
            beq L1DD0

L1DF3       lda #$00
            bmi L1DFE
            eor L0E21
            and #$20
            bne L1DD0
L1DFE       ldx #$0B
L1E00       lda L0E0A,X
            cmp #$3F
            beq L1E0C
            cmp L0E26,X
            bne L1DD0

L1E0C       dex
            bne L1E00
            txa
L1E10       pha

            jsr MOVE_CALL
            dta b($A2,$5D,$C1)

            pla
            rts

L1E19       lda #$FF
            bit L0E4C
            bmi L1E10
            tax
            rts

            stx L1ED5+1
            lda ICAX2Z
            sta L1EDA+1
            ldy #$22
            jsr L1ED1
            bmi L1E61
            lda ICHIDZ
            sta IOCB0,X
            jsr L1E7D
            bmi L1E5C
            ldy #$98
            bcc L1E5C
            ror L1E49+1
L1E42       jsr L1E7D
            bmi L1E5C
            bcs L1E42
L1E49       lda #$00 
            bpl L1E57
            lsr L1E49+1

            jsr MOVE_CALL
            dta b($D1,$86,$42,$E0)

L1E57       jsr L1E92
            bpl L1E42

L1E5C       lda #$FF
            sta IOCB0,X
L1E61       tya
            pha
            ldy #$2D
            jsr L1ED1
            pla
            tay
            cpy #$88
            bne L1E91

            jsr MOVE_CALL
            dta b($42,$E0,$4D,$13)
            dta b($CD,$13,$4D,$36)

            lda #$E0
            bne L1EC2

L1E7D       jsr MOVE_CALL
* MOVE L1E89, L1427, 3
            dta b($5E,$89,$54,$27)
* CALL L1EC9
            dta b($9E,$C9)

            bmi L1E91
            lda L1185+1
            and L1185+2
            cmp #$FF
            tya
L1E91       rts

L1E92       jsr MOVE_CALL
            dta b($5D,$9C,$42,$E2)
            dta b($5C,$AE,$54,$27)
            dta b($9E,$C9)

            bmi L1E91
            sec
            ldx #$FE
L1EA4       lda L0E16-$FE,X
            sbc L1185+1-$FE,X
            sta L0E51-$FE,X
            inx
            bne L1EA4

            jsr ADC_1
            dta a(L0E51)

            jsr MOVE_CALL
            dta b($51,$86,$54,$27)
            dta b($9E,$CF)

            bmi L1E91
            lda #$E2
L1EC2       jsr L1EDA
            cld
            ldy #$01
            rts

            jsr MOVE_CALL
* MOVE8 L0E03, L0E51, 3
            dta b($A2,$79,$C7)

            ldy #$2E
L1ED1       ldx #$00
            stx L0048
L1ED5       ldx #$00
            jmp L0FAC

L1EDA       ldx #$00
            bmi L1E91
            sta L1EE1+1
L1EE1       jmp (RUNAD)

END_ADDR    equ *

            blk dos RUNAD
            dta a(start)
