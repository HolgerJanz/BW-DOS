* BW_DOS command HEXEDIT file [position]

hex     equ 128
pos     equ 131
edix    equ 134

        org $3000
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
        jmp $e456

getname jmp prtex

kname   dta c"K:"
        dta b(155)

getkey  jsr close2

        ldx #$20
        lda #3
        sta $342,x

        lda <kname
        sta $344,x
        lda >kname
        sta $345,x

        lda #4
        sta $34a,x
        lda #0
        sta $34b,x

        jsr $e456
        bmi keyerr

        ldx #$20
        ldy #7
        jsr gepu
        bpl gkey2

keyerr  lda #'?'

gkey2   pha
        jsr close2

        pla
        rts

gepu10  ldx #$10

gepu    pha

        tya
        sta $342,x

        lda #0
        sta $348,x
        sta $349,x

        pla
        jmp $e456

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
        jmp prt1

gethex  ldy #0
        sty hex
        sty hex+1
        sty hex+2

gethx2  cpy #7
        bcs ghxerr

        lda edbuf,y
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
gethx4  asl hex
        rol hex+1
        rol hex+2
        dex
        bne gethx4

        pla
        ora hex
        sta hex

        jmp gethx2

ghxrts  rts

ghxerr  jsr print
        dta b(155)
        dta c'Bad parameter !'
        dta b(155,0)

err2x   ldy #8
        lda (10),y
        sta err5y+1
        iny
        lda (10),y
        sta err5y+2
        ldy #1
err5y   jsr $e474

err2    jsr close
        jmp (10)

point   ldx #$10
        lda #37
        sta $342,x

        lda pos
        sta $34c,x
        lda pos+1
        sta $34d,x
        lda pos+2
        sta $34e,x

        jsr cioname
        bpl ghxrts

        jsr print
        dta b(155)
        dta c'Can''t set file-position !'
        dta b(155,0)
        jmp err2x

close   ldx #$10
        jsr closex

close2  ldx #$20

closex  lda #12
        sta $342,x
        jsr $e456
        bmi clerj
        rts

clerj   jmp ederr

cioname lda <name
        sta $344,x
        lda >name
        sta $345,x

        jmp $e456

start   lda $700
        cmp #'S'
        beq start2

        jsr print
        dta b(155,253)
        dta c'Incorrect DOS !'
        dta b(155,0)

        jmp (10)

start2  lda 10
        clc
        adc #3
        sta getname+1
        lda 11
        adc #0
        sta getname+2

        jsr getname
        beq cntofl

        ldy #33
st3     lda (10),y
        sta name-33,y
        iny
        cpy #61
        bcc st3

        jsr getname

        ldy #36
st4     lda (10),y
        sta edbuf-36,y
        iny
        cpy #61
        bcc st4

        jsr gethex

        ldx #2
st5b    lda hex,x
        sta pos,x
        dex
        bpl st5b

* open

st8     jsr close

        ldx #$10
        lda #3
        sta $342,x

        lda #12
        sta $34a,x
        lda #0
        sta $34b,x

        jsr cioname
        bpl edit1

cntofl  jsr print
        dta b(155)
        dta c'Can''t open file !'
        dta b(155,0)
        jmp err2x

* edit loop

edit1   jsr prteol

        lda pos+2
        jsr prthex
        lda pos+1
        jsr prthex
        lda pos
        jsr prthex

        jsr print
        dta c': '
        dta b(0)

* file open? (GETLEN)

        ldx #$10
        lda #39
        sta $342,x

        jsr cioname
        bpl edit1b

* error

EDERR   jsr print
        dta b(155)
        dta c'I/O Error !'
        dta b(155,0)
        jmp err2x

edit1b  ldx #$10

        lda pos
        cmp $34c,x
        lda pos+1
        sbc $34d,x
        lda pos+2
        sbc $34e,x
        bcc edit1c
* behind
        jsr print
        dta c"  "
        dta b(0)
        jmp edit1d

edit1c  jsr point

        ldy #7
        jsr gepu10
        bmi ederr

        jsr prthex

edit1d  jsr print
        dta c' => '
        dta b(0)

        lda #$20
        sta edbuf
        sta edbuf+1

        lda #0
        sta edix

edit2   jsr getkey

        cmp #155
        beq edit3
        cmp #27
        beq ed2esc
        cmp #126
        beq ed2del

        and #127
        cmp #$30
        bcc edit2
        cmp #$3a
        bcc edit2b

        and #$5f
        cmp #$41
        bcc edit2
        cmp #$47
        bcs edit2

edit2b  ldx edix
        cpx #2
        bcs edit2

        sta edbuf,x
        inc edix

edit2c  jsr prt1
        jmp edit2

ed2del  ldx edix
        beq edit2

        dec edix
        jmp edit2c

ed2esc  jsr prteol
        jmp err2

edit3   ldx edix
        beq edit3b

        lda #$9b
        sta edbuf,x

        jsr gethex

        jsr point

        lda hex
        ldy #11
        jsr gepu10
        bpl edit3b
        jmp ederr

edit3b  inc pos
        bne edit4
        inc pos+1
        bne edit4
        inc pos+2

edit4   jmp edit1

name    equ *
edbuf   equ *+$100

        end
