# backend/database.py
import os
import sqlite3
from datetime import datetime
from pathlib import Path

class DatabaseManager:
    """کلاس مدیریت دیتابیس برای برنامه"""
    
    def __init__(self, db_name="plasma.db"):
        """مقداردهی اولیه و ایجاد دیتابیس"""
        # تعیین مسیر دیتابیس در کنار فایل اجرایی
        base_dir = "/home/plasma/Documents" #Path(__file__).parent.parent
        self.db_path = os.path.join(base_dir, db_name)
        
        # ایجاد دیتابیس و جداول مورد نیاز
        self.initialize_database()
    
    def initialize_database(self):
        """ایجاد دیتابیس و جداول مورد نیاز اگر وجود نداشته باشند"""
        try:
            # بررسی وجود فایل دیتابیس
            create_tables = not os.path.exists(self.db_path)
            
            # اتصال به دیتابیس
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            # ایجاد جداول مورد نیاز
            if create_tables:
                # جدول بیماران طبق ساختار داده شده
                cursor.execute('''
                CREATE TABLE "patients" (
                    "id"	INTEGER NOT NULL,
                    "name"	TEXT,
                    "age"	INTEGER,
                    "gender"	INTEGER,
                    "codemeli"	INTEGER NOT NULL,
                    PRIMARY KEY("id" AUTOINCREMENT)
                );
                ''')
                
                # جدول اپراتورها طبق ساختار داده شده
                cursor.execute('''
                CREATE TABLE "operator" (
                    "id"	INTEGER NOT NULL,
                    "name"	TEXT,
                    "code"	INTEGER NOT NULL,
                    "reserve1"	TEXT,
                    "reserve2"	TEXT,
                    PRIMARY KEY("id" AUTOINCREMENT)
                );
                ''')
                
                # اضافه کردن داده‌های نمونه برای اپراتورها
                sample_operators = [
                    ('علی محمدی', 1234, None, None),
                    ('مریم احمدی', 5678, None, None),
                    ('رضا کریمی', 9012, None, None)
                ]
                
                cursor.executemany('''
                INSERT INTO operator (name, code, reserve1, reserve2)
                VALUES (?, ?, ?, ?)
                ''', sample_operators)
                
                # اضافه کردن داده‌های نمونه برای بیماران
                sample_patients = [
                    ('علی محمدی', 30, 1, 1234567890),  # 1 برای مرد
                    ('مریم احمدی', 25, 0, 9876543210),  # 0 برای زن
                    ('رضا کریمی', 40, 1, 5555555555)   # 1 برای مرد
                ]
                
                cursor.executemany('''
                INSERT INTO patients (name, age, gender, codemeli)
                VALUES (?, ?, ?, ?)
                ''', sample_patients)
                
                conn.commit()
                print("دیتابیس با موفقیت ایجاد شد و داده‌های نمونه اضافه شدند.")
            
            conn.close()
            
        except sqlite3.Error as e:
            print(f"خطا در ایجاد دیتابیس: {e}")
            raise
    
    def execute_query(self, query, params=None, fetch_one=False):
        """اجرای یک query در دیتابیس"""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            if params:
                cursor.execute(query, params)
            else:
                cursor.execute(query)
            
            if query.strip().upper().startswith(("SELECT", "PRAGMA")):
                if fetch_one:
                    result = cursor.fetchone()
                else:
                    result = cursor.fetchall()
            else:
                conn.commit()
                result = cursor.rowcount
            
            cursor.close()
            conn.close()
            return result
            
        except sqlite3.Error as e:
            print(f"خطا در اجرای query: {e}")
            raise


class PatientManager:
    """کلاس مدیریت بیماران"""
    
    def __init__(self, db_manager=None):
        """مقداردهی اولیه"""
        self.db_manager = db_manager or DatabaseManager()
    
    def search_patient(self, codemeli):
        """جستجوی بیمار با کد ملی"""
        query = '''
        SELECT codemeli, name, age, gender
        FROM patients
        WHERE codemeli = ?
        '''
        
        result = self.db_manager.execute_query(query, (codemeli,), fetch_one=True)
        return result
    
    def add_patient(self, codemeli, name, age, gender):
        """افزودن بیمار جدید"""
        # بررسی وجود بیمار با کد ملی مشابه
        existing_patient = self.search_patient(codemeli)
        if existing_patient:
            return False, "بیماری با این کد ملی قبلاً ثبت شده است."
        
        query = '''
        INSERT INTO patients (codemeli, name, age, gender)
        VALUES (?, ?, ?, ?)
        '''
        
        try:
            self.db_manager.execute_query(query, (codemeli, name, age, gender))
            return True, "بیمار با موفقیت ثبت شد."
        except sqlite3.IntegrityError:
            return False, "خطا در ثبت بیمار: کد ملی تکراری است."
        except Exception as e:
            return False, f"خطا در ثبت بیمار: {str(e)}"
    
    def update_patient(self, codemeli, name=None, age=None, gender=None):
        """به‌روزرسانی اطلاعات بیمار"""
        # ابتدا بررسی می‌کنیم که بیمار وجود دارد یا خیر
        patient = self.search_patient(codemeli)
        if not patient:
            return False, "بیماری با این کد ملی یافت نشد."
        
        # ایجاد query به‌روزرسانی با فیلدهایی که مقدار دارند
        update_fields = []
        params = []
        
        if name is not None:
            update_fields.append("name = ?")
            params.append(name)
        
        if age is not None:
            update_fields.append("age = ?")
            params.append(age)
        
        if gender is not None:
            update_fields.append("gender = ?")
            params.append(gender)
        
        # اگر هیچ فیلدی برای به‌روزرسانی نباشد
        if not update_fields:
            return False, "هیچ فیلدی برای به‌روزرسانی مشخص نشده است."
        
        # ایجاد query نهایی
        query = f"UPDATE patients SET {', '.join(update_fields)} WHERE codemeli = ?"
        params.append(codemeli)
        
        try:
            self.db_manager.execute_query(query, params)
            return True, "اطلاعات بیمار با موفقیت به‌روز شد."
        except Exception as e:
            return False, f"خطا در به‌روزرسانی اطلاعات بیمار: {str(e)}"
    
    def delete_patient(self, codemeli):
        """حذف بیمار با کد ملی مشخص"""
        # ابتدا بررسی می‌کنیم که بیمار وجود دارد یا خیر
        patient = self.search_patient(codemeli)
        if not patient:
            return False, "بیماری با این کد ملی یافت نشد."
        
        query = '''
        DELETE FROM patients
        WHERE codemeli = ?
        '''
        
        try:
            self.db_manager.execute_query(query, (codemeli,))
            return True, "بیمار با موفقیت حذف شد."
        except Exception as e:
            return False, f"خطا در حذف بیمار: {str(e)}"


