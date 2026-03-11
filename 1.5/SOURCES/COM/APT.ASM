; BW-DOS command APTMOUNT [pbiId] [prtId] [drvId]

         icl '_SYSEQU.ICL'

         blk dos $2800
         icl '_TSTBW15.ICL'

         lda #$9b
         jsr _putc

; save PBI mask
         lda PDVMSK
         sta sPDVMSK

; check command parameter
         jsr chkParam
         beq *+5
         jmp getCmd
         jsr _print
         dta c'BW-DOS 1.5 APT Tool 28-02-2026',b($9b)
         dta c'Use: APT',b($9b)
         dta c'  LIST   [pbiId] [prtId]',b($9b)
         dta c'  INFO   pbiId',b($9b)
         dta c'  MOUNT  pbiId prtId drvId',b($9b)
;         dta c'  INIT   pbiId',b($9b)
;         dta c'  INSERT pbiId secCnt name',b($9b)
;         dta c'  DELETE pbiId',b($9b)
         dta b(0)
         rts

getCmd   jsr BW_CRNAME

; parse command
         lda #0
         sta cmdFound+1
         tax

nxtCmd3  ldy #0
nxtCmd4  lda cmdList,X
         beq cmdFound
         cmp BW_COMFNAM+3,Y
         bne nxtCmd1
         iny
         inx
         cmp #$9b
         bne nxtCmd4
         beq cmdFound

nxtCmd2  inx
         lda cmdList,X
nxtCmd1  cmp #$9b
         bne nxtCmd2
         inc cmdFound+1
         inx
         bne nxtCmd3

cmdFound ldx #0
         lda cmdVecHi,X
         pha
         lda cmdVecLo,X
         pha
         rts

cmdList  dta c'LIST',b($9b)
         dta c'INFO',b($9b)
         dta c'MOUNT',b($9b)
         dta c'INIT',b($9b)
         dta c'INSERT',b($9b)
         dta c'DELETE',b($9b)
         dta b(0)

cmdVecHi dta h(aptListV,aptInfoV,aptMontV,aptInitV,aptInstV,aptDeleV,errorPaV)
cmdVecLo dta l(aptListV,aptInfoV,aptMontV,aptInitV,aptInstV,aptDeleV,errorPaV)


; command LIST
aptList  jsr chkParam
aptListV equ aptList-1
; check PBI Id
         beq _lsDev
         jsr getPBIM

; check partition number
         jsr chkParam
         beq _lsPrts
         jsr getPRTM

; check for other invalid parameter
         jsr chkParam
         beq _lsPrt
         jmp errorPar

; list one partition
_lsPrt   jsr lsPrt
         jmp _exit

; list partitions
_lsPrts  jsr lsPrts
         jmp _exit

; list PBI devices
_lsDev   jsr lsDev

_exit    lda sPDVMSK
         sta PDVMSK
         rts


;command INFO
aptInfo  jsr chkParam
aptInfoV equ aptInfo-1
; check PBI Id
         bne *+5
         jmp errorPar
         jsr getPBIM

; check for other invalid parameter
         jsr chkParam
         beq _infoPrt
         jmp errorPar

_infoPrt jsr infoPrt
         jmp _exit

; command MOUNT
aptMont  jsr chkParam
aptMontV equ aptMont-1
; check PBI Id
         bne *+5
         jmp errorPar
         jsr getPBIM

; check partition number
         jsr chkParam
         bne *+5
         jmp errorPar
         jsr getPRTM

; check drive number
         jsr chkParam
         bne *+5
         jmp errorPar
         jsr getDRVM

; check for other invalid parameter
         jsr chkParam
         beq _stPrt
         jmp errorPar

; list one partition
_stPrt   jsr stPrt
         jmp _exit


; command INIT
aptInit  jsr chkParam
aptInitV equ aptInit-1
; check PBI Id
         bne *+5
         jmp errorPar
         jsr getPBIM

; check for other invalid parameter
         jsr chkParam
         beq _initPrt
         jmp errorPar

