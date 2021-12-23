._CPU = 6809
.STACK = 0x8000
.BUFFER = 0x7E01
.TMP1 = 0x7F00

.include hardware.asm

0x4000:     ; Compiled to RAM (development)
; 0xC000:   ; Compiled to ROM

Top:
    LDS    #STACK      ; Initialize the stack
    JSR    InitUART    ; Initialize the UART

Main:
    JSR    GetInput    ; Get a line of input from the user
    BRA    Main

GetInput:
; Read an input line from the UART. Echo back the chars to the UART.
; Limit the buffer to 256 bytes. Don't backspace before beginning.
    CLR    BUFFER           ; Make a ...
    LDX    #BUFFER+1        ; ... leading 0
InpMain:
    JSR    ReadByte         ; Get the input character
    CMPA   #0x0D             ; Is this CarriageReturn (Windows)?
    BEQ    InpMain          ; Yes ... just ignore those
    CMPA   #0x0A             ; Is this LineFeed?
    BNE    Inp01            ; No ... try others
    CLR    ,X+              ; Null terminate the buffer
    JSR    WriteByte        ; Echo the LineFeed on the terminal
    RTS                     ; Done
Inp01:
    CMPA   #0x08              ; Is this BACKSPACE?
    BNE    Inp02            ; No ... try others
    CMPX   #BUFFER          ; Any characters to remove?
    BEQ    InpMain          ; No ... just ig nore this
    LEAX   -1,X             ; Back up over last character
    JSR    WriteByte        ; Echo the BACKSPACE on the terminal
    BRA    InpMain          ; Continue
Inp02:
    CMPX   #BUFFER+32       ; Is the buffer full (leaving space for NULL)
    BEQ    InpMain          ; Yes ... ignore
    STA    ,X+              ; Add the character to the buffer
    JSR    WriteByte        ; Echo the character on the terminal
    BRA    InpMain          ; Continue

InitUART:
; 8N1@115200
    LDA    #0x7             ; Master reset
    STA    ACI_CONTROL      ; Reset the UART
    LDA    #0x15            ; 8N1 + divide by 16
    STA    ACI_CONTROL      ; Configure communications
    RTS

ReadByte:
; Wait for a byte from the UART.
; Return in A
    LDA    ACI_CONTROL      ; Data ...
    LSRA                    ; ... available?
    BCC    ReadByte         ; No ... wait
    LDA    ACI_DATA         ; Get the data
    RTS

WriteByte:
; Wait for UART to be ready.
; Send byte to UART from A
    PSHS   A                ; Hold the output value
WriteWait:
    LDA    ACI_CONTROL      ; Buffer ...
    LSRA                    ; ... is ...
    LSRA                    ; ... full?
    BCC    WriteWait        ; Yes ... wait
    PULS   A                ; Restore the output value
    STA    ACI_DATA         ; Send the data
    RTS

PrepInput:
    PSHS   X                ; Hold X
    LDX    #BUFFER          ; Start of buffer
PrepInput2:
    LDA    ,X+              ; Next character of input
    BEQ    PrepInDone       ; Null terminator ... done
    CMPA   #0x20             ; Is this a SPACE?
    BNE    PrepInput1       ; No ... skip
    LDA    #0               ; Turn spaces ...
    STA    -1,X             ; ... to nulls
    BRA    PrepInput2       ; Next character
PrepInput1:
    CMPA   #0x61             ; Lower case "a"
    BLO    PrepInput2       ; Not a lower case letter ... continue
    CMPA   #0x7A    ; "z"    ; Lower case "z"
    BHI    PrepInput2       ; Not a lower case letter ... continue
    SUBA   #0x20             ; Convert lower to upper
    STA    -1,X             ; Replace lower with upper
    BRA    PrepInput2       ; Next character
PrepInDone:
    PULS   X,PC             ; Restore X

