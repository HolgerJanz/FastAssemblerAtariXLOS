* SUBTTL 'Self-test, Part 3.1'

* STH - Self-test Hardware
* ENTRY   JSR STH
* NOTES
*   Problem: this is superfluous; SLFTSV could vector to
*   EST.
STH  EQU *
     JMP EST ;execute self-test

* EMS - Execute Memory Self-test
* ENTRY   JSR EMS
EMS  EQU *
     JSR IST ;initialize self-test
     JMP STM ;self-test memory

* EST - Execute Self-test
* ENTRY   JSR EST
EST  EQU *
     JSR IST ;initialize self-test
*    JMP SEL ;self-test

* SEL - Self-test
* ENTRY   JSR SEL
SEL  EQU *
* Initialize
     LDA #0
     STA STTIME  ;clear main screen timeout timer
     STA STTIME+1
     STA STAUT   ;clear auto-mode flag
     STA AUDCTL  ;initialize audio control register
     LDA #$03    ;initialize POKEY
     STA SKCTL   ;serial port control
     JSR SAS     ;silence all sounds
     LDA #$40    ;disable DLI
     STA NMIEN   ;NMI enable
     LDX #0      ;main screen colors
     JSR SUC     ;set up colors
     LDX <DISL1  ;display list for main screen
     LDY >DISL1
     JSR SDL     ;set up display list
     LDA <PMD    ;process main screen DLI routine
     STA VDSLST  ;display list NMI address
     LDA >PMD
     STA VDSLST+1
     LDX #3*4    ;main screen bold lines
     LDA #$AA    ;color 1
     JSR SVR     ;set value in range
* Wait for all screen DLI's to clear and for VBLANK
     LDX #0
SEL1 STX WSYNC   ;wait for HBLANK synchronization
     INX
     BNE SEL1    ;if not done waiting
* Wait until beam close to top (main screen DLI near)
SEL2 LDA VCOUNT
     CMP #24
     BCS SEL2    ;if not done waiting
* Preset for self-test type determination
     LDA #$10    ;initially select memory test
     STA STPASS  ;pass indicator
     LDA #$C0    ;enable DLI
     STA NMIEN
* Determine type of self-test
SEL3 LDA CONSOL  ;console switches
     AND #$01    ;START key indicator
     BNE SEL3    ;if START key not pressed
     LDA #$FF    ;clear character
     STA CH
     LDA STSEL   ;selection
     AND #$0F    ;selection
     CMP #$01    ;memory test indicator
     BEQ SEL5    ;if memory test
     CMP #$02
     BEQ SEL6    ;if audio-visual test
     CMP #$04
     BEQ SEL7    ;if keyboard test
* Self-test all
SEL4 LDA #$88    ;indicate all tests
     STA STSEL   ;selection
     LDA #$FF    ;auto-mode indicator
     STA STAUT   ;auto-mode flag
* Self-test memory
SEL5 JMP STM     ;self-test memory
* Self-test audio-visual
SEL6 JMP STV     ;self-test audio-visual
* Self-test keyboard
SEL7 JMP STK     ;self-test keyboard

* IST - Initialize Self-test
* ENTRY   JSR IST
IST  EQU *   
     LDA #$11   ;indicate memory test
     STA STSEL  ;selection
     LDA #$21
     STA SDMCTL ;select small size playfield
     LDA #$C0
     STA NMIEN  ;enable DLI
     LDA #$41
     STA STJMP  ;ANTIC jump instruction
     LDA #$FF   ;clear code indicator
     STA CH     ;key code
     RTS        ;return

* SDL - Set Up Display List
* ENTRY   JSR SDL
SDL  EQU *    
     STA STKST   ;keyboard self-test flag
     TYA
     PHA         ;save high address
     TXA
     PHA         ;save low address
     LDA #0
     STA SDMCTL  ;DMACTL (DMA control) shadow
     STA HELPFG  ;HELP key flag
     LDA <POD    ;process DLI routine
     STA VDSLST
     LDA >POD
     STA VDSLST+1
     LDX #0*4    ;screen memory
     TXA         ;value is 0
     JSR SVR     ;set value in range
     PLA         ;saved low address
     TAX
     PLA         ;saved high address
     TAY
     STX SDLSTL  ;low display list address
     STX STJMP+1 ;low display list address
     STY SDLSTH  ;high display list address
     STY STJMP+2 ;high display list address
     LDA #$21
     STA SDMCTL
     RTS         ;return

