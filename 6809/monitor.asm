._CPU = 6809

.HELLO = 0xA5  ; Startup value (we are alive)
.ERROR = 0x66  ; Invalid command
.OK    = 0x88  ; OK (write and load)

.STACK = 0x200 ; Builds towards 0x0000

.TMP1  = 0x202 ; Used to combine 2 nibbles into a byte
.TMP2  = 0x204 ; Used to combine to bytes ...
.TMP3  = 0x205 ; ... into a word

; Hardware
.PIA_A_DATA = 0x8000
.PIA_A_CTRL = 0x8001
.PIA_B_DATA = 0x8002
.PIA_B_CTRL = 0x8003

0xFF00:

top:
    LDS    #STACK           ; Initialize stack

    LDA    #0               ; Select ...
    STA    PIA_A_CTRL       ; ... data direction ...
    STA    PIA_B_CTRL       ; ... registers

    STA    PIA_A_DATA       ; Port A is all inputs
    LDA    #0xFF            ; Port B is ...
    STA    PIA_B_DATA       ; ... all outputs

    LDA    #4               ; Select ...
    STA    PIA_A_CTRL       ; ... data ...
    STA    PIA_B_CTRL       ; ... registers

    LDA    #HELLO           ; Initial "hello" ...
    STA    PIA_B_DATA       ; ... value

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
    BEQ    top              ; ... restart (to get the "hello")

    LDA    #ERROR           ; Return ...
    STA    PIA_B_DATA       ; ... error value

    BRA    main             ; Back to top of loop

; 01 AA AA -> memory[AAAA]
DoRead:
    BSR    ReadWord         ; Get the address ...
    LDX    TMP2             ; ... to X
    LDA    ,X               ; Read memory
    STA    PIA_B_DATA       ; Output the value
    BRA    main             ; Back to main loop

; 02 AA AA VV -> OK
DoWrite:
    BSR    ReadWord         ; Get the address ...
    LDX    TMP2             ; ... to X
    BSR    ReadByte         ; Get the value
    STA    ,X               ; Write the value to memory
    LDA    #OK              ; Output ...
    STA    PIA_B_DATA       ; ... OK
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
    STA    PIA_B_DATA       ; ... OK
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
    LDA    #0               ; Start with ...
    STA    TMP1             ; ... zeros
    LDB    #2               ; 2 nibbles to read
    
wait1:
    LDA    PIA_A_DATA       ; Read the input port
    ANDA   #0x80            ; Only the upper bit (the clock)
    BNE    wait1            ; Wait for clock to go low

    ASL    TMP1             ; Shift ...
    ASL    TMP1             ; ... over ...
    ASL    TMP1             ; ... last ...
    ASL    TMP1             ; ... nibble

    LDA    PIA_A_DATA       ; Read the input port
    ANDA   #0x0F            ; Just the data bits
    ORA    TMP1             ; OR it into ...
    STA    TMP1             ; ... the result

wait2:
    LDA    PIA_A_DATA       ; Read input port
    ANDA   #0x80            ; Wait for clock to ...
    BEQ    wait2            ; ... go high
  
    DECB                    ; Both nibbles loaded?
    BNE    wait1            ; No ... do them both
  
    LDA    TMP1             ; Return the result
    STA    PIA_B_DATA       ; Echo back (for development)

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
