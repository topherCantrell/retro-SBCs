._CPU = 6809

.STACK = 0x800
.TMP1 = 0x200
.TMP2 = 0x202
.HELLO = 0xA5

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
    JSR    ReadByte
    DECA
    BEQ    DoLoad

    LDA    #0x66
    STA    PIA_B_DATA
    JMP    main

DoLoad:

    JSR    ReadByte
    STA    TMP2
    JSR    ReadByte
    STA    TMP2+1

    LDX    TMP2

    JSR    ReadByte
    STA    TMP2
    JSR    ReadByte
    STA    TMP2+1

    LDY    TMP2

load:
    JSR    ReadByte
    STA    ,Y+
    LEAX   -1,X
    BNE    load

    LDA    #EXEC
    STA    PIA_B_DATA

    LDY    TMP2

    JMP    ,Y
    
ReadByte:
    LDA    #0                ; Start with ...
    STA    TMP1
    LDB    #2
    
wait1:
    LDA    PIA_A_DATA
    ANDA   #0x80
    BNE    wait1

    ASL    TMP1
    ASL    TMP1
    ASL    TMP1
    ASL    TMP1

    LDA    PIA_A_DATA
    ANDA   #0x0F
    ORA    TMP1
    STA    TMP1

wait2:
    LDA    PIA_A_DATA
    ANDA   #0x80
    BEQ    wait2

    DECB
    BNE    wait1

    LDA    TMP1
    STA    PIA_B_DATA

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
