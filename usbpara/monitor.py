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

def main():
    
    with serial.Serial('COM7',115200) as ser:        
              
        res = hello_prop(ser)
        print('# GOT',res)
        
        res = hello(ser)
        print('# GOT',res)
        
        with open('../6809/looper.asm.bin','rb') as f:
            data = f.read()
            
        res = load(ser,0x1000,data)
        print('# LOAD',res)
        
        res = execute(ser,0x1000)
        print('# EXEC',res)
        
        for i in range(20):
            res = raw_read(ser)
            print('# RAW',res)
        
main()
