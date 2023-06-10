* Sector Copy

* Equates

* CIO
CIOV       equ $E456
* CIOCB addresses
ICHID      equ $0340
ICDNO      equ $0341
ICCOM      equ $0342
ICSTA      equ $0343
ICBAL      equ $0344
ICBAH      equ $0345
ICPTL      equ $0346
ICPTH      equ $0347
ICBLL      equ $0348
ICBLH      equ $0349
ICAX1      equ $034a
ICAX2      equ $034b

* SIO
SIOV       equ $E459
* SIOCB addresses
DDEVIC     equ $0300
DUNIT      equ $0301
DCOMND     equ $0302
DSTATS     equ $0303
DBUFLO     equ $0304
DBUFHI     equ $0305
DTIMLO     equ $0306
DTIMHI     equ $0307
DBYTLO     equ $0308
DBYTHI     equ $0309
DAUX1      equ $030a
DAUX2      equ $030b

* cursor
CRSINH     equ $02F0

* SpartaDOS
DOSVEC     equ $000A
SD_BUFOFF  equ $0A ; offset in line buffer
SD_LBUF    equ $3F ; offset to line buffer
SD_ZCRNAME equ $03 ; offset for jmp to crunch name
SD_COMFNAM equ $21 ; offset to buffer for crunch name 
SD_LSIO    equ $0A ; negative offset to SIO vector

* zero page buffers
BUFRLO     equ $0032
BUFRHI     equ $0033

* start of code
            blk dos $3000
start       lda #$ff
            sta CRSINH    ; cursor off
* get parameter
            jsr pcheck
            bcc start_manu
            jmp start_para
start_manu  jsr PRINT
            dta c'Sector Copy 2022-02-20',b($9B)
            dta c'  Use: SECOPY Dx: Dy:    disk to disk',b($9B)
            dta c'       SECOPY Dx: Dy:fn  disk to file',b($9B)
            dta c'       SECOPY Dx:fn Dy:  file to disk',b($9B)
            dta c'  No format and drive check',b($9b)
            dta c'  Single density only',b($9B)
            dta b($ff)
            jmp the_end

start_para  jsr pget
            beq start_rdrv
            jmp start_wopen

* copy sector of disk to file
* SECOPY Dx: Dy:FILE
start_rdrv  ldy #SD_COMFNAM+1    ; read drive number
            lda (DOSVEC),Y
            sta start_rdnm
            and #$0f
            sta start_rdn+1
            sta start_xdn+1
            jsr print
            dta c'Read from drive D'
start_rdnm  dta c'X:',b($9b,$ff)

            jsr pcheck
            bcs start_rpath
            jsr print
            dta c'Second parameter missing',b($9b,$ff)
            jmp the_end

start_rpath jsr pget
            bne start_ropen
            jmp start_xdrv

start_ropen jsr print
            dta c'Sectors to file',b($9b,$ff)

            ldx #$10    ; channel 1
            lda #$03    ; open
            sta ICCOM,X
            lda #$08    ; write mode
            sta ICAX1,X
            lda DOSVEC
            clc
            adc #SD_COMFNAM
            sta ICBAL,X    ; adr of file name
            lda DOSVEC+1
            adc #$00
            sta ICBAH,X
            jsr CIOV
            bpl start_rlops

* error open file for write
            lda ICSTA
            jsr convh2a
            stx start_rof
            sty start_rof+1
            jsr print
            dta c'Open for write file state $'
start_rof   dta c'ff',b($9b,$ff)
            jmp end_close

start_rlops jsr print
            dta b($9c),c'Sector $',b($ff)
* loop over sector            
start_rloop inc start_rsl+1
            bne start_rssio 
            inc start_rsh+1
* write info
start_rssio lda start_rsh+1
            jsr convh2a
            stx start_rsnr
            sty start_rsnr+1
            lda start_rsl+1
            jsr convh2a
            stx start_rsnr+2
            sty start_rsnr+3
            jsr print
start_rsnr  dta c'ffff'
            dta b($1e,$1e,$1e,$1e,$ff)

* set SIOCB and read sector
            lda #$31    ; disk drive
            sta DDEVIC
start_rdn   lda #$00
            sta DUNIT    ; drive number
            lda #'R'    ; command read sector
            sta DCOMND
            lda #$40    ; state S/R $40, W/P $80
            sta DSTATS
            lda <buffer_sector
            sta DBUFLO
            lda >buffer_sector    ; buffer adress
            sta DBUFHI
            lda #$07    ; timeout default 7, format(!) $e0
            sta DTIMLO
            lda #$80    ; sector length $80
            sta DBYTLO
            lda #$00
            sta DBYTHI
start_rsl   lda #$00    ; sector number $01
            sta DAUX1
start_rsh   lda #$00
            sta DAUX2
            jsr lsio ;SIOV
            bit DSTATS
            bmi start_rend

