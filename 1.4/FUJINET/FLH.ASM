* FujiNet FLH List Hosts
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
        bpl output
        jmp SD_FAIL

output  lda #$00
        sta iter2
        lda #'1'
        sta slt_num

slt_lp  lda slt_num
        jsr _putc
        lda #':'
        jsr _putc
        ldx iter2
        ldy >host_s
        lda #fn_hslt_ln
        jsr prnchar
        inc slt_num
        lda iter2
        clc
        adc #fn_hslt_ln
        sta iter2
        bne slt_lp

        rts

* print characters
* address: X,Y length: A
prnchar stx nxtchar+1
        sty nxtchar+2
        sta cpxchar+1
        ldx #$00
        stx iter1
nxtchar lda $ffff,X
        beq prneol
        jsr _putc
        inc iter1
        ldx iter1
cpxchar cpx #$00
        bne nxtchar
* print EOL
prneol  lda #$9b
        jmp _putc

* DCB data for Fuji
siodata dta b($70,$01)  ; FujiNet device and unit
        dta b($F4)      ; Command READ HOST SLOTS
siostat dta b($40)      ; status
        dta a(host_s)   ; host slots buffer
        dta b($10)      ; time out
        dta b($00)      ; unused
siobsz  dta a(host_sl)  ; buffer size
        dta b($00)      ; AUX1
        dta b($00)      ; AUX2

        icl '_CHKSDOS.ICL'
        icl '_SDFAIL.ICL'
        icl '_SDLSIO.ICL'
        icl '_PRINT.ICL'

* buffer for SIO GET HOST SLOTS ($100 aligned)
host_sl equ fn_hslt_ln*8
host_s  equ *&$FF00+$100

iter1   equ host_s+host_sl
iter2   equ iter1+1
slt_num equ iter2+1

        end
