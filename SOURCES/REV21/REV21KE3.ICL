* SUBTTL 'Keyboard, Editor and Screen Handler, Part 3'

SST1 LDA #SUCCES ;indicate success
     STA DSTAT   ;status
     LDA ATACHR  ;data
*    JMP ESP     ;return

* ESP - Perform Editor SPECIAL
ESP  EQU *
ESPV EQU *-1
     RTS

* ECL - Perform Editor CLOSE
ECL  EQU *
ECLV EQU *-1
* Check for fine scrolling
     BIT FINE ;fine scrolling flag
     BPL SST  ;if not fine scrolling, perform STA:
* Process fine scrolling.
     LDA #$40
     STA NMIEN ;disable DLI
     LDA #0    ;clear fine scrolling flag
     STA FINE
     LDA <RIR   ;return from interrupt rout:
     STA VDSLST ;restore initial DLI vector:
     LDA >RIR
     STA VDSLST+1
     JMP EOP ;perform editor OPEN, retur:

* EGB - Perform Editor GET-BYTE
EGB  EQU *
EGBV EQU *-1
* Initialize
     JSR SWA    ;swap
     JSR CRE    ;check cursor range for editor
     LDA BUFCNT ;buffer count
     BNE EGB4   ;if something in the buffer
* Get line
     LDA ROWCRS   ;cursor row
     STA BUFSTR   ;buffer start pointer
     LDA COLCRS   ;low cursor column
     STA BUFSTR+1 ;high buffer start pointer

EGB1 JSR KGB    ;perform keyboard GET-BYTE
     STY DSTAT  ;status
     LDA ATACHR ;ATASCII character
     CMP #EOL
     BEQ EGB3   ;if EOL

     JSR PCH    ;process character
     JSR SWA    ;swap
     LDA LOGCOL ;logical column
     CMP #113   ;column near column 120
     BNE EGB2   ; if not near column 120, no beep

     JSR BEL    ;beep

EGB2 JMP EGB1    ;process new character

* Process EOL
EGB3 JSR ROD      ;restore old data under cur:
     JSR CBC      ;compute buffer count
     LDA BUFSTR   ;buffer start pointer
     STA ROWCRS   ;cursor row
     LDA BUFSTR+1 ;high buffer start pointer
     STA COLCRS   ;low cursor column
* Check buffer count
EGB4 LDA BUFCNT  ;buffer count
     BEQ EGB6    ;if buffer count zero
* Decrement and check buffer count
EGB5 DEC BUFCNT ;decrement buffer count
     BEQ EGB6   ;if buffer count zero
* Check status
     LDA DSTAT ;status
     BMI EGB5  ;if error, continue decrementing
* Perform GET-BYTE
     JSR SGB    ;perform screen GET-BYTE
     STA ATACHR ;ATASCII character
     JMP SWA    ;swap, return
* Exit
EGB6 JSR RWS    ;return with scrolling
     LDA #EOL
     STA ATACHR ;ATASCII character
     JSR SECC   ;set exit conditions
     STY DSTAT  ;status
     JMP SWA    ;swap, return

* IRA - Invoke Routine Pointed to by ADRESS
IRA  EQU *
     JMP (ADRESS) ;execute, return

* EPB - Perform Editor PUT-BYTE
EPB  EQU *
EPBV EQU *-1
     STA ATACHR ;ATASCII character
     JSR SWA    ;swap
     JSR CRE    ;check cursor range for editor
     LDA #0
     STA SUPERF ;clear super function flag
*    JMP PCH    ;process character, return

* PCH - Process Character
PCH  EQU *
     JSR ROD  ;restore old data under cursor
     JSR CCC  ;check for control character
     BEQ PCH2 ;if control character
* Display character
PCH1 ASL ESCFLG ;escape flag
     JSR CEL    ;check EOL
     JMP SWA    ;swap, return
* Process control character.
PCH2 LDA DSPFLG ;display flag
     ORA ESCFLG ;escape flag
     BNE PCH1   ;if display or escape, display char
* Continue
     ASL ESCFLG
     INX
* Check for super function
     LDA SUPERF
     BEQ PCH3 ;if not super function
