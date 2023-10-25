* SUBTTL 'Self-test, Part 4'

* VFR - Verify First 8K ROM
* C clear, if verified
*   set, if not verified
VFR  EQU *
* Initialize
     LDX #0    ;offset to first region to checksum
     STX STCHK ;initial sum is zero
     STX STCHK+1
* Checksum ROM
VFR1 JSR CRR  ;checksum region of ROM
     CPX #12
     BNE VFR1 ;if not done
* Compare result
     LDA $C000 ;low checksum in ROM
     LDX $C001 ;high checksum in ROM
*    JMP VCS   ;verify checksum, return

* VCS - Verify Checksum
VCS  EQU *
     CMP STCHK   ;low checksum
     BNE VCS1    ;if low checksum bad
     CPX STCHK+1 ;high checksum
     BNE VCS1    ;if high checksum bad
     CLC ;indicate verified
     RTS ;return
VCS1 SEC ;indicate not verified
     RTS

* VSR - Verify Second 8K ROM
* C clear, if verified
*   set, if not verified
VSR  EQU *
     LDX #0
     STX STCHK ;initial sum is zero
     STX STCHK+1
     LDX #12   ;offset to first region to checksum
     JSR CRR   ;checksum region of ROM
     JSR CRR   ;checksum region of ROM
     LDA $FFF8 ;low checksum from ROM
     LDX $FFF9 ;high checksum from ROM
     JMP VCS   ;verify checksum, return

* CRR - Checksum Region of ROM
* X = offset
CRR  EQU *
* Transfer range addresses
     LDY #0
CRR1 LDA TARV,X
     STA STADR1,Y
     INX
     INY
     CPY #4   ;4 bytes for 2 addresses
     BNE CRR1 ;if not done
* Checksum range
     LDY #0
CRR2 CLC
     LDA (STADR1),Y
     ADC STCHK
     STA STCHK
     BCC CRR3    ;if low value non-zero
     INC STCHK+1 ;adjust high value
CRR3 INC STADR1  ;advance address
     BNE CRR4    ;if low address non-zero
     INC STADR1+1        ;adjust high address
CRR4 LDA STADR1  ;current address
     CMP STADR2  ;end of range
     BNE CRR2    ;if not done
     LDA STADR1+1
     CMP STADR2+1
     BNE CRR2    ;if not done
     RTS

* TARV - Table of Address Ranges to Verify
TARV DTA A($C002,$D000) ;first 8K ROM, $C002 - $CFFF
     DTA A($5000,$5800) ;first 8K ROM, $D000 - $D7FF
     DTA A($D800,$E000) ;first 8K ROM, $D800 - $DFFF
     DTA A($E000,$FFF8) ;second 8K ROM, $E000 - $FFF7
     DTA A($FFFA,$0000) ;second 8K ROM, $FFFA - $FFFF
