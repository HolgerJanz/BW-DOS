;
; System equates
;
; OS EQUATES
; ----------
; 
; Syntax:
; Use '=' for addresses
; and '<' for read addresses (ex: KBCODE)
; and '>' for write addresses (ex: STIMER)
; and '#' for values
; 
; IO EQUATES
; 
ICHID       = $0000
ICDNO       = $0001
ICCOM       = $0002
ICSTA       = $0003
ICBAL       = $0004
ICBAH       = $0005
ICPTL       = $0006
ICPTH       = $0007
ICBLL       = $0008
ICBLH       = $0009
ICAX1       = $000A
ICAX2       = $000B
ICAX3       = $000C
ICAX4       = $000D
ICAX5       = $000E
ICAX6       = $000F
; 
; DISPLAY LIST EQUATES
; 
ADLI        = $0080
AVB         = $0040
ALMS        = $0040
AVSCR       = $0020
AHSCR       = $0010
AJMP        = $0001
AEMPTY1     = $0000
AEMPTY2     = $0010
AEMPTY3     = $0020
AEMPTY4     = $0030
AEMPTY5     = $0040
AEMPTY6     = $0050
AEMPTY7     = $0060
AEMPTY8     = $0070
; 
; OS VARIABLES FOR XL/XE
; 
; PAGE 0
; 
NGFLAG      = $0001
CASINI      = $0002
RAMLO       = $0004
TRAMSZ      = $0006
CMCMD       = $0007
WARMST      = $0008
BOOT        = $0009
DOSVEC      = $000A
DOSINI      = $000C
APPMHI      = $000E
POKMSK      = $0010
BRKKEY      = $0011
RTCLOK      = $0012
BUFADR      = $0015
ICCOMT      = $0017
DSKFMS      = $0018
DSKUTL      = $001A
ABUFPT      = $001C
ICHIDZ      = $0020
ICDNOZ      = $0021
ICCOMZ      = $0022
ICSTAZ      = $0023
ICBALZ      = $0024
ICBAHZ      = $0025
ICPTLZ      = $0026
ICPTHZ      = $0027
ICBLLZ      = $0028
ICBLHZ      = $0029
ICAX1Z      = $002A
ICAX2Z      = $002B
ICAX3Z      = $002C
ICAX4Z      = $002D
ICAX5Z      = $002E
ICAX6Z      = $002F
STATUS      = $0030
CHKSUM      = $0031
BUFRLO      = $0032
BUFRHI      = $0033
BFENLO      = $0034
BFENHI      = $0035
LTEMP       = $0036
BUFRFL      = $0038
RECVDN      = $0039
XMTDON      = $003A
CHKSNT      = $003B
NOCKSM      = $003C
BPTR        = $003D
FTYPE       = $003E
FEOF        = $003F
FREQ        = $0040
SOUNDR      = $0041
CRITIC      = $0042
FMSZPG      = $0043
ZCHAIN      = $004A
DSTAT       = $004C
ATRACT      = $004D
DRKMSK      = $004E
COLRSH      = $004F
TEMP        = $0050
HOLD1       = $0051
LMARGN      = $0052
RMARGN      = $0053
ROWCRS      = $0054
COLCRS      = $0055
DINDEX      = $0057
SAVMSC      = $0058
OLDROW      = $005A
OLDCOL      = $005B
OLDCHR      = $005D
OLDADR      = $005E
FKDEF       = $0060
PALNTS      = $0062
LOGCOL      = $0063
ADRESS      = $0064
MLTTMP      = $0066
SAVADR      = $0068
RAMTOP      = $006A
BUFCNT      = $006B
BUFSTR      = $006C
BITMSK      = $006E
SHFAMT      = $006F
ROWAC       = $0070
COLAC       = $0072
ENDPT       = $0074
DELTAR      = $0076
DELTAC      = $0077
KEYDEF      = $0079
SWPFLG      = $007B
HOLDCH      = $007C
INSDAT      = $007D
COUNTR      = $007E
LOMEM       = $0080
; 
; PAGE 2
; 
VDSLST      = $0200
VPRCED      = $0202
VINTER      = $0204
VBREAK      = $0206
VKEYBD      = $0208
VSERIN      = $020A
VSEROR      = $020C
VSEROC      = $020E
VTIMR1      = $0210
VTIMR2      = $0212
VTIMR4      = $0214
VIMIRQ      = $0216
CDTMV1      = $0218
CDTMV2      = $021A
CDTMV3      = $021C
CDTMV4      = $021E
CDTMV5      = $0220
VVBLKI      = $0222
VVBLKD      = $0224
CDTMA1      = $0226
CDTMA2      = $0228
CDTMF3      = $022A
SRTIMR      = $022B
CDTMF4      = $022C
INTEMP      = $022D
CDTMF5      = $022E
SDMCTL      = $022F
SDLSTL      = $0230
SDLSTH      = $0231
SSKCTL      = $0232
SPARE       = $0233
LPENH       = $0234
LPENV       = $0235
BRKKY       = $0236
VPIRQ       = $0238
CDEVIC      = $023A
CCOMND      = $023B
CAUX1       = $023C
CAUX2       = $023D
TMPSIO      = $023E
ERRFLG      = $023F
DFLAGS      = $0240
DBSECT      = $0241
BOOTAD      = $0242
COLDST      = $0244
RECLEN      = $0245
DSKTIM      = $0246
PDVMSK      = $0247
SHPDVS      = $0248
PDMSK       = $0249
RELADR      = $024A
PPTMPA      = $024C
PPTMPX      = $024D
CHSALT      = $026B
VSFLAG      = $026C
KEYDIS      = $026D
FINE        = $026E
GPRIOR      = $026F
PADDL0      = $0270
PADDL1      = $0271
PADDL2      = $0272
PADDL3      = $0273
PADDL4      = $0274
PADDL5      = $0275
PADDL6      = $0276
PADDL7      = $0277
STICK0      = $0278
STICK1      = $0279
STICK2      = $027A
STICK3      = $027B
PTRIG0      = $027C
PTRIG1      = $027D
PTRIG2      = $027E
PTRIG3      = $027F
PTRIG4      = $0280
PTRIG5      = $0281
PTRIG6      = $0282
PTRIG7      = $0283
STRIG0      = $0284
STRIG1      = $0285
STRIG2      = $0286
STRIG3      = $0287
HIBYTE      = $0288
WMODE       = $0289
BLIM        = $028A
IMASK       = $028B
JVECK       = $028C
NEWADR      = $028E
TXTROW      = $0290
TXTCOL      = $0291
TINDEX      = $0293
TXTMSC      = $0294
TXTOLD      = $0296
CRETRY      = $029C
HOLD3       = $029D
SUBTMP      = $029E
HOLD2       = $029F
DMASK       = $02A0
TMPLBT      = $02A1
ESCFLG      = $02A2
TABMAP      = $02A3
LOGMAP      = $02B2
INVFLG      = $02B6
FILFLG      = $02B7
TMPROW      = $02B8
TMPCOL      = $02B9
SCRFLG      = $02BB
HOLD4       = $02BC
DRETRY      = $02BD
SHFLOC      = $02BE
BOTSCR      = $02BF
PCOLR0      = $02C0
PCOLR1      = $02C1
PCOLR2      = $02C2
PCOLR3      = $02C3
COLOR0      = $02C4
COLOR1      = $02C5
COLOR2      = $02C6
COLOR3      = $02C7
COLOR4      = $02C8
RUNADR      = $02C9
HIUSED      = $02CB
ZHIUSE      = $02CD
GBYTEA      = $02CF
LOADAD      = $02D1
ZLOADA      = $02D3
DSCTLN      = $02D5
ACMISR      = $02D7
KRPDER      = $02D9
KEYREP      = $02DA
NOCLIK      = $02DB
HELPFG      = $02DC
DMASAV      = $02DD
PBPNT       = $02DE
PBUFSZ      = $02DF
RUNAD       = $02E0
INITAD      = $02E2
RAMSIZ      = $02E4
MEMTOP      = $02E5
MEMLO       = $02E7
HNDLOD      = $02E9
DVSTAT      = $02EA
CBAUDL      = $02EE
CBAUDH      = $02EF
CRSINH      = $02F0
KEYDEL      = $02F1
CH1         = $02F2
CHACT       = $02F3
CHBAS       = $02F4
NEWROW      = $02F5
NEWCOL      = $02F6
ROWINC      = $02F8
COLINC      = $02F9
CHAR        = $02FA
ATACHR      = $02FB
CH          = $02FC
FILDAT      = $02FD
DSPFLG      = $02FE
SSFLAG      = $02FF
; 
; PAGE 3
; 
DDEVIC      = $0300
DUNIT       = $0301
DCOMND      = $0302
DSTATS      = $0303
DBUFLO      = $0304
DBUFHI      = $0305
DTIMLO      = $0306
DUNUSE      = $0307
DBYTLO      = $0308
DBYTHI      = $0309
DAUX1       = $030A
DAUX2       = $030B
TIMER1      = $030C
ADDCOR      = $030E
CASFLG      = $030F
TIMER2      = $0310
TEMP1       = $0312
TEMP2       = $0314
TEMP3       = $0315
SAVIO       = $0316
TIMFLG      = $0317
STACKP      = $0318
TSTAT       = $0319
HATABS      = $031A
PUPBT1      = $033D
PUPBT2      = $033E
PUPBT3      = $033F
IOCB0       = $0340
IOCB1       = $0350
IOCB2       = $0360
IOCB3       = $0370
IOCB4       = $0380
IOCB5       = $0390
IOCB6       = $03A0
IOCB7       = $03B0
PRNBUF      = $03C0
SUPERF      = $03E8
CKEY        = $03E9
CASSBT      = $03EA
CARTCK      = $03EB
DERRF       = $03EC
ACMVAR      = $03ED
BASICF      = $03F8
MINTLK      = $03F9
GINTLK      = $03FA
CHLINK      = $03FB
CASBUF      = $03FD
; 
; HARDWARE REGISTERS
; 
; GTIA
; 
M0PF        = $D000
HPOSP0      = $D000
M1PF        = $D001
HPOSP1      = $D001
M2PF        = $D002
HPOSP2      = $D002
M3PF        = $D003
HPOSP3      = $D003
P0PF        = $D004
HPOSM0      = $D004
P1PF        = $D005
HPOSM1      = $D005
P2PF        = $D006
HPOSM2      = $D006
P3PF        = $D007
HPOSM3      = $D007
M0PL        = $D008
SIZEP0      = $D008
M1PL        = $D009
SIZEP1      = $D009
M2PL        = $D00A
SIZEP2      = $D00A
M3PL        = $D00B
SIZEP3      = $D00B
P0PL        = $D00C
SIZEM       = $D00C
P1PL        = $D00D
GRAFP0      = $D00D
P2PL        = $D00E
GRAFP1      = $D00E
P3PL        = $D00F
GRAFP2      = $D00F
TRIG0       = $D010
GRAFP3      = $D010
TRIG1       = $D011
GRAFM       = $D011
TRIG2       = $D012
COLPM0      = $D012
TRIG3       = $D013
COLPM1      = $D013
PAL         = $D014
COLPM2      = $D014
COLPM3      = $D015
COLPF0      = $D016
COLPF1      = $D017
COLPF2      = $D018
COLPF3      = $D019
COLBK       = $D01A
PRIOR       = $D01B
VDELAY      = $D01C
GRACTL      = $D01D
HITCLR      = $D01E
CONSOL      = $D01F
; 
; POKEY
; 
POT0        = $D200
AUDF1       = $D200
POT1        = $D201
AUDC1       = $D201
POT2        = $D202
AUDF2       = $D202
POT3        = $D203
AUDC2       = $D203
POT4        = $D204
AUDF3       = $D204
POT5        = $D205
AUDC3       = $D205
POT6        = $D206
AUDF4       = $D206
POT7        = $D207
AUDC4       = $D207
ALLPOT      = $D208
AUDCTL      = $D208
KBCODE      = $D209
STIMER      = $D209
RANDOM      = $D20A
SKREST      = $D20A
POTGO       = $D20B
SERIN       = $D20D
SEROUT      = $D20D
IRQST       = $D20E
IRQEN       = $D20E
SKSTAT      = $D20F
SKCTL       = $D20F
; 
; PIA
; 
PORTA       = $D300
PORTB       = $D301
PACTL       = $D302
PBCTL       = $D303
; 
; ANTIC
; 
DMACLT      = $D400
CHACTL      = $D401
DLISTL      = $D402
DLISTH      = $D403
HSCROL      = $D404
VSCROL      = $D405
PMBASE      = $D407
CHBASE      = $D409
WSYNC       = $D40A
VCOUNT      = $D40B
PENH        = $D40C
PENV        = $D40D
NMIEN       = $D40E
NMIST       = $D40F
NMIRES      = $D40F
; 
; FLOATING POINT ROUTINES
; 
AFP         = $D800
FASC        = $D8E6
IFP         = $D9AA
FPI         = $D9D2
ZFR0        = $DA44
ZF1         = $DA46
FSUB        = $DA60
FADD        = $DA66
FMUL        = $DADB
FDIV        = $DB28
PLYEVL      = $DD40
FLD0R       = $DD89
FLD0P       = $DD8D
FLD1R       = $DD98
FLD1P       = $DD9C
FSTOR       = $DDA7
FSTOP       = $DDAB
FMOVE       = $DDB6
EXP         = $DDC0
EXP10       = $DDCC
LOG         = $DECD
LOG10       = $DED1
; 
; ROM VECTORS
; 
DSKINV      = $E453
CIOV        = $E456
SIOV        = $E459
SETVBV      = $E45C
SYSVBV      = $E45F
XITVBV      = $E462
SIOINV      = $E465
SENDEV      = $E468
INTINV      = $E46B
CIOINV      = $E46E
SELFSV      = $E471
WARMSV      = $E474
COLDSV      = $E477
RBLOKV      = $E47A
CSOPIV      = $E47D
PUPDIV      = $E480
SELFTSV     = $E483
PENTV       = $E486
PHUNLV      = $E489
PHINIV      = $E48C
GPDVV       = $E48F
;
; Code equates
;
L0086       = $0086
L008A       = $008A
L008C       = $008C
L008F       = $008F
L0093       = $0093
L0094       = $0094
L0097       = $0097
L009A       = $009A
L009B       = $009B
L009D       = $009D
L00A0       = $00A0
L00A2       = $00A2
L00A9       = $00A9
L00B9       = $00B9
L00BB       = $00BB
L00BD       = $00BD
L00C1       = $00C1
L00C8       = $00C8
L00C9       = $00C9
L00CA       = $00CA
L00CE       = $00CE
L00D0       = $00D0
L00D3       = $00D3
L00DC       = $00DC
L00F0       = $00F0
L00FC       = $00FC
L0100       = $0100
L01A0       = $01A0
L01A9       = $01A9
L04A9       = $04A9
L05A0       = $05A0
L0700       = $0700
L0701       = $0701
L0706       = $0706
L0708       = $0708
L071D       = $071D
L0747       = $0747
L074C       = $074C
L0762       = $0762
L0766       = $0766
L0768       = $0768
L078A       = $078A
L078F       = $078F
L0795       = $0795
L07A0       = $07A0
L07A1       = $07A1
L07BE       = $07BE
L07BF       = $07BF
L07C8       = $07C8
L07F2       = $07F2
L081A       = $081A
L0847       = $0847
L085E       = $085E
L085F       = $085F
L0863       = $0863
L0869       = $0869
L086B       = $086B
L088A       = $088A
L088B       = $088B
L08C5       = $08C5
L08E4       = $08E4
L08E6       = $08E6
L08E8       = $08E8
L090B       = $090B
L090E       = $090E
L090F       = $090F
L0919       = $0919
L093A       = $093A
L093B       = $093B
L0942       = $0942
L0943       = $0943
L0946       = $0946
L0948       = $0948
L0965       = $0965
L096B       = $096B
L096F       = $096F
L0972       = $0972
L0974       = $0974
L09B8       = $09B8
L09BA       = $09BA
L09C2       = $09C2
L09E1       = $09E1
L0A3A       = $0A3A
L0A3C       = $0A3C
L0A71       = $0A71
L0A76       = $0A76
L0A94       = $0A94
L0A98       = $0A98
L0AA4       = $0AA4
L0AA7       = $0AA7
L0AF5       = $0AF5
L0AFC       = $0AFC
L0B00       = $0B00
L0B0D       = $0B0D
L0B28       = $0B28
L0B29       = $0B29
L0B33       = $0B33
L0B68       = $0B68
L0B79       = $0B79
L0B7C       = $0B7C
L0BA2       = $0BA2
L0BAA       = $0BAA
L0BE9       = $0BE9
L0BEE       = $0BEE
L0C15       = $0C15
L0C2C       = $0C2C
L0C6E       = $0C6E
L0C95       = $0C95
L0CA0       = $0CA0
L0CA9       = $0CA9
L0CC4       = $0CC4
L0CE4       = $0CE4
L0CE6       = $0CE6
L0CE7       = $0CE7
L0CEA       = $0CEA
L0CEC       = $0CEC
L0CED       = $0CED
L0CEE       = $0CEE
L0CF1       = $0CF1
L0CF2       = $0CF2
L0CF3       = $0CF3
L0CF4       = $0CF4
L0CF5       = $0CF5
L0CF7       = $0CF7
L0CF9       = $0CF9
L0D03       = $0D03
L0D12       = $0D12
L0D18       = $0D18
L0D19       = $0D19
L0D1A       = $0D1A
L0D1B       = $0D1B
L0D1D       = $0D1D
L0D1E       = $0D1E
L0D36       = $0D36
L0D37       = $0D37
L0D38       = $0D38
L0D39       = $0D39
L0D3A       = $0D3A
L0D3E       = $0D3E
L0D43       = $0D43
L0D48       = $0D48
L0D4D       = $0D4D
L0D53       = $0D53
L0D6F       = $0D6F
L0D79       = $0D79
L0D8A       = $0D8A
L0D9C       = $0D9C
L0D9D       = $0D9D
L0DB1       = $0DB1
L0DB2       = $0DB2
L0DC5       = $0DC5
L0DE5       = $0DE5
L0DE6       = $0DE6
L0DE9       = $0DE9
L0DEE       = $0DEE
L0DEF       = $0DEF
L0DF0       = $0DF0
L0DFE       = $0DFE
L0E0A       = $0E0A
L0E0B       = $0E0B
L0E16       = $0E16
L0E21       = $0E21
L0E26       = $0E26
L0E27       = $0E27
L0E38       = $0E38
L0E39       = $0E39
L0E3A       = $0E3A
L0E3B       = $0E3B
L0E3C       = $0E3C
L0E3D       = $0E3D
L0E3E       = $0E3E
L0E3F       = $0E3F
L0E40       = $0E40
L0E41       = $0E41
L0E42       = $0E42
L0E43       = $0E43
L0E44       = $0E44
L0E45       = $0E45
L0E48       = $0E48
L0E4C       = $0E4C
L0E4D       = $0E4D
L0E51       = $0E51
L0E52       = $0E52
L0E53       = $0E53
L0E55       = $0E55
L0E58       = $0E58
L0E59       = $0E59
L0E5D       = $0E5D
L0E5E       = $0E5E
L0E5F       = $0E5F
L0E60       = $0E60
L0E64       = $0E64
L0E6B       = $0E6B
L0EC9       = $0EC9
L0ED7       = $0ED7
L0ED8       = $0ED8
L0F15       = $0F15
L0F40       = $0F40
L0F43       = $0F43
L0F46       = $0F46
L0F49       = $0F49
L0F4C       = $0F4C
L0F58       = $0F58
L0F59       = $0F59
L0FAC       = $0FAC
L0FEC       = $0FEC
L1088       = $1088
L109C       = $109C
L10BA       = $10BA
L10BB       = $10BB
L10BE       = $10BE
L10C2       = $10C2
L10C3       = $10C3
L10CD       = $10CD
L10DB       = $10DB
L10DC       = $10DC
L10E2       = $10E2
L1108       = $1108
L1109       = $1109
L110C       = $110C
L1114       = $1114
L1121       = $1121
L1131       = $1131
L113B       = $113B
L1149       = $1149
L1182       = $1182
L1187       = $1187
L118A       = $118A
L11BE       = $11BE
L1217       = $1217
L1278       = $1278
L1284       = $1284
L12A3       = $12A3
L12F6       = $12F6
L1354       = $1354
L136A       = $136A
L1398       = $1398
L139B       = $139B
L139E       = $139E
L13AE       = $13AE
L13BF       = $13BF
L143E       = $143E
L1489       = $1489
L14A9       = $14A9
L14BF       = $14BF
L14DA       = $14DA
L14F5       = $14F5
L14FD       = $14FD
L150C       = $150C
L1511       = $1511
L159C       = $159C
L159E       = $159E
L15B9       = $15B9
L15C9       = $15C9
L15D9       = $15D9
L1684       = $1684
L16AD       = $16AD
L16B2       = $16B2
L16FE       = $16FE
L1A11       = $1A11
L1A23       = $1A23
L1A24       = $1A24
L1AA2       = $1AA2
L1AB4       = $1AB4
L1AE8       = $1AE8
L1AEA       = $1AEA
L1AFE       = $1AFE
L1B01       = $1B01
L1B0C       = $1B0C
L1B13       = $1B13
L1B2B       = $1B2B
L1B6C       = $1B6C
L1BAE       = $1BAE
L1BE5       = $1BE5
L1BE9       = $1BE9
L1C2B       = $1C2B
L1C2C       = $1C2C
L1C43       = $1C43
L1C48       = $1C48
L1C57       = $1C57
L1C69       = $1C69
L1C6E       = $1C6E
L1C7C       = $1C7C
L1CA3       = $1CA3
L1CAA       = $1CAA
L1CC7       = $1CC7
L1CCC       = $1CCC
L1D02       = $1D02
L1D03       = $1D03
L1D0D       = $1D0D
L1D13       = $1D13
L1D1C       = $1D1C
L1D4D       = $1D4D
L1D8A       = $1D8A
L1DBD       = $1DBD
L1DBF       = $1DBF
L1DC5       = $1DC5
L1DF4       = $1DF4
L1E10       = $1E10
L1E4A       = $1E4A
L1E7D       = $1E7D
L1ED1       = $1ED1
L1ED6       = $1ED6
L1EDA       = $1EDA
L1EDB       = $1EDB
L1EE2       = $1EE2
L2020       = $2020
L2060       = $2060
L20A9       = $20A9
L20BE       = $20BE
L2120       = $2120
L225D       = $225D
L2281       = $2281
L22BF       = $22BF
L22F0       = $22F0
L2313       = $2313
L239A       = $239A
L23B3       = $23B3
L24AD       = $24AD
L25AE       = $25AE
L26AC       = $26AC
L2754       = $2754
L2809       = $2809
L292A       = $292A
L29A0       = $29A0
L2A9B       = $2A9B
L2AA5       = $2AA5
L2B1F       = $2B1F
L2B5A       = $2B5A
L2C68       = $2C68
L2DA0       = $2DA0
L30A0       = $30A0
L30EE       = $30EE
L3136       = $3136
L31A0       = $31A0
L36ED       = $36ED
L36F0       = $36F0
L3811       = $3811
L3833       = $3833
L38A2       = $38A2
L38F0       = $38F0
L3B5A       = $3B5A
L3BA0       = $3BA0
L3BC1       = $3BC1
L3BC2       = $3BC2
L3CF8       = $3CF8
L3F38       = $3F38
L3FBF       = $3FBF
L404A       = $404A
L405F       = $405F
L4061       = $4061
L4142       = $4142
L4197       = $4197
L41F0       = $41F0
L4253       = $4253
L4391       = $4391
L43B1       = $43B1
L43F4       = $43F4
L445C       = $445C
L4481       = $4481
L4585       = $4585
L45BE       = $45BE
L45C1       = $45C1
L45C4       = $45C4
L4600       = $4600
L4691       = $4691
L46BB       = $46BB
L49A5       = $49A5
L4B12       = $4B12
L4B76       = $4B76
L4B81       = $4B81
L4C5A       = $4C5A
L4CDD       = $4CDD
L4CFC       = $4CFC
L4D13       = $4D13
L4D40       = $4D40
L4D5B       = $4D5B
L4D8F       = $4D8F
L4DD0       = $4DD0
L4E57       = $4E57
L4F43       = $4F43
L4FAC       = $4FAC
L5246       = $5246
L53FA       = $53FA
L5B22       = $5B22
L5E09       = $5E09
L6006       = $6006
L600E       = $600E
L6463       = $6463
L6C24       = $6C24
L6D75       = $6D75
L6DEB       = $6DEB
L702E       = $702E
L7B18       = $7B18
L7C94       = $7C94
L7E20       = $7E20
L7E38       = $7E38
L8021       = $8021
L8521       = $8521
L9018       = $9018
L91E3       = $91E3
L9351       = $9351
L93C1       = $93C1
L9AA3       = $9AA3
L9B13       = $9B13
L9B2A       = $9B2A
LA00F       = $A00F
LA0D5       = $A0D5
LA1A0       = $A1A0
LA209       = $A209
LA2BF       = $A2BF
LA2D7       = $A2D7
LA3A0       = $A3A0
LA4A0       = $A4A0
LA5BF       = $A5BF
LA7A0       = $A7A0
LA99A       = $A99A
LA9A0       = $A9A0
LAAA0       = $AAA0
LAC9D       = $AC9D
LAD15       = $AD15
LB00D       = $B00D
LBD60       = $BD60
LBF22       = $BF22
LBFFA       = $BFFA
LBFFC       = $BFFC
LBFFD       = $BFFD
LC0A9       = $C0A9
LC43A       = $C43A
LC90A       = $C90A
LCD09       = $CD09
LCE06       = $CE06
LCE0C       = $CE0C
LD0C2       = $D0C2
LD0C5       = $D0C5
LD10E       = $D10E
LE5AD       = $E5AD
LE610       = $E610
LE80D       = $E80D
LEDE7       = $EDE7
LF5D5       = $F5D5
LFC95       = $FC95
LFD20       = $FD20
LFF00       = $FF00
LFF20       = $FF20
LFFA9       = $FFA9
LFFBD       = $FFBD
LFFE4       = $FFE4
LFFFF       = $FFFF


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Start of code
;
            org $36E6

