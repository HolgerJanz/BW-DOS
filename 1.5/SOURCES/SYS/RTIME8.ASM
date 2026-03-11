* RTime8 Clock driver RTIME8 [/R]

        icl '_SYSEQU.ICL'

* init with 0
RFLAG   equ $80 ;flag read-only
SFLAG   equ $81 ;flag use startup MEMLO
ITDTR   equ $82 ;iterator for DATER
ITPRN   equ $83 ;iterator for print

OMEML   equ $84 ;old MENLO
NMEML   equ $86 ;new MEMLO
AGETT   equ $88 ;address GETTD
ASETT   equ $8A ;address SETTD
LDRVP   equ $8C ;length of driver part (without init part)

RTIME8  equ $d5b9

        blk dos $3000
        jsr _print
        dta b($9b),c'RTime8 TD 1.5 ',b($00)
        icl '_TSTBW15.ICL'

* init variables
        lda #$00
        ldx #$03
        sta RFLAG,X
        dex
        bpl *-3
        lda #'W'
        sta sta_dyn
* check parameter
        jsr BW_CRNAME
        beq paramok
        ldx #$02
parchk  lda BW_COMFNAM+3,X
        cmp PARAM,X
        bne paramer
        dex
        bpl parchk
        lda #$ff
        sta RFLAG
        lda #'R'
        sta sta_dyn
        jsr BW_CRNAME
        beq paramok
paramer lda #$9c ; Parameter error
        jmp errext
* clear DECIN
paramok lda #$00
        ldx #$03
        sta BW_DECIN,X
        dex
        bpl *-4
* reset and check for RTime8
        jsr rt8test
* read clock
initrtc jsr GETTD
* check for start up MEMLO and use stat or dyn hdl
        lda BW_SMEMLO
        cmp MEMLO
        bne insdrv
        lda BW_SMEMLO+1
        cmp MEMLO+1
        bne insdrv
        lda #$ff
        sta SFLAG
        lda sta_dyn
        ora #$20
        sta sta_dyn
* install driver
* set old OMEML and init NMEML
insdrv  lda MEMLO
        sta OMEML
        sta NMEML
        lda MEMLO+1
        sta OMEML+1
        sta NMEML+1
* check for ini part
        lda SFLAG
        bne noini
        clc
        lda NMEML
        adc <reainie-reainib
        sta NMEML
        lda NMEML+1
        adc #$00
        sta NMEML+1
* set AGETT/ASETT
noini   lda NMEML
        sta AGETT
        sta ASETT
        lda NMEML+1
        sta AGETT+1
        sta ASETT+1
        clc
        lda RFLAG
        bne *+6
        lda <SETTD-GETTD
        bne *+4
        lda <SETTDRO-GETTD
        adc ASETT
        sta ASETT
        lda ASETT+1
        adc #$00
        sta ASETT+1
* set NMEML
        lda RFLAG
        beq *+6
        lda <rearode-rearodb
        bne *+4
        lda <reawrde-rearodb
        sta LDRVP
        clc
        lda NMEML
        adc LDRVP
        sta NMEML
        lda NMEML+1
        adc #$00
        sta NMEML+1
* set init part (maybe not needed)
        lda DOSINI
        sta VDOSINI+1
        lda DOSINI+1
        sta VDOSINI+2
        lda NMEML
        sta nmemlol+1
        lda NMEML+1
        sta nmemloh+1
* set rt8map1/2 addresses
        lda AGETT
        clc
        adc <rt8map-rearodb
        sta rt8map1+1
        sta rt8map2+1
        lda AGETT+1
        adc #0
        sta rt8map1+2
        sta rt8map2+2
* set decmap1/2/3 addresses
        lda AGETT
        clc
        adc <decmap-rearodb
        sta decmap1+1
        sta decmap2+1
        sta decmap3+1
        lda AGETT+1
        adc #0
        sta decmap1+2
        sta decmap2+2
        sta decmap3+2
* set rt8wait1/2 addresses
        lda AGETT
        clc
        adc <rt8wait-rearodb
        sta rt8wait1+1
        sta rt8wait2+1
        lda AGETT+1
        adc #0
        sta rt8wait1+2
        sta rt8wait2+2
* copy ini driver
        ldy #$00
        lda SFLAG
        bne noinid
nextinp lda reainib,Y
        sta (OMEML),Y
        iny
        cpy <reainie-reainib
        bcc nextinp
* copy set(get) driver
noinid  ldx #$00
        lda RFLAG
        bne cprop
nextwrp lda rearodb,X
        sta (OMEML),Y
        iny
        inx
        cpx <reawrde-rearodb
        bcc nextwrp
        bcs setini
cprop   lda rearodb,X
        sta (OMEML),Y
        iny
        inx
        cpx <rearode-rearodb
        bcc cprop
* set DOSINI or BW_MEMLO
setini  lda SFLAG
        bne setbwme
        lda OMEML
        sta DOSINI
        lda OMEML+1
        sta DOSINI+1
        jmp setmeml
