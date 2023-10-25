*NORM - Normalize FR0
*ENTRY   JSR NORM
NORM EQU *
     LDX #0
     STX FRE ;byte to shift in
*   JMP N0E ;normalize FR0/FRE, return

*N0E - Normalize FR0/FRE
*ENTRY   JSR N0E
N0E  EQU *
     LDX #FMPREC-1 
     LDA FR0  ;exponent
     BEQ N0E5 ;if exponent zero, number is zero
N0E1 LDA FR0M ;first byte of mantissa
     BNE N0E3 ;if not zero, no shift
*Shift mantissa left 1 byte
     LDY #0 ;offset to first byte of mantissa
N0E2 LDA FR0M+1,Y ;byte to shift
     STA FR0M,Y   ;byte of destination
     INY
     CPY #FMPREC ;size of mantissa
     BCC N0E2    ;if not done
*Decrement exponent and check for completion
     DEC FR0  ;decrement exponent
     DEX
     BNE N0E1 ;if not done
*Check first byte of mantissa
     LDA FR0M ;first byte of mantissa
     BNE N0E3 ;if mantissa not zero
*Zero exponent
     STA FR0 ;zero exponent
     CLC
     RTS ;return
*Check for overflow
N0E3 LDA FR0  ;exponent
     AND #$7F ;clear sign
     CMP #$40+49 ;bias+49
     BCC N0E4 ;if exponent < 49, no overflow
*Return error
*   SEC ;indicate error
     RTS ;return
*Check for underflow
N0E4 CMP #$40-49
     BCS N0E5 ;if exponent >= -49, no underflow
*Zero result
     JSR ZFR0 ;zero FR0
*Exit
N0E5 CLC ;indicate no error
     RTS ;return

*S0R - Shift FR0 Right
*ENTRY   JSR S0R
*  A = shift count
S0R  EQU *   
     LDX #FR0    ;indicate shift of FR0
     BNE SRR     ;shift register right, return
*   JMP S1R

*S1R - Shift FR1 Right
*ENTRY   JSR S1R
*  A = shift count
S1R  EQU *
     LDX #FR1 ;indicate shift of FR1
*   JMP SRR  ;shift register right, return

*SRR - Shift Register Right
*ENTRY   JSR SRR
*  X = offset to register
*  A = shift count
SRR  EQU *   
     STX ZTEMP3  ;register
     STA ZTEMP4  ;shift count
     STA ZTEMP4+1  ;save shift count
SRR1 LDY #FMPREC-1 ;mantissa size-1
SRR2 LDA $0004,X ;byte to shift
     STA $0005,X ;byte of destination
     DEX
     DEY
     BNE SRR2    ;if not done
     LDA #0
     STA $0005,X ;first byte of mantissa
     LDX ZTEMP3  ;register
     DEC ZTEMP4  ;decrement shift count
     BNE SRR1    ;if not done
*Adjust exponent
     LDA $0000,X  ;exponent
     CLC
     ADC ZTEMP4+1 ;subtract shift count
     STA $0000,X  ;update exponent
     RTS          ;return

*S0ER - Shift FR0/FRE Right
*ENTRY   JSR S0ER
S0ER EQU *     
     LDX #FMPREC*2 ;number of bytes to shift
S0ER1 LDA FR0,X    ;byte to shift
     STA FR0+1,X   ;byte of destination
     DEX
     BPL S0ER1 ;if not done
     LDA #0
     STA FR0   ;shift in 0
     RTS       ;return

*C0A - Convert FR0 to ASCII
*ENTRY   JSR C0A
*  A = decimal point position
C0A  EQU *
*Initialize
     STA ZTEMP4 ;decimal point position counter
     LDX #0     ;offset to first byte of FR0M
     LDY #0     ;offset to first byte of LBUF
*Convert next byte
C0A1 JSR TDP    ;test for decimal point
     SEC
     SBC #1     ;decrement deciaml point position
     STA ZTEMP4 ;update deciaml point position counter
*Convert first digit of next byte
     LDA FR0M,X ;byte
     LSR @
     LSR @
     LSR @
     LSR @   ;first digit
     JSR SNL ;store number in line buffer
*Convert second digit of next byte
     LDA FR0M,X ;byte
     AND #$0F   ;extract second digit
     JSR SNL    ;store number in line buffer
     INX
     CPX #FMPREC ;nuber of bytes
     BCC C0A1    ;if not done
