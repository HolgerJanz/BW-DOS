; CHKDSK for SpartaDOS 16k

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
ICAX3       equ $000C
ICAX4       equ $000D
ICAX5       equ $000E
ICAX6       equ $000F
ADLI        equ $0080
AVB         equ $0040
ALMS        equ $0040
AVSCR       equ $0020
AHSCR       equ $0010
AJMP        equ $0001
AEMPTY1     equ $0000
AEMPTY2     equ $0010
AEMPTY3     equ $0020
AEMPTY4     equ $0030
AEMPTY5     equ $0040
AEMPTY6     equ $0050
AEMPTY7     equ $0060
AEMPTY8     equ $0070
DOSVEC      equ $000A
IOCB0       equ $0340
CIOV        equ $E456
WARMSV      equ $E474
;
; Code equates
;
L0080       equ $0080
L0082       equ $0082
L0083       equ $0083
L0084       equ $0084
L0700       equ $0700
L0703       equ $0703
L0704       equ $0704
L070A       equ $070A


;CHKBUF      equ $6400      ; CHKDSK buffer
CHKBUF_V    equ CHKBUF     ; fs version
CHKBUF_SS   equ CHKBUF+1   ; sector size
CHKBUF_SC   equ CHKBUF+2   ; sector count
CHKBUF_SF   equ CHKBUF+4   ; dector free
CHKBUF_NAM  equ CHKBUF+6   ; volume name
CHKBUF_SN   equ CHKBUF+14  ; sequence number
CHKBUF_RN   equ CHKBUF+15  ; random number

;
; Start of code
;
            org $500
;
start       lda L0700              ; AD 00 07
            cmp #'S'               ; C9 53
            bne L608C              ; D0 0E
            lda L0703              ; AD 03 07
            cmp #'B'               ; C9 42
            bne L608C              ; D0 07
            lda L0704              ; AD 04 07
            cmp #'W'               ; C9 57
            beq L60A9              ; F0 1D
L608C       jsr print              ; 20 03 60
            .byte $9B,$FD
            .byte 'Error: Not BW-DOS !'
            .byte $9B,$00
            jmp (DOSVEC)           ; 6C 0A 00

L60A9       lda DOSVEC             ; A5 0A
            clc                    ; 18
            adc #$03               ; 69 03
            sta _CRNAME+1            ; 8D 3B 60
            lda DOSVEC+1           ; A5 0B
            adc #$00               ; 69 00
            sta _CRNAME+2            ; 8D 3C 60
            lda DOSVEC             ; A5 0A
            sec                    ; 38
            sbc #$13               ; E9 13
            sta L0080              ; 85 80
            lda DOSVEC+1           ; A5 0B
            sbc #$00               ; E9 00
            sta L0080+1            ; 85 81
            jsr _CRNAME              ; 20 3A 60
            jsr L606D              ; 20 6D 60
            ldx #$10               ; A2 10
            lda #$2F ; chkdsk       ; A9 2F
            sta IOCB0+ICCOM,X      ; 9D 42 03
            lda DOSVEC             ; A5 0A
            clc                    ; 18
            adc #$21               ; 69 21
            sta IOCB0+ICBAL,X      ; 9D 44 03
            lda DOSVEC+1           ; A5 0B
            adc #$00               ; 69 00
            sta IOCB0+ICBAH,X      ; 9D 45 03
            lda #<CHKBUF           ; A9 00
            sta IOCB0+ICBLL,X      ; 9D 48 03
            lda #>CHKBUF               ; A9 64
            sta IOCB0+ICBLH,X      ; 9D 49 03
            jsr CIOV               ; 20 56 E4
            bpl L60F3              ; 10 03
            jmp L603D              ; 4C 3D 60
L60F3       jsr print              ; 20 03 60
            .byte $9B
            .byte '      Volume: '
            .byte $00
            ldy #<CHKBUF_NAM       ; A0 06
            ldx #>CHKBUF_NAM       ; A2 64
            lda #$08               ; A9 08
            jsr prnChars           ; 20 B8 61
            lda CHKBUF_SN          ; AD 0E 64
            jsr prnDecA            ; 20 93 61
            lda CHKBUF_RN              ; AD 0F 64
            jsr prnDecA            ; 20 93 61
            jsr print              ; 20 03 60
            .byte $9B
            .byte 'Bytes/sector:'
            .byte $00
            ldx #$00               ; A2 00
            lda CHKBUF_SS              ; AD 01 64
            bne L6135              ; D0 01
            inx                    ; E8
