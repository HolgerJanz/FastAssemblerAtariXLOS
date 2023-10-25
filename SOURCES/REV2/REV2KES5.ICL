* SRC - Save Row and Column
SRC  EQU     *              
     LDX     #2              ;offset to last byte
SRC1 LDA     ROWCRS,X        ;byte of cursor row/column
     STA     TMPROW,X        ;save byte of cursor row/co:
     DEX
     BPL     SRC1            ;if not done
     RTS                     ;return

* RRC - Restore Row and Column
RRC  EQU *
     LDX #2 ;offset to last byte
RRC1 LDA TMPROW,X ;byte of saved cursor row/c:
     STA ROWCRS,X ;byte of row/column
     DEX
     BPL RRC1 ;if not done
     RTS

* SWA - Swap Cursor Position with Regular Cursor Position
SWA  EQU *
* Check for split screen
     LDA BOTSCR ;screen bottom
     CMP #24    ;normal indicator
     BEQ SWA2   ;if not split screen
* Swap cursor parameters
     LDX #11      ;offset to last byte
SWA1 LDA ROWCRS,X ;destination cursor paramet:
     PHA          ;save cursor parameter
     LDA TXTROW,X ;source cursor parameter
     STA ROWCRS,X ;update destination cursor :
     PLA          ;saved cursor parameter
     STA TXTROW,X ;update source cursor param:
     DEX
     BPL SWA1     ;if not done
* Complement swap flag
     LDA SWPFLG ;swap flag
     EOR #$FF   ;complement swap flag
     STA SWPFLG ;update swap flag
* Exit.
SWA2 JMP SST ;perform pscreen STATUS, return

* SKC - Sound Key Click
SKC  EQU *
     LDX #2*63 ;2 times trip count
     PHA
* Turn loudspeaker on
SKC1 STX CONSOL ;turn loudspeaker on
* Wait for VBLANK (loudspeaker off)
     LDA VCOUNT
SKC2 CMP VCOUNT
     BEQ SKC2
* Decrement and check trip count
     DEX
     DEX
     BPL SKC1 ;if not done
* Exit
     PLA
     RTS

* SCL - Set Cursor at Left Edge
SCL  EQU *
     LDA #0     ;assume 0
     LDX SWPFLG ;swap flag
     BNE SCL1   ;if not swapped
     LDX DINDEX ;mode
     BNE SCL2   ;if not mode 0
SCL1 LDA LMARGN ;use left margin instead of 0
SCL2 STA COLCRS ;set low cursor column
     RTS

* SMS - Set Memory Scan Counter Address
SMS  EQU *
     LDA SAVMSC
     STA ADRESS
     LDA SAVMSC+1
     STA ADRESS+1
     RTS

* SSP - Perform Screen SPECIAL
* draws a line from OLDROW/OLDCOL to NEWROW/NEWCOL
SSP  EQU *
SSPV EQU *-1
* Determine command
     LDX #0      ;assume no fill
     LDA ICCOMZ  ;command
     CMP #$11    ;DRAW command
     BEQ SSP2    ;if DRAW command
     CMP #$12    ;FILL command
     BEQ SSP1    ;if FILL command
     LDY #NVALID ;invalid command error
     RTS         ;return
SSP1 INX         ;indicate fill
SSP2 STX FILFLG  ;right fill flag
* Set destination row/column
     LDA ROWCRS ;cursor row
     STA NEWROW
     LDA COLCRS ;cursor column
     STA NEWCOL
     LDA COLCRS+1
     STA NEWCOL+1
* Compute row increment and difference
     LDA #1     ;assume increment +1
     STA ROWINC ;row increment
     STA COLINC ;column increment
     SEC
     LDA NEWROW ;destination row
     SBC OLDROW ;subtract source row
     STA DELTAR ;row difference
     BCS SSP3   ;if difference positive
* Set row increment to -1 and complement row differen:
     LDA #$FF   ;increment -1
     STA ROWINC ;update row increment
     LDA DELTAR ;row difference
     EOR #$FF
     CLC
     ADC #1     ;add 1 for 2's complement
     STA DELTAR ;update row difference
* Compute column increment and difference
SSP3 SEC
     LDA NEWCOL  ;destination column
     SBC OLDCOL  ;source column
     STA DELTAC  ;column difference
     LDA NEWCOL+1
     SBC OLDCOL+1
     STA DELTAC+1
     BCS SSP4    ;if difference positive
