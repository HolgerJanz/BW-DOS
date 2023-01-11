* FujiNet FLS List Slot Path Content

        icl '_SYSEQU.ICL'
        icl '_FNEQU.ICL'

        blk dos $3000
        jsr _chksdos
* clear buffer
        ldx #$00
        txa
clr_buf sta buffer,X
        inx
        bne clr_buf
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
* parse
_bufoff ldx $ffff
        jsr getlbuf
        cmp #' '
        beq *-5
        cmp #$9b
        beq prnuse
* check for slot number
        cmp #'1'
        bcc badpara
        cmp #'9'
        bcs badpara
        tay
        jsr getlbuf
        cmp #' '
        beq sslt
        cmp #$9b
        bne badpara
        dex
        jmp sslt
* Bad Parameter
badpara jsr prnuse
        ldy #$9C
        jmp SD_FAIL
prnuse  jsr _print
        dta b($9b),c'Usage: FLS slot# [path[/pattern]]',b($9b,$00)
        rts

* set slot
sslt    dey
        tya
        and #$0F
        sta mntslt
        sta openslt
        sta readslt
        sta closslt
* set path in buffer for open directory
        ldy #$00
nxtlbuf jsr getlbuf
        cmp #$9b
        beq spatt
        sta buffer,Y
        iny
        jmp nxtlbuf
* set null for pattern
spatt   dey
        bmi mount
        lda buffer,Y
        cmp #'/'
        bne spatt
setnul  lda #$00
        sta buffer,Y
* mount host slot
mount   ldx <mounts
        ldy >mounts
        jsr do_sio
* open directory
        ldx <opendir
        ldy >opendir
        jsr do_sio
* read directory
        jmp prneol
read    ldx <readdir
        ldy >readdir
        jsr do_sio
* $7F7F = last entry
        lda buffer
        cmp #$7F
        bne print
        lda buffer+1
        cmp #$7F
        beq close
* print entry
print   ldx #$00
        stx iter1
nxtchar lda buffer,X
        beq prneol
        jsr _putc
        inc iter1
        ldx iter1
        cpx #$FF
        bne nxtchar
prneol  lda #$9b
        jsr _putc
* check ESC key
        lda #$1C ; ESC
        cmp CH
        beq close
        jmp read
* close directory
close   ldx <closdir
        ldy >closdir
        jsr do_sio
        rts

* get next char from command line
getlbuf lda $ffff,X
        inx
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

* DCB data for Fuji MOUNT HOST SLOT
mounts  dta b($70,$01)  ; FujiNet device and unit
        dta b($F9)      ; Command OPEN DIRECTORY
        dta b($00)      ; status
        dta a($0000)    ; device slots buffer
        dta b($10)      ; time out
        dta b($00)      ; unused
        dta a($0000)    ; buffer size
mntslt  dta b($00)      ; AUX1 slot number
        dta b($00)      ; AUX2

* DCB data for Fuji OPEN DIRECTORY
opendir dta b($70,$01)  ; FujiNet device and unit
        dta b($F7)      ; Command OPEN DIRECTORY
        dta b($80)      ; status
        dta a(buffer)   ; device slots buffer
        dta b($10)      ; time out
        dta b($00)      ; unused
        dta a($100)     ; buffer size
openslt dta b($00)      ; AUX1 slot number
        dta b($00)      ; AUX2

* DCB data for Fuji READ DIRECTORY
readdir dta b($70,$01)  ; FujiNet device and unit
        dta b($F6)      ; Command READ DIRECTORY
        dta b($40)      ; status
        dta a(buffer)   ; device slots buffer
        dta b($10)      ; time out
        dta b($00)      ; unused
        dta a($FF)      ; buffer size
        dta b($FF)      ; AUX1 used buffer size
readslt dta b($00)      ; AUX2 slot number

* DCB data for Fuji CLOSE DIRECTORY
closdir dta b($70,$01)  ; FujiNet device and unit
        dta b($F5)      ; Command CLOSE DIRECTORY
        dta b($00)      ; status
        dta a($0000)    ; device slots buffer
        dta b($10)      ; time out
        dta b($00)      ; unused
        dta a($0000)    ; buffer size
closslt dta b($00)      ; AUX1 slot number
        dta b($00)      ; AUX2

        icl '_CHKSDOS.ICL'
        icl '_SDFAIL.ICL'
        icl '_SDLSIO.ICL'
        icl '_PRINT.ICL'

iter1   equ *
* device slots buffer
buffer  equ iter1+1

        end
