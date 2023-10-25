* SUBTTL 'Central Input/Output'

* ICIO - Initialize CIO
ICIO EQU *
* Initialize IOCB's
     LDX #0       ;index of first IOCB
ICIO1 LDA #IOCFRE ;IOCB free indicator
     STA ICHID,X  ;set IOCB free
     LDA <[IIN-1]
     STA ICPTL,X  ;initialize PUT-BYTE routine address
     LDA >[IIN-1]
     STA ICPTH,X 
     TXA ;index of current IOCB
     CLC
     ADC #IOCBSZ ;add IOCB size
     TAX         ;index of next IOCB
     CMP <MAXIOC ;index of first invalid IOCB
     BCC ICIO1   ;if not done
     RTS ;return

* IIN - Indicate IOCB Not Open Error
* EXIT
*   Y = IOCB Not Open error code
IIN  EQU *      
     LDY #NOTOPN ;IOCB not open error
     RTS         ;return

* CIO - Central Input/Output
CIO  EQU *
* Initialize
     STA CIOCHR  ;save possible output byte value
     STX ICIDNO  ;save IOCB index
* Check IOCB index validity
     TXA         ;IOCB index
     AND #$0F    ;index modulo 16
     BNE CIO1    ;if IOCB not multiple of 16, error
     CPX <MAXIOC ;index of first invalid IOCB
     BCC CIO2    ;if index within range
* Indicate Invalid IOCB Index error
CIO1 LDY #BADIOC ;invalid IOCB index error
     JMP SSC     ;set status and complete operation, return
* Move part of IOCB to zero page IOCB.
CIO2 LDY #0       ;offset to first byte of page zero IOCB
CIO3 LDA IOCB,X   ;byte of IOCB
     STA IOCBAS,Y ;byte of zero page IOCB
     INX
     INY
     CPY <ICSPRZ-IOCBAS ;offset to first undesired byte
     BCC CIO3    ;if not done
* Check for provisionally open IOCB
     LDA ICHIDZ  ;handler ID
     CMP #$7F    ;provisionally open indicator
     BNE PCC     ;if not provisionally open, perform:
* Check for CLOSE command
     LDA ICCOMZ  ;command
     CMP #CLOSE
     BEQ XCL     ;if CLOSE command
* Check handler load flag
     LDA HNDLOD
     BNE LHO ;if handler load desired
* Indicate nonexistent device error
*    JMP IND ;indicate nonexistent device error,:

* IND - Indicate Nonexistent Device Error
IND  EQU *      
     LDY #NONDEV ;nonexistent device error
IND1 JMP SSC     ;set status and complete operation,:

* LHO - Load Peripheral Handler for OPEN
* ENTRY   JSR LHO
LHO  EQU *   
     JSR PHL  ;load and initialize peripheral han:
     BMI IND1 ;if error
*    JMP PCC  ;perform CIO command, return

* PCC - Perform CIO Command
PCC  EQU     *      
* Check command validity
     LDY #NVALID ;assume invalid code
     LDA ICCOMZ  ;command
     CMP #OPEN   ;first valid command
     BCC XOP1    ;if command invalid
     TAY         ;command
     CPY #SPECIL ;last valid command
     BCC PCC1    ;if valid
     LDY #SPECIL ;substitute SPECIAL command
* Obtain vector offset
PCC1 STY ICCOMT   ;save command
     LDA TCVO-3,Y ;vector offset for command
     BEQ XOP      ;if OPEN command, process
* Perform command
     CMP #2
     BEQ XCL ;if CLOSE command, process
     CMP #8
     BCS XSS ;if STATUS or SPECIAL command, process
     CMP #4
     BEQ XGT ;if GET command, process
     JMP XPT ;process PUT command, process

* XOP - Execute OPEN Command
XOP  EQU *
* Check IOCB free
     LDA ICHIDZ  ;handler ID
     CMP #IOCFRE ;IOCB free indicator
     BEQ XOP2    ;if IOCB free
* Process error
     LDY #PRVOPN ;IOCB previously open error
XOP1 JMP SSC     ;set status and complete operation, return
* Check handler load
XOP2 LDA HNDLOD
     BNE PPO ;if user wants unconditional poll
