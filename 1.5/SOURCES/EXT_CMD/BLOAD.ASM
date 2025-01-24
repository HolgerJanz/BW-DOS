* BW-DOS Command BLOAD file

name    equ $6e4

        blk dos $500
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
***

close   ldx #$10
        lda #12
        sta $342,x
        jmp $e456
***

start   lda $700
        cmp #'S'
        beq start2

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

        jsr getname

        ldy #36
        lda (10),y
        cmp #$9b
        bne start3a

        jsr print
        dta b(155)
        dta c'BLOAD fname adr. '
        dta c'[len.]'
        dta b(155,0)
        jmp err2

start3a ldy #33

start3  lda (10),y
        sta name-33,y
        iny
        cpy #61
        bcc start3

        jsr gethex
        bne start4
        jsr print
        dta b(155)
        dta c'No address specified !'
        dta b(155,0)
        jmp err2x

start4  txa
        pha
        tya
        pha
        lda #$ff
        sta lenflg

        jsr gethex
        bne start5

        ldy #$ff
        ldx #$ff
        lsr lenflg

start5  txa
        pha
        tya
        pha

        jsr close

        ldx #$10
        lda #3
        sta $342,x

        lda <name
        sta $344,x
        lda >name
        sta $345,x

        lda #4
        sta $34a,x
        lda #0
        sta $34b,x

        jsr $e456
        bpl start6

        jsr print
        dta b(155)
        dta c'Can''t open !'
        dta b(155,0)
        jmp err2x

start6  ldx #$10
        lda #7
        sta $342,x

        pla
        sta $348,x
        pla
        sta $349,x

        pla
        sta $344,x
        pla
        sta $345,x

        jsr $e456
        bpl start7

        cpy #136
        beq st6eof

        jsr print
        dta b(155)
        dta c'I/O Error !'
        dta b(155,0)
        jmp err2x

st6eof  lda #0

lenflg  equ st6eof+1

        bpl start7

        jsr print
        dta b(155)
        dta c'EOF found !'
        dta b(155,0)

start7  jmp err2

        end