*Exit
*   JMP TDP ;test for decimal point, return

*TDP - Test for Decimal Point
*ENTRY   JSR TDP
*  ZTEMP4 = decimal point position counter
TDP  EQU *
*Check decimal point position counter
     LDA ZTEMP4 ;decimal point position counter
     BNE TDP1   ;if not decimal point position, exit
*Insert decimal point
     LDA #'.'
     JSR SAL ;store ASCII character in line buffer
*Exit
TDP1 RTS ;return

*SNL - Store Number in Line Buffer
*ENTRY   JSR SNL
*  A = digit to store
*  Y = offset
*EXIT
*  ASCII digit placed in line buffer
SNL  EQU *
     ORA #$30 ;convert digit to ASCII
*   JMP SAL  ;store ASCII character in line buffer, return

*SAL - Store ASCII Character in Line Buffer
*ENTRY   JSR SAL
*  Y = offset
*  A = character
*EXIT
*  Character placed in line buffer
*  Y = incremented offset
SAL  EQU *
     STA LBUFF,Y ;store character in line buffer
     INY ;increment offset
     RTS ;return

*FNZ - Find Last Non-zero Character in Line Buffer
*FNZ returns the last non-zero character.  If the last
*non-zero character is ".", FNZ returns the character
*preceding the ".".  If no other non-zero character is
*encountered, FNZ returns the first character.
*ENTRY   JSR FNZ
*EXIT
*  A = character
*  X = offset to character
FNZ  EQU *
*Initialize
     LDX #10 ;offset to last possible character
*Check next character
FNZ1 LDA LBUFF,X ;character
     CMP #'.'
     BEQ FNZ2 ;if ".", return preceding character
     CMP #'0'
     BNE FNZ3 ;if not "0", exit
*Decrement offset and check for completion.
     DEX
     BNE FNZ1 ;if not done
*Return character preceding "." or first character
FNZ2 DEX ;offset to character
     LDA LBUFF,X ;character
*Exit.
FNZ3 RTS ;return

*GND - Get Next Digit
*ENTRY   JSR GND
*  FR0 - FR0+5 = number
*EXIT
*  A = digit
GND  EQU *
     JSR S0L  ;shift FR0 left 1 digit
     LDA FRX  ;excess digit
     AND #$0F ;extract low order digit
     RTS      ;return

*DLP - Decrement Line Buffer Pointer
*ENTRY   JSR DLP
*  INBUFF-INBUFF+1 = line buffer pointer
*EXIT
*  INBUFF-INBUFF+1 = incremented line buffer pointer
DLP  EQU *
     SEC
     LDA INBUFF ;line buffer pointer
     SBC #1     ;subtract 1
     STA INBUFF ;update line buffer pointer
     LDA INBUFF+1
     SBC #0
     STA INBUFF+1
     RTS ;return

*SUE - Set Up Exponent for Multiply or Divide
*ENTRY   JSR SUE
*EXIT
*  A = FR0 exponent (without sign)
*  FR1 = FR1 exponent (without sign)
*  FRSIGN = sign of result
SUE  EQU *  
     LDA FR0    ;FR0 exponent
     EOR FR1    ;EOR with FR1 exponent
     AND #$80   ;extract sign
     STA FRSIGN ;sign of result
     ASL FR1    ;shift out FR1 sign
     LSR FR1    ;FR1 exponent without sign
     LDA FR0    ;FR0 exponent
     AND #$7F   ;FR0 exponent without sign
     RTS        ;return

*SUP - Set Up for Multiply or Divide
*ENTRY   JSR SUP
*  A = exponent
SUP  EQU *  
     ORA FRSIGN ;place sign in exponent
     STA EEXP ;exponent
     LDA #0
     STA FR0  ;clear FR0 exponent
     STA FR1  ;clear FR0 exponent
     JSR M12  ;move FR1 to FR2
     JSR S2L  ;shift FR2 left 1 digit
     LDA FRX  ;excess digit
     AND #$0F ;extract low order digit
     STA FR2  ;shift in low order digit
     LDA #FMPREC ;mantissa size
     STA ZTEMP1  ;mantissa size
     JSR M0E  ;move FR0 to FRE
     JSR ZFR0 ;zero FR0
     RTS      ;return

