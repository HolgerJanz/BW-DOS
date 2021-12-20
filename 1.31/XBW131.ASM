* BW-DOS 1.31
            icl 'XBW131.inc'

* 6502 opcodes
op_BIT_abs  equ $2C
op_SBC_imd  equ $E9
op_JMP_abs  equ $4C

* MOVE commands
MV_4        equ $4000
MV_8        equ $8000
MV_C        equ $C000

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
            jmp SSIOV       ;$70C jmp LSIO 4C EE 0C

CMD_TAB_L   dta l(CMD_CAR-1,CMD_RUN-1,CMD_PRINT-1,CMD_TYPE-1)
            dta l(CMD_DIR-1,CMD_DIRS-1,CMD_BASIC-1)

CMD_TAB_H   dta h(CMD_CAR-1,CMD_RUN-1,CMD_PRINT-1,CMD_TYPE-1)
            dta h(CMD_DIR-1,CMD_DIRS-1,CMD_BASIC-1)

CONV_A      sta DECIN
            lda #$00
            sta DECIN+1
            lda #$00
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

            dta a(L0F9D,L0FA0)
            dta a(L0FA3,L0FA6)
            dta a(L0FA9,L0F89)

DOS_INI     cld
            lda L0047
            bne L07F2
            dec L0047
            bit INCMND
            bpl L07F2
            jsr L0847
L07EF       jmp COMTAB
L07F2       jsr MOVE

            dta h(MV_4+SMEMLO),l(SMEMLO)
            dta h(MV_4+MEMLO),l(MEMLO)

            dta h(MV_4+L07EF+1),l(L07EF+1)
            dta h(MV_4+DOSVEC),l(DOSVEC)

            dta h(MV_C+L0DF2),l(L0DF2)
            dta h(MV_4+ECHOFLG),l(ECHOFLG)

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
L082B       cpx #$44
            beq L0837
            dey
            dey
            dey
            bpl L0825
            tay
            bmi L0843
L0837       ldx #$FD
L0839       lda L0747,X
L083C       sta HATABS,Y
            iny
            inx
            bne L0839
L0843       rts

            dta b($44,$D4,$07)
L0847       jmp (DOSINI)

* date time buffer
L084A       dta b(28,11,95)
            dta b(22,14,06)

* $850 set time date
SETTD       jsr MOVE

            dta h(MV_C+DATER),l(DATER)
            dta h(MV_C+L084A),l(L084A)

* $857 get time data
GETTD       jsr MOVE

            dta h(MV_C+L084A),l(L084A)
            dta h(MV_C+DATER),l(DATER)

L085E       rts

L085F       lda L1488+1
            dta b(op_BIT_abs)
L0863       lda #$01
            ldx #$69
            bne L086D
L0869       lda #$01
L086B       ldx #op_SBC_imd
L086D       sta L088A+1
            stx L088A
            ldx #$FE
L0875       jsr INC_PC
            sta L0789+1,X
            sta L078E+1,X
            inx
            bne L0875
            lda L088A
            asl @
            dex
L0886       inx
            lda $FFFF,X
L088A       adc #$00
            sta $FFFF,X
            stx L088A+1
            txa
            beq L0886
            rts

* command RUN
CMD_RUN     bne L089B
L0898       jmp (RUNLOC)
L089B       jsr MOVE

            dta h(MV_C+L0E00),l(L0E00)
            dta h(MV_4+RUNLOC),l(RUNLOC)

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
MOVE        jsr L0A76
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
L0957       lda L0D8A,X
            sta L0D8A,Y
            inx
            iny
            dec L0945+1
            bne L0957
L0964       lda #$00
            bpl MOVE
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
            dta a(L0BE1,6)
            pla
            jsr CONV_A
            jsr DO_CIO_0
            dta b($0B)
            dta a(DECOUT+4,4)
            jsr DO_CIO_0
            dta b($0B)
            dta a(L0BE1,1)
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
            dta a(L0D78,4)
* get command line
            jsr DO_CIO
            dta b($40,$05)
            dta a(LBUF,$40)
            jsr PARSE_LINE
            jmp _COMTAB

* Command CAR
CMD_CAR     lda LBFFD
            inc LBFFD
            cmp LBFFD
            sta LBFFD
            bne L0A92
            ldx LBFFC
            bne L0A92
            lda DWARM
            sta WARMST
            stx INCMND
            dex
            stx DWARM
            jmp (LBFFA)

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
L0A6D       dta a(L0BE2)
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

L0AEF       jsr MOVE

L0AF2       dta h(MV_4+L0B38+1),l(L0B38+1)
            dta h(MV_4+HATABS+2),l(HATABS+2)

            dta h(MV_C+L0A6D+2),l(L0A6D+2)
            dta h(MV_4+IOCB0+ICPTL),l(IOCB0+ICPTL)

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
            jsr MOVE

L0B32       dta h(MV_C+HATABS+1),l(HATABS+1)
            dta h(MV_4+L0B38+1),l(L0B38+1)

            ldx #$0B
L0B38       lda LFFFF,X
L0B3B       sta L0A98,X
            dex
            bpl L0B38
            jsr MOVE

            dta h(MV_4+L0A9C),l(L0A9C)
            dta h(MV_8+L09B8),l(L09B8)

            dta h(MV_4+L0A9E),l(L0A9E)
            dta h(MV_4+L0A6F),l(L0A6F)

            dta h(MV_C+L09F5),l(L09F5)
            dta h(MV_8+L0A9C),l(L0A9C)

            jsr L0863
            dta a(L09B8)

            jsr L0863
            dta a(L09BA)

L0B5A       lda ECHOFLG
            and BATFLG
            bmi L0AEF
            jsr MOVE

L0B65       dta h(MV_4+L0B3B+1),l(L0B3B+1)
            dta h(MV_4+HATABS+2),l(HATABS+2)

            dta h(MV_C+L0A9E),l(L0A9E)
            dta h(MV_4+IOCB0+ICPTL),l(IOCB0+ICPTL)

            beq L0AFA
CMD_PRINT   bne L0BA0
            lda COMFNAM
            cmp L0D79
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
            jsr MOVE

            dta h(MV_C+COMFNAM),l(COMFNAM)
            dta h(MV_4+L0D79),l(L0D79)

L0BC1       rts

PARSE_CMD   jsr INT_CMD
* begin statement table
* called via CIO
            dta c'RENAM',b($C5)
            dta c'ERAS',b($C5)
            dta b($9B)
            dta c'PROTEC',b($D4)
            dta c'UNPROTEC',b($D4)
L0BE1       dta b($9B)
L0BE2       dta c'Error',b($9B,$9B)
L0BE9       dta b($90,$94)
            dta c'M',b($C4)
            dta c'R',b($C4)
            dta c'C',b($C4)
            dta c'LOA',b($C4)
* called via CMD_TAB_H/L
            dta c'CA',b($D2)
            dta c'RU',b($CE)
            dta c'PRIN',b($D4)
            dta c'TYP',b($C5)
            dta c'DI',b($D2)
            dta c'DIR',b($D3)
            dta c'BASI',b($C3)
            dta b($00)
* CHANGE: 9 free bytes, e.g. CREDIR is now MD etc.
* we use them to set left margin to 0 at DOS entry
            beq *+9    ; jump over init code
ext_init    lda #$00
            sta $52    ; left margin 0
            jmp L0B28  ; continue DOS entry
* end statement table

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

INT_CMD     ldx #$FF
            stx FMSZPG
L0C37       ldx #$00
            ldy #$00
            inc FMSZPG
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
            lda FMSZPG
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
CMD_DIRS    eor #$12
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
            sta L0CA0
            jsr DO_CIO_1
L0CA0       dta b($08,$03)
            dta a(COMFNAM,28)
L0CA6       jsr DO_CIO
L0CA9       dta b($44,$07)
            dta a(LBUF)
            dta a(64)
            php
            jsr MOVE

            dta h(MV_C+IOCB1+ICBLL),l(MV_C+IOCB1+ICBLL)
            dta h(MV_4+L0CBE),l(MV_4+L0CBE)

            jsr DO_CIO
            dta b($40,$0B)
            dta a(LBUF)
L0CBE       dta a($40)
            plp
            bpl L0CA6
            rts

L0CC4       sta FMSZPG+2
            txa
            pha
            ldx ECHOFLG,Y
            lda HATABS+1,X
            sta FMSZPG
            lda HATABS+2,X
            sta FMSZPG+1
            ldx L0A3C,Y
            pla
            tay
            lda (FMSZPG),Y
            pha
            dey
            lda (FMSZPG),Y
            pha
            lda FMSZPG+2
            rts

* Start of COMTAB
DWARM       dta b($FF)             ; -21
            dta b($80)             ; -20 ???
DECOUT      dta b($20,$20,$20,$20) ; -19
            dta b($20,$20,$20,$20)
SSIOV       dta b(op_JMP_abs)      ; -13 jmp SIO
LSIO        dta a(SIOV)            ; -10
ECHOFLG     dta b($ff)             ; -8
BATFLG      dta b($FF)             ; -7
DECIN       dta b($00,$00,$00,$00) ; -6
WRTCMD      dta c'P'               ; -2 W=verify P=no verify
SWARMST     dta b($FF)             ; -1 00 in CP, $FF trap errors
; DOSVEC => $0cf9
COMTAB      jmp _COMTAB            ; COMTAB Jump to DOS CP
CRNAME      jmp _CRNAME            ; +3
DIVIO       dta a(R_DIVIO)         ; +6
XDIVIO      dta a(R_XDIVIO)        ; +8
BUFOFF      dta b($00)             ; +10
ZORIG       dta a(BW_BEGIN)        ; +11
DATER       dta b($1C,$0B,$5F)     ; +13 28.11.95
TIMER       dta b($16,$0E,$06)     ; +16 22:14:06
ODATER      dta b($1C,$0B,$5F)     ; +19
OTIMER      dta b($16,$0E,$06)     ; +22
TDOVER      dta b($00)             ; +25
TRUN        dta a(L085E)           ; +26
            dta a(L1711)           ; +28 ??? buffer address ???
