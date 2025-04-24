import QtQuick
import QtQuick.Controls
import QtQuick.Layouts


Item {
    id: plasmaTimerRoot
    width: parent ? parent.width : 800
    height: parent ? parent.height : 850

    // سیگنال برای بازگشت به صفحه قبل
    signal goBack()

    // پراپرتی‌های بیمار و درمان
    property int patientId: 0
    property string patientCodemeli: ""
    property string patientName: ""
    property int diseaseId: 0
    property string diseaseName: ""
    property int initialMinutes: 2
    property int initialSeconds: 0

    // پراپرتی برای ذخیره تعداد جلسات قبلی
    property int previousSessionsCount: 0
    property string lastSessionDate: ""

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

    // تابع برای دریافت تعداد جلسات قبلی
    function loadPreviousSessions() {
        if (patientId > 0) {
            try {
                // دریافت تعداد جلسات قبلی از بک‌اند
                var sessionsInfo = sessionBackend.getPatientSessionsInfo(patientId)
                previousSessionsCount = sessionsInfo.count || 0
                lastSessionDate = sessionsInfo.lastDate || ""

                logger.log("تعداد جلسات قبلی بیمار: " + previousSessionsCount +
                          ", آخرین جلسه: " + lastSessionDate)
            } catch (error) {
                logger.log("خطا در بارگیری اطلاعات جلسات قبلی: " + error)
                previousSessionsCount = 0
                lastSessionDate = ""
            }
        }
    }

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
                           if (isRunning) {
                               showConfirmDialog("آیا مطمئن هستید که می‌خواهید خارج شوید؟")
                           } else {
                               goBack() // فراخوانی سیگنال بازگشت
                           }
                       } else {
                           //logger.log("Swiped Left")
                       }
                   }
               }
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
                Layout.preferredHeight: 180  // ارتفاع بیشتر برای اطلاعات اضافی
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
                    spacing: 15  // فاصله بین آیتم‌ها

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
                            //text: patientId + "" + diseaseId
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

                    // خط جداکننده
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: "#E0E0E0"
                    }

                    // اطلاعات جلسات قبلی
                    Item {
                        width: parent.width
                        height: sessionsInfoText.height

                        Text {
                            id: sessionsInfoText
                            width: parent.width
                            text: "تعداد جلسات قبلی: " + previousSessionsCount +
                                  (lastSessionDate ? " (آخرین جلسه: " + lastSessionDate + ")" : "")
                            font {
                                family: "Tahoma"
                                pixelSize: 16
                            }
                            color: previousSessionsCount > 0 ? "#388E3C" : "#9E9E9E"
                            elide: Text.ElideRight
                            wrapMode: Text.Wrap
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

            // دکمه‌های اضافی
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                visible: !isRunning

                // دکمه نمایش تاریخچه جلسات
                Button {
                    id: showHistoryButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50

                    contentItem: Text {
                        text: "تاریخچه جلسات"
                        font {
                            family: "Tahoma"
                            pixelSize: 16
                            bold: true
                        }
                        color: "#795548"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 10
                        color: "#EFEBE9"
                        border.color: "#795548"
                        border.width: 1
                    }

                    onClicked: {
                        showSessionHistory()
                    }
                }
            }

            // دکمه ذخیره دستی جلسه
            Button {
                id: manualSaveButton
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                visible: isCompleted // فقط زمانی نمایش داده می‌شود که تایمر به پایان رسیده باشد

                contentItem: Text {
                    text: "ذخیره مجدد جلسه"
                    font {
                        family: "Tahoma"
                        pixelSize: 16
                        bold: true
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
                    saveTherapySession()
                    showToast("جلسه درمانی مجدداً ذخیره شد")
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
                logger.log("Seconds in Timer : " + seconds)
                seconds--
            } else if (minutes > 0) {
                minutes--
                seconds = 59
                logger.log("Minutes in Timer : " + minutes)
            } else {
                // اتمام زمان
                logger.log("In TO TIMER")
                isRunning = false
                isCompleted = true
                try {
                    showToast("زمان درمان به پایان رسید")
                    logger.log("زمان درمان به اتمام رسید")
                    try {
                            relayController.setRelay(1, false)
                            logger.log("رله 1 خاموش شد")
                        } catch (error) {
                           logger.log("خطا در خاموش کردن رله: " + error)
                        }
                    logger.log("Befor Save Save Therapy")
                    // ذخیره جلسه در دیتابیس
                    saveTherapySession()
                } catch (error){
                    logger.log("ERROR : " + error)
                }
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
            totalTimeInSeconds = (minutes * 60) + seconds
            initialMinutes = minutes
            initialSeconds = seconds
            showToast("تایمر شروع شد - در پایان زمان، جلسه ذخیره خواهد شد")
            // روشن کردن رله 1 هنگام شروع تایمر
            try {
               relayController.setRelay(1, true)
               logger.log("رله 1 روشن شد")
            } catch (error) {
               logger.log("خطا در روشن کردن رله: " + error)
           }
        } else {
            showToast("تایمر متوقف شد")
            logger.log("تایمر متوقف شد")
            // خاموش کردن رله 1 هنگام توقف تایمر
            try {
                relayController.setRelay(1, false)
                logger.log("رله 1 خاموش شد")
            } catch (error) {
                logger.log("خطا در خاموش کردن رله: " + error)
          }
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
        showToast("تایمر به حالت اولیه برگشت")
        logger.log("تایمر به حالت اول برگشت")
    }

    // تابع ذخیره جلسه تراپی
    function saveTherapySession() {
        try {
            logger.log("saveTherapySession running");
            // اگر تایمر به صورت کامل اجرا شده باشد
            if (isCompleted) {
                // بررسی معتبر بودن شناسه‌ها
                logger.log("ذخیره جلسه - شناسه بیمار: " + patientId + " شناسه درمان: " + diseaseId);

                if (patientId <= 0 || diseaseId <= 0) {
                    logger.log("شناسه بیمار یا بیماری نامعتبر است");

                    // تلاش مجدد برای یافتن شناسه‌ها
                    if (patientId <= 0 && patientCodemeli) {
                        patientId = patientBackend.getPatientIdByCodeMeli(patientCodemeli);
                        logger.log("تلاش مجدد - شناسه بیمار: " + patientId);
                    }

                    if (diseaseId <= 0 && diseaseName) {
                        var diseaseInfo = diseaseBackend.getDiseaseInfo(diseaseName);
                        if (diseaseInfo && diseaseInfo.id) {
                            diseaseId = diseaseInfo.id;
                            logger.log("تلاش مجدد - شناسه بیماری: " + diseaseId);
                        }
                    }

                    // بررسی مجدد شناسه‌ها
                    if (patientId <= 0 || diseaseId <= 0) {
                        logger.log("خطا: شناسه بیمار یا بیماری همچنان نامعتبر است");
                        showToast("خطا: اطلاعات بیمار یا نوع درمان ناقص است");
                        return;
                    }
                }

                logger.log("در حال ذخیره جلسه با مقادیر: patientId=" + patientId +
                          " diseaseId=" + diseaseId +
                          " minutes=" + initialMinutes +
                          " seconds=" + initialSeconds);

                var success = sessionBackend.addSession(
                    patientId,
                    diseaseId,
                    initialMinutes,
                    initialSeconds,
                    ""  // یادداشت خالی
                );

                logger.log("نتیجه ذخیره جلسه: " + success);

                if (success) {
                    logger.log("جلسه با موفقیت ذخیره شد");
                    showToast("جلسه درمانی با موفقیت در تاریخچه ذخیره شد");
                } else {
                    logger.log("خطا در ذخیره جلسه");
                    showToast("خطا در ذخیره جلسه درمانی");
                }
            } else {
                logger.log("تایمر به پایان نرسیده است، جلسه ذخیره نمی‌شود");
            }
        } catch (error) {
            logger.log("ERROR in saveTherapySession: " + error);
        }
    }
    // تابع نمایش تاریخچه جلسات
    function showSessionHistory() {
        var component = Qt.createComponent("TherapyHistory.qml")
        if (component.status === Component.Ready) {
            var historyPage = component.createObject(plasmaTimerRoot.parent, {
                "patientId": patientId,
                "patientName": patientName,
                "patientCodemeli": patientCodemeli
            })

            historyPage.goBack.connect(function() {
                historyPage.destroy()
                plasmaTimerRoot.visible = true
            })

            plasmaTimerRoot.visible = false
        } else {
            logger.log("خطا در بارگذاری صفحه تاریخچه:", component.errorString())
            showToast("خطا در بارگذاری صفحه تاریخچه")
        }
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
        try {
            logger.log("Showing toast: " + message);
            toastText.text = message;  // به جای toast.text از toastText.text استفاده کنید
            toast.opacity = 1;
            toastTimer.start();
        } catch (error) {
            logger.log("ERROR in showToast: " + error);
        }
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
        logger.log("PlasmaTimer loaded - patientId:"+ patientId+
                    "patientName:"+patientName+ "-"+
                    "diseaseId:"+ diseaseId+ "-"+
                    "diseaseName:"+ diseaseName+ "-"+
                    "initialMinutes:"+ initialMinutes+ "-"+
                    "initialSeconds:"+ initialSeconds+ "-"+
                    "patientCodemeli:"+ patientCodemeli)

        // اگر patientId صفر باشد، سعی کنید آن را بر اساس کد ملی پیدا کنید
        if (patientId <= 0 && patientCodemeli) {
            logger.log("تلاش برای یافتن شناسه بیمار با کد ملی:"+ patientCodemeli)
            patientId = patientBackend.getPatientIdByCodeMeli(patientCodemeli)
            logger.log("شناسه بیمار یافت شده:"+patientId)
        }

        // اگر diseaseId صفر باشد، سعی کنید آن را بر اساس نام بیماری پیدا کنید
        if (diseaseId <= 0 && diseaseName) {
            logger.log("تلاش برای یافتن شناسه بیماری با نام:"+diseaseName)
            var diseaseInfo = diseaseBackend.getDiseaseInfo(diseaseName)
            if (diseaseInfo && diseaseInfo.id) {
                diseaseId = diseaseInfo.id
                logger.log("شناسه بیماری یافت شده:"+ diseaseId)
            }
        }

        // بارگیری اطلاعات جلسات قبلی
        loadPreviousSessions()

        // تنظیم مقادیر اولیه
        minutes = initialMinutes
        logger.log("Minutes : " + minutes)
        seconds = initialSeconds
        logger.log("seconds : " + seconds)
        updateProgress()
        progressCanvas.requestPaint()
    }
}
