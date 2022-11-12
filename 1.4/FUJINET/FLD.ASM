* FujiNet FLH List Devices
        icl '_SYSEQU.ICL'
        icl '_FNEQU.ICL'

        blk dos $3000
        jsr _chksdos
* read config via SIO
        ldx #$0b
nxtsiod lda siodata,X
        sta DDEVIC,X
        dex
        bpl nxtsiod
        jsr SD_SIO
        bpl nxtslt
        jmp SD_FAIL

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
* print file name
        ldx #$02
        stx iter1
nxtchar lda dev_s,X
        beq prneol
        jsr _putc
        inc iter1
        ldx iter1
        cpx #fn_devs_ln
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
        sta nxtchar+1
        lda nxthsl+2
        adc #$00
        sta nxthsl+2
        sta nxtmod+2
        sta nxtchar+2
* increment device numver
        inc slt_num
        lda slt_num
        cmp #'9'
        bcc nxtslt

        rts

* DCB data for Fuji
siodata dta b($70,$01)  ; FujiNet device and unit
        dta b($F2)      ; Command READ DEVICE SLOTS
siostat dta b($40)      ; status
        dta a(dev_s)    ; device slots buffer
        dta b($10)      ; time out
        dta b($00)      ; unused
siobsz  dta a(dev_sl)   ; buffer size
        dta b($00)      ; AUX1
        dta b($00)      ; AUX2

        icl '_CHKSDOS.ICL'
        icl '_SDFAIL.ICL'
        icl '_SDLSIO.ICL'
        icl '_PRINT.ICL'

* device slots buffer
dev_sl  equ fn_devs_ln*8
dev_s   equ *

iter1   equ dev_s+dev_sl

        end
