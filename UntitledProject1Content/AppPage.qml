// AppPage.qml - بدون نیاز به QtGraphicalEffects
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: appPage
    anchors.fill: parent

    // رنگ‌های اصلی برنامه
    property color primaryColor: "#3F51B5"
    property color accentColor: "#FF4081"
    property color backgroundColor: "#F5F5F5"
    property color cardColor: "#FFFFFF"
    property color textColor: "#333333"

    Rectangle {
        anchors.fill: parent
        color: backgroundColor
    }

    // StackView داخلی برای مدیریت صفحات برنامه
    StackView {
        id: appStackView
        anchors.fill: parent
        initialItem: mainAppPage
    }

    // صفحه اصلی برنامه
    Component {
        id: mainAppPage
        Item {
            width: appStackView.width
            height: appStackView.height

            // نوار بالایی (هدر)
            Rectangle {
                id: headerBar
                width: parent.width
                height: 70
                color: primaryColor
                z: 2

                // سایه ساده برای هدر
                Rectangle {
                    anchors.top: parent.bottom
                    width: parent.width
                    height: 2
                    color: "#30000000"
                }

                Text {
                    text: "سیستم مدیریت بیماران"
                    color: "white"
                    font {
                        family: "Tahoma"
                        pixelSize: 22
                        bold: true
                    }
                    anchors.centerIn: parent
                }
            }

            // محتوای اصلی
            Flickable {
                anchors {
                    top: headerBar.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                contentHeight: mainColumn.height + 40
                clip: true

                ColumnLayout {
                    id: mainColumn
                    anchors {
                        top: parent.top
                        topMargin: 20
                        horizontalCenter: parent.horizontalCenter
                    }
                    width: parent.width * 0.9
                    spacing: 20

                    // کارت جستجوی بیمار
                    Rectangle {
                        id: searchCardShadow
                        Layout.fillWidth: true
                        Layout.preferredHeight: searchCard.height + 4
                        radius: 10
                        color: "#20000000"

                        Rectangle {
                            id: searchCard
                            anchors {
                                fill: parent
                                margins: 2
                            }
                            radius: 10
                            color: cardColor

                            ColumnLayout {
                                id: searchColumn
                                anchors {
                                    top: parent.top
                                    topMargin: 20
                                    horizontalCenter: parent.horizontalCenter
                                }
                                width: parent.width * 0.9
                                spacing: 15

                                // عنوان کارت
                                Text {
                                    text: "جستجوی بیمار"
                                    font {
                                        family: "Tahoma"
                                        pixelSize: 20
                                        bold: true
                                    }
                                    color: primaryColor
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                // توضیحات
                                Text {
                                    text: "لطفاً کد ملی بیمار را وارد کنید"
                                    font {
                                        family: "Tahoma"
                                        pixelSize: 14
                                    }
                                    color: "#757575"
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                // فیلد ورود کد ملی
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 80
                                    color: "#F9F9F9"
                                    radius: 8
                                    border.color: nationalIdField.focus ? primaryColor : "#E0E0E0"
                                    border.width: 1

                                    TextField {
                                        id: nationalIdField
                                        anchors {
                                            fill: parent
                                            margins: 5
                                        }
                                        placeholderText: "کد ملی را وارد کنید..."
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 18
                                        }
                                        color: textColor
                                        horizontalAlignment: TextInput.AlignHCenter
                                        verticalAlignment: TextInput.AlignVCenter
                                        inputMethodHints: Qt.ImhDigitsOnly
                                        maximumLength: 10

                                        background: Rectangle {
                                            color: "transparent"
                                        }

                                        // اعتبارسنجی دستی به جای RegExpValidator
                                        onTextChanged: {
                                            // حذف کاراکترهای غیر عددی
                                            var newText = text.replace(/[^0-9]/g, "")
                                            if (newText !== text) {
                                                text = newText
                                            }

                                            // پنهان کردن پیام خطا در صورت تغییر متن
                                            errorMessage.visible = false
                                        }
                                    }
                                }

                                // پیام خطا
                                Text {
                                    id: errorMessage
                                    text: ""
                                    color: "#F44336"
                                    font {
                                        family: "Tahoma"
                                        pixelSize: 14
                                    }
                                    visible: false
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                // دکمه جستجو
                                Rectangle {
                                    id: searchButtonShadow
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 70
                                    color: "#20000000"
                                    radius: 10

                                    Rectangle {
                                        id: searchButton
                                        anchors {
                                            fill: parent
                                            bottomMargin: searchMouseArea.pressed ? 1 : 3
                                            leftMargin: 2
                                            rightMargin: 2
                                            topMargin: 2
                                        }
                                        color: searchMouseArea.pressed ? Qt.darker(primaryColor, 1.2) : primaryColor
                                        radius: 10

                                        Text {
                                            text: "جستجو"
                                            color: "white"
                                            font {
                                                family: "Tahoma"
                                                pixelSize: 20
                                                bold: true
                                            }
                                            anchors.centerIn: parent
                                        }

                                        MouseArea {
                                            id: searchMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true

                                            onClicked: {
                                                if (nationalIdField.text.length === 10) {
                                                    errorMessage.visible = false
                                                    // فراخوانی تابع جستجوی بیمار در backend
                                                    patientBackend.searchPatient(nationalIdField.text)
                                                } else {
                                                    errorMessage.text = "کد ملی باید 10 رقم باشد"
                                                    errorMessage.visible = true
                                                }
                                            }
                                        }

                                        Behavior on color {
                                            ColorAnimation { duration: 100 }
                                        }
                                    }
                                }

                                // دکمه ثبت بیمار جدید
                                Rectangle {
                                    id: newPatientButtonShadow
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 70
                                    color: "#20000000"
                                    radius: 10

                                    Rectangle {
                                        id: newPatientButton
                                        anchors {
                                            fill: parent
                                            bottomMargin: newPatientMouseArea.pressed ? 1 : 3
                                            leftMargin: 2
                                            rightMargin: 2
                                            topMargin: 2
                                        }
                                        color: newPatientMouseArea.pressed ? Qt.darker(accentColor, 1.2) : accentColor
                                        radius: 10

                                        Text {
                                            text: "ثبت بیمار جدید"
                                            color: "white"
                                            font {
                                                family: "Tahoma"
                                                pixelSize: 20
                                                bold: true
                                            }
                                            anchors.centerIn: parent
                                        }

                                        MouseArea {
                                            id: newPatientMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true

                                            onClicked: {
                                                console.log("ثبت بیمار جدید")
                                                // باز کردن صفحه ثبت بیمار جدید
                                                var newPage = appStackView.push("NewPatientPage.qml", {
                                                    "isEditMode": false,
                                                    "searchedCodemeli": nationalIdField.text,
                                                    "stackView": appStackView
                                                })

                                                // اتصال به سیگنال بعد از push
                                                if (newPage) {
                                                    console.log("Successfully pushed NewPatientPage")
                                                    newPage.backRequested.connect(function() {
                                                        console.log("backRequested signal received from new patient page")
                                                        appStackView.pop()
                                                    })
                                                } else {
                                                    console.log("Failed to push NewPatientPage")
                                                }
                                            }
                                        }

                                        Behavior on color {
                                            ColorAnimation { duration: 100 }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // کارت اطلاعات بیمار - در ابتدا مخفی است
                    Rectangle {
                        id: patientInfoCardShadow
                        Layout.fillWidth: true
                        Layout.preferredHeight: infoColumn.height + 44
                        radius: 10
                        color: "#20000000"
                        visible: false
                        opacity: 0

                        Rectangle {
                            id: patientInfoCard
                            anchors {
                                fill: parent
                                margins: 2
                            }
                            radius: 10
                            color: cardColor

                            ColumnLayout {
                                id: infoColumn
                                anchors {
                                    top: parent.top
                                    topMargin: 20
                                    horizontalCenter: parent.horizontalCenter
                                }
                                width: parent.width * 0.9
                                spacing: 15

                                // عنوان کارت
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 50
                                    color: primaryColor
                                    radius: 8

                                    Text {
                                        text: "اطلاعات بیمار"
                                        color: "white"
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 18
                                            bold: true
                                        }
                                        anchors.centerIn: parent
                                    }
                                }

                                // اطلاعات بیمار
                                GridLayout {
                                    Layout.fillWidth: true
                                    columns: 2
                                    rowSpacing: 15
                                    columnSpacing: 15

                                    // کد ملی
                                    Text {
                                        text: "کد ملی:"
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 16
                                            bold: true
                                        }
                                        color: textColor
                                        Layout.alignment: Qt.AlignRight
                                    }

                                    Text {
                                        id: patientCodemeliText
                                        text: ""
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 16
                                        }
                                        color: textColor
                                    }

                                    // نام
                                    Text {
                                        text: "نام:"
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 16
                                            bold: true
                                        }
                                        color: textColor
                                        Layout.alignment: Qt.AlignRight
                                    }

                                    Text {
                                        id: patientNameText
                                        text: ""
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 16
                                        }
                                        color: textColor
                                    }

                                    // سن
                                    Text {
                                        text: "سن:"
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 16
                                            bold: true
                                        }
                                        color: textColor
                                        Layout.alignment: Qt.AlignRight
                                    }

                                    Text {
                                        id: patientAgeText
                                        text: ""
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 16
                                        }
                                        color: textColor
                                    }

                                    // جنسیت
                                    Text {
                                        text: "جنسیت:"
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 16
                                            bold: true
                                        }
                                        color: textColor
                                        Layout.alignment: Qt.AlignRight
                                    }

                                    Text {
                                        id: patientGenderText
                                        text: ""
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 16
                                        }
                                        color: textColor
                                    }
                                }

                                // دکمه ویرایش اطلاعات
                                Rectangle {
                                    id: editButtonShadow
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 70
                                    color: "#20000000"
                                    radius: 10

                                    Rectangle {
                                        id: editButton
                                        anchors {
                                            fill: parent
                                            bottomMargin: editMouseArea.pressed ? 1 : 3
                                            leftMargin: 2
                                            rightMargin: 2
                                            topMargin: 2
                                        }
                                        color: editMouseArea.pressed ? Qt.darker("#FFC107", 1.2) : "#FFC107"
                                        radius: 10

                                        Text {
                                            text: "ویرایش اطلاعات"
                                            color: "#212121"
                                            font {
                                                family: "Tahoma"
                                                pixelSize: 20
                                                bold: true
                                            }
                                            anchors.centerIn: parent
                                        }

                                        MouseArea {
                                            id: editMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true

                                            onClicked: {
                                                console.log("ویرایش اطلاعات بیمار")
                                                // باز کردن صفحه ویرایش بیمار
                                                var newPage = appStackView.push("NewPatientPage.qml", {
                                                    "isEditMode": true,
                                                    "currentPatientCodemeli": String(patientCodemeliText.text),
                                                    "patientName": patientNameText.text,
                                                    "patientAge": parseInt(patientAgeText.text),
                                                    "patientGender": patientGenderText.text === "مرد" ? 1 : 0,
                                                    "stackView": appStackView
                                                })

                                                // اتصال به سیگنال بعد از push
                                                if (newPage) {
                                                    console.log("Successfully pushed NewPatientPage for editing")
                                                    newPage.backRequested.connect(function() {
                                                        console.log("backRequested signal received from edit page")
                                                        appStackView.pop()
                                                    })
                                                }
                                            }
                                        }

                                        Behavior on color {
                                            ColorAnimation { duration: 100 }
                                        }
                                    }
                                }

                                // دکمه پلاسما تراپی
                                Rectangle {
                                    id: therapyButtonShadow
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 70
                                    color: "#20000000"
                                    radius: 10

                                    Rectangle {
                                        id: therapyButton
                                        anchors {
                                            fill: parent
                                            bottomMargin: therapyMouseArea.pressed ? 1 : 3
                                            leftMargin: 2
                                            rightMargin: 2
                                            topMargin: 2
                                        }
                                        color: therapyMouseArea.pressed ? Qt.darker("#4CAF50", 1.2) : "#4CAF50"
                                        radius: 10

                                        Text {
                                            text: "پلاسما تراپی"
                                            color: "white"
                                            font {
                                                family: "Tahoma"
                                                pixelSize: 20
                                                bold: true
                                            }
                                            anchors.centerIn: parent
                                        }

                                        MouseArea {
                                            id: therapyMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true

                                            onClicked: {
                                                console.log("ثبت نوبت جدید برای بیمار با کد ملی:", patientCodemeliText.text)
                                                // باز کردن صفحه PlasmaTherapy.qml
                                                var therapyPage = appStackView.push("PlasmaTherapy.qml", {
                                                    "patientCodemeli": patientCodemeliText.text,
                                                    "patientName": patientNameText.text,
                                                    "patientAge": parseInt(patientAgeText.text || "0"),
                                                    "patientGender": patientGenderText.text === "مرد" ? 1 : 0,
                                                    "stackView": appStackView
                                                })

                                                // اتصال به سیگنال بعد از push
                                                if (therapyPage && therapyPage.backRequested) {
                                                    therapyPage.backRequested.connect(function() {
                                                        console.log("backRequested signal received from therapy page")
                                                        appStackView.pop()
                                                    })
                                                }
                                            }
                                        }

                                        Behavior on color {
                                            ColorAnimation { duration: 100 }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // اتصال به سیگنال‌های patientBackend
            Connections {
                target: patientBackend

                function onPatientFound(codemeli, name, age, gender) {
                    console.log("Patient found signal received:", codemeli, name, age, gender)

                    // پر کردن فیلدهای اطلاعات بیمار
                    patientCodemeliText.text = codemeli
                    patientNameText.text = name
                    patientAgeText.text = age.toString()
                    patientGenderText.text = gender === 1 ? "مرد" : "زن"

                    // نمایش کارت اطلاعات بیمار
                    patientInfoCardShadow.visible = true

                    // انیمیشن نمایش اطلاعات
                    patientInfoCardAnimation.start()
                }

                function onPatientNotFound() {
                    console.log("Patient not found signal received")

                    // نمایش پیام خطا
                    errorMessage.text = "بیماری با این کد ملی یافت نشد"
                    errorMessage.visible = true

                    // مخفی کردن کارت اطلاعات بیمار
                    patientInfoCardShadow.visible = false
                }

                function onErrorOccurred(errorMessage) {
                    console.log("Error occurred:", errorMessage)

                    // نمایش پیام خطا
                    errorMessage.text = errorMessage
                    errorMessage.visible = true
                }
            }

            // انیمیشن نمایش کارت اطلاعات بیمار
            NumberAnimation {
                id: patientInfoCardAnimation
                target: patientInfoCardShadow
                property: "opacity"
                from: 0.0
                to: 1.0
                duration: 300
                easing.type: Easing.OutQuad
            }
        }
    }
}
