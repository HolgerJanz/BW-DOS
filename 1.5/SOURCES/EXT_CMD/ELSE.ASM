* BW-DOS command ELSE

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

no2     jsr getline

        ldx #0

no3     lda buffer,x
        cmp vzor,x
        bne no2

        inx

        cmp #155
        bne no3

        jmp (10)

vzor    dta c'ENDIF'
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
