* BW-DOS command FORMAT

        icl '_SYSEQU.ICL'

pthlen  equ 128
dosix   equ 129
doslen  equ 130
dens    equ 132
hsflg   equ 133
zmapcnt equ 134
zusecnt equ 136
ztemp   equ 137
zpcnt   equ 138
ztempx  equ 139

buff    equ $400
nambuff equ $500

* subroutine block
        blk dos $2800
        icl '_TSTBW15.ICL'
        jmp start2

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

err5    jsr close

        jmp (10)

errtab  dta b(1,10,100)

close   ldx #$10
        lda #12
        sta $342,x
        jsr $e456
        bmi error

        rts

kname   dta c'K:'
        dta b(155)

getkey  jsr close

        ldx #$10
        lda #3
        sta $342,X

        lda <kname
        sta $344,X
        lda >kname
        sta $345,X

        lda #4
        sta $34a,X
        lda #0
        sta $34b,X

        jsr $e456

        ldx #$10
        lda #7
        sta $342,X

        lda #0
        sta $348,X
        sta $349,X

        jsr $e456
        bmi jabort ;check <BREAK>

        pha
        jsr close
        pla

        cmp #27 ;check <ESC>
        bne gprts

jabort  jmp abort

path    dta c'D0:>DOS>'

getpath ldy #0

gtpt2   lda path,y
        sta buff,y

        iny
        cpy pthlen
        bcc gtpt2

gprts   rts

getnme  ldx dosix
        dex

gtn1    inx
        txa
        and #15
        cmp #8
        bcs gtn2

        lda nambuff,x
        cmp #$20
        beq gtn2

        sta buff,y
        iny
        bne gtn1

gtn2    lda #'.'
        sta buff,y
        iny

        ldx #7

gtn3    inx
        txa
        and #15
        cmp #11
        bcs gtn4

        lda nambuff,x
        cmp #$20
        beq gtn4

        sta buff,y
        iny
        bne gtn3

gtn4    lda #$9b
        sta buff,y

        rts

dosfltr dta b(155)
        dta c'SOD.*'

srchdos jsr close

        jsr getpath
        ldx #5
srd2    lda dosfltr,x
        sta buff,y
        iny
        dex
        bpl srd2

* OPEN DIR

        ldx #$10
        lda #3
        sta $342,x

        lda #6
        sta $34a,x
        lda #0
        sta $34b,x

        jsr ciobuff
        bmi dirend

srd3    ldx #$10
        lda #5
        sta $342,x

        lda <buff+64
        sta $344,x
        lda >buff+64
        sta $345,x

        lda #64
        sta $348,x
        lda #0
        sta $349,x

        jsr $e456
        bmi dirend
*
        lda buff+64
        cmp #$30
        bcs dirend

        lda buff+74
        bmi srd3
*
        ldx dosix
        cpx #$90
        bcs srd3

        ldy #66

srd4    lda buff,y
        sta nambuff,x
        inx
        iny

        cpy #77
        bcc srd4

        lda pthlen
        sta nambuff,x

        lda dosix
        clc
        adc #16
        sta dosix

        jmp srd3

dirend  jmp close

abort   jsr close

        jsr print
        dta b(155)
        dta c'Operation aborted.'
        DTA b(155,0)

        jmp err5x

yesno   jsr print
        dta c' (Y/N)? '
        dta b(0)

yn1     jsr getkey
        and #$5f

        ldx #0
        cmp #'N'
        beq yn2

        ldx #128
        cmp #'Y'
        bne yn1

yn2     stx yn3+1

        jsr prt1
        lda #$9b
        jsr prt1

yn3     lda #0
        asl @

        rts

ciobuff lda <buff
        sta $344,x
        lda >buff
        sta $345,x

        jmp $e456


* print decimals
prndca  ldx #$00
prndcax ldy #$00
        sta BW_DECIN,Y
        iny
        txa
        sta BW_DECIN,Y
        iny
        lda #$00
        sta BW_DECIN,Y
        jsr CONVDC
        ldy #$00
        sty zpcnt
nxtdig  lda BW_DECOUT,Y
        cmp #' '
        beq isspc
        jsr prt1
isspc   inc zpcnt
        ldy zpcnt
        cpy #8
        bne nxtdig
        rts
