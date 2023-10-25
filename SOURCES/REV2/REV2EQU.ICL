* SUBTTL 'System Symbol Equates'

* Identification Equates
IDREV  EQU $02 ;identification revision number
IDDAY  EQU $10 ;identification day
IDMON  EQU $05 ;identification month
IDYEAR EQU $83 ;identification year
IDCPU  EQU $02 ;identification CPU series
IDPN1  EQU 'B' ;identification part number field 1
IDPN2  EQU 'B' ;identification part number field 2
IDPN3  EQU $00 ;identification part number field 3
IDPN4  EQU $00 ;identification part number field 4
IDPN5  EQU $01 ;identification part number field 5

* Configuration Equates
* NOTES
*   Problem: last byte of HATABS (as defined by:
*   overlaps first power-up validation byte.
MAXDEV EQU 33 ;offset to last possible entry of HATABS
IOCBSZ EQU 16 ;length of IOCB

SEIOCB EQU 0*IOCBSZ ;screen editor IOCB index
MAXIOC EQU 8*IOCBSZ ;first invalid IOCB index

DSCTSZ EQU 128 ;disk sector size

LEDGE  EQU 2  ;left edge
REDGE  EQU 39 ;right edge

INIML  EQU $0700 ;initial MEMLO

ICSORG EQU $CC00 ;international character set origin
DCSORG EQU $E000 ;domestic character set origin

*      IOCB Command Code Equates
OPEN   EQU $03 ;open
GETREC EQU $05 ;get record
GETCHR EQU $07 ;get character(s)
PUTREC EQU $09 ;put record
PUTCHR EQU $0B ;put character(s)
CLOSE  EQU $0C ;close
STATIS EQU $0D ;status
SPECIL EQU $0E ;special

* Special Entry Command Equates

* Screen Commands
DRAWLN EQU $11 ;draw line
FILLIN EQU $12 ;draw line with right fill

* ICAX1 Auxiliary Byte 1 Equates
APPEND EQU $01 ;open write append (D:) or screen read (E:)
DIRECT EQU $02 ;open for directory access (D:)
OPNIN  EQU $04 ;open for input (all devices)
OPNOT  EQU $08 ;open for output (all devices)
MXDMOD EQU $10 ;open for mixed mode (E:, S:)
INSCLR EQU $20 ;open for input without clearing screen (E:, S:)

* Device Code Equates
CASSET EQU 'C' ;cassette
DISK   EQU 'D' ;disk
SCREDT EQU 'E' ;screen editor
KBD    EQU 'K' ;keyboard
PRINTR EQU 'P' ;printer
DISPLY EQU 'S' ;screen display

* Character and Key Code Equates
CLS    EQU $7D ;clear screen
EOL    EQU $9B ;end of line (RETURN)
HELP   EQU $11 ;key code for HELP
CNTLF1 EQU $83 ;key code for CTRL-F1
CNTLF2 EQU $84 ;key code for CTRL-F2
CNTLF3 EQU $93 ;key code for CTRL-F3
CNTLF4 EQU $94 ;key code for CTRL-F4
CNTL1  EQU $9F ;key code for CTRL-1

* Status Code Equates
SUCCES EQU 1   ;successful operation
BRKABT EQU 128 ;BREAK key abort
PRVOPN EQU 129 ;IOCB already open error
NONDEV EQU 130 ;nonexistent device error
WRONLY EQU 131 ;IOCB opened for write only error
NVALID EQU 132 ;invalid command error
NOTOPN EQU 133 ;device/file not open error
BADIOC EQU 134 ;invalid IOCB index error
RDONLY EQU 135 ;IOCB opened for read only error
EOFERR EQU 136 ;end of file error
TRNRCD EQU 137 ;truncated record error
TIMOUT EQU 138 ;peripheral device timeout error
DNACK  EQU 139 ;device does not acknowledge command error
FRMERR EQU 140 ;serial bus framing error
CRSROR EQU 141 ;cursor overrange error
OVRRUN EQU 142 ;serial bus data overrun error
CHKERR EQU 143 ;serial bus checksum error
DERROR EQU 144 ;device done (operation incomplete) error
BADMOD EQU 145 ;bad screen mode number error
FNCNOT EQU 146 ;function not implemented in handler error
SCRMEM EQU 147 ;insufficient memory for screen mode error

* DCB Device Bus ID Equates
DISKID EQU $31 ;disk bus ID
PDEVN  EQU $40 ;printer bus ID
CASET  EQU $60 ;cassette bus ID

* Bus Command Equates
FOMAT  EQU '!' ;format command
PUTSEC EQU 'P' ;put sector command
READ   EQU 'R' ;read command
STATC  EQU 'S' ;status command
WRITE  EQU 'W' ;write command

* Command Auxiliary Byte Equates
DOUBLE EQU 'D' ;print 20 characters double width
NORMAL EQU 'N' ;print 40 characters normally
PLOT   EQU 'P' ;plot
SIDWAY EQU 'S' ;print 16 characters sideways

* Bus Response Equates
ACK    EQU 'A' ;device acknowledged
COMPLT EQU 'C' ;device successfully completed operation
ERROR  EQU 'E' ;device incurred error in attempted operation
NACK   EQU 'N' ;device did not understand

* Floating Point Package Miscellaneous Equates
FPREC  EQU 6 ;precision
FMPREC EQU FPREC-1 ;length of mantissa

* Cassette Record Type Equates
HDR    EQU $FB ;header
DTR    EQU $FC ;data record
DT1    EQU $FA ;last data record
EOT    EQU $FE ;end of tape (file)
TONE1  EQU 2 ;record
TONE2  EQU 1 ;playback

* Cassette Timing Equates
WLEADN EQU 1152 ;NTSC 19.2 second WRITE file leader
RLEADN EQU 576  ;NTSC 9.6 second READ file leader
WIRGLN EQU 180  ;NTSC 3.0 second WRITE IRG
RIRGLN EQU 120  ;NTSC 2.0 second READ IRG
WSIRGN EQU 15   ;NTSC 0.25 second WRITE short IRG
RSIRGN EQU 10   ;NTSC 0.16 second READ short IRG
BEEPNN EQU 30   ;NTSC 0.5 second beep duration
BEEPFN EQU 10   ;NTSC 0.16 second beep separation

WLEADP EQU 960 ;PAL 19.2 second WRITE file leader
RLEADP EQU 480 ;PAL 9.6 second READ file leader
WIRGLP EQU 150 ;PAL 3.0 second WRITE IRG
RIRGLP EQU 100 ;PAL 2.0 second READ IRG
WSIRGP EQU 13  ;PAL 0.25 second WRITE short IRG
RSIRGP EQU 8   ;PAL 0.16 second READ short IRG
BEEPNP EQU 25  ;PAL 0.5 second beep duration
BEEPFP EQU 8   ;PAL 0.16 second beep separation

WIRGHI EQU 0 ;high WRITE IRG
RIRGHI EQU 0 ;high READ IRG

* Power-up Validation Byte Value Equates
PUPVL1 EQU $5C ;power-up validation value 1
PUPVL2 EQU $93 ;power-up validation value 2
PUPVL3 EQU $25 ;power-up validation value 3

* Relocating Loader Miscellaneous Equates
DATAER EQU 156 ;end of record appears before END r:
MEMERR EQU 157 ;memory insufficient for load error

* Miscellaneous Equates
IOCFRE EQU $FF ;IOCB free indicator

B19200 EQU $0028 ;19200 baud POKEY counter value
B00600 EQU $05CC ;600 baud POKEY counter value

HITONE EQU $05 ;FSK high freq. POKEY counter value (5326 Hz)
LOTONE EQU $07 ;FSK low freq. POKEY counter value (3995 Hz)

NCOMLO EQU $34 ;PIA lower NOT COMMAND line command
NCOMHI EQU $3C ;PIA raise NOT COMMAND line command

MOTRGO EQU $34 ;PIA cassette motor ON command
MOTRST EQU $3C ;PIA cassette motor OFF command

NODAT  EQU $00 ;SIO immediate operation
GETDAT EQU $40 ;SIO read data frame
PUTDAT EQU $80 ;SIO write data frame

CRETRI EQU 13 ;number of command frame retries
DRETRI EQU 1  ;number of device retries
CTIM   EQU 2  ;command frame ACK timeout

NBUFSZ EQU 40 ;print normal buffer size
DBUFSZ EQU 20 ;print double buffer size
SBUFSZ EQU 29 ;print sideways buffer size

* SUBTTL 'System Address Equates'
       ICL 'REV2EQUS.ICL'
* SUBTTL 'Hardware Address Equates'
       ICL 'REV2EQUH.ICL'

* SUBTTL 'Miscellaneous Address Equates'

* Self-test Page Zero Address Equates
STTIME EQU $80 ;2-byte main screen timeout timer
STAUT  EQU $82 ;1-byte auto-mode flag
STJMP  EQU $83 ;3-byte ANTIC jump instruction
STSEL  EQU $86 ;1-byte selection
STPASS EQU $87 ;1-byte pass
STSPP  EQU $88 ;1-byte SELECT previously pressed flag
*      EQU $89 ;1-byte (not used)
STKST  EQU $8A ;1-byte keyboard self-test flag (0 = not)
STCHK  EQU $8B ;2-byte checksum
STSMM  EQU $8D ;1-byte screen memory mask
STSMP  EQU $8E ;1-byte screen memory pointer
ST1K   EQU $8F ;1-byte current 1K of memory to test
STPAG  EQU $90 ;2-byte current page to test
STPC   EQU $92 ;1-byte page count
STMVAL EQU $93 ;1-byte correct value for memory test
STSKP  EQU $94 ;1-byte simulated keypress index
STTMP1 EQU $95 ;2-byte temporary
STVOC  EQU $97 ;1-byte current voice indicator
STNOT  EQU $98 ;1-byte current note counter
STCDI  EQU $99 ;1-byte cleft display pointer
STCDA  EQU $9A ;1-byte cleft data pointer
STTMP2 EQU $9B ;2-byte temporary
STTMP3 EQU $9D ;1-byte temporary
STADR1 EQU $9E ;2-byte temporary address
STADR2 EQU $A0 ;2-byte temporary address
STBL   EQU $A2 ;1-byte blink counter
STTMP4 EQU $A3 ;1-byte temporary
STLM   EQU $A4 ;1-byte LED mask
STTMP5 EQU $A5 ;1-byte temporary

* Self-test Address Equates
ST3000 EQU $3000 ;screen memory
ST3002 EQU $3002 ;cleft display
ST3004 EQU $3004 ;"VOICE #" text display
ST300B EQU $300B ;voice number display
ST301C EQU $301C ;START key display
ST301E EQU $301E ;SELECT key display
ST3020 EQU $3020 ;OPTION key display, first 8K ROM display
ST3021 EQU $3021 ;keyboard character display
ST3022 EQU $3022 ;keyboard text display
ST3024 EQU $3024 ;second 8K ROM display
ST3028 EQU $3028 ;"RAM" text display
ST3038 EQU $3038 ;RAM display
ST303C EQU $303C ;fifth note display
ST304C EQU $304C ;"B S" text display
ST3052 EQU $3052 ;tab key display
ST3062 EQU $3062 ;cleft display
ST306D EQU $306D ;return key display
ST3072 EQU $3072 ;control key display
ST3092 EQU $3092 ;"SH" text display
ST309E EQU $309E ;sixth note display
ST30AB EQU $30AB ;"SH" text display
ST30B7 EQU $30B7 ;"S P A C E   B A R" text display
ST30C1 EQU $30C1 ;cleft display
ST30C2 EQU $30C2 ;cleft display
ST30C7 EQU $30C7 ;third note display
ST30CA EQU $30CA ;fourth note display
ST30F8 EQU $30F8 ;third note display
ST3100 EQU $3100 ;screen memory
ST3121 EQU $3121 ;cleft display
ST3122 EQU $3122 ;cleft display
ST313C EQU $313C ;fifth note display
ST3150 EQU $3150 ;first line of staff display
ST3154 EQU $3154 ;first note display
ST3181 EQU $3181 ;cleft display
ST3182 EQU $3182 ;cleft display
ST3186 EQU $3186 ;second note display
ST318C EQU $318C ;fifth note display
ST31B0 EQU $31B0 ;second line of staff display
ST31C2 EQU $31C2 ;cleft display
ST31CA EQU $31CA ;fourth note display
ST31EE EQU $31EE ;sixth note display
ST31F1 EQU $31F1 ;cleft display
ST3210 EQU $3210 ;third line of staff display
ST321A EQU $321A ;fourth note display
ST3248 EQU $3248 ;third note display
ST3270 EQU $3270 ;fourth line of staff display
ST32D0 EQU $32D0 ;fifth line of staff display