* Search handler table
     JSR SHT ;search handler table
     BCS PPO ;if not found, poll
* Initialize status
     LDA #0
     STA DVSTAT  ;clear status
     STA DVSTAT+1
* Initialize IOCB
*    JMP IIO ;initialize IOCB for OPEN, return

* IIO - Initialize IOCB for OPEN
IIO  EQU *
* Compute handler entry point
     JSR CEP  ;compute handler entry point
     BCS XOP1 ;if error
* Execute command
     JSR EHC ;execute handler command
* Set PUT-BYTE routine address in IOCB
     LDA #PUTCHR
     STA ICCOMT  ;command
     JSR CEP     ;compute handler entry point
     LDA ICSPRZ  ;PUT-BYTE routine address
     STA ICPTLZ  ;IOCB PUT-BYTE routine address
     LDA ICSPRZ+1
     STA ICPTHZ
     JMP CCO ;complete CIO operation, return

* PPO - Peripheral for OPEN
PPO  EQU *
     JSR PHO ;poll
     JMP SSC ;set status and complete operation

* XCL - Execute CLOSE Command
* ENTRY   JSR XCL
XCL  EQU *
* Initialize
     LDY #SUCCES ;assume success
     STY ICSTAZ  ;status
     JSR CEP     ;compute handler entry point
     BCS XCL1    ;if error
* Execute command
     JSR EHC ;execute handler command
* Close IOCB
XCL1 LDA #IOCFRE ;IOCB free indicator
     STA ICHIDZ  ;indicate IOCB free
     LDA >[IIN-1]
     STA ICPTHZ  ;reset initial PUT-BYTE routine address
     LDA <[IIN-1]
     STA ICPTLZ
     JMP CCO ;complete CIO operation, return

* XSS - Execute STATUS and SPECIAL Commands
* ???word about implicit OPEN and CLOSE
XSS  EQU *
* Check IOCB free
     LDA ICHIDZ  ;handler ID
     CMP #IOCFRE
     BNE XSS1    ;if IOCB not free
* Open IOCB
     JSR SHT  ;search handler table
     BCS XOP1 ;if error
* Execute command
XSS1 JSR CEP ;compute handler entry point
     JSR EHC ;execute handler command
* Restore handler ID, in case IOCB implicitly opened
     LDX ICIDNO  ;IOCB index
     LDA ICHID,X ;original handler ID
     STA ICHIDZ  ;restore zero page handler ID
     JMP CCO     ;complete CIO operation, return

* XGT - Execute GET Command
XGT  EQU *
* Check GET validity
     LDA ICCOMZ ;command
     AND ICAX1Z ;???
     BNE XGT2   ;if GET command valid
* Process error
     LDY #WRONLY ;IOCB opened for write only error
XGT1 JMP SSC     ;set status and complete operation, return
* Compute and check handler entry point
XGT2 JSR CEP  ;compute handler entry point
     BCS XGT1 ;if error
* Check buffer length
     LDA ICBLLZ  ;buffer length
     ORA ICBLLZ+1
     BNE XGT3    ;if buffer length non-zero
* Get byte
     JSR EHC    ;execute handler command
     STA CIOCHR ;data
     JMP CCO    ;complete CIO operation, return
* Fill buffer
XGT3 JSR EHC    ;execute handler command
     STA CIOCHR ;data
     BMI XGT7   ;if error, end transfer
     LDY #0
     STA (ICBALZ),Y ;byte of buffer
     JSR IBP    ;increment buffer pointer
     LDA ICCOMZ ;command
     AND #$02
     BNE XGT4   ;if GET RECORD command
* Check for EOL
     LDA CIOCHR ;data
     CMP #EOL
     BNE XGT4   ;if not EOL
* Process EOL
     JSR DBL  ;decrement buffer length
     JMP XGT7 ;clean up
* Check buffer full
XGT4 JSR DBL  ;decrement buffer length
     BNE XGT3 ;if buffer not full, continue
* Check command
     LDA ICCOMZ ;command
     AND #$02
     BNE XGT7   ;if GET CHARACTER command, clean up
