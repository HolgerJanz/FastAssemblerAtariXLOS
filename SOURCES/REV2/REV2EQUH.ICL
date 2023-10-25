*      Cartridge Address Equates
CARTCS EQU $BFFA ;2-byte cartridge coldstart address
CART   EQU $BFFC ;1-byte cartridge present indicator
CARTFG EQU $BFFD ;1-byte cartridge flags
CARTAD EQU $BFFE ;2-byte cartridge start vector

*      CTIA/GTIA Address Equates
CTIA   EQU $D000 ;CTIA/GTIA area
*      Read/Write Addresses
CONSOL EQU $D01F ;console switches and speaker control
*      Read Addresses
M0PF   EQU $D000 ;missle 0 and playfield collision
M1PF   EQU $D001 ;missle 1 and playfield collision
M2PF   EQU $D002 ;missle 2 and playfield collision
M3PF   EQU $D003 ;missle 3 and playfield collision

P0PF   EQU $D004 ;player 0 and playfield collision
P1PF   EQU $D005 ;player 1 and playfield collision
P2PF   EQU $D006 ;player 2 and playfield collision
P3PF   EQU $D007 ;player 3 and playfield collision

M0PL   EQU $D008 ;missle 0 and player collision
M1PL   EQU $D009 ;missle 1 and player collision
M2PL   EQU $D00A ;missle 2 and player collision
M3PL   EQU $D00B ;missle 3 and player collision

P0PL   EQU $D00C ;player 0 and player collision
P1PL   EQU $D00D ;player 1 and player collision
P2PL   EQU $D00E ;player 2 and player collision
P3PL   EQU $D00F ;player 3 and player collision

TRIG0  EQU $D010 ;joystick trigger 0
TRIG1  EQU $D011 ;joystick trigger 1

TRIG2  EQU $D012 ;cartridge interlock
TRIG3  EQU $D013 ;ACMI module interlock

PAL    EQU $D014 ;PAL/NTSC indicator
*      Write Addresses
HPOSP0 EQU $D000 ;player 0 horizontal position
HPOSP1 EQU $D001 ;player 1 horizontal position
HPOSP2 EQU $D002 ;player 2 horizontal position
HPOSP3 EQU $D003 ;player 3 horizontal position

HPOSM0 EQU $D004 ;missle 0 horizontal position
HPOSM1 EQU $D005 ;missle 1 horizontal position
HPOSM2 EQU $D006 ;missle 2 horizontal position
HPOSM3 EQU $D007 ;missle 3 horizontal position

SIZEP0 EQU $D008 ;player 0 size
SIZEP1 EQU $D009 ;player 1 size
SIZEP2 EQU $D00A ;player 2 size
SIZEP3 EQU $D00B ;player 3 size

SIZEM  EQU $D00C ;missle sizes

GRAFP0 EQU $D00D ;player 0 graphics
GRAFP1 EQU $D00E ;player 1 graphics
GRAFP2 EQU $D00F ;player 2 graphics
GRAFP3 EQU $D010 ;player 3 graphics

GRAFM  EQU $D011 ;missle graphics

COLPM0 EQU $D012 ;player-missle 0 color/luminance
COLPM1 EQU $D013 ;player-missle 1 color/luminance
COLPM2 EQU $D014 ;player-missle 2 color/luminance
COLPM3 EQU $D015 ;player-missle 3 color/luminance

COLPF0 EQU $D016 ;playfield 0 color/luminance
COLPF1 EQU $D017 ;playfield 1 color/luminance
COLPF2 EQU $D018 ;playfield 2 color/luminance
COLPF3 EQU $D019 ;playfield 3 color/luminance

COLBK  EQU $D01A ;background color/luminance

PRIOR  EQU $D01B ;priority select
VDELAY EQU $D01C ;vertical delay
GRACTL EQU $D01D ;graphic control
HITCLR EQU $D01E ;collision clear

*      PBI Address Equates
PBI    EQU $D100 ;parallel bus interface area
*      Read Addresses
PDVI   EQU $D1FF ;parallel device IRQ status
*      Write Addresses
PDVS   EQU $D1FF ;parallel device select

*      POKEY Address Equates
POKEY  EQU $D200 ;POKEY area
*      Read Addresses
POT0   EQU $D200 ;potentiometer 0
POT1   EQU $D201 ;potentiometer 1
POT2   EQU $D202 ;potentiometer 2
POT3   EQU $D203 ;potentiometer 3
POT4   EQU $D204 ;potentiometer 4
POT5   EQU $D205 ;potentiometer 5
POT6   EQU $D206 ;potentiometer 6
POT7   EQU $D207 ;potentiometer 7

ALLPOT EQU $D208 ;potentiometer port state
KBCODE EQU $D209 ;keyboard code
RANDOM EQU $D20A ;random number generator
SERIN  EQU $D20D ;serial port input
IRQST  EQU $D20E ;IRQ interrupt status
SKSTAT EQU $D20F ;serial port and keyboard status
*      Write Addresses
AUDF1  EQU $D200 ;channel 1 audio frequency
AUDC1  EQU $D201 ;channel 1 audio control

AUDF2  EQU $D202 ;channel 2 audio frequency
AUDC2  EQU $D203 ;channel 2 audio control

AUDF3  EQU $D204 ;channel 3 audio frequency
AUDC3  EQU $D205 ;channel 3 audio control

