* BW-DOS command SAVE file start end [/A]

        blk dos $500
        jmp start

syntax  dta b(155)
        dta c'Syntax Error!'
opner   dta b(155)
        dta c'Can''t open file!'
daterr  dta b(155)
        dta c'I/O Error !'
        dta b(155)

header  dta a($ffff)
from    dta a(0)
to      dta a(0)

dosver  dta b(155)
        dta c'Incorrect DOS !'
txtend  dta b(155)

puts    stx putiocb
        sta putlen
        sty putix

puts2   ldx putiocb
        lda #11
        sta $342,x
        lda #0
        sta $348,x
        sta $349,x

        ldy putix
        lda syntax,y

        jsr $e456
        bmi prtex

        inc putix
        dec putlen
        bne puts2

prtex   rts

getname jmp prtex

ghxrts  ldy hex
        ldx hex+1
        rts

gethex  jsr getname

        lda #0
        sta hex
        sta hex+1

        ldy #36

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
gethx4  asl hex
        rol hex+1
        dex
        bne gethx4

        pla
        ora hex
        sta hex

        jmp gethx2

ghxerr  ldy #0
        lda <opner-syntax+1

error2  ldx #0
        jsr puts

        ldy #8
        lda (10),y
        sta err5y+1
        iny
        lda (10),y
        sta err5y+2
        ldy #1
err5y   jsr $e474

error3  jsr close
        jmp (10)

close   ldx #$10
        lda #12
        sta $342,x
        jmp $e456

start   lda $700
        cmp #'S'
        beq start2

        ldy <dosver-syntax
        lda <txtend-dosver+1
        ldx #0
        jsr puts
        jmp (10)

start2  lda 10
        clc
        adc #3
        sta getname+1
        lda 11
        adc #0
        sta getname+2

        jsr getname
        bne strt21
        ldy #0
        lda <opner-syntax+1
        jmp error2

strt21  ldy #33
strt3   lda (10),y
        sta name-33,y
        iny
        cpy #61
        bcc strt3

        jsr gethex
        sty from
        stx from+1

        jsr gethex
        sty to
        stx to+1

        jsr getname

        lda #8
        sta aux

        ldy #36
        lda (10),y
        cmp #'/'
        bne strt4

        iny
        lda (10),y
        cmp #'A'
        bne strt4

        inc aux

strt4   jsr close

        ldx #$10
        lda #3
        sta $342,x

        lda <name
        sta $344,x
        lda >name
        sta $345,x

        lda aux
        sta $34a,x
        lda #0
        sta $34b,x

        jsr $e456
        bpl strt5

        ldy <opner-syntax
        lda <daterr-opner+1
        jmp error2

saverr  ldy <daterr-syntax
        lda <header-daterr
        jmp error2

strt5   lsr aux
        bcs strt6

        ldx #$10
        ldy <header-syntax
        lda #2
        jsr puts
        bmi saverr

strt6   ldx #$10
        ldy <from-syntax
        lda #4
        jsr puts
        bmi saverr

        ldx #$10
        lda #11
        sta $342,x

        lda from
        sta $344,x
        lda from+1
        sta $345,x

        lda to
        sec
        sbc from
        sta $348,x
        lda to+1
        sbc from+1
        sta $349,x

        inc $348,x
        bne strt7
        inc $349,x

strt7   jsr $e456
        bmi saverr

        jsr close
        bmi saverr

        jmp (10)

hex     equ *

aux     equ hex+2

putix   equ aux+1
putlen  equ putix+1
putiocb equ putlen+1

name    equ putiocb+1 ;+28

        end
