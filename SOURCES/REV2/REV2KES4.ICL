* CCA - Convert Cursor Row/Column to Address
CCA  EQU *
     LDX #1
     STX MLTTMP ;initialize
     DEX
     STX ADRESS+1 ;clear high address
     LDA ROWCRS   ;cursor row position
     ASL @ ;2 times row position
     ROL ADRESS+1
     ASL @ ;4 time row position
     ROL ADRESS+1
     ADC ROWCRS ;add to get 5 times row pos
     STA ADRESS
     BCC CCA1
     INC ADRESS+1
CCA1 LDY DINDEX   ;mode
     LDX TLSC,Y   ;left shift count
CCA2 ASL ADRESS   ;ADRESS = ADRESS*X
     ROL ADRESS+1 ;divide
     DEX
     BNE CCA2
     LDA COLCRS+1 ;high cursor column
     LSR @ ;save least significant bit
     LDA COLCRS ;low cursor column
     LDX TRSC,Y ;right shift count
     BEQ CCA4   ;if no shift
CCA3 ROR @ ;roll in carry
     ASL MLTTMP ;shift index
     DEX
     BNE CCA3
CCA4 ADC ADRESS ;add address
     BCC CCA5   ;if no carry
     INC ADRESS+1 ;adjuct high address
CCA5 CLC
     ADC SAVMSC ;add saved memory scan coun:
     STA ADRESS ;update address
     STA OLDADR ;save address
     LDA ADRESS+1
     ADC SAVMSC+1
     STA ADRESS+1
     STA OLDADR+1
     LDX TRSC,Y
     LDA TMSK,X
     AND COLCRS ;and in low cursor column
     ADC OPNTMP
     TAY
     LDA TDSM-1,Y ;display mask
     STA DMASK    ;display mask
     STA SHFAMT
     LDY #0
CCA6 RTS

* SZA - Set Zero Data and Advance Cursor Column
SZA  EQU *
     LDA #0
     BEQ SDA ;set data and advance cursor
*    JMP SEA  ;set EOL Data and Advance Cursor Column

* SEA - Set EOL Data and Advance Cursor Column
SEA  EQU *
     LDA #EOL ;special case eliminator
*    JMP SDA  ;set data and advance cursor

* SDA - Set Data and Advance Cursor Column
SDA  EQU *
     STA INSDAT ;set data
*    JMP ACC ;advance cursor column, return

* ACC - Advance Cursor Column
ACC  EQU *
     INC LOGCOL   ;increment logical column
     INC COLCRS   ;increment low cursor colum:
     BNE ACC1     ;if no carry
     INC COLCRS+1 ;adjust high cursor column
ACC1 LDA COLCRS   ;low cursor column
     LDX DINDEX   ;mode
     CMP TMCC,X
     BEQ ACC2     ;if equal, process EOL
     CPX #0
     BNE CCA6     ;if not mode 0, exit
     CMP RMARGN   ;right margin
     BEQ CCA6     ;if at right margin, exit
     BCC CCA6     ;if before right margin, ex:
ACC2 CPX #8
     BNE ACC3     ;if not mode 8
     LDA COLCRS+1 ;high cursor column
     BEQ CCA6     ;if only at 64
ACC3 LDA DINDEX   ;mode
     BNE RET      ;if mode 0, exit
     LDA LOGCOL   ;logical column
     CMP #81
     BCC ACC4     ;if < 81, definitely not li:
     LDA INSDAT
     BEQ RET      ;if non-zero, do not do log:
     JSR RWS      ;return with scrolling
     JMP RET5     ;return
ACC4 JSR RET      ;return
     LDA ROWCRS   ;cursor row
     CLC
     ADC <8*[LOGMAP-TABMAP] ;add offset for log:
     JSR BMG   ;ger bit from bit map
     BCC ACC5
     LDA INSDAT
     BEQ ACC5  ;if zero, do not extend
     CLC
     JSR ILN1  ;insert line
ACC5 JMP SLC   ;set logical column, return

* RWS - Return with Scrolling
RWS  EQU *
     LDA #EOL ;select scrolling
     STA INSDAT
