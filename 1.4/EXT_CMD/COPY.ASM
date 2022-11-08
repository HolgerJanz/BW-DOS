* COPY 1.3 for BW-DOS

* System equates
            icl '_SYSEQU.ICL'

* Code equates
* offset of file name in path
path1_fn    equ $0080
path2_fn    equ $0081
* temporar variables
zp_temp1    equ $0082
L0083       equ $0083
L0084       equ $0084
L0085       equ $0085
L0086       equ $0086
L0087       equ $0087
L0088       equ $0088
L0089       equ $0089

path1       equ $0500
L0501       equ $0501
path2       equ $0540
L0580       equ $0580
L0581       equ $0581
L0588       equ $0588
L058A       equ $058A
L058C       equ $058C
L0591       equ $0591
L05E0       equ $05E0

* Opcodes 6502
opcode_BIT  equ $2c

* Start of code
start_addr  equ $3000
            org start_addr
* check DOS version
start       lda BW_SPARTA
            cmp #'S'
            beq sd_found
            jsr print
            dta b($9B)
            dta c'Incorrect DOS version'
            dta b($9B,$00)
            jmp (DOSVEC)
* set CRNAME vector
sd_found    lda DOSVEC
            clc
            adc #$03
            sta CRNAME_V+1
            lda DOSVEC+1
            adc #$00
            sta CRNAME_V+2
* check for parameters
            ldy #SD_BUFOFF
            lda (DOSVEC),Y
            clc
            adc #SD_LBUF
            tay
            lda (DOSVEC),Y
            cmp #$9B
            bne par_found
            jsr print
            dta b($9B)
            dta c'COPY 1.3 for BW-DOS'
            dta b($9B)
            dta c'Syntax: COPY source destination[/A]'
            dta b($9B,$00)
            jmp (DOSVEC)
* get paths
par_found   jsr close_123
* set path1 and path1_fn
            lda #$00
            jsr get_path
            sta path1_fn
* set path2 and path2_fn
            lda #$40
            jsr get_path
            sta path2_fn
* search fname1 for wildcards
            ldx path1_fn
nxt_fn1char lda path1,X
            inx
            cmp #'?'
            beq L6259
            cmp #'*'
            beq L6259
            cmp #$9B
            bne nxt_fn1char

            lda path1
            cmp #'D'
            beq L6256
            jsr set_p1_star
            jsr set_p2_star
            ldx path1_fn
            jsr L6427
            ldx #$0B
L6214       lda L05E0,X
            sta L0580,X
            dex
            bpl L6214
            ldx $81
            jsr L6427
            jsr L6504
            ldx $81
            jsr L610F
            bcs L6238
            ldy #SD_TDOVER 
            lda #$00
            sta (DOSVEC),Y
            jsr copy_23
            jmp close2dos
L6238       ldy #$A5 ; bad file name
            jmp error

* set path end to *.*, if no file name
set_p1_star ldx path1_fn
            dta b(opcode_BIT)
set_p2_star ldx path2_fn
            lda path1,X
            cmp #$9B
            bne no_setstar
            ldy #$03
nxt_starc   lda star.star,Y
            sta path1,X
            inx
            dey
            bpl nxt_starc
no_setstar  rts

L6256       jsr set_p1_star
L6259       jsr set_p2_star
            ldx path2_fn
            jsr L6427
            lsr L0086
            lsr L0089
            jsr L6486
            jmp chk_err

L626B       jsr L64C6
            jmp chk_err

nxt_file    ldx $80
            jsr L610F
            bcs L626B
            jsr L6504
            ldx $81
            jsr L610F
            bcs L626B
            lda #$00
            bit L0083
            bpl L62B1
            ldy #SD_ODATER
            ldx #$14
L628C       txa
            pha
            lda L0581,X
            and #$0F
            pha
            lda L0580,X
            and #$0F
            tax
            pla
            clc
            adc L6337,X
            sta (DOSVEC),Y
            pla
            tax
            inx
            inx
            inx
            iny
            cpy #$18
            bne L628C
            lda #$00
            sta (DOSVEC),Y
            lda #$FF
L62B1       ldy #SD_TDOVER
            sta (DOSVEC),Y
            jsr L64C6
            lda path1
            cmp #$44 
            bne cpy_file
            ldx #$FF
L62C1       inx
            lda path1,X
            cmp path2,X
            bne cpy_file
            cmp #$9B
            bne L62C1
            jsr print
            dta b($9B)
            dta c'Can''t copy a file to itself !'
            dta b($9B,$00)
            jmp abort2dos

* print file name and copy file
cpy_file    jsr print
            dta c'Copying '
            dta b($00)
            ldx #$00
            lda <path1
            sta IOCB0+ICBAL,X
            lda >path2
            sta IOCB0+ICBAH,X
            lda #$40
            sta IOCB0+ICBLL,X
            lda #$00
            sta IOCB0+ICBLH,X
            lda #$09 ; put record
            sta IOCB0+ICCOM,X
            jsr CIOV
            sec
            ror L0086
            jsr copy_23