* Adjust for super function
     TXA
     CLC
     ADC <TSFR-TCCR-3
     TAX ;adjusted offset
* Process control character or super function
PCH3 LDA TCCR,X   ;low routine address
     STA ADRESS
     LDA TCCR+1,X ;high routine address
     STA ADRESS+1
     JSR IRA      ;invoke routine pointed to :
     JSR SECC     ;set exit conditions
     JMP SWA      ;swap, return

* IGN - Ignore Character and Perform Keyboard GET-BYTE
IGN  EQU *
     LDA #$FF ;clear code indicator
     STA CH   ;key code
*    JMP KGB  ;perform keyboard GET-BYTE, return

* KGB - Perform Keyboard GET-BYTE
KGB  EQU *
KGBV EQU *-1
* Initialize
KGB1 LDA #0
     STA SUPERF ;clear super function flag
* Check for special edit read mode
     LDA ICAX1Z
     LSR @
     BCS KGB11 ;if special edit read mode
* Check for BREAK abort
     LDA #BRKABT ;assume BREAK abort
     LDX BRKKEY  ;BREAK key flag
     BEQ KGB10   ;if BREAK abort
* Check for character
     LDA CH   ;key code
     CMP #$FF ;clear code indicator
     BEQ KGB1 ;if no character
* Process character
     STA HOLDCH ;save character
     LDX #$FF   ;clear code indicator
     STX CH     ;key code
* Sound key click if desired
     LDX NOCLIK ;click inhibit flag

*<CHG>     BNE KGB2   ;if click inhibited
     BEQ KGB2   ;if click inhibited

     JSR SKC    ;sound key click
* Set offset to key definition
KGB2 TAY ;save character
* Check for CTRL and SHIFT together
     CPY #$C0
     BCS IGN ;if CTRL and SHIFT together, ignore
* Convert to ATASCII character
     LDA (KEYDEF),Y ;ATASCII character
* Set ATASCII character
KGB3 STA ATACHR ;ATASCII character
     TAX
     BMI KGB4   ;if special key
     JMP KGB17  ;process shift/control lock
* Check for null character
KGB4 CMP #$80
     BEQ IGN ;if null, ignore
* Check for inverse video key
     CMP #$81
     BNE KGB5 ;if not inverse video key
* Process inverse video key
     LDA INVFLG
     EOR #$80
     STA INVFLG
     BCS IGN ;ignore
* Check for CAPS key
KGB5 CMP #$82
     BNE KGB6 ;if not CAPS key
* Process CAPS key
     LDA SHFLOK ;shift/control lock flags
     BEQ KGB7   ;if no lock, process CAPS lock
     LDA #$00   ;no lock indicator
     STA SHFLOK ;shoft/control lock flags
     BEQ IGN    ;ignore
* Check for SHIFT-CAPS key
KGB6 CMP #$83
     BNE KGB8 ;if not SHIFT-CAPS
* Process SHIFT-CAPS key
KGB7 LDA #$40   ;CAPS lock indicator
     STA SHFLOK ;shift/control lock flags
     BNE IGN    ;ignore
* Check for CTRL-CAPS key
KGB8 CMP #$84
     BNE KGB9 ;if not CTRL-CAPS
* Process CTRL-CAPS key
     LDA #$80   ;control lock indicator
     STA SHFLOK ;shift/control lock flags
     JMP IGN    ;ignore
* Check for CTRL-3 key
KGB9 CMP #$85
     BNE KGB12 ;if not CTRL-3 key
* Process CTRL-3 key
     LDA #EOFERR
* Set status and BREAK key flag
KGB10 STA DSTAT ;status
     STA BRKKEY ;BREAK key flag
* Set EOL character
KGB11 LDA #EOL
     JMP KGB19 ;set ATASCII character
* Check for CTRL-F3 key
KGB12 CMP #$89
     BNE KGB14 ;if not CTRL-F3 key
* Process CTRL-F3 key
     LDA NOCLIK ;toggle keyclick status
     EOR #$FF
     STA NOCLIK
     BNE KGB13  ;if click inhibited
     JSR SKC    ;sound key click
