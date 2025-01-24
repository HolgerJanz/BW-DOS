* BW-DOS Command REN file new_name

* System equates
         icl '_SYSEQU.ICL'

         blk dos $400
         icl '_TSTBW14.ICL'
         lda #$00
         sta ren_bufx
* get file
         jsr BW_CRNAME
         beq par_err
         ldx #$00
         stx only_fnm
         stx dot_cnt
         jsr get_name
         ldx ren_bufx
         lda #','
         sta ren_buf,X
         stx ren_bufs
         inc ren_bufx
* get new name
         jsr BW_CRNAME
         beq par_err
         ldx #$FE
         stx dot_cnt
         ldx #$03
         stx only_fnm
         jsr get_name
         cpx #17
         bcs par_err
         ldx ren_bufx
         lda #$9b
         sta ren_buf,X
         inc ren_bufx
* too many parameter
         jsr BW_CRNAME
         bne par_err
* execute CD command
         lda #$20 ; rename
         sta IOCB0+ICCOM+$10
         lda <ren_buf
         sta IOCB0+ICBAL+$10
         lda >ren_buf
         sta IOCB0+ICBAH+$10
         lda ren_bufx
         sta IOCB0+ICBLL+$10
         lda #0
         sta IOCB0+ICBLH+$10
         ldx #$10
         jsr CIOV
* check error
         bmi ren_err
         rts

ren_err  cpy #$AA ; not found -> ren dir
         beq ren_dir
error1   tya
         jmp (BW_FAIL)

par_err  lda #$9C ; parameter error
         jmp (BW_FAIL)

open     lda #$03
         sta IOCB0+ICCOM+$10
         lda <ren_buf
         sta IOCB0+ICBAL+$10
         lda >ren_buf
         sta IOCB0+ICBAH+$10
         stx IOCB0+ICAX1+$10
         lda #0
         sta IOCB0+ICAX2+$10
ciov10   ldx #$10
         jsr CIOV
         bmi error1
         rts

close    lda #12
         sta IOCB0+ICCOM+$10
         jmp ciov10

pnt_not  sta IOCB0+ICCOM+$10
         stx IOCB0+ICAX3+$10
         sty IOCB0+ICAX4+$10
         lda #0
         sta IOCB0+ICAX5+$10
         jmp ciov10

point0   lda #37 ; point first entry
         ldx #0
         ldy #0
         jmp pnt_not

rd_wr    stx IOCB0+ICCOM+$10
         lda <dir_buf
         sta IOCB0+ICBAL+$10
         lda >dir_buf
         sta IOCB0+ICBAH+$10
         lda #23
         sta IOCB0+ICBLL+$10
         lda #0
         sta IOCB0+ICBLH+$10
         jmp ciov10

* try rename directory
ren_dir  lda #$9b
         ldx ren_bufs
         sta ren_buf,X
* open dir to be renamed
         ldx #4+32 ; read, no create
         jsr open
* point to first entry
         jsr point0
* read first entry
         ldx #7
         jsr rd_wr
         jsr close
* get old name
         ldx #10
nxt_old  lda dir_name,X
         sta old_name,X
         dex
         bpl nxt_old
* get new name
         ldx ren_bufs
         ldy #0
nxt_new  inx
         lda ren_buf,X
         cmp #$9b
         bne chk_nxt1
         lda #' '
nxt_002  sta new_name,Y
         iny
         cpy #10
         bcc nxt_002
chk_nxt1 cmp #'.'
         bne chk_nxt2
         lda #' '
nxt_001  sta new_name,Y
         iny
         cpy #8
         bcc nxt_001
         bcs nxt_new
chk_nxt2 cmp #'*'
         beq wc_error
         cmp #'?'
         beq wc_error
         sta new_name,Y
         iny
         cpy #11
         bcc nxt_new
* set new name to subdir
         jsr set_new
* write subdir
         ldx #12+32 ; udate
         jsr open
         jsr point0
         ldx #11
         jsr rd_wr
         jsr close
* write new name in directory
         ldx #12+16 ; update
         jsr open
* find entry
nxt_dir  ldx #7
         jsr rd_wr
         lda dir_buf
         and #$28
         cmp #$28
         bne nxt_dir
         ldx #$00
nxt_003  lda dir_name,X
         cmp old_name,X
         bne nxt_dir
         inx
         cpx #11
         bne nxt_003
* point back to last entry
         lda #38
         jsr pnt_not
         sec
         lda IOCB0+ICAX3+$10
         sbc #23
         tax
         lda IOCB0+ICAX4+$10
         sbc #0
         tay
         lda #37
         jsr pnt_not
* write new name
         jsr set_new
         ldx #11
         jsr rd_wr
         jsr close
         rts

set_new  ldx #10
nxt_snew lda new_name,X
         sta dir_name,X
         dex
         bpl nxt_snew
         rts

wc_error lda #$A3
         jmp (BW_FAIL)

get_name ldy ren_bufx
_lname   lda BW_COMFNAM,X
         inx
         cmp #$9b
         bne _lname1
         sty ren_bufx
         rts
_lname1  cmp #'.'
         beq chk_dok
         cmp #'*'
         beq chk_ok

         cmp #'0'
         bcc par_err2
         cmp #'9'+1
         bcc chk_ok

         cmp #'?'
         beq chk_ok

         cpx #$03
         bne *+6
         cmp #':'
         beq chk_ok

         sta chr_buf
         lda only_fnm
         bne _lname2
         lda chr_buf
         cmp #'>'
         beq chk_ok
         cmp #'<'
         beq chk_ok

_lname2  lda chr_buf

         cmp #'A'
         bcc par_err2
         cmp #'Z'+1
         bcc chk_ok
         cmp #'_'
         beq chk_ok
         bne par_err2

chk_dok  inc dot_cnt
         bne chk_ok
par_err2 jmp par_err

chk_ok   sta ren_buf,Y
         iny
         jmp _lname

ren_bufx dta b(0)
ren_bufs dta b(0)
only_fnm dta b(0)
chr_buf  dta b(0)
dot_cnt  dta b(0)

old_name equ *
new_name equ old_name+11

dir_buf  equ new_name+11
dir_name equ dir_buf+6

ren_buf  equ dir_buf+23

         end
