* SUBTTL 'Peripheral Handler Loading Facility, Part 3'

* PHR - Perform Peripheral Handler Loading Initializa:
* Performs Power-up Polling, with Handler loading a:
* and Initialization;
* Performs System Reset Re-initialization of all ha:
* Input Parameters:
*   WARMST (used to distinguish Cold and Warm Start).
* Output Parameters:
*   None.
* Modified:
*   Registers are not saved;
*   All kinds of side effects when any handler is loade:
*   (potentially MEMLO, DVSTAT thru DVSTAT+3, the DCB,
*   CHLINK, ZCHAIN, TEMP1, TEMP2, TEMP3.    This list m:
*   not be complete.).
PHR  EQU *
* Check for coldstart
     LDA WARMST ;warmstart flag
     BEQ PHR2   ;if coldstart
* Process warmstart
     LDA <[CHLINK-18]
     STA ZCHAIN
     LDA >[CHLINK-18]
     STA ZCHAIN+1
* Check next link
PHR1 LDY #18 ;offset to link
     CLC
     LDA (ZCHAIN),y ;low link
     TAX
     INY
     ADC (ZCHAIN),Y ;high link
     BEQ PHR4 ;if forward link null
* Re-initialize peripheral handler
     LDA (ZCHAIN),Y ;high link
     STA ZCHAIN+1
     STX ZCHAIN
     JSR CLT  ;checksum linkage table
     BNE PHR4 ;if checksum bad
     JSR PHW  ;re-initialize peripheral h:
     BCS PHR4 ;if error
* Continue with next handler
     BCC PHR1 ;continue with next handler
* Process coldstart
PHR2 LDA #0
     STA CHLINK ;clear chain link
     STA CHLINK+1
     LDA #$4F ;send POLL RESET poll
     BNE PHR7
* Perform type 3 poll
PHR3 LDA #0
     TAY
     JSR PHPP
     BPL PHR5 ;if poll answered
