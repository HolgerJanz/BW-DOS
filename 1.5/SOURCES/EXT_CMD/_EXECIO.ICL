         icl '_TSTBW14.ICL'
* get parameter
nxt_ok   jsr BW_CRNAME
         beq end_ok
* execute command
         ldx #$10
         lda <EXE_CIO
         sta IOCB0+ICCOM,X
         lda <BW_COMFNAM
         sta IOCB0+ICBAL,X
         lda >BW_COMFNAM
         sta IOCB0+ICBAH,X
         lda #28
         sta IOCB0+ICBLL,X
         lda #0
         sta IOCB0+ICBLH,X
         jsr CIOV
* check error
         bpl nxt_ok
         tya
         jmp (BW_FAIL)
end_ok   rts
