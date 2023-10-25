* SUBTTL 'Self-test, Part 3.2'

* TMNT - Table of Memory Not to Test
* NOTES
*   Problem: bytes wasted by redundant entries.
TMNT DTA H($0000) ;$0000-$03FF,zero page and stack
     DTA H($5000) ;$5000-$53FF,self-test ROM
     DTA H($5400) ;$5400-$57FF,self-test ROM
     DTA H(ST3000) ;ST3000-ST3000+$03FF,screen memory
     DTA H(ST3000) ;ST3000-ST3000+$03FF,screen memory
     DTA H(ST3000) ;ST3000-ST3000+$03FF,screen memory
TMNTL EQU *-TMNT ;length

* STK - Self-test Keyboard
* STK verifies the operation of the keyboard by displaying
* keys as they are pressed.  In auto-mode, the verification
* is simulated.
* ENTRY   JSR STK
* NOTES
*   Problem: one too many bytes taken from TSKP table.
*   Problem: wasted bytes for extra LDA CH.
*   Problem: logic is convoluted (due to SBT and SAS
*   subroutines appearing in the middle of STK).
STK  EQU *
* Initialize
     LDX #0
     STX STSKP  ;initialize simulated keypress index
     LDX #3     ;keyboard test colors
     JSR SUC    ;set up colors
     LDX <DISL4 ;keyboard display list
     LDY >DISL4
     LDA #$FF   ;indicate keyboard self-test
     JSR SDL    ;set up display list
* Test keyboard
STK1 LDX #2  ;offset to "KEYBOARD TEST" text
     JSR SSM ;set screen memory
     LDX #7  ;offset to keyboard text
     JSR SSM ;set screen memory
* Check auto-mode
     LDA STAUT ;auto-mode flag
     BEQ STK3  ;if not auto-mode
* Simulate keypress
STK2 LDX STSKP    ;offset to next simulated keypress
     LDA TSKP,X   ;simulated keypress
     INC STSKP    ;advance offset to simulated keypress
     LDX STSKP    ;offset to simulated keypress
     CPX <TSKPL+1 ;last offset+1+1
     BNE STK4     ;if last keypress not processed
* Self-test memory
     JSR DLW ;delay a long while
     JMP STM ;self-test memory
* Get a keypress
STK3 LDA CH   ;key code
     CMP #$FF ;clear code indicator
     BEQ STK3 ;if no key pressed
     CMP #$C0
     BCS STK3 ;if ???
     LDA CH   ;key code
* Process keypress
STK4 LDX #$FF ;clear code indicator
     STX CH   ;key code
     PHA      ;save key code
     AND #$80
     BEQ STK5 ;if not CTRL
     LDX #8   ;offset to control key text
     JSR SSM  ;set screen memory
* Check for shift key
STK5 PLA      ;saved key code
     PHA      ;save key code
     AND #$40
     BEQ STK6 ;if not shift key
* Process keyboard shift key display
     LDX #5  ;offset to "SH"
     JSR SSM ;set screen memory
     LDX #4  ;offset to "SH"
     JSR SSM ;set screen memory
* Check for special keys
STK6 PLA      ;saved key code
     AND #$3F
     CMP #$21
     BEQ KSB  ;if space bar, process display
     CMP #$2C
     BEQ KTK  ;if tab key, process display
     CMP #$34
     BEQ KBK  ;if backspace key, process display
     CMP #$0C
     BEQ KRK  ;if return key, process display
* Process other key displays
     TAX         ;key code
     LDA TSMC,X  ;display character
     PHA         ;save display character
     LDA <ST3021
     STA STTMP1  ;screen pointer
     LDA >ST3021
     STA STTMP1+1
* Find display character in screen memory
     PLA      ;saved display character
     LDY #$FF ;preset offset
STK7 INY
     CMP (STTMP1),Y
     BNE STK7 ;if not found
* Display inverse video
     LDA (STTMP1),Y
     EOR #$80    ;invert video
     STA (STTMP1),Y
* Check auto-mode
STK8 LDA STAUT ;auto-mode flag
     BEQ STK9  ;if not auto-mode
* Process auto-mode
     JSR SBT  ;sound beep tone
     LDX #20  ;20-VBLANK delay
     JSR DAW  ;delay a while
     JSR SAS  ;silence all sounds
     LDX #10  ;10-VBLANK delay
     JSR DAW  ;delay a while
     JMP STK1 ;get next simulated keypress
