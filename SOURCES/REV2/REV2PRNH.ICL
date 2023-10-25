* SUBTTL 'Printer Handler'

* PIN - Initialize Printer
PIN  EQU *
     LDA #30    ;30 second timeout
     STA PTIMOT ;printer timeout
     RTS

* Printer Handler Address Data
PSTB DTA A(DVSTAT) ;status buffer address
PPRB DTA A(PRNBUF) ;printer buffer address

* PST - Perform Printer STATUS
PST  EQU *
PSTV EQU *-1
     LDA #4     ;4 bytes for status
     STA PBUFSZ ;buffer size
     LDX PSTB   ;address of status buffer
     LDY PSTB+1
     LDA #STATC ;status command
     STA DCOMND ;command
     STA DAUX1
     JSR SDP  ;set up DCB for printer
     JSR SIOV ;vector to SIO
     BMI PSP  ;if error, return
     JSR STS  ;set printer timeout from status
*    JMP PSP  ; return

* PSP - Perform Printer SPECIAL
* does nothing.
PSP  EQU *
PSPV EQU *-1
     RTS

* POP - Perform Printer OPEN
POP  EQU *
POPV EQU *-1
     JSR PST ;perform printer STATUS
     LDA #0
     STA PBPNT ;clear pointer buffer pointer
     RTS

* PPB - Perform Printer PUT-BYTE
PPB  EQU *
PPBV EQU *-1
* Initialize
     PHA         ;save data
     LDA ICDNO,X ;device number
     STA ICDNOZ  ;device number
     JSR PPM     ;process print mode
* Put data in buffer
     LDX PBPNT    ;printer buffer pointer
     PLA          ;saved data
     STA PRNBUF,X ;put data in buffer
     INX
* Check for buffer full
     CPX PBUFSZ ;printer buffer size
     BEQ PPP    ;if buffer full, perform PUT
* Update printer buffer pointer
     STX PBPNT ;printer buffer pointer
* Check for EOL
     CMP #EOL
     BEQ PPB1 ;if EOL, space fill
* Exit
     LDY #SUCCES
     RTS
* Space fill buffer
PPB1 LDA #' ' ;indicate space fill
*    JMP FPB  ;fill printer buffer, retur:

* FPB - Fill Printer Buffer
FPB  EQU *
* Fill printer buffer
FPB1 STA PRNBUF,X ;byte of printer buffer
     INX
     CPX PBUFSZ ;printer buffer size
     BNE FPB1   ;if not done
* Perform printer PUT
*    JMP PPP ;perform printer PUT, retur:

* PPP - Perform Printer PUT
PPP  EQU *
* Clear printer buffer pointer
     LDA #0
     STA PBPNT ;clear printer buffer pointer
* Set up DCB
     LDX PPRB ;address of printer buffer
     LDY PPRB+1
     JSR SDP  ;set up DCB for printer
* Perform PUT
     JMP SIOV ;vector to SIO, return

* PCL - Perform Printer CLOSE
PCL  EQU *
PCLV EQU *-1
* Initialize
     JSR PPM ;process print mode
* Check buffer pointer
     LDA #EOL  ;indicate EOL fill
     LDX PBPNT ;printer buffer pointer
     BNE FPB   ;if buffer pointer non-zero, fill buffer
* Exit
     LDY #SUCCES
     RTS

* SDP - Set Up DCB for Printer
SDP  EQU *
     STX DBUFLO ;low buffer address
     STY DBUFHI ;high buffer address
     LDA #PDEVN ;printer device bus ID
     STA DDEVIC ;device bus ID
     LDA ICDNOZ ;device number
     STA DUNIT  ;unit number
     LDA #$80   ;SIO WRITE command
     LDX DCOMND ;I/O direction
     CPX #STATC ;STATUS command
     BNE SDP1   ;if STATUS command
     LDA #$40   ;SIO READ command
SDP1 STA DSTATS ;SIO command
     LDA PBUFSZ
     STA DBYTLO ;low buffer size
     LDA #0
     STA DBYTHI ;high buffer size
     LDA PTIMOT
     STA DTIMLO ;device timeout
     RTS

* STS - Set Printer Timeout from Status
STS  EQU *
     LDA DVSTAT+2 ;timeout
     STA PTIMOT   ;set printer timeout
     RTS

* PPM - Process Print Mode
* sets up the DCB according to the print mode.
PPM  EQU *
* Initialize
     LDY #WRITE ;WRITE command
     LDA ICAX2Z ;print mode
* Determine buffer size
PPM1 CMP #NORMAL ;NORMAL mode
     BNE PPM2    ;if not NORMAL mode
     LDX #NBUFSZ ;NORMAL mode buffer size
     BNE PPM4    ;set buffer size
PPM2 CMP #DOUBLE ;DOUBLE mode
     BNE PPM3    ;if not DOUBLE mode
     LDX #DBUFSZ ;DOUBLE mode buffer size
     BNE PPM4    ;set buffer size
PPM3 CMP #SIDWAY ;SIDEWAYS mode
     BNE PPM5    ;if not SIDEWAYS mode, assume NORMAL
     LDX #SBUFSZ ;SIDEWAYS mode buffer size
* Set buffer size
PPM4 STX PBUFSZ  ;set printer buffer size
* Set DCB command and mode
     STY DCOMND  ;command
     STA DAUX1   ;print mode
     RTS
*    Assume NORMAL mode
PPM5 LDA #NORMAL ;NORMAL mode
     BNE PPM1    ;set buffer size
