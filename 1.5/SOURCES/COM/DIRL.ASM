* BW-DOS Command DIRL path

         icl '_SYSEQU.ICL'

msk      equ $400
dirbuf   equ $410

         blk dos $480
         icl '_TSTBW15.ICL'
         jsr BW_CRNAME
* dir open
d_open   lda #$03
         sta $352
         lda <BW_COMFNAM
         sta $354
         lda >BW_COMFNAM
         sta $355
         lda #28
         sta $358
         lda #0
         sta $359
         lda #$04+$10
         sta $35A
         lda #$00
         sta $35B
         ldx #$10
         jsr CIOV
         bmi _error1

         ldx #0
         lda #$0b
         sta $342
         stx $348
         stx $349
         lda #$9b
         jsr CIOV
_error1  bmi error

* screen output
         lda #$09
         sta $342
         lda <linebuf
         sta $344
         lda >linebuf
         sta $345
         lda #40
         sta $348
         lda #0
         sta $349
* dir input
         lda #$07
         sta $352
         lda <dirbuf
         sta $354
         lda >dirbuf
         sta $355
         lda #23
         sta $358
         lda #0
         sta $359
         jsr getmsk
* entry loop
lloop    ldx #$10
         jsr CIOV
         bmi close

         lda dirbuf
         and #%00001000 ; used?
         beq lloop

         ldx #10
srch1b   lda msk,x
         cmp #'?'
         beq srch1c
         cmp dirbuf+6,x
         bne lloop
srch1c   dex
         bpl srch1b

         jsr l2linebuf

         ldx #$00
         jsr CIOV
         bmi error
         bpl lloop
* close
close    lda #$0C
         sta $352
         ldx #$10
         jsr CIOV
         bmi error
         ldx BW_BUFOFF
         lda BW_LBUF,X
         cmp #$9b
         beq end_exit
         jsr BW_CRNAME
         jmp d_open
end_exit rts

error    tya
         jmp (BW_FAIL)

l2linebuf   ldx #' '
         lda dirbuf
         and #$01
         beq *+4
         ldx #'*'
         stx linebuf

l2e_nm   ldx #$0A
         ldy #$0B
l2e_nam  lda dirbuf+6,X
         sta linebuf+1,Y
         cpy #9
         bne *+3
         dey
         dey
         dex
         bpl l2e_nam

         lda dirbuf
         and #$20
         bne l2e_sizd

         ldx #2
l2e_sizi lda dirbuf+3,X
         sta BW_DECIN,X
         dex
         bpl l2e_sizi
         jsr convdc
         ldx #7
l2e_sizo lda BW_DECOUT,X
         sta linebuf+13,X
         dex
         bpl l2e_sizo
         bmi l2e_dt

l2e_sizd ldx #7
l2e_szdl lda l2e_dir,X
         sta linebuf+13,X
         dex
         bpl l2e_szdl

l2e_dt   ldx #0
         stx BW_DECIN+1
         stx BW_DECIN+2
         stx l2e_dtex
         stx l2e_dtlx
l2e_dtl  jsr l2e_dto
         bcc l2e_dtl

         rts

l2e_dir  dta c' <dir>  '
l2e_dtex dta b(0)
l2e_dtlx dta b(0)

l2e_dto  ldx l2e_dtlx
         lda dirbuf+17,X
         sta BW_DECIN
         jsr convdc

         ldx l2e_dtex
         lda BW_DECOUT+6
         cmp #' '
         bne *+4
         lda #'0'
         sta linebuf+22,X
         inx
         lda BW_DECOUT+7
         sta linebuf+22,X

         inc l2e_dtex
         inc l2e_dtex
         inc l2e_dtex

         inc l2e_dtlx
         lda l2e_dtlx
         cmp #6
         rts

convdc   jmp (BW_CONVDC)


getmsk  ldy #0
dc1noc  ldx BW_COMFNAM,Y
        iny
        cpx #':'
        beq dc1no
        cpx #'<'
        beq dc1no
        cpx #'>'
        beq dc1no
        cpx #$9b
        bne dc1noc
        beq dc1noe
dc1no   tya
        bpl dc1noc

dc1noe  tax

        lda BW_COMFNAM,X
        cmp #$9B
        bne dc1srt

        lda #'?'
        ldx #10
dc1lstd sta msk,X
        dex
        bpl dc1lstd
        rts

dc1srt  ldy #0
        lda #6
        sta tmp
        dex

dc1b1   inx

        lda BW_COMFNAM,X
        cmp #'*'
        beq dc1bhve

        cmp #'.'
        beq dc1btec

        cmp #'?'
        beq dc1bzn

        jsr jelipl
        bcs dc1bnep

dc1bzn  jsr dc1bput
        jmp dc1b1

dc1bput cpy #8
        bcc dc1bp2

        bit tmp
        bpl dc1bp1

        cpy #11
        bcc dc1bp2

dc1bp1  rts

dc1bp2  sta msk,y
        iny
        rts

dc1bhve lda #'?'
        jsr dc1bput
        bcc dc1bhve
        bcs dc1b1

dc1bnep sec
        ror tmp

dc1btec lda #$20
        jsr dc1bput
        bcc dc1btec

        ror tmp
        bcc dc1b1

        rts

jelipl  cmp #'_'
        beq jlpp

        cmp #$30
        bcc jlpm
        cmp #$3a
        bcc jlpp
        cmp #$41
        bcc jlpm
        cmp #$5b
        bcs jlpm

jlpp    clc
        rts

jlpm    sec
        rts

tmp     dta b(0)

linebuf dta c'#ABCDEFGH ABC 1234567 11-22-33 11:22:33',b($9b)

        end
