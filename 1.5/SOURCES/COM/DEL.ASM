; BW-DOS 1.5 Command DEL path

         icl '_SYSEQU.ICL'

         blk dos $3000
         icl '_TSTBW15.ICL'

         lda #0 
         sta DEL_REC
         sta DEL_QT
         sta DEL_PROK

         lda #$9b
         jsr _putc

; parameter loop
nxt_par  jsr get_par  ; next parameter

         jsr chk_opt  ; check option
         bcs nxt_par

         lda #1
         sta DEL_PROK

         jsr ini_var  ; initialize variables

nxt_del  jsr prn_pmsg ; print message

         jsr del_fil  ; delete files

         lda DEL_REC  ; check for recursive
         beq nxt_par

nxt_sub  jsr get_sub  ; get subdir
         bcs prv_del

         jsr psh_sub
         jmp nxt_del

prv_del  jsr pop_sub
         bcc nxt_sub

         lda DEL_ROOT
         beq nxt_par
         jsr del_sub

         jmp nxt_par

         icl '_PRINT.ICL'

get_par  ldx BW_BUFOFF
         lda BW_LBUF,X
         cmp #$9b
         bne get_pok
         lda DEL_PROK
         bne get_pex
         jsr _print
         dta c'DEL for BW-DOS 1.5'
         dta b($9B)
         dta c'Use: DEL [/RQ] files ..'
         dta b($9B,$00)
get_pex  jmp (DOSVEC)
get_pok  jsr BW_CRNAME
         rts

; if no option param, c=1
chk_opt  lda BW_COMFNAM+3
         cmp #'/'
         bne chk_oend

         ldx #$03
chk_nxt  inx
         lda BW_COMFNAM,X

         cmp #'R'
         bne chk_qt
         lda #$01
         sta DEL_REC
         bne chk_nxt

chk_qt   cmp #'Q'
         bne chk_eol
         lda #$01
         sta DEL_QT
         bne chk_nxt

chk_eol  cmp #$9B
         bne chk_oerr

         sec
         rts

chk_oend clc
         rts

chk_oerr lda #$9C ; parameter error
         jmp (BW_FAIL)

ini_var  lda #$00
         ldx <_DTA_END-_DTA_STR
ini_vl1  sta _DTA_STR-1,X
         dex
         bne ini_vl1
; first dir seek set to 23
         lda #23
         sta DEL_STKL
; get path and set seperator offset
         lda #$02
         sta DEL_PTHS
         ldx #$FF
ini_vl2  inx
         lda BW_COMFNAM,X
         sta DEL_PTH,X
         cmp #'<'
         bne ini_vc1
         stx DEL_PTHS
ini_vc1  cmp #'>'
         bne ini_vc2
         stx DEL_PTHS
ini_vc2  cmp #$9b
         bne ini_vl2
         dex
; add *.* if necessary
         cpx DEL_PTHS
         bne ini_cdir

ini_stdp inx
         ldy #$00
ini_vl3  lda BW_STDPAT,Y
         sta DEL_PTH,X
         inx
         iny
         cpy #$04
         bcc ini_vl3
         bcs ini_patt
; check for subdirectory if no wildcart
ini_cdir stx DEL_TMP
         ldx DEL_PTHS
ini_cwc  inx
         lda DEL_PTH,X
         cmp #'*'
         beq ini_patt
         cmp #'?'
         beq ini_patt
         cmp #$9b
         bne ini_cwc
         ldy #$04+32 ; raw mode, path
         jsr opn_dir
         php
         jsr cls_dir
         plp
         bmi ini_patt
         ldx DEL_TMP
         inx
         lda #'>'
         sta DEL_PTH,X
         stx DEL_PTHS
         stx DEL_ROOT
         bne ini_stdp
; get pattern
ini_patt ldx DEL_PTHS
         inx
         ldy #$00
ini_patl lda DEL_PTH,X
         sta DEL_PATT,Y
         inx
         iny
         cmp #$9B
         bne ini_patl
         rts

prn_pmsg lda DEL_QT
         bne del_fno
         ldx #$00
         lda <DEL_MSG
         sta IOCB0+ICBAL,X
         lda >DEL_MSG
         sta IOCB0+ICBAH,X
         lda #$ff
         sta IOCB0+ICBLL,X
         lda #$00
         sta IOCB0+ICBLH,X
         lda #$09 ; put record
         sta IOCB0+ICCOM,X
         jsr CIOV
         bpl del_fno
         tya
         jmp (BW_FAIL)

del_fil  ldx #$10
         lda #$21 ; delete files
         sta IOCB0+ICCOM,X
         lda <DEL_PTH
         sta IOCB0+ICBAL,X
         lda >DEL_PTH
         sta IOCB0+ICBAH,X
         lda #128
         sta IOCB0+ICBLL,X
         lda #0
         sta IOCB0+ICBLH,X
         jsr CIOV
         bpl del_fok
         cpy #$AA ; file not found
         beq del_fno
         tya
         jmp (BW_FAIL)
