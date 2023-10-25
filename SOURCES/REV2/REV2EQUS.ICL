* Page Zero Address Equates
LNFLG  EQU $00 ;1-byte LNBUG flag (0 = not LNBUG)
NGFLAG EQU $01 ;1-byte memory status (0 = failure)

* Not Cleared
CASINI EQU $02 ;2-byte cassette program initialization address
RAMLO  EQU $04 ;2-byte RAM address for memory test
TRAMSZ EQU $06 ;1-byte RAM size temporary
CMCMD  EQU $07 ;1-byte command communications

* Cleared upon Coldstart Only
WARMST EQU $08 ;1-byte warmstart flag (0 = coldstart)
BOOT?  EQU $09 ;1-byte successful boot flags
DOSVEC EQU $0A ;2-byte disk program start vector
DOSINI EQU $0C ;2-byte disk program initialization address
APPMHI EQU $0E ;2-byte applications memory high limit

* Cleared upon Coldstart or Warmstart
INTZBS EQU $10 ;first page zero location to clear

POKMSK EQU $10 ;1-byte IRQEN shadow
BRKKEY EQU $11 ;1-byte BREAK key flag (0 = no BREAK)
RTCLOK EQU $12 ;3-byte real time clock (16 millisecond units)
BUFADR EQU $15 ;2-byte disk interface buffer address
ICCOMT EQU $17 ;1-byte CIO command table index
DSKFMS EQU $18 ;2-byte DOS File Management System pointer
DSKUTL EQU $1A ;2-byte DOS utility pointer
ABUFPT EQU $1C ;4-byte ACMI buffer pointer area

ZIOCB  EQU $20 ;address of page zero IOCB
IOCBAS EQU $20 ;16-byte page zero IOCB
ICHIDZ EQU $20 ;1-byte handler ID ($FF = IOCB free)
ICDNOZ EQU $21 ;1-byte device number
ICCOMZ EQU $22 ;1-byte command code
ICSTAZ EQU $23 ;1-byte status of last action
ICBALZ EQU $24 ;1-byte low buffer address
ICBAHZ EQU $25 ;1-byte high buffer address
ICPTLZ EQU $26 ;1-byte low PUT-BYTE routine address-1
ICPTHZ EQU $27 ;1-byte high PUT-BYTE routine address-1
ICBLLZ EQU $28 ;1-byte low buffer length
ICBLHZ EQU $29 ;1-byte high buffer length
ICAX1Z EQU $2A ;1-byte first auxiliary information
ICAX2Z EQU $2B ;1-byte second auxiliary information
ICSPRZ EQU $2C ;4-byte spares

ENTVEC EQU $2C ;2-byte (not used)
ICIDNO EQU $2E ;1-byte IOCB index (IOCB number times IOCBSZ)
CIOCHR EQU $2F ;1-byte character for current CIO operation

STATUS EQU $30 ;1-byte SIO operation status
CHKSUM EQU $31 ;1-byte checksum (single byte sum with carry)
BUFRLO EQU $32 ;1-byte low data buffer address
BUFRHI EQU $33 ;1-byte high data buffer address
BFENLO EQU $34 ;1-byte low data buffer end address
BFENHI EQU $35 ;1-byte high data buffer end address
LTEMP  EQU $36 ;2-byte relocating loader temporary
BUFRFL EQU $38 ;1-byte data buffer full flag (0 = not full)
RECVDN EQU $39 ;1-byte receive-frame done flag (0 = not done)
XMTDON EQU $3A ;1-byte transmit-frame done flag (0 = not done)
CHKSNT EQU $3B ;1-byte checksum sent flag (0 = not sent)
NOCKSM EQU $3C ;1-byte no checksum follows data flag (0 = does)
BPTR   EQU $3D ;1-byte cassette buffer pointer
FTYPE  EQU $3E ;1-byte cassette IRG type (neg. = continuous)
FEOF   EQU $3F ;1-byte cassette EOF flag (0 = no EOF)
FREQ   EQU $40 ;1-byte cassette beep counter
SOUNDR EQU $41 ;1-byte noisy I/O flag (0 = quiet)

CRITIC EQU $42 ;1-byte critical section flag (0 = not critical)

