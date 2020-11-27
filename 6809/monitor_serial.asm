._CPU = 6809

.HELLO = 0xA5  ; Startup value (we are alive)
.ERROR = 0x66  ; Invalid command
.OK    = 0x88  ; OK (write and load)

.STACK = 0x200 ; Builds towards 0x0000

.TMP2  = 0x202 ; Used to combine two bytes ...
.TMP3  = 0x203 ; ... into a word

.include hardware.asm

0xFF00:

top:
    LDS    #STACK           ; Initialize stack

    LDA    #0x7             ; Master reset
    STA    ACI_CONTROL      ; Reset the UART
    LDA    #0x15            ; 8N1 + divide by 16
    STA    ACI_CONTROL      ; Configure communications

main:
    BSR    ReadByte         ; Get the command byte

    DECA                    ; 1 = ...
    BEQ    DoRead           ; ... read byte
    DECA                    ; 2 = ...
    BEQ    DoWrite          ; ... do write
    DECA                    ; 3 = ...
    BEQ    DoLoad           ; ... multi-byte write
    DECA                    ; 4 = ...
    BEQ    DoExec           ; ... execute
    DECA                    ; 5 = ...
    BEQ    DoHello          ; ... return HELLO value

    LDA    #ERROR           ; Return ...
    BSR    SendByte         ; ... error value

    BRA    main             ; Back to top of loop

; 05
DoHello:
    LDA    #HELLO           ; Send the ...
    BSR    SendByte         ; ... hello value
    BRA    main             ; Back to top of loop

; 01 AA AA -> memory[AAAA]
DoRead:
    BSR    ReadWord         ; Get the address ...
    LDX    TMP2             ; ... to X
    LDA    ,X               ; Read memory
    BSR    SendByte         ; Output the value
    BRA    main             ; Back to main loop

; 02 AA AA VV -> OK
DoWrite:
    BSR    ReadWord         ; Get the address ...
    LDX    TMP2             ; ... to X
    BSR    ReadByte         ; Get the value
    STA    ,X               ; Write the value to memory
    LDA    #OK              ; Output ...
    BSR    SendByte         ; ... OK
    BRA    main             ; Back to main loop

; 03 AA AA LL LL vv vv ... -> OK
DoLoad:
    BSR    ReadWord         ; Read the address ...
    LDY    TMP2             ; ... to Y
    BSR    ReadWord         ; Read the count ...
    LDX    TMP2             ; ... to X
load:
    BSR    ReadByte         ; Read the next data byte
    STA    ,Y+              ; Store the data to memory
    LEAX   -1,X             ; All bytes loaded?
    BNE    load             ; No ... go back for them all
    LDA    #OK              ; Output ...
    BSR    SendByte         ; ... OK
    BRA    main             ; Back to main loop

; 04 AA AA
DoExec:
    BSR    ReadWord         ; Get the address to call ...
    LDX    TMP2             ; ... to X
    JMP    ,X               ; Jump to it

ReadWord:
    BSR    ReadByte         ; Get MSB
    STA    TMP2             ; To memory temporary
    BSR    ReadByte         ; Get the length LSB
    STA    TMP2+1           ; To memory temporary
    RTS                     ; Done
    
ReadByte:
    LDA    ACI_CONTROL      ; Data ...
    LSRA                    ; ... available?
    BCC    ReadByte         ; No ... wait
    LDA    ACI_DATA         ; Get the data
    RTS
    
SendByte:
    LDA    ACI_CONTROL      ; Buffer ...
    LSRA                    ; ... is ...
    LSRA                    ; ... full?
    BCC   SendByte          ; Yes ... wait
    STA   ACI_DATA          ; Send the data
    RTS

0xFFF0:
    .word top
    .word top
    .word top
    .word top
    .word top
    .word top
    .word top
    .word top  ; RESET
