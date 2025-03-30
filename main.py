import os
import sys
from pathlib import Path
from datetime import datetime, timedelta 

from PySide6.QtCore import QObject, Signal, Slot, Property, QUrl, QCoreApplication
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from backend.logic import LoginManager
from backend.logger import Logger
from backend.logic import LoginManager
from backend.database import PatientManager, DiseaseManager, TherapySessionManager, DatabaseManager
#from PySide6.QtCore import QtMsgType, qInstallMessageHandler
from backend.relay_controller import RelayController

class Backend(QObject):
    # سیگنال‌ها برای ارتباط با QML
    loginSuccessful = Signal()
    loginFailed = Signal(str)
    
    def __init__(self):
        super().__init__()
        self._login_manager = LoginManager()
    
    @Slot()
    def exitApplication(self):
        print("Exiting application...")
        # انجام کارهای پاکسازی اگر نیاز است
        QCoreApplication.quit()  # بستن برنامه پایتون
    def cleanup_before_exit():
        print("Application is about to quit. Performing cleanup...")
        
        # انجام کارهای پاکسازی عمومی


    @Slot(int, result=bool)
    def validateOperatorCode(self, code):
        """بررسی اعتبار کد اپراتوری"""
        result, message = self._login_manager.validate_code(code)
        
        if result:
            self.loginSuccessful.emit()
        else:
            self.loginFailed.emit(message)
        
        return result
    
    @Slot(int)
    def saveOperatorCode(self, code):
        """ذخیره کد اپراتوری برای استفاده بعدی"""
        self._login_manager.save_code(code)


class PatientBackend(QObject):
    # سیگنال‌ها برای ارتباط با QML
    patientFound = Signal(str, str, int, int)  # کد ملی، نام، سن، جنسیت
    patientNotFound = Signal()  # سیگنال برای عدم یافتن بیمار
    errorOccurred = Signal(str)  # سیگنال برای خطا
    patientAdded = Signal(bool, str)  # سیگنال برای اضافه کردن بیمار
    patientUpdated = Signal(bool, str)  # سیگنال برای به‌روزرسانی بیمار
    patientDeleted = Signal(bool, str)  # سیگنال برای حذف بیمار
    
    def __init__(self):
        super().__init__()
        self._patient_manager = PatientManager()
        # اضافه کردن یک نمونه از TherapySessionManager برای استفاده در getPatientSessionsInfo
        self._session_manager = TherapySessionManager()
    
    @Slot(str)
    def searchPatient(self, codemeli):
        """جستجوی بیمار با کد ملی"""
        try:
            # جستجوی بیمار در دیتابیس
            patient = self._patient_manager.search_patient(codemeli)
            
            if patient:
                # ارسال اطلاعات بیمار به QML
                # patient[0]: codemeli, patient[1]: name, patient[2]: age, patient[3]: gender
                self.patientFound.emit(patient[0], patient[1], patient[2], patient[3])
                print(f"بیمار با کد ملی {codemeli} یافت شد.")
            else:
                # ارسال سیگنال عدم یافتن بیمار
                self.patientNotFound.emit()
                print(f"بیماری با کد ملی {codemeli} یافت نشد.")
        
        except Exception as e:
            error_msg = f"خطا در جستجوی بیمار: {str(e)}"
            print(error_msg)
            self.errorOccurred.emit(error_msg)
    
    @Slot(str, str, int, int)
    def addPatient(self, codemeli, name, age, gender):
        """افزودن بیمار جدید"""
        try:
            result, message = self._patient_manager.add_patient(str(codemeli), name, age, gender)
            self.patientAdded.emit(result, message)
            
            # اگر بیمار با موفقیت اضافه شد، اطلاعات آن را برگردانیم
            if result:
                self.searchPatient(codemeli)
            
        except Exception as e:
            error_msg = f"خطا در افزودن بیمار: {str(e)}"
            print(error_msg)
            self.errorOccurred.emit(error_msg)
    
    @Slot(str, str, int, int)
    def updatePatient(self, codemeli, name, age, gender):
        """به‌روزرسانی اطلاعات بیمار"""
        try:
            # اگر مقادیر خالی یا منفی باشند، None قرار می‌دهیم تا تغییر نکنند
            name_param = name if name else None
            age_param = age if age >= 0 else None
            gender_param = gender if gender >= 0 else None
            
            result, message = self._patient_manager.update_patient(
                codemeli, name_param, age_param, gender_param
            )
            self.patientUpdated.emit(result, message)
            
            # اگر بیمار با موفقیت به‌روز شد، اطلاعات جدید را برگردانیم
            if result:
                self.searchPatient(codemeli)
            
        except Exception as e:
            error_msg = f"خطا در به‌روزرسانی اطلاعات بیمار: {str(e)}"
            print(error_msg)
            self.errorOccurred.emit(error_msg)

    @Slot(str)
    def deletePatient(self, codemeli):
        """حذف بیمار"""
        try:
            result, message = self._patient_manager.delete_patient(codemeli)
            self.patientDeleted.emit(result, message)
            
        except Exception as e:
            error_msg = f"خطا در حذف بیمار: {str(e)}"
            print(error_msg)
            self.errorOccurred.emit(error_msg)

    @Slot(str, result=int)
    def getPatientIdByCodeMeli(self, codemeli):
        """دریافت شناسه بیمار با کد ملی"""
        try:
            query = "SELECT id FROM patients WHERE codemeli = ?"
            result = self._patient_manager.db_manager.execute_query(query, (codemeli,), fetch_one=True)
            if result:
                print(f"شناسه بیمار با کد ملی {codemeli}: {result[0]}")
                return result[0]
            print(f"بیماری با کد ملی {codemeli} یافت نشد")
            return 0
        except Exception as e:
            print(f"خطا در دریافت شناسه بیمار: {e}")
            return 0