* PMD - Process Main Screen DLI
* 1) .IF MAIN SCREEN IS ON FOR MORE than FIVE MINUTES
* THEN 'ALL TESTS' SELECTION IS SELECTED AND EXECUTED
* 2) COLORS FOR CURRENTLY SELECTED CHOICE AND THE
* NON-SELECTED CHOICES ARE DISPLAYED ON FLY
* 3) SELECTION PROCESS IS HANDLED
* ENTRY   JMP PMD
* EXIT
*   Exits via RTI
PMD  EQU *    
* Initialize
     PHA         ;save A
     TXA
     PHA         ;save X
* Check for 4th time
PMD1 LDX #$7A    ;assume non-selected color
     LDA STPASS  ;pass indicator
     CMP #$01    ;4th time indicator
     BEQ PMD3    ;if 4th time
* Check for selection
     AND #$01    ;selection indicatorn
     BEQ PMD2    ;if selected
* Increment and check blink counter
     INC STBL    ;increment blink counter
     LDA STBL    ;blink counter
     AND #$20    ;blink indicator
     BEQ PMD2    ;if not to blink
     LDX #$2C    ;use selected color
* Set color
PMD2 STX WSYNC   ;wait for HBLANK synchronization
     STX COLPF0  ;playfield 0 color
     CLC
     ROR STPASS  ;advance pass indicator
     LDA #0
     STA ATRACT
* Exit
     PLA
     TAX         ;restore X
     PLA         ;restore A
     RTI         ;return
* Check for SELECT previously pressed
PMD3 LDA STSPP   ;SELECT previously pressed  flag
     BNE PMD4    ;if SELECT previously pressed
* Check for SELECT pressed
     LDA CONSOL  ;console switches
     AND #$02    ;SELECT key indicator
     BNE PMD5    ;if SELECT not pressed, exit
* Process SELECT pressed
     LDA STSEL   ;current selection
     ROL @
     ROL STSEL   ;next selection
     LDA #$20    ;blink indicator
     STA STBL    ;blink counter
     LDA #$FF    ;SELECT previously pressed indicator
     STA STSPP   ;SELECT previously pressed flag
     BNE PMD5
* Process SELECT previously pressed
PMD4 LDA CONSOL  ;console switches
     AND #$02    ;SELECT key indicator
     BEQ PMD5    ;if SELECT still pressed
     LDA #0      ;SELECT not previously pressed indicator
     STA STSPP   ;SELECT previously pressed flag
* ???every 4th time???
PMD5 LDA STSEL   ;selection
     AND #$0F
     ORA #$10    ;reset indicate memory test
     STA STPASS  ;pass indicator
* Advance main screen timer
     INC STTIME
     BNE PMD6    ;if low not zero
     INC STTIME+1
* Check main screen timer
PMD6 LDA STTIME+1
     CMP #250    ;main screen timeout
     BNE PMD7    ;if main screen timed out
* Process main screen timeout
     CLI
     JMP SEL4    ;self-test all
* Continue
PMD7 JMP PMD1    ;continue

* DISL1 - Display List for Main Screen
DISL1 DTA B($70,$70,$70,$70,$70)
      DTA B($47)
      DTA A(SMEM1)
      DTA B($70,$70,$70)
      DTA B($4E)
      DTA A(ST3000)
      DTA B($70)
      DTA B($F0)
      DTA B($C6)
      DTA A(SMEM2)
      DTA B($70,$86)
      DTA B($70,$86)
      DTA B($70,$06)
      DTA B($70,$70)
      DTA B($4E)
      DTA A(ST3000)
      DTA B($70,$70,$70)
      DTA B($42)
      DTA A(SMEM3)
      DTA B($41)
      DTA A(DISL1)

* SMEM1 - "SELF TEST" Text
SMEM1 DTA B($00,$00,$00,$00)
      DTA B($33,$25,$2C,$26) ;"SELF"
      DTA B($00)
      DTA B($34,$25,$33,$34) ;"TEST"
      DTA B($00,$00,$00)

* SMEM2 - "MEMORY AUDIO-VISUAL KEYBOARD ALL TESTS" Text
SMEM2 DTA B($00,$00)
      DTA B($2D,$25,$2D,$2F,$32,$39) ;"MEMORY"
      DTA B($00,$00,$00,$00,$00)
      DTA B($00,$00,$00,$00,$00)
      DTA B($21,$35,$24,$29,$2F)     ;"AUDIO"
      DTA B($0D)                     ;"-"
      DTA B($36,$29,$33,$35,$21,$2C) ;"VISUAL"
      DTA B($00,$00,$00,$00)
      DTA B($2B,$25,$39,$22,$2F,$21,$32,$24) ;"KEYBOARD"
      DTA B($00,$00,$00,$00,$00,$00,$00,$00)
      DTA B($21,$2C,$2C)         ;"ALL"
      DTA B($00)
      DTA B($34,$25,$33,$34,$33) ;"TESTS"
      DTA B($00,$00,$00,$00,$00)