*FRA10 - Add FR1 to FR0
*ENTRY   JSR FRA10
*  FR0 = augend
*  FR1 = addend
*EXIT
*  FR0 = sum
FRA10 EQU *
     LDX #FR0+FPREC-1 ;offset to last byte of FR0
     BNE F1R
*   JMP FRA20

*FRA20 - Add FR2 to FR0
*ENTRY   JSR FRA20
*  FR0 = augend
*  FR2 = addend
*EXIT
*  FR0 = sum
FRA20 EQU *
     LDX #FR0+FPREC-1 ;offset to last byte of FR0
     BNE F2R
*   JMP FRA1E

*FRA1E - Add FR1 to FRE
*ENTRY   JSR FRA1E
*  FRE = augend
*  FR1 = addend
*EXIT
*  FRE = sum
FRA1E EQU *
     LDX #FRE+FPREC-1 ;offset to last byte of FRE
*   JMP F1R ;add FR1 to register, return

*F1R - Add FR1 to Register
*ENTRY   JSR F1R
*  X = offset to last byte of augend register
*  FR1 = addend
*EXIT
*  Sum in augend register
F1R  EQU *
     LDY #FR1+FPREC-1 ;offset to last byte of FR1
     BNE FARR
*   JMP FRA2E

*FRA2E - Add FR2 to FRE
*ENTRY   JSR FRA2E
*  FRE = augend
*  FR2 = addend
*EXIT
*  FRE = sum
FRA2E EQU *
     LDX #FRE+FPREC-1 ;offset to last byte of FRE
*   JMP F2R

*F2R - Add FR2 to Register
*ENTRY   JSR F2R
*  X = offset to last byte of augend register
*  FR2 = addend
*EXIT
*  Sum in augend register
F2R  EQU *
     LDY #FR2+FPREC-1 ;offset to last byte of FR2
*   JMP FARR

*FARR - Add Register to Register
*ENTRY   JSR FARR
*  X = offset to last byte of augend register
*  Y = offset to last byte of addend register
*EXIT
*  Sum in augend register
FARR EQU *
*Initialize
     LDA #FPREC-1 ;floating point number size-1
     STA ZTEMP4   ;byte count
     CLC
     SED
*Add
FARR1 LDA $0000,X ;byte of augend
     ADC $0000,Y  ;add byte of addend
     STA $0000,X  ;update byte of augend
     DEX
     DEY
     DEC ZTEMP4   ;decrement byte count
     BPL FARR1    ;if not done
*Exit.
     CLD
     RTS ;return

*M12 - Move FR1 to FR2
*ENTRY   JSR M12
*  FR1 = number to move
*EXIT
*  FR2 = moved number
M12  EQU *
     LDY #FPREC-1 ;offset to last byte
M121 LDA FR1,Y ;byte of source
     STA FR2,Y ;byte of destination
     DEY
     BPL M121  ;if not done
     RTS       ;return

*M0E - Move FR0 to FRE
*ENTRY   JSR M0E
*  FR0 = number to move
*EXIT
*  FRE = moved number
M0E  EQU *
     LDY #FPREC-1 ;offset to last byte
M0E1 LDA FR0,Y ;byte of source
     STA FRE,Y ;byte of destination
     DEY
     BPL M0E1  ;if not done
     RTS ;return

*PLYEVL - Evaluate Polynomial
*Y = A(0)+A(1)*X+A(2)*X^2+...+A(N)*X^N
*ENTRY   JSR PLYEVL
*  X = low address of coefficient table
*  Y = high address of coefficient table
*  FR0 = X argument
*  A = N+1
*EXIT
*  FR0 = Y result
*check program counter 14
P14  EQU *
X14  EQU 1/[P14/PLYEVL]/[PLYEVL/P14]
*PLYEVL EQU *
     STX FPTR2   ;save pointer to coefficients
     STY FPTR2+1
     STA PLYCNT  ;degree
     LDX <PLYARG
     LDY >PLYARG
     JSR FST0R   ;save argument
     JSR FMOVE   ;move argument to FR1
     LDX FPTR2
     LDY FPTR2+1
     JSR FLD0R   ;initialize sum in FR0
     DEC PLYCNT  ;decrement degree
     BEQ PLY3    ;if complete, exit
