* FujiNet FCONFIG 
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

* configuration output
output  jsr _print
        dta b($9b),c'           SSID: ',b($00)
        ldx <fc_ssid
        ldy >fc_ssid
        lda #fn_ssid_ln
        jsr prnchar

        jsr _print
        dta c'       Hostname: ',b($00)
        ldx <fc_host
        ldy >fc_host
        lda #fn_host_ln
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
        dta c'FCONFIG Version: 1.0 06-11-2022',b($9b,$00)

        jsr _print
        dta c'  Fuji Firmware: ',b($00)
        ldx <fc_firm
        ldy >fc_firm
        lda #fn_firm_ln
        jsr prnchar

        rts

* DCB data for Fuji get adapter config
siodata dta b($70,$01)  ; FujiNet device and unit
        dta b($E8)      ; Command GET ADAPTER CONFIG
siostat dta b($40)      ; status
        dta a(fconfig)  ; CONFIG buffer
        dta b($10)      ; time out
        dta b($00)      ; unused
siobsz  dta a(fconf_e-fconfig) ; buffer size
        dta b($00)      ; AUX1
        dta b($00)      ; AUX2

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
        jsr SD_PUTDEC
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

        icl '_CHKSDOS.ICL'
        icl '_SDFAIL.ICL'
        icl '_SDLSIO.ICL'
        icl '_PRINT.ICL'
        icl '_CONVH2A.ICL'

* data declaration
iter1   equ *
* FujiNet SIO CONFIG block
fconfig equ iter1+1
fc_ssid equ fconfig
fc_host equ fc_ssid+fn_ssid_ln
fc_loIP equ fc_host+fn_host_ln
fc_gate equ fc_loIP+fn_ip_ln
fc_nmsk equ fc_gate+fn_ip_ln
fc_dnsi equ fc_nmsk+fn_ip_ln
fc_maca equ fc_dnsi+fn_ip_ln
fc_bssi equ fc_maca+fn_mac_ln
fc_firm equ fc_bssi+fn_mac_ln
fconf_e equ fc_firm+fn_firm_ln

        end
