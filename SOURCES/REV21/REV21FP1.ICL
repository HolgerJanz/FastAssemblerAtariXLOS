* SUBTTL 'Floating Point Package'

* FPP - Floating Point Package

* FPP is a collection of routines for floating point
* computations.  A floating point number is represented
* in 6 bytes:
* Byte 0
*   Bit 7      Sign of mantissa
*   Bits 0 - 6 BCD exponent, biased by $40
* Bytes 1 - 5  BCD mantissa

* AFP - Convert ASCII to Floating Point
* ENTRY   JSR AFP
*   INBUFF = line buffer pointer
*   CIX = offset to first byte of number
* EXIT
*   C clear, if valid number
*   C set, if invalid number
* NOTES
*   Problem: bytes wasted by check for "-", near AFP7.
* check program counter 04
P04  EQU *
X04  EQU 1/[P04/AFP]/[AFP/P04]
* AFP  EQU *
* Initialize
     JSR SLB ;skip leading blanks
* Check for number
     JSR TVN  ;test for valid number character
     BCS AFP5 ;if not number character
* Set initial values
     LDX #EEXP ;exponent
     LDY #4    ;indicate 4 bytes to clear
     JSR ZXLY
     LDX #$FF
     STX DIGRT ;number of digits after decimal point
     JSR ZFR0  ;zero FR0
     BEQ AFP2  ;get first character
* Indicate not first character
AFP1 LDA #$FF   ;indicate not first character
     STA FCHFLG ;first character flag
* Get next character
AFP2 JSR GNC  ;get next character
     BCS AFP6 ;if character not numeric
* Process numeric character
     PHA      ;save digit
     LDX FR0M ;first byte
     BNE AFP3 ;if not zero
     JSR S0L  ;shift FR0 left 1 digit
     PLA      ;saved digit
     ORA FR0M+FMPREC-1 ;insert into last byte
     STA FR0M+FMPREC-1 ;update last byte
* Check for decimal point
     LDX DIGRT ;number of digits after decimal point
     BMI AFP1  ;if no decimal point, process next character
* Increment number of digits after decimal point
     INX       ;increment number of digits
     STX DIGRT ;number of digits after decimal point
     BNE AFP1  ;process next character
* Increment exponent, if necessary
AFP3 PLA       ;clean stack
     LDX DIGRT ;number of digits after decimal point
     BPL AFP4  ;if already have decimal point
     INC EEXP  ;increment number of digits more than 9
* Process next character
AFP4 JMP AFP1 ;process next character
* Exit
AFP5 RTS ;return
* Process non-numeric character
AFP6 CMP #'.'
     BEQ AFP8   ;if ".", process decimal point
     CMP #'E'
     BEQ AFP9   ;if "E", process exponent
     LDX FCHFLG ;first character flag
     BNE AFP16  ;if not first character, process end of input
     CMP #'+'
     BEQ AFP1   ;if "+", process next character
     CMP #'-'
     BEQ AFP7   ;if "-", process negative sign
* Process negative sign
AFP7 STA NSIGN ;sign of number
     BEQ AFP1  ;process next character
* Process decimal point
AFP8 LDX DIGRT ;number of digits after decimal point
     BPL AFP16 ;if already have decimal point
     INX       ;zero
     STX DIGRT ;number of digits after decimal point
     BEQ AFP1  ;process next character
* Process exponent
AFP9 LDA CIX   ;offset to character
     STA FRX   ;save offset to character
     JSR GNC   ;get next character
     BCS AFP13 ;if not numeric
* Process numeric character in exponent
AFP10 TAX     ;first character of exponent
     LDA EEXP ;number of digits more than 9
     PHA      ;save number of digits more than 9
     STX EEXP ;first character of exponent
* Process second character of exponent
     JSR GNC   ;get next character
     BCS AFP11 ;if not numeric, no second digit
     PHA       ;save second digit
     LDA EEXP  ;first digit
     ASL @     ;2 times first digit
     STA EEXP  ;2 times first digit
     ASL @     ;4 times first digit
     ASL @     ;8 times first digit
     ADC EEXP  ;add 2 times first digit
     STA EEXP  ;save 10 times first digit
     PLA       ;saved second digit
     CLC
     ADC EEXP  ;insert in exponent
     STA EEXP  ;update exponent