* write sector to file
            ldx #$10    ; channel 1
            lda #$0b    ; put chars
            sta ICCOM,X
            lda <buffer_sector
            sta ICBAL,X    ; adr of file name
            lda >buffer_sector
            sta ICBAH,X
            lda #$80
            sta ICBLL,X    ; length $80
            lda #$00
            sta ICBLH,X
            jsr CIOV
            bmi start_rfend
            jmp start_rloop

start_rfend ldx #$10
            lda ICSTA,X
            jsr convh2a
            stx start_rwfm
            sty start_rwfm+1
            jsr print
            dta b($9b),c'Write file state $'
start_rwfm  dta c'ff',b($9b,$ff)

start_rend  lda DSTATS
            jsr convh2a
            stx start_rstam
            sty start_rstam+1
            jsr print
            dta b($9b),c'Read sector state $'
start_rstam dta c'ff',b($9b,$ff)

* close file
            jmp end_close

* copy file to sector of disk
* SECOPY Dx:FILE Dy:
start_wopen jsr print
            dta c'File to sectors',b($9b,$ff)

            ldx #$10    ; channel 1
            lda #$03    ; open
            sta ICCOM,X
            lda #$04    ; read mode
            sta ICAX1,X
            lda DOSVEC
            clc
            adc #SD_COMFNAM
            sta ICBAL,X    ; adr of file name
            lda DOSVEC+1
            adc #$00
            sta ICBAH,X
            jsr CIOV
            bpl start_wc2p

* error open file for write
            lda ICSTA
            jsr convh2a
            stx start_wof
            sty start_wof+1
            jsr print
            dta c'Open for read file state $'
start_wof   dta c'ff',b($9b,$ff)
* close file
            jmp end_close

start_wc2p  jsr pcheck
            bcs start_wc2pd
            jsr print
            dta c'Second parameter missing',b($9b,$ff)
* close file
            jmp end_close

start_wc2pd jsr pget
            beq start_wdrv
            jsr print
            dta c'Second parameter no drive number',b($9b,$ff)
* close file
            jmp end_close

start_wdrv  ldy #SD_COMFNAM+1    ; read drive number
            lda (DOSVEC),Y
            sta start_wdnm
            and #$0f
            sta start_wdn+1
            jsr print
            dta c'Write to drive D'
start_wdnm  dta c'X:',b($9b,$ff)

            jsr print
            dta b($9c),c'Sector $',b($ff)
* loop over sector
start_wloop inc start_wsl+1
            bne start_wssio 
            inc start_wsh+1
* write info
start_wssio lda start_wsh+1
            jsr convh2a
            stx start_wsnr
            sty start_wsnr+1
            lda start_wsl+1
            jsr convh2a
            stx start_wsnr+2
            sty start_wsnr+3
            jsr print
start_wsnr  dta c'ffff'
            dta b($1e,$1e,$1e,$1e,$ff)

* read sector from file
            ldx #$10    ; channel 1
            lda #$07    ; get chars
            sta ICCOM,X
            lda <buffer_sector
            sta ICBAL,X    ; adr of buffer
            lda >buffer_sector
            sta ICBAH,X
            lda #$80
            sta ICBLL,X    ; length $80
            lda #$00
            sta ICBLH,X
            jsr CIOV
            bmi start_wfend

* set SIOCB and write sector
            lda #$31    ; disk drive
            sta DDEVIC
start_wdn   lda #$00
            sta DUNIT    ; drive number
            lda #'W'    ; command write sector
            sta DCOMND
            lda #$80    ; state S/R $40, W/P $80
            sta DSTATS
            lda <buffer_sector
            sta DBUFLO
            lda >buffer_sector    ; buffer adress $4000
            sta DBUFHI
            lda #$07    ; timeout default 7, format(!) $e0
            sta DTIMLO
            lda #$80    ; sector length $80
            sta DBYTLO
            lda #$00
            sta DBYTHI
start_wsl   lda #$00    ; sector number $01
            sta DAUX1
start_wsh   lda #$00
            sta DAUX2
            jsr lsio ;SIOV
            bit DSTATS
            bmi start_wend
            jmp start_wloop

start_wfend ldx #$10
            lda ICSTA,X
            jsr convh2a
            stx start_wwfm
            sty start_wwfm+1
            jsr print
            dta b($9b),c'Read file state $'
start_wwfm  dta c'ff',b($9b,$ff)

start_wend  lda DSTATS
            jsr convh2a
            stx start_wstam
            sty start_wstam+1
            jsr print
            dta b($9b),c'Write sector state $'
start_wstam dta c'ff',b($9b,$ff)

* close file
end_close   ldx #$10    ; channel 1
            lda #$0C    ; close
            sta ICCOM,X
            jsr CIOV

            jmp the_end

* copy sector to sector of disk
* SECOPY Dx: Dy:
start_xdrv  ldy #SD_COMFNAM+1    ; read drive number
            lda (DOSVEC),Y
            sta start_xdnm
            and #$0f
            sta start_ydn+1
            jsr print
            dta c'Write to drive D'
