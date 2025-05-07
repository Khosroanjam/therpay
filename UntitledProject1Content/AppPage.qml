// AppPage.qml - با دکمه گزارش‌گیری و آیکون‌های اضافه شده
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: appPage
    anchors.fill: parent

    // رنگ‌های اصلی برنامه
    property color primaryColor: "#21a35b"
    property color accentColor: "#e6a22e"
    property color backgroundColor: "#F5F5F5"
    property color cardColor: "#FFFFFF"
    property color textColor: "#333333"
    property var reportBackend: null
    property bool isCheckingPatientExists: false
    signal goBack()
    // اضافه کردن دسترسی به کیبورد مجازی سراسری
    property var globalKeyboard: null

    // MouseArea سراسری برای از دست دادن فوکوس
    MouseArea {
        id: globalMouseArea
        anchors.fill: parent
        z: -1  // زیر همه چیز

        onClicked: {
            if (globalKeyboard && globalKeyboard.visible) {
                globalKeyboard.hide()
                forceActiveFocus()
            }
        }
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
            // تصویر پشت زمینه
            Image {
                id: wallpaper
                source: "images/medical-wallpaper-2.jpg"
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                cache: true
                z: -2
            }
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
                    text: "Plasma Therapy"
                    color: "white"
                    font.family: "Tahoma"
                    font.pixelSize: 22
                    font.bold: true
                    anchors.centerIn: parent
                }

                // دکمه گزارش‌گیری در گوشه سمت چپ هدر با آیکون
                Rectangle {
                    id: reportButtonHeader
                    width: 120
                    height: 40
                    radius: 20
                    color: reportHeaderMouseArea.pressed ? Qt.darker("#4CAF50", 1.2) : "#4CAF50"
                    anchors.left: parent.left
                    anchors.leftMargin: 15
                    anchors.verticalCenter: parent.verticalCenter

                    Row {
                        spacing: 6
                        anchors.centerIn: parent

                        Image {
                            source: "images/report-icon.png"
                            width: 18
                            height: 18
                            anchors.verticalCenter: parent.verticalCenter
                            sourceSize.width: 18
                            sourceSize.height: 18
                        }

                        Text {
                            text: "Report"
                            color: "white"
                            font.family: "Tahoma"
                            font.pixelSize: 14
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: reportHeaderMouseArea
                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            if (globalKeyboard && globalKeyboard.visible) {
                                globalKeyboard.hide()
                            }

                            logger.log("باز کردن صفحه گزارش‌گیری")
                            var reportPage = appStackView.push("ReportPage.qml", {
                                "stackView": appStackView,
                                "reportBackend": reportBackend
                            })

                            if (reportPage && reportPage.backRequested) {
                                reportPage.backRequested.connect(function() {
                                    logger.log("backRequested signal received from report page")
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

            // محتوای اصلی
            Flickable {
                anchors.top: headerBar.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                contentHeight: mainColumn.height + 40
                clip: true

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

                            if (Math.abs(deltaX) > Math.abs(deltaY) && Math.abs(deltaX) > 100) {
                                if (deltaX > 0) {
                                    logger.log("Swiped Right")
                                    patientInfoCardShadow.visible = false
                                    nationalIdField.text = ""
                                    errorMessage.visible = false
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    id: mainColumn
                    anchors.top: parent.top
                    anchors.topMargin: 20
                    anchors.horizontalCenter: parent.horizontalCenter
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
                            anchors.fill: parent
                            anchors.margins: 2
                            radius: 10
                            color: cardColor

                            ColumnLayout {
                                id: searchColumn
                                anchors.top: parent.top
                                anchors.topMargin: 20
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: parent.width * 0.9
                                spacing: 15

                                RowLayout {
                                    Layout.alignment: Qt.AlignHCenter
                                    spacing: 10

                                    Text {
                                        text: "Search Patient"
                                        font.family: "Tahoma"
                                        font.pixelSize: 20
                                        font.bold: true
                                        color: primaryColor
                                    }

                                    Image {
                                        source: "images/medical-report.png"
                                        width: 60
                                        height: 60
                                        sourceSize.width: 24
                                        sourceSize.height: 24
                                    }
                                }

                                // توضیحات with icon
                                RowLayout {
                                    Layout.alignment: Qt.AlignHCenter
                                    spacing: 8

                                    Text {
                                        id: lblPatientCodeMeli
                                        text: "جستجو با کد ملی بیمار انجام می شود"
                                        font.family: "Tahoma"
                                        font.pixelSize: 14
                                        color: "#757575"
                                    }

                                    Image {
                                        source: "images/info-icon.png"
                                        width: 16
                                        height: 16
                                        sourceSize.width: 16
                                        sourceSize.height: 16
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            nationalIdField.forceActiveFocus()
                                            if (globalKeyboard) {
                                                globalKeyboard.show(nationalIdField)
                                            }
                                            mouse.accepted = false
                                        }
                                    }
                                }

                                // فیلد ورود کد ملی
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 80
                                    color: "#F9F9F9"
                                    radius: 8
                                    border.color: nationalIdField.focus ? primaryColor : "#E0E0E0"
                                    border.width: 1.5

                                    TextField {
                                        id: nationalIdField
                                        anchors.fill: parent
                                        anchors.margins: 5
                                        placeholderText: "کد ملی را وارد کنید..."
                                        font.family: "Tahoma"
                                        font.pixelSize: 18
                                        color: textColor
                                        horizontalAlignment: TextInput.AlignHCenter
                                        verticalAlignment: TextInput.AlignVCenter
                                        inputMethodHints: Qt.ImhDigitsOnly
                                        maximumLength: 10

                                        background: Rectangle {
                                            color: "transparent"
                                        }

                                        onActiveFocusChanged: {
                                            if (activeFocus && globalKeyboard) {
                                                globalKeyboard.show(nationalIdField)
                                            } else if (!activeFocus && globalKeyboard && globalKeyboard.visible) {
                                                globalKeyboard.hide()
                                            }
                                        }

                                        onTextChanged: {
                                            // حذف کاراکترهای غیر عددی
                                            var newText = text.replace(/[^0-9]/g, "")
                                            if (newText !== text) {
                                                text = newText
                                            }
                                            errorMessage.visible = false
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                nationalIdField.forceActiveFocus()
                                                if (globalKeyboard) {
                                                    globalKeyboard.show(nationalIdField)
                                                }
                                                mouse.accepted = false
                                            }
                                        }
                                    }
                                }

                                // پیام خطا
                                Text {
                                    id: errorMessage
                                    text: ""
                                    color: "#F44336"
                                    font.family: "Tahoma"
                                    font.pixelSize: 14
                                    visible: false
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                // دکمه جستجو با آیکون
                                Rectangle {
                                    id: searchButtonShadow
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 70
                                    color: "#20000000"
                                    radius: 10
                                    property bool buttonPressed: searchMouseArea.pressed

                                    states: [
                                        State {
                                            name: "pressed"
                                            when: searchButtonShadow.buttonPressed
                                            PropertyChanges {
                                                target: searchButtonShadow
                                                color: "#40000000"
                                            }
                                        }
                                    ]

                                    Rectangle {
                                        id: searchButton
                                        anchors.fill: parent
                                        anchors.bottomMargin: searchMouseArea.pressed ? 1 : 3
                                        anchors.leftMargin: 2
                                        anchors.rightMargin: 2
                                        anchors.topMargin: 2
                                        color: searchMouseArea.pressed ? Qt.darker(primaryColor, 1.2) : primaryColor
                                        radius: 10
                                        property bool isHovered: false

                                        SequentialAnimation {
                                            id: clickAnimation
                                            PropertyAnimation {
                                                target: searchButton
                                                property: "scale"
                                                to: 0.95
                                                duration: 100
                                                easing.type: Easing.OutQuad
                                            }
                                            PropertyAnimation {
                                                target: searchButton
                                                property: "scale"
                                                to: 1.0
                                                duration: 100
                                                easing.type: Easing.OutElastic
                                                easing.amplitude: 1.2
                                                easing.period: 0.5
                                            }
                                        }

                                        Row {
                                            spacing: 10
                                            anchors.centerIn: parent

                                            Text {
                                                text: "Search"
                                                color: "white"
                                                font.family: "Tahoma"
                                                font.pixelSize: 20
                                                font.bold: true
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                            Image {
                                                source: "images/search.png"
                                                width: 34
                                                height: 34
                                                anchors.verticalCenter: parent.verticalCenter
                                                sourceSize.width: 34
                                                sourceSize.height: 34
                                            }
                                        }

                                        MouseArea {
                                            id: searchMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true

                                            onEntered: parent.isHovered = true
                                            onExited: parent.isHovered = false

                                            onClicked: {
                                                clickAnimation.start()

                                                if (globalKeyboard && globalKeyboard.visible) {
                                                    globalKeyboard.hide()
                                                }

                                                if (nationalIdField.text.length === 10) {
                                                    errorMessage.visible = false
                                                    patientBackend.searchPatient(nationalIdField.text)
                                                } else {
                                                    errorMessage.text = "کد ملی باید 10 رقم باشد"
                                                    errorMessage.visible = true
                                                }
                                            }
                                        }

                                        states: [
                                            State {
                                                name: "hovered"
                                                when: searchButton.isHovered
                                                PropertyChanges {
                                                    target: searchButton
                                                    scale: 1.05
                                                }
                                            }
                                        ]

                                        transitions: [
                                            Transition {
                                                from: ""
                                                to: "hovered"
                                                PropertyAnimation {
                                                    properties: "scale"
                                                    duration: 200
                                                    easing.type: Easing.OutCubic
                                                }
                                            },
                                            Transition {
                                                from: "hovered"
                                                to: ""
                                                PropertyAnimation {
                                                    properties: "scale"
                                                    duration: 200
                                                    easing.type: Easing.OutCubic
                                                }
                                            }
                                        ]

                                        Behavior on color {
                                            ColorAnimation { duration: 100 }
                                        }
                                    }
                                }

                                // دکمه ثبت بیمار جدید با آیکون
                                Rectangle {
                                    id: newPatientButtonShadow
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 70
                                    color: "#20000000"
                                    radius: 10
                                    property bool buttonPressed: newPatientMouseArea.pressed

                                    states: [
                                        State {
                                            name: "pressed"
                                            when: newPatientButtonShadow.buttonPressed
                                            PropertyChanges {
                                                target: newPatientButtonShadow
                                                color: "#40000000"
                                            }
                                        }
                                    ]

                                    Rectangle {
                                        id: newPatientButton
                                        anchors.fill: parent
                                        anchors.bottomMargin: newPatientMouseArea.pressed ? 1 : 3
                                        anchors.leftMargin: 2
                                        anchors.rightMargin: 2
                                        anchors.topMargin: 2
                                        color: newPatientMouseArea.pressed ? Qt.darker(accentColor, 1.2) : accentColor
                                        radius: 10
                                        property bool isHovered: false

                                        SequentialAnimation {
                                            id: newPatientClickAnimation
                                            PropertyAnimation {
                                                target: newPatientButton
                                                property: "scale"
                                                to: 0.95
                                                duration: 100
                                                easing.type: Easing.OutQuad
                                            }
                                            PropertyAnimation {
                                                target: newPatientButton
                                                property: "scale"
                                                to: 1.0
                                                duration: 150
                                                easing.type: Easing.OutElastic
                                                easing.amplitude: 1.2
                                                easing.period: 0.5
                                            }
                                        }

                                        // اضافه کردن انیمیشن موج (ripple) برای دکمه
                                        Item {
                                            id: rippleArea
                                            anchors.fill: parent
                                            clip: true

                                            function createRipple(mouseX, mouseY) {
                                                var ripple = rippleComponent.createObject(rippleArea, {
                                                    "x": mouseX - rippleSize/2,
                                                    "y": mouseY - rippleSize/2
                                                });
                                                ripple.destroy(800);
                                            }

                                            property real rippleSize: Math.max(width, height) * 2

                                            Component {
                                                id: rippleComponent

                                                Rectangle {
                                                    id: rippleRect
                                                    width: rippleSize
                                                    height: rippleSize
                                                    radius: rippleSize/2
                                                    color: "white"
                                                    opacity: 0.3

                                                    NumberAnimation on scale {
                                                        from: 0
                                                        to: 1
                                                        duration: 500
                                                        easing.type: Easing.OutQuad
                                                    }

                                                    NumberAnimation on opacity {
                                                        from: 0.3
                                                        to: 0
                                                        duration: 500
                                                        easing.type: Easing.OutQuad
                                                    }
                                                }
                                            }
                                        }

                                        Row {
                                            spacing: 20
                                            anchors.centerIn: parent


                                            Text {
                                                text: "New Patient"
                                                color: "white"
                                                font.family: "Tahoma"
                                                font.pixelSize: 20
                                                font.bold: true
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                            Image {
                                                source: "images/save.png"
                                                width: 34
                                                height: 34
                                                anchors.verticalCenter: parent.verticalCenter
                                                sourceSize.width: 34
                                                sourceSize.height: 34
                                            }
                                        }

                                        MouseArea {
                                            id: newPatientMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true

                                            onEntered: parent.isHovered = true
                                            onExited: parent.isHovered = false

                                            onClicked: {
                                                newPatientClickAnimation.start()
                                                rippleArea.createRipple(mouse.x, mouse.y)

                                                if (globalKeyboard && globalKeyboard.visible) {
                                                    globalKeyboard.hide()
                                                }
                                                logger.log("ثبت بیمار جدید")
                                                if (nationalIdField.text.length <= 9) {
                                                    logger.log("طول کد ملی کوچیک تر از ۱۰ کاراکتر است")
                                                    errorMessage.text = "طول کاراکتر کد ملی نباید کمتر از ۱۰ کاراکتر باشد"
                                                    errorMessage.visible = true
                                                    return
                                                }

                                                isCheckingPatientExists = true
                                                patientBackend.checkPatientExists(nationalIdField.text)
                                            }
                                        }

                                        states: [
                                            State {
                                                name: "hovered"
                                                when: newPatientButton.isHovered
                                                PropertyChanges {
                                                    target: newPatientButton
                                                    scale: 1.05
                                                }
                                            }
                                        ]

                                        transitions: [
                                            Transition {
                                                from: ""
                                                to: "hovered"
                                                PropertyAnimation {
                                                    properties: "scale"
                                                    duration: 200
                                                    easing.type: Easing.OutCubic
                                                }
                                            },
                                            Transition {
                                                from: "hovered"
                                                to: ""
                                                PropertyAnimation {
                                                    properties: "scale"
                                                    duration: 200
                                                    easing.type: Easing.OutCubic
                                                }
                                            }
                                        ]

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
                            anchors.fill: parent
                            anchors.margins: 2
                            radius: 10
                            color: cardColor

                            ColumnLayout {
                                id: infoColumn
                                anchors.top: parent.top
                                anchors.topMargin: 20
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: parent.width * 0.9
                                spacing: 15

                                // عنوان کارت
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 50
                                    color: primaryColor
                                    radius: 8

                                    Row {
                                        spacing: 8
                                        anchors.centerIn: parent

                                        Image {
                                            source: "images/user-info-icon.png"
                                            width: 22
                                            height: 22
                                            anchors.verticalCenter: parent.verticalCenter
                                            sourceSize.width: 22
                                            sourceSize.height: 22
                                        }

                                        Text {
                                            text: " Patient Info"
                                            color: "white"
                                            font.family: "Tahoma"
                                            font.pixelSize: 18
                                            font.bold: true
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 25

                                    // کد ملی
                                    RowLayout {
                                        Layout.fillWidth: true
                                        layoutDirection: Qt.RightToLeft  // چیدمان از راست به چپ

                                        Text {
                                            text: "National Code:"
                                            font.family: "Tahoma"
                                            font.pixelSize: 16
                                            font.bold: true
                                            color: textColor
                                        }

                                        Text {
                                            id: patientCodemeliText
                                            text: ""
                                            font.family: "Tahoma"
                                            font.pixelSize: 16
                                            color: textColor
                                            Layout.fillWidth: true
                                            horizontalAlignment: Text.AlignRight
                                        }
                                    }

                                    // نام
                                    RowLayout {
                                        Layout.fillWidth: true
                                        layoutDirection: Qt.RightToLeft

                                        Text {
                                            text: "Name:"
                                            font.family: "Tahoma"
                                            font.pixelSize: 16
                                            font.bold: true
                                            color: textColor
                                        }

                                        Text {
                                            id: patientNameText
                                            text: ""
                                            font.family: "Tahoma"
                                            font.pixelSize: 16
                                            color: textColor
                                            Layout.fillWidth: true
                                            horizontalAlignment: Text.AlignRight
                                        }
                                    }

                                    // سن
                                    RowLayout {
                                        Layout.fillWidth: true
                                        layoutDirection: Qt.RightToLeft

                                        Text {
                                            text: "Age:"
                                            font.family: "Tahoma"
                                            font.pixelSize: 16
                                            font.bold: true
                                            color: textColor
                                        }

                                        Text {
                                            id: patientAgeText
                                            text: ""
                                            font.family: "Tahoma"
                                            font.pixelSize: 16
                                            color: textColor
                                            Layout.fillWidth: true
                                            horizontalAlignment: Text.AlignRight
                                        }
                                    }

                                    // جنسیت
                                    RowLayout {
                                        Layout.fillWidth: true
                                        layoutDirection: Qt.RightToLeft

                                        Text {
                                            text: "Gender:"
                                            font.family: "Tahoma"
                                            font.pixelSize: 16
                                            font.bold: true
                                            color: textColor
                                        }

                                        Text {
                                            id: patientGenderText
                                            text: ""
                                            font.family: "Tahoma"
                                            font.pixelSize: 16
                                            color: textColor
                                            Layout.fillWidth: true
                                            horizontalAlignment: Text.AlignRight
                                        }
                                    }
                                }

                                // دکمه ویرایش اطلاعات با آیکون
                                Rectangle {
                                    id: editButtonShadow
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 70
                                    color: "#20000000"
                                    radius: 10

                                    Rectangle {
                                        id: editButton
                                        anchors.fill: parent
                                        anchors.bottomMargin: editMouseArea.pressed ? 1 : 3
                                        anchors.leftMargin: 2
                                        anchors.rightMargin: 2
                                        anchors.topMargin: 2
                                        color: editMouseArea.pressed ? Qt.darker("#FFC107", 1.2) : "#FFC107"
                                        radius: 10

                                        Row {
                                            spacing: 10
                                            anchors.centerIn: parent

                                            Image {
                                                source: "images/edit.png"
                                                width: 22
                                                height: 22
                                                anchors.verticalCenter: parent.verticalCenter
                                                sourceSize.width: 22
                                                sourceSize.height: 22
                                            }

                                            Text {
                                                text: "Edit Info"
                                                color: "#212121"
                                                font.family: "Tahoma"
                                                font.pixelSize: 20
                                                font.bold: true
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }

                                        MouseArea {
                                            id: editMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true

                                            onClicked: {
                                                if (globalKeyboard && globalKeyboard.visible) {
                                                    globalKeyboard.hide()
                                                }

                                                logger.log("ویرایش اطلاعات بیمار")
                                                var newPage = appStackView.push("NewPatientPage.qml", {
                                                    "isEditMode": true,
                                                    "currentPatientCodemeli": String(patientCodemeliText.text),
                                                    "patientName": patientNameText.text,
                                                    "patientAge": parseInt(patientAgeText.text),
                                                    "patientGender": patientGenderText.text === "مرد" ? 1 : 0,
                                                    "stackView": appStackView,
                                                    "globalKeyboard": globalKeyboard
                                                })

                                                if (newPage) {
                                                    logger.log("Successfully pushed NewPatientPage for editing")
                                                    newPage.backRequested.connect(function() {
                                                        logger.log("backRequested signal received from edit page")
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

                                // دکمه پلاسما تراپی با آیکون
                                Rectangle {
                                    id: therapyButtonShadow
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 70
                                    color: "#20000000"
                                    radius: 10

                                    Rectangle {
                                        id: therapyButton
                                        anchors.fill: parent
                                        anchors.bottomMargin: therapyMouseArea.pressed ? 1 : 3
                                        anchors.leftMargin: 2
                                        anchors.rightMargin: 2
                                        anchors.topMargin: 2
                                        color: therapyMouseArea.pressed ? Qt.darker("#4CAF50", 1.2) : "#4CAF50"
                                        radius: 10

                                        Row {
                                            spacing: 10
                                            anchors.centerIn: parent

                                            Image {
                                                source: "images/therapy.png"
                                                width: 24
                                                height: 24
                                                anchors.verticalCenter: parent.verticalCenter
                                                sourceSize.width: 24
                                                sourceSize.height: 24
                                            }

                                            Text {
                                                text: "Plasma Therapy"
                                                color: "white"
                                                font.family: "Tahoma"
                                                font.pixelSize: 20
                                                font.bold: true
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }

                                        MouseArea {
                                            id: therapyMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true

                                            onClicked: {
                                                if (globalKeyboard && globalKeyboard.visible) {
                                                    globalKeyboard.hide()
                                                }

                                                logger.log("ثبت نوبت جدید برای بیمار با کد ملی:", patientCodemeliText.text)
                                                var therapyPage = appStackView.push("PlasmaTherapy.qml", {
                                                    "patientCodemeli": patientCodemeliText.text,
                                                    "patientName": patientNameText.text,
                                                    "patientAge": parseInt(patientAgeText.text || "0"),
                                                    "patientGender": patientGenderText.text === "مرد" ? 1 : 0,
                                                    "stackView": appStackView,
                                                    "globalKeyboard": globalKeyboard
                                                })

                                                if (therapyPage && therapyPage.backRequested) {
                                                    therapyPage.backRequested.connect(function() {
                                                        logger.log("backRequested signal received from therapy page")
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

                    // دکمه گزارش‌گیری در پایین صفحه با آیکون
                    Rectangle {
                        id: reportButtonShadow
                        Layout.fillWidth: true
                        Layout.preferredHeight: 70
                        color: "#20000000"
                        radius: 10
                        visible: true

                        Rectangle {
                            id: reportButton
                            anchors.fill: parent
                            anchors.bottomMargin: reportMouseArea.pressed ? 1 : 3
                            anchors.leftMargin: 2
                            anchors.rightMargin: 2
                            anchors.topMargin: 2
                            color: reportMouseArea.pressed ? Qt.darker("#673AB7", 1.2) : "#673AB7"
                            radius: 10
                            visible: false

                            Row {
                                spacing: 10
                                anchors.centerIn: parent

                                Image {
                                    source: "images/chart.png"
                                    width: 24
                                    height: 24
                                    anchors.verticalCenter: parent.verticalCenter
                                    sourceSize.width: 24
                                    sourceSize.height: 24
                                }

                                Text {
                                    text: "Reports"
                                    color: "white"
                                    font.family: "Tahoma"
                                    font.pixelSize: 20
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: reportMouseArea
                                anchors.fill: parent
                                hoverEnabled: true

                                onClicked: {
                                    if (globalKeyboard && globalKeyboard.visible) {
                                        globalKeyboard.hide()
                                    }

                                    logger.log("باز کردن صفحه گزارش‌گیری")
                                    var reportPage = appStackView.push("ReportPage.qml", {
                                        "stackView": appStackView,
                                        "globalKeyboard": globalKeyboard,
                                        "reportBackend": reportBackend
                                    })

                                    if (reportPage && reportPage.backRequested) {
                                        reportPage.backRequested.connect(function() {
                                            logger.log("backRequested signal received from report page")
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

            // اتصال به سیگنال‌های patientBackend
            Connections {
                target: patientBackend

                function onPatientExistsResult(exists) {
                    if (isCheckingPatientExists) {
                        isCheckingPatientExists = false

                        if (exists) {
                            errorMessage.text = "بیماری با این کد ملی قبلاً ثبت شده است"
                            errorMessage.visible = true
                        } else {
                            var newPage = appStackView.push("NewPatientPage.qml", {
                                "isEditMode": false,
                                "searchedCodemeli": nationalIdField.text,
                                "stackView": appStackView,
                                "globalKeyboard": globalKeyboard
                            })

                            if (newPage) {
                                logger.log("Successfully pushed NewPatientPage")
                                newPage.backRequested.connect(function() {
                                    logger.log("backRequested signal received from new patient page")
                                    appStackView.pop()
                                })
                            } else {
                                logger.log("Failed to push NewPatientPage")
                            }
                        }
                    }
                }

                function onPatientFound(codemeli, name, age, gender) {
                    logger.log("Patient found signal received:", codemeli, name, age, gender)

                    patientCodemeliText.text = codemeli
                    patientNameText.text = name
                    patientAgeText.text = age.toString()
                    patientGenderText.text = gender === 1 ? "مرد" : "زن"

                    patientInfoCardShadow.visible = true
                    patientInfoCardAnimation.start()
                }

                function onPatientNotFound() {
                    logger.log("Patient not found signal received")
                    errorMessage.text = "بیماری با این کد ملی یافت نشد"
                    errorMessage.visible = true
                    patientInfoCardShadow.visible = false
                }

                function onErrorOccurred(errorMsg) {
                    logger.log("Error occurred:", errorMsg)
                    errorMessage.text = errorMsg
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

    // تابع کمکی برای مدیریت فوکوس و کیبورد
    function focusAndShowKeyboard(textField) {
        if (textField) {
            textField.forceActiveFocus()
            if (globalKeyboard) {
                globalKeyboard.show(textField)
            }
        }
    }
}
