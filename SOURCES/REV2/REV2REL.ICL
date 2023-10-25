* SUBTTL 'Relocating Loader'

* RLR - Relocate Routine
* RLR relocates a relocatable routine which is assemb:
* origin 0.
* GBYTEA - GBYTEA+1 = address of get-byte routine
RLR  EQU *
* Clear parameter block
     LDX #5       ;offset to last parameter
RLR1 LDA #0
     STA PARMBL,X ;clear byte of parameter bl:
     DEX
     BPL RLR1     ;if not done
* Get a new record type and set the subroutine vector:
RLR2 LDA #0
     STA LCOUNT  ;process 0th byte of a reco:
     JSR GBY     ;get type ID
     LDY #DATAER
     BCS RLR4    ;if EOF before END record
     STA HIBYTE  ;save type ID
     JSR GBY     ;get record length
     LDY #DATAER
     BCS RLR4    ;if EOF before END record
     STA RECLEN
     LDA HIBYTE  ;get type ID
     CMP #$0B    ;END record
     BEQ ERC     ;if END record
     ROL @       ;set subroutine vectors
     TAX
     LDA TRPR,X
     STA RUNADR
     LDA TRPR+1,X
     STA RUNADR+1
RLR3 LDA RECLEN
     CMP LCOUNT
     BEQ RLR2    ;if LCOUNT=RECLEN, get new :
     JSR GBY     ;get next byte
     LDY #DATAER
     BCS RLR4    ;if EOF before END record
     JSR CAL     ;call record subroutine
     INC LCOUNT
     BNE RLR3    ;continue
RLR4 RTS

* ERC - Handle END Record
* ERC handles record type of
* 1.End Record
* Record format:
* Byte 0          Type ID
* Byte 1          Self-start flag
* Bytes 2 - 3     Run address
* Process formula
* RUNADR+LOADAD ==> Start Execution Address n Loader-:
* parameter block.
* End record calculates the start execution address b:
* RUNADR with LOADAD, and returns to the Caller with :
* block and a status byte in the Y register. Y=1 mean:
* successful, else is a data structure error.
ERC  EQU *
     JSR GBY     ;get low byte of the RUNADR
     LDY #DATAER
     BCS END3    ;if EOF before END record
     STA RUNADR
     JSR GBY     ;get high byte of the RUNADR
     LDY #DATAER
     BCS END3    ;if EOF before END record
     STA RUNADR+1
     LDA RECLEN  ;RECLEN here is self-start flag
     CMP #1
     BEQ END2    ;if 1, an absolute RUNADR, no fixup
     BCC END4    ;if 0, this is not a self-start pro:
* Process relative start
     CLC
     LDA RUNADR   ;execution address, needs f:
     ADC LOADAD
     TAY
     LDA RUNADR+1
     ADC LOADAD+1 ;A= high byte, Y=low byte
END1 STY RUNADR   ;set up Loader-Caller param:
     STA RUNADR+1
END2 LDY #SUCCES  ;Y=1 successful operation

END3 RTS      ;return
END4 LDY #0   ;fill self-start parameter :
     LDA #0   ;for non-self start program
     BEQ END1 ;continue

* GBY - Get Byte
GBY  EQU * 
     JMP (GBYTEA) ;get byte, return

* CAL - Execute at Run Address
CAL  EQU * 
     JMP (RUNADR) ;process record, return

* TEX - Handle Text Record
* TEX handles record types of
* 1.Non-zero page relocatable text
* 2.Zero page relocatable text
* 3.Absolute text
* Record format
* |Type|Length  |Relative addr.|text|
* |ID  |(RECLEN)|(RELADR)      |    |
* Process formula
* A register ===> (NEWADR+LCOUNT)
* Relocate object text into fixed address of NEWADR+L:
* ENTRY   JSR TEX
* NOTES
* 1.The relocating address (NEWADR) for absolute text:
* relative address (RELADR), relocating address fixup:
* needed.
* 2.There is no need to compare MEMTOP for processing:
* text.
* 3.X register is used as an indexing to zero page va:
* or non-zero page variables.     X=0 means pointing :
* page fariable, whereas X=2 means pointing to zero p:
* variables.
* 4.Each byte of the object text comes in A register.
TEX  EQU *
     LDY LCOUNT ;A register=data coming in
     CPY #$01
     BEQ TEX1 ;if 1, process highest used address
     BCS FTX  ;if 2 or greater, relocate object t:
     STA RELADR
     STA NEWADR  ;for absolute text NEWADR=RELADR
     BCC TEX8