start_xdnm  dta c'X:',b($9b,$ff)

            jsr print
            dta c'Sectors to sectors',b($9b)
            dta b($9c),c'Sector $',b($ff)

* loop over sector
start_xloop inc start_xsl+1
            inc start_ysl+1
            bne start_xssio 
            inc start_xsh+1
            inc start_ysh+1
* write info
start_xssio lda start_xsh+1
            jsr convh2a
            stx start_xsnr
            sty start_xsnr+1
            lda start_xsl+1
            jsr convh2a
            stx start_xsnr+2
            sty start_xsnr+3
            jsr print
start_xsnr  dta c'ffff'
            dta b($1e,$1e,$1e,$1e,$ff)

* set SIOCB and read sector
            lda #$31    ; disk drive
            sta DDEVIC
start_xdn   lda #$00
            sta DUNIT   ; drive number
            lda #'R'    ; command read sector
            sta DCOMND
            lda #$40    ; state S/R $40, W/P $80
            sta DSTATS
            lda <buffer_sector
            sta DBUFLO
            lda >buffer_sector ; buffer adress
            sta DBUFHI
            lda #$07    ; timeout default 7, format(!) $e0
            sta DTIMLO
            lda #$80    ; sector length $80
            sta DBYTLO
            lda #$00
            sta DBYTHI
start_xsl   lda #$00    ; sector number $01
            sta DAUX1
start_xsh   lda #$00
            sta DAUX2
            jsr lsio
            bit DSTATS
            bmi start_xend

* set SIOCB and write sector
            lda #$31    ; disk drive
            sta DDEVIC
start_ydn   lda #$00
            sta DUNIT   ; drive number
            lda #'W'    ; command write sector
            sta DCOMND
            lda #$80    ; state S/R $40, W/P $80
            sta DSTATS
            lda <buffer_sector
            sta DBUFLO
            lda >buffer_sector ; buffer adress $4000
            sta DBUFHI
            lda #$07    ; timeout default 7, format(!) $e0
            sta DTIMLO
            lda #$80    ; sector length $80
            sta DBYTLO
            lda #$00
            sta DBYTHI
start_ysl   lda #$00    ; sector number $01
            sta DAUX1
start_ysh   lda #$00
            sta DAUX2
            jsr lsio
            bit DSTATS
            bmi start_xfend

            jmp start_xloop

start_xfend lda DSTATS
            jsr convh2a
            stx start_xwfm
            sty start_xwfm+1
            jsr print
            dta b($9b),c'Write sector state $'
start_xwfm  dta c'ff',b($9b,$ff)
            lda #$01
            sta DSTATS

start_xend  lda DSTATS
            jsr convh2a
            stx start_xstam
            sty start_xstam+1
            jsr print
            dta b($9b),c'Read sector state $'
start_xstam dta c'ff',b($9b,$ff)

the_end     lda #$00
            sta CRSINH
            rts

* local SIO vector to SpartaDOS SIO            
lsio_set    dta b($ff)
lsio        lda lsio_set
            bpl lsio_call

            lda DOSVEC
            sec
            sbc #SD_LSIO
            sta BUFRLO

            lda DOSVEC+1
            sbc #$00
            sta BUFRHI

            ldy #$00
            lda (BUFRLO),Y
            sta lsio_call+1
            iny
            lda (BUFRLO),Y
            sta lsio_call+2

            lda #$00
            sta lsio_set

lsio_call   jsr $ffff
            rts

* parameter subroutines            
* check for next parameter
*   sets carry if next parameter is available
pcheck      ldy #SD_BUFOFF
            lda (DOSVEC),Y
            clc
            adc #SD_LBUF
            tay
            lda (DOSVEC),Y
            cmp #$9b
            clc
            beq pcheck_end
            sec
pcheck_end  rts

* get next parameter
*   calls crunch name 
pget_set    dta b($ff)
pget        lda pget_set
            bpl pget_call

            lda DOSVEC
            clc
            adc #SD_ZCRNAME
            sta pget_call+1

            lda DOSVEC+1
            adc #$00
            sta pget_call+2

            lda #$00
            sta pget_set

pget_call   jsr $ffff
            rts

* convert hex to atascii
*   hex A -> atascii X,Y
convh2a     pha
            lsr @
            lsr @
            lsr @
            lsr @
            sed
            clc
            adc #$90
            adc #$40
            tax
            pla
            and #$0f
            clc
            adc #$90
            adc #$40
            tay
            cld
            rts

* print subroutine
print       pla
            sta print_iter+1
            pla
            sta print_iter+2
print_loop  inc print_iter+1
            bne print_iter
            inc print_iter+2
print_iter  lda $ffff
            cmp #$ff
            beq print_end
            jsr cioputchr
            jmp print_loop
print_end   lda print_iter+2
            pha
            lda print_iter+1
            pha
            rts
* call cio put char subroutine
cioputchr   ldx #$00
            stx ICBLL
            stx ICBLH
            ldy #$0B
            sty ICCOM
            jmp CIOV

* sector buffer
buffer_sector equ *

            end
