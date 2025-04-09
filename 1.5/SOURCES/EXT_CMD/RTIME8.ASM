* BW-DOS command RTIME8.SYS [/R]

        icl '_SYSEQU.ICL'

srchadr equ 128
relzp   equ 130
redflg  equ 132
tcnt    equ 134
ttmp    equ 135
rt8tp   equ 138

port    equ $d5b8
cnt     equ $31     ;sio check
tmp     equ $30     ;sio status
tmp2    equ $32     ;sio adr.
cnt2    equ $33     ;---"---

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

getname jmp prtex

start   equ *
        icl '_TSTBW15.ICL'

        lda 10
        clc
        adc #3
        sta getname+1
        lda 11
        adc #0
        sta getname+2
        jsr getname

        ldy #36
        lda (10),y
        cmp #'O'
        bne st2on
* OFF?
        iny
        lda (10),y
        cmp #'F'
        bne syntax

        iny
        cmp (10),y
        bne syntax

        iny
        lda (10),y
        cmp #$9b
        bne syntax
        jmp disable
* ON?
st2on   ldx #0

        cmp #'/'
        bne st2o2

        inx

        iny
        lda (10),y
        cmp #'R'
        bne syntax

        iny
        lda (10),y

st2o2   cmp #$9b
        beq start3

syntax  jsr print
        dta b(155)
        dta c'Syntax: RTIME8 [/R]'
        dta b(155)
        dta c'        RTIME8 OFF'
        dta b(155,0)

        JMP (10)

* alread installed ?

start3  stx redflg

        jsr srchrut
        bcc start4
* yes!
        jsr print
        dta b(155)
        dta c'RTIME8 driver already installed !'
        dta b(155,0)
        jmp (10)

* install

start4  jsr rt8test
        bcs start4a

* no RTC8
        jsr print
        dta b(155)
        dta c'RTIME8 cartridge not installed !'
        dta b(155,0)
        jmp (10)

start4a ldx redflg

        lda 743
        sta srchadr
        clc
        adc reslent,x
        sta 743
        sta r01+1

        lda 744
        sta srchadr+1
        adc #0
        sta 744
        sta r02+1
* relok

rlk0    ldx #0

rlk1    lda relokt,x
        sta relzp
        lda relokt+1,x
        sta relzp+1

        ora relzp
        beq instal2

        lda relokt+2,x
        sec
        sbc <resid
        tay
        lda relokt+3,x
        sbc >resid
        pha

        tya
        ldy #1

        clc
        adc srchadr
        sta (relzp),y
        iny
        pla
        adc srchadr+1
        sta (relzp),y

        inx
        inx
        inx
        inx

        jmp rlk1

instal2 lda 10
        clc
        adc #13
        tay
        lda 11
        adc #0
        tax

        sty xtra2+1
        stx xtra2+2

        iny
        bne inst2xa
        inx

inst2xa sty xtra3+1
        stx xtra3+2

        iny
        bne inst2xb
        inx

inst2xb sty xtra1+1
        stx xtra1+2

* flag mode

        ldx redflg
        dex
        stx wait+1

        ldx #3

inst2b  lda $706,x
        sta oldadr,x
        dex
        bpl inst2b

        ldx redflg
        ldy reslent,x

instl2  dey
        lda resid,y
        sta (srchadr),y

        tya
        bne instl2

        ldy #2
instl3  lda 11,y
        sta (srchadr),y

        lda srchadr-1,y
        sta 11,y

        dey
        bne instl3

        ldx #1
        ldy #3

        lda redflg
        beq instl4
        ldy #5

instl4  lda newadr,x
        sta $706,x
        lda newadr,y
        sta $708,x
        dey
        dex
        bpl instl4

        jsr print
        dta b(155)
        dta c'RTIME8 driver installed'
        dta b(0)

        lda redflg
        beq instl5

        jsr print
        dta c' (read-only)'
        dta b(0)

instl5  jsr print
        dta c'.',b(155,0)
        jmp (10)

disable jsr srchrut
        sta redflg
        bcs disab2

        jsr print
        dta b(155)
        dta c'RTIME8 driver not installed!'
        dta b(155,0)

        jmp diserr2

discant jsr print
        dta b(155)
        dta c'RTIME8 driver is not the last'
        dta b(155)
        dta c'installed driver!'
        dta b(155,0)

diserr2 jsr print
        dta c'Can''t remove.'
        dta b(155,0)

        jmp (10)

disab2  lda 743
        sec
        sbc srchadr
        tay
        lda 744
        sbc srchadr+1
        bne discant

        tya
        ldx redflg
        cmp reslent,x
        bne discant

* remove
        ldy #2

disbl2  lda (srchadr),y
        sta 11,y

        lda srchadr-1,y
        sta 743-1,y

        dey
        bne disbl2

        ldy <oldadr-resid
        ldx #0

disabl3 lda (srchadr),y
        sta $706,x

        iny
        inx
        cpx #4
        bcc disabl3

        jsr print
        dta b(155)
        dta c'RTIME8 driver removed.'
        dta b(155,0)

        jmp (10)

