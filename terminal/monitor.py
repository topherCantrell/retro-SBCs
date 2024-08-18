import serial
import time
import sys

# py opcodetools.asm monitor.asm
# py monitor.py test.asm.bin

# Serial dongle to board
ser = serial.Serial('COM4',115200)

# Make sure it is alive
ser.write(b'\x05')
a = ser.read()
print('Hello ...',a)

# Read the binary
with open(sys.argv[1],'rb') as f:
    data = f.read()
print(sys.argv[1],len(data),"bytes")

# Load the binary on the board
a = len(data)//256
b = len(data)%256
cmd = [0x03,0x40,0x00,a,b]
ser.write(cmd)
ser.write(data)
a = ser.read()
print('Load ...',a)

# Execute the binary on the board
cmd = [0x04,0x40,0x00]
ser.write(cmd)

# Done
ser.close()
