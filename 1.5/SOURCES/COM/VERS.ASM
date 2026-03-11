; BW-DOS 1.5 Command VERS

; System equates
         icl '_SYSEQU.ICL'

         blk dos $580

start    jsr _print
         dta b($9b),c'  ',b(0)

         lda BW_DOS
         cmp #'B'
         bne chk_srd
         lda BW_DOS+1
         cmp #'W'
         bne chk_srd
         lda BW_VERS
         jsr get_hex
         stx txt_bwd+7
         sty txt_bwd+9
         cmp #$15
         php
         jsr _print
txt_bwd  dta c'BW-DOS x.x ',b(0)
         plp
         bcc prn_prd
         lda BW_SECBUF+1
         cmp #$16
         bcs prn_prd
         jsr _print
         dta c'CP ',b(0)
prn_prd  jsr _print
         dta c'- ',b(0)

chk_srd  lda BW_SPARTA
         cmp #'S'
         beq prn_sd
         cmp #'R'
         beq prn_rd
prn_unk  jsr _print
         dta c'Unkown DOS version',b($9b,0)
         rts

prn_sd   lda BW_SVERS
         jsr get_hex
         stx txt_sd+10
         sty txt_sd+12
         lda BW_SSVERS
         jsr get_hex
         sty txt_sd+13
         jsr _print
txt_sd   dta c'SpartaDOS x.xx',b($9b,0)
         rts

prn_rd   lda BW_SVERS
         jsr get_hex
         stx txt_rd+8
         sty txt_rd+10
         jsr _print
txt_rd   dta c'RealDOS x.x',b($9b,0)
         rts

get_hex  tay
         lsr @
         lsr @
         lsr @
         lsr @
         ora #$30
         tax
         tya
         pha
         and #$0F
         ora #$30
         tay
         pla
         rts

         icl '_PRINT.ICL'

         blk dos RUNAD
         dta a(start)

         end
