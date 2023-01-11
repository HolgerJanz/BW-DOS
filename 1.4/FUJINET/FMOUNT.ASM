* FujiNet FMOUNT Mount File of Host Slot to Disk Slot

        icl '_SYSEQU.ICL'
        icl '_FNEQU.ICL'

* main
        blk dos $3000
        jsr _chksdos
* clear device slot to be set
        ldx #fn_devs_ln-1
        lda #$00
        sta hstslt,X
        dex
        bpl *-4
*  parse parameter
*  get BUFOFF
        clc
        lda DOSVEC
        adc #SD_BUFOFF
        sta _bufoff+1
        lda DOSVEC+1
        adc #$00
        sta _bufoff+2
*  get LBUF
        clc
        lda DOSVEC
        adc #SD_LBUF
        sta getlbuf+1
        lda DOSVEC+1
        adc #$00
        sta getlbuf+2
*  parse parameter
_bufoff ldx $ffff
        jsr trim
        cmp #$9b
        bne *+5
        jmp prnhlp
*  check D#:
        cmp #'D'
        beq getdnum
        cmp #'d'
        beq getdnum
        bne badpara
getdnum jsr getlbuf
        cmp #'1'
        bcc badpara
        cmp #'9'
        bcs badpara
        jsr getnum
        sta devslt
        jsr getlbuf
        cmp #':'
        bne badpara
        jsr trim
*  no further parameter => unmount
        cmp #$9b
        bne *+5
        jmp unmount
*  check for slot number
        cmp #'1'
        bcc badpara
        cmp #'9'
        bcs badpara
        jsr getnum
        sta hstslt
        jsr trim
*  check mount mode
        ldy #$01
        cmp #'R'
        beq mread
        cmp #'W'
        beq mwrite
        cmp #'r'
        beq mread
        cmp #'w'
        beq mwrite
        bne badpara
mwrite  iny
mread   sty mmode
        jsr trim
*  check file name
        ldy #$00
fnamlp  cmp #$9b
        beq mount
        sta fname,Y
        iny
        jsr getlbuf
        jmp fnamlp
* error bad parameter
badpara jsr prnhlp
        ldy #$9C ; Bad Parameter
        jmp SD_FAIL
prnhlp  jsr _print
        dta b($9b),c'Vers 04-01-2023',b($9b)
        dta c'Usage: FMOUNT D#: [slot# R|W file]',b($9b,$00)
        rts
        
* mount disk slot
*  pad file name with null
mount   lda #$00
        sta fname,Y
        iny
        bne *-4
*  read device slots
        jsr rddslt
*  mount host slot
        lda hstslt
        sta hmntslt
        jsr _print
        dta c'mount host slot',b($9b,$00)
        ldx <siohmnt
        ldy >siohmnt
        jsr do_sio
*  set device slot
*   calc address
        ldx devslt
sltclc  beq setdslt
        clc
        lda sdsadr+1
        adc #fn_devs_ln
        sta sdsadr+1
        lda sdsadr+2
        adc #$00
        sta sdsadr+2
        dex
        jmp sltclc
*   set slot
setdslt ldx #$00
        lda hstslt,X
sdsadr  sta devslts,X
        inx
        cpx #fn_devs_ln
        bne *-9
*  write device slots
        jsr wrdslt
*  set file for device slot
        jsr _print
        dta c'set file for device slot',b($9b,$00)
        lda devslt
        sta fnamslt
        lda hstslt
        asl @
        asl @
        asl @
        asl @
        ora mmode
        sta fnamsm
        ldx <siosfnm
        ldy >siosfnm
        jsr do_sio
*  mount device
        jsr _print
        dta c'mount device slot',b($9b,$00)
        lda devslt
        sta dmntslt
        lda mmode
        sta dmntmod
        ldx <siodmnt
        ldy >siodmnt
        jsr do_sio
        rts

* unmont disk slot
*  read device slots
unmount jsr rddslt
*  unmount device slot
        jsr _print
        dta c'unmount device slot',b($9b,$00)
        lda devslt
        sta unmntsl
        ldx <sioumnt
        ldy >sioumnt
        jsr do_sio
*  set slot unmounted
*  calc slot addr
        ldx devslt
        beq clrdslt
sadrclc clc
        lda dsltadr+1
        adc #fn_devs_ln
        sta dsltadr+1
        lda dsltadr+2
        adc #$00
        sta dsltadr+2
        dex
        bne sadrclc
