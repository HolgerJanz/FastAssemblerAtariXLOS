
* PCI - Process Cassette I/O
PCI  EQU *
* Check command type
     LDA DSTATS ;command type
     BPL PCI3   ;if READ
* Write a record
     LDA <B00600
     STA AUDF3    ;set 600 baud
     LDA >B00600
     STA AUDF4
     JSR ESS      ;enable SIO SEND
     LDX PALNTS   ;PAL/NTSC offset
     LDY WSIRGX,X ;low short WRITE IRG time
     LDA DAUX2    ;IRG type
     BMI PCI1     ;if short IRG is desired
     LDY WIRGLX,X ;low long WRITE IRG time
PCI1 LDX #WIRGHI  ;high IRG time
     JSR SSV      ;set SIO VBLANK parameters
     LDA #MOTRGO
     STA PACTL  ;turn on motor
PCI2 LDA TIMFLG ;timeout flag
     BNE PCI2   ;if no timeout
     JSR SBP    ;set buffer pointers
     JSR SEN    ;send
     JMP PCI6   ;exit
* Read a record
PCI3 LDA #$FF     ;cassette I/O indicator
     STA CASFLG   ;cassette I/O flag
     LDX PALNTS   ;PAL/NTSC offset
     LDY RSIRGX,X ;low short READ IRG time
     LDA DAUX2    ;IRG type
     BMI PCI4     ;if short IRG desired
     LDY RIRGLX,X ;low long READ IRG time
PCI4 LDX #RIRGHI  ;high READ IRG time
     JSR SSV      ;set SIO VBLANK parameters
     LDA #MOTRGO
     STA PACTL  ;turn on motor
PCI5 LDA TIMFLG ;timeout flag
     BNE PCI5   ;if no timeout
     JSR SBP    ;set buffer pointers
     JSR GTO    ;get device timeout
     JSR SSV    ;set SIO VBLANK parameters
     JSR SBR    ;set initial baud rate
     JSR REC    ;receive
* Exit
PCI6 LDA DAUX2 ;IRG type
     BMI PCI7  ;if doing short IRG
     LDA #MOTRST
     STA PACTL ;turn off motor
PCI7 JMP CSO   ;complete SIO operation, return

* PTE - Process Timer Expiration
PTE  EQU *
     LDA #0     ;timeout indicator
     STA TIMFLG ;timeout flag
     RTS

* ESS - Enable SIO SEND
ESS  EQU *
* Initialize
     LDA #$07 ;mask off previous serail bus control bits
     AND SSKCTL
     ORA #$20 ;set SEND mode
* Check device type.
     LDY DDEVIC
     CPY #CASET
     BNE ESS1 ;if not cassette
* Process cassette
     ORA #$08    ;set FSK output
     LDY #LOTONE ;set FSK tone frequencies
     STY AUDF2
     LDY #HITONE
     STY AUDF1
* Set serial bus control
ESS1 STA SSKCTL ;SKCTL shadow
     STA SKCTL
     LDA #$C7   ;mask off previous serial bus interrupt bits
     AND POKMSK ;and with POKEY IRQ enable
     ORA #$10   ;enable output data needed interrupt
     JMP SSR    ;set for SEND, return

* ESR - Enable SIO RECEIVE
ESR  EQU *      
     LDA #$07   ;mask off previous serial bus control bits
     AND SSKCTL
     ORA #$10   ;set receive mode asynchronous
     STA SSKCTL ;SKCTL shadow
     STA SKCTL
     STA SKRES
     LDA #$C7   ;mask off previous serial bus interrupt bits
     AND POKMSK ;and with POKEY IRQ enable
     ORA #$20   ;enable RECEIVE interrupt
*    JMP SSR    ;set for RECEIVE, return

* SSR - Set for SEND or RECEIVE
SSR  EQU *
* Initialize
     STA POKMSK ;update POKEY IRQ enable
     STA IRQEN  ;IRQ enable
     LDA #$28   ;clock ch. 3 with 1.79 MHz, ch. 4 with ch. 3
     STA AUDCTL ;set audio control
