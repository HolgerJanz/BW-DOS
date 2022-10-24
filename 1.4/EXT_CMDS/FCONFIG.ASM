* FujiNet FCONFIG 
        icl '_SYSEQU'

        blk dos $3000
        jsr _chkbwdos14
* read config via SIO
        ldx #$0b
nxtsiod lda siodata,X
        sta DDEVIC,X
        dex
        bpl nxtsiod
* first try old buffer size $8B
        jsr BW_SIO
        bpl adptbuf
        cpy #$8F ; check sum record
        beq newconf
error   tya
        jmp (BW_FAIL)
* second try new buffer size $8C
newconf inc DBYT
        lda #$40
        sta DSTATS
        jsr BW_SIO
        bpl output
        jmp error
* adapt buffer for old config
adptbuf ldx #$20
nxtbb   lda fconfig,X
        inx
        sta fconfig,X
        inx
        cpx siobsz
        bcc nxtbb
        lda #$00
        sta fconfig+$20
* configuretion output
output  ldx #$02
        lda #$00
clrdci  sta BW_DECIN,X
        dex
        bpl clrdci

        jsr _print
        dta c'           SSID: ',b($00)
        ldx <fc_ssid
        ldy >fc_ssid
        lda #$21
        jsr prnchar

        jsr _print
        dta c'       Hostname: ',b($00)
        ldx <fc_host
        ldy >fc_host
        lda #$40
        jsr prnchar

        jsr _print
        dta c'     IP Address: ',b($00)
        ldx <fc_loIP
        ldy >fc_loIP
        jsr prnip

        jsr _print
        dta c'Gateway Address: ',b($00)
        ldx <fc_gate
        ldy >fc_gate
        jsr prnip

        jsr _print
        dta c'    DNS Address: ',b($00)
        ldx <fc_dnsi
        ldy >fc_dnsi
        jsr prnip

        jsr _print
        dta c'        Netmask: ',b($00)
        ldx <fc_nmsk
        ldy >fc_nmsk
        jsr prnip

        jsr _print
        dta c'    MAC Address: ',b($00)
        ldx <fc_maca
        ldy >fc_maca
        jsr prnmac

        jsr _print
        dta c'          BSSID: ',b($00)
        ldx <fc_bssi
        ldy >fc_bssi
        jsr prnmac

        jsr _print
        dta c'FCONFIG Version: 1.0 24-10-2022',b($9b,$00)

        jsr _print
        dta c'  Fuji Firmware: ',b($00)
        ldx <fc_firm
        ldy >fc_firm
        lda #$0f
        jsr prnchar

        rts

* DCB data for Fuji get adapter config
siodata dta b($70,$01)  ; FUJINET device and unit
        dta b($E8)      ; Command GET ADAPTER CONFIG
siostat dta b($40)      ; status
        dta a(fconfig)  ; buffer for date time
        dta b($40)      ; time out 15s
        dta b($00)      ; unused
siobsz  dta a(fconf_e-fconfig-1) ; buffer size -1 for old version
        dta b($00)      ; AUX1 and iter for DATER
        dta b($00)      ; AUX2 and iter for print

fconfig equ *
fc_ssid dta c'                                 '
fc_host dta c'                                                                '
fc_loIP dta b($00,$00,$00,$00)
fc_gate dta b($00,$00,$00,$00)
fc_nmsk dta b($00,$00,$00,$00)
fc_dnsi dta b($00,$00,$00,$00)
fc_maca dta b($00,$00,$00,$00,$00,$00)
fc_bssi dta b($00,$00,$00,$00,$00,$00)
fc_firm dta c'               '
fconf_e equ *

iter1   dta b($00)
iter2   dta b($00)

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


* print IP address
prnip   stx nxtipp+1
        sty nxtipp+2
        ldx #$00
        stx iter1
nxtipp  lda $ffff,X

        sta BW_DECIN
        jsr CONVDC
        ldx #$05
nxtipd  lda BW_DECOUT,X
        cmp #' '
        beq nxtipx
        stx iter2
        jsr _putc
        ldx iter2
nxtipx  inx
        cpx #$08
        bcc nxtipd

        inc iter1
        ldx iter1
        cpx #$04
        beq prneol

        lda #'.'
        jsr _putc
        ldx iter1

        jmp nxtipp

* print MAC
prnmac  stx nxtmacp+1
        sty nxtmacp+2
        ldx #$00
        stx iter1
nxtmacp lda $ffff,X

        jsr _convh2a
        tya
        pha
        txa
        jsr _putc
        pla
        jsr _putc

        inc iter1
        ldx iter1
        cpx #$06
        beq prneol

        lda #':'
        jsr _putc
        ldx iter1

        jmp nxtmacp

CONVDC  jmp (BW_CONVDC)
        icl '_CHKBWD14'
        icl '_PRINT'
        icl '_CONVH2A'

        end