* BW-DOS Command MD path

        icl '_SYSEQU.ICL'

EXE_CIO equ $2A
        blk dos $580
        icl '_EXECIO.ICL'

        end
