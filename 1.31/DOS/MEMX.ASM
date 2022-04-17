;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; RAM/ROM Info for SpartaDOS 3 by hjx

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Equates
;
RAMTOP      equ $6a
RAMSIZ      equ $2e4
MEMTOP      equ $2e5
MEMLO       equ $2e7

REVDAT      equ $ffee
XLXEOP      equ $fff1
PATNUM      equ $fff2
REVNUM      equ $fff7
CHKSUM      equ $fff8
; 
; CIO
; 
CIOV        equ $E456
; CIOCB addresses
ICHID       equ $0340
ICDNO       equ $0341
ICCOM       equ $0342
ICSTA       equ $0343
ICBAL       equ $0344
ICBAH       equ $0345
ICPTL       equ $0346
ICPTH       equ $0347
ICBLL       equ $0348
ICBLH       equ $0349
ICAX1       equ $034a
ICAX2       equ $034b

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Start of code
;
            org $2800
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
            .byte 'RAM Info:',$9b
            .byte '  RAMSIZ='
_ramsiz     .byte 'xx00 RAMTOP='
_ramtop     .byte 'xx00',$9b
            .byte '  MEMLO ='
_memlow     .byte 'xxxx MEMTOP='
_memtop     .byte 'xxxx'
            .byte $9b,$ff
            jsr check_ext
            jsr print
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
; extended memory check

RTCLOK      equ $12
CRITIC      equ $42
SDMCTL      equ $022F
PORTB       equ $D301
DMACTL      equ $D400
NMIEN       equ $D40E

ZBNKSWTMSK  equ $00D0

; memory addresses to check for alias of main memory
; see RAMBO 256k
            org $3000
RB256TEST   .byte $00 

; bit mask kind Rambo1 ($00), Rambo2 ($01), or Compy ($FF)
USEDMASK    .byte $FF

BNKCNT      .byte $00
SPARBNKS    .byte $00

; determine extended memory
;
check_ext   lda #<BNKSWTMSK             ; check Compy
            sta ZBNKSWTMSK
            lda #>BNKSWTMSK
            sta ZBNKSWTMSK+1
            jsr CHKBNKS
            stx BNKCNT

            lda #<BNKSWTMSKR1           ; check Rambo1
            sta ZBNKSWTMSK
            lda #>BNKSWTMSKR1
            sta ZBNKSWTMSK+1
            jsr CHKBNKS
            cpx BNKCNT
            bmi check_r2
            beq check_r2
            lda #$00
            sta USEDMASK                ; used mask $00 Rambo1
            stx BNKCNT                  ; save higher cnt

check_r2    lda #<BNKSWTMSKR2           ; check Rambo2
            sta ZBNKSWTMSK
            lda #>BNKSWTMSKR2
            sta ZBNKSWTMSK+1
            jsr CHKBNKS
            cpx BNKCNT
            bmi check_r1
            beq check_r1
            lda #$01
            sta USEDMASK                ; used mask $01 Rambo2
            stx BNKCNT                  ; save higher cnt

            ldx #$00                    ; copy Rambo2 to mask
CPYR2M      lda BNKSWTMSKR2,X
            sta BNKSWTMSK,X
            inx
            cpx #$40  
            bne CPYR2M
            jmp start_rambo

check_r1
            bit USEDMASK
            bmi start_compy
            ldx #$00             ; copy Rambo1 to mask
CPYR1M      lda BNKSWTMSKR1,X
            sta BNKSWTMSK,X
            inx
            cpx #$40  
            bne CPYR1M

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; write kind of extended memory
;            
start_rambo
            jsr PRINT
            .byte '  ExtRambo=',$FF
            jmp start_check

start_compy
            cpx #$04
            bcc start_check
            jsr PRINT
            .byte '  ExtCompy=',$FF

start_check
; check bank count
            ldx BNKCNT
            cpx #$04
            bcc EXT_NO
            bne EXT_192
            jsr PRINT
            .byte '64k PORTB-Bits=23',$9B,$FF
            jmp EXT_END
; no banks            
EXT_NO      jsr PRINT
            .byte '  No Extended Memory',$9B,$FF
            jmp EXT_END
            
EXT_192     cpx #$0C
            beq EXT_256
            bcs EXT_320
            jsr PRINT
            .byte '128K PORTB-Bits=236',$9B,$FF
            jmp EXT_END

EXT_256     jsr PRINT
            .byte '192K PORTB-Bits=2365',$9B,$FF
            jmp EXT_END
            