_initPrt jsr _print
         dta C'Init',B($9b,0)
         jsr initPrt
         jmp _exit

; command INSERT
aptInst  jsr _print
aptInstV equ aptInst-1
         dta C'Insert',B($9b,0)
         jmp _exit

; command DELETE
aptDele  jsr _print
aptDeleV equ aptDele-1
         dta C'Delete',B($9b,0)
         jmp _exit

         icl '_PRINT.ICL'

initMBR  ldx 0
         sta bufPDCB,X
         sta bufPDCB+$100,X
         inx
         bne initMBR
         lda MBRsig
         sta bufPDCB+$1FE
         lda MBRsig+1
         sta bufPDCB+$1FF
         rts

; convert sector count ($80) to MB (BW_DECOUT)
convSM   ldx #2
_convSM1 lsr $82
         ror $81
         ror $80
         dex
         bpl _convSM1

         ldx #2
_convSM2 lda $80,X
         sta BW_DECIN,X
         dex
         bpl _convSM2

         jsr convDC
         rts

fndAPT   ldx #0
_fndAPT1 lda prtTabTy,X
         cmp #$7F ; partition type APT
         beq _fndAPT2
         txa
         clc
         adc #$10
         tax
         cpx #$40
         bcc _fndAPT1
_fndAPT2 cpx #$40
         rts

; APT info
infoPrt  jsr polling
         jsr dosError
; controller name
         ldx #0
_infoPr1 lda IctName,X
         beq _infoPr2
         sta infoCtrl,X
         inx
         cpx #27
         bcc _infoPr1
; media name
_infoPr2 ldx #0
_infoPr3 lda ImdName,X
         beq _infoPr4
         sta infoMedi,X
         inx
         cpx #27
         bcc _infoPr3
; bytes per sector
_infoPr4 lda IbyPsec
         sta BW_DECIN
         lda IbyPsec+1
         sta BW_DECIN+1
         lda #0
         sta BW_DECIN+2
         jsr convDC
         ldx #0
         ldy #0
_infoPr5 lda BW_DECOUT,X
         cmp #' '
         beq *+6
         sta infoBPS,Y
         iny
         inx
         cpx #8
         bcc _infoPr5
; sector count
         ldx #2
_infoPr6 lda IsecCnt+1,X
         sta $80,X
         dex
         bpl _infoPr6

         jsr convSM

         ldx #0
         ldy #0
_infoPr9 lda BW_DECOUT,X
         cmp #' '
         beq *+6
         sta infoSize,Y
         iny
         inx
         cpx #8
         bcc _infoPr9
         lda #'M'
         sta infoSize,Y
         iny
         lda #'B'
         sta infoSize,Y

; APT sector count
         jsr getMBR
         bmi _prninfo
         jsr chkMBR
         bne _prninfo

         jsr fndAPT
         bcs _prninfo

_infoPr7 ldy #0
_infoPrB lda prtTabCn+1,X
         sta $80,Y
         inx
         iny
         cpy #3
         bcc _infoPrB

         jsr convSM

         ldx #0
         ldy #0
_infoPrC lda BW_DECOUT,X
         cmp #' '
         beq *+6
         sta infoAPT,Y
         iny
         inx
         cpx #8
         bcc _infoPrC
         lda #'M'
         sta infoAPT,Y
         iny
         lda #'B'
         sta infoAPT,Y

_prninfo jsr _print
         dta c'Controller: '
infoCtrl dta c'                           ',b($9b)
         dta c'     Media: '
infoMedi dta c'                           ',b($9b)
         dta c'       BPS: '
infoBPS  dta c'     ',b($9b)
         dta c'      Size: '
infoSize dta c'         ',b($9b)
         dta c'       APT: '
infoAPT  dta c'-        ',b($9b)
         dta b(0)
         rts

; initialize APT
initPrt  jsr polling
         jsr dosError
;         jsr initMBR
         rts

