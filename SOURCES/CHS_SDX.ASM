* Update Check Sum for XL OS ROM
*  for SpartaDOS X
* Use: CHS_SDX rom_file

PRINTF   smb 'PRINTF'
U_GETPAR smb 'U_GETPAR'
U_GETKEY smb 'U_GETKEY'
U_FAIL   smb 'U_FAIL'
FOPEN    smb 'FOPEN'
FCLOSE   smb 'FCLOSE'
FREAD    smb 'FREAD'
FWRITE   smb 'FWRITE'
FILELENG smb 'FILELENG'
FSEEK    smb 'FSEEK'

FHANDLE equ $760
FMODE   equ $778
FAUX1   equ $782
FAUX2   equ $783
FAUX3   equ $784
FAUX4   equ $785
FAUX5   equ $786

ztmp  equ $80
zch1  equ $82
zch2  equ $84

CH    equ $2fc

osbfl equ $4000
osco2 equ $3ff8

      blk reloc main
* check parameter
      jsr U_GETPAR
      bne strt
* error no parameter
      jsr PRINTF
      dta b($9b),c'Error - no OS ROM file specified',b($9b,0)
      rts
* start checking
* print read message
strt  jsr PRINTF
      dta b($9b),c'Read OS ROM file',b($9b,0)
* open IOCB 1
      lda #$04
      sta FMODE
      jsr FOPEN
* check length
      jsr FILELENG
      lda <osbfl
      cmp FAUX1
      bne errtr
      lda >osbfl
      cmp FAUX2
      bne errtr
      lda #$00
      cmp FAUX3
      bne errtr
      beq rdfl
errtr lda #$89 ; error trancated record
      jsr U_FAIL
* read 16k
rdfl  lda osbfv
      sta FAUX1
      lda osbfv+1
      sta FAUX2
      lda <osbfl
      sta FAUX4
      lda >osbfl
      sta FAUX5
      jsr FREAD
      bpl *+7
      lda #$88
      jsr U_FAIL
* close IOCB
      jsr FCLOSE
* print file check sums
      jsr PRINTF
      dta c'File check sums: %4x %4x',b($9b,0)
      dta v(osch1,osch2)
* calc check sum 1
      lda #$00
      sta zch1
      sta zch1+1
      sta zch2
      sta zch2+1
      lda osbfv
      sta ztmp
      lda osbfv+1
      sta ztmp+1
      ldy #$02 ; start at $4002
cch1l lda (ztmp),Y
      clc
      adc zch1
      sta zch1
      bcc *+4
      inc zch1+1
      iny
      bne cch1l
      inc ztmp+1
      lda ztmp+1
      cmp osbv2+1
      bcc cch1l
* calc check sum 2
cch2l lda (ztmp),Y
      clc
      adc zch2
      sta zch2
      bcc *+4
      inc zch2+1
      iny
      bne *+6
      inc ztmp+1
      bne cch2l
      cpy #$F8
      bne cch2l
      lda ztmp+1
      cmp osbv3+1
      bcc cch2l
* calc check sum 2 second part
      iny
      iny
cch22 lda (ztmp),Y
      clc
      adc zch2
      sta zch2
      bcc *+4
      inc zch2+1
      iny
      bne cch22
* print calc check sums
      jsr PRINTF
      dta c'Calc check sums: %4x %4x',b($9b,0)
      dta a(zch1,zch2)
* compare check sums file with calc
      lda osch1
      cmp zch1
      bne asup
      lda osch1+1
      cmp zch1+1
      bne asup
      lda osch2
      cmp zch2
      bne asup
      lda osch2+1
      cmp zch2+1
      bne asup
* write OK
      jsr PRINTF
      dta c'OK',b($9b,0)
      rts
* ask for update
asup  jsr PRINTF
      dta c'Update check sums in file? (y/n)',b($9b,0)
* check keyboard for Y
      jsr U_GETKEY
      cmp #'Y'
      beq uchs
* abort
      jsr PRINTF
      dta c'Abort',b($9b,0)
      rts
* update check sum in file
* open file for update
UCHS  lda #$0c
      sta FMODE
      jsr FOPEN
* write zch1
      lda <zch1
      sta FAUX1
      lda >zch1
      sta FAUX2
      lda #$02
      sta FAUX4
      lda #$00
      sta FAUX5
      jsr FWRITE
* seek to chk2      
      lda <osco2
      sta FAUX1
      lda >osco2
      sta FAUX2
      lda #$00
      sta FAUX3
      jsr FSEEK
* write zch2
      lda <zch2
      sta FAUX1
      lda >zch2
      sta FAUX2
      lda #$02
      sta FAUX4
      lda #$00
      sta FAUX5
      jsr FWRITE
* close file
      jsr FCLOSE
* success message
      jsr PRINTF
      dta c'Done',b($9b,0)
* The End
      rts


osbfv dta v(osbuf)
osbv2 dta v(osbuf+$2000)
osbv3 dta v(osbuf+$3f00)

osbuf equ *
osch1 equ *
osch2 equ *+osco2

      blk empty osbfl main

      blk update addresses
      blk update symbols

      end
