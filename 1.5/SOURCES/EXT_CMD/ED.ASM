; BW-ED 1.5 Editor

; System equates
ICHID    equ $00
ICDNO    equ $01
ICCOM    equ $02
ICSTA    equ $03
ICBAL    equ $04
ICBAH    equ $05
ICPTL    equ $06
ICPTH    equ $07
ICBLL    equ $08
ICBLH    equ $09
ICAX1    equ $0A
ICAX2    equ $0B
ICAX3    equ $0C

NGFLAG   equ $01
DOSVEC   equ $0A
BRKKEY   equ $11
SAVMSC   equ $58
KEYDEF   equ $79

ZSCRNBUF equ $D0 ; start of screen buffer
ZTXTBUFL equ $D2 ; length of text buffer
ZKEYDEF  equ $D4 ; key def 800 $fefe of KEYDEF

NOCLIK   equ $2DB
MEMTOP   equ $2E5
CH       equ $2FC

IOCB1    equ $350
IOCB1ID  equ $10

CONSOL   equ $D01F
VCOUNT   equ $D40B
SKCTL    equ $D20F
CIOV     equ $E456

REVNUM   equ $fff7
KDEF800  equ $fefe

BW_SPARTA  equ $700 ; SpartaDOS flag 'S'
BW_DOS     equ $703 ; BW-DOS flag 'BW'
BW_VERS    equ $705 ; BW-DOS version
BW_CRNAME  equ $729 ; Jump to CRNAME
BW_COMFNAM equ $747 ; result from BW_CRNAME
BW_CURDRV  equ $7A6 ; current drive in Dx:<EOL>

SCRNBUFO equ 24*40-1 ; screen buffer offset below MEMTOP

         blk dos $2800
; test BW-DOS 1.5
         lda BW_SPARTA
         cmp #'S'
         bne _bw15_e
         lda BW_DOS
         cmp #'B'
         bne _bw15_e
         lda BW_DOS+1
         cmp #'W'
         bne _bw15_e
         lda BW_VERS
         cmp #$15
         bcs _bw15_f
_bw15_e  lda #$0B
         sta $342
         lda <_bw15_t
         sta $344
         lda >_bw15_t
         sta $345
         lda <_bw15_f-_bw15_t
         sta $348
         ldx #$00
         stx $349
         jsr CIOV
         jmp ($000A)
_bw15_t  dta b($9B,$FD)
         dta c'Error: no BW-DOS 1.5'
         dta b($9B)
_bw15_f  equ *

; set key def OS A/B or XL
         lda KEYDEF
         sta ZKEYDEF
         lda KEYDEF+1
         sta ZKEYDEF+1
         lda REVNUM
         cmp #$FF
         bne initBuff ; $FF for OS A/B
         lda #$FE     ; KEYDEF $FEFE
         sta ZKEYDEF
         sta ZKEYDEF+1

; calculate text buffer size and screen buffer address
initBuff sec
         lda MEMTOP
         sbc <SCRNBUFO
         sta ZSCRNBUF
         lda MEMTOP+1
         sbc >SCRNBUFO
         sta ZSCRNBUF+1

         sec
         lda ZSCRNBUF
         sbc <TXTBUFFE
         sta ZTXTBUFL
         lda ZSCRNBUF+1
         sbc >TXTBUFFE
         sta ZTXTBUFL+1

; save screen
         lda ZSCRNBUF
         sta $F4
         lda ZSCRNBUF+1
         sta $F5
         lda SAVMSC
         sta $F8
         lda SAVMSC+1
         sta $F9
         ldx WNDLINES
         inx
L4014    jsr CPINCDST
         jsr INC_SRC
         dex
         bpl L4014

; init
         lda TXTBUFFB
         bne L4029
         jsr INI_CLOS ; init data and close IOCB1
         lda #$03
         sta $FC
L4029    jsr DOSPARA ; check for SparataDOS parameter
         beq L403B

