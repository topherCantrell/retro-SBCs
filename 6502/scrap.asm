._CPU = 6502

.include hardware.asm

0x8000:
top:

    LDA    #0xFA
    STA    0x8222
    LDA    #0xCE
    STA    0x8223

done:
    JMP    0xFF00