* Process manual mode
STK9 JSR SBT    ;sound beep tone
STK10 LDA SKSTAT
     AND #$04
     BEQ STK10
     JSR SAS    ;silence all sounds
     JMP STK1   ;get next keypress

* SBT - Sound Beep Tone
* ENTRY   JSR SBT
SBT  EQU *
     LDA #$64  ;frequency
     STA AUDF1 ;set frequency
     LDA #$A8  ;pure tone, half volume
     STA AUDC1 ;set control
     RTS       ;return

* SAS - Silence All Sounds
* ENTRY   JSR SAS
SAS  EQU *
     LDA #0    ;volume 0
     STA AUDC1 ;silence voice 1
     STA AUDC2 ;silence voice 2
     STA AUDC3 ;silence voice 3
     STA AUDC4 ;silence voice 4
     RTS       ;return

* KSB - Process Keyboard Space Bar Display
* ENTRY   JSR KSB
KSB  EQU *
     LDX #3   ;offset to "S P A C E   B A R" text
     JSR SSM  ;set screen memory
     JMP STK8 ;continue

* KBK - Process Keyboard Backspace Key Display
* ENTRY   JSR KBK
KBK  EQU *
     LDX #6   ;offset to "B S" text
     JSR SSM  ;set screen memory
     JMP STK8 ;continue

* KTK - Process Keyboard Tab Key Display
* ENTRY   JSR KTK
KTK  EQU *  
     LDA #$7F
     STA ST3052
     STA ST3052+1
     BNE STK8    ;continue

* KRK - Process Keyboard Return Key Display
* ENTRY   JSR KRK
KRK  EQU *  
     LDA #$32
     STA ST306D
     LDA #$34
     STA ST306D+1
     BNE STK8    ;continue

* TSKP - Table of Simulated Keypresses
TSKP DTA B($52,$08,$0A,$2B,$28,$0D,$3D,$39,$2D) ;"Copyright"
     DTA B($1F,$30,$35,$1A)                     ;"1983"
     DTA B($7F,$2D,$3F,$28,$0D)                 ;"Atari"
TSKPL EQU *-TSKP  ;length

* STV - Self-test Audio-visual
* STV verifies the operation of the display and voices by
* displaying and playing a tune.
* ENTRY   JSR STV
STV  EQU *
* Initialize
     LDX #2  ;audio-visual test colors
     JSR SUC ;set up colors
* Test audio-visual
STV1 LDA #0
     STA STVOC ;initialize voice indicator
* Test voice
STV2 LDA #0
     STA STNOT  ;initialize note counter
     LDX <DISL5 ;audio-visual display list
     LDY >DISL5
     LDA #0     ;indicate not keyboard self-test
     JSR SDL    ;set up display list
* Display voice number
     LDX #9     ;offset to "VOICE #" text
     JSR SSM    ;set screen memory
     LDA STVOC  ;voice indicator
     LSR @      ;voice number
     CLC
     ADC #$11   ;adjust for screen memory
     STA ST300B ;voice number display
* Display staff
     LDX #$0F     ;offset to last byte of staff lines
STV3 LDA #$FF     ;color 2
     STA ST3150,X ;byte of first line of staff
     STA ST31B0,X ;byte of second line of staff
     STA ST3210,X ;byte of third line of staff
     STA ST3270,X ;byte of fourth line of staff
     STA ST32D0,X ;byte of fifth line of staff
     DEX
     BPL STV3     ;if not done
* Display cleft
     LDA #0       ;offset to first cleft display address
     STA STCDI    ;cleft display pointer
     LDA #2*6
     STA STCDA    ;cleft data pointer
STV4 LDX STCDI    ;cleft display pointer
     LDA TCDA+1,X ;high address of cleft display
     TAY
     LDA TCDA,X   ;low address of cleft display
     TAX
     LDA STCDA    ;cleft data pointer
     JSR DVN      ;display ???
     CLC
     LDA STCDA    ;cleft data pointer
     ADC #6
     STA STCDA    ;update cleft data pointer
     INC STCDI    ;increment cleft display pointer
     INC STCDI
     LDA STCDI    ;cleft display pointer
     CMP <TCDAL   ;length of cleft display table
     BNE STV4     ;if not done
* Delay
     JSR DMW      ;delay a middling while
* Display and play first note
     LDX <ST3154
     LDY >ST3154
     LDA #0*6
     JSR DVN
     LDA #$51 ;first note frequency
     JSR SVN
