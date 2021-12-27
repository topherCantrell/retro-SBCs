; Version 1.0

.include hardware.asm

._CPU = 6809
.STACK = 0x8000              ; Stack at the end of RAM

.BUFFER = 0x7E00             ; 256 bytes for user input including ...
.END_OF_INPUT = 0x7F00       ; ... leading space and null terminator

.VALUE_OVERFLOW = 0x7F02     ; Three bytes ...
.VALUE_UPPER = 0x7F03        ; ... for word ...
.VALUE_LOWER = 0x7F04        ; ... parsing

.TMP1 = 0x7F06
.TMP2 = 0x7F08
.TMP3 = 0x7F0A

;0x4000:                     ; When compiled to RAM (development)
0xC000:                      ; When compiled to ROM

Top:
    LDS    #STACK            ; Initialize the stack
    JSR    UARTInit          ; Initialize the UART
    LDX    #STR_INFO         ; Print info ...
    JSR    PrintStr          ; ... to show we are starting

Main:
    LDX    #PROMPT           ; Print the ...
    JSR    PrintStr          ; ... input prompt
    JSR    GetInput          ; Get a line of input from the user
    STX    END_OF_INPUT      ; This is one past the terminating null
    JSR    PrepInput         ; Tokenize it

    LDX    #BUFFER           ; Start at the beginning of the buffer
    JSR    FindNextToken     ; Get the next token
    BEQ    Main              ; Blank line ... ignore

    LDU    #CommandList      ; List of command names and functions
FC01:
    TFR    U,Y               ; For string-compare
FC02:
    LDA    ,U+               ; Move U ...
    BNE    FC02              ; ... to next ...
    LEAU   2,U               ; ... entry in list
    JSR    StrCompare        ; Is this the command?
    BEQ    DoCommand         ; Yes ... do it
    CMPU   #EndOfCommandList ; No ... have we checked all commands?
    BNE    FC01              ; No ... try the next one
    LDX    #ERR_UNKNOWN      ; Print ...
    JSR    PrintStr          ; ... Unknown Command
    BRA    Main              ; Next command
DoCommand:
    LDY    -2,U              ; Get the command function
    JSR    ,Y                ; Execute the command
    BRA    Main              ; Back for more commands

STR_INFO:
    .byte "68B09 SBC Monitor v1.0",13,10,0

STR_HELP:
    .byte "  # Comment rest of line.",13,10
    .byte "  # Case doesn't matter. Commas are ignored.",13,10
    .byte "  # Underscores in values are ignored.",13,10
    .byte "  # Decimal: 32  Hex: 0xFACE  Binary: 0b11001111",13,10
    .byte "  > INFO",13,10
    .byte "  68B09 SBC Monitor v1.0",13,10
    .byte "  > HELP",13,10
    .byte "  (show this help)",13,10
    .byte "  > PEEK 100",13,10
    .byte "  BB",13,10
    .byte "  > PEEK 100 4",13,10
    .byte "  BB, 22, BB, 22",13,10
    .byte "  > POKE 100 2",13,10
    .byte "  OK",13,10
    .byte "  > POKE 100 2 0x45 0b11_00_1111",13,10
    .byte "  OK",13,10
    .byte "  > LOAD 100 4",13,10
    .byte "  CHECKSUM: 00C6",13,10
    .byte "  > DUMP 0x4005 18",13,10
    .byte "         0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F | 0123456789ABCDEF",13,10
    .byte "  4000:                45 ED 8E 40 49 BD 45 AB 8E 40 9A |      E..@I.E..@.",13,10
    .byte "  4010: BD 45 AB BD 45 2F BF                            | .E..E/.",13,10
    .byte "  > EXEC 100",13,10
    .byte "  BYE",13,10
    .byte 0

CommandList:
    .byte "INFO",0
    .word CMD_INFO
    .byte "HELP",0
    .word CMD_HELP
    .byte "PEEK",0
    .word CMD_PEEK
    .byte "DUMP",0
    .word CMD_DUMP
    .byte "POKE",0
    .word CMD_POKE
    .byte "EXEC",0
    .word CMD_EXEC    
    .byte "LOAD",0
    .word CMD_LOAD
    .byte "FILL",0
    .word CMD_FILL
EndOfCommandList:

PROMPT:
    .byte "> ",0
STR_DUMP_HEAD:
    .byte "       0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F | 0123456789ABCDEF",13,10,0
