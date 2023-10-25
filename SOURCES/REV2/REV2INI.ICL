* SUBTTL 'Initialization'

* PWS - Perform Warmstart
* Exits to PCS or PRS
PWS  EQU *
* Initialize
     SEI
* Check for cartridge change
     LDA TRIG3  ;cartridge interlock
     CMP GINTLK ;previous cartridge interlock status
     BNE PCS    ;if cartridge changed, perform coldstart
* Check for cartridge
     ROR @
     BCC PWS1   ;if no cartridge
* Verify no change in cartridge
     JSR CCE    ;check cartridge equivalence
     BNE PCS    ;if different cartridge, coldstart
* Check coldstart status
PWS1 LDA COLDST ;coldstart status
     BNE PCS    ;if coldstart was in progress, perform coldstart
* Perform warmstart
     LDA #$FF   ;indicate warmstart
     BNE PRS    ;preset memory, return

* RES - Process RESET
*   Exits to PCS, if coldstart, or PWS, if warmstart
RES  EQU       *
* Initialize
     SEI
*    Delay 0.1 second for RESET bounce
     LDX #140 ;0.1 second delay
RES1 DEY
     BNE RES1 ;if inner loop not done
     DEX
     BNE RES1 ;if outer loop not done
* Check power-up validation bytes
     LDA PUPBT1
     CMP <PUPVL1
     BNE PCS  ;if validation byte 1 differs, coldstart
     LDA PUPBT2
     CMP <PUPVL2
     BNE PCS  ;if validation byte 2 differs, coldstart
     LDA PUPBT3
     CMP <PUPVL3
     BEQ PWS  ;if all bytes validated, perform warmstart
*    JMP PCS  ;perform coldstart, return

* PCS - Perform Coldstart
* Exits to PRS
PCS  EQU *
     LDA #0   ;indicate coldstart
* JMP PRS  ;preset memory, return

* PRS - Preset Memory
*   Exits via CARTCS vector or DOSVEC vector
PRS  EQU *        
* Update warmstart flag
     STA WARMST ;update warmstart flag
* Set initial conditions
     SEI
     CLD
     LDX #$FF
     TXS ;set stack pointer
* Perform miscellaneous initialization
     JSR PMI    ;perform miscellaneous initialization
* Initialize memory status
     LDA #1     ;no failure indicator
     STA NGFLAG ;memory status flag
* Check type
     LDA WARMST ;warmstart flag
     BNE PRS8   ;if warmstart
* Zero all RAM (except beginning of page zero)
     LDA #0
     LDY #WARMST   ;initial offset into page zero
     STA RAMLO
     STA RAMLO+1   ;initialize RAM pointer
PRS3 LDA #$FF
     STA (RAMLO),Y ;attempt to store $FF
     CMP (RAMLO),Y
     BEQ PRS4      ;if $FF stored successfully
     LSR NGFLAG    ;indicate memory failure
PRS4 LDA #$00
     STA (RAMLO),Y ;attempt to store $00
     CMP (RAMLO),Y
     BEQ PRS5      ;if $00 stored successfully
     LSR NGFLAG    ;indicate memory failure
PRS5 INY
     BNE PRS3      ;if not end of page
* Advance to next page and check for completion
     INC RAMLO+1  ;advance RAM pointer to next page
     LDX RAMLO+1
     CPX TRAMSZ   ;RAM size
     BNE PRS3     ;if not at end of RAM
* Initialize DOSVEC
     LDA <PPD   ;power-up display routine address
     STA DOSVEC ;initialize DOS vector
     LDA >PPD
     STA DOSVEC+1
* Verify ROM checksums
     LDA PORTB
     AND #$7F   ;select self-test ROM
     STA PORTB  ;port B memory control
     JSR VFR    ;verify first 8K ROM
     BCS PRS6   ;if first 8K ROM bad
     JSR VSR    ;verify second 8K ROM
     BCC PRS7   ;if seond 8K ROM good
PRS6 LSR NGFLAG ;indicate memory bad
PRS7 LDA PORTB
     ORA #$80   ;disable self-test ROM
     STA PORTB  ;update port B memory control