SMEMLO      dta a(END_ADDR)        ; +30 start up MEMLO
INCMND      dta b($00)             ; +32 Reset $00-CP $FF-Cart
COMFNAM     dta c'D1:STARTUP.BAT'  ; +33 28 Bytes
            dta b($9B)
            dta c'             '
RUNLOC      dta a(L085E)           ; COMTAB+61 address for RUN
* start code to check for STARTUP.BAT
LBUF        jsr L07F2              ; COMTAB+63 comman line buffer 64 Bytes
            lda #$FF
            sta FMSZPG+4
            ldy #$01
L0D41       jsr R_DIVIO
            jsr L0A71
L0D47       stx COLDST
            lda BOOT
L0D4C       ora #$01
            sta BOOT
            jmp _COMTAB
L0D53       clc
            rts
            dta c'                          '
L0D6F       dta c'         '
* end of LBUF and COMTAB

L0D78       dta b($9B)
L0D79       dta c'D1:'
            dta b($9B)
            dta c'.BAT'
            dta b($9B)
            dta c'.COM'
            dta b($9B)
            dta c'*.*'
L0D8A       dta b($9B)
            dta c'Volume:          '
L0D9C       dta c' '
L0D9D       dta c'                    '
L0DB1       dta c' '
L0DB2       dta c'                   '
L0DC5       dta c' '
            dta b($9B)
            dta c'Directory:'
            dta b($C4,$C9,$D2) ; DIR inverse
            dta c'<DIR>FREE SECTORS'
L0DE5       dta b($00)
L0DE6       dta b($00,$00,$00)
L0DE9       dta b($80)
            dta c'    '
L0DEE       dta c' '
L0DEF       dta c' '
L0DF0       dta c'  '
L0DF2       dta b($FF,$FF)
            dta c'DOS       '
L0DFE       dta c' !'
L0E00       dta b($00,$00,$00,$02,$00)
            dta b($1C,$17,$00,$01,$00)
L0E0A       dta b($2d)

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
; E: not found => Self Test
            jmp SELFSV

; update HATABS
_e_found    inx
            stx L0B32+1
            stx L0B65+3
            stx L0AF2+3
            inx
            stx L0B28+1
* move dos_iniv to DOSINI
            jsr MOVE
            
            dta h(MV_C+dos_iniv),l(MV_C+dos_iniv)
            dta h(MV_4+DOSINI),l(MV_4+DOSINI)

* print BW-DOS version
            jsr DO_CIO_0
            dta b($0B)
            dta a(dos_text,dos_text_e-dos_text)
            jmp LBUF

dos_iniv    dta a(DOS_INI)
dos_text    dta b($9B)
            dta c'BW-DOS 1.31 BEWESOFT 2021-12-18'
            dta b($9B)
dos_text_e  equ *

* buffer addresses $0E0B-$0F4B ($141 Bytes)
L0E16       equ start+$0B
L0E21       equ start+$16
L0E26       equ start+$1B
L0E27       equ start+$1C
L0E38       equ start+$2D
L0E3B       equ start+$30
L0E3E       equ start+$33
L0E3F       equ start+$34
L0E41       equ start+$36
L0E42       equ start+$37
L0E45       equ start+$3A
L0E48       equ start+$3D
L0E4C       equ start+$41
L0E4D       equ start+$42
L0E51       equ start+$46
L0E52       equ start+$47
L0E55       equ start+$4A
L0E58       equ start+$4D
L0E5D       equ start+$52
L0E5F       equ start+$54
L0E6B       equ start+$60
L0ED7       equ start+$CC
L0ED8       equ start+$CD
L0F15       equ start+$10A
L0F38       equ start+$12D
L0F40       equ start+$135
L0F43       equ start+$138
L0F46       equ start+$13B
L0F49       equ start+$13E


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
            blk dos start+$141 ;$0F4C
;
L0F4C       ldx L0E3B+2            ; AE 3D 0E
            lda L0E3E              ; AD 3E 0E
            jsr L1BE9              ; 20 E9 1B
            ldy L0E3F              ; AC 3F 0E
L0F58       rts                    ; 60
L0F59       lda L0F58,Y            ; B9 58 0F
            and #$1F               ; 29 1F
            pha                    ; 48
            lda L0F46,Y            ; B9 46 0F
            pha                    ; 48
            ldx FMSZPG+3           ; A6 46
            rts                    ; 60
            bne L0F38              ; D0 D0
            stx L00D0,Y            ; 96 D0
            bne L0F9D              ; D0 31
            inx                    ; E8
            .byte $EB
            and (L008F,X)          ; 21 8F
            .byte $89
            ora L7C94,Y            ; 19 94 7C
            inx                    ; E8
            .byte $53
            sty LFC95              ; 8C 95 FC
            .byte $FC
            sta L00FC,X            ; 95 FC
            .byte $FC,$34
            rol LTEMP,X            ; 36 36
            rol LF5D5,X            ; 3E D5 F5
            sbc L53FA,X            ; FD FA 53
            .byte $12
            sbc (RTCLOK),Y         ; F1 12
L0F89       .byte $12
            ldy ICCOMZ             ; A4 22
            sta L10DB+1            ; 8D DC 10
            tya                    ; 98
            and #$F0               ; 29 F0
            cmp #$20               ; C9 20
            bne L0F9B              ; D0 05
            and L0F58,Y            ; 39 58 0F
            bne L0FAF              ; D0 14
L0F9B       ldy #$A8               ; A0 A8
L0F9D       rts                    ; 60
            ldy #$22               ; A0 22
L0FA0       bit L2DA0              ; 2C A0 2D
L0FA3       bit L30A0              ; 2C A0 30
L0FA6       bit L31A0              ; 2C A0 31
L0FA9       bit L29A0              ; 2C A0 29
L0FAC       sta L10DB+1            ; 8D DC 10
L0FAF       cld                    ; D8
            stx FMSZPG+3           ; 86 46
            lda #$01               ; A9 01
            sta L10BA+1            ; 8D BB 10
            cpy #$28               ; C0 28
            bne L0FC4              ; D0 09
            jsr L0F59              ; 20 59 0F
L0FBE       bit LA1A0              ; 2C A0 A1
L0FC1       jmp L10DB              ; 4C DB 10
L0FC4       tsx                    ; BA
            stx L10C2+1            ; 8E C3 10
            inx                    ; E8
            inx                    ; E8
            lda L0100,X            ; BD 00 01
            sta L12A2+1            ; 8D A3 12
            sty L109B+1            ; 8C 9C 10
            lda L0F58,Y            ; B9 58 0F
            and #$C0               ; 29 C0
            sta L0FEB+1            ; 8D EC 0F
            ldx FMSZPG+3           ; A6 46
            jsr L1121              ; 20 21 11
            bne L0FEB              ; D0 09
            bit L0FEB+1            ; 2C EC 0F
            bpl L1000              ; 10 19
            ldy #$81               ; A0 81
            bne L0FC1              ; D0 D6
L0FEB       lda #$00               ; A9 00
            bpl L1023              ; 10 34
            ldx #$FF               ; A2 FF
            jsr L1121              ; 20 21 11
            bne L0FBE+1            ; D0 C9
            lda FMSZPG+3           ; A5 46
            sta L0ED7,Y            ; 99 D7 0E
            lda ICDNOZ             ; A5 21
            sta L0ED8,Y            ; 99 D8 0E
L1000       sty L10CC+1            ; 8C CD 10
            ldx #$EB               ; A2 EB
L1005       lda L0ED7,Y            ; B9 D7 0E
            sta L0D4C+1,X          ; 9D 4D 0D
            iny                    ; C8
            inx                    ; E8
            bne L1005              ; D0 F6
            ldy #$68               ; A0 68
L1011       lda L0E55,Y            ; B9 55 0E
            cmp L0E38+1            ; CD 39 0E
            beq L102F              ; F0 16
            tya                    ; 98
            sec                    ; 38
            sbc #$1A               ; E9 1A
            tay                    ; A8
            bcs L1011              ; B0 F1
            jsr L10BE              ; 20 BE 10
L1023       ldy #$85               ; A0 85
            lda L109B+1            ; AD 9C 10
            cmp #$2D               ; C9 2D
            bne L0FC1              ; D0 95
            jmp L10BA              ; 4C BA 10
L102F       ldx #$E6               ; A2 E6
L1031       lda L0D6F,X            ; BD 6F 0D
            pha                    ; 48
            lda L0E55,Y            ; B9 55 0E
            sta L0D6F,X            ; 9D 6F 0D
            pla                    ; 68
            sta L0E55,Y            ; 99 55 0E
            iny                    ; C8
            inx                    ; E8
            bne L1031              ; D0 EE
            bit L0FEB+1            ; 2C EC 0F
            bpl L1093              ; 10 4B
            jsr L1BE5              ; 20 E5 1B
            ldy #$07               ; A0 07
            lda (FMSZPG),Y         ; B1 43
            cmp #$80               ; C9 80
            bne L105B              ; D0 08
            lda #$1F               ; A9 1F
            tay                    ; A8
            iny                    ; C8
            cmp (FMSZPG),Y         ; D1 43
            bcc L105E+1            ; 90 04