* SMEM3 - "SELECT,START OR RESET" Text
SMEM3 DTA B($00,$00,$00,$00)
      DTA B($42)
      DTA B($B3,$A5,$AC,$A5,$A3,$B4) ;"SELECT"
      DTA B($56)
      DTA B($0C)                 ;","
      DTA B($42)
      DTA B($B3,$B4,$A1,$B2,$B4) ;"START"
      DTA B($56)
      DTA B($2F,$32)             ;"OR"
      DTA B($42)
      DTA B($B2,$A5,$B3,$A5,$B4) ;"RESET"
      DTA B($56)
      DTA B($00,$00,$00)

* DISL2 - Display List for Memory Test
DISL2 DTA B($70,$70,$70)
      DTA B($46)
      DTA A(ST3000)
      DTA B($70)
      DTA B($70,$06)
      DTA B($70,$08)
      DTA B($70)
      DTA B($70,$06)
      DTA B($70,$08)
      DTA B($70,$08)
      DTA B($70,$08)
      DTA B($70,$08)
      DTA B($70,$70,$70)
      DTA B($01)
      DTA A(DISL3)

* DISL3 - Display List for Exit Text
DISL3 DTA B($A0,$40)
      DTA B($42)
      DTA A(SMEM4)
      DTA B($01)
      DTA A(STJMP)

* SMEM4 - "RESET OR HELP TO EXIT" Text
SMEM4 DTA B($00,$00,$00,$00,$00)
      DTA B($42)
      DTA B($B2,$A5,$B3,$A5,$B4) ;"RESET"
      DTA B($56)
      DTA B($2F,$32)         ;"OR"
      DTA B($42)
      DTA B($A8,$A5,$AC,$B0) ;"HELP"
      DTA B($56)
      DTA B($34,$2F)         ;"TO"
      DTA B($00)
      DTA B($25,$38,$29,$34) ;"EXIT"
      DTA B($00,$00,$00,$00,$00)

* DISL4 - Display List for Keyboard Test
DISL4 DTA B($70,$70,$70,$70)
      DTA B($46)
      DTA A(ST3000)
      DTA B($70,$70,$70)
      DTA B($70,$02)
      DTA B($70)
      DTA B($70,$02)
      DTA B($70,$02)
      DTA B($70,$02)
      DTA B($70,$02)
      DTA B($70,$02)
      DTA B($70,$70)
      DTA B($01)
      DTA A(DISL3)

* DISL5 - Display List for Audio-visual Test
DISL5 DTA B($70,$70,$70,$70)
      DTA B($46)
      DTA A(SMEM5)
      DTA B($70,$06)
      DTA B($70,$70)
      DTA B($4B)
      DTA A(ST3100)
      DTA B($0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B)
      DTA B($0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B)
      DTA B($0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B)
      DTA B($0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B)
      DTA B($0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B)
      DTA B($0B,$0B)
      DTA B($70)
      DTA B($46)
      DTA A(ST3000)
      DTA B($70)
      DTA B($01)
      DTA A(DISL3)

* SMEM5 - "AUDIO-VISUAL TEST" Text
SMEM5 DTA B($00,$00)
      DTA B($21,$35,$24,$29,$2F)     ;"AUDIO"
      DTA B($0D)                     ;"-"
      DTA B($36,$29,$33,$35,$21,$2C) ;"VISUAL"
      DTA B($00,$00,$00,$00)
      DTA B($00,$00,$00,$00)
      DTA B($34,$25,$33,$34)         ;"TEST"
      DTA B($00,$00,$00,$00,$00,$00)

* STM - Self-test Memory
* STM verifies ROM and RAM by verifying the ROM checksums and
* writing and reading all possible values to each byte of RAM.
* ENTRY   JSR STM
* NOTES
*   Problem: searches beyond end of TMNT.
STM  EQU *
* Initialize
     LDX <DISL2 ;memory test display list
     LDY >DISL2
     LDA #0     ;indicate not keyboard self-test
     JSR SDL    ;set up display list
     LDX #1     ;memory test colors
     JSR SUC    ;set up colors
     LDX #0     ;offset to "MEMORY TEST   ROM" test
     JSR SSM    ;set screen memory
     LDX #1     ;offset to "RAM" text
     JSR SSM    ;set screen memory
