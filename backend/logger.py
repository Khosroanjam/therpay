# backend/logger.py
import os
import datetime
from pathlib import Path
from PySide6.QtCore import QObject, Slot

class Logger(QObject):
    def __init__(self):
        super().__init__()
        # تعیین مسیر فایل لاگ
        user_dir = os.path.expanduser("~")
        log_dir = os.path.join(user_dir, ".plasma_app", "logs")
        os.makedirs(log_dir, exist_ok=True)
        
        # نام فایل لاگ بر اساس تاریخ
        today = datetime.datetime.now().strftime("%Y-%m-%d")
        self.log_file = os.path.join(log_dir, f"plasma_app_{today}.log")
        
        # نوشتن هدر در فایل لاگ
        with open(self.log_file, "a", encoding="utf-8") as f:
            f.write(f"\n\n--- شروع برنامه در {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')} ---\n")
    
    @Slot(str)
    def log(self, message):
        """ثبت پیام در فایل لاگ"""
        try:
            timestamp = datetime.datetime.now().strftime("%H:%M:%S")
            log_message = f"[{timestamp}] {message}"
            
            # نمایش در کنسول
            print(f"QML Log: {log_message}")
            
            # نوشتن در فایل
            with open(self.log_file, "a", encoding="utf-8") as f:
                f.write(f"{log_message}\n")
        except Exception as e:
            print(f"خطا در نوشتن لاگ: {e}")
    
    @Slot(str, str)
    def logWithTag(self, tag, message):
        """ثبت پیام با تگ در فایل لاگ"""
        self.log(f"[{tag}] {message}")
    
    @Slot()
    def getLogFilePath(self):
        """دریافت مسیر فایل لاگ"""
        return self.log_file