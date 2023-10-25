* SUBTTL 'Peripheral Handler Loading Facility, Part 2'

* CLT - Checksum Linkage Table
* ENTRY   JSR CLT
*   ZCHAIN = ZCHAIN+1 = address of linkage tabl:
* EXIT
*   A = checksum of linkage table
* CHANGES
*   Y
* CALLS
*   -none-
CLT  EQU *
     LDY #17 ;offset to last byte to sum
     LDA #0  ;initial sum
     CLC
CLT1 ADC (ZCHAIN),Y ;add byte
     DEY
     BPL CLT1 ;if not done
     ADC #0   ;add final carry
     EOR #$FF ;complement
     RTS      ;return
