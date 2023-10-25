* SUBTTL 'Peripheral Handler Loading Facility, Part 4'

* PHU - Perform Peripheral Handler Unlinking
* Handler entry unlinking routine. This routine is ca:
* by the OS handler initialization to unlink a handle:
* initialization fails, or by the handler itself if i:
* the handler unload feature.     This routine is ent:
* OS vector at $E49B.
* Input Parameters:
*   A Address of linkage table to unlink (High);
*   Y Address of linkage table to unlink (Low).
*   COLDST: Tested to see if PHU is called during cold :
*   if so, chain entry is unlinked even if at M:
* Output Parameters:
*   Carry is set to indicate error;in this case,
*   no unlinking has occurred.
* Modified:
*   TEMP1, TEMP2;
*   ZCHAIN,ZCHAIN+1;
* The forward chain pointer in the precedessor of the:
* table being removed is modified to point to the suc:
* of the removed table if the removal is successful--
* this forward chain pointer may be CHLINK, CHLINK+1.
* The registers are not saved.
* Subroutines called:
*   SHC, CLT.
PHU  EQU *
* Search handler chain
     JSR SHC  ;search handler chain
     BCS PHU3 ;if error
* Perform unlinking
     TAY        ;(save return parameter)
     LDA ZCHAIN ;save ZCHAIN (points to pre:
     PHA
     LDA ZCHAIN+1
     PHA
     STX ZCHAIN   ;make ZCHAIN point to linka:
     STY ZCHAIN+1 ;to be removed
     LDA COLDST   ;coldstart flag
     BNE PHU1     ;if coldstart, unconditional:
     LDY #16 ;check if loaded at MEMLO..:
     CLC     ;by checking if size is non:
     LDA (ZCHAIN),Y
     INY
     ADC (ZCHAIN),Y
     BNE PHU2 ;if handler size non-zero
     JSR CLT  ;checksum linkage table
     BNE PHU2 ;if checksum nonzero, bad c:
PHU1 LDY #18  ;take link from table being:
     LDA (ZCHAIN),Y
     TAX
     INY
     LDA (ZCHAIN),Y
     TAY
     PLA ;Make ZCHAIN point to the predecess:
     STA ZCHAIN+1
     PLA
     STA ZCHAIN
     TYA     ;And put forward link from table be:
     LDY #19 ;removed into its predecessors link:
     STA (ZCHAIN),Y
     DEY
     TXA
     STA (ZCHAIN),Y
     CLC ;indicate success
     RTS
* Clean stack and process error
PHU2 PLA ;Error return--restore stack
     PLA
* Process error
PHU3 SEC ;indicate error
     RTS