*    JMP RET ;return, return .

* RET - Return
RET  EQU *
     JSR SCL ;set cursor at left edge
     LDA #0
     STA COLCRS+1 ;high cursor column
     INC ROWCRS   ;increment cursor row
     LDX DINDEX
     LDY #24   ;assume 24 lines
     BIT SWPFLG
     BPL RET1  ;if normal
     LDY #4    ;substitute 4 lines
     TYA
     BNE RET2
RET1 LDA TMRC,X ;mode row count
RET2 CMP ROWCRS ;cursor row
     BNE RET5
     STY HOLD3
     TXA ;mode
     BNE RET5   ;if mode not 0, do not scroll
     LDA INSDAT
     BEQ RET5   ;if zero, do not scroll
* If EOL, roll in a 0
     CMP #EOL ;to extend bottom logical line
     BEQ RET3 ;if EOL
     CLC
RET3 JSR SCR
     INC SCRFLG
     DEC BUFSTR
     BPL RET4
     INC BUFSTR
RET4 DEC HOLD3
     LDA LOGMAP
     SEC ;indicate for partial line
     BPL RET3 ;if partial logical line
     LDA HOLD3
     STA ROWCRS ;cursor row
RET5 JMP SLC ;set logical column, return

* SEP - Subtract End Point
SEP  EQU *
     SEC
     LDA ROWAC,X ;low value from which to su:
     SBC ENDPT
     STA ROWAC,X ;new low value
     LDA ROWAC+1,X ;hogh value from which to s:
     SBC ENDPT+1
     STA ROWAC+1,X ;new high value
     RTS

* CRE - Check Cursor Range for Editor
CRE  EQU *
* Check for mixed mode
     LDA BOTSCR
     CMP #4  ;mixed mode indicator
     BEQ CCR ;if mixed mode, check cursor range,:
* Check for mode 0
     LDA DINDEX ;mode
     BEQ CCR    ;if mode 0, check ursor usage
* Open editor
     JSR EOP ;perform editor OPEN
*    JMP CCR ;check cursor range, return

* CCR - Check Cursor Range
CCR  EQU *
     LDA #39
     CMP RMARGN   ;right margin
     BCS CCR1     ;if 39 >= right margin
     STA RMARGN   ;set right margin
CCR1 LDX DINDEX
     LDA TMRC,X   ;mode row count
     CMP ROWCRS   ;cursor row
     BCC CCR5     ;if count > row position, e:
     BEQ CCR5     ;if count = row position, e:
     CPX #8
     BNE CCR2     ;if not mode 8
     LDA COLCRS+1 ;high cursor column
     BEQ CCR4     ;if high cursor column zero
     CMP #1
     BNE CCR5     ;if >1, bad
     BEQ CCR3     ;if 1, check low
CCR2 LDA COLCRS+1 ;high cursor column
     BNE CCR5     ;if high cursor column non-:
CCR3 LDA TMCC,X   ;mode column count
     CMP COLCRS   ;low cursor column
     BCC CCR5     ;if count > column position:
     BEQ CCR5     ;if count = column position:
CCR4 LDA #SUCCES  ;success indicator
     STA DSTAT    ;indicate success
     LDA #BRKABT  ;assume BREAK abort
     LDX BRKKEY   ;BREAK key status
     STA BRKKEY   ;clear BREAK key status
     BEQ CCR6     ;if BREAK
     RTS
* Process range error
CCR5 JSR CHM     ;move cursor home
     LDA #CRSROR ;indicate cursor overrange
* Exit
CCR6 STA DSTAT ;status
     PLA       ;clean stack for return to :
     PLA
     LDA SWPFLG
     BPL CCR7 ;if not swapped
     JMP SWA  ;swap, return
CCR7 JMP SST  ;return (to CIO)

* ROD - Restore Old Data under Cursor
ROD  EQU *
     LDY #0
     LDA OLDADR+1
     BEQ ROD1   ;if page zero
     LDA OLDCHR ;old data
     STA (OLDADR),Y