ERR_NOT_IMPLEMENTED:
    .byte "** NOT IMPLEMENTED **",13,10,0
ERR_UNKNOWN:
    .byte "** UNKNOWN COMMAND **",13,10,0
ERR_INVALID_BYTE:
    .byte "** INVALID BYTE: ",0
ERR_INVALID_WORD:
    .byte "** INVALID WORD: ",0
ERR_END:
    .byte " **",13,10,0
COMMA:
    .byte ", ",0
STR_OK:
    .byte "OK",13,10,0
ERR_TOO_MANY:
    .byte "** TOO MANY PARAMETERS **",13,10,0
ERR_NOT_ENOUGH:
    .byte "** NOT ENOUGH PARAMETERS **",13,10,0
STR_CHK:
    .byte "CHECKSUM: ",0
STR_BYE:
    .byte "BYE",13,10,0
STR_BACK:
    .byte "BACK",13,10,0
STR_COLON:
    .byte ": ",0
STR_SEP:
    .byte "| ",0

ErrInvalidByte: 
    PSHS   X                 ; Hold the pointer to the value
    LDX    #ERR_INVALID_BYTE ; Print the ...
    JSR    PrintStr          ; ... "INVALID: "
ErrInvalidCom:
    PULS   X                 ; Restore pointer to value
    JSR    PrintStr          ; Print the value
    LDX    #ERR_END          ; Print the ...
    JSR    PrintStr          ; ... end of the error message
    RTS

ErrInvalidWord:
    PSHS   X                 ; Hold the pointer to the value 
    LDX    #ERR_INVALID_WORD ; Print the ...
    JSR    PrintStr          ; ... "INVALID"
    JMP    ErrInvalidCom     ; Print the end value and the end of the message

ErrTooMany:
    LDX    #ERR_TOO_MANY     ; Print the ...
    JSR    PrintStr          ; ... error message
    RTS

ErrNotEnough:
    LDX    #ERR_NOT_ENOUGH   ; Print the ...
    JSR    PrintStr          ; ... error message
    RTS

CMD_INFO:
    LDX    #STR_INFO         ; Print the ...
    JSR    PrintStr          ; ... monitor info
    RTS

CMD_HELP:    
    LDX    #STR_HELP         ; Print the ...
    JSR    PrintStr          ; ... help string
    RTS

CMD_PEEK:
; PEEK 0x100 [1]
    JSR    FindNextToken     ; Get the address
    BEQ    ErrNotEnough      ; Error if not given
    JSR    ParseWord         ; Parse the address
    BNE    ErrInvalidWord    ; Error if invalid
    LDD    VALUE_UPPER       ; Hold the ...
    STD    TMP2              ; ... address
    LDB    #1                ; Default number ...
    STB    TMP3              ; ... of peeks
    JSR    FindNextToken     ; Get the count
    BEQ    CMDPEEK01         ; No count ... use default    
    JSR    ParseByte         ; Yes ... parse the count
    BNE    ErrInvalidByte    ; Error if invalid
    LDB    VALUE_LOWER       ; Get the ...
    STB    TMP3              ; Peek count
    JSR    FindNextToken     ; Is there another parameter?
    BNE    ErrTooMany        ; Yes ... error   
CMDPEEK01:
    LDY    TMP2              ; Y has the address
    LDB    TMP3              ; B has the count
CMDPEEK02:
    LDA    ,Y+               ; Get the value from memory
    JSR    PrintByte         ; Print it on the screen
    DECB                     ; All done?
    BEQ    CMDPEEKdone       ; Yes ... out
    LDX    #COMMA            ; Print the ...
    JSR    PrintStr          ; ... ", "
    JMP    CMDPEEK02         ; Do all peeks
CMDPEEKdone:
    JSR    PrintCRLF         ; CRLF
    RTS

CMD_POKE:
; POKE 100 55 [2 4 20 8]
    JSR    FindNextToken     ; Get the address
    BEQ    ErrNotEnough      ; Error if not given
    JSR    ParseWord         ; Parse the address
    LBNE   ErrInvalidWord    ; Error if invalid
    LDY    VALUE_UPPER       ; Get the address
    JSR    FindNextToken     ; Get the 1st poke
    BEQ    ErrNotEnough      ; Error if not given
