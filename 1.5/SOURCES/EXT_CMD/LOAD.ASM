* BW-DOS Command LOAD path

* System equates
         icl '_SYSEQU.ICL'

EXE_CIO  equ $28
         blk dos $580
         ldx #$10
         lda #$04
         sta IOCB0+ICAX1,X
         lda #$80
         sta IOCB0+ICAX2,X
         icl '_EXECIO.ICL'

         end
