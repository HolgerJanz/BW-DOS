* BW-DOS Command PROT path

        icl '_SYSEQU.ICL'

EXE_CIO equ $23
        blk dos $580
        icl '_EXECIO.ICL'

        end
