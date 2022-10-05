* COPY 1.3 for BW-DOS

* System equates
            icl '_SYSEQU.ASM'

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
; search fname1 for wildcards
            ldx path1_fn
nxt_fn1char lda path1,X
            inx
            cmp #'?'
            beq L6259
            cmp #'*'
            beq L6259
            cmp #$9B
            bne nxt_fn1char

            lda path1              ; AD 00 05
            cmp #'D'               ; C9 44
            beq L6256              ; F0 4F
            jsr set_p1_star        ; 20 3D 62
            jsr set_p2_star        ; 20 40 62
            ldx path1_fn           ; A6 80
            jsr L6427              ; 20 27 64
            ldx #$0B               ; A2 0B
L6214       lda L05E0,X            ; BD E0 05
            sta L0580,X            ; 9D 80 05
            dex                    ; CA
            bpl L6214              ; 10 F7
            ldx $81                ; A6 81
            jsr L6427              ; 20 27 64
            jsr L6504              ; 20 04 65
            ldx $81                ; A6 81
            jsr L610F              ; 20 0F 61
            bcs L6238              ; B0 0C
            ldy #SD_TDOVER         ; A0 19
            lda #$00               ; A9 00
            sta (DOSVEC),Y         ; 91 0A
            jsr copy_23              ; 20 47 63
            jmp close2dos          ; 4C 00 61
L6238       ldy #$A5 ; bad file name ; A0 A5
            jmp error              ; 4C BD 60

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

L6256       jsr set_p1_star        ; 20 3D 62
L6259       jsr set_p2_star        ; 20 40 62
            ldx path2_fn           ; A6 81
            jsr L6427              ; 20 27 64
            lsr L0086              ; 46 86
            lsr L0089              ; 46 89
            jsr L6486              ; 20 86 64
            jmp chk_err              ; 4C 24 63

L626B       jsr L64C6              ; 20 C6 64
            jmp chk_err              ; 4C 24 63

nxt_file    ldx $80              ; A6 80
            jsr L610F              ; 20 0F 61
            bcs L626B              ; B0 F3
            jsr L6504              ; 20 04 65
            ldx $81                ; A6 81
            jsr L610F              ; 20 0F 61
            bcs L626B              ; B0 E9
            lda #$00               ; A9 00
            bit L0083              ; 24 83
            bpl L62B1              ; 10 29
            ldy #SD_ODATER         ; A0 13
            ldx #$14               ; A2 14
L628C       txa                    ; 8A
            pha                    ; 48
            lda L0581,X            ; BD 81 05
            and #$0F               ; 29 0F
            pha                    ; 48
            lda L0580,X            ; BD 80 05
            and #$0F               ; 29 0F
            tax                    ; AA
            pla                    ; 68
            clc                    ; 18
            adc L6337,X            ; 7D 37 63
            sta (DOSVEC),Y         ; 91 0A
            pla                    ; 68
            tax                    ; AA
            inx                    ; E8
            inx                    ; E8
            inx                    ; E8
            iny                    ; C8
            cpy #$18               ; C0 18
            bne L628C              ; D0 E1
            lda #$00               ; A9 00
            sta (DOSVEC),Y         ; 91 0A
            lda #$FF               ; A9 FF
L62B1       ldy #SD_TDOVER         ; A0 19
            sta (DOSVEC),Y         ; 91 0A
            jsr L64C6              ; 20 C6 64
            lda path1              ; AD 00 05
            cmp #$44               ; C9 44
            bne cpy_file              ; D0 35
            ldx #$FF               ; A2 FF
L62C1       inx                    ; E8
            lda path1,X            ; BD 00 05
            cmp path2,X            ; DD 40 05
            bne cpy_file              ; D0 2A
            cmp #$9B               ; C9 9B
            bne L62C1              ; D0 F3
            jsr print              ; 20 03 60
            .byte $9B
            .byte 'Can''t copy a file to itself !'
            .byte $9B,$00
            jmp abort2dos              ; 4C EE 60

