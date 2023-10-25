* EXP - Compute Power of e
* ENTRY   JSR EXP
* check program counter 22
P22  EQU *
X22  EQU 1/[P22/EXP]/[EXP/P22]
* EXP EQU *
* Initialize
     LDX <LOG10E ;base 10 logarithm of e
     LDY >LOG10E
     JSR FLD1R   ;load FR1
* Compute X*LOG10(E).
     JSR FMUL ;multiply
     BCS EXP6 ;if overflow, error
* Compute result = 10^(X*LOG10(E))
*    JMP EXP10 ;compute power of 10, return



* EXP10 - Compute Power of 10
* ENTRY   JSR EXP10
* check program counter 23
P23  EQU *
X23  EQU 1/[P23/EXP10]/[EXP10/P23]
* EXP10 EQU *
* Initialize
     LDA #0
     STA XFMFLG ;zero integer part
     LDA FR0
     STA SGNFLG ;save argument sign
     AND #$7F   ;extract absolute value
     STA FR0    ;update argument
* Check for argument less than 1
     SEC
     SBC #$40 ;subtract bias
     BMI EXP1 ;if argument < 1
* Extract integer and fractional parts of exponent
     CMP #FPREC-2
     BPL EXP6    ;if argument too big, error
     LDX <FPSCR
     LDY >FPSCR
     JSR FST0R   ;save argument
     JSR FPI     ;convert argument to integer
     LDA FR0
     STA XFMFLG  ;save interger part
     LDA FR0+1   ;most significant byte of integer part
     BNE EXP6    ;if integer part too large, error
     JSR IFP     ;convert integer part to floating point
     JSR FMOVE   ;???
     LDX <FPSCR
     LDY >FPSCR
     JSR FLD0R   ;argument
     JSR FSUB    ;subtract to get fractional part
* Compute 10 to fractional exponent
EXP1 LDA <NPCOEF
     LDX <P10COF
     LDY >P10COF
     JSR PLYEVL ;P(X)
     JSR FMOVE
     JSR FMUL   ;P(X)*P(X)
* Check integer part
     LDA XFMFLG ;integer part
     BEQ EXP4   ;if integer part zero
* Compute 10 to integer part
     CLC
     ROR @    ;integer part divided by 2
     STA FR1  ;exponent
     LDA #1   ;assume mantissa 1
     BCC EXP2 ;if integer part even
     LDA #$10 ;substitute mantissa 10
EXP2 STA FR1M ;mantissa
     LDX #FMPREC-1 ;offset to last byte of mantissa
     LDA #0
EXP3 STA FR1M+1,X  ;zero byte of mantissa
     DEX
     BPL EXP3 ;if not done
     LDA FR1  ;exponent
     CLC
     ADC #$40 ;add bias
     BCS EXP6 ;if too big, error
     BMI EXP6 ;if underflow, error
     STA FR1  ;10 to integer part
* Compute product of 10 to integer part and 10 to fractional part
     JSR FMUL ;multiply to get result
* Invert result if argument < 0
EXP4 LDA SGNFLG ;argument sign
     BPL EXP5   ;if argument >= 0
     JSR FMOVE
     LDX <FONE
     LDY >FONE
     JSR FLD0R  ;load FR0
     JSR FDIV   ;divide to get result
* Exit
EXP5 RTS ;return
* Return error.
EXP6 SEC ;indicate error
     RTS ;return

* P10COF - Power of 10 Coefficients
P10COF DTA B($3D,$17,$94,$19,$00,$00) ;0.0000179419
       DTA B($3D,$57,$33,$05,$00,$00) ;0.0000573305
       DTA B($3E,$05,$54,$76,$62,$00) ;0.0005547662
       DTA B($3E,$32,$19,$62,$27,$00) ;0.0032176227
       DTA B($3F,$01,$68,$60,$30,$36) ;0.0168603036
       DTA B($3F,$07,$32,$03,$27,$41) ;0.0732032741
       DTA B($3F,$25,$43,$34,$56,$75) ;0.2543345675
       DTA B($3F,$66,$27,$37,$30,$50) ;0.6627373050
       DTA B($40,$01,$15,$12,$92,$55) ;1.15129255
       DTA B($3F,$99,$99,$99,$99,$99) ;0.9999999999
