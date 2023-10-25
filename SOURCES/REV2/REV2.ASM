* Converted to MADS by Jakub 'Ilmenit' Debski 'Dec 2020
* Converted to FastAssembler by Holger Janz October 2023

* TITLE  'OS - Operating System'

* Copyright 1984 ATARI.  Unauthorized reproduction, adaptation,
* distribution, performance or display of this computer program
* or the associated audiovisual work is strictly prohibited.

* OS - Operating System

* Revision A (400/800)
* D. Crane/A. Miller/L. Kaplan/R. Whitehead

* Revision B (400/800)
* Fix several problems.
* M. Mahar/R. S. Scheiman

* Revision 10 (1200XL)
* Support 1200XL, add new features.
* H. Stewart/L. Winner/R. S. Scheiman/
* Y. M. Chen/M. W. Colburn        10/26/82

* Revision 11 (1200XL)
* Fix several problems.
* R. S. Scheiman  12/23/82

* Revision 1 (600XL/800XL)
* Support PBI and on-board BASIC.
* R. S. Scheiman/R. K. Nordin/Y. M. Chen  03/11/83

* Revision 2 (600XL/800XL)
* Fix several problems.
* R. S. Scheiman  05/10/83
* Bring closer to Coding Standard (object unchanged).
* R. K. Nordin    11/01/83

* SUBTTL 'System Symbol Equates'
     ICL 'REV2EQU.ICL'

* SUBTTL 'First 8K ROM Identification and Checksum'
     BLK NONE $C000
*    First 8K ROM Identification and Checksum
     DTA A($9211) ;reserved for checksum
     DTA B(IDDAY,IDMON,IDYEAR) ;date (day, month, year)
     DTA B($00) ;not used
     DTA B(IDPN1,IDPN2,IDPN3,IDPN4,IDPN5) ;part number
     DTA B(IDREV) ;revision number

* SUBTTL 'Interrupt Handler'
     ICL 'REV2IRQ.ICL'

* SUBTTL 'Initialization'
     ICL 'REV2INI.ICL'

* SUBTTL 'Disk Input/Ouput'
     ICL 'REV2DIO.ICL'

* SUBTTL 'Relocating Loader'
     ICL 'REV2REL.ICL'

* SUBTTL 'Self-test, Part 1'
     ICL 'REV2ST1.ICL'

* SUBTTL 'Parallel Input/Output'
     ICL 'REV2PIO.ICL'

* SUBTTL 'Peripheral Handler Loading Facility, Part 1'
     ICL 'REV2PHL1.ICL'

* SUBTTL 'Self-test, Part 2'
     ICL 'REV2ST2.ICL'

* SUBTTL 'Peripheral Handler Loading Facility, Part 2'
     ICL 'REV2PHL2.ICL'

* fill bytes
 DTA B(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0) ;$00
 DTA B(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0) ;$10
 DTA B(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0) ;$20
 DTA B(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0) ;$30
 DTA B(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0) ;$40
 DTA B(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0) ;$50
 DTA B(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0) ;$60
 DTA B(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0) ;$70
 DTA B(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0) ;$80
 DTA B(0,0,0,0,0,0,0,0,0,0,0)

* SUBTTL 'International Character Set'
* check program counter
P01  EQU *
X01  EQU 1/[P01/ICSORG]/[ICSORG/P01]
     ICL 'REV2ICS.ICL'

* SUBTTL 'Self-test, Part 3'
* check program counter
P02  EQU *
X02  EQU 1/[P02/$D000]/[$D000/P02] 
     BLK NONE $5000
     ICL 'REV2ST31.ICL'
     ICL 'REV2ST32.ICL'

* SUBTTL 'Floating Point Package'
*   (C) Copyright 1978 Shepardson Microsystems, Inc.
* check program counter
P03  EQU *
X03  EQU 1/[P03/$5800]/[$5800/P03]
     BLK NONE $D800
     ICL 'REV2FPP1.ICL'
     ICL 'REV2FPP2.ICL'
     ICL 'REV2FPP3.ICL'
     ICL 'REV2FPP4.ICL'

* fill bytes
 DTA B(0,0)

* SUBTTL 'Domestic Character Set'
* check program counter
P26  EQU *
X26  EQU 1/[P26/DCSORG]/[DCSORG/P26]
     ICL 'REV2DCS.ICL'

* SUBTTL 'Device Handler Vector Tables'
* check program counter
P27  EQU *
X27  EQU 1/[P27/EDITRV]/[EDITRV/P27]
     ICL 'REV2DHVT.ICL'

