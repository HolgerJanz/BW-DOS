* BW-DOS command MEMEDIT 

        blk dos $500
        jmp start

edbuf   equ $6fb

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

kname   dta c'K:'
        dta b(155)

getkey  jsr close

        ldx #$10
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

        ldx #$10
        lda #7
        sta $342,x

        lda #0
        sta $348,x
        sta $349,x

        jsr $e456
        bpl gkey2

        lda #'?'

gkey2   pha

        jsr close

        pla
        rts

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
***

gethex  ldy #0
        sty hexl
        sty hexh

gethx2  cpy #5
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
gethx4  asl hexl
        rol hexh
        dex
        bne gethx4

        pla
        ora hexl
        sta hexl

        jmp gethx2

ghxrts  ldy #0
        ldx #0

hexl    equ ghxrts+1
hexh    equ ghxrts+3

        rts

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

close   ldx #$10
        lda #12
        sta $342,x
        jmp $e456

start   lda $700
        cmp #'S'
        beq start2

        jsr print
        dta b(155,253)
        dta c'Incorrect DOS!'
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

        ldy #36
st4     lda (10),y
        sta edbuf-36,y
        iny
        cpy #41
        bcc st4

        jsr gethex

        sty pos
        stx pos+1

* edit loop

edit1   jsr prteol

        lda pos+1
        jsr prthex
        lda pos
        jsr prthex

        jsr print
        DTA c': '
        DTA b(0)

ed1ps   lda $ffff

pos     equ ed1ps+1

        jsr prthex

edit1d  jsr print
        dta c' => '
        dta B(0)

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

edit2b  ldx #0
        cpx #2
        bcs edit2

edix    equ edit2b+1

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

        lda pos
        sta edit3a+1
        lda pos+1
        sta edit3a+2

        jsr gethex

edit3a  sty $ffff

edit3b  inc pos
        bne edit4
        inc pos+1

edit4   jmp edit1

        end
