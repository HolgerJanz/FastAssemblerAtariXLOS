* SUBTTL 'Self-test, Part 2'

* TSTO - Table of Self-test Text Offsets
TSTO DTA L(TXT0-TTXT) ;0 offset to "MEMORY TEST   ROM" text
     DTA L(TXT1-TTXT) ;1 offset to "RAM" text
     DTA L(TXT2-TTXT) ;2 offset to "KEYBOARD TEST" text
     DTA L(TXT3-TTXT) ;3 offset to "S P A C E   B A R" text
     DTA L(TXT4-TTXT) ;4 offset to "SH" text
     DTA L(TXT5-TTXT) ;5 offset to "SH" text
     DTA L(TXT6-TTXT) ;6 offset to "B S" text
     DTA L(TXT7-TTXT) ;7 offset to keyboard text
     DTA L(TXT8-TTXT) ;8 offset to control key text
     DTA L(TXT9-TTXT) ;9 offset to "VOICE #" text

* TTXT - Table of Text Sequences
TTXT EQU *

* TXT0 - "MEMORY TEST   ROM" Text
TXT0 DTA B($00,$00)
     DTA B($2D,$25,$2D,$2F,$32,$39) ;"MEMORY"
     DTA B($00)
     DTA B($34,$25,$33,$34) ;"TEST"
     DTA B($00,$00,$00)
     DTA B($32,$2F,$2D) ;"ROM"
TXT0L EQU *-TXT0 ;length

* TXT1 - "RAM" Text
TXT1 DTA B($32,$21,$2D) ;"RAM"
TXT1L EQU *-TXT1 ;length

* TXT2 - "KEYBOARD TEST" Text
TXT2 DTA B($00,$00)
     DTA B($2B,$25,$39,$22,$2F,$21,$32,$24) ;"KEYBOARD"
     DTA B($00)
     DTA B($34,$25,$33,$34) ;"TEST"
     DTA B($00,$00,$00)
     DTA B($B2)
TXT2L EQU *-TXT2 ;length

* TXT7 - Keyboard
TXT7 EQU *
* First Row (Function Keys)
     DTA B($91) ;"1"
     DTA B($00)
     DTA B($92) ;"2"
     DTA B($00)
     DTA B($93) ;"3"
     DTA B($00)
     DTA B($94) ;"4"
     DTA B($00)
     DTA B($A8) ;"H"
     DTA B($00)
     DTA B($A1) ;"A"
     DTA B($00)
     DTA B($A2) ;"B"
     DTA B($00,$00,$00)
* Second Row ("1 2 3 4 5 6 7 8 9 0 < >")
     DTA B($5B)
     DTA B($00)
     DTA B($11) ;"1"
     DTA B($00)
     DTA B($12) ;"2"
     DTA B($00)
     DTA B($13) ;"3"
     DTA B($00)
     DTA B($14) ;"4"
     DTA B($00)
     DTA B($15) ;"5"
     DTA B($00)
     DTA B($16) ;"6"
     DTA B($00)
     DTA B($17) ;"7"
     DTA B($00)
     DTA B($18) ;"8"
     DTA B($00)
     DTA B($19) ;"9"
     DTA B($00)
     DTA B($10) ;"0"
     DTA B($00)
     DTA B($1C) ;"<"
     DTA B($00)
     DTA B($1E) ;">"
     DTA B($00)
     DTA B($A2) ;"B"
     DTA B($80)
     DTA B($B3) ;"S"
     DTA B($00,$00,$00)
* Third Row ("Q W E R T Y U I O P - =")
     DTA B($FF)
     DTA B($FF)
     DTA B($00)
     DTA B($31) ;"Q"
     DTA B($00)
     DTA B($37) ;"W"
     DTA B($00)
     DTA B($25) ;"E"
     DTA B($00)
     DTA B($32) ;"R"
     DTA B($00)
     DTA B($34) ;"T"
     DTA B($00)
     DTA B($39) ;"Y"
     DTA B($00)
     DTA B($35) ;"U"
     DTA B($00)
     DTA B($29) ;"I"
     DTA B($00)
     DTA B($2F) ;"O"
     DTA B($00)
     DTA B($30) ;"P"
     DTA B($00)
     DTA B($0D) ;"-"
     DTA B($00)
     DTA B($1D) ;"="
     DTA B($00)
     DTA B($B2) ;"R"
     DTA B($B4) ;"T"
     DTA B($00,$00,$00)
