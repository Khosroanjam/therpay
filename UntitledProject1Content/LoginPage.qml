// LoginPage.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects  // برای Qt 6

Item {
    id: loginPage
    anchors.fill: parent

    // سیگنال برای اعلام ورود موفق
    signal loginSuccessful()

    // پارامترهای قابل تنظیم
    readonly property color primaryColor: "#2196F3"
    readonly property color primaryDarkColor: "#1565C0"
    readonly property color errorColor: "#f44336"
    readonly property color textColor: "#333333"
    readonly property color hintTextColor: "#aaaaaa"
    readonly property color labelColor: "#757575"
    readonly property string fontFamily: "Tahoma"

    // انیمیشن اصلی برای زمان ورود به صفحه
    ParallelAnimation {
        id: pageEnterAnimation
        running: true

        NumberAnimation {
            target: topSection
            property: "opacity"
            from: 0
            to: 1
            duration: 800
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: bottomSection
            property: "opacity"
            from: 0
            to: 1
            duration: 800
            easing.type: Easing.OutCubic
        }
    }

    // کیبورد مجازی در سطح برنامه
    VirtualKeyboard {
        id: globalKeyboard
        anchors.fill: parent
        z: 1000
    }

    // MouseArea سراسری برای از دست دادن فوکوس
    MouseArea {
        id: globalMouseArea
        anchors.fill: parent
        z: -1  // زیر همه چیز

        onClicked: {
            // کلیک روی صفحه اصلی باعث از دست رفتن فوکوس کیبورد می‌شود
            if (globalKeyboard.visible) {
                forceActiveFocus()  // فوکوس را به پنجره اصلی بده
            }
        }
    }

    // پس‌زمینه با گرادیانت
    Rectangle {
        id: backgroundGradient
        anchors.fill: parent

        gradient: Gradient {
            GradientStop { position: 0.0; color: "#f5f5f5" }
            GradientStop { position: 1.0; color: "#e0e0e0" }
        }
    }

    // ساختار اصلی صفحه
    ColumnLayout {
        anchors.fill: parent
        spacing: 0 // بدون فاصله بین دو بخش

        // بخش بالا - لوگو (50٪)
        Rectangle {
            id: topSection
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.5
            color: "transparent"
            opacity: 0 // برای انیمیشن

            Item {
                id: logoContainer
                anchors.centerIn: parent
                width: parent.width * 0.6
                height: parent.height * 0.6

                // تبدیل برای چرخش سه بعدی
                transform: Rotation {
                    id: logoRotation
                    origin.x: logoContainer.width / 2
                    origin.y: logoContainer.height / 2
                    axis { x: 0; y: 1; z: 0 }
                    angle: 0
                }

                // لوگوی جلو
                Image {
                    id: frontLogo
                    source: "images/plasma-logo.png"
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    visible: logoRotation.angle < 90
                }

                // لوگوی پشت (برای نمایش هنگام چرخش)
                Image {
                    id: backLogo
                    source: "images/plasma-logo.png" // می‌توانید تصویر متفاوتی استفاده کنید
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    opacity: 0.7
                    rotation: 180
                    mirror: true
                    visible: logoRotation.angle >= 90
                }

                // افکت انیمیشن برای لوگو
                SequentialAnimation {
                    id: logoFlipAnimation
                    running: true

                    // تاخیر اولیه
                    PauseAnimation { duration: 1000 }

                    // چرخش به پشت
                    NumberAnimation {
                        target: logoRotation
                        property: "angle"
                        to: 180
                        duration: 1200
                        easing.type: Easing.InOutQuad
                    }

                    // تاخیر کوتاه
                    PauseAnimation { duration: 500 }

                    // چرخش به جلو
                    NumberAnimation {
                        target: logoRotation
                        property: "angle"
                        to: 0
                        duration: 1200
                        easing.type: Easing.InOutQuad
                    }

                    // تاخیر طولانی‌تر قبل از تکرار
                    PauseAnimation { duration: 5000 }

                    // تکرار انیمیشن
                    loops: Animation.Infinite
                }

                // انیمیشن تپش آرام لوگو
                SequentialAnimation {
                    running: true
                    loops: Animation.Infinite

                    NumberAnimation {
                        target: logoContainer
                        property: "scale"
                        to: 1.05
                        duration: 2000
                        easing.type: Easing.InOutQuad
                    }

                    NumberAnimation {
                        target: logoContainer
                        property: "scale"
                        to: 1
                        duration: 2000
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }

        // بخش پایین - فرم ورود (50٪)
        Rectangle {
            id: bottomSection
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.5
            color: "transparent"
            opacity: 0 // برای انیمیشن

            // کانتینر برای انیمیشن flip
            Item {
                id: formCardContainer
                width: parent.width * 0.9
                height: parent.height * 0.8
                anchors.centerIn: parent

                // تبدیل برای چرخش سه بعدی
                transform: Rotation {
                    id: cardRotation
                    origin.x: formCardContainer.width / 2
                    origin.y: formCardContainer.height / 2
                    axis { x: 1; y: 0; z: 0 } // چرخش حول محور X (بالا به پایین)
                    angle: 0
                }

                // کارت روی جلو (فرم ورود)
                Rectangle {
                    id: formCard
                    anchors.fill: parent
                    radius: 10
                    color: "white"
                    visible: cardRotation.angle <= 90

                    // سایه کارت
                    layer.enabled: true
                    layer.effect: DropShadow {
                        transparentBorder: true
                        horizontalOffset: 0
                        verticalOffset: 3
                        radius: 8.0
                        samples: 17
                        color: "#30000000"
                    }

                    // انیمیشن ظاهر شدن کارت
                    NumberAnimation on opacity {
                        from: 0
                        to: 1
                        duration: 800
                        running: true
                        easing.type: Easing.OutCubic
                    }

                    // محتوای فرم ورود
                    ColumnLayout {
                        id: loginForm
                        anchors.centerIn: parent
                        width: parent.width * 0.8
                        spacing: 30 // فاصله بین TextField و دکمه

                        // TextBox مدرن
                        Rectangle {
                            id: background
                            Layout.fillWidth: true
                            Layout.preferredHeight: 120
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
                                font.family: fontFamily
                                horizontalAlignment: TextInput.AlignHCenter
                                selectByMouse: true
                                inputMethodHints: Qt.ImhDigitsOnly

                                // رنگ متن
                                color: textColor
                                placeholderTextColor: hintTextColor

                                // انیمیشن ظاهر شدن تدریجی
                                opacity: 0

                                // انیمیشن ظاهر شدن با تاخیر
                                Timer {
                                    interval: 400
                                    running: true
                                    onTriggered: {
                                        textFieldAnimation.start()
                                    }
                                }

                                NumberAnimation {
                                    id: textFieldAnimation
                                    target: modernTextField
                                    property: "opacity"
                                    from: 0
                                    to: 1
                                    duration: 1000
                                    easing.type: Easing.OutCubic
                                }

                                // MouseArea برای نمایش کیبورد
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        modernTextField.forceActiveFocus()
                                        globalKeyboard.show(modernTextField)
                                        mouse.accepted = false
                                    }
                                }

                                // حذف حاشیه پیش‌فرض
                                background: Rectangle {
                                    color: "transparent"

                                    // خط زیر متن
                                    Rectangle {
                                        id: underline
                                        width: parent.width
                                        height: 2
                                        color: modernTextField.focus ? primaryColor : "#e0e0e0"
                                        anchors.bottom: parent.bottom

                                        Behavior on color {
                                            ColorAnimation { duration: 200 }
                                        }

                                        // انیمیشن خط زیر هنگام فوکوس
                                        states: [
                                            State {
                                                name: "focused"
                                                when: modernTextField.focus
                                                PropertyChanges {
                                                    target: underline
                                                    height: 2.5
                                                }
                                            },
                                            State {
                                                name: "unfocused"
                                                when: !modernTextField.focus
                                                PropertyChanges {
                                                    target: underline
                                                    height: 1
                                                }
                                            }
                                        ]

                                        transitions: [
                                            Transition {
                                                from: "*"; to: "*"
                                                NumberAnimation {
                                                    properties: "height"
                                                    duration: 200
                                                    easing.type: Easing.OutCubic
                                                }
                                            }
                                        ]
                                    }
                                }

                                // لیبل شناور
                                Text {
                                    id: floatingLabel
                                    text: "اپراتور"
                                    color: modernTextField.focus ? primaryColor : labelColor
                                    font.pixelSize: modernTextField.text.length > 0 || modernTextField.focus ? 12 : 16
                                    font.family: fontFamily
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

                                // پاک کردن پیام خطا هنگام تایپ
                                onTextChanged: {
                                    if (errorMessage.visible) {
                                        errorMessage.visible = false
                                    }
                                }
                            }

                            // پیام خطا
                            Text {
                                id: errorMessage
                                anchors.top: modernTextField.bottom
                                anchors.topMargin: 5
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: errorColor
                                font.pixelSize: 14
                                font.family: fontFamily
                                visible: false

                                // انیمیشن نمایش پیام خطا
                                opacity: 0

                                // انیمیشن لرزش هنگام نمایش خطا
                                SequentialAnimation {
                                    id: errorShakeAnimation

                                    PropertyAction {
                                        target: errorMessage
                                        property: "opacity"
                                        value: 1
                                    }

                                    NumberAnimation {
                                        target: errorMessage
                                        property: "x"
                                        from: errorMessage.x - 10
                                        to: errorMessage.x
                                        duration: 100
                                    }

                                    NumberAnimation {
                                        target: errorMessage
                                        property: "x"
                                        from: errorMessage.x + 10
                                        to: errorMessage.x
                                        duration: 100
                                    }

                                    NumberAnimation {
                                        target: errorMessage
                                        property: "x"
                                        from: errorMessage.x - 5
                                        to: errorMessage.x
                                        duration: 100
                                    }

                                    NumberAnimation {
                                        target: errorMessage
                                        property: "x"
                                        from: errorMessage.x + 5
                                        to: errorMessage.x
                                        duration: 100
                                    }
                                }
                            }
                        }

                        // دکمه مدرن
                        Item {
                            id: buttonContainer
                            Layout.preferredWidth: parent.width * 0.5
                            Layout.preferredHeight: 50
                            Layout.alignment: Qt.AlignHCenter

                            // انیمیشن ظاهر شدن دکمه با تاخیر
                            opacity: 0
                            scale: 0.95

                            // تایمر برای تاخیر در نمایش دکمه
                            Timer {
                                interval: 600
                                running: true
                                onTriggered: {
                                    buttonAnimation.start()
                                }
                            }

                            ParallelAnimation {
                                id: buttonAnimation

                                NumberAnimation {
                                    target: buttonContainer
                                    property: "opacity"
                                    from: 0
                                    to: 1
                                    duration: 1000
                                    easing.type: Easing.OutCubic
                                }

                                NumberAnimation {
                                    target: buttonContainer
                                    property: "scale"
                                    from: 0.95
                                    to: 1
                                    duration: 1000
                                    easing.type: Easing.OutBack
                                }
                            }

                            // سایه دکمه
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
                                    family: fontFamily
                                    pixelSize: 16
                                    bold: true
                                }

                                // شخصی‌سازی ظاهر دکمه
                                background: Rectangle {
                                    id: buttonBg
                                    color: loginButton.down ? primaryDarkColor : primaryColor
                                    radius: 25

                                    // گرادیانت زیبا برای دکمه
                                    gradient: Gradient {
                                        orientation: Gradient.Horizontal
                                        GradientStop { position: 0.0; color: primaryColor }
                                        GradientStop { position: 1.0; color: Qt.lighter(primaryColor, 1.2) }
                                    }

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

                                onPressed: {
                                    ripple.xPosition = mouseX
                                    ripple.yPosition = mouseY
                                    rippleAnimation.start()
                                    opacityAnimation.start()
                                }

                                // فراخوانی تابع backend برای بررسی اعتبار کد
                                onClicked: {
                                    // انیمیشن اسپینر
                                    busyIndicator.visible = true
                                    busyIndicator.running = true

                                    // مخفی کردن کیبورد قبل از بررسی
                                    globalKeyboard.hide()

                                    // تاخیر کوتاه برای نمایش اسپینر (در محیط واقعی نیازی به این تاخیر نیست)
                                    loginTimer.start()
                                }
                            }

                            // نشانگر در حال بارگذاری
                            BusyIndicator {
                                id: busyIndicator
                                anchors.centerIn: parent
                                width: 40
                                height: 40
                                visible: false
                                running: false
                            }

                            // تایمر برای شبیه‌سازی بارگذاری
                            Timer {
                                id: loginTimer
                                interval: 1500
                                repeat: false
                                onTriggered: {
                                    busyIndicator.visible = false
                                    busyIndicator.running = false

                                    if (backend) {
                                        if (backend.validateOperatorCode(modernTextField.text)) {
                                            // انیمیشن چرخش کارت قبل از خروج
                                            cardFlipAnimation.start()
                                        } else {
                                            // نمایش خطا
                                            errorMessage.visible = true
                                            errorShakeAnimation.start()
                                        }
                                    } else {
                                        console.error("Backend is not available")
                                        errorMessage.text = "خطا در اتصال به سیستم"
                                        errorMessage.visible = true
                                        errorShakeAnimation.start()
                                    }
                                }
                            }
                        }
                    }
                }

                // کارت روی پشت (صفحه تایید)
                Rectangle {
                    id: backCard
                    anchors.fill: parent
                    radius: 10
                    color: "#f0f8ff"  // رنگ روشن آبی
                    visible: cardRotation.angle > 90

                    // سایه کارت
                    layer.enabled: true
                    layer.effect: DropShadow {
                        transparentBorder: true
                        horizontalOffset: 0
                        verticalOffset: 3
                        radius: 8.0
                        samples: 17
                        color: "#30000000"
                    }

                    // کانتینر محتوا با چرخش معکوس برای خنثی کردن اثر چرخش کارت
                    Item {
                        id: backContentContainer
                        anchors.fill: parent

                        // چرخش معکوس برای محتوای کارت پشتی
                        transform: Rotation {
                            origin.x: backContentContainer.width / 2
                            origin.y: backContentContainer.height / 2
                            axis { x: 1; y: 0; z: 0 }
                            angle: 180  // چرخش معکوس نسبت به کارت
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 20

                            Text {
                                id: successTitle
                                text: "ورود موفقیت‌آمیز"
                                font.family: fontFamily
                                font.pixelSize: 24
                                font.bold: true
                                color: primaryColor
                                anchors.horizontalCenter: parent.horizontalCenter
                                opacity: 0

                                // انیمیشن ظاهر شدن متن
                                NumberAnimation on opacity {
                                    from: 0
                                    to: 1
                                    duration: 500
                                    running: backCard.visible
                                    easing.type: Easing.OutCubic
                                }
                            }

                            // آیکون تیک با انیمیشن
                            Item {
                                id: checkIconContainer
                                width: 80
                                height: 80
                                anchors.horizontalCenter: parent.horizontalCenter

                                Rectangle {
                                    id: successCircle
                                    anchors.centerIn: parent
                                    width: 0
                                    height: 0
                                    radius: width / 2
                                    color: "#4CAF50"  // رنگ سبز

                                    // انیمیشن ظاهر شدن دایره
                                    NumberAnimation on width {
                                        from: 0
                                        to: 80
                                        duration: 400
                                        running: backCard.visible
                                        easing.type: Easing.OutBack
                                        easing.overshoot: 1.2
                                    }

                                    NumberAnimation on height {
                                        from: 0
                                        to: 80
                                        duration: 400
                                        running: backCard.visible
                                        easing.type: Easing.OutBack
                                        easing.overshoot: 1.2
                                    }
                                }

                                // علامت تیک
                                Canvas {
                                    id: checkMark
                                    anchors.fill: parent
                                    anchors.margins: 20
                                    opacity: 0

                                    // انیمیشن ظاهر شدن تیک با تاخیر
                                    NumberAnimation on opacity {
                                        from: 0
                                        to: 1
                                        duration: 400
                                        running: backCard.visible
                                        easing.type: Easing.OutCubic
                                    }

                                    // تاخیر در شروع رسم تیک
                                    Timer {
                                        interval: 400
                                        running: backCard.visible
                                        onTriggered: {
                                            checkMark.requestPaint()
                                        }
                                    }

                                    onPaint: {
                                        var ctx = getContext("2d")
                                        ctx.reset()

                                        ctx.strokeStyle = "white"
                                        ctx.lineWidth = 6
                                        ctx.lineCap = "round"
                                        ctx.lineJoin = "round"

                                        // مسیر تیک
                                        ctx.beginPath()
                                        ctx.moveTo(width * 0.2, height * 0.5)
                                        ctx.lineTo(width * 0.45, height * 0.75)
                                        ctx.lineTo(width * 0.8, height * 0.25)
                                        ctx.stroke()
                                    }
                                }
                            }

                            // پیام موفقیت
                            Text {
                                id: successMessage
                                text: "کد اپراتوری شما با موفقیت تأیید شد"
                                font.family: fontFamily
                                font.pixelSize: 16
                                color: textColor
                                anchors.horizontalCenter: parent.horizontalCenter
                                opacity: 0

                                // انیمیشن ظاهر شدن متن با تاخیر
                                NumberAnimation on opacity {
                                    from: 0
                                    to: 1
                                    duration: 500
                                    running: backCard.visible
                                    easing.type: Easing.OutCubic
                                }
                            }

                            // پیام در حال انتقال
                            Text {
                                id: redirectMessage
                                text: "در حال ورود به صفحه اصلی..."
                                font.family: fontFamily
                                font.pixelSize: 14
                                font.italic: true
                                color: labelColor
                                anchors.horizontalCenter: parent.horizontalCenter
                                opacity: 0

                                // انیمیشن ظاهر شدن متن با تاخیر بیشتر
                                NumberAnimation on opacity {
                                    from: 0
                                    to: 1
                                    duration: 500
                                    running: backCard.visible
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }
                }

                // انیمیشن چرخش کارت
                SequentialAnimation {
                    id: cardFlipAnimation

                    // چرخش به پشت
                    NumberAnimation {
                        target: cardRotation
                        property: "angle"
                        to: 180
                        duration: 800
                        easing.type: Easing.InOutQuad
                    }

                    // تاخیر کوتاه برای نمایش پیام موفقیت
                    PauseAnimation { duration: 2000 }

                    // انیمیشن خروج نرم
                    NumberAnimation {
                        target: loginPage
                        property: "opacity"
                        to: 0
                        duration: 500
                        easing.type: Easing.InQuad
                    }

                    // فراخوانی سیگنال ورود موفق پس از اتمام انیمیشن
                    ScriptAction { script: loginSuccessful() }
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
            errorShakeAnimation.start()
        }
    }

    // دکمه تست برای اجرای انیمیشن flip (فقط برای آزمایش - می‌توانید آن را حذف کنید)
    Rectangle {
        id: testFlipButton
        width: 30
        height: 30
        radius: 15
        color: "#80000000"
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 10
        visible: false  // در حالت عادی مخفی است

        Text {
            anchors.centerIn: parent
            text: "F"
            color: "white"
            font.bold: true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (cardRotation.angle === 0)
                    cardFlipAnimation.start()
                else if (cardRotation.angle === 180)
                    cardRotation.angle = 0

                if (logoRotation.angle === 0)
                    logoRotation.angle = 180
                else if (logoRotation.angle === 180)
                    logoRotation.angle = 0
            }
        }
    }
}
