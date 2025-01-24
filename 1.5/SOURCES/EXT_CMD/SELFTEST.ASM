* SELF TEST - ATARI RAINBOW
* XL1200 PLUS RAINBOW LOGO
* 10/26/82

* Equates
RAMTOP EQU $6A

COLDST EQU $244
HELPFG EQU $2DC
ATACHR EQU $2FB

ICCOM  EQU $342
ICBAL  EQU $344
ICBAH  EQU $345
ICAX1  EQU $34A
ICAX2  EQU $34B

COLPF0 EQU $D016
CONSOL EQU $D01F
IRQEN  EQU $D20E
WSYNC  EQU $D40A
PORTB  EQU $D301

CIOV   EQU $E456
SETVBV EQU $E45C
XITVBV EQU $E462
COLDSV EQU $E477
SLFTSV EQU $E483

REVNUM   equ $fff7

ZPAGE1 EQU $80
ZPAGE2 EQU $82
RAIN   EQU $84

       BLK DOS $3000
* cold start at reset
       LDA #$FF
       STA COLDST
* reset HELP key
       LDA #0
       STA HELPFG
* close E:
       LDX #$00
       LDA #$0C
       STA ICCOM,X
       JSR CIOV
* open E:
* screen memory hard coded $4000
       LDA >$4000
       STA RAMTOP
       LDX #$00
       LDA #$03
       STA ICCOM,X
       LDA <SCRN
       STA ICBAL,X
       LDA >SCRN
       STA ICBAH,X
       LDA #8
       STA ICAX1,X
       LDA #6
       STA ICAX2,X
       JSR CIOV
* enable keyboard
       LDA #$40
       STA IRQEN
* Draw ATARI
       LDX #0
       LDY #0
       LDA <DATTBL
       STA ZPAGE1
       LDA >DATTBL
       STA ZPAGE1+1
       LDA <DATADR
       STA ZPAGE2
       LDA >DATADR
       STA ZPAGE2+1
MAINLP LDA (ZPAGE1),Y
       STA (ZPAGE2),Y
       INY
       CPY #$0E
       BNE MAINLP
       LDY #0
       CLC
       LDA ZPAGE1
       ADC #$0E
       STA ZPAGE1
       BCC *+4
       INC ZPAGE1+1
       CLC
       LDA ZPAGE2
       ADC #$14
       STA ZPAGE2
       BCC *+4
       INC ZPAGE2+1
       INX
       CPX #$1A
       BNE MAINLP
* Draw the (R) mark.
       LDX #$04
       LDY #$00
PPD1   LDA TPOR1,X
       STA TPOR1A,Y
       LDA TPOR2,X
       STA TPOR2A,Y
       TYA
       CLC
       ADC #20
       TAY
       DEX
       BPL PPD1
* switch on rainbow
       LDY <VBLK
       LDX >VBLK
       LDA #7
       JSR SETVBV
* wait for HELP or START
       LDA #$08
       STA CONSOL
STALL  LDA HELPFG
       BNE BYEBYE
       LDA CONSOL
       AND #$01
       BNE STALL
BYEBYE LDA #$08
       STA CONSOL
       LDA #0
       STA HELPFG
* switch off rainbow
       LDY <XITVBV
       LDX >XITVBV
       LDA #7
       JSR SETVBV
* check XL or 400/800
       LDA REVNUM
       BPL XLSTST
* 400/800 cold start
       jmp COLDSV
* XL jump to self test
XLSTST LDA PORTB
       AND #$7F
       STA PORTB
       JMP SLFTSV

* vertical blank interrupt routrine
VBLK   SEI
       DEC RAIN
       LDA RAIN
       AND #$FE
       TAX
       LDY #230
VLP    STA WSYNC
       INX
       INX
       BNE VR
       LDX #$10
VR     STX COLPF0
       DEY
       BNE VLP
       CLI
       JMP XITVBV

SCRN   DTA c'S:',B($9B)