CONVDC  jmp (BW_CONVDC)

prnside jsr print
        dta b($9b)
        dta c' Num of sides: '
        dta b($00)
        rts

prntrck jsr print
        dta b($9b)
        dta c'  Tracks/side: '
        dta b($00)
        rts

prnsecs jsr print
        dta b($9b)
        dta c'Sectors/track: '
        dta b($00)
        rts

prnbyte jsr print
        dta b($9b)
        dta c' Bytes/sector: '
        dta b($00)
        rts

prnstep jsr print
        dta b($9b)
        dta c'Stepping rate: '
        dta b($00)
        rts

prnflag jsr print
        dta b($9b)
        dta c'  Flag FM/MFM: '
        dta b($00)
        rts

* print configuration
prnconf jsr prnside
        ldx buff+4
        inx
        txa
        jsr prndca

        jsr prntrck
        lda buff
        jsr prndca

        jsr prnsecs
        ldx buff+2
        lda buff+3
        jsr prndcax

        jsr prnbyte
        ldx buff+6
        lda buff+7
        jsr prndcax

        jsr prnstep
        lda buff+1
        jsr prndca

        jsr prnflag
        lda buff+5
        jsr prndca

        lda #$9b
        jsr prt1
        rts

* get number
* A/X 16bit, Y 0=16bit 1=8bit
getnu   sty zpcnt
        sta BW_DECIN
        stx BW_DECIN+1
        lda #$00
        sta BW_DECIN+2

* conv hex -> char
        jsr convhc
* print char and calc length
        ldx #0
        stx ztemp
getnu1  lda BW_DECOUT+3,X
        cmp #' '
        beq getnu2
        stx ztempx
        jsr prt1
        ldx ztempx
        inc ztemp
getnu2  inx
        cpx #5
        bcc getnu1
* edit
getnua  jsr getkey
        cmp #$9b ;return
        beq getnur
        cmp #$7e ;delete
        beq getnud
        cmp #$9c ;delete line
        beq getnul
        cmp #'0'
        bcc getnua
        cmp #'9'+1
        bcs getnua

* key 0-9
        ldx ztemp
        cpx #5
        bcs getnua
        inx
        stx ztemp

        pha
        ldy #0
getnu09 lda BW_DECOUT+1,Y
        sta BW_DECOUT,Y
        iny
        cpy #7
        bcc getnu09
        pla
        sta BW_DECOUT+7

        jsr prt1

        jsr convch
        ldx zpcnt
        lda BW_DECIN,X
        beq getnua
        lda #$7e

* delete
getnud  ldx ztemp
        beq getnua
        dex
        stx ztemp

        jsr prt1

        ldy #7
getnudl lda BW_DECOUT-1,Y
        sta BW_DECOUT,Y
        dey
        bne getnudl
        lda #' '
        sta BW_DECOUT
        bne getnua

* delete line
getnul  ldx ztemp
        beq getnua

        lda #$7e
        jsr prt1
        dec ztemp
        bne *-7

        ldx #7
        lda #' '
        sta BW_DECOUT,X
        dex
        bpl *-4
        bmi getnua

* return
getnur  jsr convch
        rts

* convert hex to char
convhc  jmp (BW_CONVDC)

* convert char to hex
convch  ldx #2
        lda #0
        sta BW_DECIN,X
        dex
        bpl *-4

        ldx #4
convch1 lda BW_DECOUT+3,X
        cmp #' '
        beq convch2
        and #$0F
        tay
        beq convch2

convch3 clc
        lda BW_DECIN
        adc CDT1,X
        sta BW_DECIN
        lda BW_DECIN+1
        adc CDT2,X
        sta BW_DECIN+1
        lda BW_DECIN+2
        adc #0
        sta BW_DECIN+2

        dey
        bne convch3

convch2 dex
        bpl convch1
        rts

CDT2    dta b($27,$03,$00,$00,$00)
CDT1    dta b($10,$E8,100,10,1)