ROD1 RTS

* BMIO - Initialize for Bit Map Operation
BMIO EQU *
     PHA    ;save logical column
     AND #7 ;logical column modulo 8
     TAX    ;offset to bit mask
     LDA TBTM,X  ;bit mask
     STA BITMSK  ;set bit mask
     PLA ;logical column
     LSR @
     LSR @
     LSR @ ;logical column divided by 8
     TAX ;offset
     RTS

* BLR - Rotate Logical Line Bit Map Left
BLR  EQU *
     ROL LOGMAP+2
     ROL LOGMAP+1
     ROL LOGMAP
     RTS

* BMP - Put Bit in Bit Map
BMP  EQU *
     BCC BMC ;if C clear, clear bit in bit map,:
*    JMP BMS ;set bit in bit map, return

* BMS - Set Bit in Bit Map
BMS  EQU *
     JSR BMIO ;initialize for bit mask op:
     LDA TABMAP,X
     ORA BITMSK   ;set bit
     STA TABMAP,X ;update bit map
     RTS

* BMC - Clear Bit in Bit Map
BMC  EQU *
     JSR BMIO ;initialize for bit mask op:
     LDA BITMSK
     EOR #$FF
     AND TABMAP,X ;clear bit
     STA TABMAP,X ;update bit map
     RTS

* BLG - Get Bit from Logical Line Bit Map
BLG  EQU *
     LDA ROWCRS ;cursor row
*    JMP BLG1

* BLG1 - Get Bit from Logical Line Bit Map
BLG1 EQU *
     CLC
*    JMP BLG2

* BLG2 - Get Bit from Logical Line Bit Map
BLG2 EQU *
     ADC <8*[LOGMAP-TABMAP] ;add offset for log:
*    JMP BMG ;get bit from bit map, return

* BMG - Get Bit from Bit Map
BMG  EQU *
     JSR BMIO ;initialize for bit mask operation
     CLC
     LDA TABMAP,X
     AND BITMSK
     BEQ BMG1
     SEC
BMG1 RTS

* CIA - Convert Internal Character to ATASCII
CIA  EQU *
     LDA CHAR
* Check mode
     LDY DINDEX ;mode
     CPY #14
     BCS CIA2 ;if mode >= 14
     CPY #12
     BCS CIA1 ;if mode 12 or 13
     CPY #3
     BCS CIA2 ;if mode >= 3
* Convert internal character to ATASCII
CIA1 ROL @
     ROL @
     ROL @
     ROL @
     AND #3
     TAX
     LDA CHAR ;character
     AND #$9F ;strip off cloumn address
     ORA TIAC,X ;or in new column address
* Exit
CIA2 STA ATACHR ;ATASCII character
CIA3 RTS

* MLN - Move Line
MLN  EQU       *
* Initialize
     LDX RAMTOP   ;(high) RAM size
     DEX          ;decrement (high) RAM size
     STX FRMADR+1 ;high source address
     STX TOADR+1  ;high destination address
     LDA <[$0000-80] ;low RAM size - 80
     STA FRMADR      ;low source address
     LDA <[$0000-40] ;low RAM size - 40
     STA TOADR  ;low destination address
     LDX ROWCRS ;cursor row
* Check for completion
MLN1 INX
     CPX BOTSCR ;screen bottom
     BEQ CIA3   ;if done, return
* Move line
     LDY #39        ;offset to last byte
MLN2 LDA (FRMADR),Y ;byte of source
     STA (TOADR),Y  ;byte of destination
     DEY
     BPL MLN2 ;if not done
* Adjust source and destination addresses
     SEC
     LDA FRMADR ;source address
     STA TOADR  ;update destination address
     SBC <40    ;subtract 40
     STA FRMADR ;update.source address
     LDA FRMADR+1
     STA TOADR+1
     SBC >40
     STA FRMADR+1
* Continue
     JMP MLN1 ;continue

* ELL - Extend Logical Line
ELL  EQU *
     PHP ;save bit
     LDY #22