; read file of parameter
         lda #$04  ; for read
         sta IOCB1+ICAX1
         jsr OPEN_RW4
         bmi PREADER
         jsr TRY_RD4
; close IOCB1 if error
PREADER  jsr CLOS_IO4

; main loop
L403B    lda $E7
         tax
         cmp $EF
         bcc L404B
         sbc #$25
         bcc L404D
         tax
         cmp $EF
         bcc L404D
L404B    stx $EF
L404D    jsr UPD_SCRN
         jsr CHK_KEY
         jsr EXE_KEY
         jmp L403B

; check for SparatDOS parameter
DOSPARA  lda BW_CURDRV+1
         sta L4873+1
         jsr BW_CRNAME
         beq NO_PARAM
         ldx #$00
         stx $FC
PARALOOP lda BW_COMFNAM,X  ; copy file name to screen
         cmp #$9B
         beq PARAM_OK
         sta L4873,X
         inc $FC
         inx
         bne PARALOOP ; BW-DOS CFNAME max 28 bytes (at least 28th is EOL)
PARAM_OK lda #$01
         rts
NO_PARAM lda #$00 ; not SparatDOS
         rts

; initialize zero page addresses
L4059    dta a(TXTBUFF) ; $E0 Text buffer begin
         dta a(TXTBUFF) ; $E2 Start Current Line
         dta a(1)     ; $E4 Number Current Line
         dta b($00)   ; $E6 
         dta b($00)   ; $E7 Current Column
         dta b(1)     ; $E8 TOTO 1 Line count
         dta b(0)     ; $E9
         dta a(TXTBUFF) ; $EA Start Tagged Line
         dta a(TXTBUFFE) ; $EC End of current text
         dta b($20)   ; $EE
         dta b($00)   ; $EF
         dta b($00)   ; $F0
         dta b($00)   ; $F1
         dta b($FF)   ; $F2
ZEROINI  ldy #$12 ; copy $12 bytes to $E0
L406E    lda L4059,Y
         sta $00E0,Y
         dey
         bpl L406E
         rts


L407B    jsr UPD_SCRN
; read pressed key
CHK_KEY  lda #$FF  ; check for key
         tax
         cmp CH
         beq CHK_KEY

         ldy NOCLIK
         bne DO_KEY
; sound key click
         ldy #2*63 ;2 times trip count
; Turn loudspeaker on
SKC1     sty CONSOL ;turn loudspeaker on
; Wait for VBLANK (loudspeaker off)
         lda VCOUNT
SKC2     cmp VCOUNT
         beq SKC2
; Decrement and check trip count
         dey
         dey
         bpl SKC1
         txa

DO_KEY   bit CH
         bpl L408F  ; no ctrl key
         bvc L408F  ; no shift key
         lda #$3F
L408F    sta $F2
         and CH
         stx CH
         tay
         and #$3F
         cmp #$3C
         beq L40AF
         cmp #$27
         beq L40B7

;         lda $FEFE,Y   ; OS A/B
;         lda (KEYDEF),Y ; XL
         lda (ZKEYDEF),Y ; OS A/B or XL

         cmp #$61  ; < a
         bcc L40AE
         cmp #$7B  ; > z
         bcs L40AE
         eor $EE
L40AE    rts

L40AF    lda $EE
         eor #$20
         sta $EE
         bcs L407B
L40B7    lda $F0
         eor #$80
         sta $F0
         bcs CHK_KEY
L40BF    asl @
         php
         cmp #$C0
         bcs L40CB
         sbc #$3F
         bcs L40CB
         adc #$C0
L40CB    plp
         ror @
         rts

; write state, input A, position Y
WRT_NR   sta $FA
         lda #$00
         sta $FF
         clc
         php
         bcc L40DE
; in A: high byte, X: low byte, Y: position
WRT_NR2  stx $FA
         sta $FF
         sec
         php