* Test first 8K ROM
STM1 LDA ST3020
     CMP #$AA   ;color 1 for failure
     BEQ STM4   ;if first 8K ROM already failed
     LDA #$55   ;color 0 for test
     JSR DFS    ;display first ROM status
     JSR DMW    ;delay a middling while
     JSR VFR    ;verify first 8K ROM
     BCS STM2   ;if ROM failed
     LDA #$FF   ;color 2 for success
     JMP STM3
STM2 LDA #$AA   ;color 1 for failure
STM3 JSR DFS    ;display first ROM status
* Test second 8K ROM
STM4 LDA ST3024
     CMP #$AA   ;color 1 for failure
     BEQ STM7   ;if second 8K ROM already failed
     LDA #$55   ;color 0 for test
     JSR DSS    ;display second ROM status
     JSR DMW    ;delay a middling while
     JSR VSR    ;verify second 8K ROM
     BCS STM5   ;if ROM failed
     LDA #$FF   ;color 2 for success
     JMP STM6
STM5 LDA #$AA   ;color 1 for failure
STM6 JSR DSS    ;display second ROM status
* Test RAM
STM7 LDA #$C0   ;mask for left side of a screen byte
     STA STSMM
     LDA #$04   ;initially select LED 1 off
     STA STLM   ;LED mask
     LDA #0
     STA STSMP  ;initialize ???
     STA STPAG  ;initialize current page
     STA STPAG+1
     STA ST1K   ;initialize current 1K to test
* Test 1K of RAM
STM8 LDX STSMP  ;screen memory pointer
     LDA ST3038,X
     AND STSMM
     CMP #$80
     BEQ STM17  ;if already failed
     CMP #$08
     BEQ STM17  ;if already failed
     LDA #$44   ;color 0 for test
     JSR DRS    ;display RAM block status
     LDA STLM   ;LED mask
     JSR SLD    ;set LED's
     LDA STLM   ;current LED mask
     EOR #$0C   ;complement LED's selected
     STA STLM   ;update LED mask
* Check for memory not to test
     LDX <TMNTL-1+2 ;2 bytes beyond last byte of table
STM9 LDA TMNT,X  ;range to test
     CMP STPAG+1 ;high current page
     BEQ STM15   ;if not to test, indicate success
     DEX
     BPL STM9    ;if not done
* Test 1K of RAM.
     LDA #4      ;number of pages to test
     STA STPC    ;page count
* Write initial list to page
STM10 LDX #0 ;initial value to write
* Write list to page
STM11 LDY #0 ;offset to first byte of page
STM12 TXA
     STA (STPAG),Y ;byte of page
     INX
     INY
     BNE STM12     ;if not done writing page
* Verify list written to page
     STX STMVAL     ;first correct value to test
     LDY #0         ;offset to first byte of page
STM13 LDA (STPAG),Y ;byte of page
     CMP STMVAL     ;correct value
     BNE STM14      ;if not correct value
     INC STMVAL     ;increment value to test
     INY
     BNE STM13      ;if not done verifying page
* Increment and test initial value to write
     INX            ;increment initial value to write
     BNE STM11      ;if not done, write another list
* Decrement and test page counter
     INC STPAG+1    ;increment high current page
     DEC STPC       ;decrement page count
     BNE STM10      ;if not done testing pages
     BEQ STM16      ;indicate success
* Display failure
STM14 JSR DMW       ;delay a middling while
     LDA #$88       ;color 1 for failure
     JSR DRS        ;display RAM block status
     JMP STM17
* Delay for simulating test of memory not to test
STM15 JSR DLW       ;delay a long while
* Display success
STM16 LDA #$CC      ;color 2 for success
     JSR DRS        ;display RAM block status
STM17 LDA STSMM
     BMI STM20
     LDA #$C0
     STA STSMM
     INC STSMP   ;increment screen memory pointer
STM18 CLC
     LDA ST1K    ;current 1K to test
     ADC >$0400  ;add 1K
     STA STPAG+1 ;high current page
     STA ST1K    ;update current 1K to test
     CMP RAMSIZ  ;RAM size
     BNE STM8    ;if not done testing RAM
* Check for auto-mode
     LDA STAUT   ;auto-mode flag
     BNE STM19   ;if auto-mode, perform audio-visual test
* Test memory again.
     JMP STM1    ;test memory again
* Process auto-mode.
STM19 LDA #$0C   ;indicate LED 1 and 2 off
     JSR SLD     ;set LED's
     JSR DLW     ;delay a long while
     JMP STV     ;self-test audio-visual
