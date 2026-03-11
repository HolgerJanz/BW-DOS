; Ultimate/Side1/2 Clock driver ULSD12TD.SYS [/R]

            icl '_SYSEQU.ICL'

; init with 0
RFLAG       equ $80 ;flag read-only
SFLAG       equ $81 ;flag use startup MEMLO
ITDTR       equ $82 ;iterator for DATER
ITPRN       equ $83 ;iterator for print

OMEML       equ $84 ;old MENLO
NMEML       equ $86 ;new MEMLO
AGETT       equ $88 ;address GETTD
ASETT       equ $8A ;address SETTD
OGETT       equ $8C ;16-bit offset for realloc (negative)
LDRVP       equ $8E ;length of driver part (without init part)
ZTEMP1      equ $8F

; RTC register
ULCLOCK     equ $D3E2
S2CLOCK     equ $D5E2

            blk dos $3000
            icl '_TSTBW15.ICL'

; init variables
            lda #$00
            ldx #$03
            sta RFLAG,X
            dex
            bpl *-3
            lda #'W'
            sta sta_dyn
; check parameter
            jsr BW_CRNAME
            beq paramok
            ldx #$02
parchk      lda BW_COMFNAM+3,X
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
paramer     lda #$9c ; Parameter error
            jmp errext

prnMsg      jsr _print
            dta b($9b)
clkFoundTxt dta c'Ultimate TD 1.5 ',b($00)
            rts

; clear DECIN
paramok     lda #$00
            ldx #$03
            sta BW_DECIN,X
            dex
            bpl *-4
; reset and check for RTime8
            jsr clkTest
            jsr prnMsg
; read clock
initrtc     jsr GETTD
; check for start up MEMLO and use stat or dyn hdl
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
; install driver
; set old OMEML and init NMEML
insdrv      lda MEMLO
            sta OMEML
            sta NMEML
            lda MEMLO+1
            sta OMEML+1
            sta NMEML+1
; check for ini part
            lda SFLAG
            bne noini
            clc
            lda NMEML
            adc <reainie-reainib
            sta NMEML
            lda NMEML+1
            adc #$00
            sta NMEML+1
; set AGETT/ASETT/OGETT
noini       lda NMEML
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
            sec
            lda <GETTD
            sbc AGETT
            sta OGETT
            lda >GETTD
            sbc AGETT+1
            sta OGETT+1
; set NMEML
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
; set init part (maybe not needed)
            lda DOSINI
            sta VDOSINI+1
            lda DOSINI+1
            sta VDOSINI+2
            lda NMEML
            sta nmemlol+1
            lda NMEML+1
            sta nmemloh+1

; realloc
            ldx <realocAddrL
reallocNxt  lda realocAddr,X
            sta ZTEMP1
            lda realocAddr+1,X
            sta ZTEMP1+1
            ldy #$01
            sec
            lda (ZTEMP1),Y
            sbc OGETT
            sta (ZTEMP1),Y
            iny
            lda (ZTEMP1),Y
            sbc OGETT+1
            sta (ZTEMP1),Y
            dex
            dex
            bpl reallocNxt

; copy ini driver
            ldy #$00
            lda SFLAG
            bne noinid
nextinp     lda reainib,Y
            sta (OMEML),Y
            iny
            cpy <reainie-reainib
            bcc nextinp
; copy set(get) driver
noinid      ldx #$00
            lda RFLAG
            bne cprop
nextwrp     lda rearodb,X
            sta (OMEML),Y
            iny
            inx
            cpx <reawrde-rearodb
            bcc nextwrp
            bcs setini
cprop       lda rearodb,X
            sta (OMEML),Y
            iny
            inx
            cpx <rearode-rearodb
            bcc cprop
* set DOSINI or BW_MEMLO
setini      lda SFLAG
            bne setbwme
            lda OMEML
            sta DOSINI
            lda OMEML+1
            sta DOSINI+1
            jmp setmeml
setbwme     lda NMEML
            sta BW_SMEMLO
            lda NMEML+1
            sta BW_SMEMLO+1
* set MEMLO to new MEMLO
setmeml     lda NMEML
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
nxtout      ldx ITDTR
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
td_out      dta c'dd-mm-yy hh:mm:ss '
sta_dyn     dta c'x',b($9b,$00)
            rts

* vector for CONVDC
CONVDC      jmp (BW_CONVDC)

PARAM       dta c'/R',b($9b)