* Exit
PHR4 RTS
* Process answered poll
PHR5 CLC
     LDA MEMLO
     ADC DVSTAT
     STA TEMP1
     LDA MEMLO+1
     ADC DVSTAT+1
     STA TEMP1+1 ;(TEMP2 := MEMLO + handler :
     SEC
     LDA MEMTOP
     SBC TEMP1
     LDA MEMTOP+1
     SBC TEMP1+1 ;(subtract MEMTOP)
     BCS PHR8    ;if room to load
* Prepare for another poll
PHR6 LDA #$4E
* following any load or init:
* prepare for another Type 3:
* sending a "special" load c:
* serial port.
* Poll:
PHR7 TAY ;Send either "special" load:
     JSR PHPP
     JMP PHR3 ;go poll again
* Load peripheral handler
PHR8 LDA DVSTAT+2 ;call the loader
     LDX MEMLO
     STX DVSTAT+2 ;(Parameter = load address)
     LDX MEMLO+1
     STX DVSTAT+3
     JSR LPH  ;load peripheral handler
     BMI PHR6 ;if load error, poll again
     SEC      ;Call for initialize new ha:
     JSR PHC  ;(Parameter = add size to M:
     BCS PHR6 ;if init error, poll again
     BCC PHR3 ;poll again normally

* PHPP - Perform Poll
* Polling subroutine calls SIO for Type 3 or 4 Poll.
* Input Parameters:
*   A Value for AUX1
*   Y Value for AUX2
* Output Parameters:
*   Y SIO status from poll
*   DVSTAT: Device minimum size (low), if poll answered
*   DVSTAT+1: Device minimum size (high), if poll answe:
*   DVSTAT+2: Device address for loading, if poll answe:
*   DVSTAT+3: Device version number, if poll answered
* Modified:
*   The registers are not saved;
* Subroutines called:
*   SIO (performs poll and returns to PHP's caller).
PHPP EQU *
* Initialize
     PHA ;save parameter
* Set up DCB
     LDX <PHPL-1 ;offset to last byte of DCB:
PHP1 LDA PHPA,X ;byte of DCB data
     STA DCB,X ;byte of DCB
     DEX
     BPL PHP1 ;if not done
* Set parameters in DBC auxiliary bytes
     STY DAUX2
     PLA
     STA DAUX1
* Perform SIO
     JMP SIOV ;vector to SIO, return

* DCB Poll Request Data
PHPA DTA B($4F) ;device bus ID
     DTA B(1)   ;unit number
     DTA B('@') ;type 3 or 4 poll command
     DTA B($40) ;I/O direction
     DTA A(DVSTAT) ;buffer
     DTA B(30) ;timeout
     DTA B(0)
     DTA A(4) ;buffer length
PHPL EQU *-PHPA ;length

* LPH - Load Peripheral Handler
* This subroutine calls the relocating loader to load
* a handler from a peripheral.
* Input Parameters:
*   A       Peripheral serial address for load;
*   DVSTAT+2: Load address (low)
*   DVSTAT+3: Load address (high)
* Output Parameters:
*   From the relocating loader.
* Modified:
*   TEMP1, TEMP2, TEMP3,
*   DVSTAT+3, DVSTAT+3 (forced even),
*   Relocating loader variables and parameters,
*   Registers not saved;
* Subroutines called:
* RLR (relocating loader).
LPH  EQU *
* Initialize
     STA TEMP2 ;save peripheral address
     LDX #0
     STX TEMP1 ;set starting block number
     DEX
     STX TEMP3 ;set starting byte number
* Ensure load address even
     LDA DVSTAT+2 ;low load address
     ROR @
     BCC LPH1     ;if even
     INC DVSTAT+2 ;increment low load address
     BNE LPH1     ;if no carry
     INC DVSTAT+3 ;increment high load address
* Set up relocating loader parameters
LPH1 LDA DVSTAT+2        ;load address
     STA LOADAD
     LDA DVSTAT+3
     STA LOADAD+1
     LDA <PHG ;get-byte routine address
     STA GBYTEA
     LDA >PHG
     STA GBYTEA+1
     LDA #$80 ;loader page zero load addr:
     STA ZLOADA
* Relocate routine
     JMP RLR ;relocate routine, return

* PHG - Perform Peripheral Handler GET-BYTE
* Get a byte subroutine for relocating loader passes
* bytes from peripheral to relocating loader via
* cassette buffer. Calls GNL each time new
* buffer is needed.
* Input Parameters:
*   TEMP1: Next block number;
*   TEMP2: Peripheral address (for GNL);
*   TEMP3: Next byte number (index to CASBUF).
* Output Parameters (for relocating loader):
*   Carry bit indicates error;
*   A  Next byte, if no error.
* Modified:
*   Cassette buffer CASBUF;
*   TEMP3;
*   X, Y not saved.
* Subroutines called:
*   GNL, which calls SIO to get load records.
PHG  EQU *
* Check for another byte in buffer
     LDX TEMP3
     INX
     STX TEMP3
     BEQ PHG2 ;if empty, load next block
* Retrieve next byte
PHG1 LDX TEMP3
     LDA CASBUF-$80,X
     CLC ;indicate no error
     RTS
* Load next block and retrieve next byte
PHG2 LDA <0-128 ;offset to first byte
     STA TEMP3
     JSR GNL   ;get next load block
     BPL PHG1  ;if no error, retrieve next byte
* Process error
     SEC ;indicate error
     RTS

* GNL - Get Next Load Block
* Subroutine to get a load block from the peripheral
* Input Parameters:
*   TEMP1: Block number
*   Output Parameters (for relocating loader):
*   Negative bit is set by SIO if I/O error occurs
* Modified:
*   TEMP1;
*   the DCB (SIO);
*   Registers not saved
* Subroutines called:
*   SIO
GNL  EQU *
* Set up DCB
     LDX <GNLAL-1 ;offset to last DCB data by:
GNL1 LDA GNLA,X ;byte of DCB data
     STA DCB,X  ;byte of DCB
     DEX
     BPL GNL1   ;if not done
* Set DCB parameters
     LDX TEMP1  ;block number
     STX DAUX1  ;auxiliary 1
     INX
     STX TEMP1  ;next block number
     LDA TEMP2  ;device address
     STA DDEVIC ;device bus ID
* Perform SIO
     JMP SIOV

* DCB Data
GNLA DTA B($00)    ;dummy device bus ID
     DTA B(1)      ;dummy unit number
     DTA B('&')    ;load command
     DTA B($40)    ;I/O direction
     DTA A(CASBUF) ;buffer
     DTA B(30)     ;timeout
     DTA B(0)
     DTA A(128)    ;buffer length
     DTA B(0)      ;auxiliary 1
     DTA B(0)      ;auxiliary 2
GNLAL EQU *-GNLA  ;length

* SHC - Search Handler Chain
* Forward chain search searches for pointer to handle:
* table whose address matches caller's parameter. If :
* parameter is zero, this routine looks for the point:
* the final linkage table since this table's forward :
* is zero (null.
* Input Parameters:
*   A Linkage table address to match (High)
*   Y Linkage table address to match (Low)
* Output Parameters:
*   ZCHAIN points to linkage whose forward pointe:
*     contains the match (if match is found);
*     if the match is found just following the li:
*     chain base CHLINK, then ZCHAIN points to CH:
*     minus 18;
*   If match successful, A (High) and X (Low) contain
*     matched address (equiv. to A and Y parms.);
*   Carry bit is set to indicate no match or checksum v:
*     along the chain. [Note: the linkage table p:
*     to by ZCHAIN upon return is not checksum ch:
* Modified:
*   TEMP1, TEMP2, ZCHAIN;
*   The registers are not saved.
* Subroutines called:
*   CLT
SHC  EQU * 
* Initialize
     STY TEMP1
     STA TEMP1+1
     LDA <[CHLINK-18]
     STA ZCHAIN ;start ZCHAIN at proper off:
     LDA >[CHLINK-18]
     STA ZCHAIN+1
* Check for match
SHC1 LDY #18
     LDA (ZCHAIN),Y
     TAX ;low chain pointer
     INY
     LDA (ZCHAIN),Y ;high chain pointer
     CMP TEMP2 ;check for match with param:
     BNE SHC2  ;if no match
     CPX TEMP1
     BNE SHC2  ;if no match
* Exit
     CLC ;indicate match
     RTS ;return
* Check for end of chain
SHC2 CMP #0   ;end of chain indicator
     BNE SHC4 ;if not end of chain
     CPX #0
     BNE SHC4 ;if not end of chain
* Process end of chain or checksum error
SHC3 SEC ;return error (checksum or end)
     RTS
* Set link to new linkage table
SHC4 STX ZCHAIN  ;link to new linkage table
     STA ZCHAIN+1
     JSR CLT  ;checksum linkage table
     BNE SHC3 ;if error
* Continue searching chain
     BEQ SHC1 ;continue searching chain

* PHW - Perform Peripheral Handler Warmstart Initiali:
* PHC is the main entry. This performs full initializ:
*   including adding the new linkage table into:
*   table chain;
* PHW does all initialization except adding to the li:
*   table chain (intended for warm start reinit:
* PHI is the full initialization entry for calling
*   init from outside the OS.
* The code does the following:
* 1) Links new handler to end of chain;
* 2) Calls handler init subroutine in handler;
* 3) If 2 failed, unlinks handler from chain,
*    and returns with carry;
* 4) Else, conditionally zeroes handler size ent:
*    handler linkage table (per parameter);
* 5) Adds handler size entry (possibly zeroed) t:
* 6) If handler size entry is nonzero, MEMLO is :
*    forced even;
* 7) Calculates and enters linkage table checksu:
* 8) Returns with carry clear.
* PHC is called by PHR when loading handlers at cold
*   initialization;and by PHL when loading a ha:
*   application request under CIO;
* PHW is called by PHR to reinitialize a handler duri:
*   warm-start;
* PHI is vectored by OS vector at $E49E and is intend:
*   for use by system-level applications which :
*   handlers (ie., AUTORUN.SYS handler loader, :
* Input Parameters:
* PHC:
*   DVSTAT, DVSTAT+1 contain handler size (for
*   handler init, not used by this routine);
*   DVSTAT+2, DVSTAT+3 contain handler linkage :
*   address.
* PHW:
*   DVSTAT+2, DVSTAT+3 same;
*   DVSTAT, DVSTAT+1 undefined.
* PHI:
*   A and Y contain handler linkage table addre:
*   they are copied into DVSTAT+3 and DVSTAT+2;
*   DVSTAT, DVSTAT+1 may or may not be signific:
*   any concern about these are up to the progr:
*   of the peripheral handler init routine and :
*   is making use of the non-OS-caller entry PH:
* For PHI and PHC, the Carry bit specifies whether
*   the handler size entry of the linkage table:
*   be zeroed prior to adding to MEMLO: Carry s:
*   do NOT zero this entry.
* Output Parameters:
*   Carry indicates error (initialization failed);
*   The registers are not saved.
* Modified:
*   DVSTAT+2, DVSTAT+3 are modified by PHI;
*   ZCHAIN, TEMP1, TEMP2;
*   MEMLO, MEMLO+1 conditionally incremented by handler:
* Subroutines called:
*   SHC (to find end of linkage table chain);
*   PHU (to unlink handler if init. error);
*   CLT (to insert linkage table checksum);
*   loaded handler's INIT entry.
PHW  EQU *
     SEC ;indicate not zeroing handler size
     PHP
     BCS PHQ ;initialize handler and update MEML:

* PHI - Perform Peripheral Handler Initialization wit:
PHI  EQU *
     STA DVSTAT+3
     STY DVSTAT+2
*    JMP PHC ;perform coldstart initiali:

* PHC - Perform Peripheral Handler Coldstart Initiali:
PHC  EQU *
* Initialize
     PHP
* Search for end of chain
     LDA #0   ;indicate searching for end of chai:
     TAY
     JSR SHC  ;search handler chain
     BCS PHQ1 ;if error, exit
* Enter at end of chain
     LDY #18        ;offset
     LDA DVSTAT+2
     STA (ZCHAIN),Y ;low link
     TAX
     INY
     LDA DVSTAT+3
     STA (ZCHAIN),Y ;high link
     STX ZCHAIN     ;link to new table
     STA ZCHAIN+1
     LDA #0         ;indicate end of chain
     STA (ZCHAIN),Y ;low link
     DEY
     STA (ZCHAIN),Y ;high link
* Initialize handler
*    JMP PHQ ;initialize handler, return

* PHQ - Initialize Handler and Update MEMLO
PHQ  EQU *
* Initialize handler
     JSR PHX  ;initialize handler
     BCC PHQ2 ;if no error
* Process error
     LDA DVSTAT+3
     LDY DVSTAT+2
     JSR PHU ;unlink handler
* Exit, indicating error
PHQ1 PLP ;fix stack
     SEC ;indicate error
     RTS
* Check for zeroing handler size
PHQ2 PLP
     BCS PHQ3 ;if not zero
* Zero handler size
     LDA #0
     LDY #16        ;offset
     STA (ZCHAIN),Y ;zero size
     INY
     STA (ZCHAIN),Y
* Increase MEMLO by size
PHQ3 CLC
     LDY #16        ;offset to size
     LDA MEMLO
     ADC (ZCHAIN),Y ;add low size
     STA MEMLO      ;new low MEMLO
     INY
     LDA MEMLO+1
     ADC (ZCHAIN),Y ;add high size
     STA MEMLO+1    ;new high MEMLO
* Pu checksum in linkage table
     LDY #15 ;offset to checksum
     LDA #0
     STA (ZCHAIN),Y ;clear checksum
     JSR CLT ;checksum linkage table
     LDY #15 ;offset to checksum
     STA (ZCHAIN),Y ;checksum
* Exit
     CLC ;indicate success
     RTS ;return

* PHX - Initialize Handler
PHX  EQU *
     CLC
     LDA ZCHAIN
     ADC #12
     STA TEMP1   ;low handler initialization:
     LDA ZCHAIN+1
     ADC #0
     STA TEMP1+1 ;high handler initializatio:
     JMP (TEMP1) ;initialize handler, return
