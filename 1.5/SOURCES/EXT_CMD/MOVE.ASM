* BW-DOS command MOVE file path

        icl '_SYSEQU.ICL'

namoffs equ 128
tmp     equ 129
emptypo equ 130
status  equ 132
filepos equ 133
sect1st equ 135
mainsec equ 137
mainsta equ 140
srcpos  equ 141
dstpos  equ 143
subd1st equ 145
movflg  equ 147
namiter equ 148

        blk dos $3000
        icl '_TSTBW15.ICL'

        lda #0
        sta quite

        jsr close

        ldx BW_BUFOFF
        lda BW_LBUF,X
        cmp #155
        bne strt

        jsr _print
        dta b($9B)
        dta c'MOVE for BW-DOS 1.5'
        dta b($9B)
        dta c'Use: MOVE [/Q] src [dst]'
        dta b($9B,$00)
        rts

strt    jsr BW_CRNAME
        lda BW_COMFNAM+3
        cmp #'/'
        bne strt1
        lda BW_COMFNAM+4
        cmp #'Q'
        bne parerr
        lda BW_COMFNAM+5
        cmp #155
        bne parerr

        jsr BW_CRNAME
        lda #1
        sta quite
        bne strt1

parerr  lda #156 ; Parameter error
        jmp (BW_FAIL)

strt1   jsr getpar

        jsr BW_CRNAME
        lda BW_COMFNAM
        cmp src
        beq strt2a
        jmp baddev

strt2a  lda BW_COMFNAM+1
        cmp src+1
        beq strt2b

* different drive
        lda #160 ; Drive number error
        jmp (BW_FAIL)

strt2b  lda #0
        sta movflg

movloop jsr getfltr

* search source
        ldy <src
        ldx >src
        lda #$14
        jsr open

        jsr gethead
        ldx #22
strt2c  lda dirbuf,x
        sta dir1hl,x
        dex
        bpl strt2c

        jsr search
        bpl strt2d

        lda movflg
        bne extok
        lda #170 ; File not found
        jmp (BW_FAIL)

extok   lda #155
        jsr _putc
        jmp (10) ; exit

* OK

strt2d  lda status
        sta mainsta
        lda emptypo
        sta srcpos
        lda emptypo+1
        sta srcpos+1

        lda dirbuf+1
        sta subd1st
        lda dirbuf+2
        sta subd1st+1

        ldx #10
strt2db lda dirbuf+6,X
        sta msk,x
        dex
        bpl strt2db

* destination

        jsr close

        ldx #0

strt3a  lda BW_COMFNAM,X
        sta dst,X
        inx
        cpx #28
        bcs strt3b
        cmp #155
        bne strt3a

        dex

strt3b  lda dst-1,x
        cmp #':'
        beq strt3c
        cmp #'<'
        beq strt3c
        cmp #'>'
        beq strt3c

        lda #'>'
        jsr strt3p

* add file name

strt3c  stx namiter
        ldy #0

strt3ca cpy #8
        bcs strt3cb

        lda dirbuf+6,y
        cmp #32
        beq strt3cb

        jsr strt3p
        iny
        bne strt3ca

strt3cb ldy #8
        lda dirbuf+6,y
        cmp #32
        beq strt3cd
        lda #'.'
        jsr strt3p

strt3cc cpy #11
        bcs strt3cd

        lda dirbuf+6,y
        cmp #32
        beq strt3cd

        jsr strt3p
        iny
        bne strt3cc

strt3cd lda #155
        jsr strt3p

        jmp strt4

strt3p  sta dst,x
        inx
        rts

* search in dest dir

strt4   ldy <dst
        ldx >dst
        lda #$14
        jsr open

        jsr gethead

        ldx #22
strt4ax lda dirbuf,x
        sta dir2hl,x
        dex
        bpl strt4ax

        ldx #22
strt4aa lda dirbuf,x
        cmp dir1hl,x
        bne strt4ab
        dex
        bpl strt4aa
* same dir
        lda #151 ; File already exits
        jmp (BW_FAIL)

strt4ab jsr search
        bmi strt5
* already exists
        lda #151 ; File already exits
        jmp (BW_FAIL)

* subdir?

strt5   lda emptypo
        sta dstpos
        lda emptypo+1
        sta dstpos+1
        bpl strt5aa

        lda #169 ; Directory is full
        jmp (BW_FAIL)

strt5aa jsr close

        lda mainsta
        bmi strt5a
        jmp strt6

* subdir -> build path

strt5a  jsr setsio

        lda #0
        tax
strt5b  sta pathbuf,x
        dex
        bne strt5b

        lda #155
        sta pathbuf
* main?
        lda dir2hl+1
        ora dir2hl+2
        bne strt5c
* main!
        lda mainsec
        sta sect1st
        lda mainsec+1
        sta sect1st+1
        jmp strt6

* no main