L40DE    lda #$00
         sta $F6
         sta $F7
         sta $F8

         ldx #$0F
         sed   ; convert to dec ascii
L40E9    asl $FA
         rol $FF
         lda $F6
         adc $F6
         sta $F6
         lda $F7
         adc $F7
         sta $F7
         rol $F8
         dex
         bpl L40E9
         cld

         lda $F6
         jsr L412F

         lda $F7
         plp
         bcc L410E
         jsr L412F

         lda $F8
L410E    jsr L4138
         iny
         sty $FA
L4114    lda L4868,Y
         cmp #$30
         bne L412E
         ldx $FA
L411D    lda L4868+1,X
         sta L4868,X
         inx
         cmp #$12
         bne L411D

         dex
         dex
         cpx $FA
         bne L4114
L412E    rts

L412F    pha
         jsr L4138
         pla
         lsr @
         lsr @
         lsr @
         lsr @
L4138    and #$0F
         ora #$30
         sta L4868,Y
         dey
         rts

L4141    lda SAVMSC
         sta $F8
         lda SAVMSC+1
         sta $F9
         ldx WNDLINES
         inx
L414D    jsr INC_SRC
         dex
         bpl L414D
         rts

; copy line and increment destination
CPINCDST ldy #$27
L4156    lda ($F8),Y
         sta ($F4),Y
         dey
         bpl L4156
         clc
         lda $F4
         adc #$28
         sta $F4
         bcc L4168
         inc $F5
L4168    rts

L4169    sec
         lda $F8
         sbc #$28
         sta $F8
         bcs L4174
         dec $F9
L4174    sec
         lda $F4
         sbc #$28
         sta $F4
         bcs L417F
         dec $F5
L417F    ldy #$27
L4181    lda ($F4),Y
         sta ($F8),Y
         dey
         bpl L4181
         rts

CIOV4    ldx #IOCB1ID
         jsr CIOV
         bpl L419D
         
WRT_FAIL lda #$0C ; write "Fail"
         jsr WRT_STAT
         lda IOCB1+ICSTA
         ldy #$09
         jsr WRT_NR
         jmp L419D2
L419D    ldy #$12
         sty L4872
L419D2   ldy IOCB1+ICSTA
         rts

WRT_STAT tay
         ldx #$03
L41A9    lda L41B8,Y
         sta L4868+1,X
         lda #$12
         sta L486E,X
         dey
         dex
         bpl L41A9
         tya
         lsr @
         lsr @
         tay
         lda MDLSTCH,Y
         sta L4868+5
L41B8    rts
         dta c'LoadSaveErroEdit'
MDLSTCH  dta b($12,$12),c'r',b($12)

L41C9    tya
         clc
         adc $F6
         sta $F6
         bcc L41D3
         inc $F7
L41D3    rts

; increment source (updates screen)
INC_SRC  lda #$28
         clc
         adc $F8
         sta $F8
         sta L4546+1
         lda $F9
         adc #$00
         sta $F9
         sta L4546+2
         rts

L41E8    jsr WRT_STAT
         lda #$00
         sta $FD
         sta $F1
         lda $EE
         pha
         lda #$20
         sta $EE
L41F8    ldx $FC
         lda #$A0
         sta L4873,X
         jsr UPD_SCRN
         jsr CHK_KEY
         ldx $FC
         cmp #$9B
         beq L4234
         and #$7F
         cmp #$1B
         beq L4232
         cmp #$7E
         beq L4228
         cmp #$21
         bcc L41F8
         cmp #$7E
         bcs L41F8
         cpx #$1B
         bcs L41F8
         sta L4873,X
         inc $FC
         bpl L41F8
L4228    txa
         beq L41F8
         jsr L4237
         dec $FC
         bpl L41F8
L4232    dec $F1
L4234    pla
         sta $EE
L4237    lda #$12
         sta L4873,X
         rts

L423D    sta IOCB1+ICAX1
         jsr L41E8
