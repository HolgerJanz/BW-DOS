* MEMX for BW-DOS

RAMTOP      equ $6a
RAMSIZ      equ $2e4
MEMTOP      equ $2e5
MEMLO       equ $2e7

REVDAT      equ $ffee
XLXEOP      equ $fff1
PATNUM      equ $fff2
REVNUM      equ $fff7
CHKSUM      equ $fff8

* Start of code
            blk dos $2800
* print RAM data
start       lda RAMTOP
            jsr convh2a
            sta _ramtop+0
            stx _ramtop+1

            lda <RAMSIZ
            sta $80
            lda >RAMSIZ
            sta $81
            lda <_ramsiz
            sta $83
            lda >_ramsiz
            sta $84
            lda #$00
            sta $82
            sta $85
            ldx #$01
            jsr movh2a

            lda <_memtop-_ramsiz+2
            sta $85
            ldx #$01
            jsr movh2a

            lda <_memtop-_ramsiz
            sta $85
            ldx #$01
            jsr movh2a

            lda <_memlow-_ramsiz+2
            sta $85
            ldx #$01
            jsr movh2a

            lda <_memlow-_ramsiz
            sta $85
            ldx #$01
            jsr movh2a

* print ROM data
            lda <REVDAT
            sta $80
            lda >REVDAT
            sta $81
            lda #$00
            sta $82

            lda <_revdat-_ramsiz
            sta $85
            ldx #$03
            jsr movh2a

            lda <_xlxeop-_ramsiz
            sta $85
            ldx #$01
            jsr movh2a

            lda <_patnum-_ramsiz
            sta $85
            ldx #$05
            jsr movh2a

            lda <_revnum-_ramsiz
            sta $85
            ldx #$01
            jsr movh2a

            lda <_chksum-_ramsiz+2
            sta $85
            ldx #$01
            jsr movh2a

            lda <_chksum-_ramsiz
            sta $85
            ldx #$01
            jsr movh2a

            jsr _print
            dta b($9b),c'RAM Info:',b($9b)
            dta c'  RAMSIZ='
_ramsiz     dta c'xx00 RAMTOP='
_ramtop     dta c'xx00',b($9b)
            dta c'  MEMLO ='
_memlow     dta c'xxxx MEMTOP='
_memtop     dta c'xxxx'
            dta b($9b,$00)
            jsr check_ext
            jsr _print
            dta b($9b),c'ROM Info:',b($9b)
            dta c'  REV='
_revnum     dta c'xx DAT='
_revdat     dta c'xxxxxx XLO='
_xlxeop     dta c'xx',b($9b)
            dta c'  PN='
_patnum     dta c'xxxxxxxxxx CHK='
_chksum     dta c'xxxx'
            dta b($9b,$00)

            rts


* move hex to atascii
*  read hex ($80) offset $82
*  write atascii ($83) offset $85
*  X: how many hex to convert
*  offsets $82 and $85 are incremented
movh2a      txa
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
            bne movh2a
            rts

* convert hex to atascii
*   hex A -> atascii A,X
convh2a     sed
            pha
            and #$0f
            clc
            adc #$90
            adc #$40
            tax
            pla
            lsr @
            lsr @
            lsr @
            lsr @
            clc
            adc #$90
            adc #$40
            cld            
            rts

* _print subroutine
            icl '_PRINT.ASM'

* extended memory check

RTCLOK      equ $12
CRITIC      equ $42
PORTB       equ $D301
NMIEN       equ $D40E

            blk dos $3000
* memory addresses to check for alias of main memory
* see RAMBO 256k
RB256TEST   dta b($00) 
* bit mask kind Rambo1 ($00), Rambo2 ($01), or Compy ($FF)
USEDMASK    dta b($FF)
* calculated max bank count
BNKCNT      dta b($00)

* use zero page for performance
* buffer for bank switch masks $06
BNKSWTBUF   equ $E0
* buffer for bytes used for testing $06
BNKSAVBUF   equ $F0

* determine extended memory

check_ext   ldx #$05
compyLoop   lda BNKSWTMSK,X
            sta BNKSWTBUF,x
            dex
            bpl compyLoop

            jsr CHKBNKS
            stx BNKCNT

            ldx #$05
rambo1Loop  lda BNKSWTMSKR1,X
            sta BNKSWTBUF,x
            dex
            bpl rambo1Loop

            jsr CHKBNKS
            cpx BNKCNT
            bmi check_r2
            beq check_r2
            lda #$00
            sta USEDMASK  ; used mask $00 Rambo1
            stx BNKCNT    ; save higher cnt

check_r2    ldx #$05
rambo2Loop  lda BNKSWTMSKR2,X
            sta BNKSWTBUF,x
            dex
            bpl rambo2Loop

            jsr CHKBNKS
            cpx BNKCNT
            bmi check_r1
            beq check_r1
            lda #$01
            sta USEDMASK  ; used mask $01 Rambo2
            stx BNKCNT    ; save higher cnt

            jmp start_rambo

check_r1    bit USEDMASK
            bmi start_compy

* write kind of extended memory

start_rambo jsr _print
            dta c'  ExtRambo=',b($00)
            jmp start_check

start_compy cpx #$04
            bcc start_check
            jsr _print
            dta c'  ExtCompy=',b($00)

start_check ldx BNKCNT
            cpx #$04
            bcc EXT_NO
            bne EXT_192
            jsr _print
            dta c'64k PORTB-Bits=23',b($9B,$00)
            jmp EXT_END

