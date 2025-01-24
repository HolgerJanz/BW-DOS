* BW-DOS command CUT file1 file2 position [length]

hex     equ 128
pos     equ 131
len     equ 134
lenflg  equ 137
memlen  equ 138
status  equ 140

        blk dos $3000
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

ghxrts  ldy #1
ghxrts2 rts

gethex  jsr getname

        lda #0
        sta hex
        sta hex+1
        sta hex+2

        ldy #36
        lda (10),y
        cmp #155
        beq ghxrts2

gethx2  cpy #43
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
gethx4  asl hex
        rol hex+1
        rol hex+2
        dex
        bne gethx4

        pla
        ora hex
        sta hex

        jmp gethx2

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

err2    jsr closes
        jmp (10)

closes  ldx #$10
        jsr clss2
        ldx #$20

clss2   lda #12
        sta $342,x
        jsr $e456
        bmi ioerr
        rts

ioerr   jsr print
        dta b(155)
        dta c"I/O Error !"
        dta b(155,0)
        jmp err2x

cionam1 lda <name1
        sta $344,x
        lda >name1
        sta $345,x

        jmp $e456

getn2   jsr getname

        ldy #33
st3     lda (10),y
        sta name-33,y
        iny
        cpy #61
        bcc st3

        rts

start   lda $700
        cmp #'S'
        beq start2

        jsr print
        dta b(155,253)
        dta c"Incorrect DOS !"
        dta b(155,0)

        jmp (10)

start2  lda 10
        clc
        adc #3
        sta getname+1
        lda 11
        adc #0
        sta getname+2

* names
        jsr getn2

        ldx #29
st2b    lda name,x
        sta name1,x
        dex
        bpl st2b

        jsr getn2

        ldx #0
        stx pos
        stx pos+1
        stx pos+2

        stx lenflg

        dex
        stx len
        stx len+1
        stx len+2

* pos
        jsr gethex
        beq st6

        ldx #2
st5b    lda hex,x
        sta pos,x
        dex
        bpl st5b

* len
st6     jsr gethex
        beq st7

        ldx #2
st6c    lda hex,x
        sta len,x
        dex
        bpl st6c

        stx lenflg

* open1
st7     jsr closes

        ldx #$10
        lda #3
        sta $342,x

        lda #4
        sta $34a,x
        lda #0
        sta $34b,x

        jsr cionam1
        bpl st9

st7er   jsr print
        dta b(155)
        dta c'Can''t open file !'
        dta b(155,0)
        jmp err2x

* point
st9     lda pos
        ora pos+1
        ora pos+2
        beq st10

        ldx #$10
        lda #37
        sta $342,x

        lda pos
        sta $34c,x
        lda pos+1
        sta $34d,x
        lda pos+2
        sta $34e,x

        jsr cionam1
        bpl st10
***
        jsr print
        dta b(155)
        dta c'Can''t set '
        dta c'file-position !'
        dta b(155,0)
        jmp err2x

* open2
st10    ldx #$20

        lda #3
        sta $342,x

        lda #8
        sta $34a,x
        lda #0
        sta $34b,x

        lda <name
        sta $344,x
        lda >name
        sta $345,x

        jsr $e456
        bmi st7er

* copy it
st11    jsr jeli0

        bne st11b
        jmp stxx

st11b   ldx #$10
        lda #7
        sta $342,x

        lda <buff
        sta $344,x
        lda >buff
        sta $345,x

        lda 741
        sec
        sbc <buff
        sta $348,x
        lda 742
        sbc >buff
        sta $349,x

        lda len+2
        bne st11c

        lda len
        cmp $348,x
        lda len+1
        sbc $349,x
        bcs st11c

        lda len
        sta $348,x
        lda len+1
        sta $349,x

st11c   jsr $e456
        sty status
        bpl st11d

        cpy #136
        bne ioerrj

st11d   ldx #$10
        lda $348,x
        sta memlen
        lda $349,x
        sta memlen+1

        ora memlen
        beq st12

* save
        ldx #$20
        lda #11
        sta $342,x

        lda <buff
        sta $344,x
        lda >buff
        sta $345,x

        lda memlen
        sta $348,x
        lda memlen+1
        sta $349,x

        jsr $e456
        bpl st12
ioerrj  jmp ioerr

st12    lda len
        sec
        sbc memlen
        sta len

        lda len+1
        sbc memlen+1
        sta len+1
        bcs st14

        dec len+2

st14    lda status
        bmi st14eof

stxx    jsr jeli0
        beq st15

        jmp st11

st14eof lda lenflg
        beq st15

        jsr print
        dta b(155)
        dta c'EOF found !'
        dta b(155,0)

st15    jmp err2

jeli0   lda len
        ora len+1
        ora len+2

        rts

name1   equ *
name    equ *+30
buff    equ *+60

        end
