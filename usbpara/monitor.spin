CON
  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000

CON
  CLOCK_DELAY = 10

OBJ
    PST      : "Parallax Serial Terminal"      

VAR
    byte dataBuffer[16*1024]

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

pri read(address)
  writeToRetro(1)
  writeToRetro( (address>>8) & $FF )
  writeToRetro( address & $FF )
  return readFromRetro

pri write(address,value)
  writeToRetro(2)
  writeToRetro( (address>>8) & $FF )
  writeToRetro( address & $FF )
  writeToRetro(value)
  return readFromRetro

pri load(address,len,p) | i
  writeToRetro(3)
  writeToRetro( (address>>8) & $FF )
  writeToRetro( address & $FF )
  writeToRetro( (len>>8) & $FF )
  writeToRetro( len & $FF )
  repeat i from 0 to len-1
    writeToRetro(byte[p+i])
  return readFromRetro

pri exec(address)
  writeToRetro(4)
  writeToRetro( (address>>8) & $FF )
  writeToRetro( address & $FF )
  ' Nothing coming back from the board here
  ' We left the monitor

pri hello
  writeToRetro(5)
  return readFromRetro

PUB monitor | i, j, k

  ' PauseMSec(2000)   ' Give the user time to switch to terminal  
  PST.start(115200) ' Start the serial terminal   
                  
  '        BB AA
  outa := $00_FF
  dira := $00_FF
    
  repeat
    i := PST.CharIn
    if i==1       ' READ
      i := (PST.CharIn << 8) | PST.CharIn
      i := read(i)
      PST.Char(i)
    elseif i==2   ' WRITE
      i := (PST.CharIn << 8) | PST.CharIn
      j := PST.CharIn
      i := write(i,j)
      PST.Char(i)
    elseif i==3   ' LOAD
      i := (PST.CharIn << 8) | PST.CharIn
      j := (PST.CharIn << 8) | PST.CharIn
      repeat k from 0 to j-1
        dataBuffer[k] := PST.CharIn
      i := load(i,j,@dataBuffer)
      PST.Char(i)
    elseif i==4   ' EXEC
      i := (PST.CharIn << 8) | PST.CharIn
      exec(i)
    elseif i==5   ' HELLO
      i := hello
      PST.Char(i)
    elseif i==6   ' HELLO PROP
      PST.Char($CC) 
    elseif i==7   ' RAW READ
      PST.Char(readFromRetro)
    else
      PST.Char($99) 


PUB monitorMAN | i ' USED IN DEVELOPMENT/DEBUG

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

  i := write($1234,$FA)
  PST.hex(i,2)
  PST.char(13)

  i := hello
  PST.hex(i,2)
  PST.char(13)

  i := load($1000,16,@loop_program)
  exec($1000)  
  
  PST.char(13)
  repeat
    PST.hex(readFromRetro,2)
    PST.char(13)
    PauseMSec(1000)


PRI PauseMSec(Duration)
  waitcnt(((clkfreq / 1_000 * Duration - 3932) #> 381) + cnt)


DAT

loop_program ' 16

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