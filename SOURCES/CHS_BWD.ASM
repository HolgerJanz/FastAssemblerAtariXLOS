* Update Check Sum for OS ROM
*  for BW-DOS 1.4
* Use: CHS_BWD rom_file

ztmp  equ $80
zch1  equ $82
zch2  equ $84

CH    equ $2fc

bwdos equ $703
bwver equ $705
bwfl  equ $70f
bwcrn equ $729
bwcfn equ $747

osbuf equ $4000
osbfl equ $4000
osch1 equ $4000
osch2 equ $7FF8

      blk dos $3000
* check for BW-DOS 1.4
      lda #'B'
      cmp bwdos
      bne errbw
      lda #'W'
      cmp bwdos+1
      bne errbw
      lda bwver
      cmp #$14
      bcc errbw
      bcs chkpa
* error no BW-DOS 1.4
errbw lda #$0b
      sta $342
      lda <nobw
      sta $344
      lda >nobw
      sta $345
      lda <nobwl
      sta $348
      lda >nobwl
      sta $349
      ldx #0
      jsr $e456
      rts
* check parameter
chkpa jsr bwcrn
      bne strt
* error no parameter
      lda #$0b
      sta $342
      lda <nofl
      sta $344
      lda >nofl
      sta $345
      lda <nofll
      sta $348
      lda >nofll
      sta $349
      ldx #0
      jsr $e456
      rts
* start checking
* print read message
strt  lda #$0b
      sta $342
      lda <stms
      sta $344
      lda >stms
      sta $345
      lda <stmsl
      sta $348
      lda >stmsl
      sta $349
      ldx #0
      jsr $e456
* close IOCB 1
      jsr clos1
* open IOCB 1
      ldx #$10
      lda #$03
      sta $342,X
      lda <bwcfn
      sta $344,X
      lda >bwcfn
      sta $345,X
      lda #$04
      sta $34a,X
      lda #$00
      sta $34b,X
      jsr $e456
      bpl rdos
cioer tya
      jmp (bwfl)
* read 16k
rdos  ldx #$10
      lda #$07
      sta $342,X
      lda <osbuf
      sta $344,X
      lda >osbuf
      sta $345,X
      lda <osbfl
      sta $348,X
      lda >osbfl
      sta $349,X
      jsr $e456
      bmi cioer
      cpy #$03 ;last btyte?
      beq *+6
      ldy #$89 ;not - truncated record
      bne cioer
* close IOCB
      jsr clos1
* get file check sums
      lda osch1+1
      jsr ch2a
      stx fch1
      sty fch1+1
      lda osch1
      jsr ch2a
      stx fch1+2
      sty fch1+3
      lda osch2+1
      jsr ch2a
      stx fch2
      sty fch2+1
      lda osch2
      jsr ch2a
      stx fch2+2
      sty fch2+3
* print file check sums
      lda #$0b
      sta $342
      lda <fchk
      sta $344
      lda >fchk
      sta $345
      lda <fchkl
      sta $348
      lda >fchkl
      sta $349
      ldx #0
      jsr $e456
* calc check sum 1
      lda #$00
      sta zch1
      sta zch1+1
      sta zch2
      sta zch2+1
      lda <osbuf
      sta ztmp
      lda >osbuf
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
      cmp >osbuf+$2000 ; end at $6000
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
      cmp >osbuf+$3F00
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
* get calc check sums
      lda zch1+1
      jsr ch2a
      stx cch1
      sty cch1+1
      lda zch1
      jsr ch2a
      stx cch1+2
      sty cch1+3
      lda zch2+1
      jsr ch2a
      stx cch2
      sty cch2+1
      lda zch2
      jsr ch2a
      stx cch2+2
      sty cch2+3
* print calc check sums
      lda #$0b
      sta $342
      lda <cchk
      sta $344
      lda >cchk
      sta $345
      lda <cchkl
      sta $348
      lda >cchkl
      sta $349
      ldx #0
      jsr $e456
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
      lda #$0b
      sta $342
      lda <okms
      sta $344
      lda >okms
      sta $345
      lda <okmsl
      sta $348
      lda >okmsl
      sta $349
      ldx #0
      jmp $e456
* ask for update
asup  lda #$0b
      sta $342
      lda <asku
      sta $344
      lda >asku
      sta $345
      lda <askul
      sta $348
      lda >askul
      sta $349
      ldx #0
      jsr $e456
* check keyboard for Y
      lda #$FF
      sta CH
      tax
      cmp CH
      beq *-3
      lda CH
      stx CH
      cmp #$2b
      beq uchs
* abort
      lda #$0b
      sta $342
      lda <abrt
      sta $344
      lda >abrt
      sta $345
      lda <abrtl
      sta $348
      lda >abrtl
      sta $349
      ldx #0
      jsr $e456
      rts
* update check sum in file
* open file for update
uchs  ldx #$10
      lda #$03
      sta $342,X
      lda <bwcfn
      sta $344,X
      lda >bwcfn
      sta $345,X
      lda #$0c
      sta $34a,X
      lda #$00
      sta $34b,X
      jsr $e456
      bpl wros
cioe2 tya
      jmp (bwfl)
* write zch1
wros  ldx #$10
      lda #$0b
      sta $342,X
      lda <zch1
      sta $344,X
      lda >zch1
      sta $345,X
      lda #$02
      sta $348,X
      lda #$00
      sta $349,X
      jsr $e456
      bmi cioe2
* seek zch2
      ldx #$10
      lda #$25
      sta $342,X
      lda #$f8
      sta $34c,X
      lda #$3f
      sta $34d,X
      lda #$00
      sta $34e,X
      jsr $e456
      bmi cioe2
* write zch2
      ldx #$10
      lda #$0b
      sta $342,X
      lda <zch2
      sta $344,X
      lda >zch2
      sta $345,X
      lda #$02
      sta $348,X
      lda #$00
      sta $349,X
      jsr $e456
      bmi cioe2
* close IOCB 1
      jsr clos1
* success message
      lda #$0b
      sta $342
      lda <done
      sta $344
      lda >done
      sta $345
      lda <donel
      sta $348
      lda >donel
      sta $349
      ldx #0
      jsr $e456
* The End
      rts

* close IOCB 1
clos1 ldx #$10
      lda #$0c
      sta $342,X
      jmp $e456

* conv hex A to ATASCII X,Y
ch2a  pha
      lsr @
      lsr @
      lsr @
      lsr @
      sed
      clc
      adc #$90
      adc #$40
      tax
      pla
      and #$0f
      clc
      adc #$90
      adc #$40
      tay
      cld
      rts

nobw  dta b($9b),c'Error - no BW-DOS 1.4',b($9b)
nobwl equ *-nobw

nofl  dta b($9b),c'Error - no OS ROM file specified',b($9b)
nofll equ *-nofl

stms  dta b($9b),c'Read OS ROM file',b($9b)
stmsl equ *-stms

fchk  dta c'File check sums: '
fch1  dta c'xxxx '
fch2  dta c'yyyy',b($9b)
fchkl equ *-fchk

cchk  dta c'Calc check sums: '
cch1  dta c'xxxx '
cch2  dta c'yyyy',b($9b)
cchkl equ *-cchk

okms  dta c'OK',b($9b)
okmsl equ *-okms

asku  dta c'Update check sums in file? (y/n)',b($9b)
askul equ *-asku

abrt  dta c'Abort',b($9b)
abrtl equ *-abrt

done  dta c'Done',b($9b)
donel equ *-done

      end
