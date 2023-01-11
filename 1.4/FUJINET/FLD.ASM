* FujiNet FLD List Devices
        icl '_SYSEQU.ICL'
        icl '_FNEQU.ICL'

        blk dos $3000
        jsr _chksdos
* read config via SIO
        ldx <siorslt
        ldy >siorslt
        jsr do_sio
* print device slot
        lda #$9b
        jsr _putc
nxtslt  jsr _print
        dta c'D'
slt_num dta c'1:',b($00)
        ldx #$00
nxthsl  lda dev_s,X
        cmp #$FF
        beq prneol
        clc
        adc #$01
        ora #'0'
        sta slt_hst
        inx
        lda #'R'
nxtmod  ldy dev_s,X
        cpy #$02 ; read/write
        bne *+5
        clc
        adc #$05 ; 'R'+$05='W'
        sta slt_mod
* print host slot number and mode
        jsr _print
        dta c'('
slt_hst dta c'y'
slt_mod dta c'z)'
        dta b($00)
* get file name
        ldx <siogfnm
        ldy >siogfnm
        jsr do_sio
* print file name
        ldx #$00
        stx iter1
nxtchar lda fname,X
        beq prneol
        jsr _putc
        inc iter1
        ldx iter1
        bne nxtchar
* print EOL
prneol  lda #$9b
        jsr _putc
* increment buffer address
        clc
        lda nxthsl+1
        adc #fn_devs_ln
        sta nxthsl+1
        sta nxtmod+1
        lda nxthsl+2
        adc #$00
        sta nxthsl+2
        sta nxtmod+2
* increment device numver
        inc fgnmslt
        inc slt_num
        lda slt_num
        cmp #'9'
        bcc nxtslt
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

* DCB data for Fuji
siorslt dta b($70,$01)  ; FujiNet device and unit
        dta b($F2)      ; Command READ DEVICE SLOTS
        dta b($40)      ; status
        dta a(dev_s)    ; device slots buffer
        dta b($10)      ; time out
        dta b($00)      ; unused
        dta a(dev_sl)   ; buffer size
        dta b($00)      ; AUX1
        dta b($00)      ; AUX2

* get file name for device slot
siogfnm dta b($70,$01)  ; FujiNet device and unit
        dta b($DA)      ; Command GET FILE NAME
        dta b($40)      ; status
        dta a(fname)    ; file name buffer
        dta b($10)      ; time out
        dta b($00)      ; unused
        dta a($0100)    ; 256 bytes
fgnmslt dta b($00)      ; slot number
        dta b($00)      ; AUX2

        icl '_CHKSDOS.ICL'
        icl '_SDFAIL.ICL'
        icl '_SDLSIO.ICL'
        icl '_PRINT.ICL'

* device slots buffer
dev_sl  equ fn_devs_ln*8
dev_s   equ *
iter1   equ dev_s+dev_sl
fname   equ iter1+1
* fname is 256 Bytes
        end