* get configuration
getconf jsr prnside
        ldx buff+4
        inx
        txa
        ldx #0
        ldy #1
        jsr getnu
        ldx BW_DECIN
        dex
        stx buff+4

        jsr prntrck
        lda buff
        ldx #0
        ldy #1
        jsr getnu
        lda BW_DECIN
        sta buff

        jsr prnsecs
        ldx buff+2
        lda buff+3
        ldy #2
        jsr getnu
        lda BW_DECIN
        sta buff+3
        lda BW_DECIN+1
        sta buff+2

        jsr prnbyte
        ldx buff+6
        lda buff+7
        ldy #2
        jsr getnu
        lda BW_DECIN
        sta buff+7
        lda BW_DECIN+1
        sta buff+6

        jsr prnstep
        lda buff+1
        ldx #0
        ldy #1
        jsr getnu
        lda BW_DECIN
        sta buff+1

        jsr prnflag
        lda buff+5
        ldx #0
        ldy #1
        jsr getnu
        lda BW_DECIN
        sta buff+5

        lda #$9b
        jsr prt1

        rts

* get configuratin from boot sector for slot 4
getbcf4 ldx #$08
* check boot sector for SDFS
bootchk lda buff,X
        cmp booter,X
        beq *+5
        jmp baddns2
        dex
        bpl bootchk
* bytes per sector
        ldx #$00
        lda buff+31
        sta ftbsl+4
        bne *+3
        inx
        stx ftbsh+4
* no more than 256 bytes per sector
        lda buff+31
        and #$7F
        beq *+5
        jmp baddns2

* sides and tracks
        lda buff+30
        and #$80
        asl @
        rol @
        sta ftside+4
        lda buff+30
        and #$7F
        sta fttrks+4

* total sector count
        lda buff+11
        sta fttotal+8
        lda buff+12
        sta fttotal+9

        jmp only1s

* get configuratin from Conf Block for slot 4
getcnf4 lda buff+7
* bytes per sector
        sta ftbsl+4
        lda buff+6
        sta ftbsh+4
* no more than 256 bytes per sector
        cmp #$02
        bcc *+5
        jmp baddns2

* sides and tracks
        lda buff+4
        sta ftside+4
        lsr @
        ror @
        ora buff
        sta fttrks+4

* total sector count
        lda #$00
        sta fttotal+8
        sta fttotal+9
        ldx buff
adsctrl clc
        lda buff+3
        adc fttotal+8
        sta fttotal+8
        lda buff+2
        adc fttotal+9
        sta fttotal+9
        dex
        bne adsctrl

        lda ftside+4
        beq only1s
        asl fttotal+8
        rol fttotal+9

* bitmap sectors
only1s  lda fttotal+8
        sta zmapcnt
        lda fttotal+9
        sta zmapcnt+1

        lda zmapcnt
        bne *+4
        dec zmapcnt+1
        dec zmapcnt

        ldx #10
        lda ftbsh+4
        beq *+3
        inx

mapcntl lsr zmapcnt+1
        ror zmapcnt
        dex
        bne mapcntl

        ldx zmapcnt
        inx
        stx ftmaps+4

* main map sector
        clc
        lda ftmaps+4
        adc #$04
        sta ftmain+4

* free sector count
        clc
        lda #$06
        adc ftmaps+4
        sta zusecnt

        sec
        lda fttotal+8
        sbc zusecnt
        sta ftfree+8
        lda fttotal+9
        sbc #$00
        sta ftfree+9

* bitmap start and end

* use index
        lda zusecnt
        lsr @
        lsr @
        lsr @
        sta mapusex+4

* use byte
        lda #$FF
        sta ztemp
        lda zusecnt
        and #$07
        tax
        beq getmby2
getmby1 clc
        ror ztemp
        dex
        bne getmby1

getmby2 lda ztemp
        sta mapuseb+4

* free index
        lda fttotal+8
        sta zmapcnt
        lda fttotal+9
        sta zmapcnt+1

        ldx #3
shmpby  lsr zmapcnt+1
        ror zmapcnt
        dex
        bne shmpby

        lda zmapcnt
        ldy ftbsh+4
        bne no256sc
        and #$7F
no256sc sta mapfrex+4

* free byte
        lda #$00
        sta ztemp
        lda fttotal+8
        and #$07
        tax
        beq getmby4
getmby3 sec
        ror ztemp
        dex
        bne getmby3

getmby4 lda ztemp
        sta mapfreb+4

