._CPU = 6809

.TMP1 = 0x80 ; General purpose 1
.TMP2 = 0x81 ; General purpose 2

0x1000:

; Sum of integers from 1 to A. Return sum in A.
; For instance, sum(5) = 5 + 4 + 3 + 2 + 1 = 15
; We use recursion here knowing these two rules:
;   sum(A) = A + sum(A-1)
;   sum(1) = 1
sum:
    CMPA    #1     ; Is the value 1?
    BEQ    sumout  ; Yes ... that is the result
    STA    ,-S     ; Store the original value in a local
    SUBA   #1      ; Get the sum ...
    JSR    sum     ; ... for one less
    ADDA   ,S+     ; Add sum(X-1) to sum(X) and remove the local
sumout:
    RTS

addout:
    RTS

funcA:
    LDA    #5
    STA    TMP1
    ; ...
    LDA    TMP1
    ADDA   #1
    STA    TMP1
    ; ...
    RTS

funcB:
    LDA    #50
    STA    TMP1
    LDA    #40
    STA    TMP2
    ; ...
    RTS

funcC:
    ; ...
    LDA    #1
    STA    TMP2    ; Using TMP2
    ; ...
    JSR    funcA   ; funcA mangles TMP1
    JSR    funcB   ; funcB mangles TMP1 and TMP2 (oops)
    ; ...
    LDA    TMP2    ; Our value is gone
    ; ...
    RTS


funcD:
    ; ...
    LDA    #5
    STA    ,-S    ; Have to remember which way to go. Stacks decrement.
    ; ...
    LDA    1,S
    ADDA   #1
    STA    1,S
    ; ...
    ;LDA    ,S+    ; Extra step here ... cleaning up the local variable. this form is better if you need the value and you are cleaning up
    ;PULS   A
    LEAS   1,S
    ;
    RTS
