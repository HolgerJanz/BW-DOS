* BW-DOS command DUMP file

hex     equ 128
pos     equ 131
len     equ 134
ascii   equ 137
llen    equ 138
lpos    equ 139
save82  equ 140
status  equ 141
lix     equ 142

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
        cmp #'/'
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
        dta c'Bad parameter'
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

        lda save82
        sta 82

        jmp (10)

close   ldx #$10
        lda #12
        sta $342,x
        jmp $e456

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
        dta c'Incorrect DOS'
        dta b(155,0)

        jmp (10)

start2  lda 82
        sta save82
        lda #0
        sta 82

        lda 10
        clc
        adc #3
        sta getname+1
        lda 11
        adc #0
        sta getname+2

        jsr getname

        ldy #33
st3     lda (10),y
        sta name-33,y
        iny
        cpy #61
        bcc st3

        ldx #0
        stx pos
        stx pos+1
        stx pos+2
        stx ascii

        dex
        stx len
        stx len+1
        stx len+2

        jsr gethex
        bne st5

        cmp #'/'
        beq st7
        bne st6

st5     ldx #2
st5b    lda hex,x
        sta pos,x
        dex
        bpl st5b

st6     jsr gethex
        bne st6b

        cmp #'/'
        beq st7
        bne st6d

st6b    ldx #2
st6c    lda hex,x
        sta len,x
        dex
        bpl st6c

st6d    jsr getname

st7     ldy #36
        lda (10),y
        cmp #'/'
        bne st8

        iny
        lda (10),y
        cmp #'A'
        bne st8

        dec ascii

* OPEN
st8     jsr close

        ldx #$10
        lda #3
        sta $342,x

        lda #4
        sta $34a,x
        lda #0
        sta $34b,x

        jsr cioname
        bpl st9
        jsr print
        dta b(155)
        dta c'Cannot open file'
        dta b(155,0)
        jmp err2x

* POINT
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

        jsr cioname
        bpl st10
        jsr print
        dta b(155)
        dta c'Cannot set file position'
        dta b(155,0)
        jmp err2x

* DUMP IT !
st10    lda #155
        jsr prt1

* GET
dump1   ldx #$10
        lda #7
        sta $342,x

        lda #8
        sta $348,x
        lda #0
        sta lpos
        sta lix
        sta $349,x

        jsr cioname
        sty status

        ldx #$10
        lda $348,x
        sta llen
* LEN
        lda len
        tax
        sec
        sbc llen
        sta len
        lda len+1
        sbc #0
        sta len+1
        lda len+2
        sbc #0
        sta len+2
        bcs dump1a

        stx llen
        lda #136
        sta status

dump1a  lda llen
        bne dump1b
        jmp dumpx
* POS
dump1b  lda pos+2
        jsr dprthx
        lda pos+1
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
        bne dump2
        inc pos+2

* DATA
dump2   ldx lix
        lda name,x
        jsr dprthx

        jsr dspac

        inc lix
        lda lix
        cmp llen
        bcc dump2

        lda #0
        sta lix

* MOVE
dump3   lda lpos
        cmp #31
        bcs dump4

        jsr dspac

        jmp dump3

* CHARS
dump4   ldx lix
        lda name,x

        ldx ascii
        bne dump4a

        cmp #$9b
        bne dump4aa
        lda #$20

dump4aa pha
        lda #27
        jsr prt1
        pla
        jmp dump4d

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

* EOL
        jsr prteol

* NEXT?
dumpx   lda status
        bmi dumpx2

        lda 764
        cmp #$1c
        beq desc

        jmp dump1

dumpx2  cmp #136
        bne *+5
        jmp err2

        jsr print
        dta b(155)
        dta c'Error while reading'
        dta b(155,0)

        jmp err2x

desc    lda #$ff
        sta 764

        jsr print
        dta b(155)
        dta c'<Aborted>'
        dta b(155,0)
        jmp err2

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