* check full bit map
        lda mapfrex+4
        ora mapfreb+4
        bne getmby5
        lda #$FF
        sta mapfrex+4
        sta mapfreb+4

getmby5 rts

getsion jsr sion
        bpl *+5
        jmp wrber
        rts

******* BOOT SECTORS 3*128 bytes *******
        blk dos $3000
booter  dta b(0,3)
        dta a($3000,$7e0)
        jmp $3080
boomain dta a(0) ;sector number of main
boototl dta a(0) ;total sector count
boofree dta a(0) ;free sector count
boomcnt dta b(0) ;map sector count
boomap  dta a(4) ;sector number of map
boosfre dta a($1F) ;sector number start free search
boodfre dta a(4) ;sector number start free dir search
booname dta c"@@@@@@@@"
bootrck dta b(0) ;track count
booslen dta b(0) ;sector size

boofver dta b($20) ; file system version
        dta b(6,1,255,255,0)
booseq  dta b(0) ;sequence number
boornd  dta b(0) ;random number
booboo  dta a(0) ;boot file map sector
        dta b(0,0,0)
dtaix   dta b(0)
mapix   dta b(0,0)
        dta b(0)

*** loader
getlen  equ $43
gadr    jsr get1
        sta getadr
        jsr get1
        sta getadr+1

        and getadr
        cmp #$ff
        rts

read0f  ldx #$2f
read0   lda #0
read    stx sioadr+1
        sta sioadr

        ldx #9
read1   lda siotab,x
        sta $300,x
        dex
        bpl read1

        lda $30a
        ora $30b
        beq readerr

        jsr $e459
        bpl readrts

readerr lda $d301
        ora #1
        sta $d301

ssave   ldx #$ff
        txs

        sec
readrts rts

boorun  jmp ($2e0)
booini  jmp ($2e2)

siotab  dta b($31,1)
        dta c'R'
        dta b(64)
sioadr  dta a($2e00)
        dta b(7,0)

siolen  equ *
* 2 bytes will be overwritten
boostrt tsx
        stx ssave+1

        lda booslen
        and #128
        sta siolen
        sta mapix
        sta dtaix
        asl @
        rol @
        eor #1
        sta siolen+1
* XF DENSITY TEST
        inc $30a
        jsr read0f
* START
        jsr gadr
        bne readerr
        beq boost2

boost1  jsr booini

boost2  jsr gadr
        beq boost2

        lda getadr
        ora getadr+1
        beq boorun

        lda <readrts
        sta $2e2
        lda >readrts
        sta $2e3

        jsr get1
        sec
        sbc getadr
        pha
        php
        jsr get1
        plp
        sbc getadr+1
        sta getlen+1
        pla
        sta getlen

* LD BLOCK

boost3  jsr get
boost4  sta $ffff
getadr  equ boost4+1

        inc getadr
        bne boost5
        inc getadr+1

boost5  lda getlen
        bne boost6
        lda getlen+1
        beq boost1

        dec getlen+1
boost6  dec getlen

        jmp boost3

get1    lda #0
        sta getlen
        sta getlen+1

get     ldx dtaix
        cpx siolen
        beq get2

get1b   lda $2e00,x
        inx
        stx dtaix
        rts

getblok lda getadr
        ldx getadr+1
        jsr read

        lda getadr
        clc
        adc siolen
        sta getadr
        lda getadr+1
        adc siolen+1
        sta getadr+1

        lda getlen
        sec
        sbc siolen
        sta getlen
        lda getlen+1
        sbc siolen+1
        sta getlen+1

* next data

get2    ldy mapix
        cpy siolen
        bne get2b

* next map

        lda booboo
        sta $30a
        lda booboo+1
        sta $30b

        jsr read0f

        lda $2f00
        sta booboo
        lda $2f01
        sta booboo+1

        ldy #4

get2b   lda $2f00,y
        sta $30a
        lda $2f01,y
        sta $30b

        iny
        iny
        sty mapix

        lda getlen+1
        bne getblok

        lda siolen
        bpl get2c

        lda getlen
        bmi getblok

get2c   ldx #$2e
        jsr read0

        ldx #0
        jmp get1b

************** END BOOT SECTORS *******

* Search DOS

