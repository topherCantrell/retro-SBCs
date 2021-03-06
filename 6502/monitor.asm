._CPU = 6502

.include hardware.asm

.HELLO = 0xA5  ; Startup value (we are alive)
.POWER = 0xA4  ; Power on value
.ERROR = 0x66  ; Invalid command
.OK    = 0x88  ; OK (write and load)

.TMP1  = 0x82  ; Used to combine 2 nibbles into a byte
.TMP2  = 0x84  ; Used to combine two bytes into a word
.TMP3  = 0x86  ; Used to fill memory

0xFF00:
top:

    LDX    #0xFF            ; Set stack to ...
    TXS                     ; ... 01FF (builds to lower memory)

    JSR    InitHardware     ; RIOT or UART

    LDA    #POWER           ; Initial "hello" ...
    JSR    WriteByte        ; ... value

main:
    JSR    ReadByte         ; Get the command byte
    TAX                     ; A to X so we can DEC

    DEX                     ; 1 = ...
    BEQ    DoRead           ; ... read byte
    DEX                     ; 2 = ...
    BEQ    DoWrite          ; ... do write
    DEX                     ; 3 = ...
    BEQ    DoLoad           ; ... multi-byte write (load)
    DEX                     ; 4 = ...
    BEQ    DoExec           ; ... execute
    DEX                     ; 5 = ...
    BEQ    DoHello          ; ... send back the "hello" value

    LDA    #ERROR           ; Return ...
    JSR    WriteByte        ; ... error value

    JMP    main             ; Back to top of loop

DoHello:
    LDA    #HELLO           ; Send the ...
    JSR    WriteByte        ; ... hello value
    JMP    main             ; Back to the main loop

; 01 AA AA -> memory[AAAA]
DoRead:
    JSR    ReadWord         ; Get the address
    LDY    #0
    LDA    (TMP2),Y         ; Read desired memory address
    JSR    WriteByte        ; Output the value
    JMP    main             ; Back to main loop

; 02 AA AA VV -> OK
DoWrite:
    JSR    ReadWord         ; Read the address
    JSR    ReadByte         ; Value
    LDY    #0
    STA    (TMP2),Y         ; Write desired memory address
    LDA    #OK              ; Output ...
    JSR    WriteByte        ; ... OK
    JMP    main             ; Back to the main loop

; 03 AA AA LL LL vv vv ... -> OK
DoLoad:
    JSR    ReadWord         ; Read the address
    LDA    TMP2             ; Copy ...
    STA    TMP3             ; ... address ...
    LDA    TMP2+1           ; ... to ...
    STA    TMP3+1           ; ... TMP3
    JSR    ReadWord         ; Read the length to TMP2

load:
    JSR    ReadByte         ; Read the next byte
    LDY    #0
    STA    (TMP3),Y         ; Copy it to memory

    INC    TMP3             ; Bump ...
    BNE    load2            ; ... the pointer ...
    INC    TMP3+1           ; ... to memory

load2:
    DEC    TMP2             ; Decrement the count LSB
    BNE    load             ; More to load ... loop back for more
    LDA    TMP2+1           ; Anything to borrow?
    BEQ    load3            ; No? We are done
    DEC    TMP2+1           ; Borrow from MSB
    JMP    load             ; Do all bytes

load3:
    LDA    #OK              ; Output ...
    JSR    WriteByte        ; ... OK
    JMP    main             ; Back to the main loop

; 04 AA AA
DoExec:
    JSR    ReadWord         ; Get the destination
    JMP    (TMP2)           ; Jump to it

ReadWord:
    JSR    ReadByte         ; Get the ...
    STA    TMP2+1           ; ... MSB (6502 is little endian)
    JSR    ReadByte         ; Get the ...
    STA    TMP2             ; ... LSB
    RTS                     ; Done

; --------------------------
; RIOT specific
; --------------------------

;InitHardware:
;	LDA    #0               ; Set port A ...
;    STA    RIOT_A_DDR       ; ... to all inputs
;    LDA    #0xFF            ; Set port A ...
;    STA    RIOT_B_DDR       ; ... to all outputs
;    RTS                     ; Done
;
;WriteByte:
;    STA    RIOT_B_DATA      ; Simple for the PIA
;    RTS                     ; Done
;
;ReadByte:
;    LDA    #0               ; Start with ...
;    STA    TMP1             ; ... zeros
;    LDX    #2               ; 2 nibbles to read
;
;wait1:
;    LDA    RIOT_A_DATA      ; Read the input port
;    AND    #0x80            ; Only the upper bit (the clock)
;    BNE    wait1            ; Wait for clock to go low
;
;    ASL    TMP1             ; Shift ...
;    ASL    TMP1             ; ... over ...
;    ASL    TMP1             ; ... last ...
;    ASL    TMP1             ; ... nibble
;
;    LDA    RIOT_A_DATA      ; Read the input port
;    AND    #0x0F            ; Just the data bits
;    ORA    TMP1             ; OR it into ...
;    STA    TMP1             ; ... the result
;
;wait2:
;    LDA    RIOT_A_DATA      ; Read input port
;    AND    #0x80            ; Wait for clock to ...
;    BEQ    wait2            ; ... go high
;
;    DEX                     ; Both nibbles loaded?
;    BNE    wait1            ; No ... do them both
;
;    LDA    TMP1             ; Return the result
;    STA    RIOT_B_DATA      ; Echo back (for development)
;
;    RTS

; --------------------------
; UART specific
; --------------------------

InitHardware:

    LDA    #0x03            ; Master ...
    STA    UART_CTL         ; ... reset
    LDA    #0x16            ; 8N1, div64
    STA    UART_CTL         ; Configure UART
    RTS                     ; Done

ReadByte:
readu1:
    LDA    UART_CTL         ; Wait ...
    LSR    A                ; ... for ...
    BCC    readu1           ; ... data
    LDA    UART_DATA        ; Get the character
    RTS                     ; Done

WriteByte:
    TAX                     ; Hold outgoing value
writeu1:
    LDA    UART_CTL         ; Buffer ...
    LSR    A                ; ... is ...
    LSR    A                ; ... full?
    BCC    writeu1          ; Yes ... wait
    TXA                     ; Restore outgoing value
    STA    UART_DATA        ; Send the data
    RTS                     ; Done

0xFFFA:
    .word top    ; NMI
    .word top    ; RESET
    .word top    ; IRQ
