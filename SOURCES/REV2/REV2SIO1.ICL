* SUBTTL 'Serial Input/Output'

* ISIO - Initialize SIO
ISIO EQU *
     LDA #MOTRST
     STA PACTL   ;turn off motor
     LDA #NCOMHI
     STA PBCTL   ;raise NOT COMMAND line
     LDA #$03    ;POKEY out of initialize mode
     STA SSKCTL  ;SKCTL shadow
     STA SOUNDR  ;select noisy I/O
     STA SKCTL
     RTS

* SIO - Serial Input/Output
SIO  EQU *
* Initialize
     TSX
     STX STACKP ;save stack pointer
     LDA #1     ;critical section indicator
     STA CRITIC ;indicate critical section
* Check device ID
     LDA DDEVIC ;device ID
     CMP #CASET
     BNE SIO1 ;if not cassette
* Process cassette
     JMP PCI ;process cassette I/O, return
* Process intelligent device
SIO1 LDA #0
     STA CASFLG  ;indicate not cassette
     LDA #DRETRI
     STA DRETRY  ;set device retry count
SIO2 LDA #CRETRI
     STA CRETRY  ;set command frame retry count
* Send command frame
SIO3 LDA <B19200
     STA AUDF3 ;set baud rate to 19200
     LDA >B19200
     STA AUDF4
* Set up command buffer
     CLC
     LDA DDEVIC ;device ID
     ADC DUNIT  ;add unit number
     ADC #$FF   ;subtract 1
     STA CDEVIC ;device bus ID
     LDA DCOMND ;command
     STA CCOMND
     LDA DAUX1  ;auxiliary information 1
     STA CAUX1
     LDA DAUX2  ;auxiliary information 2
     STA CAUX2
* Set buffer pointer to command frame buffer
     CLC
     LDA <CDEVIC ;low buffer address
     STA BUFRLO   ;low buffer address
     ADC #4
     STA BFENLO  ;low buffer end address
     LDA >CDEVIC ;high buffer address
     STA BUFRHI  ;high buffer address
     STA BFENHI  ;high buffer end address
* Send command frame to device
     LDA #NCOMLO
     STA PBCTL  ;lower NOT COMMAND line
     JSR SID    ;send command frame
     LDA ERRFLG ;error flag
     BNE SIO4   ;if error received
     TYA ;status
     BNE SIO5 ;if ACK received
* Process NAK or timeout
SIO4 DEC CRETRY ;decrement command frame retry count
     BPL SIO3 ;if retries not exhausted
* Process command frame retries exhausted
     JMP SIOA ;process error
* Process ACK
SIO5 LDA DSTATS
     BPL SIO6 ;if no data to send
* Send data frame to device
     LDA #CRETRI
     STA CRETRY ;set command frame retry count
     JSR SBP  ;set buffer pointers
     JSR SID  ;send data frame
     BEQ SIOA ;if error
* Wait for complete
SIO6 JSR GTO ;set device timeout
     LDA #0
     STA ERRFLG ;clear error flag
     JSR STW  ;set timer and wait
     BEQ SIO8 ;if timeout
* Process no timeout
     BIT DSTATS
     BVS SIO7 ;if more data follows
     LDA ERRFLG ;error flag
     BNE SIOA ;if error
* Process no error
     BEQ CSO ;complete SIO operation
* Receive data frame from device
SIO7 JSR SBP ;set buffer pointers
     JSR REC ;receive
* Check error flag
SIO8 LDA ERRFLG ;error flag
     BEQ SIO9 ;if no error preceded data
* Process error
     LDA TSTAT  ;temporary status
     STA STATUS ;status
* Check status
SIO9 LDA STATUS ;status
     CMP #SUCCES
     BEQ CSO ;if successful, complete operation, return
* Process error
SIOA DEC DRETRY ;decrement device retry count
     BMI CSO ;if retries exhausted, complete, return
* Retry
     JMP SIO2

* CSO - Complete SIO Operation
CSO  EQU *
     JSR DSR ;disable SEND and RECEIVE
     LDA #0  ;not critical section indicator
     STA CRITIC ;critical section flag
     LDY STATUS ;status
     STY DSTATS ;status
     RTS