ELL1 TYA
     JSR BLG1
     PHP
     TYA
     CLC
     ADC <8*[LOGMAP-TABMAP]+1 ;add offset for log:
     PLP
     JSR BMP ;put bit in bit map
     DEY
     BMI ELL2
     CPY ROWCRS ;cursor row
     BCS ELL1
ELL2 LDA ROWCRS ;cursor row
     CLC
     ADC <8*[LOGMAP-TABMAP] ;add offset for log:
     PLP
     JMP BMP ;put bit in bit map, return

* CLN - Clear Line
CLN  EQU *
     LDA LMARGN ;left margin
     STA COLCRS ;low cursor column
     JSR CCA    ;convert cursor row/column to address
     SEC
     LDA RMARGN ;right margin
     SBC LMARGN ;subtract left margin
     TAY        ;screen width
     LDA #0
CLN1 STA (ADRESS),Y
     DEY
     BPL CLN1 ;if not done
     RTS

* SCR - Scroll
SCR  EQU *
* Initialize
     JSR BLR ;rotate logical line bit map left
* Check for fine scrolling
     LDA FINE
     BEQ SCR5   ;if not fine scrolling
SCR1 LDA VSFLAG ;vertical scroll count
     BNE SCR1   ;if prior scroll not yet done
     LDA #8
     STA VSFLAG ;vertical scroll count
* Wait forscroll to complete
SCR2 LDA VSFLAG  ;vertical scroll count
     CMP #1      ;start of last scan
     BNE SCR2    ;if not done waiting
SCR3 LDA VCOUNT
     CMP #$40
     BCS SCR3 ;if not done waiting for safe place
     LDX #$0D
     LDA BOTSCR
     CMP #4
     BNE SCR4 ;if not split screen
     LDX #$70
SCR4 CPX VCOUNT
     BCS SCR4 ;if not done waiting
* Exit
SCR5 JSR SMS ;set memory scan counter address
*    JMP SSD ;scroll screen for delete, return

* SSD - Scroll Screen for Delete
SSD  EQU *
* Initializ
     LDA ADRESS ;address
     LDX ADRESS+1
* Calculate number of bytes to move
SSD1 INX
     CPX RAMTOP
     BEQ SSD2 ;if at RAMTOP
     SEC
     SBC #$10
     JMP SSD1 ;continue
SSD2 ADC #39  ;(CLC and ADC #40)
     BNE SSD3 ;if byte count non-zero
     LDX ADRESS+1
     INX
     CPX RAMTOP
     BEQ SSD6 ;if at RAMTOP
     CLC
     ADC #$10
* Adjust address
SSD3 TAY ;number of bytes
     STA COUNTR
     SEC
     LDA ADRESS
     SBC COUNTR ;subtract
     STA ADRESS ;update low address
     BCS SSD4   ;if no borrow
     DEC ADRESS+1 ;adjust high address
* Move data down
SSD4 LDA ADRESS
     CLC
     ADC #40
     STA COUNTR  ;address + 40
     LDA ADRESS+1
     ADC #0
     STA COUNTR+1
SSD5 LDA (COUNTR),Y ;byte to move
     STA (ADRESS),Y ;move byte
     INY
     BNE SSD5 ;if not done (256-=16 times)
     LDY #256-240
     LDA ADRESS
     CMP <0-40 ;#$D8 ; compliment -40
     BEQ SSD6 ;if all done
     CLC
     ADC #240
     STA ADRESS   ;update low address
     BCC SSD4     ;if no carry
     INC ADRESS+1 ;adjust high address
     BNE SSD4     ;continue
* Clear last line
SSD6 LDX RAMTOP
     DEX
     STX COUNTR+1
     LDX <0-40
     STX COUNTR
     LDA #0
     LDY #39
SSD7 STA (COUNTR),Y ;clear byte of last line
     DEY
     BPL SSD7 ;if not done
*    JMP SLC  ;set logical column, return

* SLC - Set Logical Column
SLC  EQU *
* Initialize
     LDA #0
     STA LOGCOL  ;initialize logical column
     LDA ROWCRS  ;cursor row
     STA HOLD1   ;working row
