// MainWindow.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

Window {
    id: mainWindow
    visible: true
    width: 800
    height: 600
    title: "Plasma Company"

    // این تابع هنگام بستن پنجره فراخوانی می‌شود
    Component.onDestruction: {
        backend.exitApplication()
    }

    // StackView برای مدیریت صفحات
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: loginPage
    }

    // کامپوننت صفحه ورود
    Component {
        id: loginPage
        LoginPage {
            onLoginSuccessful: {
                stackView.replace(appPage)
            }
        }
    }

    // کامپوننت صفحه اصلی برنامه
    Component {
        id: appPage
        AppPage {}
    }
}