OPEN_RW4 ldy $F1   ; IOCB1 closed?
         beq L4248
         rts
L4248    dey
         sty BRKKEY
         lda #$03  ; OPEN
         sta IOCB1+ICCOM
         lda <L4873  ; address file name
         sta IOCB1+ICBAL
         lda >L4873
         sta IOCB1+ICBAH
         lda #$00
         sta IOCB1+ICAX2
         jsr CIOV4
         lda IOCB1+ICAX1
         ora #$03
         sta IOCB1+ICCOM
         lda <TXTBUFF
         sta IOCB1+ICBAL
         lda >TXTBUFF
         sta IOCB1+ICBAH
         tya
         rts

; startup init
INI_CLOS jsr ZEROINI
         lda #$9B
         sta TXTBUFF
         sta TXTBUFFB
CLOS_IO4 lda #$0C  ; CLOSE IOCB1
         sta IOCB1+ICCOM
         ldx #IOCB1ID
         jsr CIOV
         lda #$03  ; init keyboard
         sta SKCTL
         lda #$80  ; set flags
         sta $FD
         asl @
         sta $F1   ; set flag IOCB Closed
         rts

; command load text
X_LOADTX lda #$04
         jsr L423D
         bpl TRY_RD4

L42A3    jmp CLOS_IO4

TRY_RD4  lda $F1
         bne L42A3
         jsr ZEROINI
         lda ZTXTBUFL ; max length
         sta IOCB1+ICBLL
         lda ZTXTBUFL+1
         sta IOCB1+ICBLH
         ldx #IOCB1ID
         jsr CIOV
         cpy #$88  ; EOF
         beq L42C6
; check and handle file too large
         cpy #$01
         bne READERR
         ldy #$89 ; truncated record
         sty IOCB1+ICSTA
         jsr WRT_FAIL
         jmp L42C6

READERR  jsr WRT_FAIL
         jmp INI_CLOS

L42C6    clc
         lda <TXTBUFF  ; calc end address
         adc IOCB1+ICBLL
         sta $EC
         lda >TXTBUFF
         adc IOCB1+ICBLH
         sta $ED
         jsr CLOS_IO4

L42DA    ldx #$00
; set end EOL mark
         lda #$9B
         sta ($EC,X)
         jsr L478C
         cpy #$80
         bcc L42F1

; truncated rec at too long line;
; stop load, show error, and reinit;
; originally it was tried to add EOLS
         ldy #$89 ; truncated record
         sty IOCB1+ICSTA
         jsr WRT_FAIL
         jmp INI_CLOS

L42F1    inc $E8
         bne *+4
         inc $E9
         ldx #$E2
         jsr L47B1
         sec
         lda $E2
         sbc $EC
         lda $E3
         sbc $ED
         bcc L42DA

L42F1B   lda $E2
         sta $EC
         lda $E3
         sta $ED
         lda $E8
         bne L4315
         dec $E9
L4315    dec $E8
         ldy #$07
         jmp L406E

; command save text
X_SAVETX lda #$08
         jsr L423D
         bmi L433B
         lda $F1
         bne L433B
         sec
         lda $EC
         sbc <TXTBUFF
         sta IOCB1+ICBLL
         lda $ED
         sbc >TXTBUFF
         sta IOCB1+ICBLH

         jsr CIOV4
L433B    jmp CLOS_IO4
L433E    sec
         lda $EC
         sbc $F6
         tay
         lda $ED
         sbc $F7
         tax
         stx $FA
         rts

L434C    sta $FF
         jsr L433E
         clc
         lda $EC
         adc $FF
         sta $F8
         lda $ED
         adc #$00
         sta $F9
         lda ZSCRNBUF
         cmp $F8
         lda ZSCRNBUF+1
         sbc $F9
         bcs L436A
         sec
         rts

L436A    jsr L473A
         bcs L437A
; update tagged line
         clc
         lda $EA
         adc $FF
         sta $EA
         bcc L437A
         inc $EB