AUDF4  EQU $D206 ;channel 4 audio frequency
AUDC4  EQU $D207 ;channel 4 audio control

AUDCTL EQU $D208 ;audio control
STIMER EQU $D209 ;start timers
SKRES  EQU $D20A ;reset SKSTAT status
POTGO  EQU $D20B ;start potentiometer scan sequence
SEROUT EQU $D20D ;serial port output
IRQEN  EQU $D20E ;IRQ interrupt enable
SKCTL  EQU $D20F ;serial port and keyboard control

*      PIA Address Equates
PIA    EQU $D300 ;PIA area
*      Read/Write Addresses
PORTA  EQU $D300 ;port A direction register or jacks 0 and 1
PORTB  EQU $D301 ;port B direction register or memory control
PACTL  EQU $D302 ;port A control
PBCTL  EQU $D303 ;port B control

*      ANTIC Address Equates
ANTIC  EQU $D400 ;ANTIC area
*      Read Addresses
VCOUNT EQU $D40B ;vertical line counter
PENH   EQU $D40C ;light pen horizontal position
PENV   EQU $D40D ;light pen vertical position
NMIST  EQU $D40F ;NMI interrupt status
*      Write Addresses
DMACTL EQU $D400 ;DMA control
CHACTL EQU $D401 ;character control
DLISTL EQU $D402 ;low display list address
DLISTH EQU $D403 ;high disply list address
HSCROL EQU $D404 ;horizontal scroll
VSCROL EQU $D405 ;vertical scroll
PMBASE EQU $D407 ;player-missle base address
CHBASE EQU $D409 ;character base address
WSYNC  EQU $D40A ;wait for HBLANK synchronization
NMIEN  EQU $D40E ;NMI enable
NMIRES EQU $D40F ;NMI interrupt status reset

*      PBI RAM Address Equates
PBIRAM EQU $D600 ;parallel bus interface RAM area

*      Floating Point Package Address Equates
AFP    EQU $D800 ;convert ASCII to floating point
FASC   EQU $D8E6 ;convert floating point to ASCII
IFP    EQU $D9AA ;convert integer to floating point
FPI    EQU $D9D2 ;convert floating point to integer
ZFR0   EQU $DA44 ;zero FR0
ZF1    EQU $DA46 ;zero floating point number
FSUB   EQU $DA60 ;subtract floating point numbers
FADD   EQU $DA66 ;add floating point numbers
FMUL   EQU $DADB ;multiply floating point numbers
FDIV   EQU $DB28 ;divide floating point numbers
PLYEVL EQU $DD40 ;evaluate floating point polynomial
FLD0R  EQU $DD89 ;load floating point number
FLD0P  EQU $DD8D ;load floating point number
FLD1R  EQU $DD98 ;load floating point number
FLD1P  EQU $DD9C ;load floating point number
FST0R  EQU $DDA7 ;store floating point number
FST0P  EQU $DDAB ;store floating point number
FMOVE  EQU $DDB6 ;move floating point number
LOG    EQU $DECD ;calculate floating point logarithm
LOG10  EQU $DED1 ;calculate floating point base 10 logarithm
EXP    EQU $DDC0 ;calculate floating point exponentiation
EXP10  EQU $DDCC ;calculate floating point base 10 exponentiation

*      Parallel Device Address Equates
PDID1  EQU $D803 ;parallel device ID 1
PDIOV  EQU $D805 ;parallel device I/O vector
PDIRQV EQU $D808 ;parallel device IRQ vector
PDID2  EQU $D80B ;parallel device ID 2
PDVV   EQU $D80D ;parallel device vector table

*      Device Handler Vector Table Address Equates
EDITRV EQU $E400 ;editor handler vector table
SCRENV EQU $E410 ;screen handler vector table
KEYBDV EQU $E420 ;keyboard handler vector table
PRINTV EQU $E430 ;printer handler vector table
CASETV EQU $E440 ;cassette handler vector table

*      Jump Vector Address Equates
JMPVBG EQU $E450 ;begin of jump vector table
DINITV EQU $E450 ;vector to initialize DIO
DSKINV EQU $E453 ;vector to DIO
CIOV   EQU $E456 ;vector to CIO
SIOV   EQU $E459 ;vector to SIO
SETVBV EQU $E45C ;vector to set VBLANK parameters
SYSVBV EQU $E45F ;vector to process immediate VBLANK NMI
XITVBV EQU $E462 ;vector to process deferred VBLANK NMI
SIOINV EQU $E465 ;vector to initialize SIO
SENDEV EQU $E468 ;vector to enable SEND
INTINV EQU $E46B ;vector to initialize interrupt handler
CIOINV EQU $E46E ;vector to initialize CIO
BLKBDV EQU $E471 ;vector to power-up display (formerly memo pad)
WARMSV EQU $E474 ;vector to warmstart
COLDSV EQU $E477 ;vector to coldstart
RBLOKV EQU $E47A ;vector to read cassette block
CSOPIV EQU $E47D ;vector to open cassette for input
PUPDIV EQU $E480 ;vector to power-up display
SLFTSV EQU $E483 ;vector to self-test
PHENTV EQU $E486 ;vector to enter peripheral handler
PHUNLV EQU $E489 ;vector to unlink peripheral handler
PHINIV EQU $E48C ;vector to initialize peripheral handler

*      Generic Parallel Device Handler Vector Table Address Equates
GPDVV  EQU $E48F ;generic parallel device handler vector table