; copy from page $30 to $7
L36E6       cld                    ; D8
            ldx #$00               ; A2 00
            ldy #$20               ; A0 20
L36EB       lda L3700,X            ; BD 00 37
            sta L0700,X            ; 9D 00 07
            inx                    ; E8
            bne L36EB              ; D0 F7
            inc L36ED              ; EE ED 36
            inc L36F0              ; EE F0 36
            dey                    ; 88
            bne L36EB              ; D0 EE
            jmp L0E0B              ; 4C 0B 0E

; page 7 table
L3700       .byte $53     ;$700 the character "S" for SpartaDOS
			.byte $32     ;$701 $32 for compatibility with SpartaDOS 3.2
			.byte $00
			.byte $42,$57 ;$703 "BW" when BW-DOS is installed
			.byte,$13     ;$705 BW-DOS version 1.3x etc.
			.word $0857   ;$706 Adress GETTD
			.word $0850   ;$708 Adress SETTD
			.word $072A   ;$70A Adress CONVDC
            jmp L0CEE     ;$70C jmp LSIO for compatibility with BiboDOS

            .byte $0F
            sta BITMSK,X           ; 95 6E
L3712       .byte $97,$7F
            sta (COUNTR,X)         ; 81 7E

            asl                    ; 0A
            php                    ; 08
            .byte $0B,$0C,$0C,$0C
            asl                    ; 0A
            sta L0CF3              ; 8D F3 0C
            lda #$00               ; A9 00
            sta L0CF4              ; 8D F4 0C
            lda #$00               ; A9 00
            sta L0CF5              ; 8D F5 0C
            ldx #$07               ; A2 07
L372C       stx L074C              ; 8E 4C 07
            ldx #$18               ; A2 18
            lda #$00               ; A9 00
L3733       asl L0CF3              ; 0E F3 0C
            rol L0CF4              ; 2E F4 0C
            rol L0CF5              ; 2E F5 0C
            rol                    ; 2A
            cmp #$0A               ; C9 0A
            bcc L3746              ; 90 05
            sbc #$0A               ; E9 0A
            inc L0CF3              ; EE F3 0C
L3746       dex                    ; CA
            bne L3733              ; D0 EA
            ora #$30               ; 09 30
            ldx #$00               ; A2 00
L374D       sta L0CE6,X            ; 9D E6 0C
            dex                    ; CA
            bmi L37A0              ; 30 4D
            lda L0CF3              ; AD F3 0C
            ora L0CF4              ; 0D F4 0C
            ora L0CF5              ; 0D F5 0C
            bne L372C              ; D0 CE
            lda #$20               ; A9 20
            bne L374D              ; D0 EB
L3762       inc L0D03              ; EE 03 0D
            bit L20A9              ; 2C A9 20
            ldy L0D03              ; AC 03 0D
            ldx L0D38,Y            ; BE 38 0D
            cpx #$20               ; E0 20
            beq L3762              ; F0 F0
            sta L07C8              ; 8D C8 07
            lda #$00               ; A9 00
            sta L07BF              ; 8D BF 07
            cpx #$9B               ; E0 9B
            beq L3790              ; F0 12
            lda L0D39,Y            ; B9 39 0D
            cmp #$9B               ; C9 9B
            beq L3790              ; F0 0B
            cmp #$3A               ; C9 3A
            beq L37A1              ; F0 18
            lda L0D3A,Y            ; B9 3A 0D
            cmp #$3A               ; C9 3A
            beq L3795              ; F0 05
L3790       ldy #$41               ; A0 41
            jsr L07BE              ; 20 BE 07
L3795       ldy L0D03              ; AC 03 0D
            jsr L07BE              ; 20 BE 07
            sty L0D03              ; 8C 03 0D
L379E       cpx #$03               ; E0 03
L37A0       rts                    ; 60
L37A1       inc L07BF              ; EE BF 07
            jsr L0795              ; 20 95 07
            lda L0D1B              ; AD 1B 0D
            sta L0D1A              ; 8D 1A 0D
            lda #$31               ; A9 31
            sta L0D1B              ; 8D 1B 0D
            bne L379E              ; D0 EA
L37B4       sta L0D1A,X            ; 9D 1A 0D
            cpx #$1B               ; E0 1B
            bcs L37BC              ; B0 01
            inx                    ; E8
L37BC       iny                    ; C8
            .byte $2C,$A2,$00      ; bit L00A2
            lda L0D38,Y            ; B9 38 0D
            cmp #$9B               ; C9 9B
            beq L37CB              ; F0 04
            cmp #$20               ; C9 20
            bne L37B4              ; D0 E9
