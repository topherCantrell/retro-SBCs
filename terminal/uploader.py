import socket
import time

cs = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
cs.connect(('10.0.0.7',1234))

cs.send(b'info\x0D')

time.sleep(1)

cs.close()