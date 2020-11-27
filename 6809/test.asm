._CPU = 6809

0xFF00:

top:
    
    LDX   #5
    EXG   A,  B
    PSHS  Y, X, B, A
    PULS  A, B, X, Y, PC

    JMP [0x100]

    NOP