# اضافه کردن کلاس جدید برای مدیریت بیماری‌ها
class DiseaseBackend(QObject):
    # سیگنال‌ها برای ارتباط با QML
    diseaseUpdated = Signal()  # سیگنال برای به‌روزرسانی لیست بیماری‌ها
    errorOccurred = Signal(str)  # سیگنال برای خطا
    
    def __init__(self):
        super().__init__()
        self._disease_manager = DiseaseManager()
    
    @Slot(str, result='QVariantMap')
    def getDiseaseInfo(self, disease_name):
        """دریافت اطلاعات یک بیماری با نام آن"""
        try:
            result = self._disease_manager.get_disease_info(disease_name)
            return result if result else {}
        except Exception as e:
            error_msg = f"خطا در دریافت اطلاعات بیماری: {str(e)}"
            print(error_msg)
            self.errorOccurred.emit(error_msg)
            return {}
    
    @Slot(result='QVariantList')
    def getAllDiseases(self):
        """دریافت لیست همه بیماری‌ها"""
        try:
            return self._disease_manager.get_all_diseases()
        except Exception as e:
            error_msg = f"خطا در دریافت لیست بیماری‌ها: {str(e)}"
            print(error_msg)
            self.errorOccurred.emit(error_msg)
            return []
    
    @Slot(str, str, int, int, result=bool)
    def addDisease(self, name, description, minutes, seconds):
        """اضافه کردن یک بیماری جدید"""
        try:
            result, message = self._disease_manager.add_disease(name, description, minutes, seconds)
            if result:
                self.diseaseUpdated.emit()
                print(f"بیماری '{name}' با موفقیت اضافه شد.")
            else:
                print(f"خطا در اضافه کردن بیماری: {message}")
                self.errorOccurred.emit(message)
            return result
        except Exception as e:
            error_msg = f"خطا در اضافه کردن بیماری: {str(e)}"
            print(error_msg)
            self.errorOccurred.emit(error_msg)
            return False
    
    @Slot(int, str, str, int, int, result=bool)
    def updateDisease(self, disease_id, name, description, minutes, seconds):
        """به‌روزرسانی اطلاعات یک بیماری"""
        try:
            result, message = self._disease_manager.update_disease(
                disease_id, name, description, minutes, seconds
            )
            if result:
                self.diseaseUpdated.emit()
                print(f"بیماری با شناسه {disease_id} با موفقیت به‌روز شد.")
            else:
                print(f"خطا در به‌روزرسانی بیماری: {message}")
                self.errorOccurred.emit(message)
            return result
        except Exception as e:
            error_msg = f"خطا در به‌روزرسانی بیماری: {str(e)}"
            print(error_msg)
            self.errorOccurred.emit(error_msg)
            return False
    
    @Slot(str, int, int, result=bool)
    def updateDiseaseTime(self, disease_name, minutes, seconds):
        """به‌روزرسانی زمان پیش‌فرض برای یک بیماری"""
        try:
            result, message = self._disease_manager.update_disease_time(disease_name, minutes, seconds)
            if result:
                self.diseaseUpdated.emit()
                print(f"زمان پیش‌فرض بیماری '{disease_name}' با موفقیت به‌روز شد.")
            else:
                print(f"خطا در به‌روزرسانی زمان بیماری: {message}")
                self.errorOccurred.emit(message)
            return result
        except Exception as e:
            error_msg = f"خطا در به‌روزرسانی زمان بیماری: {str(e)}"
            print(error_msg)
            self.errorOccurred.emit(error_msg)
            return False
    
    @Slot(int, result=bool)
    def deleteDisease(self, disease_id):
        """حذف یک بیماری"""
        try:
            result, message = self._disease_manager.delete_disease(disease_id)
            if result:
                self.diseaseUpdated.emit()
                print(f"بیماری با شناسه {disease_id} با موفقیت حذف شد.")
            else:
                print(f"خطا در حذف بیماری: {message}")
                self.errorOccurred.emit(message)
            return result
        except Exception as e:
            error_msg = f"خطا در حذف بیماری: {str(e)}"
            print(error_msg)
            self.errorOccurred.emit(error_msg)
            return False

