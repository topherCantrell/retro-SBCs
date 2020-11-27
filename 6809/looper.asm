
._CPU = 6809

0x1000:
    LDA #0

here:
    DECA
    STA    0x8002

    LDX    #0x100
wait:
    LEAX   -1,X
    BNE    wait

    BRA    here
