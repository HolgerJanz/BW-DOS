* MEM for BW-DOS

            icl '_SYSEQU.ASM'

* Start of code
            blk dos $3400
start       jsr _chkbwdos14
* print RAM data
            jsr IRQ_OFF
            lda PORTB
            pha
* switch to RAM under OS
            and #$FE
            sta PORTB
* check RAM $E000 (64kB)
            ldy $E000
            ldx #$55
            stx $E000
            cpx $E000
            sty $E000
            bne calc_main
            ldy $E000
            ldx #$CC
            stx $E000
            cpx $E000
            sty $E000
            bne calc_main
            lda #$0E ; 14k under OS
            sta _add_OSRAM+1
* restore PIA PORT B
calc_main   pla
            sta PORTB
            jsr IRQ_ON
* calc main
            lda RAMSIZ
            lsr
            lsr
            clc
_add_OSRAM  adc #$00
            sta BW_DECIN
            lda #$00
            sta BW_DECIN+1
            sta BW_DECIN+2
            jsr CONVDC
            lda BW_DECOUT+6
            sta _main
            lda BW_DECOUT+7
            sta _main+1
* calc free main mem
            sec
            lda MEMTOP
            sbc MEMLO
            sta BW_DECIN
            lda MEMTOP+1
            sbc MEMLO+1
            sta BW_DECIN+1
* add 1 because MEMLO and MEMTOP are included
            clc
            inc BW_DECIN
            bcc *+5
            inc BW_DECIN+1
            lda #$00
            sta BW_DECIN+2
            jsr CONVDC
            lda BW_DECOUT+3
            sta _free
            lda BW_DECOUT+4
            sta _free+1
            lda BW_DECOUT+5
            sta _free+2
            lda BW_DECOUT+6
            sta _free+3
            lda BW_DECOUT+7
            sta _free+4
* RAM varaibles
            lda RAMTOP
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
            dta c'  Main: '
_main       dta c'xx kB Free: '
_free       dta c'xxxxx bytes',b($9b)
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

CONVDC      jmp (BW_CONVDC)


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
            icl '_CHKBWD14.ASM'

* extended memory check

            blk dos $3000
* memory addresses to check for alias of main memory
* see RAMBO 256k
RB256TEST   dta b($00) 
* bit mask kind Rambo1 ($01), Rambo2 ($02), Compy ($03),  or Axlon($04) 
USEDMASK    dta b($00)
* calculated max bank count and size in kB
BNKCNT      dta b($00,$00)

* use zero page for performance
* buffer for bank switch masks $06
BNKSWTBUF   equ $E0
* buffer for bytes used for testing $06
BNKSAVBUF   equ $F0
* buffer for bytes used for Rambo 256
BNK0R256BUF equ $FF

* determine extended memory
check_ext   lda #$00
            sta BNKCNT
            sta BNKCNT+1
            sta USEDMASK

            ldx #$06
compyLoop   lda BNKSWTMSK,X
            sta BNKSWTBUF,X
            dex
            bpl compyLoop
            jsr CHKBNKS
            cpx #$00
            beq check_axl
            stx BNKCNT
            lda #$03
            sta USEDMASK

chk_rambo   ldx #$06
rambo1Loop  lda BNKSWTMSKR1,X
            sta BNKSWTBUF,X
            dex
            bpl rambo1Loop
            jsr CHKBNKS
            cpx BNKCNT
            bmi check_r2
            beq check_r2
            stx BNKCNT    ; save higher cnt
            lda #$01
            sta USEDMASK  ; used mask Rambo1

check_r2    ldx #$06
rambo2Loop  lda BNKSWTMSKR2,X
            sta BNKSWTBUF,X
            dex
            bpl rambo2Loop
            jsr CHKBNKS
            cpx BNKCNT
            bmi prnt_ext
            beq prnt_ext
            stx BNKCNT    ; save higher cnt
            lda #$02
            sta USEDMASK  ; used mask Rambo2
            bne prnt_ext