; check for further parameter
chkParam ldx BW_BUFOFF
         lda BW_LBUF,X
         cmp #$9b
         rts

; read MBR sector $0
getMBR   ldx #3
         lda #0
_MBRsetl sta cmdCBsec,X
         dex
         bpl _MBRsetl
         jsr SIOrdDCB
         rts

; check MBR signature
chkMBR   lda MBRsig
         cmp prtSig
         bne chkMBR
         lda MBRsig+1
         cmp prtSig+1
_chkMBR  rts

; get APT partition table
getPrtTb jsr polling
         jsr dosError
; get MBR
         jsr getMBR
         jsr dosError
; check MBR signature
         jsr chkMBR
         beq _MBRset2
         ldy #194 ; MBR signature is invalid
         jmp dosErroj
; get APT
_MBRset2 jsr getPSec
         jsr SIOrdPrt
         jsr dosError
         jsr chkAPTs1
         rts

; list all partitions
lsPrts   jsr getPrtTb
         jsr prnPrts
         rts

; substract one from partition sector
; for leading meta sector
sub1sec  sec
         lda cmdCBsec
         sbc #1
         sta cmdCBsec
         lda cmdCBsec+1
         sbc #0
         sta cmdCBsec+1
         lda cmdCBsec+2
         sbc #0
         sta cmdCBsec+2
         lda cmdCBsec+3
         sbc #0
         sta cmdCBsec+3
         rts

; check partition for mounted drive number
; -> X = $10xPartNo
; <- A = drive number (0 not mounted)
getDrvNo ldy #$10
getDrvN2 lda aptPsec,X
         cmp aptMsec,Y
         bne getDrvN1
         lda aptPsec+1,X
         cmp aptMsec+1,Y
         bne getDrvN1
         lda aptPsec+2,X
         cmp aptMsec+2,Y
         bne getDrvN1
         lda aptPsec+3,X
         cmp aptMsec+3,Y
         bne getDrvN1
         tya
         lsr @
         lsr @
         lsr @
         lsr @
         bne getDrvN3
getDrvN1 tya
         clc
         adc #$10
         tay
         bne getDrvN2
         lda #0
getDrvN3 sta prtDrv
         rts

; set drive number for listing
; -> X = $10xPartNo
setDrvNo jsr getDrvNo
         beq _prnPrL4
         ldy #'D'
         sty prnPDrvN
         cmp #10
         bcs _prnPrL5
         ora #$30
         sta prnPDrvN+1
         bne _prnPrL6
_prnPrL5 ora #$40
         sta prnPDrvN+1
         bne _prnPrL6
_prnPrL4 lda #'-'
         sta prnPDrvN
         sta prnPDrvN+1
_prnPrL6 rts

; set partition name for listing
; -> X = $10xPartNo
setPrtNm ldy #0
         lda aptPtyp,X
         beq _prnPrL2

         cmp #3
         beq _prnPrN1

         ldx #0
         lda #' '
_prnPrN2 sta prnPName,X
         inx
         cpx #26
         bne _prnPrN2

         rts

_prnPrN1 lda aptPXsec+0,X
         and #$0F
         sta cmdCBsec+3
         lda aptPXsec+1,X
         sta cmdCBsec+0
         lda aptPXsec+2,X
         sta cmdCBsec+1
         lda aptPXsec+3,X
         sta cmdCBsec+2
         jmp _prnPrN3

_prnPrL2 lda aptPsec,X
         sta cmdCBsec,Y
         inx
         iny
         cpy #$04
         bcc _prnPrL2
         jsr sub1sec

_prnPrN3 jsr SIOrdDCB
         jsr dosError
         jsr chkAPTs2

         ldx #0
_prnPrL3 lda prtName,X
         bne *+4
         lda #' '
         sta prnPName,X
         inx
         cpx #26
         bne _prnPrL3
         rts