* Fourth Row ("A S D F G H J K L ; + *")
     DTA B($80)
     DTA B($DC)
     DTA B($80)
     DTA B($00)
     DTA B($21) ;"A"
     DTA B($00)
     DTA B($33) ;"S"
     DTA B($00)
     DTA B($24) ;"D"
     DTA B($00)
     DTA B($26) ;"F"
     DTA B($00)
     DTA B($27) ;"G"
     DTA B($00)
     DTA B($28) ;"H"
     DTA B($00)
     DTA B($2A) ;"J"
     DTA B($00)
     DTA B($2B) ;"K"
     DTA B($00)
     DTA B($2C) ;"L"
     DTA B($00)
     DTA B($1B) ;";"
     DTA B($00)
     DTA B($0B) ;"+"
     DTA B($00)
     DTA B($0A) ;"*"
     DTA B($00)
     DTA B($A3) ;"C"
     DTA B($00,$00,$00)
* Fifth Row ("Z X C V B N M , . /")
     DTA B($80)
     DTA B($B3) ;"S"
     DTA B($A8) ;"H"
     DTA B($80)
     DTA B($00)
     DTA B($3A) ;"Z"
     DTA B($00)
     DTA B($38) ;"X"
     DTA B($00)
     DTA B($23) ;"C"
     DTA B($00)
     DTA B($36) ;"V"
     DTA B($00)
     DTA B($22) ;"B"
     DTA B($00)
     DTA B($2E) ;"N"
     DTA B($00)
     DTA B($2D) ;"M"
     DTA B($00)
     DTA B($0C) ;","
     DTA B($00)
     DTA B($0E) ;"."
     DTA B($00)
     DTA B($0F) ;"/"
     DTA B($00)
     DTA B($80)
     DTA B($B3) ;"S"
     DTA B($A8) ;"H"
     DTA B($80)
     DTA B($00,$00,$00)
* Sixth Row (Space Bar)
     DTA B($00,$00,$00,$00,$00)
     DTA B($80)
     DTA B($B3) ;"S"
     DTA B($80)
     DTA B($B0) ;"P"
     DTA B($80)
     DTA B($A1) ;"A"
     DTA B($80)
     DTA B($A3) ;"C"
     DTA B($80)
     DTA B($A5) ;"E"
     DTA B($80)
     DTA B($80)
     DTA B($80)
     DTA B($A2) ;"B"
     DTA B($80)
     DTA B($A1) ;"A"
     DTA B($80)
     DTA B($B2) ;"R"
     DTA B($80)
TXT7L EQU *-TXT7 ;length

* TXT3 - "S P A C E   B A R" Text
TXT3 DTA B($00)
     DTA B($33) ;"S"
     DTA B($00)
     DTA B($30) ;"P"
     DTA B($00)
     DTA B($21) ;"A"
     DTA B($00)
     DTA B($23) ;"C"
     DTA B($00)
     DTA B($25) ;"E"
     DTA B($00)
     DTA B($00)
     DTA B($00)
     DTA B($22) ;"B"
     DTA B($00)
     DTA B($21) ;"A"
     DTA B($00)
     DTA B($32) ;"R"
     DTA B($00)
TXT3L EQU *-TXT3 ;length

* TXT4 - "SH" Text
TXT4 DTA B($00)
     DTA B($33,$28) ;"SH"
     DTA B($00)
TXT4L EQU *-TXT4 ;length

* TXT5 - "SH" Text
TXT5 EQU TXT4
TXT5L EQU TXT4L ;length

* TXT6 - "B S" Text
TXT6 DTA B($22) ;"B"
     DTA B($00)
     DTA B($33) ;"S"
TXT6L EQU *-TXT6 ;length

* TXT8 - Control Key
TXT8 DTA B($00)
     DTA B($5C)
     DTA B($00)
TXT8L EQU *-TXT8 ;length

* TXT9 - "VOICE #" Text
TXT9 DTA B($36,$2F,$29,$23,$25) ;"VOICE"
     DTA B($00)
     DTA B($03) ;"#"
TXT9L EQU *-TXT9 ;length