L437A    lda $F8
         sta $EC
         lda $F9
         sta $ED
         clc
         lda $F6
         adc $FF
         sta $F8
         lda $F7
         adc $FA
         sta $F9
         clc
         lda $F7
         adc $FA
         sta $F7
         jmp L43A2
L4399    dec $F7
         dec $F9
L439D    dey
         lda ($F6),Y
         sta ($F8),Y
L43A2    tya
         bne L439D
         dex
         bpl L4399
         clc
         rts

L43AA    sta $FF
         sec
         lda $EC
         sbc $FF
         sta $EC
         bcs L43B7
         dec $ED
L43B7    jsr L473A
         bcs L43C7
; update tagged line
         sec
         lda $EA
         sbc $FF
         sta $EA
         bcs L43C7
         dec $EB
L43C7    clc
         lda $F6
         adc $FF
         sta $F8
         lda $F7
         adc #$00
         sta $F9
         jsr L433E
         sty $FA
         ldy #$00
L43DB    dex
         bmi L43EB
L43DE    lda ($F8),Y
         sta ($F6),Y
         iny
         bne L43DE
         inc $F9
         inc $F7
         bne L43DB
L43EB    cpy $FA
         beq L43F6
         lda ($F8),Y
         sta ($F6),Y
         iny
         bne L43EB
L43F6    rts

L43F7    pha
         clc
         lda $E2
         adc $E7
         sta $F6
         lda $E3
         adc #$00
         sta $F7
         lda #$01
         jsr L434C
         pla
         bcs L441C
         ldy $E7
         sta ($E2),Y
         cmp #$9B
         bne L441B
         inc $E8
         bne L441B
         inc $E9
L441B    clc
L441C    rts

L441D    clc
         lda $E2
         adc $E7
         sta $F6
         lda $E3
         adc #$00
         sta $F7
         lda #$01
         jmp L43AA

EXE_KEY  sta $FA
         lda #$10  ; write Edit
         jsr WRT_STAT
         lda $FA
         bit $F2
         bmi L447F
         cmp #$2D
         bne L4443
         jmp X_PAGEUP
L4443    cmp #$3D
         bne L444A
         jmp X_PAGEDW
L444A    ora #$20
         cmp #$65 ; <CTRL><SHIFT><E>
         bne L447E
; clear buffer
         jsr SETCHFL
         jmp INI_CLOS

; command move window up (shrink)
X_WINSUP ldx WNDLINES
         dex
         beq L447E
         stx WNDLINES
         dex
         cpx $E6
         bcs L4464
         jsr X_CURSUP
L4464    jsr L4141
         jsr INC_SRC
         jmp L4169

; set change flag
SETCHFL  pha
         lda #$2A
         sta L4872
         pla
         rts

; command move window down (enlarge)
X_WINDWN ldx WNDLINES
         inx
         cpx #$17
         bcs L447E
         jsr L4141
         jsr CPINCDST
         inc WNDLINES
L447E    rts

L447F    ldy $F1
         bne L448D
         ldy #$18
L4485    cmp L4829,Y
         beq L44A9
         dey
         bpl L4485
L448D    jsr SETCHFL
         ldy #$00
         sty $F1
         cmp #$9B
         beq L44A3
         ora $F0
         jsr L478C
         cpy #$7F
         bcs L447E
L44A3    jsr L43F7
         jmp X_CURRGT
L44A9    tya
         asl @
         tay
         lda L483E,Y
         sta $F8
         lda L483E+1,Y
         sta $F9
         jmp ($F8)

; update screen
UPD_SCRN ldy $E7
         iny
         tya
         ldy #$48
         jsr WRT_NR  ; write current Column

         ldy $E7
         lda ($E2),Y
         ldy #$4D
         jsr WRT_NR  ; write ATASCII under cursor

         ldx $E4
         lda $E5
         ldy #$3F
         jsr WRT_NR2  ; write current Line

         sec
         lda ZSCRNBUF
         sbc $EC
         tax
         lda ZSCRNBUF+1
         sbc $ED
         ldy #$34
         jsr WRT_NR2  ; write free bytes

         ldx #$1D
         lda $EE
         beq L44EA
         dex