PokeMore:
    JSR    ParseByte         ; Parse ...
    LBNE   ErrInvalidWord    ; ... the value
    LDA    VALUE_LOWER       ; Store ...
    STA    ,Y+               ; ... the value
    JSR    FindNextToken     ; Next token (if any)
    BNE    PokeMore          ; There is another ... go back
    LDX    #STR_OK           ; Print ...
    JSR    PrintStr          ; ... "OK"
    RTS

CMD_LOAD:
; LOAD 0x100 512
;   ..... data .....
    JSR    FindNextToken     ; Get the address
    LBEQ   ErrNotEnough      ; Error if not given
    JSR    ParseWord         ; Parse the address
    LBNE   ErrInvalidWord    ; Error if invalid
    LDU    VALUE_UPPER       ; Get the address
    JSR    FindNextToken     ; Get the length
    LBEQ   ErrNotEnough      ; Error if not given
    JSR    ParseWord         ; Parse the length
    LBNE   ErrInvalidWord    ; Error if invalid
    LDY    VALUE_UPPER       ; Get the length
    CMPY   #0                ; There must ...
    LBEQ   ErrInvalidWord    ; ... be at least one
    JSR    FindNextToken     ; Make sure there are ...
    LBNE   ErrTooMany        ; ... no more input tokens
    CLR    TMP2              ; Clear the ...
    CLR    TMP2+1            ; ... checksum
LOAD1:
    JSR    UARTRead          ; Get the data byte
    STA    ,U+               ; Store it to memory
    TFR    A,B               ; To LSB of D
    CLRA                     ; MSB of D to 0
    ADDD   TMP2              ; Add to ...
    STD    TMP2              ; ... checksum
    LEAY   -1,Y              ; Do ...
    BNE    LOAD1             ; ... all
    LDX    #STR_CHK          ; Print ...
    JSR    PrintStr          ; ... the ...
    LDD    TMP2              ; ... ...
    JSR    PrintWord         ; ... ...
    JSR    PrintCRLF         ; ... checksum
    RTS

CMD_EXEC:
; EXEC 0x100
    JSR    FindNextToken     ; Get the address
    LBEQ   ErrNotEnough      ; Error if not given
    JSR    ParseWord         ; Parse the address
    LBNE   ErrInvalidWord    ; Error if invalid
    JSR    FindNextToken     ; Make sure there are ...
    LBNE   ErrTooMany        ; ... no more tokens
    LDX    #STR_BYE          ; Tell the user ...
    JSR    PrintStr          ; ... we are leaving
    LDX    VALUE_UPPER       ; Get the address
    JSR    ,X                ; Call it
    LDX    #STR_BACK         ; Tell the user ...
    JSR    PrintStr          ; ... we are back
    RTS

CMD_FILL:
; FILL 0x100 512 00
    JSR    FindNextToken     ; Get the address
    LBEQ   ErrNotEnough      ; Error if not given
    JSR    ParseWord         ; Parse the address
    LBNE   ErrInvalidWord    ; Error if invalid
    LDU    VALUE_UPPER       ; Get the address
    JSR    FindNextToken     ; Get the length
    LBEQ   ErrNotEnough      ; Error if not given
    JSR    ParseWord         ; Parse the length
    LBNE   ErrInvalidWord    ; Error if invalid
    LDY    VALUE_UPPER       ; Get the length
    CMPY   #0                ; There must ...
    LBEQ   ErrInvalidWord    ; ... be at least one
    JSR    FindNextToken     ; Get the value
    LBEQ   ErrNotEnough      ; Error if not given
    JSR    ParseByte         ; Parse ...
    LBNE   ErrInvalidByte    ; ... the value
    JSR    FindNextToken     ; Make sure ...
    LBNE   ErrTooMany        ; ... there are no more
    LDA    VALUE_LOWER       ; The fill value
FILL1:
    STA    ,U+               ; Fill ...
    LEAY   -1,Y              ; ... the ...
    BNE    FILL1             ; ... memory chunk
    LDX    #STR_OK           ; Print ...
    JSR    PrintStr          ; ... "OK"
    RTS