start2  jsr print
        dta b(155)
        dta c'BW-DOS Formatter 1.5'
        dta b(155,0)
* getpar
        lda 10
        clc
        adc #3
        sta getname+1
        lda 11
        adc #0
        sta getname+2
* sio
        lda 10
        sec
        sbc #10
        sta siojmp+1
        sta doslen
        lda 11
        sbc #0
        sta siojmp+2
        sta doslen+1

        ldy #8
        lda (doslen),y
        sta wrtcmd

        lda #0
        sta doslen
        sta doslen+1

        jsr getname
        ldy #34
        lda (10),y
        sta path+1

        lda #0
        sta dosix

        lda #8
        sta pthlen
        jsr srchdos

        lsr pthlen
        jsr srchdos

        lda dosix
        bne strt3

        jsr print
        dta b(155)
        dta c'No DOS-files found ...'
        dta b(155,0)
        jmp strt4

* DOS Menu

strt3   jsr print
        dta b(155)
        dta c'Select DOS:'
        DTA b(155,0)

        lda #0
        sta pthlen
        lda #$31
        sta strt3d

strt3b  ldx pthlen
        cpx dosix
        bcs strt3f

        ldy #0
strt3c  lda nambuff,x
        sta strt3e,y
        inx
        iny
        cpy #8
        bcc strt3c

        jsr print
        dta c'  '
strt3d  dta c'0) '
strt3e  dta c'FILENAME'
        dta b(155,0)

        lda pthlen
        clc
        adc #16
        sta pthlen

        inc strt3d

        jmp strt3b

strt3no jsr print
        dta c'N'
        dta b(155,0)

        jmp strt4

strt3f  jsr print
        dta c'  N) -No DOS-'
        dta b(155)
        dta c'Choice: '
        dta b(0)

strt3g  jsr getkey
        and #127
        tax

        cmp #'N'
        beq strt3no
        cmp #'n'
        beq strt3no

        sec
        sbc #$31
        cmp #9
        bcs strt3g

        asl @
        asl @
        asl @
        asl @
        cmp dosix
        bcs strt3g

* DOS select

        pha

        txa
        jsr prt1
        lda #$9b
        jsr prt1

        pla
        sta dosix

        tax
        lda nambuff+11,x
        sta pthlen
        jsr getpath
        jsr getnme

        jsr close

* open dos-file

        ldx #$10
        lda #3
        sta $342,x

        lda #4
        sta $34a,x
        lda #0
        sta $34b,x

        jsr ciobuff
        bmi rddoser
* read it
        ldx #$10
        lda #7
        sta $342,x

        lda <buffer
        sta $344,x
        lda >buffer
        sta $345,x

        lda $2e5
        sec
        sbc <buffer
        sta $348,x
        lda $2e6
        sbc >buffer
        sta $349,x

        jsr $e456
        bpl rddostl

        cpy #136
        beq strt3h

rddoser jsr print
        dta b(155)
        dta c'Cannot read DOS file!'
        dta b(0)
        jmp abort

rddostl jsr print
        dta b(155)
        dta c'DOS file too large!'
        dta b(0)
        jmp abort

strt3h  ldx #$10
        lda $348,x
        sta doslen
        lda $349,x
        sta doslen+1

        jsr close

* DOS loaded

strt4   jsr print
        dta b(155)
        dta c'Drive to format: '
        dta b(0)

strt4b  jsr getkey
        sec
        sbc #$30
        beq strt4b
        cmp #10
        bcs strt4b

        sta siodr1
        sta siodr2
        sta siodr3
        sta siodr4
        sta siodr5

        ora #$30
        sta path+1
        sta strt4l

        jsr prt1

        jsr print
        dta b(155,155)
        dta c'Select density:'
        dta b(155)
        dta c'  1) Single density'
        dta b(155)
        dta c'  2) Medium density'
        dta b(155)
        dta c'  3) Double density'
        dta b(155)
        dta c'  4) Double-sided Double density'
        dta b(155)
        dta c'  5) Reset File System'
        dta b(155)
        dta c'  6) Create File System'
        dta b(155)
        dta c'  7) Custom Configuration'
        dta b(155)
        dta c'Choice: '
        dta b(0)