* Display and play second note
     LDX <ST3186
     LDY >ST3186
     LDA #0*6
     JSR DVN
     LDA #$5B ;second note frequency
     JSR SVN
* Display and play third note
     LDX <ST30F8
     LDY >ST30F8
     LDA #12*6
     JSR DVN
     LDX <ST30C7
     LDY >ST30C7
     LDA #14*6
     JSR DVN
     LDX <ST3248
     LDY >ST3248
     LDA #13*6
     JSR DVN
     LDA #$44 ;third note frequency
     JSR SVN
* Display and play fourth note
     LDX <ST30CA
     LDY >ST30CA
     LDA #12*6
     JSR DVN
     LDX <ST321A
     LDY >ST321A
     LDA #13*6
     JSR DVN
     LDX <ST31CA
     LDY >ST31CA
     LDA #1*6
     JSR DVN
     LDA #$3C ;fourth note frequency
     JSR SVN
* Display and play fifth note
     LDX <ST303C
     LDY >ST303C
     LDA #12*6
     JSR DVN
     LDX <ST318C
     LDY >ST318C
     LDA #13*6
     JSR DVN
     LDX <ST313C
     LDY >ST313C
     LDA #1*6
     JSR DVN
     LDA #$2D ;fifth note frequency
     JSR SVN
* Display and play sixth note
     LDX <ST309E
     LDY >ST309E
     LDA #12*6
     JSR DVN
     LDX <ST31EE
     LDY >ST31EE
     LDA #13*6
     JSR DVN
     LDA #$35 ;sixth note frequency
     JSR SVN
* Delay
     JSR DLW ;delay a long while
* Advance to next voice
     INC STVOC ;increment voice indicator
     INC STVOC
     LDA STVOC ;voice indicator
     CMP #8    ;last voice indicator
     BNE STV5  ;if all voices not processed
* Process test completion.
     LDA STAUT ;auto-mode flag
     BNE STV6  ;if auto-mode, perform keyboard test
     JMP STV1  ;repeat audio-visual test
* Test next voice.
STV5 JMP STV2  ;test next voice
* Self-test keyboard
STV6 JSR DLW ;delay a long while
     JMP STK ;self-test keyboard

* SVN - Sound Tone
* ENTRY   JSR SVN
SVN  EQU *
* Sound note.
     LDY STVOC   ;current voice indicator
     STA AUDF1,Y ;set frequency
     LDA #$A8    ;pure tone, half volume
     STA AUDC1,Y ;set control
* Delay a while
     LDX STNOT  ;current note
     LDA TNDD,X ;delay time
     TAX
     JSR DAW    ;delay a while
* Increment note counter
     INC STNOT  ;increment note counter
* Exit
     JSR SAS ;silence all sounds
     RTS     ;return

* DVN - Display
* ENTRY   JSR DVN
DVN  EQU * 
     STX STTMP2
     STY STTMP2+1
     TAX
     LDY #0
     LDA #16
     STA STTMP3
     LDA #6
     STA STTMP4
DVN1 LDA TAVD,X
     ORA (STTMP2),Y
     STA (STTMP2),Y
     JSR AST  ;add 16
     DEC STTMP3
     BNE DVN1
     INC STTMP3
     INX
     DEC STTMP4
     BNE DVN1
     RTS      ;return

* AST - Add Sixteen
* ENTRY   JSR AST
AST  EQU *   
     CLC
     LDA STTMP2   ;current low value
     ADC #16      ;add 16
     STA STTMP2   ;new low value
     BCC AST1     ;if no carry
     INC STTMP2+1 ;adjust high value
AST1 RTS          ;return

* TNDD - Table of Note Duration Delays
TNDD DTA B(32) ;0 first note
     DTA B(32) ;1 second note
     DTA B(32) ;2 third note
     DTA B(16) ;3 fourth note
     DTA B(16) ;4 fifth note
     DTA B(32) ;5 sixth note

* TAVD - Table of Audio-visual Test Display Data
TAVD DTA B($01,$1F,$3F,$7F,$3E,$1C) ;0
     DTA B($00,$41,$42,$4C,$70,$40) ;1
     DTA B($00,$01,$02,$04,$08,$10) ;2
     DTA B($00,$43,$44,$48,$48,$48) ;3
     DTA B($00,$44,$22,$10,$08,$07) ;4
     DTA B($00,$04,$08,$05,$02,$00) ;5
     DTA B($00,$30,$48,$88,$84,$84) ;6
     DTA B($00,$88,$88,$90,$A0,$C0) ;7
     DTA B($00,$F0,$88,$84,$82,$82) ;8
     DTA B($00,$82,$82,$84,$88,$F0) ;9
     DTA B($00,$00,$00,$00,$00,$80) ;10
     DTA B($80,$80,$80,$80,$80,$80) ;11
     DTA B($00,$1C,$3E,$7F,$7E,$7C) ;12
     DTA B($40,$00,$00,$00,$00,$00) ;13
     DTA B($00,$04,$04,$06,$05,$06) ;14

