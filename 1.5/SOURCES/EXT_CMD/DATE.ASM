* BW-DOS command DATE

decout  equ 128
index   equ 130
tmp     equ 131

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

prtnm   lda (decout),y
        ora #$30
prt1    tay
        lda #0
        tax
        sta $348,x
        sta $349,x
        lda #11
        sta $342,x
        tya
        jmp $e456

start   lda $700
        cmp #'S'
        bne sterr

        lda $703
        cmp #'B'
        bne sterr

        lda $704
        cmp #'W'
        beq start2

sterr   jsr print
        dta b(155)
        dta c'Error: Not BW-DOS'
        dta b(155,0)

        jmp (10)

closes  lda #0
        sta 752

        ldx #$10
        jsr close
        ldx #$20

close   lda #12
        sta $342,x
        jmp $e456


gettd   jmp ($706)
settd   jmp ($708)
convdc  jmp ($70a)

vzor    dta c'  -  -   '

mytd    dta b(0,0,0)

kname   dta c'K:'
        dta b(155)

etab    dta b(0,1,3,4,6,7,8)

start2  lda 10
        sec
        sbc #19
        sta decout
        lda 11
        sbc #0
        sta decout+1

        jsr gettd

        jsr print
        dta b(155)
        dta c'Current date is '
        dta b(0)

        ldy #13

stl1    tya
        pha

        lda (10),y
        ldy #13
        sta (decout),y

        lda #0
        iny
        sta (decout),y
        iny
        sta (decout),y

        jsr convdc

        ldy #6
        jsr prtnm
        ldy #7
        jsr prtnm

        pla
        pha
        cmp #15
        beq stl2

        lda #'-'
        jsr prt1

stl2    pla
        tay

        iny
        cpy #16
        bcc stl1

        jsr print
        dta b(155,0)

        ldx #8
        lda #32

stl3    lda vzor,x
        sta text,x

        dex
        bpl stl3

        lda #0
        sta index

        jsr closes

        ldx #$10
        lda <kname
        sta $344,x
        lda >kname
        sta $345,x
        lda #4
        sta $34a,x
        lda #0
        sta $34b,x
        lda #3
        sta $342,x

        sta 752

        jsr $e456

        ldx #15
stl4    lda $340,x
        sta $360,x
        dex
        bpl stl4

edloop  ldx index
        ldy etab,x
        lda #160
        sta text,y

        ldx #$20
        lda <txt0
        sta $344,x
        lda >txt0
        sta $345,x
        lda #26
        sta $348,x
        lda #0
        sta $349,x
        lda #11
        sta $342,x
        jsr $e456

        lda #$1c
        jsr prt1


edl2    ldx #$10
        lda #0
        sta $348,x
        sta $349,x
        lda #7
        sta $342,x

        jsr $e456
        bmi edl2

        cmp #27
        beq edesc
        cmp #155
        beq edret
        cmp #126
        beq eddel

        cmp #$30
        bcc edl2
        cmp #$3a
        bcs edl2

        ldx index
        cpx #6
        bcs edl2

        ldy etab,x
        sta text,y

        inc index
        jmp edloop

eddel   ldx index
        beq edl2

        ldy etab,x
        lda #32
        sta text,y

        dec index
        jmp edloop

edesc   jsr closes

        jsr print
        dta b(155)
        dta c'Aborted.'
        dta b(155,0)

        jmp (10)

edret   jsr closes

        lda index
        beq notchg
        cmp #6
        bne invalid

        lda #32
        sta text+8

        lda #0
        sta index

        jsr edget
        cmp #32
        bcs invalid
        tax
        beq invalid
        sta mytd

        jsr edget
        cmp #13
        bcs invalid
        tax
        beq invalid
        sta mytd+1

        jsr edget
        sta mytd+2

        jsr gettd

        ldy #13

edret2  lda mytd-13,y
        sta (10),y

        iny
        cpy #16
        bcc edret2

        jsr settd

        jsr print

txt0    dta c'Enter new date: '
text    dta c'  -  -   '
        dta b(155,0)

        jmp (10)

notchg  jsr print
        dta c'(Date not changed)'
        dta c'         '
        dta b(155,0)
        jmp (10)

invalid jsr print
        dta b(155)
        dta c'Invalid date!'
        dta b(155,0)

        jmp (10)

edgtb   dta b(0,10,20,30,40)
        dta b(50,60,70,80,90)

edget   jsr edgt2
        tax
        lda edgtb,x
        sta tmp

        jsr edgt2
        clc
        adc tmp
        pha

        jsr edgt2

        pla
        rts

edgt2   ldx index
        inc index

        lda text,x
        and #15

        rts

        end
