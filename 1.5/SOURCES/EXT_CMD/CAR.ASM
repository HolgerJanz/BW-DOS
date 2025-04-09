* BW-DOS Command CAR

     icl '_SYSEQU.ICL'

     blk dos $580
     icl '_TSTBW15.ICL'
     lda CARTFG
     inc CARTFG
     cmp CARTFG
     sta CARTFG
     bne cerr
     ldx CART
     bne cerr
     lda BW_DWARM
     sta WARMST
     stx BW_INCMND
     dex
     stx BW_DWARM
     jmp (CARTCS)

cerr lda #$9C
     jmp (BW_FAIL)

     end
