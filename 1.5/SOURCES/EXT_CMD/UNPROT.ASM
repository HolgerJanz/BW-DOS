* BW-DOS Command UNPROT path

* System equates
         icl '_SYSEQU.ICL'

EXE_CIO  equ $24
         blk dos $580
         icl '_EXECIO.ICL'

         end