L44EA    stx L4891
         lda SAVMSC
         sta $F8
         lda SAVMSC+1
         sta $F9
         ldx #$27
         jsr L458F

         lda $E0
         sta $F6
         lda $E1
         sta $F7
         lda #$00
         sta $FA
;
; loop over all screen lines
;
L4506    ldx #$01
         lda #$FC
         ldy $EA
         cpy $F6
         bne L4518
         ldy $EB
         cpy $F7
         bne L4518
         lda #$D4
L4518    ldy #$27
         sta ($F8),Y
         ldy #$00
         sta ($F8),Y
         lda $F6
         cmp $EC
         lda $F7
         sbc $ED
         bcs L455F

         lda #$9B
         ldy #$00
L452E    cpy $EF
         beq L4539
         cmp ($F6),Y
         beq L455B
         iny
         bpl L452E

L4539    lda ($F6),Y
         cmp #$9B
         php
         bne L4543
         lda L48B9
L4543    jsr L40BF
L4546    sta L4546,X
         inx
         plp
         beq L455B
         iny
         cpx #$27
         bcc L4539

         lda #$9B
L4554    cmp ($F6),Y
         beq L455B
         iny
         bpl L4554

L455B    iny
         jsr L41C9
L455F    txa
         tay
         lda #$00
L4563    cpy #$27
         bcs L456C
         sta ($F8),Y
         iny
         bpl L4563

L456C    lda $FA
         cmp $E6
         bne L457E
         lda $E7
         sbc $EF
         tay
         iny
         lda ($F8),Y
         eor $FD
         sta ($F8),Y
L457E    jsr INC_SRC
         inc $FA
         lda $FA
         cmp WNDLINES
         beq L458D
         jmp L4506

; last line
L458D    ldx #$4F
L458F    ldy #$27
L4591    lda L4868,X
         jsr L40BF
         eor #$80
         sta ($F8),Y
         dex
         dey
         bpl L4591
         
         jmp INC_SRC

; check for changes to save
X_EXITED lda L4868+10
         cmp #'*'
         bne *+5
         jsr X_SAVETX

         pla
         pla
         jsr L4141
         ldx WNDLINES
         inx
L45AB    jsr L4169
         dex
         bpl L45AB
         rts

; command escape next character
X_ESCNCH lda #$FF
         sta $F1
         rts

; command delete next character
X_DELNXT jsr X_CURLFT
         bcs L45E0
; command delete character under cursor
X_DELUND ldy $E7
         lda ($E2),Y
         cmp #$9B
         bne L45D1
         jsr L4743
         bcs L45E0
         lda $E8
         bne L45CF
         dec $E9
L45CF    dec $E8
L45D1    jsr L441D
         jsr L478C
         cpy #$80
         bcc L45E0
         lda #$9B
         jsr L43F7
L45E0    jsr SETCHFL
         lda $EA
         sta $F6
         ldy $EB
         dey
         sty $F7
         ldy #$FF
         lda ($F6),Y
         cmp #$9B
         beq L45F4
         jmp X_GOTOTG
L45F4    rts

; command delete line
X_DELLIN jsr X_GTBGNL
         jsr SETCHFL
         lda $E2
         sta $F6
         lda $E3
         sta $F7
         jsr L478C
         jsr L4743
         php
         bcs L460A
         iny
L460A    tya
         jsr L43AA
         plp
         bcs L461A
         lda $E8
         bne L4617
         dec $E9
L4617    dec $E8
         clc
L461A    rts

; command insert
X_INSLIN lda #$9B
         bne *+4
X_INSERT lda #$20
         jsr SETCHFL
         jsr EXE_KEY
         jsr X_CURLFT
         rts