FMSZPG EQU $43 ;7-byte reserved for DOS File Management System

ZCHAIN EQU $4A ;2-byte handler linkage chain point:
DSTAT  EQU $4C ;1-byte display status
ATRACT EQU $4D ;1-byte attract-mode timer and flag
DRKMSK EQU $4E ;1-byte attract-mode dark (luminance) mask
COLRSH EQU $4F ;1-byte attract-mode color shift
TMPCHR EQU $50 ;1-byte temporary character
HOLD1  EQU $51 ;1-byte temporary
LMARGN EQU $52 ;1-byte text column left margin
RMARGN EQU $53 ;1-byte text column right margin
ROWCRS EQU $54 ;1-byte cursor row
COLCRS EQU $55 ;2-byte cursor column
DINDEX EQU $57 ;1-byte display mode
SAVMSC EQU $58 ;2-byte saved memory scan counter
OLDROW EQU $5A ;1-byte prior row
OLDCOL EQU $5B ;2-byte prior column
OLDCHR EQU $5D ;1-byte saved character under cursor
OLDADR EQU $5E ;2-byte saved cursor memory address
FKDEF  EQU $60 ;2-byte function key definition tab:
PALNTS EQU $62 ;1-byte PAL/NTSC indicator (0 = NTS:
LOGCOL EQU $63 ;1-byte logical line cursor column
ADRESS EQU $64 ;2-byte temporary address

MLTTMP EQU $66 ;1-byte temporary
OPNTMP EQU $66 ;1-byte open temporary
TOADR  EQU $66 ;2-byte destination address

SAVADR EQU $68 ;2-byte saved address
FRMADR EQU $68 ;2-byte source address

RAMTOP EQU $6A ;1-byte RAM size
BUFCNT EQU $6B ;1-byte buffer count (logical line size)
BUFSTR EQU $6C ;2-byte buffer start pointer
BITMSK EQU $6E ;1-byte bit mask for bit map operation
SHFAMT EQU $6F ;1-byte shift amount for pixel justification
ROWAC  EQU $70 ;2-byte draw working row
COLAC  EQU $72 ;2-byte draw working column
ENDPT  EQU $74 ;2-byte end point
DELTAR EQU $76 ;1-byte row difference
DELTAC EQU $77 ;2-byte column difference
KEYDEF EQU $79 ;2-byte key definition table addres:
SWPFLG EQU $7B ;1-byte split screen swap flag (0 = not swapped)
HOLDCH EQU $7C ;1-byte temporary character
INSDAT EQU $7D ;1-byte temporary
COUNTR EQU $7E   ;2-byte draw iteration count

* Reserved for Application and Floating Point Package
* EQU $0080 ;128 bytes reserved for application and FPP

* Floating Point Package Page Zero Address Equates
FR0    EQU $D4 ;6-byte register 0
FR0M   EQU $D5 ;5-byte register 0 mantissa
QTEMP  EQU $D9 ;1-byte temporary
FRE    EQU $DA ;6-byte (internal) register E
FR1    EQU $E0 ;6-byte register 1
FR1M   EQU $E1 ;5-byte register 1 mantissa
FR2    EQU $E6 ;6-byte (internal) register 2
FRX    EQU $EC ;1-byte temporary
EEXP   EQU $ED ;1-byte value of exponent
FRSIGN EQU $EE ;1-byte floating point sign
NSIGN  EQU $EE ;1-byte sign of number
PLYCNT EQU $EF ;1-byte polynomial degree
ESIGN  EQU $EF ;1-byte sign of exponent
SGNFLG EQU $F0 ;1-byte sign flag
FCHFLG EQU $F0 ;1-byte first character flag
XFMFLG EQU $F1 ;1-byte transform flag
DIGRT  EQU $F1 ;1-byte number of digits after decimal point
CIX    EQU $F2 ;1-byte current input index
INBUFF EQU $F3 ;2-byte line input buffer
ZTEMP1 EQU $F5 ;2-byte temporary
ZTEMP4 EQU $F7 ;2-byte temporary
ZTEMP3 EQU $F9 ;2-byte temporary
FLPTR  EQU $FC ;2-byte floating point number pointer
FPTR2  EQU $FE ;2-byte floating point number pointer

* Page One (Stack) Address Equates
* EQU $0100 ;256-byte stack

* Page Two Address Equates
INTABS EQU $0200 ;42-byte interrupt handler table

VDSLST EQU $0200 ;2-byte display list NMI vector
VPRCED EQU $0202 ;2-byte serial I/O proceed line IRQ vector
VINTER EQU $0204 ;2-byte serial I/O interrupt line IRQ vector
VBREAK EQU $0206 ;2-byte BRK instruction IRQ vector
VKEYBD EQU $0208 ;2-byte keyboard IRQ vector
VSERIN EQU $020A ;2-byte serial input ready IRQ vector
VSEROR EQU $020C ;2-byte serial output ready IRQ vector
VSEROC EQU $020E ;2-byte serial output complete IRQ vector
VTIMR1 EQU $0210 ;2-byte POKEY timer 1 IRQ vector
VTIMR2 EQU $0212 ;2-byte POKEY timer 2 IRQ vector
VTIMR4 EQU $0214 ;2-byte POKEY timer 4 IRQ vector
VIMIRQ EQU $0216 ;2-byte immediate IRQ vector
CDTMV1 EQU $0218 ;2-byte countdown timer 1 value
CDTMV2 EQU $021A ;2-byte countdown timer 2 value
CDTMV3 EQU $021C ;2-byte countdown timer 3 value
CDTMV4 EQU $021E ;2-byte countdown timer 4 value
CDTMV5 EQU $0220 ;2-byte countdown timer 5 value
VVBLKI EQU $0222 ;2-byte immediate VBLANK NMI vector
VVBLKD EQU $0224 ;2-byte deferred VBLANK NMI vector
CDTMA1 EQU $0226 ;2-byte countdown timer 1 vector
CDTMA2 EQU $0228 ;2-byte countdown timer 2 vector

CDTMF3 EQU $022A ;1-byte countdown timer 3 flag (0 = expired)
SRTIMR EQU $022B ;1-byte software key repeat timer
CDTMF4 EQU $022C ;1-byte countdown timer 4 flag (0 = expired)
INTEMP EQU $022D ;1-byte temporary
CDTMF5 EQU $022E ;1-byte countdown timer 5 flag (0 = expired)
SDMCTL EQU $022F ;1-byte DMACTL shadow
SDLSTL EQU $0230 ;1-byte DLISTL shadow
SDLSTH EQU $0231 ;1-byte DLISTH shadow
SSKCTL EQU $0232 ;1-byte SKCTL shadow
LCOUNT EQU $0233 ;1-byte relocating loader record le:
LPENH  EQU $0234 ;1-byte light pen horizontal value
LPENV  EQU $0235 ;1-byte light pen vertical value
BRKKY  EQU $0236 ;2-byte BREAK key vector
VPIRQ  EQU $0238 ;2-byte parallel device IRQ vector
CDEVIC EQU $023A ;1-byte command frame device ID
CCOMND EQU $023B ;1-byte command frame command
CAUX1  EQU $023C ;1-byte command auxiliary 1
CAUX2  EQU $023D ;1-byte command auxiliary 2

TEMP   EQU $023E ;1-byte temporary
* !!! ASSERT  low TEMP<>$FF may not be the last word on a page
ASSER1 EQU 1/TEMP&$FF^$FF

ERRFLG EQU $023F ;1-byte I/O error flag (0 = no error)
* !!! ASSERT  low ERRFLG<>$FF ;may not be the last word on a page
ASSER2 EQU 1/ERRFLG&$FF^$FF

DFLAGS EQU $0240 ;1-byte disk flags from sector 1
DBSECT EQU $0241 ;1-byte disk boot sector count
BOOTAD EQU $0242 ;2-byte disk boot memory address
COLDST EQU $0244 ;1-byte coldstart flag (0 = complete)
RECLEN EQU $0245 ;1-byte relocating loader record le:
DSKTIM EQU $0246 ;1-byte disk format timeout
PDVMSK EQU $0247 ;1-byte parallel device selection mask
SHPDVS EQU $0248 ;1-byte PDVS (parallel device selec:
PDIMSK EQU $0249 ;1-byte parallel device IRQ selection mask
RELADR EQU $024A ;2-byte relocating loader relative :
PPTMPA EQU $024C ;1-byte parallel device handler tem:
PPTMPX EQU $024D ;1-byte parallel device handler tem:

* EQU $024E ;6 bytes reserved for Atari

* EQU $0254 ;23 bytes reserved for Atari

CHSALT EQU $026B ;1-byte character set alternate
VSFLAG EQU $026C ;1-byte fine vertical scroll count
KEYDIS EQU $026D ;1-byte keyboard disable
FINE   EQU $026E ;1-byte fine scrolling mode
GPRIOR EQU $026F ;1-byte PRIOR shadow

PADDL0 EQU $0270 ;1-byte potentiometer 0
PADDL1 EQU $0271 ;1-byte potentiometer 1
PADDL2 EQU $0272 ;1-byte potentiometer 2
PADDL3 EQU $0273 ;1-byte potentiometer 3
PADDL4 EQU $0274 ;1-byte potentiometer 4
PADDL5 EQU $0275 ;1-byte potentiometer 5
PADDL6 EQU $0276 ;1-byte potentiometer 6
PADDL7 EQU $0277 ;1-byte potentiometer 7

STICK0 EQU $0278 ;1-byte joystick 0
STICK1 EQU $0279 ;1-byte joystick 1
STICK2 EQU $027A ;1-byte joystick 2
STICK3 EQU $027B ;1-byte joystick 3

PTRIG0 EQU $027C ;1-byte paddle trigger 0
PTRIG1 EQU $027D ;1-byte paddle trigger 1
PTRIG2 EQU $027E ;1-byte paddle trigger 2
PTRIG3 EQU $027F ;1-byte paddle trigger 3
PTRIG4 EQU $0280 ;1-byte paddle trigger 4
PTRIG5 EQU $0281 ;1-byte paddle trigger 5
PTRIG6 EQU $0282 ;1-byte paddle trigger 6
PTRIG7 EQU $0283 ;1-byte paddle trigger 7

STRIG0 EQU $0284 ;1-byte joystick trigger 0
STRIG1 EQU $0285 ;1-byte joystick trigger 1
STRIG2 EQU $0286 ;1-byte joystick trigger 2
STRIG3 EQU $0287 ;1-byte joystick trigger 3

HIBYTE EQU $0288 ;1-byte relocating loader high byte:
WMODE  EQU $0289 ;1-byte cassette WRITE mode ($80 = writing)
BLIM   EQU $028A ;1-byte cassette buffer limit
IMASK  EQU $028B ;1-byte (not used)
JVECK  EQU $028C ;2-byte jump vector or temporary
NEWADR EQU $028E ;2-byte relocating address
TXTROW EQU $0290 ;1-byte split screen text cursor row
TXTCOL EQU $0291 ;2-byte split screen text cursor column
TINDEX EQU $0293 ;1-byte split scree text mode
TXTMSC EQU $0294 ;2-byte split screen memory scan counter
TXTOLD EQU $0296 ;6-byte OLDROW, OLDCOL, OLDCHR, OLDADR for text
CRETRY EQU $029C ;1-byte number of command frame ret:
HOLD3  EQU $029D ;1-byte temporary
SUBTMP EQU $029E ;1-byte temporary
HOLD2  EQU $029F ;1-byte (not used)
DMASK  EQU $02A0 ;1-byte display (pixel location) mask
TMPLBT EQU $02A1 ;1-byte (not used)
ESCFLG EQU $02A2 ;1-byte escape flag ($80 = ESC detected)
TABMAP EQU $02A3 ;15-byte (120-bit) tab stop bit map
LOGMAP EQU $02B2 ;8-byte (32-bit) logical line bit map
INVFLG EQU $02B6 ;1-byte inverse video flag ($80 = inverse)
FILFLG EQU $02B7 ;1-byte right fill flag (0 = no fill)
TMPROW EQU $02B8 ;1-byte temporary row
TMPCOL EQU $02B9 ;2-byte temporary column
SCRFLG EQU $02BB ;1-byte scroll occurence flag (0 = not occurred)
HOLD4  EQU $02BC ;1-byte temporary
DRETRY EQU $02BD ;1-byte number of device retries
SHFLOK EQU $02BE ;1-byte shift/control lock flags
BOTSCR EQU $02BF ;1-byte screen bottom (24 = normal, 4 = split)

PCOLR0 EQU $02C0 ;1-byte player-missle 0 color/luminance
PCOLR1 EQU $02C1 ;1-byte player-missle 1 color/luminance
PCOLR2 EQU $02C2 ;1-byte player-missle 2 color/luminance
PCOLR3 EQU $02C3 ;1-byte player-missle 3 color/luminance

COLOR0 EQU $02C4 ;1-byte playfield 0 color/luminance
COLOR1 EQU $02C5 ;1-byte playfield 1 color/luminance
COLOR2 EQU $02C6 ;1-byte playfield 2 color/luminance
COLOR3 EQU $02C7 ;1-byte playfield 3 color/luminance

COLOR4 EQU $02C8 ;1-byte background color/luminance

PARMBL EQU $02C9 ;6-byte relocating loader parameter:
RUNADR EQU $02C9 ;2-byte run address
HIUSED EQU $02CB ;2-byte highest non-zero page addre:
ZHIUSE EQU $02CD ;2-byte highest zero page address

OLDPAR EQU $02CF ;6-byte relocating loader parameter:
GBYTEA EQU $02CF ;2-byte GET-BYTE routine address
LOADAD EQU $02D1 ;2-byte non-zero page load address
ZLOADA EQU $02D3 ;2-byte zero page load address

DSCTLN EQU $02D5 ;2-byte disk sector length
ACMISR EQU $02D7 ;2-byte ACMI interrupt service rout:
KRPDEL EQU $02D9 ;1-byte auto-repeat delay
KEYREP EQU $02DA ;1-byte auto-repeat rate
NOCLIK EQU $02DB ;1-byte key click disable
HELPFG EQU $02DC ;1-byte HELP key flag (0 = no HELP)
DMASAV EQU $02DD ;1-byte SDMCTL save/restore
PBPNT  EQU $02DE ;1-byte printer buffer pointer
PBUFSZ EQU $02DF ;1-byte printer buffer size

*      EQU $02E0 ;4 bytes reserved for DOS

RAMSIZ EQU $02E4 ;1-byte high RAM size
MEMTOP EQU $02E5 ;2-byte top of available user memory
MEMLO  EQU $02E7 ;2-byte bottom of available user memory
HNDLOD EQU $02E9 ;1-byte user load flag (0 = no hand:
DVSTAT EQU $02EA ;4-byte device status buffer
CBAUDL EQU $02EE ;1-byte low cassette baud rate
CBAUDH EQU $02EF ;1-byte high cassette baud rate
CRSINH EQU $02F0 ;1-byte cursor inhibit (0 = cursor on)
KEYDEL EQU $02F1 ;1-byte key debounce delay timer
CH1    EQU $02F2 ;1-byte prior keyboard character
CHACT  EQU $02F3 ;1-byte CHACTL shadow
CHBAS  EQU $02F4 ;1-byte CHBASE shadow

NEWROW EQU $02F5 ;1-byte draw destination row
NEWCOL EQU $02F6 ;2-byte draw destination column
ROWINC EQU $02F8 ;1-byte draw row increment
COLINC EQU $02F9 ;1-byte draw column increment

CHAR   EQU $02FA ;1-byte internal character
ATACHR EQU $02FB ;1-byte ATASCII character or plot point
CH     EQU $02FC ;1-byte keyboard code (buffer)
FILDAT EQU $02FD ;1-byte right fill data
DSPFLG EQU $02FE ;1-byte control character display flag (0 = no)
SSFLAG EQU $02FF ;1-byte start/stop flag (0 = not stopped)

* Page Three Address Equates

DCB    EQU $0300 ;12-byte device control block
DDEVIC EQU $0300 ;1-byte unit 1 bus ID
DUNIT  EQU $0301 ;1-byte unit number
DCOMND EQU $0302 ;1-byte bus command
DSTATS EQU $0303 ;1-byte command type/status return
DBUFLO EQU $0304 ;1-byte low data buffer address
DBUFHI EQU $0305 ;1-byte high data buffer address
DTIMLO EQU $0306 ;1-byte timeout (seconds)
DUNUSE EQU $0307 ;1-byte (not used)
DBYTLO EQU $0308 ;1-byte low number of bytes to transfer
DBYTHI EQU $0309 ;1-byte high number of bytes to transfer
DAUX1  EQU $030A ;1-byte first command auxiliary
DAUX2  EQU $030B ;1-byte second command auxiliary

TIMER1 EQU $030C ;2-byte initial baud rate timer value
JMPERS EQU $030E ;1-byte jumper options
CASFLG EQU $030F ;1-byte cassette I/O flag (0 = not cassette I/O)
TIMER2 EQU $0310 ;2-byte final baud rate timer value
TEMP1  EQU $0312 ;2-byte temporary
TEMP2  EQU $0313 ;1-byte temporary
PTIMOT EQU $0314 ;1-byte printer timeout
TEMP3  EQU $0315 ;1-byte temporary
SAVIO  EQU $0316 ;1-byte saved serial data input indicator
TIMFLG EQU $0317 ;1-byte timeout flag (0 = timeout)
STACKP EQU $0318 ;1-byte SIO saved stack pointer
TSTAT  EQU $0319 ;1-byte temporary status

HATABS EQU $031A ;35-byte handler address table

PUPBT1 EQU $033D ;1-byte power-up validation byte 1
PUPBT2 EQU $033E ;1-byte power-up validation byte 2
PUPBT3 EQU $033F ;1-byte power-up validation byte 3

IOCB   EQU $0340 ;128-byte I/O control blocks area
ICHID  EQU $0340 ;1-byte handler ID ($FF = free)
ICDNO  EQU $0341 ;1-byte device number
ICCOM  EQU $0342 ;1-byte command code
ICSTA  EQU $0343 ;1-byte status of last action
ICBAL  EQU $0344 ;1-byte low buffer address
ICBAH  EQU $0345 ;1-byte high buffer address
ICPTL  EQU $0346 ;1-byte low PUT-BYTE routine address-1
ICPTH  EQU $0347 ;1-byte high PUT-BYTE routine address-1
ICBLL  EQU $0348 ;1-byte low buffer length
ICBLH  EQU $0349 ;1-byte high buffer length
ICAX1  EQU $034A ;1-byte first auxiliary information
ICAX2  EQU $034B ;1-byte second auxiliary information
ICSPR  EQU $034C ;4-byte work area

PRNBUF EQU $03C0 ;40-byte printer buffer
SUPERF EQU $03E8 ;1-byte editor super function flag :
CKEY   EQU $03E9 ;1-byte cassette boot request flag :
CASSBT EQU $03EA ;1-byte cassette boot flag (0 = not:
CARTCK EQU $03EB ;1-byte cartridge equivalence checksum
DERRF  EQU $03EC ;1-byte screen OPEN error flag (0 = not)

* Remainder of Page Three Not Cleared upon Reset

ACMVAR EQU $03ED ;11 bytes reserved for ACMI
BASICF EQU $03F8 ;1-byte BASIC switch flag (0 = BASIC enabled)
MINTLK EQU $03F9 ;1-byte ACMI module interlock
GINTLK EQU $03FA ;1-byte cartridge interlock
CHLINK EQU $03FB ;2-byte loaded handler chain link
CASBUF EQU $03FD ;3-byte first 3 bytes of cassette buffer

* Page Four Address Equates
* EQU $0400   ;128-byte remainder of cassette buffer
* Reserved for Application
USAREA EQU $0480 ;128 bytes reserved for application

* Page Five Address Equates
* Reserved for Application and Floating Point Package
* EQU $0500 ;256 bytes reserved for application and FPP

* Floating Point Package Address Equates
LBPR1  EQU $057E ;1-byte LBUFF preamble
LBPR2  EQU $057F ;1-byte LBUFF preamble
LBUFF  EQU $0580 ;128-byte line buffer
PLYARG EQU $05E0 ;6-byte floating point polynomial argument
FPSCR  EQU $05E6 ;6-byte floating point temporary
FPSCR1 EQU $05EC ;6-byte floating point temporary

* Page Six Address Equates
* Reserved for Application
* EQU $0600 ;256 bytes reserved for application
