import tornado.ioloop
import tornado.web
import tornado.websocket

import serial
import threading
import json
import time

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

class UploadJSONHandler(tornado.web.RequestHandler):

    def post(self):
        '''
        {
            "uploadAddress" : "0x4000",
            "executeAddress" : null,
            "binary64" : "12345678"
        }
        '''
        pass

class UploadHandler(tornado.web.RequestHandler):

    # address, binary, [optional execute address]

    def _parse_numeric(self,data):
        # These must be positive
        data = data.upper()
        data = data.replace('_','')
        value = 0
        try:
            if data.startswith('0X'):
                value = int(data[2:],16)
            elif data.startswith('0B'):
                value = int(data[2:],2)
            else:
                value = int(data)
            if value>65535:
                value = -1
            elif value<0:
                value = -1
        except Exception:
            value = -1
        return value        

    def post(self):        

        upload_address = self.request.arguments.get('address1')[0].decode()
        execute_address = self.request.arguments.get('address2')[0].decode()
        if upload_address == '':
            upload_address = '0'
        if execute_address == '':
            execute_address = upload_address
        upaddr = self._parse_numeric(upload_address)
        if upaddr<0:
            self.write('Error: invalid load address '+upaddr)
            return
        exaddr = self._parse_numeric(execute_address)
        if exaddr<0:
            self.write('Error: invalid execute address '+exaddr)
            return        

        do_upload = self.request.arguments.get('upload')[0]
        do_execute = self.request.arguments.get('execute')[0]

        file_info = None
        if 'binaryfile' in self.request.files:
            file_info = self.request.files['binaryfile'][0]
        
        if do_upload==b'true':
            if not file_info:                
                self.write('Error: no file selected')
                return            
            data = file_info['body']
            print('Uploading "'+file_info['filename']+'" to '+upload_address) 
            # TODO address as given (hex, whatever)
            cmd = 'LOAD '+upload_address+' '+str(len(data))+'\x0D'   
            chk = 0
            for d in data:
                chk += d
                chk = chk & 0xFFFF                
            broadcast('\n')
            broadcast('** Uploading file "'+file_info['filename']+'" to '+upload_address+'\n')
            broadcast('** Length: '+str(len(data))+' Checksum: '+hex(chk)[2:].upper()+'\n')
            ser.write(cmd.encode())
            time.sleep(0.5)
            ser.write(data)

        if do_execute==b'true':           
            time.sleep(0.5)
            broadcast('\n')
            broadcast('** Executing '+execute_address+'\n')        
            cmd2 = 'EXEC '+execute_address+'\x0D'
            ser.write(cmd2.encode())
        
        self.write("OK\n")
        
class WebsocketHandler(tornado.websocket.WebSocketHandler):

    def open(self):
        global web_clients
        web_clients.add(self)

    def on_close(self):
        global web_clients
        if self in web_clients:
            web_clients.remove(self)
        
    def on_message(self, message):
        # Key from the browser
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
    (r"/uploadJSON",UploadJSONHandler),
    (r"/web-socket", WebsocketHandler,{}),
    (r"/(.*)", tornado.web.StaticFileHandler, {        
        "path": "/home/pi/terminal/webroot", 
        "default_filename": "index.html"}),
]

web_clients = set()

threading.Thread(target=watchSBC).start()

app = tornado.web.Application(handlers)
app.listen(80)
io_loop = tornado.ioloop.IOLoop.current()
io_loop.start()
