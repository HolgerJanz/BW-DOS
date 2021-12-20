;
; Command BOOT file_name
;

;
; System equates
;
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

DOSVEC      equ $000A
DDEVIC      equ $0300
IOCB0       equ $0340
CIOV        equ $E456
WARMSV      equ $E474
;
; Code equates
;
L0080       equ $0080
L0082       equ $0082

L0500       equ $0500
L0528       equ $0528
L0540       equ $0540
L05C0       equ $05C0

L0700       equ $0700
;
; Start of code
;
            org $6000
;
            jmp start              ; 4C 22 61

            icl '_PRINT.ASM'

crname      jmp L6026              ; 4C 26 60

get_par     jsr crname              ; 20 3A 60
            ldx #$00               ; A2 00
            ldy #$22               ; A0 22
            lda (DOSVEC),Y         ; B1 0A
            and #$0F               ; 29 0F
            sta _dunit             ; 8D 49 62
            dey                    ; 88
L604C       stx L0080              ; 86 80
L604E       lda (DOSVEC),Y         ; B1 0A
            sta L0500,X            ; 9D 00 05
            inx                    ; E8
            iny                    ; C8
            cmp #':'               ; C9 3A
            beq L604C              ; F0 F3
            cmp #'>'               ; C9 3E
            beq L604C              ; F0 EF
            cmp #'<'               ; C9 3C
            beq L604C              ; F0 EB
            cmp #$9B               ; C9 9B
            bne L604E              ; D0 E9
L6026       rts                    ; 60

L6066       ldx L0080              ; A6 80
            ldy #$00               ; A0 00
            lda #$06               ; A9 06
            sta L0080+1            ; 85 81
            dex                    ; CA
L606F       inx                    ; E8
            lda L0500,X            ; BD 00 05
            cmp #$2A               ; C9 2A
            beq L609C              ; F0 25
            cmp #$2E               ; C9 2E
            beq L60A8              ; F0 2D
            cmp #$3F               ; C9 3F
            beq L6084              ; F0 05
            jsr L610A              ; 20 0A 61
            bcs L60A5              ; B0 21
L6084       jsr L608A              ; 20 8A 60
            jmp L606F              ; 4C 6F 60
L608A       cpy #$08               ; C0 08
            bcc L6097              ; 90 09
            bit L0080+1            ; 24 81
            bpl L6096              ; 10 04
            cpy #$0B               ; C0 0B
            bcc L6097              ; 90 01
L6096       rts                    ; 60
L6097       sta L0540,Y            ; 99 40 05
            iny                    ; C8
            rts                    ; 60
L609C       lda #$3F               ; A9 3F
            jsr L608A              ; 20 8A 60
            bcc L609C              ; 90 F9
            bcs L606F              ; B0 CA
L60A5       sec                    ; 38
            ror L0080+1            ; 66 81
L60A8       lda #$20               ; A9 20
            jsr L608A              ; 20 8A 60
            bcc L60A8              ; 90 F9
            ror L0080+1            ; 66 81
            bcc L606F              ; 90 BC
            rts                    ; 60

error       tya                    ; 98
            pha                    ; 48
            jsr _print              ; 20 03 60
            .byte $9B
            .byte 'Error '
            .byte $00
            ldx #$02               ; A2 02
            pla                    ; 68
; output error number in decimal
L60C4       ldy #$00               ; A0 00
L60C6       cmp decimal,X            ; DD FD 60
            bcc L60D1              ; 90 06
            sbc decimal,X            ; FD FD 60
            iny                    ; C8
            bne L60C6              ; D0 F5
L60D1       pha                    ; 48
            txa                    ; 8A
            pha                    ; 48
            tya                    ; 98
            ora #$30               ; 09 30
            jsr _putc              ; 20 27 60
            pla                    ; 68
            tax                    ; AA
            pla                    ; 68
            dex                    ; CA
            bpl L60C4              ; 10 E4
            lda #$9B               ; A9 9B
            jsr _putc              ; 20 27 60
; stop batch
L60E5       ldy #$08               ; A0 08
            lda (DOSVEC),Y         ; B1 0A
            sta xdivio+1            ; 8D F5 60
            iny                    ; C8
            lda (DOSVEC),Y         ; B1 0A
            sta xdivio+2            ; 8D F6 60
            ldy #$01               ; A0 01
xdivio      jsr WARMSV             ; 20 74 E4
            jsr close              ; 20 00 61
            jmp (DOSVEC)           ; 6C 0A 00

decimal     .byte 1,10,100

close       ldx #$10               ; A2 10
            lda #$0C               ; A9 0C
            sta IOCB0+ICCOM,X      ; 9D 42 03
            jmp CIOV               ; 4C 56 E4
L610A       cmp #$5F               ; C9 5F
            beq L611E              ; F0 10
            cmp #$30               ; C9 30
            bcc L6120              ; 90 0E
            cmp #$3A               ; C9 3A
            bcc L611E              ; 90 08
            cmp #$41               ; C9 41
            bcc L6120              ; 90 06
            cmp #$5B               ; C9 5B
            bcs L6120              ; B0 02
L611E       clc                    ; 18
            rts                    ; 60
