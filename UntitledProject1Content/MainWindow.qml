// MainWindow.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

Window {
    id: mainWindow
    visible: true
    width: 800
    height: 700
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

    // کیبورد مجازی در سطح برنامه
       VirtualKeyboard {
           id: globalKeyboard
           anchors.bottom: parent.bottom
           visible: false
           z: 1000
       }

       // تابع سراسری برای نمایش کیبورد
       function showKeyboard(textField) {
           globalKeyboard.attachTo(textField)
           globalKeyboard.visible = true
       }

    // کامپوننت صفحه ورود
       Component {
           id: loginPage
           LoginPage {
               onLoginSuccessful: {
                   var appPageComponent = stackView.push("AppPage.qml")
                   // ارسال کیبورد مجازی به AppPage
                   if (appPageComponent) {
                       appPageComponent.globalKeyboard = globalKeyboard
                   }
               }
           }
       }

    // کامپوننت صفحه اصلی برنامه
    Component {
        id: appPage
        AppPage {}
    }
}
