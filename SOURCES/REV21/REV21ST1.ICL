* SUBTTL 'Self-test, Part 1'

* SES - Select and Execute Self-test
* SES selects the self-test ROM and executes the self-test.
* ENTRY   JSR SES
* NOTES
*   Problem: this could be contiguous with other OS ROM
*   self-test code (near TSTO).
SES  EQU *
     LDA #$FF
     STA COLDST ;force coldstart on RESET
     LDA PORTB
     AND #$7F   ;enable self-test ROM
     STA PORTB  ;update port B memory control
     JMP SLFTSV ;vector to self-test