* SUBTTL 'Jump Vectors'
* check program counter
P28  EQU *
X28  EQU 1/[P28/JMPVBG]/[JMPVBG/P28]
     ICL 'REV2JVT.ICL'

* SUBTTL 'Generic Parallel Device Handler Vector Table'
* check program counter
P29  EQU *
X29  EQU 1/[P29/GPDVV]/[GPDVV/P29]
     ICL 'REV2GPVT.ICL'

* fill bytes
 DTA B(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
 DTA B(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
 DTA B(0,0)

* SUBTTL '$E4C0 Patch'
* check program counter
P30  EQU *
X30  EQU 1/[P30/$E4C0]/[$E4C0/P30]
* E4C0 - $E4C0 Patch
* For compatibility with OS Revision B, return.
     RTS

* SUBTTL 'Central Input/Output'
     ICL 'REV2CIO.ICL'

* SUBTTL 'Peripheral Handler Loading Facility, Part 3'
     ICL 'REV2PHL3.ICL'

* SUBTTL '$E912 Patch'
* check program counter
P31  EQU *
X31  EQU 1/[P31/$E912]/[$E912/P31]
* E912 - $E912 Patch
* For compatibilty with OS Revision B, set VBLANK parameters.
     JMP SVP ;set VBLANK parameters, return

* SUBTTL 'Peripheral Handler Loading Facility, Part 4'
     ICL 'REV2PHL4.ICL'

* fill bytes
 DTA B(0,0)

* SUBTTL '$E959 Patch'
* check program counter
P32  EQU *
X32  EQU 1/[P32/$E959]/[$E959/P32]
* E959 - $E959 Patch
* For compatibilty with OS Revision B, perform PIO.
     JMP PIO ;perform PIO, return

* SUBTTL 'Serial Input/Output'
     ICL 'REV2SIO1.ICL'
     ICL 'REV2SIO2.ICL'

* SUBTTL 'Keyboard, Editor and Screen Handler, Part 1'
     ICL 'REV2KES1.ICL'

* SUBTTL 'Peripheral Handler Loading Facility, Part 5'
     ICL 'REV2PHL5.ICL'

* fill bytes
 DTA B(0,0,0,0,0,0)

* SUBTTL '$EF6B Patch'
* check program counter
P33  EQU *
X33  EQU 1/[P33/$EF6B]/[$EF6B/P33]
* EF6B - $EF6B Patch
* For compatibility with OS Revision B
     JMP ICR ;initiate cassette READ, return

* SUBTTL 'Keyboard, Editor and Screen Handler, Part 2'
     ICL 'REV2KES2.ICL'

* SUBTTL '$F223 Patch'
* check program counter
P34  EQU *
X34  EQU 1/[P34/$F223]/[$F223/P34]
* F223 - $F223 Patch
* For compatibility with OS Revision B, perform power-up display.
PPD  EQU *
     JMP SES ;select and execute self-test

* SUBTTL 'Keyboard, Editor and Screen Handler, Part 3'
     ICL 'REV2KES3.ICL'
     ICL 'REV2KES4.ICL'
     ICL 'REV2KES5.ICL'

* fill bytes
 DTA B(0,0)
* check program counter
P35  EQU *
X35  EQU 1/[P35/$FCD8]/[$FCD8/P35]
* FCD8 - $FCD8 Patch
* For compatibility with OS Revision B, sound key click
     JMP SKC ;sound key click, return

* SUBTTL 'Cassette Handler'
     ICL 'REV2CASH.ICL'

* SUBTTL 'Printer Handler'
     ICL 'REV2PRNH.ICL'

* SUBTTL 'Self-test, Part 4'
     ICL 'REV2ST4.ICL'

* fill bytes
 DTA B(0,0,0)
* check program counter
P36  EQU *
X36  EQU 1/[P36/$FFEE]/[$FFEE/P36]
* SUBTTL 'Second 8K ROM Identification and Checksum'
     DTA B(IDDAY,IDMON,IDYEAR) ;date (day, month, year)
     DTA B(IDCPU) ;CPU series
     DTA B(IDPN1,IDPN2,IDPN3,IDPN4,IDPN5) ;part number
     DTA B(IDREV) ;revision number
     DTA A($6C8C) ;reserved for checksum

* check program counter
P37  EQU *
X37  EQU 1/[P37/$FFFA]/[$FFFA/P37]
* SUBTTL '6502 Machine Vectors'
     DTA A(NMI) ;vector NMI
     DTA A(RES) ;vector RESET
     DTA A(IRQ) ;vector IRQ

     END