EXT_NO      jsr _print
            dta c'  No Extended Memory',b($9B,$00)
            jmp EXT_END

EXT_192     cpx #$0C
            beq EXT_256
            bcs EXT_320
            jsr _print
            dta c'128K PORTB-Bits=236',b($9B,$00)
            jmp EXT_END

EXT_256     jsr _print
            dta c'192K PORTB-Bits=2356',b($9B,$00)
            jmp EXT_END

EXT_320     cpx #$10
            bne EXT_576
            bit USEDMASK
            bmi CMP_320
            jsr _print
            dta c'256K PORTB-Bits=2356',b($9B,$00)
            jmp EXT_END
CMP_320     jsr _print
            dta c'256K PORTB-Bits=2367',b($9B,$00)
            jmp EXT_END

EXT_576     cpx #$20
            bne EXT_1088     
            bit USEDMASK
            bmi CMP_576
            bne RA2_576
            jsr _print
            dta c'512K PORTB-Bits=12356',b($9B,$00)
            jmp EXT_END
RA2_576     jsr _print
            dta c'512K PORTB-Bits=23567',b($9B,$00)
            jmp EXT_END
CMP_576     jsr _print
            dta c'512K PORTB-Bits=12367',b($9B,$00)
            jmp EXT_END

EXT_1088    cpx #$40
            beq EXT_1088EQ
            jmp EXT_NO
EXT_1088EQ  bit USEDMASK
            bmi CMP_1088
            bne RA2_1088
            jsr _print
            dta c'1024K PORTB-Bits=123567',b($9B,$00)
            jmp EXT_END
RA2_1088    jsr _print
            dta c'1024K PORTB-Bits=123567',b($9B,$00)
            jmp EXT_END
CMP_1088    jsr _print
            dta c'1024K PORTB-Bits=012367',b($9B,$00)
EXT_END     rts

* Subroutine check banks

CHKBNKS     lda PORTB
            pha
* wait for vertical blank interrupt
            inc CRITIC
            lda RTCLOK+2
WAITLOOP    cmp RTCLOK+2
            beq WAITLOOP
* switch off interrupts
            lda #$00         ; 2 cycle
            sta NMIEN        ; 4 cycle
            sei              ; 2 cycle
*                             =8 cycle

* try to save and write banks            
            ldy #$05        ; 2 cycle
BNKSAVWRT   ldx BNKSWTBUF,Y ; 4 cycle
            stx PORTB       ; 4 cycle
            lda $7000       ; 4 cycle
            sta BNKSAVBUF,Y ; 4 cycle
            stx $7000       ; 4 cycle
            dey             ; 2 cycle
            bpl BNKSAVWRT   ; 3 cycle
*                            =25*6+2=152 cycle

* check banks
BNKCHK      iny             ; 2 cycle
            lda BNKSWTBUF,Y ; 4 cycle
            sta PORTB       ; 4 cycle
            cmp $7000       ; 4 cycle
            bne BNKSTOP     ; 2 cycle
            cpy #$05        ; 3 cycle
            bne BNKCHK      ; 3 cycle
            iny             ; 2 cycle
BNKSTOP     tya             ; 2 cycle
* save bank bit count in X
            tax             ; 2 cycle
*                            =22*6+6=138 cycle

* restore banks
            ldy #$00        ; 2 cycle
BNKRESTR    lda BNKSWTBUF,Y ; 4 cycle
            sta PORTB       ; 4 cycle
            lda BNKSAVBUF,Y ; 4 cycle
            sta $7000       ; 4 cycle
            iny             ; 2 cycle
            cpy #$06        ; 3 cycle
            bne BNKRESTR    ; 3 cycle
*                            =24*6+2=146 cycle

* check memory aliases (RAMBO 256k)
            lda #$00        ; 2 cycle
            sta RB256TEST   ; 4 cycle
            lda BNK0R256    ; 4 cycle
            sta PORTB       ; 4 cycle
            lda #$04        ; 2 cycle
            sta $7000       ; 4 cycle
*                            =20 cycle

* restore PIA PORT B
            pla            ; 2 cycle
            sta PORTB      ; 4 cycle
* enable interrupts
            lda #$E0       ; 2 cycle
            sta NMIEN      ; 4 cycle
            dec CRITIC     ; 6 cycle
            cli            ; 2 cycle
*                           =20 cycle

* ca. 500 cycle in VB (max NTCS ca. 1000, PAL ca. 3000)
* everything ok

* calc bank numbers by bits
            cpx #$00
            beq BNKCHKEND
            lda #$01
SHIFTLOOP   asl @
            dex
            bne SHIFTLOOP
* substract main banks for Rambo 256k
            sec
            sbc RB256TEST
            tax

BNKCHKEND   rts

* Compy
* 1110:1011 1110:0011 1010:0011 0010:0011 0010:0001 0010:0000
BNKSWTMSK   dta b($EB,$E3,$A3,$23,$21,$20)

* Rambo1
* 1110:1011 1110:0011 1100:0011 1000:0011 1000:0001 0000:0001
BNKSWTMSKR1 dta b($EB,$E3,$C3,$83,$81,$01)

* Rambo2
* 1110:1011 1110:0011 1100:0011 1000:0011 0000:0001 1000:0001
BNKSWTMSKR2 dta b($EB,$E3,$C3,$83,$01,$81)

* Rambo 256k bank 0 = first 16k of main memory
* 1000:0011
BNK0R256    dta b($83)

            end

