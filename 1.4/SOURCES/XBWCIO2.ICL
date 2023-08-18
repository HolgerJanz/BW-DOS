* GETBYTE
GET         ldx FCBAUX1
GETV        equ GET-1
            cpx #$16
            beq DLG0
            lda #$00
            dta b(op_BIT_abs)
* PUBYTE
PUT         lda #$FF
PUTV        equ PUT-1
            sta RWFLG
            and #$0C
            eor #$07
            cmp ICCOMZ
            bne GP1
RTAD        lda #$00
            cmp #$E4
            bcc GP1
            ldy ICBLHZ
            bne PTA3
* Y=0
            iny
            cpy ICBLLZ
            bcs GP1

PTA3        jsr MOV_CAL
  dta h(MC_mov+ICBALZ),l(ICBALZ),h(MC_2+LDSA7B+1),l(LDSA7B+1)
  dta h(MC_mov+ICBLLZ),l(ICBLLZ),h(MC_2+L0E51),l(L0E51)
  dta h(MC_jsrE+LDSA),l(LDSA)

            php

            jsr MOV_CAL
  dta h(MC_mov+LDSA7B+1),l(LDSA7B+1),h(MC_2+ICBALZ),l(ICBALZ)
  dta h(MC_movE+L0E51),l(L0E51),h(MC_2+ICBLLZ),l(ICBLLZ)

            plp
            bmi PTA4

            jsr SBC_1
            dta a(ICBALZ)
* X=1
            lda (ICBALZ-1,X)
            inc ICBLLZ
PTA1        sta CIODTA+1
BLEX        jsr TESTEOF
            beq STAT3
            rts

GP1         jsr MOV_CAL
  dta h(MC_mov+PTA1+1),l(PTA1+1),h(MC_2+LDSA7B+1),l(LDSA7B+1)
  dta b(MC_cpyE+2,K0001-DAT_BUF,L0E51-DAT_BUF)

BLOCK       jsr LDSA
BLOCKV      equ BLOCK-1
            bpl BLEX
* EOF
PTA4        lda #$8B ; $88 eor $03
STAT3       eor #$03
            sta XOK+1
            rts

NXTDAT      jsr ZAJMAP
            iny
            iny
            sty FCBMAPX
            cpy L0045
            bne SETP6
* next map
            jsr ZAJMAP
            ldy #$00
            lda (L0043),Y
            tax
            iny
            ora (L0043),Y
            bne NEXTM2
            jsr L1B6C
            ldy #$02
NEXTM3      lda L0E3B,Y
            sta (L0043),Y
            iny
            cpy #$04
            bcc NEXTM3
            jsr ZAJMAP
            ldy #$01
NEXTM4      lda VTOCSEC,Y
            sta (L0043),Y
            dey
            bpl NEXTM4

            jsr MOV_CAL
  dta h(MC_jsr+L1C2B),l(L1C2B)
  dta b(MC_cpyE+2,VTOCSEC-DAT_BUF,FCBMAP-DAT_BUF)

            beq NEXTM1
NEXTM2      lda (L0043),Y
            sta FCBMAP+1
            stx FCBMAP
NEXTM1      jsr ZAJMAP
            ldy #$04
            sty FCBMAPX
SETP6       lda (L0043),Y
            sta FCBSECT
            iny
            lda (L0043),Y
            sta L0E3B
            ora FCBSECT
            rts

UPRAVLEN    sec
            ldx #$FD
UPRLN2      lda FCBLEN-$FD,X
            sbc FCBPOS-$FD,X
            inx
            bne UPRLN2
            bcs UPRLN3

            jsr MOV_CAL
  dta b(MC_cpyE+3,FCBPOS-DAT_BUF,FCBLEN-DAT_BUF)

            clc
UPRLN3      rts

LDSA        lda FCBAUX1
            ldy #$83
            bit RWFLG
            bpl LDSA0A
            lsr @
            ldy #$87
LDSA0A      and #$04
            bne LDSA0
            jmp RETERRY

* CLOSE
CLOSE       lda FCBAUX1
CLOSEV      equ CLOSE-1
            cmp #$16
            bne CLOS1
            lsr DLOPF