CMD_DUMP:
; DUMP 0x105 16
;       0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F | 0123456789ABCDEF
; 0100 -- -- -- -- -- 10 55 BF C8 00 00 00 DE 21 45 90 |      ..AB0...Y.*
; 0110 A0 A2 B6 00 83 -- -- -- -- -- -- -- -- -- -- -- | UyXK.
    JSR    FindNextToken     ; Get the address
    LBEQ   ErrNotEnough      ; Error if not given
    JSR    ParseWord         ; Parse the address
    LBNE   ErrInvalidWord    ; Error if invalid
    LDU    VALUE_UPPER       ; Get the address
    JSR    FindNextToken     ; Get the length
    LBEQ   ErrNotEnough      ; Error if not given
    JSR    ParseWord         ; Parse the length
    LBNE   ErrInvalidWord    ; Error if invalid
    LDY    VALUE_UPPER       ; Get the length
    CMPY   #0                ; There must ...
    LBEQ   ErrInvalidWord    ; ... be at least one
    JSR    FindNextToken     ; Get the value
    LBNE   ErrNotEnough      ; Error too many
    LDX    #STR_DUMP_HEAD    ; Print the ...
    JSR    PrintStr          ; ... header

    STU    TMP1              ; Hold the starting point    
    STY    TMP2              ; Hold the length
    TFR    U,D               ; Hold ...
    ADDD   TMP2              ; ... the ...
    STD    TMP3              ; ... end point
    TFR    U,D               ; Start on ...    
    CLRB                     ; ... 16 byte ...
    TFR    D,U               ; ... boundary

; Clear the ASCII output buffer
DUMP0:
    LDX    #BUFFER           ; ASCII dump buffer
    LDB    #16               ; 16 to clear in buffer
    LDA    #0x20             ; Space
DUMP1:
    STA    ,X+               ; Clear ...
    DECB                     ; ... the ascii ...
    BNE    DUMP1             ; ... dump buffer
    CLRA                     ; null terminate ...
    STA    ,X                ; ... dump buffer
    TFR    U,D               ; Print the ...
    JSR    PrintWord         ; ... address of the line
    LDX    #STR_COLON        ; Print the ...
    JSR    PrintStr          ; ... colon after address

    LDY    #BUFFER           ; Pointer into dump buffer
    LDB    #16               ; 16 bytes on this line
DUMP2:
    CMPU   TMP1              ; Are we before the requested data?
    BLO    DUMPspace         ; Yes ... print spaces
    CMPU   TMP3              ; Are we after the requested data?
    BHS    DUMPspace         ; Yes ... print spaces
    LDA    ,U+               ; Get the value from memory
    CMPA   #0x20             ; Too low to print?
    BLO    DUMPascdot        ; Yes ... use a dot
    CMPA   #0x7E             ; Too high to print?
    BHI    DUMPascdot        ; Yes ... use a dot
    STA    ,Y+               ; Store the character in the dump buffer
    JSR    PrintByte         ; Print the 2 digit hex
    BRA    DUMP3             ; Continue with next
DUMPascdot:
    JSR    PrintByte         ; Print the 2 digit hex
    LDA    #0x2E             ; Store a dot to represent ...
    STA    ,Y+               ; ... this unprintable
DUMP3:
    LDA    #0x20             ; Space between ...
    JSR    UARTWrite         ; ... bytes
    DECB                     ; Do all ...
    BNE    DUMP2             ; ... 16 on this row
    LDX    #STR_SEP          ; Print the separator ...
    JSR    PrintStr          ; ... before the dump buffer
    LDX    #BUFFER           ; Print the ascii ...
    JSR    PrintStr          ; ... dump buffer
    JSR    PrintCRLF         ; Next line

    CMPU   TMP3              ; Have we reached the end?
    BLO    DUMP0             ; No ... do more lines
    RTS

DUMPspace:            
    LEAU   1,U               ; Next in memory
    LEAY   1,Y               ; Next in the dump buffer
    LDA    #0x20             ; Print ...
    JSR    UARTWrite         ; ... two ...
    JSR    UARTWrite         ; ... spaces
    BRA    DUMP3             ; Continue with the line

ParseByte:
; X is the buffer
    JSR    ParseWord         ; Parse the value
    BNE    PBY1              ; Check for errors
    LDD    VALUE_UPPER       ; Is the value ...
    CMPD   #255              ; ... larger than a byte?
    LBHI   ParseBad          ; Yes ... error
    LBRA   ParseGood         ; No ... OK
PBY1:
    RTS

ParseWord:
; X is the buffer
    PSHS   X                 ; Hold pointer to token
    LDA    ,X                ; Get the ...
    LDB    1,X               ; ... first two characters
    CMPD   #0x3058           ; "0X" ?
    BNE    PW1               ; No ... check for binary
    LEAX   2,X               ; Skip the base marker
    JSR    ParseHex          ; Parse hex value
    PULS   X,PC              ; Restore token
