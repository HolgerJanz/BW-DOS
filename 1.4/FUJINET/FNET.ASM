* FujiNet FNET connect to WiFi

        icl '_SYSEQU.ICL'
        icl '_FNEQU.ICL'

* main
        blk dos $3000
        jsr _chksdos
* clear SSID/passwd buffer
        ldx #fn_ssid_ln+fn_pass_ln-1
        lda #$00
        sta wfssid,X
        dex
        bpl *-4
* parse comand line
        jsr _lbinit
        jsr _lbtrim
        cmp #$9b
        beq prnhlp
* parse ssid
        cmp #'"'
        bne *+8
        sta nxtidc+1
        jsr _lbget
        ldy #$00
nxtidc  cmp #' '
        beq parsepw
        cmp #$9b
        beq callsio
        cpy #fn_ssid_ln-1
        bcs badpara
        sta wfssid,Y
        jsr _lbget
        iny
        jmp nxtidc
* parse passwd
parsepw jsr _lbtrim
        cmp #'"'
        bne *+8
        sta nxtpwc+1
        jsr _lbget
        ldy #$00
nxtpwc  cmp #' '
        bne *+11
        jsr _lbtrim
        cmp #$9b
        beq callsio
        bne badpara
        cmp #$9b
        beq callsio
        cpy #fn_pass_ln-1
        bcs badpara
        sta wfpass,Y
        jsr _lbget
        iny
        jmp nxtpwc

* error bad parameter
badpara jsr prnhlp
        ldy #$9C ; Bad Parameter
        jmp _fail
prnhlp  jsr _print
        dta b($9b),c'Vers 20-01-2023',b($9b)
        dta c'Usage: FNET ssid [passwd]',b($9b,$00)
        rts

* call sio
callsio jsr _print
        dta b($9b),c'set and connect',b($9b,$00)
        ldx <siossid
        ldy >siossid
        jsr _dosio
* wait 4-5 sec
        ldx RTCLOK+2
        dex
        cpx RTCLOK+2
        bne *-2
* get status
        jsr _print
        dta c'get status',b($9b,$00)
        ldx <siostat
        ldy >siostat
        jsr _dosio
* check status
        lda wfstat
        cmp #WF_CACT
        beq wifiok
        jsr _print
        dta c'status ',b($00)
        lda wfstat
        jsr _putdec
        lda #$9b
        jsr _putc
        rts
wifiok  jsr _print
        dta c'ok',b($9b,$00)
        rts

        icl '_PRINT.ICL'
        icl '_CHKSDOS.ICL'
        icl '_SDLBUF.ICL'
        icl '_SDFAIL.ICL'
        icl '_SDLSIO.ICL'

* DCB data for Fuji SET SSID AND CONNECT
siossid dta b($70,$01)  ; FujiNet device and unit
        dta b($FB)      ; Command SET SSID AND CONNECT
        dta b($80)      ; status
        dta a(wfssid)   ; buffer SSID and passwd
        dta b($10)      ; time out
        dta b($00)      ; unused
        dta a(fn_ssid_ln+fn_pass_ln) ; buffer size
        dta b($01)      ; AUX1 save SSID and passwd
        dta b($00)      ; AUX2
* DCB data for Fuji GET WIFI STATUS
siostat dta b($70,$01)  ; FujiNet device and unit
        dta b($FA)      ; Command GET WIFI STATUS
        dta b($40)      ; status
        dta a(wfstat)   ; status buffer
        dta b($10)      ; time out
        dta b($00)      ; unused
        dta a(1)        ; buffer length
        dta b($00)      ; AUX1
        dta b($00)      ; AUX2

wfstat  equ *
* SSID 33 Bytes
wfssid  equ wfstat+1
* passwd 64 Bytes
wfpass  equ wfssid+fn_ssid_ln

        end