EXT_320     cpx #$10
            bne EXT_576
            bit USEDMASK
            bmi CMP_320
            jsr PRINT
            .byte '256K PORTB-Bits=2365',$9B,$FF
            jmp EXT_END
CMP_320     jsr PRINT
            .byte '256K PORTB-Bits=2367',$9B,$FF
            jmp EXT_END

EXT_576     cpx #$20
            bne EXT_1088     
            bit USEDMASK
            bmi CMP_576
            bne RA2_576
            jsr PRINT
            .byte '512K PORTB-Bits=23651',$9B,$FF
            jmp EXT_END
RA2_576     jsr PRINT
            .byte '512K PORTB-Bits=23657',$9B,$FF
            jmp EXT_END
CMP_576     jsr PRINT
            .byte '512K PORTB-Bits=23671',$9B,$FF
            jmp EXT_END

EXT_1088    cpx #$40
            beq EXT_1088EQ
            jmp EXT_NO
EXT_1088EQ  bit USEDMASK
            bmi CMP_1088
            bne RA2_1088
            jsr PRINT
            .byte '1024K PORTB-Bits=236517',$9B,$FF
            jmp EXT_END
RA2_1088    jsr PRINT
            .byte '1024K PORTB-Bits=236571',$9B,$FF
            jmp EXT_END
CMP_1088    jsr PRINT
            .byte '1024K PORTB-Bits=236710',$9B,$FF
EXT_END     rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Subroutine check banks
;
CHKBNKS
; save PIA PORT B
            lda PORTB
            pha
; set carry if BASIC is active
            and #$02
            lsr
            lsr
            php
; wait for vertical blank interrupt
            inc CRITIC
            jsr WAITSYNC
; switch off interrupts
            plp
            lda #$00
; if BASIC is active then do not switch off screen,
; if BASIC is not active then switch off screen to
; prevent bad screen if BASIC is switch in at test
            bcc *+5
            sta DMACTL
            sta NMIEN
            sei

; try to save and write banks            
            ldy #$3F
BNKSAVWRT   lda (ZBNKSWTMSK),Y
            tax
            stx PORTB
            lda $7000
            sta BNKSAVBUF,Y
;            lda (ZBNKSWTMSK),Y
            stx $7000
            dey
            bpl BNKSAVWRT

; write to check memory aliases (RAMBO 256k)
            lda #$FF
            sta RB256TEST
; check banks
BNKCHK      iny
            lda (ZBNKSWTMSK),Y
            sta PORTB
;            lda (ZBNKSWTMSK),Y
            cmp $7000
            bne BNKSTOP
            cpy #$3F
            bne BNKCHK
            iny
BNKSTOP     tya                 ; save bank count in X
            tax

; restore banks
            ldy #$00
BNKRESTR    lda (ZBNKSWTMSK),Y
            sta PORTB
            lda BNKSAVBUF,Y
            sta $7000
            iny
            cpy #$40
            bne BNKRESTR

; reset check memory aliases (RAMBO 256k)
            lda #$00
            sta RB256TEST
; restore PIA PORT B
            pla
            sta PORTB
; enable interrupts
            lda #$E0
            sta NMIEN
            dec CRITIC
            cli
            jsr WAITSYNC
            rts

; wait for sync            
WAITSYNC    lda RTCLOK+2
WAITLOOP    cmp RTCLOK+2
            beq WAITLOOP
            rts            

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Compy Shop
BNKSWTMSK
            .byte $E2,$E6,$EA,$EE ; 1110:0010 1110:0110 1110:1010 1110:1110
            .byte $A2,$A6,$AA,$AE ; 1010:0010 1010:0110 1010:1010 1010:1110
            .byte $62,$66,$6A,$6E ; 0110:0010 0110:0110 0110:1010 0110:1110 
            .byte $22,$26,$2A,$2E ; 0010:0010 0010:0110 0010:1010 0010:1110
            .byte $E0,$E4,$E8,$EC ; 1110:0000 1110:0100 1110:1000 1110:1100
            .byte $A0,$A4,$A8,$AC ; 1010:0000 1010:0100 1010:1000 1010:1100
            .byte $60,$64,$68,$6C ; 0110:0000 0110:0100 0110:1000 0110:1100
            .byte $20,$24,$28,$2C ; 0010:0000 0010:0100 0010:1000 0010:1100