setbwme lda NMEML
        sta BW_SMEMLO
        lda NMEML+1
        sta BW_SMEMLO+1
* set MEMLO to new MEMLO
setmeml lda NMEML
        sta MEMLO
        lda NMEML+1
        sta MEMLO+1
* set GETTD (SETTD)
        lda AGETT
        sta BW_GETTD
        lda AGETT+1
        sta BW_GETTD+1
        lda ASETT
        sta BW_SETTD
        lda ASETT+1
        sta BW_SETTD+1
* print current date time
* convert date time to atascii
nxtout  ldx ITDTR
        lda BW_DATER,X
        sta BW_DECIN
        jsr CONVDC
        ldx ITPRN
        lda BW_DECOUT+6
        cmp #' '
        bne *+4
        lda #'0'
        sta td_out,X
        inx
        lda BW_DECOUT+7
        sta td_out,X
        inx
        inx
        stx ITPRN
        inc ITDTR
        cpx #$12
        bcc nxtout
        jsr _print
td_out  dta c'dd-mm-yy hh:mm:ss '
sta_dyn dta c'x',b($9b,$00)
        rts

* vector for CONVDC
CONVDC  jmp (BW_CONVDC)

PARAM   dta c'/R',b($9b)

rt8test php ; save interrupts
        sei
        lda $AFFF ; save potential OSS bank
        pha
* reset read sequency
        lda RTIME8
        lda RTIME8
* write $01 (start clock) to control $F
        ldx #$0f
        jsr rt8wait
        stx RTIME8
        ldx #$00
        stx RTIME8
        ldx #$01
        stx RTIME8
* check RTime8 (try writing alarm seconds, registe $8)
        ldx #8
* save alarm seconds
        jsr rt8wait
        stx RTIME8
        lda RTIME8
        and #$0f
        pha
        lda RTIME8
        and #$0f
        pha
* write $77
        jsr rt8wait
        stx RTIME8
        lda #$07
        sta RTIME8
        sta RTIME8
* check $77
        jsr rt8wait
        stx RTIME8
        lda RTIME8
        and #$0f
        cmp #$07
        bne rt8err
        lda RTIME8
        and #$0f
        cmp #$07
        bne rt8err
* write $AA
        jsr rt8wait
        stx RTIME8
        lda #$0A
        sta RTIME8
        sta RTIME8
* check $AA
        jsr rt8wait
        stx RTIME8
        lda RTIME8
        and #$0f
        cmp #$0A
        bne rt8err
        lda RTIME8
        and #$0f
        cmp #$0A
        bne rt8err
* restore alarm seconds
        jsr rt8wait
        stx RTIME8
        pla
        tay
        pla
        sta RTIME8
        sty RTIME8
* everything OK
        pla
        tay
        lda $D500,Y ; restore OSS bank
        plp ; restore interrupts
        rts
* RTime8 not found
rt8err  pla
        pla
        pla
        tay
        lda $D500,Y ; restore OSS bank
        plp ; restore interrupts
        lda #$8A ; Device does not respond
* error handler
errext  pha
        lda #$9b
        jsr _putc
        pla
        jmp (BW_FAIL)

* reloc driver
reainib equ *
* set MEMLO and DOSINI
VDOSINI jsr COLDSV
nmemlol lda #$FF
        sta MEMLO
nmemloh lda #$FF
        sta MEMLO+1
        rts
reainie equ *

* Read-Only Driver
rearodb  equ *
GETTD    php ; save interrupts
         sei
         lda $AFFF ; save potential OSS bank
         pha
         ldx #5
rloop    equ *
rt8wait1 jsr rt8wait
         stx RTIME8
         lda RTIME8
         and #$0f
         tay
         lda RTIME8
         and #$0f
         clc
decmap1  adc decmap,Y
rt8map1  ldy rt8map,X
         sta BW_DATER,Y
         dex
         bpl rloop
rt8exit  pla
         tay
         lda $D500,Y ; restore OSS bank
         plp ; restore interrupts
         rts
rt8map   dta b(5,4,3,0,1,2)
decmap   dta b(00,10,20,30,40,50,60,70,80,90)
rt8wait  ldy #0
rt8waitl lda RTIME8
         and #$f0
         beq rt8waite
         dey
         bne rt8waitl
SETTDRO  equ *
rt8waite rts

rearode equ *
* Write Driver
SETTD    php ; save interrupts
         sei
         lda $AFFF ; save potential OSS bank
         pha
         ldx #5
wloop    equ *
rt8wait2 jsr rt8wait
rt8map2  ldy rt8map,X
         lda BW_DATER,Y
         ldy #10
wloop2   dey
decmap2  cmp decmap,Y
         bcc wloop2
decmap3  sbc decmap,Y
         stx RTIME8
         sty RTIME8
         sta RTIME8
         dex
         bpl wloop
         bmi rt8exit
reawrde  equ *

        icl '_PRINT.ICL'

        end
