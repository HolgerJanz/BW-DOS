; BW-DOS 1.5 Command SORTDIR [/R] path ..

; System equates
         icl '_SYSEQU.ICL'

ZBUF_SIZ equ $80
ZDIR_SIZ equ $82
ZDIR_CI1 equ $84
ZDIR_CI2 equ $86
ZDIR_CU1 equ $88
ZDIR_CU2 equ $8A
ZSWP_FLG equ $8C
ZTEMP    equ $8D

         blk dos $2800
; check BW-DOS 1.5
         icl '_TSTBW15.ICL'

         lda #0 
         sta SRT_REC
         sta SRT_PROK

         sec
         lda MEMTOP
         sbc <SRT_BUFF
         sta ZBUF_SIZ
         lda MEMTOP+1
         sbc >SRT_BUFF
         sta ZBUF_SIZ+1

         lda #$9b
         jsr _putc

; parameter loop
nxt_par  jsr get_par  ; next parameter

         jsr chk_opt  ; check option
         bcs nxt_par

         lda #1
         sta SRT_PROK

         jsr ini_var  ; initialize variables

nxt_del  jsr prn_pmsg ; print message

         jsr srt_fil  ; sort files

         lda SRT_REC  ; check for recursive
         beq nxt_par

nxt_sub  jsr get_sub  ; get subdir
         bcs prv_del

         jsr psh_sub
         jmp nxt_del

prv_del  jsr pop_sub
         bcc nxt_sub
         bcs nxt_par

; ********** subroutines *************
         icl '_PRINT.ICL'

; get next parameter, if not exit
get_par  ldx BW_BUFOFF
         lda BW_LBUF,X
         cmp #$9b
         bne get_pok
         lda SRT_PROK
         bne get_pex
; no parameter -> print info end exit
         jsr _print
         dta c'SORTDIR for BW-DOS 1.5'
         dta b($9B)
         dta c'Use: SORTDIR [/R] path ..'
         dta b($9B,$00)
get_pex  jmp (DOSVEC)
get_pok  jsr BW_CRNAME
         rts

; check for option /R
; if found, c=1
chk_opt  lda BW_COMFNAM+3
         cmp #'/'
         bne chk_oend
         lda BW_COMFNAM+4
         cmp #'R'
         bne chk_oerr
         lda BW_COMFNAM+5
         cmp #$9B
         bne chk_oerr
         lda #$01
         sta SRT_REC
         sec
         rts
chk_oend clc
         rts
chk_oerr lda #$9C ; parameter error
         jmp (BW_FAIL)

; initialize variables
ini_var  lda #$00
         ldx <_DTA_END-_DTA_STR
ini_vl1  sta _DTA_STR-1,X
         dex
         bne ini_vl1
; first dir seek set to 23
         lda #23 ; ignore first dir entry
         sta SRT_STKL
; check for :, end ignore
         lda BW_COMFNAM+3
         cmp #':'
         bne ini_gpss
         lda BW_COMFNAM+4
         cmp #$9b
         bne ini_gpss
         sta BW_COMFNAM+3
; get path and set seperator offset
ini_gpss ldx #$FF
ini_vl2  inx
         lda BW_COMFNAM,X
         sta SRT_PTH,X
         cmp #$9b
         bne ini_vl2
         stx SRT_PTHS
         stx SRT_PTHI
         rts

; print path message
prn_pmsg ldx #$00
         lda <SRT_MSG
         sta IOCB0+ICBAL,X
         lda >SRT_MSG
         sta IOCB0+ICBAH,X
         lda #$ff
         sta IOCB0+ICBLL,X
         lda #$00
         sta IOCB0+ICBLH,X
         lda #$09 ; put record
         sta IOCB0+ICCOM,X
         jsr CIOV
         bpl srt_fno
         tya
         jmp (BW_FAIL)
srt_fno  rts

; sort directory in buffer
srt_do   lda #0
         sta ZSWP_FLG

         lda ZDIR_CI1
         sta ZDIR_CU1
         lda ZDIR_CI1+1
         sta ZDIR_CU1+1

         lda ZDIR_CI2
         sta ZDIR_CU2
         lda ZDIR_CI2+1
         sta ZDIR_CU2+1

