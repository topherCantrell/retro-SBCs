import serial
import threading

ser = serial.Serial('COM4',115200)

a = 'Hello World\n'

for c in a:
    print(ord(c))

for c in a.encode():
    print(c)

ser.close()


