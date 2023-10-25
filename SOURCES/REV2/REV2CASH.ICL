* SUBTTL 'Cassette Handler'

* CIN - Initialize Cassette
CIN  EQU *
     LDA <B00600 ;indicate 600 baud
     STA CBAUDL  ;cassette baud rate
     LDA >B00600
     STA CBAUDH
*    JMP CSP

* CSP - Perform Cassette SPECIAL
* Does nothing.
CSP  EQU *
CSPV EQU *-1
     RTS

* COP - Perform Cassette OPEN
COP  EQU *
COPV EQU *-1
* Set Cassette IRG type
     LDA ICAX2Z ;second auxiliary information
     STA FTYPE  ;cassette IRG type
* Check OPEN mode
     LDA ICAX1Z ;OPEN mode
     AND #$0C ;open for input and output bits
     CMP #$04 ;open for input bit
     BEQ OCI  ;if open for input, process, return
     CMP #$08 ;open for output bit
     BEQ OCO  ;if open for output, process, return
     RTS

* OCI - Open Cassette for Input
OCI  EQU *
* Process open for input.
     LDA #0     ;indicate reading
     STA WMODE  ;WRITE mode
     STA FEOF   ;indicate no FEOF yet
     LDA #TONE2 ;tone for pressing PLAY
     JSR AUB    ;alert user with beep
     BMI PBC1   ;if error
* Initialize cassette READ.
*    JMP ICR ;initialize cassette READ, return

* ICR - Initialize Cassette READ
ICR  EQU *
* Initialize
     LDA #MOTRGO ;motor on
     STA PACTL   ;port A control
* Wait for leader read
     LDX PALNTS
     LDY RLEADL,X ;low READ leader
     LDA RLEADH,X ;high READ leader
     TAX
     LDA #3
     STA CDTMF3
     JSR SETVBV ;set up VBLANK timer
ICR1 LDA CDTMF3
     BNE ICR1 ;if not done waiting
* Initialize
     LDA #128 ;buffer size
     STA BPTR ;initialize buffer pointer
     STA BLIM ;initialize buffer limit
     JMP OCO2 ;exit

* PBC - Process BREAK for Cassette Operation
PBC  EQU *
     LDY #BRKABT ;BREAK abort error
     DEC BRKKEY  ;reset BREAK key flag

PBC1 LDA #0    ;indicate reading
     STA WMODE ;WRITE mode
     RTS

* OCO - Open Cassette for Output
OCO  EQU *
* Initialize
     LDA #$80  ;indicate writing
     STA WMODE ;WRITE mode
     LDA #TONE1
     JSR AUB  ;alert user with beep
     BMI PBC1 ;if error
* Set baud rate to 600
     LDA <B00600
     STA $D204
     LDA >B00600
     STA $D206
* Write marks
     LDA #$60
     STA DDEVIC
     JSR SENDEV
     LDA #MOTRGO ;write 5 second blank tape
     STA PACTL
* Wait for leader written
     LDX PALNTS
     LDY WLEADL,X
     LDA WLEADH,X
     TAX
     LDA #3
     JSR SETVBV ;set VBLANK parameters
     LDA #$FF
     STA CDTMF3
OCO1 LDA BRKKEY ;BREAK key flag
     BEQ PBC
     LDA CDTMF3
     BNE OCO1 ;if not done waiting
* Initialize buffer pointer
     LDA #0
     STA BPTR ;buffer pointer
* Indicate success
OCO2 LDY #SUCCES ;indicate success
     RTS

* CGB - Perform Cassette GET-BYTE
CGB  EQU *
CGBV EQU *-1
* Check for EOF
     LDA FEOF ;EOF flag
     BMI RCB3 ;if at EOF already
* Check for end of buffer
     LDX BPTR ;buffer pointer
     CPX BLIM ;buffer limit
     BEQ RCB  ;if end of buffer, read block
* Get next byte
     LDA CASBUF+3,X ;byte
     INC BPTR       ;increment pointer
     LDY #SUCCES    ;indicate success
CGB1 RTS

* RCB - Read Cassette Block
RCB  EQU *
* Perform READ
     LDA #'R' ;read
     JSR SCB  ;perform SIO on cassette buffer
     TYA
     BMI CGB1 ;if SIO error
     LDA #0
     STA BPTR ;reset pointer
     LDX #$80 ;default number of bytes
* Check for header
     LDA CASBUF+2
     CMP #EOT
     BEQ RCB2 ;if header, read again
* Check for last record
     CMP #DT1
     BNE RCB1 ;if not last data record
     LDX CASBUF+130 ;number of bytes
* Set number of bytes
RCB1 STX BLIM
* Perform cassette GET-BYTE
     JMP CGB ;perform cassette GET-BYTE
* Set EOF flag
RCB2 DEC FEOF ;set EOF flag
* Exit
RCB3 LDY #EOFERR ;end of file indicator
     RTS

* CPB - Perform Cassette PUT-BYTE
CPB  EQU *
CPBV EQU *-1
* Move data to buffer
     LDX BPTR ;buffer pointer
     STA CASBUF+3,X ;data
     INC BPTR    ;increment buffer pointer
     LDY #SUCCES ;assume success
