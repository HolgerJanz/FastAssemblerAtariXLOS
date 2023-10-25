* ILP - Initialize Line Buffer Pointer
* ENTRY   JSR ILP
* EXIT
*   INBUFF-INBUFF+1= line buffer address
ILP  EQU *
     LDA >LBUFF ;high buffer address
     STA INBUFF+1 ;high line buffer pointer
     LDA <LBUFF ;low buffer address
     STA INBUFF ;low line buffer pointer
     RTS        ;return

* SIL - Shift Integer Left
* ENTRY   JSR SIL
*   ZTEMP4-ZTEMP4+1= number (high, low) to shift
* EXIT
*   ZTEMP4-ZTEMP4+1 shifted left 1
SIL  EQU *  
     CLC
     ROL ZTEMP4+1 ;shift low
     ROL ZTEMP4   ;shift high
     RTS          ;return

* FSUB - Perform Floating Point Subtract
* FSUB subtracts FR1 from FR0.
* ENTRY   JSR FSUB
*   FR0 = minuend
*   FR1 = subtrahend
* EXIT
*   C set, if error
*   C clear, if no error
*   FR0 = difference
* check program counter 10
P10  EQU *
X10  EQU 1/[P10/FSUB]/[FSUB/P10]
* FSUB EQU *
* Complement sign of subtrahend and add
     LDA FR1  ;subtrahend exponent
     EOR #$80 ;complement sign of subtrahend
     STA FR1  ;update subtrahend exponent
*    JMP FADD ;perform add, return

* FADD - Perform Floating Point Add
* ENTRY   JSR FADD
*   FR0 = augend
*   FR1 = addend
* EXIT
*   C set, if error
*   C clear, if no error
*   FR0 = sum
* check program counter 11
P11  EQU *
X11  EQU 1/[P11/FADD]/[FADD/P11]
* FADD EQU *
* Initialize
FADD1 LDA FR1   ;exponent of addend
     AND #$7F   ;clear sign of addend mantissa
     STA ZTEMP4 ;save addend exponent
     LDA FR0    ;exponent of augend
     AND #$7F   ;clear sign of augend mantissa
     SEC
     SBC ZTEMP4 ;subtract addend exponent
     BPL FADD3  ;if augend exponent >= addend exponent
* Swap augend and addend
     LDX #FPREC-1 ;offset to last byte
FADD2 LDA FR0,X   ;byte of augend
     LDY FR1,X    ;byte of addend
     STA FR1,X    ;move byte of augend to addend
     TYA
     STA FR0,X ;move byte of addend to augend
     DEX
     BPL FADD2 ;if not done
     BMI FADD1 ;re-initialize
* Check alignment
FADD3 BEQ FADD4  ;if exponent difference zero, already aligned
     CMP #FMPREC ;mantissa precision
     BCS FADD6   ;if exponent difference < mantissa precision
* Align
     JSR S1R ;shift FR1 right
* Check for like signs of mantissas
FADD4 SED
     LDA FR0   ;augend exponent
     EOR FR1   ;EOR with addend exponent
     BMI FADD8 ;if signs differ, subtract
* Add
     LDX #FMPREC-1 ;offset to last byte of mantissa
     CLC
FADD5 LDA FR0M,X ;byte of augend mantissa
     ADC FR1M,X  ;add byte of addend mantissa
     STA FR0M,X  ;update byte of result mantissa
     DEX
     BPL FADD5 ;if not done
     CLD
     BCS FADD7 ;if carry, process carry
* Exit
FADD6 JMP NORM ;normalize, return
* Process carry
FADD7 LDA #1  ;indicate shift 1
     JSR S0R  ;shift FR0 right
     LDA #1   ;carry
     STA FR0M ;set carry in result
* Exit
     JMP NORM ;normalize, return
* Subtract
FADD8 LDX #FMPREC-1 ;offset to last byte of mantissa
     SEC
FADD9 LDA  FR0M,X ;byte of augend mantissa
     SBC  FR1M,X  ;subtract byte of addend mantissa
     STA  FR0M,X  ;update byte of result mantissa
     DEX
     BPL  FADD9   ;if not done
     BCC  FADD10  ;if borrow, process borrow
* Exit
     CLD
     JMP NORM ;normalize ???, return
* Process borrow
FADD10 LDA FR0 ;result exponent
     EOR #$80  ;complement sign of result
     STA FR0   ;update result exponent
     SEC
     LDX #FMPREC-1 ;offset to last byte of mantissa
FADD11 LDA #0
     SBC FR0M,X ;complement byte of result mantissa
     STA FR0M,X ;update byte of result mantissa
     DEX
     BPL FADD11 ;if not done
