import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: therapyHistoryRoot
    width: parent.width
    height: parent.height

    // سیگنال برای بازگشت به صفحه قبل
    signal goBack()

    // پراپرتی‌های بیمار
    property int patientId: 0
    property string patientName: ""
    property string patientCodemeli: ""

    // مدل داده‌ها برای جلسات
    property var sessionsModel: []

    // لود کردن لیست جلسات از دیتابیس
    function loadSessions() {
        sessionsModel = sessionBackend.getPatientSessions(patientId)
        console.log("تعداد جلسات بارگذاری شده:", sessionsModel.length)
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
                        goBack() // فراخوانی سیگنال بازگشت
                    }
                }
            }

            // عنوان صفحه
            Text {
                text: "تاریخچه جلسات درمانی"
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

            // اطلاعات بیمار
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                color: "white"
                radius: 10

                // سایه ساده
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width + 6
                    height: parent.height + 6
                    radius: 10
                    color: "#20000000"
                    z: -1
                }

                // اطلاعات بیمار
                Column {
                    anchors {
                        fill: parent
                        margins: 20
                    }
                    spacing: 15

                    Text {
                        text: "نام بیمار: " + patientName
                        font {
                            family: "Tahoma"
                            pixelSize: 16
                            bold: true
                        }
                        color: "#424242"
                        width: parent.width
                        elide: Text.ElideRight
                    }

                    Text {
                        text: "کد ملی: " + patientCodemeli
                        font {
                            family: "Tahoma"
                            pixelSize: 16
                        }
                        color: "#424242"
                        width: parent.width
                    }
                }
            }

            // جدول تاریخچه جلسات
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "white"
                radius: 10

                // سایه ساده
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width + 6
                    height: parent.height + 6
                    radius: 10
                    color: "#20000000"
                    z: -1
                }

                // سربرگ جدول
                Rectangle {
                    id: tableHeader
                    width: parent.width
                    height: 40
                    color: "#E3F2FD"
                    radius: 10

                    // فقط گوشه‌های بالا گرد باشند
                    Rectangle {
                        width: parent.width
                        height: parent.height / 2
                        color: parent.color
                        anchors.bottom: parent.bottom
                    }

                    Row {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 5

                        Text {
                            width: parent.width * 0.25
                            text: "تاریخ"
                            font {
                                family: "Tahoma"
                                pixelSize: 14
                                bold: true
                            }
                            color: "#1976D2"
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            height: parent.height
                        }

                        Text {
                            width: parent.width * 0.25
                            text: "نوع درمان"
                            font {
                                family: "Tahoma"
                                pixelSize: 14
                                bold: true
                            }
                            color: "#1976D2"
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            height: parent.height
                        }

                        Text {
                            width: parent.width * 0.15
                            text: "مدت"
                            font {
                                family: "Tahoma"
                                pixelSize: 14
                                bold: true
                            }
                            color: "#1976D2"
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            height: parent.height
                        }

                        Text {
                            width: parent.width * 0.15
                            text: "وضعیت"
                            font {
                                family: "Tahoma"
                                pixelSize: 14
                                bold: true
                            }
                            color: "#1976D2"
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            height: parent.height
                        }

                        Text {
                            width: parent.width * 0.20
                            text: "عملیات"
                            font {
                                family: "Tahoma"
                                pixelSize: 14
                                bold: true
                            }
                            color: "#1976D2"
                            horizontalAlignment: Text.AlignCenter
                            verticalAlignment: Text.AlignVCenter
                            height: parent.height
                        }
                    }
                }

                // لیست جلسات
                ListView {
                    id: sessionsListView
                    anchors {
                        top: tableHeader.bottom
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                        margins: 1
                    }
                    clip: true
                    model: sessionsModel

                    delegate: Rectangle {
                        width: sessionsListView.width
                        height: 60
                        color: index % 2 === 0 ? "#FFFFFF" : "#F5F5F5"

                        // تبدیل تاریخ به فرمت مناسب
                        function formatDate(dateString) {
                            var date = new Date(dateString);
                            return date.toLocaleDateString(Qt.locale("fa_IR"), "yyyy/MM/dd") + " " +
                                   date.toLocaleTimeString(Qt.locale("fa_IR"), "hh:mm");
                        }

                        Row {
                            anchors {
                                fill: parent
                                margins: 10
                            }
                            spacing: 5

                            Text {
                                width: parent.width * 0.25
                                text: formatDate(modelData.session_date)
                                font {
                                    family: "Tahoma"
                                    pixelSize: 12
                                }
                                color: "#424242"
                                horizontalAlignment: Text.AlignRight
                                verticalAlignment: Text.AlignVCenter
                                height: parent.height
                                elide: Text.ElideRight
                            }

                            Text {
                                width: parent.width * 0.25
                                text: modelData.disease_name
                                font {
                                    family: "Tahoma"
                                    pixelSize: 12
                                }
                                color: "#424242"
                                horizontalAlignment: Text.AlignRight
                                verticalAlignment: Text.AlignVCenter
                                height: parent.height
                                elide: Text.ElideRight
                            }

                            Text {
                                width: parent.width * 0.15
                                text: (modelData.duration_minutes < 10 ? "0" : "") + modelData.duration_minutes + ":" +
                                      (modelData.duration_seconds < 10 ? "0" : "") + modelData.duration_seconds
                                font {
                                    family: "Tahoma"
                                    pixelSize: 12
                                }
                                color: "#424242"
                                horizontalAlignment: Text.AlignRight
                                verticalAlignment: Text.AlignVCenter
                                height: parent.height
                            }

                            Text {
                                width: parent.width * 0.15
                                text: modelData.completed ? "کامل" : "ناقص"
                                font {
                                    family: "Tahoma"
                                    pixelSize: 12
                                }
                                color: modelData.completed ? "#4CAF50" : "#F44336"
                                horizontalAlignment: Text.AlignRight
                                verticalAlignment: Text.AlignVCenter
                                height: parent.height
                            }

                            // دکمه‌های عملیات
                            Row {
                                width: parent.width * 0.20
                                height: parent.height
                                spacing: 10

                                // دکمه نمایش جزئیات
                                Button {
                                    width: 30
                                    height: 30
                                    anchors.verticalCenter: parent.verticalCenter

                                    contentItem: Text {
                                        text: "👁"
                                        font.pixelSize: 16
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    background: Rectangle {
                                        radius: 15
                                        color: parent.down ? "#E3F2FD" : "transparent"
                                        border.color: "#1976D2"
                                        border.width: 1
                                    }

                                    onClicked: {
                                        // نمایش جزئیات جلسه
                                        showSessionDetails(modelData.id)
                                    }
                                }

                                // دکمه حذف جلسه
                                Button {
                                    width: 30
                                    height: 30
                                    anchors.verticalCenter: parent.verticalCenter

                                    contentItem: Text {
                                        text: "×"
                                        font {
                                            pixelSize: 20
                                            bold: true
                                        }
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        color: "#F44336"
                                    }

                                    background: Rectangle {
                                        radius: 15
                                        color: parent.down ? "#FFEBEE" : "transparent"
                                        border.color: "#F44336"
                                        border.width: 1
                                    }

                                    onClicked: {
                                        // حذف جلسه
                                        showDeleteConfirmDialog(modelData.id)
                                    }
                                }
                            }
                        }
                    }

                    // نمایش پیام در صورت خالی بودن لیست
                    Text {
                        anchors.centerIn: parent
                        text: "هیچ جلسه‌ای ثبت نشده است"
                        font {
                            family: "Tahoma"
                            pixelSize: 16
                        }
                        color: "#9E9E9E"
                        visible: sessionsListView.count === 0
                    }
                }
            }
        }
    }

    // دیالوگ تایید حذف جلسه
    Popup {
        id: deleteConfirmDialog
        modal: true
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: Math.min(parent.width - 40, 400)
        padding: 20

        property int sessionId: 0

        ColumnLayout {
            spacing: 20
            width: parent.width

            Text {
                text: "تایید حذف"
                font {
                    family: "Tahoma"
                    pixelSize: 18
                    bold: true
                }
                Layout.fillWidth: true
            }

            Text {
                text: "آیا از حذف این جلسه اطمینان دارید؟"
                font.family: "Tahoma"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: 10
                Layout.fillWidth: true
                Layout.topMargin: 10

                Button {
                    text: "بله"
                    Layout.fillWidth: true
                    onClicked: {
                        var success = sessionBackend.deleteSession(deleteConfirmDialog.sessionId)
                        if (success) {
                            showToast("جلسه با موفقیت حذف شد")
                            loadSessions()
                        } else {
                            showToast("خطا در حذف جلسه")
                        }
                        deleteConfirmDialog.close()
                    }
                }

                Button {
                    text: "خیر"
                    Layout.fillWidth: true
                    onClicked: {
                        deleteConfirmDialog.close()
                    }
                }
            }
        }
    }

    // دیالوگ نمایش جزئیات جلسه
    Popup {
        id: sessionDetailsDialog
        modal: true
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: Math.min(parent.width - 40, 400)
        height: Math.min(parent.height - 80, 500)
        padding: 20

        property int sessionId: 0
        property var sessionDetails: null

        function loadSessionDetails() {
            sessionDetails = sessionBackend.getSessionDetails(sessionId)
        }

        function formatDate(dateString) {
            var date = new Date(dateString);
            return date.toLocaleDateString(Qt.locale("fa_IR"), "yyyy/MM/dd") + " " +
                   date.toLocaleTimeString(Qt.locale("fa_IR"), "hh:mm");
        }

        onOpened: {
            loadSessionDetails()
        }

        ColumnLayout {
            spacing: 15
            anchors.fill: parent

            Text {
                text: "جزئیات جلسه"
                font {
                    family: "Tahoma"
                    pixelSize: 18
                    bold: true
                }
                Layout.fillWidth: true
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ColumnLayout {
                    width: sessionDetailsDialog.width - 40
                    spacing: 15

                    // اطلاعات بیمار
                    GroupBox {
                        title: "اطلاعات بیمار"
                        Layout.fillWidth: true

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 10

                            Text {
                                text: "نام: " + (sessionDetailsDialog.sessionDetails ? sessionDetailsDialog.sessionDetails.patient_name : "")
                                font.family: "Tahoma"
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "کد ملی: " + (sessionDetailsDialog.sessionDetails ? sessionDetailsDialog.sessionDetails.national_id : "")
                                font.family: "Tahoma"
                                Layout.fillWidth: true
                            }
                        }
                    }

                    // اطلاعات جلسه
                    GroupBox {
                        title: "اطلاعات جلسه"
                        Layout.fillWidth: true

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 10

                            Text {
                                text: "نوع درمان: " + (sessionDetailsDialog.sessionDetails ? sessionDetailsDialog.sessionDetails.disease_name : "")
                                font.family: "Tahoma"
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "تاریخ: " + (sessionDetailsDialog.sessionDetails ? sessionDetailsDialog.formatDate(sessionDetailsDialog.sessionDetails.session_date) : "")
                                font.family: "Tahoma"
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "مدت زمان: " + (sessionDetailsDialog.sessionDetails ?
                                    ((sessionDetailsDialog.sessionDetails.duration_minutes < 10 ? "0" : "") + sessionDetailsDialog.sessionDetails.duration_minutes + ":" +
                                    (sessionDetailsDialog.sessionDetails.duration_seconds < 10 ? "0" : "") + sessionDetailsDialog.sessionDetails.duration_seconds) : "")
                                font.family: "Tahoma"
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "وضعیت: " + (sessionDetailsDialog.sessionDetails ? (sessionDetailsDialog.sessionDetails.completed ? "کامل" : "ناقص") : "")
                                font.family: "Tahoma"
                                color: sessionDetailsDialog.sessionDetails && sessionDetailsDialog.sessionDetails.completed ? "#4CAF50" : "#F44336"
                                Layout.fillWidth: true
                            }
                        }
                    }

                    // یادداشت‌ها
                    GroupBox {
                        title: "یادداشت‌ها"
                        Layout.fillWidth: true

                        TextArea {
                            anchors.fill: parent
                            text: sessionDetailsDialog.sessionDetails ? sessionDetailsDialog.sessionDetails.notes : ""
                            readOnly: true
                            wrapMode: TextArea.Wrap
                            font.family: "Tahoma"
                            background: Rectangle {
                                color: "#F5F5F5"
                                border.color: "#E0E0E0"
                                border.width: 1
                                radius: 5
                            }
                        }
                    }
                }
            }

            // دکمه بستن
            Button {
                text: "بستن"
                Layout.fillWidth: true
                onClicked: {
                    sessionDetailsDialog.close()
                }
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

    // تابع نمایش دیالوگ تایید حذف
    function showDeleteConfirmDialog(sessionId) {
        deleteConfirmDialog.sessionId = sessionId
        deleteConfirmDialog.open()
    }

    // تابع نمایش دیالوگ جزئیات جلسه
    function showSessionDetails(sessionId) {
        sessionDetailsDialog.sessionId = sessionId
        sessionDetailsDialog.open()
    }

    // اتصال به سیگنال به‌روزرسانی جلسات
    Connections {
        target: sessionBackend
        function onSessionUpdated() {
            console.log("سیگنال به‌روزرسانی جلسات دریافت شد")
            loadSessions() // به‌روزرسانی لیست جلسات
        }
    }

    Component.onCompleted: {
        loadSessions() // بارگذاری لیست جلسات در هنگام بارگذاری صفحه
    }
}