* Set voice controls
     LDX #6     ;offset to last voice control
     LDA #$A8   ;pure tone, half volume
     LDY SOUNDR ;noisy I/O flag
     BNE SSR1   ;if noisy I/O desired
     LDA #$A0   ;pure tone, no volume
SSR1 STA AUDC1,X ;set tone and volume
     DEX
     DEX
     BPL SSR1 ;if not done
* Turn off certain voices
     LDA #$A0   ;pure tone, no volume
     STA AUDC3  ;turn off sound on voice 3
     LDY DDEVIC ;device bus ID
     CPY #CASET ;cassette device ID
     BEQ SSR2   ;if cassette device
     STA AUDC1  ;turn off sound on voice 1
     STA AUDC2  ;turn off sound on voice 2
SSR2 RTS

* DSR - Disable SEND and RECEIVE
DSR  EQU *
* Disable serial bus interrupts
     NOP
     LDA #$C7   ;mask to clear serial bus interrupts
     AND POKMSK ;and with POKEY IRQ enable
     STA POKMSK ;update POKEY IRQ enable
     STA IRQEN  ;IRQ enable
* Turn off audio volume
     LDX #6   ;offset to last voice control
     LDA #$00 ;no volume
DSR1 STA AUDC1,X ;turn off voice
     DEX
     DEX
     BPL DSR1 ;if not done
     RTS

* GTO - Get Device Timeout
GTO  EQU *      
     LDA DTIMLO ;device timeout
     ROR @
     ROR @
     TAY ;rotated timeout
     AND #$3F ;lower 6 bits
     TAX ;high timeout
     TYA ;rotated timeout
     ROR @
     AND #$C0 ;upper 2 bits
     TAY ;low timeout
     RTS

* TSIH - Table of SIO Interrupt Handlers
* NOTES
*   Problem: not used
TSIH DTA A(IRIR) ;serial input ready IRQ
     DTA A(ORIR) ;serial output ready IRQ
     DTA A(OCIR) ;serial output complete IRQ

* SID - Send to Intelligent Device
* NOTES
*   Problem: bytes wasted by outer delay loop.
SID  EQU *
* Delay
     LDX #1
SID1 LDY #255
SID2 DEY
     BNE SID2 ;if inner loop not done
     DEX
     BNE SID1 ;if outer loop not done
* Send data frame
     JSR SEN
* Set timer and wait
     LDY <CTIM ;frame acknowledge timeout
     LDX >CTIM
*    JMP STW ;set timer and wait, return

* STW - Set Timer and Wait
STW  EQU *
     JSR SSV ;set SIO VBLANK parameters
     JSR WCA ;wait for completion or ACK
     TYA     ;wait termination status
     RTS

* CBR - Compute Baud Rate
* CBR computes value for POKEY frequency for the baud rate as
* measured by an interval of the VCOUNT timer.
CBR  EQU *
     STA TIMER2   ;save final timer value
     STY TIMER2+1
     JSR AVV      ;adjust VCOUNT value
     STA TIMER2   ;save adjusted timer 2 value
     LDA TIMER1
     JSR AVV      ;adjust VCOUNT value
     STA TIMER1   ;save adjusted timer 1 value
     LDA TIMER2
     SEC
     SBC TIMER1
     STA TEMP1    ;save difference
     LDA TIMER2+1
     SEC
     SBC TIMER1+1
     TAY          ;difference
     LDX PALNTS
     LDA #0
     SEC
     SBC CONS1X,X
CBR1 CLC
     ADC CONS1X,X ;accumulate product
     DEY
     BPL CBR1  ;if not done
     CLC
     ADC TEMP1 ;add to get total VCOUNT difference
     TAY       ;total VCOUNT difference
     LSR @
     LSR @
     LSR @
     ASL @ ;interval divided by 4
     SEC
     SBC #22 ;adjust offset
     TAX     ;offset
     TYA     ;total VCOUNT difference
     AND #7  ;extract lower 3 bits of interval
     TAY     ;lower 3 bits of interval
     LDA <0-11