P10LEN EQU *-P10COF
NPCOEF EQU [P10LEN]/FPREC

* LOG10E - Base 10 Logarithm of e
LOG10E DTA B($3F,$43,$42,$94,$48,$19) ;base 10 logarithm of e

* FONE - 1.0
FONE DTA B($40,$01,$00,$00,$00,$00) ;1.0

* XFORM - Transform
* Z = (X-C)/(X+C)
* ENTRY   JSR XFORM
XFORM EQU *
     STX FPTR2
     STY FPTR2+1
     LDX <PLYARG
     LDY >PLYARG
     JSR FST0R  ;save argument
     LDX FPTR2
     LDY FPTR2+1
     JSR FLD1R  ;load FR1
     JSR FADD   ;X+C
     LDX <FPSCR
     LDY >FPSCR
     JSR FST0R  ;store FR0
     LDX <PLYARG
     LDY >PLYARG
     JSR FLD0R  ;load FR0
     LDX FPTR2
     LDY FPTR2+1
     JSR FLD1R  ;load FR1
     JSR FSUB   ;X-C
     LDX <FPSCR
     LDY >FPSCR
     JSR FLD1R  ;load FR1
     JSR FDIV   ;divide to get result
     RTS        ;return

* LOG - Compute Base e Logarithm
* ENTRY   JSR LOG
*   FR0 = argument
* check program counter 24
P24  EQU *
X24  EQU 1/[P24/LOG]/[LOG/P24]
* LOG EQU *
     LDA #1   ;indicate base e logarithm
     BNE LOGS ;compute logartihm, return
*    JMP LOG10

* LOG10 - Compute Base 10 Logarithm
* ENTRY   JSR LOG10
*   FR0 = argument
* check program counter 25
P25  EQU *
X25  EQU 1/[P25/LOG10]/[LOG10/P25]
* LOG10 EQU *
     LDA #0   ;indicate base 10 logartihm
*    JMP LOGS ;compute logarithm, return

* LOGS - Compute Logarithm
* ENTRY   JSR LOGS
*   A = 0, if base 10 logarithm
*     = 1, if base e logartihm
*   FR0 = argument
* EXIT
*   C set, if error
*   C clear, if no error
*   FR0 = result
LOGS EQU *
* Initialize
     STA SGNFLG ;save logarithm base indicator
* Check argument
     LDA FR0   ;argument exponent
     BEQ LOGS1 ;if argument zero, error
     BMI LOGS1 ;if argument negative, error
* X = F*(10^Y), 1<F<10
* 10^Y HAS SAME EXP BYTE AS X
* & MANTISSA BYTE = 1 OR 10
     JMP LOGQ
* Return error
LOGS1 SEC ;indicate error
     RTS  ;return

* LOGC - Complete Computation of Logarithm
* ENTRY   JSR LOGC
*   SGNFLG = 0, if base 10 logarithmr
*          = 1, if base e logarithm
* NOTES
*   Problem: logic is convoluted because LOGQ code
*   was moved.
LOGC EQU *
* Initialize
     SBC #$40
     ASL @
     STA XFMFLG  ;save Y
     LDA FR0+1
     AND #$F0
     BNE LOGC2
     LDA #1      ;mantissa is 1
     BNE LOGC3   ;set mantissa
LOGC2 INC XFMFLG ;increment Y
     LDA #$10    ;mantissa is 10
LOGC3 STA FR1M   ;mantissa
     LDX #FMPREC-1 ;offset to last byte of mantissa
     LDA #0
LOGC4 STA FR1M+1,X ;zero byte of mantissa
     DEX
     BPL LOGC4   ;if not done
     JSR FDIV    ;X = X/(10^Y), S.B. IN (1,10)