Strcmp:
; Compare two strings pointed to by X and Y.
; Return Z=1 if the same or Z=0 if different
    PSHS    Y,X         ; Hold X and Y
Next:
    LDA     ,X+         ; Characters ...
    CMPA    ,Y+         ; ... match?
    BNE     Done        ; No ... return with Z=0
    TSTA                ; Is this the end of the string?
    BNE     Next        ; No ... keep checking
    ; Return with Z=1
Done:
   PULS  X,Y,PC

PrintStr:
    LDA    ,X+          ; Next character from string
    BEQ    PrintStr1    ; Null terminator ... done
    JSR    WriteByte    ; Print the character
    BRA    PrintStr     ; Do them all
PrintStr1:
    RTS

S_INFO:
    .byte "INFO",0
S_HELP:
    .byte "HELP",0
S_PEEK:
    .byte "PEEK",0
S_DUMP:
    .byte "DUMP",0
S_POKE:
    .byte "POKE",0
S_EXEC:
    .byte "EXEC",0
S_IN:
    .byte "IN",0
S_OUT:
    .byte "OUT",0
S_LOAD:
    .byte "LOAD",0

PROMPT:
    .byte "> ",0
ERR_COMMAND:
    .byte "UNKNOWN COMMAND",10,0
ERR_INVALID_BYTE:
    .byte "INVALID BYTE: ",0
ERR_INVALID_WORD:
    .byte "INVALID WORD: ",0
ERR_TOO_MANY:
    .byte "TOO MANY VALUES GIVEN",10,0
ERR_TOO_FEW:
    .byte "NOT ENOUGH VALUES GIVEN",10,0

MainLoop:
    LDX     #PROMPT
    JSR     PrintStr
    JSR     GetInput
    TFR     X,U
    JSR     PrepInput
    LDX     #BUFFER
    JSR     FindNextToken
    
    LDY     #S_EXEC
    JSR     Strcmp
    BEQ     CMD_EXEC

    LDY     #S_LOAD
    JSR     Strcmp
    BEQ     CMD_EXEC

    ; ... others ...

    LDX     #ERR_COMMAND      ; Print ...
    JSR     PrintStr          ; ... error message
    BRA     MainLoop          ; Try again

SkipToken:
    LDA     ,X+
    BNE     SkipToken
    RTS

FindNextToken:
; Advance X to the start of the next token and return Z=0
; Return Z=1 if there are no more tokens
    CMPX    #BUFFER+256       ; End of the
    BEQ     FNTnone
    LDA     ,X+
    BEQ     FindNextToken
    RTS
FNTnone:
    ORA     #1
    RTS

CMD_EXEC:
    JSR    SkipToken
    RTS

CMD_LOAD:
    JSR    SkipToken
    RTS

ParseWord:
; X is the buffer

; if starts with 0b ... parse binary
; if starts with 0x ... parse hex
; parse decimal

ParseDecimal:
; Init value to 0
PD1:
; Get character. If 0, return result
; If "_" goto PD1
; Multiply result by 10
; Error if overflow
; Error check character
; character to binary
; add to result
; goto PD1

ParseOUT:
  ;LDD  value
  RTS

ParseBinary:
  LDY #0 ; Init value to 0
PB1:
  LDA ,X+ ; Get character. If 0, return result
  BEQ ParseOUT
  CMPA   #0x5F ; If "_" goto PB1
  BEQ  PB1
; Shift result left 1
; Error if overflow
; Error check character
; character to binary
; add to result
; goto PB1

ParseHex:
; Init value to 0
PH1:
; Get character. If 0, return result
; If "_" goto PH1
; Shift result left 4 bits
; Error if overflow
; Error check character
; character to binary
; add to result
; goto PH1  

; Compiled to ROM
;
;0xFFF0:
;    .word Top
;    .word Top
;    .word Top
;    .word Top
;    .word Top
;    .word Top
;    .word Top
;    .word Top  ; RESET