KGB13 JMP IGN ;ignore
* Check for function key
KGB14 CMP #$8E
     BCS KGB16 ;if code >= $8E, not a function key
     CMP #$8A
     BCC KGB13 ;if code < $8A, not a function key
* Process function key
     SBC #$8A   ;convert $8A - $bD to 0 - 3
     ASL HOLDCH ;saved character
     BPL KGB15  ;if no SHIFT
     ORA #$04   ;convert 0 - 3 to 4 - 7
KGB15 TAY       ;offset to function key def:
     LDA (FKDEF),Y ;function key
     JMP KGB3      ;set ATASCII character
* Check for super function
KGB16 CMP #$92
     BCS KGB17 ;if code >= $92, process shift/control
     CMP #$8E
     BCC KGB13 ;if code < $8E, not super function
* Process super function
     SBC #$8E-$1C ;convert $8E - $91 to $1C -:
     INC SUPERF   ;set super function flag
     BNE KGB19    ;set ATASCII character
* Process shift/control lock
KGB17 LDA HOLDCH ;saved character
     CMP #$40
     BCS KGB18 ;if not lower case
     LDA ATACHR ;ATASCII character
     CMP #'a'
     BCC KGB18  ;if < "a", do not process
     CMP #'z'+1
     BCS KGB18  ;if > "z", do not process
     LDA SHFLOK ;shift/control lock flags
     BEQ KGB18  ;if no lock
     ORA HOLDCH ;modify character
     JMP KGB2   ;reprocess character
* Invert character, if necessary
KGB18 JSR CCC   ;check for control character
     BEQ KGB20  ;if control character, do not invert
     LDA ATACHR ;ATASCII character
     EOR INVFLG ;invert character
* Set ATASCII character
KGB19 STA ATACHR ;ATASCII character
* Exit
KGB20 JMP SST ;perform screen status, return

* ESC - Escape
ESC  EQU *
     LDA #$80   ;indicate escape detected
     STA ESCFLG ;escape flag
     RTS

* CUP - Move Cursor Up
CUP  EQU *
     DEC ROWCRS  ;decrement cursor row
     BPL CUP2    ;if row positive
     LDX BOTSCR  ;screen bottom
     DEX         ;screen bottom - 1
CUP1 STX ROWCRS  ;update cursor row
CUP2 JMP SBS     ;set buffer start and logical colum:

* CDN - Move Cursor Down
CDN  EQU *
     INC ROWCRS ;increment cursor row
     LDA ROWCRS ;cursor row
     CMP BOTSCR ;screen bottom
     BCC CUP2   ;if at bottom, set buffer start
     LDX #0
     BEQ CUP1 ;update cursor row, return

* CLF - Move Cursor Left
CLF  EQU *
     DEC COLCRS ;decrement low cursor column
     LDA COLCRS ;low cursor column
     BMI CRM    ;if negative, move cursor to margin
     CMP LMARGN ;left margin
     BCS SCC1   ;if at left margin, set logical col
*    JMP CRM    ;move cursor to right margin, return

* CRM - Move Cursor to Right Margin
CRM  EQU  *
     LDA  RMARGN ;right margin
*    JMP  SCC    ;set cursor column, return

* SCC - Set Cursor Column
SCC  EQU *
     STA COLCRS ;set low cursor column
SCC1 JMP SLC    ;set logical column, return

* CRT - Move Cursor Right
CRT  EQU *
     INC COLCRS ;increment low cursor column
     LDA COLCRS ;low cursor column
     CMP RMARGN ;right margin
     BCC SCC1   ;if before right margin, process
     BEQ SCC1   ;if at right margin
*    JMP CLM    ;move cursor to left margin, return

* CLM - Move Cursor to Left Margin
CLM  EQU *
     LDA LMARGN ;left margin
     JMP SCC    ;set cursor column, return

* CSC - Clear Screen
CSC  EQU *
* Set memory scan counter address
     JSR SMS ;set memory scan counter
* Clear address
     LDY ADRESS
     LDA #0
     STA ADRESS
CSC1 STA (ADRESS),Y
     INY
     BNE CSC1 ;if not done with page
     INC ADRESS+1
     LDX ADRESS+1
     CPX RAMTOP ;(high) RAM size
     BCC CSC1   ;if not done
