* BW-DOS Command RUN addr

         icl '_SYSEQU.ICL'

         blk dos $580
init     equ *
         icl '_TSTBW15.ICL'
* save last run address
         lda BW_RUNLOC
         sta SRUNLOC
         lda BW_RUNLOC+1
         sta SRUNLOC+1
         rts

         blk dos INITAD
         dta a(init)

         blk dos $580
* restore last address
         lda SRUNLOC
         sta BW_RUNLOC
         lda SRUNLOC+1
         sta BW_RUNLOC+1
* get parameter
         jsr BW_CRNAME
         bne CPR1
         lda SRUNLOC+1
         cmp #$07 ; no rerun below page 7
         bcc par_err
CPRUN    jmp (BW_RUNLOC)
* clear run address
CPR1     ldx #$00
         stx BW_RUNLOC
         stx BW_RUNLOC+1
* calc address
CPR2     lda BW_COMFNAM+3,X
         cmp #$9b
         beq CPRUN
         cmp #'0'
         bcc par_err
         cmp #'9'+1
         bcc CPR21
         cmp #'A'
         bcc  par_err
         cmp #'F'+1
         bcs par_err
CPR21    cpx #$04
         bcs par_err
         inx
         sec
         sbc #$30
         cmp #$0A
         bcc CPR3
         sbc #$07
CPR3     asl @
         asl @
         asl @
         asl @
         ldy #$04
CPR4     asl @
         rol BW_RUNLOC
         rol BW_RUNLOC+1
         dey
         bne CPR4
         beq CPR2

* error, set run address to DOSVEC
par_err  lda SRUNLOC
         sta BW_RUNLOC
         lda SRUNLOC+1
         sta BW_RUNLOC+1
         lda #$9C ; parameter error
         jmp (BW_FAIL)

SRUNLOC  equ *

         end
