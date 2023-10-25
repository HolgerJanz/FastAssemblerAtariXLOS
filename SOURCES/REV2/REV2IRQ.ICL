* SUBTTL 'Interrupt Handler'

* IIH - Initialize Interrupt Handler
*   TRIG3 = ACMI module interlock
*   TRIG2 = cartridge interlock
IIH  EQU *
     LDA #$40
     STA NMIEN  ;disable DLI and enable VBLANK NMI
     LDA TRIG3  ;cartridge interlock
     STA GINTLK ;cartridge interlock status
     RTS        ;return

* NMI - Process NMI
*   Exits via appropriate vector to process NMI
NMI  EQU *
*    ASSERT  $C0=high NMI    ;for compatibility with LNBUG
*    Check for display list NMI
     BIT NMIST
     BPL NMI1      ;if not display list NMI
     JMP (VDSLST)  ;process display list NMI, return
*    Initialize
NMI1 CLD
*    Save registers
     PHA ;save A
     TXA
     PHA ;save X
     TYA
     PHA ;save Y
*    Reset NMI status
     STA NMIRES    ;reset NMI status
*    Process NMI
     JMP (VVBLKI)  ;process immediate VBLANK NMI, return

* IRQ - Process IRQ
IRQ  EQU *        
*    Initialize
     CLD
*    Process IRQ
     JMP (VIMIRQ)  ;process immediate IRQ, return

* IIR - Process Immediate IRQ
*   Exits via appropriate vector to process IRQ
IIR  EQU *
*    Initialize
     PHA         ;save A
*    Check for serial input ready IRQ
     LDA IRQST   ;IRQ status
     AND #$20    ;serial input ready
     BNE IIR1    ;if not serial input ready
*    Process serial input IRQ
     LDA #$DF    ; not($20)     ;all other interrupts
     STA IRQEN   ;enable all other interrupts
     LDA POKMSK
     STA IRQEN
     JMP (VSERIN) ;process serial input ready IRQ, return
*    Process possible ACMI IRQ
*    Initialize further
IIR1 TXA
     PHA        ;save X
*    Check for parallel device IRQ
     LDA PDVI   ;parallel device IRQ statuses
     AND PDIMSK ;select desired IRQ statuses
     BEQ IIR2   ;if no desired IRQ
*    Process parallel device IRQ
     JMP (VPIRQ) ;process parallel device IR:
*    Check other types of IRQ
IIR2 LDX <TIRL-1-1  ;offset to next to last entry
IIR3 LDA TIRQ,X ;IRQ type
     CPX #5     ;offset to serial out complete
     BNE IIR4   ;if not serial out complete
     AND POKMSK ;and with POKEY IRQ enable
     BEQ IIR5   ;if serial out complete not enabled
IIR4 BIT IRQST  ;IRQ interrupt status
     BEQ IIR6   ;if interrupt found
IIR5 DEX
     BPL IIR3   ;if not done
*    Coninue IRQ processing
     JMP CIR    ;continue IRQ processing, return
*    Enable other interrupts
IIR6 EOR #$FF   ;complement mask
     STA IRQEN  ;enable all others
     LDA POKMSK ;POKEY IRQ mask
     STA IRQEN  ;enable indicated IRQ's
*    Check for BREAK key IRQ
     CPX #0
     BNE IIR7     ;if not BREAK key IRQ
*    Check for keyboard disabled
     LDA KEYDIS
     BNE CIR      ;if keyboard disabled, cont:
*    Process IRQ
IIR7 LDA TOIH,X   ;offset to interrupt handler
     TAX
     LDA INTABS,X ;interrupt handler address
     STA JVECK
     LDA INTABS+1,X
     STA JVECK+1
     PLA
     TAX         ;restore X
     JMP (JVECK) ;process interrupt, return

* BIR - Process BREAK Key IRQ
*   Exits via RTI
BIR  EQU *
*    Process BREAK
     LDA #0
     STA BRKKEY ;clear BREAK key flag
     STA SSFLAG ;clear start/stop flag
     STA CRSINH ;enable cursor
     STA ATRACT ;turn off attract-mode
*    Exit
BIR1 PLA        ;restore A
     RTI        ;return

* CIR - Continue IRQ Processing
*   Exits via appropriate vector to process IRQ or to XIR
CIR  EQU * 
*    Initialize
     PLA          ;saved ???
     TAX
