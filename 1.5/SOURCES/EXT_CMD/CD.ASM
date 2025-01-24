* BW-DOS Command CD path

* System equates
         icl '_SYSEQU.ICL'

EXE_CIO  equ $2C
         blk dos $580
         icl '_EXECIO.ICL'

         end