check_axl   cpx #$00
            bne prnt_ext
            jsr CHKAXLON
            cpx #$00
            beq prnt_ext
            stx BNKCNT
            lda #$04
            sta USEDMASK

prnt_ext    lda USEDMASK

            cmp #$00
            bne prnt_um1
            jsr _print
            dta c'  Ext None',b($9b,$00)
            jmp prnt_end

prnt_um1    cmp #$01
            bne prnt_um2
prnt_rambo  jsr _print
            dta c'  Rambo',b($00)
            jmp prnt_nmbrs

prnt_um2    cmp #$02
            beq prnt_rambo

prnt_um3    cmp #$03
            bne prnt_um4
            jsr _print
            dta c'  Compy',b($00)
            jmp prnt_nmbrs

prnt_um4    cmp #$04
            bne prnt_nmbrs
            jsr _print
            dta c'  Axlon',b($00)
            jmp prnt_nmbrs


prnt_nmbrs  lda #$00
            ldx BNKCNT
            stx BW_DECIN
            sta BW_DECIN+1
            sta BW_DECIN+2
            jsr CONVDC
            lda BW_DECOUT+5
            sta _extbanks
            lda BW_DECOUT+6
            sta _extbanks+1
            lda BW_DECOUT+7
            sta _extbanks+2


            ldx #$04
prnt_size   lda BNKCNT
            asl @
            sta BNKCNT
            lda BNKCNT+1
            rol @
            sta BNKCNT+1
            dex
            bne prnt_size

            lda BNKCNT
            sta BW_DECIN
            lda BNKCNT+1
            sta BW_DECIN+1
            lda #$00
            sta BW_DECIN+2
            jsr CONVDC
            lda BW_DECOUT+4
            sta _extsize
            lda BW_DECOUT+5
            sta _extsize+1
            lda BW_DECOUT+6
            sta _extsize+2
            lda BW_DECOUT+7
            sta _extsize+3

            jsr _print
            dta ': '
_extsize    dta 'xxxx kB Banks:'
_extbanks   dta 'yyy'
            dta b($9B,$00)

prnt_end    rts

* check AXLON extended memory
* bank count in register A
CHKAXLON    jsr IRQ_OFF
*                             =8 cycle
* try to save and write banks            
            ldy #$08        ; 2 cycle
            lda #$FF        ; 2 cycle
AXLSAVWRT   sta AXLON       ; 4 cycle
            ldx $7000       ; 4 cycle
            stx BNKSAVBUF,Y ; 4 cycle
            sta $7000       ; 4 cycle
            lsr @           ; 1 cycle
            dey             ; 2 cycle
            bpl AXLSAVWRT   ; 3 cycle
*                            =22*8+4=180 cycle
* check banks
            ldx #$00        ; 2 cycle
AXLBNKCHK   iny             ; 2 cycle
            sta AXLON       ; 4 cycle
            cmp $7000       ; 4 cycle
            bne AXLBNKSTOP  ; 2 cycle
            tax             ; 1 cycle
            sec             ; 1 cycle
            rol @           ; 1 cycle
            cpy #$08        ; 3 cycle
            bne AXLBNKCHK   ; 3 cycle
AXLBNKSTOP  txa             ; 1 cycle
            pha             ; 1 cycle
*                            =21*8+4=176 cycle
* restore banks
            ldy #$00        ; 2 cycle
            tya             ; 1 cylee
AXLBNKRESTR sta AXLON       ; 4 cycle
            ldx BNKSAVBUF,Y ; 4 cycle
            stx $7000       ; 4 cycle
            sec             ; 1 cycle
            rol @           ; 1 cycle
            iny             ; 2 cycle
            cpy #$09        ; 3 cycle
            bne AXLBNKRESTR ; 3 cycle
*                            =22*8+3=179 cycle
            jsr IRQ_ON