class TherapySessionBackend(QObject):

    """کلاس واسط برای مدیریت جلسات تراپی در QML"""
    
    # سیگنال برای اعلام به‌روزرسانی جلسات
    sessionUpdated = Signal()
    
    def __init__(self):
        """مقداردهی اولیه"""
        super().__init__()
        # اتصال به دیتابیس
        self.session_manager = TherapySessionManager()
    
    @Slot(int, int, int, int, str, result=bool)
    def addSession(self, patient_id, disease_id, minutes, seconds, notes=""):
        """افزودن یک جلسه جدید"""
        print(f"درخواست افزودن جلسه: patient_id={patient_id}, disease_id={disease_id}, minutes={minutes}, seconds={seconds}")
        if patient_id <= 0 or disease_id <= 0:
            print("خطا: شناسه بیمار یا بیماری نامعتبر است")
            return False
            
        try:
            success, message = self.session_manager.add_session(patient_id, disease_id, minutes, seconds, notes)
            print(f"نتیجه افزودن جلسه: {success}, {message}")
            if success:
                self.sessionUpdated.emit()
            else:
                print(f"عدم اجرای success")
            return success
        except Exception as e:
            print(f"خطا در افزودن جلسه: {e}")
            return False
    
    @Slot(int, result='QVariantList')
    def getPatientSessions(self, patient_id):
        """دریافت لیست جلسات یک بیمار"""
        return self.session_manager.get_patient_sessions(patient_id)
    
    @Slot(int, result='QVariant')
    def getSessionDetails(self, session_id):
        """دریافت جزئیات یک جلسه"""
        return self.session_manager.get_session_details(session_id)
    
    @Slot(int, int, int, str, bool, result=bool)
    def updateSession(self, session_id, minutes, seconds, notes, completed=True):
        """به‌روزرسانی اطلاعات یک جلسه"""
        success, _ = self.session_manager.update_session(session_id, minutes, seconds, notes, completed)
        if success:
            self.sessionUpdated.emit()
        return success
    
    @Slot(int, result=bool)
    def deleteSession(self, session_id):
        """حذف یک جلسه"""
        success, _ = self.session_manager.delete_session(session_id)
        if success:
            self.sessionUpdated.emit()
        return success
        
    @Slot(int, result='QVariant')
    def getPatientSessionsInfo(self, patientId):
        """
        دریافت اطلاعات جلسات درمانی یک بیمار شامل تعداد کل جلسات
        
        :param patientId: شناسه بیمار
        :return: دیکشنری حاوی تعداد جلسات
        """
        try:
            # بررسی معتبر بودن شناسه بیمار
            if not patientId or patientId <= 0:
                print(f"Invalid patient ID: {patientId}")
                return {"count": 0}
                    
            # اجرای کوئری برای دریافت تعداد جلسات
            count_query = "SELECT COUNT(*) FROM therapy_sessions WHERE patient_id = ?"
            count_result = self.session_manager.db_manager.execute_query(count_query, (patientId,))
            print(f"getPatientSessionsInfo Result: {count_result}")
            
            # نتیجه به صورت تاپل است، اولین عنصر آن را می‌گیریم
            count = count_result[0][0] if count_result and len(count_result) > 0 else 0
            
            print(f"Found {count} sessions for patient {patientId}")
            return {"count": count}
                
        except Exception as e:
            print(f"Error in getPatientSessionsInfo: {e}")
            return {"count": 0}

