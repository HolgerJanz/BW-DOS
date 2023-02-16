* FujiNet FDSWAP Swap Drives
* 2023-02-01, ep
* based on a lot of works by Holger Janz
* v0004

        icl '_SYSEQU.ICL'
        icl '_FNEQU.ICL'

srcptr  equ $D4              ; FR0.0
dstptr  equ $D6              ; FR0.2

        blk dos $3000
        jsr _chksdos

* parse comand line
        jsr _lbinit
        jsr _lbtrim

        cmp #$9b             ; no parameters
        bne p1
        jmp prnhlp

p1      cmp #'/'
        bne p2
        jsr _lbget
        cmp #'?'
        beq *+5
        jmp parerr
        jmp prnman

p2      and #$DF
        cmp #'D'
        beq *+5
        jmp parerr
        jsr _lbget           ; should be drive number 1-8
        jsr chknum
        bcc *+5
        jmp parerr
        sta srcdrvid
        jsr _lbget
        cmp #':'
        beq *+5
        jmp parerr

        jsr _lbtrim
        and #$DF
        cmp #'D'
        beq *+5
        jmp parerr
        jsr _lbget           ; should be drive number 1-8
        jsr chknum
        bcc *+5
        jmp parerr
        sta dstdrvid
        jsr _lbget
        cmp #':'
        beq p3
        jmp parerr

* Parsing done, stupidity check
p3      lda srcdrvid         ; src must not equal dst
        cmp dstdrvid
        bne *+5
        jmp srceqdst

        lda srcdrvid         ; convert drive ID to LUN
        and #$0F
        sta srcdrvnr
        lda dstdrvid
        and #$0F
        sta dstdrvnr

        ldx <siorslt         ; FN CMD F2: read device slots
        ldy >siorslt
        jsr _dosio

        lda srcdrvid         ; calc addresses in F2 table for both drives
        jsr calcptr
        stx srcptr
        sty srcptr+1
        lda dstdrvid
        jsr calcptr
        stx dstptr
        sty dstptr+1

        lda #$FF             ; default ext drive status to offline
        sta srcdrvst
        sta dstdrvst

        ldy #$01
        lda (srcptr),y       ; get r/w flag
        sta srcdrvrw
        dey
        lda (srcptr),y       ; hslot# =$FF means empty
        sta srcdrvhs
        cmp #$FF
        bne p4
        jsr nofnsrc
        ldx <siorsta         ; if no drive on FN check for external drives
        ldy >siorsta
        lda srcdrvnr
        sta siorsta+1
        jsr dosio_v          ; SIO CMD $53 call without exit on error
        sta srcdrvst         ; will be set to success or timeout
        bmi p41
        jsr extsrc           ; external online drive found (e.g. real 1050)
        jmp p41

p4      jsr fnsrc
P41     ldy #$01             ; same checks for destination
        lda (dstptr),y
        sta dstdrvrw
        dey
        lda (dstptr),y
        sta dstdrvhs
        cmp #$FF
        bne p5
        jsr nofndst
        ldx <siorsta
        ldy >siorsta
        lda dstdrvnr
        sta siorsta+1
        jsr dosio_v
        sta dstdrvst
        bmi p51
        jsr extdst
        jmp p51

p5      jsr fndst
p51     lda srcdrvst         ; exit if external src or dst is online
        bmi p52
        jmp exit

p52     lda dstdrvst
        bmi p53
        jmp exit

p53     ldx srcdrvnr         ; FN CMD $FA: read source slot filename
        dex
        stx fgnmslt
        lda <src_fn
        sta fname
        lda >src_fn
        sta fname+1
        ldx <siogfnm
        ldy >siogfnm
        jsr _dosio

        ldx dstdrvnr         ; FN CMD $FA: read destination slot filename
        dex
        stx fgnmslt
        lda <dst_fn
        sta fname
        lda >dst_fn
        sta fname+1
        ldx <siogfnm
        ldy >siogfnm
        jsr _dosio

        ldy #37              ; swap contents in $F2 table
s1      lda (srcptr),y
        tax
        lda (dstptr),y
        sta (srcptr),y
        txa
        sta (dstptr),y
        dey
        bpl s1

* Move SRC (?) TO DST (?)

        lda srcdrvhs
        cmp #$FF
        bne x1
        ldx dstdrvnr         ; unmount dest if src was empty
        dex
        stx unmntsl
        ldx <sioumnt
        ldy >sioumnt
        jsr _dosio           ; E9 perform unmount
        ldx <siowdev
        ldy >siowdev
        jsr _dosio           ; F1 write device slots
        jmp x2

