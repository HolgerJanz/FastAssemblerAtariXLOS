* SUBTTL 'Peripheral Handler Loading Facility, Part 1'

* PHL - Load and Initialize Peripheral Handler
*  Subroutine to load, relocate, initialize and open a
*  "provisionally" opened IOCB. This routine is called
*  upon first I/O attempt following provisional open.
*  It does the final opening by simulating the first
*  part of a normal CIO OPEN and then finishing with
*  code which is in CIO.
* Input parameters:
*  ICIDNO  (specifies which IOCB);
*  various values in the provisionally-opened IOCB:
*          ICSPR (handler name)
*          ICSPR+1 (serial address for loading);
*  whatever the called subroutines require.
* Output parameters:
*  None. (Error returns are all handled by called subr:
*          in fact, all returns are handled by called :
* Modified:
*  ICHID in both calling IOCB and ZIOCB (part of compl:
*  ICCOMT (a CIO variable);
*  Registers not saved.
* Subroutines called:
*  LPH (does the loading);
*  PHC (initializes the loaded handler);
*  FDH (a CIO entry--finds handler table entry of
*          newly loaded/initialized handler);
*  IIO (a CIO entry--finishes full proper opening of I:
*          including calling handler OPEN entry--IIO r:
*          to PHL's caller);
*  IND (a CIO entry--returns with error to PHL's calle:
* NOTES
*  Problem: in the CRASS65 version, ICIDNO was:
*  zero-page.
PHL  EQU *
* Load peripheral handler.
     DTA B($AE),A(ICIDNO) ;LDX.w ICIDNO
     LDA     ICSPR+1,X
     JSR     LPH    ;load peripheral handler
     BCS     PHL1   ;if error
* Initialize peripheral handler
     CLC            ;indicate zero handler size
     JSR     PHC    ;initialize peripheral hand:
     BCS     PHL1   ;if error
* Find device handler
     DTA B($AE),A(ICIDNO) ;LDX.w ICIDNO
     LDA     ICSPR,X
     JSR     FDH    ;find device handler
     BCS     PHL1   ;if not found
* Set handler ID.
     DTA B($AE),A(ICIDNO) ;LDX.w ICIDNO
     STA     ICHID,X ;handler ID
     STA     ICHIDZ
* Simulate initial CIO OPEN processing.
     LDA     #OPEN   ;OPEN command
     STA     ICCOMT  ;command
     JMP     IIO     ;initialize IOCB for OPEN, return
* Indicate nonexistent device error.
PHL1 JMP     IND     ;indicate nonexistent device error