CLOS1       and #$08
            beq UPRLN3

            jsr MOV_CAL
  dta b(MC_cpy+3,FCBLEN-DAT_BUF,RENNAM-DAT_BUF)
  dta b(MC_cpy+2,FCBDIR1-DAT_BUF,FCB1ST-DAT_BUF)
  dta h(MC_jsr+OPNDRD),l(OPNDRD)
  dta h(MC_jsr+LDDIR),l(LDDIR)
  dta b(MC_cpyE+3,RENNAM-DAT_BUF,DIRBUF+3-DAT_BUF)

SADIR       lda #$FF
            dta b(op_BIT_abs)
LDDIR       lda #$00
            pha

            jsr MOV_CAL
  dta b(MC_cpy+2,FCBDIRP-DAT_BUF,POSTMP-DAT_BUF)
  dta b(MC_cpy+1,NULY-DAT_BUF,POSTMP+2-DAT_BUF)
  dta h(MC_jsrE+SETPOS),l(SETPOS)

            pla
            dta b(op_BIT_abs)
LDDIRN      lda #$00
            dta b(op_BIT_abs)
SADIRN      lda #$FF
            sta RWFLG

            jsr MOV_CAL
  dta h(MC_mov+DIRBAD+1),l(DIRBAD+1),h(MC_2+LDSA7B+1),l(LDSA7B+1)
  dta b(MC_cpyE+2,K0017-DAT_BUF,L0E51-DAT_BUF)

LDSA0       lda L0045
            sec
            sbc FCBIX
            bne LDSA2
            lda #$FF
LDSA2       sta LDSA7C+1
            lda L0E52
            bne LDSA4
            lda L0E51
            beq LDSARET
            jsr LDSAUPL
LDSA4       jsr TESTEOF
            beq LDSAEOF
            jsr LDSAUPL
            lda FCBSECT
            ora L0E3B
            bne LDSA6
            lda FCBAUX1
            and #$08
            bne LDSA5B
STPER       jsr RETERRS
            dta b($A6)
LDSAEOF     dex
LDSARET     rts

LDSA5B      jsr MOV_CAL
  dta h(MC_jsr+L1B6C),l(L1B6C)
  dta b(MC_cpy+2,VTOCSEC-DAT_BUF,FCBSECT-DAT_BUF)
  dta h(MC_jsrE+ZAJMAP),l(ZAJMAP)

            lda VTOCSEC
            sta (L0043),y
            iny
            lda VTOCSEC+1
            sta (L0043),Y
            jsr L1C2B
* jsr changed cannot be combined into a block under UNI
* UNI destroys reg. Y at the entrance
LDSA6       ldx FCBSECT
            lda L0E3B

            jsr MOV_CAL
  dta h(MC_jsr+ZAJIST),l(ZAJIST)
  dta h(MC_movE+LDSA7B+1),l(LDSA7B+1),h(MC_2+LDSA8+1),l(LDSA8+1)
* X=0
            ldy FCBIX
            bit RWFLG
            bmi LDSA8
LDSA7       lda (L0043),Y
LDSA7B       sta $FFFF,X
            iny
            inx
            cpx LDSA7C+1
            bne LDSA7
            beq LDSA9

* POINT
POINT       ldy #$FD
POINTV      equ POINT-1
POI2        lda IOCB0+ICAX3,X
            sta POSTMP-$FD,Y
            inx
            iny
            bne POI2

SETPOS      lda POSTMP+2
            bmi STPER

            jsr MOV_CAL
  dta b(MC_CPY+1,K0002-DAT_BUF,FCBMAPX-DAT_BUF)
  dta b(MC_CPY+2,FCB1ST-DAT_BUF,FCBMAP-DAT_BUF)
  dta b(MC_CPY+3,POSTMP-DAT_BUF,FCBPOS-DAT_BUF)
  dta h(MC_jsrE+UPRAVLEN),l(UPRAVLEN)

            bcs SETP3B
            lda FCBAUX1
            and #$08
            beq STPER