* Clean up logical line bit map
*    LDY #0 ;offset to first byte of bit
     LDA #$FF
CSC2 STA LOGMAP,Y ;byte of logical line bit
     INY
     CPY #4   ;4 bytes
     BCC CSC2 ;if not done
* Exit
*    JMP CHM ;move cursor home, return

* CHM - Move Cursor Home
CHM  EQU     *
     JSR     SCL      ;set cursor at left edge
     STA     LOGCOL   ;logical column
     STA     BUFSTR+1 ;high buffer start
     LDA     #0
     STA     ROWCRS   ;cursor row
     STA     COLCRS+1 ;high cursor column
     STA     BUFSTR   ;low buffer start pointer
     RTS              ;return

* BSP - Backspace
BSP  EQU *
     LDA LOGCOL ;logical column
     CMP LMARGN ;left margin
     BEQ BSP3   ;if at left margin
     LDA COLCRS ;low cursor column
     CMP LMARGN ;left margin
     BNE BSP1   ;if not atleft margin
     JSR DWQ    ;see if line should be deleted
BSP1 JSR CLF    ;move cursor left
     LDA COLCRS ;low cursor column
     CMP RMARGN ;right margin
     BNE BSP2   ;if not at right margin
     LDA ROWCRS ;cursor low
     BEQ BSP2   ;if row zero
     JSR CUP    ;move cursor up
BSP2 LDA #' '
     STA ATACHR ;ATASCII character
     JSR PLO    ;plot point
BSP3 JMP SLC    ;set logical column, return

* TAB - Tab
TAB  EQU *
TAB1 JSR CRT    ;move cursor right
     LDA COLCRS ;low cursor column
     CMP LMARGN ;left margin
     BNE TAB2   ;if not at left margin
     JSR RET    ;return
     JSR BLG    ;get bit from logical line bit map
     BCS TAB3   ;if end of logical line
* Check for tab stop
TAB2 LDA LOGCOL ;logical column
     JSR BMG    ;set bit from bit map
     BCC TAB1   ;if not tab stop, keep looking
* Set logical lolumn
TAB3 JMP SLC    ;set logical column, return

* STB - Set Tab
STB  EQU *
     LDA LOGCOL ;logical column
     JMP BMS    ;set bit in bit map, retrun

* CTB - Clear Tab
CTB  EQU *
     LDA LOGCOL ;logical column
     JMP BMC    ;clear bit in bit map, return

* ICH - Insert Character
ICH  EQU *
     JSR SRC ;save row and column
     JSR GDC ;get data under cursor
     STA INSDAT
     LDA #0
     STA SCRFLG
ICH1 JSR SPQ    ;store data
     LDA LOGCOL ;logical column
     PHA        ;save logical column
     JSR ACC    ;advance cursor column
     PLA        ;saved logical column
     CMP LOGCOL ;logical column 
     BCS ICH2   ;if saved logical column >= logical
     LDA INSDAT
     PHA
     JSR GDC     ;get data under cursor
     STA INSDAT
     PLA
     JMP ICH1 ;continue
* Exit
ICH2 JSR RRC ;restore row and column
ICH3 DEC SCRFLG
     BMI ICH4 ;if scroll occured
     DEC ROWCRS ;decrement cursor row
     BNE ICH3 ;continue
ICH4 JMP SLC ;set logical column, return

* DCH - Delete Character
DCH  EQU *
* Save row and column
     JSR SRC ;save row and column
* Get data to the right of cursor
DCH1 JSR CCA     ;convert cursor row/column to addre:
     LDA ADRESS
     STA SAVADR  ;save address
     LDA ADRESS+1
     STA SAVADR+1
     LDA LOGCOL  ;logical column
     PHA         ;save lgical column
     JSR SZA     ;set zero data and advance cursor
     PLA         ;saved logical column
     CMP LOGCOL  ;logical column
     BCS DCH2    ;if saved logical column >= logical
     LDA ROWCRS  ;cursor row
     CMP BOTSCR  ;screen bottom
     BCS DCH2    ;if row off screem, exit
     JSR GDC     ;get data under cursor
     LDY #0
     STA (SAVADR),Y ;put data in previous posit:
     BEQ DCH1       ;continue
