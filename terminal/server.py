import tornado.ioloop
import tornado.web
import tornado.websocket

import serial
import threading

'''
sudo python3 -m pip install tornado

Put the pi in kiosk mode: https://wolfgang-ziegler.com/blog/setting-up-a-raspberrypi-in-kiosk-mode-2020
Point the kiosk to "http://localhost"

- Add this line to /etc/rc.local (before the exit 0):
-   /home/pi/ONBOOT.sh 2> /home/pi/ONBOOT.errors > /home/pi/ONBOOT.stdout &
- Add the following ONBOOT.sh script to /home/pi and make it executable:
  
#!/bin/bash
cd /home/pi/terminal
python3 server.py  
'''

class UploadHandler(tornado.web.RequestHandler):

    # address, binary, [optional execute address]

    def get(self):
        text = self.get_argument('text', '')
        self.write(text.upper())

class WebsocketHandler(tornado.websocket.WebSocketHandler):

    def open(self):
        global web_clients
        web_clients.add(self)

    def on_close(self):
        global web_clients
        if self in web_clients:
            web_clients.remove(self)
        
    def on_message(self, message):
        """
        Message received on channel
        """
        if message=='Enter':
            message = '\x0D'        
        ser.write(message.encode())

def broadcast(message):
    global web_clients
    for client in web_clients:
        try:
            client.write_message(message)
        except Exception:
            pass

ser = serial.Serial('/dev/ttyUSB0',baudrate=115200)

def watchSBC():    
    while True:
        c = ser.read(1)       
        # print('>',c,'<') 
        if c==b'\x0A':
            message = '\x0A'       
        elif c==b'\x0D':
            message = ''          
        else:
            try:
                message = c.decode()        
            except Exception:
                message = ''
        if message:
            io_loop.add_callback(broadcast,message)            

handlers = [
    (r"/upload",UploadHandler),
    (r"/web-socket", WebsocketHandler,{}),
    (r"/(.*)", tornado.web.StaticFileHandler, {        
        "path": "/home/pi/terminal/webroot", 
        "default_filename": "index.html"}),
]

# TODO: Convert backspace and enter to "Backspace" and "Enter". Ignore all other non-char keys.
# TODO: POST for uploading code

# TODO: watch serial port for incoming chars (from board) and pass
#       them on to the websocket
# TODO: pass keys from the websocket to the serial

web_clients = set()

threading.Thread(target=watchSBC).start()

app = tornado.web.Application(handlers)
app.listen(80)
io_loop = tornado.ioloop.IOLoop.current()
io_loop.start()