SETP3B      lda POSTMP
            ldx POSTMP+1
            ldy POSTMP+2
            jsr L14FD
            sta FCBIX
            stx POSTMP
            sty POSTMP+1
* forward
SETP4       jsr NXTDAT
            lda POSTMP
            ora POSTMP+1
            beq POSCXX
            jsr SBC_1
            dta a(POSTMP)
            bcs SETP4

LDSA8       lda $FFFF,X
            sta (L0043),Y
            iny
            inx
LDSA7C      cpx #$00
            bne LDSA8
            jsr L1C2B
LDSA9       lda LDSA7C+1

            jsr SBC_A
            dta a(L0E51)

            jsr ADC_L
            dta a(LDSA7B+1)

            jsr ADC_L
            dta a(FCBPOS)

            bcc LDSA11
            inc L0E42
LDSA11      jsr UPRAVLEN
            lda FCBIX
            clc
            adc LDSA7C+1
            cmp L0045
            bne LDSA12
            jsr NXTDAT
            lda #$00
LDSA12      sta FCBIX
            jmp LDSA0

TESTEOF     ldx #$FD
            sec
LDSA3       lda FCBLEN-$FD,X
            sbc FCBPOS-$FD,X
            sta POSTMP-$FD,X
            inx
            bne LDSA3
            bit RWFLG
            bmi LDSA3A
            ora POSTMP+1
            beq LDSA3B
LDSA3A      lda #$FF
POSCXX      rts

DLCLRS      jsr GETSTK
            sta DLG0+1
            asl @
            lsr @
            tax
            lda #$9B
            tay
DLCL1       sta DIBUF-1,X
            lda #$20
            dex
            bne DLCL1
            stx DLBX+1
* RTS omitted - never mind
LDSA3B      lda POSTMP
            rts

LDSAUPL     cmp LDSA7C+1
            bcs POSCXX
            sta LDSA7C+1
* RTS omitted - never mind
L14FD       bit L0045
            bpl POSCMPX
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
POSCMPX     rts

OPNDRD      lda #$14
            dta b(op_BIT_abs)
OPNINT1     lda #$0C
OPNINT      sta FCBAUX1
            pha

            jsr MOV_CAL
  dta b(MC_cpy+3,NULY-DAT_BUF,POSTMP-DAT_BUF)
  dta h(MC_jsrE+SETPOS),l(SETPOS)

            pla
            cmp #$10
            bcc OPNINT2

            jsr MOV_CAL
  dta b(MC_cpy+1,K0017-DAT_BUF,FCBLEN-DAT_BUF)
  dta h(MC_jsr+LDDIRN),l(LDDIRN)
  dta b(MC_cpyE+3,DIRBUF+3-DAT_BUF,FCBLEN-DAT_BUF)

OPNINT2      rts

OPENT       jsr MOV_CAL
  dta b(MC_cpy+11,SRCHNAM-DAT_BUF,DIRBUF+6-DAT_BUF)
  dta b(MC_cpy+3,NULY-DAT_BUF,DIRBUF+3-DAT_BUF)
  dta h(MC_movE+DATER),l(DATER),h(MC_6+L0E32),l(L0E32)

            bit TDOVER
            bpl OPNT2

            jsr MOV_CAL
  dta h(MC_movE+ODATER),l(ODATER),h(MC_6+L0E32),l(L0E32)

OPNT2       lda MYA1
            sta FCBAUX1
            and #$20
            ora #$08
            sta DIRBUF
            rts

OPNDL       bit DLOPF
            bmi DLTOO
            lda #$16
            sta MYA1

            jsr MOV_CAL
  dta h(MC_jsr+OPN3),l(OPN3)
  dta b(MC_cpyE+11,SRCHNAM-DAT_BUF,DIRNAM-DAT_BUF)

            stx DLG0+1
            lda ICAX2Z
            sta DTYPE+1
            bpl OPNDL2

            jsr DLCLRS
            dta b($2A)

            sty DIBUF+40

            jsr MOV_CAL
  dta b(MC_cpy+8,DIRVOL-DAT_BUF,DIBUF-DAT_BUF)
  dta b(MC_cpy+8,DCBVOL-DAT_BUF,DIBUF+12-DAT_BUF)
  dta b(MC_cpy+11,DLDIR-DAT_BUF,DIBUF+20-DAT_BUF)
  dta b(MC_cpyE+8,DIRBUF+6-DAT_BUF,DIBUF+32-DAT_BUF)

