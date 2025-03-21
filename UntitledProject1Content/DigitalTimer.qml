import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Item {
    id: root
    width: 400  // عرض مناسب
    height: 350 // ارتفاع بیشتر برای جا شدن دکمه‌ها

    // پراپرتی‌های قابل تنظیم
    property int minutes: 0
    property int seconds: 0
    property bool running: false
    property bool isCountdown: true // شمارش معکوس

    // پراپرتی‌های رنگ
    property color accentColor: "#2962FF"
    property color accentLightColor: "#82B1FF"
    property color accentDarkColor: "#0039CB"
    property color backgroundColor: "#FFFFFF"
    property color digitColor: "white"
    property color buttonTextColor: "white"

    // سیگنال‌ها
    signal timerCompleted()

    // تایمر داخلی
    Timer {
        id: timer
        interval: 1000 // هر ثانیه
        running: root.running
        repeat: true
        onTriggered: {
            updateTime();
        }
    }

    // تابع به‌روزرسانی زمان
    function updateTime() {
        if (isCountdown) {
            // شمارش معکوس
            if (seconds > 0) {
                seconds--;
            } else {
                if (minutes > 0) {
                    minutes--;
                    seconds = 59;
                } else {
                    // تایمر به پایان رسیده است
                    stop();
                    timerCompleted();
                    completionMessage.visible = true; // نمایش پیام پایان تایمر
                }
            }
        } else {
            // شمارش عادی
            seconds++;
            if (seconds >= 60) {
                seconds = 0;
                minutes++;
            }
        }
    }

    // تابع شروع تایمر
    function start() {
        running = true;
        pulseAnimation.start();
    }

    // تابع توقف تایمر
    function stop() {
        running = false;
        pulseAnimation.stop();
    }

    // تابع ریست تایمر
    function reset() {
        running = false;
        pulseAnimation.stop();
        minutes = 0;
        seconds = 0;
    }

    // تابع تنظیم زمان
    function setTime(m, s) {
        minutes = m;
        seconds = s;
    }

    // افزایش زمان
    function increaseMinutes() {
        if (!running) {
            minutes = Math.min(minutes + 1, 99);
        }
    }

    function increaseSeconds() {
        if (!running) {
            seconds++;
            if (seconds >= 60) {
                seconds = 0;
                increaseMinutes();
            }
        }
    }

    // کاهش زمان
    function decreaseMinutes() {
        if (!running && minutes > 0) {
            minutes--;
        }
    }

    function decreaseSeconds() {
        if (!running) {
            if (seconds > 0) {
                seconds--;
            } else if (minutes > 0) {
                minutes--;
                seconds = 59;
            }
        }
    }

    // تبدیل عدد به رشته دو رقمی
    function pad(number) {
        return number < 10 ? '0' + number : number;
    }

    // انیمیشن پالس
    SequentialAnimation {
        id: pulseAnimation
        running: false
        loops: Animation.Infinite

        PropertyAnimation {
            target: timerBackground
            property: "scale"
            to: 1.03
            duration: 500
            easing.type: Easing.InOutQuad
        }

        PropertyAnimation {
            target: timerBackground
            property: "scale"
            to: 1.0
            duration: 500
            easing.type: Easing.InOutQuad
        }
    }

    // اتصال سیگنال پایان تایمر به نمایش پیام
    Connections {
        target: root
        function onTimerCompleted() {
            completionMessage.visible = true;
        }
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: "#F5F5F5"
        radius: 20

        Rectangle {
            id: timerBackground
            width: parent.width - 24
            height: parent.height - 24
            radius: 16
            anchors.centerIn: parent
            color: backgroundColor

            // سایه برای کارت
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#40000000"
                shadowHorizontalOffset: 0
                shadowVerticalOffset: 3
                shadowBlur: 12
                shadowOpacity: 0.3
            }

            // گرادیان بالای کارت
            Rectangle {
                id: topGradient
                height: 8
                radius: 4
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 5
                }

                gradient: Gradient {
                    GradientStop { position: 0.0; color: accentLightColor }
                    GradientStop { position: 1.0; color: accentColor }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10 // کاهش فاصله بین عناصر

                // عنوان تایمر
                Text {
                    text: "تایمر پلاسما تراپی"
                    font {
                        family: "Tahoma"
                        pixelSize: 18
                        bold: true
                    }
                    color: accentColor
                    Layout.alignment: Qt.AlignHCenter
                }

                // نمایش زمان و دکمه‌های کنترل
                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 15

                    // ستون دکمه‌های دقیقه
                    ColumnLayout {
                        spacing: 5 // کاهش فاصله بین عناصر

                        // دکمه افزایش دقیقه
                        RoundButton {
                            id: minUpButton
                            Layout.preferredWidth: 50
                            Layout.preferredHeight: 50
                            Layout.alignment: Qt.AlignHCenter
                            enabled: !running

                            contentItem: Text {
                                text: "+"
                                font.pixelSize: 30
                                font.bold: true
                                color: minUpButton.enabled ? buttonTextColor : "#AAAAAA"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                radius: 25
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: minUpButton.enabled ? (minUpButton.pressed ? accentDarkColor : accentColor) : "#DDDDDD" }
                                    GradientStop { position: 1.0; color: minUpButton.enabled ? (minUpButton.pressed ? accentColor : accentLightColor) : "#EEEEEE" }
                                }

                                // سایه برای دکمه
                                layer.enabled: minUpButton.enabled
                                layer.effect: MultiEffect {
                                    shadowEnabled: true
                                    shadowColor: accentColor
                                    shadowHorizontalOffset: 0
                                    shadowVerticalOffset: 2
                                    shadowBlur: 8
                                    shadowOpacity: 0.3
                                }
                            }

                            onClicked: {
                                increaseMinutes();
                            }
                        }

                        // نمایش دقیقه
                        Rectangle {
                            Layout.preferredWidth: 85
                            Layout.preferredHeight: 85
                            Layout.alignment: Qt.AlignHCenter
                            radius: 10
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: accentColor }
                                GradientStop { position: 1.0; color: accentDarkColor }
                            }

                            layer.enabled: true
                            layer.effect: MultiEffect {
                                shadowEnabled: true
                                shadowColor: accentColor
                                shadowHorizontalOffset: 0
                                shadowVerticalOffset: 3
                                shadowBlur: 10
                                shadowOpacity: 0.4
                            }

                            Text {
                                anchors.centerIn: parent
                                text: pad(minutes)
                                font {
                                    pixelSize: 46
                                    bold: true
                                    family: "Tahoma"
                                }
                                color: digitColor
                            }

                            // افکت نقطه‌ای برای نمایش وضعیت فعال
                            Rectangle {
                                width: 8
                                height: 8
                                radius: 4
                                color: running ? "#4CAF50" : "transparent"
                                anchors {
                                    top: parent.top
                                    right: parent.right
                                    margins: 8
                                }

                                // انیمیشن چشمک زدن
                                SequentialAnimation on opacity {
                                    running: root.running
                                    loops: Animation.Infinite
                                    PropertyAnimation { to: 0.3; duration: 800 }
                                    PropertyAnimation { to: 1.0; duration: 800 }
                                }
                            }

                            // برچسب دقیقه
                            Text {
                                text: "دقیقه"
                                font {
                                    family: "Tahoma"
                                    pixelSize: 12
                                }
                                color: "white"
                                anchors {
                                    bottom: parent.bottom
                                    horizontalCenter: parent.horizontalCenter
                                    bottomMargin: 6
                                }
                            }
                        }

                        // دکمه کاهش دقیقه
                        RoundButton {
                            id: minDownButton
                            Layout.preferredWidth: 50
                            Layout.preferredHeight: 50
                            Layout.alignment: Qt.AlignHCenter
                            enabled: !running

                            contentItem: Text {
                                text: "-"
                                font.pixelSize: 30
                                font.bold: true
                                color: minDownButton.enabled ? buttonTextColor : "#AAAAAA"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                radius: 25
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: minDownButton.enabled ? (minDownButton.pressed ? accentDarkColor : accentColor) : "#DDDDDD" }
                                    GradientStop { position: 1.0; color: minDownButton.enabled ? (minDownButton.pressed ? accentColor : accentLightColor) : "#EEEEEE" }
                                }

                                // سایه برای دکمه
                                layer.enabled: minDownButton.enabled
                                layer.effect: MultiEffect {
                                    shadowEnabled: true
                                    shadowColor: accentColor
                                    shadowHorizontalOffset: 0
                                    shadowVerticalOffset: 2
                                    shadowBlur: 8
                                    shadowOpacity: 0.3
                                }
                            }

                            onClicked: {
                                decreaseMinutes();
                            }
                        }
                    }

                    // جداکننده
                    Item {
                        Layout.preferredWidth: 25
                        Layout.preferredHeight: 85

                        Text {
                            anchors.centerIn: parent
                            text: ":"
                            font {
                                pixelSize: 46
                                bold: true
                                family: "Tahoma"
                            }
                            color: accentColor

                            // انیمیشن چشمک زدن
                            SequentialAnimation on opacity {
                                running: root.running
                                loops: Animation.Infinite
                                PropertyAnimation { to: 0.3; duration: 500 }
                                PropertyAnimation { to: 1.0; duration: 500 }
                            }
                        }
                    }

                    // ستون دکمه‌های ثانیه
                    ColumnLayout {
                        spacing: 5 // کاهش فاصله بین عناصر

                        // دکمه افزایش ثانیه
                        RoundButton {
                            id: secUpButton
                            Layout.preferredWidth: 50
                            Layout.preferredHeight: 50
                            Layout.alignment: Qt.AlignHCenter
                            enabled: !running

                            contentItem: Text {
                                text: "+"
                                font.pixelSize: 30
                                font.bold: true
                                color: secUpButton.enabled ? buttonTextColor : "#AAAAAA"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                radius: 25
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: secUpButton.enabled ? (secUpButton.pressed ? accentDarkColor : accentColor) : "#DDDDDD" }
                                    GradientStop { position: 1.0; color: secUpButton.enabled ? (secUpButton.pressed ? accentColor : accentLightColor) : "#EEEEEE" }
                                }

                                // سایه برای دکمه
                                layer.enabled: secUpButton.enabled
                                layer.effect: MultiEffect {
                                    shadowEnabled: true
                                    shadowColor: accentColor
                                    shadowHorizontalOffset: 0
                                    shadowVerticalOffset: 2
                                    shadowBlur: 8
                                    shadowOpacity: 0.3
                                }
                            }

                            onClicked: {
                                increaseSeconds();
                            }
                        }

                        // نمایش ثانیه
                        Rectangle {
                            Layout.preferredWidth: 85
                            Layout.preferredHeight: 85
                            Layout.alignment: Qt.AlignHCenter
                            radius: 10
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: accentColor }
                                GradientStop { position: 1.0; color: accentDarkColor }
                            }

                            layer.enabled: true
                            layer.effect: MultiEffect {
                                shadowEnabled: true
                                shadowColor: accentColor
                                shadowHorizontalOffset: 0
                                shadowVerticalOffset: 3
                                shadowBlur: 10
                                shadowOpacity: 0.4
                            }

                            Text {
                                anchors.centerIn: parent
                                text: pad(seconds)
                                font {
                                    pixelSize: 46
                                    bold: true
                                    family: "Tahoma"
                                }
                                color: digitColor
                            }

                            // برچسب ثانیه
                            Text {
                                text: "ثانیه"
                                font {
                                    family: "Tahoma"
                                    pixelSize: 12
                                }
                                color: "white"
                                anchors {
                                    bottom: parent.bottom
                                    horizontalCenter: parent.horizontalCenter
                                    bottomMargin: 6
                                }
                            }
                        }

                        // دکمه کاهش ثانیه
                        RoundButton {
                            id: secDownButton
                            Layout.preferredWidth: 50
                            Layout.preferredHeight: 50
                            Layout.alignment: Qt.AlignHCenter
                            enabled: !running

                            contentItem: Text {
                                text: "-"
                                font.pixelSize: 30
                                font.bold: true
                                color: secDownButton.enabled ? buttonTextColor : "#AAAAAA"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                radius: 25
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: secDownButton.enabled ? (secDownButton.pressed ? accentDarkColor : accentColor) : "#DDDDDD" }
                                    GradientStop { position: 1.0; color: secDownButton.enabled ? (secDownButton.pressed ? accentColor : accentLightColor) : "#EEEEEE" }
                                }

                                // سایه برای دکمه
                                layer.enabled: secDownButton.enabled
                                layer.effect: MultiEffect {
                                    shadowEnabled: true
                                    shadowColor: accentColor
                                    shadowHorizontalOffset: 0
                                    shadowVerticalOffset: 2
                                    shadowBlur: 8
                                    shadowOpacity: 0.3
                                }
                            }

                            onClicked: {
                                decreaseSeconds();
                            }
                        }
                    }
                }

                // پیش‌تنظیم‌های زمان
                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 10

                    Button {
                        text: "1 دقیقه"
                        Layout.preferredHeight: 30
                        enabled: !running

                        contentItem: Text {
                            text: "1 دقیقه"
                            font {
                                pixelSize: 12
                                family: "Tahoma"
                            }
                            color: parent.enabled ? "#424242" : "#AAAAAA"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            radius: 5
                            color: parent.pressed ? "#E0E0E0" : "#F5F5F5"
                            border.color: "#BDBDBD"
                            border.width: 1
                        }

                        onClicked: {
                            if (!running) {
                                setTime(1, 0);
                            }
                        }
                    }

                    Button {
                        text: "2 دقیقه"
                        Layout.preferredHeight: 30
                        enabled: !running

                        contentItem: Text {
                            text: "2 دقیقه"
                            font {
                                pixelSize: 12
                                family: "Tahoma"
                            }
                            color: parent.enabled ? "#424242" : "#AAAAAA"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            radius: 5
                            color: parent.pressed ? "#E0E0E0" : "#F5F5F5"
                            border.color: "#BDBDBD"
                            border.width: 1
                        }

                        onClicked: {
                            if (!running) {
                                setTime(2, 0);
                            }
                        }
                    }

                    Button {
                        text: "5 دقیقه"
                        Layout.preferredHeight: 30
                        enabled: !running

                        contentItem: Text {
                            text: "5 دقیقه"
                            font {
                                pixelSize: 12
                                family: "Tahoma"
                            }
                            color: parent.enabled ? "#424242" : "#AAAAAA"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            radius: 5
                            color: parent.pressed ? "#E0E0E0" : "#F5F5F5"
                            border.color: "#BDBDBD"
                            border.width: 1
                        }

                        onClicked: {
                            if (!running) {
                                setTime(5, 0);
                            }
                        }
                    }
                }

                // دکمه‌های کنترل
                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter
                    Layout.topMargin: 5
                    spacing: 20

                    // دکمه شروع/توقف
                    Button {
                        id: startStopButton
                        Layout.preferredWidth: 140
                        Layout.preferredHeight: 50

                        contentItem: Text {
                            text: running ? "توقف" : "شروع"
                            font {
                                pixelSize: 18
                                bold: true
                                family: "Tahoma"
                            }
                            color: buttonTextColor
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            radius: 25
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: running ? "#F44336" : "#4CAF50" }
                                GradientStop { position: 1.0; color: running ? "#D32F2F" : "#388E3C" }
                            }

                            // سایه برای دکمه
                            layer.enabled: true
                            layer.effect: MultiEffect {
                                shadowEnabled: true
                                shadowColor: running ? "#F44336" : "#4CAF50"
                                shadowHorizontalOffset: 0
                                shadowVerticalOffset: 3
                                shadowBlur: 10
                                shadowOpacity: 0.3
                            }

                            // افکت هاور
                            Rectangle {
                                anchors.fill: parent
                                radius: 25
                                color: "white"
                                opacity: startStopButton.hovered ? 0.2 : 0

                                Behavior on opacity {
                                    NumberAnimation { duration: 200 }
                                }
                            }
                        }

                        onClicked: {
                            if (running) {
                                stop();
                            } else {
                                // اگر تایمر صفر است، شروع نکن
                                if (minutes === 0 && seconds === 0 && isCountdown) {
                                    return;
                                }
                                start();
                            }
                        }
                    }

                    // دکمه ریست
                    Button {
                        id: resetButton
                        Layout.preferredWidth: 140
                        Layout.preferredHeight: 50

                        contentItem: Text {
                            text: "ریست"
                            font {
                                pixelSize: 18
                                bold: true
                                family: "Tahoma"
                            }
                            color: buttonTextColor
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            radius: 25
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#607D8B" }
                                GradientStop { position: 1.0; color: "#455A64" }
                            }

                            // سایه برای دکمه
                            layer.enabled: true
                            layer.effect: MultiEffect {
                                shadowEnabled: true
                                shadowColor: "#607D8B"
                                shadowHorizontalOffset: 0
                                shadowVerticalOffset: 3
                                shadowBlur: 10
                                shadowOpacity: 0.3
                            }

                            // افکت هاور
                            Rectangle {
                                anchors.fill: parent
                                radius: 25
                                color: "white"
                                opacity: resetButton.hovered ? 0.2 : 0

                                Behavior on opacity {
                                    NumberAnimation { duration: 200 }
                                }
                            }
                        }

                        onClicked: {
                            reset();
                        }
                    }
                }
            }
        }
    }

    // نمایش پیام پایان تایمر
    Rectangle {
        id: completionMessage
        anchors.fill: parent
        color: "#80000000"
        visible: false
        z: 10

        // انیمیشن ظاهر شدن
        NumberAnimation on opacity {
            from: 0
            to: 1
            duration: 300
            running: completionMessage.visible
        }

        Rectangle {
            width: 320
            height: 220
            radius: 20
            color: "white"
            anchors.centerIn: parent

            // سایه برای کارت
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#40000000"
                shadowHorizontalOffset: 0
                shadowVerticalOffset: 4
                shadowBlur: 15
                shadowOpacity: 0.4
            }

            // گرادیان بالای کارت
            Rectangle {
                height: 10
                radius: 5
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 5
                }

                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#4CAF50" }
                    GradientStop { position: 1.0; color: "#388E3C" }
                }
            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20

                // آیکون تیک
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 70
                    height: 70
                    radius: 35
                    color: "#4CAF50"

                    Text {
                        anchors.centerIn: parent
                        text: "✓"
                        font {
                            pixelSize: 42
                            bold: true
                        }
                        color: "white"
                    }

                    // انیمیشن ظاهر شدن آیکون
                    SequentialAnimation on scale {
                        running: completionMessage.visible
                        NumberAnimation { from: 0; to: 1.2; duration: 300; easing.type: Easing.OutBack }
                        NumberAnimation { from: 1.2; to: 1.0; duration: 200; easing.type: Easing.OutBack }
                    }
                }

                Text {
                    text: "زمان درمان به پایان رسید"
                    font {
                        pixelSize: 22
                        bold: true
                        family: "Tahoma"
                    }
                    color: "#212121"
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "لطفاً دستگاه را خاموش کنید"
                    font {
                        pixelSize: 16
                        family: "Tahoma"
                    }
                    color: "#757575"
                    Layout.alignment: Qt.AlignHCenter
                }

                Button {
                    text: "تأیید"
                    Layout.preferredWidth: 150
                    Layout.preferredHeight: 50
                    Layout.alignment: Qt.AlignHCenter

                    contentItem: Text {
                        text: "تأیید"
                        font {
                            pixelSize: 18
                            bold: true
                            family: "Tahoma"
                        }
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 25
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#4CAF50" }
                            GradientStop { position: 1.0; color: "#388E3C" }
                        }

                        // سایه برای دکمه
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowColor: "#4CAF50"
                            shadowHorizontalOffset: 0
                            shadowVerticalOffset: 3
                            shadowBlur: 10
                            shadowOpacity: 0.3
                        }
                    }

                    onClicked: {
                        completionMessage.visible = false;
                    }
                }
            }

            // انیمیشن ظاهر شدن کارت
            NumberAnimation on scale {
                from: 0.8
                to: 1.0
                duration: 300
                easing.type: Easing.OutBack
                running: completionMessage.visible
            }
        }
    }
}