L37CB       lda #$9B               ; A9 9B
            sta L0D1A,X            ; 9D 1A 0D
            stx L07BF              ; 8E BF 07
            rts                    ; 60
            sta LA00F,X            ; 9D 0F A0
            .byte $0F,$A3,$0F
            ldx APPMHI+1           ; A6 0F
            lda #$0F               ; A9 0F
            .byte $89,$0F
            cld                    ; D8
            lda FMSZPG+4           ; A5 47
            bne L37F2              ; D0 0D
            dec FMSZPG+4           ; C6 47
            bit L0D19              ; 2C 19 0D
            bpl L37F2              ; 10 06
            jsr L0847              ; 20 47 08
            jmp L0CF9              ; 4C F9 0C
L37F2       jsr L0919              ; 20 19 09
            eor L4217              ; 4D 17 42
            .byte $E7,$47
            beq L383C              ; F0 40
            asl                    ; 0A
            cmp L4CF2              ; CD F2 4C
            sbc (L008A),Y          ; F1 8A
L3802       sta L0E4C,X            ; 9D 4C 0E
            cpx #$97               ; E0 97
            bcc L380C              ; 90 03
            dec L0E40,X            ; DE 40 0E
L380C       inx                    ; E8
            bne L3802              ; D0 F3
            tay                    ; A8
            bit L07A0              ; 2C A0 07
L3813       iny                    ; C8
            tya                    ; 98
            sta L0E55,X            ; 9D 55 0E
            txa                    ; 8A
            clc                    ; 18
            adc #$1A               ; 69 1A
            tax                    ; AA
            cpy #$04               ; C0 04
            bcc L3813              ; 90 F2
            beq L3811              ; F0 EE
            ldy #$1E               ; A0 1E
L3825       ldx HATABS,Y           ; BE 1A 03
            bne L382B              ; D0 01
            tya                    ; 98
L382B       cpx #$44               ; E0 44
            beq L3837              ; F0 08
            dey                    ; 88
            dey                    ; 88
            dey                    ; 88
            bpl L3825              ; 10 F1
            tay                    ; A8
            bmi L3843              ; 30 0C
L3837       ldx #$FD               ; A2 FD
L3839       lda L0747,X            ; BD 47 07
L383C       sta HATABS,Y           ; 99 1A 03
            iny                    ; C8
            inx                    ; E8
            bne L3839              ; D0 F6
L3843       rts                    ; 60
            .byte $44,$D4,$07
            jmp (DOSINI)           ; 6C 0C 00
            .byte $1C,$0B,$5F
            asl APPMHI,X           ; 16 0E
			.byte $06

; $850 SETTD
			jsr $0919			   ; 20 19 09
			cmp $C806			   ; CD 06 C8
            lsr                    ; 4A

; $857 GETTD
            jsr L0919              ; 20 19 09
            iny                    ; C8
            lsr                    ; 4A
            cmp L6006              ; CD 06 60
            lda L1489              ; AD 89 14
            bit L01A9              ; 2C A9 01
            ldx #$69               ; A2 69
            bne L386D              ; D0 04
            lda #$01               ; A9 01
            ldx #$E9               ; A2 E9
L386D       sta L088B              ; 8D 8B 08
            stx L088A              ; 8E 8A 08
            ldx #$FE               ; A2 FE
L3875       jsr L08C5              ; 20 C5 08
            sta L078A,X            ; 9D 8A 07
            sta L078F,X            ; 9D 8F 07
            inx                    ; E8
            bne L3875              ; D0 F4
            lda L088A              ; AD 8A 08
            asl                    ; 0A
            dex                    ; CA
L3886       inx                    ; E8
            lda LFFFF,X            ; BD FF FF
            adc #$00               ; 69 00
            sta LFFFF,X            ; 9D FF FF
            stx L088B              ; 8E 8B 08
            txa                    ; 8A
            beq L3886              ; F0 F1
            rts                    ; 60

            bne L389B              ; D0 03
L3898       jmp (L0D36)            ; 6C 36 0D
L389B       jsr L0919              ; 20 19 09
            dec L4D00              ; CE 00 4D
            rol L00BD,X            ; 36 BD
            ora LE80D,X            ; 1D 0D E8
            sec                    ; 38
            sbc #$30               ; E9 30
            cmp #$0A               ; C9 0A
            bcc L38B3              ; 90 06
            sbc #$07               ; E9 07
            cmp #$10               ; C9 10
            bcs L3898              ; B0 E5
L38B3       asl                    ; 0A
            asl                    ; 0A
            asl                    ; 0A
            asl                    ; 0A
            ldy #$04               ; A0 04
L38B9       asl                    ; 0A
            rol L0D36              ; 2E 36 0D
            rol L0D37              ; 2E 37 0D
            dey                    ; 88
            bne L38B9              ; D0 F6
            beq L38A2              ; F0 DD

; $08C5
            stx L08E6              ; 8E E6 08
            sty L08E8              ; 8C E8 08
            tsx                    ; BA
            inx                    ; E8
            inx                    ; E8
            inx                    ; E8
            inc L0100,X            ; FE 00 01
            lda L0100,X            ; BD 00 01
            inx                    ; E8
            tay                    ; A8
            bne L38DC              ; D0 03
            inc L0100,X            ; FE 00 01
L38DC       lda L0100,X            ; BD 00 01
            sta L08E4              ; 8D E4 08
            lda LFF00,Y            ; B9 00 FF
            ldx #$00               ; A2 00
            ldy #$00               ; A0 00
            rts                    ; 60

L38EA       jsr L08C5              ; 20 C5 08
            ldx #$03               ; A2 03
            .byte $2C,$A2,$00      ; bit L00A2
            pha                    ; 48
            and #$1F               ; 29 1F
            sta L090F,X            ; 9D 0F 09
            pla                    ; 68
            lsr                    ; 4A
            lsr                    ; 4A
            lsr                    ; 4A
            lsr                    ; 4A
            lsr                    ; 4A
            sta L090B              ; 8D 0B 09
            jsr L08C5              ; 20 C5 08
            sta L090E,X            ; 9D 0E 09
            txa                    ; 8A
            beq L38EA              ; F0 E0
            ldx #$00               ; A2 00
L390C       dex                    ; CA
            lda LFFFF,X            ; BD FF FF
            sta LFFFF,X            ; 9D FF FF
            txa                    ; 8A
            bne L390C              ; D0 F6
            tya                    ; 98
            bmi L3968              ; 30 4F
L3919       jsr L0A76              ; 20 76 0A
L391C       jsr L08C5              ; 20 C5 08
            tay                    ; A8
L3920       asl                    ; 0A
            asl                    ; 0A
            php                    ; 08
            tya                    ; 98
            and #$1F               ; 29 1F
            plp                    ; 28
            bcs L38F0              ; B0 C7
            bmi L3949              ; 30 1E
            sta L093B              ; 8D 3B 09
            jsr L08C5              ; 20 C5 08
            sta L093A              ; 8D 3A 09
            tya                    ; 98
            pha                    ; 48
            jsr L0942              ; 20 42 09
            jsr L0948              ; 20 48 09
            jsr L0A76              ; 20 76 0A
            pla                    ; 68
            bpl L391C              ; 10 DA
            lda #$00               ; A9 00
            pha                    ; 48
            lda #$00               ; A9 00
            plp                    ; 28
            rts                    ; 60
L3949       sta L0946              ; 8D 46 09
            sty L0965              ; 8C 65 09
            jsr L08C5              ; 20 C5 08
            tax                    ; AA
            jsr L08C5              ; 20 C5 08
            tay                    ; A8
L3957       lda L0D8A,X            ; BD 8A 0D
            sta L0D8A,Y            ; 99 8A 0D
            inx                    ; E8
            iny                    ; C8
            dec L0946              ; CE 46 09
            bne L3957              ; D0 F3
            lda #$00               ; A9 00
            bpl L3919              ; 10 B1
L3968       ldx #$00               ; A2 00
            rts                    ; 60
            jsr L08C5              ; 20 C5 08
            bit LC0A9              ; 2C A9 C0
            bit L04A9              ; 2C A9 04
            sta FMSZPG+1           ; 85 44
            asl                    ; 0A
            asl                    ; 0A
            tax                    ; AA
            tay                    ; A8
            bcs L3989              ; B0 0D
            jsr L08C5              ; 20 C5 08
            lsr                    ; 4A
            sta IOCB0+ICAX1,X      ; 9D 4A 03
            lda #$00               ; A9 00
            ror                    ; 6A
            sta IOCB0+ICAX2,X      ; 9D 4B 03
L3989       lda #$67               ; A9 67
            sta FMSZPG             ; 85 43
L398D       jsr L08C5              ; 20 C5 08
            sta IOCB0+ICCOM,Y      ; 99 42 03
L3993       iny                    ; C8
            asl FMSZPG             ; 06 43
            bcc L3993              ; 90 FB
            bne L398D              ; D0 F3
            lda FMSZPG+1           ; A5 44
            pha                    ; 48
            lda #$20               ; A9 20
            jsr CIOV               ; 20 56 E4
            pla                    ; 68
            tax                    ; AA
            tya                    ; 98
            bpl L39C0              ; 10 19
            cmp #$88               ; C9 88
L39A9       beq L39C0              ; F0 15
            pha                    ; 48
            txa                    ; 8A
            pha                    ; 48
L39AE       and #$1C               ; 29 1C
            beq L39BC              ; F0 0A
            ora #$C0               ; 09 C0
            jsr L0974              ; 20 74 09
            .byte $0C,$00,$00,$00,$00
L39BC       pla                    ; 68
            bpl L39C2              ; 10 03
            pla                    ; 68
L39C0       tay                    ; A8
            rts                    ; 60

L39C2       jsr L096F              ; 20 6F 09
            .byte $0B
            sbc (DOSVEC+1,X)       ; E1 0B
            asl $00                ; 06 00
            pla                    ; 68
            jsr L071D              ; 20 1D 07
            jsr L096F              ; 20 6F 09
            .byte $0B
            nop                    ; EA
            .byte $0C,$04,$00
            jsr L096F              ; 20 6F 09
            .byte $0B
            sbc (DOSVEC+1,X)       ; E1 0B
            ora ($00,X)            ; 01 00
            jsr L0B7C              ; 20 7C 0B
            cld                    ; D8
            jsr L0B28              ; 20 28 0B
            stx L0D12              ; 8E 12 0D
            stx L0D03              ; 8E 03 0D
            dex                    ; CA
L39EC       stx L0D19              ; 8E 19 0D
            txs                    ; 9A
            jsr L096B              ; 20 6B 09
            cpy DOSINI             ; C4 0C
            ldy LC90A              ; AC 0A C9
            asl                    ; 0A
            jsr L096F              ; 20 6F 09
            .byte $0B
            sei                    ; 78
            .byte $0D,$04,$00      ; ora RAMLO
            jsr L096B              ; 20 6B 09
            rti                    ; 40
            ora BUFRFL             ; 05 38
            .byte $0D,$40,$00      ; ora FREQ
            jsr L0BAA              ; 20 AA 0B
            jmp L09E1              ; 4C E1 09

; Command CAR
            lda LBFFD              ; AD FD BF
            inc LBFFD              ; EE FD BF
            cmp LBFFD              ; CD FD BF
            sta LBFFD              ; 8D FD BF
            bne L3A92              ; D0 74
            ldx LBFFC              ; AE FC BF
            bne L3A92              ; D0 6F
            lda L0CE4              ; AD E4 0C
            sta WARMST             ; 85 08
            stx L0D19              ; 8E 19 0D
            dex                    ; CA
            stx L0CE4              ; 8E E4 0C
            jmp (LBFFA)            ; 6C FA BF

L3A32       sta BASICF             ; 8D F8 03
            php                    ; 08
            jsr L096F              ; 20 6F 09

            .byte $0C
            bpl L3A44              ; 10 08
            rti                    ; 40
            bvc L39EC              ; 50 AD
            ora (L00D3,X)          ; 01 D3
            ror                    ; 6A
            ror                    ; 6A
            plp                    ; 28
L3A44       rol                    ; 2A
            rol                    ; 2A
            sta PORTB              ; 8D 01 D3
            ldx #$CE               ; A2 CE
L3A4B       txa                    ; 8A
            sec                    ; 38
            sbc #$10               ; E9 10
            tax                    ; AA
            stx FMSZPG+1           ; 86 44
            eor (FMSZPG),Y         ; 51 43
            sta (FMSZPG),Y         ; 91 43
            eor (FMSZPG),Y         ; 51 43
            bne L3A4B              ; D0 F1
            sta MEMTOP             ; 8D E5 02
            inx                    ; E8
            inx                    ; E8
            stx RAMSIZ             ; 8E E4 02
            stx MEMTOP+1           ; 8E E6 02
            stx RAMTOP             ; 86 6A
            jsr L096B              ; 20 6B 09
            .byte $80
            clc                    ; 18
            .byte $03,$E2,$0B,$00,$00
            
            ldx #$00               ; A2 00
            stx L0CE4              ; 8E E4 0C
            sta L0946              ; 8D 46 09
            php                    ; 08
            pla                    ; 68
            sta L0943              ; 8D 43 09
            rts                    ; 60

; Command BASIC
            lda L0D1D              ; AD 1D 0D
            cmp #$4F               ; C9 4F
            bne L3A92              ; D0 0C
            lda L0D1E              ; AD 1E 0D
            cmp #$46               ; C9 46
            beq L3A32              ; F0 A5
            clc                    ; 18
            eor #$4E               ; 49 4E
            beq L3A32              ; F0 A0

L3A92       lda #$9C ; error 156 no cart ; A9 9C
            pha                    ; 48
            jmp L09C2              ; 4C C2 09

            .byte $00,$00,$00,$00,$00,$00,$00,$00
            .byte $00,$00,$00,$00
L3AA4       jmp (L09B8)            ; 6C B8 09
L3AA7       jmp (L09BA)            ; 6C BA 09
L3AAA       jsr L0B7C              ; 20 7C 0B
            txa                    ; 8A
            bne L3AA4              ; D0 F4
            bit L0CF2              ; 2C F2 0C
            bpl L3ABD              ; 10 08
            jsr L0AA4              ; 20 A4 0A
            cpy #$00               ; C0 00
            bpl L3AD3              ; 10 17
            rts                    ; 60
L3ABD       ldy #$01               ; A0 01
            ldx #$05               ; A2 05
            jsr L0CC4              ; 20 C4 0C
            cpy #$00               ; C0 00
            bmi L3AAA              ; 30 E2
            ldx #$00               ; A2 00
            cpx #$00               ; E0 00
            bne L3AA7              ; D0 D9
            pha                    ; 48
            jsr L0AA7              ; 20 A7 0A
            pla                    ; 68
L3AD3       bit L0CF1              ; 2C F1 0C
            bmi L3AEA              ; 30 12
            pha                    ; 48
            ldy #$00               ; A0 00
            ldx #$07               ; A2 07
            jsr L0CC4              ; 20 C4 0C
            cpy #$00               ; C0 00
            bpl L3AE7              ; 10 03
            jsr L0B79              ; 20 79 0B
L3AE7       pla                    ; 68
            ldy #$01               ; A0 01
L3AEA       ldx #$00               ; A2 00
            cpy #$00               ; C0 00
L3AEE       rts                    ; 60
L3AEF       jsr L0919              ; 20 19 09
            .byte $4B
            and L1C43,Y            ; 39 43 1C
            dex                    ; CA
            .byte $6F,$43
            lsr L00F0              ; 46 F0
            cpx L7E20              ; EC 20 7E
            .byte $0B
            ldy #$00               ; A0 00
            lda L0A3A,Y            ; B9 3A 0A
            sta L0B0D              ; 8D 0D 0B
            lda L0BE9,Y            ; B9 E9 0B
            jsr L0974              ; 20 74 09
            php                    ; 08
            .byte $03,$1A
            .byte $0D,$1C,$00      ; ora ABUFPT
            bmi L3AEE              ; 30 D9
            lda #$00               ; A9 00