srchrut lda 743
        sec
        sbc reslent+1
        sta srchadr
        lda 744
        sbc #0
        sta srchadr+1

srchr1  ldy <s1-resid

srchr2  lda (srchadr),y
        cmp resid,y
        bne srchnxt

        dey
        cpy <tst1-resid
        bne srchr2

        ldy <gtd2-resid

srchr3  lda (srchadr),y
        cmp resid,y
        bne srchnxt

        dey
        cpy <rdr7-resid
        bne srchr3

        ldy <wt3-resid

srchr4  lda (srchadr),y
        cmp resid,y
        bne srchnxt

        dey
        cpy <tst2-resid
        bne srchr4

        ldy <wait+1-resid
        lda (srchadr),y
        clc
        adc #1

        sec
        rts


srchnxt lda srchadr
        bne snxt2
        dec srchadr+1
snxt2   dec srchadr

        lda srchadr+1
        cmp BW_SMEMLO+1
        bcc snxt3
        bne srchr1
        lda srchadr
        cmp BW_SMEMLO
        bcs srchr1

snxt3   rts

* test RTIME8 installed

rt8tl   dta b(0,0,0,1,1,0,1)
rt8th   dta b(60,60,24,32,13,100,8)

*

rt8test lda #6
        sta rt8tp

rt8t2   ldx rt8tp
        jsr trdreg

        ldx rt8tp
        cmp rt8tl,x
        bcc rt8ter
        cmp rt8th,x
        bcs rt8ter

        dec rt8tp
        bpl rt8t2

        sec
        rts

rt8ter  clc
        rts

trdreg  sec
        ror tcnt

trdr2   dec tcnt
        beq trdret

        jsr trdr4
        sta ttmp
        jsr trdr4
        cmp ttmp
        bne trdr2

trdret  rts

trdr4   jsr twait

        stx port

        jsr tget15
        tay

        jsr tget15

trdr7   dey
        bmi trdret

        clc
        adc #10
        bcc trdr7

twait   ldy #0

twt2    dey
        beq twt3

        jsr tget15
        bne twt2

*       rts omitted

tget15  lda port
        and #15

twt3    rts

* relocate part

resid   jsr $ffff

r01     lda #$22
        sta 743
r02     lda #$22
tst1    sta 744

        rts

gtdtb   dta b(18,17,16,13,14,15)

rdreg   sec
        ror cnt

rdr2    dec cnt
        beq rdret

s1      jsr rdr4
        sta tmp
s2      jsr rdr4
        cmp tmp
        bne rdr2

rdret   rts

oldadr  dta a(0,0)

rdr4    jsr wait

        stx port

s3      jsr get15
        tay

s4      jsr get15

rdr7    dey
        bmi rdret

        clc
        adc #10
        bcc rdr7

gettd   ldx #5

gtd2    jsr rdreg
s5      ldy gtdtb,x
        sta (10),y

        dex
        bpl gtd2

*       rts omitted

wait    ldy #0

wt2     dey
        beq wt3

s6      jsr get15
tst2    bne wt2

*       rts omitted

get15   lda port
        and #15

wt3     rts

* end gettd

std4t   dta b(0,3,3,6,1,4)
        dta b(6,2,5,0,3,5)

settd   ldx #5

std2    ldy gtdtb,x
        lda (10),y
s7      jsr wrreg

        dex
        bpl std2

* day of week

xtra1   lda $ffff

        sec
        sbc #84
        bcs std3
        adc #100

std3    sta cnt

        lsr @
        lsr @

        clc
        adc cnt
xtra2   adc $ffff

xtra3   ldx $ffff
s8      adc std4t-1,x

        tay

        lda cnt
        and #3
        bne std5
        cpx #3
        bcc std6

std5    iny

std6    tya

std7    sec
        sbc #7
        bcs std7
        adc #8

        ldx #6

wrreg   sta tmp2

        sec
        ror cnt2

wrrg1   lda tmp2
        ldy #255

wrrg2   iny
        sec
        sbc #10
        bcs wrrg2
        adc #10

        pha
        tya
        pha

s9      jsr wait

        pla
        stx port
        sta port
        pla
        sta port

s10     jsr rdreg
        cmp tmp2
        beq wrrg4

        dec cnt2
        bne wrrg1

wrrg4   rts

reslen1 equ std4t-resid
reslen2 equ *-resid

reslent dta l(reslen2,reslen1)

newadr  dta a(0,0,0)

relokt  dta a(s1,rdr4)
        dta a(s2,rdr4)
        dta a(rdr4,wait)
        dta a(s3,get15)
        dta a(s4,get15)
        dta a(gtd2,rdreg)
        dta a(s5,gtdtb)
        dta a(s6,get15)
        dta a(std2,gtdtb)
        dta a(s7,wrreg)
        dta a(s8,std4t-1)
        dta a(s9,wait)
        dta a(s10,rdreg)

        dta a(newadr-1,gettd)
        dta a(newadr+1,settd)
        dta a(newadr+3,rdret)

        dta a(0,0)

        end
