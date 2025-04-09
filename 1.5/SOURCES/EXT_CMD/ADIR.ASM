* ADIR diretory of Atari DOS disk
* and related for BW-DOS

        icl '_SYSEQU.ICL'

* Atari DOS directory sectors
FDIRSEC equ $169
* sector count per directory
DSECCNT equ $08
* VTOC sector
VTOCSEC equ $168
* VTOC sector 2 for medium density
VTOCSE2 equ $400
* VTOCSE2 total medium density
TFREEMD equ $3F2

* mask for directory sector
DIR128  equ $7F
DIR256  equ $FF

        blk dos $3000
        icl '_TSTBW15.ICL'
* clear DECIN
        ldx #$02
        lda #$00
        sta BW_DECIN,X
        dex
        bpl *-4
* parse parameter
        jsr BW_CRNAME
        ldx BW_BUFOFF
        lda BW_LBUF,X
        cmp #$9b
        beq *+7
* parameter error
errpar  lda #$9C
        jmp (BW_FAIL)
* get drive number
        lda BW_COMFNAM+1
        and #$0F
        sta siounit
* init no fail at SIO error
* see try reading VTOCE2
        lda #$00
        sta sionofl
* set cfname index
        lda #$03
        sta cfnmidx
* parse first part of path
        jsr parcfnm

* start directory output
        lda #$9b
        jsr _putc
        lda #$00
        sta entcnt
        lda #DSECCNT
        sta seccnt
        lda <FDIRSEC
        sta siosec
        lda >FDIRSEC
        sta siosec+1
* read sector
nxtsec  jsr _dosio
        ldx #$00
        stx diriter
* loop over file entries
nxtfile lda buffer,X
* check empty
* do not stop, BIBO DOS uses 64 entries
        beq nxtetr
* check deleted
        and #$80
        bne nxtetr2
* check pattern
        jsr chkpat
        bcs nxthdl
        bcc nxtetr2
* if iter=0 and flag=0 => end
nxtetr  ora diriter
        bne *+5
        jmp dirend
nxtetr2 lda #$10
        clc
        adc diriter
        sta diriter
        tax
        jmp dirmask
* handle entry
nxthdl  lda pathflg
        bne hdlpath
        jsr prnfil
        jmp hdlend
* handle path
hdlpath ldx diriter
        lda buffer,X
        and #$10
        beq nxtetr2
* set next dir
        lda #$00
        sta entcnt
        lda #DSECCNT
        sta seccnt
        lda buffer+3,X
        sta siosec
        lda buffer+4,X
        sta siosec+1
* parse next part
        jsr parcfnm
        jmp nxtsec
* check for next entry
hdlend  ldx diriter
        txa
dirmask and <DIR128
        beq nxtincs
        jmp nxtfile
* next sector
nxtincs dec seccnt
        beq dirend
        inc siosec
        bne *+5
        inc siosec+1
        jmp nxtsec

* end of director
dirend  lda pathflg
        beq *+7
* no directory
        lda #$96
        jmp (BW_FAIL)
* print summary of disk
        lda entcnt
        and #$01
        beq *+7
        lda #$9b
        jsr _putc
        lda <VTOCSEC
        sta siosec
        lda >VTOCSEC
        sta siosec+1
        jsr _dosio
* get free VTOC1
        lda buffer+3
        sta BW_DECIN
        lda buffer+4
        sta BW_DECIN+1
* get total
        lda buffer+1
        sta totsec
        lda buffer+2
        sta totsec+1
* check medium density
        lda totsec+1
        cmp >TFREEMD
        bne prnfree
* get free from medium VTOC2
        lda <VTOCSE2
        sta siosec
        lda >VTOCSE2
        sta siosec+1
        lda #$FF
        sta sionofl
        jsr _dosio
        bpl vtoc2ok
        lda #'?'
        sta freetxt
        sta tottxt
        bne prnfree
vtoc2ok clc
        lda buffer+$7a
        adc BW_DECIN
        sta BW_DECIN
        lda buffer+$7b
        adc BW_DECIN+1
        sta BW_DECIN+1
* print total
prnfree jsr CONVDC
        jsr putdco
        jsr _print
freetxt dta c' free, ',b($00)
* get total
        lda totsec
        sta BW_DECIN
        lda totsec+1
        sta BW_DECIN+1
* print total
        jsr CONVDC
        jsr putdco
        jsr _print
tottxt  dta c' total, ',b($00)
* print bps
        lda siosiz+1
        bne prn256
        jsr _print
        dta c'128bps',b($9b,$00)
        rts
prn256  jsr _print
        dta c'256bps',b($9b,$00)
        rts

* parse pattern
parcfnm ldx cfnmidx
* set pattern to space
        ldy #$0A
        lda #'?'
        sta filpat,Y
        dey
        bpl *-4
* check empty pattern
        lda BW_COMFNAM,X
        cmp #$9b
        beq bparend
        cmp #':'
        beq bparend
* set pattern to space
        ldy #$0A
        lda #' '
        sta filpat,Y
        dey
        bpl *-4
* parse name pattern
        ldy #$00