* check for error and exit
chk_err     lda L0089
            bmi L632B
            jmp nxt_file
L632B       lda L0086
            bpl L6332
            jmp close2dos
L6332       ldy #$AA ; File not found
            jmp error

L6337       dta b(00,10,20,30,40,50,60,70)
            dta b(80,90,00,00,00,00,00,00)

* copy file IOCB 1 to 2
copy_23     jsr close_23
            lsr L0087
            lsr L0088
L634E       ldx #$03
L6350       lda #$00
            sta _memsiz,X
            lda MEMTOP,X
            sta _memtop2,X
            dex
            bpl L6350
            lda #$00 
            sta L0085
            jsr get_bytes
            bmi L636E
            lda #$02
            jsr get_bytes
            bpl L6373
L636E       dec L0085
            jsr close_2
L6373       lda #$00
            jsr put_bytes
            lda #$02
            jsr put_bytes
            lda L0085
            beq L634E
            jmp close_23

_memtop     dta a(start_addr)
_memtop2    dta a($8000)

_memlow     dta a($5000)
            dta a(_memlo2)

_memsiz     dta a($0000)
            dta a($0000)

get_bytes   pha
            lda L0087
            bmi L63A1
            sec
            ror L0087
            ldx #$20
            lda #$04
            ldy #$00
            jsr open_m
L63A1       pla
            tay
            ldx #$20
            lda _memlow,Y
            sta IOCB0+ICBAL,X
            lda _memlow+1,Y
            sta IOCB0+ICBAH,X
            lda _memtop,Y
            sec
            sbc _memlow,Y
            sta IOCB0+ICBLL,X
            lda _memtop+1,Y
            sbc _memlow+1,Y
            sta IOCB0+ICBLH,X
            lda #$07 ; get chars
            sta IOCB0+ICCOM,X
            tya
            pha
            jsr CIOV
            sty zp_temp1
            pla
            tay
            lda IOCB0+ICBLL,X
            sta _memsiz,Y
            lda IOCB0+ICBLH,X
            sta _memsiz+1,Y
            ldy zp_temp1
            bpl L63E6
            cpy #$88 
            bne L6424
L63E6       tya
            rts

put_bytes   pha
            lda L0088
            bmi L63F9
            sec
            ror L0088
            ldx #$30
            lda L0084
            ldy #$40
            jsr open_m
L63F9       pla
            tay
            ldx #$30
            lda _memlow,Y
            sta IOCB0+ICBAL,X
            lda _memlow+1,Y
            sta IOCB0+ICBAH,X
            lda _memsiz,Y
            sta IOCB0+ICBLL,X
            lda _memsiz+1,Y
            sta IOCB0+ICBLH,X
            ora _memsiz,Y
            beq L63E6
            lda #$0B ; put chars
            sta IOCB0+ICCOM,X
            jsr CIOV
            bpl L63E6
L6424       jmp error

L6427       ldy #$00
            lda #$06
            sta zp_temp1
            bne L643A
L642F       lda #$3F
            jsr L646C
            bcc L642F
L6436       jsr L646C
L6439       inx
L643A       lda path1,X
            cmp #$2A
            beq L642F
            cmp #$2E
            beq L644C
            jsr char_ok
            bcc L6436
            ror zp_temp1
L644C       lda #$20
            jsr L646C
            bcc L644C
            ror zp_temp1
            bcc L6439
            lda #$08
            sta L0084
            lda path1,X
            cmp #$2F
            bne L646B
            lda L0501,X
            cmp #$41
            bne L646B
            inc L0084
L646B       rts

L646C       cpy #$08
            bcc L6479
            bit zp_temp1
            bpl L6478
            cpy #$0B 
            bcc L647C
L6478       rts
L6479       sta L05E0,Y
L647C       iny
            sta L05E0,Y
            rts

L6481       ldy #$94
            jmp error

L6486       lsr L0083
            ldx #$10
            lda #$06
            sta IOCB0+ICAX1,X
            lda #$80
            ldy path1
            cpy #$44
            beq L6499
            asl @
L6499       sta IOCB0+ICAX2,X
            ldy #$00
            jsr open
            jsr get_rec
            bmi L6481
            lda L0580
            cmp #$9B
            bne L64CB
            jsr get_rec
            bmi L6481
            lda L0581
            cmp #$6F
            bne L64CB
            jsr get_rec
            bmi L6481
            jsr get_rec
            bmi L6481
            sec
            ror L0083
L64C6       jsr get_rec
            bmi L64FC
L64CB       lda L0083
            bmi L64F1
            lda L0580
            cmp #$30
            bcs L64FC
            lda L058A
            bmi L64C6
            ldx #$02
            ldy #$00