x1      nop
        lda srcdrvhs         ; F9 mount host slot
        sta hmntslt
        ldx <siohmnt
        ldy >siohmnt
        jsr _dosio

        ldx <siowdev         ; F1 write device slot
        ldy >siowdev
        jsr _dosio

        ldx dstdrvnr         ; E2 set file name for device slot
        dex
        stx fnamslt
        lda srcdrvhs
        asl @
        asl @
        asl @
        asl @
        ora srcdrvrw
        sta fnamsm
        lda <src_fn
        sta fnamew
        lda >src_fn
        sta fnamew+1
        ldx <siosfnm
        ldy >siosfnm
        jsr _dosio

        ldx dstdrvnr         ; F8 mount device slot
        dex
        stx dmntslt
        lda srcdrvrw
        sta dmntmod
        ldx <siodmnt
        ldy >siodmnt
        jsr _dosio

* MOVE DST (?) TO SRC (?)

x2      lda dstdrvhs
        cmp #$FF
        bne x3
        ldx srcdrvnr         ; unmount src if dest was empty
        dex
        stx unmntsl
        ldx <sioumnt
        ldy >sioumnt
        jsr _dosio           ; perform unmount
        ldx <siowdev
        ldy >siowdev
        jsr _dosio           ; F1 write device slots
        jmp x4

x3      nop
        lda dstdrvhs         ; F9 mount host slot
        sta hmntslt
        ldx <siohmnt
        ldy >siohmnt
        jsr _dosio

        ldx <siowdev         ; F1 write device slot
        ldy >siowdev
        jsr _dosio

        ldx srcdrvnr         ; E2 set file name for device slot
        dex
        stx fnamslt
        lda dstdrvhs
        asl @
        asl @
        asl @
        asl @
        ora dstdrvrw
        sta fnamsm
        lda <dst_fn
        sta fnamew
        lda >dst_fn
        sta fnamew+1
        ldx <siosfnm
        ldy >siosfnm
        jsr _dosio

        ldx srcdrvnr         ; F8 mount device slot
        dex
        stx dmntslt
        lda dstdrvrw
        sta dmntmod
        ldx <siodmnt
        ldy >siodmnt
        jsr _dosio

x4      nop
exit    rts                  ; PROGRAM NORMAL EXIT


* ------------- Subroutines and buffers below --------------


calcptr sec                  ; A must contain drive number
        sbc #$31
        asl @
        tax
        clc
        lda <dev_s
        adc devsptr,x
        pha
        inx
        lda >dev_s
        adc devsptr,x
        tay
        pla
        tax
        rts                  ; X,Y contain address

chknum  cmp #'1'
        bcc no_num
        cmp #'9'
        bcs no_num
        rts
no_num  sec
        rts

* set DCB and call SIO but do not exit on error
dosio_v stx dosio_a+1
        sty dosio_a+2
        ldx #$0b
dosio_a lda $FFFF,X
        sta DDEVIC,X
        dex
        bpl dosio_a
        jsr SD_SIO
        lda DSTATS
        rts


* Get SIO Status (CMD $53)
siorsta dta b($31,$FF)  ; SIO disk drive and drive number
        dta b($53)      ; Command READ STATUS
        dta b($40)      ; read data direction
        dta a($02EA)    ; address DVSTAT
        dta b($02)      ; timeout
        dta b($00)      ; unused
        dta a($0004)    ; xfer 4 bytes
        dta b($00)      ; AUX1
        dta b($00)      ; AUX2

* get file name for device slot
siogfnm dta b($70,$01)  ; FujiNet device and unit
        dta b($DA)      ; Command GET FILE NAME
        dta b($40)      ; status
fname   dta a($FFFF)    ; file name buffer
        dta b($10)      ; time out
        dta b($00)      ; unused
        dta a($0100)    ; 256 bytes
fgnmslt dta b($00)      ; slot number
        dta b($00)      ; AUX2

* set file name for device slot
siosfnm dta b($70,$01)  ; FujiNet device and unit
        dta b($E2)      ; Command SET FILE NAME
        dta b($80)      ; status
fnamew  dta a($FFFF)    ; file name buffer
        dta b($10)      ; time out
        dta b($00)      ; unused
        dta a($0100)    ; 256 bytes
fnamslt dta b($00)      ; slot number
fnamsm  dta b($00)      ; host slot bit 4-7, mode bit 0-3, AUX2