class OperatorManager:
    """کلاس مدیریت اپراتورها"""
    
    def __init__(self, db_manager=None):
        """مقداردهی اولیه"""
        self.db_manager = db_manager or DatabaseManager()
    
    def validate_operator_code(self, code):
        """بررسی اعتبار کد اپراتوری"""
        query = '''
        SELECT code, name
        FROM operator
        WHERE code = ?
        '''
        
        result = self.db_manager.execute_query(query, (code,), fetch_one=True)
        
        if result:
            # به‌روزرسانی زمان آخرین ورود (در فیلد reserve1)
            self.update_last_login(code)
            return True, result
        else:
            return False, None
    
    def update_last_login(self, code):
        """به‌روزرسانی زمان آخرین ورود اپراتور در فیلد reserve1"""
        query = '''
        UPDATE operator
        SET reserve1 = ?
        WHERE code = ?
        '''
        
        last_login = datetime.now().strftime('%Y/%m/%d %H:%M:%S')
        self.db_manager.execute_query(query, (last_login, code))
    
    def add_operator(self, name, code, reserve1=None, reserve2=None):
        """افزودن اپراتور جدید"""
        # بررسی وجود اپراتور با کد مشابه
        query_check = '''
        SELECT code FROM operator WHERE code = ?
        '''
        existing_operator = self.db_manager.execute_query(query_check, (code,), fetch_one=True)
        
        if existing_operator:
            return False, "اپراتوری با این کد قبلاً ثبت شده است."
        
        query = '''
        INSERT INTO operator (name, code, reserve1, reserve2)
        VALUES (?, ?, ?, ?)
        '''
        
        try:
            self.db_manager.execute_query(query, (name, code, reserve1, reserve2))
            return True, "اپراتور با موفقیت ثبت شد."
        except Exception as e:
            return False, f"خطا در ثبت اپراتور: {str(e)}"
    
    def update_operator(self, code, name=None, reserve1=None, reserve2=None):
        """به‌روزرسانی اطلاعات اپراتور"""
        # ابتدا بررسی می‌کنیم که اپراتور وجود دارد یا خیر
        query_check = '''
        SELECT code FROM operator WHERE code = ?
        '''
        existing_operator = self.db_manager.execute_query(query_check, (code,), fetch_one=True)
        
        if not existing_operator:
            return False, "اپراتوری با این کد یافت نشد."
        
        # ایجاد query به‌روزرسانی با فیلدهایی که مقدار دارند
        update_fields = []
        params = []
        
        if name is not None:
            update_fields.append("name = ?")
            params.append(name)
        
        if reserve1 is not None:
            update_fields.append("reserve1 = ?")
            params.append(reserve1)
        
        if reserve2 is not None:
            update_fields.append("reserve2 = ?")
            params.append(reserve2)
        
        # اگر هیچ فیلدی برای به‌روزرسانی نباشد
        if not update_fields:
            return False, "هیچ فیلدی برای به‌روزرسانی مشخص نشده است."
        
        # ایجاد query نهایی
        query = f"UPDATE operator SET {', '.join(update_fields)} WHERE code = ?"
        params.append(code)
        
        try:
            self.db_manager.execute_query(query, params)
            return True, "اطلاعات اپراتور با موفقیت به‌روز شد."
        except Exception as e:
            return False, f"خطا در به‌روزرسانی اطلاعات اپراتور: {str(e)}"
    
    def delete_operator(self, code):
        """حذف اپراتور با کد مشخص"""
        query_check = '''
        SELECT code FROM operator WHERE code = ?
        '''
        existing_operator = self.db_manager.execute_query(query_check, (code,), fetch_one=True)
        
        if not existing_operator:
            return False, "اپراتوری با این کد یافت نشد."
        
        query = '''
        DELETE FROM operator
        WHERE code = ?
        '''
        
        try:
            self.db_manager.execute_query(query, (code,))
            return True, "اپراتور با موفقیت حذف شد."
        except Exception as e:
            return False, f"خطا در حذف اپراتور: {str(e)}"
    
    def get_all_operators(self):
        """دریافت لیست تمام اپراتورها"""
        query = '''
        SELECT id, name, code, reserve1, reserve2
        FROM operator
        ORDER BY name
        '''
        
        return self.db_manager.execute_query(query)