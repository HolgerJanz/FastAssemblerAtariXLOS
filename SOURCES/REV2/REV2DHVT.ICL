* SUBTTL 'Device Handler Vector Tables'

* EDITRV - Editor Handler Vector Table
 DTA A(EOPV) ;perform editor OPEN
 DTA A(ECLV) ;perform editor CLOSE
 DTA A(EGBV) ;perform editor GET-BYTE
 DTA A(EPBV) ;perform editor PUT-BYTE
 DTA A(SSTV) ;perform editor STATUS (screen STAT:
 DTA A(ESPV) ;perform editor SPECIAL
 JMP SIN     ;initialize editor (initialize scre:
 DTA B(0)    ;reserved

* SCRENV - Screen Handler Vector Table
 DTA A(SOPV) ;perform screen OPEN
 DTA A(ECLV) ;perform screen CLOSE (editor CLOSE:
 DTA A(SGBV) ;perform screen GET-BYTE
 DTA A(SPBV) ;perform screen PUT-BYTE
 DTA A(SSTV) ;perform screen STATUS
 DTA A(SSPV) ;perform screen SPECIAL
 JMP SIN     ;initialize screen
 DTA B(0)    ;reserved

* KEYBDV - Keyboard Handler Vector Table
 DTA A(SSTV) ;perform keyboard OPEN (screen STAT:
 DTA A(SSTV) ;perform keyboard CLOSE (screen STA:
 DTA A(KGBV) ;perform keyboard GET-BYTE
 DTA A(ESPV) ;perform keyboard SPECIAL (editor S:
 DTA A(SSTV) ;perform keyboard STATUS (screen ST:
 DTA A(ESPV) ;perform keyboard SPECIAL (editor S:
 JMP SIN      ;initialize keyboard (initialize sc:
 DTA B(0)     ;reserved

* PRINTV - Printer Handler Vector Table
 DTA A(POPV) ;perform printer OPEN
 DTA A(PCLV) ;perform printer CLOSE
 DTA A(PSPV) ;perform printer SPECIAL
 DTA A(PPBV) ;perform printer PUT-BYTE
 DTA A(PSTV) ;perform printer STATUS
 DTA A(PSPV) ;perform printer SPECIAL
 JMP PIN     ;initialize printer
 DTA B(0)    ;reserved

* CASETV - Cassette Handler Vector Table
 DTA A(COPV) ;perform cassette OPEN
 DTA A(CCLV) ;perform cassette CLOSE
 DTA A(CGBV) ;perform cassette GET-BYTE
 DTA A(CPBV) ;perform cassette PUT-BYTE
 DTA A(CSTV) ;perform cassette STATUS
 DTA A(CSPV) ;perform cassette SPECIAL
 JMP CIN     ;initialize cassette
 DTA B(0)    ;reserved