; command insert before tagged line
X_TAGCPY jsr L478C
         jsr SETCHFL
         sty $FE
         lda $EA
         sta $F6
         lda $EB
         sta $F7
         iny
         tya
         jsr L434C
         bcc L4630
         rts
L4630    inc $E8
         bne L4636
         inc $E9
L4636    lda $E0
         cmp $EA
         lda $E1
         sbc $EB
         bcc L464E
         sec
         lda $E0
         adc $FE
         sta $E0
         bcc L464B
         inc $E1
L464B    jmp L465D
L464E    lda $EA
         cmp $E2
         lda $EB
         sbc $E3
         bcs L466B
         ldx #$E0
         jsr L47B1
L465D    sec
         lda $E2
         adc $FE
         sta $E2
         bcc L4668
         inc $E3
L4668    jsr L474C
L466B    ldy $FE
L466D    lda ($E2),Y
         sta ($EA),Y
         dey
         bpl L466D
         sec
         lda $EA
         adc $FE
         sta $EA
         bcc L467F
         inc $EB
L467F    jmp X_CURDWN

; command goto tagged line
X_GOTOTG lda $E2
         sta $EA
         lda $E3
         sta $EB
         rts

; command tag line
X_TAGLIN jsr X_GTENDT
         jsr X_GTBGNL
L4691    lda $E2
         cmp $EA
         bne L469D
         lda $E3
         cmp $EB
         beq L46A2
L469D    jsr X_CURSUP
         bcc L4691
L46A2    rts
L46A3    dec $E7
         clc
L46A6    rts

; command cursor left
X_CURLFT ldy $E7
         bne L46A3
         lda #$01
         cmp $E4
         lda #$00
         sbc $E5
         bcs L46A6
         jsr X_CURSUP
         jmp X_GTENDL

; command cursor up
X_CURSUP jsr L4758
         bcs L46A6
         ldx #$E2
         jsr L479A
         lda $E6
         beq L46CE
         dec $E6
         jmp L4705
L46CE    ldx #$E0
         jsr L479A
         jmp L4705
L46D6    inc $E7
         clc
L46D9    rts

; command cursor right
X_CURRGT ldy $E7
         lda ($E2),Y
         cmp #$9B
         bne L46D6
         jsr L4743
         bcs L46D9
         jsr X_GTBGNL

; command cursor down
X_CURDWN jsr L474C
         bcs L46D9
         ldx #$E2
         jsr L47B1
         ldx $E6
         inx
         cpx WNDLINES
         bcs L4700
         inc $E6
         bcc L4705
L4700    ldx #$E0
         jsr L47B1
L4705    ldy #$00
L4707    cpy $E7
         beq L4714
         lda ($E2),Y
         cmp #$9B
         beq L4714
         iny
         bne L4707
L4714    sty $E7
         clc
         rts

; command page up
X_PAGEUP ldx WNDLINES
         dex
         bne L471F
         inx
L471F    stx $FA
L4721    jsr X_CURSUP
         dec $FA
         bne L4721
         rts

; command page down
X_PAGEDW ldx WNDLINES
         dex
         bne L4730
         inx
L4730    stx $FA
L4732    jsr X_CURDWN
         dec $FA
         bne L4732
         rts

L473A    lda $F6
         cmp $EA
         lda $F7
         sbc $EB
         rts
L4743    lda $E4
         cmp $E8
         lda $E5
         sbc $E9
         rts
L474C    jsr L4743
         bcs L4757
         inc $E4
         bne L4757
         inc $E5
L4757    rts
L4758    lda #$01
         cmp $E4
         lda #$00
         sbc $E5
         bcs L476B
         lda $E4
         bne L4768
         dec $E5
L4768    dec $E4
         clc
L476B    rts

; command togle display of EOL
X_SHWEOL lda L48B9
         eor #$BB
         sta L48B9
         rts