* Indicate coldstart in progress
     LDA #$FF
     STA COLDST ;indicate coldstart in progress
     BNE PRSC   ;continue with coldstart procedures
* Perform warmstart procedures
PRS8 LDX #0
     LDA DERRF  ;screen OPEN error flag
     BEQ PRS9   ;if in screen OPEN
* Clean up APPMHI
     DTA B($8E),A(APPMHI)   ; STXw APPMHI
     DTA B($8E),A(APPMHI+1) ; STXw APPMHI+1
     TXA
* Clear page 2 and part of page 3
PRS9 STA $0200,X ;clear byte of page 2
     CPX <ACMVAR ;start of page 3 locations not to clear
     BCS PRSA    ;if not to clear this page 3 location
     STA $0300,X ;clear byte of page 3
PRSA DEX
     BNE PRS9    ;if not done
* Clear part of page 0
     LDX #INTZBS ;offset to first page 0 byte to clear
PRSB STA $0000,X ;clear byte of page 0
     INX
     BPL PRSB    ;if not done
* Record BASIC status
PRSC LDX #0      ;initially assume BASIC enabled
     LDA PORTB   ;port B memory control
     AND #$02    ;BASIC enabled indicator
     BEQ PRSD    ;if BASIC enabled
     INX         ;indicate BASIC disabled
PRSD STX BASICF  ;BASIC flag
* Establish power-up validation bytes
     LDA <PUPVL1
     STA PUPBT1  ;validation byte 1
     LDA <PUPVL2
     STA PUPBT2  ;validation byte 2
     LDA <PUPVL3
     STA PUPBT3  ;validation byte 3
* Establish screen margins
     LDA #LEDGE
     STA LMARGN  ;left margin
     LDA #REDGE
     STA RMARGN  ;right margin
* Establish parameters for NTSC or PAL
     LDA PAL  ;GTIA flag bits
     AND #$0E ;PAL/NTSC indicator
     BNE PRSE ;if NTSC
     LDA #5   ;PAL key repeat delay
     LDX #1   ;PAL indicator
     LDY #40  ;PAL key repeat initial delay
     BNE PRSF ;set parameters
PRSE LDA #6   ;NTSC key repeat delay
     LDX #0   ;NTSC indicator
     LDY #48  ;NTSC key repeat initial delay
PRSF STA KEYREP ;set key repeat rate
     STX PALNTS ;set PAL/NTSC status
     STY KRPDEL ;set key repeat initial delay
* Copy interrupt vector table from ROM to RAM
     LDX <TIHL-1  ;offset to last byte of table
PRSG LDA TIHV,X   ;byte of table of interrupt vectors
     STA INTABS,X ;byte of RAM table
     DEX
     BPL PRSG     ;if not done
* Copy handler vector table from ROM to RAM
     LDX <THAL-1  ;offset to last byte of table
PRSH LDA THAV,X   ;byte of handler vector table
     STA HATABS,X ;byte of RAM table
     DEX
     BPL PRSH    ;if not done
* Initialize software
     JSR ISW     ;initialize software
* Enable IRQ interrupts
     CLI
* Check for memory problems
     LDA NGFLAG  ;memory status
     BNE PRSI    ;if memory good
* Perform memory self-test on bad memory
     LDA PORTB
     AND #$7F    ;enable self-test ROM
     STA PORTB   ;update port B memory control
     LDA #2
     STA CHACT   ;CHACTL (character control) shadow
     LDA >DCSORG ;high domestic character set origin
     STA CHBAS   ;CHBASE (character base) shadow
     JMP EMS     ;execute memory self-test
* Check for cartridge
PRSI LDX #0
     STX TRAMSZ  ;clear cartridge flag
     LDX RAMSIZ  ;RAM size
     CPX >$B000 ;start of cartridge area
     BCS PRSJ    ;if RAM in cartridge area
     LDX CART
     BNE PRSJ    ;if no cartridge
     INC TRAMSZ  ;set cartridge flag
     JSR CCE     ;check cartridge equivalence
     JSR ICS     ;initialize cartridge software