strt4c  jsr getkey

        sec
        sbc #$31
        cmp #7
        bcs strt4c
        sta dens
        clc
        adc #$31

strt4c3 jsr prt1

        jsr print
        dta b(155,155)
        dta c'Volume name: '
        dta b(0)

        lda #0
        sta ztemp

strt4d  jsr getkey
        cmp #155
        beq strt4g
        cmp #126
        beq strt4f
        cmp #156
        beq strt4f3

        cmp #27
        bcc strt4e
        cmp #32
        bcc strt4d
        cmp #125
        bcc strt4e
        cmp #128
        bcc strt4d
        cmp #155
        bcc strt4e
        cmp #160
        bcc strt4d
        cmp #253
        bcs strt4d

strt4e  ldx ztemp
        cpx #8
        bcs strt4d
        sta booname,x

        inc ztemp
        bcc strt4f2

strt4f  ldx ztemp
        beq strt4d

        dec ztemp

strt4f2 jsr prt1
        jmp strt4d

strt4f3 ldx ztemp
        beq strt4d

        lda #126
        jsr prt1
        dec ztemp
        bne *-7

        jmp strt4d

strt4g  ldx ztemp

strt4h  cpx #8
        bcs strt4i

        lda #32
        sta booname,x
        inx
        bne strt4h


strt4i  lda #155
        jsr prt1

        lda dens
        cmp #$06
        bcc *+5
        jmp strt4cc
        cmp #$05
        bcc *+5
        jmp strt4o
        cmp #$04
        bcc *+5
        jmp strt4rd

        jsr print
        dta b(155)
        dta c'XF-551 High Speed'
        dta b(0)
        jsr yesno

        lda #0
        ror @
        sta hsflg

        jsr strt4q
        jsr print
        dta c'Format <RETURN> or Build Directory <B>'
        dta b(155,0)

        jsr getkey
        cmp #155
        beq strt4m
        and #$5f
        cmp #'B'
        beq strt4n

strt4m  jmp format1

strt4n  jmp form3

* custom configuration
strt4cc lda #$04
        sta dens
        lda #0
        sta hsflg

        jsr getsion
strt4c2 jsr getconf

* no more than 256 bytes per sector
        lda buff+6
        cmp #$02
        bcs form1bx

        jsr getcnf4

        jsr strt4q
        jsr print
        dta c'Format <RETURN> or Configure <C>'
        dta b(155,0)

        jsr getkey
        cmp #'C'
        beq strt4c2
        cmp #155
        bne strt4p

        jsr sioo
        bmi form1bx

* check configuration
* some drives are disturbed by read config
;        ldx #11
;form1bz lda buff,x
;        sta buff+64,x
;        dex
;        bpl form1bz
;
;        jsr sion
;        bmi form1bx
;
;        ldx #11
;form1by lda buff,x
;        cmp buff+64,x
;        bne form1bx
;        dex
;        bpl form1by

        jmp form2

form1bx jsr print
        dta b(155)
        dta c'Unsupported configuration!'
        dta b(155)
        dta c'Configure <C> or Abort <ESC>'
        dta b(155,0)
        jsr getkey
        cmp #'C'
        bne *-5
        jmp strt4c2

strt4ok jmp form1ba

strt4p  jmp abort

* build directory
strt4o  lda #$04
        sta dens
        jsr getsion
        jsr prnconf
        jsr prninit
        jsr getcnf4
        jmp form3

strt4q  jsr print
        dta b(155)
        dta c'Format drive '
strt4l  dta c'0,'
        dta b(155,0)
        rts

prninit jsr strt4q
        jsr print
        dta c'Initialize <RETURN>'
        dta b(155,0)
        jsr getkey
        cmp #155
        bne strt4p
        rts

* reset directory
strt4rd lda #$04
        sta dens
        jsr prninit
        jsr rd1boot
        jsr getbcf4
        jmp form3

sion    ldx #11
        dta b($2c)
sioo    ldx #23
        dta b($2c)
siowr   ldx #35
        dta b($2c)
sioform ldx #47
        dta b($2c)
siord   ldx #59

        ldy #11
sio1    lda siotabs,X
        sta $300,Y
        dex
        dey
        bpl sio1

siojmp  jmp ($fffe)

