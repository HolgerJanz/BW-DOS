* MEM for BW-DOS

            icl '_SYSEQU.ICL'

* Start of code
            blk dos $3000
* memory $3000 to check for alias of main memory
* see RAMBO 256k
RB256TEST   equ *-1
            jsr _chkbwdos14
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
            lsr @
            lsr @
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
            inc BW_DECIN
            bne *+5
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
* RAM variables
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

* ROM data
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

            lda <_chksum2-_ramsiz+2
            sta $85
            ldx #$01
            jsr movh2a

            lda <_chksum2-_ramsiz
            sta $85
            ldx #$01
            jsr movh2a

            lda <CHKSUM1
            sta $80
            lda >CHKSUM1
            sta $81
            lda #$00
            sta $82

            lda <_chksum1-_ramsiz+2
            sta $85
            ldx #$01
            jsr movh2a

            lda <_chksum1-_ramsiz
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
            dta c'ROM Info:',b($9b)
            dta c'  REV='
_revnum     dta c'xx DAT='
_revdat     dta c'xxxxxx XLO='
_xlxeop     dta c'xx',b($9b)
            dta c'  PN='
_patnum     dta c'xxxxxxxxxx CHK1='
_chksum1    dta c'xxxx CHK2='
_chksum2    dta c'xxxx'
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
            icl '_PRINT.ICL'
            icl '_CHKBW14.ICL'

* extended memory check
* calculated max bank count and size in kB
BNKCNT      dta b($00)
BKBCNT      dta b($00,$00)

check_ext   jsr SWPORTB
            jsr CHKPORTB
            lda BNKCNT
            beq check_axlon
            jsr _print
            dta c'  PORTB',b($00)
            jsr prnt_nmbrs
            jsr BW_CRNAME
            beq check_axlon
            jsr wrt_portb

check_axlon jsr CHKAXLON
            lda BNKCNT
            beq check_end
            jsr _print
            dta c'  AXLON',b($00)
            jsr prnt_nmbrs
check_end   rts

prnt_nmbrs  lda #$00
            ldx BNKCNT
            stx BKBCNT
            sta BKBCNT+1
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
prnt_size   lda BKBCNT
            asl @
            sta BKBCNT
            lda BKBCNT+1
            rol @
            sta BKBCNT+1
            dex
            bne prnt_size

            lda BKBCNT
            sta BW_DECIN
            lda BKBCNT+1
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
            dta c': '
_extsize    dta c'xxxx kB Banks:'
_extbanks   dta c'yyy'
            dta b($00)
            lda RB256FLAG
            beq prnt_end
            jsr _print
            dta c'+Main'
            dta b($00)
prnt_end    lda #$9b
            jsr _putc
            rts

wrt_portb   jsr _print
            dta c'  PORTB values saved in ',b($00)
            ldx #$00
            lda #9
            sta $342
            lda <BW_COMFNAM
            sta $344
            lda >BW_COMFNAM
            sta $345
            lda #$FF
            sta $348
            jsr CIOV
            jsr close1
* open file
            lda <BW_COMFNAM
            sta $344+$10
            lda >BW_COMFNAM
            sta $345+$10
            lda #8
            sta $34A+$10
            lda #0
            sta $34B+$10
            lda #3
            jsr cio1
            bpl wrt_file
            tya
            pha
            jsr close1
            pla
            jmp (BW_FAIL)
* write data
wrt_file    lda <RBTAB
            sta $344+$10
            lda >RBTAB
            sta $345+$10
            lda BNKCNT
            sta $348+$10
            lda #0
            sta $349+$10
            lda #11
            jsr cio1
            bpl cls_file
            tya
            pha
            jsr close1
            pla
            jmp (BW_FAIL)
cls_file    jmp close1

close1      lda #12
cio1        ldx #$10
            sta $342,X
            jmp CIOV

TEMP1       dta b(0)
SPORTB      dta b(0)
BUFF        equ $500
SWTAB       equ $BF ;$480
ZBUFF       equ $7E

* create PORTB table
SWPORTB     ldx #63
            lda #1
            clc
ST5B        sta SWTAB+1,X
            dex
            bmi ST5C
            adc #4
            sta TEMP1
            and #$10
            adc TEMP1
            bcc ST5B
            adc #1
            bne ST5B
ST5C        stx SWTAB
            rts

* check PORTB banks
* bank count in register A
CHKPORTB    lda #$00
            sta RB256TEST
            sta RB256FLAG ; would collide with $6FFF
* clear banking tab
            ldx #63
            lda #$FF ; OFF
RT0A        sta RBTAB,X
            dex
            bpl RT0A
* store PORTB
            lda PORTB
            sta SPORTB
            jsr IRQ_OFF
* save
            ldx #64
RT0         lda SWTAB,X
            sta PORTB
            lda $6FFF
            sta ZBUFF,X
            dex
            bpl RT0
* wait VB
            jsr WAITVB
* set
            ldx #64
RT1         lda SWTAB,X
            sta PORTB
            stx $6FFF
            dex
            bpl RT1
* wait VB
            jsr WAITVB
* check extended
            ldy #0
            ldx #64
RT2         lda SWTAB,X
            sta PORTB
            cpx $6FFF
            bne RT3
            lda SWTAB,X
            sta RBTAB,Y
            iny
RT3         dex
            bne RT2
* check main banking => sub 4 banks
            lda RB256TEST
            beq RT31
            sta RB256FLAG
            tya
            beq RT31
            sec
            sbc #$03
            pha
* skip 3 highest banks,
* one is already skipped
            tax
            ldy #$00
RT32        lda RBTAB+3,Y
            sta RBTAB,Y
            iny
            dex
            bne RT32
            pla
            tay
* save bank count
RT31        sty BNKCNT
* wait VB
            jsr WAITVB
* restore
            ldx #64
RT4         lda SWTAB,X
            sta PORTB
            lda ZBUFF,X
            sta $6FFF
            dex
            bpl RT4
* restore PIA PORT B
            lda SPORTB
            sta PORTB
            jsr IRQ_ON
            rts

RB256FLAG   dta b(0)

* check AXLON extended memory
* bank count in register A
CHKAXLON    lda #$00
            sta RB256TEST
            sta RB256FLAG ; reset for common output
            jsr IRQ_OFF
* save
            ldx #$FF
ART0        stx AXLON
            lda $6FFF
            sta BUFF,X
            dex
            cpx #$FF
            bne ART0
* set
            ldx #$FF
ART1        stx AXLON
            stx $6FFF
            dex
            cpx #$FF
            bne ART1
* check extended
            ldy #0
            ldx #$FF
ART2        stx AXLON
            cpx $6FFF
            bne ART3
            iny
ART3        dex
            bne ART2
* save bank count
            sty BNKCNT
* restore
            ldx #$FF
ART4        stx AXLON
            lda BUFF,X
            sta $6FFF
            dex
            cpx #$FF
            bne ART4
* restore axlon register to main
            lda #$00
            sta AXLON
            jsr IRQ_ON
            rts

IRQ_ON      lda #$40
            sta NMIEN
            cli
            dec CRITIC
            rts

IRQ_OFF     inc CRITIC
* wait for vertical blank interrupt
            lda RTCLOK+2
WAITLP      cmp RTCLOK+2
            beq WAITLP
* switch off interrupts
            lda #$00
            sta NMIEN
            sei
            rts

WAITVB      lda SPORTB
            sta PORTB
            lda VCOUNT
            cmp #$82
            bcc *-5
            rts

RBTAB       equ *

            end
