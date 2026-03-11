* BW-DOS Command DISASS file [position]

hex     equ 128
pos     equ 131
lpos    equ 139
status  equ 141

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

ghxrts  ldy #1
ghxrts2 rts

gethex  jsr getname

        lda #0
        sta hex
        sta hex+1
        sta hex+2

        ldy #36
        lda (10),y
        cmp #155
        beq ghxrts2

gethx2  cpy #43
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
        rol hex+2
        dex
        bne gethx4

        pla
        ora hex
        sta hex

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

close   ldx #$10
        lda #12
        sta $342,x
        jmp $e456

cioname lda <name
        sta $344,x
        lda >name
        sta $345,x

        jmp $e456

start   lda $700
        cmp #'S'
        beq start2

        jsr print
        dta b(155,253)
        dta c'Incorrect DOS !'
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

        ldy #33
st3     lda (10),y
        sta name-33,y
        iny
        cpy #61
        bcc st3

        ldx #0
        stx pos
        stx pos+1
        stx pos+2
        stx status

        jsr gethex
        beq st8

        ldx #2
st5b    lda hex,x
        sta pos,x
        dex
        bpl st5b

* OPEN
st8     jsr close

        ldx #$10
        lda #3
        sta $342,x
        lda #4
        sta $34a,x
        lda #0
        sta $34b,x
        jsr cioname
        bpl st9
        jsr print
        dta b(155)
        dta c'Can''t open file !'
        dta b(155,0)
        jmp err2x

* POINT
st9     lda pos
        ora pos+1
        ora pos+2
        beq st10
        ldx #$10
        lda #37
        sta $342,x
        lda pos
        sta $34c,x
        lda pos+1
        sta $34d,x
        lda pos+2
        sta $34e,x
        jsr cioname
        bpl st10
        jsr print
        dta b(155)
        dta c'Can''t set file position!'
        dta b(155,0)
        jmp err2x

d1err   jmp dumpx

* LIST IT !
st10    jsr print
        dta b(155)
        dta c'BW-DOS Mini-Disassembler by BEWESOFT'
        dta b(155,155,0)

* GET
dump1   lda #0
        sta lpos
        lda pos+2
        jsr dprthx
        lda pos+1
        jsr dprthx
        lda pos
        jsr dprthx
        jsr dspac

* DATA
        jsr data1
        bmi d1err
        sta name
        tax
        lda adtab,x
        tax
        lda lentab,x
        tax
        dex
        beq dump2
        dex
        txa
        pha
        jsr data1
        bmi d1err
        sta name+1
        pla
        beq dump2
        jsr data1
        bmi d1err
        sta name+2

* MOVE
dump2   lda lpos
        cmp #18
        bcs dump4
        jsr dspac
        jmp dump2

* INSTRUCTION
dump4   ldx name
        lda nmtab,x
        asl @
        adc nmtab,x
        tax
        lda nmtxt+2,x
        pha
        lda nmtxt+1,x
        pha
        lda nmtxt,x
        jsr dprt1
        pla
        jsr dprt1
        pla
        jsr dprt1
        jsr dspac

* OPERAND
        ldx name
        lda adtab,x
        asl @
        asl @
        pha
        tax
        lda adtxt,x
        jsr dprt1
        pla
        pha
        lsr @
        lsr @
        cmp #8
        bne dump4b

* BRANCH
        lda name+1
        bmi dump4mi

        pha
        lda #'+'
        jsr dprt1
        pla

        clc
        adc #2
        jmp dump4pm

dump4mi pha
        lda #'-'
        jsr dprt1
        pla

        eor #$ff
        sec
        sbc #1

dump4pm jsr dolar
        jmp dump4c

* ADR

dump4b  tax
        lda lentab,x
        tax
        dex
        beq dump4d

        txa
        jsr dolar
        tax

        dex
        beq dump4bb

        lda name+2
        jsr dprthx

dump4bb lda name+1
dump4c  jsr dprthx

dump4d  pla
        tax

        lda adtxt+3,x
        pha
        lda adtxt+2,x
        pha
        lda adtxt+1,x

        jsr dprt1
        pla
        jsr dprt1
        pla
        jsr dprt1

* EOL

        jsr prteol

* NEXT?
dumpx   lda status
        bmi dumpx2

        lda 764
        cmp #$1c
        beq desc

        jmp dump1

dumpx2  cmp #136
        beq dumpx3

        jsr print
        dta b(155)
        dta c'Error reading file!'
        dta b(155,0)
        jmp err2x

desc    lda #$ff
        sta 764

        jsr print
        dta b(155)
        dta c'<Aborted>'
        dta b(155,0)
dumpx3  jmp     err2

data1   ldx #$10
        lda #7
        sta $342,x

        lda #0
        sta $348,x
        sta $349,x

        jsr $e456
        sty status

        bmi data1er

        inc pos
        bne data1c
        inc pos+1
        bne data1c
        inc pos+2

data1c  pha
        jsr dspac
        pla
        pha
        jsr dprthx
        pla

        ldy #1
        rts

data1er cpy #136
        bne d1erx

        jsr print
        dta c' <EOF>'
        dta b(155,0)

d1erx   ldy status
        rts

