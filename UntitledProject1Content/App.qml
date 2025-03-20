import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15


Window {
    id: rootWindow
    visible: true
    width: 800
    height: 600
    title: "Plasma Company"

    // StackView برای مدیریت صفحات مختلف
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: mainPage
    }

    // صفحه اصلی به عنوان یک کامپوننت
    Component {
        id: mainPage
        Item {
            width: rootWindow.width
            height: rootWindow.height
            ColumnLayout {
                anchors.fill: parent
                spacing: 1

                // قسمت دریافت کد ملی بیمار
                Rectangle {
                    id: recGivePatientMeliNumber
                    Layout.preferredHeight: parent.height * 0.5
                    Layout.preferredWidth: parent.width
                    color: "#f5f5f5"  // رنگ پس زمینه روشن

                    // سایه برای کارت اصلی
                    Rectangle {
                        id: cardShadow
                        anchors.centerIn: parent
                        width: patientCard.width + 6
                        height: patientCard.height + 6
                        radius: 8
                        color: "#20000000"
                    }

                    // کارت اصلی برای دریافت کد ملی
                    Rectangle {
                        id: patientCard
                        anchors.centerIn: parent
                        width: parent.width * 0.8
                        height: parent.height * 0.8
                        radius: 8
                        color: "white"

                        ColumnLayout {
                            anchors.centerIn: parent
                            width: parent.width * 0.8
                            spacing: 20

                            // عنوان
                            Text {
                                text: "ورود اطلاعات بیمار"
                                font {
                                    family: "Tahoma"
                                    pixelSize: 22
                                    bold: true
                                }
                                color: "#2196F3"
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

                            // ورودی کد ملی با طراحی مدرن
                            Rectangle {
                                id: inputContainer
                                Layout.preferredWidth: parent.width
                                Layout.preferredHeight: 70
                                color: "transparent"

                                TextField {
                                    id: nationalIdField
                                    anchors {
                                        left: parent.left
                                        right: parent.right
                                        verticalCenter: parent.verticalCenter

                                    }
                                    height: 70

                                    placeholderText: "2722665379"
                                    inputMethodHints: Qt.ImhDigitsOnly  // فقط اعداد
                                    maximumLength: 10
                                    topPadding: 30
                                    bottomPadding: 10
                                    // اعتبارسنجی دستی به جای RegExpValidator
                                    onTextChanged: {
                                        // حذف کاراکترهای غیر عددی
                                        var newText = text.replace(/[^0-9]/g, "")
                                        if (newText !== text) {
                                            text = newText
                                        }
                                    }

                                    font {
                                        family: "Tahoma"
                                        pixelSize: 16
                                    }

                                    color: "#212121"
                                    selectionColor: "#B3E5FC"
                                    selectedTextColor: "#01579B"

                                    horizontalAlignment: TextInput.AlignHCenter
                                    verticalAlignment: TextInput.AlignVCenter

                                    background: Rectangle {
                                        color: "transparent"

                                        Rectangle {
                                            width: parent.width
                                            height: 2
                                            color: nationalIdField.focus ? "#2196F3" : "#E0E0E0"
                                            anchors.bottom: parent.bottom

                                            Behavior on color {
                                                ColorAnimation { duration: 200 }
                                            }
                                        }
                                    }

                                    // افکت لیبل شناور
                                    Text {
                                        id: floatingLabel
                                        text: "کد ملی"
                                        color: nationalIdField.focus ? "#2196F3" : "#757575"
                                        font {
                                            family: "Tahoma"
                                            pixelSize: nationalIdField.text.length > 0 || nationalIdField.focus ? 12 : 16
                                        }
                                        anchors {
                                            bottom: nationalIdField.text.length > 0 || nationalIdField.focus ?
                                                   nationalIdField.top : nationalIdField.verticalCenter
                                            bottomMargin: nationalIdField.text.length > 0 || nationalIdField.focus ? 8 : 0
                                            horizontalCenter: parent.horizontalCenter
                                        }

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

                                    // نمایش پیام خطا
                                    Text {
                                        id: errorText
                                        anchors {
                                            top: nationalIdField.bottom
                                            topMargin: 4
                                            horizontalCenter: parent.horizontalCenter
                                        }
                                        color: "#F44336"
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 12
                                        }
                                        visible: false
                                    }

                                    // اعتبارسنجی کد ملی هنگام خروج از فیلد
                                    onEditingFinished: {
                                        if (text.length > 0 && text.length < 10) {
                                            errorText.text = "کد ملی باید 10 رقم باشد"
                                            errorText.visible = true
                                        } else {
                                            errorText.visible = false
                                        }
                                    }
                                }
                            }

                            // دکمه جستجو با طراحی مدرن
                            Item {
                                id: buttonContainer
                                Layout.preferredWidth: parent.width * 0.4
                                Layout.preferredHeight: 50
                                Layout.alignment: Qt.AlignHCenter
                                Layout.topMargin: 10

                                // سایه دکمه
                                Rectangle {
                                    anchors.fill: parent
                                    anchors.topMargin: 2
                                    anchors.leftMargin: 2
                                    anchors.rightMargin: 2
                                    anchors.bottomMargin: 2
                                    radius: 25
                                    color: "#20000000"
                                    visible: !searchButton.down
                                }

                                Button {
                                    id: searchButton
                                    anchors.fill: parent
                                    text: "جستجوی بیمار"
                                    font {
                                        family: "Tahoma"
                                        pixelSize: 16
                                        bold: true
                                    }

                                    background: Rectangle {
                                        id: buttonBg
                                        color: searchButton.down ? "#1565C0" : "#2196F3"
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
                                        property real xPosition
                                        property real yPosition

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
                                            to: searchButton.width * 2
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

                                    contentItem: Text {
                                        text: searchButton.text
                                        font: searchButton.font
                                        color: "white"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        elide: Text.ElideRight
                                    }

                                    // افکت تغییر اندازه هنگام کلیک
                                    transform: Scale {
                                        id: buttonScale
                                        origin.x: searchButton.width / 2
                                        origin.y: searchButton.height / 2
                                        xScale: searchButton.pressed ? 0.95 : 1.0
                                        yScale: searchButton.pressed ? 0.95 : 1.0

                                        Behavior on xScale {
                                            NumberAnimation { duration: 100 }
                                        }
                                        Behavior on yScale {
                                            NumberAnimation { duration: 100 }
                                        }
                                    }

                                    onPressed: {
                                        ripple.xPosition = mouseX
                                        ripple.yPosition = mouseY
                                        rippleAnimation.start()
                                        opacityAnimation.start()
                                    }

                                    onClicked: {
                                        if (nationalIdField.text.length === 10) {
                                            errorText.visible = false
                                            // فراخوانی تابع جستجوی بیمار در backend
                                            patientBackend.searchPatient((nationalIdField.text))
                                        } else {
                                            errorText.text = "کد ملی باید 10 رقم باشد"
                                            errorText.visible = true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // قسمت نمایش اطلاعات بیمار
                Rectangle {
                    id: recshowInfo
                    Layout.preferredHeight: parent.height * 0.5
                    Layout.preferredWidth: parent.width
                    color: "#FAFAFA"  // رنگ پس زمینه روشن‌تر

                    // کارت اطلاعات بیمار
                    Rectangle {
                        id: patientInfoCard
                        anchors.centerIn: parent
                        width: parent.width * 0.8
                        height: parent.height * 0.8
                        radius: 8
                        color: "white"
                        visible: false  // در ابتدا مخفی است

                        // سایه برای کارت
                        Rectangle {
                            anchors.centerIn: parent
                            width: patientInfoCard.width + 6
                            height: patientInfoCard.height + 6
                            radius: 8
                            color: "#20000000"
                            z: -1
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 15

                            // عنوان کارت
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                color: "#2196F3"
                                radius: 4

                                Text {
                                    anchors.centerIn: parent
                                    text: "اطلاعات بیمار"
                                    font {
                                        family: "Tahoma"
                                        pixelSize: 18
                                        bold: true
                                    }
                                    color: "white"
                                }
                            }

                            // اطلاعات بیمار
                            GridLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                columns: 2
                                rowSpacing: 20
                                columnSpacing: 20

                                // کد ملی
                                Text {
                                    text: "کد ملی:"
                                    font {
                                        family: "Tahoma"
                                        pixelSize: 14
                                        bold: true
                                    }
                                    color: "#424242"
                                    Layout.alignment: Qt.AlignRight
                                }

                                Text {
                                    id: patientCodemeliText
                                    text: ""
                                    font {
                                        family: "Tahoma"
                                        pixelSize: 14
                                    }
                                    color: "#212121"
                                }

                                // نام
                                Text {
                                    text: "نام:"
                                    font {
                                        family: "Tahoma"
                                        pixelSize: 14
                                        bold: true
                                    }
                                    color: "#424242"
                                    Layout.alignment: Qt.AlignRight
                                }

                                Text {
                                    id: patientNameText
                                    text: ""
                                    font {
                                        family: "Tahoma"
                                        pixelSize: 14
                                    }
                                    color: "#212121"
                                }

                                // سن
                                Text {
                                    text: "سن:"
                                    font {
                                        family: "Tahoma"
                                        pixelSize: 14
                                        bold: true
                                    }
                                    color: "#424242"
                                    Layout.alignment: Qt.AlignRight
                                }

                                Text {
                                    id: patientAgeText
                                    text: ""
                                    font {
                                        family: "Tahoma"
                                        pixelSize: 14
                                    }
                                    color: "#212121"
                                }

                                // جنسیت
                                Text {
                                    text: "جنسیت:"
                                    font {
                                        family: "Tahoma"
                                        pixelSize: 14
                                        bold: true
                                    }
                                    color: "#424242"
                                    Layout.alignment: Qt.AlignRight
                                }

                                Text {
                                    id: patientGenderText
                                    text: ""
                                    font {
                                        family: "Tahoma"
                                        pixelSize: 14
                                    }
                                    color: "#212121"
                                }
                            }

                            // دکمه‌های عملیات
                            RowLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 20

                                // دکمه ویرایش اطلاعات
                                Button {
                                    id: editButton
                                    text: "ویرایش اطلاعات"
                                    font {
                                        family: "Tahoma"
                                        pixelSize: 14
                                    }

                                    background: Rectangle {
                                        color: editButton.down ? "#FFA000" : "#FFC107"
                                        radius: 4

                                        Behavior on color {
                                            ColorAnimation { duration: 150 }
                                        }
                                    }

                                    contentItem: Text {
                                        text: editButton.text
                                        font: editButton.font
                                        color: "#212121"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    onClicked: {
                                        console.log("ویرایش اطلاعات بیمار")
                                        // باز کردن صفحه ویرایش بیمار
                                        stackView.push("NewPatientPage.qml",
                                        {
                                            "isEditMode": true,
                                            "currentPatientCodemeli": String(patientCodemeliText.text),
                                            "patientName": patientNameText.text,
                                            "patientAge": parseInt(patientAgeText.text),
                                            "patientGender": patientGenderText.text === "مرد" ? 1 : 0
                                        })
                                    }
                                }

                                // دکمه ثبت پلاسما تراپی
                                Button {
                                    id: newAppointmentButton
                                    text: "پلاسما تراپی"
                                    font {
                                        family: "Tahoma"
                                        pixelSize: 14
                                    }

                                    background: Rectangle {
                                        color: newAppointmentButton.down ? "#388E3C" : "#4CAF50"
                                        radius: 4

                                        Behavior on color {
                                            ColorAnimation { duration: 150 }
                                        }
                                    }

                                    contentItem: Text {
                                        text: newAppointmentButton.text
                                        font: newAppointmentButton.font
                                        color: "white"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    onClicked: {
                                           console.log("ثبت نوبت جدید برای بیمار با کد ملی:", patientCodemeliText.text)

                                           // باز کردن صفحه PlasmaTherapy.qml
                                           var component = Qt.createComponent("PlasmaTherapy.qml")
                                           if (component.status === Component.Ready) {
                                               var plasmaTherapyPage = component.createObject(null, {
                                                   "patientCodemeli": patientCodemeliText.text,
                                                   "patientName": patientNameText.text,
                                                   "patientAge": parseInt(patientAgeText.text || "0"),
                                                   "patientGender": patientGenderText.text === "مرد" ? 1 : 0
                                               })

                                               // اتصال سیگنال بازگشت
                                               plasmaTherapyPage.goBack.connect(function() {
                                                   console.log("بازگشت از صفحه پلاسما تراپی")
                                                   stackView.pop()
                                               })

                                               stackView.push(plasmaTherapyPage)
                                           } else if (component.status === Component.Error) {
                                               console.error("خطا در بارگذاری PlasmaTherapy.qml:", component.errorString())
                                           }
                                       }
                                }
                            }
                        }
                    }

                    // کارت عدم یافتن بیمار
                    Rectangle {
                        id: patientNotFoundCard
                        anchors.centerIn: parent
                        width: parent.width * 0.7
                        height: parent.height * 0.4
                        radius: 8
                        color: "white"
                        visible: false  // در ابتدا مخفی است

                        // سایه برای کارت
                        Rectangle {
                            anchors.centerIn: parent
                            width: patientNotFoundCard.width + 6
                            height: patientNotFoundCard.height + 6
                            radius: 8
                            color: "#20000000"
                            z: -1
                        }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 20

                            // آیکون هشدار
                            Text {
                                text: "⚠️"
                                font.pixelSize: 48
                                Layout.alignment: Qt.AlignHCenter
                            }

                            // پیام خطا
                            Text {
                                text: "بیماری با این کد ملی یافت نشد!"
                                font {
                                    family: "Tahoma"
                                    pixelSize: 18
                                    bold: true
                                }
                                color: "#F44336"
                                Layout.alignment: Qt.AlignHCenter
                            }

                            // توضیحات
                            Text {
                                text: "می‌توانید با کلیک بر روی دکمه زیر، بیمار جدیدی ثبت کنید."
                                font {
                                    family: "Tahoma"
                                    pixelSize: 14
                                }
                                color: "#757575"
                                Layout.alignment: Qt.AlignHCenter
                            }

                            // دکمه ثبت بیمار جدید
                            Button {
                                id: newPatientButton
                                text: "ثبت بیمار جدید"
                                font {
                                    family: "Tahoma"
                                    pixelSize: 14
                                }
                                Layout.alignment: Qt.AlignHCenter

                                background: Rectangle {
                                    color: newPatientButton.down ? "#1565C0" : "#2196F3"
                                    radius: 4

                                    Behavior on color {
                                        ColorAnimation { duration: 150 }
                                    }
                                }

                                contentItem: Text {
                                    text: newPatientButton.text
                                    font: newPatientButton.font
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: {
                                    console.log("ثبت بیمار جدید")
                                    // باز کردن صفحه ثبت بیمار جدید
                                    stackView.push("NewPatientPage.qml",
                                    {
                                        "isEditMode": false,
                                        "searchedCodemeli": nationalIdField.text
                                    })
                                }
                            }
                        }
                    }

                    // انیمیشن‌های نمایش اطلاعات
                    NumberAnimation {
                        id: patientInfoCardAnimation
                        target: patientInfoCard
                        property: "opacity"
                        from: 0.0
                        to: 1.0
                        duration: 300
                        easing.type: Easing.OutQuad
                    }

                    NumberAnimation {
                        id: patientNotFoundCardAnimation
                        target: patientNotFoundCard
                        property: "opacity"
                        from: 0.0
                        to: 1.0
                        duration: 300
                        easing.type: Easing.OutQuad
                    }
                }
            }

            // اتصال به سیگنال‌های patientBackend
            Connections {
                target: patientBackend

                function onPatientFound(codemeli, name, age, gender) {
                    // پر کردن فیلدهای اطلاعات بیمار
                    patientCodemeliText.text = codemeli
                    patientNameText.text = name
                    patientAgeText.text = age.toString()
                    patientGenderText.text = gender === 1 ? "مرد" : "زن"

                    // نمایش کارت اطلاعات بیمار و مخفی کردن کارت عدم یافتن بیمار
                    patientInfoCard.visible = true
                    patientNotFoundCard.visible = false

                    // انیمیشن نمایش اطلاعات
                    patientInfoCardAnimation.start()
                }

                function onPatientNotFound() {
                    // مخفی کردن کارت اطلاعات بیمار و نمایش کارت عدم یافتن بیمار
                    patientInfoCard.visible = false
                    patientNotFoundCard.visible = true

                    // انیمیشن نمایش پیام عدم یافتن بیمار
                    patientNotFoundCardAnimation.start()
                }

                function onErrorOccurred(errorMessage) {
                    errorText.text = errorMessage
                    errorText.visible = true
                }
            }
        }
    }
}