PW1:
    CMPD   #0x3042           ; "0B" ?
    BNE    PW2               ; No ... do decimal
    LEAX   2,X               ; Skip the base marker
    JSR    ParseBinary       ; Parse binary value
    PULS   X,PC              ; Restore token
PW2:
    JSR    ParseDecimal      ; Must be a decimal value
    PULS   X,PC              ; Restore token

ParseHex:
    CLR    VALUE_OVERFLOW    ; Start ...
    CLR    VALUE_UPPER       ; ... with ...
    CLR    VALUE_LOWER       ; ... value = 0
PH1: 
    LDA    ,X+               ; Next text input
    LBEQ   ParseGood         ; End of token ... we have the value
    CMPA   #0x5F             ; Ignore ...
    BEQ    PH1               ; ... underscores
    CMPA   #65               ; Letters A-F?
    BHS    PHletts           ; Yes ... go do those
    CMPA   #0x30             ; Too low?
    LBLO   ParseBad          ; Yes ... not a valid digit
    CMPA   #0x39             ; Too high?
    LBHI   ParseBad          ; Yes ... not a valid digit
    SUBA   #0x30             ; ASCII to number
    BRA    PHdo
PHletts:
    CMPA   #70               ; Too high?
    LBHI   ParseBad          ; Yes ... not a valid digit
    SUBA   #65-10            ; ASCII to number (+10)
PHdo:
    ASL    VALUE_LOWER       ; Now multiplied ...
    ROL    VALUE_UPPER       ; ... by ...
    ROL    VALUE_OVERFLOW    ; ... 2
    ASL    VALUE_LOWER       ; Now multiplied ...
    ROL    VALUE_UPPER       ; ... by ...
    ROL    VALUE_OVERFLOW    ; ... 4
    ASL    VALUE_LOWER       ; Now multiplied ...
    ROL    VALUE_UPPER       ; ... by ...
    ROL    VALUE_OVERFLOW    ; ... 8
    ASL    VALUE_LOWER       ; Now multiplied ...
    ROL    VALUE_UPPER       ; ... by ...
    ROL    VALUE_OVERFLOW    ; ... 16
    TST    VALUE_OVERFLOW    ; Handle ...
    BNE    ParseBad          ; ... overflows
    ADDA   VALUE_LOWER       ; Add in the ...
    STA    VALUE_LOWER       ; ... new lower digit
    BRA    PH1               ; Continue

ParseDecimal:
    CLR    VALUE_OVERFLOW    ; Start ...
    CLR    VALUE_UPPER       ; ... with ...
    CLR    VALUE_LOWER       ; ... value = 0
PD1:
    LDA    ,X+               ; Next text input
    BEQ    ParseGood         ; End of token ... we have the value
    CMPA   #0x5F             ; Ignore ...
    BEQ    PD1               ; ... underscores
; Check the value and convert from ASCII
    CMPA   #0x30             ; Too low?
    BLO    ParseBad          ; Yes ... not a valid digit
    CMPA   #0x39             ; Too high?
    BHI    ParseBad          ; Yes ... not a valid digit
    SUBA   #0x30             ; ASCII to number
; Multiply value by 10
    STA    TMP1              ; Hold the new digit number
    LDD    VALUE_UPPER       ; Hold the value to add for *5
    ;
    ASL    VALUE_LOWER       ; Now multiplied ...
    ROL    VALUE_UPPER       ; ... by ...
    ROL    VALUE_OVERFLOW    ; ... 2        
    ;
    ASL    VALUE_LOWER       ; Now multiplied ...
    ROL    VALUE_UPPER       ; ... by ...
    ROL    VALUE_OVERFLOW    ; ... 4    
    ;
    ANDCC  #0b11111110       ; Clear the carry
    ADCB   VALUE_LOWER       ; Add to original to ...
    ADCA   VALUE_UPPER       ; ... make times 5
    ROL    VALUE_OVERFLOW    ; Shift any carry into the overflow
    STD    VALUE_UPPER       ; Now times 5
    ;
    ASL    VALUE_LOWER       ; Now multiplied ...
    ROL    VALUE_UPPER       ; ... by ...
    ROL    VALUE_OVERFLOW    ; ... 10    
    ;
    TST    VALUE_OVERFLOW    ; Catch overflows ...
    BNE    ParseBad          ; ... from the multiply
