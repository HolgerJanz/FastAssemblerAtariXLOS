* SUBTTL 'Disk Input/Ouput'

* IDIO - Initialize DIO
IDIO EQU *
     LDA #160    ;160 second timeout
     STA DSKTIM  ;set initial disk timeout
     LDA <DSCTSZ ;disk sector size
     STA DSCTLN
     LDA >DSCTSZ
     STA DSCTLN+1
     RTS

* DIO - Disk I/O
DIO  EQU *
* Initialize
     LDA #DISKID ;disk bus ID
     STA DDEVIC  ;device bus ID
     LDA DSKTIM  ;timeout
     LDX DCOMND  ;command
     CPX #FOMAT
     BEQ DIO1    ;if FORMAT command
     LDA #7      ;set timeout to 7 seconds
DIO1 STA DTIMLO  ;timeout
* Set SIO command
     LDX #GETDAT ;assume GET DATA
     LDA DCOMND  ;command
     CMP #PUTSEC
     BEQ DIO2    ;if PUT SECTOR command
     CMP #WRITE
     BNE DIO3    ;if not WRITE command
DIO2 LDX #PUTDAT ;select PUT DATA
* Check command
DIO3 CMP #STATC
     BNE DIO4  ;if not STATUS command
* Set up STATUS command
     LDA <DVSTAT
     STA DBUFLO ;buffer address
     LDA >DVSTAT
     STA DBUFHI
     LDY <4     ;low byte count
     LDA >4     ;high byte count
     BEQ DIO5   ;perform SIO
* Set up other commands
DIO4 LDY DSCTLN   ;low byte count
     LDA DSCTLN+1 ;high byte count
* Perform SIO
DIO5 STX DSTATS ;SIO command
     STY DBYTLO ;low byte count
     STA DBYTHI ;high byte count
     JSR SIOV   ;vector to SIO
     BPL DIO6   ;if no error
* Process error
     RTS
* Process successful operation
DIO6 LDA DCOMND     ;command
     CMP #STATC
     BNE DIO7       ;if not STATUS command
     JSR SBA        ;set buffer address
     LDY #2
     LDA (BUFADR),Y ;timeout status
     STA DSKTIM     ;disk timeout
* Set byte count
DIO7 LDA DCOMND
     CMP #FOMAT
     BNE DIOA       ;if not FORMAT command
     JSR SBA        ;set buffer address
     LDY #$FE       ;initial buffer pointer
DIO8 INY            ;increment buffer pointer
     INY            ;increment buffer pointer
DIO9 LDA (BUFADR),Y ;low bad sector data
     CMP #$FF
     BNE DIO8       ;if low not $FF
     INY
     LDA (BUFADR),Y ;high bad sector data
     INY
     CMP #$FF
     BNE DIO9       ;if high not $FF
     DEY
     DEY
     STY DBYTLO     ;low bad sector byte count
     LDA #0
     STA DBYTHI     ;high bad sector byte count
* Exit
DIOA LDY DSTATS ;status
     RTS

* SBA - Set Buffer Address
SBA  EQU *
     LDA DBUFLO
     STA BUFADR  ;buffer address
     LDA DBUFHI
     STA BUFADR+1
     RTS