* Set column increment to -1 and complement column di
     LDA #$FF   ;increment -1
     STA COLINC ;update column increment
     LDA DELTAC ;column difference
     EOR #$FF   ;absolute value of column d:
     STA DELTAC ;update column difference
     LDA DELTAC+1
     EOR #$FF
     STA DELTAC+1
     INC DELTAC ;add 1 for 2's complement
     BNE SSP4   ;if no carry
     INC DELTAC+1 ;adjust for 2's complement
SSP4 LDX #2      ;offset to last byte
     LDY #0
     STY COLAC+1 ;zero high working column
SSP5 TYA
     STA ROWAC,X  ;zero byte of working row/c:
     LDA OLDROW,X ;byte of source row/column
     STA ROWCRS,X ;byte of cursor row/column
     DEX
     BPL SSP5     ;if not done
* Determine difference
     LDA DELTAC   ;low column difference
     INX          ;offset to working row
     TAY          ;low column difference
     LDA DELTAC+1 ;high column difference
     STA COUNTR+1 ;initialize high iteration :
     STA ENDPT+1  ;initialize high end point
     BNE SSP6     ;if high column difference :
     LDA DELTAC   ;low column difference
     CMP DELTAR   ;row difference
     BCS SSP6     ;if column difference > row:
     LDA DELTAR   ;row difference
     LDX #2       ;offset to working column
     TAY          ;row difference
SSP6 TYA          ;low maximum difference
     STA COUNTR   ;low iteration counter
     STA ENDPT    ;low end point
     PHA          ;save low end point
     LDA ENDPT+1  ;high end point
     LSR @        ;C = LSB of high end point
     PLA          ;saved low end point
     ROR @
     STA ROWAC,X  ;low working row or column
* Check for iteration counter zero
SSP7 LDA COUNTR   ;low iteration counter
     ORA COUNTR+1 ;or in high iteration count:
     BNE SSP8     ;if iteration counter is no:
     JMP SSP19    ;exit
* Update working row
SSP8 CLC
     LDA ROWAC   ;working row
     ADC DELTAR  ;row difference
     STA ROWAC   ;update working row
     BCC SSP9    ;if no carry
     INC ROWAC+1 ;adjust high working row
SSP9 LDA ROWAC+1 ;high working row
     CMP ENDPT+1 ;high end point
     BCC SSP11   ;if high working row < high:
     BNE SSP10   ;if high working row > high:
     LDA ROWAC   ;low working row
     CMP ENDPT   ;low end point
     BCC SSP11   ;if low working row < low e:
SSP10 CLC
     LDA ROWCRS ;cursor row
     ADC ROWINC ;add row increment
     STA ROWCRS ;update cursor row
     LDX #0     ;indicate subtract from wor:
     JSR SEP    ;subtract end pointer
SSP11 CLC
     LDA COLAC  ;low working column
     ADC DELTAC ;add column difference
     STA COLAC  ;update working column
     LDA COLAC+1
     ADC DELTAC+1
     STA COLAC+1
     CMP ENDPT+1 ;high end point
     BCC SSP15   ;if high working column < h:
     BNE SSP12   ;if high working column > h:
     LDA COLAC   ;low working column
     CMP ENDPT   ;low end point
     BCC SSP15   ;if low working column < lo:
SSP12 BIT COLINC  ;column increment
     BPL SSP13    ;if column increment positi:
     DEC COLCRS   ;decrement low cursor colum:
     LDA COLCRS   ;low cursor column
     CMP #$FF
     BNE SSP14
     LDA COLCRS+1 ;high cursor column
     BEQ SSP14    ;if zero, do not decrement
     DEC COLCRS+1 ;decrement high cursor colu:
     BPL SSP14
SSP13 INC COLCRS  ;increment low cursor colum:
     BNE SSP14    ;if no carry
     INC COLCRS+1 ;adjust high cursor column
SSP14 LDX #2      ;indicate subtract from wor:
     JSR SEP      ;subtract end pointer
* Plot point
SSP15 JSR CCR ;check cursor range
     JSR PLO  ;plot point
* Check for right fill
     LDA FILFLG ;right fill flag
     BEQ SSP18  ;if no right fill
* Process right fill
     JSR SRC    ;save row and column
     LDA ATACHR ;plot point
     STA HOLD4  ;save plot point
SSP16 LDA ROWCRS ;cursor row
     PHA        ;save cursor row
     JSR ACC    ;advance cursor column
     PLA        ;saved cursor row
     STA ROWCRS ;restore cursor row
     JSR CCR    ;check cursor range
     JSR GDC    ;get data under cursor
     BNE SSP17  ;if non-zero data encounter:
     LDA FILDAT ;fill data
     STA ATACHR ;plot point
     JSR PLO    ;plot point
     JMP SSP16  ;continue
