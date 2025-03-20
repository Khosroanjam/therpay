import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: newPatientRoot
    width: parent.width
    height: parent.height

    // پراپرتی‌های صفحه
    property string currentPatientCodemeli: ""
    property bool isEditMode: false
    property string patientName: ""
    property int patientAge: 0
    property int patientGender: 1
    property string searchedCodemeli: ""  // پراپرتی برای دریافت کد ملی جستجو شده

    Rectangle {
        anchors.fill: parent
        color: "#f5f5f5"

        // سربرگ صفحه
        Rectangle {
            id: header
            width: parent.width
            height: 60
            color: "#2196F3"

            // دکمه بازگشت
            Rectangle {
                id: backButton
                width: 40
                height: 40
                radius: 20
                color: backMouseArea.pressed ? "#1565C0" : "transparent"
                anchors {
                    right: parent.right
                    rightMargin: 10
                    verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "→"
                    font {
                        pixelSize: 24
                        bold: true
                    }
                    color: "white"
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: backMouseArea
                    anchors.fill: parent
                    onClicked: stackView.pop()
                }
            }

            // عنوان صفحه
            Text {
                text: newPatientRoot.isEditMode ? "ویرایش اطلاعات بیمار" : "ثبت بیمار جدید"
                font {
                    family: "Tahoma"
                    pixelSize: 18
                    bold: true
                }
                color: "white"
                anchors.centerIn: parent
            }
        }

        // فرم ورود اطلاعات
        Flickable {
            id: formFlickable
            anchors {
                top: header.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: 20
            }
            contentHeight: formColumn.height + 40
            clip: true

            ColumnLayout {
                id: formColumn
                width: parent.width
                spacing: 20

                // کارت اصلی فرم
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: formLayout.height + 40
                    color: "white"
                    radius: 8

                    // سایه برای کارت
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width + 6
                        height: parent.height + 6
                        radius: 8
                        color: "#20000000"
                        z: -1
                    }

                    // محتوای فرم
                    ColumnLayout {
                        id: formLayout
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                            margins: 20
                        }
                        spacing: 20

                        // عنوان فرم
                        Text {
                            text: "لطفاً اطلاعات بیمار را وارد کنید"
                            font {
                                family: "Tahoma"
                                pixelSize: 16
                                bold: true
                            }
                            color: "#424242"
                            Layout.alignment: Qt.AlignHCenter
                        }

                        // فیلد کد ملی
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Text {
                                text: "کد ملی:"
                                font {
                                    family: "Tahoma"
                                    pixelSize: 14
                                }
                                color: "#424242"
                            }

                            TextField {
                                id: codemeliField
                                Layout.fillWidth: true
                                height: 40
                                placeholderText: "کد ملی 10 رقمی"
                                inputMethodHints: Qt.ImhDigitsOnly
                                maximumLength: 10
                                enabled: !newPatientRoot.isEditMode

                                // تنظیم مستقیم مقدار text بر اساس حالت
                                text: isEditMode ? currentPatientCodemeli.toString() :
                                      (searchedCodemeli && searchedCodemeli.length > 0 ? searchedCodemeli : "")

                                Component.onCompleted: {
                                        if (isEditMode && currentPatientCodemeli) {
                                            console.log("Setting codemeli in edit mode:", currentPatientCodemeli)
                                            text = currentPatientCodemeli
                                        } else if (searchedCodemeli && searchedCodemeli.length > 0) {
                                            console.log("Setting searched codemeli:", searchedCodemeli)
                                            text = searchedCodemeli
                                        }
                                    }

                                font {
                                    family: "Tahoma"
                                    pixelSize: 14
                                }

                                background: Rectangle {
                                    color: codemeliField.enabled ? "white" : "#F5F5F5"
                                    border.color: codemeliField.focus ? "#2196F3" : "#E0E0E0"
                                    border.width: 1
                                    radius: 4
                                }

                                onTextChanged: {
                                    var newText = text.replace(/[^0-9]/g, "")
                                    if (newText !== text) {
                                        text = newText
                                    }
                                }
                            }

                            Text {
                                id: codemeliError
                                text: "کد ملی باید 10 رقم باشد"
                                color: "#F44336"
                                font {
                                    family: "Tahoma"
                                    pixelSize: 12
                                }
                                visible: false
                            }
                        }

                        // فیلد نام
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Text {
                                text: "نام و نام خانوادگی:"
                                font {
                                    family: "Tahoma"
                                    pixelSize: 14
                                }
                                color: "#424242"
                            }

                            TextField {
                                id: nameField
                                Layout.fillWidth: true
                                height: 40
                                placeholderText: "نام و نام خانوادگی بیمار"
                                text: isEditMode ? patientName : ""

                                font {
                                    family: "Tahoma"
                                    pixelSize: 14
                                }

                                background: Rectangle {
                                    color: "white"
                                    border.color: nameField.focus ? "#2196F3" : "#E0E0E0"
                                    border.width: 1
                                    radius: 4
                                }
                            }

                            Text {
                                id: nameError
                                text: "لطفاً نام و نام خانوادگی را وارد کنید"
                                color: "#F44336"
                                font {
                                    family: "Tahoma"
                                    pixelSize: 12
                                }
                                visible: false
                            }
                        }

                        // فیلد سن
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Text {
                                text: "سن:"
                                font {
                                    family: "Tahoma"
                                    pixelSize: 14
                                }
                                color: "#424242"
                            }

                            TextField {
                                id: ageField
                                Layout.fillWidth: true
                                height: 40
                                placeholderText: "سن بیمار"
                                inputMethodHints: Qt.ImhDigitsOnly
                                maximumLength: 3
                                text: isEditMode ? patientAge.toString() : ""

                                font {
                                    family: "Tahoma"
                                    pixelSize: 14
                                }

                                background: Rectangle {
                                    color: "white"
                                    border.color: ageField.focus ? "#2196F3" : "#E0E0E0"
                                    border.width: 1
                                    radius: 4
                                }

                                onTextChanged: {
                                    var newText = text.replace(/[^0-9]/g, "")
                                    if (newText !== text) {
                                        text = newText
                                    }
                                }
                            }
                        }

                        // فیلد جنسیت
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Text {
                                text: "جنسیت:"
                                font {
                                    family: "Tahoma"
                                    pixelSize: 14
                                }
                                color: "#424242"
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 20

                                RadioButton {
                                    id: maleRadio
                                    text: "مرد"
                                    checked: isEditMode ? (patientGender === 1) : true

                                    contentItem: Text {
                                        text: maleRadio.text
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 14
                                        }
                                        color: "#424242"
                                        leftPadding: maleRadio.indicator.width + 4
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                RadioButton {
                                    id: femaleRadio
                                    text: "زن"
                                    checked: isEditMode ? (patientGender === 0) : false

                                    contentItem: Text {
                                        text: femaleRadio.text
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 14
                                        }
                                        color: "#424242"
                                        leftPadding: femaleRadio.indicator.width + 4
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }
                        }

                        // پیام خطا
                        Text {
                            id: formError
                            text: ""
                            color: "#F44336"
                            font {
                                family: "Tahoma"
                                pixelSize: 14
                            }
                            Layout.alignment: Qt.AlignHCenter
                            visible: false
                        }

                        // دکمه ثبت
                        Button {
                            id: submitButton
                            text: newPatientRoot.isEditMode ? "به‌روزرسانی اطلاعات" : "ثبت بیمار"
                            Layout.preferredWidth: 200
                            Layout.preferredHeight: 50
                            Layout.alignment: Qt.AlignHCenter
                            Layout.topMargin: 10

                            font {
                                family: "Tahoma"
                                pixelSize: 16
                                bold: true
                            }

                            background: Rectangle {
                                color: submitButton.down ? "#388E3C" : "#4CAF50"
                                radius: 25

                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                            }

                            contentItem: Text {
                                text: submitButton.text
                                font: submitButton.font
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                // بررسی اعتبار فیلدها
                                var isValid = true

                                // بررسی کد ملی
                                if (!newPatientRoot.isEditMode) {
                                    if (codemeliField.text.length !== 10) {
                                        codemeliError.visible = true
                                        isValid = false
                                    } else {
                                        codemeliError.visible = false
                                    }
                                }

                                // بررسی نام
                                if (nameField.text.trim() === "") {
                                    nameError.visible = true
                                    isValid = false
                                } else {
                                    nameError.visible = false
                                }

                                if (isValid) {
                                    formError.visible = false

                                    // تعیین جنسیت (1 برای مرد، 0 برای زن)
                                    var gender = maleRadio.checked ? 1 : 0

                                    // ثبت یا به‌روزرسانی اطلاعات بیمار
                                    if (newPatientRoot.isEditMode) {
                                        patientBackend.updatePatient(
                                            newPatientRoot.currentPatientCodemeli,
                                            nameField.text.trim(),
                                            parseInt(ageField.text || "0"),
                                            gender
                                        )
                                    } else {
                                        patientBackend.addPatient(
                                            parseInt(codemeliField.text),
                                            nameField.text.trim(),
                                            parseInt(ageField.text || "0"),
                                            gender
                                        )
                                    }
                                } else {
                                    formError.text = "لطفاً اطلاعات را به درستی وارد کنید"
                                    formError.visible = true
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

        function onPatientAdded(success, message) {
            if (success) {
                // نمایش پیام موفقیت
                showToast(message)

                // بازگشت به صفحه قبل
                stackView.pop()

                // جستجوی بیمار تازه ثبت شده
                patientBackend.searchPatient(parseInt(codemeliField.text))
            } else {
                // نمایش پیام خطا
                formError.text = message
                formError.visible = true
            }
        }

        function onPatientUpdated(success, message) {
            if (success) {
                // نمایش پیام موفقیت
                showToast(message)

                // بازگشت به صفحه قبل
                stackView.pop()

                // جستجوی بیمار به‌روزرسانی شده
                patientBackend.searchPatient(newPatientRoot.currentPatientCodemeli)
            } else {
                // نمایش پیام خطا
                formError.text = message
                formError.visible = true
            }
        }
    }

    // کامپوننت نمایش پیام موقت (Toast)
    function showToast(message) {
        toast.text = message
        toast.opacity = 1
        toastTimer.start()
    }

    Rectangle {
        id: toast
        width: toastText.width + 40
        height: 50
        radius: 25
        color: "#323232"
        opacity: 0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20

        Text {
            id: toastText
            text: ""
            color: "white"
            font {
                family: "Tahoma"
                pixelSize: 14
            }
            anchors.centerIn: parent
        }

        Behavior on opacity {
            NumberAnimation { duration: 300 }
        }

        Timer {
            id: toastTimer
            interval: 3000
            onTriggered: toast.opacity = 0
        }
    }

    // وقتی صفحه نمایش داده می‌شود
    Component.onCompleted: {
        console.log("NewPatientPage loaded - isEditMode:", isEditMode,
                    "searchedCodemeli:", searchedCodemeli,
                    "currentPatientCodemeli:", currentPatientCodemeli)

        // اطمینان از اینکه پیام‌های خطا مخفی هستند
        formError.visible = false
        codemeliError.visible = false
        nameError.visible = false

        // اطلاعات دیباگ برای بررسی مقادیر
        console.log("Initial field values - codemeliField:", codemeliField.text,
                    "nameField:", nameField.text,
                    "ageField:", ageField.text)
    }
}
