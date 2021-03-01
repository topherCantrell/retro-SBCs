.UART_DATA    = 0x0000
.UART_CTL     = 0x0001

.RIOT_RAM      = 0x0080 ; 80-FF, 128 bytes. Mirrored 180-1FF for stack.

.RIOT_A_DATA   = 0x0280
.RIOT_A_DDR    = 0x0281
.RIOT_B_DATA   = 0x0282
.RIOT_B_DDR    = 0x0283
.RIOT_RO_TIMER = 0x0284
.RIOT_WO_T1    = 0x0294
.RIOT_WO_T8    = 0x0295
.RIOT_WO_T64   = 0x0296
.RIOT_WO_T1024 = 0x0297

.SELECT_IO     = 0x0000
.SELECT_SPARE  = 0x4000
.SELECT_RAM    = 0x8000
.SELECT_ROM    = 0xC000

.VECTOR_NMI   = 0xFFFA
.VECTOR_RESET = 0xFFFC
.VECTOR_IRQ   = 0xFFFE

; Address decode
;
;11_xxxxxx_xxxxxxxx ROM 16K
;10_xxxxxx_xxxxxxxx RAM 16K
;
;01_00xxxx_xxxxxxxx Spare 0 4K
;01_01xxxx_xxxxxxxx Spare 1 4K
;01_10xxxx_xxxxxxxx Spare 2 4K
;01_11xxxx_xxxxxxxx Spare 3 4K
;
;00_xxxxxx_xxxxxxxx I/O (see below)
;
;00_xxxxxx0xxxxxx0 UART Control/Status
;00_xxxxxx0xxxxxx1 UART Transmit/Receive
;
;00_xxxx0x1xxxxxxx RAM (128 bytes)
;
;00_xxxx1x__1xxxx000 Data A
;00_xxxx1x__1xxxx001 DDRA
;00_xxxx1x__1xxxx010 Data B
;00_xxxx1x__1xxxx011 DDRB
;
;00_xxxx1x1xx0x1bc (write) edge detect control
;00_xxxx1x1xxxa1x0 (read) timer
;00_xxxx1x1xxxx1x1 (read) interrupt flags
;00_xxxx1x1xx1a100 (write) div 1T
;00_xxxx1x1xx1a101 (write) div 8T
;00_xxxx1x1xx1a110 (write) div 64T
;00_xxxx1x1xx1a111 (write) div 1024T