OPNDL2      sec
            ror DLOPF
            rts

* MD
CREDIR      lda #$28
CREDIRV     equ CREDIR-1
            ldx #$09
            bne OPEN00
* SAVE
STAT        lda ICAX1Z
STATV       equ STAT-1
            and #$F0
            ora #$04
            dta b(op_BIT_abs)
OPEN        lda $2A
OPENV       equ OPEN-1
            and #$3F
            dta b(op_BIT_abs)
OPEN014     lda #$14
OPEN0       ldx #op_AND_abs
OPEN00      stx OPNXT
            cmp #$06
            beq OPNDL
            cmp #$20
            bcc OPNER0
            and #$EF
OPNER0      sta MYA1
            and #$0F
            lsr @
            bcc OPNER0B
            cmp #$04
            bne OPNER1
OPNER0B     lsr @
            bcc OPN3

OPNER1      ldy #$A8
            dta b(op_BIT_abs)
NEWI3       ldy #$A3
            dta b(op_BIT_abs)
OPNFUL      ldy #$A9
            dta b(op_BIT_abs)
DLTOO       ldy #$A1
            jmp RETERRY

NEWILD      ldx #$0A
NEWI2       lda SRCHNAM,X
            cmp #'?'
            beq NEWI3
            dex
            bpl NEWI2
            jmp (GETTDV)

PTH         lda #$00
            bpl ERR_170

            jsr MOV_CAL
  dta b(MC_cpy+11,SRCHNAM-DAT_BUF,RENNAM-DAT_BUF)
  dta b(MC_cpy+11,DOSNAM-DAT_BUF,SRCHNAM-DAT_BUF)
  dta b(MC_cpy+2,DCBMAIN-DAT_BUF,FCB1ST-DAT_BUF)
  dta h(MC_jsr+OPNDRD),l(OPNDRD)
  dta h(MC_jsrE+L1DC5),l(L1DC5)

            bne ERR_170

            jsr MOV_CAL
  dta b(MC_cpy+11,RENNAM-DAT_BUF,SRCHNAM-DAT_BUF)
  dta b(MC_cpy+2,DIRBUF+1-DAT_BUF,FCB1ST-DAT_BUF)
  dta h(MC_jsr+OPNDRD),l(OPNDRD)
  dta h(MC_jsrE+L1DC2),l(L1DC2)

            bne ERR_170
            jmp OPNJ2

OPN3        jsr L1AAE
            php
            pla
            ror @
            ror @
            ror PTH+1
            lda MYA1
            and #$10
            bne OPNJ2BJ
            jsr OPNDRD
            jsr L1DBF
            beq OPNJE
OPNPT0      lda MYA1
            cmp #$04
            beq PTH
            and #$08
            bne OPN4B

ERR_170     jsr RETERRS
            dta b($AA)
* bookmarks
OPN4BE      jsr NEWILD
            jsr L1D4D
OPN4B       bit FCBDIRP+1
            bmi OPNFUL

            jsr MOV_CAL
  dta h(MC_jsr+NEWILD),l(NEWILD)
  dta h(MC_jsr+OPENT),l(OPENT)
  dta h(MC_jsr+L1B6C),l(L1B6C)
  dta b(MC_cpy+2,VTOCSEC-DAT_BUF,DIRBUF+1-DAT_BUF)
  dta b(MC_cpy+1,K1C-DAT_BUF,FCBAUX1-DAT_BUF)
  dta h(MC_jsr+SADIR),l(SADIR)
  dta b(MC_cpy+2,FCBDIRP-DAT_BUF,SRCHTMP-DAT_BUF)
  dta b(MC_cpy+2,NULY-DAT_BUF,FCBDIRP-DAT_BUF)
  dta h(MC_jsr+LDDIR),l(LDDIR)
  dta b(MC_cpy+3,FCBLEN-DAT_BUF,DIRBUF+3-DAT_BUF)
  dta h(MC_jsr+SADIR),l(SADIR)
  dta b(MC_cpy+2,SRCHTMP-DAT_BUF,FCBDIRP-DAT_BUF)
  dta h(MC_jsrE+LDDIR),l(LDDIR)