L3B17       ldy L0B00              ; AC 00 0B
            ldx L0A3C,Y            ; BE 3C 0A
            ora IOCB0,X            ; 1D 40 03
            sta L0CF1,Y            ; 99 F1 0C
            lda #$FF               ; A9 FF
            sta IOCB0,X            ; 9D 40 03
L3B28       lda HATABS+2           ; AD 1C 03
            cmp #$0A               ; C9 0A
            beq L3B5A              ; F0 2B
            jsr L0919              ; 20 19 09
            .byte $C3,$1B,$4B
            and L0BA2,Y            ; 39 A2 0B
L3B38       lda LFFFF,X            ; BD FF FF
            sta L0A98,X            ; 9D 98 0A
            dex                    ; CA
            bpl L3B38              ; 10 F7
            jsr L0919              ; 20 19 09
            lsr                    ; 4A
            .byte $9C,$89
            clv                    ; B8
            lsr                    ; 4A
            .byte $9E
            lsr                    ; 4A
            .byte $6F
            cmp #$F5               ; C9 F5
            txa                    ; 8A
            .byte $9C
            jsr L0863              ; 20 63 08
            clv                    ; B8
            ora #$20               ; 09 20
            .byte $63
            php                    ; 08
            tsx                    ; BA
            ora #$AD               ; 09 AD
            sbc (DOSINI),Y         ; F1 0C
            and L0CF2              ; 2D F2 0C
            bmi L3AEF              ; 30 8D
            jsr L0919              ; 20 19 09
            .byte $4B,$3C,$43,$1C
            dex                    ; CA
            .byte $9E,$43
            lsr L00F0              ; 46 F0
            .byte $8B
            bne L3BA0              ; D0 2F
            lda L0D1A              ; AD 1A 0D
            cmp L0D79              ; CD 79 0D
            bne L3BA0              ; D0 27
            ldy #$00               ; A0 00
            bit L01A0              ; 2C A0 01
            tya                    ; 98
L3B7F       and #$01               ; 29 01
            tay                    ; A8
            sty L0B00              ; 8C 00 0B
            lda L0CF1,Y            ; B9 F1 0C
            bmi L3B28              ; 30 9E
            ldx #$03               ; A2 03
            jsr L0CC4              ; 20 C4 0C
            lda #$FF               ; A9 FF
            bmi L3B17              ; 30 84
L3B93       lda #$20               ; A9 20
            jsr L0762              ; 20 62 07
            ldy #$45               ; A0 45
            jsr L07BE              ; 20 BE 07
            ldy #$01               ; A0 01
            .byte $2C,$A0,$00      ; bit L00A0
            jsr L0AFC              ; 20 FC 0A
            bpl L3BC1              ; 10 1A
            jmp L0A94              ; 4C 94 0A
            lda L0D38              ; AD 38 0D
            cmp #$2D               ; C9 2D
            beq L3B93              ; F0 E2
            cmp #$3B               ; C9 3B
            beq L3BC1              ; F0 0C
            jsr L0766              ; 20 66 07
            bne L3BC2              ; D0 08
            jsr L0919              ; 20 19 09
            cmp L4D1A              ; CD 1A 4D
            adc L2060,Y            ; 79 60 20

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; begin statement table
            .byte $33,$0C
            .byte 'RENAM'
            .byte $C5
            .byte 'ERAS'
            .byte $C5,$9B
            .byte 'PROTEC'
            .byte $D4
            .byte 'UNPROTEC'
            .byte $D4,$9B
            .byte 'Error'
            .byte $9B,$9B,$90,$94

            .byte 'CREDI'
            .byte $D2
            .byte 'DELDI'
            .byte $D2

;            .byte 'M'		; MD make dir
;            .byte $C4
;            .byte 'R'		; RD remove dir
;            .byte $C4

            .byte 'CW'		; change dir
;            .byte 'C'
            .byte $C4

            .byte 'LOA'
            .byte $C4
            .byte 'CA'
            .byte $D2
            .byte 'RU'
            .byte $CE
            .byte 'PRIN'
            .byte $D4
            .byte 'TYP'
            .byte $C5
            .byte 'DI'
            .byte $D2
            .byte 'DIR'
            .byte $D3
            .byte 'BASI'
            .byte $C3
            .byte $00
            
 ;           .byte $00,$00,$00,$00,$00,$00,$00,$00
 ;           .byte $00

; end statement table

            jsr L0A71              ; 20 71 0A
            ldy #$4A               ; A0 4A
            jsr L07BE              ; 20 BE 07
            clc                    ; 18
L3C23       lda #$04               ; A9 04
L3C25       rol                    ; 2A
            sta L0C2C              ; 8D 2C 0C
            jsr L0972              ; 20 72 09
            php                    ; 08
            plp                    ; 28
L3C2E       .byte $1A
            .byte $0D,$1C,$00      ; ora ABUFPT
L3C32       rts                    ; 60
            ldx #$FF               ; A2 FF
            stx FMSZPG             ; 86 43
L3C37       ldx #$00               ; A2 00
            ldy #$00               ; A0 00
            inc FMSZPG             ; E6 43
L3C3D       jsr L08C5              ; 20 C5 08
            pha                    ; 48
            eor L0D1D,Y            ; 59 1D 0D
            asl                    ; 0A
            beq L3C48              ; F0 01
            dex                    ; CA
L3C48       iny                    ; C8
            pla                    ; 68
            beq L3C32              ; F0 E6
            bpl L3C3D              ; 10 EF
            txa                    ; 8A
            bmi L3C37              ; 30 E6
            lda L0D1D,Y            ; B9 1D 0D
            cmp #$9B               ; C9 9B
            bne L3C37              ; D0 DF
            jsr L0768              ; 20 68 07
            pla                    ; 68
            pla                    ; 68
            lda FMSZPG             ; A5 43
            cmp #$0D               ; C9 0D
            beq L3C23              ; F0 C0
            bcs L3C74              ; B0 0F
            adc #$20               ; 69 20
            sta L0C6E              ; 8D 6E 0C
            jsr L0972              ; 20 72 09
            .byte $00,$00,$1A
            .byte $0D,$1C,$00      ; ora ABUFPT
            rts                    ; 60

L3C74       tay                    ; A8
            lda L0708,Y            ; B9 08 07
            pha                    ; 48
            lda L0701,Y            ; B9 01 07
            pha                    ; 48
            cpx #$03               ; E0 03
            rts                    ; 60

            lda #$80               ; A9 80
            eor #$12               ; 49 12
            pha                    ; 48
            lda L0D19,X            ; BD 19 0D
            cmp #$38               ; C9 38
            beq L3C97              ; F0 0B
            and #$F9               ; 29 F9
            cmp #$38               ; C9 38
            bne L3C97              ; D0 05
            ldy #$4F               ; A0 4F
            jsr L07BE              ; 20 BE 07
L3C97       pla                    ; 68
            eor #$9F               ; 49 9F
            sta L0CA0              ; 8D A0 0C
            jsr L0972              ; 20 72 09
            php                    ; 08
            .byte $03,$1A
            .byte $0D,$1C,$00      ; ora ABUFPT
L3CA6       jsr L096B              ; 20 6B 09
            .byte $44,$07
            sec                    ; 38
            .byte $0D,$40,$00      ; ora FREQ
            php                    ; 08
            jsr L0919              ; 20 19 09
            .byte $C3
            cli                    ; 58
            jmp L20BE              ; 4C BE 20
            .byte $6B
            ora #$40               ; 09 40
            .byte $0B
            sec                    ; 38
            .byte $0D,$40,$00      ; ora FREQ
            plp                    ; 28
            bpl L3CA6              ; 10 E3
            rts                    ; 60
            sta FMSZPG+2           ; 85 45
            txa                    ; 8A
            pha                    ; 48
            ldx L0CF1,Y            ; BE F1 0C
            lda HATABS+1,X         ; BD 1B 03
            sta FMSZPG             ; 85 43
            lda HATABS+2,X         ; BD 1C 03
            sta FMSZPG+1           ; 85 44
            ldx L0A3C,Y            ; BE 3C 0A
            pla                    ; 68
            tay                    ; A8
            lda (FMSZPG),Y         ; B1 43
            pha                    ; 48
            dey                    ; 88
            lda (FMSZPG),Y         ; B1 43
            pha                    ; 48
            lda FMSZPG+2           ; A5 45
            rts                    ; 60

; start of COMTAB
            .byte $FF				; COMTAB-21: DWARM $0ce4
            .byte $80
			.byte $20,$20,$20,$20	; COMTAB-19: DECOUT
			.byte $20,$20,$20,$20
			.byte $4C				; jmp SIO
			.word $E459				; COMTAB-10 LSIO
			.byte $FF				; COMTAB-8  ECHOFLG
            .byte $FF				; COMTAB-7  BATFLG 
            .byte $00,$00,$00,$00	; COMTAB-6  DECIN
			.byte $50				; COMTAB-2  WRTCMD 
			.byte $FF				; COMTAB-1  WARMST
; DOSVEC => $0CF9
            jmp L09E1               ; COMTAB    Jump to DOS CP
            jmp L0766               ; COMTAB+3  CRNAME
            .word $0AFC				; COMTAB+6  DIVIO
            .word $0B7E				; COMTAB+8  XDIVIO
            .byte $00      			; COMTAB+10 BUFOFF
            .byte $00,$07
            .byte $1C,$0B,$5F		; COMTAB+13 DATER 28.11.95
			.byte $16,$0E,$06		; COMTAB+16 TIMER 22:14:06
            .byte $1C,$0B,$5F		; COMTAB+19 ODATER
			.byte $16,$0E,$06		; COMTAB+22 OTIMER
			.byte $00				; COMTAB+25 TDOVER
            .word $085E				; COMTAB+26 TRUN
            .byte $11,$17			; ??? buffer adr ???
            .word $1EE4				; COMTAB+30 SMEMLO start up MEMLO
            .byte $00				; COMTAB+32 INCMND Reset $00-CP $FF-Cart
			.byte 'D1:STARTUP.BAT',$9B ; COMTAB+33 COMFNAM 28 Bytes
			.byte $20,$20,$20
			.byte $20,$20,$20
			.byte $20,$20,$20
			.byte $20,$20,$20,$20
			.word $085E				; COMTAB+61 RUNLOC address for RUN
									; COMTAB+63  LBUF comman line buffer 64 Bytes
            jsr L07F2              ; 20 F2 07
            lda #$FF               ; A9 FF
            sta FMSZPG+4           ; 85 47
            ldy #$01               ; A0 01
            jsr L0AFC              ; 20 FC 0A
            bmi L3D55              ; 30 0F
            jsr L0A71              ; 20 71 0A
            stx COLDST             ; 8E 44 02
            lda BOOT               ; A5 09
            ora #$01               ; 09 01
            sta BOOT               ; 85 09
            jmp L09E1              ; 4C E1 09

L3D55       clc                    ; 18
            rts                    ; 60
            jsr L2020              ; 20 20 20
            jsr L2020              ; 20 20 20
            jsr L2020              ; 20 20 20
            jsr L2020              ; 20 20 20
            jsr L2020              ; 20 20 20
            jsr L2020              ; 20 20 20
            jsr L2020              ; 20 20 20
            jsr L2020              ; 20 20 20
            jsr L2020              ; 20 20 20
            jsr L2020              ; 20 20 20
            jsr L2020              ; 20 20 20
            .byte $9B,$44
            and (XMTDON),Y         ; 31 3A
            .byte $9B
            rol L4142              ; 2E 42 41
            .byte $54,$9B
            rol L4F43              ; 2E 43 4F
            eor L2A9B              ; 4D 9B 2A
            rol L9B2A              ; 2E 2A 9B
            lsr SHFAMT,X           ; 56 6F
            jmp (L6D75)            ; 6C 75 6D
            adc XMTDON             ; 65 3A
            jsr L2020              ; 20 20 20
            jsr L2020              ; 20 20 20
            jsr L2020              ; 20 20 20
            jsr L2020              ; 20 20 20
            jsr L2020              ; 20 20 20
            jsr L2020              ; 20 20 20
            jsr L2020              ; 20 20 20
            jsr L2020              ; 20 20 20
            jsr L2020              ; 20 20 20
            jsr L2020              ; 20 20 20
            jsr L2020              ; 20 20 20
            jsr L2020              ; 20 20 20
            jsr L2020              ; 20 20 20
            jsr L2020              ; 20 20 20
            jsr L2020              ; 20 20 20
            jsr L2020              ; 20 20 20
            jsr L2020              ; 20 20 20
            jsr L449B              ; 20 9B 44
            adc #$72               ; 69 72
            adc LOGCOL             ; 65 63
            .byte $74,$6F,$72
            adc LC43A,Y            ; 79 3A C4
            cmp #$D2               ; C9 D2
            .byte $3C,$44
            eor #$52               ; 49 52
            rol L5246,X            ; 3E 46 52
            eor FMSZPG+2           ; 45 45
            jsr L4553              ; 20 53 45
            .byte $43,$54,$4F,$52,$53,$00,$00,$00
            .byte $00,$80
            jsr L2020              ; 20 20 20
            jsr L2020              ; 20 20 20
            jsr LFF20              ; 20 20 FF
            .byte $FF,$44,$4F,$53
            jsr L2020              ; 20 20 20
            jsr L2020              ; 20 20 20
            jsr L2120              ; 20 20 21
            .byte $00,$00,$00,$02,$00,$1C,$17,$00
            ora ($00,X)            ; 01 00
;            and L1AA2              ; 2D A2 1A
			.byte $2D

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; start
L3E0B		ldx #$1A			
L3E0D       lda DDEVIC,X           ; BD 00 03
            cmp #$45               ; C9 45
            beq L3E1E              ; F0 0A
            inx                    ; E8
            inx                    ; E8
            inx                    ; E8
            cpx #$3B               ; E0 3B
            bcc L3E0D              ; 90 F2
            jmp SELFSV             ; 4C 71 E4
L3E1E       inx                    ; E8
            stx L0B33              ; 8E 33 0B
            stx L0B68              ; 8E 68 0B
            stx L0AF5              ; 8E F5 0A
            inx                    ; E8
            stx L0B29              ; 8E 29 0B
            jsr L0919              ; 20 19 09
            dec L4062              ; CE 62 40
            .byte $0C
            txa                    ; 8A

; clear memory form MEMLO to MEMTOP
            ldy #$E4               ; A0 E4
            ldx #$1E               ; A2 1E
L3E38       stx L0E3D              ; 8E 3D 0E
L3E3B       sta LFF00,Y            ; 99 00 FF
            iny                    ; C8
            bne L3E3B              ; D0 FA
            inx                    ; E8
            cpx MEMTOP+1           ; EC E6 02
            bcc L3E38              ; 90 F1

; write start text
L3E47       tya                    ; 98

;            lda L0E64,Y
            eor L0E64,Y            ; 59 64 0E

            beq L3E5F              ; F0 12
            sta L0EC9              ; 8D C9 0E
            tya                    ; 98
            pha                    ; 48
            jsr L096F              ; 20 6F 09

;			anc #$C9               ???
;			asl $0001
            .byte $0B
            cmp #$0E               ; C9 0E
            ora ($00,X)            ; 01 00

            pla                    ; 68
            tay                    ; A8
            iny                    ; C8
            bne L3E47              ; D0 E8