; print file name and copy file
cpy_file    jsr print              ; 20 03 60
            .byte 'Copying '
            .byte $00
            ldx #$00               ; A2 00
            lda #<path1               ; A9 00
            sta IOCB0+ICBAL,X      ; 9D 44 03
            lda #>path2               ; A9 05
            sta IOCB0+ICBAH,X      ; 9D 45 03
            lda #$40               ; A9 40
            sta IOCB0+ICBLL,X      ; 9D 48 03
            lda #$00               ; A9 00
            sta IOCB0+ICBLH,X      ; 9D 49 03
            lda #$09 ; put record  ; A9 09
            sta IOCB0+ICCOM,X      ; 9D 42 03
            jsr CIOV               ; 20 56 E4
            sec                    ; 38
            ror L0086              ; 66 86
            jsr copy_23              ; 20 47 63

; check for error and exit
chk_err     lda L0089              ; A5 89
            bmi L632B              ; 30 03
            jmp nxt_file              ; 4C 71 62
L632B       lda L0086              ; A5 86
            bpl L6332              ; 10 03
            jmp close2dos          ; 4C 00 61
L6332       ldy #$AA ; File not found ; A0 AA
            jmp error              ; 4C BD 60

L6337       .byte 00,10,20,30,40,50,60,70
            .byte 80,90,00,00,00,00,00,00

; copy file IOCB 1 to 2
copy_23     jsr close_23           ; 20 64 60
            lsr L0087              ; 46 87
            lsr L0088              ; 46 88
L634E       ldx #$03               ; A2 03
L6350       lda #$00               ; A9 00
            sta _memsiz,X            ; 9D 8C 63
            lda MEMTOP,X           ; BD E5 02
            sta _memtop2,X           ; 9D 86 63
            dex                    ; CA
            bpl L6350              ; 10 F2
            lda #$00               ; A9 00
            sta L0085              ; 85 85
            jsr get_bytes              ; 20 90 63
            bmi L636E              ; 30 07
            lda #$02               ; A9 02
            jsr get_bytes              ; 20 90 63
            bpl L6373              ; 10 05
L636E       dec L0085              ; C6 85
            jsr close_2              ; 20 69 60
L6373       lda #$00               ; A9 00
            jsr put_bytes              ; 20 E8 63
            lda #$02               ; A9 02
            jsr put_bytes              ; 20 E8 63
            lda L0085              ; A5 85
            beq L634E              ; F0 CD
            jmp close_23           ; 4C 64 60

_memtop     .word start_addr
_memtop2    .word $8000

_memlow     .word $5000
            .word _memlo2

_memsiz     .word $0000
            .word $0000

get_bytes   pha                    ; 48
            lda L0087              ; A5 87
            bmi L63A1              ; 30 0C
            sec                    ; 38
            ror L0087              ; 66 87
            ldx #$20               ; A2 20
            lda #$04               ; A9 04
            ldy #$00               ; A0 00
            jsr open_m             ; 20 7C 60
L63A1       pla                    ; 68
            tay                    ; A8
            ldx #$20               ; A2 20
            lda _memlow,Y          ; B9 88 63
            sta IOCB0+ICBAL,X      ; 9D 44 03
            lda _memlow+1,Y        ; B9 89 63
            sta IOCB0+ICBAH,X      ; 9D 45 03
            lda _memtop,Y          ; B9 84 63
            sec                    ; 38
            sbc _memlow,Y          ; F9 88 63
            sta IOCB0+ICBLL,X      ; 9D 48 03
            lda _memtop+1,Y        ; B9 85 63
            sbc _memlow+1,Y        ; F9 89 63
            sta IOCB0+ICBLH,X      ; 9D 49 03
            lda #$07 ; get chars   ; A9 07
            sta IOCB0+ICCOM,X      ; 9D 42 03
            tya                    ; 98
            pha                    ; 48
            jsr CIOV               ; 20 56 E4
            sty zp_temp1              ; 84 82
            pla                    ; 68
            tay                    ; A8
            lda IOCB0+ICBLL,X      ; BD 48 03
            sta _memsiz,Y            ; 99 8C 63
            lda IOCB0+ICBLH,X      ; BD 49 03
            sta _memsiz+1,Y            ; 99 8D 63
            ldy zp_temp1              ; A4 82
            bpl L63E6              ; 10 04
            cpy #$88               ; C0 88
            bne L6424              ; D0 3E
L63E6       tya                    ; 98
            rts                    ; 60

