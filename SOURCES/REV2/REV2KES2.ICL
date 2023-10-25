* SUBTTL 'Keyboard, Editor and Screen Handler, Part 2'

* SIN - Initialize Screen
SIN  EQU *
     LDA #$FF   ;clear code indicator
     STA CH     ;key code
     LDA RAMSIZ ;size of RAM
     STA RAMTOP ;RAM size
     LDA #$40   ;CAPS lock indicator
     STA SHFLOK ;shift/control lock flags
     LDA <TCKD  ;table of character key def:
     STA KEYDEF ;key definition table addre:
     LDA >TCKD
     STA KEYDEF+1
     LDA <TFKD  ;table of function key defi:
     STA FKDEF  ;function key definition ta:
     LDA >TFKD
     STA FKDEF+1
     RTS

* SOP - Perform Screen OPEN
SOP  EQU *
SOPV EQU *-1
* Check mode
     LDA ICAX2Z
     AND #$0F
     BNE COC ;if not mode 0, complete OPEN command
* Process mode 0
*    JMP EOP ;perform editor OPEN, return

* EOP - Perform Editor OPEN
EOP  EQU *
EOPV EQU *-1
     LDA ICAX1Z
     AND #$0F
     STA ICAX1Z
     LDA #0
*    JMP COC ;complete OPEN command, return

* COC - Complete OPEN Command
* ENTRY   JSR COC
*   A = mode
COC  EQU *
* Check mode
     STA DINDEX ;save mode
     CMP #16
     BCC COC1   ;if mode within range
* Process invalid mode
     LDA #BADMOD
     JMP COCH
* Initialize for OPEN
COC1 LDA >DCSORG ;high domestic character se:
     STA CHBAS   ;character set base
     LDA >ICSORG ;high international charact:
     STA CHSALT  ;alternate character set ba:
     LDA #2
     STA CHACT
     STA SDMCTL  ;turn off DMA
     LDA #SUCCES
     STA DSTAT   ;clear status
     LDA #$C0    ;enable IRQ
     ORA POKMSK
     STA POKMSK
     STA IRQEN
