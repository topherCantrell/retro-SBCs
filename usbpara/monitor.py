import serial
import time

class MonitorError(Exception):
    pass

class Monitor:
    
    def __init__(self,port_name):
        self._ser = serial.Serial(port_name,115200)
        
    def close(self):
        self._ser.close()
        
    def serial_read(self):
        v = self._ser.read()
        return v[0]
    
    def serial_write(self,value):
        self._ser.write(bytes([value]))
    
    def hello(self):  
        self._ser.write(b'\x05')
        v = self._ser.read()
        if v[0]!=0xA5:
            raise MonitorError(f'Unexpected response to hello: {hex(v[0])}')        
    
    def prop_hello(self):
        '''just for the propeller GPIO'''
        self._ser.write(b'\x06')
        v = self._ser.read()
        if v[0]!=0xCC:
            raise MonitorError(f'Unexpected response to hello: {hex(v[0])}') 
    
    def prop_raw_read(self):
        '''just for the propeller GPIO'''
        self._ser.write(b'\x07')
        v = self._ser.read()
        return v[0]

    def read(self,address):
        cmd = [1, (address>>8)&0xFF, address & 0xFF]
        self._ser.write(bytes(cmd))
        ret = self._ser.read()
        return ret[0]

    def write(self,address,value):
        cmd = [2, (address>>8)&0xFF, address & 0xFF, value &0xFF]
        self._ser.write(bytes(cmd))
        v = self._ser.read()
        if v[0]!=0x88:
            raise MonitorError(f'Unexpected response to write: {hex(v[0])}') 

    def load(self,address,data):
        len_data = len(data)
        cmd = [3, (address>>8)&0xFF, address & 0xFF, (len_data>>8)&0xFF, len_data & 0xFF]
        self._ser.write(bytes(cmd))
        self._ser.write(data)
        v = self._ser.read()
        if v[0]!=0x88:
            raise MonitorError(f'Unexpected response to load: {hex(v[0])}') 

    def execute(self,address):
        cmd = [4, (address>>8)&0xFF, address & 0xFF]
        self._ser.write(bytes(cmd))
        # Nothing coming back ... we left the monitor

    def load_run(self,address,data):
        self.load(address,data)
        self.execute(address)
        
    def load_file(self,address,filename):
        with open(filename,'rb') as f:
            data = f.read()            
        self.load(address,data)
        
    def load_run_file(self,address,filename):
        with open(filename,'rb') as f:
            data = f.read()            
        self.load_run(address,data)
    
        
def main():
    mon = Monitor('COM4')
    a = mon.hello()

    print(a)


    """
    
    a = mon.read(0xFF59)
    print(hex(a))
        
    a = mon.read(0x8765)
    print(hex(a))
    
    mon.write(0x8765,0x98)
    
    a = mon.read(0x8765)
    print(hex(a))
    
    mon.load_run_file(0x8000,'../6502/scrap.asm.bin')
    
    time.sleep(2)
    
    # Power on value
    a = mon.serial_read()
    print(hex(a))
    
    a = mon.read(0x8222)
    print(hex(a))
    a = mon.read(0x8223)
    print(hex(a))
      
    
    mon.close()
    """
        
        
main()