* Open screen editor
PRSJ LDA #OPEN
     LDX #SEIOCB ;screen editor IOCB index
     STA ICCOM,X ;command
     LDA <SEDS  ;screen editor device specification
     STA ICBAL,X ;buffer address
     LDA >SEDS
     STA ICBAH,X
     LDA #OPNIN+OPNOT ;open for input/output
     STA ICAX1,X ;auxiliary informatin 1
     JSR CIOV    ;vector to CIO
     BPL PRSK    ;if no error
* Process error (which should never happen)
     JMP RES     ;retry power-up
* Delay, ensuring VBLANK
PRSK INX
     BNE PRSK ;if inner loop not done
     INY
     BPL PRSK ;if outer loop not done
* Attempt cassette boot
     JSR ACB     ;attempt cassette boot
* Check cartridge for disk boot
     LDA TRAMSZ
     BEQ PRSL    ;if no cartridge
     LDA CARTFG  ;cartridge mode flags
     ROR @
     BCC PRSM    ;if disk boot not desired
* Attempt disk boot
PRSL JSR ADB     ;attempt disk boot
* Initialize peripheral handler loading facility
     JSR PHR     ;poll, load, relocate, init:
* Indicate coldstart complete
PRSM LDA #0
     STA COLDST  ;indicate coldstart complete
* Check cartridge for execution
     LDA TRAMSZ
     BEQ PRSN    ;if no cartridge
     LDA CARTFG  ;cartridge mode flags
     AND #$04
     BEQ PRSN    ;if execution not desired
* Execute cartridge
     JMP (CARTCS) ;execute cartridge
* Exit to power-up display or booted program
PRSN JMP (DOSVEC) ;vector to booted program

* ICS - Initialize Cartridge Software
* ENTRY JSR ICS
ICS  EQU  *
     JMP (CARTAD) ;initialize cartridge software

* PAI - Process ACMI Interrupt
* PAI does nothing
* NOTES
*   Problem: this code is unneeded unless ACMI :
*   option is selected
PAI  EQU *
     CLC
     RTS

* THAV - Table of Handler Vectors
* NOTES THAV is moved to RAM table HATABS
THAV DTA B(PRINTR) ;printer device code
     DTA A(PRINTV) ;printer handler vector table
     DTA B(CASSET) ;cassette device code
     DTA A(CASETV) ;cassette handler vector table
     DTA B(SCREDT) ;editor device code
     DTA A(EDITRV) ;editor handler vector table
     DTA B(DISPLY) ;screen device code
     DTA A(SCRENV) ;screen handler vector table
     DTA B(KBD)    ;keyboard device code
     DTA A(KEYBDV) ;keyboard handler vector table
THAL EQU *-THAV    ;length

* BMSG - Boot Error Message
BMSG DTA c'BOOT ERROR',B(EOL)
* Screen Editor Device Specification
SEDS DTA c'E:',B(EOL)

* TIHV - Table of Interrupt Handler Vectors
* NOTES TIHV is moved to RAM table INTABS
TIHV DTA A(RIR)  ;VDSLST - display list NMI vector
     DTA A(XIR)  ;VPRCED - proceed line IRQ vector
     DTA A(XIR)  ;VINTER - interrupt line IRQ vector
     DTA A(XIR)  ;VBREAK - BRK instruction IRQ vector
     DTA A(KIR)  ;VKEYBD - keyboard IRQ vector
     DTA A(IRIR) ;VSERIN - serial input ready IRQ vector
     DTA A(ORIR) ;VSEROR - serial output ready IRQ vector
     DTA A(OCIR) ;VSEROC - serial output complete IRQ vector
     DTA A(XIR)  ;VTIMR1 - POKEY timer 1 IRQ vector
     DTA A(XIR)  ;VTIMR2 - POKEY timer 2 IRQ vector
     DTA A(XIR)  ;VTIMR4 - POKEY timer 4 IRQ vector
     DTA A(IIR)  ;VIMIRQ - immediate IRQ vector
     DTA A(0)    ;CDTMV1 - countdown timer 1 vector
     DTA A(0)    ;CDTMV2 - countdown timer 2 vector
     DTA A(0)    ;CDTMV3 - countdown timer 3 vector
     DTA A(0)    ;CDTMV4 - countdown timer 4 vector
     DTA A(0)    ;CDTMV5 - countdown timer 5 vector
     DTA A(IVNM) ;VVBLKI - immediate VBLANK NMI vector
     DTA A(DVNM) ;VVBLKD - deferred VBLANK NMI vector