L105B       jsr L10BE              ; 20 BE 10
L105E       sty L00A0,X            ; 94 A0
L1060       asl L00B9,X            ; 16 B9
            eor LD10E              ; 4D 0E D1
            .byte $43
            bne L107D              ; D0 15
            iny                    ; C8
            cpy #$1E               ; C0 1E
            bcc L1060+1            ; 90 F4
            ldy #$26               ; A0 26
L106F       lda L0E45,Y            ; B9 45 0E
            cmp (FMSZPG),Y         ; D1 43
            bne L107D              ; D0 07
            iny                    ; C8
            cpy #$28               ; C0 28
            bcc L106F              ; 90 F4
            bcs L1093              ; B0 16
L107D       lda #$99               ; A9 99
            jsr L1131              ; 20 31 11
            iny                    ; C8
            lda (FMSZPG),Y         ; B1 43
            ldy L0E38+1            ; AC 39 0E
L1088       sta L0DE9,Y            ; 99 E9 0D
            jsr MOVE              ; 20 19 09
            .byte $22,$CC,$E3,$91,$14
L1093       ldy L0E38+1            ; AC 39 0E
            lda L0DE9,Y            ; B9 E9 0D
            sta FMSZPG+2           ; 85 45
L109B       ldy #$00               ; A0 00
            jsr L0F59              ; 20 59 0F
            bit L0FEB+1            ; 2C EC 0F
            bvc L10AB              ; 50 06
            jsr L10E2              ; 20 E2 10
            stx L0E38              ; 8E 38 0E
L10AB       ldy L10CC+1            ; AC CD 10
            ldx #$EB               ; A2 EB
L10B0       lda L0D4C+1,X          ; BD 4D 0D
            sta L0ED7,Y            ; 99 D7 0E
            iny                    ; C8
            inx                    ; E8
            bne L10B0              ; D0 F6
L10BA       ldy #$01               ; A0 01
            bne L10DB              ; D0 1D
L10BE       jsr INC_PC              ; 20 C5 08
            tay                    ; A8
L10C2       ldx #$00               ; A2 00
            txs                    ; 9A
            tya                    ; 98
            pha                    ; 48
            lda L0FEB+1            ; AD EC 0F
            beq L10D3              ; F0 07
L10CC       ldy #$00               ; A0 00
            lda #$FF               ; A9 FF
            sta L0ED7,Y            ; 99 D7 0E
L10D3       jsr L10E2              ; 20 E2 10
            jsr L1114              ; 20 14 11
            pla                    ; 68
            tay                    ; A8
L10DB       lda #$00               ; A9 00
            ldx FMSZPG+3           ; A6 46
            cpy #$00               ; C0 00
            rts                    ; 60
L10E2       ldx L0E38+1            ; AE 39 0E
            lda L0E4C,X          ; BD 4C 0E
            bpl L10FB              ; 10 11
            lsr L0E4C,X          ; 5E 4C 0E
            jsr L1BE5              ; 20 E5 1B
            jsr L1C2B              ; 20 2B 1C
            inc L0E6B              ; EE 6B 0E
            lda #$B9               ; A9 B9
            jsr L1131              ; 20 31 11
L10FB       ldx #$03               ; A2 03
L10FD       dex                    ; CA
            bmi L1113              ; 30 13
            jsr L110C              ; 20 0C 11
            bne L10FD              ; D0 F8
            bcc L10FD              ; 90 F6
L1107       jsr L1B11+2            ; 20 13 1B
            bpl L10FB              ; 10 EF
L110C       lda L0F40,X            ; BD 40 0F
            eor L0E38+1            ; 4D 39 0E
            asl                    ; 0A
L1113       rts                    ; 60
L1114       ldx #$02               ; A2 02
L1116       jsr L110C              ; 20 0C 11
            bne L111E              ; D0 03
            sta L0F40,X            ; 9D 40 0F
L111E       dex                    ; CA
            bpl L1116              ; 10 F5
L1121       ldy #$54               ; A0 54
L1123       txa                    ; 8A
            cmp L0ED7,Y            ; D9 D7 0E
            beq L1130              ; F0 07
            tya                    ; 98
            sec                    ; 38
            sbc #$15               ; E9 15
            tay                    ; A8
            bcs L1123              ; B0 F3
L1130       rts                    ; 60
L1131       sta L1149              ; 8D 49 11
            sta L113B              ; 8D 3B 11
            ldy #$26               ; A0 26
L1139       lda (FMSZPG),Y         ; B1 43
L113B       sta L0E45,Y            ; 99 45 0E
            sta (FMSZPG),Y         ; 91 43
            iny                    ; C8
            cpy #$28               ; C0 28
            bcc L1139              ; 90 F4
            ldy #$09               ; A0 09
L1147       lda (FMSZPG),Y         ; B1 43
L1149       lda L0E4D,Y            ; B9 4D 0E
            sta (FMSZPG),Y         ; 91 43
            iny                    ; C8
            cpy #$1E               ; C0 1E
            bcc L1147              ; 90 F4
            rts                    ; 60
            jsr MOVE              ; 20 19 09
            cpy #$28               ; C0 28
            eor (L0086),Y          ; 51 86
            ldy #$20               ; A0 20
            jsr L1181+1            ; 20 82 11
            ldy #$1F               ; A0 1F
            jsr L1181+1            ; 20 82 11
            ldy #$0B               ; A0 0B
L1167       jsr L1181+1            ; 20 82 11
            cpy #$0F               ; C0 0F
            bcc L1167              ; 90 F9
            ldy #$16               ; A0 16
L1170       jsr L1181+1            ; 20 82 11
            cpy #$1E               ; C0 1E
            bcc L1170              ; 90 F9
            ldy #$26               ; A0 26
            jsr L1181+1            ; 20 82 11
            jsr L1181+1            ; 20 82 11
            lda #$00               ; A9 00
L1181       bit L43B1              ; 2C B1 43
            iny                    ; C8
L1185       sta LFFFF,X            ; 9D FF FF
            inx                    ; E8
            rts                    ; 60

L118A       ldx #$FD               ; A2 FD
L118C       lda DECOUT+4            ; AD EA 0C
            cmp #$20               ; C9 20
            bne L1196+1            ; D0 04
            lda DECOUT+5-$FD,X            ; BD EE 0B
L1196       bit L39A9              ; 2C A9 39
            ora #$30               ; 09 30
            sta DECOUT+5-$FD,X            ; 9D EE 0B
            inx                    ; E8
            bne L118C              ; D0 EB
            rts                    ; 60
L11A2       jsr L14DA              ; 20 DA 14
            sta (ICHIDZ),Y         ; 91 20
            ora L1107+2,Y          ; 19 09 11
            txa                    ; 8A
            jmp L6DEB              ; 4C EB 6D
            sta L4FAC,X            ; 9D AC 4F
            .byte $17
            beq L1215              ; F0 61
L11B4       jsr MOVE              ; 20 19 09
            .byte $4E,$5A,$4C,$F3
            .byte $87,$25,$A2
L11BE       .byte $00
            bpl L11A2              ; 10 E1
            jsr L14DA              ; 20 DA 14
            sty ICHIDZ,X           ; 94 20
            ora L4C09,Y            ; 19 09 4C
            inx                    ; E8
            cmp LAC9D              ; CD 9D AC
            .byte $4F,$1A
            beq L1215              ; F0 44
L11D1       jsr L14DA              ; 20 DA 14
            .byte $12
            jsr MOVE              ; 20 19 09
            .byte $AB
            sta LAD15,X            ; 9D 15 AD
            and (APPMHI,X)         ; 21 0E
            lsr                    ; 4A
            bcc L11E6              ; 90 05
            ldx #$2A               ; A2 2A
            stx L0D9D              ; 8E 9D 0D
L11E6       and #$10               ; 29 10
            beq L11EF+1            ; F0 06
            jsr MOVE              ; 20 19 09
            .byte $A3,$47
L11EF       ora L24AD,X            ; 1D AD 24
            asl L25AE              ; 0E AE 25
            asl L26AC              ; 0E AC 26
            asl LFD20              ; 0E 20 FD
            .byte $14
            cmp #$00               ; C9 00
            beq L1204              ; F0 04
            inx                    ; E8
            bne L1204              ; D0 01
            iny                    ; C8
L1204       stx DECIN              ; 8E F3 0C
            sty DECIN+1              ; 8C F4 0C
            jsr MOVE              ; 20 19 09
            .byte $07
            and BRKKEY             ; 25 11
            txa                    ; 8A
            cpy L6DEB              ; CC EB 6D
            .byte $AB
L1215       beq L1274              ; F0 5D
L1217       jsr MOVE              ; 20 19 09
            .byte $2B
            php                    ; 08
            sta (L009D,X)          ; 81 9D
            .byte $BF
            bne L11B4              ; D0 93
            bit L11BE              ; 2C BE 11
            bpl L11D1              ; 10 AB
            jsr L14DA              ; 20 DA 14
            bit ICHIDZ             ; 24 20
            ora L2809,Y            ; 19 09 28
            sta L2313,X            ; 9D 13 23
            lda ABUFPT             ; A5 1C
            and ZCHAIN             ; 25 4A
            jsr L8021              ; 20 21 80
            and #$21               ; 29 21
            .byte $80
            bit L07A1              ; 2C A1 07
            .byte $32
            lda L0E21            ; AD 21 0E
            and #$20               ; 29 20
            bne L1252+1            ; D0 0D
            jsr MOVE              ; 20 19 09
            lsr L6C24              ; 4E 24 6C
            .byte $F3,$07
            rol                    ; 2A
            cpy LEDE7              ; CC E7 ED
L1252       lda #$A0               ; A9 A0
            .byte $FB