* ca. 530 cycle in VB (max NTCS ca. 1000, PAL ca. 3000)
* everything ok
            pla
            tax
            rts

* check PORTB banks
* bank count in register A
CHKBNKS     lda PORTB
            pha
            jsr IRQ_OFF
*                             = 16 cycle
* try to save and write banks            
            ldy #$06        ; 2 cycle
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
            cpy #$06        ; 3 cycle
            bne BNKCHK      ; 3 cycle
            iny             ; 2 cycle
BNKSTOP     dey             ; 2 cycle
            tya             ; 2 cycle
* save bank bit count in X
            tax             ; 2 cycle
*                            =22*6+8=140 cycle
* restore banks
            ldy #$00        ; 2 cycle
BNKRESTR    lda BNKSWTBUF,Y ; 4 cycle
            sta PORTB       ; 4 cycle
            lda BNKSAVBUF,Y ; 4 cycle
            sta $7000       ; 4 cycle
            iny             ; 2 cycle
            cpy #$07        ; 3 cycle
            bne BNKRESTR    ; 3 cycle
*                            =24*6+2=146 cycle
* check memory aliases (RAMBO 256k)
            lda #$00        ; 2 cycle
            sta RB256TEST   ; 4 cycle
            lda BNK0R256    ; 4 cycle
            sta PORTB       ; 4 cycle
            lda $7000       ; 4 cycle
            sta BNK0R256BUF ; 2 cycle
            lda #$04        ; 2 cycle
            sta $7000       ; 4 cycle
*                            =26 cycle
* calc bank numbers by bits
            lda #$00        ; 2 cycle
            cpx #$00        ; 3 cycle
            beq BNKCHKEND   ; 3 cycle
            lda #$01        ; 2 cycle
SHIFTLOOP   asl @           ; 2 cycle
            dex             ; 2 cycle
            bne SHIFTLOOP   ; 3 cycle
* substract main banks for Rambo 256k
            sec             ; 1 cycle
            sbc RB256TEST   ; 4 cycle
            tax             ; 2 cycle
* restore Rambo 256k test byte
BNKCHKEND   lda BNK0R256    ; 4 cycle
            sta PORTB       ; 4 cycle
            lda BNK0R256BUF ; 4 cycle
            sta $7000       ; 2 cycle
*                             = 7*7+10+21=80
* restore PIA PORT B
            pla            ; 2 cycle
            sta PORTB      ; 4 cycle
            jsr IRQ_ON
*                           =24 cycle
* ca. 590 cycle in VB (max NTCS ca. 1000, PAL ca. 3000)
* everything ok
            rts

IRQ_ON      lda #$E0       ; 2 cycle
            sta NMIEN      ; 4 cycle
            dec CRITIC     ; 6 cycle
            cli            ; 2 cycle
            rts

IRQ_OFF     inc CRITIC
* wait for vertical blank interrupt
            lda RTCLOK+2
WAITLOOP    cmp RTCLOK+2
            beq WAITLOOP
* switch off interrupts
            lda #$00         ; 2 cycle
            sta NMIEN        ; 4 cycle
            sei              ; 2 cycle
            rts

* Compy
* 1110:1011 1110:0011 1010:0011 0010:0011 0010:0001 0010:0000
BNKSWTMSK   dta b($F3,$EB,$E3,$A3,$23,$21,$20)

* Rambo1
* 1110:1011 1110:0011 1100:0011 1000:0011 1000:0001 0000:0001
BNKSWTMSKR1 dta b($F3,$EB,$E3,$C3,$83,$81,$01)

* Rambo2
* 1110:1011 1110:0011 1100:0011 1000:0011 0000:0001 1000:0001
BNKSWTMSKR2 dta b($F3,$EB,$E3,$C3,$83,$01,$81)

* Rambo 256k bank 0 = first 16k of main memory
* 1000:0011
BNK0R256    dta b($83)

            end