* WCA - Wait for Completion or ACK
* EXIT
*   Y = 0, if failure
*   Y = $FF, if success
* NOTES
*   Problem: WCA does not handle NAK correctly;
*   just before WCA3 should be removed
WCA  EQU *
* Initialize
     LDA #0
     STA ERRFLG ;clear error flag
* Set buffer pointer.
     CLC
     LDA <TEMP  ;low temporary address
     STA BUFRLO ;low buffer address
     ADC #1
     STA BFENLO ;low buffer end address
     LDA >TEMP  ;high temporary address
     STA BUFRHI ;high buffer address
     STA BFENHI ;high buffer end address
     LDA #$FF
     STA NOCKSM ;indicate no checksum follows
     JSR REC    ;receive
     LDY #$FF   ;assume success
     LDA STATUS ;status
     CMP #SUCCES
     BNE WCA2   ;if failure
     LDA TEMP   ;byte received
     CMP #ACK
     BEQ WCA4   ;if ACK, exit
     CMP #COMPLT
     BEQ WCA4   ;if complete, exit
     CMP #ERROR
     BNE WCA1   ;if device did not send back
* Process unrecognized response.
     LDA #DERROR
     STA STATUS ;indicate device error
     BNE WCA2   ;check for timeout
* Process nothing sent back
WCA1 LDA #DNACK
     STA STATUS ;indicate NAK
* Check for timeout
WCA2 LDA STATUS
     CMP #TIMOUT
     BEQ WCA3 ;if timeout
* Process other error
     LDA #$FF   ;error indicator
     STA ERRFLG ;indicate error
     BNE WCA4   ;exit
* Indicate failure
WCA3 LDY #0 ;failure indicator
* Exit
WCA4 LDA STATUS ;status
     STA TSTAT  ;temporary status
     RTS

* SEN - Send
* SEN sends a buffer over the serial bus.
* NOTES
*   Problem: an interrupt may occur before CHKS:
*   initialized, causing an incorrect checksum :
*   STA CHKSUM should precede STA SEROUT.
SEN  EQU *
* Initialize
     LDA #SUCCES ;assume success
     STA STATUS  ;status
     JSR ESS     ;enable SIO SEND
     LDY #0
     STY CHKSUM  ;clear checksum
     STY CHKSNT  ;clear checksum sent flag
     STY XMTDON  ;clear transmit-frame done flag
* Initiate TRANSMIT
     LDA (BUFRLO),Y ;first byte from buffer
     STA SEROUT ;serial output register
     STA CHKSUM ;checksum
* Check BREAK key
SEN1 LDA BRKKEY
     BNE SEN2 ;if BREAK key not pressed
* Process BREAK key
     JMP PBK ;process BREAK key, return
* Process BREAK key not pressed
SEN2 LDA XMTDON ;transmit-frame done flag
     BEQ SEN1   ;if transmit-frame not done
* Exit
     JSR DSR ;disable SEND and RECEIVE
     RTS

* ORIR - Process Serial Output Ready IRQ
* Exits via RTI
ORIR EQU *
* Initialize
     TYA
     PHA ;save Y
     INC BUFRLO ;increment low buffer pointer
     BNE ORI1   ;if low buffer pointer non-zero
     INC BUFRHI ;increment high buffer pointer
* Check end of buffer
ORI1 LDA BUFRLO ;buffer address
     CMP BFENLO ;buffer end address
     LDA BUFRHI
     SBC BFENHI
     BCC ORI4   ;if not past end of buffer
* Process end of buffer
     LDA CHKSNT ;checksum sent flag
     BNE ORI2   ;if checksum already sent
* Send checksum
     LDA CHKSUM ;checksum
     STA SEROUT ;serial output register
     LDA #$FF
     STA CHKSNT ;indicate checksum sent
     BNE ORI3
* Enable TRANSMIT done interrupt
ORI2 LDA POKMSK
     ORA #$08
     STA POKMSK
     STA IRQEN
* Exit
ORI3 PLA
     TAY ;restore Y
     PLA ;restore A
     RTI
* Transmit next byte from buffer
ORI4 LDY #0
     LDA (BUFRLO),Y ;byte from buffer
     STA SEROUT ;serial output register
     CLC
     ADC CHKSUM ;add byte to checksum
     ADC #0
     STA CHKSUM ;update checksum
     JMP ORI3   ;exit