del_fok  lda #$01
         sta DEL_OK
del_fno  rts

opn_dir  ldx #$10
         lda #$03 ; open dir
         sta IOCB0+ICCOM,X
         lda <DEL_PTH
         sta IOCB0+ICBAL,X
         lda >DEL_PTH
         sta IOCB0+ICBAH,X
         tya
         sta IOCB0+ICAX1,X
         lda #$00
         sta IOCB0+ICAX2,X
         jsr CIOV
         rts

cls_dir  ldx #$10 ; close dir
         lda #$0C
         sta IOCB0+ICCOM,X
         jsr CIOV
         bmi get_serr
         rts

get_sub  ldy #$04+16 ; raw mode and ignore fname
         jsr opn_dir
         bpl get_ssk
get_serr tya
         jmp (BW_FAIL)

get_ssk  ldx #$10
         lda #$25 ; point
         sta IOCB0+ICCOM,X
         ldy DEL_STKP
         lda DEL_STKL,Y
         sta IOCB0+ICAX3,X
         lda DEL_STKH,Y
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
         bmi get_serr

         ldx #$10 ; save note
         ldy DEL_STKP
         lda IOCB0+ICAX3,X
         sta DEL_STKL,Y
         lda IOCB0+ICAX4,X
         sta DEL_STKH,Y

         jsr cls_dir ; found
         clc
         rts

get_send jsr cls_dir ; not found
         sec
         rts

del_sub  ldx DEL_PTHS
         lda DEL_PTH,X
         pha
         lda #$9b
         sta DEL_PTH,X

         ldx #$10
         lda #$2B ; remove dir
         sta IOCB0+ICCOM,X
         lda <DEL_PTH
         sta IOCB0+ICBAL,X
         lda >DEL_PTH
         sta IOCB0+ICBAH,X
         jsr CIOV
         bpl del_sbok
         cpy #$A7 ; ignore non-empty subdirs
         beq del_sbok
         tya
         jmp (BW_FAIL)

del_sbok pla
         ldx DEL_PTHS
         sta DEL_PTH,X
         rts

psh_sub  inc DEL_STKP
         ldx DEL_STKP
         cpy #$10
         bcc psh_sok
psh_err  lda #$B6 ; path too long
         jmp (BW_FAIL)
;  set point stack
psh_sok  lda #23
         sta DEL_STKL,X
         lda #0
         sta DEL_STKH,X
;  add path
         ldx DEL_PTHS
         ldy #$FF
psh_dlop inx
         iny
         lda RDDIRBNM,Y
         cmp #' '
         bne psh_pset
         cpy #8
         bcs psh_pend
         lda RDDIRBNM+8
         cmp #' '
         beq psh_pend
         ldy #7
         lda #'.'

psh_pset sta DEL_PTH,X
         cpy #10
         bcc psh_dlop

         inx
psh_pend lda #'>'
         sta DEL_PTH,X
         stx DEL_PTHS
         inx

add_path ldy #0
psh_plop lda DEL_PATT,Y
         sta DEL_PTH,X
         inx
         bmi psh_err
         iny
         cmp #$9b
         bne psh_plop

         rts

pop_sub  ldx DEL_STKP
         php
         lda #0
         sta DEL_STKL,X
         sta DEL_STKH,X
         plp
         bne pop_sdir
         sec
         rts

pop_sdir jsr del_sub
         dec DEL_STKP

         ldx DEL_PTHS
pop_pslp dex
         cpx #03
         bcc pop_apat
         lda DEL_PTH,X
         cmp #'>'
         beq pop_apat
         cmp #'<'
         beq pop_apat
         bne pop_pslp

pop_apat stx DEL_PTHS
         inx
         jsr add_path
         clc
         rts

DEL_REC  dta b(0)
DEL_QT   dta b(0)
DEL_PROK dta b(0)
DEL_MSG  dta c'Deleting ' ; message
_DTA_STR equ *
DEL_PTH  equ _DTA_STR    ; current path
DEL_STKP equ DEL_PTH+128 ; current stack pointer
DEL_STKL equ DEL_STKP+1  ; directory position low
DEL_STKH equ DEL_STKL+16 ; directory position high
DEL_OK   equ DEL_STKH+16 ; flag, something was deleted
DEL_TMP  equ DEL_OK+1    ; temporary variable
DEL_ROOT equ DEL_TMP+1   ; flag, delete root directory
DEL_PTHS equ DEL_ROOT+1  ; path offset of last separator
RDDIRBUF equ DEL_PTHS+1  ; dir entry buffer
RDDIRBNM equ RDDIRBUF+6  ; name in dir buff
DEL_PATT equ RDDIRBUF+23 ; pattern buffer
_DTA_END equ DEL_PATT+24

         end