L1255       txa                    ; 8A
            pha                    ; 48
            lda RUNLOC+1,Y          ; B9 37 0D
            jsr CONV_A              ; 20 1D 07
            jsr L118A              ; 20 8A 11
            pla                    ; 68
            tax                    ; AA
            lda DECOUT+6              ; AD EC 0C
            sta L0DB1,X            ; 9D B1 0D
            lda DECOUT+7            ; AD ED 0C
            sta L0DB2,X            ; 9D B2 0D
            inx                    ; E8
            inx                    ; E8
            inx                    ; E8
            iny                    ; C8
            bne L1255              ; D0 E1
L1274       dec L1283+1            ; CE 84 12
L1277       ldx #$00               ; A2 00
            lda L0D9D,X            ; BD 9D 0D
            inc L1277+1            ; EE 78 12
            sta L10DB+1            ; 8D DC 10
            rts                    ; 60
L1283       lda #$00               ; A9 00
            asl                    ; 0A
            bne L1274              ; D0 EC
            bcs L12EE              ; B0 64
            jmp L1217              ; 4C 17 12
            ldx L0E48              ; AE 48 0E
            cpx #$16               ; E0 16
            beq L1283              ; F0 EF
            lda #$6A               ; A9 6A
            eor #$6A               ; 49 6A
            sta FMSZPG+5           ; 85 48
            and #$0C               ; 29 0C
            eor #$07               ; 49 07
            cmp ICCOMZ             ; C5 22
            bne L12DF              ; D0 3D
L12A2       lda #$00               ; A9 00
            cmp #$E4               ; C9 E4
            bcc L12DF              ; 90 37
            ldy ICBLHZ             ; A4 29
            bne L12B1              ; D0 05
            iny                    ; C8
            cpy ICBLLZ             ; C4 28
            bcs L12DF              ; B0 2E
L12B1       jsr MOVE              ; 20 19 09
            rti                    ; 40
            bit ROWCRS             ; 24 54
            .byte $27
            rti                    ; 40
            plp                    ; 28
            lsr L9351              ; 4E 51 93
            ror                    ; 6A
            php                    ; 08
            jsr MOVE              ; 20 19 09
            .byte $54,$27
            rti                    ; 40
            bit L00CE              ; 24 CE
            eor (FREQ),Y           ; 51 40
            plp                    ; 28
            plp                    ; 28
            bmi L12EE              ; 30 21
            jsr L0869              ; 20 69 08
            bit L0000              ; 24 00
            lda (ICSTAZ,X)         ; A1 23
            inc ICBLLZ             ; E6 28
            sta L10DB+1            ; 8D DC 10
L12D9       jsr L14BF              ; 20 BF 14
            beq L12F0              ; F0 12
            rts                    ; 60
L12DF       jsr MOVE              ; 20 19 09
            .byte $52,$D7,$54,$27
            ldx #$7E               ; A2 7E
            .byte $C7
            jsr L136A              ; 20 6A 13
            bpl L12D9              ; 10 EB
L12EE       lda #$8B               ; A9 8B
L12F0       eor #$03               ; 49 03
            sta L10BA+1            ; 8D BB 10
            rts                    ; 60
L12F6       jsr L0F4C              ; 20 4C 0F
            iny                    ; C8
            iny                    ; C8
            sty L0E3F              ; 8C 3F 0E
            cpy FMSZPG+2           ; C4 45
            bne L1345              ; D0 43
            jsr L0F4C              ; 20 4C 0F
            ldy #$00               ; A0 00
            lda (FMSZPG),Y         ; B1 43
            tax                    ; AA
            iny                    ; C8
            ora (FMSZPG),Y         ; 11 43
            bne L1335              ; D0 26
            jsr L1B6C              ; 20 6C 1B
            ldy #$02               ; A0 02
L1314       lda L0E3B,Y            ; B9 3B 0E
            sta (FMSZPG),Y         ; 91 43
            iny                    ; C8
            cpy #$04               ; C0 04
            bcc L1314              ; 90 F6
            jsr L0F4C              ; 20 4C 0F
            ldy #$01               ; A0 01
L1323       lda L0DE5,Y            ; B9 E5 0D
            sta (FMSZPG),Y         ; 91 43
            dey                    ; 88
            bpl L1323              ; 10 F8
            jsr MOVE              ; 20 19 09
            .byte $1C,$2B
            ldx #$5B               ; A2 5B
            .byte $B3
            beq L133D              ; F0 08
L1335       lda (FMSZPG),Y         ; B1 43
            sta L0E3E              ; 8D 3E 0E
            stx L0E3B+2            ; 8E 3D 0E
L133D       jsr L0F4C              ; 20 4C 0F
            ldy #$04               ; A0 04
            sty L0E3F              ; 8C 3F 0E
L1345       lda (FMSZPG),Y         ; B1 43
            sta L0E38+2            ; 8D 3A 0E
            iny                    ; C8
            lda (FMSZPG),Y         ; B1 43
            sta L0E3B              ; 8D 3B 0E
            ora L0E38+2            ; 0D 3A 0E
            rts                    ; 60
L1354       sec                    ; 38
            ldx #$FD               ; A2 FD
L1357       lda L0D47+1,X          ; BD 48 0D
            sbc L0D41+2,X          ; FD 43 0D
            inx                    ; E8
            bne L1357              ; D0 F7
            bcs L1369              ; B0 07
            jsr MOVE              ; 20 19 09
            .byte $A3
            ldx L00BB,Y            ; B6 BB
            clc                    ; 18
L1369       rts                    ; 60
L136A       lda L0E48              ; AD 48 0E
            ldy #$83               ; A0 83
            bit FMSZPG+5           ; 24 48
            bpl L1376              ; 10 03
            lsr                    ; 4A
            ldy #$87               ; A0 87
L1376       and #$04               ; 29 04
            bne L13BF              ; D0 45
            jmp L10C2              ; 4C C2 10
            lda L0E48              ; AD 48 0E
            cmp #$16               ; C9 16
            bne L1387              ; D0 03
            lsr L0E52+1            ; 4E 53 0E
L1387       and #$08               ; 29 08
            beq L1369              ; F0 DE
            jsr MOVE              ; 20 19 09
L138E       .byte $23,$BB
            sty LBF22              ; 8C 22 BF
            .byte $B9,$15,$0C ; lda L0C15,Y ; B9 15 0C
            .byte $13,$9E
L1398       .byte $A3
L1399       sty LA99A              ; 8C 9A A9
            .byte $FF
L139D       bit.w L00A9            ; 2C A9 00
            pha                    ; 48
            jsr MOVE              ; 20 19 09
            .byte $22
            cmp (ADRESS,X)         ; C1 64
            and (DELTAR,X)         ; 21 76
            ror L0094              ; 66 94
            rol L2C68,X            ; 3E 68 2C
L13AE       lda #$00               ; A9 00
            bit LFFA9              ; 2C A9 FF
            sta FMSZPG+5           ; 85 48
            jsr MOVE              ; 20 19 09
            eor (L00DC),Y          ; 51 DC
            .byte $54,$27
            ldx #$7C               ; A2 7C
            .byte $C7
L13BF       lda FMSZPG+2           ; A5 45
            sec                    ; 38
            sbc L0E3B+1            ; ED 3C 0E
            bne L13C9              ; D0 02
            lda #$FF               ; A9 FF
L13C9       sta L1488+1            ; 8D 89 14
            lda L0E52              ; AD 52 0E
            bne L13D9              ; D0 08
            lda L0E51              ; AD 51 0E
            beq L13F5              ; F0 1F
            jsr L14F5              ; 20 F5 14
L13D9       jsr L14BF              ; 20 BF 14
            beq L13F3+1            ; F0 16
            jsr L14F5              ; 20 F5 14
            lda L0E38+2            ; AD 3A 0E
            ora L0E3B              ; 0D 3B 0E
            bne L140E              ; D0 25
            lda L0E48              ; AD 48 0E
            and #$08               ; 29 08
            bne L13F6              ; D0 06
L13F0       jsr L10BE              ; 20 BE 10
L13F3       ldx L00CA              ; A6 CA
L13F5       rts                    ; 60
L13F6       jsr MOVE              ; 20 19 09
            .byte $1B
            jmp (L5B22)            ; 6C 22 5B
            bcs L138E              ; B0 8F
            jmp LE5AD              ; 4C AD E5
            ora L4391              ; 0D 91 43
            iny                    ; C8
            lda L0DE6              ; AD E6 0D
            sta (FMSZPG),Y         ; 91 43
            jsr L1C2B              ; 20 2B 1C
L140E       ldx L0E38+2            ; AE 3A 0E
            lda L0E3B              ; AD 3B 0E
            jsr MOVE              ; 20 19 09
            .byte $1B
            sbc #$D4               ; E9 D4
            .byte $27,$54,$82
            ldy L0E3B+1            ; AC 3C 0E
            bit FMSZPG+5           ; 24 48
            bmi L1480+1            ; 30 5D
L1424       lda (FMSZPG),Y         ; B1 43
            sta LFFFF,X            ; 9D FF FF
            iny                    ; C8
            inx                    ; E8
            cpx L1488+1            ; EC 89 14
            bne L1424              ; D0 F4
            beq L148F              ; F0 5D
            ldy #$FD               ; A0 FD
L1434       lda IOCB0+ICAX3,X      ; BD 4C 03
            sta ECHOFLG,Y          ; 99 F1 0C
            inx                    ; E8
            iny                    ; C8
            bne L1434              ; D0 F6
