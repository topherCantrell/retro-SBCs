# retro-boards

Single-board 6809, Z80, 6502, etc

# Monitor Program

```
# This is a comment line in case you ever need comments

> INFO
6809B SBC ver 1.21.2

> HELP   # Help is little more than example commands (like below)
(lots of spew here)

> PEEK 1024       # Read a single byte from memory
5F

> PEEK 0x400 4    # Read 4 bytes of memory starting at 0x400
5F 60 7B 11

> DUMP 0x40D 5    # Memory dump format 5 bytes of memory starting at 40D
      00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F | ASCII
0400: -- -- -- -- -- -- -- -- -- -- -- -- -- 12 30 00 |              ...
0410: 38 5B -- -- -- -- -- -- -- -- -- -- -- -- -- -- | 8[

> POKE 0x400 0b11_00_11_00  # Poke a single value to 0x400
OK

> POKE 0x400 10 20 55 60 88 # Poke 5 values into memory starting at 0x400
OK

> LOAD 0x400 255 # Read 255 bytes of data from the stream and store in memory (intended for an external program to load code)
(...255 bytes read from stream..)
CHK 17D

> EXEC 49152  # Execute the code at 49152
BYE

> IN 20  # I/O "in" operation (for processors that support it)
88

> OUT 20 FF # I/O "out" operation (for processors that support it)
OK
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