* TCDA - Table of Cleft Display Addresses
TCDA DTA A(ST30C1) ;0
     DTA A(ST3121) ;1
     DTA A(ST3181) ;2
     DTA A(ST31F1) ;3
     DTA A(ST3002) ;4
     DTA A(ST3062) ;5
     DTA A(ST3122) ;6
     DTA A(ST3182) ;7
     DTA A(ST30C2) ;8
     DTA A(ST31C2) ;9
TCDAL EQU *-TCDA ;length

* SVR - Set Value in Range
* ENTRY   JSR SVR
*   A = value to set
*   X = offset to TARS range
* EXIT
*   A = value set
SVR  EQU *
* Initialize
     PHA ;save value
* Set address range
     LDA TARS,X   ;start of range
     STA STADR1
     LDA TARS+1,X
     STA STADR1+1
     LDA TARS+2,X ;end of range
     STA STADR2
     LDA TARS+3,X
     STA STADR2+1
* Set value in range
     LDY #0         ;offset to first byte
SVR1 PLA            ;saved value
     STA (STADR1),Y ;byte of range
     INC STADR1     ;increment low address
     BNE SVR2       ;if no carry
     INC STADR1+1   ;adjust high address
SVR2 PHA            ;save value
     LDA STADR1     ;low current address
     CMP STADR2     ;low end of range
     BNE SVR1       ;if definitely not done
     LDA STADR1+1   ;high current address
     CMP STADR2+1   ;high end of range
     BNE SVR1       ;if not done
* Exit.
     PLA ;restore value
     RTS ;return

* SSM - Set Screen Memory
* ENTRY   JSR SSM
SSM  EQU *   
     LDA TSTO,X   ;offset to source
     TAY
     LDA TSTL,X   ;length of source
     STA STADR1   ;length
     LDA TSTD,X   ;offset to destination
     TAX
SSM1 LDA TTXT,Y   ;byte of source
     STA ST3000,X ;byte of destination
     INY
     INX
     DEC STADR1   ;decrement length
     BNE SSM1     ;if not done
     RTS          ;return

* SUC - Set Up Colors*
* ENTRY   JSR     SUC
*   X = 0, if main screen colors
*     = 1, if memory test colors
*     = 2, if keyboard test colors
*     = 3, if audio-visual test colors
* EXIT
*   COLOR0, COLOR1, COLOR2 and COLOR4 set.
* CHANGES
*   A
* CALLS
*   none-
SUC  EQU *  
     LDA SUCA,X
     STA COLOR0  ;playfield 0 color
     LDA SUCB,X
     STA COLOR1  ;playfield 1 color
     LDA SUCC,X
     STA COLOR2  ;playfield 2 color
     LDA SUCD,X
     STA COLOR4  ;background color
     RTS         ;return

SUCA DTA B($2C) ;0 main screen playfield 0 color
     DTA B($0C) ;1 memory test playfield 0 color
     DTA B($2A) ;2 keyboard test playfield 0 color
     DTA B($18) ;3 audio-visual test playfield 0 color

SUCB DTA B($0F) ;0 main screen playfield 1 color
     DTA B($32) ;1 memory test playfield 1 color
     DTA B($0C) ;2 keyboard test playfield 1 color
     DTA B($0E) ;3 audio-visual test playfield 1 color

SUCC DTA B($D2) ;0 main screen playfield 2 color
     DTA B($D6) ;1 memory test playfield 2 color
     DTA B($00) ;2 keyboard test playfield 2 color
     DTA B($B4) ;3 audio-visual test playfield 2 color

SUCD DTA B($D2) ;0 main screen background color
     DTA B($A0) ;1 memory test background color
     DTA B($30) ;2 keyboard test background color
     DTA B($B4) ;3 audio-visual test background color