L143E       lda L0DF0              ; AD F0 0D
            bmi L13F0              ; 30 AD
            jsr MOVE              ; 20 19 09
            and (KEYDEF,X)         ; 21 79
            lda ICCOMZ,X           ; B5 22
            lda L23B3,Y            ; B9 B3 23
            .byte $64
            ldx L0093,Y            ; B6 93
            .byte $54
            bcs L145A              ; B0 07
            lda L0E48              ; AD 48 0E
            and #$08               ; 29 08
            beq L13F0              ; F0 96
L145A       lda L0DEE              ; AD EE 0D
            ldx L0DEF              ; AE EF 0D
            ldy L0DF0              ; AC F0 0D
            jsr L14FD              ; 20 FD 14
            sta L0E3B+1            ; 8D 3C 0E
            stx L0DEE              ; 8E EE 0D
            sty L0DEF              ; 8C EF 0D
            jsr L12F6              ; 20 F6 12
            lda L0DEE              ; AD EE 0D
            ora L0DEF              ; 0D EF 0D
            beq L14D9              ; F0 5F
            jsr L0869              ; 20 69 08
            inc LB00D              ; EE 0D B0
L1480       inc LFFBD              ; EE BD FF
            .byte $FF
            sta (FMSZPG),Y         ; 91 43
            iny                    ; C8
            inx                    ; E8
L1488       cpx #$00               ; E0 00
            bne L1480+1            ; D0 F5
            jsr L1C2B              ; 20 2B 1C
L148F       lda L1488+1            ; AD 89 14
            jsr L086B              ; 20 6B 08
            eor (APPMHI),Y         ; 51 0E
            jsr L085F              ; 20 5F 08
            .byte $27,$14
            jsr L085F              ; 20 5F 08
            rti                    ; 40
            asl IOCB5              ; 0E 90 03
            inc L0E42              ; EE 42 0E
            jsr L1354              ; 20 54 13
L14A9       lda L0E3B+1            ; AD 3C 0E
            clc                    ; 18
            adc L1488+1            ; 6D 89 14
            cmp FMSZPG+2           ; C5 45
            bne L14B9              ; D0 05
            jsr L12F6              ; 20 F6 12
            lda #$00               ; A9 00
L14B9       sta L0E3B+1            ; 8D 3C 0E
            jmp L13BF              ; 4C BF 13
L14BF       ldx #$FD               ; A2 FD
            sec                    ; 38
L14C2       lda L0D47+1,X          ; BD 48 0D
            sbc L0D41+2,X          ; FD 43 0D
            sta ECHOFLG,X          ; 9D F1 0C
            inx                    ; E8
            bne L14C2              ; D0 F4
            bit FMSZPG+5           ; 24 48
            bmi L14D7              ; 30 05
            ora L0DEF              ; 0D EF 0D
            beq L14F1              ; F0 1A
L14D7       lda #$FF               ; A9 FF
L14D9       rts                    ; 60
L14DA       jsr INC_PC              ; 20 C5 08
            sta L1283+1            ; 8D 84 12
            asl                    ; 0A
            lsr                    ; 4A
            tax                    ; AA
            lda #$9B               ; A9 9B
            tay                    ; A8
L14E6       sta L0D9C,X            ; 9D 9C 0D
            lda #$20               ; A9 20
            dex                    ; CA
            bne L14E6              ; D0 F8
            stx L1277+1            ; 8E 78 12
L14F1       lda L0DEE              ; AD EE 0D
            rts                    ; 60
L14F5       cmp L1488+1            ; CD 89 14
            bcs L14D9              ; B0 DF
            sta L1488+1            ; 8D 89 14
L14FD       bit FMSZPG+2           ; 24 45
            bpl L150B              ; 10 0A
            asl                    ; 0A
            pha                    ; 48
            txa                    ; 8A
            rol                    ; 2A
            tax                    ; AA
            tya                    ; 98
            rol                    ; 2A
            tay                    ; A8
            pla                    ; 68
            lsr                    ; 4A
L150B       rts                    ; 60

L150C       lda #$14               ; A9 14
            dta b(op_BIT_abs)
            lda #$0C
;            bit L0CA9              ; 2C A9 0C
L1511       sta L0E48              ; 8D 48 0E
            pha                    ; 48
            jsr MOVE              ; 20 19 09
            .byte $23
            ror ADRESS,X           ; 76 64
            sty FTYPE,X            ; 94 3E
            pla                    ; 68
            cmp #$10               ; C9 10
            bcc L152D              ; 90 0B
            jsr MOVE              ; 20 19 09
            and (HOLDCH,X)         ; 21 7C
            .byte $BB,$13
            ldx L9AA3              ; AE A3 9A
            .byte $BB
L152D       rts                    ; 60
            jsr MOVE              ; 20 19 09
            .byte $2B
            sta (L009D,X)          ; 81 9D
            .byte $23
            ror L009A,X            ; 76 9A
            cmp LCE06              ; CD 06 CE
            .byte $32
            bit TDOVER            ; 2C 12 0D
            bpl L1547              ; 10 07
            jsr MOVE              ; 20 19 09
            cmp LCE0C              ; CD 0C CE
            .byte $32
L1547       lda FMSZPG+6           ; A5 49
            sta L0E48              ; 8D 48 0E
            and #$20               ; 29 20
            ora #$08               ; 09 08
            sta L0E21            ; 8D 21 0E
            rts                    ; 60
L1554       bit L0E52+1            ; 2C 53 0E
            bmi L15C3+1            ; 30 6B
            lda #$16               ; A9 16
            sta FMSZPG+6           ; 85 49
            jsr MOVE              ; 20 19 09
            asl L0000,X            ; 16 00
            .byte $AB
            sta (WARMST,X)         ; 81 08
            stx L1283+1            ; 8E 84 12
            lda ICAX2Z             ; A5 2B
            sta L11BE              ; 8D BE 11
            bpl L1583+2            ; 10 16
            jsr L14DA              ; 20 DA 14
            rol                    ; 2A
            sty L0DC5              ; 8C C5 0D
            jsr MOVE              ; 20 19 09
            plp                    ; 28
            .byte $00,$13
            plp                    ; 28
            cmp L2B1F,Y            ; D9 1F 2B
            .byte $3C,$27
            tay                    ; A8
L1583       sta L3833,X            ; 9D 33 38
            ror L0E52+1            ; 6E 53 0E
            rts                    ; 60
            lda #$28               ; A9 28
            ldx #$09               ; A2 09
            bne L15A0              ; D0 10
            lda ICAX1Z             ; A5 2A
            and #$F0               ; 29 F0
            ora #$04               ; 09 04
            bit L2AA5              ; 2C A5 2A
            and #$3F               ; 29 3F
L159B       bit L14A9              ; 2C A9 14
L159E       ldx #$29               ; A2 29
L15A0       stx L1684              ; 8E 84 16
            cmp #$06               ; C9 06
            beq L1554              ; F0 AD
            cmp #$20               ; C9 20
            bcc L15AD              ; 90 02
            and #$EF               ; 29 EF
L15AD       sta FMSZPG+6           ; 85 49
            and #$0F               ; 29 0F
            lsr                    ; 4A
            bcc L15B8              ; 90 04
            cmp #$04               ; C9 04
            bne L15BB              ; D0 03
L15B8       lsr                    ; 4A
L15B9       bcc L15FF+1            ; 90 45
L15BB       ldy #$A8               ; A0 A8
L15BD       bit LA3A0              ; 2C A0 A3
L15C0       bit LA9A0              ; 2C A0 A9
L15C3       bit LA1A0              ; 2C A0 A1
            jmp L10C2              ; 4C C2 10
L15C9       ldx #$0A               ; A2 0A
L15CB       lda L0E0A+1,X          ; BD 0B 0E
            cmp #$3F               ; C9 3F
            beq L15BD+1            ; F0 EC
            dex                    ; CA
            bpl L15CB              ; 10 F6
            jmp (GETTDV)            ; 6C 06 07
L15D8       lda #$00               ; A9 00
            bpl L1622              ; 10 46
            jsr MOVE              ; 20 19 09
            .byte $2B
            sta (L008C,X)          ; 81 8C
            .byte $2B
            ror                    ; 6A
            sta (ICCOMZ,X)         ; 81 22
            cpy L15B9              ; CC B9 15
            .byte $0C
            sta LD0C5,X            ; 9D C5 D0
            .byte $34
            jsr MOVE              ; 20 19 09
            .byte $2B
            sty L2281              ; 8C 81 22
            tya                    ; 98
            .byte $B9,$15,$0C     ; lda L0C15,Y ; B9 15 0C
            sta LD0C2,X            ; 9D C2 D0
            and DSTAT              ; 25 4C
            .byte $B2
L15FF       asl ICHIDZ,X           ; 16 20
            ldx L081A              ; AE 1A 08
            pla                    ; 68
            ror                    ; 6A
            ror                    ; 6A
            ror L15D8+1            ; 6E D9 15
            lda FMSZPG+6           ; A5 49
            and #$10               ; 29 10
            bne L167D              ; D0 6D
            jsr L150C              ; 20 0C 15
            jsr L1DBF              ; 20 BF 1D
            beq L167F              ; F0 67
L1618       lda FMSZPG+6           ; A5 49
            cmp #$04               ; C9 04
            beq L15D8              ; F0 BA
            and #$08               ; 29 08
            bne L162C              ; D0 0A
L1622       jsr L10BE              ; 20 BE 10
            tax                    ; AA
L1626       jsr L15C9              ; 20 C9 15
            jsr L1D4D              ; 20 4D 1D
