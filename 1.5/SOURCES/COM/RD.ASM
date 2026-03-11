* BW-DOS Command RD path

        icl '_SYSEQU.ICL'

EXE_CIO equ $2B
        blk dos $580
        icl '_EXECIO.ICL'

        end