* TSMC - Table of Screen Memory Character Codes
* Entry n is the screen memory character code for key code n.
TSMC DTA B($2C) ;$00 L key
     DTA B($2A) ;$01 J key
     DTA B($1B) ;$02 semicolon key
     DTA B($91) ;$03
     DTA B($92) ;$04
     DTA B($2B) ;$05 K key
     DTA B($0B) ;$06 plus key
     DTA B($0A) ;$07 asterisk key
     DTA B($2F) ;$08 O key
     DTA B($00) ;$09
     DTA B($30) ;$0A P key
     DTA B($35) ;$0B U key
     DTA B($B2) ;$0C RETURN key
     DTA B($29) ;$0D I key
     DTA B($0D) ;$0E minus key
     DTA B($1D) ;$0F = key

     DTA B($36) ;$10 V key
     DTA B($A8) ;$11
     DTA B($23) ;$12 C key
     DTA B($93) ;$13
     DTA B($94) ;$14
     DTA B($22) ;$15 B key
     DTA B($38) ;$16 X key
     DTA B($3A) ;$17 Z key
     DTA B($14) ;$18 4 key
     DTA B($00) ;$19
     DTA B($13) ;$1A 3 key
     DTA B($16) ;$1B 6 key
     DTA B($5B) ;$1C ESC key
     DTA B($15) ;$1D 5 key
     DTA B($12) ;$1E 2 key
     DTA B($11) ;$1F 1 key

     DTA B($0C) ;$20 comma key
     DTA B($00) ;$21 space key
     DTA B($0E) ;$22 period key
     DTA B($2E) ;$23 N key
     DTA B($00) ;$24
     DTA B($2D) ;$25 M key
     DTA B($0F) ;$26 / key
     DTA B($A1) ;$27 inverse video key
     DTA B($32) ;$28 R key
     DTA B($00) ;$29
     DTA B($25) ;$2A E key
     DTA B($39) ;$2B Y key
     DTA B($FF) ;$2C TAB key
     DTA B($34) ;$2D T key
     DTA B($37) ;$2E W key
     DTA B($31) ;$2F Q key

     DTA B($19) ;$30 9 key
     DTA B($00) ;$31
     DTA B($10) ;$32 0 key
     DTA B($17) ;$33 7 key
     DTA B($A2) ;$34 backspace key
     DTA B($18) ;$35 8 key
     DTA B($1C) ;$36 < key
     DTA B($1E) ;$37 > key
     DTA B($26) ;$38 F key
     DTA B($28) ;$39 H key
     DTA B($24) ;$3A D key
     DTA B($00) ;$3B
     DTA B($A3) ;$3C CAPS key
     DTA B($27) ;$3D G key
     DTA B($33) ;$3E S key
     DTA B($21) ;$3F A key

* TARS - Table of Address Ranges to Set
TARS DTA A(ST3000,ST3000+$0EFF) ;0 screen memory
     DTA A(ST3020,ST3020+4)     ;1 memory test first 8K ROM
     DTA A(ST3024,ST3024+4)     ;2 memory test second 8K ROM
     DTA A(ST3000,ST3000+32)    ;3 main screen bold lines

* TSTL - Table of Self-test Text Lengths
TSTL DTA L(TXT0L) ;0 length of "MEMORY TEST   ROM" text
     DTA L(TXT1L) ;1 length of "RAM" text
     DTA L(TXT2L) ;2 length of "KEYBOARD TEST" text
     DTA L(TXT3L) ;3 length of "S P A C E   B A R" text
     DTA L(TXT4L) ;4 length of "SH" text
     DTA L(TXT5L) ;5 length of "SH" text
     DTA L(TXT6L) ;6 length of "B S" text
     DTA L(TXT7L) ;7 length of keyboard text
     DTA L(TXT8L) ;8 length of control key text
     DTA L(TXT9L) ;9 length of "VOICE #" text

* TSTD - Table of Self-test Text Destination Offsets
TSTD DTA L(ST3000-ST3000) ;0 offset to "MEMORY TEST   ROM" text
     DTA L(ST3028-ST3000) ;1 offset to "RAM" text
     DTA L(ST3000-ST3000) ;2 offset to "KEYBOARD TEST" text
     DTA L(ST30B7-ST3000) ;3 offset to "S P A C E   B A R" text
     DTA L(ST3092-ST3000) ;4 offset to "SH" text
     DTA L(ST30AB-ST3000) ;5 offset to "SH" text
     DTA L(ST304C-ST3000) ;6 offset to "B S" text
     DTA L(ST3022-ST3000) ;7 offset to keyboard text
     DTA L(ST3072-ST3000) ;8 offset to control key text
     DTA L(ST3004-ST3000) ;9 offset to "VOICE #" text