L162C       bit L0E4C            ; 2C 4C 0E
            bmi L15C0+1            ; 30 90
            jsr MOVE              ; 20 19 09
            ora L00C9,X            ; 15 C9
            ora ICAX5Z,X           ; 15 2E
            .byte $1B
            jmp (L5B22)            ; 6C 22 5B
            tya                    ; 98
            and (SWPFLG,X)         ; 21 7B
            ldx L9B13,Y            ; BE 13 9B
            .byte $22
            cmp (OLDCHR,X)         ; C1 5D
            .byte $22
            ror L00C1,X            ; 76 C1
            .byte $13,$9E,$23,$BB
            txs                    ; 9A
            .byte $13,$9B,$22
            eor L93C1,X            ; 5D C1 93
            .byte $9E
            lda FMSZPG+6           ; A5 49
            and #$20               ; 29 20
            beq L1678              ; F0 1E
L165A       beq L1618              ; F0 BC
            jsr MOVE              ; 20 19 09
            .byte $22
            lda L225D,Y            ; B9 5D 22
            tya                    ; 98
            lda L0F15,Y            ; B9 15 0F
            ora ICAX5Z,X           ; 15 2E
            and (HOLDCH,X)         ; 21 7C
            txs                    ; 9A
            .byte $22
            eor L1398,X            ; 5D 98 13
            lda (ICCOMZ),Y         ; B1 22
            tya                    ; 98
            .byte $B9,$15,$0C      ; lda L0C15,Y ; B9 15 0C
            .byte $93,$9E
L1678       jmp L16B2              ; 4C B2 16
L167B       bpl L1626              ; 10 A9
L167D       bne L16BA+1            ; D0 3C
L167F       lda FMSZPG+6           ; A5 49
            eor L0E21            ; 4D 21 0E
L1684       and #$20               ; 29 20
            beq L1696              ; F0 0E
            lda FMSZPG+6           ; A5 49
            and #$08               ; 29 08
            beq L165A              ; F0 CC
            ldy #$97               ; A0 97
L1690       bit LA4A0              ; 2C A0 A4
            jmp L10C2              ; 4C C2 10
L1696       lda FMSZPG+6           ; A5 49
            and #$08               ; 29 08
            beq L16B2              ; F0 16
            lda L0E21            ; AD 21 0E
            and #$21               ; 29 21
            lsr                    ; 4A
            bne L16B2              ; D0 0E
            bcs L1690+1            ; B0 EB
            lda FMSZPG+6           ; A5 49
            cmp #$08               ; C9 08
            bne L16B2              ; D0 06
L16AC       lda #$00               ; A9 00
            bpl L167B              ; 10 CB
            inc FMSZPG+6           ; E6 49
L16B2       jsr MOVE              ; 20 19 09
            .byte $22
            lda LA5BF,Y            ; B9 BF A5
            tya                    ; 98
L16BA       lda L49A5,Y            ; B9 A5 49
            jsr L1511              ; 20 11 15
            lda FMSZPG+6           ; A5 49
            cmp #$10               ; C9 10
            bcc L16DB              ; 90 15
            jsr MOVE              ; 20 19 09
            .byte $22
            lda LA2BF,Y            ; B9 BF A2
            ror L00C1,X            ; 76 C1
            lda FMSZPG+6           ; A5 49
            and #$07               ; 29 07
            bne L16DB              ; D0 06
            jsr MOVE              ; 20 19 09
            .byte $A3
            ldx L00BB,Y            ; B6 BB
L16DB       lda FMSZPG+6           ; A5 49
            lsr                    ; 4A
            bcc L16FD              ; 90 1D
            jsr MOVE              ; 20 19 09
            .byte $A3,$BB,$64
            jmp L143E              ; 4C 3E 14
            ldy #$00               ; A0 00
            bit L05A0              ; 2C A0 05
L16EE       lda L0E3F+1,Y          ; B9 40 0E
            sta IOCB0+ICAX3,X      ; 9D 4C 03
            iny                    ; C8
            inx                    ; E8
            txa                    ; 8A
            and #$0F               ; 29 0F
            cmp #$03               ; C9 03
            bcc L16EE              ; 90 F1
L16FD       rts                    ; 60
L16FE       stx L1C2B+1            ; 8E 2C 1C
            lda #$FF               ; A9 FF
            sta L0F49,X            ; 9D 49 0F
            txa                    ; 8A
            clc                    ; 18
            adc #$17               ; 69 17
            sta FMSZPG+1           ; 85 44
            lda #$11               ; A9 11
            sta FMSZPG             ; 85 43
            rts                    ; 60
L1711       equ *

            org $1A11
;
L1A11       cpx #$08               ; E0 08
            bcc L1A1E              ; 90 09
            bit L1C47+1            ; 2C 48 1C
            bpl L1A22              ; 10 08
            cpx #$0B               ; E0 0B
            bcs L1A22              ; B0 04
L1A1E       sta L0E0A+1,X          ; 9D 0B 0E
            inx                    ; E8
L1A22       rts                    ; 60
L1A23       ldy #$00               ; A0 00
            sty L1AE9+1            ; 8C EA 1A
            inc L1A23+1            ; EE 24 1A
            lda #$0E               ; A9 0E
            sta L1C47+1            ; 8D 48 1C
            ldx #$00               ; A2 00
            beq L1A3E              ; F0 0A
L1A34       lda #$3F               ; A9 3F
            jsr L1A11              ; 20 11 1A
            bcc L1A34              ; 90 F9
L1A3B       jsr L1A11              ; 20 11 1A
L1A3E       iny                    ; C8
            lda (ICBALZ),Y         ; B1 24
            cmp #$2A               ; C9 2A
            beq L1A34              ; F0 EF
            cmp #$3F               ; C9 3F
            beq L1A3B              ; F0 F2
            cmp #$5F               ; C9 5F
            beq L1A3B              ; F0 EE
            cmp #$2E               ; C9 2E
            beq L1A65              ; F0 14
            cmp #$30               ; C9 30
            bcc L1A61              ; 90 0C
            cmp #$3A               ; C9 3A
            bcc L1A3B              ; 90 E2
            cmp #$41               ; C9 41
            bcc L1A61              ; 90 04
            cmp #$5B               ; C9 5B
            bcc L1A3B              ; 90 DA
L1A61       sec                    ; 38
            ror L1C47+1            ; 6E 48 1C
L1A65       lda #$20               ; A9 20
            jsr L1A11              ; 20 11 1A
            bcc L1A65              ; 90 F9
            ror L1C47+1            ; 6E 48 1C
            bcc L1A3E              ; 90 CD
            lda (ICBALZ),Y         ; B1 24
            cmp #$2F               ; C9 2F
            bne L1A84              ; D0 0D
            iny                    ; C8
            lda (ICBALZ),Y         ; B1 24
            dey                    ; 88
            cmp #$41               ; C9 41
            bne L1A84              ; D0 05
            ror L16AC+1            ; 6E AD 16
            iny                    ; C8
            iny                    ; C8
L1A84       cpy L1A23+1            ; CC 24 1A
L1A87       sty L1A23+1            ; 8C 24 1A
            php                    ; 08
            beq L1A8E              ; F0 01
            clc                    ; 18
L1A8E       ror L1AFD+1            ; 6E FE 1A
            lda (ICBALZ),Y         ; B1 24
            plp                    ; 28
            rts                    ; 60
            jsr MOVE              ; 20 19 09
            .byte $1A,$9F,$1A,$FA
            ldx #$B9               ; A2 B9
            .byte $E3
            ldy #$02               ; A0 02
L1AA1       lda (ICBALZ),Y         ; B1 24
            cmp #$3A               ; C9 3A
            beq L1A87              ; F0 E0
            dey                    ; 88
            bne L1AA1              ; D0 F7
L1AAA       jsr L10BE              ; 20 BE 10
            stx ICHIDZ,Y           ; 96 20
            .byte $9F,$1A
            sty L1AE7+1            ; 8C E8 1A
L1AB4       lsr L16AC+1            ; 4E AD 16
            jsr MOVE              ; 20 19 09
            .byte $22,$E3
            lda L239A,Y            ; B9 9A 23
            bne L1AF4              ; D0 33
            cmp #$3E               ; C9 3E
            bne L1AE0              ; D0 1B
            jsr MOVE              ; 20 19 09
            ldx #$CC               ; A2 CC
            lda L22F0,Y            ; B9 F0 22
L1ACD       jsr L150C              ; 20 0C 15
            jsr L1B0C              ; 20 0C 1B
            lda L0E42+1            ; AD 43 0E
            ora L0E42+2            ; 0D 44 0E
            beq L1AAA              ; F0 CF
            jsr L1A23              ; 20 23 1A
            bne L1AF4              ; D0 14
L1AE0       cmp #$3C               ; C9 3C
            beq L1ACD              ; F0 E9
L1AE4       lsr L16AC+1            ; 4E AD 16
L1AE7       ldy #$00               ; A0 00
L1AE9       cpy #$00               ; C0 00
            rts                    ; 60
L1AEC       jsr L1B01              ; 20 01 1B
            jsr L1A23              ; 20 23 1A
            beq L1AE4              ; F0 F0
L1AF4       cmp #$3E               ; C9 3E
            beq L1AEC              ; F0 F4
            bne L1AE7              ; D0 ED
            jsr L1AB4              ; 20 B4 1A
L1AFD       lda #$00               ; A9 00
            bmi L1B11+1            ; 30 11
L1B01       lsr L16AC+1            ; 4E AD 16
            jsr L150C              ; 20 0C 15
            jsr L1DC4+1            ; 20 C5 1D
            bmi L1AAA              ; 30 9E
L1B0C       jsr MOVE              ; 20 19 09
            ldx #$98               ; A2 98