* Set highest used address
TEX1 STA RELADR+1 ;save high byte of RELADR
     STA NEWADR+1 ;for absolute text NEWADR=R:
     LDX #0       ;X=an index to non-zero or :
     LDA HIBYTE   ;HIBYTE=Type ID
     BEQ TEX2     ;if 0, process non-zero pag:
     CMP #$0A
     BEQ TEX3     ;if $0A, needs no relative :
     LDX #2       ;X=2 for zero page text rec:
TEX2 CLC          ;fix relocating addr. for n:
     LDA RELADR   ;text & zero page text
     ADC LOADAD,X ;NEWADR=RELADR+LOADAD
     STA NEWADR
     LDA RELADR+1
     ADC LOADAD+1,X
     STA NEWADR+1 ;Loader start relocating
TEX3 CLC
     LDA NEWADR  ;NEWADR+RECLEN is the last used mem:
     ADC RECLEN  ;for this particular record
     PHA
     LDA #0      ;A=high byte, S=low byte
     ADC NEWADR+1
     TAY ;high byte
     PLA ;low byte
     SEC
     SBC #2 ;skip unwanted 2 bytes of relative :
     BCS TEX4
     DEY
TEX4 PHA
     TYA
     CMP HIUSED+1,X ;HIUSED stores the highest :
     PLA
     BCC TEX6 ;if HIUSED>(NEWADR+RECLEN),:
     BNE TEX5 ;if HIUSED<=(NEWADR+RECLEN)
     CMP HIUSED,X
     BCC TEX6
* Update HIUSED
TEX5 STA HIUSED,X ;update HIUSED
     PHA
     TYA
     STA HIUSED+1,X
     PLA
TEX6 LDX HIBYTE
     CPX #$01
     BEQ TEX8    ;if zero page text
* Check MEMTOP
     CPY MEMTOP+1 ;MEMTOP>HIUSED, OK
     BCC TEX8
     BNE TEX7
     CMP MEMTOP
     BCC TEX8
TEX7 PLA          ;MEMTOP<=HIUSED then error
     PLA          ;do a force return to calle:
     LDY #MEMERR  ;set memory insufficient fl:
TEX8 RTS          ;return

* FTX - Relocate Text into Memory
FTX  EQU *
     SEC
     PHA        ;A register has object text
     LDA LCOUNT ;LCOUNT counts 2 bytes of relative :
     SBC #2     ;-2 is the total bytes of object te:
     CLC
     ADC NEWADR
     STA LTEMP  ;A ===>(NEWADR+LCOUNT-2)
     LDA #0
     ADC NEWADR+1
     STA LTEMP+1
     PLA
     LDY #0
     STA (LTEMP),Y
     JMP TEX8   ;return

* WOR - Handle Word Reference Record Type
* WOR handles record types of
* 1.Non-zero page word references to non-zero page.
* 2.Zero page word references to non-zero page.
* Record format
* |Type|Length  |Offset1|Offset2|Offsetn|
* |ID  |(RECLEN)|A Reg. |       |       |
* Process formula
* (A register +NEWADR)W +LOADAD ===> (NEWADR+ A regis:
* Count, the offset from the start relocating address:
* low byte
* of a word needing to be fixed.  The fixup process i:
* content of the word and add loading address, then r:
* fixed word.
* Offset information comes in A register.
WOR  EQU *
     CLC
     ADC NEWADR    ;offset in A register
     STA LTEMP
     LDA #0
     ADC NEWADR+1
     STA LTEMP+1   ;offset +NEWADR= LTEMP
     LDY #0
     LDA (LTEMP),Y ;get low byte content of wh:
     CLC
     ADC LOADAD    ;fix low byte of a word
     STA (LTEMP),Y
     INC LTEMP     ;increment LTEMP pointer by:
     BNE WOR1      ;if low not zero
     INC LTEMP+1   ;increment high
WOR1 LDA (LTEMP),Y ;fix high byte of a word
     ADC LOADAD+1
     STA (LTEMP),Y ;restore processed content
     RTS

* LOO - Handle Low Byte and One Byte Record Types
* LOO handles record types of
* 1.Non-zero page low byte references to non-zero ppa:
* 2.Zero page low byte references to non-zero page.
* 3.Non-zero page one byte references to zero page.
* 4.Zero page one byte references to zero page.
* Record format
* |Type   |Length         |Offset1|Offset2|Offsetn|
* |ID     |(RECLEN)       |A Reg. |A Reg. |       |
* The process formula for non-zero page low byte refe:
* non-zero page record and zero page low byte referen:
* non-zero page record is
* (offset + NEWADR)+LOADAD ===> (offset +NEWADR)
* The process formula for non-zero page one byte refe:
* zero
* page record and zero page one byte references to ze:
* record
* is
* (offset + NEWADR)+LOADADZ ===> (offset + NEWADR)
* Count from the offset from the start relocating add:
* low byte or one byte need to be fixed. Get the cont:
* low byte or one byteand add either LOADAD or LOADAD:
* page loading address), then restore the value.
* The offset comes in A register.
* The X register for this routine points to either no:
* variables or zero page variables. Record type 2 & 3:
* non-zero page variable, type 4 & 5 needs zero page :
* X=2 points to zero page variable.
LOO  EQU *
     LDX #0     ;X=0 points to non-zero page variab:
     LDY HIBYTE ;HIBYTE has Type ID
     CPY #4     ;type 4 & 5 needs zero page variabl:
     BCC LOO1   ;if type 2 or 3, need non-zero page:
     LDX #2     ;point to zero page variable