; extension for 1088k
            .byte $E3,$E7,$EB,$EF ; 1110:0011 1110:0111 1110:1011 1110:1111
            .byte $A3,$A7,$AB,$AF ; 1010:0011 1010:0111 1010:1011 1010:1111
            .byte $63,$67,$6B,$6F ; 0110:0011 0110:0111 0110:1011 0110:1111 
            .byte $23,$27,$2B,$2F ; 0010:0011 0010:0111 0010:1011 0010:1111
            .byte $E1,$E5,$E9,$ED ; 1110:0001 1110:0101 1110:1001 1110:1101
            .byte $A1,$A5,$A9,$AD ; 1010:0001 1010:0101 1010:1001 1010:1101
            .byte $61,$65,$69,$6D ; 0110:0001 0110:0101 0110:1001 0110:1101
            .byte $21,$25,$29,$2D ; 0010:0001 0010:0101 0010:1001 0010:1101

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Bank masks Rambo 1 and 2
;
BNKSWTMSKR1
            .byte $E2,$E6,$EA,$EE ; 1110:0010 1110:0110 1110:1010 1110:1110
            .byte $A2,$A6,$AA,$AE ; 1010:0010 1010:0110 1010:1010 1010:1110
            .byte $C2,$C6,$CA,$CE ; 1100:0010 1100:0110 1100:1010 1100:1110
            .byte $82,$86,$8A,$8E ; 1000:0010 1000:0110 1000:1010 1000:1110
            .byte $E0,$E4,$E8,$EC ; 1110:0000 1110:0100 1110:1000 1110:1100
            .byte $A0,$A4,$A8,$AC ; 1010:0000 1010:0100 1010:1000 1010:1100
            .byte $C0,$C4,$C8,$CC ; 1100:0000 1100:0100 1100:1000 1100:1100
            .byte $80,$84,$88,$8C ; 1000:0000 1000:0100 1000:1000 1000:1100
; extension for 1088k
            .byte $62,$66,$6A,$6E ; 0110:0010 0110:0110 0110:1010 0110:1110
            .byte $22,$26,$2A,$2E ; 0010:0010 0010:0110 0010:1010 0010:1110
            .byte $42,$46,$4A,$4E ; 0100:0010 0100:0110 0100:1010 0100:1110
            .byte $02,$06,$0A,$0E ; 0000:0010 0000:0110 0000:1010 0000:1110
            .byte $60,$64,$68,$6C ; 0110:0000 0110:0100 0110:1000 0110:1100
            .byte $20,$24,$28,$2C ; 0010:0000 0010:0100 0010:1000 0010:1100
            .byte $40,$44,$48,$4C ; 0100:0000 0100:0100 0100:1000 0100:1100
            .byte $00,$04,$08,$0C ; 0000:0000 0000:0100 0000:1000 0000:1100

BNKSWTMSKR2
            .byte $E2,$E6,$EA,$EE ; 1110:0010 1110:0110 1110:1010 1110:1110
            .byte $A2,$A6,$AA,$AE ; 1010:0010 1010:0110 1010:1010 1010:1110
            .byte $C2,$C6,$CA,$CE ; 1100:0010 1100:0110 1100:1010 1100:1110
            .byte $82,$86,$8A,$8E ; 1000:0010 1000:0110 1000:1010 1000:1110
            .byte $62,$66,$6A,$6E ; 0110:0010 0110:0110 0110:1010 0110:1110
            .byte $22,$26,$2A,$2E ; 0010:0010 0010:0110 0010:1010 0010:1110
            .byte $42,$46,$4A,$4E ; 0100:0010 0100:0110 0100:1010 0100:1110
            .byte $02,$06,$0A,$0E ; 0000:0010 0000:0110 0000:1010 0000:1110
; extension for 1088k
            .byte $E0,$E4,$E8,$EC ; 1110:0000 1110:0100 1110:1000 1110:1100
            .byte $A0,$A4,$A8,$AC ; 1010:0000 1010:0100 1010:1000 1010:1100
            .byte $C0,$C4,$C8,$CC ; 1100:0000 1100:0100 1100:1000 1100:1100
            .byte $80,$84,$88,$8C ; 1000:0000 1000:0100 1000:1000 1000:1100
            .byte $60,$64,$68,$6C ; 0110:0000 0110:0100 0110:1000 0110:1100
            .byte $20,$24,$28,$2C ; 0010:0000 0010:0100 0010:1000 0010:1100
            .byte $40,$44,$48,$4C ; 0100:0000 0100:0100 0100:1000 0100:1100
            .byte $00,$04,$08,$0C ; 0000:0000 0000:0100 0000:1000 0000:1100

; $20 Bytes extension $40
BNKSAVBUF   equ *

