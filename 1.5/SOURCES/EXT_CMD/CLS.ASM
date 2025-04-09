* BW-DOS 1.5 Command CLS
      blk dos $600
      lda #$00
      tax
      sta $340+$08,X
      sta $340+$09,X
      lda #$0B
      sta $340+$02,X
      lda #$7D
      jmp $E456

      end