L1B11       lda LBD60,Y            ; B9 60 BD
            rti                    ; 40
            .byte $0F
            bpl L1B11+1            ; 10 FA
            and #$7F               ; 29 7F
            sta L0F40,X            ; 9D 40 0F
            tay                    ; A8
            jsr L16FE              ; 20 FE 16
            lda L0F46,X            ; BD 46 0F
            pha                    ; 48
            lda L0F43,X            ; BD 43 0F
            tax                    ; AA
            pla                    ; 68
            sec                    ; 38
L1B2B       sty DUNIT              ; 8C 01 03
            stx DAUX1              ; 8E 0A 03
            sta DAUX2              ; 8D 0B 03
            dex                    ; CA
            bne L1B3B              ; D0 04
            tax                    ; AA
            bne L1B3B              ; D0 01
            tay                    ; A8
L1B3B       ldx #$52               ; A2 52
            lda #$40               ; A9 40
            bcc L1B45              ; 90 04
            ldx WRTCMD              ; AE F7 0C
            asl                    ; 0A
L1B45       stx DCOMND             ; 8E 02 03
            sta DSTATS             ; 8D 03 03
            lda L0DE9,Y            ; B9 E9 0D
            sta DBYTLO             ; 8D 08 03
            asl                    ; 0A
            rol                    ; 2A
            eor #$01               ; 49 01
            sta DBYTHI             ; 8D 09 03
            jsr MOVE              ; 20 19 09
            .byte $5B
            bvs L1B7F+2            ; 70 23
            asl FMSZPG+4           ; 06 47
            ldx.w ICSTAZ           ; AE 23 00
            rti                    ; 40
            .byte $43,$43,$04
            sty L30EE              ; 8C EE 30
            .byte $77
L1B6B       rts                    ; 60
L1B6C       lda L0E48              ; AD 48 0E
            cmp #$10               ; C9 10
            bcs L1B75+1            ; B0 03
            ldy #$00               ; A0 00
L1B75       bit DMASK              ; 2C A0 02
            tya                    ; 98
            pha                    ; 48
            ldx #$FE               ; A2 FE
L1B7C       lda L0E5F,Y            ; B9 5F 0E
L1B7F       sta DECOUT+1,X          ; 9D E7 0C
            iny                    ; C8
            inx                    ; E8
            bne L1B7C              ; D0 F6
            jsr L1BAE              ; 20 AE 1B
            jsr L1CA2+1            ; 20 A3 1C
            jsr L0869              ; 20 69 08
            sbc DOSINI+1           ; E5 0D
L1B91       jsr L1D8A              ; 20 8A 1D
            tax                    ; AA
            and (FMSZPG),Y         ; 31 43
            bne L1B9E              ; D0 05
            jsr L1BAE              ; 20 AE 1B
            bcc L1B91              ; 90 F3
L1B9E       txa                    ; 8A
            eor (FMSZPG),Y         ; 51 43
            sta (FMSZPG),Y         ; 91 43
            jsr L1C2B              ; 20 2B 1C
            jsr L0869              ; 20 69 08
            .byte $5A
            asl L9018              ; 0E 18 90
            .byte $1B
L1BAE       jsr L0863            ; 20 63 08
            sbc DOSINI+1           ; E5 0D
            lda L0DE5              ; AD E5 0D
            cmp L0E58              ; CD 58 0E
            lda L0DE6              ; AD E6 0D
            sbc L0E58+1            ; ED 59 0E
            bcc L1B6B              ; 90 AA
            jsr L0869              ; 20 69 08
            sbc DOSINI+1           ; E5 0D
            pla                    ; 68
            pla                    ; 68
            sec                    ; 38
            pla                    ; 68
            tay                    ; A8
            ldx #$FE               ; A2 FE
L1BCD       lda DECOUT+1,X          ; BD E7 0C
            sta L0E5F,Y            ; 99 5F 0E
            iny                    ; C8
            inx                    ; E8
            bne L1BCD              ; D0 F6
            ldx L0DE5              ; AE E5 0D
            bcc L1BEA              ; 90 0E
            dey                    ; 88
            dey                    ; 88
            beq L1B75+1            ; F0 96
            ldy #$A2               ; A0 A2
            jmp L10C2              ; 4C C2 10
L1BE5       lda #$00               ; A9 00
            ldx #$01               ; A2 01
L1BE9       sec                    ; 38
L1BEA       stx L1C68+1            ; 8E 69 1C
            sta L1C6D+1            ; 8D 6E 1C
            php                    ; 08
            ldx #$02               ; A2 02
L1BF3       lda L0F49,X            ; BD 49 0F
            beq L1BFB              ; F0 03
            dec L0F49,X            ; DE 49 0F
L1BFB       dex                    ; CA
            bpl L1BF3              ; 10 F5
            ldx #$02               ; A2 02
L1C00       jsr L110C              ; 20 0C 11
            bne L1C35              ; D0 30
            lda L0F43,X            ; BD 43 0F
            tay                    ; A8
            cmp L1C68+1            ; CD 69 1C
            bne L1C35              ; D0 27
            lda L0F46,X            ; BD 46 0F
            cmp L1C6D+1            ; CD 6E 1C
            bne L1C35              ; D0 1F
            dey                    ; 88
            bne L1C1C              ; D0 03
            tay                    ; A8
            beq L1C5E              ; F0 42
L1C1C       jsr L16FE              ; 20 FE 16
            plp                    ; 28
            bcs L1C34              ; B0 12
L1C22       ldy FMSZPG+2           ; A4 45
            lda #$00               ; A9 00
L1C26       dey                    ; 88
            sta (FMSZPG),Y         ; 91 43
            bne L1C26              ; D0 FB
L1C2B       ldx #$00               ; A2 00
            asl L0F40,X            ; 1E 40 0F
            sec                    ; 38
            ror L0F40,X            ; 7E 40 0F
L1C34       rts                    ; 60
L1C35       dex                    ; CA
            bpl L1C00              ; 10 C8
            stx L1C47+1            ; 8E 48 1C
            inx                    ; E8
            stx L1C56+1            ; 8E 57 1C
L1C3F       lda L0F40,X            ; BD 40 0F
L1C42       beq L1C47              ; F0 03
            lda L0F49,X            ; BD 49 0F
L1C47       cmp #$FF               ; C9 FF
            bcs L1C51              ; B0 06
            sta L1C47+1            ; 8D 48 1C
            stx L1C56+1            ; 8E 57 1C
L1C51       inx                    ; E8
            cpx #$03               ; E0 03
            bcc L1C3F              ; 90 E9
L1C56       ldx #$00               ; A2 00
            jsr L1B11+2            ; 20 13 1B
            ldx L1C56+1            ; AE 57 1C
L1C5E       jsr L16FE              ; 20 FE 16
            lda L0E38+1            ; AD 39 0E
            sta L0F40,X            ; 9D 40 0F
            tay                    ; A8
L1C68       lda #$00               ; A9 00
            sta L0F43,X            ; 9D 43 0F
L1C6D       lda #$00               ; A9 00
            sta L0F46,X            ; 9D 46 0F
            plp                    ; 28
            bcc L1C22              ; 90 AD
            ldx L1C68+1            ; AE 69 1C
            clc                    ; 18
            jmp L1B2B              ; 4C 2B 1B
L1C7C       jsr MOVE              ; 20 19 09
            .byte $22
            bcs L1CDC+1            ; B0 5B
            sta L118A,X            ; 9D 8A 11
            .byte $43
            sta (FMSZPG),Y         ; 91 43
            jsr MOVE              ; 20 19 09
            .byte $1C,$2B,$22
            adc LA2D7,Y            ; 79 D7 A2
            dec LA0D5              ; CE D5 A0
            .byte $04
L1C95       lsr L0E5F+1            ; 4E 60 0E
            ror L0E5F              ; 6E 5F 0E
            dey                    ; 88
            bne L1C95              ; D0 F7
            jsr L0863            ; 20 63 08
            .byte $5A
L1CA2       asl L39AE              ; 0E AE 39
            asl L7E38              ; 0E 38 7E
L1CA8       jmp L600E              ; 4C 0E 60
            ldx #$0A               ; A2 0A
L1CAD       lda L0E16,X            ; BD 16 0E
            cmp #$3F               ; C9 3F
            beq L1CB7              ; F0 03
            sta L0E27,X          ; 9D 27 0E
L1CB7       dex                    ; CA
            bpl L1CAD              ; 10 F3
            rts                    ; 60
            sec                    ; 38
            bit DSKFMS             ; 24 18
            php                    ; 08
            lsr L0E21            ; 4E 21 0E
            plp                    ; 28
            rol L0E21            ; 2E 21 0E
            rts                    ; 60
L1CC7       .byte $AB,$34
            dec L00BB              ; C6 BB
L1CCB       lda L1D1C,X            ; BD 1C 1D
            .byte $1C,$1C,$1C
            tya                    ; 98
            and #$07               ; 29 07
            pha                    ; 48
            tay                    ; A8
            lda L1CC7,Y            ; B9 C7 1C
            sta L1D01+1            ; 8D 02 1D
L1CDC       lda L1CCB+1,Y          ; B9 CC 1C
            sta L1D01+2            ; 8D 03 1D
            lda L0DFE,Y            ; B9 FE 0D
            sta L1D12+1            ; 8D 13 1D
            jsr L159B+1            ; 20 9C 15
            pla                    ; 68
            bne L1CFB+1            ; D0 0E
            jsr MOVE              ; 20 19 09
            .byte $2B
            sta (L0097,X)          ; 81 97
            .byte $1A,$23,$2B
            sta (L008C,X)          ; 81 8C
            .byte $AB,$97
L1CFB       sta (ICHIDZ,X)         ; 81 20
            ora GRACTL             ; 0D 1D D0
            .byte $3C