PLY1 JSR FMUL    ;argument times current sum
     BCS PLY3    ;if overflow
     CLC
     LDA FPTR2   ;current low coefficient address
     ADC #FPREC  ;add floating point number size
     STA FPTR2   ;update low coefficient address
     BCC PLY2    ;if no carry
     LDA FPTR2+1 ;current high coefficceint address
     ADC #0      ;adjust high coefficient address
     STA FPTR2+1 ;update high coefficient address
PLY2 LDX FPTR2   ;low coefficient address
     LDY FPTR2+1 ;high coefficient address
     JSR FLD1R   ;get next coefficient
     JSR FADD    ;add coefficient to argument times sum
     BCS PLY3    ;if overflow
     DEC PLYCNT  ;decrement degree
     BEQ PLY3    ;if complete, exit
     LDX <PLYARG ;low argument address
     LDY >PLYARG ;high argument address
     JSR FLD1R   ;get argument
     BMI PLY1    ;continue
PLY3 RTS ;return

*FLD0R - ???
*ENTRY   JSR FLD0R
*  X = low pointer
*  Y = high pointer
*EXIT
*  FR0 loaded
*check program counter 15
P15  EQU *
X15  EQU 1/[P15/FLD0R]/[FLD0R/P15]
*FLD0R EQU *
     STX FLPTR   ;low pointer
     STY FLPTR+1 ;high pointer
*   JMP FLD0P   ;load FR0, return

*FLD0P - Load FR0
*ENTRY   JSR FLD0P
*  FLPTR = pointer
*EXIT
*  FR0 loaded
*check program counter 16
P16  EQU *
X16  EQU 1/[P16/FLD0P]/[FLD0P/P16]
*FLD0P EQU *
     LDY #FPREC-1   ;offset to last byte
FLD01 LDA (FLPTR),Y ;byte of source
     STA FR0,Y      ;byte of destination
     DEY
     BPL FLD01 ;if not done
     RTS       ;return

*FLD1R - Load FR1
*ENTRY   JSR FLD1R
*  X = low pointer
*  Y = high pointer
*EXIT
*  FR1 loaded
*check program counter 17
P17  EQU *
X17  EQU 1/[P17/FLD1R]/[FLD1R/P17]
*FLD1R EQU *
     STX FLPTR   ;low pointer
     STY FLPTR+1 ;high pointer
*   JMP FLD1P   ;load FR1, return

*FLD1P - Load FR1
*ENTRY   JSR FLD1P
*  FLPTR = pointer
*EXIT
*  FR1 loaded
*check program counter 18
P18  EQU *
X18  EQU 1/[P18/FLD1P]/[FLD1P/P18]
*FLD1P EQU *
     LDY #FPREC-1   ;offset to last byte
FLD11 LDA (FLPTR),Y ;byte of source
     STA FR1,Y ;byte of destination
     DEY
     BPL FLD11 ;if not done
     RTS ;return

*FST0R - Store FR0
*ENTRY   JSR FST0R
*  FR0 = number
*  X = low pointer
*  Y = high pointer
*EXIT
*  FR0 stored
*check program counter 19
P19  EQU *
X19  EQU 1/[P19/FST0R]/[FST0R/P19]
*FST0R EQU *
     STX FLPTR   ;low pointer
     STY FLPTR+1 ;high pointer
*   JMP FST0P

*FST0P - Store FR0
*ENTRY   JSR FST0P
*  FR0 = number
*  FLPTR = pointer
*EXIT
*  FR0 stored
*check program counter 20
P20  EQU *
X20  EQU 1/[P20/FST0P]/[FST0P/P20]
*FST0P EQU *
     LDY #FPREC-1  ;offset to last byte
FST01 LDA FR0,Y    ;byte of source
     STA (FLPTR),Y ;byte of destination
     DEY
     BPL FST01 ;if not done
     RTS       ;return

*FMOVE - Move FR0 to FR1
*ENTRY   JSR FMOVE
*check program counter 21
P21  EQU *
X21  EQU 1/[P21/FMOVE]/[FMOVE/P21]
*FMOVE EQU *
     LDX #FPREC-1 ;offset to last byte
FMO1 LDA FR0,X ;byte of source
     STA FR1,X ;byte of destination
     DEX
     BPL FMO1  ;if not done
     RTS ;return
