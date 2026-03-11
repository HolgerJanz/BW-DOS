* BW-DOS Command CHVOL

zpg1    equ 128

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

error   tya
        pha

        jsr print
        dta b(155)
        dta c'Error '
        dta b(0)

        ldx #2
        pla

err2    ldy #0

err3    cmp errtab,x
        bcc err4

        sbc errtab,x
        iny
        bne err3

err4    pha
        txa
        pha

        tya
        ora #$30
        jsr prt1

        pla
        tax
        pla

        dex
        bpl err2

        lda #$9b
        jsr prt1

err5x   ldy #8
        lda (10),y
        sta err5y+1
        iny
        lda (10),y
        sta err5y+2
        ldy #1
err5y   jsr $e474

err5    jmp (10)

errtab  dta b(1,10,100)

start   lda $700
        cmp #'S'
        beq start2

        jsr print
        dta b(155,253)
        dta c'Incorrect DOS version'
        dta b(155,0)

        jmp (10)

start2  lda 10
        sta zpg1
        clc
        adc #3
        sta getname+1
        lda 11
        sta zpg1+1
        adc #0
        sta getname+2

        dec zpg1+1

        ldy #256-10
        lda (zpg1),y
        sta siojp+1
        iny
        lda (zpg1),y
        sta siojp+2

        jsr getname
        bne start21
        ldy #$9C
        jmp error

start21 ldy #33
        lda (10),y
        cmp #'D'
        bne ster1

        iny
        lda (10),y
        and #15
        sta siodriv

        lda #'R'
        ldx #$40
        jsr rwsect

        lda buff+7
        cmp #$80
        bne ster2

        lda buff+32
        cmp #$20
        bcc ster2

        lda buff+31
        asl @
        beq start3

ster2   ldy #148
        dta b($2c)
ster1   ldy #146
        jmp error

start3  ldy #36

st3b    lda (10),y
        cmp #155
        beq st3c

        sta buff+22-36,y

        iny
        cpy #44
        bcc st3b

st3c    cpy #44
        bcs start4

        lda #32
        sta buff+22-36,y

        iny
        bne st3c

start4  ldy #256-2
        lda (zpg1),y
        ldx #128
        jsr rwsect

        jmp err5

sioex   rts

rwsect  sta siocmd
        stx siostat

        ldx #11
rws2    lda rwst,x
        sta $300,x
        dex
        bpl rws2

siojp   jsr sioex
        bpl sioex

        jmp error

rwst    dta b($31)
siodriv dta b(0)
siocmd  dta b(0)
siostat dta b(0)
        dta a(buff,7,128,1)

buff    equ *

        end
