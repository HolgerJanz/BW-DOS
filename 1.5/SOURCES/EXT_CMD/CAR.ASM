* BW-DOS Command CAR

* System equates
         icl '_SYSEQU.ICL'

         blk dos $580
         icl '_TSTBW14.ICL'
         lda CARTFG
         inc CARTFG
         cmp CARTFG
         sta CARTFG
         bne car_err
         ldx CART
         bne car_err
         lda BW_DWARM
         sta WARMST
         stx BW_INCMND
         dex
         stx BW_DWARM
         jmp (CARTCS)

car_err  lda #$9C
         jmp (BW_FAIL)

         end