siotabs dta b($31)
siodr1  dta b(0)
        dta c'N'
        dta b(64)
        dta a(buff)
        dta b(7,0)
        dta a(12,1)

        dta b($31)
siodr2  dta b(0)
        dta c'O'
        dta b(128)
        dta a(buff)
        dta b(7,0)
        dta a(12,1)

        dta b($31)
siodr3  dta b(0)
wrtcmd  dta c'W'
        dta b(128)
        dta a(buff)
        dta b(7,0)
wrtlen  dta a(128)
wrtsect dta a(1)

        dta b($31)
siodr4  dta b(0)
formcmd dta c'!'
        dta b(64)
        dta a(buff)
        dta b(255,0)
formlen dta a(128,4)

        dta b($31)
siodr5  dta b(0)
        dta c'R'
        dta b(64)
        dta a(buff)
        dta b(7,0)
rdlen   dta a(128)
rdsect  dta a(1)

* Custom formatting
ftstrk  dta b(18,26,18,18,0)
ftside  dta b(0,0,0,1,0)
ftmodul dta b(0,4,4,4,4)

* initialization
ftbsh   dta b(0,0,1,1,0)
ftbsl   dta b(128,128,0,0,0)

ftmain  dta b(5,6,5,5,0)

fttotal dta a(720,1040,720,1440,0)
ftfree  dta a(713,1032,713,1433,0)

ftmaps  dta b(1,2,1,1,0)
fttrks  dta b(40,40,40,40+128,0)

* bit map use and free
mapusex dta b(0,1,0,0,0)
mapuseb dta b(1,255,1,1,0)
mapfrex dta b(89,1,89,179,0)
mapfreb dta b(255,255,255,255,0)

formmedj jmp formmed

format1 ldx dens
        dex
        beq formmedj

        jsr sion
        bmi formncf

        ldx dens

        lda #40
        sta buff
        lda #0
        sta buff+2
        lda ftstrk,X
        sta buff+3
        lda ftside,X
        sta buff+4
        lda ftmodul,X
        sta buff+5
        lda ftbsh,X
        sta buff+6
        lda ftbsl,X
        sta buff+7

        jsr sioo
        bmi baddns

form1ba ldx #11
form1b  lda buff,x
        sta buff+64,x
        dex
        bpl form1b

        jsr sion
        bmi baddns

        ldx #11
form1bb lda buff,x
        cmp buff+64,x
        bne baddns
        dex
        bpl form1bb
        bmi form2

* adjust density

baddns  ldx dens
        dex
        beq formncf

baddns2 jsr print
        dta b(155)
        dta c'Cannot format, unsupported format!'
        dta b(0)
        jmp abort

* Drive not configurable

formncf ldx dens
        cpx #1
        bcc form2
        bne baddns2

formmed lda #$22
        dta b($2c)
form2   lda #$21

        ora hsflg
        sta formcmd

        ldx dens
        lda ftbsl,x
        sta formlen
        lda ftbsh,x
        sta formlen+1

form2b  jsr print
        dta b(155)
        DTA c'Formatting ... '
        DTA b(0)

        jsr sioform
        bpl form23j

        jsr print
        dta b(155,253)
        DTA c'Error during formatting!'
        DTA b(155)
        DTA c'Try again'
        DTA b(0)
        jsr yesno
        bcs form2b

        jmp abort

form23j jmp form3

wrtboo  sta wrtb2+1
        stx wrtb2+2

        ldx #127
wrtb2   lda $ffff,x
        sta buff,x
        dex
        bpl wrtb2

wrtbo2  jsr siowr
        bmi wrber

        inc wrtsect

        rts

wrber   jsr print
        dta b(155,253)
        dta c'Cannot create directory!'
        dta b(0)
        jmp abort

clbufff lda #255
        bne clbf1
clbuf   lda #0
clbf1   ldx #0
clbf2   sta buff,x
        dex
        bne clbf2
        rts

mainvz  DTA b($28,0,0,23,0,0)
        DTA c'MAIN       '

* Formatted successfully

* boot sector

