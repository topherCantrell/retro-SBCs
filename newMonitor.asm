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
    LDX    #TESTSTR
    JSR    PrintStr
    LDX    #BUFFER+1
    JSR    PrintStr
    LDX    #TESTSTR
    JSR    PrintStr
    BRA    Main

GetInput:
; Read an input line from the UART. Echo back the chars to the UART.
; Limit the buffer to 256 bytes. Don't backspace before beginning.
    CLR    BUFFER           ; Make a ...
    LDX    #BUFFER+1        ; ... leading 0
InpMain:
    JSR    ReadByte         ; Get the input character
    CMPA   #0x0D            ; Is this ENTER key?
    BNE    Inp01            ; No ... process it    
    CLR    ,X+              ; Null terminate the buffer    
    JSR    WriteByte        ; Send a return
    LDA    #0x0A            ; Send a ...
    JSR    WriteByte        ; ... new-line to terminal
    RTS                     ; Done
Inp01:
    CMPA   #0x08            ; Is this BACKSPACE?
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

PrintStr:
    LDA    ,X+          ; Next character from string
    BEQ    PrintStr1    ; Null terminator ... done
    JSR    WriteByte    ; Print the character
    BRA    PrintStr     ; Do them all
PrintStr1:
    RTS

TESTSTR:
    .byte  "Hello",13,10,0

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