TIHL EQU *-TIHV  ;length

* PMI - Perform Miscellaneous Initialization
* NOTES
*   Problem: initial address for sizing RAM sho:
*   $4000 (16K) instead of $2800
PMI  EQU *
* Check for cartridge special execution case
     LDA TRIG3
     ROR @
     BCC PMI1    ;if cartridge not inserted
     LDA CART
     BNE PMI1    ;if not cartridge
     LDA CARTFG  ;cartridge flags
     BPL PMI1    ;if special execution not desired
* Execute cartridge
     JMP (CARTAD)        ;execute cartridge
*    Initialize hardware
PMI1 JSR IHW     ;initialize hardware
* Disable BASIC
     LDA PORTB
     ORA #$02    ;disable BASIC
     STA PORTB   ;update port B memory control
* If warmstart, check previous BASIC status
     LDA WARMST
     BEQ PMI2    ;if coldstart
     LDA BASICF  ;BASIC flag
     BNE PMI4    ;if BASIC not previously enabled
     BEQ PMI3    ;enable BASIC
*    Check OPTION key
PMI2 LDA CONSOL  ;console switches
     AND #$04    ;OPTION key indicator
     BEQ PMI4    ;if OPTION key pressed, do not enable BASIC
* Enable BASIC
PMI3 LDA PORTB
     AND #$FD    ;enable BASIC
     STA PORTB   ;update port B memory control
* Determine size of RAM
PMI4 LDA <$2800 ;initial low address
     TAY              ;offset to first byte of page
     STA TRAMSZ-1     ;set initial low address
     LDA >$2800      ;initial RAM size
     STA TRAMSZ       ;set initial RAM size (high address)
PMI5 LDA (TRAMSZ-1),Y ;first byte of page
     EOR #$FF         ;complement
     STA (TRAMSZ-1),Y ;attempt to store complement
     CMP (TRAMSZ-1),Y
     BNE PMI6         ;if complement not stored
     EOR #$FF         ;original value
     STA (TRAMSZ-1),Y ;attempt to store original value
     CMP (TRAMSZ-1),Y
     BNE PMI6         ;if original value not stored
     INC TRAMSZ       ;increment high address
     BNE PMI5         ;continue
* Exit
PMI6 RTS

* CCE - Check Cartridge Equivalence
* NOTES
*   Problem: this code checksums $BFF0 - $C0EF;:
*   checksum $BF00 - $BFFF
CCE  EQU *
* Initialize
     LDA #0 ;initial sum
     TAX    ;offset to first byte
     CLC
* Checksum 256 bytes of cartridge area
CCE1 ADC $BFF0,X ;add in byte
     INX
     BNE CCE1    ;if not done
* Exit
     CMP CARTCK  ;previous checksum
     STA CARTCK  ;new checksum
     RTS         ;return

* IHW - Initialize Hardware
IHW  EQU *
* Initialize CTIA, ANTIC and POKEY areas
     LDA #0      ;initialization value
     TAX         ;initial offset
     STA PBCTL   ;set for direction register first
IHW1 STA CTIA,X  ;initialize CTIA/GTIA area register
     STA ANTIC,X ;initialize ANTIC area register
     STA POKEY,X ;initialize POKEY area register
     CPX <PORTB
     BEQ IHW2    ;if port B, don't initialize
     STA PIA,X   ;initialize PIA area register
IHW2 INX
     BNE IHW1    ;if not done
* Initialize PIA
     LDA #$3C
     STA PBCTL ;precondition port B outputs
     LDA #$FF
     STA PORTB ;all high
     LDA #$38
     STA PACTL ;select data direction register
     STA PBCTL ;select data direction register
     LDA #$00
     STA PORTA ;all inputs
     LDA #$FF
     STA PORTB ;all outputs
     LDA #$3C
     STA PACTL ;back to port
     STA PBCTL ;back to port
     LDA PORTB ;clear interrupts
     LDA PORTA ;clear interrupts
