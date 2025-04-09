* convert hex to atascii
*   hex A -> atascii X,Y
_convh2a sed
         pha
         and #$0f
         clc
         adc #$90
         adc #$40
         tay
         pla
         lsr @
         lsr @
         lsr @
         lsr @
         clc
         adc #$90
         adc #$40
         cld
         tax
         rts
