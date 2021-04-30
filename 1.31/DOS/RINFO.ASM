;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; RAM/ROM Info for SpartaDOS 3 by hjx

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Equates
;
RAMTOP      = $6a
RAMSIZ      = $2e4
MEMTOP      = $2e5
MEMLO       = $2e7

REVDAT      = $ffee
XLXEOP      = $fff1
PATNUM      = $fff2
REVNUM      = $fff7
CHKSUM      = $fff8
; 
; CIO
; 
CIOV        = $E456
; CIOCB addresses
ICHID       = $0340
ICDNO       = $0341
ICCOM       = $0342
ICSTA       = $0343
ICBAL       = $0344
ICBAH       = $0345
ICPTL       = $0346
ICPTH       = $0347
ICBLL       = $0348
ICBLH       = $0349
ICAX1       = $034a
ICAX2       = $034b

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Start of code
;
            org $0500
start

; print RAM data
            lda RAMTOP
            jsr convh2a
            sta _ramtop+0
            stx _ramtop+1

            lda #<RAMSIZ
            sta $80
            lda #>RAMSIZ
            sta $81
            lda #<_ramsiz
            sta $83
            lda #>_ramsiz
            sta $84
            lda #$00
            sta $82
            sta $85
            ldx #$01
            jsr movh2a

            lda #_memtop-_ramsiz+2
            sta $85
            ldx #$01
            jsr movh2a

            lda #_memtop-_ramsiz
            sta $85
            ldx #$01
            jsr movh2a

            lda #_memlow-_ramsiz+2
            sta $85
            ldx #$01
            jsr movh2a

            lda #_memlow-_ramsiz
            sta $85
            ldx #$01
            jsr movh2a

; print ROM data
            lda #<REVDAT
            sta $80
            lda #>REVDAT
            sta $81
            lda #$00
            sta $82

            lda #_revdat-_ramsiz
            sta $85
            ldx #$03
            jsr movh2a

            lda #_xlxeop-_ramsiz
            sta $85
            ldx #$01
            jsr movh2a

            lda #_patnum-_ramsiz
            sta $85
            ldx #$05
            jsr movh2a

            lda #_revnum-_ramsiz
            sta $85
            ldx #$01
            jsr movh2a

            lda #_chksum-_ramsiz+2
            sta $85
            ldx #$01
            jsr movh2a

            lda #_chksum-_ramsiz
            sta $85
            ldx #$01
            jsr movh2a

            jsr print
            .byte $9b,'RAM Info:',$9b
            .byte '  RAMSIZ='
_ramsiz     .byte 'xx00 RAMTOP='
_ramtop     .byte 'xx00',$9b
            .byte '  MEMLO ='
_memlow     .byte 'xxxx MEMTOP='
_memtop     .byte 'xxxx'
            .byte $9b
            .byte 'ROM Info:',$9b
            .byte '  REV='
_revnum     .byte 'xx DAT='
_revdat     .byte 'xxxxxx XLO='
_xlxeop     .byte 'xx',$9b
            .byte '  PN='
_patnum     .byte 'xxxxxxxxxx CHK='
_chksum     .byte 'xxxx'
            .byte $9b,$ff
            
            rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; move hex to atascii
;   hex $80 length $82, atascii $83
;
movh2a      
movh2aLoop  txa
            pha
            ldy $82
            lda ($80),y
            inc $82
            jsr convh2a
            ldy $85
            sta ($83),y
            iny
            sty $85
            txa
            sta ($83),y
            inc $85
            pla
            tax
            dex
            bne movh2aLoop
            rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; convert hex to atascii
;   hex A -> atascii A,X
;
convh2a     sed
            pha
            and #$0f
            clc
            adc #$90
            adc #$40
            tax
            pla
            lsr
            lsr
            lsr
            lsr
            clc
            adc #$90
            adc #$40
            cld            
            rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; print subroutine            
;
print       pla
            sta print_iter+1
            pla
            sta print_iter+2
print_loop  inc print_iter+1
            bne print_iter
            inc print_iter+2
print_iter  lda $ffff
            cmp #$ff
            beq print_end
            
            ldx #$00            ; put char
            stx ICBLL
            stx ICBLH
            ldy #$0B
            sty ICCOM
            jsr CIOV
            
            jmp print_loop
print_end   lda print_iter+2
            pha
            lda print_iter+1
            pha
            rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; run address            
;
;            run start