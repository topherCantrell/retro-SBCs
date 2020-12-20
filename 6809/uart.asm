._CPU = 6809

.include hardware.asm

0x1000:

    LDA    #0x7             ; Master reset
    STA    ACI_CONTROL      ; Reset the UART
    LDA    #0x15            ; 8N1 + divide by 16
    STA    ACI_CONTROL      ; Configure communications

top:
    BSR  ReadByte
    DECA
    BSR  WriteByte
    BRA  top

ReadByte:
    LDA    ACI_CONTROL      ; Data ...
    LSRA                    ; ... available?
    BCC    ReadByte         ; No ... wait
    LDA    ACI_DATA         ; Get the data
    RTS

WriteByte:
    PSHS   A                ; Hold the output value
WriteWait:
    LDA    ACI_CONTROL      ; Buffer ...
    LSRA                    ; ... is ...
    LSRA                    ; ... full?
    BCC    WriteWait        ; Yes ... wait
    PULS   A                ; Restore the output value
    STA    ACI_DATA         ; Send the data
    RTS

delay_ms:
    LDA  #0x4
    PSHS X
delay2:
    LDX  #0x0
delay1:
    LEAX -1,X
    BNE  delay1
    DECA
    BNE  delay2
    PULS X,PC
