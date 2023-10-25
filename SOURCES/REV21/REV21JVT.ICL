* SUBTTL 'Jump Vectors'
 JMP IDIO ;initialize DIO
 JMP DIO  ;perform DIO
 JMP CIO  ;perform CIO
 JMP PIO  ;perform PIO
 JMP SVP  ;set VBLANK parameters
 JMP IVNM ;process immediate VBLANK NMI
 JMP DVNM ;process deferred VBLANK NMI
 JMP ISIO ;initialize SIO
 JMP ESS  ;enable SIO SEND
 JMP IIH  ;initialize interrupt handler
 JMP ICIO ;initialize CIO
 JMP PPD  ;perform power-up display
 JMP PWS  ;perform warmstart
 JMP PCS  ;perform coldstart
 JMP RCB  ;read cassette block
 JMP OCI  ;open cassette for input
 JMP PPD  ;perform power-up display
 JMP STH  ;self-test hardware
 JMP PHE  ;perform peripheral handler entry
 JMP PHU  ;perform peripheral handler unlinking
 JMP PHI  ;perform peripheral handler initialization