nxtfnc  lda BW_COMFNAM,X
        cmp #$9b
        beq bparend
        cmp #':'
        beq parend
        cmp #'*'
        beq padnam
        cmp #'.'
        beq parext
        sta filpat,Y
        iny
        inx
        cpy #$08
        bne nxtfnc
        lda BW_COMFNAM,X
        cmp #$9b
        beq parend
        cmp #':'
        beq parend
        cmp #'.'
        bne jerrpar
        beq parext
* * => pad with ?
padnam  lda #'?'
        sta filpat,Y
        iny
        cpy #$08
        bne *-6
        inx
        lda BW_COMFNAM,X
        cmp #$9b
bparend beq parend
        cmp #':'
        beq parend
        cmp #'.'
        bne jerrpar
* parse ext pattern
parext  inx
        ldy #$00
nxtfxc  lda BW_COMFNAM,X
        cmp #$9b
        beq parend
        cmp #':'
        beq parend
        cmp #'*'
        beq padext
        sta filpex,Y
        iny
        inx
        cpy #$03
        bne nxtfxc
        lda BW_COMFNAM,X
        cmp #$9b
        beq parend
        cmp #':'
        beq parend
        bne jerrpar
* * => pad with ?
padext  lda #'?'
        sta filpex,Y
        iny
        cpy #$03
        bne *-6
        inx
        lda BW_COMFNAM,X
        cmp #$9b
        beq parend
        cmp #':'
        beq parend
jerrpar jmp errpar
parend  stx cfnmidx
        ldy #$00
        sty pathflg
        cmp #$9b
        beq *+8
        inc pathflg
        inc cfnmidx
        rts

* print entry
prnfil  ldx diriter
        lda buffer,X
        pha
* check lock
        and #$20
        beq *+6
        lda #'*'
        bne *+4
        lda #' '
        jsr _putc
        bpl *+5
        jmp _siofl
* check dir
        pla
        and #$10
        beq *+6
        lda #':'
        bne *+4
        lda #' '
        jsr _putc
        bpl *+5
        jmp _siofl
* get sector count
        ldx diriter
        inx
        lda buffer,X
        sta BW_DECIN
        inx
        lda buffer,X
        sta BW_DECIN+1
        lda #$00
        sta BW_DECIN+2
        inx
        inx
        inx
        stx diriter
* print name
nxtchar lda buffer,X
        jsr _putc
        bpl *+5
        jmp _siofl
        inc diriter
        ldx diriter
        txa
        and #$0F
        bne nxtchar
* print sector cont
        lda #' '
        jsr _putc
        jsr CONVDC
        jsr putdco
        inc entcnt
        lda entcnt
        and #$01
        bne *+6
        lda #$9b
        bne *+4
        lda #' '
        jsr _putc
        bpl *+5
        jmp _siofl
        rts

* set DCB and call SIO
_dosio  ldx #$0b
_nxtsio lda siodata,X
        sta DDEVIC,X
        dex
        bpl _nxtsio
        jsr BW_SIO
        bpl _sioend
        lda sionofl
        bmi _sioend
* check done error at 128bps=> try 256bps
        lda siosiz+1
        bne _siofl
* set buffer size 256
        lda #$00
        sta siosiz
        lda #$01
        sta siosiz+1
* set directory mask
        lda <DIR256
        sta dirmask+1
        bne _dosio
_siofl  tya
        jmp (BW_FAIL)
_sioend rts

* put 5 digit from DCOUT
putdco  ldx #$03
        stx dcoiter
nxtdco  lda BW_DECOUT,X
        cmp #' '
        bne putnz
        lda #'0'
putnz   jsr _putc
        inc dcoiter
        ldx dcoiter
        cpx #$08
        bcc nxtdco
        rts

* check pattern
* input X index in buffer
* retunr C = OK
chkpat  inx
        inx
        inx
        inx
        ldy #$FF
* check file pattern
chknxt  inx
        iny
        cpy #$0B
        beq chkok
        lda filpat,Y
        cmp #'?'
        beq chknxt
        cmp buffer,X
        beq chknxt
        clc
        bcc *+3
chkok   sec
        rts

CONVDC  jmp (BW_CONVDC)

        icl '_PRINT.ICL'

* DCB data for read sector
siodata dta b($31)      ; device
siounit dta b($01)      ; unit
        dta c'R'        ; Command READ SECTOR
        dta b($40)      ; status
        dta a(buffer)   ; path buffer
        dta b($01)      ; time out
        dta b($00)      ; unused
siosiz  dta a($80)      ; buffer size
siosec  dta a($0000)    ; AUX1/2 sector number

* flag path or patter
pathflg equ *
* cfname index
cfnmidx equ pathflg+1
* flag for no error handling in _dosio
sionofl equ cfnmidx+1
* check pattern name+ext
filpat  equ sionofl+1
filpex  equ filpat+8
* entry count
entcnt  equ filpex+3
* directory sector count
seccnt  equ entcnt+1
* total sector count
totsec  equ seccnt+1
* iterator for number output
dcoiter equ totsec+2
* iterator for offset in director sector
diriter equ dcoiter+1
* sector buffer
buffer  equ diriter+1

        end
