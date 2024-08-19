
# Schematic

Click for [Schematics](/6502/SCHEMATICS.md)

# Address Decoding

```
## 6850ACIA

A14, A15 = 00

00_xxxxxx_0xxxxxx0 UART Control/Status
00_xxxxxx_0xxxxxx1 UART Transmit/Receive

## 6532 RIOT

A14, A15 = 00

00_xxxx0x_1xxxxxxx RAM (128 bytes)
00_xxxx1x_1xxxx000 Data A
00_xxxx1x_1xxxx001 DDRA
00_xxxx1x_1xxxx010 Data B
00_xxxx1x_1xxxx011 DDRB
;
00_xxxx1x_1xx0x1bc (write) edge detect control
00_xxxx1x_1xxxa1x0 (read) timer
00_xxxx1x_1xxxx1x1 (read) interrupt flags
00_xxxx1x_1xx1a100 (write) div 1T
00_xxxx1x_1xx1a101 (write) div 8T
00_xxxx1x_1xx1a110 (write) div 64T
00_xxxx1x_1xx1a111 (write) div 1024T

## Spare decoding

A14, A15 = 01
Then A12 and A13 is demuxed.

01_00xxxx_xxxxxxxx Spare 0 4K
01_01xxxx_xxxxxxxx Spare 1 4K
01_10xxxx_xxxxxxxx Spare 2 4K
01_11xxxx_xxxxxxxx Spare 3 4K

## RAM

A14, A15 = 10

10_xxxxxx_xxxxxxxx RAM 16K

## ROM

A14, A15 = 11

11_xxxxxx_xxxxxxxx ROM 16K

```

# Memory Map from Above Decoding

In the Atari2600, the 128 bytes of RIOT memory was the only built-in RAM (many cartridges contained additional RAM).

See the simple [Atari2600 schematics here](/atari2600/Hardware.jpg).

The 6502 instruction set uses includes index modes that use the first 256 bytes of RAM. The 6502 stack pointer is
a 8-bit register with the upper word fixed to "0100". Thus the second 256 bytes of RAM is where the stack lives.

The Atari 2600 mapped the RIOT chip RAM in the first page of RAM from "0080-00FF". This same 128 bytes of memory
ghosts to "0180-01FF" for the stack. But it is the same memory.

My board uses the same mapping/ghosting to the RIOT as the Atari2600 -- for nostalgia sake. The large 4K RAM area is 
mapped to higher memory.

```
0000        UART Control/Status
0001        UART Transmit/Receive
;
0080 - 00FF RAM
0180 - 01FF RAM mirror (stack)
;
0280        Data A
0281        DDRA
0282        Data B
0283        DDRB
;
0284        Timer output (read only)
0294        Set 1 clock interval (write only)
0295        Set 8 clock interval (write only)
0296        Set 64 clock interval (write only)
0297        Set 1024 clock interval (write only)
;
4000 - 7FFF Spare select space (4xxx, 5xxx, 6xxx, 7xxx)
;
8000 - BFFF RAM
;
C000 - FFFF ROM
;
FFFA - FFFB NMI   Interrupt vector
FFFC - FFFD RESET Interrupt vector
FFFE - FFFF IRQ   Interrupt vector
```

# Software
  - [hardware.asm](hardware.asm) - include file defines for the hardware
  - [first.asm](first.asm) - simple program to write to the I/O ports (test with a meter)
  - [second.asm](second.asm) - I/O test but uses the stack to test RAM
  - [monitor.asm](monitor.asm) - binary serial monitor program (requires external control program)