* Check buffer full
     CPX #127 ;offset to last byte of buffer
     BEQ CPB1 ;if buffer full
     RTS
* Write cassette buffer
CPB1 LDA #DTR ;indicate data record type
     JSR WCB  ;write cassette buffer
     LDA #0
     STA BPTR ;reset buffer pointer
     RTS

* CST - Perform Cassette STATUS
CST  EQU *
CSTV EQU *-1
     LDY #SUCCES ;indicate success
     RTS

* CCL - Perform Cassette CLOSE
CCL  EQU *
CCLV EQU *-1
* Check mode
     LDA WMODE ;WRITE mode
     BMI CCL2  ;if writing
* Process reading
     LDY #SUCCES ;indicate success
* Exit
CCL1 LDA #MOTRST
     STA PACTL ;stop motor
     RTS
* Process writing
CCL2 LDX BPTR ;buffer pointer
     BEQ CCL3 ;if no data bytes in buffer
     STX CASBUF+130 ;number of bytes
     LDA #DT1 ;indicate data record type
     JSR WCB  ;write cassette buffer
     BMI CCL1 ;if error, exit
* Zero buffer
CCL3 LDX #127 ;offset to last byte in buffer
     LDA #0
CCL4 STA CASBUF+3,X  ;zero byte
     DEX
     BPL CCL4 ;if not done
* Write cassette buffer
     LDA #EOT ;indicate EOT record type
     JSR WCB  ;write cassette buffer
* Exit
     JMP CCL1

* AUB - Alert User with Beep
AUB  EQU *
* Initialize
     STA FREQ ;frequency
* Compute termination time of beep duration
AUB1 LDA RTCLOK+2 ;current time
     CLC
     LDX PALNTS
     ADC BEEPNX,X ;add constant for 1 second
     TAX          ;beep duration termination
* Turn on speaker
AUB2 LDA #$FF
     STA CONSOL ;turn on speaker
     LDA #$00
* Delay
     LDY #$F0
AUB3 DEY
     BNE AUB3 ;if not done delaying
* Turn off speaker
     STA CONSOL ;turn off speaker
* Delay
     LDY #$F0
AUB4 DEY
     BNE AUB4 ;if not done delaying
* Check for beep duration termination time.
     CPX RTCLOK+2 ;compare current time
     BNE AUB2 ;if termination time not reached
     DEC FREQ ;decrement frequency
     BEQ AUB6 ;if all done, wait
* Compute termination time of beep separation.
     TXA
     CLC
     LDX PALNTS
     ADC BEEPFX,X ;add constant
     TAX          ;beep separation terminatio:
* Wait for termination of beep separation
AUB5 CPX RTCLOK+2 ;compare current time
     BNE AUB5     ;if termination time not reached
* Beep again
     BEQ AUB1 ;beep again
* Wait for key
AUB6 JSR WFK ;wait for key
     TYA ;status
     RTS

* WFK - Wait for Key
WFK  EQU *
     LDA KEYBDV+5 ;keyboard GET-BYTE routine
     PHA         ;put address on stack
     LDA KEYBDV+4
     PHA
     RTS ;invoke keyboard GET-BYTE

* SCB - Perform SIO on Cassette Buffer
SCB  EQU *
     STA DCOMND  ;command
     LDA >131
     STA DBYTHI  ;buffer length
     LDA <131
     STA DBYTLO
     LDA >CASBUF
     STA DBUFHI  ;buffer address
     LDA <CASBUF
     STA DBUFLO
     LDA #$60    ;cassette bus ID
     STA DDEVIC
     LDA #0
     STA DUNIT
     LDA #35     ;timeout
     STA DTIMLO
     LDA DCOMND  ;command
     LDY #GETDAT ;assume SIO GET-DATA comman:
     CMP #READ
     BEQ SCB1    ;if READ command
     LDY #PUTDAT ;SIO PUT-DATA command
SCB1 STY DSTATS  ;SIO command
     LDA FTYPE   ;IRG type
     STA DAUX2   ;second auxiliary informati:
     JSR SIOV    ;vector to SIOV
     RTS

* WCB - Write Cassette Buffer
WCB  EQU *
     STA CASBUF+2 ;record type
     LDA #$55
     STA CASBUF+0
     STA CASBUF+1
     LDA #'W' ;write
     JSR SCB ;perform SIO on cassette buffer
     RTS

* NTSC/PAL Constant Tables
WLEADH DTA H(WLEADN) ;>NTSC WRITE file leader
       DTA H(WLEADP) ;>PAL WRITE file leader
WLEADL DTA L(WLEADN) ;<NTSC WRITE file leader
       DTA L(WLEADP) ;<PAL WRITE file leader
RLEADH DTA H(RLEADN) ;>NTSC READ file leader
       DTA H(RLEADP) ;>PAL READ file leader
RLEADL DTA L(RLEADN) ;<NTSC READ file leader
       DTA L(RLEADP) ;<PAL READ file leader
BEEPNX DTA B(BEEPNN) ;NTSC beep duration
       DTA B(BEEPNP) ;PAL beep duration
BEEPFX DTA B(BEEPFN) ;NTSC beep separation
       DTA B(BEEPFP) ;PAL beep separation
