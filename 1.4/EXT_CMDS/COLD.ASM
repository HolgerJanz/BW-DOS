* Cold Start with jump to The!Cart Menu

* OS equates
       icl '_SYSEQU.ASM'

* The!Cart Register (from-to,default)

* Mode Select
TCMOSL equ $d5a6    ; mode ($00-$3d,$01)
* Cartridge mode is selected with bits 0-5 of $D5A6, values
* other than the ones listed here are reserved (and result
* in "cartridge off"):
* $00: off, cartridge disabled
* $01: 8k banks at $A000
* $02: AtariMax 1MBit / 128k
* $03: Atarimax 8MBit / 1MB
* $04: OSS M091
* $08: SDX 64k cart, $D5Ex banking
* $09: Diamond GOS 64k cart, $D5Dx banking
* $0A: Express 64k cart, $D57x banking
* $0C: Atrax 128k cart
* $0D: Williams 64k cart
* $20: flexi mode (separate 8k banks at $A000 and $8000)
* $21: standard 16k cart at $8000-$BFFF
* $22: MegaMax 16k mode (up to 2MB), AtariMax 8Mbit banking
* $23: Blizzard 16k
* $24: Sic!Cart 512k
* $28: 16k Mega cart
* $29: 32k Mega cart
* $2A: 64k Mega cart
* $2B: 128k Mega cart
* $2C: 256k Mega cart
* $2D: 512k Mega cart
* $2E: 1024k Mega cart
* $2F: 2048k Mega cart
* $30: 32k XEGS cart
* $31: 64k XEGS cart
* $32: 128k XEGS cart
* $33: 256k XEGS cart
* $34: 512k XEGS cart
* $35: 1024k XEGS cart
* $38: 32k SWXEGS cart
* $39: 64k SWXEGS cart
* $3A: 128k SWXEGS cart
* $3B: 256k SWXEGS cart
* $3C: 512k SWXEGS cart
* $3D: 1024k SWXEGS cart
TCMOSL.OFF   equ $00  ; off, cartridge disabled
TCMOSL.8K    equ $01  ; 8k banks at $A000
TCMOSL.OSS   equ $04
TCMOSL.FLEXI equ $21  ; flexi mode,
*                     ; separate 8k banks at $A000 and $8000
TCMOSL.16K   equ $21  ; standard 16k cart at $8000-$BFFF

* how to figure out that The!Cart is not active?
* If the address is not used then the XL returns $ff but
* the XE (and old 800) return $d5 (high byte of address,
* the value of the last bus cycle)
TCMOSL.XLLOCK  equ $ff  ; config lock or not present
TCMOSL.XELOCK  equ $d5  ; config lock or not present

* Mode Flash/RAM Select
TCMOFR equ $d5a7  ;flash/RAM mode (0-15,0)
* bit 0: primary bank write enable (0equreadOnly, 1equwrite)
* bit 1: primary bank source (0equflash, 1equRAM)
* bit 2: secondary bank write enable (0equreadOnly, 1equwrite)
* bit 3: secondary bank source (0equflash, 1equRAM)
TCMOFR.PBRAM equ $03  ; primary bank RAM
TCMOFR.SBRAM equ $0C  ; secondary bank RAM

* Primary Bank
TCPBRL equ $d5a0  ; register low byte (0-255,0)
TCPBRH equ $d5a1  ; register high byte (0-63,0)
TCPBEN equ $d5a2  ; enable (0equdis-1equen,1)

* Secondary Bank 
TCSBRL equ $d5a3  ; register low byte (0-255,0)
TCSBRH equ $d5a4  ; register high byte (0-63,0)
TCSBEN equ $d5a5  ; enable (0equdis-1equen,0)

* SPI interface to EEPROM
TCINEP equ $d5a8
* bit 0: SPI CLK
* bit 1: SPI CS
* bit 7: SPI data in (on reads), SPI data out (on writes)

* configuration lock
TCCOLO equ $d5af
* Writing to this register disables "The!Cart" registers
* at $d5aX.

        blk dos $2800
        jsr _chkbwdos
* set XDIVIO
        ldy #SD_XDIVIO
        lda (DOSVEC),Y
        sta XDIVIO+1
        iny
        lda (DOSVEC),Y
        sta XDIVIO+2
* stop batch and hard copy
        ldy #$01
        jsr XDIVIO
        ldy #$00
        jsr XDIVIO
* switch The!Cart
        lda #$00    ; switch off DMA
        sta SDMCTL
        sta DMACTL
        sei         ; mask all interrupts
        sta NMIEN
* reset TC register
        sta TCPBEN  ; diable and set:
        sta TCSBRL  ; disable Secondary Bank 
        sta TCSBRH
        sta TCSBEN
        sta TCMOFR  ; cfg flash r/o
        sta TCPBRL ; set P bank (Menu equ $0000)
        sta TCPBRH
* set start menu
        lda TCMOSL.8K  ; set mode
        sta TCMOSL
        lda #$01    ; finally enable and do not read/write
        sta TCPBEN  ; TC register any further
* jump cold start
        jmp COLDSV 

XDIVIO  jmp WARMSV

        icl '_PRINT'
        icl '_CHKBWD'

        end
