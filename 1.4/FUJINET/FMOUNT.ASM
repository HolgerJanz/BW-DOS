* FujiNet FMOUNT Mount Host Slot File to Disk Slot
        icl '_SYSEQU.ICL'
        icl '_FNEQU.ICL'

        blk dos $3000
        jsr _chksdos
* parse parameter
* get BUFOFF
        clc
        lda DOSVEC
        adc #SD_BUFOFF
        sta _bufoff+1
        lda DOSVEC+1
        adc #$00
        sta _bufoff+2
* get LBUF
        clc
        lda DOSVEC
        adc #SD_LBUF
        sta getlbuf+1
        lda DOSVEC+1
        adc #$00
        sta getlbuf+2
* parse parameter
_bufoff ldx $ffff
        jsr trim
* check D#:
        cmp #'D'
        bne badpara
        jsr getlbuf
        cmp #'1'
        bcc badpara
        cmp #'9'
        bcs badpara
        jsr getnum
        sta dskslt
        jsr trim
* no further parameter => unmount
        cmp #$9b
        bne *+5
        jmp unmount
* check for slot number
        cmp #'1'
        bcc badpara
        cmp #'9'
        bcs badpara
        jsr getnum
        sta hstslt
        jsr trim
* check mount mode
        ldy #$01
        cmp #'R'
        beq mread
        cmp #'W'
        beq mwrite
        bne badpara
mwrite  iny
mread   sty mmode
        jsr trim
* check file name
        ldy #$00
fnamlp  cmp #$9b
        beq mount
        sta fname,Y
        jsr getlbuf
        jmp fnamlp
* error bad parameter
badpara jsr _print
        dta b($9b),c'Usage: FMOUNT D#: slot# R|W file',b($9b,$00)
        ldy #$9C ; Bad Parameter
        jmp SD_FAIL

* mount disk slot
mount

        rts
        
* unmont disk solt
*   read device slots
unmount ldx <siordev
        ldy >siordev
        jsr do_sio
* unmount device slot
        lda dskslt
        sta unmntsl
        ldx <sioumnt
        ldy >sioumnt
        jsr do_sio
* set slot unmounted
        ldx dskslt
????
        lda #$FF
        sta devslts

* write device slots
        ldx <siowdev
        ldy >siowdev
        jsr do_sio
        rts

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

* DCB data for Fuji
siordev dta b($70,$01)  ; FujiNet device and unit
        dta b($F2)      ; Command READ DEVICE SLOTS
        dta b($40)      ; status
        dta a(devslts)  ; device slots buffer
        dta b($10)      ; time out
        dta b($00)      ; unused
        dta a(fn_devs_l8) ; 8 device slots
        dta b($00)      ; AUX1
        dta b($00)      ; AUX2

siowdev dta b($70,$01)  ; FujiNet device and unit
        dta b($F1)      ; Command WRITE DEVICE SLOTS
        dta b($80)      ; status
        dta a(devslts)  ; device slots buffer
        dta b($10)      ; time out
        dta b($00)      ; unused
        dta a(fn_devs_l8) ; 8 device slots
        dta b($00)      ; AUX1
        dta b($00)      ; AUX2

sioumnt dta b($70,$01)  ; FujiNet device and unit
        dta b($E9)      ; Command UMOUNT DEVICE SLOT
        dta b($80)      ; status
        dta a($0000)    ; device slots buffer
        dta b($10)      ; time out
        dta b($00)      ; unused
        dta a($0000)    ; 8 device slots
unmntsl dta b($00)      ; AUX1
        dta b($00)      ; AUX2


* device slots buffer
devslts equ *
dskslt  equ devslts+fn_devs_l8
hstslt  equ dskslt+1
mmode   equ hstslt+1
fname   equ mmode+1

        end