STM20 LDA #$0C
     STA STSMM
     BNE STM18

* DFS - Display First ROM Status
* ENTRY   JSR DFS
DFS  EQU * 
     LDX #1*4 ;first 8K ROM display
     JSR SVR  ;set value in range
     AND #$FC
     STA ST3020+3
     RTS      ;return

* DSS - Display Second ROM Status
* ENTRY   JSR DSS
DSS  EQU * 
     LDX #2*4 ;second 8K ROM display
     JSR SVR  ;set value in range
     AND #$FC
     STA ST3024+3
     RTS      ;return

* SLD - Set LED's
* ENTRY   JSR SLD
*   A = LED mask (bit 3 - LED 2, bit 2 - LED 1)
SLD  EQU *   
     STA STTMP5 ;save LED mask
     LDA PORTB
     AND #$F3   ;clear LED control
     ORA STTMP5 ;set LED control according to mask
     STA PORTB  ;update port B memory control
     RTS        ;return

* DMW - Delay a Middling While
* ENTRY   JSR DMW
DMW  EQU *
     LDX #60 ;60-VBLANK delay
     BNE DAW ;delay a while

* DLW - Delay a Long While
* ENTRY   JSR DLW
DLW  EQU * 
     LDX #150 ;150-VBLANK delay
*    JMP DAW  ;delay a while, return

* DAW - Delay a While
* ENTRY   JSR     DAW
DAW  EQU *  
DAW1 LDY #$FF  ;initialize inner loop counter
DAW2 STY WSYNC ;wait for HBLANK synchronization
     DEY
     BNE DAW2  ;if inner loop not done
     DEX
     BNE DAW1  ;if outer loop not done
     RTS       ;return

* DRS - Display RAM Block Status
* ENTRY   JSR DRS
DRS  EQU *
     PHA         ;save color
     LDX STSMP
     LDA STSMM
     EOR #$FF    ;complement
     AND ST3038,X
     STA ST3038,X
     PLA         ;saved color
     AND STSMM
     ORA ST3038,X
     STA ST3038,X
     RTS         ;return

* POD - Process Other DLI's
* POD turns the last line on the screen into white on black,
* handles keyboard self-test display of console switches, handles
* HELP key for exit, and ensures no attract-mode.
* ENTRY   JMP POD
* EXIT
*   Exits via RTI
POD  EQU *
* Initialize
     PHA   ;save A
* Select colors
     LDA #$0C   ;white color
     STA COLPF1 ;playfield 1 color
     LDA COLOR4 ;background color
     STA COLPF2 ;playfield 2 color
* Ensure no attract-mode
     LDA #0     ;no attract-mode
     STA ATRACT ;attract-mode timer/flag
* Check HELP key
     LDA HELPFG ;HELP key flag
     BEQ POD1   ;if HELP not pressed
* Process HELP key.
     LDA #0     ;HELP key not pressed indicator
     STA HELPFG ;HELP key flag
     LDA #$0C   ;LED's off
     JSR SLD    ;set LED's
     CLI
     JMP SEL    ;start over with main screen
* Check for keyboard self-test.
POD1 LDA STKST  ;keyboard self-test flag
     BEQ PODA   ;if not keyboard self-test, exit
* Set display of console switches pressed.
     LDA CONSOL ;console switches
     AND #$01   ;START key indicator
     BEQ POD2   ;if START key pressed
     LDA #$B3
     BNE POD3   ;set display
POD2 LDA #$33
POD3 STA ST301C ;set START key display
     LDA CONSOL ;console switches
     AND #$02   ;SELECT key indicator
     BEQ POD4   ;if SELECT key pressed
     LDA #$F3
     BNE POD5   ;set display
POD4 LDA #$73
POD5 STA ST301E ;set SELECT key display
     LDA CONSOL ;console switches
     AND #$04   ;OPTION key indicator
     BEQ POD6   ;if OPTION key pressed
     LDA #$AF
     BNE POD7   ;set display
POD6 LDA #$2F
POD7 STA ST3020 ;set OPTION key display
* Sound tone if console switches pressed.
     LDA CONSOL ;console switches
     AND #$07   ;key indicators
     CMP #$07   ;no keys pressed
     BEQ POD8   ;if no keys pressed
     LDA #100   ;frequency
     STA AUDF2  ;set frequency of voice 2
     LDA #$A8   ;pure tone, half volume
     BNE POD9   ;set control of voice 2
POD8 LDA #0     ;zero volume
POD9 STA AUDC2  ;set control of voice 2
* Exit
PODA PLA        ;restore A
     RTI        ;return