srt_loop ldy #0
; free flag
         lda (ZDIR_CU1),Y
         and #$10 ; free flag
         sta ZTEMP
         lda (ZDIR_CU2),Y
         and #$10 ; free flag
         cmp ZTEMP
         bcc _srt_swp
         bne srt_nxt
; do sort free entries by name
         lda ZTEMP
         bne srt_nxt
; subdir
         lda (ZDIR_CU2),Y
         and #$20 ; dir flag
         sta ZTEMP
         lda (ZDIR_CU1),Y
         and #$20 ; dir flag
         cmp ZTEMP
         bcc _srt_swp
         bne srt_nxt
; character 1
         ldy #6
         lda (ZDIR_CU2),Y
         cmp (ZDIR_CU1),Y
         bcc _srt_swp
         bne srt_nxt
; character 2
         iny
         lda (ZDIR_CU2),Y
         cmp (ZDIR_CU1),Y
         bcc srt_swp
         bne srt_nxt
; character 3
         iny
         lda (ZDIR_CU2),Y
         cmp (ZDIR_CU1),Y
         bcc srt_swp
         bne srt_nxt
; character 4
         iny
         lda (ZDIR_CU2),Y
         cmp (ZDIR_CU1),Y
         bcc srt_swp
         bne srt_nxt
; character 5
         iny
         lda (ZDIR_CU2),Y
         cmp (ZDIR_CU1),Y
         bcc srt_swp
         bne srt_nxt
; character 6
         iny
         lda (ZDIR_CU2),Y
         cmp (ZDIR_CU1),Y
         bcc srt_swp
         bne srt_nxt
; character 7
         iny
         lda (ZDIR_CU2),Y
         cmp (ZDIR_CU1),Y
         bcc srt_swp
         bne srt_nxt
; character 8
         iny
         lda (ZDIR_CU2),Y
         cmp (ZDIR_CU1),Y
         bcc srt_swp
         bne srt_nxt
; character 9
         iny
         lda (ZDIR_CU2),Y
         cmp (ZDIR_CU1),Y
         bcc srt_swp
         bne srt_nxt
; character 10
         iny
         lda (ZDIR_CU2),Y
         cmp (ZDIR_CU1),Y
_srt_swp bcc srt_swp
         bne srt_nxt
; character 11
         iny
         lda (ZDIR_CU2),Y
         cmp (ZDIR_CU1),Y
         bcc srt_swp

srt_nxt  sec
         lda ZDIR_CU1
         sta ZDIR_CU2
         sbc #23
         sta ZDIR_CU1
         lda ZDIR_CU1+1
         sta ZDIR_CU2+1
         sbc #0
         sta ZDIR_CU1+1

         cmp >SRT_BUFF
         bcc srt_chk
         bne srt_jlp
         lda ZDIR_CU1
         cmp <SRT_BUFF
         bcc srt_chk
srt_jlp  jmp srt_loop

srt_chk  lda ZSWP_FLG
         beq srt_doe
         jmp srt_do

srt_doe  rts

; byte 1
srt_swp  ldy #0
         lda (ZDIR_CU1),Y
         tax
         lda (ZDIR_CU2),Y
         sta (ZDIR_CU1),Y
         txa
         sta (ZDIR_CU2),Y
; byte 2
         iny
         lda (ZDIR_CU1),Y
         tax
         lda (ZDIR_CU2),Y
         sta (ZDIR_CU1),Y
         txa
         sta (ZDIR_CU2),Y
; byte 3
         iny
         lda (ZDIR_CU1),Y
         tax
         lda (ZDIR_CU2),Y
         sta (ZDIR_CU1),Y
         txa
         sta (ZDIR_CU2),Y
; byte 4
         iny
         lda (ZDIR_CU1),Y
         tax
         lda (ZDIR_CU2),Y
         sta (ZDIR_CU1),Y
         txa
         sta (ZDIR_CU2),Y