SSP17 LDA HOLD4  ;saved plot point
     STA ATACHR ;restore plot point
     JSR RRC    ;restore row and column
* Subtract 1 from iteration counter
SSP18 SEC
     LDA COUNTR ;iteration counter
     SBC #1     ;subtract 1
     STA COUNTR ;update iteration counter
     LDA COUNTR+1
     SBC #0
     STA COUNTR+1
* Check for completion
     BMI SSP19 ;if iteration counter negative, exit
     JMP SSP7  ;continue
* Exit
SSP19 JMP SST ;perform screen STATUS, return

* TMSK - Table of Bit Masks
TMSK DTA B($00) ;0 - mask for no bits
     DTA B($01) ;1 - mask for lower 1 bit
     DTA B($03) ;2 - mask for lower 2 bits
     DTA B($07) ;3 - mask for lower 3 bits

* TDSC - Table of Default Screen Colors
TDSC DTA B($28) ;default playfield 0 color
     DTA B($CA) ;default playfield 1 color
     DTA B($94) ;default playfield 2 color
     DTA B($46) ;default playfield 3 color
     DTA B($00) ;default background color

* TCCR - Table of Control Character Routines
* Each entry is 3 bytes. The first byte is the control
* character; the second and third bytes are the address
* the routine which processes the control character
TCCR DTA B($1B)
     DTA A(ESC) ;escape
     DTA B($1C)
     DTA A(CUP) ;move cursor up
     DTA B($1D)
     DTA A(CDN) ;move cursor down
     DTA B($1E)
     DTA A(CLF) ;move cursor left
     DTA B($1F)
     DTA A(CRT) ;move cursor right
     DTA B($7D)
     DTA A(CSC) ;clear screen
     DTA B($7E)
     DTA A(BSP) ;backspace
     DTA B($7F)
     DTA A(TAB) ;tab
     DTA B($9B)
     DTA A(RWS) ;return with scrolling
     DTA B($9C)
     DTA A(DLN) ;delete line
     DTA B($9D)
     DTA A(ILN) ;insert line
     DTA B($9E)
     DTA A(CTB) ;clear tab
     DTA B($9F)
     DTA A(STB) ;set tab
     DTA B($FD)
     DTA A(BEL) ;sound bell
     DTA B($FE)
     DTA A(DCH) ;delete character
     DTA B($FF)
     DTA A(ICH) ;insert character
TCCRL EQU *-TCCR