; set partition number for listing
; -> prtCur
convDC   jmp (BW_CONVDC)
setPrtNo lda prtCur
         clc
         adc #1
         sta BW_DECIN
         lda #0
         sta BW_DECIN+1
         sta BW_DECIN+2
         jsr convDC
         lda BW_DECOUT+6
         ora #$10
         sta prnPNum
         lda BW_DECOUT+7
         sta prnPNum+1
         rts

setPrtTy lda aptPtyp,X
         cmp #4
         tay
         lda #'?'
         bcs setPrtTN
         lda APTprtTy,Y
setPrtTN sta prnPtyp
         rts

; print current partition 
prnPrt   lsr notFound
         jsr setDrvNo
         jsr setPrtTy
         jsr setPrtNm
         jsr setPrtNo
         jsr _print
         dta c'PRT#'
prnPNum  dta c'xx('
prnPtyp  dta c'?):'
prnPDrvN dta c'--:'
prnPName dta c'                          ',b($9b,0)
         rts

; set drive for partition
stPrt    jsr getPrtTb
         jsr gtPrtCnt
         lda prtCur
         cmp prtCnt
         bcs errorAPT
         jsr chkPrt
         bcs errorAPT
         jsr getDrvNo

         lda prtDrv
         cmp newDrv
         beq prnPrt ;_stPrt1

         lda prtDrv
         asl @
         asl @
         asl @
         asl @
         tay
         beq _stPrt2
         jsr clrMnt

_stPrt2  lda newDrv
         asl @
         asl @
         asl @
         asl @
         tay
         beq _stPrt1
         jsr setMnt

_stPrt1  jsr prnPrt

         jsr SIOwrPrt
         jsr dosError
         jsr SIOfmch
         jsr dosError
         rts

; clear mount entry
clrMnt   lda #0
         sta bufPDCB,Y
         iny
         tya
         and #$0F
         bne clrMnt
         rts

; set mount entry
setMnt   txa
         pha
         tya
         pha
_setMnt1 lda aptPlst,X
         sta bufPDCB,Y
         inx
         iny
         tya
         and #$0F
         bne _setMnt1
         pla
         tay
         lda prtCur
         clc
         adc #1
         sta mapPrtNo,Y
         lda #0
         sta mapPrtNo+1,Y
         pla
         tax
         rts

; print one partition
lsPrt    jsr getPrtTb
         jsr gtPrtCnt
         lda prtCur
         cmp prtCnt
         bcc _lsPrt1
errorAPT ldy #193 ; APT partition number is not found
         jmp dosErroj

_lsPrt1  jsr prnPrt2
         lda notFound
         bne errorAPT
         rts

; print partition if it is valid
prnPrt2  jsr chkPrt
         bcc _prnPrtC
         beq _prnPrtN
_prnPrtC jmp prnPrt
_prnPrtN rts

; print partitions of device
prnPrts  jsr gtPrtCnt

         lda #0
         sta prtCur

_prnPrL1 jsr prnPrt2

         inc prtCur
         lda prtCur
         cmp prtCnt
         bcc _prnPrL1
         rts

; get partion count from APT sector
gtPrtCnt lda aptPCnt
         sec
         sbc #$10
         sta prtCnt
         lda #1
         sta notFound
         rts

; check partition
chkPrt   asl @
         asl @
         asl @
         asl @
         tax

         lda aptPlst,X
         beq _chkPrtN
         and #$40
         beq _chkPrtN
         lda aptPtyp,X
         bne _chkPrtN

         clc
         rts

_chkPrtN sec
         rts

; check APT meta sector for signature
chkAPTs1 ldx #3
_chkAPTl lda bufPDCB,X
         cmp APTsig1,X
         bne _chkAPTe
         dex
         bpl _chkAPTl
         rts
_chkAPTe ldy #191 ; APT signature is invalid
         jmp dosErroj

; check APT leading meta sector for signature
chkAPTs2 ldx #7
_chkAP2l lda bufDCB,X
         cmp APTsig2,X
         bne _chkAP2e
         dex
         bpl _chkAP2l
         rts