*    Check for port A interrupt
     BIT PACTL    ;port A control
     BPL CIR1     ;if not port A interrupt
*    Process proceed line IRQ
     LDA PORTA    ;clear interrupt status bit
     JMP (VPRCED) ;process proceed line IRQ, return
*    Check for port B interrupt
CIR1 BIT PBCTL    ;port B control
     BPL CIR2     ;if not port B interrupt
*    Process interrupt line IRQ
     LDA PORTB    ;clear interrupt status bit
     JMP (VINTER) ;process interrupt line IRQ, return
*    Check for BRK instruction IRQ
CIR2 PLA
     STA JVECK
     PLA       ;saved P
     PHA       ;resave P
     AND #$10  ;B bit of P register
     BEQ CIR3  ;if not BRK instruction IRQ
*    Process BRK instruction IRQ
     LDA JVECK
     PHA
     JMP (VBREAK) ;process BRK instruction IRQ, return
*    Exit IRQ processing
CIR3 LDA     JVECK
     PHA
*    JMP XIR ;exit IRQ processing, return

* XIR - Exit IRQ Processing
*   Exits to RIR
XIR  EQU *
     PLA     ;restore A
*    JMP RIR ;return from interrupt

* RIR - Return from Interrupt
*   Exits via RTI
RIR  EQU *
     RTI   ;return

* TIRQ - Table of IRQ Types
* Entry n is the interrupt indicator of priority n (0 is lowest)
* NOTES
*   Problem: entry 7 (serial input ready) not used
TIRQ DTA B($80) ;0 BREAK key IRQ
     DTA B($40) ;1 keyboard IRQ
     DTA B($04) ;2 timer 4 IRQ
     DTA B($02) ;3 timer 2 IRQ
     DTA B($01) ;4 timer 1 IRQ
     DTA B($08) ;5 serial output complete IRQ
     DTA B($10) ;6 serial output ready IRQ
     DTA B($20) ;7 serial input ready IRQ
TIRL EQU *-TIRQ ;length

* TOIH - Table of Offsets to Interrupt Handlers
* Entry n is the offset to the interrupt handler vector
* corresponding to entry n of TIRQ
* NOTES
*   Problem: entry 7 (serial input ready) not used
TOIH DTA L(BRKKY-INTABS)  ;0 BREAK key IRQ
     DTA L(VKEYBD-INTABS) ;1 keyboard IRQ
     DTA L(VTIMR4-INTABS) ;2 timer 4 IRQ
     DTA L(VTIMR2-INTABS) ;3 timer 2 IRQ
     DTA L(VTIMR1-INTABS) ;4 timer 1 IRQ
     DTA L(VSEROC-INTABS) ;5 serial output complete IRQ
     DTA L(VSEROR-INTABS) ;6 serial output ready IRQ
     DTA L(VSERIN-INTABS) ;7 serial input ready IRQ

* WFR - Wait for RESET
* loops forever, does not exit
WFR  EQU *
WFR1 JMP WFR1

* IVNM - Process Immediate VBLANK NMI
*   Exits to DVNM or via VVBLKD vector
IVNM EQU *
*    Increment frame counter and attract-mode counter
     INC RTCLOK+2 ;increment low frame counter
     BNE IVN1   ;if low counter not zero
     INC ATRACT ;increment attract-mode counter/flag
     INC RTCLOK+1 ;increment middle frame counter
     BNE IVN1   ;if middle counter not zero
     INC RTCLOK ;increment high frame counter
*    Set attract-mode effects
IVN1 LDA #$FE   ;select no luminance change
     LDX #0     ;select no color shift
     LDY ATRACT ;attract-mode timer/flag
     BPL IVN2   ;if not attract-mode
     STA ATRACT ;ensure continued attract-mode
     LDX RTCLOK+1 ;select color shift
     LDA #$F6   ;select lower luminance
IVN2 STA DRKMSK ;attract-mode luminance
     STX COLRSH ;attract-mode color shift