* Process third character of exponent???
     LDY CIX   ;offset to third character
     JSR ICX   ;increment offset
AFP11 LDA ESIGN ;sign of exponent
     BEQ AFP12 ;if no sign on exponent
* Process negative exponent
     LDA EEXP ;exponent
     EOR #$FF ;complement exponent
     CLC
     ADC #1   ;add 1 for 2's complement
     STA EEXP ;update exponent
* Add in number of digits more than 9
AFP12 PLA ;saved number of digits more than 9
     CLC
     ADC EEXP  ;add exponent
     STA EEXP  ;update exponent
     BNE AFP16 ;process end of input
* Process non-numeric in exponent
AFP13 CMP #'+'
     BEQ AFP14 ;if "+", process next character
     CMP #'-'
     BNE AFP15 ;if not "-", ???
     STA ESIGN ;save sign of exponent
* Process next character
AFP14 JSR GNC  ;get next character
     BCC AFP10 ;if numeric, process numeric character
* Process other non-numeric in exponent
AFP15 LDA FRX ;saved offset
     STA CIX  ;restore offset
* Process end of input
AFP16 DEC CIX  ;decrement offset
     LDA EEXP  ;exponent
     LDX DIGRT ;number of digits after decimal point
     BMI AFP17 ;if no decimal point
     BEQ AFP17 ;if no digits after decimal point
     SEC
     SBC DIGRT ;subtract number of digits after decimal point
AFP17 PHA ;save adjusted exponent
     ROL @ ;set C with sign of exponent
     PLA  ;saved adjusted exponent
     ROR @ ;shift right
     STA EEXP  ;save power of 100
     BCC AFP18 ;if no carry, process even number
     JSR S0L   ;shift FR0 left 1 digit
AFP18 LDA EEXP ;exponent
     CLC
     ADC #$40+4 ;add bias plus 4 for normalization
     STA FR0    ;save exponent
     JSR NORM   ;normalize number
     BCS AFP20  ;if error
* Check sign of number
     LDX NSIGN ;sign of number
     BEQ AFP19 ;if sign of number not negative
* Process negative number
     LDA FR0  ;first byte of mantissa
     ORA #$80 ;indicate negative
     STA FR0  ;update first byte of mantissa
* Exit
AFP19 CLC ;indicate valid number
AFP20 RTS ;return

* FASC - Convert Floating Point Number to ASCII
* ENTRY   JSR FASC
*   FR0 - FR0+5 = number to convert
* EXIT
*   INBUFF = pointer to start of number
*   High order bit of last charecter set
* check program counter 05
P05  EQU *
X05  EQU 1/[P05/FASC]/[FASC/P05]
* FASC EQU *
* Initialize
     JSR ILP   ;initialize line buffer pointer
     LDA #'0'
     STA LBPR2 ;put "0" in front of line buffer
* Check for E format required
     LDA FR0    ;exponent
     BEQ FASC2  ;if exponent zero, number zero
     AND #$7F   ;clear sign
     CMP #$40-1 ;bias-1
     BCC FASC3  ;if exponent < bias-1, E format required
     CMP #$40+5 ;bias+5
     BCS FASC3  ;if >= bias+5, E format required
* Process E format not required
     SEC
     SBC #$40-1  ;subtract bias-1, yielding decimal position
     JSR C0A     ;convert FR0 to ASCII
     JSR FNZ     ;find last non-zero character
     ORA #$80    ;set high order bit
     STA LBUFF,X ;update last character
     LDA LBUFF   ;first character
     CMP #'.'
     BEQ FASC1   ;if decimal point
     JMP FASC10
FASC1 JSR DLP    ;decrement line buffer pointer
     JMP FASC11  ;perform final adjustment
