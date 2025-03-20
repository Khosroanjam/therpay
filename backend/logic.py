# backend/logic.py
from .database import OperatorManager

class LoginManager:
    """کلاس مدیریت ورود به سیستم"""
    
    def __init__(self):
        """مقداردهی اولیه"""
        self.operator_manager = OperatorManager()
        self.current_operator_code = None
        self.current_operator_info = None
    
    def validate_code(self, code):
        """بررسی اعتبار کد اپراتوری"""
        if not code or code <= 0:
            return False, "کد اپراتوری باید یک عدد مثبت باشد."
        
        # بررسی کد در دیتابیس
        is_valid, operator_info = self.operator_manager.validate_operator_code(code)
        
        if is_valid:
            self.current_operator_code = code
            self.current_operator_info = operator_info
            return True, "ورود موفقیت‌آمیز"
        else:
            return False, "کد اپراتوری نامعتبر است."
    
    def save_code(self, code):
        """ذخیره کد اپراتوری برای استفاده بعدی"""
        self.current_operator_code = code
        # می‌توانید کد را در تنظیمات برنامه یا حافظه موقت ذخیره کنید
        print(f"کد اپراتوری {code} ذخیره شد.")
    
    def get_current_operator_info(self):
        """دریافت اطلاعات اپراتور فعلی"""
        return self.current_operator_info