_chkAP2e ldy #192 ; APT leading signature is invalid
         jmp dosErroj

; get APT partition sector from MBR
getPSec  jsr fndAPT
         bcc _getPSf
         ldy #190 ; APT partition in MBR is not found
         jmp dosErroj
_getPSf  ldy #0
_getPSl2 lda prtTabSe,X
         sta prtSec,Y
         inx
         iny
         cpy #4
         bcc _getPSl2
         rts

; get PBI Id from COMFNAM
getPBIM  jsr BW_CRNAME
         lda BW_COMFNAM+4
         cmp #$9b
         bne errorPar
         lda BW_COMFNAM+3
         jsr chkAdig
         and #$0F
         cmp #$08
         bcs errorPar
         tax
         lda #1
_getPBIM dex
         bmi _getPBMe
         asl @
         bne _getPBIM
_getPBMe sta PDVMSK
         rts

errorPar ldy #156 ; Parameter error
errorPaV equ errorPar-1
         jmp dosErroj

chkAdig  cmp #'0'
         bcc errorPar
         cmp #'9'+1
         bcs errorPar
         rts

; get partition number from COMFNAM
getPRTM  jsr BW_CRNAME

         lda BW_COMFNAM+3
         jsr chkAdig
         and #$0F
         beq errorPar
         sta prtCur

         lda BW_COMFNAM+4
         cmp #$9b
         beq _getPTM1
         jsr chkAdig

         lda #0
_getPTM2 clc
         adc #10
         dec prtCur
         bne _getPTM2
         sta prtCur
         lda BW_COMFNAM+4
         and #$0F
         clc
         adc prtCur
         sta prtCur

         lda BW_COMFNAM+5
         cmp #$9b
         bne errorPar

_getPTM1 dec prtCur
         rts

; get drive number
getDRVM  jsr BW_CRNAME

         lda BW_COMFNAM+3
         cmp #'0'
         bcc errorPar
         cmp #'O'+1
         bcs errorPar
         cmp #'9'+1
         bcc getDRVM1
         cmp #'A'
         bcc errorPar
getDRVM1 and #$0F
         sta newDrv
         lda BW_COMFNAM+4
         cmp #$9B
         bne errorPar
         rts

; list PBI devices
lsDev    ldx #$00
         stx ctrlId
         inx
         stx PDVMSK
         stx notFound
_lsDevNx lda PDVMSK
         and sPDVMSK
         beq _lsDevNo
         jsr polling
         bmi _lsDevNo
         lsr notFound
         jsr prnPBI
_lsDevNo asl PDVMSK
         inc ctrlId 
         lda ctrlId 
         cmp #$08  
         bcc _lsDevNx
         lda notFound
         beq _lsDevEx
         jsr _print
         dta c'APT PBI devices are not found',b($9b,0)
_lsDevEx rts

; poll for PBI device 
polling  jsr SIOstat
         bmi *+5
         jsr SIOinfo
         rts

; print PBI device
prnPBI   lda ctrlId
         ora #$30
         sta prnPBIno
         ldx #0
_prnPBIl lda ImdName,X
         bne *+4
         lda #' '
         sta prnPBImd,X
         lda IctName,X
         bne *+4
         lda #' '
         sta prnPBIct,X
         inx
         cpx #16
         bcc _prnPBIl
         jsr _print
         dta c'PBI#'
prnPBIno dta c'x:'
prnPBImd dta c'                /'
prnPBIct dta c'                '
         dta b($9b,0)
_rts     rts

; error to DOS, if error code >$80
; -> Y = error code
dosError bpl _rts
; error to DOS
dosErroj jsr _exit
         tya
         jmp (BW_FAIL)

; call SIO

; write partition sector
SIOwrPrt lda <bufPDCB
         sta cmdCBbuf
         lda >bufPDCB
         sta cmdCBbuf+1
         ldx #3
