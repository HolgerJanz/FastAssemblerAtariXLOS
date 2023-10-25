* SUBTTL 'Peripheral Handler Loading Facility, Part 5'

* PHE - Perform Peripheral Handler Entry
* PHE attempts to enter a peripheral handler in the handler table.
* ENTRY   JSR     PHE
*   X = device code
*   A = high linkage table address
*   Y = low linkage table address
* EXIT
*   Success:
*   C clear
*   Handler table entry made
*   Failure due to entry previously made:
*   C set
*   N clear
*   X = offset to second byte of duplicate entry
*   A, Y unchanged
*   Failure due to handler table full:
*   C set
*   N set
* CHANGES
*   A X Y
PHE  EQU *
* Initialize
     PHA ;save high linkage table address
     TYA
     PHA ;save low linkage table address
* Search for device code in handler table
     TXA    ;device code
     LDX #0 ;offset to first entry of table
PHE1 CMP HATABS,X ;device code from table
     BEQ PHE3     ;if device code found
     INX
     INX
     INX
     CPX #MAXDEV+1 ;offset+1 of last possible entry
     BMI PHE1      ;if not done
* Search for empty entry in handler table
     LDX #0 ;offset to first entry of table
     TAY    ;save device code
     LDA #0
PHE2 CMP HATABS,X ;device code from table
     BEQ PHE4     ;if empty entry found
     INX
     INX
     INX
     CPX #MAXDEV+1 ;offset+1 of last possible entry
     BMI PHE2      ;if not done
* Return table full condition
     PLA ;clean stack
     PLA
     LDY #$FF ;indicate table full (set N)
     SEC ;indicate failure
     RTS
* Return device code found condition
PHE3 PLA ;saved Y
     TAY ;restore Y
     PLA ;restore A
     INX ;indicate device code found (clear N)
     SEC ;indicate failure
     RTS ;return
* Enter handler in table
PHE4 TYA            ;device code
     STA HATABS,X   ;enter device code
     PLA            ;saved low linkage table address
     STA HATABS+1,X ;low address
     PLA            ;saved high linkage table address
     STA HATABS+2,X ;high address
* Return success condition
     CLC ;indicate success
     RTS

* PHO - Perform Peripheral Handler Poll at OPEN
* Subroutine to perform Type 4 Poll at OPEN time, and
* "provisionally" open IOCB if peripheral answers.
* Input parameters:
*   ICIDNO identifies calling IOCB;
*   From zero-page IOCB:
*     ICBALZ,ICBAHZ (buffer pointer)
*     ICDNOZ (device number from caller's filespe:
*   From caller's buffer: device name (in filespec.)
* Output parameters:
* "No device" error returned if Poll not answered.
* If poll is answered, the calling IOCB is "Provision:
*   opened (and successful status is returned)-:
*   ICHIDZ set to mark provisional open
*   ICPTLZ,ICPTHZ points to PTL (special PUT-BY:
*   ICSPR in calling IOCB set to device name (f:
*   ICSPR+1 in calling IOCB set to device seria:
* Modified:
*   Registers not saved.
* Subroutines called:
*   PHP performs poll.
* NOTES
*   Problem: in the CRASS65 version, ICIDNO was:
*   zero-page.
PHO  EQU *
     LDY #0       ;Call for Type 4 Poll with
     LDA (ICBALZ),Y ;device name from user
     LDY ICDNOZ   ;OPEN
     JSR PHPP
     BPL PHO1     ;if poll answered
     LDY #NONDEV  ;Return "no device" error
     RTS          ;return
PHO1 LDA #$7F     ;"Provisionally" OPEN the I:
     STA ICHIDZ   ;(Mark "provisional")
     LDA <[PTL-1]
     STA ICPTLZ   ;(Special put byte routine :
     LDA >[PTL-1]
     STA ICPTHZ
     LDA DVSTAT+2 ;(Peripheral address for lo:
     DTA B($AE),A(ICIDNO) ;LDX.w ICIDNO
     STA ICSPR+1,X
     LDY #0
     LDA (ICBALZ),Y ;(Device name from user)
     STA ICSPR,X
     LDY #SUCCES ;indicate success
     RTS

* PTL - Perform PUT-BYTE for Provisionally Open IOCB
* Put byte entry for provisionally opened IOCB's.
* This routine performs load, relocation, initializat:
* and finishes OPEN, then calls handler's put byte en:
* Input parameters:
*   A Byte to output;
*   X IOCB index (IOCB number times 16);
*   Y "Function not supported" error code $92.
*   AUX1 and AUX2 in zero-page IOCB are copied from the:
*   IOCB prior to the call to PTL.
* Output parameters:
*   Various errors may be returned if loading fails (ei:
*   did not allow loading by setting HNDLOD fla:
*   was a loading error or calling error);
* If no loading error, this routine returns nothing--:
*   returned is returned by the loaded PUT-BYTE:
*   is called by this routine after the handler:
*   initialized, and opened.
* Modified:
*   ICIDNO (a CIO variable);
*   all of the zero-page IOCB is copied fromt he callin:
*   normal CIO open-operation variables are affected;
*   after opening, the zero-page IOCB is copied to the :
*   Registers not saved if error return;if handler is l:
*     and opened properly, the caller's A and X r:
*     passed to the loaded handler's PUT-BYTE rou:
*     Y is passed to that routine as $92)--then r:
*     on return is up to handler PUT-BYTE since i:
*     directly to caller.
* Subroutines called:
*   PHL (does loading, initializing and opening--calls :
*   loaded handler's INIT, OPEN, and PUT-BYTE entries a:
*   The PUT-BYTE entry returns directly to the PTL call:
* NOTES
*   Problem: in the CRASS65 version, ICIDNO was:
*   zero-page.
PTL  EQU *
     PHA ;save byte to output
     TXA ;IOCB index
     PHA ;save IOCB index
     AND #$0F ;IOCB index modulo 16
     BNE PTL2 ;if IOCB not dividable by 16, error
     CPX <MAXIOC
     BPL PTL2 ;if IOCB index invalid
     LDA HNDLOD
     BNE PTL3 ;if user wants loading
     LDY #NONDEV ;indicate nonexistent device error
* Return error
PTL1 PLA ;clean stack
     PLA
     CPY #0 ;indicate failure (set N)
     RTS
PTL2 LDY #BADIOC ;indicate bad IOCB number error
     BMI PTL1 ;return error
* Simulate beginning of CIO, since CIO bypassed
PTL3 DTA B($8E),A(ICIDNO) ;STX.w ICIDNO  ;IOCB index
     LDY #0 ;offset to first byte of page zero
* Copy IOCB to page zero IOCB.
PTL4 LDA IOCB,X  ;byte of IOCB
     STA ZIOCB,Y ;byte of page zero IOCB
     INX
     INY
     CPY #12
     BMI PTL4 ;if not done
     JSR PHL  ;load and initialize peripheral han:
     BMI PTL1 ;if error
     PLA ;Re-do the put byte call,
     TAX ;this time calling real handler
     PLA
     TAY
     LDA ICPTHZ
     PHA ;(Put byte entry address minus one)
     LDA ICPTLZ
     PHA
     TYA
     LDY #FNCNOT
     RTS ;invoke handler (address on stack)