* Exit
     CLD
     JMP NORM ;normalize ???, return

* FMUL - Perform Floating Point Multiply
* ENTRY   JSR     FMUL
*   FR0 = multiplicand
*   FR1 = multiplier
* EXIT
*   C set, if error
*   C clear, if no error
*   FR0 = product
* check program counter 12
P12  EQU *
X12  EQU 1/[P12/FMUL]/[FMUL/P12]
* FMUL EQU *
* Check for zero multiplicand
     LDA FR0   ;multiplicand exponent
     BEQ FMUL8 ;if multiplicand exponent zero, result is zero
* Check for zero multiplier
     LDA FR1   ;multiplier exponent
     BEQ FMUL7 ;if multiplier exponent zero, result is zero
     JSR SUE   ;set up exponent
     SEC
     SBC #$40  ;subtract bias
     SEC       ;add 1
     ADC FR1   ;add multiplier exponent
     BMI FMUL9 ;if overflow, error
* Set up
     JSR SUP   ;set up
* Compute number of times to add multiplicand
FMUL1 LDA FRE+FPREC-1 ;last byte of FRE
     AND #$0F         ;extract low order digit
     STA ZTEMP1+1
* Check for completion
FMUL2 DEC ZTEMP1+1 ;decrement counter
     BMI FMUL3 ;if done
     JSR FRA10 ;add FR1 to FR0
     JMP FMUL2 ;continue
* Compute number of times to add 10 times multiplicand
FMUL3 LDA FRE+FPREC-1 ;last byte of FRE
     LSR @
     LSR @
     LSR @
     LSR @ ;high order digit
     STA ZTEMP1+1
* Check for completion
FMUL4 DEC ZTEMP1+1 ;decrement counter
     BMI FMUL5 ;if done
     JSR FRA20 ;add FR2 to FR0
     JMP FMUL4 ;continue
* Set up for next set of adds
FMUL5 JSR S0ER ;shift FR0/FRE right
* Decrement counter and test for completion
     DEC ZTEMP1 ;decrement
     BNE FMUL1  ;if not done
* Set exponent
FMUL6 LDA EEXP ;exponent
     STA FR0   ;result exponent
     JMP N0E   ;normalize, return
* Return zero result
FMUL7 JSR ZFR0 ;zero FR0
* Return no error
FMUL8 CLC ;indicate no error
     RTS  ;return
* Return error
FMUL9 SEC ;indicate error
     RTS  ;return

* FDIV - Perform Floating Point Divide
* ENTRY   JSR     FDIV
*   FR0 dividend
*   FR1 divisor
* EXIT
*   C clear, if no error
*   C set, if error
*   FR0 quotient
* check program counter 13
P13  EQU *
X13  EQU 1/[P13/FDIV]/[FDIV/P13]
* FDIV EQU *
* Check for zero divisor
     LDA FR1   ;divisor exponent
     BEQ FMUL9 ;if divisor exponent zero, error
* Check for zero dividend
     LDA FR0    ;dividend exponent
     BEQ FMUL8  ;if dividend exponent zero, result is zero
     JSR SUE    ;set up exponent
     SEC
     SBC FR1    ;subtract divisor exponent
     CLC
     ADC #$40   ;add bias
     BMI FMUL9  ;if overflow, error
     JSR SUP    ;set up
     INC ZTEMP1 ;divide requires extra pass
     JMP FDIV3  ;skip shift
* Shift FR0/FRE left one byte
FDIV1 LDX #0         ;offset to first byte to shift
FDIV2 LDA FR0+1,X    ;byte to shift
     STA FR0,X       ;byte of destination
     INX
     CPX #FMPREC*2+2 ;number of bytes to shift
     BNE FDIV2       ;if not done
* Subtract 2 times divisor from dividend
FDIV3 LDY #FPREC-1 ;offset to last byte
     SEC
     SED
FDIV4 LDA FRE,Y ;byte of dividend
     SBC FR2,Y  ;subtract byte of 2*divisor
     STA FRE,Y  ;update byte of dividend
     DEY
     BPL FDIV4  ;if not done
     CLD
     BCC FDIV5  ;if difference < 0
     INC QTEMP  ;increment
     BNE FDIV3  ;continue
* Adjust
FDIV5 JSR FRA2E ;add FR2 to FR0
* Shift last byte of quotient left one digit
     ASL QTEMP
     ASL QTEMP
     ASL QTEMP
     ASL QTEMP
* Subtract divisor from dividend
FDIV6 LDY #FPREC-1 ;offset to last byte
     SEC
     SED
