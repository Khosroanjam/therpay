// LoginPage.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: loginPage
    anchors.fill: parent

    // سیگنال برای اعلام ورود موفق
    signal loginSuccessful()

    // ColumnLayout برای تقسیم صفحه به دو بخش عمودی
    ColumnLayout {
        anchors.fill: parent
        spacing: 0 // بدون فاصله بین دو بخش

        // بخش بالا (50٪)
        Rectangle {
            id: topSection
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.5
            Image {
                id: logo
                source: "images/plasma-logo.png"
                anchors.centerIn: parent
                fillMode: Image.PreserveAspectFit
                width: parent.width * 0.6
                height: parent.height * 0.6
            }
        }

        // بخش پایین (50٪)
        Rectangle {
            id: bottomSection
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.5

            // استفاده از ColumnLayout برای قرار دادن TextField و دکمه
            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width * 0.8
                spacing: 30 // فاصله بین TextField و دکمه

                // TextBox مدرن
                Rectangle {
                    id: background
                    Layout.fillWidth: true
                    height: 120
                    radius: 8
                    color: "transparent"

                    // TextBox مدرن با افکت Material Design
                    TextField {
                        id: modernTextField
                        width: parent.width - 20
                        height: 50
                        anchors.centerIn: parent
                        placeholderText: "کد اپراتوری خود را وارد کنید"
                        font.pixelSize: 16
                        font.family: "Tahoma"
                        horizontalAlignment: TextInput.AlignHCenter
                        selectByMouse: true

                        // رنگ متن
                        color: "#333333"
                        placeholderTextColor: "#aaaaaa"

                        // حذف حاشیه پیش‌فرض
                        background: Rectangle {
                            color: "transparent"

                            // خط زیر متن
                            Rectangle {
                                id: underline
                                width: parent.width
                                height: 2
                                color: modernTextField.focus ? "#2196F3" : "#e0e0e0"
                                anchors.bottom: parent.bottom

                                Behavior on color {
                                    ColorAnimation { duration: 200 }
                                }
                            }
                        }

                        // لیبل شناور
                        Text {
                            id: floatingLabel
                            text: "اپراتور"
                            color: modernTextField.focus ? "#2196F3" : "#757575"
                            font.pixelSize: modernTextField.text.length > 0 || modernTextField.focus ? 12 : 16
                            anchors.bottom: modernTextField.text.length > 0 || modernTextField.focus ?
                                            modernTextField.top : modernTextField.verticalCenter
                            anchors.bottomMargin: modernTextField.text.length > 0 || modernTextField.focus ? 25 : 20
                            anchors.horizontalCenter: parent.horizontalCenter

                            Behavior on font.pixelSize {
                                NumberAnimation { duration: 200 }
                            }
                            Behavior on anchors.bottomMargin {
                                NumberAnimation { duration: 200 }
                            }
                            Behavior on anchors.bottom {
                                AnchorAnimation { duration: 200 }
                            }
                            Behavior on color {
                                ColorAnimation { duration: 200 }
                            }
                        }
                    }

                    // پیام خطا
                    Text {
                        id: errorMessage
                        anchors.top: modernTextField.bottom
                        anchors.topMargin: 5
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "#f44336"
                        font.pixelSize: 14
                        font.family: "Tahoma"
                        visible: false
                    }
                }

                // دکمه مدرن
                Item {
                    id: buttonContainer
                    Layout.preferredWidth: parent.width * 0.5
                    Layout.preferredHeight: 50
                    Layout.alignment: Qt.AlignHCenter

                    Rectangle {
                        anchors.fill: parent
                        anchors.topMargin: 2
                        anchors.leftMargin: 2
                        anchors.rightMargin: 2
                        anchors.bottomMargin: 2
                        radius: 25
                        color: "#20000000"
                        visible: !loginButton.down
                    }

                    Button {
                        id: loginButton
                        text: "ورود"
                        anchors.fill: parent
                        font {
                            family: "Tahoma"
                            pixelSize: 16
                            bold: true
                        }

                        // شخصی‌سازی ظاهر دکمه
                        background: Rectangle {
                            id: buttonBg
                            color: loginButton.down ? "#1565C0" : "#2196F3"
                            radius: 25

                            // انیمیشن تغییر رنگ
                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                        }

                        // افکت موج دایره‌ای هنگام کلیک
                        Rectangle {
                            id: ripple
                            property real size: 0
                            property real xPosition: width / 2
                            property real yPosition: height / 2

                            x: xPosition - size/2
                            y: yPosition - size/2
                            height: size
                            width: size
                            radius: size/2
                            color: "white"
                            opacity: 0

                            NumberAnimation {
                                id: rippleAnimation
                                target: ripple
                                property: "size"
                                from: 0
                                to: loginButton.width * 2
                                duration: 300
                                easing.type: Easing.OutQuad
                            }

                            NumberAnimation {
                                id: opacityAnimation
                                target: ripple
                                property: "opacity"
                                from: 0.3
                                to: 0
                                duration: 300
                                easing.type: Easing.OutQuad
                            }
                        }

                        // رنگ متن دکمه
                        contentItem: Text {
                            text: loginButton.text
                            font: loginButton.font
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        // افکت تغییر اندازه هنگام کلیک
                        transform: Scale {
                            id: buttonScale
                            origin.x: loginButton.width / 2
                            origin.y: loginButton.height / 2
                            xScale: loginButton.pressed ? 0.95 : 1.0
                            yScale: loginButton.pressed ? 0.95 : 1.0

                            Behavior on xScale {
                                NumberAnimation { duration: 100 }
                            }
                            Behavior on yScale {
                                NumberAnimation { duration: 100 }
                            }
                        }

                        onPressedChanged: {
                            if (pressed) {
                                rippleAnimation.start()
                                opacityAnimation.start()
                            }
                        }

                        // فراخوانی تابع backend برای بررسی اعتبار کد
                        onClicked: {
                            if (backend) {
                                if (backend.validateOperatorCode(modernTextField.text)) {
                                    loginSuccessful()
                                }
                            } else {
                                console.error("Backend is not available")
                            }
                        }
                    }
                }
            }
        }
    }

    // اتصال سیگنال‌های backend به توابع QML
    Connections {
        target: backend

        // هنگام خطا در ورود
        function onLoginFailed(message) {
            errorMessage.text = message
            errorMessage.visible = true
        }
    }
}
