; Example batch file
; configure ramdisk and clock
IF
Install IDE+2 clock?
IDEP2TD.SYS
ELSE
IF
Install APE compatible clock?
CLOCK.SYS ON
APETIME
ELSE
IF
Install RTIME8 clock?
RTIME8.SYS
ELSE
IF
Install software clock?
CLOCK.SYS ON
DATE
TIME
ENDIF
IF
Install ramdisk?
RAMDISK.SYS 8E
ENDIF