FDIV7 LDA FRE,Y ;byte of dividend
     SBC FR1,Y  ;subtract byte of divisor
     STA FRE,Y  ;update byte of dividend
     DEY
     BPL FDIV7  ;if not done
     CLD
     BCC FDIV8  ;if difference < 0
     INC QTEMP  ;increment
     BNE FDIV6  ;continue
* Adjust
FDIV8 JSR FRA1E ;add FR1 to FR0
     DEC ZTEMP1 ;decrement
     BNE FDIV1  ;if not done
* Clear exponent
     JSR     S0ER ;shift  FR0/FRE right
* Exit
     JMP     FMUL6

* GNC - Get Next Character
* ENTRY   JSR GNC
*   INBUFF-INBUFF+1 = line buffer pointer
*   CIX = offset to character
* EXIT
*   C set, if character not numeric
*   A = non-numeric character
*   C clear, if character numeric
*   CIX = offset to next character
GNC  EQU *  
     JSR TNC ;test for numeric character
     LDY CIX ;offset
     BCC ICX ;if numeric, increment offset, return
     LDA (INBUFF),Y ;character
*    JMP ICX ;increment offset, return

* ICX - Increment Character Offset
* ENTRY   JSR ICX
*   Y = offset
* EXIT
*   CIX = offset to next character
ICX  EQU *  
     INY     ;increment offset
     STY CIX ;offset
     RTS     ;return

* SLB - Skip Leading Blanks
* ENTRY   JSR SLB
*   INBUFF-INBUFF+1 = line buffer pointer
*   CIX = offset
* EXIT
*   CIX = offset to first non-blank character
SLB  EQU *
* Initialize.
     LDY CIX ;offset to character
     LDA #' '
* Search for first non-blank character
SLB1 CMP (INBUFF),Y ;character
     BNE SLB2 ;if non-blank character
     INY
     BNE SLB1 ;if not done
* Exit
SLB2 STY CIX ;offset to first non-blank character
     RTS     ;return

* TNC - Test for Numeric Character
* ENTRY   JSR     TNC
*   INBUFF-INBUFF+1 = line buffer pointer
*   CIX = offset
* EXIT
*   C set, if numeric
*   C clear if non-numeric
TNC  EQU *  
     LDY CIX ;offset
     LDA (INBUFF),Y ;character
     SEC
     SBC #'0'
     BCC TVN2 ;if < "0", return failure
     CMP #'9'-'0'+1 ;return success or failure
     RTS

* TVN - Test for Valid Number Character
* ENTRY   JSR TVN
* EXIT
*   C set, if not number
*   C clear, if number
* NOTES
*   Problem: bytes wasted by BCC TVN5.
TVN  EQU *
* Initialize
     LDA CIX ;offset
     PHA     ;save offset
* Check next character
     JSR GNC  ;get next character
     BCC TVN5 ;if numeric, return success
     CMP #'.'
     BEQ TVN4 ;if ".", check next character
     CMP #'+'
     BEQ TVN3 ;if "+", check next character
     CMP #'-'
     BEQ TVN3 ;if "-", check next character
* Clean stack
TVN1 PLA ;clean stack
* Return failure
TVN2 SEC ;indicate failure
     RTS ;return
* Check character after "+" or "-"
TVN3 JSR GNC  ;get next character
     BCC TVN5 ;if numeric, return success
     CMP #'.'
     BNE TVN1 ;if not ".", return failure
* Check character after ".".
TVN4 JSR GNC  ;get next character
     BCC TVN5 ;if numeric, return success
     BCS TVN1 ;return failure
* Return success
TVN5 PLA     ;saved offset
     STA CIX ;restore offset
     CLC     ;indicate success
     RTS     ;return

* S2L - Shift FR2 Left One Digit
* ENTRY   JSR S2L
S2L  EQU *
     LDX #FR2+1 ;indicate shift of FR2 mantissa
     BNE SML    ;shift mantissa left 1 digit, return
*    JMP S0L

* S0L - Shift FR0 Left One Digit
* ENTRY   JSR S0L
S0L  EQU *
     LDX #FR0M ;indicate shift of FR0 mantissa
*    JMP SML   ;shift mantissa left 1 digit, return

* SML - Shift Mantissa Left One Digit
* ENTRY   JSR SML
* EXIT
*   FRX = excess digit
SML  EQU *
     LDY #4 ;number of bits to shift
SML2 CLC
     ROL $0004,X ;shift 5th byte left 1 bit
     ROL $0003,X ;shift 4th byte left 1 bit
     ROL $0002,X ;shift 3rd byte left 1 bit
     ROL $0001,X ;shift 2nd byte left 1 bit
     ROL $0000,X ;shift 1st byte left 1 bit
     ROL FRX     ;shift excess digit left 1 bit
     DEY
     BNE SML2 ;if not done
     RTS