; command goto begin of text
X_GTBGNT jsr X_CURSUP
         bcc X_GTBGNT

; command goto begin of line
X_GTBGNL lda #$00
         sta $E7
         clc
         rts

; command goto end of text
X_GTENDT jsr X_CURDWN
         bcc X_GTENDT

; command goto end of line
X_GTENDL jsr L478C
         sty $E7
         clc
         rts
L478C    pha
         ldy #$00
         lda #$9B
L4791    cmp ($E2),Y
         beq L4798
         iny
         bpl L4791
L4798    pla
         rts
L479A    lda $00,X
         sta $F6
         lda NGFLAG,X
         sta $F7
         dec $F7
         ldy #$FF
L47A6    dey
         lda ($F6),Y
         cmp #$9B
         bne L47A6
         iny
         jmp L47C2
L47B1    lda $00,X
         sta $F6
         lda NGFLAG,X
         sta $F7
         ldy #$00
L47BB    lda ($F6),Y
         iny
         cmp #$9B
         bne L47BB
L47C2    jsr L41C9
         lda $F6
         sta $00,X
         lda $F7
         sta NGFLAG,X
         rts

; Operations: key and jump table
L4829    dta b($18,$1B,$1C,$1D,$1E,$1F,$7E,$FE)
         dta b($01,$1A,$15,$04,$02,$05,$14,$07)
         dta b($9C,$03,$0C,$13,$16,$00,$60,$FF)
         dta b($9D)

L483E    dta a(X_EXITED) ; <CTRL><X>
         dta a(X_ESCNCH) ; <ESC>
         dta a(X_CURSUP) ; Up
         dta a(X_CURDWN) ; Down
         dta a(X_CURLFT) ; Left
         dta a(X_CURRGT) ; Right
         dta a(X_DELNXT) ; <Delete
         dta a(X_DELUND) ; <CTRL><Delete>

         dta a(X_GTBGNL) ; <CTRL><A>
         dta a(X_GTENDL) ; <CTRL><Z>
         dta a(X_WINSUP) ; <CTRL><U>
         dta a(X_WINDWN) ; <CTRL><D>
         dta a(X_GTBGNT) ; <CTRL><B>
         dta a(X_GTENDT) ; <CTRL><E>
         dta a(X_GOTOTG) ; <CTRL><G>
         dta a(X_TAGLIN) ; <CTRL><T>

         dta a(X_DELLIN) ; <SHIFT><Delete>
         dta a(X_TAGCPY) ; <CTRL><C>
         dta a(X_LOADTX) ; <CTRL><L>
         dta a(X_SAVETX) ; <CTRL><S>
         dta a(X_SHWEOL) ; <CTRL><V>
         dta a(X_PAGEUP) ; <CTRL><[>
         dta a(X_PAGEDW) ; <CTRL><]>
         dta a(X_INSERT) ; <INS>

         dta a(X_INSLIN) ; <SHIFT><INS>

; Data for first and last line
; first line with state
L4868    dta b($11),c'BW-ED'
L486E    dta c'1.5',b($12)
L4872    dta b($12)
L4873    dta c'D1:' ; file name
         dta b($12,$12,$12,$12,$12,$12,$12,$12)
         dta b($12,$12,$12,$12,$12,$12,$12,$12)
         dta b($12,$12,$12,$12,$12,$12,$12,$12)
         dta b($12,$05)
; last line with info
         dta b($1A)
L4891    dta b($12,$12)
         dta c'Free:'
         dta b($12,$12,$12,$12,$12,$12)
         dta c'Line:'
         dta b($12,$12,$12,$12,$12,$12)
         dta c'Col:'
         dta b($12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$03)

; Vectors and Variables
WNDLINES dta b($16) ; number of text line
L48B9    dta b($20)

TXTBUFFB dta b($00)
TXTBUFF  equ *   ; text buffer
TXTBUFFE equ *+1 ; initial end of text buffer

         end
