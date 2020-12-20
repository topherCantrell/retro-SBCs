import serial
import time

def read(ser,address):  # 1
    cmd = [1, (address>>8)&0xFF, address & 0xFF]
    ser.write(bytes(cmd))
    ret = ser.read()
    return ret

def write(ser,address,value):  # 2
    cmd = [2, (address>>8)&0xFF, address & 0xFF, value &0xFF]
    ser.write(bytes(cmd))
    ret = ser.read()
    return ret

def load(ser,address,data):  # 3
    len_data = len(data)
    cmd = [3, (address>>8)&0xFF, address & 0xFF, (len_data>>8)&0xFF, len_data & 0xFF]
    ser.write(bytes(cmd))
    ser.write(data)
    ret = ser.read()
    return ret

def execute(ser,address):  # 4
    cmd = [4, (address>>8)&0xFF, address & 0xFF]
    ser.write(bytes(cmd))
    ret = ser.read()
    return ret

def hello(ser):  # 5
    ser.write(b'\x05')
    v = ser.read()
    return v

def hello_prop(ser):  # 6
    ser.write(b'\x06')
    v = ser.read()
    return v

def raw_read(ser):  # 7
    ser.write(b'\x07')
    v = ser.read()
    return v

def load_run(ser,address,data):
    load(ser,address,data)
    execute(ser,address)
    
def main():
    
    with serial.Serial('COM7',115200) as ser: # SILVER
        with open('../6809_hilo/hilo.asm.bin','rb') as f:
            data = f.read()
            
        load_run(ser,0x2000,data)
    
def main4():
    with serial.Serial('COM7',115200) as ser: # BLACK
        res = hello(ser)
        print('# Hello:',res)
        
        write(ser,0x8001,0) # select the ...
        write(ser,0x8003,0) # ... data direction regs
        write(ser,0x8000,0b1_1111111) # All outputs
        write(ser,0x8002,0b00000_111) # Inputs and outputs
        write(ser,0x8001,4) # select the ...
        write(ser,0x8003,4) # ... data registers
        
        #                  A gfedcba
        write(ser,0x8000,0b1_0000001)
        #                        DCB
        write(ser,0x8002,0b00000_100)
        
        # Read the buttons
        while(True):
            a = read(ser,0x8002)
            print('#',hex(a[0]))
            time.sleep(1)
    
def main3():
    with serial.Serial('COM7',115200) as ser: # BLACK
        res = hello(ser)
        print('# Hello:',res)
        
        for x in range(20):
            a = read(ser,x+0xFF00)
            print('#',hex(a[0]))

def main2():
    
    with serial.Serial('COM7',115200) as ser:  # SILVER
    #with serial.Serial('COM3',115200) as ser: # BLACK
              
        res = hello_prop(ser)
        print('# Hello prop:',res)
        
        res = hello(ser)
        print('# Hello:',res)
        
        with open('../6809/monitor_serial.asm.bin','rb') as f:
            data = f.read()
            
        load_run(ser,0x1000,data)
                        
        """
        while True:
            res = raw_read(ser)
            print('# RAW',res)
            time.sleep(1)
            
        """

        """ 
                                
        write(ser,0xA000,7)
        
        write(ser,0xA000,0x15)
        
                       
        res = read(ser,0xA000)        
        print(hex(res[0]))
        
        write(ser,0xA001,0x39)
        write(ser,0xA001,0x36)

        
        while True:
            res = read(ser,0xA000)
            print(hex(res[0]))
            time.sleep(1)     
             
        with open('../6809/looper.asm.bin','rb') as f:
            data = f.read()
            
        res = load(ser,0x1000,data)
        print('# LOAD',res)
        
        res = execute(ser,0x1000)
        print('# EXEC',res)
        
        for i in range(20):
            res = raw_read(ser)
            print('# RAW',res)
        """        
        
main()