; Add in the new lower digit
    CLRA                     ; The new ...  
    LDB    TMP1              ; ... lower digit    
    ANDCC  #0b11111110       ; Clear the carry
    ADCB   VALUE_LOWER       ; Add in ...
    ADCA   VALUE_UPPER       ; ... the new lower digit    
    STD    VALUE_UPPER       ; The new value
    BCC    PD1               ; Catch overflow or keep going
ParseBad:
    ANDCC  #0b11111011       ; Z=0 ... BAD VALUE
    RTS
ParseGood:
    ORCC   #0b00000100       ; Z=1 ... GOOD VALUE
    RTS

ParseBinary:
    CLR    VALUE_OVERFLOW    ; Start ...
    CLR    VALUE_UPPER       ; ... with ...
    CLR    VALUE_LOWER       ; ... value = 0
PB1:
    LDA    ,X+               ; Next text input
    BEQ    ParseGood         ; End of token ... we have the value
    CMPA   #0x5F             ; Ignore ...
    BEQ    PB1               ; ... underscores
; Check the value and convert from ASCII
    CMPA   #0x30             ; Too low?
    BLO    ParseBad          ; Yes ... not a valid digit
    CMPA   #0x31             ; Too high?
    BHI    ParseBad          ; Yes ... not a valid digit
    SUBA   #0x30             ; ASCII to number
    ASL    VALUE_LOWER       ; Now multiplied ...
    ROL    VALUE_UPPER       ; ... by ...
    ROL    VALUE_OVERFLOW    ; ... 2
    TST    VALUE_OVERFLOW    ; Handle ...
    BNE    ParseBad          ; ... overflows
    ADDA   VALUE_LOWER       ; Add in the ...
    STA    VALUE_LOWER       ; ... new low bit
    BRA    PB1               ; Do them all

FindNextToken:
    CMPX   END_OF_INPUT      ; End of buffer?
    BEQ    FNT02             ; Return Z=1 ... no more
    LDA    ,X                ; Find the end ...
    BEQ    FNT01             ; ... of the ...
    LEAX   1,X               ; ... current ...
    BRA    FindNextToken     ; ... token
FNT01:
    CMPX   END_OF_INPUT      ; End of buffer?
    BEQ    FNT02             ; Return Z=1 ... no more
    LDA    ,X                ; Find the start ...
    BNE    FNT02             ; ... of the ...
    LEAX   1,X               ; ... next ...
    BRA    FNT01             ; ... token
FNT02:
    RTS                      ; Done (Z=1 for NO MORE or Z=0 for FOUND)

GetInput:
; Read an input line from the UART. Echo back the chars to the UART.
; Limit the buffer to 256 bytes. Don't backspace before beginning.
    LDX    #BUFFER           ; Make ...
    LDA    #0x20             ; ... a leading ...
    STA    ,X+               ; ... space
InpMain:
    JSR    UARTRead          ; Get the input character
    CMPA   #0x0D             ; Is this ENTER key?
    BNE    Inp01             ; No ... process it    
    CLR    ,X+               ; Null terminate the buffer    
    JSR    UARTWrite         ; Send a return
    LDA    #0x0A             ; Send a ...
    JSR    UARTWrite         ; ... new-line to terminal
    RTS                      ; Done
Inp01:
    CMPA   #0x08             ; Is this BACKSPACE?
    BNE    Inp02             ; No ... try others
    CMPX   #BUFFER+1         ; Any characters to remove?
    BEQ    InpMain           ; No ... just ignore this
    LEAX   -1,X              ; Back up over last character
    JSR    UARTWrite         ; Echo the BACKSPACE on the terminal
    BRA    InpMain           ; Continue
Inp02:
    CMPX   #BUFFER+255       ; Is the buffer full? (leaving space for trailing NULL)
    BEQ    InpMain           ; Yes ... ignore
    STA    ,X+               ; Add the character to the buffer
    JSR    UARTWrite         ; Echo the character on the terminal
    BRA    InpMain           ; Continue

PrepInput:
    PSHS   X                 ; Hold X
    LDX    #BUFFER           ; Start of buffer
PrepInput2:
    LDA    ,X+               ; Next character of input
    BEQ    PrepInDone        ; Null terminator ... done
    CMPA   #0x23             ; "#" comment?
    BNE    PrepInput2b       ; No ... keep going
    LDA    #0                ; Null terminate ...
    STA    -1,X              ; ... to here
    STX    END_OF_INPUT      ; Line ends at comment
    BRA    PrepInDone        ; Done
