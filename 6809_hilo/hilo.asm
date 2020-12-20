._CPU = 6809

.include ../6809/hardware.asm

.STACK      = 0x200    ; Builds towards 0x0000

.guess      = 0x202    ; Player's guess
.compNum    = 0x203    ; Computer's number
.randBCD    = 0x204    ; Random compNum
.prevSwitch = 0x205    ; Previous value read from switches
.tmp1 = 0x206          ; Temporary use
.tmp2 = 0x207          ; Temporary use

0x2000:

   LDS   #STACK        ; Init the stack
   BSR   InitIO        ; Init (and blank) the display
   CLR   prevSwitch    ; Nothing pressed

Top:
   JSR   Splash        ; Splash mode till user presses a button

   LDA   #0x50         ; Start player's guess ...
   STA   guess         ; ... at 50

   LDA   randBCD       ; Hold the ...
   STA   compNum       ; ... computer's number

   JSR   Game          ; Play the game
   BRA   Top           ; New game

InitIO:
; Initialize the HI/LO hardware
; Port A = A_gfedcba
; Port B = 12345_DCB
   LDA   #0            ; Select the ...
   STA   PIA_A_CTRL    ; ... data direction ...
   STB   PIA_B_CTRL    ; ... registers
   LDA   #0xFF         ; Port A is ...
   STA   PIA_A_DATA    ; ... all outputs
   LDA   #0x07         ; Port B is ...
   STA   PIA_B_DATA    ; ... 3 outputs and 5 inputs
   LDA   #4            ; Select the ...
   STA   PIA_A_CTRL    ; ... data ...
   STA   PIA_B_CTRL    ; ... registers
   LDA   #0b1_1111111  ; Blank ...
   STA   PIA_A_DATA    ; ... the ...
   LDA   #0b00000_111  ; ... ...
   STA   PIA_B_DATA    ; ... display
   RTS

SwitchPressed:
; Return switch-pressed transition values (since last read)
; return A pressed switches
   PSHS  B             ; Going to use
   JSR   ReadSwitches  ; Current value of switches
   TFR   A,B           ; Hold for later
   STA   tmp1          ; Hold for later
   EORA  prevSwitch    ; Only keep the changes
   ANDA  tmp1          ; And only new downs
   STB   prevSwitch    ; New previous-value
   PULS  B,PC

DelayEnterAbort:
; Delay with abort-if-enter-pressed
; B = number of inner loops
; return Z=0 if aborted
   PSHS  X,B,A         ; Going to use

del2:
   JSR   SwitchPressed ; Get switch transitions
   ANDA  #0b00100      ; ENTER pressed?
   BNE   deldone       ; Yes ... abort the delay

   LDX   #0x0180       ; Inner delay
del1:
   LDA   randBCD       ; Roll ...
   JSR   IncBCD        ; ... the ...
   STA   randBCD       ; ... random number
   LEAX  -1,X          ; Do inner ...
   BNE   del1          ; ... delay ...
   DECB                ; Do outer...
   BNE   del2          ; ... delay

deldone:
   ; Z=0 if aborted. Z=1 if not aborted.
   PULS  A,B,X,PC      ; Restore and out

Delay:
; Delay
; B = number of inner loops
; return A accumulated switch presses
   PSHS  X,B           ; Going to use
   CLR   tmp1          ; Accumulate switch presses

del22:
   JSR   SwitchPressed ; Get switch transitions
   ORA   tmp1          ; OR them ...
   STA   tmp1          ; ... to return

   LDX   #0x0180       ; Inner delay
del21:
   LDA   randBCD       ; Roll ...
   JSR   IncBCD        ; ... the ...
   STA   randBCD       ; ... random number
   LEAX  -1,X          ; Do inner ...
   BNE   del21         ; ... delay
   DECB                ; Do outer ...
   BNE   del22         ; ... delay
   LDA   tmp1          ; Return accumulated presses
   PULS  B,X,PC        ; Restore and out

Game:
   LDA   guess         ; Write the player's ...
   JSR   WriteBCD      ; ... current value to the display

