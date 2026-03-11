* BW-DOS command DATE
        icl '_SYSEQU.ICL'

        blk dos $3000
        icl '_TSTBW15.ICL'

        jsr gettd

        jsr print
        dta b(155)
        dta c'Current date: '
        dta b(0)

        ldy #13

; date time output
stl1    tya
        pha

        lda BW_COMTAB,y
        ldy #13
        sta BW_DECOUT,y

        lda #0
        iny
        sta BW_DECOUT,y
        iny
        sta BW_DECOUT,y

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

; date input
        jsr print
        dta b(155,0)

        ldx #8
        lda #32

stl3    lda vzor,x
        sta text,x

        dex
        bpl stl3
; set index in input line
        lda #0
        sta index

        jsr closes
; open keyboard
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
; set cursor in input line
edloop  ldx index
        ldy etab,x
        lda #160 ; inverse space
        sta text,y
; print enter data
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

; check 0-9
        cmp #$30
        bcc edl2
        cmp #$3a
        bcs edl2

; check input range
        jsr chkrng
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

        ldy #13
edret2  lda mytd-13,y
        sta BW_COMTAB,y
        iny
        cpy #16
        bcc edret2

        jsr settd

        jsr print

txt0    dta c'    New date: '
text    dta c'  -  -   '
        dta b(155,0)

        jmp BW_COMTAB

index   dta b(0)
tmp     dta b(0)

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

; check range of data input
; A = char digit
; x = index (0-5)
chkrng  cmp mtab,X
        bcs crerrs

        cpx #1
        bcc crokc
        bne chkrng3
; if day 0x then not 00
        cmp #'1'
        bcs chkrd2
        ldy text
        cpy #'0'
        beq crerr
; if day 3x then only 30-31
chkrd2  ldy text
        cpy #'3'
crokc   bcc crok
        cmp #'2'
crerrs  bcs crerr

chkrng3 cpx #3
        bne chkrng5
; if day 0x then not 00
        cmp #'1'
        bcs chkrd3
        ldy text+3
        cpy #'0'
        beq crerr
; if month 1x then only 10-12
chkrd3  ldy text+3
        cpy #'1'
        bcc chkrmh
        cmp #'3'
        bcs crerr
; if day 3x then check month
chkrmh  ldy text
        cpy #'3'
        bcc crok
; calc month end check max day
        pha
        ldy text+3
        cpy #'1'
        bcc *+4
        adc #9
        and #$0F
        tay
        lda text+1
        cmp ltab-1,Y
        pla
        bcs crerr

; check leap year (20)00-(20)99
chkrng5 cpx #5
        bne crok
        ldy text+3
        cpy #'0'
        bne crok
        ldy text+4
        cpy #'2'
        bne crok
        ldy text
        cpy #'2'
        bne crok
        ldy text+1
        cpy #'9'
        bne crok
; 29-02 check leap year
        pha
        lda text+6
        and #$0F
        tay
        pla
        pha
        clc
        adc edgtb,Y
        and #$03
        tay
        pla
        cpy #0
        bne crerr
; date ok
crok    clc
        rts
; invalid date
crerr   sec
        rts

; first invalid digit for date digit (ddmmyy)
mtab    dta c'4:2:::'
; first 3x invalid day for index month (1-12)
ltab    dta c'202121221212'

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

vzor    dta c'  -  -   '

mytd    dta b(0,0,0)

kname   dta c'K:'
        dta b(155)

etab    dta b(0,1,3,4,6,7,8)

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

        end
