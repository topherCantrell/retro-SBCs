; PIA
.PIA_A_DATA = 0x8000  ; 100x_xxxx_xxxx_xx00
.PIA_A_CTRL = 0x8001  ; 100x_xxxx_xxxx_xx01
.PIA_B_DATA = 0x8002  ; 100x_xxxx_xxxx_xx10
.PIA_B_CTRL = 0x8003  ; 100x_xxxx_xxxx_xx11
; TODO: bit breakdowns of control

; ACI
.ACI_CONTROL = 0xA000  ; 101x_xxxx_xxxx_xxx0
.ACI_DATA = 0xA001     ; 101x_xxxx_xxxx_xxx1
; Write to control:
;   I_TT_WWW_CC
;   I =   0: receive interrupt disabled
;         1: receive interrupt enabled
;   T =  00: RTS=low, transmit interrupt disabled
;        01: RTS=low, transmit interrupt enabled
;        10: RTS=high, transmit interrupt disabled
;        11: RTS=low, transmit a break, transmit interrupt disabled
;   W = 000: 7E2
;       001: 7O2
;       010: 7E1
;       011: 7O1
;       100: 8N2
;       101: 8N1
;       110: 8E1
;       111: 8O1
;   C =  00: divide by 1
;        01: divide by 16
;        10: divide by 64
;        11: master reset
; Read from control:
;  bit
;   0 = 1: receive data register full (1 means you can read)
;   1 = 1: transmit data register empty (1 means you can write)
;   2 = 1: data carrier detect
;   3 = 1: clear to send
;   4 = 1: framing error
;   5 = 1: receiver overrun
;   6 = 1: parity error
;   7 = 1: interrupt request
;
; For my environment: 0_00_101_01
;   I =   0: Receive interrupts off
;   T =  00: Transmit interrupt off
;   W = 101: 8N1
;   C =  01: Divide by 16 (115200)

; ROM vectors:
; 0xFFF0:
;    .word ????  ; FFF0: 6809 exceptions
;    .word ????  ; FFF2: SWI3
;    .word ????  ; FFF4: SWI2
;    .word ????  ; FFF6: FIRQ
;    .word ????  ; FFF8: IRQ
;    .word ????  ; FFFA: SWI
;    .word ????  ; FFFC: NMI
;    .word ????  ; FFFE: RESET
