* SUBTTL 'Keyboard, Editor and Screen Handler, Part 1'

* TSMA - Table of Screen Memory Allocation
* Entry n is the number of $40-byte blocks to allocate for
* graphics mode n.
* NOTES
*   Problem: For readability, this, and other t:
*   this area, could be moved closer to the oth:
*   the Keyboard, Editor and Screen Handler (ju:
*   the EF6B patch).
TSMA DTA B(24)  ;0
     DTA B(16)  ;1
     DTA B(10)  ;2
     DTA B(10)  ;3
     DTA B(16)  ;4
     DTA B(28)  ;5
     DTA B(52)  ;6
     DTA B(100) ;7
     DTA B(196) ;8
     DTA B(196) ;9
     DTA B(196) ;10
     DTA B(196) ;11
     DTA B(28)  ;12
     DTA B(16)  ;13
     DTA B(100) ;14
     DTA B(196) ;15

* TDLE - Table of Display List Entry Counts
* Each entry is 2 bytes.
TDLE DTA B(23,23)  ;0
     DTA B(11,23)  ;1
     DTA B(47,47)  ;2
     DTA B(95,95)  ;3
     DTA B(97,97)  ;4
     DTA B(97,97)  ;5
     DTA B(23,11)  ;6
     DTA B(191,97) ;7
     DTA B(19,19)  ;8
     DTA B(9,19)   ;9
     DTA B(39,39)  ;10
     DTA B(79,79)  ;11
     DTA B(65,65)  ;12
     DTA B(65,65)  ;13
     DTA B(19,9)   ;14
     DTA B(159,65) ;15

* TAGM - Table of ANTIC Graphics Modes
* Entry n is the ANTIC graphics mode corresponding to internal
* graphics mode n.
TAGM DTA B($02) ;int 0 40x2x8 characters
     DTA B($06) ;int 1 20x5x8 characters
     DTA B($07) ;int 2 20x5x16 characters
     DTA B($08) ;int 3 40x4x8 graphics
     DTA B($09) ;int 4 80x2x4 graphics
     DTA B($0A) ;int 5 80x4x4 graphics
     DTA B($0B) ;int 6 160x2x2 graphics
     DTA B($0D) ;int 7 160x4x2 graphics
     DTA B($0F) ;int 8 320x2x1 graphics
     DTA B($0F) ;int 9 320x2x1 GTIA "lum" mode
     DTA B($0F) ;int 10 320x2x1 GTIA "color/lum" mode
     DTA B($0F) ;int 11 320x2x1 GTIA "color" mode
     DTA B($04) ;int 12 40x5x8 characters
     DTA B($05) ;int 13 40x5x16 characters
     DTA B($0C) ;int 14 160x2x1 graphics
     DTA B($0E) ;int 15 160x4x1 graphics

* TDLV - Table of Display List Vulnerability
* Entry n is non-zero if the display list for mode n cannot
* cross a page boundary.
TDLV DTA B(0) ;0
     DTA B(0) ;1
     DTA B(0) ;2
     DTA B(0) ;3
     DTA B(0) ;4
     DTA B(0) ;5
     DTA B(0) ;6
     DTA B(1) ;7
     DTA B(1) ;8
     DTA B(1) ;9
     DTA B(1) ;10
     DTA B(1) ;11
     DTA B(0) ;12
     DTA B(0) ;13
     DTA B(1) ;14
     DTA B(1) ;15

* TLSC - Table of Left Shift Counts
* Entry n is the NUMBER OF LEFT SHIFTS NEEDED TO MULTIPLY
* COLCRS BY # BYTES/ROW ((ROWCRS*5)/(2;TLSC)) for mode n.
TLSC DTA B(3) ;0
     DTA B(2) ;1
     DTA B(2) ;2
     DTA B(1) ;3
     DTA B(1) ;4
     DTA B(2) ;5
     DTA B(2) ;6
     DTA B(3) ;7
     DTA B(3) ;8
     DTA B(3) ;9
     DTA B(3) ;10
     DTA B(3) ;11
     DTA B(3) ;12
     DTA B(3) ;13
     DTA B(2) ;14
     DTA B(3) ;15

* TMCC - Table of Mode Column Counts
* Entry n is the low column count for mode n.
TMCC DTA L(40)  ;0
     DTA L(20)  ;1
     DTA L(20)  ;2
     DTA L(40)  ;3
     DTA L(80)  ;4
     DTA L(80)  ;5
     DTA L(160) ;6
     DTA L(160) ;7
     DTA L(320) ;8
     DTA L(80)  ;9
     DTA L(80)  ;10
     DTA L(80)  ;11
     DTA L(40)  ;12
     DTA L(40)  ;13
     DTA L(160) ;14
     DTA L(160) ;15

* TMRC - Table of Mode Row Counts
* Entry n is the row count for mode n.
TMRC DTA B(24)  ;0
     DTA B(24)  ;1
     DTA B(12)  ;2
     DTA B(24)  ;3
     DTA B(48)  ;4
     DTA B(48)  ;5
     DTA B(96)  ;6
     DTA B(96)  ;7
     DTA B(192) ;8
     DTA B(192) ;9
     DTA B(192) ;10
     DTA B(192) ;11
     DTA B(24)  ;12
     DTA B(12)  ;13
     DTA B(192) ;14
     DTA B(192) ;15

* TRSC - Table of Right Shift Counts
* Entry n is HOW MANY RIGHT SHIFTS FOR HCRSR FOR PARTIAL
* BYTE MODES for mode n.
TRSC DTA B(0) ;0
     DTA B(0) ;1
     DTA B(0) ;2
     DTA B(2) ;3
     DTA B(3) ;4
     DTA B(2) ;5
     DTA B(3) ;6
     DTA B(2) ;7
     DTA B(3) ;8
     DTA B(1) ;9
     DTA B(1) ;10
     DTA B(1) ;11
     DTA B(0) ;12
     DTA B(0) ;13
     DTA B(3) ;14
     DTA B(2) ;15

* TDSM - Table of Display Masks
* NOTES
*   Includes TBTM - Table of Bit Masks.
TDSM DTA B($FF) ;1
     DTA B($F0) ;2
     DTA B($0F) ;3
     DTA B($C0) ;4
     DTA B($30) ;5
     DTA B($0C) ;6
     DTA B($03) ;7
TBTM DTA B($80) ;8 (0)
     DTA B($40) ;9 (1)
     DTA B($20) ;10 (2)
     DTA B($10) ;11 (3)
     DTA B($08) ;12 (4)
     DTA B($04) ;13 (5)
     DTA B($02) ;14 (6)
     DTA B($01) ;15 (7)
