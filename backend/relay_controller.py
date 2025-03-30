# relay_controller.py
from PySide6.QtCore import QObject, Slot, Signal

class RelayController(QObject):
    # سیگنال‌ها برای اطلاع‌رسانی به QML
    relayStateChanged = Signal(int, bool)  # شماره رله، وضعیت
    relayError = Signal(str)  # پیام خطا
    
    def __init__(self, logger=None):
        super().__init__()
        # ذخیره نمونه logger
        self.logger = logger
        
        # تلاش برای وارد کردن RPi.GPIO
        try:
            import RPi.GPIO as GPIO
            self.GPIO = GPIO
            GPIO_AVAILABLE = True
            self.log("RPi.GPIO با موفقیت وارد شد")
        except (ImportError, RuntimeError):
            # اگر در رزبری پای نیستیم یا کتابخانه نصب نشده است
            self.log("RPi.GPIO در دسترس نیست، استفاده از شبیه‌ساز")
            GPIO_AVAILABLE = False
            
            # کلاس شبیه‌ساز ساده
            class GPIO:
                BOARD = 1
                BCM = 2
                OUT = 3
                IN = 4
                HIGH = True
                LOW = False
                PUD_UP = 22
                PUD_DOWN = 21
                
                _mode = None
                _pin_states = {}
                _warnings = True
                
                @staticmethod
                def setmode(mode):
                    GPIO._mode = mode
                    print(f"[MOCK] GPIO.setmode({mode})")
                
                @staticmethod
                def setwarnings(flag):
                    GPIO._warnings = flag
                    print(f"[MOCK] GPIO.setwarnings({flag})")
                
                @staticmethod
                def setup(channel, direction, pull_up_down=None, initial=None):
                    GPIO._pin_states[channel] = initial if initial is not None else False
                    print(f"[MOCK] GPIO.setup(channel={channel}, direction={direction}, initial={initial})")
                
                @staticmethod
                def output(channel, state):
                    GPIO._pin_states[channel] = state
                    print(f"[MOCK] GPIO.output(channel={channel}, state={state})")
                
                @staticmethod
                def input(channel):
                    state = GPIO._pin_states.get(channel, False)
                    print(f"[MOCK] GPIO.input(channel={channel}) -> {state}")
                    return state
                
                @staticmethod
                def cleanup(channel=None):
                    if channel is None:
                        GPIO._pin_states.clear()
                        print("[MOCK] GPIO.cleanup() - All pins")
                    else:
                        if channel in GPIO._pin_states:
                            del GPIO._pin_states[channel]
                        print(f"[MOCK] GPIO.cleanup(channel={channel})")
            
            self.GPIO = GPIO

        # تنظیم حالت پین‌های GPIO
        self.GPIO.setmode(self.GPIO.BCM)  # استفاده از شماره‌گذاری BCM
        self.GPIO.setwarnings(False)
        
        # تعریف پین‌های رله
        self.relay_pins = {
            1: 17,  # رله 1 به پین GPIO17 متصل است
            2: 18,  # رله 2 به پین GPIO18 متصل است
            3: 27,  # رله 3 به پین GPIO27 متصل است
            4: 22,  # رله 4 به پین GPIO22 متصل است
        }
        
        # تنظیم پین‌ها به عنوان خروجی و خاموش کردن همه رله‌ها
        for pin in self.relay_pins.values():
            try:
                self.GPIO.setup(pin, self.GPIO.OUT)
                self.GPIO.output(pin, self.GPIO.HIGH)  # در اکثر رله‌ها، HIGH به معنای خاموش است
                self.log(f"پین {pin} به عنوان خروجی تنظیم شد")
            except Exception as e:
                error_msg = f"خطا در تنظیم پین {pin}: {e}"
                self.log(error_msg)
                self.relayError.emit(error_msg)
    
    def log(self, message):
        """ثبت پیام در لاگ"""
        if self.logger:
            self.logger.log(message)
        else:
            print(f"RelayController: {message}")
    
    @Slot(int, bool)
    def setRelay(self, relay_number, state):
        """تنظیم وضعیت رله
        
        Args:
            relay_number (int): شماره رله (1 تا 4)
            state (bool): وضعیت رله (True = روشن، False = خاموش)
        """
        try:
            if relay_number in self.relay_pins:
                pin = self.relay_pins[relay_number]
                # در اکثر رله‌ها، LOW به معنای روشن و HIGH به معنای خاموش است
                self.GPIO.output(pin, not state)  # معکوس کردن منطق برای رله‌های معمولی
                self.relayStateChanged.emit(relay_number, state)
                self.log(f"رله {relay_number} {'روشن' if state else 'خاموش'} شد")
                return True
            else:
                error_msg = f"شماره رله نامعتبر: {relay_number}"
                self.log(error_msg)
                self.relayError.emit(error_msg)
                return False
        except Exception as e:
            error_msg = f"خطا در تنظیم رله {relay_number}: {e}"
            self.log(error_msg)
            self.relayError.emit(error_msg)
            return False
    
    # بقیه متدها مثل قبل، فقط به جای print از self.log استفاده کنید
    # ...
    
    def cleanup(self):
        """پاکسازی پین‌های GPIO هنگام خروج از برنامه"""
        try:
            # خاموش کردن همه رله‌ها
            for pin in self.relay_pins.values():
                self.GPIO.output(pin, self.GPIO.HIGH)  # HIGH = خاموش
            
            # آزادسازی پین‌ها
            self.GPIO.cleanup()
            self.log("پین‌های GPIO پاکسازی شدند")
        except Exception as e:
            self.log(f"خطا در پاکسازی GPIO: {e}")