L6135       jsr prnDecAX              ; 20 95 61
            jsr print              ; 20 03 60
            .byte $9B
            .byte ' Total bytes: '
            .byte $00
            ldy #$02               ; A0 02
            jsr prnDecChk              ; 20 70 61
            jsr print              ; 20 03 60
            .byte $9B
            .byte '  Bytes free: '
            .byte $00
            ldy #$04               ; A0 04
            jsr prnDecChk              ; 20 70 61
            lda #$9B               ; A9 9B
            jsr put_char              ; 20 27 60
            jmp L6064              ; 4C 64 60

prnDecChk   lda #$08               ; A9 08
            pha                    ; 48
            lda #$00               ; A9 00
            pha                    ; 48
            lda CHKBUF,Y            ; B9 00 64
            tax                    ; AA
            lda CHKBUF+1,Y            ; B9 01 64
            ldy #$00               ; A0 00
            bit CHKBUF_SS              ; 2C 01 64
            bpl L619C              ; 10 18
            lsr                    ; 4A
            pha                    ; 48
            txa                    ; 8A
            ror                    ; 6A
            tax                    ; AA
            tya                    ; 98
            ror                    ; 6A
            tay                    ; A8
            pla                    ; 68
            jmp L619C              ; 4C 9C 61

CONVDC_V    jmp (L070A)            ; 6C 0A 07

prnDecA     ldx #$00               ; A2 00
prnDecAX    tay                    ; A8
            lda #$04               ; A9 04
            pha                    ; 48
            pha                    ; 48
            lda #$00               ; A9 00
L619C       pha                    ; 48
            tya                    ; 98
            ldy #$0D               ; A0 0D
            sta (L0080),Y          ; 91 80
            iny                    ; C8
            txa                    ; 8A
            sta (L0080),Y          ; 91 80
            iny                    ; C8
            pla                    ; 68
            sta (L0080),Y          ; 91 80
            jsr CONVDC_V              ; 20 90 61
            pla                    ; 68
            clc                    ; 18
            adc L0080              ; 65 80
            tay                    ; A8
            lda #$00               ; A9 00
            adc L0080+1            ; 65 81
            tax                    ; AA
            pla                    ; 68
prnChars    sty L0082              ; 84 82
            stx L0083              ; 86 83
            sta L0084              ; 85 84
L61BE       ldy #$00               ; A0 00
            lda (L0082),Y          ; B1 82
            jsr put_char              ; 20 27 60
            inc L0082              ; E6 82
            bne L61CB              ; D0 02
            inc L0083              ; E6 83
L61CB       dec L0084              ; C6 84
            bne L61BE              ; D0 EF
            rts                    ; 60

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

put_char    tay                    ; A8
            lda #$00               ; A9 00
            tax                    ; AA
            sta IOCB0+ICBLL,X      ; 9D 48 03
            sta IOCB0+ICBLH,X      ; 9D 49 03
            lda #$0B ; put chars   ; A9 0B
            sta IOCB0+ICCOM,X      ; 9D 42 03
            tya                    ; 98
            jmp CIOV               ; 4C 56 E4

_CRNAME     jmp L6026              ; 4C 26 60

L603D       tya                    ; 98
            pha                    ; 48
            jsr print              ; 20 03 60
            .byte $9B
            .byte 'Error'
            .byte $00
            pla                    ; 68
            jsr prnDecA            ; 20 93 61
            lda #$9B               ; A9 9B
            jsr put_char           ; 20 27 60
            ldy #$08               ; A0 08
            lda (DOSVEC),Y         ; B1 0A
            sta L6061+1            ; 8D 62 60
            iny                    ; C8
            lda (DOSVEC),Y         ; B1 0A
            sta L6061+2            ; 8D 63 60
            ldy #$01               ; A0 01
L6061       jsr WARMSV             ; 20 74 E4
L6064       jsr L606D              ; 20 6D 60
            jmp (DOSVEC)           ; 6C 0A 00

            .byte 1,10,100

L606D       ldx #$10               ; A2 10
            lda #$0C ; close       ; A9 0C
            sta IOCB0+ICCOM,X      ; 9D 42 03
            jmp CIOV               ; 4C 56 E4
CHKBUF      equ *