L6120       sec                    ; 38
            rts                    ; 60

start       lda $700              ; AD 00 07
            cmp #$53               ; C9 53
            beq L6148              ; F0 1F
            jsr _print             ; 20 03 60
            .byte $9B,$FD
            .byte 'Incorrect DOS version'
            .byte $9B,$00
            jmp (DOSVEC)           ; 6C 0A 00
; set crname
L6148       lda DOSVEC             ; A5 0A
            clc                    ; 18
            adc #$03               ; 69 03
            sta crname+1            ; 8D 3B 60
            lda DOSVEC+1           ; A5 0B
            adc #$00               ; 69 00
            sta crname+2            ; 8D 3C 60
; set lsio
            lda DOSVEC             ; A5 0A
            sec                    ; 38
            sbc #$0A               ; E9 0A
            sta L0082              ; 85 82
            sta lsio+1             ; 8D 55 62
            lda DOSVEC+1           ; A5 0B
            sbc #$00               ; E9 00
            sta L0082+1            ; 85 83
            sta lsio+2             ; 8D 56 62

            jsr close              ; 20 00 61
            jsr get_par              ; 20 3D 60
            jsr L6066              ; 20 66 60
; open
            ldx #$10               ; A2 10
            lda #$03               ; A9 03
            sta IOCB0+ICCOM,X      ; 9D 42 03
            lda <L0500             ; A9 00
            sta IOCB0+ICBAL,X      ; 9D 44 03
            lda >L0500             ; A9 05
            sta IOCB0+ICBAH,X      ; 9D 45 03
            lda #$14               ; A9 14
            sta IOCB0+ICBLH,X      ; 9D 49 03
            sta IOCB0+ICAX1,X      ; 9D 4A 03
            lda #$00               ; A9 00
            sta IOCB0+ICAX2,X      ; 9D 4B 03
            jsr CIOV               ; 20 56 E4
            bpl L6199              ; 10 03
L6196       jmp error              ; 4C B4 60
; get chars
L6199       ldx #$10               ; A2 10
            lda #$07               ; A9 07
            sta IOCB0+ICCOM,X      ; 9D 42 03
            lda <L05C0               ; A9 C0
            sta IOCB0+ICBAL,X      ; 9D 44 03
            lda >L05C0               ; A9 05
            sta IOCB0+ICBAH,X      ; 9D 45 03
            lda #$17               ; A9 17
            sta IOCB0+ICBLL,X      ; 9D 48 03
            lda #$00               ; A9 00
            sta IOCB0+ICBLH,X      ; 9D 49 03
            jsr CIOV               ; 20 56 E4
            bpl L61D5              ; 10 1C
            cpy #$88               ; C0 88
            bne L6196              ; D0 D9
            jsr _print             ; 20 03 60
            .byte $9B
            .byte 'File not found!'
            .byte $9B,$00
            jmp L60E5              ; 4C E5 60
L61D5       ldx #$0A               ; A2 0A
L61D7       lda L0540,X            ; BD 40 05
            cmp #$3F               ; C9 3F
            beq L61E3              ; F0 05
            cmp L05C0+6,X            ; DD C6 05
            bne L6199              ; D0 B6
L61E3       dex                    ; CA
            bpl L61D7              ; 10 F1
            lda L05C0              ; AD C0 05
            and #$28               ; 29 28
            cmp #$08               ; C9 08
            bne L6199              ; D0 AA
; close
            jsr close              ; 20 00 61
; read write sector 1
            jsr read              ; 20 21 62
            lda L05C0+1            ; AD C1 05
            sta L0528              ; 8D 28 05
            lda L05C0+2            ; AD C2 05
            sta L0528+1            ; 8D 29 05
            jsr write              ; 20 27 62
            jsr _print             ; 20 03 60
            .byte $9B
            .byte 'BOOT-file installed.'
            .byte $9B,$00
            jmp (DOSVEC)           ; 6C 0A 00

read        lda #$52               ; A9 52
            ldy #$40               ; A0 40
            bne L622D              ; D0 06
; set write command from WRTCMD
write       ldy #$08               ; A0 08
            lda (L0082),Y          ; B1 82
            ldy #$80               ; A0 80
L622D       sta _dcomnd              ; 8D 4A 62
            sty _dstats              ; 8C 4B 62
            ldx #$0B               ; A2 0B
L6235       lda _ddevic,X            ; BD 48 62
            sta DDEVIC,X           ; 9D 00 03
            dex                    ; CA
            bpl L6235              ; 10 F7
            jsr lsio              ; 20 54 62
            tya                    ; 98
            bmi L6245              ; 30 01
            rts                    ; 60
L6245       jmp error              ; 4C B4 60

_ddevic     .byte $31
_dunit      .byte $00          ; and (L0000),Y ; 31 00
_dcomnd     .byte $00
_dstats     .byte $00
_dbuflh     .word L0500
_dtimlo     .byte $07          ; ora CMCMD ; 05 07
_dunuse     .byte $00
_dbytlh     .word $0080
_daux1      .byte $01
_daux2      .byte $00          ; ora (L0000,X) ; 01 00

lsio        jmp ($FFFF)            ; 6C FF FF