main2:
   LDA   randBCD       ; Roll ...
   JSR   IncBCD        ; ... the ...
   STA   randBCD       ; ... random number
   JSR   SwitchPressed ; Did the user ...
   CMPA  #0            ; ... press a button?
   BEQ   main2         ; No ... wait (and spin the random)

   CMPA  #0b10000      ; Tens up pressed?
   BHS   onesUp        ; Yes ... handle it
   CMPA  #0b01000      ; Tens down pressed?
   BHS   onesDown      ; Yes ... handle it
   CMPA  #0b00100      ; Enter pressed?
   BHS   enter         ; Yes ... handle it
   CMPA  #0b00010      ; Ones down pressed?
   BHS   tensDown      ; Yes ... handle it
   ; It must be tens up

tensUp:
   LDA   guess         ; Current value
   LDB   #10           ; Increment 10 times
tu1:
   JSR   IncBCD        ; Add one
   DECB                ; Do ...
   BNE   tu1           ; ... all 10
   STA   guess         ; New value
   BRA   Game          ; Update display

tensDown:
   LDA   guess         ; Current value
   LDB   #10           ; Decrement 10 times
td1:
   JSR   DecBCD        ; Subtract one
   DECB                ; Do ...
   BNE   td1           ; ... all 10
   STA   guess         ; New value
   BRA   Game          ; Update display

onesUp:
   LDA   guess         ; Current value
   JSR   IncBCD        ; Add one
   STA   guess         ; New value
   BRA   Game          ; Update display

onesDown:
   LDA   guess         ; Current value
   JSR   DecBCD        ; Subtract one
   STA   guess         ; New value
   BRA   Game          ; Update display

enter:
   LDA   guess         ; Compare player's guess ...
   CMPA  compNum       ; ... to our number
   BEQ   win           ; Same ... win
   BHI   lower         ; Player is higher ... tell them to guess LOWER
   ; Must be lower ... tell them to guess HIGHER

higher:
   LDA   #0xA1         ; "Higher" hint
   BSR   flash         ; Flash the hint
   JMP   Game          ; Back to game loop

lower:
   LDA   #0xB0         ; "Lower" hint
   BSR   flash         ; Flash the hint
   JMP   Game          ; Back to game loop

flash:
   PSHS  X,B,A         ; We'll use these
   STA   tmp2          ; Hold the hint value
   LDX   #2            ; Two flashes
flash1:
   LDA   #0xFF         ; Blank the ...
   JSR   WriteBCD      ; ... display
   LDB   #10           ; Short ...
   JSR   Delay         ; ... delay
   LDA   tmp2          ; Show ...
   JSR   WriteBCD      ; ... hint
   LDB   #20           ; Longer ...
   JSR   Delay         ; ... delay
   LEAX  -1,X          ; Do ...
   BNE   flash1        ; ... all flashes
   LDA   #0xFF         ; Blank the ...
   JSR   WriteBCD      ; ... display
   LDB   #10           ; Short ...
   JSR   Delay         ; ... delay
   PULS  A,B,X,PC      ; Restore and out

win:
   LDA   #0xFF           ; Blank the ...
   JSR   WriteBCD        ; ... display
   LDB   #0x10           ; Short ...
   JSR   DelayEnterAbort ; ... delay
   BNE   windone         ; Enter pressed ... next game
   LDA   guess           ; Show the ...
   JSR   WriteBCD        ; ... winning guess
   LDB   #0x10           ; Short ...
   JSR   DelayEnterAbort ; ... delay
   BEQ   win             ; Enter NOT proessed ... keep flashing
windone:
   JMP   Top             ; Start a new game

Splash:
   LDA   #0xA1           ; H1
   JSR   WriteBCD        ; Write "Hi"
   LDB   #100            ; Delay value
   JSR   DelayEnterAbort ; Delay (or abort)
   BNE   splashdone      ; User pressed ENTER ... we are done
   LDA   #0xB0           ; L0
   JSR   WriteBCD        ; Write "Lo"
   LDB   #100            ; Delay value
   JSR   DelayEnterAbort ; Delay (or abort)
   BEQ   Splash          ; User did not press ENTER ... keep splashing