PrepInput2b:
    CMPA   #0x20             ; Is this a SPACE?
    BNE    PrepInput1        ; No ... skip
    LDA    #0                ; Turn spaces ...
    STA    -1,X              ; ... to nulls
    BRA    PrepInput2        ; Next character
PrepInput1:
    CMPA   #0x2C             ; Is this a comma?
    BNE    PrepInput1b       ; No ... skip
    LDA    #0                ; Turn commas ...
    STA    -1,X              ; ... to nulls
    BRA    PrepInput2        ; Next character
PrepInput1b:
    CMPA   #0x61             ; Lower case "a"
    BLO    PrepInput2        ; Not a lower case letter ... continue
    CMPA   #0x7A    ; "z"    ; Lower case "z"
    BHI    PrepInput2        ; Not a lower case letter ... continue
    SUBA   #0x20             ; Convert lower to upper
    STA    -1,X              ; Replace lower with upper
    BRA    PrepInput2        ; Next character
PrepInDone:
    PULS   X,PC              ; Restore X

StrCompare:
; Compare two strings pointed to by X and Y.
; Return Z=1 if the same or Z=0 if different
    PSHS   Y,X               ; Hold pointers
Next:
    LDA    ,X+               ; Characters ...
    CMPA   ,Y+               ; ... match?
    BNE    Done              ; No ... return with Z=0
    TSTA                     ; Is this the end of the string?
    BNE    Next              ; No ... keep checking
    ; Return with Z=1
Done:
   PULS    X,Y,PC
   
PrintStr:
    PSHS   X                 ; Hold X
PrintStr2:
    LDA    ,X+               ; Next character from string
    BEQ    PrintStr1         ; Null terminator ... done
    JSR    UARTWrite         ; Print the character
    BRA    PrintStr2         ; Do them all
PrintStr1:
    PULS   X,PC              ; Restore X

PrintCRLF:
    LDA    #0x0D             ; Print the ...
    JSR    UARTWrite         ; ... CR
    LDA    #0x0A             ; Print the ...
    JSR    UARTWrite         ; ... LF
    RTS    
    
PrintWord:
    JSR    PrintByte         ; Print the upper 2 digits
    TFR    B,A               ; Print ...
    JSR    PrintByte         ; ... the lower 2 digits
    RTS

PrintByte:
    PSHS   A                 ; Hold the lower digit
    LSRA                     ; Print ...
    LSRA                     ; ... the ...
    LSRA                     ; ... upper ... 
    LSRA                     ; ... ...
    JSR    PrintDigit        ; ... digit
    PULS   A                 ; Restore the lower
    JSR    PrintDigit        ; Print the lower digit
    RTS

PrintDigit:
    ANDA   #0x0F             ; Just one digit
    CMPA   #10               ; Hex letter?
    BHS    PD01              ; Yes ... go do that
    ADDA   #0x30             ; No ... offset from ascii "0"
    JSR    UARTWrite         ; Print the digit
    RTS
PD01:
    ADDA   #65-10            ; Offset from ascii "A"
    JSR    UARTWrite         ; Print the digit
    RTS

UARTInit:
; 8N1@115200
    LDA    #0x7              ; Master reset
    STA    ACI_CONTROL       ; Reset the UART
    LDA    #0x15             ; 8N1 + divide by 16
    STA    ACI_CONTROL       ; Configure communications
    RTS

UARTRead:
; Wait for a byte from the UART.
; Return in A
    LDA    ACI_CONTROL       ; Data ...
    LSRA                     ; ... available?
    BCC    UARTRead          ; No ... wait
    LDA    ACI_DATA          ; Get the data
    RTS

UARTWrite:
; Wait for UART to be ready.
; Send byte to UART from A
    PSHS   A                 ; Hold the output value
WriteWait:
    LDA    ACI_CONTROL       ; Buffer ...
    LSRA                     ; ... is ...
    LSRA                     ; ... full?
    BCC    WriteWait         ; Yes ... wait
    PULS   A                 ; Restore the output value
    STA    ACI_DATA          ; Send the data
    RTS

; When compiled to ROM
;
0xFFF0:
    .word Top
    .word Top
    .word Top
    .word Top
    .word Top
    .word Top
    .word Top
    .word Top  ; RESET