* Search for beginning of line
SLC1 LDA HOLD1  ;add in row component
     JSR BLG1
     BCS SLC2   ;if beginning of line found
     LDA LOGCOL ;logical column
     CLC
     ADC #40    ;add number of characters per line
     STA LOGCOL ;update logical column
     DEC HOLD1  ;decrement working row
     JMP SLC1   ;continue
* Add in cursor column
SLC2 CLC
     LDA LOGCOL  ;logical column
     ADC COLCRS  ;add low cursor column
     STA LOGCOL  ;update logical column
     RTS

* CBC - Compute Buffer Count
CBC  EQU *
* Initialize
     JSR SRC    ;save row and column
     LDA LOGCOL ;logical column
     PHA        ;save logical column
     LDA BUFSTR ;start of buffer
     STA ROWCRS ;cursor row
     LDA BUFSTR+1
     STA COLCRS ;low cursor column
     LDA #1
     STA BUFCNT ;initialize buffer count
* Determine last line on screen
CBC1 LDX #23    ;normal last line on screen
     LDA SWPFLG
     BPL CBC2   ;if not swapped
     LDX #3     ;last line on screen
* Check for cursor on last line of screen
CBC2 CPX ROWCRS ;cursor row
     BNE CBC3   ;if cursor on last line
     LDA COLCRS ;low cursor column
     CMP RMARGN ;right margin
     BNE CBC3   ;if not at right margin
     INC BUFCNT ;fake SEA to avoid scrolling
     JMP CBC4
CBC3 JSR SZA    ;set zero data and advance cursor
     INC BUFCNT
     LDA LOGCOL ;logical column
     CMP LMARGN ;left margin
     BNE CBC1   ;if not yet at left margin
     DEC ROWCRS ;decrement cursor row
     JSR CLF    ;move cursor left
CBC4 JSR GDC    ;get data under cursor
     BNE CBC6   ;if non-zero, quit
     DEC BUFCNT ;DECREMENT COUNTER
     LDA LOGCOL ;logical column
     CMP LMARGN ;left margin
     BEQ CBC6   ;if beginning of logical line, exit
     JSR CLF    ;move cursor left
     LDA COLCRS ;low cursor column
     CMP RMARGN ;right margin
     BNE CBC5   ;if cursor column not right margin
     DEC ROWCRS ;decrement cursor row
CBC5 LDA BUFCNT
     BNE CBC4   ;if BUFCNT non-zero, continue
CBC6 PLA        ;saved logical column
     STA LOGCOL ;restore logical column
     JMP RRC    ;restore row and column, return

* SBS - Set Bufer Start and Logical Column
SBS  EQU *
     JSR SLC ;set logical column
     LDA HOLD1
     STA BUFSTR
     LDA LMARGN ;left margin
     STA BUFSTR+1
SBS1 RTS

* DQQ - Delete Line
DQQ  EQU *
     LDA LOGCOL ;logical column
     CMP LMARGN ;left margin
     BNE DQQ1   ;if not at left margin
     DEC ROWCRS ;decrement cursor row
DQQ1 JSR SLC    ;set logical column
*    JMP DWQ

* DWQ - Delete Line
DWQ  EQU *
* Check for left margin
     LDA LOGCOL ;logical column
     CMP LMARGN ;left margin
     BEQ SBS1   ;if at left margin, return
     JSR CCA    ;convert cursor row/column to addre:
     LDA RMARGN ;right margin
     SEC
     SBC LMARGN ;subtract left margin
     TAY        ;offset to last byte
DWQ1 LDA (ADRESS),Y
     BNE SBS1
     DEY
     BPL DWQ1 ;if not done
     JMP DLN1 ;delete line, return

* CCC - Check for Control Character
CCC  EQU *
     LDX <TCCRL-3 ;offset to last entry
CCC1 LDA TCCR,X   ;control character
     CMP ATACHR   ;ATASCII character
     BEQ CCC2     ;if character found, exit
     DEX
     DEX
     DEX
     BPL CCC1 ;if not done, continue sear:
CCC2 RTS
