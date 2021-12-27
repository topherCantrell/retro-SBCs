import getkey

import serial
import threading
import socket

ser = serial.Serial('/dev/ttyUSB0',baudrate=115200)

def watchSBC():
    while True:
        c = ser.read()        
        if c==b'\x0A':
            print() 
        else:
            print(c.decode(),end='')

def watchKeyboard():
    while True:
        key = getkey.getkey()
        if len(key)>1:
            continue
        key = ord(key)
        if key==0x7F:
            key = 8    
        if key==0x0A:
            key = 0x0D        
        ser.write(bytearray([key]))

def watchSocket():
    ssock = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
    server_address = ('',1234)
    ssock.bind(server_address)
    ssock.listen()
    while True:
        # Only 1 at a time (should be plenty)
        cs,ad = ssock.accept()
        print('\n Remote connection from',ad)
        while True:
            try:
                g = cs.recv(256)
                if not g:
                    break
            except Exception:
                break
            ser.write(g)
        print('\n Remote connection terminated')

threading.Thread(target=watchSBC).start()
threading.Thread(target=watchKeyboard).start()
threading.Thread(target=watchSocket).start()