* OCIR - Process Serial Output Complete IRQ
* Exits via RTI
OCIR EQU *
* Check checksum sent
     LDA CHKSNT ;checksum sent flag
     BEQ OCI1   ;if checksum not yet sent
* Process checksum sent
     STA XMTDON ;indicate transmit-frame done
* Disable TRANSMIT done interrupt
     LDA POKMSK
     AND #$F7
     STA POKMSK
     STA IRQEN
* Exit
OCI1 PLA
     RTI

* REC - Receive
REC  EQU *
* Initialize
     LDA #0
     LDY CASFLG
     BNE REC1    ;if cassette
     STA CHKSUM  ;initialize checksum
REC1 STA BUFRFL  ;clear buffer full flag
     STA RECVDN  ;clear receive-frame done flag
     LDA #SUCCES ;assume success
     STA STATUS  ;status
     JSR ESR     ;enable SIO RECEIVE
     LDA #NCOMHI
     STA PBCTL
* Check BREAK key
REC2 LDA BRKKEY
     BNE REC3 ;if BREAK key not pressed
* Process BREAK key
     JMP PBK ;process BREAK key, return
* Process BREAK key not pressed
REC3 LDA TIMFLG ;timeout flag
     BEQ ITO    ;if timeout, indicate timeout
* Process no timeout
     LDA RECVDN ;receive-frame done flag
     BEQ REC2   ;if receive-frame done, continue
* Exit
     RTS

* ITO - Indicate Timeout
ITO  EQU *      
     LDA #TIMOUT ;timeout indicator
     STA STATUS  ;indicate timeout
     RTS         ;return

* IRIR - Process Serial Input Ready IRQ
IRIR EQU *
* Initialize
     TYA
     PHA ;save Y
     LDA SKSTAT
     STA SKRES ;reset status register
* Check for frame error
     BMI IRI1 ;if no frame error
* Process frame error
     LDY #FRMERR ;frame error
     STY STATUS  ;indicate frame error
* Check for overrun error
IRI1 AND #$20
     BNE IRI2 ;if no overrun error
* Process overrun error
     LDY #OVRRUN ;overrun error
     STY STATUS  ;indicate overrun error
* Check for buffer full
IRI2 LDA BUFRFL
     BEQ IRI5 ;if buffer not yet full
* Process buffer full
     LDA SERIN  ;checksum from device
     CMP CHKSUM ;computed checksum
     BEQ IRI3   ;if checksums match
* Process checksum error
     LDY #CHKERR ;checksum error
     STY STATUS  ;indicate checksum error
* Indicate receive-frame done
IRI3 LDA #$FF   ;receive-frame done indicator
     STA RECVDN ;indicate receive-frame done
* Exit
IRI4 PLA
     TAY ;restore Y
     PLA ;restore A
     RTI
* Process buffer not full
IRI5 LDA SERIN ;serial input register
     LDY #0
     STA (BUFRLO),Y ;byte of buffer
     CLC
     ADC CHKSUM ;add byte to checksum
     ADC #0
     STA CHKSUM ;update checksum
     INC BUFRLO ;increment low buffer pointer
     BNE IRI6   ;if low buffer pointer non-zero
     INC BUFRHI ;increment high buffer pointer
* Check end of buffer
IRI6 LDA BUFRLO ;buffer address
     CMP BFENLO ;buffer end address
     LDA BUFRHI
     SBC BFENHI
     BCC IRI4   ;if not past end of buffer
* Process end of buffer
     LDA NOCKSM ;no checksum follows flag
     BEQ IRI7   ;if checksum will follow
* Process no checksum will follow
     LDA #0
     STA NOCKSM ;clear no checksum follows flag
     BEQ IRI3   ;indicate receive-frame done
* Process checksum will follow
IRI7 LDA #$FF
     STA BUFRFL ;indicate buffer full
     BNE IRI4   ;exit

* SBP - Set Buffer Pointers
SBP  EQU *
     CLC
     LDA DBUFLO
     STA BUFRLO ;low buffer address
     ADC DBYTLO
     STA BFENLO ;low buffer end address
     LDA DBUFHI
     STA BUFRHI ;high buffer address
     ADC DBYTHI
     STA BFENHI ;high buffer end address
     RTS
