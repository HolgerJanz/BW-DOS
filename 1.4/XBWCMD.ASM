* vector tab for commands called via RTS opcode
CMD_TAB_L   dta l(CMD_CAR_V,CMD_RUN_V,CMD_PRINT_V,CMD_TYPE_V)
            dta l(CMD_DIR_V,CMD_DIRS_V,CMD_BASIC_V,CMD_TYPE_V)
CMD_TAB_H   dta h(CMD_CAR_V,CMD_RUN_V,CMD_PRINT_V,CMD_TYPE_V)
            dta h(CMD_DIR_V,CMD_DIRS_V,CMD_BASIC_V,CMD_TYPE_V)

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
            bne L0733
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
            cmp #':'
            beq L07A1
L0789       lda LBUF+2,Y
            cmp #':'
L078E       beq L0795
L0790       ldy <PROMPTD-LBUF
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
L07AD       lda #$31
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
HATAB_D     dta a(OPEN_V)
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
            jsr JMP_DOSDINI
JMP_COMTAB  jmp COMTAB

L07F2       jsr MOVE_CALL
  dta h(MC_mov+SMEMLO),l(SMEMLO),h(MC_2+MEMLO),l(MEMLO)
  dta h(MC_mov+JMP_COMTAB+1),l(JMP_COMTAB+1),h(MC_2+DOSVEC),l(DOSVEC)
  dta h(MC_movE+INIFLAGS),l(INIFLAGS),h(MC_2+ECHOFLG),l(ECHOFLG)

            txa
L0802       sta L0E4C,X
            cpx #$97
            bcc L080C
            dec L0E3F+1,X
L080C       inx
            bne L0802
            tay
            dta b(op_BIT_abs)
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
L0839       lda HATABS_D-$FD,X
L083C       sta HATABS,Y
            iny
            inx
            bne L0839
L0843       rts

HATABS_D    dta c'D',a(HATAB_D)

JMP_DOSDINI jmp (DOSINI)

* date time buffer
DATTIMBUF   dta b(INI_DAY,INI_MONTH,INI_YEAR)
            dta b(INI_HOUR,INI_MINUTE,INI_SECOND)

* set time date
SETTD       jsr MOVE_CALL
  dta h(MC_movE+DATER),l(DATER),h(MC_6+DATTIMBUF),l(DATTIMBUF)

* get time data
GETTD       jsr MOVE_CALL
  dta h(MC_movE+DATTIMBUF),l(DATTIMBUF),h(MC_6+DATER),l(DATER)

_RTS        rts

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

* print error number
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
            jsr L0B28
            stx LMARGN
            stx TDOVER
            stx BUFOFF
            dex
L09EC       stx INCMND
            txs
* close IOCB1
            jsr DO_CIO
            dta b($C4,$0C)
L09F5       dta a(L0AAD_V,L0ACA_V)
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
L0A3A       dta b($10,$08)
L0A3C       dta b($40,$50)

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
L0AAD       txa
L0AAD_V     equ L0AAD-1
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
L0ACA       cpx #$00
L0ACA_V     equ L0ACA-1
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
* $ff is updated at start with offset for E:
L0AF2 dta h(MC_mov+L0B38+1),l(L0B38+1),h(MC_2+HATABS),b($FF)
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
* $ff is updated at start with offset for E:
L0B32 dta h(MC_movE+HATABS),b($FF),h(MC_2+L0B38+1),l(L0B38+1)

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
* $ff is updated at start with offset for E:
L0B65 dta h(MC_mov+L0B3B+1),l(L0B3B+1),h(MC_2+HATABS),b($FF)
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
* extension *.bat
            ldy <EXT_BAT-LBUF
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
            dta c'RE',b($CE)       ; 32
            dta c'DE',b($CC)       ; 33
            dta b($9B)
            dta c'PRO',b($D4)      ; 35
            dta c'UNPRO',b($D4)    ; 36
ERROR1      dta b($9B)
ERROR2      dta c'Error',b($9B)
            dta b($9B)
L0BE9       dta b($90)
            dta b($94)
            dta c'M',b($C4)        ; 42
            dta c'R',b($C4)        ; 43
            dta c'C',b($C4)        ; 44
            dta c'LOA',b($C4)
*  called via CMD_TAB_H/L
            dta c'CA',b($D2)
            dta c'RU',b($CE)
            dta c'PRIN',b($D4)
            dta c'TYP',b($C5)
            dta c'DI',b($D2)
            dta c'DIR',b($D3)
            dta c'BASI',b($C3)
            dta c'MA',b($CE)
            dta b($00)

            jsr L0A71
* standard execute *.com
            ldy <EXT_COM-LBUF
            jsr L07BE
            clc
L0C23       lda #$04 
            rol @
            sta L0C2C
            jsr DO_CIO_1
L0C2C       dta b($08,$28)
            dta a(COMFNAM,28)
L0C32       rts

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
CMD_DIR     lda #$0D
CMD_DIR_V   equ CMD_DIR-1
            dta b(op_BIT_abs)
CMD_DIRS    lda #$0C
CMD_DIRS_V  equ CMD_DIRS-1
            pha
            lda COMFNAM-1,X
            cmp #$38
            beq L0C97
            and #$F9
            cmp #$38
            bne L0C97
* standard *.*
            ldy <STD_PAT-LBUF
L0C94       jsr L07BE
L0C97       pla
            dta b(op_BIT_abs)

* command TYPE
CMD_TYPE    lda #$08
CMD_TYPE_V  equ CMD_TYPE-1
            sta L0CA0
            jsr DO_CIO_1
L0CA0       dta b($08,$03)
            dta a(COMFNAM,28)
L0CA6       jsr DO_CIO
            dta b($44,$07)
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