splashdone:
   RTS                   ; Out

IncBCD:
; Increment the BCD value in A
   PSHS  B             ; We will use these
   TFR   A,B           ; Get ...
   ANDB  #0x0F         ; ... LSD
   LSRA                ; Get ...
   LSRA                ; ... ...
   LSRA                ; ... ...
   LSRA                ; ... MSD
   INCB                ; Add to the lower digit
   CMPB  #0x09         ; Did we carry?
   BLE   INCok         ; No ... keep this number
   LDB   #0            ; Lower digit wraps to 0
   INCA                ; Carry into the upper digit
   CMPA  #0x09         ; Did we carry?
   BLE   INCok         ; No ... keep this number
   LDA   #0            ; Wrap the upper digit
INCok:
   LSLA                ; Move ...
   LSLA                ; ... to ...
   LSLA                ; ... upper ...
   LSLA                ; ... nibble
   STA   tmp1          ; Hold upper
   ORB   tmp1          ; Add in the lower
   TFR   B,A
   PULS  B,PC          ; Restore and out

DecBCD:
; Decrement the BCD value in A
   PSHS  B             ; We will use these
   TFR   A,B           ; Get ...
   ANDB  #0x0F         ; ... LSD
   LSRA                ; Get ...
   LSRA                ; ... ...
   LSRA                ; ... ...
   LSRA                ; ... MSD
   DECB                ; Decrement the lower digit
   CMPB  #255          ; Did we borrow?
   BNE   INCok         ; No borrow ... we are OK
   LDB   #9            ; Wrap to 9
   DECA                ; Borrow from upper digit
   CMPA  #255          ; Did we borrow?
   BNE   INCok         ; No borrow ... we are OK
   LDA   #9            ; Wrap to 9
   BRA   INCok         ; Put the digits back together

WriteBCD:
; Write a BCD number to the display
; A = 2 digit hex number
   PSHS  X,B,A         ; Preserve these
   TFR   A,B           ; Get ...
   ANDB  #0x0F         ; ... LSD
   LSRA                ; Get ...
   LSRA                ; ... ...
   LSRA                ; ... ...
   LSRA                ; ... MSD
   LDX   #Digits       ; Segment patterns
   LDA   A,X           ; Get the raw segment pattern
   BSR   WriteDisplay  ; Draw the display
   PULS  A,B,X,PC      ; Restore and out

 WriteDisplay:
 ; A=MSD (7 segments)
 ; B=LSD (4-bit binary)
   PSHS  B,A
   COMA                ; The 7-seg is active low
   LSLA                ; Everything left 1 bit
   LSRB                ; A bit into carry
   RORA                ; A bit into upper bit
   ANDB  #0x07         ; Only the lower 3 bits matter
   STA   PIA_A_DATA    ; Output the 7 segments + A
   STB   PIA_B_DATA    ; Output BCD
   PULS  A,B           ; Restore and out

ReadSwitches:
; Return switch states in A
   LDA   PIA_B_DATA    ; Read the switches
   LSRA                ; Shift ...
   LSRA                ; ... right ...
   LSRA                ; ... 3 bits
   COMA                ; Buttons are 0 when pressed
   ANDA  #0b000_11111  ; Mask off all but the buttons
   RTS                 ; out

Digits:
;            gfedcba
   .byte 0b0_0111111   ; 0
   .byte 0b0_0000110   ; 1
   .byte 0b0_1011011   ; 2
   .byte 0b0_1001111   ; 3
   .byte 0b0_1100110   ; 4
   .byte 0b0_1101101   ; 5
   .byte 0b0_1111100   ; 6
   .byte 0b0_0000111   ; 7
   .byte 0b0_1111111   ; 8
   .byte 0b0_1100111   ; 9
   .byte 0b0_1110110   ; A   "H"
   .byte 0b0_0111000   ; B   "L"
   .byte 0b0_0000001   ; C
   .byte 0b0_0000010   ; D
   .byte 0b0_0000100   ; E
   .byte 0b0_0000000   ; F   Blank

