import os
import sys
from pathlib import Path

from PySide6.QtCore import QObject, Signal, Slot, Property, QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from backend.logic import LoginManager

from backend.logic import LoginManager
from backend.database import PatientManager

class Backend(QObject):
    # سیگنال‌ها برای ارتباط با QML
    loginSuccessful = Signal()
    loginFailed = Signal(str)
    
    def __init__(self):
        super().__init__()
        self._login_manager = LoginManager()
    
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

def main():
    # ایجاد برنامه
    app = QGuiApplication(sys.argv)
    
    # ایجاد موتور QML
    engine = QQmlApplicationEngine()
    
    # ایجاد نمونه backend
    backend = Backend()
    patient_backend = PatientBackend()
    # قرار دادن backend در context موتور QML
    engine.rootContext().setContextProperty("backend", backend)
    engine.rootContext().setContextProperty("patientBackend", patient_backend)

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