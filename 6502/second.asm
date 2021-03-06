._CPU = 6502

.include hardware.asm

0xF000:

    LDX    #0xFF       ; Set stack to ...
    TXS                ; ... 01FF (builds to lower memory)

    LDA    #0xFF       ; Set all ...
    STA    RIOT_A_DDR  ; ... GPIO pins ...
    STA    RIOT_B_DDR  ; ... to be outputs

    LDA    #0x93       ; Test value
    STA    RIOT_A_DATA ; Use a meter to check for 10010011

    LDA    #0xA1       ; Another test value
    JSR    func1       ; Test calling a routine (and coming back)
    JSR    func2       ; Another stack test
    STA    RIOT_B_DATA ; Use a meter to check for 0xA1 + (3 + 5) + 5 = 0xAE = 10101110

here:
    JMP    here        ; Endless loop

func1:
    CLC                ; No previous carry
    ADC    #3          ; Add 3 to A
    JSR    func2       ; Add 5 to A (test a nested call)
    RTS

func2:
    CLC                ; No previous carry
    ADC    #5          ; Add 5 to A
    RTS

0xFFFA:
    .word  0xFF00       ; NMI vector
    .word  0xFF00       ; RESET vector
    .word  0xFF00       ; IRQ vector
