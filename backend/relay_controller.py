# relay_controller.py
from PySide6.QtCore import QObject, Slot, Signal
import serial

class RelayController(QObject):
    # سیگنال برای اطلاع‌رسانی وضعیت پورت
    connectionStatus = Signal(bool, str)

    def __init__(self):
        super().__init__()
        self.serial_port = None
        self.is_connected = False
        self.port_name = '/dev/ttyUSB0'
        self.try_connect()

    def try_connect(self):
        """تلاش برای اتصال به پورت سریال"""
        try:
            self.serial_port = serial.Serial(
                port=self.port_name,
                baudrate=9600,
                timeout=1
            ).connected = True
            print(f"Successfully connected to {self.port_name}")
            self.connectionStatus.emit(True, f"Connected to {self.port_name}")
        except serial.SerialException:
            self.is_connected = False
            print(f"Could not connect to {self.port_name}")
            self.connectionStatus.emit(False, f"Port {self.port_name} not available")

    @Slot(str)
    def sendSerialCommand(self, command):
        """ارسال دستور به پورت سریال"""
        if not self.is_connected:
            print(f"Port not connected. Command '{command}' not sent.")
            return False

        try:
            command = command + '\n'
            self.serial_port.write(command.encode())
            self.serial_port.flush()
            print(f"Command sent successfully: {command}")
            return True
        except Exception as e:
            print(f"Error sending command: {e}")
            self.is_connected = False
            self.connectionStatus.emit(False, "Connection lost")
            return False

    @Slot()
    def reconnect(self):
        """تلاش مجدد برای اتصال"""
        self.try_connect()

    def __del__(self):
        """پاکسازی و بستن پورت"""
        if self.serial_port and self.serial_port.is_open:
            try:
                self.serial_port.close()
            except:
                pass