*    Update COLPF1 (in case fine scrolling and critical :
     LDA COLOR1 ;playfield 1 color
     EOR COLRSH ;modify color with attract-:
     AND DRKMSK ;modify with attract-mode l:
     STA COLPF1 ;set playfield 1 color/lumi:
*    Process countdown timer 1
     LDX #0     ;indicate countdown timer 1
     JSR DCT    ;decrement countdown timer
     BNE IVN3   ;if timer not expired
     JSR PTO    ;process countdown timer 1 expiration
*    Check for critical sction
IVN3 LDA CRITIC
     BNE IVN4            ;if critical section
*    Check for IRQ enabled
     TSX         ;stack pointer
     LDA $0104,X ;stacked P
     AND #$04    ;I (IRQ disable) bit
     BEQ IVN5    ;if IRQ enabled
*    Exit
IVN4 JMP DVNM   ;process deferred VBLANK NMI, return
*    Process IRQ enabled non-critical section
*    Check for cartridge change
IVN5 LDA TRIG3  ;cartridge interlock
     CMP GINTLK ;previous cartridge interlock status
     BNE WFR    ;if cartridge change, wait for RESET
*    Set hardware registers from shadows
     LDA PENV
     STA LPENV  ;light pen vertical position
     LDA PENH
     STA LPENH  ;light pen vertical position
     LDA SDLSTH
     STA DLISTH ;high display list address
     LDA SDLSTL
     STA DLISTL ;low display list address
     LDA SDMCTL
     STA DMACTL ;DMA control
     LDA GPRIOR
     STA PRIOR  ;prioritty select
*    Check for vertical scroll enabled
     LDA VSFLAG ;vertical scroll count
     BEQ IVN6   ;if vertical scroll not ena:
*    Scroll one line
     DEC VSFLAG ;decrement vertical scroll :
     LDA #8     ;scroll one line
     SEC
     SBC VSFLAG ;subtract vertical scroll c:
     AND #07
     STA VSCROL ;set vertical scroll
*    Turn off speaker
IVN6 LDX #$08   ;speaker off
     STX CONSOL ;set speaker control
*    Set color registers from shadows
*    LDX #8              ;offset to background color
IVN7 CLI
     LDA PCOLR0,X ;color register shadow
     EOR COLRSH   ;modify with attract-mode color shift
     AND DRKMSK   ;modify with attract-mode luminance
     STA COLPM0,X ;set color register
     DEX
     BPL IVN7     ;if not done
*    Set character set control
     LDA CHBAS
     STA CHBASE
     LDA CHACT
     STA CHACTL
*    Process countdown timer 2
     LDX #2   ;indicate countdown timer 2
     JSR DCT  ;decrement countdown timer
     BNE IVN8 ;if timer not expired
     JSR PTT  ;process countdown timer 2 expiration
*    Process timers 3, 4 and 5
IVN8 LDX #2              ;preset offset to timer 2
IVN9 INX
     INX        ;offset to countdown timer
     LDA CDTMV3-4,X ;countdown timer
     ORA CDTMV3+1-4,X
     BEQ IVNA   ;if countdown timer already expired
     JSR DCT    ;decrement countdown timer
     STA CDTMF3-4,X ;indicate timer expiration status
IVNA CPX #8     ;offset to timer 5
     BNE IVN9   ;if all timers not done
*    Check debounce counter
     LDA SKSTAT ;keyboard status
     AND #$04   ;key down indicator
     BEQ IVNB   ;if key down
*    Process key up
     LDA KEYDEL ;key delay counter
     BEQ IVNB   ;if counted down already
     DEC KEYDEL ;decrement key delay counter
*    Check software key repeat timer
IVNB LDA SRTIMR ;key repeat timer
     BEQ IVND   ;if key repeat timer expired
     LDA SKSTAT ;keyboard status
     AND #$04   ;key down indicator
     BNE IVNC   ;if key no longer down
     DEC SRTIMR ;decrement key repeat timer
     BNE IVND   ;if key repeat timer not expired
*    Process key repeat timer expiration
     LDA KEYDIS ;keyboard disable flag
     BNE IVND   ;if keyboard disabled, no r:
     LDA KEYREP ;initial timer value
     STA SRTIMR ;reset key repeat timer
     LDA KBCODE ;key code
*    Check for hidden codes
     CMP #CNTL1
     BEQ IVND    ;if CTRL-1
     CMP #CNTLF1
     BEQ IVND    ;if CTRL-F1
     CMP #CNTLF2
     BEQ IVND    ;if CTRL-F2
     CMP #CNTLF4
     BEQ IVND    ;if CTRL-F4
     AND #$3F
     CMP #HELP
     BEQ IVND    ;if HELP
*    Set key code
     LDA KBCODE ;key code
     STA CH     ;set key code
     JMP IVND   ;continue
*    Zero key repeat timer
IVNC LDA #0
     STA SRTIMR ;zero key repeat timer
*    Read joysticks
IVND LDA PORTA  ;joystick readings
     LSR @
     LSR @
     LSR @
     LSR @      ;joystick 1 reading
     STA STICK1 ;set joystick 1 reading
     STA STICK3 ;simulate joystick 3 reading
     LDA PORTA  ;joystick readings
     AND #$0F   ;joystick 0 reading
     STA STICK0 ;set joystick 0 reading
     STA STICK2 ;simulate joystick 2 reading
*    Read joystick triggers
     LDA TRIG0  ;trigger 0 indicator
     STA STRIG0 ;set trigger 0 indicator
     STA STRIG2 ;simulate trigger 2 indicator
     LDA TRIG1  ;trigger 1 indicator
     STA STRIG1 ;set trigger 1 indicator
     STA STRIG3 ;simulate trigger 3 indicator
*    Read potentiometers
     LDX #3       ;offset to last potentiometer
IVNE LDA POT0,X   ;potentiometer reading
     STA PADDL0,X ;set potentiometer reading
     STA PADDL4,X ;simulate potentiometer reading
     DEX
     BPL IVNE     ;if not done
*    Start potentiometers for next time
     STA POTGO    ;start potentiometers
*    Read paddle triggers
     LDX #2       ;offset to paddle trigger reading
     LDY #1       ;offset to joystick reading
IVNF LDA STICK0,Y ;joystick reading
     LSR @
     LSR @
     LSR @        ;paddle trigger reading
     STA PTRIG1,X ;set paddle trigger reading
     STA PTRIG5,X ;simulate paddle trigger reading
     LDA #0
     ROL @        ;paddle trigger reading
     STA PTRIG0,X ;set paddle trigger reading
     STA PTRIG4,X ;simulate paddle trigger reading
     DEX
     DEX
     DEY
     BPL IVNF     ;if not done
*    Exit
     JMP (VVBLKD) ;process deferred VBLANK NMI, return

* PTO - Process Countdown Timer One Expiration
PTO  EQU * 
     JMP (CDTMA1) ;process countdown timer 1 expiration

* PTT - Process Countdown Timer Two Expiration
PTT  EQU * 
     JMP (CDTMA2) ;process countdown timer 2 expiration

* DCT - Decrement Countdown Timer
*   X = offset to timer value
* EXIT
*   A = 0, if timer expired
*     = $FF, if timer did not expire
DCT  EQU *   
     LDY CDTMV1,X   ;low timer value
     BNE DCT1       ;if low timer value not zero
     LDY CDTMV1+1,X ;high timer value
     BEQ DCT2       ;if timer value zero, exit
     DEC CDTMV1+1,X ;decrement high timer value
DCT1 DEC CDTMV1,X   ;decrement low timer value
     BNE DCT2       ;if low timer value not zero
     LDY CDTMV1+1,X ;high timer value
     BNE DCT2       ;if high timer value not zero
     LDA #0         ;indicate timer expired
     RTS            ;return
DCT2 LDA #$FF       ;indicate timer did not expire
     RTS            ;return

* SVP - Set Vertical Blank Parameters
* SVP sets countdown timers and VBLANK vectors
*   X = high initial timer value or high vector address
*   Y = low initial timer value or low vector address
*   A = 1, if timer 1 value
*       2, if timer 2 value
*       3, if timer 3 value
*       4, if timer 4 value
*       5, if timer 5 value
*       6, if immediate VBLANK vector
*       7, if deferred VBLANK vector
SVP  EQU *        
*    Initialize
     ASL @       ;compute offset+2 to value or vector
     STA INTEMP  ;offset+2 to value or vector
     TXA         ;high timer value or high vector address
*    Ensure no VBLANK in progress by delaying after HBLANK
     LDX #5      ;20 CPU cycles
     STA WSYNC   ;wait for HBLANK synchronization
SVP1 DEX
     BNE SVP1    ;if not done delaying
*    Set timer value or vector address
     LDX INTEMP       ;offset+2 to value or vector
     STA CDTMV1-2+1,X ;high timer value or high vector address
     TYA
     STA CDTMV1-2,X   ;low timer value or low vector address
     RTS              ;return

* DVNM - Process Deferred VBLANK NMI
*   Exits via RTI
DVNM EQU *
     PLA
     TAY
     PLA
     TAX
     PLA
     RTI
