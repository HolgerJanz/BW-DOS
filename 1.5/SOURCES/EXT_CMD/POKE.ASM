* Poke for SpartaDOS 3 by hjx

CIOV   equ $E456

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

SIOV   equ $E459

DDEVIC equ $0300
DUNIT  equ $0301
DCOMND equ $0302
DSTATS equ $0303
DBUFLO equ $0304
DBUFHI equ $0305
DTIMLO equ $0306
DTIMHI equ $0307
DBYTLO equ $0308
DBYTHI equ $0309
DAUX1  equ $030a
DAUX2  equ $030b

CRSINH equ $02F0

DOSVEC      equ $000A
SD_BUFOFF   equ $0A ; offset in line buffer
SD_LBUF     equ $3F ; offset to line buffer
SD_ZCRNAME  equ $03 ; offset for jmp to crunch name
SD_COMFNAM  equ $21 ; offset to buffer for crunch name 
SD_LSIO     equ $0A ; negative offset to SIO vector

* Start of code
            org $580
start       jsr pcheck  ; check for parameter 1
            bcs start_poke
error_msg   jsr PRINT
            dta b($9b),c'POKE 1.2',b($9b)
            dta c'Parameter Error',b($9b)
            dta c'Use: POKE aaaa vv[vv] ...',b($9B)
            dta b($ff)
            rts

start_poke  lda #$00
            sta flag_word
            jsr pget
_error_msg  beq error_msg

            ldx #$00            ; get address
            ldy #SD_COMFNAM+3
loop_r4     lda (DOSVEC),Y
            cmp #$9b
            beq error_msg
            sta char1,x
            iny
            inx
            cpx #$04
            bne loop_r4
            lda (DOSVEC),Y
            cmp #$9b
error_msg2  bne error_msg

            ldx char1            ; convert address
            ldy char2
            jsr conva2h
            sta adr1_h

            ldx char3
            ldy char4
            jsr conva2h
            sta adr1_l

            jsr pcheck         ; check for parameter 2
            bcc error_msg
            jsr pget
            beq error_msg

            ldx #$00
            ldy #SD_COMFNAM+3  ; get value
loop_r2     lda (DOSVEC),Y
            cmp #$9b
            beq _error_msg
            sta char1,x
            iny
            inx
vchar_cnt   cpx #$02
            bne loop_r2
            lda (DOSVEC),Y
            cmp #$9b
            beq poke

            lda flag_word      ; chek for word
            bne error_msg2

            lda #$ff
            sta flag_word
            lda #$04
            sta vchar_cnt+1
            jmp loop_r2

poke        ldx char1          ; convert value
            ldy char2
            jsr conva2h
            sta val1

            lda flag_word      ; check for word
            beq poke_byte

            clc                ; calc adr for high byte
            lda adr1_l
            adc #$01
            sta adr2_l
            lda adr1_h
            adc #$00
            sta adr2_h

            lda val1           ; set value for high byte
            sta val2

            ldx char3          ; convert value 2 (low)
            ldy char4
            jsr conva2h
            sta val1

c_val2      lda #$00
c_adr2      sta $ffff

poke_byte   equ *
c_val1      lda #$00
c_adr1      sta $ffff

            jsr pcheck  ; check for further parameter
            bcc poke_end
            jmp start_poke

poke_end    rts

flag_word   dta b($00)
char1       dta b($00)
char2       dta b($00)
char3       dta b($00)
char4       dta b($00)

adr1_l      equ c_adr1+1
adr1_h      equ adr1_l+1

adr2_l      equ c_adr2+1
adr2_h      equ adr2_l+1

val1        equ c_val1+1
val2        equ c_val2+1

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
* jump for jsr to crunch name
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

            end