class ReportBackend(QObject):
    """کلاس واسط برای گزارش‌گیری در QML"""
    
    def __init__(self):
        """مقداردهی اولیه"""
        #Logger.log("ReportBacked initialized . . .")
        super().__init__()
        self.db_manager = DatabaseManager()
    
    @Slot(result=int)
    def getTotalPatientCount(self):
        """دریافت تعداد کل بیماران"""
        query = "SELECT COUNT(*) FROM patients"
        result = self.db_manager.execute_query(query)
        return result[0][0] if result and len(result) > 0 else 0
    
    @Slot(result=int)
    def getTotalSessionCount(self):
        """دریافت تعداد کل جلسات"""
        query = "SELECT COUNT(*) FROM therapy_sessions"
        result = self.db_manager.execute_query(query)
        return result[0][0] if result and len(result) > 0 else 0
    
    @Slot(result=int)
    def getCurrentMonthSessionCount(self):
        """دریافت تعداد جلسات ماه جاری"""
        # محاسبه تاریخ اول ماه جاری
        now = datetime.now()
        first_day = datetime(now.year, now.month, 1).strftime("%Y-%m-%d")
        
        query = "SELECT COUNT(*) FROM therapy_sessions WHERE session_date >= ?"
        result = self.db_manager.execute_query(query, (first_day,))
        return result[0][0] if result and len(result) > 0 else 0
    
    @Slot(result='QVariantList')
    def getDiseaseDistribution(self):
        """دریافت توزیع انواع درمان"""
        query = """
            SELECT d.name, COUNT(*) as count 
            FROM therapy_sessions ts
            JOIN diseases d ON ts.disease_id = d.id
            GROUP BY d.name
            ORDER BY count DESC
        """
        result = self.db_manager.execute_query(query)
        
        distribution = []
        for row in result:
            distribution.append({"name": row[0], "count": row[1]})
        
        return distribution
    
    @Slot(result='QVariantList')
    def getWeeklySessionCount(self):
        """دریافت تعداد جلسات در هفته اخیر"""
        # محاسبه تاریخ 7 روز قبل
        now = datetime.now()
        seven_days_ago = (now - timedelta(days=7)).strftime("%Y-%m-%d")
        
        query = """
            SELECT strftime('%Y-%m-%d', session_date) as date, COUNT(*) as count 
            FROM therapy_sessions
            WHERE session_date >= ?
            GROUP BY date
            ORDER BY date
        """
        result = self.db_manager.execute_query(query, (seven_days_ago,))
        
        weekly_data = []
        for row in result:
            weekly_data.append({"date": row[0], "count": row[1]})
        
        return weekly_data
    
    @Slot(str, str, str, result='QVariantList')
    def getPatientsList(self, search="", gender=None, sort_by="name"):
        """دریافت لیست بیماران با فیلتر و مرتب‌سازی"""
        params = []
        where_clauses = []
        
        if search:
            where_clauses.append("(p.name LIKE ? OR p.codemeli LIKE ?)")
            params.extend([f"%{search}%", f"%{search}%"])
        
        if gender is not None and gender != "":
            where_clauses.append("p.gender = ?")
            params.append(int(gender))
        
        where_clause = " WHERE " + " AND ".join(where_clauses) if where_clauses else ""
        
        query = f"""
            SELECT p.id, p.name, p.codemeli, p.age, p.gender,
                   COUNT(ts.id) as session_count,
                   MAX(ts.session_date) as last_session
            FROM patients p
            LEFT JOIN therapy_sessions ts ON p.id = ts.patient_id
            {where_clause}
            GROUP BY p.id
            ORDER BY {sort_by}
        """
        
        result = self.db_manager.execute_query(query, params)
        
        patients = []
        for row in result:
            patients.append({
                "id": row[0],
                "name": row[1],
                "codemeli": row[2],
                "age": row[3],
                "gender": row[4],
                "sessionCount": row[5],
                "lastSession": row[6] if row[6] else ""
            })
        
        return patients
    
    @Slot(str, str, int, result='QVariantList')
    def getSessionsList(self, start_date=None, end_date=None, disease_id=None):
        """دریافت لیست جلسات با فیلتر"""
        params = []
        where_clauses = []
        
        if start_date:
            where_clauses.append("ts.session_date >= ?")
            params.append(start_date)
        
        if end_date:
            where_clauses.append("ts.session_date <= ?")
            params.append(end_date)
        
        if disease_id is not None and disease_id > 0:
            where_clauses.append("ts.disease_id = ?")
            params.append(disease_id)
        
        where_clause = " WHERE " + " AND ".join(where_clauses) if where_clauses else ""
        
        query = f"""
            SELECT ts.id, ts.session_date, p.name as patient_name, d.name as disease_name,
                   ts.duration_minutes, ts.duration_seconds, ts.completed
            FROM therapy_sessions ts
            JOIN patients p ON ts.patient_id = p.id
            JOIN diseases d ON ts.disease_id = d.id
            {where_clause}
            ORDER BY ts.session_date DESC
        """
        
        result = self.db_manager.execute_query(query, params)
        
        sessions = []
        for row in result:
            sessions.append({
                "id": row[0],
                "date": row[1],
                "patientName": row[2],
                "diseaseName": row[3],
                "duration": f"{row[4]}:{row[5]:02d}",
                "completed": bool(row[6])
            })
        
        return sessions
    
    @Slot(result='QVariantList')
    def getDiseaseStatistics(self):
        """دریافت آمار انواع درمان"""
        query = """
            SELECT d.id, d.name,
                   COUNT(DISTINCT ts.patient_id) as patient_count,
                   COUNT(ts.id) as session_count,
                   AVG(ts.duration_minutes) as avg_minutes
            FROM diseases d
            LEFT JOIN therapy_sessions ts ON d.id = ts.disease_id
            GROUP BY d.id
            ORDER BY session_count DESC
        """
        
        result = self.db_manager.execute_query(query)
        
        stats = []
        for row in result:
            avg_duration = round(row[4], 1) if row[4] is not None else 0
            stats.append({
                "id": row[0],
                "name": row[1],
                "patientCount": row[2],
                "sessionCount": row[3],
                "avgDuration": avg_duration
            })
        
        return stats
    @Slot(int, result='QVariantList')
    def getPatientSessions(self, patient_id):
        """دریافت جلسات مربوط به یک بیمار خاص"""
        try:
            query = """
                SELECT ts.id, ts.session_date, p.name as patient_name, d.name as disease_name,
                    ts.duration_minutes, ts.duration_seconds, ts.completed
                FROM therapy_sessions ts
                JOIN patients p ON ts.patient_id = p.id
                JOIN diseases d ON ts.disease_id = d.id
                WHERE ts.patient_id = ?
                ORDER BY ts.session_date DESC
            """
            
            result = self.db_manager.execute_query(query, (patient_id,))
            
            sessions = []
            for row in result:
                sessions.append({
                    "id": row[0],
                    "date": row[1],
                    "patientName": row[2],
                    "diseaseName": row[3],
                    "duration": f"{row[4]}:{row[5]:02d}",
                    "completed": bool(row[6])
                })
            
            return sessions
        except Exception as e:
            print(f"Error getting patient sessions: {str(e)}")
            return []
    @Slot(int, result='QVariantList')
    def getPatientDiseaseStatistics(self, patient_id):
        """دریافت آمار بیماری‌های یک بیمار خاص"""
        try:
            query = """
                SELECT d.id, d.name,
                    COUNT(ts.id) as session_count,
                    MIN(ts.session_date) as first_session,
                    MAX(ts.session_date) as last_session,
                    AVG(ts.duration_minutes) as avg_minutes,
                    SUM(ts.duration_minutes) as total_minutes
                FROM therapy_sessions ts
                JOIN diseases d ON ts.disease_id = d.id
                WHERE ts.patient_id = ?
                GROUP BY d.id
                ORDER BY session_count DESC
            """
            
            result = self.db_manager.execute_query(query, (patient_id,))
            print(f"PatientDiseaseStatistics Resule {result}")
            stats = []
            for row in result:
                avg_duration = round(row[5], 1) if row[5] is not None else 0
                total_duration = row[6] if row[6] is not None else 0
                
                stats.append({
                    "id": row[0],
                    "name": row[1],
                    "sessionCount": row[2],
                    "firstSession": row[3],
                    "lastSession": row[4],
                    "avgDuration": avg_duration,
                    "totalDuration": total_duration
                })
            print(f"stats {stats}")
            return stats
        except Exception as e:
            print(f"Error getting patient disease statistics: {str(e)}")
            return []