* unmount device slot
sioumnt dta b($70,$01)  ; FujiNet device and unit
        dta b($E9)      ; Command UMOUNT DEVICE SLOT
        dta b($00)      ; status
        dta a($0000)    ; unused
        dta b($10)      ; time out
        dta b($00)      ; unused
        dta a($0000)    ; unused
unmntsl dta b($00)      ; AUX1
        dta b($00)      ; AUX2

* write device slots
siowdev dta b($70,$01)  ; FujiNet device and unit
        dta b($F1)      ; Command WRITE DEVICE SLOTS
        dta b($80)      ; status
        dta a(dev_s)    ; device slots buffer
        dta b($10)      ; time out
        dta b($00)      ; unused
        dta a($0130)    ; 8 device slots
        dta b($00)      ; AUX1
        dta b($00)      ; AUX2

* read device slots
siorslt dta b($70,$01)  ; FujiNet device and unit
        dta b($F2)      ; Command READ DEVICE SLOTS
        dta b($40)      ; status
        dta a(dev_s)    ; device slots buffer
        dta b($10)      ; time out
        dta b($00)      ; unused
        dta a($0130)    ; buffer size
        dta b($00)      ; AUX1
        dta b($00)      ; AUX2

* mount disk slot
siodmnt dta b($70,$01)  ; FujiNet device and unit
        dta b($F8)      ; Command MOUNT DISK SLOT
        dta b($00)      ; status
        dta a($0000)    ; unused
        dta b($10)      ; time out
        dta b($00)      ; unused
        dta a($0000)    ; unused
dmntslt dta b($00)      ; disk slot
dmntmod dta b($00)      ; mode

* mount host slot
siohmnt dta b($70,$01)  ; FujiNet device and unit
        dta b($F9)      ; Command MOUNT HOST SLOT
        dta b($00)      ; status
        dta a($0000)    ; unused
        dta b($10)      ; time out
        dta b($00)      ; unused
        dta a($0000)    ; unused
hmntslt dta b($00)      ; AUX1
        dta b($00)      ; AUX2


        icl '_PRINT.ICL'
        icl '_CHKSDOS.ICL'
        icl '_SDFAIL.ICL'
        icl '_SDLSIO.ICL'
        icl '_SDLBUF.ICL'

prnman  jsr _print
        dta b($9b),c'Swaps any two drives on FujiNet',b($9b)
        dta c'Checks for other existing drives',b($9b,$00)

prnhlp  jsr _print
        dta b($9b),c'Version 2023-02-01 (ep)',b($9b)
        dta c'Usage: FDSWAP Dx: Dy:',b($9b,$00)
        rts

parerr  jsr _print
        dta b($9b),c'Parameter error',b($9b,$00)
        rts

srceqdst jsr _print
        dta b($9b),c'No way! Source = Destination',b($9b,$00)
        rts

nofnsrc jsr _print
        dta b($9b),c'FN no source',b($9B,$00)
        rts

fnsrc   jsr _print
        dta b($9b),c'FN source okay',b($9B,$00)
        rts

nofndst jsr _print
        dta b($9b),c'FN no destination',b($9B,$00)
        rts

fndst   jsr _print
        dta b($9b),c'FN destination okay',b($9B,$00)
        rts

extsrc  jsr _print
        dta b($9b),c'External source drive online',b($9B,$00)
        rts

extdst  jsr _print
        dta b($9b),c'External destination drive online',b($9B,$00)
        rts



* Laufwerks-ID, Laufwerksnummer, hslot#, R/W, SIO-Status
srcdrvid  dta b($00)
srcdrvnr  dta b($00)
srcdrvhs  dta b($00)
srcdrvrw  dta b($00)
srcdrvst  dta b($00)

dstdrvid  dta b($00)
dstdrvnr  dta b($00)
dstdrvhs  dta b($00)
dstdrvrw  dta b($00)
dstdrvst  dta b($00)


devsptr dta a(0)
        dta a(38)
        dta a(76)
        dta a(114)
        dta a(152)
        dta a(190)
        dta a(228)
        dta a(266)

dev_s   dta f(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0) ; 304 bytes
        dta f(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
        dta f(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
        dta f(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
        dta f(0,0,0,0,0,0,0,0,0,0,0,0)

src_fn  dta f(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0) ; 256 bytes
        dta f(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
        dta f(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
        dta f(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)

dst_fn  dta f(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0) ; 256 bytes
        dta f(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
        dta f(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
        dta f(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