* Process GET RECORD
XGT5 JSR EHC    ;execute handler command
     STA CIOCHR ;data
     BMI XGT6   ;if error
* Check for EOL
     LDA CIOCHR ;data
     CMP #EOL
     BNE XGT5   ;if not EOL, continue
* Process end of record
     LDA #TRNRCD ;truncated record error
     STA ICSTAZ  ;status
* Process error
XGT6 JSR DBP  ;decrement buffer pointer
     LDY #0
     LDA #EOL
     STA (ICBALZ),Y ;set EOL in buffer
     JSR IBP ;increment buffer pointer
* Clean up
XGT7 JSR SFL ;set final buffer length
     JMP CCO ;complete CIO operation, return

* XPT - Execute PUT Command
XPT  EQU *
* Check PUT validity
     LDA ICCOMZ  ;command
     AND ICAX1Z
     BNE XPT2 ;if PUT command valid
* Process error
     LDY #RDONLY ;IOCB opened for read only error
XPT1 JMP SSC ;set status and complete operation, return
* Compute and check handler entry point
XPT2 JSR CEP  ;compute handler entry point
     BCS XPT1 ;if error
* Check buffer length
     LDA ICBLLZ ;buffer length
     ORA ICBLLZ+1
     BNE XPT3 ;if buffer length non-zero
* Put byte
     LDA CIOCHR ;data
     INC ICBLLZ ;set buffer length to 1
     BNE XPT4   ;transfer one byte
* Transfer data from buffer to handler
XPT3 LDY #0
     LDA (ICBALZ),Y ;byte from buffer
     STA CIOCHR     ;data
XPT4 JSR EHC  ;execute handler command
     PHP      ;save status
     JSR IBP  ;increment buffer pointer
     JSR DBL  ;decrement buffer length
     PLP      ;status
     BMI XPT6 ;if error
* Check command
     LDA ICCOMZ  ;command
     AND #$02
     BNE XPT5 ;if PUT RECORD command
* Check for EOL
     LDA CIOCHR ;data
     CMP #EOL
     BEQ XPT6 ;if EOL, clean up
* Check for buffer empty
XPT5 LDA ICBLLZ  ;buffer length
     ORA ICBLLZ+1
     BNE XPT3    ;if buffer not empty, continue
* Check command
     LDA ICCOMZ ;command
     AND #$02
     BNE XPT6 ;if PUT CHARACTER command
* Write EOL
     LDA #EOL
     JSR EHC ;execute handler command
* Clean up
XPT6 JSR SFL ;set final buffer length
     JMP CCO ;complete CIO operation, return

* SSC - Set Status and Complete Operation
SSC  EQU *     
     STY ICSTAZ ;status
*    JMP CCO    ;complete CIO operation, return

* CCO - Complete CIO Operation
CCO  EQU *
* Initialize
     LDY ICIDNO ;IOCB index
* Restore buffer pointer
     LDA ICBAL,Y
     STA ICBALZ ;restore buffer pointer
     LDA ICBAH,Y
     STA ICBAHZ
* Move part of zero page IOCB to IOCB
     LDX #0 ;first byte of zero page IOCB
     STX HNDLOD
CCO1 LDA IOCBAS,X ;byte of zero page IOCB
     STA IOCB,Y   ;byte of IOCB
     INX
     INY
     CPX #ICSPRZ-IOCBAS ;offset to first undesired byte
     BCC CCO1 ;if not done
* Restore A, X and Y
     LDA CIOCHR ;data
     LDX ICIDNO ;IOCB index
     LDY ICSTAZ ;status
     RTS

* CEP - Compute Handler Entry Point
CEP  EQU *
* Check handler ID validity
     LDY ICHIDZ    ;handler ID
     CPY #MAXDEV+1 ;first invalid ID
     BCC CEP1      ;if handler ID within range
* Process error
     LDY #NOTOPN ;IOCB not open error
     BCS CEP2