L3E5F       jmp L0D38              ; 4C 38 0D

; set DOSINI
            .word $07E0

; start text BW-DOS etc.

;            .byte $9b,'BW-DOS 1.31a BEWESOFT & HJX 2020',$9B,$00
           
            .byte $9B,$21,$22,$23,$24,$25,$26,$27
            .byte $36,$37,$2A,$49,$5B,$20,$4A,$40
            .byte $43,$31,$44,$76,$66,$3B,$36,$26
            .byte $36,$2A,$2A,$3B,$20,$21,$85,$3F
            .byte $08,$62,$0B,$03,$66,$60,$71,$62
            .byte $7B,$66,$6C,$7F,$0C,$1C,$17,$16
            .byte $05,$11,$12,$1B,$7E,$5C,$44,$5E
            .byte $18,$7B,$5F,$49,$52,$5C,$4D,$5A
            .byte $2B,$68,$D9,$63,$64,$65,$66,$13
            .byte $20,$20,$39,$6B,$25,$3E,$6E,$2E
            .byte $70,$17,$20,$36,$31,$02,$37,$25
            .byte $3D,$79,$2A,$29,$33,$3A,$2C,$3E
            .byte $0D,$41,$43,$F8,$64

;			.byte $42,$56,$2F,$47,$4B,$56,$26,$36
;			.byte $26,$3A,$3A,$43,$46,$55,$2E,$27
;			.byte $73,$38,$32,$51,$51,$42,$53,$44
;			.byte $57,$5F,$4E,$3B,$2D,$24,$27,$2A
;			.byte $BB,$21

; end text BW-DOS etc.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
            org $3F4C
;
            ldx L0E3D              ; AE 3D 0E
            lda L0E3E              ; AD 3E 0E
            jsr L1BE9              ; 20 E9 1B
            ldy L0E3F              ; AC 3F 0E
            rts                    ; 60
            lda L0F58,Y            ; B9 58 0F
            and #$1F               ; 29 1F
            pha                    ; 48
            lda L0F46,Y            ; B9 46 0F
            pha                    ; 48
            ldx FMSZPG+3           ; A6 46
            rts                    ; 60
            bne L3F38              ; D0 D0
            stx L00D0,Y            ; 96 D0
            bne L3F9D              ; D0 31
            inx                    ; E8
            .byte $EB
            and (L008F,X)          ; 21 8F
            .byte $89
            ora L7C94,Y            ; 19 94 7C
            inx                    ; E8
            .byte $53
            sty LFC95              ; 8C 95 FC
            .byte $FC
            sta L00FC,X            ; 95 FC
            .byte $FC,$34
            rol LTEMP,X            ; 36 36
            rol LF5D5,X            ; 3E D5 F5
            sbc L53FA,X            ; FD FA 53
            .byte $12
            sbc (RTCLOK),Y         ; F1 12
            .byte $12
            ldy ICCOMZ             ; A4 22
            sta L10DC              ; 8D DC 10
            tya                    ; 98
            and #$F0               ; 29 F0
            cmp #$20               ; C9 20
            bne L3F9B              ; D0 05
            and L0F58,Y            ; 39 58 0F
            bne L3FAF              ; D0 14
L3F9B       ldy #$A8               ; A0 A8
L3F9D       rts                    ; 60
            ldy #$22               ; A0 22
            bit L2DA0              ; 2C A0 2D
            bit L30A0              ; 2C A0 30
            bit L31A0              ; 2C A0 31
            bit L29A0              ; 2C A0 29
            sta L10DC              ; 8D DC 10
L3FAF       cld                    ; D8
            stx FMSZPG+3           ; 86 46
            lda #$01               ; A9 01
            sta L10BB              ; 8D BB 10
            cpy #$28               ; C0 28
            bne L3FC4              ; D0 09
            jsr L0F59              ; 20 59 0F
            bit LA1A0              ; 2C A0 A1
L3FC1       jmp L10DB              ; 4C DB 10
L3FC4       tsx                    ; BA
            stx L10C3              ; 8E C3 10
            inx                    ; E8
            inx                    ; E8
            lda L0100,X            ; BD 00 01
            sta L12A3              ; 8D A3 12
            sty L109C              ; 8C 9C 10
            lda L0F58,Y            ; B9 58 0F
            and #$C0               ; 29 C0
            sta L0FEC              ; 8D EC 0F
            ldx FMSZPG+3           ; A6 46
            jsr L1121              ; 20 21 11
            bne L3FEB              ; D0 09
            bit L0FEC              ; 2C EC 0F
            bpl L4000              ; 10 19
            ldy #$81               ; A0 81
            bne L3FC1              ; D0 D6
L3FEB       lda #$00               ; A9 00
            bpl L4023              ; 10 34
            ldx #$FF               ; A2 FF
            jsr L1121              ; 20 21 11
            bne L3FBF              ; D0 C9
            lda FMSZPG+3           ; A5 46
            sta L0ED7,Y            ; 99 D7 0E
            lda ICDNOZ             ; A5 21
            sta L0ED8,Y            ; 99 D8 0E
L4000       sty L10CD              ; 8C CD 10
            ldx #$EB               ; A2 EB
L4005       lda L0ED7,Y            ; B9 D7 0E
            sta L0D4D,X            ; 9D 4D 0D
            iny                    ; C8
            inx                    ; E8
            bne L4005              ; D0 F6
            ldy #$68               ; A0 68
L4011       lda L0E55,Y            ; B9 55 0E
            cmp L0E39              ; CD 39 0E
            beq L402F              ; F0 16
            tya                    ; 98
            sec                    ; 38
            sbc #$1A               ; E9 1A
            tay                    ; A8
            bcs L4011              ; B0 F1
            jsr L10BE              ; 20 BE 10
L4023       ldy #$85               ; A0 85
            lda L109C              ; AD 9C 10
            cmp #$2D               ; C9 2D
            bne L3FC1              ; D0 95
            jmp L10BA              ; 4C BA 10
L402F       ldx #$E6               ; A2 E6
L4031       lda L0D6F,X            ; BD 6F 0D
            pha                    ; 48
            lda L0E55,Y            ; B9 55 0E
            sta L0D6F,X            ; 9D 6F 0D
            pla                    ; 68
            sta L0E55,Y            ; 99 55 0E
            iny                    ; C8
            inx                    ; E8
            bne L4031              ; D0 EE
            bit L0FEC              ; 2C EC 0F
            bpl L4093              ; 10 4B
            jsr L1BE5              ; 20 E5 1B
            ldy #$07               ; A0 07
            lda (FMSZPG),Y         ; B1 43
            cmp #$80               ; C9 80
            bne L405B              ; D0 08
            lda #$1F               ; A9 1F
            tay                    ; A8
            iny                    ; C8
            cmp (FMSZPG),Y         ; D1 43
            bcc L405F              ; 90 04
L405B       jsr L10BE              ; 20 BE 10
            sty L00A0,X            ; 94 A0
            asl L00B9,X            ; 16 B9
L4062       eor LD10E              ; 4D 0E D1
            .byte $43
            bne L407D              ; D0 15
            iny                    ; C8
            cpy #$1E               ; C0 1E
            bcc L4061              ; 90 F4
            ldy #$26               ; A0 26
L406F       lda L0E45,Y            ; B9 45 0E
            cmp (FMSZPG),Y         ; D1 43
            bne L407D              ; D0 07
            iny                    ; C8
            cpy #$28               ; C0 28
            bcc L406F              ; 90 F4
            bcs L4093              ; B0 16
L407D       lda #$99               ; A9 99
            jsr L1131              ; 20 31 11
            iny                    ; C8
            lda (FMSZPG),Y         ; B1 43
            ldy L0E39              ; AC 39 0E
            sta L0DE9,Y            ; 99 E9 0D
            jsr L0919              ; 20 19 09
            .byte $22
            cpy L91E3              ; CC E3 91
            .byte $14
L4093       ldy L0E39              ; AC 39 0E
            lda L0DE9,Y            ; B9 E9 0D
            sta FMSZPG+2           ; 85 45
            ldy #$00               ; A0 00
            jsr L0F59              ; 20 59 0F
            bit L0FEC              ; 2C EC 0F
            bvc L40AB              ; 50 06
            jsr L10E2              ; 20 E2 10
            stx L0E38              ; 8E 38 0E
L40AB       ldy L10CD              ; AC CD 10
            ldx #$EB               ; A2 EB
L40B0       lda L0D4D,X            ; BD 4D 0D
            sta L0ED7,Y            ; 99 D7 0E
            iny                    ; C8
            inx                    ; E8
            bne L40B0              ; D0 F6
            ldy #$01               ; A0 01
            bne L40DB              ; D0 1D
            jsr L08C5              ; 20 C5 08
            tay                    ; A8
            ldx #$00               ; A2 00
            txs                    ; 9A
            tya                    ; 98
            pha                    ; 48
            lda L0FEC              ; AD EC 0F
            beq L40D3              ; F0 07
            ldy #$00               ; A0 00
            lda #$FF               ; A9 FF
            sta L0ED7,Y            ; 99 D7 0E
L40D3       jsr L10E2              ; 20 E2 10
            jsr L1114              ; 20 14 11
            pla                    ; 68
            tay                    ; A8
L40DB       lda #$00               ; A9 00
            ldx FMSZPG+3           ; A6 46
            cpy #$00               ; C0 00
            rts                    ; 60
            ldx L0E39              ; AE 39 0E
            lda L0E4C,X            ; BD 4C 0E
            bpl L40FB              ; 10 11
            lsr L0E4C,X            ; 5E 4C 0E
            jsr L1BE5              ; 20 E5 1B
            jsr L1C2B              ; 20 2B 1C
            inc L0E6B              ; EE 6B 0E
            lda #$B9               ; A9 B9
            jsr L1131              ; 20 31 11
L40FB       ldx #$03               ; A2 03
L40FD       dex                    ; CA
            bmi L4113              ; 30 13
            jsr L110C              ; 20 0C 11
            bne L40FD              ; D0 F8
            bcc L40FD              ; 90 F6
            jsr L1B13              ; 20 13 1B
            bpl L40FB              ; 10 EF
            lda L0F40,X            ; BD 40 0F
            eor L0E39              ; 4D 39 0E
            asl                    ; 0A
L4113       rts                    ; 60
            ldx #$02               ; A2 02
L4116       jsr L110C              ; 20 0C 11
            bne L411E              ; D0 03
            sta L0F40,X            ; 9D 40 0F
L411E       dex                    ; CA
            bpl L4116              ; 10 F5
            ldy #$54               ; A0 54
L4123       txa                    ; 8A
            cmp L0ED7,Y            ; D9 D7 0E
            beq L4130              ; F0 07
            tya                    ; 98
            sec                    ; 38
            sbc #$15               ; E9 15
            tay                    ; A8
            bcs L4123              ; B0 F3
L4130       rts                    ; 60
            sta L1149              ; 8D 49 11
            sta L113B              ; 8D 3B 11
            ldy #$26               ; A0 26
L4139       lda (FMSZPG),Y         ; B1 43
            sta L0E45,Y            ; 99 45 0E
            sta (FMSZPG),Y         ; 91 43
            iny                    ; C8
            cpy #$28               ; C0 28
            bcc L4139              ; 90 F4
            ldy #$09               ; A0 09
L4147       lda (FMSZPG),Y         ; B1 43
            lda L0E4D,Y            ; B9 4D 0E
            sta (FMSZPG),Y         ; 91 43
            iny                    ; C8
            cpy #$1E               ; C0 1E
            bcc L4147              ; 90 F4
            rts                    ; 60
            jsr L0919              ; 20 19 09
            cpy #$28               ; C0 28
            eor (L0086),Y          ; 51 86
            ldy #$20               ; A0 20
            jsr L1182              ; 20 82 11
            ldy #$1F               ; A0 1F
            jsr L1182              ; 20 82 11
            ldy #$0B               ; A0 0B
L4167       jsr L1182              ; 20 82 11
            cpy #$0F               ; C0 0F
            bcc L4167              ; 90 F9
            ldy #$16               ; A0 16
L4170       jsr L1182              ; 20 82 11
            cpy #$1E               ; C0 1E
            bcc L4170              ; 90 F9
            ldy #$26               ; A0 26
            jsr L1182              ; 20 82 11
            jsr L1182              ; 20 82 11
            lda #$00               ; A9 00
            bit L43B1              ; 2C B1 43
            iny                    ; C8
            sta LFFFF,X            ; 9D FF FF
            inx                    ; E8
            rts                    ; 60
            ldx #$FD               ; A2 FD
L418C       lda L0CEA              ; AD EA 0C
            cmp #$20               ; C9 20
            bne L4197              ; D0 04
            lda L0BEE,X            ; BD EE 0B
            bit L39A9              ; 2C A9 39
            ora #$30               ; 09 30
            sta L0BEE,X            ; 9D EE 0B
            inx                    ; E8
            bne L418C              ; D0 EB
            rts                    ; 60
L41A2       jsr L14DA              ; 20 DA 14
            sta (ICHIDZ),Y         ; 91 20
            ora L1109,Y            ; 19 09 11
            txa                    ; 8A
            jmp L6DEB              ; 4C EB 6D
            sta L4FAC,X            ; 9D AC 4F
            .byte $17
            beq L4215              ; F0 61
L41B4       jsr L0919              ; 20 19 09
            lsr L4C5A              ; 4E 5A 4C
            .byte $F3,$87
            and L00A2              ; 25 A2
            .byte $00
            bpl L41A2              ; 10 E1
            jsr L14DA              ; 20 DA 14
            sty ICHIDZ,X           ; 94 20
            ora L4C09,Y            ; 19 09 4C
            inx                    ; E8
            cmp LAC9D              ; CD 9D AC
            .byte $4F,$1A
            beq L4215              ; F0 44
L41D1       jsr L14DA              ; 20 DA 14
            .byte $12
            jsr L0919              ; 20 19 09
            .byte $AB
            sta LAD15,X            ; 9D 15 AD
            and (APPMHI,X)         ; 21 0E
            lsr                    ; 4A
            bcc L41E6              ; 90 05
            ldx #$2A               ; A2 2A
            stx L0D9D              ; 8E 9D 0D
L41E6       and #$10               ; 29 10
            beq L41F0              ; F0 06
            jsr L0919              ; 20 19 09
            .byte $A3,$47
            ora L24AD,X            ; 1D AD 24
            asl L25AE              ; 0E AE 25
            asl L26AC              ; 0E AC 26
            asl LFD20              ; 0E 20 FD
            .byte $14
            cmp #$00               ; C9 00
            beq L4204              ; F0 04
            inx                    ; E8
            bne L4204              ; D0 01
            iny                    ; C8
L4204       stx L0CF3              ; 8E F3 0C
            sty L0CF4              ; 8C F4 0C
            jsr L0919              ; 20 19 09
            .byte $07
            and BRKKEY             ; 25 11
            txa                    ; 8A
            cpy L6DEB              ; CC EB 6D
            .byte $AB
L4215       beq L4274              ; F0 5D
L4217       jsr L0919              ; 20 19 09
            .byte $2B
            php                    ; 08
            sta (L009D,X)          ; 81 9D
            .byte $BF
            bne L41B4              ; D0 93
            bit L11BE              ; 2C BE 11
            bpl L41D1              ; 10 AB
            jsr L14DA              ; 20 DA 14
            bit ICHIDZ             ; 24 20
            ora L2809,Y            ; 19 09 28
            sta L2313,X            ; 9D 13 23
            lda ABUFPT             ; A5 1C
            and ZCHAIN             ; 25 4A
            jsr L8021              ; 20 21 80
            and #$21               ; 29 21
            .byte $80
            bit L07A1              ; 2C A1 07
            .byte $32
            lda L0E21              ; AD 21 0E
            and #$20               ; 29 20
            bne L4253              ; D0 0D
            jsr L0919              ; 20 19 09
            lsr L6C24              ; 4E 24 6C
            .byte $F3,$07
            rol                    ; 2A
            cpy LEDE7              ; CC E7 ED
            lda #$A0               ; A9 A0
            .byte $FB
