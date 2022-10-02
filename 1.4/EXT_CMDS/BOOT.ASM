* BW-DOS Command BOOT file_name

* System equates
            icl '_SYSEQU.ASM'

* Code equates
* index of last seperator in path
LAST_SEP    equ $0080
* flag for switch from name to ext
EXT_FLAG    equ $0081
* zero page with local SIO address
Z_LSIO      equ $0082

* buffer for path and sector
BUFFER      equ $0500
* file name internal representation
INT_NAME    equ $0540
* buffer for directory entry
DIR_ENTRY   equ $05C0

* Start of code
            blk dos $2800
* check for SparataDOS
start       lda BW_SPARTA
            cmp #'S'
            beq sd_fnd
            jsr _print
            dta b($9B)
            dta c'Error: Incorrect DOS version'
            dta b($9B,$00)
            jmp (DOSVEC)
* set crname
sd_fnd      lda DOSVEC
            clc
            adc #$03
            sta crname+1
            lda DOSVEC+1
            adc #$00
            sta crname+2
* set lsio
            lda DOSVEC
            sec
            sbc #$0A
            sta Z_LSIO
            sta lsio+1
            lda DOSVEC+1
            sbc #$00
            sta Z_LSIO+1
            sta lsio+2
* close IOCB 1 and get parameter
            jsr close_1
            jsr get_path
            jsr get_name
* open director for read IOCB 1
            ldx #$10
            lda #$03
            sta IOCB0+ICCOM,X
            lda <BUFFER
            sta IOCB0+ICBAL,X
            lda >BUFFER
            sta IOCB0+ICBAH,X
            lda #$14
            sta IOCB0+ICBLH,X
            sta IOCB0+ICAX1,X
            lda #$00
            sta IOCB0+ICAX2,X
            jsr CIOV
            bpl srch_entry
bra_error   jmp error
* directory entries IOCB 1
srch_entry  ldx #$10
            lda #$07
            sta IOCB0+ICCOM,X
            lda <DIR_ENTRY
            sta IOCB0+ICBAL,X
            lda >DIR_ENTRY
            sta IOCB0+ICBAH,X
            lda #$17
            sta IOCB0+ICBLL,X
            lda #$00
            sta IOCB0+ICBLH,X
            jsr CIOV
            bpl chk_entry
            cpy #$88
            bne bra_error
            jsr _print
            dta b($9B)
            dta c'Error: File not found!'
            dta b($9B,$00)
            jmp error_exit
* check dir entry for file name
chk_entry   ldx #$0A
L61D7       lda INT_NAME,X
            cmp #'?'
            beq L61E3
            cmp DIR_ENTRY+6,X
            bne srch_entry
L61E3       dex
            bpl L61D7
* check for used + non directory entry
            lda DIR_ENTRY
            and #$28
            cmp #$08
            bne srch_entry
* close IOCB 1
            jsr close_1
* read sector 1
            jsr read_sec
* copy sector number of first sector map
            lda DIR_ENTRY+1
            sta BUFFER+$28
            lda DIR_ENTRY+2
            sta BUFFER+$28+1
* write sector back
            jsr write_sec
* print success and exit to DOS
            jsr _print
            dta b($9B)
            dta c'Boot file installed.'
            dta b($9B,$00)
            jmp (DOSVEC)

* read/write first sector of boot drive
read_sec    lda #$52
            ldy #$40
            bne do_sio
* set write command from WRTCMD
write_sec   ldy #$08
            lda (Z_LSIO),Y
            ldy #$80
* execute sio command
do_sio      sta _dcomnd
            sty _dstats
            ldx #$0B
cp_cb_loop  lda _ddevic,X
            sta DDEVIC,X
            dex
            bpl cp_cb_loop
            jsr lsio
            tya
            bmi sio_error
            rts
sio_error   jmp error

            icl '_PRINT.ASM'

* call CRNAME
crname      jmp exe_rts

* check and get file and path name
get_path    jsr crname
            ldx #$00
* get drive number
            ldy #$22
            lda (DOSVEC),Y
            and #$0F
            sta _dunit
            dey
* get path and last path seperator
sep_found   stx LAST_SEP
next_char   lda (DOSVEC),Y
            sta BUFFER,X
            inx
            iny
            cmp #':'
            beq sep_found
            cmp #'>'
            beq sep_found
            cmp #'<'
            beq sep_found
            cmp #$9B
            bne next_char
exe_rts     rts

* convert name to internal name
get_name    ldx LAST_SEP
            ldy #$00
            lda #$06
            sta EXT_FLAG
            dex
char_loop   inx
            lda BUFFER,X
            cmp #'*'
            beq set_quest
            cmp #'.'
            beq set_space
            cmp #'?'
            beq no_check
            jsr check_char
            bcs set_spaces
no_check    jsr set_char
            jmp char_loop

set_char    cpy #$08
            bcc set_ok
            bit EXT_FLAG
            bpl no_set
            cpy #$0B
            bcc set_ok
no_set      rts
set_ok      sta INT_NAME,Y
            iny
            rts

set_quest   lda #'?'
            jsr set_char
            bcc set_quest
            bcs char_loop

set_spaces  sec
            ror EXT_FLAG
set_space   lda #$20
            jsr set_char
            bcc set_space
            ror EXT_FLAG
            bcc char_loop
            rts

* print error
error       tya
            pha
            jsr _print
            dta b($9B)
            dta c'Error '
            dta b($00)
* output error number in decimal
            ldx #$02
            pla
dec_loop    ldy #$00
sbc_loop    cmp decimal,X
            bcc next_dec
            sbc decimal,X
            iny
            bne sbc_loop
next_dec    pha
            txa
            pha
            tya
            ora #$30
            jsr _putc
            pla
            tax
            pla
            dex
            bpl dec_loop
            lda #$9B
            jsr _putc
* stop batch
error_exit  ldy #$08
            lda (DOSVEC),Y
            sta xdivio+1
            iny
            lda (DOSVEC),Y
            sta xdivio+2
            ldy #$01
xdivio      jsr WARMSV
            jsr close_1
            jmp (DOSVEC)

* array with decimals
decimal     dta b(1,10,100)

* close IOCB 1
close_1     ldx #$10
            lda #$0C
            sta IOCB0+ICCOM,X
            jmp CIOV

* check char for _ or 0-9 or A-Z 
check_char  cmp #'_'
            beq char_ok
            cmp #'0'
            bcc char_not_ok
            cmp #':' ; char after 9
            bcc char_ok
            cmp #'A'
            bcc char_not_ok
            cmp #'[' ; char after Z
            bcs char_not_ok
char_ok     clc
            rts
char_not_ok sec
            rts

* SIO device control block
_ddevic     dta b($31)
_dunit      dta b($00)
_dcomnd     dta b($00)
_dstats     dta b($00)
_dbuflh     dta a(BUFFER)
_dtimlo     dta b($07)
_dunuse     dta b($00)
_dbytlh     dta a($0080)
* sector number $0001
_daux1      dta b($01)
_daux2      dta b($00)

* local SIO call
lsio        jmp ($FFFF)

            end