* Compute entry point
CEP1 LDA HATABS+1,Y ;low address
     STA ICSPRZ
     LDA HATABS+2,Y ;high address
     STA ICSPRZ+1
     LDY ICCOMT     ;command
     LDA TCVO-3,Y   ;vector offset for command
     TAY
     LDA (ICSPRZ),Y ;low vector address
     TAX            ;low vector address
     INY
     LDA (ICSPRZ),Y ;high vector address
     STA ICSPRZ+1   ;set high address
     STX ICSPRZ     ;set low address
     CLC            ;indicate success
* Exit
CEP2 RTS

* DBL - Decrement Buffer Length
* EXIT
*   Z set if buffer length = 0
DBL  EQU *
     LDA ICBLLZ   ;low buffer length
     BNE DBL1     ;if low buffer length non-zero
     DEC ICBLLZ+1 ;decrement high buffer length
DBL1 DEC ICBLLZ   ;decrement low buffer length
     LDA ICBLLZ
     ORA ICBLLZ+1 ;indicate buffer length status
     RTS

* DBP - Decrement Buffer Pointer
DBP  EQU *
     LDA ICBALZ ;low buffer address
     BNE DBP1   ;if low buffer address non-zero
     DEC ICBALZ+1 ;decrement high buffer address
DBP1 DEC ICBALZ ;decrement low buffer address
     RTS

* IBP - Increment Buffer Pointer
IBP  EQU *
     INC ICBALZ ;increment low buffer address
     BNE IBP1   ;if low buffer address non-zero
     INC ICBALZ+1 ;increment high buffer address
IBP1 RTS

* SFL - Set Final Buffer Length
SFL  EQU *
     LDX ICIDNO  ;IOCB index
     SEC
     LDA ICBLL,X ;initial length
     SBC ICBLLZ  ;subtract byte count
     STA ICBLLZ  ;update length
     LDA ICBLH,X
     SBC ICBLLZ+1
     STA ICBLHZ
     RTS

* EHC - Execute Handler Command
EHC  EQU *
     LDY #FNCNOT ;assume function not defined error
     JSR IDH     ;invoke device handler
     STY ICSTAZ  ;status
     CPY #0      ;set N accordingly
     RTS

* IDH - Invoke Device Handler
IDH  EQU *
     TAX          ;save A
     LDA ICSPRZ+1 ;high vector
     PHA          ;put high vector on stack
     LDA ICSPRZ   ;low vector
     PHA          ;put low vector on stack
     TXA          ;restore A
     LDX ICIDNO   ;IOCB index
     RTS ;invoke handler (address on stack)

* SHT - Search Handler Table
SHT  EQU *
* Set device number
     SEC
     LDY #1
     LDA (ICBALZ),Y ;device number
     SBC #'1'
     BMI SHT1 ;if number less than  "1"
     CMP #'9'-'1'+1
     BCC SHT2 ;if number in range "1" to "9"
SHT1 LDA #0   ;substitute device number "1"
SHT2 STA ICDNOZ ;device number (0 through 8)
     INC ICDNOZ ;adjust number to range 1 t:
* Find device handler
     LDY #0         ;offset to device code
     LDA (ICBALZ),Y ;device code
*    JMP FDH        ;find device handler, return

* FDH - Find Device Handler
FDH  EQU *
* Check device code
     BEQ FDH2 ;if device code null
* Search handler table for device
     LDY #MAXDEV  ;offset to last possible entry
FDH1 CMP HATABS,Y ;device code from table
     BEQ FDH3     ;if device found
     DEY
     DEY
     DEY
     BPL FDH1 ;if not done
* Process device not found
FDH2 LDY #NONDEV ;nonexistent device error
     SEC ;indicate error
     RTS
* Set handler ID
FDH3 TYA ;offset to device code in table
     STA ICHIDZ ;set handler ID
     CLC ;indicate no error
     RTS

* TCVO - Table of Command Vector Offsets
* Entry n is the vector offset for command n+3.
TCVO DTA B(0) ;3 open
     DTA B(4) ;4
     DTA B(4) ;5 get record
     DTA B(4) ;6
     DTA B(4) ;7 get byte(s)
     DTA B(6) ;8
     DTA B(6) ;9 put record
     DTA B(6) ;10
     DTA B(6) ;11 put byte(s)
     DTA B(2) ;12 close
     DTA B(8) ;13 status
     DTA B(10) ;14 special