L4255       txa                    ; 8A
            pha                    ; 48
            lda L0D37,Y            ; B9 37 0D
            jsr L071D              ; 20 1D 07
            jsr L118A              ; 20 8A 11
            pla                    ; 68
            tax                    ; AA
            lda L0CEC              ; AD EC 0C
            sta L0DB1,X            ; 9D B1 0D
            lda L0CED              ; AD ED 0C
            sta L0DB2,X            ; 9D B2 0D
            inx                    ; E8
            inx                    ; E8
            inx                    ; E8
            iny                    ; C8
            bne L4255              ; D0 E1
L4274       dec L1284              ; CE 84 12
            ldx #$00               ; A2 00
            lda L0D9D,X            ; BD 9D 0D
            inc L1278              ; EE 78 12
            sta L10DC              ; 8D DC 10
            rts                    ; 60
L4283       lda #$00               ; A9 00
            asl                    ; 0A
            bne L4274              ; D0 EC
            bcs L42EE              ; B0 64
            jmp L1217              ; 4C 17 12
            ldx L0E48              ; AE 48 0E
            cpx #$16               ; E0 16
            beq L4283              ; F0 EF
            lda #$6A               ; A9 6A
            eor #$6A               ; 49 6A
            sta FMSZPG+5           ; 85 48
            and #$0C               ; 29 0C
L429C       eor #$07               ; 49 07
            cmp ICCOMZ             ; C5 22
            bne L42DF              ; D0 3D
            lda #$00               ; A9 00
            cmp #$E4               ; C9 E4
            bcc L42DF              ; 90 37
            ldy ICBLHZ             ; A4 29
            bne L42B1              ; D0 05
            iny                    ; C8
            cpy ICBLLZ             ; C4 28
            bcs L42DF              ; B0 2E
L42B1       jsr L0919              ; 20 19 09
            rti                    ; 40
            bit ROWCRS             ; 24 54
            .byte $27
            rti                    ; 40
            plp                    ; 28
            lsr L9351              ; 4E 51 93
            ror                    ; 6A
            php                    ; 08
            jsr L0919              ; 20 19 09
            .byte $54,$27
            rti                    ; 40
            bit L00CE              ; 24 CE
            eor (FREQ),Y           ; 51 40
            plp                    ; 28
            plp                    ; 28
            bmi L42EE              ; 30 21
            jsr L0869              ; 20 69 08
            bit $00                ; 24 00
            lda (ICSTAZ,X)         ; A1 23
            inc ICBLLZ             ; E6 28
            sta L10DC              ; 8D DC 10
L42D9       jsr L14BF              ; 20 BF 14
            beq L42F0              ; F0 12
            rts                    ; 60
L42DF       jsr L0919              ; 20 19 09
            .byte $52,$D7,$54,$27
            ldx #$7E               ; A2 7E
            .byte $C7
            jsr L136A              ; 20 6A 13
            bpl L42D9              ; 10 EB
L42EE       lda #$8B               ; A9 8B
L42F0       eor #$03               ; 49 03
            sta L10BB              ; 8D BB 10
            rts                    ; 60
            jsr L0F4C              ; 20 4C 0F
            iny                    ; C8
            iny                    ; C8
            sty L0E3F              ; 8C 3F 0E
            cpy FMSZPG+2           ; C4 45
            bne L4345              ; D0 43
            jsr L0F4C              ; 20 4C 0F
            ldy #$00               ; A0 00
            lda (FMSZPG),Y         ; B1 43
            tax                    ; AA
            iny                    ; C8
            ora (FMSZPG),Y         ; 11 43
            bne L4335              ; D0 26
            jsr L1B6C              ; 20 6C 1B
            ldy #$02               ; A0 02
L4314       lda L0E3B,Y            ; B9 3B 0E
            sta (FMSZPG),Y         ; 91 43
            iny                    ; C8
            cpy #$04               ; C0 04
            bcc L4314              ; 90 F6
            jsr L0F4C              ; 20 4C 0F
            ldy #$01               ; A0 01
L4323       lda L0DE5,Y            ; B9 E5 0D
            sta (FMSZPG),Y         ; 91 43
            dey                    ; 88
            bpl L4323              ; 10 F8
            jsr L0919              ; 20 19 09
            .byte $1C,$2B
            ldx #$5B               ; A2 5B
            .byte $B3
            beq L433D              ; F0 08
L4335       lda (FMSZPG),Y         ; B1 43
            sta L0E3E              ; 8D 3E 0E
            stx L0E3D              ; 8E 3D 0E
L433D       jsr L0F4C              ; 20 4C 0F
            ldy #$04               ; A0 04
            sty L0E3F              ; 8C 3F 0E
L4345       lda (FMSZPG),Y         ; B1 43
            sta L0E3A              ; 8D 3A 0E
            iny                    ; C8
            lda (FMSZPG),Y         ; B1 43
            sta L0E3B              ; 8D 3B 0E
            ora L0E3A              ; 0D 3A 0E
            rts                    ; 60
            sec                    ; 38
            ldx #$FD               ; A2 FD
L4357       lda L0D48,X            ; BD 48 0D
            sbc L0D43,X            ; FD 43 0D
            inx                    ; E8
            bne L4357              ; D0 F7
            bcs L4369              ; B0 07
            jsr L0919              ; 20 19 09
            .byte $A3
            ldx L00BB,Y            ; B6 BB
            clc                    ; 18
L4369       rts                    ; 60
            lda L0E48              ; AD 48 0E
            ldy #$83               ; A0 83
            bit FMSZPG+5           ; 24 48
            bpl L4376              ; 10 03
            lsr                    ; 4A
            ldy #$87               ; A0 87
L4376       and #$04               ; 29 04
            bne L43BF              ; D0 45
            jmp L10C2              ; 4C C2 10
            lda L0E48              ; AD 48 0E
            cmp #$16               ; C9 16
            bne L4387              ; D0 03
            lsr L0E53              ; 4E 53 0E
L4387       and #$08               ; 29 08
            beq L4369              ; F0 DE
            jsr L0919              ; 20 19 09
L438E       .byte $23,$BB
            sty LBF22              ; 8C 22 BF
            lda L0C15,Y            ; B9 15 0C
            .byte $13,$9E,$A3
            sty LA99A              ; 8C 9A A9
            .byte $FF
            .byte $2C,$A9,$00      ; bit L00A9
            pha                    ; 48
            jsr L0919              ; 20 19 09
            .byte $22
            cmp (ADRESS,X)         ; C1 64
            and (DELTAR,X)         ; 21 76
            ror L0094              ; 66 94
            rol L2C68,X            ; 3E 68 2C
            lda #$00               ; A9 00
            bit LFFA9              ; 2C A9 FF
            sta FMSZPG+5           ; 85 48
            jsr L0919              ; 20 19 09
            eor (L00DC),Y          ; 51 DC
            .byte $54,$27
            ldx #$7C               ; A2 7C
            .byte $C7
L43BF       lda FMSZPG+2           ; A5 45
            sec                    ; 38
            sbc L0E3C              ; ED 3C 0E
            bne L43C9              ; D0 02
            lda #$FF               ; A9 FF
L43C9       sta L1489              ; 8D 89 14
            lda L0E52              ; AD 52 0E
            bne L43D9              ; D0 08
            lda L0E51              ; AD 51 0E
            beq L43F5              ; F0 1F
            jsr L14F5              ; 20 F5 14
L43D9       jsr L14BF              ; 20 BF 14
            beq L43F4              ; F0 16
            jsr L14F5              ; 20 F5 14
            lda L0E3A              ; AD 3A 0E
            ora L0E3B              ; 0D 3B 0E
            bne L440E              ; D0 25
            lda L0E48              ; AD 48 0E
            and #$08               ; 29 08
            bne L43F6              ; D0 06
L43F0       jsr L10BE              ; 20 BE 10
            ldx L00CA              ; A6 CA
L43F5       rts                    ; 60
L43F6       jsr L0919              ; 20 19 09
            .byte $1B
            jmp (L5B22)            ; 6C 22 5B
            bcs L438E              ; B0 8F
            jmp LE5AD              ; 4C AD E5
            ora L4391              ; 0D 91 43
            iny                    ; C8
            lda L0DE6              ; AD E6 0D
            sta (FMSZPG),Y         ; 91 43
            jsr L1C2B              ; 20 2B 1C
L440E       ldx L0E3A              ; AE 3A 0E
            lda L0E3B              ; AD 3B 0E
            jsr L0919              ; 20 19 09
            .byte $1B
            sbc #$D4               ; E9 D4
            .byte $27,$54,$82
            ldy L0E3C              ; AC 3C 0E
            bit FMSZPG+5           ; 24 48
            bmi L4481              ; 30 5D
L4424       lda (FMSZPG),Y         ; B1 43
            sta LFFFF,X            ; 9D FF FF
            iny                    ; C8
            inx                    ; E8
            cpx L1489              ; EC 89 14
            bne L4424              ; D0 F4
            beq L448F              ; F0 5D
            ldy #$FD               ; A0 FD
L4434       lda IOCB0+ICAX3,X      ; BD 4C 03
            sta L0CF1,Y            ; 99 F1 0C
            inx                    ; E8
            iny                    ; C8
            bne L4434              ; D0 F6
            lda L0DF0              ; AD F0 0D
            bmi L43F0              ; 30 AD
            jsr L0919              ; 20 19 09
            and (KEYDEF,X)         ; 21 79
            lda ICCOMZ,X           ; B5 22
            lda L23B3,Y            ; B9 B3 23
            .byte $64
            ldx L0093,Y            ; B6 93
            .byte $54
            bcs L445A              ; B0 07
            lda L0E48              ; AD 48 0E
            and #$08               ; 29 08
            beq L43F0              ; F0 96
L445A       lda L0DEE              ; AD EE 0D
            ldx L0DEF              ; AE EF 0D
            ldy L0DF0              ; AC F0 0D
            jsr L14FD              ; 20 FD 14
            sta L0E3C              ; 8D 3C 0E
            stx L0DEE              ; 8E EE 0D
            sty L0DEF              ; 8C EF 0D
            jsr L12F6              ; 20 F6 12
            lda L0DEE              ; AD EE 0D
            ora L0DEF              ; 0D EF 0D
            beq L44D9              ; F0 5F
            jsr L0869              ; 20 69 08
            inc LB00D              ; EE 0D B0
            inc LFFBD              ; EE BD FF
            .byte $FF
            sta (FMSZPG),Y         ; 91 43
            iny                    ; C8
            inx                    ; E8
            cpx #$00               ; E0 00
            bne L4481              ; D0 F5
            jsr L1C2B              ; 20 2B 1C
L448F       lda L1489              ; AD 89 14
            jsr L086B              ; 20 6B 08
            eor (APPMHI),Y         ; 51 0E
            jsr L085F              ; 20 5F 08
            .byte $27
L449B       .byte $14
            jsr L085F              ; 20 5F 08
            rti                    ; 40
            asl IOCB5              ; 0E 90 03
            inc L0E42              ; EE 42 0E
            jsr L1354              ; 20 54 13
            lda L0E3C              ; AD 3C 0E
            clc                    ; 18
            adc L1489              ; 6D 89 14
            cmp FMSZPG+2           ; C5 45
            bne L44B9              ; D0 05
            jsr L12F6              ; 20 F6 12
            lda #$00               ; A9 00
L44B9       sta L0E3C              ; 8D 3C 0E
            jmp L13BF              ; 4C BF 13
            ldx #$FD               ; A2 FD
            sec                    ; 38
L44C2       lda L0D48,X            ; BD 48 0D
            sbc L0D43,X            ; FD 43 0D
            sta L0CF1,X            ; 9D F1 0C
            inx                    ; E8
            bne L44C2              ; D0 F4
            bit FMSZPG+5           ; 24 48
            bmi L44D7              ; 30 05
            ora L0DEF              ; 0D EF 0D
            beq L44F1              ; F0 1A
L44D7       lda #$FF               ; A9 FF
L44D9       rts                    ; 60
            jsr L08C5              ; 20 C5 08
            sta L1284              ; 8D 84 12
            asl                    ; 0A
            lsr                    ; 4A
            tax                    ; AA
            lda #$9B               ; A9 9B
            tay                    ; A8
L44E6       sta L0D9C,X            ; 9D 9C 0D
            lda #$20               ; A9 20
            dex                    ; CA
            bne L44E6              ; D0 F8
            stx L1278              ; 8E 78 12
L44F1       lda L0DEE              ; AD EE 0D
            rts                    ; 60
            cmp L1489              ; CD 89 14
            bcs L44D9              ; B0 DF
            sta L1489              ; 8D 89 14
            bit FMSZPG+2           ; 24 45
            bpl L450B              ; 10 0A
            asl                    ; 0A
            pha                    ; 48
            txa                    ; 8A
            rol                    ; 2A
            tax                    ; AA
            tya                    ; 98
            rol                    ; 2A
            tay                    ; A8
            pla                    ; 68
            lsr                    ; 4A
L450B       rts                    ; 60
            lda #$14               ; A9 14
            bit L0CA9              ; 2C A9 0C
            sta L0E48              ; 8D 48 0E
            pha                    ; 48
            jsr L0919              ; 20 19 09
            .byte $23
            ror ADRESS,X           ; 76 64
            sty FTYPE,X            ; 94 3E
            pla                    ; 68
            cmp #$10               ; C9 10
            bcc L452D              ; 90 0B
            jsr L0919              ; 20 19 09
            and (HOLDCH,X)         ; 21 7C
            .byte $BB,$13
            ldx L9AA3              ; AE A3 9A
            .byte $BB
L452D       rts                    ; 60
            jsr L0919              ; 20 19 09
            .byte $2B
            sta (L009D,X)          ; 81 9D
            .byte $23
            ror L009A,X            ; 76 9A
            cmp LCE06              ; CD 06 CE
            .byte $32
            bit L0D12              ; 2C 12 0D
            bpl L4547              ; 10 07
            jsr L0919              ; 20 19 09
            cmp LCE0C              ; CD 0C CE
            .byte $32
L4547       lda FMSZPG+6           ; A5 49
            sta L0E48              ; 8D 48 0E
            and #$20               ; 29 20
            ora #$08               ; 09 08
            sta L0E21              ; 8D 21 0E
L4553       rts                    ; 60
L4554       bit L0E53              ; 2C 53 0E
            bmi L45C4              ; 30 6B
            lda #$16               ; A9 16
            sta FMSZPG+6           ; 85 49
            jsr L0919              ; 20 19 09
            asl $00,X              ; 16 00
            .byte $AB
            sta (WARMST,X)         ; 81 08
            stx L1284              ; 8E 84 12
            lda ICAX2Z             ; A5 2B
            sta L11BE              ; 8D BE 11
            bpl L4585              ; 10 16
            jsr L14DA              ; 20 DA 14
            rol                    ; 2A
            sty L0DC5              ; 8C C5 0D
            jsr L0919              ; 20 19 09
            plp                    ; 28
            .byte $00,$13
            plp                    ; 28
            cmp L2B1F,Y            ; D9 1F 2B
            .byte $3C,$27
            tay                    ; A8
            sta L3833,X            ; 9D 33 38
            ror L0E53              ; 6E 53 0E
            rts                    ; 60
            lda #$28               ; A9 28
            ldx #$09               ; A2 09
            bne L45A0              ; D0 10
            lda ICAX1Z             ; A5 2A
            and #$F0               ; 29 F0
            ora #$04               ; 09 04
            bit L2AA5              ; 2C A5 2A
            and #$3F               ; 29 3F
            bit L14A9              ; 2C A9 14
            ldx #$29               ; A2 29