strt5c  ldx #22
strt5ca lda dir2hl,x
        sta secbuf,x
        dex
        bpl strt5ca

        ldx #10
strt5cb lda dir2hl+6,x
        sta msk,x
        dex
        bpl strt5cb

* put name/num

strt5d  lda secbuf+1
        ora secbuf+2
        bne strt5db
        jmp strt5j
* name
strt5db ldy #11
strt5e  dey
        cpy #7
        beq strt5f

        lda secbuf+6,y
        cmp #32
        beq strt5e

strt5eb lda secbuf+6,y
        jsr putname
        dey
        cpy #7
        bne strt5eb

        lda #'.'
        jsr putname

strt5f  ldy #8

strt5g  dey
        bmi strt5h

        lda secbuf+6,y
        cmp #32
        beq strt5g

strt5gb lda secbuf+6,y
        jsr putname
        dey
        bpl strt5gb

strt5h  lda #'>'
        jsr putname
* num
        lda secbuf+1
        cmp subd1st
        bne strt5i
        lda secbuf+2
        cmp subd1st+1
        bne strt5i

* no loop

looped  lda #151 ; File already exits
        jmp (BW_FAIL)

* next dir
strt5i  ldy secbuf+1
        ldx secbuf+2
        jsr rsect

        ldy secbuf+4
        ldx secbuf+5
        jsr rsect
        jmp strt5d

* end of path

strt5j  lda #':'
        jsr putname
        lda src+1
        jsr putname
        lda #'D'
        jsr putname

* search sect1st

        ldy <pathbuf
        ldx >pathbuf
        lda #$14
        jsr open

        jsr search
        bpl strt5k

* nothing found ???

divne   lda #148 ; Invalid disk format
        jmp (BW_FAIL)

strt5k  lda status
        bpl divne
* ok
        lda dirbuf+1
        sta sect1st
        lda dirbuf+2
        sta sect1st+1

        jsr close

* to be moved subdir is no superdir?

        lda subd1st
        cmp sect1st
        bne strt6
        lda subd1st+1
        cmp sect1st+1
        bne strt6
        jmp looped

* no subdir to move

* read source entry

strt6   ldy <src
        ldx >src
        lda #$1c
        jsr open

        jsr points
        jsr getdir

* "delete" it!

        lda dirbuf
        pha
        lda #$10
        sta dirbuf

        jsr points
        jsr putdir
        jsr close

        pla
        sta dirbuf

* save dest entry

        ldy <dst
        ldx >dst
        lda #$1c
        jsr open

        ldy dstpos
        ldx dstpos+1
        jsr point

        jsr putdir

        jsr close

* sub-dir

        lda mainsta
        bmi strt6b
        jmp strt6c

* save name

strt6b  ldx #22
strt6ba lda dirbuf,x
        sta secbuf,x
        dex
        bpl strt6ba
* open
        ldx #0
strt6baa lda dst,x
        cmp #$9b
        beq strt6bab
        inx
        cpx #35
        bcc strt6baa
        bcs strt6bbe

strt6bab sta dst+4,x
        lda #'>'
        sta dst,x
        lda #'*'
        sta dst+1,x
        sta dst+3,x
        lda #'.'
        sta dst+2,x

        ldy <dst
        ldx >dst
        lda #$1c
        jsr open
* read
        jsr gethead

* same name?

        ldx #10
strt6bb lda dirbuf+6,x
        cmp secbuf+6,x
        bne strt6bbe
        dex
        bpl strt6bb
        bmi strt6bc

strt6bbe jmp divne

strt6bc lda sect1st
        sta dirbuf+1
        lda sect1st+1
        sta dirbuf+2

        jsr point0
        jsr putdir
        jsr close

* done!

strt6c  lda quite
        bne nxtmov
        jsr _print
        dta b(155)
        dta c'Moving ',b(0)
        bpl *+5
        jmp cioerr

nxtnchr ldx namiter
        lda dst,X
        cmp #155
        beq nxtmov
        jsr _putc
        inc namiter
        bpl nxtnchr

nxtmov  sec
        rol movflg
        jmp movloop ; next

* subroutines

putname pha

        lda pathbuf+255
        bne pthtool

        ldx #255
putnm2  lda pathbuf-1,x
        sta pathbuf,x
        dex
        bne putnm2

        pla
        sta pathbuf

        rts

pthtool lda #150 ; Directory not found
        jmp (BW_FAIL)

setsio  lda #128
        sta seclen
        asl @
        sta seclen+1
        tax
        rol @
        tay
        jsr rsect

        lda secbuf+7
        cmp #$80
        bne setsioe

        lda secbuf+31
        sta seclen
        asl @
        bne setsioe
        rol @
        eor #1
        sta seclen+1

        lda secbuf+9
        sta mainsec
        lda secbuf+10
        sta mainsec+1

        rts

setsioe lda #148
        jmp (BW_FAIL)

rsect   sty secnum
        stx secnum+1

        ldx #11
