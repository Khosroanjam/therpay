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
        try:
            # اول تلاش کنید از مسیر نسبی استفاده کنید
            base_dir = Path(__file__).parent.parent
            self.db_path = os.path.join(base_dir, db_name)
            
            # تست دسترسی نوشتن
            test_file = os.path.join(base_dir, ".test_write")
            with open(test_file, 'w') as f:
                f.write("test")
            os.remove(test_file)
            
            print(f"استفاده از مسیر دیتابیس: {self.db_path}")
        except (IOError, PermissionError):
            # اگر دسترسی نوشتن نداشتید، از مسیر کاربر استفاده کنید
            user_dir = os.path.expanduser("~")
            base_dir = os.path.join(user_dir, ".plasma_app")
            os.makedirs(base_dir, exist_ok=True)
            self.db_path = os.path.join(base_dir, db_name)
            print(f"استفاده از مسیر دیتابیس کاربر: {self.db_path}")
        
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
    
class DiseaseManager:
    """کلاس مدیریت بیماری‌ها و زمان‌های پیش‌فرض آن‌ها"""
    
    def __init__(self, db_manager=None):
        """مقداردهی اولیه"""
        self.db_manager = db_manager or DatabaseManager()
        self._initialize_disease_table()
    
    def _initialize_disease_table(self):
        """ایجاد جدول بیماری‌ها اگر وجود نداشته باشد"""
        try:
            # بررسی وجود جدول diseases
            check_table_query = """
            SELECT name FROM sqlite_master WHERE type='table' AND name='diseases';
            """
            table_exists = self.db_manager.execute_query(check_table_query, fetch_one=True)
            
            if not table_exists:
                # ایجاد جدول بیماری‌ها
                create_table_query = """
                CREATE TABLE diseases (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT NOT NULL UNIQUE,
                    description TEXT,
                    default_minutes INTEGER NOT NULL,
                    default_seconds INTEGER NOT NULL
                );
                """
                self.db_manager.execute_query(create_table_query)
                
                # اضافه کردن چند نمونه داده پیش‌فرض
                default_data = [
                    ('پوست', 'درمان پوست با پلاسما تراپی', 2, 30),
                    ('زخم دیابتی', 'درمان زخم دیابتی با پلاسما تراپی', 5, 0),
                    ('جوان‌سازی پوست', 'جوان‌سازی پوست با پلاسما تراپی', 3, 0),
                    ('ریزش مو', 'درمان ریزش مو با پلاسما تراپی', 4, 0),
                    ('ترمیم زخم', 'ترمیم زخم با پلاسما تراپی', 2, 0)
                ]
                
                insert_query = """
                INSERT INTO diseases (name, description, default_minutes, default_seconds)
                VALUES (?, ?, ?, ?);
                """
                
                for data in default_data:
                    self.db_manager.execute_query(insert_query, data)
                
                print("جدول بیماری‌ها با موفقیت ایجاد شد و داده‌های نمونه اضافه شدند.")
        
        except sqlite3.Error as e:
            print(f"خطا در ایجاد جدول بیماری‌ها: {e}")
            raise
    
    def get_disease_info(self, disease_name):
        """دریافت اطلاعات یک بیماری خاص با نام آن"""
        query = """
        SELECT id, name, description, default_minutes, default_seconds
        FROM diseases
        WHERE name = ?;
        """
        
        result = self.db_manager.execute_query(query, (disease_name,), fetch_one=True)
        
        if result:
            return {
                "id": result[0],
                "name": result[1],
                "description": result[2],
                "default_minutes": result[3],
                "default_seconds": result[4]
            }
        
        return None
    
    def get_all_diseases(self):
        """دریافت لیست همه بیماری‌ها"""
        query = """
        SELECT id, name, description, default_minutes, default_seconds
        FROM diseases
        ORDER BY name;
        """
        
        results = self.db_manager.execute_query(query)
        
        diseases = []
        for result in results:
            diseases.append({
                "id": result[0],
                "name": result[1],
                "description": result[2],
                "default_minutes": result[3],
                "default_seconds": result[4]
            })
        
        return diseases
    
    def add_disease(self, name, description, minutes, seconds):
        """اضافه کردن یک بیماری جدید"""
        # بررسی وجود بیماری با نام مشابه
        existing_disease = self.get_disease_info(name)
        if existing_disease:
            return False, "بیماری با این نام قبلاً ثبت شده است."
        
        query = """
        INSERT INTO diseases (name, description, default_minutes, default_seconds)
        VALUES (?, ?, ?, ?);
        """
        
        try:
            self.db_manager.execute_query(query, (name, description, minutes, seconds))
            return True, "بیماری با موفقیت ثبت شد."
        except sqlite3.IntegrityError:
            return False, "خطا در ثبت بیماری: نام بیماری تکراری است."
        except Exception as e:
            return False, f"خطا در ثبت بیماری: {str(e)}"
    
    def update_disease(self, disease_id, name=None, description=None, minutes=None, seconds=None):
        """به‌روزرسانی اطلاعات یک بیماری"""
        # ابتدا بررسی می‌کنیم که بیماری وجود دارد یا خیر
        query_check = """
        SELECT id FROM diseases WHERE id = ?;
        """
        existing_disease = self.db_manager.execute_query(query_check, (disease_id,), fetch_one=True)
        
        if not existing_disease:
            return False, "بیماری با این شناسه یافت نشد."
        
        # ایجاد query به‌روزرسانی با فیلدهایی که مقدار دارند
        update_fields = []
        params = []
        
        if name is not None:
            update_fields.append("name = ?")
            params.append(name)
        
        if description is not None:
            update_fields.append("description = ?")
            params.append(description)
        
        if minutes is not None:
            update_fields.append("default_minutes = ?")
            params.append(minutes)
        
        if seconds is not None:
            update_fields.append("default_seconds = ?")
            params.append(seconds)
        
        # اگر هیچ فیلدی برای به‌روزرسانی نباشد
        if not update_fields:
            return False, "هیچ فیلدی برای به‌روزرسانی مشخص نشده است."
        
        # ایجاد query نهایی
        query = f"UPDATE diseases SET {', '.join(update_fields)} WHERE id = ?;"
        params.append(disease_id)
        
        try:
            self.db_manager.execute_query(query, params)
            return True, "اطلاعات بیماری با موفقیت به‌روز شد."
        except sqlite3.IntegrityError:
            return False, "خطا در به‌روزرسانی اطلاعات بیماری: نام بیماری تکراری است."
        except Exception as e:
            return False, f"خطا در به‌روزرسانی اطلاعات بیماری: {str(e)}"
    
    def update_disease_time(self, disease_name, minutes, seconds):
        """به‌روزرسانی زمان پیش‌فرض برای یک بیماری"""
        # ابتدا بررسی می‌کنیم که بیماری وجود دارد یا خیر
        disease_info = self.get_disease_info(disease_name)
        if not disease_info:
            return False, "بیماری با این نام یافت نشد."
        
        query = """
        UPDATE diseases 
        SET default_minutes = ?, default_seconds = ? 
        WHERE name = ?;
        """
        
        try:
            self.db_manager.execute_query(query, (minutes, seconds, disease_name))
            return True, "زمان پیش‌فرض بیماری با موفقیت به‌روز شد."
        except Exception as e:
            return False, f"خطا در به‌روزرسانی زمان پیش‌فرض بیماری: {str(e)}"
    
    def delete_disease(self, disease_id):
        """حذف یک بیماری با شناسه آن"""
        # ابتدا بررسی می‌کنیم که بیماری وجود دارد یا خیر
        query_check = """
        SELECT id FROM diseases WHERE id = ?;
        """
        existing_disease = self.db_manager.execute_query(query_check, (disease_id,), fetch_one=True)
        
        if not existing_disease:
            return False, "بیماری با این شناسه یافت نشد."
        
        query = """
        DELETE FROM diseases
        WHERE id = ?;
        """
        
        try:
            self.db_manager.execute_query(query, (disease_id,))
            return True, "بیماری با موفقیت حذف شد."
        except Exception as e:
            return False, f"خطا در حذف بیماری: {str(e)}"

        