* Initialize POKEY
     LDA #$22   ;get POKEY out of initialize mode and set ch 4
     STA SKCTL  ;set serial port control
     LDA #$A0   ;pure tone, no volume
     STA AUDC3  ;turn off channel 3
     STA AUDC4  ;turn off channel 4
     LDA #$28   ;clock ch 3 with 179 MHz, ch 4 with ch 3
     STA AUDCTL ;set audio control
     LDA #$FF
     STA SEROUT  ;start bit only
     RTS

* ISW - Initialize Software
ISW  EQU *
* Initialize BREAK key handling
     DEC BRKKEY ;turn off BREAK key flag
     LDA <BIR
     STA BRKKY  ;set BREAK key IRQ routine address
     LDA >BIR
     STA BRKKY+1
* Initialize RAMSIZ and MEMTOP
     LDA TRAMSZ   ;determined size of RAM
     STA RAMSIZ   ;size of RAM
     STA MEMTOP+1 ;high top of memory
     LDA #$00
     STA MEMTOP   ;low top of memory
* Initialize MEMLO
     LDA <INIML ;initial MEMLO address
     STA MEMLO
     LDA >INIML
     STA MEMLO+1
* Initialize device handlers
     JSR EDITRV+12 ;initialize editor handler
     JSR SCRENV+12 ;initialize screen handler
     JSR KEYBDV+12 ;initialize keyboard handler
     JSR PRINTV+12 ;initialize printer handler
     JSR CASETV+12 ;initialize cassette handler
* Initialize various routines
     JSR CIOINV ;initialize CIO
     JSR SIOINV ;initialize SIO
     JSR INTINV ;initialize interrupt handler
     JSR DINITV ;initialize DIO
* Initialize generic parallel device handler
     LDA <PIR
     STA VPIRQ    ;parallel device IRQ routin:
     LDA >PIR
     STA VPIRQ+1
     JSR GPDVV+12 ;initialize parallel device:
* Set status of START key
     LDA CONSOL ;console switches
     AND #$01   ;START key indicator
     EOR #$01   ;START key status
     STA CKEY   ;cassette boot request flag
     RTS

* ADB - Attempt Disk Boot
ADB  EQU *
* Check type of reset
     LDA WARMST
     BEQ ADB1 ;if not warmstart
* Process warmstart
     LDA BOOT? ;successful boot flags
     AND #$01  ;successful disk boot indicator
     BEQ BAI2  ;if disk boot not successful, return
* Initialize disk booted software
     JMP IBS   ;initialize booted software
* Process coldstart
ADB1 LDA #1
     STA DUNIT  ;disk unit number
     LDA #STATC ;status
     STA DCOMND ;command
     JSR DSKINV ;issue command
     BMI BAI2   ;if error, return
* Boot
*    JMP ABI ;attempt boot and initialize

* ABI - Attempt Boot and Initialize
ABI  EQU *
     LDA >1
     STA DAUX2
     LDA <1          ;sector number
     STA DAUX1
     LDA <[CASBUF+3] ;buffer address
     STA DBUFLO
     LDA >[CASBUF+3]
     STA DBUFHI
*    JMP BAI ;boot and initialize

* BAI - Boot and Initialize
BAI  EQU *
* Read first sector
     JSR GNS ;get next sector
     BPL CBI ;if no error, complete boot and initialize
* Process error
BAI1 JSR DBE   ;display boot error message
     LDA CASSBT
     BEQ ABI   ;if not cassette boot, try again
* Exit
BAI2 RTS

* CBI - Complete Boot and Initialize
CBI  EQU *
* Transfer flags
     LDX #3
CBI1 LDA CASBUF+3,X ;byte from buffer
     STA DFLAGS,X   ;flag byte
     DEX
     BPL CBI1       ;if not done
* Transfer sector
     LDA BOOTAD
     STA RAMLO      ;set boot address
     LDA BOOTAD+1
     STA RAMLO+1
     LDA CASBUF+7
     STA DOSINI     ;establish initializtion address
     LDA CASBUF+8
     STA DOSINI+1