rws2    lda rwsiot,x
        sta $300,x
        dex
        bpl rws2

        jsr BW_SIO

        tya
        bmi erjp2

        rts

erjp2   jmp (BW_FAIL)

baddev  lda #168 ; Command not implemented
        jmp (BW_FAIL)

getpar  ldx #0

        lda BW_COMFNAM+1
        and #15
        sta rwsdriv

        lda BW_COMFNAM
        cmp #'D'
        bne baddev

gtpar0  stx namoffs

gtpar1  lda BW_COMFNAM,x
        sta src,x

        inx

        cmp #':'
        beq gtpar0
        cmp #'>'
        beq gtpar0
        cmp #'<'
        beq gtpar0

        cmp #$9b
        bne gtpar1

        rts

getfltr ldx namoffs
        ldy #0

        lda #6
        sta tmp

        dex

dc1b1   inx

        lda src,x
        cmp #'*'
        beq dc1bhve

        cmp #'.'
        beq dc1btec

        cmp #'?'
        beq dc1bzn

        jsr jelipl
        bcs dc1bnep

dc1bzn  jsr dc1bput
        jmp dc1b1

dc1bput cpy #8
        bcc dc1bp2

        bit tmp
        bpl dc1bp1

        cpy #11
        bcc dc1bp2

dc1bp1  rts

dc1bp2  sta msk,y
        iny
        rts

dc1bhve lda #'?'
        jsr dc1bput
        bcc dc1bhve
        bcs dc1b1

dc1bnep sec
        ror tmp

dc1btec lda #$20
        jsr dc1bput
        bcc dc1btec

        ror tmp
        bcc dc1b1

        rts

close   ldx #$10

        lda #12
        jmp ciocmd

jelipl  cmp #'_'
        beq jlpp

        cmp #$30
        bcc jlpm
        cmp #$3a
        bcc jlpp
        cmp #$41
        bcc jlpm
        cmp #$5b
        bcs jlpm

jlpp    clc
        rts

jlpm    sec
        rts

open    pha
        tya
        pha
        txa
        pha

        jsr close

        ldx #$10
        pla
        sta $345,x
        pla
        sta $344,x
        pla
        sta $34a,x
        lda #0
        sta $34b,x

        lda #3

ciocmd  sta $342,x

cio     jsr $e456
        bpl gtdret

cioerr  tya
        jmp (BW_FAIL)

gethead jsr point0

getdir  lda #7
        dta b($2c)
putdir  lda #11

        ldx #$10
        sta $342,x

        lda <dirbuf
        sta $344,x
        lda >dirbuf
        sta $345,x
        lda #23
        sta $348,x
        lda #0
        sta $349,x

        jsr $e456
        bpl gtdret

        cpy #136
        bne cioerr

        tya
gtdret  rts

note    ldx #$10
        lda <src
        sta $344,x
        lda >src
        sta $345,x
        lda #38

        jsr ciocmd

        ldx #$10
        lda $34e,x
        bne noterr
        lda $34d,x
        bmi noterr
        sta filepos+1
        lda $34c,x
        sta filepos

        rts

noterr  lda #166
        jmp (BW_FAIL)

point0  ldy #0
        ldx #0
        beq point

points  ldy srcpos
        ldx srcpos+1

point   txa
        ldx #$10
        sta $34d,x
        tya
        sta $34c,x
        lda #0
        sta $34e,x

        lda <src
        sta $344,x
        lda >src
        sta $345,x

        lda #37
        jmp ciocmd

search  lda #0
        sta emptypo
        sta emptypo+1

srch1   jsr note

        jsr getdir
        bmi srch2
        lda dirbuf
        beq srch2

        and #8+16
        cmp #8
        bne srch3

        ldx #10
srch1b  lda msk,x
        cmp #'?'
        beq srch1c
        cmp dirbuf+6,x
        bne srch1
srch1c  dex
        bpl srch1b

        ldx #0
        lda dirbuf
        and #32
        beq srch1d
        dex
srch1d  stx status

        lda filepos
        sta emptypo
        lda filepos+1
        sta emptypo+1

        lda #0
        rts

srch3   jsr condep
        jmp srch1

srch2   jsr note
        jsr condep

        lda #255
        rts

condep  lda emptypo
        ora emptypo+1
        bne condepx

        lda filepos
        sta emptypo
        lda filepos+1
        sta emptypo+1

condepx rts

        icl '_PRINT.ICL'

rwsiot  dta b($31)
rwsdriv dta b(0,'R')
        dta b(64)
        dta a(secbuf)
        dta b(7,0)
seclen  dta a(128)
secnum  dta a(1)

quite   equ *
src     equ quite+1
msk     equ src+40
dst     equ msk+20
dirbuf  equ dst+50
secbuf  equ dirbuf+40
pathbuf equ secbuf+256
dir1hl  equ pathbuf+256
dir2hl  equ dir1hl+40

        end
