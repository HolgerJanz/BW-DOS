* Clears Memory from MEMLO to MEMTOP

MEMTOP equ $02E5
MEMLO  equ $02E7
CH     equ $02FC

* CIO
CIOV        equ $E456
* CIOCB addresses
ICHID  equ $0340
ICDNO  equ $0341
ICCOM  equ $0342
ICSTA  equ $0343
ICBAL  equ $0344
ICBAH  equ $0345
ICPTL  equ $0346
ICPTH  equ $0347
ICBLL  equ $0348
ICBLH  equ $0349
ICAX1  equ $034a
ICAX2  equ $034b

* SpartaDOS 
DOSVEC      equ $000A
SD_BUFOFF   equ $0A ; offset in line buffer
SD_LBUF     equ $3F ; offset to line buffer
SD_ZCRNAME  equ $03 ; offset for jmp to crunch name
SD_COMFNAM  equ $21 ; offset to buffer for crunch name 
SD_LSIO     equ $0A ; negative offset to SIO vector

            blk dos $500

            jsr pcheck          ; check for parameter 1
            bcc startClear

            jsr pget            ; get parameter
            beq parameterError

            ldx #$00
            ldy #SD_COMFNAM+3   ; get value
loop_r2     lda (DOSVEC),Y
            cmp #$9b
            beq parameterError
            sta clr_char,x
            iny
            inx
vchar_cnt   cpx #$02
            bne loop_r2

            lda (DOSVEC),Y      ; check for end after second char
            cmp #$9b
            bne parameterError

            ldx clr_char        ; convert to hex
            ldy clr_char+1
            jsr conva2h
            sta clearValue+1

            jsr pcheck          ; check for too many parameter
            bcc startClear

parameterError jsr print
            dta b($9b),c'MEMCLEAR 14-03-2024',b($9b)
            dta c'Use: MEMCLEAR [hh]',b($9b,$ff)
            rts

startClear  lda MEMLO+1
            jsr convh2a
            stx adr_low
            sty adr_low+1
            lda MEMLO
            jsr convh2a
            stx adr_low+2
            sty adr_low+3

            lda MEMTOP+1
            jsr convh2a
            stx adr_high
            sty adr_high+1
            lda MEMTOP
            jsr convh2a
            stx adr_high+2
            sty adr_high+3

            jsr PRINT
            dta b($9b),c'Clear memory ' 
adr_low     dta c'xxxx-'
adr_high    dta c'yyyy with '
clr_char    dta c'00? (Y)',b($ff)

            jsr getKey
            and #$DF ; upper or lower
            cmp #'Y'
            beq clear_start
            jsr PRINT
            dta b($9b),c'Abort',b($9b,$ff)
            rts

clear_start jsr PRINT
            dta b($9b),c'Clearing ... ',b($ff)

            lda clearValue+1
            ldx #$7F
zclr_loop   sta $80,X
            dex
            bpl zclr_loop

            lda MEMLO
            sta clear_loop+1
            lda MEMLO+1
            sta clear_loop+2

clearValue  ldx #$00
clear_loop  stx $ffff

            lda clear_loop+2    ; check for MEMTOP
            cmp MEMTOP+1
            bne clear_inc
            lda clear_loop+1
            cmp MEMTOP
            bcs clear_end

clear_inc   inc clear_loop+1    ; inc address
            bne clear_loop
            inc clear_loop+2
            jmp clear_loop

clear_end   jsr PRINT
            dta c'Done',b($9b,$ff)
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

            ldx #$00            ; put char
            stx ICBLL
            stx ICBLH
            ldy #$0B
            sty ICCOM
            jsr CIOV

            jmp print_loop
print_end   lda print_iter+2
            pha
            lda print_iter+1
            pha
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

* convert atascii to hex
*   atascii X,Y -> hex A
conva2h     txa
            jsr conva2h_h
            asl @
            asl @
            asl @
            asl @
            sta conva2h_o+1
            tya
            jsr conva2h_h
conva2h_o   ora #$00
            rts

conva2h_h   sec
            sbc #'0'
            cmp #$0A
            bcc conva2h_hl
            clc
            adc #$09
conva2h_hl  and #$0F
            rts

* get key

knam        dta c'K:'
            dta b(155)

getkey      jsr close2

            ldx #$20
            lda #3
            sta ICCOM,x
            lda #4
            sta ICAX1,x
            lda #0
            sta ICAX2,x
            lda <knam
            sta ICBAL,x
            lda >knam
            sta ICBAH,x
            jsr CIOV

            ldx #$20
            lda #7
            sta ICCOM,x
            lda #0
            sta ICBLL,x
            sta ICBLH,x
            jsr CIOV

            pha
            jsr close2
            pla
            rts
            
close2      ldx #$20
            lda #12
            sta ICCOM,x
            jmp CIOV

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

            end
