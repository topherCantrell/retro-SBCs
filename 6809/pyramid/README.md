
# ROM calls in the code

Patch these replacing "A0xx" with "40xx".

```
093C: AD 9F A0 00         JSR     [POLCAT]                  ; Get a key (or 0 if none)
;
0965: AD 9F A0 02         JSR     [CHROUT]                  ; Print A to screen
;
0976: AD 9F A0 02         JSR     [CHROUT]                  ; ... to screen
099C: AD 9F A0 02         JSR     [CHROUT]                  ; Print A to screen on new line
09A4: AD 9F A0 02         JSR     [CHROUT]                  ; ... to ...
;
; No tape function for now. Maybe one day.
0E92: AD 9F A0 0C         JSR     [WRTLDR]                  ; Turn on cassette and write leader
0EA3: AD 9F A0 08         JSR     [BLKOUT]                  ; Write to tape
0EB1: AD 9F A0 08         JSR     [BLKOUT]                  ; Write to tape
0ECC: AD 9F A0 04         JSR     [CSRDON]                  ; Start cassette and sync
0EDD: AD 9F A0 06         JSR     [BLKIN]                   ; Read from tape
0EED: AD 9F A0 06         JSR     [BLKIN]                   ; Read from tape
```

No need for <MORE> prompt. NOP out any code that reads/uses 0x01B0 (m01B0).

```
; Change to 2B to 21 (LBMI to LBRN)
09AE: 10 2B FF 6C         LBMI    MorePrompt                ; Yes ... do it and out
```

CHROUT must scroll the coco screen memory as expected. Use the actual code.

0x60 is space character.

```

; Cursor to start of last line on screen
061A: 8E 05 E0            LDX     #$05E0                    ; Cursor ...
061D: 9F 88               STX     <cursor                   ; ... position

; Will never hit this with MORE disabled
092E: 9E 88               LDX     <cursor                   ; Back pointer ...
0930: 30 19               LEAX    -7,X                      ; ... up 7 over ...
0932: 9F 88               STX     <cursor                   ; ... MORE prompt

; This needs to be a routine that prints a backspace and does this.
095C: DE 88               LDU     <cursor                   ; Back screen ...
095E: 33 5F               LEAU    -1,U                      ; ... pointer up ...
0960: DF 88               STU     <cursor                   ; ... over ignored space

0969: 96 89               LDA     <cursor+1                 ; LSB of screen position (we know MSB is a 4 or 5)
096B: 81 FE               CMPA    #$FE                      ; Have we reached the end of the screen?
096D: 25 3C               BCS     $09AB                     ; No ... handle any MORE and out
096F: DE 88               LDU     <cursor                   ; Cursor position
0971: 33 C8 DF            LEAU    $-21,U                    ; Back up to end of current row (where it will be after CR)
0974: 86 0D               LDA     #$0D                      ; CR ...
0976: AD 9F A0 02         JSR     [CHROUT]                  ; ... to screen

; Cursor block (on and off) ... ignore this for now
0A0E: A7 9F 00 88         STA     [cursor]                  ; Store to cursor

```