class TherapySessionManager:
    def __init__(self, db_manager=None):
        self.db_manager = db_manager or DatabaseManager()
        self._initialize_session_table()
    
    def _initialize_session_table(self):
        """ایجاد جدول جلسات تراپی اگر وجود نداشته باشد"""
        try:
            # بررسی وجود جدول therapy_sessions
            check_table_query = """
            SELECT name FROM sqlite_master WHERE type='table' AND name='therapy_sessions';
            """
            table_exists = self.db_manager.execute_query(check_table_query, fetch_one=True)
            
            if not table_exists:
                # ایجاد جدول جلسات تراپی
                create_table_query = """
                CREATE TABLE therapy_sessions (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    patient_id INTEGER NOT NULL,
                    disease_id INTEGER NOT NULL,
                    session_date TEXT NOT NULL,
                    duration_minutes INTEGER NOT NULL,
                    duration_seconds INTEGER NOT NULL,
                    notes TEXT,
                    completed INTEGER DEFAULT 1,
                    FOREIGN KEY (patient_id) REFERENCES patients (id),
                    FOREIGN KEY (disease_id) REFERENCES diseases (id)
                );
                """
                self.db_manager.execute_query(create_table_query)
                print("جدول جلسات تراپی با موفقیت ایجاد شد.")
        
        except Exception as e:
            print(f"خطا در ایجاد جدول جلسات تراپی: {e}")
            raise
    
    def add_session(self, patient_id, disease_id, minutes, seconds, notes=""):
        """افزودن یک جلسه تراپی جدید"""
        try:
            # بررسی اعتبار پارامترها
            if patient_id <= 0:
                print(f"خطا: شناسه بیمار نامعتبر است: {patient_id}")
                return False, "شناسه بیمار نامعتبر است"
                
            if disease_id <= 0:
                print(f"خطا: شناسه بیماری نامعتبر است: {disease_id}")
                return False, "شناسه بیماری نامعتبر است"
            
            # بررسی وجود بیمار و بیماری
            patient_check = self.db_manager.execute_query(
                "SELECT id FROM patients WHERE id = ?", (patient_id,), fetch_one=True)
            if not patient_check:
                print(f"خطا: بیمار با شناسه {patient_id} یافت نشد")
                return False, "بیمار یافت نشد"
                
            disease_check = self.db_manager.execute_query(
                "SELECT id FROM diseases WHERE id = ?", (disease_id,), fetch_one=True)
            if not disease_check:
                print(f"خطا: بیماری با شناسه {disease_id} یافت نشد")
                return False, "بیماری یافت نشد"
            
            current_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            query = '''
            INSERT INTO therapy_sessions 
            (patient_id, disease_id, session_date, duration_minutes, duration_seconds, notes)
            VALUES (?, ?, ?, ?, ?, ?)
            '''
            
            self.db_manager.execute_query(query, 
                (patient_id, disease_id, current_date, minutes, seconds, notes))
            
            print(f"جلسه تراپی با موفقیت ثبت شد. بیمار: {patient_id}, درمان: {disease_id}")
            return True, "جلسه تراپی با موفقیت ثبت شد."
        except Exception as e:
            print(f"خطا در افزودن جلسه تراپی: {e}")
            return False, str(e)
    
    def get_patient_sessions(self, patient_id):
        """دریافت تمام جلسات یک بیمار"""
        try:
            query = '''
            SELECT 
                ts.id, 
                ts.session_date, 
                d.name AS disease_name, 
                ts.duration_minutes, 
                ts.duration_seconds, 
                ts.notes,
                ts.completed
            FROM therapy_sessions ts
            JOIN diseases d ON ts.disease_id = d.id
            WHERE ts.patient_id = ?
            ORDER BY ts.session_date DESC
            '''
            
            rows = self.db_manager.execute_query(query, (patient_id,))
            
            sessions = []
            for row in rows:
                sessions.append({
                    'id': row[0],
                    'session_date': row[1],
                    'disease_name': row[2],
                    'duration_minutes': row[3],
                    'duration_seconds': row[4],
                    'notes': row[5],
                    'completed': bool(row[6])
                })
            return sessions
        except Exception as e:
            print(f"خطا در دریافت جلسات بیمار: {e}")
            return []
    
    def get_session_details(self, session_id):
        """دریافت جزئیات یک جلسه"""
        try:
            query = '''
            SELECT 
                ts.id, 
                p.name AS patient_name,
                p.codemeli,
                d.name AS disease_name, 
                ts.session_date, 
                ts.duration_minutes, 
                ts.duration_seconds, 
                ts.notes,
                ts.completed
            FROM therapy_sessions ts
            JOIN patients p ON ts.patient_id = p.id
            JOIN diseases d ON ts.disease_id = d.id
            WHERE ts.id = ?
            '''
            
            row = self.db_manager.execute_query(query, (session_id,), fetch_one=True)
            if row:
                return {
                    'id': row[0],
                    'patient_name': row[1],
                    'national_id': row[2],
                    'disease_name': row[3],
                    'session_date': row[4],
                    'duration_minutes': row[5],
                    'duration_seconds': row[6],
                    'notes': row[7],
                    'completed': bool(row[8])
                }
            return None
        except Exception as e:
            print(f"خطا در دریافت جزئیات جلسه: {e}")
            return None
    
    def update_session(self, session_id, minutes, seconds, notes, completed=True):
        """به‌روزرسانی اطلاعات یک جلسه"""
        try:
            query = '''
            UPDATE therapy_sessions
            SET duration_minutes = ?, duration_seconds = ?, notes = ?, completed = ?
            WHERE id = ?
            '''
            
            self.db_manager.execute_query(query, 
                (minutes, seconds, notes, 1 if completed else 0, session_id))
            
            return True, "جلسه با موفقیت به‌روزرسانی شد."
        except Exception as e:
            print(f"خطا در به‌روزرسانی جلسه تراپی: {e}")
            return False, str(e)
    
    def delete_session(self, session_id):
        """حذف یک جلسه"""
        try:
            query = 'DELETE FROM therapy_sessions WHERE id = ?'
            self.db_manager.execute_query(query, (session_id,))
            return True, "جلسه با موفقیت حذف شد."
        except Exception as e:
            print(f"خطا در حذف جلسه تراپی: {e}")
            return False, str(e)