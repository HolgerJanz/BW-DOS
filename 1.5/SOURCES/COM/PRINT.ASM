* BW-DOS Command PRINT [file]

         icl '_SYSEQU.ICL'

         blk dos $580
         jsr BW_CRNAME
         bne do_divio
         ldy #$00
         jsr XDIVIO
         bmi io_err
         rts

do_divio ldy #$00
         jsr DIVIO
         bpl cd_ok
io_err   tya
         jmp (BW_FAIL)
cd_ok    rts

DIVIO    jmp (BW_DIVIO)
         rts
XDIVIO   jmp (BW_XDIVIO)
         rts

         end
