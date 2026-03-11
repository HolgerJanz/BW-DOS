* BW-DOS command PAUSE

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

xdivio  jmp ($ffff)

start   lda $700
        cmp #'S'
        beq start2

        jsr print
        dta b(155,253)
        dta c'Incorrect DOS version'
        dta b(155,0)

        jmp (10)

start2  lda 10
        clc
        adc #8
        sta xdivio+1
        lda 11
        adc #0
        sta xdivio+2
        jsr print
        dta b(155)
        dta c'Press <RETURN> to continue...'
        dta b(0)

start3  jsr close

        ldx #$10
        lda #3
        sta $342,x

        lda <knam
        sta $344,x
        lda >knam
        sta $345,x

        lda #4
        sta $34a,x
        lda #0
        sta $34b,x

        jsr $e456
        bmi start3

        ldx #$10
        lda #7
        sta $342,x
        lda #0
        sta $348,x
        sta $349,x

        jsr $e456
        bmi start3

        pha
        jsr close
        pla

        cmp #155
        beq stret
        cmp #27
        bne start3
* esc
        ldy #1
        jsr xdivio

        jsr print
        dta b(155)
        dta c'(Batch file aborted)'
        dta b(0)

* return
stret   jsr print
        dta b(155,0)

        jmp (10)

close   ldx #$10
        lda #12
        sta $342,x

        jmp $e456

knam    dta c'K:'
        dta b(155)

        end