L45A0       stx L1684              ; 8E 84 16
            cmp #$06               ; C9 06
            beq L4554              ; F0 AD
            cmp #$20               ; C9 20
            bcc L45AD              ; 90 02
            and #$EF               ; 29 EF
L45AD       sta FMSZPG+6           ; 85 49
            and #$0F               ; 29 0F
            lsr                    ; 4A
            bcc L45B8              ; 90 04
            cmp #$04               ; C9 04
            bne L45BB              ; D0 03
L45B8       lsr                    ; 4A
            bcc L4600              ; 90 45
L45BB       ldy #$A8               ; A0 A8
            bit LA3A0              ; 2C A0 A3
            bit LA9A0              ; 2C A0 A9
            bit LA1A0              ; 2C A0 A1
            jmp L10C2              ; 4C C2 10
            ldx #$0A               ; A2 0A
L45CB       lda L0E0B,X            ; BD 0B 0E
            cmp #$3F               ; C9 3F
            beq L45BE              ; F0 EC
            dex                    ; CA
            bpl L45CB              ; 10 F6
            jmp (L0706)            ; 6C 06 07
L45D8       lda #$00               ; A9 00
            bpl L4622              ; 10 46
            jsr L0919              ; 20 19 09
            .byte $2B
            sta (L008C,X)          ; 81 8C
            .byte $2B
            ror                    ; 6A
            sta (ICCOMZ,X)         ; 81 22
            cpy L15B9              ; CC B9 15
            .byte $0C
            sta LD0C5,X            ; 9D C5 D0
            .byte $34
            jsr L0919              ; 20 19 09
            .byte $2B
            sty L2281              ; 8C 81 22
            tya                    ; 98
            lda L0C15,Y            ; B9 15 0C
            sta LD0C2,X            ; 9D C2 D0
            and DSTAT              ; 25 4C
            .byte $B2
            asl ICHIDZ,X           ; 16 20
            ldx L081A              ; AE 1A 08
            pla                    ; 68
            ror                    ; 6A
            ror                    ; 6A
            ror L15D9              ; 6E D9 15
            lda FMSZPG+6           ; A5 49
            and #$10               ; 29 10
            bne L467D              ; D0 6D
            jsr L150C              ; 20 0C 15
            jsr L1DBF              ; 20 BF 1D
            beq L467F              ; F0 67
L4618       lda FMSZPG+6           ; A5 49
            cmp #$04               ; C9 04
            beq L45D8              ; F0 BA
            and #$08               ; 29 08
            bne L462C              ; D0 0A
L4622       jsr L10BE              ; 20 BE 10
            tax                    ; AA
L4626       jsr L15C9              ; 20 C9 15
            jsr L1D4D              ; 20 4D 1D
L462C       bit L0E4C              ; 2C 4C 0E
            bmi L45C1              ; 30 90
            jsr L0919              ; 20 19 09
            ora L00C9,X            ; 15 C9
            ora ICAX5Z,X           ; 15 2E
            .byte $1B
            jmp (L5B22)            ; 6C 22 5B
            tya                    ; 98
            and (SWPFLG,X)         ; 21 7B
            ldx L9B13,Y            ; BE 13 9B
            .byte $22
            cmp (OLDCHR,X)         ; C1 5D
            .byte $22
            ror L00C1,X            ; 76 C1
            .byte $13,$9E,$23,$BB
            txs                    ; 9A
            .byte $13,$9B,$22
            eor L93C1,X            ; 5D C1 93
            .byte $9E
            lda FMSZPG+6           ; A5 49
            and #$20               ; 29 20
            beq L4678              ; F0 1E
L465A       beq L4618              ; F0 BC
            jsr L0919              ; 20 19 09
            .byte $22
            lda L225D,Y            ; B9 5D 22
            tya                    ; 98
            lda L0F15,Y            ; B9 15 0F
            ora ICAX5Z,X           ; 15 2E
            and (HOLDCH,X)         ; 21 7C
            txs                    ; 9A
            .byte $22
            eor L1398,X            ; 5D 98 13
            lda (ICCOMZ),Y         ; B1 22
            tya                    ; 98
            lda L0C15,Y            ; B9 15 0C
            .byte $93,$9E
L4678       jmp L16B2              ; 4C B2 16
L467B       bpl L4626              ; 10 A9
L467D       bne L46BB              ; D0 3C
L467F       lda FMSZPG+6           ; A5 49
            eor L0E21              ; 4D 21 0E
            and #$20               ; 29 20
            beq L4696              ; F0 0E
            lda FMSZPG+6           ; A5 49
            and #$08               ; 29 08
            beq L465A              ; F0 CC
            ldy #$97               ; A0 97
            bit LA4A0              ; 2C A0 A4
            jmp L10C2              ; 4C C2 10
L4696       lda FMSZPG+6           ; A5 49
            and #$08               ; 29 08
            beq L46B2              ; F0 16
            lda L0E21              ; AD 21 0E
            and #$21               ; 29 21
            lsr                    ; 4A
            bne L46B2              ; D0 0E
            bcs L4691              ; B0 EB
            lda FMSZPG+6           ; A5 49
            cmp #$08               ; C9 08
            bne L46B2              ; D0 06
            lda #$00               ; A9 00
            bpl L467B              ; 10 CB
            inc FMSZPG+6           ; E6 49
L46B2       jsr L0919              ; 20 19 09
            .byte $22
            lda LA5BF,Y            ; B9 BF A5
            tya                    ; 98
            lda L49A5,Y            ; B9 A5 49
            jsr L1511              ; 20 11 15
            lda FMSZPG+6           ; A5 49
            cmp #$10               ; C9 10
            bcc L46DB              ; 90 15
            jsr L0919              ; 20 19 09
            .byte $22
            lda LA2BF,Y            ; B9 BF A2
            ror L00C1,X            ; 76 C1
            lda FMSZPG+6           ; A5 49
            and #$07               ; 29 07
            bne L46DB              ; D0 06
            jsr L0919              ; 20 19 09
            .byte $A3
            ldx L00BB,Y            ; B6 BB
L46DB       lda FMSZPG+6           ; A5 49
            lsr                    ; 4A
            bcc L46FD              ; 90 1D
            jsr L0919              ; 20 19 09
            .byte $A3,$BB,$64
            jmp L143E              ; 4C 3E 14
            ldy #$00               ; A0 00
            bit L05A0              ; 2C A0 05
L46EE       lda L0E40,Y            ; B9 40 0E
            sta IOCB0+ICAX3,X      ; 9D 4C 03
            iny                    ; C8
            inx                    ; E8
            txa                    ; 8A
            and #$0F               ; 29 0F
            cmp #$03               ; C9 03
            bcc L46EE              ; 90 F1
L46FD       rts                    ; 60
            stx L1C2C              ; 8E 2C 1C
            lda #$FF               ; A9 FF
            sta L0F49,X            ; 9D 49 0F
            txa                    ; 8A
            clc                    ; 18
            adc #$17               ; 69 17
            sta FMSZPG+1           ; 85 44
            lda #$11               ; A9 11
            sta FMSZPG             ; 85 43
            rts                    ; 60
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
            org $4A11
;
            cpx #$08               ; E0 08
            bcc L4A1E              ; 90 09
            bit L1C48              ; 2C 48 1C
            bpl L4A22              ; 10 08
            cpx #$0B               ; E0 0B
            bcs L4A22              ; B0 04
L4A1E       sta L0E0B,X            ; 9D 0B 0E
            inx                    ; E8
L4A22       rts                    ; 60
            ldy #$00               ; A0 00
            sty L1AEA              ; 8C EA 1A
            inc L1A24              ; EE 24 1A
            lda #$0E               ; A9 0E
            sta L1C48              ; 8D 48 1C
            ldx #$00               ; A2 00
            beq L4A3E              ; F0 0A
L4A34       lda #$3F               ; A9 3F
            jsr L1A11              ; 20 11 1A
            bcc L4A34              ; 90 F9
L4A3B       jsr L1A11              ; 20 11 1A
L4A3E       iny                    ; C8
            lda (ICBALZ),Y         ; B1 24
            cmp #$2A               ; C9 2A
            beq L4A34              ; F0 EF
            cmp #$3F               ; C9 3F
            beq L4A3B              ; F0 F2
            cmp #$5F               ; C9 5F
            beq L4A3B              ; F0 EE
            cmp #$2E               ; C9 2E
            beq L4A65              ; F0 14
            cmp #$30               ; C9 30
            bcc L4A61              ; 90 0C
            cmp #$3A               ; C9 3A
            bcc L4A3B              ; 90 E2
            cmp #$41               ; C9 41
            bcc L4A61              ; 90 04
            cmp #$5B               ; C9 5B
            bcc L4A3B              ; 90 DA
L4A61       sec                    ; 38
            ror L1C48              ; 6E 48 1C
L4A65       lda #$20               ; A9 20
            jsr L1A11              ; 20 11 1A
            bcc L4A65              ; 90 F9
            ror L1C48              ; 6E 48 1C
            bcc L4A3E              ; 90 CD
            lda (ICBALZ),Y         ; B1 24
            cmp #$2F               ; C9 2F
            bne L4A84              ; D0 0D
            iny                    ; C8
            lda (ICBALZ),Y         ; B1 24
            dey                    ; 88
            cmp #$41               ; C9 41
            bne L4A84              ; D0 05
            ror L16AD              ; 6E AD 16
            iny                    ; C8
            iny                    ; C8
L4A84       cpy L1A24              ; CC 24 1A
L4A87       sty L1A24              ; 8C 24 1A
            php                    ; 08
            beq L4A8E              ; F0 01
            clc                    ; 18
L4A8E       ror L1AFE              ; 6E FE 1A
            lda (ICBALZ),Y         ; B1 24
            plp                    ; 28
            rts                    ; 60
            jsr L0919              ; 20 19 09
            .byte $1A,$9F,$1A,$FA
            ldx #$B9               ; A2 B9
            .byte $E3
            ldy #$02               ; A0 02
L4AA1       lda (ICBALZ),Y         ; B1 24
            cmp #$3A               ; C9 3A
            beq L4A87              ; F0 E0
            dey                    ; 88
            bne L4AA1              ; D0 F7
L4AAA       jsr L10BE              ; 20 BE 10
            stx ICHIDZ,Y           ; 96 20
            .byte $9F,$1A
            sty L1AE8              ; 8C E8 1A
            lsr L16AD              ; 4E AD 16
            jsr L0919              ; 20 19 09
            .byte $22,$E3
            lda L239A,Y            ; B9 9A 23
            bne L4AF4              ; D0 33
            cmp #$3E               ; C9 3E
            bne L4AE0              ; D0 1B
            jsr L0919              ; 20 19 09
            ldx #$CC               ; A2 CC
            lda L22F0,Y            ; B9 F0 22
L4ACD       jsr L150C              ; 20 0C 15
            jsr L1B0C              ; 20 0C 1B
            lda L0E43              ; AD 43 0E
            ora L0E44              ; 0D 44 0E
            beq L4AAA              ; F0 CF
            jsr L1A23              ; 20 23 1A
            bne L4AF4              ; D0 14
L4AE0       cmp #$3C               ; C9 3C
            beq L4ACD              ; F0 E9
L4AE4       lsr L16AD              ; 4E AD 16
L4AE7       ldy #$00               ; A0 00
            cpy #$00               ; C0 00
            rts                    ; 60
L4AEC       jsr L1B01              ; 20 01 1B
            jsr L1A23              ; 20 23 1A
            beq L4AE4              ; F0 F0
L4AF4       cmp #$3E               ; C9 3E
            beq L4AEC              ; F0 F4
            bne L4AE7              ; D0 ED
            jsr L1AB4              ; 20 B4 1A
            lda #$00               ; A9 00
            bmi L4B12              ; 30 11
            lsr L16AD              ; 4E AD 16
            jsr L150C              ; 20 0C 15
            jsr L1DC5              ; 20 C5 1D
            bmi L4AAA              ; 30 9E
            jsr L0919              ; 20 19 09
            ldx #$98               ; A2 98
            lda LBD60,Y            ; B9 60 BD
            rti                    ; 40
            .byte $0F
            bpl L4B12              ; 10 FA
            and #$7F               ; 29 7F
            sta L0F40,X            ; 9D 40 0F
            tay                    ; A8
            jsr L16FE              ; 20 FE 16
            lda L0F46,X            ; BD 46 0F
            pha                    ; 48
            lda L0F43,X            ; BD 43 0F
            tax                    ; AA
            pla                    ; 68
            sec                    ; 38
            sty DUNIT              ; 8C 01 03
            stx DAUX1              ; 8E 0A 03
            sta DAUX2              ; 8D 0B 03
            dex                    ; CA
            bne L4B3B              ; D0 04
            tax                    ; AA
            bne L4B3B              ; D0 01
            tay                    ; A8
L4B3B       ldx #$52               ; A2 52
            lda #$40               ; A9 40
            bcc L4B45              ; 90 04
            ldx L0CF7              ; AE F7 0C
            asl                    ; 0A
L4B45       stx DCOMND             ; 8E 02 03
            sta DSTATS             ; 8D 03 03
            lda L0DE9,Y            ; B9 E9 0D
            sta DBYTLO             ; 8D 08 03
            asl                    ; 0A
            rol                    ; 2A
            eor #$01               ; 49 01
            sta DBYTHI             ; 8D 09 03
            jsr L0919              ; 20 19 09
            .byte $5B
            bvs L4B81              ; 70 23
            asl FMSZPG+4           ; 06 47
            .byte $AE,$23,$00      ; ldx ICSTAZ
            rti                    ; 40
            .byte $43,$43,$04
            sty L30EE              ; 8C EE 30
            .byte $77
L4B6B       rts                    ; 60
            lda L0E48              ; AD 48 0E
            cmp #$10               ; C9 10
            bcs L4B76              ; B0 03
            ldy #$00               ; A0 00
            bit DMASK              ; 2C A0 02
            tya                    ; 98
            pha                    ; 48
            ldx #$FE               ; A2 FE
L4B7C       lda L0E5F,Y            ; B9 5F 0E
            sta L0CE7,X            ; 9D E7 0C
            iny                    ; C8
            inx                    ; E8
            bne L4B7C              ; D0 F6
            jsr L1BAE              ; 20 AE 1B
            jsr L1CA3              ; 20 A3 1C
            jsr L0869              ; 20 69 08
            sbc DOSINI+1           ; E5 0D
L4B91       jsr L1D8A              ; 20 8A 1D
            tax                    ; AA
            and (FMSZPG),Y         ; 31 43
            bne L4B9E              ; D0 05
            jsr L1BAE              ; 20 AE 1B
            bcc L4B91              ; 90 F3
