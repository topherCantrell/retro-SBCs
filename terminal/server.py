import tornado.ioloop
import tornado.web
import tornado.websocket

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

class CaseHandler(tornado.web.RequestHandler):

    def get(self):
        text = self.get_argument('text', '')
        self.write(text.upper())

class WebsocketHandler(tornado.websocket.WebSocketHandler):
        
    def on_message(self, message):
        """
        Message received on channel
        """
        print("Got a message",message)
        self.write_message(message)

handlers = [
    (r"/case",CaseHandler),
    (r"/web-socket", WebsocketHandler,{}),
    (r"/(.*)", tornado.web.StaticFileHandler, {        
        "path": "/home/pi/terminal/webroot", 
        "default_filename": "index.html"}),
]

app = tornado.web.Application(handlers)
app.listen(80)
tornado.ioloop.IOLoop.current().start()