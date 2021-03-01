CON
  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000

CON
  CLOCK_DELAY = 10

OBJ
    PST      : "Parallax Serial Terminal"      


pub main | i

  PauseMSec(2000)
  PST.start(115200) ' Start the serial terminal 

  repeat
    i := PST.charIn
    PST.char(i)
    'PST.hex(i,2)
  



pri readFromRetro | v
  v := ina >> 8
  return v & $FF

pri writeToRetro(value) | v,k             

  v := value >> 4
  v := v & %0_000_1111
  
  outa := v
  PauseMSec(CLOCK_DELAY)
  outa := (%1_000_0000 | v) 
  PauseMSec(CLOCK_DELAY)

  v := value & %0_000_1111
  
  outa := v  
  PauseMSec(CLOCK_DELAY)
  outa := (%1_000_0000 | v)
  PauseMSec(CLOCK_DELAY)

  return readFromRetro   

pri read(address)
  writeToRetro( 1 )
  writeToRetro( (address>>8) & $FF )
  writeToRetro( address & $FF )
  return readFromRetro 
  
pri write(address, value)
  writeToRetro( 2 )
  writeToRetro( (address>>8) & $FF )
  writeToRetro( address & $FF )
  writeToRetro(value)
  return readFromRetro

pri load(address,size,p) | i
  writeToRetro( 3 )
  writeToRetro( (address>>8) & $FF )
  writeToRetro( address & $FF )
  writeToRetro( (size>>8) & $FF )
  writeToRetro( size & $FF )
  repeat i from 0 to size-1
    writeToRetro(byte[p+i])
  return readFromRetro

pri execute(address)
  writeToRetro( 4 )
  writeToRetro( (address>>8) & $FF )
  writeToRetro( address & $FF )
  
PUB testIO | i

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
     

  writeToRetro(1)
  writeToRetro($FF)
  writeToRetro($00)

  
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
  byte $B7, $80, $02     'STA    0x8002                  
  byte $8E, $01, $00     'LDX    #0x100
'                  wait:
  byte $30, $1F          'LEAX   -1,X
  byte $26, $FC          'BNE    wait                      
  byte $20, $F3          'BRA    here