; byte 5
         iny
         lda (ZDIR_CU1),Y
         tax
         lda (ZDIR_CU2),Y
         sta (ZDIR_CU1),Y
         txa
         sta (ZDIR_CU2),Y
; byte 6
         iny
         lda (ZDIR_CU1),Y
         tax
         lda (ZDIR_CU2),Y
         sta (ZDIR_CU1),Y
         txa
         sta (ZDIR_CU2),Y
; byte 7
         iny
         lda (ZDIR_CU1),Y
         tax
         lda (ZDIR_CU2),Y
         sta (ZDIR_CU1),Y
         txa
         sta (ZDIR_CU2),Y
; byte 8
         iny
         lda (ZDIR_CU1),Y
         tax
         lda (ZDIR_CU2),Y
         sta (ZDIR_CU1),Y
         txa
         sta (ZDIR_CU2),Y
; byte 9
         iny
         lda (ZDIR_CU1),Y
         tax
         lda (ZDIR_CU2),Y
         sta (ZDIR_CU1),Y
         txa
         sta (ZDIR_CU2),Y
; byte 10
         iny
         lda (ZDIR_CU1),Y
         tax
         lda (ZDIR_CU2),Y
         sta (ZDIR_CU1),Y
         txa
         sta (ZDIR_CU2),Y
; byte 11
         iny
         lda (ZDIR_CU1),Y
         tax
         lda (ZDIR_CU2),Y
         sta (ZDIR_CU1),Y
         txa
         sta (ZDIR_CU2),Y
; byte 12
         iny
         lda (ZDIR_CU1),Y
         tax
         lda (ZDIR_CU2),Y
         sta (ZDIR_CU1),Y
         txa
         sta (ZDIR_CU2),Y
; byte 13
         iny
         lda (ZDIR_CU1),Y
         tax
         lda (ZDIR_CU2),Y
         sta (ZDIR_CU1),Y
         txa
         sta (ZDIR_CU2),Y
; byte 14
         iny
         lda (ZDIR_CU1),Y
         tax
         lda (ZDIR_CU2),Y
         sta (ZDIR_CU1),Y
         txa
         sta (ZDIR_CU2),Y
; byte 15
         iny
         lda (ZDIR_CU1),Y
         tax
         lda (ZDIR_CU2),Y
         sta (ZDIR_CU1),Y
         txa
         sta (ZDIR_CU2),Y
; byte 16
         iny
         lda (ZDIR_CU1),Y
         tax
         lda (ZDIR_CU2),Y
         sta (ZDIR_CU1),Y
         txa
         sta (ZDIR_CU2),Y
; byte 17
         iny
         lda (ZDIR_CU1),Y
         tax
         lda (ZDIR_CU2),Y
         sta (ZDIR_CU1),Y
         txa
         sta (ZDIR_CU2),Y
; byte 18
         iny
         lda (ZDIR_CU1),Y
         tax
         lda (ZDIR_CU2),Y
         sta (ZDIR_CU1),Y
         txa
         sta (ZDIR_CU2),Y
; byte 19
         iny
         lda (ZDIR_CU1),Y
         tax
         lda (ZDIR_CU2),Y
         sta (ZDIR_CU1),Y
         txa
         sta (ZDIR_CU2),Y
; byte 20
         iny
         lda (ZDIR_CU1),Y
         tax
         lda (ZDIR_CU2),Y
         sta (ZDIR_CU1),Y
         txa
         sta (ZDIR_CU2),Y
; byte 21
         iny
         lda (ZDIR_CU1),Y
         tax
         lda (ZDIR_CU2),Y
         sta (ZDIR_CU1),Y
         txa
         sta (ZDIR_CU2),Y
; byte 22
         iny
         lda (ZDIR_CU1),Y
         tax
         lda (ZDIR_CU2),Y
         sta (ZDIR_CU1),Y
         txa
         sta (ZDIR_CU2),Y