* Fuji ATARI
DATADR EQU $3AB3 ;$3AB5
DATTBL DTA B($00,$13,$90,$00,$00,$01,$C3,$FF,$FE,$1C,$00,$1F,$E0,$7C)
       DTA B($00,$13,$90,$00,$00,$03,$E3,$FF,$FE,$3E,$00,$7F,$F8,$7C)
       DTA B($00,$13,$90,$00,$00,$07,$F3,$FF,$FE,$7F,$00,$7F,$FC,$7C)
       DTA B($00,$13,$90,$00,$00,$07,$F3,$FF,$FE,$7F,$00,$FF,$FE,$7C)
       DTA B($00,$13,$90,$00,$00,$07,$F0,$0F,$80,$7F,$00,$FC,$3F,$7C)
       DTA B($00,$13,$90,$00,$00,$0F,$F8,$0F,$80,$FF,$80,$F8,$1F,$7C)
       DTA B($00,$13,$90,$00,$00,$0F,$F8,$0F,$80,$FF,$80,$F8,$1F,$7C)
       DTA B($00,$13,$90,$00,$00,$0F,$F8,$0F,$80,$FF,$80,$F8,$1F,$7C)
       DTA B($00,$13,$90,$00,$00,$1F,$7C,$0F,$81,$F7,$C0,$F8,$1F,$7C)
       DTA B($00,$13,$90,$00,$00,$1F,$7C,$0F,$81,$F7,$C0,$F8,$1F,$7C)
       DTA B($00,$13,$90,$00,$00,$1F,$7C,$0F,$81,$F7,$C0,$F8,$3E,$7C)
       DTA B($00,$13,$90,$00,$00,$3E,$3E,$0F,$83,$E3,$E0,$F8,$7C,$7C)
       DTA B($00,$13,$90,$00,$00,$3E,$3E,$0F,$83,$E3,$E0,$F8,$F8,$7C)
       DTA B($00,$33,$98,$00,$00,$3E,$3E,$0F,$83,$E3,$E0,$F9,$F0,$7C)
       DTA B($00,$33,$98,$00,$00,$7C,$1F,$0F,$87,$C1,$F0,$FB,$E0,$7C)
       DTA B($00,$73,$9c,$00,$00,$7C,$1F,$0F,$87,$C1,$F0,$FB,$E0,$7C)
       DTA B($00,$73,$9c,$00,$00,$7C,$1F,$0F,$87,$C1,$F0,$F9,$F0,$7C)
       DTA B($00,$e3,$8e,$00,$00,$FF,$FF,$8F,$8F,$FF,$F8,$F9,$F0,$7C)
       DTA B($01,$e3,$8f,$00,$00,$FF,$FF,$8F,$8F,$FF,$F8,$F8,$F8,$7C)
       DTA B($07,$e3,$8f,$c0,$00,$FF,$FF,$8F,$8F,$FF,$F8,$F8,$F8,$7C)
       DTA B($0f,$c3,$87,$f0,$01,$FF,$FF,$CF,$9F,$FF,$FC,$F8,$7C,$7C)
       DTA B($3f,$83,$83,$f8,$01,$F0,$07,$CF,$9F,$00,$7C,$F8,$7C,$7C)
       DTA B($ff,$03,$81,$fe,$01,$F0,$07,$CF,$9F,$00,$7C,$F8,$3E,$7C)
       DTA B($fe,$03,$80,$fe,$03,$E0,$03,$EF,$BE,$00,$3E,$F8,$3E,$7C)
       DTA B($f8,$03,$80,$3e,$03,$E0,$03,$EF,$BE,$00,$3E,$F8,$1F,$7C)
       DTA B($e0,$03,$80,$0e,$03,$E0,$03,$EF,$BE,$00,$3E,$F8,$1F,$7C)

* trade mark sign (R)
TPOR1A EQU DATADR-$42 ;$46 ;$3A6F
TPOR1  DTA B($B9,$A5,$B9,$81,$7E)
TPOR2A EQU TPOR1A+$50 ;$3ABF
TPOR2  DTA B($00,$7E,$81,$A5,$A9)

       END