CBI2 LDY #127       ;offset to last byte of sector
CBI3 LDA CASBUF+3,Y ;byte of sector buffer
     STA (RAMLO),Y  ;byte of boot program
     DEY
     BPL CBI3       ;if not done
* Increment loader buffer pointer
     CLC
     LDA RAMLO
     ADC #$80
     STA RAMLO
     LDA RAMLO+1
     ADC #0
     STA RAMLO+1 ;increment boot loader buffer pointer
* Decrement and check number of sectors
     DEC DBSECT ;decrement number of sectors
     BEQ CBI5   ;if no more sectors
* Get next sector
     INC DAUX1 ;increment sector number
CBI4 JSR GNS   ;get next sector
     BPL CBI2  ;if status OK
* Process error
     JSR DBE   ;display boot error message
     LDA CASSBT
     BNE BAI1  ;if cassette, start over
     BEQ CBI4  ;try sector again
* Clean up
CBI5 LDA CASSBT
     BEQ CBI6  ;if not cassette boot
     JSR GNS   ;get EOF record (but do not use it)
* Execute boot loader
CBI6 JSR EBL   ;execute boot loader
     BCS BAI1  ;if bad boot, try again
* Initialize booted software
     JSR IBS   ;initialize booted software
     INC BOOT? ;indicate boot success
     RTS       ;return

* EBL - Execute Boot Loader
EBL  EQU *
* Move boot loader start address to RAMLO
     CLC
     LDA BOOTAD
     ADC #6
     STA RAMLO   ;boot loader start address
     LDA BOOTAD+1
     ADC #0
     STA RAMLO+1
* Execute boot loader
     JMP (RAMLO) ;execute boot loader

* IBS - Initialize Booted Software
IBS  EQU *
     JMP (DOSINI) ;initialize booted software

* DBE - Display Boot Error Message
* NOTES
*   Problem: bytes wasted by LDX/TXA and LDY/TYA
*   combinations
DBE  EQU *
* Set up IOCB
     LDX <BMSG  ;boot error message
     LDY >BMSG
     TXA
     LDX #SEIOCB ;screen editor IOCB index
     STA ICBAL,X ;low buffer address
     TYA
     STA ICBAH,X ;high buffer address
     LDA #PUTREC
     STA ICCOM,X ;command
     LDA #$FF
     STA ICBLL,X ;buffer length
* Perform CIO
     JMP CIOV    ;vector to CIO, return

* GNS - Get Next Sector
GNS  EQU *
* Check type of boot
     LDA CASSBT
     BEQ GNS1  ;if not cassette boot
* Read block from cassette
     JMP RBLOKV ;vector to read cassette block routine, return
* Read sector from disk
GNS1 LDA #READ
     STA DCOMND ;command
     LDA #1     ;drive number 1
     STA DUNIT  ;set drive number
     JMP DSKINV ;vector to DIO, return

* ACB - Attempt Cassette Boot
ACB  EQU *
* Check type
     LDA WARMST ;warmstart flag
     BEQ ACB1   ;if coldstart
* Perform warmstart procedures
     LDA BOOT? ;successful boot flags
     AND #$02  ;successful cassette boot indicator
     BEQ ACB2  ;if cassette boot not successful
     JMP ACB3  ;initialize cassette
* Perform coldstart procedures
ACB1 LDA CKEY ;cassette boot request flag
     BEQ ACB2 ;if cassette boot not requested, return
* Boot cassette
     LDA #$80
     STA FTYPE  ;set long IRG type
     INC CASSBT ;set cassette boot flag
     JSR CSOPIV ;open cassette for input
     JSR BAI    ;boot and initialize
     LDA #0
     STA CASSBT ;clear cassette boot flag
     STA CKEY   ;clear cassette boot request flag
     ASL BOOT?  ;indicate successful cassette boot
     LDA DOSINI
     STA CASINI ;cassette software initialization address
     LDA DOSINI+1
     STA CASINI+1
* Exit
ACB2 RTS
* Initialize cassette booted program
ACB3 JMP (CASINI) ;initialize cassette booted program
