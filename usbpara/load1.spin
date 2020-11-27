CON
  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000

CON
  CLOCK_DELAY = 10

OBJ
    PST      : "Parallax Serial Terminal"      


pri readFromRetro | v
  v := ina >> 8
  return v & $FF

pri writeToRetro(value) | v,k             

  v := value >> 4
  v := v & %0_000_1111

  'PauseMSec(CLOCK_DELAY) 
  outa := v
  PauseMSec(CLOCK_DELAY)
  outa := (%1_000_0000 | v) 
  PauseMSec(CLOCK_DELAY)

  v := value & %0_000_1111

  'PauseMSec(CLOCK_DELAY)   
  outa := v  
  PauseMSec(CLOCK_DELAY)
  outa := (%1_000_0000 | v)
  PauseMSec(CLOCK_DELAY)

  return readFromRetro   
  
PUB testLoad | i

  PauseMSec(2000)   ' Give the user time to switch to terminal  
  PST.start(115200) ' Start the serial terminal   
                  
  '        BB AA
  outa := $00_FF
  dira := $00_FF

  repeat i from 1 to 5
    PST.hex(readFromRetro,2)
    PST.char(13)
    PauseMSec(1000)
  PST.char(13)

  writeToRetro($01)  ' Command value for load
  
  writeToRetro($00)  ' Length 00_10
  writeToRetro($10)

  writeToRetro($10)  ' Destination 10_00
  writeToRetro($00)
  
  repeat i from 0 to 16
    writeToRetro(byte[@loop_program+i])           
  
  PST.char(13)
  repeat
    PST.hex(readFromRetro,2)
    PST.char(13)
    PauseMSec(1000)


PRI PauseMSec(Duration)
  waitcnt(((clkfreq / 1_000 * Duration - 3932) #> 381) + cnt)


DAT

loop_program ' 15

  byte $86, $00          'LDA #0                  
'                  here:
  byte $4A               'DECA
  byte $4A               'DECA
  byte $B7, $80, $02     'STA    0x8002                  
  byte $8E, $FF, $FF     'LDX    #0xFFFF
'                  wait:
  byte $30, $1F          'LEAX   -1,X
  byte $26, $FC          'BNE    wait                      
  byte $20, $F2          'BRA    here