* TSFR - Table of Super Function (Shifted Function Ke:
* Each entry is 3 bytes. The first byte is the super:
* character; the second and third bytes are the addre:
* routine which processes the super function.
TSFR DTA B($1C)
     DTA A(CHM) ;move cursor home
     DTA B($1D)
     DTA A(CBT) ;move cursor to bottom
     DTA B($1E)
     DTA A(CLM) ;move cursor to left margin
     DTA B($1F)
     DTA A(CRM) ;move cursor to right margin

* TAIC - Table of ATASCII to Internal Conversion Cons:
TAIC DTA B($40) ;0
     DTA B($00) ;1
     DTA B($20) ;2
     DTA B($60) ;3

* TIAC - Table of Internal to ATASCII Conversion Cons:
TIAC DTA B($20) ;0
     DTA B($40) ;1
     DTA B($00) ;2
     DTA B($60) ;3

* TCKD - Table of Character Key Definitions
* Entry n is the ATASCII equivalent of key code n
TCKD EQU *
* Lower Case Characters
     DTA B($6C) ;$00 - l
     DTA B($6A) ;$01 - j
     DTA B($3B) ;$02 - semicolon
     DTA B($8A) ;$03 - F1
     DTA B($8B) ;$04 - F2
     DTA B($6B) ;$05 - k
     DTA B($2B) ;$06 - +
     DTA B($2A) ;$07 - *
     DTA B($6F) ;$08 - o
     DTA B($80) ;$09 - (invalid)
     DTA B($70) ;$0A - p
     DTA B($75) ;$0B - u
     DTA B($9B) ;$0C - return
     DTA B($69) ;$0D - i
     DTA B($2D) ;$0E - -
     DTA B($3D) ;$0F - =
     DTA B($76) ;$10 - v
     DTA B($80) ;$11 - (invalid)
     DTA B($63) ;$12 - c
     DTA B($8C) ;$13 - F3
     DTA B($8D) ;$14 - F4
     DTA B($62) ;$15 - b
     DTA B($78) ;$16 - x
     DTA B($7A) ;$17 - z
     DTA B($34) ;$18 - 4
     DTA B($80) ;$19 - (invalid)
     DTA B($33) ;$1A - 3
     DTA B($36) ;$1B - 6
     DTA B($1B) ;$1C - escape
     DTA B($35) ;$1D - 5
     DTA B($32) ;$1E - 2
     DTA B($31) ;$1F - 1
     DTA B($2C) ;$20 - comma
     DTA B($20) ;$21 - space
     DTA B($2E) ;$22 - period
     DTA B($6E) ;$23 - n
     DTA B($80) ;$24 - (invalid)
     DTA B($6D) ;$25 - m
     DTA B($2F) ;$26 - /
     DTA B($81) ;$27 - inverse
     DTA B($72) ;$28 - r
     DTA B($80) ;$29 - (invalid)
     DTA B($65) ;$2A - e
     DTA B($79) ;$2B - y
     DTA B($7F) ;$2C - tab
     DTA B($74) ;$2D - t
     DTA B($77) ;$2E - w
     DTA B($71) ;$2F - q
     DTA B($39) ;$30 - 9
     DTA B($80) ;$31 - (invalid)
     DTA B($30) ;$32 - 0
     DTA B($37) ;$33 - 7
     DTA B($7E) ;$34 - backspace
     DTA B($38) ;$35 - 8
     DTA B($3C) ;$36 - <
     DTA B($3E) ;$37 - >
     DTA B($66) ;$38 - f
     DTA B($68) ;$39 - h
     DTA B($64) ;$3A - d
     DTA B($80) ;$3B - (invalid)
     DTA B($82) ;$3C - CAPS
     DTA B($67) ;$3D - g
     DTA B($73) ;$3E - s
     DTA B($61) ;$3F - a
* Upper Case Characters
     DTA B($4C) ;$40 - L
     DTA B($4A) ;$41 - J
     DTA B($3A) ;$42 - colon
     DTA B($8A) ;$43 - SHIFT-F1
     DTA B($8B) ;$44 - SHIFT-F2
     DTA B($4B) ;$45 - K
     DTA B($5C) ;$46 - \
     DTA B($5E) ;$47 - ^
     DTA B($4F) ;$48 - O
     DTA B($80) ;$49 - (invalid)
     DTA B($50) ;$4A - P
     DTA B($55) ;$4B - U
     DTA B($9B) ;$4C - SHIFT-return
     DTA B($49) ;$4D - I
     DTA B($5F) ;$4E - _
     DTA B($7C) ;$4F - |
     DTA B($56) ;$50 - V
     DTA B($80) ;$51 - (invalid)
     DTA B($43) ;$52 - C
     DTA B($8C) ;$53 - SHIFT-F3
     DTA B($8D) ;$54 - SHIFT-F4
     DTA B($42) ;$55 - B
     DTA B($58) ;$56 - X
     DTA B($5A) ;$57 - Z
     DTA B($24) ;$58 - $
     DTA B($80) ;$59 - (invalid)
     DTA B($23) ;$5A - #
     DTA B($26) ;$5B - &
     DTA B($1B) ;$5C - SHIFT-escape
     DTA B($25) ;$5D - %
     DTA B($22) ;$5E - "
     DTA B($21) ;$5F - !
     DTA B($5B) ;$60 - [
     DTA B($20) ;$61 - SHIFT-space
     DTA B($5D) ;$62 - ]
     DTA B($4E) ;$63 - N
     DTA B($80) ;$64 - (invalid)
     DTA B($4D) ;$65 - M
     DTA B($3F) ;$66 - ?
     DTA B($81) ;$67 - SHIFT-inverse
     DTA B($52) ;$68 - R
     DTA B($80) ;$69 - (invalid)
     DTA B($45) ;$6A - E
     DTA B($59) ;$6B - Y
     DTA B($9F) ;$6C - SHIFT-tab
     DTA B($54) ;$6D - T
     DTA B($57) ;$6E - W
     DTA B($51) ;$6F - Q
     DTA B($28) ;$70 - (
     DTA B($80) ;$71 - (invalid)
     DTA B($29) ;$72 - )
     DTA B($27) ;$73 - '
     DTA B($9C) ;$74 - SHIFT-delete
     DTA B($40) ;$75 - @
     DTA B($7D) ;$76 - SHIFT-clear
     DTA B($9D) ;$77 - SHIFT-insert
     DTA B($46) ;$78 - F
     DTA B($48) ;$79 - H
     DTA B($44) ;$7A - D
     DTA B($80) ;$7B - (invalid)
     DTA B($83) ;$7C - SHIFT-CAPS
     DTA B($47) ;$7D - G
     DTA B($53) ;$7E - S
     DTA B($41) ;$7F - A
* Control Characters
     DTA B($0C) ;$80 - CTRL-L
     DTA B($0A) ;$81 - CTRL-J
     DTA B($7B) ;$82 - CTRL-semicolon
     DTA B($80) ;$83 - (invalid)
     DTA B($80) ;$84 - (invalid)
     DTA B($0B) ;$85 - CTRL-K
     DTA B($1E) ;$86 - CTRL-left arrow
     DTA B($1F) ;$87 - CTRL-right arrow
     DTA B($0F) ;$88 - CTRL-O
     DTA B($80) ;$89 - (invalid)
     DTA B($10) ;$8A - CTRL-P
     DTA B($15) ;$8B - CTRL-U
     DTA B($9B) ;$8C - CTRL-return
     DTA B($09) ;$8D - CTRL-I
     DTA B($1C) ;$8E - CTRL-up arrow
     DTA B($1D) ;$8F - CTRL-down arrow
     DTA B($16) ;$90 - CTRL-V
     DTA B($80) ;$91 - (invalid)
     DTA B($03) ;$92 - CTRL-C
     DTA B($89) ;$93 - CTRL-F3
     DTA B($80) ;$94 - (invalid)
     DTA B($02) ;$95 - CTRL-B
     DTA B($18) ;$96 - CTRL-X
     DTA B($1A) ;$97 - CTRL-Z
     DTA B($80) ;$98 - (invalid)
     DTA B($80) ;$99 - (invalid)
     DTA B($85) ;$9A - CTRL-3
     DTA B($80) ;$9B - (invalid)
     DTA B($1B) ;$9C - CTRL-escape
     DTA B($80) ;$9D - (invalid)
     DTA B($FD) ;$9E - CTRL-2
     DTA B($80) ;$9F - (invalid)
     DTA B($00) ;$A0 - CTRL-comma
     DTA B($20) ;$A1 - CTRL-space
     DTA B($60) ;$A2 - CTRL-period
     DTA B($0E) ;$A3 - CTRL-N
     DTA B($80) ;$A4 - (invalid)
     DTA B($0D) ;$A5 - CTRL-M
     DTA B($80) ;$A6 - (invalid)
     DTA B($81) ;$A7 - CTRL-inverse
     DTA B($12) ;$A8 - CTRL-R
     DTA B($80) ;$A9 - (invalid)
     DTA B($05) ;$AA - CTRL-E
     DTA B($19) ;$AB - CTRL-Y
     DTA B($9E) ;$AC - CTRL-tab
     DTA B($14) ;$AD - CTRL-T
     DTA B($17) ;$AE - CTRL-W
     DTA B($11) ;$AF - CTRL-Q
     DTA B($80) ;$B0 - (invalid)
     DTA B($80) ;$B1 - (invalid)
     DTA B($80) ;$B2 - (invalid)
     DTA B($80) ;$B3 - (invalid)
     DTA B($FE) ;$B4 - CTRL-delete
     DTA B($80) ;$B5 - (invalid)
     DTA B($7D) ;$B6 - CTRL-clear
     DTA B($FF) ;$B7 - CTRL-insert
     DTA B($06) ;$B8 - CTRL-F
     DTA B($08) ;$B9 - CTRL-H
     DTA B($04) ;$BA - CTRL-D
     DTA B($80) ;$BB - (invalid)
     DTA B($84) ;$BC - CTRL-CAPS
     DTA B($07) ;$BD - CTRL-G
     DTA B($13) ;$BE - CTRL-S
     DTA B($01) ;$BF - CTRL-A

* TFKD - Table of Function Key Definitions
* Entry n is the ATASCII equivalent of adjusted function
* code n
TFKD DTA B($1C) ;0 - F1 key
     DTA B($1D) ;1 - F2 key
     DTA B($1E) ;2 - F3 key
     DTA B($1F) ;3 - F3 key
     DTA B($8E) ;4 - SHIFT-F1 key
     DTA B($8F) ;5 - SHIFT-F2 key
     DTA B($90) ;6 - SHIFT-F3 key
     DTA B($91) ;7 - SHIFT-F4 key

* KIR - Process Keyboard IRQ
* Exits via RTI
KIR  EQU *
     TXA
     PHA
     TYA
     PHA ;save X,Y
     LDY PORTB  ;port B memory control
     LDA KBCODE ;keyboard code
     CMP CH1    ;last key code
     BNE KIR1   ;if not last key code
     LDX KEYDEL ;keyboard debounce delay
     BNE KIR8   ;if delay not expired, tread as bou:
* Check for CTRL-F1.
KIR1 LDX KEYDIS  ;save keyboard disable flag
     CMP #CNTLF1
     BNE KIR4 ;if not CTRL-F1
* Process CTRL-F1
     TXA        ;keyboard disable flag
     EOR #$FF   ;complelent keyboard disable flag
     STA KEYDIS ;update keyboard disable flag
     BNE KIR2   ;if keyboard disabled
     TYA        ;port B memory control
     ORA #$04   ;turn off LED 1
     BNE KIR3   ;update port B memory control
KIR2 TYA        ;port B memory control
     AND #$FB   ;turn on LED 1
KIR3 TAY        ;updated port B memory control
     BCS KIR7   ;reset keyboard controls
* Check keyboard disable
KIR4 TXA      ;keyboard disable flag
     BNE KIR9 ;if keyboard disabled, exit
* Get character
     LDA KBCODE  ;keyyboard code
     TAX         ;character
* Check for CTRL-1
     CMP #CNTL1
     BNE KIR5 ;if not CTRL-1
* Process CTRL-1
     LDA SSFLAG ;start/stop flag
     EOR #$FF   ;complement start/stop flag
     STA SSFLAG ;update start/stop flag
     BCS KIR7   ;make CTRL-1 invisible
* Check character
KIR5 AND #$3F  ;mask off shift and control bits
     CMP #HELP
     BNE KIR10 ;if not HELP key
* Process HELP
     STX HELPFG ;indicate HELP key pressed
     BEQ KIR7   ;reset keyboard controls
* Process character
KIR6 STX CH  ;key code
     STX CH1 ;reset previous key code
* Reset keyboard controls.
KIR7 LDA #3
     STA KEYDEL ;re-initialize for debounce
     LDA #0
     STA ATRACT ;clear attract-mode timer/flag
* Prepare to exit
KIR8 LDA KRPDEL ;auto-repeat delay
     STA SRTIMR ;reset software key repeat timer
     LDA SDMCTL ;DMA control
     BNE KIR9   ;if DMA not disabled, exit
     LDA DMASAV ;saved DMA control
     STA SDMCTL ;DMA control
* Exit
KIR9 STY PORTB ;update port B memory control
     PLA
     TAY
     PLA
     TAX
     PLA
     RTI
* Check for CTRL-F2 or CTRL-F4.
KIR10 CPX #CNTLF2
     BEQ KIR12 ;if CTRL-F2
     CPX #CNTLF4
     BNE KIR6 ;if not CTRL-F4
* Process CTRL-F4
     LDA CHBAS  ;character set base
     LDX CHSALT ;character set alternate
     STA CHSALT ;update character set alternate
     STX CHBAS  ;update character set base
     CPX >ICSORG ;high international charact:
     BEQ KIR11   ;if international character:
     TYA      ;port B memory control
     ORA #$08 ;turn off LED 2
     TAY      ;updated port B memory control
     BNE KIR7 ;reset keyboard controls
KIR11 TYA      ;port B memory control
     AND #$F7 ;turn on LED 2
     TAY      ;updated port B memory control
     JMP KIR7 ;reset keyboard controls
* Process CTRL-F2
KIR12 LDA SDMCTL ;DMA control
     BEQ KIR9   ;if disabled, exit

     STA DMASAV ;save DMA state
     LDA #0     ;disable DMA
     STA SDMCTL ;DMA control
     BEQ KIR9   ;exit

* FDL - Process Display List Interrupt for Fine Scrol:
* Exits via RTI
FDL  EQU *
     PHA
     LDA COLOR2 ;playfield 2 color
*    EOR.w COLRSH ;modify with attract-mode c:
     DTA B($4D),A(COLRSH)
*    AND.w DRKMSK ;modify with attract-mode l:
     DTA B($2D),A(DRKMSK)
     STA WSYNC  ;wait for HBLANK synchroniz:
     STA COLPF1 ;playfield 1 color/luminanc:
     PLA
     RTI