dolar   pha

        lda #'$'
        jsr dprt1

        pla

        rts

dprthx  pha
        lsr @
        lsr @
        lsr @
        lsr @
        jsr dprthx2
        pla

dprthx2 and #15
        clc
        adc #$30
        cmp #$3a
        bcc dprt1

        adc #6

        dta b($2c)
dspac   lda #' '

dprt1   tay
        beq dprt1ex

        inc lpos
        jmp prt1

dprt1ex rts


nmtab dta b(10,34,56,56,56,34,2,56)
 dta b(36,34,2,56,56,34,2,56)
 dta b(9,34,56,56,56,34,2,56)
 dta b(13,34,56,56,56,34,2,56)
 dta b(28,1,56,56,6,1,39,56)
 dta b(38,1,39,56,6,1,39,56)
 dta b(7,1,56,56,56,1,39,56)
 dta b(44,1,56,56,56,1,39,56)

 dta b(41,23,56,56,56,23,32,56)
 dta b(35,23,32,56,27,23,32,56)
 dta b(11,23,56,56,56,23,32,56)
 dta b(15,23,56,56,56,23,32,56)
 dta b(42,0,56,56,56,0,40,56)
 dta b(37,0,40,56,27,0,40,56)
 dta b(12,0,56,56,56,0,40,56)
 dta b(46,0,56,56,56,0,40,56)

 dta b(56,47,56,56,49,47,48,56)
 dta b(22,56,53,56,49,47,48,56)
 dta b(3,47,56,56,49,47,48,56)
 dta b(55,47,54,56,56,47,56,56)
 dta b(31,29,30,56,31,29,30,56)
 dta b(51,29,50,56,31,29,30,56)
 dta b(4,29,56,56,31,29,30,56)
 dta b(16,29,52,56,31,29,30,56)

 dta b(19,17,56,56,19,17,20,56)
 dta b(26,17,21,56,19,17,20,56)
 dta b(8,17,56,56,56,17,20,56)
 dta b(14,17,56,56,56,17,20,56)
 dta b(18,43,56,56,18,43,24,56)
 dta b(25,43,33,56,18,43,24,56)
 dta b(5,43,56,56,56,43,24,56)
 dta b(45,43,56,56,56,43,24,56)


adtab dta b(9,4,9,9,9,6,6,9)
 dta b(9,3,9,9,9,0,0,9)
 dta b(8,5,9,9,9,7,7,9)
 dta b(9,2,9,9,9,1,1,9)
 dta b(0,4,9,9,6,6,6,9)
 dta b(9,3,9,9,0,0,0,9)
 dta b(8,5,9,9,9,7,7,9)
 dta b(9,2,9,9,9,1,1,9)

 dta b(9,4,9,9,9,6,6,9)
 dta b(9,3,9,9,0,0,0,9)
 dta b(8,5,9,9,9,7,7,9)
 dta b(9,2,9,9,9,1,1,9)
 dta b(9,4,9,9,9,6,6,9)
 dta b(9,3,9,9,10,0,0,9)
 dta b(8,5,9,9,9,7,7,9)
 dta b(9,2,9,9,9,1,1,9)

 dta b(9,4,9,9,6,6,6,9)
 dta b(9,9,9,9,0,0,0,9)
 dta b(8,5,9,9,7,7,11,9)
 dta b(9,2,9,9,9,1,9,9)
 dta b(3,4,3,9,6,6,6,9)
 dta b(9,3,9,9,0,0,0,9)
 dta b(8,5,9,9,7,7,11,9)
 dta b(9,2,9,9,1,1,2,9)

 dta b(3,4,9,9,6,6,6,9)
 dta b(9,3,9,9,0,0,0,9)
 dta b(8,5,9,9,9,7,7,9)
 dta b(9,2,9,9,9,1,1,9)
 dta b(3,4,9,9,6,6,6,9)
 dta b(9,3,9,9,0,0,0,9)
 dta b(8,5,9,9,9,7,7,9)
 dta b(9,2,9,9,9,1,1,9)


nmtxt dta c'ADCANDASLBCCBCSBEQBITBMI'
 dta c'BNEBPLBRKBVCBVSCLCCLDCLI'
 dta c'CLVCMPCPXCPYDECDEXDEYEOR'
 dta c'INCINXINYJMPJSRLDALDXLDY'
 dta c'LSRNOPORAPHAPHPPLAPLPROL'
 dta c'RORRTIRTSSBCSECSEDSEISTA'
 dta c'STXSTYTAXTAYTSXTXATXSTYA'
 dta c'???'

adtxt  dta b(0,0,0,0)

       dta b(0)
       dta c',X'
       dta b(0)

       dta b(0)
       dta c',Y'
       dta b(0)

       dta c'#'
       dta b(0,0,0)

       dta c'(,X)'

       dta c'(),Y'

       dta b(0,0,0,0)

       dta b(0)
       dta c',X'
       dta b(0)

       dta c'*'
       dta b(0,0,0)

       dta b(0,0,0,0)

       dta c'()'
       dta b(0,0)

       dta b(0)
       dta c',Y'
       dta b(0)

lentab dta b(3,3,3,2,2,2,2,2)
       dta b(2,1,3,2)

name   equ *

       end
