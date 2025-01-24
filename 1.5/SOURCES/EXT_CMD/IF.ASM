* BW-DOS command IF

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

eol     lda #$9b

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

batflg  lda $ffff
        rts

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

        lda 10
        sec
        sbc #7
        sta batflg+1
        lda 11
        sbc #0
        sta batflg+2

        jsr eol

        jsr getline

        jsr print
        dta c'<Y>...Yes  <N>...No  '
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

        cmp #27
        beq escape

        and #$5f
        cmp #'Y'
        bne nono

yes0    jsr print
        dta c'Yes!'
        dta b(155,0)

        jmp (10)

nono    cmp #'N'
        beq no
        bne start3

* ESC

escape  ldy #1
        jsr xdivio

        jsr print
        dta b(155)
        dta c'(Batch file aborted)'
        dta b(155,0)

no3     jmp (10)

no      jsr print
        dta c'No!'
        dta b(155,155,0)

no2     jsr getline

        ldx #0
        jsr test
        beq no3

        ldx <vz2-vzor
        jsr test
        bne no2
        beq no3

vzor    dta c'ENDIF'
        dta b(155)
vz2     dta c'ELSE'
        dta b(155)

test    ldy #0

test2   lda buffer,y
        cmp vzor,x
        bne testx

        iny
        inx

        cmp #$9b
        bne test2

        lda #0
testx   rts

close   ldx #$10
        lda #12
        sta $342,x

        jmp $e456

knam    dta c'K:'
        dta b(155)

getlnx  ldy #1
        jsr xdivio

        jsr print
        dta b(155)
        dta c'Error: End of batch file!'
        dta b(155,0)

        jmp (10)

getline jsr batflg
        bmi getlnx

        ldx #0
        lda #5
        sta $342,x

        lda <buffer
        sta $344,x
        lda >buffer
        sta $345,x

        lda #64
        sta $348,x
        lda #0
        sta $349,x

        jsr $e456
        bmi getlnx

        rts

buffer  equ *

        end