DCH2 LDY #0
     TYA
     STA (SAVADR),Y ;clear last position
     JSR DQQ ;try to delete a line
     JSR RRC ;restore row and column
     JMP SLC ;set logical column, return

* ILN - Insert Line
ILN  EQU *
     SEC
*    JMP ILN1

* ILN1 - Insert Line
ILN1 EQU *
     JSR ELL ;extend logical line
     LDA LMARGN ;left margin
     STA COLCRS ;low cursor column
     JSR CCA ;convert cursor row/column to addre:
     JSR MLN ;move line
     JSR CLN ;clear current line
     JMP SLC ;set logical column, return

* DLN - Delete Line
DLN  EQU *
     JSR SLC ;set logical column
     LDY HOLD1
     STY ROWCRS ;cursor row
*    JMP DLN1

* DLN1 - Delete Line
DLN1 EQU *
DLN0 LDY ROWCRS ;cursor row
DLN2 TYA
     SEC
     JSR BLG2   ;get next bit
     PHP
     TYA
     CLC
     ADC <8*[LOGMAP-TABMAP] ;add offset for log:
     PLP
     JSR BMP ;put bit in bit map
     INY
     CPY #24
     BNE DLN2 ;if not done
     LDA LOGMAP+2
     ORA #1       ;set least significant bit
     STA LOGMAP+2 ;update logical line bit ma:
     LDA #0     ;delete line of data
     STA COLCRS ;low cursor column
     JSR CCA    ;convert cursor row/column :
     JSR SSD    ;scroll screen for delete
* Check for new logical line
     JSR BLG  ;get bit from logical line :
     BCC DLN0 ;if not new logical line
* Move cursor to left margin
     JMP CLM ;move cursor to left margin:

* BEL - Sound Bell
BEL  EQU *
     LDY #$20
BEL1 JSR SKC  ;sound key click
     DEY
     BPL BEL1 ;if not done
     RTS

* CBT - Move Cursor to Bottom
CBT  EQU *
     JSR CHM ;move cursor home
     JMP CUP ;move cursor up, return

* DDD - Perform Double Byte Double Decrement
DDD  EQU *
     LDA #2  ;indicate subtracting 2
     BNE DBS ;perform double byte subtract

* SDF - Store Data Indirect for Fine Scrolling
SDF  EQU *
     LDY FINE
     BEQ SDI  ;if not fine scrolling
     ORA #$20 ;enable vertical scroll
*    JMP SDI  ;store data indirect, return

* SDI - Store Data Indirect
SDI  EQU *
* Check current status
     LDY DSTAT ;status
     BMI DBS3  ;if error, return
* Store data
     LDY #0
     STA (ADRESS),Y
* Decrement
*    JMP DSD ;perform double byte single decreme:

* DSD - Perform Double Byte Single Decrement
DSD  EQU *
     LDA #1  ;indicate subtracting 1
*    JMP DBS ;perform double byte subtract, retu:

* DBS - Perform Double Byte Subtract
DBS  EQU *
* Initialize
     STA SUBTMP
* Check current status
     LDA DSTAT ;status
     BMI DBS3  ;if error
* Subtract
     LDA ADRESS
     SEC
     SBC SUBTMP
     STA ADRESS
     BCS DBS1     ;if no borrow
     DEC ADRESS+1 ;adjust high byte
* Check for overwriting APPMHI
DBS1 LDA APPMHI+1
     CMP ADRESS+1
     BCC DBS3  ;if not overwriting APPMHI
     BNE DBS2  ;if overwriting APPMHI, err:
     LDA APPMHI
     CMP ADRESS
     BCC DBS3  ;if not overwriting APPMHI
* Process error
DBS2 LDA #SCRMEM ;indicate insufficient memo:
     STA DSTAT   ;status
DBS3 RTS

* SSE - Set Scrolling Display List Entry
SSE  EQU *
     LDA #$02
     JSR SDI  ;store data indirect
     LDA #$A2 ;DLI on last visible line
     JSR SDI  ;store data indirect
     DEX
     RTS