put_bytes   pha                    ; 48
            lda L0088              ; A5 88
            bmi L63F9              ; 30 0C
            sec                    ; 38
            ror L0088              ; 66 88
            ldx #$30               ; A2 30
            lda L0084              ; A5 84
            ldy #$40               ; A0 40
            jsr open_m             ; 20 7C 60
L63F9       pla                    ; 68
            tay                    ; A8
            ldx #$30               ; A2 30
            lda _memlow,Y          ; B9 88 63
            sta IOCB0+ICBAL,X      ; 9D 44 03
            lda _memlow+1,Y        ; B9 89 63
            sta IOCB0+ICBAH,X      ; 9D 45 03
            lda _memsiz,Y          ; B9 8C 63
            sta IOCB0+ICBLL,X      ; 9D 48 03
            lda _memsiz+1,Y        ; B9 8D 63
            sta IOCB0+ICBLH,X      ; 9D 49 03
            ora _memsiz,Y          ; 19 8C 63
            beq L63E6              ; F0 CC
            lda #$0B ; put chars   ; A9 0B
            sta IOCB0+ICCOM,X      ; 9D 42 03
            jsr CIOV               ; 20 56 E4
            bpl L63E6              ; 10 C2
L6424       jmp error              ; 4C BD 60

L6427       ldy #$00               ; A0 00
            lda #$06               ; A9 06
            sta zp_temp1              ; 85 82
            bne L643A              ; D0 0B
L642F       lda #$3F               ; A9 3F
            jsr L646C              ; 20 6C 64
            bcc L642F              ; 90 F9
L6436       jsr L646C              ; 20 6C 64
L6439       inx                    ; E8
L643A       lda path1,X            ; BD 00 05
            cmp #$2A               ; C9 2A
            beq L642F              ; F0 EE
            cmp #$2E               ; C9 2E
            beq L644C              ; F0 07
            jsr char_ok              ; 20 3B 61
            bcc L6436              ; 90 EC
            ror zp_temp1              ; 66 82
L644C       lda #$20               ; A9 20
            jsr L646C              ; 20 6C 64
            bcc L644C              ; 90 F9
            ror zp_temp1              ; 66 82
            bcc L6439              ; 90 E2
            lda #$08               ; A9 08
            sta L0084              ; 85 84
            lda path1,X            ; BD 00 05
            cmp #$2F               ; C9 2F
            bne L646B              ; D0 09
            lda L0501,X            ; BD 01 05
            cmp #$41               ; C9 41
            bne L646B              ; D0 02
            inc L0084              ; E6 84
L646B       rts                    ; 60

L646C       cpy #$08               ; C0 08
            bcc L6479              ; 90 09
            bit zp_temp1              ; 24 82
            bpl L6478              ; 10 04
            cpy #$0B               ; C0 0B
            bcc L647C              ; 90 04
L6478       rts                    ; 60
L6479       sta L05E0,Y            ; 99 E0 05
L647C       iny                    ; C8
            sta L05E0,Y            ; 99 E0 05
            rts                    ; 60

L6481       ldy #$94               ; A0 94
            jmp error              ; 4C BD 60

L6486       lsr L0083              ; 46 83
            ldx #$10               ; A2 10
            lda #$06               ; A9 06
            sta IOCB0+ICAX1,X      ; 9D 4A 03
            lda #$80               ; A9 80
            ldy path1              ; AC 00 05
            cpy #$44               ; C0 44
            beq L6499              ; F0 01
            asl                    ; 0A
L6499       sta IOCB0+ICAX2,X      ; 9D 4B 03
            ldy #$00               ; A0 00
            jsr open              ; 20 84 60
            jsr get_rec              ; 20 99 60
            bmi L6481              ; 30 DB
            lda L0580              ; AD 80 05
            cmp #$9B               ; C9 9B
            bne L64CB              ; D0 1E
            jsr get_rec              ; 20 99 60
            bmi L6481              ; 30 CF
            lda L0581              ; AD 81 05
            cmp #$6F               ; C9 6F
            bne L64CB              ; D0 12
            jsr get_rec              ; 20 99 60
            bmi L6481              ; 30 C3
            jsr get_rec              ; 20 99 60
            bmi L6481              ; 30 BE
            sec                    ; 38
            ror L0083              ; 66 83
L64C6       jsr get_rec              ; 20 99 60
            bmi L64FC              ; 30 31
