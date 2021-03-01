._CPU = 6502

.include hardware.asm

0xFFE0:

top:
    LDA    #0xFF             ; All outputs
    STA    RIOT_A_DDR        ; Port A -- outputs
    STA    RIOT_B_DDR        ; Port B -- outputs
    LDA    #0x96             ; 10010110 ...
    STA    RIOT_A_DATA       ; ... to A
    LDA    #0xA5             ; 10100101 ...
    STA    RIOT_B_DATA       ; ... to B

here:
    JMP    here              ; Endless loop

0xFFFA:
    .word  top    ; NMI
    .word  top    ; RESET
    .word  top    ; IRQ