* DIR?
            lda MYA1
            and #$20
            beq OPN4D
* between, never fulfilled
OPNPT0J     beq OPNPT0

            jsr MOV_CAL
  dta b(MC_cpy+2,FCB1ST-DAT_BUF,SRCHTMP-DAT_BUF)
  dta b(MC_cpy+2,DIRBUF+1-DAT_BUF,FCB1ST-DAT_BUF)
  dta h(MC_jsr+OPNINT1),l(OPNINT1)
  dta h(MC_jsr+OPENT),l(OPENT)
  dta b(MC_cpy+1,K0017-DAT_BUF,DIRBUF+3-DAT_BUF)
  dta b(MC_cpy+2,SRCHTMP-DAT_BUF,DIRBUF+1-DAT_BUF)
  dta h(MC_jsr+SADIRN),l(SADIRN)
  dta b(MC_cpy+2,DIRBUF+1-DAT_BUF,FCB1ST-DAT_BUF)
  dta h(MC_jsr+OPNDRD),l(OPNDRD)
  dta h(MC_jsrE+LDDIR),l(LDDIR)

OPN4D       jmp OPNJ2

OPN4BEJ     bpl OPN4BE
OPNJ2BJ     bne OPNJ2B
OPNJE       lda MYA1
            eor DIRBUF
OPNXT       and #$20
            beq OPNJ1
            lda MYA1
            and #$08
            beq OPNPT0J
            ldy #$97
            dta b(op_BIT_abs)
OPNJP       ldy #$A4
            jmp RETERRY
OPNJ1       lda MYA1
            and #$08
            beq OPNJ2
            lda DIRBUF
            and #$21
            lsr @
            bne OPNJ2
            bcs OPNJP
            lda MYA1
            cmp #$08
            bne OPNJ2
OPNJ1A      lda #$00
            bpl OPN4BEJ
            inc MYA1

OPNJ2       jsr MOV_CAL
  dta b(MC_cpy+2,FCB1ST-DAT_BUF,FCBDIR1-DAT_BUF)
  dta b(MC_cpyE+5,DIRBUF+1-DAT_BUF,FCB1ST-DAT_BUF)

OPNJ2B      lda MYA1
            jsr OPNINT
            lda MYA1
            cmp #$10
            bcc OPNJ3
* DIR
            jsr MOV_CAL
  dta b(MC_cpy+2,FCB1ST-DAT_BUF,FCBDIR1-DAT_BUF)
  dta b(MC_cpyE+2,NULY-DAT_BUF,FCBDIRP-DAT_BUF)

            lda MYA1
            and #$07
            bne OPNJ3

            jsr MOV_CAL
  dta b(MC_cpyE+3,FCBPOS-DAT_BUF,FCBLEN-DAT_BUF)

OPNJ3       lda MYA1
            lsr @
            bcc OPNJ4

            jsr MOV_CAL
  dta b(MC_cpyE+3,FCBLEN-DAT_BUF,POSTMP-DAT_BUF)

            jmp SETPOS

* NOTE
NOTE        ldy #$00
NOTEV       equ NOTE-1
            dta b(op_BIT_abs)
* GETFLEN
GETLEN      ldy #$05
GETLENV     equ GETLEN-1
NOT2        lda FCBPOS,Y
            sta IOCB0+ICAX3,X
            iny
            inx
            txa
            and #$0F
            cmp #$03
            bcc NOT2
OPNJ4       rts
* set SIO buffer
ZAJADR      stx L1C2B+1
            lda #$FF
            sta L0F49,X
            txa
            clc
            adc >SIO_BUF
            sta L0044
            lda <SIO_BUF
            sta L0043
            rts
