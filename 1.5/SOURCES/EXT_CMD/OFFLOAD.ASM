* BW-DOS command OFFLOAD file [offset] [/QL]

        icl '_SYSEQU.ICL'

* init block to check for BW-DOS 1.4 (at least)
        blk dos $400
iniadd  equ *
        icl '_TSTBW14.ICL'
        rts
        blk dos INITAD
        dta a(iniadd)

* start
        blk dos $400
        jsr BW_CRNAME
        bne start3a
* help
        jsr _print
        dta b(155)
        dta c'Syntax:'
        dta b(155)
        dta c'OFFLOAD fname [off] [/QL]'
        dta b(155,0)
        jmp BW_COMTAB

start3a lda BW_COMFNAM
        sta dnam
        lda BW_COMFNAM+1
        sta dnam+1

* open
        ldx #$10
        lda #3
        sta $342,x
        lda <BW_COMFNAM
        sta $344,x
        lda >BW_COMFNAM
        sta $345,x
        lda #4
        sta $34a,x
        lda #0
        sta $34b,x
        jsr $e456
        bpl strt5
        jmp error

* offset
strt5   lda #0
        sta offsl
        sta offsh
        sta ldit
        sta noque

        jsr gethex
        bne strt3b

        cmp #'/'
        beq strt3d
        bne strt3c

strt3b  sty offsl
        stx offsh

* /QL
strt3c  jsr BW_CRNAME

strt3d  ldy #3
        lda BW_COMFNAM,y
        cmp #'/'
        bne strt4

strt3e  iny
        lda BW_COMFNAM,y
        cmp #$9b
        beq strt4

        cmp #'Q'
        beq strt3f

        cmp #'L'
        bne strt3er
        sta noque

strt3f  sta ldit
        beq strt3e

strt3er jmp ghxerr

strt4   jsr get1
        sta strt5b+1
        jsr get1
strt5b  and #0
        cmp #$ff
        bne strt5er

        jmp load1

strt5er lda #$98 ; no binary file
        jmp (BW_FAIL)

ghxrts  ldy #0
        ldx #0

hexl    equ ghxrts+1
hexh    equ ghxrts+3

        lda #1

ghxrts2 rts

gethex  jsr BW_CRNAME

        lda #0
        sta hexl
        sta hexh

        ldy #36
        lda (10),y
        cmp #155
        beq ghxrts2
        cmp #'/'
        beq ghxrts2

gethx2  cpy #41
        bcs ghxerr

        lda (10),y
        iny

        cmp #$9b
        beq ghxrts

        sec
        sbc #$30
        cmp #$0a
        bcc gethx3

        sbc #7
        cmp #$0a
        bcc ghxerr
        cmp #$10
        bcs ghxerr

gethx3  pha

        ldx #4
gethx4  asl hexl
        rol hexh
        dex
        bne gethx4

        pla
        ora hexl
        sta hexl

        jmp gethx2

ghxerr  lda #$9c ; bad parameter
        jmp (BW_FAIL)

        icl '_PRINT.ICL'

get1    ldx #$10
        lda #7
        jsr gepu1
        bpl _rts

        cpy #136
        bne error
        jmp BW_COMTAB

error   tya
        jmp (BW_FAIL)

notpoi  sta $342,x

        lda <dnam
        sta $344,x
        lda >dnam
        sta $345,x

        jsr $e456
        bmi error

_rts    rts

dnam    dta c'D1:'
        dta b(155)

prthex  pha
        lsr @
        lsr @
        lsr @
        lsr @
        jsr prthx2
        pla

prthx2  and #15
        clc
        adc #$30
        cmp #$3a
        bcc prt1

        adc #6

prt1    tay
        lda #11
        ldx #0

gepu1   sta $342,x

        lda #0
        sta $348,x
        sta $349,x

        tya
        jmp $e456

load1   jsr _print
        dta b(155,0)

load1a  jsr get1
        sta adrl
        jsr get1
        sta adrh

        and adrl
        cmp #$ff
        beq load1a

        jsr get1
        sta endl
        jsr get1
        sta endh

* print addresses
        lda adrh
        jsr prthex
        lda adrl
        jsr prthex

        lda #'-'
        jsr prt1

        lda endh
        jsr prthex
        lda endl
        jsr prthex

* position
        jsr _print
        dta c' Off.'
        dta b(0)

        ldx #$10
        lda #38
        jsr notpoi

        ldx #$10
        lda $34c,x
        sta posl
        lda $34d,x
        sta posm
        lda $34e,x
        sta posh

        jsr prthex
        lda posm
        jsr prthex
        lda posl
        jsr prthex

* length
ln0     lda #0
endl    equ ln0+1

        sec
        sbc adrl
        tay

ln1     lda #0
endh    equ ln1+1

        sbc adrh
        tax

        iny
        bne ln2
        inx

ln2     sty lenl
        stx lenh

* load?
ln3     lda #0
ldit    equ ln3+1

        bne load2

loadne  ldx #$10
ln4     lda #0
posl    equ ln4+1

        clc
ln5     adc #0
lenl    equ ln5+1

        sta $34c,x

ln6     lda #0
posm    equ ln6+1

ln7     adc #0
lenh    equ ln7+1

        sta $34d,x

ln8     lda #0
posh    equ ln8+1

        adc #0
        sta $34e,x

        lda #37
        jsr notpoi

        jmp load1

* load!
load2   jsr _print
        dta c' Load at '
        dta b(0)

        lda adrl
        clc
ld21    adc #0
offsl   equ ld21+1

        sta adrl

        lda adrh
ld22    adc #0
offsh   equ ld22+1

        sta adrh

        jsr prthex
        lda adrl
        jsr prthex

ld23    lda #0
noque   equ ld23+1

        beq ld24

        jsr _print
        dta c' ! '
        dta b(0)
        jmp load3


ld24    jsr _print
        dta c' ? '
        dta b(0)

ld25    ldx 764
        inx
        beq ld25

        lda #$ff
        sta 764

        cpx #$1d
        beq ld25esc
        cpx #$2c
        beq ld25y
        cpx #$24
        bne ld25

        lda #'N'
        jsr prt1
        jmp loadne

ld25esc jsr _print
        dta b(155)
        dta c'<Aborted>'
        dta b(155,0)
        jmp BW_COMTAB

ld25y   lda #'Y'
        jsr prt1

load3   ldx #$10
        lda #7
        sta $342,x

ld31    lda #0
adrl    equ ld31+1

        sta $344,x
ld32    lda #0
adrh    equ ld32+1

        sta $345,x

        lda lenl
        sta $348,x
        lda lenh
        sta $349,x

        jsr $e456
        bpl load4
        jmp error

load4   jmp load1

        end