L64CB       lda L0083              ; A5 83
            bmi L64F1              ; 30 22
            lda L0580              ; AD 80 05
            cmp #$30               ; C9 30
            bcs L64FC              ; B0 26
            lda L058A              ; AD 8A 05
            bmi L64C6              ; 30 EB
            ldx #$02               ; A2 02
            ldy #$00               ; A0 00
L64DF       lda L0580,X            ; BD 80 05
            sta L0580,Y            ; 99 80 05
            inx                    ; E8
            iny                    ; C8
            cpx #$0A               ; E0 0A
            bne L64EC              ; D0 01
            iny                    ; C8
L64EC       cpx #$0D               ; E0 0D
            bcc L64DF              ; 90 EF
L64F0       rts                    ; 60

L64F1       lda L0591              ; AD 91 05
            cmp #$3A               ; C9 3A
            bcc L64F0              ; 90 F8
            cmp #$40               ; C9 40
            bcc L64C6              ; 90 CA
L64FC       sec                    ; 38
            ror L0089              ; 66 89
close_1     ldx #$10               ; A2 10
            jmp close              ; 4C 6B 60

L6504       ldx #$0B               ; A2 0B
L6506       lda L05E0,X            ; BD E0 05
            cmp #$3F               ; C9 3F
            beq L6510              ; F0 03
            sta L0580,X            ; 9D 80 05
L6510       dex                    ; CA
            bpl L6506              ; 10 F3
            rts                    ; 60

; print string to console
print       pla                    ; 68
            sta L6013+1            ; 8D 14 60
            pla                    ; 68
            sta L6013+2            ; 8D 15 60
L600B       inc L6013+1            ; EE 14 60
            bne L6013              ; D0 03
            inc L6013+2            ; EE 15 60
L6013       lda $FFFF              ; AD FF FF
            beq L601E              ; F0 06
            jsr put_char           ; 20 27 60
            jmp L600B              ; 4C 0B 60
L601E       lda L6013+2            ; AD 15 60
            pha                    ; 48
            lda L6013+1            ; AD 14 60
            pha                    ; 48
L6026       rts                    ; 60

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

; open IOCB number X mode A
open_m      sta IOCB0+ICAX1,X      ; 9D 4A 03
            lda #$00               ; A9 00
            sta IOCB0+ICAX2,X      ; 9D 4B 03
open        tya                    ; 98
            sta IOCB0+ICBAL,X      ; 9D 44 03
            lda #$05               ; A9 05
            sta IOCB0+ICBAH,X      ; 9D 45 03
            lda #$03               ; A9 03
            sta IOCB0+ICCOM,X      ; 9D 42 03
            jsr CIOV               ; 20 56 E4
            bmi error              ; 30 26
L6097       tya                    ; 98
            rts                    ; 60

get_rec     ldx #$10               ; A2 10
            lda #$05               ; A9 05
            sta IOCB0+ICCOM,X      ; 9D 42 03
            lda #$80               ; A9 80
            sta IOCB0+ICBAL,X      ; 9D 44 03
            lda #$05               ; A9 05
            sta IOCB0+ICBAH,X      ; 9D 45 03
            lda #$40               ; A9 40
            sta IOCB0+ICBLL,X      ; 9D 48 03
            lda #$00               ; A9 00
            sta IOCB0+ICBLH,X      ; 9D 49 03
            jsr CIOV               ; 20 56 E4
            bpl L6097              ; 10 DE
            cpy #$88               ; C0 88
            beq L6097              ; F0 DA

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

L610F       lda #$20               ; A9 20
            sta L058C              ; 8D 8C 05
            sta L0588              ; 8D 88 05
            ldy #$FF               ; A0 FF
            bmi L6124              ; 30 09
L611B       jsr char_ok              ; 20 3B 61
            bcs L613A              ; B0 1A
L6120       sta path1,X            ; 9D 00 05
            inx                    ; E8
L6124       iny                    ; C8
            lda L0580,Y            ; B9 80 05
            cmp #$20               ; C9 20
            bne L611B              ; D0 EF
            lda #$2E               ; A9 2E
            cpy #$09               ; C0 09
            ldy #$08               ; A0 08
            bcc L6120              ; 90 EC
            lda #$9B               ; A9 9B
            sta path1,X            ; 9D 00 05
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