def main():
    # ایجاد برنامه
    app = QGuiApplication(sys.argv)
     # اتصال به سیگنال بسته شدن آخرین پنجره
    app.lastWindowClosed.connect(app.quit)
    # ایجاد موتور QML
    engine = QQmlApplicationEngine()
    # ایجاد نمونه از کنترلر رله
    relay_controller = RelayController()
    # ایجاد نمونه backend
    backend = Backend()
    patient_backend = PatientBackend()
    disease_backend = DiseaseBackend() 
    session_backend = TherapySessionBackend()
    logger = Logger()
    report_backend = ReportBackend()

    # قرار دادن backend در context موتور QML
    engine.rootContext().setContextProperty("backend", backend)
    engine.rootContext().setContextProperty("patientBackend", patient_backend)
    engine.rootContext().setContextProperty("diseaseBackend", disease_backend) 
    engine.rootContext().setContextProperty("sessionBackend", session_backend)
    engine.rootContext().setContextProperty("reportBackend", report_backend)
    engine.rootContext().setContextProperty("logger", logger)
    engine.rootContext().setContextProperty("relayController", relay_controller)
    # تنظیم مسیر فایل‌های QML
    qml_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "UntitledProject1Content")
    main_qml = os.path.join(qml_dir, "MainWindow.qml")
    print(main_qml)
    
    # بارگذاری فایل QML اصلی
    engine.load(QUrl.fromLocalFile(main_qml))
    
    # بررسی بارگذاری موفق
    if not engine.rootObjects():
        sys.exit(-1)

    # اجرای برنامه
    sys.exit(app.exec())

if __name__ == "__main__":
    main()