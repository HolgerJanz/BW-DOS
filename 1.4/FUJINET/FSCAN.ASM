* FujiNet FSCAN scan for 2,4 WiFis

        icl '_SYSEQU.ICL'
        icl '_FNEQU.ICL'

* main
        blk dos $3000
        jsr _chksdos
* scan for WiFis
        ldx <sioscan
        ldy >sioscan
        jsr _dosio
* read results
        lda #$9b
        jsr _putc
nxtsres ldx <siosres
        ldy >siosres
        jsr _dosio
* print dBm
        lda scandbm
        bpl  putdec
        pha
        lda #'-'
        jsr _putc
        pla
        eor #$FF
        clc
        adc #$01
        pha
putdec  jsr _putdec
        jsr _print
        dta c'dBm ',b($00)
* print scale
        ldx $00
        stx dbmi
nxtscl  pla
        cmp dbms,X
        pha
        lda #'*'
        bcc *+4
        eor #%00000111 ; = '-'
        jsr _putc
        inc dbmi
        ldx dbmi
        cpx #$06
        bne nxtscl
        pla
        lda #' '
        jsr _putc
* print name
        ldx #$00
        stx iter
nxtchar lda scannam,X
        beq prneol
        jsr _putc
        inc iter
        ldx iter
        cpx #33
        bne nxtchar
* print EOL
prneol  lda #$9b
        jsr _putc
* next result ?
        inc scannum
        lda scannum
        cmp wifinum
        bcc nxtsres
        rts

        icl '_PRINT.ICL'
        icl '_CHKSDOS.ICL'
        icl '_SDLBUF.ICL'
        icl '_SDFAIL.ICL'
        icl '_SDLSIO.ICL'

* DCB data for Fuji SCAN
sioscan dta b($70,$01)  ; FujiNet device and unit
        dta b($FD)      ; Command SCAN
        dta b($40)      ; status
        dta a(wifinum)  ; buffer for result count
        dta b($10)      ; time out
        dta b($00)      ; unused
        dta a(4)        ; buffer size
        dta b($00)      ; AUX1
        dta b($00)      ; AUX2
* DCB data for Fuji GET SCAN RESULT
siosres dta b($70,$01)  ; FujiNet device and unit
        dta b($FC)      ; Command GET SCAN RESULT
        dta b($40)      ; status
        dta a(scannam)    ; device slots buffer
        dta b($10)      ; time out
        dta b($00)      ; unused
        dta a(34)       ; 8 device slots
scannum dta b($00)      ; scan entry index
        dta b($00)      ; AUX2

* dBm for scale
dbmi    dta b($00)
dbms    dta b(90,80,70,60,50,40)

* iterator
iter    equ *
* number of scanned WiFis (4 Bytes)
wifinum equ iter+1 
* buffer for GET SCAN RESULT
scannam equ wifinum+4
scandbm equ scannam+33

        end