* Process zero
FASC2 LDA #$80+'0' ;"0" with high order bit set
     STA LBUFF   ;put zero character in line buffer
     RTS         ;return
* Process E format required
FASC3 LDA #1 ;GET DECIMAL POSITION???
     JSR C0A ;convert FR0 to ASCII
     JSR FNZ ;find last non-zero character
     INX     ;increment offset to last character
     STX CIX ;save offset to last character
* Adjust exponent
     LDA FR0    ;exponent
     ASL @      ;double exponent
     SEC
     SBC #$40*2 ;subtract 2 times bias
* Check first character for "0"
     LDX LBUFF ;first character
     CPX #'0'
     BEQ FASC5 ;if "0"
* Put decimal after first character
     LDX LBUFF+1 ;second character
     LDY LBUFF+2 ;decimal point
     STX LBUFF+2 ;decimal point
     STY LBUFF+1 ;third character
     LDX CIX     ;offset
     CPX #2      ;former offset to decimal point
     BNE FASC4   ;if offset pointed to second character
     INC CIX     ;increment offset
FASC4 CLC
     ADC #1      ;adjust exponent for movement of decimal point
* Convert exponent to ASCII
FASC5 STA EEXP ;exponent
     LDA #'E'
     LDY CIX   ;offset
     JSR SAL   ;store ASCII character in line buffer
     STY CIX   ;save offset
     LDA EEXP  ;exponent
     BPL FASC6 ;if exponent positive
     LDA #0
     SEC
     SBC EEXP  ;complement exponent
     STA EEXP  ;update exponent
     LDA #'-'
     BNE FASC7 ;store "-"
FASC6 LDA #'+'
FASC7 JSR SAL  ;store ASCII character in line buffer
     LDX #0    ;initial number of 10's
     LDA EEXP  ;exponent
FASC8 SEC
     SBC #10   ;subtract 10
     BCC FASC9 ;if < 0, done
     INX       ;increment number of 10's
     BNE FASC8 ;continue
FASC9 CLC
     ADC #10  ;add back 10
     PHA      ;save remainder
     TXA      ;number of 10's
     JSR SNL  ;store number in line buffer
     PLA      ;saved remainder
     ORA #$80 ;set high order bit
     JSR SNL  ;store number in line buffer
* Perform final adjustment
FASC10 LDA LBUFF ;first character
     CMP #'0'
     BNE FASC11  ;if not "0", ???
* Increment pointer to point to non-zero character
     CLC
     LDA INBUFF  ;line buffer pointer
     ADC #1      ;add 1
     STA INBUFF  ;update line buffer pointer
     LDA INBUFF+1
     ADC #0
     STA INBUFF+1
* Check for positive exponent
FASC11 LDA FR0  ;exponent
     BPL FASC12 ;if exponent positive, exit
* Process negative exponent
    JSR DLP ;decrement line buffer pointer
    LDY #0  ;offset to first character
    LDA #'-'
    STA (INBUFF),Y ;put "-" in line buffer
* Exit
FASC12  RTS ;return

* IFP - Convert Integer to Floating Point Number
* ENTRY   JSR     IFP
*   FR0 - FR0+1 = integer to convert
* EXIT
*   FR0 - FR0+5 = floating point number
* check program counter 06
P06  EQU *
X06  EQU 1/[P06/IFP]/[IFP/P06]
* IFP EQU *
* Initialize
     LDA FR0      ;low integer
     STA ZTEMP4+1 ;save low integer
     LDA FR0+1    ;high integer
     STA ZTEMP4   ;save high integer
     JSR ZFR0     ;zero FR0
* Convert to floating point
     SED
     LDY #16      ;number of bits in integer
IFP1 ASL ZTEMP4+1 ;shift integer
     ROL ZTEMP4   ;shift integer, setting C if bit present
     LDX #3       ;offset to last possible byte of number
IFP2 LDA FR0,X    ;byte of number
     ADC FR0,X    ;double byte, adding in carry
     STA FR0,X    ;update byte of number
     DEX
     BNE IFP2 ;if not done
     DEY      ;decrement count of integer bits
     BNE IFP1 ;if not done
     CLD
