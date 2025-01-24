* BW-DOS Command MAN command

* System equates
         icl '_SYSEQU.ICL'

EOLCNT   equ $80 ;EOL count
CHACNT   equ $81 ;char count
CIOERR   equ $82 ;CIO error code
LBUFX    equ $83 ;current index in LBUF
LBUFL    equ $84 ;current LBUF len
LINEL    equ $85 ;length of screen line
MAXLIN   equ $86 ;max screen line count

         blk dos $3000
         icl '_TSTBW15.ICL'
         ldx RMARGN
         inx
         stx LINEL
         jsr BW_CRNAME
         bne *+5
         jmp par_err
* get name
next     lda #$00
         sta EOLCNT
         sta CHACNT
         lda #23
         sta MAXLIN
         lda BW_DOSDRV
         bne *+5
         lda BW_COMFNAM+1
         ora #$30
         sta fname+1
         ldx #$FF
nxtchar  inx
         lda BW_COMFNAM+3,X
         sta fname+8,X
         cmp #$9b
         bne nxtchar
         ldy #$00
nxtext   lda manext,Y
         sta fname+8,X
         inx
         iny
         cpy #$05
         bcc nxtext
* open
         lda #$03
         sta $352
         lda <fname
         sta $354
         lda >fname
         sta $355
         lda #28
         sta $358
         lda #0
         sta $359
         lda #$04
         sta $35A
         lda #$00
         sta $35B
         ldx #$10
         jsr CIOV
         bpl *+5
         jmp error
* screen output
         lda #$0B
         sta $342
         lda <LBUF
         sta $344
         lda >LBUF
         sta $345
         ldx #0
         stx $348
         stx $349
* input
         lda #$07
         sta $352
         lda <LBUF
         sta $354
         lda >LBUF
         sta $355
* line buffer loop
lloop    lda #40
         sta $358
         lda #0
         sta $359
         ldx #$10
         jsr CIOV
         sty CIOERR
* init output buffer
         lda <LBUF
         sta $344
         lda >LBUF
         sta $345
* check for EOL
         lda $358
         sta LBUFL
         ldx #$FF
nxteolck inx
         cpx LBUFL
         bcs nxtloop
         inc CHACNT
         lda CHACNT
         cmp LINEL
         bcs nxtline
         lda LBUF,X
         cmp #$9b
         bne nxteolck
nxtline  lda #$00
         sta CHACNT
         inc EOLCNT
         lda EOLCNT
         cmp MAXLIN
         bcc nxteolck
* max EOL reached
         stx LBUFX
         lda #$00
         sta EOLCNT
         lda #20
         sta MAXLIN
* output to max EOL
         inx
         stx $348
         ldx #$00
         jsr CIOV
         bmi error
* check for key
         lda #$FF
getKey   cmp CH
         beq getKey
         ldy NOCLIK
         bne doKey
         jsr SKC
doKey    ldx CH
         sta CH
         cpx #$1c ; ESC
         beq close
* calc buffer address of remaining
         clc
         lda $348
         adc $344
         sta $344
         lda $345
         adc #$00
         sta $345
* calc buffer length of remaining
         sec
         lda $358
         sbc $348
         sta $358
         ldx LBUFX
         jmp nxteolck

* buffer output
nxtloop  lda $358
         sta $348
         ora $359
         beq chkcio ; read 0 chars
         lda $359
         sta $349
cioout   ldx #$00
         jsr CIOV
         bmi error
* check input error
chkcio   ldy CIOERR
         bmi close
         jmp lloop
* close
close    lda #$0C
         sta $352
         ldx #$10
         jsr CIOV
* next
         jsr BW_CRNAME
         beq *+5
         jmp next
         rts

par_err  ldy #$9C ; parameter error
error    tya
         jmp (BW_FAIL)

; sound key click
SKC      pha
         txa
         pha
         ldx #2*63 ;2 times trip count
; Turn loudspeaker on
SKC1     stx CONSOL ;turn loudspeaker on
; Wait for VBLANK (loudspeaker off)
         lda VCOUNT
SKC2     cmp VCOUNT
         beq SKC2
; Decrement and check trip count
         dex
         dex
         bpl SKC1
         pla
         tax
         pla
         rts

manext   dta c'.MAN',b($9b)
fname    dta c'Dx:>MAN>'

LBUF     equ *+28+4+1 ; plus COMFNAM len, ext len, and EOL 

         end