clkTest     jsr chkClock
            beq chkClockUSf
            jsr setClkSide
            jsr chkClock
            bne notFound
chkClockUSf rts

notFound    lda #$8A ; Device does not respond
; error handler
errext      pha
            jsr prnMsg
            lda #$9b
            jsr _putc
            pla
            jmp (BW_FAIL)

chkClock    lda #$55
            sta CLKBUF
            lda #$30+$80
            jsr CRWREGS
            lda #$30
            jsr CRWREGS
            lda CLKBUF
            cmp #$55
            rts

setClkSide  ldy #$02
            ldx <clkRegAccL
setClkSnxt  lda clkRegAcc,X
            sta ZTEMP1
            lda clkRegAcc+1,X
            sta ZTEMP1+1
            lda >S2CLOCK
            sta (ZTEMP1),Y
            dex
            dex
            bpl setClkSnxt
            ldx #7
setClkSTnxt lda side12Txt,X
            sta clkFoundTxt,X
            dex
            bpl setClkSTnxt
            rts
side12Txt   dta c'Side 1/2'

; reloc driver begin
reainib     equ *
; set MEMLO and DOSINI
VDOSINI     jsr COLDSV
nmemlol     lda #$FF
            sta MEMLO
nmemloh     lda #$FF
            sta MEMLO+1
            rts
reainie     equ *

rearodb     equ *

; get time
GETTD       lda #$00
REALOC01    jsr CRWREGS
            ldx #5
getLp1      equ *
REALOC02    ldy RMAP,X
REALOC03    lda CLKBUF,Y
            pha
            lsr @
            lsr @
            lsr @
            lsr @
            tay
            pla
            and #$0F
            clc
REALOC04    adc HEX2DEC,Y
            sta BW_DATER,X
            dex
            bpl getLp1
            rts

; read/write clock
CRWREGS     equ *
REALOC11    sta CRWBUF
REALOC12    jsr cSet00
            tay
            lda #$01
CLKREG01    sta ULCLOCK
loop3       equ *
REALOC13    lda CRWBUF,Y
REALOC14    sta CRWFLAG
            ldx #$08
loop4       lda #$01
REALOC15    asl CRWFLAG
            bcc noWrite1
            ora #$04
noWrite1    pha
            ora #$02
CLKREG02    sta ULCLOCK
            clc
CLKREG03    lda ULCLOCK
            and #$08
            beq noWrite2
            sec
noWrite2    equ *
REALOC16    rol CBITREG
            pla
CLKREG04    sta ULCLOCK
            dex
            bne loop4
REALOC17    lda CBITREG
REALOC18    sta CRWBUF,Y
            iny
            cpy #$08
            bcc loop3
cSet00      lda #$00
CLKREG05    sta ULCLOCK
            clc
SETTDRO     rts

RMAP        dta b($04,$05,$06,$02,$01,$00,$03)
HEX2DEC     dta b(0,10,20,30,40,50,60,70,80,90)
CRWFLAG     dta b(0)
CBITREG     dta b(0)
CRWBUF      dta b($11)
CLKBUF      dta b($22,$33,$44,$55,$66,$77,$88)

rearode equ *

; set time
SETTD       ldx #5
setLp2      lda BW_DATER,X
            ldy #10
setLp1      dey
REALOC05    cmp HEX2DEC,Y
            bcc setLp1
REALOC06    sbc HEX2DEC,Y
            pha
            tya
            asl @
            asl @
            asl @
            asl @
REALOC07    ldy RMAP,X
REALOC08    sta CLKBUF,Y
            clc
            pla
REALOC09    adc CLKBUF,Y
REALOC10    sta CLKBUF,Y
            dex
            bpl setLp2
            lda #$80
REALOC19    jmp CRWREGS

reawrde     equ *
; reloc driver and

; clock harware register addresses
clkRegAcc   dta a(CLKREG01,CLKREG02,CLKREG03,CLKREG04,CLKREG05)
clkRegAccL  equ *-clkRegAcc-2

; realloc addresses
realocAddr  dta a(REALOC01,REALOC02,REALOC03,REALOC04)
            dta a(REALOC05,REALOC06,REALOC07,REALOC08)
            dta a(REALOC09,REALOC10,REALOC11,REALOC12)
            dta a(REALOC13,REALOC14,REALOC15,REALOC16)
            dta a(REALOC17,REALOC18,REALOC19)
realocAddrL equ *-realocaddr-2

            icl '_PRINT.ICL'

            end