L1D01       jsr L1CA8+2            ; 20 AA 1C
            jsr L1399+2            ; 20 9B 13
            jsr L1D0D              ; 20 0D 1D
            beq L1D01              ; F0 F5
            rts                    ; 60
L1D0D       jsr L1DBF              ; 20 BF 1D
            bne L1D19              ; D0 07
L1D12       lda #$00               ; A9 00
            and L0E21            ; 2D 21 0E
            bne L1D0D              ; D0 F4
L1D19       rts                    ; 60
            lda #$24               ; A9 24
L1D1C       jsr L159E              ; 20 9E 15
            ldx #$0A               ; A2 0A
            lda #$3F               ; A9 3F
L1D23       sta L0E0A+1,X          ; 9D 0B 0E
            dex                    ; CA
            bpl L1D23              ; 10 FA
            jsr L1DBF              ; 20 BF 1D
            beq L1D3F+1            ; F0 12
            jsr L159B+1            ; 20 9C 15
            jsr L1DC4+1            ; 20 C5 1D
            lda L0E21            ; AD 21 0E
            lsr                    ; 4A
            bcc L1D45              ; 90 0B
            ldy #$A4               ; A0 A4
            bit LAAA0              ; 2C A0 AA
L1D3F       bit LA7A0              ; 2C A0 A7
            jmp L10C2              ; 4C C2 10
L1D45       lda #$10               ; A9 10
            sta L0E21            ; 8D 21 0E
            jsr L1399+2            ; 20 9B 13
L1D4D       jsr MOVE              ; 20 19 09
            .byte $22
            lda L22BF,Y            ; B9 BF 22
            tya                    ; 98
            lda L0F15,Y            ; B9 15 0F
            lda (KEYDEF,X)         ; A1 79
L1D5A       lda ICHIDZ,X           ; B5 20
            inc RTCLOK,X           ; F6 12
            beq L1D63              ; F0 03
            jsr L1C7C              ; 20 7C 1C
L1D63       ldy FMSZPG+2           ; A4 45
            dey                    ; 88
            dey                    ; 88
            cpy L0E3F              ; CC 3F 0E
            bne L1D5A+1            ; D0 EF
            jsr MOVE              ; 20 19 09
            .byte $22,$B3
            bcs L1D8D+2            ; B0 1C
            .byte $7C,$8F
            jmp L00A0              ; 4C A0 00
            lda (FMSZPG),Y         ; B1 43
            iny                    ; C8
            ora (FMSZPG),Y         ; 11 43
            bne L1D5A+1            ; D0 DC
            jsr MOVE              ; 20 19 09
            .byte $22,$BF
            lda L0C94+1,Y          ; B9 95 0C
            jmp L139D+1            ; 4C 9E 13
L1D8A       lda L0DE5              ; AD E5 0D
L1D8D       ldx L0DE6              ; AE E6 0D
            ldy #$03               ; A0 03
L1D92       pha                    ; 48
            txa                    ; 8A
            lsr                    ; 4A
            tax                    ; AA
            pla                    ; 68
            ror                    ; 6A
            dey                    ; 88
            bne L1D92              ; D0 F7
            jsr L14FD              ; 20 FD 14
            sta L1DBC+1            ; 8D BD 1D
            txa                    ; 8A
            clc                    ; 18
            adc L0E5D              ; 6D 5D 0E
            tax                    ; AA
            lda #$00               ; A9 00
            adc L0E5D+1            ; 6D 5E 0E
            jsr L1BE9              ; 20 E9 1B
            lda L0DE5              ; AD E5 0D
            and #$07               ; 29 07
            tay                    ; A8
            lda #$00               ; A9 00
            sec                    ; 38
L1DB8       ror                    ; 6A
            dey                    ; 88
            bpl L1DB8              ; 10 FC
L1DBC       ldy #$00               ; A0 00
            rts                    ; 60
L1DBF       lda #$80               ; A9 80
            bit L49A5              ; 2C A5 49
L1DC4       bit L20A9              ; 2C A9 20
            sta L1DF3+1            ; 8D F4 1D
            jsr MOVE              ; 20 19 09
            ldx #$68               ; A2 68
L1DCF       cmp (ICHIDZ,X)         ; C1 20
            ora LA209,Y            ; 19 09 A2
            ldx OLDCHR,Y           ; B6 5D
            bit L0E41              ; 2C 41 0E
            bmi L1E19              ; 30 3E
            jsr L13AE              ; 20 AE 13
            bmi L1E19              ; 30 39
            lda L0E21            ; AD 21 0E
            beq L1E19              ; F0 34
            and #$08               ; 29 08
            bne L1DF3              ; D0 0A
            bit L0E4C            ; 2C 4C 0E
            bpl L1DCF+1            ; 10 E2
            jsr L1E10              ; 20 10 1E
            beq L1DCF+1            ; F0 DD
L1DF3       lda #$00               ; A9 00
            bmi L1DFE              ; 30 07
            eor L0E21            ; 4D 21 0E
            and #$20               ; 29 20
            bne L1DCF+1            ; D0 D2
L1DFE       ldx #$0B               ; A2 0B
L1E00       lda L0E0A,X            ; BD 0A 0E
            cmp #$3F               ; C9 3F
            beq L1E0C              ; F0 05
            cmp L0E26,X          ; DD 26 0E
            bne L1DCF+1            ; D0 C4
L1E0C       dex                    ; CA
            bne L1E00              ; D0 F1
            txa                    ; 8A
L1E10       pha                    ; 48
            jsr MOVE              ; 20 19 09
            ldx #$5D               ; A2 5D
            cmp (SAVADR,X)         ; C1 68
            rts                    ; 60
L1E19       lda #$FF               ; A9 FF
            bit L0E4C            ; 2C 4C 0E
            bmi L1E10              ; 30 F0
            tax                    ; AA
            rts                    ; 60
            stx L1ED5+1            ; 8E D6 1E
            lda ICAX2Z             ; A5 2B
            sta L1EDA+1            ; 8D DB 1E
            ldy #$22               ; A0 22
            jsr L1ED1              ; 20 D1 1E
            bmi L1E61              ; 30 30
            lda ICHIDZ             ; A5 20
            sta IOCB0,X            ; 9D 40 03
            jsr L1E7C+1            ; 20 7D 1E
            bmi L1E5C              ; 30 21
            ldy #$98               ; A0 98
            bcc L1E5C              ; 90 1D
            ror L1E49+1            ; 6E 4A 1E
L1E42       jsr L1E7C+1            ; 20 7D 1E
            bmi L1E5C              ; 30 15
            bcs L1E42              ; B0 F9
L1E49       lda #$00               ; A9 00
            bpl L1E56+1            ; 10 0A
            lsr L1E49+1            ; 4E 4A 1E
            jsr MOVE              ; 20 19 09
            cmp (L0086),Y          ; D1 86
            .byte $42
L1E56       cpx #$20               ; E0 20
            .byte $92
            asl LE610,X            ; 1E 10 E6
L1E5C       lda #$FF               ; A9 FF
            sta IOCB0,X            ; 9D 40 03
L1E61       tya                    ; 98
            pha                    ; 48
            ldy #$2D               ; A0 2D
            jsr L1ED1              ; 20 D1 1E
            pla                    ; 68
            tay                    ; A8
            cpy #$88               ; C0 88
            bne L1E91              ; D0 23
            jsr MOVE              ; 20 19 09
            .byte $42
            cpx #$4D               ; E0 4D
            .byte $13
            cmp L4D13              ; CD 13 4D
            rol L00A9,X            ; 36 A9
            cpx #$D0               ; E0 D0
L1E7C       eor ICHIDZ             ; 45 20
            ora L5E09,Y            ; 19 09 5E
            .byte $89,$54,$27,$9E
            cmp #$30               ; C9 30
            ora #$AD               ; 09 AD
            stx BRKKEY             ; 86 11
            and L1185+2            ; 2D 87 11
            cmp #$FF               ; C9 FF
            tya                    ; 98
L1E91       rts                    ; 60
            jsr MOVE              ; 20 19 09
            eor L429C,X            ; 5D 9C 42
            .byte $E2,$5C
            ldx L2754              ; AE 54 27
            .byte $9E
            cmp #$30               ; C9 30
            beq L1EDA              ; F0 38
            ldx #$FE               ; A2 FE
L1EA4       lda SMEMLO+1,X         ; BD 18 0D
            sbc L1088,X            ; FD 88 10
            sta L0D53,X            ; 9D 53 0D
            inx                    ; E8
            bne L1EA4              ; D0 F4
            jsr L0863            ; 20 63 08
            eor (APPMHI),Y         ; 51 0E
            jsr MOVE              ; 20 19 09
            eor (L0086),Y          ; 51 86
            .byte $54,$27,$9E,$CF
            bmi L1E91              ; 30 D1
            lda #$E2               ; A9 E2
            jsr L1EDA              ; 20 DA 1E
            cld                    ; D8
            ldy #$01               ; A0 01
            rts                    ; 60
            jsr MOVE              ; 20 19 09
            ldx #$79               ; A2 79
            .byte $C7
            ldy #$2E               ; A0 2E
L1ED1       ldx #$00               ; A2 00
            stx FMSZPG+5           ; 86 48
L1ED5       ldx #$00               ; A2 00
            jmp L0FAC              ; 4C AC 0F
L1EDA       ldx #$00               ; A2 00
            bmi L1E91              ; 30 B3
            sta L1EE1+1            ; 8D E2 1E
L1EE1       jmp (RUNAD)            ; 6C E0 02
END_ADDR    equ *

            blk dos RUNAD
            dta a(start)