; byte 23
         iny
         lda (ZDIR_CU1),Y
         tax
         lda (ZDIR_CU2),Y
         sta (ZDIR_CU1),Y
         txa
         sta (ZDIR_CU2),Y

         lda #1
         sta ZSWP_FLG

         jmp srt_nxt

; sort files
srt_fil  ldy #$04+32 ; read raw mode and path
         jsr opn_dir
; read directory data
         ldx #$10
         lda #$07 ; read dir entry
         sta IOCB0+ICCOM,X
         lda <SRT_BUFF
         sta IOCB0+ICBAL,X
         lda >SRT_BUFF
         sta IOCB0+ICBAH,X
         lda ZBUF_SIZ
         sta IOCB0+ICBLL,X
         lda ZBUF_SIZ+1
         sta IOCB0+ICBLH,X
         jsr CIOV
         cpy #$03 ; last byte read
         beq srt_frde
         cpy #$88 ; check end of file
         beq srt_frde
         cpy #01 ; not completely read
         bne get_serr
         ldy #$93 ; not enough memory
         bne get_serr
srt_frde jsr cls_dir
; set real size and cursors
         ldx #$10
; check for at least 2 directory entries
         lda IOCB0+ICBLH,X
         bne srt_srsc
         lda IOCB0+ICBLL,X
         cmp #23*2
         bcc srt_end

srt_srsc clc
         lda IOCB0+ICBLL,X
         sta ZDIR_SIZ
         adc <SRT_BUFF
         sta ZDIR_CI2
         lda IOCB0+ICBLH,X
         sta ZDIR_SIZ+1
         adc >SRT_BUFF
         sta ZDIR_CI2+1

         sec
         lda ZDIR_CI2
         sbc #23
         sta ZDIR_CI2
         lda ZDIR_CI2+1
         sbc #0
         sta ZDIR_CI2+1

         sec
         lda ZDIR_CI2
         sbc #23
         sta ZDIR_CI1
         lda ZDIR_CI2+1
         sbc #0
         sta ZDIR_CI1+1
; sort
         jsr srt_do
; write directory data
         ldy #$08+32 ; write raw mode and path
         jsr opn_dir
         ldx #$10
         lda #$0B ; write dir entry
         sta IOCB0+ICCOM,X
         lda <SRT_BUFF
         sta IOCB0+ICBAL,X
         lda >SRT_BUFF
         sta IOCB0+ICBAH,X
         lda ZDIR_SIZ
         sta IOCB0+ICBLL,X
         lda ZDIR_SIZ+1
         sta IOCB0+ICBLH,X
         jsr CIOV
         bmi get_serr
         jsr cls_dir

srt_end  rts

get_serr tya
         jmp (BW_FAIL)

; subroutines open and close directory

opn_dir  ldx #$10
         lda #$03 ; open dir
         sta IOCB0+ICCOM,X
         lda <SRT_PTH
         sta IOCB0+ICBAL,X
         lda >SRT_PTH
         sta IOCB0+ICBAH,X
; if Dx:, Dx:>, or Dx:< then subtract $10
         tya
         ldx SRT_PTHS
         cpx #4
         bne opn_cdd
;  check for Dx:> or Dx:<
         dex
         ldy SRT_PTH,X
         cpy #'>'
         beq opn_d16
         cpy #'<'
         beq opn_d16
         bne opn_d32
;  check for Dx:
opn_cdd  cpx #3
         bne opn_d32
; raw and ignore file
opn_d16  sec
         sbc #$10
; raw with path
opn_d32  ldx #$10
         sta IOCB0+ICAX1,X
         lda #$00
         sta IOCB0+ICAX2,X
         jsr CIOV
_get_ser bmi get_serr
         rts

cls_dir  ldx #$10 ; close dir
         lda #$0C
         sta IOCB0+ICCOM,X
         jsr CIOV
         bmi get_serr
         rts

; get subdir
get_sub  ldy #$04+32 ; raw mode and path
         jsr opn_dir

         ldx #$10
         lda #$25 ; point
         sta IOCB0+ICCOM,X
         ldy SRT_STKP
         lda SRT_STKL,Y
         sta IOCB0+ICAX3,X
         lda SRT_STKH,Y
         sta IOCB0+ICAX4,X
         lda #$00
         sta IOCB0+ICAX5,X
         jsr CIOV
         bmi get_serr