form3   jsr print
        dta b(155)
        DTA c'Building Directory ... '
        DTA b(0)

        ldx dens

        lda ftbsl,X
        sta rdlen

        lda ftbsh,X
        sta rdlen+1

        lda #4
        sta rdsect
        lda #0
        sta rdsect+1
        jsr siord

        ldx dens
        lda ftmain,X
        sta boomain
        lda #0
        sta boomain+1

        lda ftmaps,X
        sta boomcnt

        clc
        adc boosfre
        sta boosfre

        lda fttrks,X
        sta bootrck

        lda ftbsl,X
        sta booslen

        txa
        asl @
        tax

        lda fttotal,X
        sta boototl
        lda fttotal+1,X
        sta boototl+1

        lda ftfree,X
        sta boofree
        lda ftfree+1,X
        sta boofree+1

        lda $d20a
        sta boornd

        lda #128
        sta wrtlen
        asl @
        sta wrtlen+1
        sta wrtsect+1
        rol @
        sta wrtsect

        lda <booter
        ldx >booter
        jsr wrtboo

        lda <booter+128
        ldx >booter+128
        jsr wrtboo

        lda <booter+256
        ldx >booter+256
        jsr wrtboo

* MAP
        jsr clbufff
* bytes per sectors
        ldx dens
        lda ftbsl,X
        sta wrtlen
        lda ftbsh,X
        sta wrtlen+1
* set bit map counter
        lda ftmaps,X
        sta zmapcnt
* bit map starts at sector 4
        lda #4
        sta wrtsect
        ldy #0
        sty wrtsect+1
* first map, mark used
        lda mapusex,X
        sta ztemp
        tya
form3b  cpy ztemp
        beq form3a
        sta buff,Y
        iny
        jmp form3b
form3a  lda mapuseb,X
        sta buff,Y
* check for just one bit map sector
        dec zmapcnt
        beq form3b1
        jsr wrtbo2
        jsr clbufff
* write completely free bit map sectors
form3b3 lda zmapcnt
        cmp #1
        beq form3b1
        jsr wrtbo2
        dec zmapcnt
        jmp form3b3
* last map, mark non existing as used
form3b1 ldx dens
        ldy mapfrex,X
        lda mapfreb,X
        sta buff,Y
        iny
        beq form3b4
        lda #0
form3b2 sta buff,Y
        iny
        bne form3b2
form3b4 jsr wrtbo2

* MAIN

form3c  jsr clbuf

        ldx wrtsect
        inx
        stx buff+4

        jsr wrtbo2

        jsr clbuf

        ldx #16
form3d  lda mainvz,x
        sta buff,x
        dex
        bpl form3d

        jsr wrtbo2

* Format done

        lda doslen
        ora doslen+1
        bne form5
        jmp form6

* Write DOS

form5   jsr print
        dta b(155)
        dta c'Writting DOS ... '
        dta b(0)

        lda #7
        sta pthlen
        jsr getpath

        lda #$9b
        sta buff,y

* Create directory >DOS

        jsr close

        ldx #$10
        lda #42
        sta $342,x

        jsr ciobuff
        bmi errorj

* Open

        inc pthlen
        jsr getpath
        jsr getnme

        jsr close

        ldx #$10
        lda #3
        sta $342,x

        lda #8
        sta $34a,x
        lda #0
        sta $34b,x

        jsr ciobuff
        bpl form5b

errorj  jmp error

rd1boot lda #128
        sta wrtlen
        sta rdlen
        asl @
        sta wrtlen+1
        sta rdlen+1
        sta wrtsect+1
        sta rdsect+1
        rol @
        sta wrtsect
        sta rdsect

        jsr siord
        bmi errorj
        rts

form5b  ldx #$10
        lda #11
        sta $342,x

        lda <buffer
        sta $344,x
        lda >buffer
        sta $345,x

        lda doslen
        sta $348,x
        lda doslen+1
        sta $349,x

        jsr $e456
        bmi errorj

        jsr close

* Install into boot sector
        jsr rd1boot

        lda boosfre
        sta buff+40
        lda boosfre+1
        sta buff+41

        jsr siowr
        bmi errorj

* Done

form6   jsr print
        dta b(155)
        dta c'Disk initialized.'
        dta b(155,155)
        dta c'Format another'
        dta b(0)

        jsr yesno
        bcc form6b

        jmp strt4

form6b  jmp (10)

buffer  equ *

        end
