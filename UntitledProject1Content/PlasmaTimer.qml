import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: plasmaTimerRoot
    width: parent.width
    height: parent.height

    // سیگنال برای بازگشت به صفحه قبل
    signal goBack()

    // پراپرتی‌های بیمار و درمان
    property string patientCodemeli: ""
    property string patientName: ""
    property string diseaseName: ""
    property int initialMinutes: 2
    property int initialSeconds: 0

    // پراپرتی‌های تایمر
    property int minutes: initialMinutes
    property int seconds: initialSeconds
    property bool isRunning: false
    property bool isCompleted: false
    property real progress: 1.0 // مقدار پیشرفت برای انیمیشن (1.0 = کامل، 0.0 = اتمام)

    // محاسبه زمان کل به ثانیه
    property int totalTimeInSeconds: (initialMinutes * 60) + initialSeconds
    property int remainingTimeInSeconds: (minutes * 60) + seconds

    // محاسبه پیشرفت بر اساس زمان باقی‌مانده
    function updateProgress() {
        if (totalTimeInSeconds > 0) {
            progress = remainingTimeInSeconds / totalTimeInSeconds
        } else {
            progress = 0
        }
    }

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
                    onClicked: {
                        if (isRunning) {
                            showConfirmDialog("آیا مطمئن هستید که می‌خواهید خارج شوید؟")
                        } else {
                            goBack() // فراخوانی سیگنال بازگشت
                        }
                    }
                }
            }

            // عنوان صفحه
            Text {
                text: "تایمر پلاسما تراپی"
                font {
                    family: "Tahoma"
                    pixelSize: 18
                    bold: true
                }
                color: "white"
                anchors.centerIn: parent
            }
        }

        // محتوای اصلی صفحه
        ColumnLayout {
            anchors {
                top: header.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: 20
            }
            spacing: 20

            // اطلاعات بیمار و درمان
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 150  // ارتفاع ثابت بیشتر برای اطلاعات
                color: "white"
                radius: 10

                // سایه ساده با استفاده از Rectangle
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width + 6
                    height: parent.height + 6
                    radius: 10
                    color: "#20000000"
                    z: -1
                }

                // استفاده از Column به جای ColumnLayout
                Column {
                    id: infoLayout
                    anchors {
                        fill: parent
                        margins: 20
                    }
                    spacing: 20  // فاصله بیشتر بین آیتم‌ها

                    // نام بیمار
                    Item {
                        width: parent.width
                        height: patientNameText.height

                        Text {
                            id: patientNameText
                            width: parent.width
                            text: "نام بیمار: " + patientName
                            font {
                                family: "Tahoma"
                                pixelSize: 16
                            }
                            color: "#424242"
                            elide: Text.ElideRight
                            wrapMode: Text.NoWrap
                        }
                    }

                    // کد ملی
                    Item {
                        width: parent.width
                        height: patientCodeText.height

                        Text {
                            id: patientCodeText
                            width: parent.width
                            text: "کد ملی: " + patientCodemeli
                            font {
                                family: "Tahoma"
                                pixelSize: 16
                            }
                            color: "#424242"
                            elide: Text.ElideRight
                            wrapMode: Text.NoWrap
                        }
                    }

                    // نوع درمان
                    Item {
                        width: parent.width
                        height: diseaseNameText.height

                        Text {
                            id: diseaseNameText
                            width: parent.width
                            text: "نوع درمان: " + diseaseName
                            font {
                                family: "Tahoma"
                                pixelSize: 16
                                bold: true
                            }
                            color: "#1976D2"
                            elide: Text.ElideRight
                            wrapMode: Text.NoWrap
                        }
                    }
                }
            }

            // نمایش تایمر با انیمیشن
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 300
                color: "white"
                radius: 10

                // سایه ساده با استفاده از Rectangle
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width + 6
                    height: parent.height + 6
                    radius: 10
                    color: "#20000000"
                    z: -1
                }

                // انیمیشن دایره‌ای تایمر
                Item {
                    id: timerAnimation
                    width: 220
                    height: 220
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 20

                    // دایره خارجی (پس‌زمینه)
                    Rectangle {
                        id: outerCircle
                        anchors.fill: parent
                        radius: width / 2
                        color: "#F5F5F5"
                        border.color: "#E0E0E0"
                        border.width: 2
                    }

                    // دایره پیشرفت (انیمیشن)
                    Canvas {
                        id: progressCanvas
                        anchors.fill: parent
                        antialiasing: true

                        property color progressColor: isCompleted ? "#4CAF50" : (isRunning ? "#2196F3" : "#9E9E9E")

                        onPaint: {
                            var ctx = getContext("2d")
                            var centerX = width / 2
                            var centerY = height / 2
                            var radius = Math.min(width, height) / 2 - 5

                            // پاک کردن کانواس
                            ctx.reset()

                            // رسم کمان پیشرفت
                            ctx.beginPath()
                            ctx.lineWidth = 8
                            ctx.strokeStyle = progressColor

                            // شروع از بالا و حرکت ساعتگرد
                            var startAngle = -Math.PI / 2
                            var endAngle = startAngle + (2 * Math.PI * progress)

                            ctx.arc(centerX, centerY, radius, startAngle, endAngle, false)
                            ctx.stroke()

                            // نقطه متحرک در انتهای کمان
                            if (isRunning) {
                                var dotX = centerX + radius * Math.cos(endAngle)
                                var dotY = centerY + radius * Math.sin(endAngle)

                                ctx.beginPath()
                                ctx.fillStyle = progressColor
                                ctx.arc(dotX, dotY, 6, 0, 2 * Math.PI)
                                ctx.fill()
                            }
                        }
                    }

                    // افکت درخشش برای حالت در حال اجرا
                    Rectangle {
                        id: pulseEffect
                        anchors.centerIn: parent
                        width: parent.width - 30
                        height: parent.height - 30
                        radius: width / 2
                        color: progressCanvas.progressColor
                        opacity: 0.1
                        visible: isRunning

                        SequentialAnimation {
                            running: isRunning
                            loops: Animation.Infinite

                            PropertyAnimation {
                                target: pulseEffect
                                property: "scale"
                                from: 0.8
                                to: 1.1
                                duration: 1000
                                easing.type: Easing.InOutQuad
                            }

                            PropertyAnimation {
                                target: pulseEffect
                                property: "scale"
                                from: 1.1
                                to: 0.8
                                duration: 1000
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }

                    // نمایش زمان دیجیتال در وسط
                    Text {
                        id: timerDisplay
                        text: (minutes < 10 ? "0" : "") + minutes + ":" +
                              (seconds < 10 ? "0" : "") + seconds
                        font {
                            family: "Tahoma"
                            pixelSize: 44
                            bold: true
                        }
                        color: isCompleted ? "#4CAF50" : (isRunning ? "#1976D2" : "#9E9E9E")
                        anchors.centerIn: parent
                    }
                }

                // نمایش پیام اتمام
                Text {
                    visible: isCompleted
                    text: "درمان با موفقیت به پایان رسید"
                    font {
                        family: "Tahoma"
                        pixelSize: 18
                        bold: true
                    }
                    color: "#4CAF50"
                    anchors.top: timerAnimation.bottom
                    anchors.topMargin: 20
                    anchors.horizontalCenter: parent.horizontalCenter

                    // انیمیشن چشمک‌زن برای پیام اتمام
                    SequentialAnimation on opacity {
                        running: isCompleted
                        loops: Animation.Infinite

                        PropertyAnimation {
                            from: 1.0
                            to: 0.3
                            duration: 800
                            easing.type: Easing.InOutQuad
                        }

                        PropertyAnimation {
                            from: 0.3
                            to: 1.0
                            duration: 800
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }

            // دکمه‌های کنترل تایمر
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                spacing: 20

                // دکمه شروع/توقف
                Button {
                    id: startStopButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60

                    contentItem: Text {
                        text: isRunning ? "توقف" : (isCompleted ? "شروع مجدد" : "شروع")
                        font {
                            family: "Tahoma"
                            pixelSize: 18
                            bold: true
                        }
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 10
                        color: {
                            if (isCompleted) return "#4CAF50"
                            return isRunning ? "#F44336" : "#4CAF50"
                        }
                    }

                    onClicked: {
                        if (isCompleted) {
                            // ریست کردن تایمر
                            resetTimer()
                        } else {
                            // شروع یا توقف تایمر
                            toggleTimer()
                        }
                    }
                }

                // دکمه ریست
                Button {
                    id: resetButton
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 60
                    visible: !isRunning

                    contentItem: Text {
                        text: "⟲"
                        font {
                            pixelSize: 24
                            bold: true
                        }
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 10
                        color: "#FF9800"
                    }

                    onClicked: {
                        resetTimer()
                    }
                }
            }

            // دکمه‌های تنظیم زمان
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 10
                columnSpacing: 10
                visible: !isRunning

                // تنظیم دقیقه
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        text: "دقیقه"
                        font {
                            family: "Tahoma"
                            pixelSize: 16
                        }
                        color: "#424242"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Button {
                            Layout.preferredWidth: 50
                            Layout.preferredHeight: 50
                            text: "+"
                            font.pixelSize: 20
                            onClicked: {
                                if (minutes < 99) minutes++
                                updateProgress()
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            color: "#F5F5F5"
                            border.color: "#E0E0E0"
                            border.width: 1
                            radius: 5

                            Text {
                                text: minutes
                                font {
                                    family: "Tahoma"
                                    pixelSize: 18
                                }
                                anchors.centerIn: parent
                            }
                        }

                        Button {
                            Layout.preferredWidth: 50
                            Layout.preferredHeight: 50
                            text: "-"
                            font.pixelSize: 20
                            enabled: minutes > 0
                            onClicked: {
                                if (minutes > 0) minutes--
                                updateProgress()
                            }
                        }
                    }
                }

                // تنظیم ثانیه
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        text: "ثانیه"
                        font {
                            family: "Tahoma"
                            pixelSize: 16
                        }
                        color: "#424242"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Button {
                            Layout.preferredWidth: 50
                            Layout.preferredHeight: 50
                            text: "+"
                            font.pixelSize: 20
                            onClicked: {
                                if (seconds < 59) {
                                    seconds++
                                } else {
                                    seconds = 0
                                    if (minutes < 99) minutes++
                                }
                                updateProgress()
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            color: "#F5F5F5"
                            border.color: "#E0E0E0"
                            border.width: 1
                            radius: 5

                            Text {
                                text: seconds
                                font {
                                    family: "Tahoma"
                                    pixelSize: 18
                                }
                                anchors.centerIn: parent
                            }
                        }

                        Button {
                            Layout.preferredWidth: 50
                            Layout.preferredHeight: 50
                            text: "-"
                            font.pixelSize: 20
                            enabled: seconds > 0 || minutes > 0
                            onClicked: {
                                if (seconds > 0) {
                                    seconds--
                                } else if (minutes > 0) {
                                    minutes--
                                    seconds = 59
                                }
                                updateProgress()
                            }
                        }
                    }
                }
            }

            // دکمه ذخیره زمان به عنوان پیش‌فرض
            Button {
                id: saveDefaultTimeButton
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                visible: !isRunning

                contentItem: Text {
                    text: "ذخیره به عنوان زمان پیش‌فرض"
                    font {
                        family: "Tahoma"
                        pixelSize: 14
                    }
                    color: "#1976D2"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 10
                    color: "#E3F2FD"
                    border.color: "#1976D2"
                    border.width: 1
                }

                onClicked: {
                    var success = diseaseBackend.updateDiseaseTime(diseaseName, minutes, seconds)
                    if (success) {
                        showToast("زمان پیش‌فرض با موفقیت ذخیره شد")
                    } else {
                        showToast("خطا در ذخیره زمان پیش‌فرض")
                    }
                }
            }
        }
    }

    // تایمر برای شمارش معکوس
    Timer {
        id: countdownTimer
        interval: 1000
        repeat: true
        running: isRunning
        onTriggered: {
            if (seconds > 0) {
                seconds--
            } else if (minutes > 0) {
                minutes--
                seconds = 59
            } else {
                // اتمام زمان
                isRunning = false
                isCompleted = true
                showToast("زمان درمان به پایان رسید")
            }

            // به‌روزرسانی مقدار پیشرفت
            updateProgress()
            // به‌روزرسانی نمایش انیمیشن
            progressCanvas.requestPaint()
        }
    }

    // تابع شروع/توقف تایمر
    function toggleTimer() {
        if (minutes === 0 && seconds === 0) {
            showToast("لطفاً زمان را تنظیم کنید")
            return
        }

        isRunning = !isRunning

        if (isRunning) {
            isCompleted = false
            // به‌روزرسانی زمان کل در صورت تغییر
            totalTimeInSeconds = (initialMinutes * 60) + initialSeconds
        }

        // به‌روزرسانی نمایش انیمیشن
        progressCanvas.requestPaint()
    }

    // تابع ریست کردن تایمر
    function resetTimer() {
        isRunning = false
        isCompleted = false
        minutes = initialMinutes
        seconds = initialSeconds
        updateProgress()
        progressCanvas.requestPaint()
    }

    // دیالوگ تایید خروج
    function showConfirmDialog(message) {
        var component = Qt.createComponent("ConfirmDialog.qml")
        if (component.status === Component.Ready) {
            var dialog = component.createObject(plasmaTimerRoot, {
                "message": message
            })

            dialog.accepted.connect(function() {
                isRunning = false
                goBack()
            })

            dialog.open()
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

    Component.onCompleted: {
        console.log("PlasmaTimer loaded - patientName:", patientName,
                    "diseaseName:", diseaseName,
                    "initialMinutes:", initialMinutes,
                    "initialSeconds:", initialSeconds)

        // تنظیم مقادیر اولیه
        minutes = initialMinutes
        seconds = initialSeconds
        updateProgress()
        progressCanvas.requestPaint()
    }
}
