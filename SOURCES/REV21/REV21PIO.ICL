* SUBTTL 'Parallel Input/Output'

* GIN - Initialize Generic Parallel Device
GIN  EQU *
* Initialize
     LDA #$01    ;initially select device 0
     STA SHPDVS  ;device select shadow
* For each potential device, initialize if device pre:
GIN1 LDA SHPDVS  ;device select shadow
     STA PDVS    ;device select
     LDA PDID1   ;first ID
     CMP #$80    ;required value
     BNE GIN2    ;if first ID not verified
     LDA PDID2   ;second ID
     CMP #$91    ;required value
     BNE GIN2    ;if second ID not verified
     JSR PDVV+12 ;initialize parallel device handler
GIN2 ASL SHPDVS  ;advance to next device
     BNE GIN1    ;if devices remain
* Exit
     LDA #$00    ;select FPP (deselect device)
*    STA SHPDVS  ;device select shadow
     STA PDVS    ;device select
     RTS

* PIO - Parallel Input/Output
*   Problem: in the CRASS65 section, CRITIC was
*   zero-page.
PIO  EQU *
* Initialize
     LDA #1
     DTA B($8D),A(CRITIC) ; STA.w CRITIC
     LDA DUNIT  ;device unit number
     PHA        ;save device unit number
     LDA PDVMSK ;device selection mask
     BEQ PIO2   ;if no device to select
* For each device, pass request to device I/O routine:
     LDX <TPDL  ;offset to first byte beyond table
PIO1 JSR SNP    ;select next parallel device
     BEQ PIO2   ;if no device selected
     TXA
     PHA        ;save offset
     JSR PDIOV  ;perform parallel device I/O
     PLA        ;saved offset
     TAX        ;restore offset
     BCC PIO1   ;if device did not field request
* Restore Floating Point Package.
     LDA #$00   ;select FPP (deselect device)
     STA SHPDVS ;device select shadow
     STA PDVS   ;device select
     BEQ PIO3   ;exit
*    Perform SIO
PIO2 JSR SIO    ;perform SIO
*    Exit
PIO3 PLA       ;saved device unit number
     STA DUNIT ;restore device unit number
     LDA #0
     DTA B($8D),A(CRITIC) ; STA.w CRITIC
     STY DSTATS
     LDY DSTATS  ;status (re-establish N)
     RTS

* PIR - Handle Parallel Device IRQ
*   Exits via RTI
PIR  EQU     *      
* Determine which device made IRQ, in order of priori:
     LDX <TPDL ;offset to first byte beyond table
PIR1 ROR @
     BCS PIR2  ;if IRQ of that device
     DEX
     BNE PIR1  ;if devices remain
* Select device and process IRQ.
PIR2 LDA SHPDVS   ;current device selection
     PHA          ;save current device select:
     LDA TPDS-1,X ;device selection desired
     STA SHPDVS   ;device select shadow
     STA PDVS     ;device select
     JSR PDIRQV   ;process IRQ
* Exit
     PLA          ;saved device selection
     STA SHPDVS   ;restore device select shad:
     STA PDVS     ;device select
     PLA          ;saved X
     TAX          ;restore X
     PLA          ;restore A
     RTI          ;return

* GOP - Perform Generic Parallel Device OPEN
GOP  EQU *  
     LDY #1  ;offset for OPEN
     JMP EPC ;execute parallel device handler co:

* GCL - Perform Generic Parallel Device CLOSE
GCL  EQU *  
     LDY #3  ;offset for CLOSE
     JMP EPC ;execute parallel device handler co:

* GGB - Perform Generic Parallel Device GET-BYTE
GGB  EQU *  
     LDY #5  ;offset for GET-BYTE
     JMP EPC ;execute parallel device handler co:

* GPB - Perform Generic Parallel Device PUT-BYTE
GPB  EQU *  
     LDY #7  ;offset for PUT-BYTE
     JMP EPC ;execute parallel device handler co:

* GST - Perform Generic Parallel Device STATUS
GST  EQU *  
     LDY #9  ;offset for STATUS
     JMP EPC ;execute parallel device handler co:

* GSP - Perform Generic Parallel Device SPECIAL
GSP  EQU *  
     LDY #11 ;offset for SPECIAL
     JMP EPC ;execute parallel device handler co:

* SNP - Select Next Parallel Device
SNP  EQU *     
* Decrement and check offset.
SNP1 DEX        ;decrement offset
     BPL SNP2   ;if devices remain
* Exit
     LDA #$00   ;select FPP (deselect device)
     STA SHPDVS ;device select shadow
     STA PDVS   ;device select
     RTS        ;return
* Ensure device is indicated by selection mask.
SNP2 LDA PDVMSK ;device selection mask
     AND TPDS,X ;device select
     BEQ SNP1   ;if device not indicated for select:
* Select device.
     STA SHPDVS ;device select shadow
     STA PDVS   ;device select
     RTS

* IPH - Invoke Parallel Device Handler
*   Y = offset into parallel defice vector tabl:
*   PPTMPA  = original A value
*   PPTMPX  = original X value
IPH  EQU *      
     LDA PDVV,Y  ;high routine address-1
     PHA         ;place on stack
     DEY
     LDA PDVV,Y  ;low routine address-1
     PHA         ;place on stack
     LDA PPTMPA  ;restore A for handler
     LDX PPTMPX  ;restore X for handler
     LDY #FNCNOT ;preset status
     RTS         ;invoke handler routine

* EPC - Execute Parallel Device Handler Command
*   Problem: in the CRASS65 version, CRITIC was:
*   zero-page.
EPC  EQU *
* Initialize.
     STA PPTMPA  ;save data byte
     STX PPTMPX  ;save X
     DTA B($AD),A(CRITIC) ;LDA.w CRITIC
     PHA         ;save critical section status
     LDA #1
     DTA B($8D),A(CRITIC) ;STA.w CRITIC
* For each device, pass request to device handler
     LDX <TPDL ;offset to first byte beyond table
EPC1 JSR SNP   ;select next device
     BEQ EPC2  ;if no device selected, return erro:
     TXA
     PHA ;save offset
     TYA
     PHA ;save Y
     JSR IPH  ;invoke parallel device handler
     BCC EPC4 ;if device did not field, try next :
* Clean up
     STA PPTMPA ;save possile data byte
     PLA        ;clean stack
     PLA
     JMP EPC3   ;exit
* Return Nonexistent Device error
EPC2 LDY #NONDEV
* Restore Floating Point Package
EPC3 LDA #$00    ;select FPP (deselect device)
     STA SHPDVS  ;device select shadow
     STA PDVS    ;device select
     PLA         ;saved critical section status
     DTA B($8D),A(CRITIC) ;STA.w CRITIC
     LDA PPTMPA  ;restore possible data byte
     STY PPTMPX
     LDY PPTMPX  ;status (re-establish N)
     RTS
* Prepare to try next device.
EPC4 PLA
     TAY ;restore Y
     PLA
     TAX ;restore X
     BCC EPC1 ;try next device

* TPDS - Table of Parallel Device Selects
TPDS DTA B($80) ;0 device 7 (lowest priority)
     DTA B($40) ;1 device 6
     DTA B($20) ;2 device 5
     DTA B($10) ;3 device 4
     DTA B($08) ;4 device 3
     DTA B($04) ;5 device 2
     DTA B($02) ;6 device 1
     DTA B($01) ;7 device 0 (highest priority)
TPDL EQU *-TPDS ;length