* Set DLI status
     LDA #$40 ;disable DLI
     STA NMIEN
     BIT FINE
     BPL COC2 ;if not fine scrolling (VBL:
     LDA <FDL
     STA VDSLST ;DLI vector
     LDA >FDL
     STA VDSLST+1
     LDA #$C0
COC2 STA NMIEN
* Clear control
     LDA #0
     STA TINDEX ;clear text index (must alw:
     STA ADRESS
     STA SWPFLG
     STA CRSINH
* Set initial tab stops
     LDY #14  ;offset to last byte of bit:
     LDA #$01 ;tab stop every 8 character:
COC3 STA TABMAP,Y ;set tab stop
     DEY
     BPL COC3 ;if not done
* Load initialize color register shadows
     LDX #4       ;offset to last color regis:
COC4 LDA TDSC,X   ;default screen color
     STA COLOR0,X ;set color register shadow
     DEX
     BPL COC4 ;if not done
* Set up
     LDY RAMTOP ;(high) RAM size
     DEY        ;decrement (high) RAM size
     STY TXTMSC+1
     LDA <[$0000-160] ;low RAM size = 160
     STA TXTMSC
     LDX DINDEX ;mode
     LDA TAGM,X ;convert to ANTIC code
     STA HOLD1  ;ANTIC code
     LDA RAMTOP ;(high) RAM size
     STA ADRESS+1
* Allocate memory
     LDY TSMA,X ;number of 40-byte blocks t:
COC5 LDA #40    ;40 bytes
     JSR DBS    ;perform double byte subtra:
     DEY
     BNE COC5   ;if not done
* Clear GTIA modes
     LDA GPRIOR
     AND #$3F ;clear GTIA modes
     STA OPNTMP+1
     TAY
* Determine mode
     CPX #8
     BCC COC7 ;if mode < 8
     CPX #15
     BEQ COC6 ;if mode 15
     CPX #12
     BCS COC7 ;if mode >= 12
* Process mode 9, 10 and 11.
     TXA ;mode
     ROR @
     ROR @
     ROR @
     AND #$C0 ;extract 2 low bits (in 2 h:
     ORA OPNTMP+1
     TAY
* Establish line boundary at X000
COC6 LDA #16 ;subtract 16 for page bound
     JSR DBS ;perform double byte subtract
* Check for mode 11
     CPX #11
     BNE COC7 ;if mode 11
* Set GTIA luminance
     LDA #6     ;GTIA luminance value
     STA COLOR4 ;background color
* Set new priority
COC7 STY GPRIOR ;new priority
* Set memory scan counter
     LDA ADRESS ;memory scan counter
     STA SAVMSC ;save memory scan counter
     LDA ADRESS+1
     STA SAVMSC+1
* Wait for VBLANK.
COC8 LDA VCOUNT
     CMP #$7A
     BNE COC8 ;if VBLANK has not occured
* Put display list under RAM
     JSR DSD    ;perform double byte single:
     LDA TDLV,X ;display list vulnerability
     BEQ COC9   ;if not vulnerable
     LDA #$FF
     STA ADRESS
     DEC ADRESS+1 ;drop down 1 page
COC9 JSR DDD      ;perform double byte double:
     LDA ADRESS   ;end of display list
     STA SAVADR   ;save address
     LDA ADRESS+1
     STA SAVADR+1
* Set up
     LDA #$41 ;ANTIC wait for VBLANK and :
     JSR SDI  ;store data indirect
     STX OPNTMP
     LDA #24
     STA BOTSCR ;screen bottom
* Check for modes 9 ,10 and 11
     LDA DINDEX ;mode
     CMP #12
     BCS COCA ;if mode >= 12, mixed mode :
     CMP #9
     BCS COCC ;if mode >= 9, mixed mode n:
* Check for mixed mode
COCA LDA ICAX1Z
     AND #MXDMOD
     BEQ COCC ;if not mixed mode
* Process mixed mode
     LDA #4
     STA BOTSCR ;screen bottom
     LDX #2
     LDA FINE
     BEQ COCB ;if not fine scrolling
     JSR SSE  ;set scrolling display list:
COCB LDA #$02
     JSR SDF  ;store data indirect for fi:
     DEX
     BPL COCB ;if not done
* Reload MSC for text
     LDY RAMTOP ;(high) RAM size
     DEY        ;decrement (high) RAM size
     TYA
     JSR SDI          ;store data indirect
     LDA <[$0000-160] ;low RAM size = 160
     JSR SDI  ;store data indirect
     LDA #$42 ;fine scrolling
     JSR SDF  ;store data indirect
     CLC
     LDA #MXDMOD
     ADC OPNTMP
     TAY
     LDX TDLE,Y
     BNE COCD
* Check mode
COCC LDY OPNTMP
     LDX TDLE,Y ;number of display list ent:
     LDA DINDEX ;mode
     BNE COCD   ;if not mode 0
* Check for fine scrolling
     LDA FINE ;fine scrolling flag
     BEQ COCD ;if not fine scrolling
* Process fine scrolling
     JSR SSE ;set scrolling display list:
     LDA #$22
     STA HOLD1
* Continue
COCD LDA HOLD1
     JSR SDI  ;store data indirect
     DEX
     BNE COCD ;if not done
* Determine mode
     LDA DINDEX ;mode
     CMP #8
     BCC COCG ;if mode < 8
     CMP #15
     BEQ COCE ;if mode 15
     CMP #12
     BCS COCG ;if mode >= 12
* Process modes 8, 9, 10, 11 and 15
COCE LDX #93    ;remaining number of DLE's
     LDA RAMTOP ;(high) RAM size
     SEC
     SBC >$1000 ;subtract 4K
     JSR SDI    ;store data indirect
     LDA <$0000
     JSR SDI    ;store data indirect
     LDA HOLD1  ;ANTIC MSC code
     ORA #$40
     JSR SDI   ;store data indirect
COCF LDA HOLD1 ;remaining DLE's
     JSR SDI   ;store data indirect
     DEX
     BNE COCF  ;if DLE's remain
* Complete display list with LMS
COCG LDA SAVMSC+1 ;high saved memory scan cou:
     JSR SDI      ;store data indirect
     LDA SAVMSC   ;low saved memory scan coun:
     JSR SDI      ;store data indirect
     LDA HOLD1
     ORA #$40
     JSR SDI      ;store data indirect
     LDA #$70     ;8 blank lines
     JSR SDI      ;store data indirect
     LDA #$70     ;8 blank lines
     JSR SDI      ;store data indirect
     LDA ADRESS   ;display list address
     STA SDLSTL   ;save display list address
     LDA ADRESS+1
     STA SDLSTL+1
     LDA #$70     ;8 blank lines
     JSR SDI      ;store data indirect
     LDA ADRESS   ;display list address
     STA MEMTOP   ;update top of memory
     LDA ADRESS+1
     STA MEMTOP+1
     LDY #1       ;offset
     LDA SDLSTL   ;saved display list address
     STA (SAVADR),Y
     INY
     LDA SDLSTL+1
     STA (SAVADR),Y
* Check status
     LDA DSTAT ;status
     BPL COCI  ;if no error
* Process error
COCH STA DERRF ;screen OPEN error flag
     JSR EOP   ;perform editor OPEN
     LDA DERRF ;restore status
     LDY #0    ;no screen OPEN error indic:
     STY DERRF ;screen OPEN error flag
     TAY       ;status
     RTS
* Check clear inhibit
COCI LDA ICAX1Z
     AND #$20 ;extract clear inhibit bit
     BNE COCJ ;if clear inhibited
* Clear screen
     JSR CSC    ;clear screen
     STA TXTROW ;set cursor at top row
     LDA LMARGN ;left margin
     STA TXTCOL ;set cursor at left margin
* Exit
COCJ LDA #$22 ;turn on DMA control
     ORA SDMCTL
     STA SDMCTL
     JMP SECC ;set exit conditions

* SGB - Perform Screen GET-BYTE
SGB  EQU *
SGBV EQU *-1
     JSR CCR ;check cursor range
     JSR GDC ;get data under cursor
     JSR CIA ;convert internal character to ATAS:
     JSR SZA ;set zero data and advance cursor
     JMP SST ;perform screen STATUS, return

* GDC - Get Data Under Cursor
GDC  EQU *
     JSR CCA ;convert cursor row/column to addre:
     LDA (ADRESS),Y
     AND DMASK

GDC1 LSR SHFAMT ;shift data down to low bits
     BCS GDC2 ;if done

     LSR @
     BPL GDC1 ;continue shifting

GDC2 STA CHAR
     CMP #0 ;restore flags
F1A3 RTS

* SPB - Perform Screen PUT-BYTE
SPB  EQU *
SPBV EQU *-1
     STA ATACHR
*    JSR ROD ;restore old data under cursor
     CMP #CLS
     BNE SPB1 ;if not clear screen
     JSR CSC ;clear screen
     JMP SECC ;set exit contitions, return
SPB1 JSR CCR ;check cursor range
*    JMP CEL ;check EOL, return

* CEL - Check End of Line
CEL  EQU *
     LDA ATACHR
     CMP #EOL
     BNE CEL1 ;if not EOL
     JSR RWS ;return with scrolling
     JMP SECC ;set exit conditions, return
CEL1 JSR PLO ;plot point
     JSR SEA ;set EOL data and advance cursor
     JMP SECC ;set exit conditions, return

* PLO - Plot Point
PLO  EQU     *
* Wait for start/stop flag clear
PLO0 LDA SSFLAG ;start/stop flag
     BNE PLO0   ;if start/stop flag non-zer:
* Save cursor row/column
     LDX #2       ;offset to last byte
PLO1 LDA ROWCRS,X ;byte of cursor row/column
     STA OLDROW,X ;save byte of cursor row/co:
     DEX
     BPL PLO1     ;if not done
* Convert ATASCII character to internal
     LDA ATACHR
     TAY
     ROL @
     ROL @
     ROL @
     ROL @
     AND #3
     TAX ;index into TAIC
     TYA ;character
     AND #$9F   ;strip off column address
     ORA TAIC,X ;or in new column address
*    JMP SPQ ;display, return

* SPQ - Display
SPQ  EQU *
* Set CHAR
     STA CHAR ;character
* Convert cursor row/column to address
     JSR CCA ;convert cursor row/column
* Shift up to proper position
     LDA CHAR  ;character
SPQ1 LSR SHFAMT
     BCS SPQ2  ;if done
     ASL @
     JMP SPQ1  ;continue shifting
* Update data
SPQ2 AND DMASK
     STA TMPCHR ;save shifted data
     LDA DMASK  ;display mask
     EOR #$FF   ;complement display mask
     AND (ADRESS),Y ;mask off old data
     ORA TMPCHR     ;or in new data
     STA (ADRESS),Y ;update data
     RTS

* SEC - Set Exit Conditions
SECC EQU *
     JSR GDC    ;get data under cursor
     STA OLDCHR
     LDX DINDEX ;mode
     BNE SST    ;if graphics, no cursor

     LDX CRSINH ;cursor inhibit flag
     BNE SST    ;if cursor inhibited

     EOR #$80 ;complement most significant bit
     JSR SPQ  ;display
*    JMP SST  ;perform screen status, return

* SST - Perform Screen STATUS
SST  EQU *
SSTV EQU *-1
     LDY DSTAT ;status
     JMP SST1  ;continue