LOO1 CLC        ;offset is in A register
     ADC NEWADR ;offset+NEWADR=the byte needs fixup
     STA LTEMP
     LDA #0
     ADC NEWADR+1
     STA LTEMP+1
     LDY #0
     LDA (LTEMP),Y ;get the content of offset+:
     CLC
     ADC LOADAD,X  ;do relocating fixup
     STA (LTEMP),Y ;restore the being fixed va:
     RTS

* HIG - Handle High Byte Record Types
* HIG handles record types of
* 1.Non-zero page high bytes references to non-zero p:
* 2.Zero page high bytes references to non-zero page.
* Record format
* |Type   |Length         |Offset1|Low byte|Offset2|L:
* |ID     |(RECLEN)       |HIBYTE |A Reg.  | (HIBYTE):
* Process formula
* (HIBYTE+NEWADR)+[[LOADAD+A]/256] ==> (HIBYTE+NEWADR:
* Count the offset from the start relocating address :
* byte needs to be fixed. Get the low byte informatio:
* A register, then add the low byte with LOADAD and s:
* flag depending on the calculation. Next do an addit:
* high byte, NEWADR and the C flag. Restore the addit:
* back to the high byte location in memory.
* HIBYTE is not Type ID here. HIBYTE is used to store:
* byte value.
HIG  EQU *
* Initialize
     PHA ;save offset pointing to hi:
* Check LCOUNT odd or even
     LDA LCOUNT
     ROR @
     PLA
     BCS HIG2     ;if even number, process lo:
* Process high byte.
     CLC
     ADC NEWADR
     STA LTEMP    ;get high byte value
     LDA #0
     ADC NEWADR+1
     STA LTEMP+1
     LDY #0
     LDA (LTEMP),Y
     STA HIBYTE   ;save high byte content
HIG1 RTS          ;return
* Process low byte
HIG2 CLC
     ADC LOADAD    ;add low byte with LOADAD
     LDA #0
     ADC LOADAD+1
     ADC HIBYTE    ;C flag+LOADAD(high byte)+H:
     LDY #0
     STA (LTEMP),Y ;store being fixed high byt:
     BEQ HIG1

* TRPR - Table of Record Processing Routines
TRPR DTA A(TEX) ;0 non-zero page relocatable text
     DTA A(TEX) ;1 zero page relocatable text
     DTA A(LOO) ;2 non-zero page low byte to non-:
     DTA A(LOO) ;3 zero page low byte to non-zero:
     DTA A(LOO) ;4 non-zero page one byte to zero:
     DTA A(LOO) ;5 zero page one byte to zero pag:
     DTA A(WOR) ;6 non-zero page word to non-zero:
     DTA A(WOR) ;7 zero page word to non-zero pag:
     DTA A(HIG) ;8 non-zero page high byte to non:
     DTA A(HIG) ;9 zero page high byte to non-zer:
     DTA A(TEX) ;10 absolute text
     DTA A(ERC) ;11 end record
