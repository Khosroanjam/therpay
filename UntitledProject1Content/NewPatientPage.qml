// NewPatientPage.qml (توجه: اسم فایل باید دقیقاً همین باشد)
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import QtQuick.Layouts

Item {
    id: newPatientRoot
    width: parent ? parent.width : 800
    height: parent ? parent.height : 800

    // سیگنال برای درخواست بازگشت
    signal backRequested()

    // پراپرتی‌های صفحه
    property string currentPatientCodemeli: ""
    property bool isEditMode: false
    property string patientName: ""
    property int patientAge: 0
    property int patientGender: 1
    property string searchedCodemeli: ""  // پراپرتی برای دریافت کد ملی جستجو شده
    property var stackView: null  // پراپرتی برای دسترسی مستقیم به stackView
    property var globalKeyboard: null  // پراپرتی برای دسترسی به کیبورد مجازی

    // متغیر برای ذخیره کد ملی جاری برای جستجوی مجدد پس از بازگشت
    property string codeToSearch: ""

    DragHandler {
           id: dragHandler
           target: null  // هیچ هدفی را حرکت نمی‌دهیم
           property point startPoint

           onActiveChanged: {
               if (active) {
                   startPoint = centroid.position
               } else {
                   var deltaX = centroid.position.x - startPoint.x
                   var deltaY = centroid.position.y - startPoint.y

                   // اگر حرکت بیشتر افقی بوده و از آستانه بیشتر است
                   if (Math.abs(deltaX) > Math.abs(deltaY) && Math.abs(deltaX) > 100) {
                       if (deltaX > 0) {
                           logger.log("Swiped Right")
                           // اینجا می‌توانید تابع goBack را فراخوانی کنید
                           backRequested()
                       } else {
                           logger.log("Swiped Left")
                       }
                   }
               }
           }
       }

    // MouseArea سراسری برای از دست دادن فوکوس
    MouseArea {
        id: globalMouseArea
        anchors.fill: parent
        z: -1  // زیر همه چیز

        onClicked: {
            // کلیک روی صفحه اصلی باعث مخفی شدن کیبورد می‌شود
            if (globalKeyboard && globalKeyboard.visible) {
                globalKeyboard.hide()
                forceActiveFocus()  // فوکوس را به صفحه اصلی بده
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#f5f5f5"

        // سربرگ صفحه با طراحی مدرن
        Rectangle {
            id: header
            width: parent.width
            height: 60
            color: "#2196F3"

            // سایه برای هدر با استفاده از Rectangle
            Rectangle {
                anchors.top: parent.bottom
                width: parent.width
                height: 2
                color: "#20000000"
            }

            // دکمه بازگشت با انیمیشن
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
                    hoverEnabled: true
                    onClicked: {
                        // مخفی کردن کیبورد قبل از بازگشت
                        if (globalKeyboard && globalKeyboard.visible) {
                            globalKeyboard.hide()
                        }

                        console.log("Back button clicked, emitting backRequested signal")

                        // ارسال سیگنال بازگشت
                        backRequested()

                        // استفاده از stackView اگر تنظیم شده باشد
                        if (stackView) {
                            console.log("Using provided stackView to pop")
                            stackView.pop()
                        }
                    }
                }

                // انیمیشن هنگام هاور
                states: [
                    State {
                        name: "hovered"
                        when: backMouseArea.containsMouse
                        PropertyChanges {
                            target: backButton
                            scale: 1.1
                        }
                    }
                ]

                transitions: [
                    Transition {
                        NumberAnimation {
                            properties: "scale"
                            duration: 150
                            easing.type: Easing.OutQuad
                        }
                    }
                ]
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

        // فرم ورود اطلاعات با قابلیت اسکرول
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
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: formColumn
                width: parent.width
                spacing: 20
                // کارت اصلی فرم با سایه
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: formLayout.height + 40
                    color: "white"
                    radius: 8

                    // سایه برای کارت با استفاده از Rectangle
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
                            text: "Please enter patient Info"
                            font {
                                family: "Tahoma"
                                pixelSize: 16
                                bold: true
                            }
                            color: "#424242"
                            Layout.alignment: Qt.AlignHCenter
                        }

                        // فیلد کد ملی با طراحی مدرن
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Text {
                                text: "National Code:"
                                font {
                                    family: "Tahoma"
                                    pixelSize: 14
                                }
                                color: "#424242"
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 50
                                color: codemeliField.enabled ? "white" : "#F5F5F5"
                                border.color: codemeliField.focus ? "#2196F3" : "#E0E0E0"
                                border.width: 1
                                radius: 4

                                TextField {
                                    id: codemeliField
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    placeholderText: "Ten-digit national code"
                                    inputMethodHints: Qt.ImhDigitsOnly
                                    maximumLength: 10
                                    enabled: !newPatientRoot.isEditMode
                                    horizontalAlignment: TextInput.AlignHCenter

                                    // تنظیم مقدار اولیه
                                    text: isEditMode ? currentPatientCodemeli :
                                          (searchedCodemeli && searchedCodemeli.length > 0 ? searchedCodemeli : "")

                                    font {
                                        family: "Tahoma"
                                        pixelSize: 14
                                    }

                                    background: Rectangle {
                                        color: "transparent"
                                    }

                                    // اضافه کردن onActiveFocusChanged برای مدیریت خودکار کیبورد
                                    onActiveFocusChanged: {
                                        if (activeFocus && globalKeyboard && enabled) {
                                            globalKeyboard.show(codemeliField)
                                        } else if (!activeFocus && globalKeyboard && globalKeyboard.visible) {
                                            globalKeyboard.hide()
                                        }
                                    }

                                    onTextChanged: {
                                        var newText = text.replace(/[^0-9]/g, "")
                                        if (newText !== text) {
                                            text = newText
                                        }

                                        // ذخیره برای جستجوی بعدی
                                        if (text.length === 10) {
                                            codeToSearch = text
                                        }

                                        // بررسی اعتبار در حین تایپ
                                        codemeliError.visible = (text.length > 0 && text.length !== 10)
                                    }

                                    // اضافه کردن MouseArea برای فوکوس و نمایش کیبورد
                                    MouseArea {
                                        anchors.fill: parent
                                        enabled: codemeliField.enabled
                                        onClicked: {
                                            if (codemeliField.enabled) {
                                                codemeliField.forceActiveFocus()
                                                if (globalKeyboard) {
                                                    globalKeyboard.show(codemeliField)
                                                }
                                            }
                                            mouse.accepted = false
                                        }
                                    }
                                }
                            }

                            Text {
                                id: codemeliError
                                text: "The national code must be ten digits"
                                color: "#F44336"
                                font {
                                    family: "Tahoma"
                                    pixelSize: 12
                                }
                                visible: false
                            }
                        }

                        // فیلد نام با طراحی مدرن
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Text {
                                text: "First name Last name : "
                                font {
                                    family: "Tahoma"
                                    pixelSize: 14
                                }
                                color: "#424242"
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 50
                                color: "white"
                                border.color: nameField.focus ? "#2196F3" : "#E0E0E0"
                                border.width: 1
                                radius: 4

                                TextField {
                                    id: nameField
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    placeholderText: "Patient Family"
                                    text: isEditMode ? patientName : ""
                                    horizontalAlignment: TextInput.AlignHCenter

                                    font {
                                        family: "Tahoma"
                                        pixelSize: 14
                                    }

                                    background: Rectangle {
                                        color: "transparent"
                                    }

                                    // اضافه کردن onActiveFocusChanged برای مدیریت خودکار کیبورد
                                    onActiveFocusChanged: {
                                        if (activeFocus && globalKeyboard) {
                                            globalKeyboard.show(nameField)
                                        } else if (!activeFocus && globalKeyboard && globalKeyboard.visible) {
                                            globalKeyboard.hide()
                                        }
                                    }

                                    onTextChanged: {
                                        // بررسی اعتبار در حین تایپ
                                        nameError.visible = (text.trim().length === 0 && activeFocus && !focus)
                                    }

                                    // اضافه کردن MouseArea برای فوکوس و نمایش کیبورد
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            nameField.forceActiveFocus()
                                            if (globalKeyboard) {
                                                globalKeyboard.show(nameField)
                                            }
                                            mouse.accepted = false
                                        }
                                    }
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

                        // فیلد سن با طراحی مدرن
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Text {
                                text: "Age:"
                                font {
                                    family: "Tahoma"
                                    pixelSize: 14
                                }
                                color: "#424242"
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 50
                                color: "white"
                                border.color: ageField.focus ? "#2196F3" : "#E0E0E0"
                                border.width: 1
                                radius: 4

                                TextField {
                                    id: ageField
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    placeholderText: "Patient Age"
                                    inputMethodHints: Qt.ImhDigitsOnly
                                    maximumLength: 3
                                    text: isEditMode ? patientAge.toString() : ""
                                    horizontalAlignment: TextInput.AlignHCenter

                                    font {
                                        family: "Tahoma"
                                        pixelSize: 14
                                    }

                                    background: Rectangle {
                                        color: "transparent"
                                    }

                                    // اضافه کردن onActiveFocusChanged برای مدیریت خودکار کیبورد
                                    onActiveFocusChanged: {
                                        if (activeFocus && globalKeyboard) {
                                            globalKeyboard.show(ageField)
                                        } else if (!activeFocus && globalKeyboard && globalKeyboard.visible) {
                                            globalKeyboard.hide()
                                        }
                                    }

                                    onTextChanged: {
                                        var newText = text.replace(/[^0-9]/g, "")
                                        if (newText !== text) {
                                            text = newText
                                        }
                                    }

                                    // اضافه کردن MouseArea برای فوکوس و نمایش کیبورد
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            ageField.forceActiveFocus()
                                            if (globalKeyboard) {
                                                globalKeyboard.show(ageField)
                                            }
                                            mouse.accepted = false
                                        }
                                    }
                                }
                            }
                        }

                        // فیلد جنسیت با طراحی مدرن
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Text {
                                text: "Gender:"
                                font {
                                    family: "Tahoma"
                                    pixelSize: 14
                                }
                                color: "#424242"
                            }

                            // اضافه کردن ButtonGroup برای مدیریت دکمه‌های رادیویی
                            ButtonGroup {
                                id: genderGroup
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 20
                                Layout.alignment: Qt.AlignHCenter

                                // دکمه رادیویی برای مرد
                                Rectangle {
                                    width: 120
                                    height: 50
                                    color: maleRadio.checked ? "#E3F2FD" : "white"
                                    border.color: maleRadio.checked ? "#2196F3" : "#E0E0E0"
                                    border.width: 1
                                    radius: 4

                                    RadioButton {
                                        id: maleRadio
                                        anchors.centerIn: parent
                                        text: "Man"
                                        checked: isEditMode ? (patientGender === 1) : true
                                        // اضافه کردن به ButtonGroup
                                        ButtonGroup.group: genderGroup

                                        contentItem: Text {
                                            text: maleRadio.text
                                            font {
                                                family: "Tahoma"
                                                pixelSize: 14
                                                bold: maleRadio.checked
                                            }
                                            color: maleRadio.checked ? "#2196F3" : "#424242"
                                            leftPadding: maleRadio.indicator.width + 4
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        onClicked: {
                                            // مخفی کردن کیبورد هنگام انتخاب رادیو باتن
                                            if (globalKeyboard && globalKeyboard.visible) {
                                                globalKeyboard.hide()
                                                forceActiveFocus()
                                            }
                                        }
                                    }
                                }

                                // دکمه رادیویی برای زن
                                Rectangle {
                                    width: 120
                                    height: 50
                                    color: femaleRadio.checked ? "#FCE4EC" : "white"
                                    border.color: femaleRadio.checked ? "#E91E63" : "#E0E0E0"
                                    border.width: 1
                                    radius: 4

                                    RadioButton {
                                        id: femaleRadio
                                        anchors.centerIn: parent
                                        text: "Woman"
                                        checked: isEditMode ? (patientGender === 0) : false
                                        // اضافه کردن به ButtonGroup
                                        ButtonGroup.group: genderGroup

                                        contentItem: Text {
                                            text: femaleRadio.text
                                            font {
                                                family: "Tahoma"
                                                pixelSize: 14
                                                bold: femaleRadio.checked
                                            }
                                            color: femaleRadio.checked ? "#E91E63" : "#424242"
                                            leftPadding: femaleRadio.indicator.width + 4
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        onClicked: {
                                            // مخفی کردن کیبورد هنگام انتخاب رادیو باتن
                                            if (globalKeyboard && globalKeyboard.visible) {
                                                globalKeyboard.hide()
                                                forceActiveFocus()
                                            }
                                        }
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

                        // دکمه ثبت با طراحی مدرن و انیمیشن
                        Item {
                            Layout.preferredWidth: 200
                            Layout.preferredHeight: 50
                            Layout.alignment: Qt.AlignHCenter
                            Layout.topMargin: 10

                            Rectangle {
                                id: buttonShadow
                                anchors.centerIn: parent
                                width: submitButton.width + 4
                                height: submitButton.height + 4
                                radius: 25
                                color: "#30000000"
                                visible: !submitButton.pressed
                            }

                            Button {
                                id: submitButton
                                anchors.centerIn: parent
                                width: 200
                                height: 50
                                text: newPatientRoot.isEditMode ? "Update" : "Register"

                                font {
                                    family: "Tahoma"
                                    pixelSize: 16
                                    bold: true
                                }

                                background: Rectangle {
                                    color: submitButton.pressed ? "#388E3C" : "#4CAF50"
                                    radius: 25

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
                                        to: submitButton.width * 2
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
                                    text: submitButton.text
                                    font: submitButton.font
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                // افکت تغییر اندازه هنگام کلیک
                                transform: Scale {
                                    id: buttonScale
                                    origin.x: submitButton.width / 2
                                    origin.y: submitButton.height / 2
                                    xScale: submitButton.pressed ? 0.95 : 1.0
                                    yScale: submitButton.pressed ? 0.95 : 1.0

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

                                onClicked: {
                                    // مخفی کردن کیبورد قبل از ثبت
                                    if (globalKeyboard && globalKeyboard.visible) {
                                        globalKeyboard.hide()
                                    }

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
                                                codemeliField.text,
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
    }

    // اتصال به سیگنال‌های patientBackend
    Connections {
        target: patientBackend

        function onPatientAdded(success, message) {
            if (success) {
                // نمایش پیام موفقیت
                showToast(message)

                // ذخیره کد ملی برای جستجوی بعدی
                var savedCode = codemeliField.text

                // بازگشت به صفحه قبل
                console.log("Patient added successfully, going back")
                backRequested()

                // استفاده از stackView اگر تنظیم شده باشد
                if (stackView) {
                    console.log("Using provided stackView to pop after patient added")
                    stackView.pop()
                }

                // جستجوی بیمار تازه ثبت شده
                patientBackend.searchPatient(savedCode)
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

                // ذخیره کد ملی برای جستجوی بعدی
                var savedCode = newPatientRoot.currentPatientCodemeli

                // بازگشت به صفحه قبل
                console.log("Patient updated successfully, going back")
                backRequested()

                // استفاده از stackView اگر تنظیم شده باشد
                if (stackView) {
                    console.log("Using provided stackView to pop after patient updated")
                    stackView.pop()
                }

                // جستجوی بیمار به‌روزرسانی شده
                patientBackend.searchPatient(savedCode)
            } else {
                // نمایش پیام خطا
                formError.text = message
                formError.visible = true
            }
        }
    }

    // کامپوننت نمایش پیام موقت (Toast) با انیمیشن
    function showToast(message) {
        toastText.text = message
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

        // سایه برای toast با استفاده از Rectangle
        Rectangle {
            anchors.centerIn: parent
            width: parent.width + 4
            height: parent.height + 4
            radius: 25
            color: "#40000000"
            z: -1
        }

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

        // انیمیشن ظاهر و مخفی شدن
        Behavior on opacity {
            NumberAnimation { duration: 300 }
        }

        Timer {
            id: toastTimer
            interval: 3000
            onTriggered: toast.opacity = 0
        }
    }

    // تابع کمکی برای مدیریت فوکوس و کیبورد
    function focusAndShowKeyboard(textField) {
        if (textField) {
            textField.forceActiveFocus()
            if (globalKeyboard) {
                globalKeyboard.show(textField)
            }
        }
    }

    // وقتی صفحه نمایش داده می‌شود
    Component.onCompleted: {
        console.log("NewPatientPage loaded - isEditMode:", isEditMode,
                    "searchedCodemeli:", searchedCodemeli,
                    "currentPatientCodemeli:", currentPatientCodemeli,
                    "stackView available:", stackView !== null,
                    "globalKeyboard available:", globalKeyboard !== null)

        // اطمینان از اینکه پیام‌های خطا مخفی هستند
        formError.visible = false
        codemeliError.visible = false
        nameError.visible = false

        // فوکوس روی اولین فیلد قابل ویرایش و نمایش کیبورد
        if (!isEditMode) {
            // کمی تأخیر برای اطمینان از اینکه صفحه کاملاً بارگذاری شده است
            Qt.callLater(function() {
                if (codemeliField.enabled) {
                    focusAndShowKeyboard(codemeliField)
                }
            })
        } else {
            // کمی تأخیر برای اطمینان از اینکه صفحه کاملاً بارگذاری شده است
            Qt.callLater(function() {
                focusAndShowKeyboard(nameField)
            })
        }
    }
}