* Set exponent
     LDA #$40+2 ;indicate decimal after last digit
     STA FR0    ;exponent
* Exit
     JMP NORM ;normalize, return

* FPI - Convert Floating Point Number to Integer
* ENTRY   JSR FPI
*         FR0 - FR0+5 = floating point number
* EXIT
*   C set, if error
*   C clear, if no error
*   FR0 - FR0+1 = integer
* check program counter 07
P07  EQU *
X07  EQU 1/[P07/FPI]/[FPI/P07]
* FPI EQU *
* Initialize
     LDA #0
     STA ZTEMP4  ;zero integer
     STA ZTEMP4+1
* Check exponent
     LDA FR0    ;exponent
     BMI FPI4   ;if sign of exponent is negative, error
     CMP #$40+3 ;bias+3
     BCS FPI4   ;if number too big, error
     SEC
     SBC #$40 ;subtract bias
     BCC FPI2 ;if number less than 1, test for round
* Compute number of digits to convert
     ADC #0 ;add carry
     ASL @  ;2 times exponent-$40+1
     STA ZTEMP1 ;number of digits to convert
* Convert
FPI1 JSR SIL      ;shift integer left
     BCS FPI4     ;if number too big, error
     LDA ZTEMP4   ;2 times integer
     STA ZTEMP3   ;save 2 times integer
     LDA ZTEMP4+1
     STA ZTEMP3+1
     JSR SIL      ;shift integer left
     BCS FPI4     ;if number too big, error
     JSR SIL      ;shift integer left
     BCS FPI4     ;if number too big, error
     CLC
     LDA ZTEMP4+1 ;8 times integer
     ADC ZTEMP3+1 ;add 2 times integer
     STA ZTEMP4+1 ;10 times integer
     LDA ZTEMP4
     ADC ZTEMP3
     STA ZTEMP4
     BCS FPI4     ;if overflow???, error
     JSR GND      ;get next digit
     CLC
     ADC ZTEMP4+1 ;insert digit in ???
     STA ZTEMP4+1 ;update ???
     LDA ZTEMP4   ;???
     ADC #0       ;add carry
     BCS FPI4     ;if overflow, error
     STA ZTEMP4   ;update ???
     DEC ZTEMP1   ;decrement count of digits to convert
     BNE FPI1     ;if not done
* Check for round required
FPI2 JSR GND  ;get next digit
     CMP #5
     BCC FPI3 ;if digit less than 5, do not round
* Round
     CLC
     LDA ZTEMP4+1
     ADC #1 ;add 1 to round
     STA ZTEMP4+1
     LDA ZTEMP4
     ADC #0
     STA ZTEMP4
* Return integer
FPI3 LDA ZTEMP4+1 ;low integer
     STA FR0      ;low integer result
     LDA ZTEMP4 ;high integer
     STA FR0+1  ;high integer result
     CLC ;indicate success
     RTS ;return
* Return error
FPI4 SEC ;indicate error
     RTS ;return

* ZFR0 - Zero FR0
* ENTRY   JSR ZFR0
* check program counter 08
P08  EQU *
X08  EQU 1/[P08/ZFR0]/[ZFR0/P08]
* ZFR0 EQU *
     LDX #FR0 ;indicate zero FR0
*    JMP ZF1  ;zero floating point number, return

* ZF1 - Zero Floating Point Number
* ENTRY   JSR ZF1
*   X = offset to register
* check program counter 09
P09  EQU *
X09  EQU 1/[P09/ZF1]/[ZF1/P09]
* ZF1 EQU *  
     LDY #6   ;number of bytes to zero
*    JMP ZXLY ;zero bytes, return

* ZXLY - Zero Page Zero Location X for Length Y
* ENTRY   JSR ZXLY
*   X = offset
*   Y = length
ZXLY EQU *
     LDA #0
ZXLY1 STA $0000,X ;zero byte
     INX
     DEY
     BNE ZXLY1 ;if not done
     RTS       ;return
