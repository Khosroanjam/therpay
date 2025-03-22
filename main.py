import os
import sys
from pathlib import Path

from PySide6.QtCore import QObject, Signal, Slot, Property, QUrl, QCoreApplication
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from backend.logic import LoginManager
from backend.logger import Logger
from backend.logic import LoginManager
from backend.database import PatientManager, DiseaseManager, TherapySessionManager
#from PySide6.QtCore import QtMsgType, qInstallMessageHandler


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

def main():
    # ایجاد برنامه
    app = QGuiApplication(sys.argv)
     # اتصال به سیگنال بسته شدن آخرین پنجره
    app.lastWindowClosed.connect(app.quit)
    # ایجاد موتور QML
    engine = QQmlApplicationEngine()
    
    # ایجاد نمونه backend
    backend = Backend()
    patient_backend = PatientBackend()
    disease_backend = DiseaseBackend() 
    session_backend = TherapySessionBackend()
    logger = Logger()

    # قرار دادن backend در context موتور QML
    engine.rootContext().setContextProperty("backend", backend)
    engine.rootContext().setContextProperty("patientBackend", patient_backend)
    engine.rootContext().setContextProperty("diseaseBackend", disease_backend) 
    engine.rootContext().setContextProperty("sessionBackend", session_backend)
    engine.rootContext().setContextProperty("logger", logger)

  


    # تنظیم مسیر فایل‌های QML
    qml_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "UntitledProject1Content")
    main_qml = os.path.join(qml_dir, "Main.qml")
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