_SIOwrPr lda prtSec,X
         sta cmdCBsec,X
         dex
         bpl _SIOwrPr
         lda #$57
         sta cmdCBcmd
         lda #$80
         sta cmdCBsta
         ldy #$20
         bne _nxtSIOs

; read partition sector
SIOrdPrt lda <bufPDCB
         sta cmdCBbuf
         lda >bufPDCB
         sta cmdCBbuf+1
         ldx #3
_SIOrdPr lda prtSec,X
         sta cmdCBsec,X
         dex
         bpl _SIOrdPr
         bmi _nxtSIOr

; read sector
SIOrdDCB lda <bufDCB
         sta cmdCBbuf
         lda >bufDCB
         sta cmdCBbuf+1
_nxtSIOr lda #$52
         sta cmdCBcmd
         lda #$40
         sta cmdCBsta
         ldy #$20
         bne _nxtSIOs

; force media change
SIOfmch  lda #$46
         sta cmdCBcmd
         lda #$00
         sta cmdCBsta
         ldy #$20
         bne _nxtSIOs

; device info
SIOinfo  lda <bufDCB
         sta cmdCBbuf
         lda >bufDCB
         sta cmdCBbuf+1
         ldy #$10
         bne _nxtSIOs

; device status
SIOstat  lda <bufDCB
         sta cmdCBbuf
         lda >bufDCB
         sta cmdCBbuf+1
         ldy #$00

_nxtSIOs ldx #$00
_nxtSIOc lda cmdDCB,Y
         sta DDEVIC,X
         iny
         inx
         cpx #$10
         bcc _nxtSIOc
         jmp (BW_LSIO)

; disk status
cmdDCB   dta b($A0,$01,$53,$40)
         dta a(bufDCB)
         dta b($06,$00)
         dta a($0004)
         dta b($00,$00,$00,$00,$00,$00)
; disk info
         dta b($A0,$01,$6E,$40)
         dta a(bufDCB)
         dta b($06,$00)
         dta a($0200)
         dta b($00,$00,$00,$00,$00,$00)
; read/write sector
         dta b($A0,$01)
cmdCBcmd dta b($52)
cmdCBsta dta b($40)
cmdCBbuf dta a(bufDCB)
         dta b($06,$00)
         dta a($0200)
cmdCBsec dta b($00,$00,$00,$00,$00,$00)

; APT sector signature $10APT
APTsig1  dta b($10)
; leading meta sígnature APT$00META
APTsig2  dta c'APT',b(0),c'META'
; MBR signature
MBRsig   dta b($55,$AA)

; APT types: D-DOS, C-FirmwareConfig, F-FloppyDrawer, X-ExternaMBR
APTprtTy dta c'DCFX'

prtCur   equ *
prtCnt   equ prtCur+4
prtDrv   equ prtCnt+1
newDrv   equ prtDrv+1
prtSec   equ newDrv+1
sPDVMSK  equ prtSec+4
ctrlId   equ sPDVMSK+1
notFound equ ctrlId+1
varEnd   equ notFound+1

bufStart equ varEnd&$FF00+$100
bufDCB   equ bufStart

; XDCB device info
IbyPsec  equ bufDCB+$06
IsecCnt  equ bufDCB+$08
ImdName  equ bufDCB+$10
IctName  equ bufDCB+$38

; MBR partion
prtTab   equ bufDCB+$1BE
prtTabTy equ prtTab+$04
prtTabSe equ prtTab+$08
prtTabCn equ prtTab+$0C
; MBR signature
prtSig   equ bufDCB+$1FE

; APT meta sector
prtName  equ bufDCB+$10

bufPDCB  equ bufDCB+$200
aptMsec  equ bufPDCB+2
aptPCnt  equ bufPDCB+5
aptPnext equ bufPDCB+8
aptPprev equ bufPDCB+8
mapPrtNo equ bufPDCB+10

aptPlst  equ bufPDCB+$100
aptPtyp  equ aptPlst+1
aptPsec  equ aptPlst+2
aptPXsec equ aptPlst+12

         end
