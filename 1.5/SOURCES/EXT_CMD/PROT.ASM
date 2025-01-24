* BW-DOS Command PROT path

* System equates
         icl '_SYSEQU.ICL'

EXE_CIO  equ $23
         blk dos $580
         icl '_EXECIO.ICL'

         end