L4B9E       txa                    ; 8A
            eor (FMSZPG),Y         ; 51 43
            sta (FMSZPG),Y         ; 91 43
            jsr L1C2B              ; 20 2B 1C
            jsr L0869              ; 20 69 08
            .byte $5A
            asl L9018              ; 0E 18 90
            .byte $1B
            jsr L0863              ; 20 63 08
            sbc DOSINI+1           ; E5 0D
            lda L0DE5              ; AD E5 0D
            cmp L0E58              ; CD 58 0E
            lda L0DE6              ; AD E6 0D
            sbc L0E59              ; ED 59 0E
            bcc L4B6B              ; 90 AA
            jsr L0869              ; 20 69 08
            sbc DOSINI+1           ; E5 0D
            pla                    ; 68
            pla                    ; 68
            sec                    ; 38
            pla                    ; 68
            tay                    ; A8
            ldx #$FE               ; A2 FE
L4BCD       lda L0CE7,X            ; BD E7 0C
            sta L0E5F,Y            ; 99 5F 0E
            iny                    ; C8
            inx                    ; E8
            bne L4BCD              ; D0 F6
            ldx L0DE5              ; AE E5 0D
            bcc L4BEA              ; 90 0E
            dey                    ; 88
            dey                    ; 88
            beq L4B76              ; F0 96
            ldy #$A2               ; A0 A2
            jmp L10C2              ; 4C C2 10
            lda #$00               ; A9 00
            ldx #$01               ; A2 01
            sec                    ; 38
L4BEA       stx L1C69              ; 8E 69 1C
            sta L1C6E              ; 8D 6E 1C
            php                    ; 08
            ldx #$02               ; A2 02
L4BF3       lda L0F49,X            ; BD 49 0F
            beq L4BFB              ; F0 03
            dec L0F49,X            ; DE 49 0F
L4BFB       dex                    ; CA
            bpl L4BF3              ; 10 F5
            ldx #$02               ; A2 02
L4C00       jsr L110C              ; 20 0C 11
            bne L4C35              ; D0 30
            lda L0F43,X            ; BD 43 0F
            tay                    ; A8
L4C09       cmp L1C69              ; CD 69 1C
            bne L4C35              ; D0 27
            lda L0F46,X            ; BD 46 0F
            cmp L1C6E              ; CD 6E 1C
            bne L4C35              ; D0 1F
            dey                    ; 88
            bne L4C1C              ; D0 03
            tay                    ; A8
            beq L4C5E              ; F0 42
L4C1C       jsr L16FE              ; 20 FE 16
            plp                    ; 28
L4C20       bcs L4C34              ; B0 12
L4C22       ldy FMSZPG+2           ; A4 45
            lda #$00               ; A9 00
L4C26       dey                    ; 88
            sta (FMSZPG),Y         ; 91 43
            bne L4C26              ; D0 FB
            ldx #$00               ; A2 00
            asl L0F40,X            ; 1E 40 0F
            sec                    ; 38
            ror L0F40,X            ; 7E 40 0F
L4C34       rts                    ; 60
L4C35       dex                    ; CA
            bpl L4C00              ; 10 C8
            stx L1C48              ; 8E 48 1C
            inx                    ; E8
            stx L1C57              ; 8E 57 1C
L4C3F       lda L0F40,X            ; BD 40 0F
            beq L4C47              ; F0 03
            lda L0F49,X            ; BD 49 0F
L4C47       cmp #$FF               ; C9 FF
            bcs L4C51              ; B0 06
            sta L1C48              ; 8D 48 1C
            stx L1C57              ; 8E 57 1C
L4C51       inx                    ; E8
            cpx #$03               ; E0 03
            bcc L4C3F              ; 90 E9
            ldx #$00               ; A2 00
            jsr L1B13              ; 20 13 1B
            ldx L1C57              ; AE 57 1C
L4C5E       jsr L16FE              ; 20 FE 16
            lda L0E39              ; AD 39 0E
            sta L0F40,X            ; 9D 40 0F
            tay                    ; A8
            lda #$00               ; A9 00
            sta L0F43,X            ; 9D 43 0F
            lda #$00               ; A9 00
            sta L0F46,X            ; 9D 46 0F
            plp                    ; 28
            bcc L4C22              ; 90 AD
            ldx L1C69              ; AE 69 1C
            clc                    ; 18
            jmp L1B2B              ; 4C 2B 1B
            jsr L0919              ; 20 19 09
            .byte $22
            bcs L4CDD              ; B0 5B
            sta L118A,X            ; 9D 8A 11
            .byte $43
            sta (FMSZPG),Y         ; 91 43
            jsr L0919              ; 20 19 09
            .byte $1C,$2B,$22
            adc LA2D7,Y            ; 79 D7 A2
            dec LA0D5              ; CE D5 A0
            .byte $04
L4C95       lsr L0E60              ; 4E 60 0E
            ror L0E5F              ; 6E 5F 0E
            dey                    ; 88
            bne L4C95              ; D0 F7
            jsr L0863              ; 20 63 08
            .byte $5A
            asl L39AE              ; 0E AE 39
            asl L7E38              ; 0E 38 7E
            jmp L600E              ; 4C 0E 60
            ldx #$0A               ; A2 0A
L4CAD       lda L0E16,X            ; BD 16 0E
            cmp #$3F               ; C9 3F
            beq L4CB7              ; F0 03
            sta L0E27,X            ; 9D 27 0E
L4CB7       dex                    ; CA
            bpl L4CAD              ; 10 F3
            rts                    ; 60
            sec                    ; 38
            bit DSKFMS             ; 24 18
            php                    ; 08
            lsr L0E21              ; 4E 21 0E
            plp                    ; 28
            rol L0E21              ; 2E 21 0E
            rts                    ; 60
            .byte $AB,$34
            dec L00BB              ; C6 BB
            lda L1D1C,X            ; BD 1C 1D
            .byte $1C,$1C,$1C
            tya                    ; 98
            and #$07               ; 29 07
            pha                    ; 48
            tay                    ; A8
            lda L1CC7,Y            ; B9 C7 1C
            sta L1D02              ; 8D 02 1D
            lda L1CCC,Y            ; B9 CC 1C
            sta L1D03              ; 8D 03 1D
            lda L0DFE,Y            ; B9 FE 0D
            sta L1D13              ; 8D 13 1D
            jsr L159C              ; 20 9C 15
            pla                    ; 68
            bne L4CFC              ; D0 0E
            jsr L0919              ; 20 19 09
            .byte $2B
L4CF2       sta (L0097,X)          ; 81 97
            .byte $1A,$23,$2B
            sta (L008C,X)          ; 81 8C
            .byte $AB,$97
            sta (ICHIDZ,X)         ; 81 20
            ora GRACTL             ; 0D 1D D0
L4D00       .byte $3C
L4D01       jsr L1CAA              ; 20 AA 1C
            jsr L139B              ; 20 9B 13
            jsr L1D0D              ; 20 0D 1D
            beq L4D01              ; F0 F5
            rts                    ; 60
L4D0D       jsr L1DBF              ; 20 BF 1D
            bne L4D19              ; D0 07
            lda #$00               ; A9 00
            and L0E21              ; 2D 21 0E
            bne L4D0D              ; D0 F4
L4D19       rts                    ; 60
L4D1A       lda #$24               ; A9 24
            jsr L159E              ; 20 9E 15
            ldx #$0A               ; A2 0A
            lda #$3F               ; A9 3F
L4D23       sta L0E0B,X            ; 9D 0B 0E
            dex                    ; CA
            bpl L4D23              ; 10 FA
            jsr L1DBF              ; 20 BF 1D
            beq L4D40              ; F0 12
            jsr L159C              ; 20 9C 15
            jsr L1DC5              ; 20 C5 1D
            lda L0E21              ; AD 21 0E
            lsr                    ; 4A
            bcc L4D45              ; 90 0B
            ldy #$A4               ; A0 A4
            bit LAAA0              ; 2C A0 AA
            bit LA7A0              ; 2C A0 A7
            jmp L10C2              ; 4C C2 10
L4D45       lda #$10               ; A9 10
            sta L0E21              ; 8D 21 0E
            jsr L139B              ; 20 9B 13
            jsr L0919              ; 20 19 09
            .byte $22
            lda L22BF,Y            ; B9 BF 22
            tya                    ; 98
            lda L0F15,Y            ; B9 15 0F
            lda (KEYDEF,X)         ; A1 79
            lda ICHIDZ,X           ; B5 20
            inc RTCLOK,X           ; F6 12
            beq L4D63              ; F0 03
            jsr L1C7C              ; 20 7C 1C
L4D63       ldy FMSZPG+2           ; A4 45
            dey                    ; 88
            dey                    ; 88
            cpy L0E3F              ; CC 3F 0E
            bne L4D5B              ; D0 EF
            jsr L0919              ; 20 19 09
            .byte $22,$B3
            bcs L4D8F              ; B0 1C
            .byte $7C,$8F
            jmp L00A0              ; 4C A0 00
            lda (FMSZPG),Y         ; B1 43
            iny                    ; C8
            ora (FMSZPG),Y         ; 11 43
            bne L4D5B              ; D0 DC
            jsr L0919              ; 20 19 09
            .byte $22,$BF
            lda L0C95,Y            ; B9 95 0C
            jmp L139E              ; 4C 9E 13
            lda L0DE5              ; AD E5 0D
            ldx L0DE6              ; AE E6 0D
            ldy #$03               ; A0 03
L4D92       pha                    ; 48
            txa                    ; 8A
            lsr                    ; 4A
            tax                    ; AA
            pla                    ; 68
            ror                    ; 6A
            dey                    ; 88
            bne L4D92              ; D0 F7
            jsr L14FD              ; 20 FD 14
            sta L1DBD              ; 8D BD 1D
            txa                    ; 8A
            clc                    ; 18
            adc L0E5D              ; 6D 5D 0E
            tax                    ; AA
            lda #$00               ; A9 00
            adc L0E5E              ; 6D 5E 0E
            jsr L1BE9              ; 20 E9 1B
            lda L0DE5              ; AD E5 0D
            and #$07               ; 29 07
            tay                    ; A8
            lda #$00               ; A9 00
            sec                    ; 38
L4DB8       ror                    ; 6A
            dey                    ; 88
            bpl L4DB8              ; 10 FC
            ldy #$00               ; A0 00
            rts                    ; 60
            lda #$80               ; A9 80
            bit L49A5              ; 2C A5 49
            bit L20A9              ; 2C A9 20
            sta L1DF4              ; 8D F4 1D
            jsr L0919              ; 20 19 09
            ldx #$68               ; A2 68
            cmp (ICHIDZ,X)         ; C1 20
            ora LA209,Y            ; 19 09 A2
            ldx OLDCHR,Y           ; B6 5D
            bit L0E41              ; 2C 41 0E
            bmi L4E19              ; 30 3E
            jsr L13AE              ; 20 AE 13
            bmi L4E19              ; 30 39
            lda L0E21              ; AD 21 0E
            beq L4E19              ; F0 34
            and #$08               ; 29 08
            bne L4DF3              ; D0 0A
            bit L0E4C              ; 2C 4C 0E
            bpl L4DD0              ; 10 E2
            jsr L1E10              ; 20 10 1E
            beq L4DD0              ; F0 DD
L4DF3       lda #$00               ; A9 00
            bmi L4DFE              ; 30 07
            eor L0E21              ; 4D 21 0E
            and #$20               ; 29 20
            bne L4DD0              ; D0 D2
L4DFE       ldx #$0B               ; A2 0B
L4E00       lda L0E0A,X            ; BD 0A 0E
            cmp #$3F               ; C9 3F
            beq L4E0C              ; F0 05
            cmp L0E26,X            ; DD 26 0E
            bne L4DD0              ; D0 C4
L4E0C       dex                    ; CA
            bne L4E00              ; D0 F1
            txa                    ; 8A
L4E10       pha                    ; 48
            jsr L0919              ; 20 19 09
            ldx #$5D               ; A2 5D
            cmp (SAVADR,X)         ; C1 68
            rts                    ; 60
L4E19       lda #$FF               ; A9 FF
            bit L0E4C              ; 2C 4C 0E
            bmi L4E10              ; 30 F0
            tax                    ; AA
            rts                    ; 60
            stx L1ED6              ; 8E D6 1E
            lda ICAX2Z             ; A5 2B
            sta L1EDB              ; 8D DB 1E
            ldy #$22               ; A0 22
            jsr L1ED1              ; 20 D1 1E
            bmi L4E61              ; 30 30
            lda ICHIDZ             ; A5 20
            sta IOCB0,X            ; 9D 40 03
            jsr L1E7D              ; 20 7D 1E
            bmi L4E5C              ; 30 21
            ldy #$98               ; A0 98
            bcc L4E5C              ; 90 1D
            ror L1E4A              ; 6E 4A 1E
L4E42       jsr L1E7D              ; 20 7D 1E
            bmi L4E5C              ; 30 15
            bcs L4E42              ; B0 F9
            lda #$00               ; A9 00
            bpl L4E57              ; 10 0A
            lsr L1E4A              ; 4E 4A 1E
            jsr L0919              ; 20 19 09
            cmp (L0086),Y          ; D1 86
            .byte $42
            cpx #$20               ; E0 20
            .byte $92
            asl LE610,X            ; 1E 10 E6
L4E5C       lda #$FF               ; A9 FF
            sta IOCB0,X            ; 9D 40 03
L4E61       tya                    ; 98
            pha                    ; 48
            ldy #$2D               ; A0 2D
            jsr L1ED1              ; 20 D1 1E
            pla                    ; 68
            tay                    ; A8
            cpy #$88               ; C0 88
            bne L4E91              ; D0 23
            jsr L0919              ; 20 19 09
            .byte $42
            cpx #$4D               ; E0 4D
            .byte $13
            cmp L4D13              ; CD 13 4D
            rol L00A9,X            ; 36 A9
            cpx #$D0               ; E0 D0
            eor ICHIDZ             ; 45 20
            ora L5E09,Y            ; 19 09 5E
            .byte $89,$54,$27,$9E
            cmp #$30               ; C9 30
            ora #$AD               ; 09 AD
            stx BRKKEY             ; 86 11
            and L1187              ; 2D 87 11
            cmp #$FF               ; C9 FF
            tya                    ; 98
L4E91       rts                    ; 60
            jsr L0919              ; 20 19 09
            eor L429C,X            ; 5D 9C 42
            .byte $E2,$5C
            ldx L2754              ; AE 54 27
            .byte $9E
            cmp #$30               ; C9 30
            beq L4EDA              ; F0 38
            ldx #$FE               ; A2 FE
L4EA4       lda L0D18,X            ; BD 18 0D
            sbc L1088,X            ; FD 88 10
            sta L0D53,X            ; 9D 53 0D
            inx                    ; E8
            bne L4EA4              ; D0 F4
            jsr L0863              ; 20 63 08
            eor (APPMHI),Y         ; 51 0E
            jsr L0919              ; 20 19 09
            eor (L0086),Y          ; 51 86
            .byte $54,$27,$9E,$CF
            bmi L4E91              ; 30 D1
            lda #$E2               ; A9 E2
            jsr L1EDA              ; 20 DA 1E
            cld                    ; D8
            ldy #$01               ; A0 01
            rts                    ; 60
            jsr L0919              ; 20 19 09
            ldx #$79               ; A2 79
            .byte $C7
            ldy #$2E               ; A0 2E
            ldx #$00               ; A2 00
            stx FMSZPG+5           ; 86 48
            ldx #$00               ; A2 00
            jmp L0FAC              ; 4C AC 0F
L4EDA       ldx #$00               ; A2 00
            bmi L4E91              ; 30 B3
            sta L1EE2              ; 8D E2 1E
            jmp (RUNAD)            ; 6C E0 02
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
            org $02E0
;
            .word L36E6
;
         
