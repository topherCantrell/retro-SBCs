._CPU = 6809

.include hardware.asm

0x4000:
    LDA    #0
here:
    BSR    WriteByte
    INCA 
    BRA    here
    
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