L64DF       lda L0580,X
            sta L0580,Y
            inx
            iny
            cpx #$0A
            bne L64EC
            iny
L64EC       cpx #$0D 
            bcc L64DF
L64F0       rts

L64F1       lda L0591
            cmp #$3A
            bcc L64F0
            cmp #$40
            bcc L64C6
L64FC       sec
            ror L0089
close_1     ldx #$10
            jmp close

L6504       ldx #$0B
L6506       lda L05E0,X
            cmp #$3F
            beq L6510
            sta L0580,X
L6510       dex
            bpl L6506
            rts

* print string to console
print       pla
            sta L6013+1
            pla
            sta L6013+2
L600B       inc L6013+1
            bne L6013
            inc L6013+2
L6013       lda $FFFF
            beq L601E
            jsr put_char
            jmp L600B
L601E       lda L6013+2
            pha
            lda L6013+1
            pha
L6026       rts

* put char to console
put_char    tay
            lda #$00
            tax
            sta IOCB0+ICBLL,X
            sta IOCB0+ICBLH,X
            lda #$0B
            sta IOCB0+ICCOM,X
            tya
            jmp CIOV

* CRNAME vector
CRNAME_V    jmp L6026

* get parameter set path
* >A start offset $00 or $40
* A> contains offset of file name
get_path    pha
            jsr CRNAME_V
            pla
            tax
            ldy #SD_COMFNAM
set_nameoff stx zp_temp1
nxt_pchar   lda (DOSVEC),Y
            sta path1,X
            inx
            iny
            cmp #':'
            beq set_nameoff
            cmp #'>'
            beq set_nameoff
            cmp #'<'
            beq set_nameoff
            cmp #$9B
            bne nxt_pchar
            lda zp_temp1
_rts        rts

* close IOCBs
close_123   jsr close_1
close_23    ldx #$30
            jsr close
close_2     ldx #$20
close       lda #$0C
            sta IOCB0+ICCOM,X
            jsr CIOV
            bpl _rts
            jmp error

star.star   dta b($9B),c'*.*'

* open IOCB number X mode A
open_m      sta IOCB0+ICAX1,X
            lda #$00
            sta IOCB0+ICAX2,X
open        tya
            sta IOCB0+ICBAL,X
            lda #$05
            sta IOCB0+ICBAH,X
            lda #$03
            sta IOCB0+ICCOM,X
            jsr CIOV
            bmi error
L6097       tya
            rts

get_rec     ldx #$10
            lda #$05
            sta IOCB0+ICCOM,X
            lda #$80
            sta IOCB0+ICBAL,X
            lda #$05
            sta IOCB0+ICBAH,X
            lda #$40
            sta IOCB0+ICBLL,X
            lda #$00
            sta IOCB0+ICBLH,X
            jsr CIOV
            bpl L6097
            cpy #$88
            beq L6097

* error message and handling
error       tya
            pha
            jsr print
            dta b($9B)
            dta c'Error '
            dta b($00)
* conv hex error code to dec ATASCII
            ldx #$02
            pla
nxt_digit   ldy #$00
nxt_sbc     cmp dec_dig,X
            bcc prn_digit
            sbc dec_dig,X
            iny
            bne nxt_sbc
prn_digit   pha
            txa
            pha
            tya
            ora #$30
            jsr put_char
            pla
            tax
            pla
            dex
            bpl nxt_digit
            lda #$9B
            jsr put_char
* stop batch (force end of file)
abort2dos   ldy #SD_XDIVIO
            lda (DOSVEC),Y 
            sta ZXDIVIO_V+1
            iny
            lda (DOSVEC),Y 
            sta ZXDIVIO_V+2
            ldy #$01
ZXDIVIO_V   jsr WARMSV
close2dos   jsr close_123
* reset date time override flag
            ldy #SD_TDOVER
            lda #$00
            sta (DOSVEC),Y
            jmp (DOSVEC)

dec_dig     dta b(1,10,100)

L610F       lda #$20
            sta L058C
            sta L0588
            ldy #$FF
            bmi L6124
L611B       jsr char_ok
            bcs L613A
L6120       sta path1,X
            inx
L6124       iny
            lda L0580,Y
            cmp #$20
            bne L611B
            lda #$2E
            cpy #$09
            ldy #$08
            bcc L6120
            lda #$9B
            sta path1,X
clc_rts     clc
L613A       rts

* check for valid character
char_ok     cmp #'?'
            beq clc_rts
            cmp #'_'
            beq clc_rts
            cmp #'0'
            bcc sec_rts
            cmp #':'
            bcc clc_rts
            cmp #'A'
            bcc sec_rts
            cmp #'['
            bcc clc_rts
sec_rts     sec
            rts

* start buffer 2 
_memlo2     equ *

            end