*  clear device slot and (X=0)
*  set host of device to invalid
clrdslt lda #$00
        ldx fn_devs_ln-1
        bne *+4
        lda #$FF
dsltadr sta devslts,X
        dex
        bpl *-8
*  write device slots
        jsr wrdslt
        rts

* read device slots
rddslt  jsr _print
        dta b($9b),c'read device slots',b($9b,$00)
        ldx <siordev
        ldy >siordev
        jmp do_sio

* write device slots
wrdslt  jsr _print
        dta c'write device slots',b($9b,$00)
        ldx <siowdev
        ldy >siowdev
        jmp do_sio

* get next char from command line
getlbuf lda $ffff,X
        inx
        rts

* trim spaces
trim    jsr getlbuf
        cmp #' '
        beq *-5
        rts

* get number ATASCII 1..8 => HEX 0..7
getnum  and #$0F
        sec
        sbc #$01
        rts

* set DCB and call SIO
do_sio  stx nxtsiod+1
        sty nxtsiod+2
        ldx #$0b
nxtsiod lda $FFFF,X
        sta DDEVIC,X
        dex
        bpl nxtsiod
        jsr SD_SIO
        bpl *+5
        jmp SD_FAIL
        rts

        icl '_CHKSDOS.ICL'
        icl '_SDFAIL.ICL'
        icl '_SDLSIO.ICL'
        icl '_PRINT.ICL'

* DCB data for FujiNet
* read device slots
siordev dta b($70,$01)  ; FujiNet device and unit
        dta b($F2)      ; Command READ DEVICE SLOTS
        dta b($40)      ; status
        dta a(devslts)  ; device slots buffer
        dta b($10)      ; time out
        dta b($00)      ; unused
        dta a(fn_devs_l8) ; 8 device slots
        dta b($00)      ; AUX1
        dta b($00)      ; AUX2

* write device slots
siowdev dta b($70,$01)  ; FujiNet device and unit
        dta b($F1)      ; Command WRITE DEVICE SLOTS
        dta b($80)      ; status
        dta a(devslts)  ; device slots buffer
        dta b($10)      ; time out
        dta b($00)      ; unused
        dta a(fn_devs_l8) ; 8 device slots
        dta b($00)      ; AUX1
        dta b($00)      ; AUX2

* unmount device slot
sioumnt dta b($70,$01)  ; FujiNet device and unit
        dta b($E9)      ; Command UMOUNT DEVICE SLOT
        dta b($00)      ; status
        dta a($0000)    ; device slots buffer
        dta b($10)      ; time out
        dta b($00)      ; unused
        dta a($0000)    ; 8 device slots
unmntsl dta b($00)      ; AUX1
        dta b($00)      ; AUX2

* mount host slot
siohmnt dta b($70,$01)  ; FujiNet device and unit
        dta b($F9)      ; Command MOUNT HOST SLOT
        dta b($00)      ; status
        dta a($0000)    ; device slots buffer
        dta b($10)      ; time out
        dta b($00)      ; unused
        dta a($0000)    ; 8 device slots
hmntslt dta b($00)      ; AUX1
        dta b($00)      ; AUX2

* set file name for device slot
siosfnm dta b($70,$01)  ; FujiNet device and unit
        dta b($E2)      ; Command SET FILE NAME
        dta b($80)      ; status
        dta a(fname)    ; file name buffer
        dta b($10)      ; time out
        dta b($00)      ; unused
        dta a($0100)    ; 256 bytes
fnamslt dta b($00)      ; slot number
fnamsm  dta b($00)      ; host slot bit 4-7, mode bit 0-3, AUX2

* mount disk slot
siodmnt dta b($70,$01)  ; FujiNet device and unit
        dta b($F8)      ; Command MOUNT DISK SLOT
        dta b($00)      ; status
        dta a($0000)    ; unused
        dta b($10)      ; time out
        dta b($00)      ; unused
        dta a($0000)    ; unused
dmntslt dta b($00)      ; disk solt
dmntmod dta b($00)      ; mode

* device slots buffer
devslts equ *
* passed device slot number
devslt  equ devslts+fn_devs_l8
* device slot to be set, 38 Bytes
hstslt  equ devslt+1
mmode   equ hstslt+1
* fname is 256 Bytes
fname   equ hstslt+fn_devs_ln
        end
