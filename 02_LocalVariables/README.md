Need more scratch space than registers. Spills over into RAM.

We use the memory, but only during the call. We initialize it as part of our function.
There is no lasting value we expect to persist. We call this a "local variable" because
its value is only valid during the call. 

Memory is precious. We can reuse these "general purpose" variables in other functions.

```
._CPU = 6809

.TMP1 = 0x80 ; General purpose 1
.TMP2 = 0x81 ; General purpose 2

0x1000:

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
```

We end up making a list like this:
  - funcA uses TMP1
  - funcB uses TMP1 and TMP2
  - funcC uses TMP2
  - funcD uses TMP3
  
When we call a function, we have to make sure the subroutine doesn't change our variables.

```
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
```

Tell this story from Greg and Linda's point of view.

For instance, we are funcC. We are using TMP2 and can call funcA without fear since funcA doesn't use TMP2. But
then we call funcB. The funcB mangles the TMP2 value. It no longer contains the value we were using.

This gets tricky to keep track of through nested calls. FuncF is using TMP1, but funcF only calls funcA. FuncA doesn't 
use TMP1 directly, but funcA calls D, E, and F. Inside E, it calls X and Y, and Y calls Z. Do any of these
other functions use TMP1?

TODO call graph picture

When Linda modifies function Y a year from now so that it does use TMP1, how does Greg know that funcF is now broken.

We can keep locals on the stack. This makes sense as the storage comes and goes with our return address.

TODO picture of stack frames ... this kind of stack frame is all modern languages (C/C++, Java, Python, etc)

```
funcD:
    ; ...
    LDA    #5
    STA    ,-S    ; Have to remember which way to go. Stacks decrement.
    ; ...
    LDA    1,S
    ADDA   #1
    STA    1,S
    ; ...
    ;LDA    ,S+    ; Extra step here ... cleaning up the local variable
    ;PULS   A
    LEAS   1,S
    ;
    RTS
```

Instructions are more complex. Compare A to D:

```
                  funcA:
1000: 86 05            LDA    #5
1002: 97 80            STA    TMP1    ; 4 cycles
                  ; ...
1004: 96 80            LDA    TMP1    ; 4 cycles
1006: 8B 01            ADDA   #1
1008: 97 80            STA    TMP1    ; 4 cycles
                  ; ...
100A: 39               RTS

                  funcD:
                  ; ...
1021: 86 05            LDA    #5
1023: A7 E2            STA    ,-S    ; 4 + 2 cycles
                  ; ...
1025: A6 61            LDA    1,S    ; 4 + 1 cycles
1027: 8B 01            ADDA   #1
1029: A7 61            STA    1,S
                  ; ...
                  ; Extra step here ... cleaning up the local variable
                  ;LDA    ,S+        ; 4 + 2 Faster if you need the value instead of loading then changing S separately
                  ;PULS   A          ; 5 + 1 These forms take longer because of the value fetch to A
102B: 32 61            LEAS   1,S    ; 4 + 1
                  ;
102D: 39               RTS
                  
                  funcD:
                  ; ...
1021: 86 05            LDA    #5
1023: A7 E2            STA    ,-S     ; 4 + 2
                  ; ...
1025: A6 61            LDA    1,S     ; 4 + 1
1027: 8B 01            ADDA   #1
1029: A7 61            STA    1,S     ; 4 + 1
                  ; ...
102B: A6 E0            LDA    ,S+     ; 4 + 2
102D: 35 02            PULS   A       ; 5 + 1
102F: 32 61            LEAS   1,S     ; 4 + 1
                  ;
1031: 39               RTS
```

The "using" code "STA 1,S" might be in a loop. The +1 cycle is dominant in the time calc. then

Stack lets us call ourselves ... recursively. Each call gets a new local variable. TODO show stack frame for:

```
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
```

Stack overflow. Do some calculations for how much 255 eats up (3 * 255 ... more stack space than possible on the 6502 limited to 256 bytes).

6809 has these wonderful addressing modes to make this easier. More tedious on other processors. Especially the 6502 with no 16 bit regs.
