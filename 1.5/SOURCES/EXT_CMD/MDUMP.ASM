* BW-DOS command MDUMP address [length] [/A]

        blk dos $480
        jmp start

print   pla
        sta print3+1
        pla
        sta print3+2

print2  inc print3+1
        bne print3
        inc print3+2

print3  lda $ffff
        beq print4

        jsr prt1
        jmp print2

print4  lda print3+2
        pha
        lda print3+1
        pha

prtex   rts

prteol  lda #$9b

prt1    tay

        lda #0
        tax
        sta $348,x
        sta $349,x

        lda #11
        sta $342,x

        tya
        jsr $e456
        bpl prt1ex
        jmp desc
prt1ex  rts

getname jmp prtex

ghxrts  ldy #0
        ldx #0
hexl    equ ghxrts+1
hexh    equ ghxrts+3

        lda #1

ghxrts2 rts

gethex  jsr getname

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

ghxerr  jsr print
        dta b(155)
        dta c'Bad parameter!'
        dta b(155,0)

err2x   ldy     #8
        lda     (10),y
        sta     err5y+1
        iny
        lda     (10),y
        sta     err5y+2
        ldy     #1
err5y   jsr     $e474

err2    jmp     (10)

start   lda     $700
        cmp     #'S'
        beq     start2

        jsr print
        dta b(155,253)
        dta c'Bad DOS !'
        dta b(155,0)

        jmp (10)

start2  lda 10
        clc
        adc #3
        sta getname+1
        lda 11
        adc #0
        sta getname+2

        ldx #0
        stx pos
        stx pos+1
        stx ascii
        stx status

        dex
        stx lenl
        stx lenh

        jsr gethex
        bne st5

        cmp #'/'
        beq st7
        bne st6

st5     sty pos
        stx pos+1

st6     jsr gethex
        bne st6b

        cmp #'/'
        beq st7
        bne st6d

st6b    sty lenl
        stx lenh

st6d    jsr getname

st7     ldy #36
        lda (10),y
        cmp #'/'
        bne st10

        iny
        lda (10),y
        cmp #'A'
        bne st10

        dec ascii

* dump it

st10    jsr prteol

* get

dump1   ldx #8
        stx llen

        dex

dump1aa lda $ffff,x
        sta name,x
        dex
        bpl dump1aa

pos     equ dump1aa+1

        inx
        stx lix
        stx lpos
* len

d1aalo  lda #0
        tax
        sec
        sbc #8
        sta lenl
d1aahi  lda #0
        sbc #0
        sta lenh
        bcs dump1a

lenl    equ d1aalo+1
lenh    equ d1aahi+1

        stx llen
        dec status

dump1a  lda #0
        bne dump1b
        jmp dumpx

llen    equ dump1a+1

* pos

dump1b  lda pos+1
        jsr dprthx
        lda pos
        jsr dprthx

        jsr dspac

        lda llen
        clc
        adc pos
        sta pos
        bcc dump2
        inc pos+1

* data

dump2   ldx #0
        lda name,x
        jsr dprthx

lix     equ dump2+1


        jsr dspac

        inc lix
        lda lix
        cmp llen
        bcc dump2

        lda #0
        sta lix
        beq dump3

*** move

dump3a  jsr dspac

dump3   lda #0
        cmp #29
        bcc dump3a
**
lpos    equ dump3+1
**

*** chars

dump4   ldx lix
        lda name,x

d4asc   ldx #0
        bne dump4a
**
ascii   equ d4asc+1
**

        cmp #$9b
        bne dump4aa
        lda #$20

dump4aa pha
        lda #27
        jsr prt1
        pla
        jmp dump4d
**

dump4a  and #127
        cmp #125
        bcc dump4b
        lda #'.'

dump4b  cmp #32
        bcs dump4d
        lda #'.'

dump4d  jsr dprt1

        inc lix
        lda lix
        cmp llen
        bcc dump4
* eol
        jsr prteol

* next?
dumpx   lda #0
        bmi dumpx2

status  equ dumpx+1

        lda 764
        cmp #$1c
        beq desc

        jmp dump1

desc    lda #$ff
        sta 764

        jsr print
        dta b(155)
        dta c'<Aborted>'
        dta b(155,0)

dumpx2  jmp err2

dprthx  pha
        lsr @
        lsr @
        lsr @
        lsr @
        jsr dprthx2
        pla

dprthx2 and #15
        clc
        adc #$30
        cmp #$3a
        bcc dprt1

        adc #6

        dta b($2c)
dspac   lda #' '

dprt1   inc lpos
        jmp prt1

name    equ *

        end
