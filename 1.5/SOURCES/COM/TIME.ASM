* BW-DOS command TIME
        icl '_SYSEQU.ICL'

        blk dos $3000
        icl '_TSTBW15.ICL'

        jsr gettd

        jsr print
        dta b(155)
        dta c'Current time: '
        dta b(0)

        ldy #16

stl1    tya
        pha

        lda BW_COMTAB,y
        ldy #13
        sta BW_DECOUT,Y

        lda #0
        iny
        sta BW_DECOUT,Y
        iny
        sta BW_DECOUT,Y

        jsr convdc

        ldy #6
        jsr prtnm
        ldy #7
        jsr prtnm

        pla
        pha
        cmp #18
        beq stl2

        lda #':'
        jsr prt1

stl2    pla
        tay

        iny
        cpy #19
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
        sta CRSINH
        jsr CIOV

        ldx #15
stl4    lda $340,x
        sta $360,x
        dex
        bpl stl4

edloop  ldx index
        ldy etab,x
        lda #160 ; inverse space
        sta text,y

        ldx #$20
        lda <txt0
        sta $344,x
        lda >txt0
        sta $345,x
        lda #24
        sta $348,x
        lda #0
        sta $349,x
        lda #11
        sta $342,x
        jsr CIOV

        lda #$1c ; cursor up
        jsr prt1

; get char from keyboard
edl2    ldx #$10
        lda #0
        sta $348,x
        sta $349,x
        lda #7
        sta $342,x
        jsr CIOV
        bmi edl2

        ldx index
        cmp #27 ; ESC
        beq edesc
        cmp #126 ; Delete
        beq eddel
        cmp #155 ; Return
        bne chkidx
        cpx #6
        beq edret

chkidx  cpx #6
        bcs edl2

* num char?
        cmp #$30
        bcc edl2
; check range
        cmp rtab,X
        bcs edl2

        cpx #1
        bne edmov
        ldy text
        cpy #'2'
        bne edmov
        cmp #'4'
        bcs edl2

edmov   ldy etab,x
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
        dta c'Aborted'
        dta b(155,0)

        jmp BW_COMTAB

edret   jsr closes

        lda #32
        sta text+8

        lda #0
        sta index

        jsr edget
        sta mytd

        jsr edget
        sta mytd+1

        jsr edget
        sta mytd+2

        jsr gettd

        ldy #16

edret2  lda mytd-16,y
        sta BW_COMTAB,y

        iny
        cpy #19
        bcc edret2

        jsr settd

        jsr print
txt0    dta c'    New time: '
text    dta c'  :  :   '
        dta b(155,0)
        JMP BW_COMTAB

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

prtnm   lda BW_DECOUT,y
        ora #$30
prt1    tay

        lda #0
        tax
        sta $348,x
        sta $349,x

        lda #11
        sta $342,x

        tya
        jmp CIOV

closes  lda #0
        sta CRSINH

        ldx #$10
        jsr close
        ldx #$20

close   lda #12
        sta $342,x
        jmp CIOV


gettd   jmp (BW_GETTD)
settd   jmp (BW_SETTD)
convdc  jmp (BW_CONVDC)

vzor    dta c'  :  :   '
mytd    dta b(0,0,0)
kname   dta c'K:',b(155)
etab    dta b(0,1,3,4,6,7,8)
rtab    dta c'3:6:6:'

index   dta b(0)
tmp     dta b(0)

        end
