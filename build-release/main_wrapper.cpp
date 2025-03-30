// این فایل برای ایجاد یک اجرایی C++ است که برنامه پایتون را راه‌اندازی می‌کند
#include <QProcess>
#include <QCoreApplication>
#include <QDir>
#include <QDebug>

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    
    // مسیر نصب برنامه
    QString installDir = "/usr/local/share/plasma_therapy";
    
    // مسیر فایل اصلی پایتون
    QString pythonScript = installDir + "/main.py";
    
    // تنظیم دایرکتوری کاری
    QDir::setCurrent(installDir);
    
    // ایجاد پروسس برای اجرای پایتون
    QProcess process;
    QStringList arguments;
    arguments << pythonScript;
    
    // اضافه کردن آرگومان‌های خط فرمان به پایتون
    for (int i = 1; i < argc; ++i) {
        arguments << argv[i];
    }
    
    qDebug() << "راه‌اندازی برنامه پایتون:" << "python3" << arguments;
    
    // اجرای پایتون
    process.start("python3", arguments);
    
    // انتظار برای پایان اجرا
    process.waitForFinished(-1);
    
    return process.exitCode();
}