CBR2 CLC
     ADC #11    ;accumulate interpolation constant
     DEY
     BPL CBR2   ;if done
     LDY #0     ;assume no addition correction
     SEC
     SBC #7     ;adjust interpolation constant
     BPL CBR3
     DEY        ;indicate addition correction
CBR3 CLC
     ADC TPFV,X ;add constant to table value
     STA CBAUDL ;low POKEY frequency value
     TYA
     ADC TPFV+1,X
     STA CBAUDH ;high POKEY frequency value
     RTS

* AVV - Adjust VCOUNT Value
AVV  EQU *
     CMP #$7C
     BMI AVV1 ;if >= $7C
     SEC
     SBC #$7C
     RTS
AVV1 CLC
     LDX PALNTS
     ADC CONS2X,X
     RTS

* SBR - Set Initial Baud Rate
* INITIAL BAUD RATE MEASUREMENT -- USED TO SET THE
* BAUD RATE AT THE START OF A RECORD.
* IT IS ASSUMED THAT THE FIRST TWO BYTES OF EVERY
* RECORD ARE $AA.
* NOTES
*   Problem: bytes wasted by branch around branch (SBR3).
SBR  EQU *
SBR1 LDA BRKKEY
     BNE SBR2 ;if BREAK key not pressed
     JMP PBK  ;process BREAK key, return
SBR2 SEI
     LDA TIMFLG ;timeout flag
     BNE SBR3   ;if no timeout
     BEQ SBR5   ;process timeout
SBR3 LDA SKSTAT
     AND #$10     ;extract start bit
     BNE SBR1     ;if start bit
     STA SAVIO    ;save serial data in
     LDX VCOUNT   ;vertical line counter
     LDY RTCLOK+2 ;low byte of VBLANK clock
     STX TIMER1
     STY TIMER1+1 ;save initial timer value
     LDX #1
     STX TEMP3 ;set mode flag
     LDY #10   ;10 bits
SBR4 LDA BRKKEY
     BEQ PBK    ;if BREAK key pressed, process, return
     LDA TIMFLG ;timeout flag
     BNE SBR6   ;if no timeout
SBR5 CLI
     JMP ITO    ;indicate timeout, return
SBR6 LDA SKSTAT
     AND #$10   ;extract
     CMP SAVIO  ;previous serial data in
     BEQ SBR4   ;if data in not changed
     STA SAVIO  ;save serial data in
     DEY        ;decrement bit counter
     BNE SBR4   ;if not done
     DEC TEMP3  ;decrement mode
     BMI SBR7   ;if done with both modes
     LDA VCOUNT
     LDY RTCLOK+2
     JSR CBR  ;compute baud rate
     LDY #9   ;9 bits
     BNE SBR4 ;set bit counter
SBR7 LDA CBAUDL
     STA AUDF3
     LDA CBAUDH
     STA AUDF4 ;set POKEY baud rate
     LDA #0
     STA SKSTAT
     LDA SSKCTL
     STA SKSTAT ;initialize POKEY serial port
     LDA #$55
     STA (BUFRLO),Y ;first byte of buffer
     INY
     STA (BUFRLO),Y ;second byte of buffer
     LDA #$AA   ;checksum
     STA CHKSUM ;checksum
     CLC
     LDA BUFRLO
     ADC #2     ;add 2
     STA BUFRLO ;update low buffer pointer
     LDA BUFRHI
     ADC #0
     STA BUFRHI ;update high buffer pointer
     CLI
     RTS