get_snxt ldx #$10
         lda #$07 ; read dir entry
         sta IOCB0+ICCOM,X
         lda <RDDIRBUF
         sta IOCB0+ICBAL,X
         lda >RDDIRBUF
         sta IOCB0+ICBAH,X
         lda #23
         sta IOCB0+ICBLL,X
         lda #$00
         sta IOCB0+ICBLH,X
         jsr CIOV
         bpl get_schk
         cpy #$88 ; check end of file
         beq get_send
         jmp get_serr

get_schk lda RDDIRBUF
         beq get_send
         and #%00101001 ; used, dir, and not protected
         cmp #%00101000
         bne get_snxt

         ldx #$10
         lda #$26 ; note
         sta IOCB0+ICCOM,X
         jsr CIOV
         bmi _get_ser

         ldx #$10 ; save note
         ldy SRT_STKP
         lda IOCB0+ICAX3,X
         sta SRT_STKL,Y
         lda IOCB0+ICAX4,X
         sta SRT_STKH,Y

         jsr cls_dir ; found
         clc
         rts

get_send jsr cls_dir ; not found
         sec
         rts

; push subdirectory
psh_sub  inc SRT_STKP
         ldx SRT_STKP
         cpy #$10
         bcc psh_sok
psh_err  lda #$B6 ; path too long
         jmp (BW_FAIL)
;  set point stack
psh_sok  lda #23
         sta SRT_STKL,X
         lda #0
         sta SRT_STKH,X
;  add path
         ldy #$FF
         ldx SRT_PTHS
         cpx #3
; if only Dx: then do not add >
         beq psh_ngt
         lda #'>'
         cmp SRT_PTH-1,X
; if only Dx:> then do not add >
         beq psh_ngt
         sta SRT_PTH,X
psh_dlop inx
psh_ngt  iny
         lda RDDIRBNM,Y
         cmp #' '
         bne psh_pset
         cpy #8
         bcs add_eol
         lda RDDIRBNM+8
         cmp #' '
         beq add_eol
         ldy #7
         lda #'.'

psh_pset sta SRT_PTH,X
         cpy #10
         bcc psh_dlop

         inx
add_eol  lda #$9b
         sta SRT_PTH,X
         stx SRT_PTHS

         rts

; pop subdirectory
pop_sub  ldx SRT_STKP
         php
         lda #0
         sta SRT_STKL,X
         sta SRT_STKH,X
         plp
         bne pop_sdir
         sec
         rts

pop_sdir dec SRT_STKP

         ldx SRT_PTHS
pop_pslp dex
         cpx SRT_PTHI
         beq pop_apat
         bcc pop_apat
         lda SRT_PTH,X
         cmp #'>'
         beq pop_apat
         cmp #'<'
         beq pop_apat
         bne pop_pslp

pop_apat jsr add_eol
         clc
         rts

; ********** data block *************

SRT_REC  dta b(0)
SRT_PROK dta b(0)
SRT_MSG  dta c'Sorting: ' ; message
_DTA_STR equ *
SRT_PTH  equ _DTA_STR      ; current path
SRT_STKP equ SRT_PTH+128   ; current stack pointer
SRT_STKL equ SRT_STKP+1    ; directory position low
SRT_STKH equ SRT_STKL+16   ; directory position high
SRT_OK   equ SRT_STKH+16   ; flag, something was deleted
SRT_TMP  equ SRT_OK+1      ; temporary variable
SRT_PTHS equ SRT_TMP+1     ; path offset of last separator
SRT_PTHI equ SRT_PTHS+1    ; starting path offset
RDDIRBUF equ SRT_PTHI+1    ; dir entry buffer
RDDIRBNM equ RDDIRBUF+6    ; name in dir buff
_DTA_END equ RDDIRBUF+23

SRT_BUFF equ _DTA_END

         end