* Compute LOG10(X), 1 <= X <= 10.
     LDX <SQR10
     LDY >SQR10
     JSR XFORM  ;Z = (X-C)/(X+C); C*C = 10
     LDX <FPSCR
     LDY >FPSCR
     JSR FST0R  ;SAVE Z
     JSR FMOVE
     JSR FMUL   ;Z*Z
     LDA <NLCOEF
     LDX <LGCOEF
     LDY >LGCOEF
     JSR PLYEVL ;P(Z*Z)
     LDX <FPSCR
     LDY >FPSCR
     JSR FLD1R  ;load FR1
     JSR FMUL   ;Z*P(Z*Z)
     LDX <FHALF
     LDY >FHALF
     JSR FLD1R
     JSR FADD   ;0.5 + Z*P(Z*Z)
     JSR FMOVE
     LDA #0
     STA FR0+1
     LDA XFMFLG
     STA FR0
     BPL LOGC5
     EOR #$FF  ;complement -1
     CLC
     ADC #1
     STA FR0
LOGC5 JSR IFP   ;convert integer to floating point
     BIT XFMFLG
     BPL LOGC6
     LDA #$80
     ORA FR0
     STA FR0    ;update exponent
LOGC6 JSR FADD  ;LOG(X) = LOG(X)+Y
* Check base of logarithm
     LDA SGNFLG ;logarithm base indicator
     BEQ LOGC7  ;if LOG10 (not LOG)
* Compute base e logarithm
     LDX <LOG10E ;base 10 logarithm of e
     LDY >LOG10E
     JSR FLD1R   ;load FR1
     JSR FDIV    ;result is LOG(X) divided by LOG10(e)
* Exit
LOGC7 CLC ;indicate success
     RTS  ;return

* SQR10 - Square Root of 10
SQR10 DTA B($40,$03,$16,$22,$77,$66) ;square root of 10

* FHALF - 0.5
FHALF DTA B($3F,$50,$00,$00,$00,$00) ;0.5

* LGCOEF - Logartihm Coefficients
LGCOEF DTA B($3F,$49,$15,$57,$11,$08) ;0.4915571108
       DTA B($BF,$51,$70,$49,$47,$08) ;-0.5170494708
       DTA B($3F,$39,$20,$57,$61,$95) ;0.3920576195
       DTA B($BF,$04,$39,$63,$03,$55) ;-0.0439630355
       DTA B($3F,$10,$09,$30,$12,$64) ;0.1009301264
       DTA B($3F,$09,$39,$08,$04,$60) ;0.0939080460
       DTA B($3F,$12,$42,$58,$47,$42) ;0.1242584742
       DTA B($3F,$17,$37,$12,$06,$08) ;0.1737120608
       DTA B($3F,$28,$95,$29,$71,$17) ;0.2895297117
       DTA B($3F,$86,$85,$88,$96,$44) ;0.8685889644
LGCOLN EQU *-LGCOEF
NLCOEF EQU LGCOLN/FPREC

* ATCOEF - Arctangent Coefficients
* NOTES
*   Problem: not used.
 DTA B($3E,$16,$05,$44,$49,$00) ;0.001605444900
 DTA B($BE,$95,$68,$38,$45,$00) ;-0.009568384500
 DTA B($3F,$02,$68,$79,$94,$16) ;0.0268799416
 DTA B($BF,$04,$92,$78,$90,$80) ;-0.0492789080
 DTA B($3F,$07,$03,$15,$20,$00) ;0.0703152000
 DTA B($BF,$08,$92,$29,$12,$44) ;-0.0892291244
 DTA B($3F,$11,$08,$40,$09,$11) ;0.1108400911
 DTA B($BF,$14,$28,$31,$56,$04) ;-0.1428315604
 DTA B($3F,$19,$99,$98,$77,$44) ;0.1999987744
 DTA B($BF,$33,$33,$33,$31,$13) ;-0.3333333113
 DTA B($3F,$99,$99,$99,$99,$99) ;0.9999999999

 DTA B($3F,$78,$53,$98,$16,$34) ;pi/4 = arctan 1

* LOGQ - Continue Computation of Loagarithm
* ENTRY   JSR     LOGQ
* NOTES
*   Problem: logic is convoluted because this code was
*   moved.
*   Problem: for readability, this might be relocated
*   before tables.
LOGQ EQU *
     LDA FR0
     STA FR1
     SEC
     JMP LOGC ;complete computation of logarithm, return