* PBK - Process BREAK Key
PBK  EQU *
     JSR DSR     ;disable SEND and RECEIVE
     LDA #MOTRST
     STA PACTL   ;turn off motor
     LDA #NCOMHI
     STA PBCTL   ;raise NOT COMMAND line
     LDA #BRKABT ;BREAK abort error
     STA STATUS  ;status
     LDX STACKP  ;saved stack pointer
     TXS         ;restore stack pointer
     DEC BRKKEY  ;indicate BREAK
     CLI
     JMP CSO ;complete SIO operation, return to caller of SIO

* SSV - Set SIO VBLANK Parameters
SSV  EQU *
     LDA <PTE   ;timer expiration routine address
     STA CDTMA1
     LDA >PTE
     STA CDTMA1+1
     LDA #1     ;timer 1
     SEI
     JSR SETVBV ;set VBLANK parameters
     LDA #1     ;no timeout indicator
     STA TIMFLG ;timeout flag
     CLI
     RTS

* TPFV - Table of POKEY Frequency Values
* TPFV translates VCOUNT interval timer measurements to POKEY
* frequency register values.
* Table entries are AUDF+7.
* Frequency-out is Frequency-in divided by 2*(AUDF+M), where
* Frequency-in = 1.78979 Mhz and M = 7.
* AUDF+7=(11.365167)*T-out, where T-out is the number of counts
* (127 used cd soulution???) of VCOUNT for one character
* time (10 bit times).
*    DTA A(636) ;baud rate 1407, VCOUNT interval 56
*    DTA A(727) ;baud rate 1231, VCOUNT interval 64
*    DTA A(818) ;baud rate 1094, VCOUNT interval 72
*    DTA A(909) ;baud rate 985, VCOUNT interval 80
TPFV DTA A(1000) ;baud rate 895, VCOUNT interval 88
     DTA A(1091) ;baud rate 820, VCOUNT interval 96
     DTA A(1182) ;baud rate 757, VCOUNT interval 104
     DTA A(1273) ;baud rate 703, VCOUNT interval 112
     DTA A(1364) ;baud rate 656, VCOUNT interval 120
     DTA A(1455) ;baud rate 615, VCOUNT interval 128
     DTA A(1546) ;baud rate 579, VCOUNT interval 136
     DTA A(1637) ;baud rate 547, VCOUNT interval 144
     DTA A(1728) ;baud rate 518, VCOUNT interval 152
     DTA A(1818) ;baud rate 492, VCOUNT interval 160
     DTA A(1909) ;baud rate 469, VCOUNT interval 168
     DTA A(2000) ;baud rate 447, VCOUNT interval 176
*    DTA A(2091) ;baud rate 428, VCOUNT interval 184
*    DTA A(2182) ;baud rate 410, VCOUNT interval 192
*    DTA A(2273) ;baud rate 394, VCOUNT interval 200
*    DTA A(2364) ;baud rate 379, VCOUNT interval 208
*    DTA A(2455) ;baud rate 365, VCOUNT interval 216
*    DTA A(2546) ;baud rate 352, VCOUNT interval 224
*    DTA A(2637) ;baud rate 339, VCOUNT interval 232
*    DTA A(2728) ;baud rate 328, VCOUNT interval 240
*    DTA A(2819) ;baud rate 318, VCOUNT interval 248

* NTSC/PAL Constant Tables
WIRGLX DTA L(WIRGLN) ;NTSC .lo(long write IRG
       DTA L(WIRGLP) ;PAL .lo(long write IRG
RIRGLX DTA L(RIRGLN) ;NTSC .lo(long read IRG
       DTA L(RIRGLP) ;PAL .lo(long read IRG
WSIRGX DTA L(WSIRGN) ;NTSC .lo(short write IRG
       DTA L(WSIRGP) ;PAL .lo(short write IRG
RSIRGX DTA L(RSIRGN) ;NTSC .lo(short read IRG
       DTA L(RSIRGP) ;PAL .lo(short read IRG

CONS1X DTA B(131) ;NTSC
       DTA B(156) ;PAL
CONS2X DTA B(7)   ;NTSC
       DTA B(32)  ;PAL
