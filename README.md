# retro-boards

Single-board 6809, Z80, 6502, etc

# Monitor Program

```
> INFO
6809B SBC ver 1.21.2

> HELP
(lots of spew here)

> PEEK 1024
5F

> PEEK 0x400 4
5F 60 7B 11

> DUMP 0x40D 5
      00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
0400: -- -- -- -- -- -- -- -- -- -- -- -- -- 12 7F 00
0410: 02 85 -- -- -- -- -- -- -- -- -- -- -- -- -- --

> POKE 0x400 0b11_00_11_00
OK

> POKE 0x400 10 20 55 60 88
OK

> LOAD 0x400 255
(...255 bytes read from stream)
CHK 17D

> EXEC 49152
BYE
```

Case is ignored. Commas are converted to spaces (allows for things like `POKE 10 1,2,3,4`). Underscores "_" in constants are ignored.

Value bases:
- `1234` decimal
- `0xBEEF` hex
- `0b11001111` binary 

Error message examples:

```
- UNKNOWN COMMAND
- INVALID BYTE: 1B77
- INVALID WORD: hello
- TOO MANY VALUES GIVEN
- NOT ENOUGH VALUES GIVEN
```
