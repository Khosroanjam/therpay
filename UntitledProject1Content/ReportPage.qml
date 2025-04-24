// ReportPage.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: reportPage
    //width: 800
    //height: 750
    anchors.fill: parent
    // سیگنال برای بازگشت به صفحه قبلی
    signal backRequested()

    // پارامترهای ورودی
    property var stackView: null
    property var globalKeyboard: null
    property var reportBackend: null

    // داده‌های آماری
    property int totalPatients: 0
    property int totalSessions: 0
    property int currentMonthSessions: 0
    property var diseaseDistribution: []
    property var weeklySessionCount: []
    property var patientsList: []
    property var sessionsList: []
    property var diseaseStatistics: []

    // تابع بارگذاری همه داده‌ها
    function loadAllData() {
        logger.log("Loading report data...")

        // بررسی وجود بک‌اند
        if (!reportBackend) {
            logger.error("ReportBackend is not available!")
            return
        }

        try {
            // بارگذاری آمار کلی
            totalPatients = reportBackend.getTotalPatientCount()
            totalSessions = reportBackend.getTotalSessionCount()
            currentMonthSessions = reportBackend.getCurrentMonthSessionCount()

            // بارگذاری توزیع بیماری‌ها
            diseaseDistribution = reportBackend.getDiseaseDistribution()

            // بارگذاری آمار هفتگی
            weeklySessionCount = reportBackend.getWeeklySessionCount()

            // بارگذاری لیست بیماران
            patientsList = reportBackend.getPatientsList("", "", "name")

            // بارگذاری لیست جلسات
            sessionsList = reportBackend.getSessionsList("", "", 0)

            // بارگذاری آمار بیماری‌ها
            diseaseStatistics = reportBackend.getDiseaseStatistics()

            logger.log("Report data loaded successfully")
        } catch (e) {
            logger.log("Error loading report data:"+e)
        }
    }
    // نمایش اطلاعات یک بیمار خاص
    function showPatientSessions(patientId, patientName) {
        // بارگذاری جلسات مربوط به بیمار
        sessionsList = reportBackend.getPatientSessions(patientId)

        // تغییر تب به لیست جلسات
        tabBar.currentIndex = 2

        // نمایش نام بیمار در بالای لیست جلسات
        patientSessionsTitle.text = "جلسات درمانی بیمار: " + patientName
        patientSessionsTitle.visible = true
    }
    // تابع بارگذاری آمار بیماری‌های یک بیمار خاص
    function loadPatientDiseaseStatistics(patientId, patientName) {
        logger.log("Loading disease statistics for patient: " + patientName + " (ID: " + patientId + ")")

        try {
            // بارگذاری آمار بیماری‌های بیمار
            var patientDiseaseStats = reportBackend.getPatientDiseaseStatistics(patientId)

            // تغییر تب به آمار بیماری‌ها
            tabBar.currentIndex = 3

            // نمایش نام بیمار در بالای آمار
            patientDiseaseStatsTitle.text = "آمار بیماری‌های بیمار: " + patientName
            patientDiseaseStatsTitle.visible = true

            // به‌روزرسانی مدل داده‌های نمودار یا جدول
            diseaseStatisticsModel.clear()

            // اگر آرایه خالی است، پیام مناسب نمایش دهید
            if (patientDiseaseStats.length === 0) {
                logger.log("No disease statistics found for patient")
                // می‌توانید یک پیام به کاربر نشان دهید
                return
            }

            // افزودن داده‌ها به مدل
            for (var i = 0; i < patientDiseaseStats.length; i++) {
                diseaseStatisticsModel.append(patientDiseaseStats[i])
            }

            // پنهان کردن ListView کلی و نمایش ListView مخصوص بیمار
            diseaseStatsView.visible = false
            diseaseStatsListView.visible = true

            logger.log("Loaded statistics for " + patientDiseaseStats.length + " diseases")
        } catch (e) {
            logger.log("Error loading patient disease statistics: " + e)
        }
    }

    // فقط یک بار Component.onCompleted در کل فایل
    Component.onCompleted: {
        logger.log("ReportPage loaded successfully")
        loadAllData()
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
                           backRequested()
                       } else {
                           logger.log("Swiped Left")
                       }
                   }
               }
           }
       }

    Rectangle {
        anchors.fill: parent
        color: "#F5F5F5"

        // نوار بالایی (هدر)
        Rectangle {
            id: headerBar
            width: parent.width
            height: 70
            color: "#3F51B5"

            // سایه ساده برای هدر
            Rectangle {
                anchors.top: parent.bottom
                width: parent.width
                height: 2
                color: "#30000000"
            }

            Text {
                text: "گزارش‌گیری و آمار"
                color: "white"
                font {
                    family: "Tahoma"
                    pixelSize: 22
                    bold: true
                }
                anchors.centerIn: parent
            }

            // دکمه بازگشت
            Rectangle {
                id: backButton
                width: 120
                height: 40
                radius: 20
                color: backMouseArea.pressed ? Qt.darker("#FF5722", 1.2) : "#FF5722"
                anchors {
                    left: parent.left
                    leftMargin: 15
                    verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "بازگشت"
                    color: "white"
                    font {
                        family: "Tahoma"
                        pixelSize: 14
                        bold: true
                    }
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: backMouseArea
                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: {
                        backRequested()
                    }
                }

                Behavior on color {
                    ColorAnimation { duration: 100 }
                }
            }

            // دکمه بازخوانی
            Rectangle {
                id: refreshButton
                width: 120
                height: 40
                radius: 20
                color: refreshMouseArea.pressed ? Qt.darker("#4CAF50", 1.2) : "#4CAF50"
                anchors {
                    right: parent.right
                    rightMargin: 15
                    verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "بازخوانی"
                    color: "white"
                    font {
                        family: "Tahoma"
                        pixelSize: 14
                        bold: true
                    }
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: refreshMouseArea
                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: {
                        loadAllData()
                    }
                }

                Behavior on color {
                    ColorAnimation { duration: 100 }
                }
            }
        }

        // تب‌ها
        TabBar {
            id: tabBar
            width: parent.width
            anchors.top: headerBar.bottom

            TabButton {
                id: overviewTabButton
                text: "آمار کلی"
                font {
                    family: "Tahoma"
                    pixelSize: 14
                    bold: true
                }
                width: implicitWidth + 20
            }

            TabButton {
                id: patientsTabButton
                text: "لیست بیماران"
                font {
                    family: "Tahoma"
                    pixelSize: 14
                    bold: true
                }
                width: implicitWidth + 20
            }

            TabButton {
                id: sessionsTabButton
                text: "لیست جلسات"
                font {
                    family: "Tahoma"
                    pixelSize: 14
                    bold: true
                }
                width: implicitWidth + 20
            }

            TabButton {
                id: diseaseStatsTabButton
                text: "آمار بیماری‌ها"
                font {
                    family: "Tahoma"
                    pixelSize: 14
                    bold: true
                }
                width: implicitWidth + 20
            }
        }

        StackLayout {
            id: tabContent
            anchors {
                top: tabBar.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                topMargin: 10
                leftMargin: 10
                rightMargin: 10
                bottomMargin: 10
            }
            currentIndex: tabBar.currentIndex

            // تب آمار کلی
            Item {
                id: overviewTab

                ScrollView {
                    id: overviewScrollView
                    anchors.fill: parent
                    contentWidth: parent.width
                    contentHeight: overviewColumn.height
                    clip: true

                    ColumnLayout {
                        id: overviewColumn
                        width: parent.width
                        spacing: 20

                        // کارت‌های آمار کلی
                        RowLayout {
                            id: statsCardsRow
                            Layout.fillWidth: true
                            spacing: 20

                            // تعداد کل بیماران
                            Rectangle {
                                id: totalPatientsCard
                                Layout.fillWidth: true
                                Layout.preferredHeight: 120
                                radius: 10
                                color: "white"

                                // سایه ساده
                                Rectangle {
                                    anchors.fill: parent
                                    radius: 10
                                    color: "#20000000"
                                    z: -1
                                }

                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 10

                                    Text {
                                        text: "تعداد کل بیماران"
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 16
                                        }
                                        color: "#555555"
                                        Layout.alignment: Qt.AlignHCenter
                                    }

                                    Text {
                                        text: totalPatients
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 30
                                            bold: true
                                        }
                                        color: "#3F51B5"
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                }
                            }

                            // تعداد کل جلسات
                            Rectangle {
                                id: totalSessionsCard
                                Layout.fillWidth: true
                                Layout.preferredHeight: 120
                                radius: 10
                                color: "white"

                                // سایه ساده
                                Rectangle {
                                    anchors.fill: parent
                                    radius: 10
                                    color: "#20000000"
                                    z: -1
                                }

                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 10

                                    Text {
                                        text: "تعداد کل جلسات"
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 16
                                        }
                                        color: "#555555"
                                        Layout.alignment: Qt.AlignHCenter
                                    }

                                    Text {
                                        text: totalSessions
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 30
                                            bold: true
                                        }
                                        color: "#4CAF50"
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                }
                            }

                            // تعداد جلسات ماه جاری
                            Rectangle {
                                id: monthlySessionsCard
                                Layout.fillWidth: true
                                Layout.preferredHeight: 120
                                radius: 10
                                color: "white"

                                // سایه ساده
                                Rectangle {
                                    anchors.fill: parent
                                    radius: 10
                                    color: "#20000000"
                                    z: -1
                                }

                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 10

                                    Text {
                                        text: "جلسات ماه جاری"
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 16
                                        }
                                        color: "#555555"
                                        Layout.alignment: Qt.AlignHCenter
                                    }

                                    Text {
                                        text: currentMonthSessions
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 30
                                            bold: true
                                        }
                                        color: "#FF9800"
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                }
                            }
                        }

                        // توزیع انواع درمان
                        Rectangle {
                            id: diseaseDistributionCard
                            Layout.fillWidth: true
                            Layout.preferredHeight: 300
                            radius: 10
                            color: "white"

                            // سایه ساده
                            Rectangle {
                                anchors.fill: parent
                                radius: 10
                                color: "#20000000"
                                z: -1
                            }

                            ColumnLayout {
                                anchors {
                                    fill: parent
                                    margins: 15
                                }
                                spacing: 10

                                Text {
                                    text: "توزیع انواع درمان"
                                    font {
                                        family: "Tahoma"
                                        pixelSize: 18
                                        bold: true
                                    }
                                    color: "#333333"
                                }

                                ListView {
                                    id: diseaseDistributionList
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    clip: true
                                    model: diseaseDistribution

                                    delegate: Rectangle {
                                        width: diseaseDistributionList.width
                                        height: 50
                                        color: "transparent"

                                        RowLayout {
                                            anchors {
                                                fill: parent
                                                margins: 5
                                            }
                                            spacing: 10

                                            Text {
                                                text: modelData.name
                                                font {
                                                    family: "Tahoma"
                                                    pixelSize: 14
                                                }
                                                color: "#333333"
                                                Layout.preferredWidth: parent.width * 0.6
                                                elide: Text.ElideRight
                                            }

                                            Rectangle {
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 20
                                                color: "#EEEEEE"
                                                radius: 5

                                                Rectangle {
                                                    height: parent.height
                                                    width: {
                                                        // محاسبه عرض بر اساس تعداد
                                                        let maxCount = 0;
                                                        for (let i = 0; i < diseaseDistribution.length; i++) {
                                                            if (diseaseDistribution[i].count > maxCount) {
                                                                maxCount = diseaseDistribution[i].count;
                                                            }
                                                        }
                                                        return maxCount > 0 ? (modelData.count / maxCount) * parent.width : 0;
                                                    }
                                                    color: Qt.hsla((index * 0.15) % 1.0, 0.7, 0.5, 1.0)
                                                    radius: 5
                                                }
                                            }

                                            Text {
                                                text: modelData.count
                                                font {
                                                    family: "Tahoma"
                                                    pixelSize: 14
                                                    bold: true
                                                }
                                                color: "#333333"
                                                Layout.preferredWidth: 50
                                                horizontalAlignment: Text.AlignRight
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // آمار هفتگی
                        Rectangle {
                            id: weeklyStatsCard
                            Layout.fillWidth: true
                            Layout.preferredHeight: 300
                            radius: 10
                            color: "white"

                            // سایه ساده
                            Rectangle {
                                anchors.fill: parent
                                radius: 10
                                color: "#20000000"
                                z: -1
                            }

                            ColumnLayout {
                                anchors {
                                    fill: parent
                                    margins: 15
                                }
                                spacing: 10

                                Text {
                                    text: "آمار هفتگی جلسات"
                                    font {
                                        family: "Tahoma"
                                        pixelSize: 18
                                        bold: true
                                    }
                                    color: "#333333"
                                }

                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    Row {
                                        id: weeklyChartBars
                                        anchors {
                                            left: parent.left
                                            right: parent.right
                                            bottom: parent.bottom
                                            bottomMargin: 30
                                        }
                                        height: parent.height - 60
                                        spacing: (width - weeklySessionCount.length * 40) / (weeklySessionCount.length + 1)

                                        Repeater {
                                            model: weeklySessionCount

                                            Item {
                                                width: 40
                                                height: parent.height

                                                Rectangle {
                                                    width: parent.width
                                                    anchors.bottom: parent.bottom
                                                    height: {
                                                        // محاسبه ارتفاع بر اساس تعداد
                                                        let maxCount = 0;
                                                        for (let i = 0; i < weeklySessionCount.length; i++) {
                                                            if (weeklySessionCount[i].count > maxCount) {
                                                                maxCount = weeklySessionCount[i].count;
                                                            }
                                                        }
                                                        return maxCount > 0 ? (modelData.count / maxCount) * parent.height : 0;
                                                    }
                                                    color: "#3F51B5"
                                                    radius: 5

                                                    Text {
                                                        anchors {
                                                            bottom: parent.top
                                                            bottomMargin: 5
                                                            horizontalCenter: parent.horizontalCenter
                                                        }
                                                        text: modelData.count
                                                        font {
                                                            family: "Tahoma"
                                                            pixelSize: 12
                                                            bold: true
                                                        }
                                                        color: "#333333"
                                                    }
                                                }

                                                Text {
                                                    anchors {
                                                        top: parent.bottom
                                                        topMargin: 5
                                                        horizontalCenter: parent.horizontalCenter
                                                    }
                                                    text: {
                                                        // تبدیل تاریخ به فرمت روز/ماه
                                                        let dateParts = modelData.date.split('-');
                                                        if (dateParts.length === 3) {
                                                            return dateParts[2] + '/' + dateParts[1];
                                                        }
                                                        return modelData.date;
                                                    }
                                                    font {
                                                        family: "Tahoma"
                                                        pixelSize: 12
                                                    }
                                                    color: "#555555"
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // تب لیست بیماران
            // تب لیست بیماران - با دکمه مشاهده گزارش‌ها
            Item {
                id: patientsTab

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10

                    // فیلترها
                    Rectangle {
                        id: patientFiltersCard
                        Layout.fillWidth: true
                        Layout.preferredHeight: 70
                        color: "white"
                        radius: 10

                        // سایه ساده
                        Rectangle {
                            anchors.fill: parent
                            radius: 10
                            color: "#20000000"
                            z: -1
                        }

                        RowLayout {
                            anchors {
                                fill: parent
                                margins: 10
                            }
                            spacing: 10

                            // جستجو
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                color: "#F5F5F5"
                                radius: 5

                                TextInput {
                                    id: patientSearchField
                                    anchors {
                                        fill: parent
                                        margins: 10
                                    }
                                    font {
                                        family: "Tahoma"
                                        pixelSize: 14
                                    }
                                    color: "#333333"
                                    clip: true

                                    property string placeholderText: "جستجو بر اساس نام یا کد ملی..."

                                    Text {
                                        anchors {
                                            fill: parent
                                            leftMargin: 5
                                        }
                                        text: patientSearchField.placeholderText
                                        font: patientSearchField.font
                                        color: "#AAAAAA"
                                        visible: !patientSearchField.text
                                    }
                                }
                            }

                            // جنسیت
                            ComboBox {
                                id: genderFilter
                                Layout.preferredWidth: 150
                                Layout.preferredHeight: 40
                                model: ["همه", "آقا", "خانم"]

                                background: Rectangle {
                                    color: "#F5F5F5"
                                    radius: 5
                                }

                                contentItem: Text {
                                    text: genderFilter.displayText
                                    font {
                                        family: "Tahoma"
                                        pixelSize: 14
                                    }
                                    color: "#333333"
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                    leftPadding: 10
                                }
                            }

                            // مرتب‌سازی
                            ComboBox {
                                id: sortFilter
                                Layout.preferredWidth: 180
                                Layout.preferredHeight: 40
                                model: ["نام", "سن", "تعداد جلسات"]

                                property var sortFields: ["name", "age", "session_count"]

                                background: Rectangle {
                                    color: "#F5F5F5"
                                    radius: 5
                                }

                                contentItem: Text {
                                    text: "مرتب‌سازی: " + sortFilter.displayText
                                    font {
                                        family: "Tahoma"
                                        pixelSize: 14
                                    }
                                    color: "#333333"
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                    leftPadding: 10
                                }
                            }

                            // دکمه جستجو
                            Rectangle {
                                id: patientSearchButton
                                Layout.preferredWidth: 100
                                Layout.preferredHeight: 40
                                color: patientSearchButtonMouseArea.pressed ? Qt.darker("#4CAF50", 1.2) : "#4CAF50"
                                radius: 5

                                Text {
                                    anchors.centerIn: parent
                                    text: "جستجو"
                                    font {
                                        family: "Tahoma"
                                        pixelSize: 14
                                        bold: true
                                    }
                                    color: "white"
                                }

                                MouseArea {
                                    id: patientSearchButtonMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true

                                    onClicked: {
                                        let genderValue = ""
                                        if (genderFilter.currentIndex === 1) genderValue = "0"
                                        if (genderFilter.currentIndex === 2) genderValue = "1"

                                        patientsList = reportBackend.getPatientsList(
                                            patientSearchField.text,
                                            genderValue,
                                            sortFilter.sortFields[sortFilter.currentIndex]
                                        )
                                    }
                                }

                                Behavior on color {
                                    ColorAnimation { duration: 100 }
                                }
                            }
                        }
                    }

                    // جدول بیماران
                    Rectangle {
                        id: patientsTableCard
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "white"
                        radius: 10

                        // سایه ساده
                        Rectangle {
                            anchors.fill: parent
                            radius: 10
                            color: "#20000000"
                            z: -1
                        }

                        ColumnLayout {
                            anchors {
                                fill: parent
                                margins: 10
                            }
                            spacing: 0

                            // هدر جدول
                            Rectangle {
                                id: patientsTableHeader
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                color: "#EEEEEE"
                                radius: 5

                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 5

                                    Text {
                                        Layout.preferredWidth: 50
                                        Layout.fillHeight: true
                                        text: "ردیف"
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 14
                                            bold: true
                                        }
                                        color: "#333333"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 1
                                        Layout.fillHeight: true
                                        color: "#DDDDDD"
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        text: "نام بیمار"
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 14
                                            bold: true
                                        }
                                        color: "#333333"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 1
                                        Layout.fillHeight: true
                                        color: "#DDDDDD"
                                    }

                                    Text {
                                        Layout.preferredWidth: 120
                                        Layout.fillHeight: true
                                        text: "کد ملی"
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 14
                                            bold: true
                                        }
                                        color: "#333333"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 1
                                        Layout.fillHeight: true
                                        color: "#DDDDDD"
                                    }

                                    Text {
                                        Layout.preferredWidth: 60
                                        Layout.fillHeight: true
                                        text: "سن"
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 14
                                            bold: true
                                        }
                                        color: "#333333"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 1
                                        Layout.fillHeight: true
                                        color: "#DDDDDD"
                                    }

                                    Text {
                                        Layout.preferredWidth: 70
                                        Layout.fillHeight: true
                                        text: "جنسیت"
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 14
                                            bold: true
                                        }
                                        color: "#333333"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 1
                                        Layout.fillHeight: true
                                        color: "#DDDDDD"
                                    }

                                    Text {
                                        Layout.preferredWidth: 80
                                        Layout.fillHeight: true
                                        text: "تعداد جلسات"
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 14
                                            bold: true
                                        }
                                        color: "#333333"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 1
                                        Layout.fillHeight: true
                                        color: "#DDDDDD"
                                    }

                                    Text {
                                        Layout.preferredWidth: 120
                                        Layout.fillHeight: true
                                        text: "آخرین جلسه"
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 14
                                            bold: true
                                        }
                                        color: "#333333"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 1
                                        Layout.fillHeight: true
                                        color: "#DDDDDD"
                                    }

                                    Text {
                                        Layout.preferredWidth: 210
                                        Layout.fillHeight: true
                                        text: "گزارش‌ها"
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 14
                                            bold: true
                                        }
                                        color: "#333333"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }

                            // محتوای جدول
                            ListView {
                                id: patientsListView
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true
                                model: patientsList

                                delegate: Rectangle {
                                    width: patientsListView.width
                                    height: 50
                                    color: index % 2 === 0 ? "#FFFFFF" : "#F9F9F9"

                                    RowLayout {
                                        anchors.fill: parent
                                        spacing: 5

                                        Text {
                                            Layout.preferredWidth: 50
                                            Layout.fillHeight: true
                                            text: index + 1
                                            font {
                                                family: "Tahoma"
                                                pixelSize: 14
                                            }
                                            color: "#333333"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        Rectangle {
                                            Layout.preferredWidth: 1
                                            Layout.fillHeight: true
                                            color: "#EEEEEE"
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            text: modelData.name
                                            font {
                                                family: "Tahoma"
                                                pixelSize: 14
                                            }
                                            color: "#333333"
                                            elide: Text.ElideRight
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        Rectangle {
                                            Layout.preferredWidth: 1
                                            Layout.fillHeight: true
                                            color: "#EEEEEE"
                                        }

                                        Text {
                                            Layout.preferredWidth: 120
                                            Layout.fillHeight: true
                                            text: modelData.codemeli
                                            font {
                                                family: "Tahoma"
                                                pixelSize: 14
                                            }
                                            color: "#333333"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        Rectangle {
                                            Layout.preferredWidth: 1
                                            Layout.fillHeight: true
                                            color: "#EEEEEE"
                                        }

                                        Text {
                                            Layout.preferredWidth: 60
                                            Layout.fillHeight: true
                                            text: modelData.age
                                            font {
                                                family: "Tahoma"
                                                pixelSize: 14
                                            }
                                            color: "#333333"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        Rectangle {
                                            Layout.preferredWidth: 1
                                            Layout.fillHeight: true
                                            color: "#EEEEEE"
                                        }

                                        Text {
                                            Layout.preferredWidth: 70
                                            Layout.fillHeight: true
                                            text: modelData.gender === 0 ? "آقا" : "خانم"
                                            font {
                                                family: "Tahoma"
                                                pixelSize: 14
                                            }
                                            color: "#333333"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        Rectangle {
                                            Layout.preferredWidth: 1
                                            Layout.fillHeight: true
                                            color: "#EEEEEE"
                                        }

                                        Text {
                                            Layout.preferredWidth: 80
                                            Layout.fillHeight: true
                                            text: modelData.sessionCount
                                            font {
                                                family: "Tahoma"
                                                pixelSize: 14
                                            }
                                            color: "#333333"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        Rectangle {
                                            Layout.preferredWidth: 1
                                            Layout.fillHeight: true
                                            color: "#EEEEEE"
                                        }

                                        Text {
                                            Layout.preferredWidth: 120
                                            Layout.fillHeight: true
                                            text: modelData.lastSession
                                            font {
                                                family: "Tahoma"
                                                pixelSize: 14
                                            }
                                            color: "#333333"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        Rectangle {
                                            Layout.preferredWidth: 1
                                            Layout.fillHeight: true
                                            color: "#EEEEEE"
                                        }

                                        // دکمه مشاهده گزارش‌ها
                                        Rectangle {
                                            Layout.preferredWidth: 100
                                            Layout.preferredHeight: 30
                                            Layout.alignment: Qt.AlignVCenter
                                            color: reportButtonMouseArea.pressed ? Qt.darker("#3F51B5", 1.2) : "#3F51B5"
                                            radius: 5

                                            Text {
                                                anchors.centerIn: parent
                                                text: "مشاهده"
                                                font {
                                                    family: "Tahoma"
                                                    pixelSize: 12
                                                    bold: true
                                                }
                                                color: "white"
                                            }

                                            MouseArea {
                                                id: reportButtonMouseArea
                                                anchors.fill: parent
                                                hoverEnabled: true

                                                onClicked: {
                                                    // نمایش جلسات مربوط به این بیمار
                                                    showPatientSessions(modelData.id, modelData.name)
                                                }
                                            }

                                            Behavior on color {
                                                ColorAnimation { duration: 100 }
                                            }

                                        }
                                        // اضافه کردن دکمه آمار بیماری‌ها
                                        Rectangle {
                                            Layout.preferredWidth: 100
                                            Layout.preferredHeight: 30
                                            Layout.alignment: Qt.AlignVCenter
                                            Layout.leftMargin: 5
                                            color: diseaseStatsButtonMouseArea.pressed ? Qt.darker("#FF5722", 1.2) : "#FF5722"
                                            radius: 5

                                            Text {
                                                anchors.centerIn: parent
                                                text: "آمار بیماری‌ها"
                                                font {
                                                    family: "Tahoma"
                                                    pixelSize: 12
                                                    bold: true
                                                }
                                                color: "white"
                                            }

                                            MouseArea {
                                                id: diseaseStatsButtonMouseArea
                                                anchors.fill: parent
                                                hoverEnabled: true

                                                onClicked: {
                                                    // نمایش آمار بیماری‌های این بیمار
                                                    loadPatientDiseaseStatistics(modelData.id, modelData.name)
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
            }

            // تب لیست جلسات
            Item {
                id: sessionsTab

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10
                    // عنوان نمایش جلسات بیمار خاص
                         Text {
                             id: patientSessionsTitle
                             Layout.fillWidth: true
                             Layout.preferredHeight: 30
                             text: ""
                             visible: false
                             font {
                                 family: "Tahoma"
                                 pixelSize: 16
                                 bold: true
                             }
                             color: "#3F51B5"
                             horizontalAlignment: Text.AlignRight
                         }

                    // فیلترها
                    Rectangle {
                        id: sessionFiltersCard
                        Layout.fillWidth: true
                        Layout.preferredHeight: 70
                        color: "white"
                        radius: 10

                        // سایه ساده
                        Rectangle {
                            anchors.fill: parent
                            radius: 10
                            color: "#20000000"
                            z: -1
                        }

                        RowLayout {
                            anchors {
                                fill: parent
                                margins: 10
                            }
                            spacing: 10

                            // تاریخ شروع
                            Rectangle {
                                Layout.preferredWidth: 150
                                Layout.preferredHeight: 40
                                color: "#F5F5F5"
                                radius: 5

                                TextInput {
                                    id: startDateField
                                    anchors {
                                        fill: parent
                                        margins: 10
                                    }
                                    font {
                                        family: "Tahoma"
                                        pixelSize: 14
                                    }
                                    color: "#333333"
                                    clip: true

                                    property string placeholderText: "تاریخ شروع..."

                                    Text {
                                        anchors {
                                            fill: parent
                                            leftMargin: 5
                                        }
                                        text: startDateField.placeholderText
                                        font: startDateField.font
                                        color: "#AAAAAA"
                                        visible: !startDateField.text
                                    }
                                }
                            }

                            // تاریخ پایان
                            Rectangle {
                                Layout.preferredWidth: 150
                                Layout.preferredHeight: 40
                                color: "#F5F5F5"
                                radius: 5

                                TextInput {
                                    id: endDateField
                                    anchors {
                                        fill: parent
                                        margins: 10
                                    }
                                    font {
                                        family: "Tahoma"
                                        pixelSize: 14
                                    }
                                    color: "#333333"
                                    clip: true

                                    property string placeholderText: "تاریخ پایان..."

                                    Text {
                                        anchors {
                                            fill: parent
                                            leftMargin: 5
                                        }
                                        text: endDateField.placeholderText
                                        font: endDateField.font
                                        color: "#AAAAAA"
                                        visible: !endDateField.text
                                    }
                                }
                            }

                            // نوع بیماری
                            ComboBox {
                                id: diseaseFilter
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                model: ["همه بیماری‌ها"]

                                // اینجا باید لیست بیماری‌ها از بک‌اند لود شود

                                background: Rectangle {
                                    color: "#F5F5F5"
                                    radius: 5
                                }

                                contentItem: Text {
                                    text: diseaseFilter.displayText
                                    font {
                                        family: "Tahoma"
                                        pixelSize: 14
                                    }
                                    color: "#333333"
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                    leftPadding: 10
                                }
                            }

                            // دکمه جستجو
                            Rectangle {
                                id: sessionSearchButton
                                Layout.preferredWidth: 100
                                Layout.preferredHeight: 40
                                color: sessionSearchButtonMouseArea.pressed ? Qt.darker("#4CAF50", 1.2) : "#4CAF50"
                                radius: 5

                                Text {
                                    anchors.centerIn: parent
                                    text: "جستجو"
                                    font {
                                        family: "Tahoma"
                                        pixelSize: 14
                                        bold: true
                                    }
                                    color: "white"
                                }

                                MouseArea {
                                    id: sessionSearchButtonMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true

                                    onClicked: {
                                        let diseaseId = diseaseFilter.currentIndex === 0 ? 0 : diseaseFilter.currentIndex;

                                        sessionsList = reportBackend.getSessionsList(
                                            startDateField.text,
                                            endDateField.text,
                                            diseaseId
                                        )
                                    }
                                }

                                Behavior on color {
                                    ColorAnimation { duration: 100 }
                                }
                            }
                        }
                    }

                    // جدول جلسات
                    Rectangle {
                        id: sessionsTableCard
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "white"
                        radius: 10

                        // سایه ساده
                        Rectangle {
                            anchors.fill: parent
                            radius: 10
                            color: "#20000000"
                            z: -1
                        }

                        ColumnLayout {
                            anchors {
                                fill: parent
                                margins: 10
                            }
                            spacing: 0

                            // هدر جدول
                            Rectangle {
                                id: sessionsTableHeader
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                color: "#EEEEEE"
                                radius: 5

                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 5

                                    Text {
                                        Layout.preferredWidth: 50
                                        Layout.fillHeight: true
                                        text: "ردیف"
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 14
                                            bold: true
                                        }
                                        color: "#333333"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 1
                                        Layout.fillHeight: true
                                        color: "#DDDDDD"
                                    }

                                    Text {
                                        Layout.preferredWidth: 120
                                        Layout.fillHeight: true
                                        text: "تاریخ جلسه"
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 14
                                            bold: true
                                        }
                                        color: "#333333"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 1
                                        Layout.fillHeight: true
                                        color: "#DDDDDD"
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        text: "نام بیمار"
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 14
                                            bold: true
                                        }
                                        color: "#333333"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 1
                                        Layout.fillHeight: true
                                        color: "#DDDDDD"
                                    }

                                    Text {
                                        Layout.preferredWidth: 150
                                        Layout.fillHeight: true
                                        text: "نوع درمان"
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 14
                                            bold: true
                                        }
                                        color: "#333333"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 1
                                        Layout.fillHeight: true
                                        color: "#DDDDDD"
                                    }

                                    Text {
                                        Layout.preferredWidth: 80
                                        Layout.fillHeight: true
                                        text: "مدت زمان"
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 14
                                            bold: true
                                        }
                                        color: "#333333"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 1
                                        Layout.fillHeight: true
                                        color: "#DDDDDD"
                                    }

                                    Text {
                                        Layout.preferredWidth: 80
                                        Layout.fillHeight: true
                                        text: "وضعیت"
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 14
                                            bold: true
                                        }
                                        color: "#333333"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }

                            // محتوای جدول
                            ListView {
                                id: sessionsListView
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true
                                model: sessionsList

                                delegate: Rectangle {
                                    width: sessionsListView.width
                                    height: 50
                                    color: index % 2 === 0 ? "#FFFFFF" : "#F9F9F9"

                                    RowLayout {
                                        anchors.fill: parent
                                        spacing: 5

                                        Text {
                                            Layout.preferredWidth: 50
                                            Layout.fillHeight: true
                                            text: index + 1
                                            font {
                                                family: "Tahoma"
                                                pixelSize: 14
                                            }
                                            color: "#333333"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        Rectangle {
                                            Layout.preferredWidth: 1
                                            Layout.fillHeight: true
                                            color: "#EEEEEE"
                                        }

                                        Text {
                                            Layout.preferredWidth: 120
                                            Layout.fillHeight: true
                                            text: modelData.date
                                            font {
                                                family: "Tahoma"
                                                pixelSize: 14
                                            }
                                            color: "#333333"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        Rectangle {
                                            Layout.preferredWidth: 1
                                            Layout.fillHeight: true
                                            color: "#EEEEEE"
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            text: modelData.patientName
                                            font {
                                                family: "Tahoma"
                                                pixelSize: 14
                                            }
                                            color: "#333333"
                                            elide: Text.ElideRight
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        Rectangle {
                                            Layout.preferredWidth: 1
                                            Layout.fillHeight: true
                                            color: "#EEEEEE"
                                        }

                                        Text {
                                            Layout.preferredWidth: 150
                                            Layout.fillHeight: true
                                            text: modelData.diseaseName
                                            font {
                                                family: "Tahoma"
                                                pixelSize: 14
                                            }
                                            color: "#333333"
                                            elide: Text.ElideRight
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        Rectangle {
                                            Layout.preferredWidth: 1
                                            Layout.fillHeight: true
                                            color: "#EEEEEE"
                                        }

                                        Text {
                                            Layout.preferredWidth: 80
                                            Layout.fillHeight: true
                                            text: modelData.duration
                                            font {
                                                family: "Tahoma"
                                                pixelSize: 14
                                            }
                                            color: "#333333"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        Rectangle {
                                            Layout.preferredWidth: 1
                                            Layout.fillHeight: true
                                            color: "#EEEEEE"
                                        }

                                        Text {
                                            Layout.preferredWidth: 80
                                            Layout.fillHeight: true
                                            text: modelData.completed ? "تکمیل شده" : "ناتمام"
                                            font {
                                                family: "Tahoma"
                                                pixelSize: 14
                                            }
                                            color: modelData.completed ? "#4CAF50" : "#FF5722"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // تب آمار بیماری‌ها
            Item {
                id: diseaseStatsTab
                // مدل داده‌های آمار بیماری‌ها
                  ListModel {
                      id: diseaseStatisticsModel
                  }
                  ColumnLayout {
                        anchors.fill: parent
                        spacing: 10

                        // عنوان نمایش آمار بیماری‌های بیمار خاص
                        Text {
                            id: patientDiseaseStatsTitle
                            Layout.fillWidth: true
                            Layout.preferredHeight: 30
                            text: ""
                            visible: false
                            font {
                                family: "Tahoma"
                                pixelSize: 16
                                bold: true
                            }
                            color: "#3F51B5"
                            horizontalAlignment: Text.AlignRight
                        }

                        // جدول نمایش آمار بیماری‌ها
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "white"
                            radius: 10

                            // سایه ساده
                            Rectangle {
                                anchors.fill: parent
                                radius: 10
                                color: "#20000000"
                                z: -1
                            }

                            ColumnLayout {
                                anchors {
                                    fill: parent
                                    margins: 10
                                }
                                spacing: 0

                                // هدر جدول
                                Rectangle {
                                    id: diseaseStatsTableHeader
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 40
                                    color: "#EEEEEE"
                                    radius: 5

                                    RowLayout {
                                        anchors.fill: parent
                                        spacing: 5

                                        Text {
                                            Layout.preferredWidth: 50
                                            Layout.fillHeight: true
                                            text: "ردیف"
                                            font {
                                                family: "Tahoma"
                                                pixelSize: 14
                                                bold: true
                                            }
                                            color: "#333333"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        Rectangle {
                                            Layout.preferredWidth: 1
                                            Layout.fillHeight: true
                                            color: "#DDDDDD"
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            text: "نام بیماری"
                                            font {
                                                family: "Tahoma"
                                                pixelSize: 14
                                                bold: true
                                            }
                                            color: "#333333"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        Rectangle {
                                            Layout.preferredWidth: 1
                                            Layout.fillHeight: true
                                            color: "#DDDDDD"
                                        }

                                        Text {
                                            Layout.preferredWidth: 100
                                            Layout.fillHeight: true
                                            text: "تعداد جلسات"
                                            font {
                                                family: "Tahoma"
                                                pixelSize: 14
                                                bold: true
                                            }
                                            color: "#333333"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        Rectangle {
                                            Layout.preferredWidth: 1
                                            Layout.fillHeight: true
                                            color: "#DDDDDD"
                                        }

                                        Text {
                                            Layout.preferredWidth: 100
                                            Layout.fillHeight: true
                                            text: "اولین جلسه"
                                            font {
                                                family: "Tahoma"
                                                pixelSize: 14
                                                bold: true
                                            }
                                            color: "#333333"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        Rectangle {
                                            Layout.preferredWidth: 1
                                            Layout.fillHeight: true
                                            color: "#DDDDDD"
                                        }

                                        Text {
                                            Layout.preferredWidth: 100
                                            Layout.fillHeight: true
                                            text: "آخرین جلسه"
                                            font {
                                                family: "Tahoma"
                                                pixelSize: 14
                                                bold: true
                                            }
                                            color: "#333333"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        Rectangle {
                                            Layout.preferredWidth: 1
                                            Layout.fillHeight: true
                                            color: "#DDDDDD"
                                        }

                                        Text {
                                            Layout.preferredWidth: 100
                                            Layout.fillHeight: true
                                            text: "میانگین زمان"
                                            font {
                                                family: "Tahoma"
                                                pixelSize: 14
                                                bold: true
                                            }
                                            color: "#333333"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        Rectangle {
                                            Layout.preferredWidth: 1
                                            Layout.fillHeight: true
                                            color: "#DDDDDD"
                                        }

                                        Text {
                                            Layout.preferredWidth: 100
                                            Layout.fillHeight: true
                                            text: "مجموع زمان"
                                            font {
                                                family: "Tahoma"
                                                pixelSize: 14
                                                bold: true
                                            }
                                            color: "#333333"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                }

                                // محتوای جدول
                                ListView {
                                    id: diseaseStatsListView
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    clip: true
                                    model: diseaseStatisticsModel

                                    delegate: Rectangle {
                                        width: diseaseStatsListView.width
                                        height: 50
                                        color: index % 2 === 0 ? "#FFFFFF" : "#F9F9F9"

                                        RowLayout {
                                            anchors.fill: parent
                                            spacing: 5

                                            Text {
                                                Layout.preferredWidth: 50
                                                Layout.fillHeight: true
                                                text: index + 1
                                                font {
                                                    family: "Tahoma"
                                                    pixelSize: 14
                                                }
                                                color: "#333333"
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }

                                            Rectangle {
                                                Layout.preferredWidth: 1
                                                Layout.fillHeight: true
                                                color: "#EEEEEE"
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true
                                                text: model.name
                                                font {
                                                    family: "Tahoma"
                                                    pixelSize: 14
                                                }
                                                color: "#333333"
                                                elide: Text.ElideRight
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }

                                            Rectangle {
                                                Layout.preferredWidth: 1
                                                Layout.fillHeight: true
                                                color: "#EEEEEE"
                                            }

                                            Text {
                                                Layout.preferredWidth: 100
                                                Layout.fillHeight: true
                                                text: model.sessionCount
                                                font {
                                                    family: "Tahoma"
                                                    pixelSize: 14
                                                }
                                                color: "#333333"
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }

                                            Rectangle {
                                                Layout.preferredWidth: 1
                                                Layout.fillHeight: true
                                                color: "#EEEEEE"
                                            }

                                            Text {
                                                Layout.preferredWidth: 100
                                                Layout.fillHeight: true
                                                text: model.firstSession
                                                font {
                                                    family: "Tahoma"
                                                    pixelSize: 14
                                                }
                                                color: "#333333"
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }

                                            Rectangle {
                                                Layout.preferredWidth: 1
                                                Layout.fillHeight: true
                                                color: "#EEEEEE"
                                            }

                                            Text {
                                                Layout.preferredWidth: 100
                                                Layout.fillHeight: true
                                                text: model.lastSession
                                                font {
                                                    family: "Tahoma"
                                                    pixelSize: 14
                                                }
                                                color: "#333333"
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }

                                            Rectangle {
                                                Layout.preferredWidth: 1
                                                Layout.fillHeight: true
                                                color: "#EEEEEE"
                                            }

                                            Text {
                                                Layout.preferredWidth: 100
                                                Layout.fillHeight: true
                                                text: model.avgDuration + " دقیقه"
                                                font {
                                                    family: "Tahoma"
                                                    pixelSize: 14
                                                }
                                                color: "#333333"
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }

                                            Rectangle {
                                                Layout.preferredWidth: 1
                                                Layout.fillHeight: true
                                                color: "#EEEEEE"
                                            }

                                            Text {
                                                Layout.preferredWidth: 100
                                                Layout.fillHeight: true
                                                text: model.totalDuration + " دقیقه"
                                                font {
                                                    family: "Tahoma"
                                                    pixelSize: 14
                                                }
                                                color: "#333333"
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                ListView {
                    id: diseaseStatsView
                    anchors.fill: parent
                    spacing: 15
                    model: diseaseStatistics
                    clip: true

                    delegate: Rectangle {
                        width: diseaseStatsView.width
                        height: 150
                        color: "white"
                        radius: 10

                        // سایه ساده
                        Rectangle {
                            anchors.fill: parent
                            radius: 10
                            color: "#20000000"
                            z: -1
                        }

                        ColumnLayout {
                            anchors {
                                fill: parent
                                margins: 15
                            }
                            spacing: 10

                            Text {
                                text: modelData.name
                                font {
                                    family: "Tahoma"
                                    pixelSize: 18
                                    bold: true
                                }
                                color: "#333333"
                                Layout.fillWidth: true
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: "#EEEEEE"
                            }

                            GridLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                columns: 3
                                rowSpacing: 10
                                columnSpacing: 20

                                // تعداد بیماران
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 5

                                    Text {
                                        text: "تعداد بیماران"
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 14
                                        }
                                        color: "#555555"
                                    }

                                    Text {
                                        text: modelData.patientCount
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 20
                                            bold: true
                                        }
                                        color: "#3F51B5"
                                    }
                                }

                                // تعداد جلسات
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 5

                                    Text {
                                        text: "تعداد جلسات"
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 14
                                        }
                                        color: "#555555"
                                    }

                                    Text {
                                        text: modelData.sessionCount
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 20
                                            bold: true
                                        }
                                        color: "#4CAF50"
                                    }
                                }

                                // میانگین مدت زمان
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 5

                                    Text {
                                        text: "میانگین مدت زمان"
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 14
                                        }
                                        color: "#555555"
                                    }

                                    Text {
                                        text: modelData.avgDuration + " دقیقه"
                                        font {
                                            family: "Tahoma"
                                            pixelSize: 20
                                            bold: true
                                        }
                                        color: "#FF9800"
                                    }
                                }

                                // نوار پیشرفت
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 10
                                    Layout.columnSpan: 3
                                    color: "#EEEEEE"
                                    radius: 5

                                    Rectangle {
                                        height: parent.height
                                        width: {
                                            // محاسبه عرض بر اساس تعداد جلسات
                                            let maxCount = 0;
                                            for (let i = 0; i < diseaseStatistics.length; i++) {
                                                if (diseaseStatistics[i].sessionCount > maxCount) {
                                                    maxCount = diseaseStatistics[i].sessionCount;
                                                }
                                            }
                                            return maxCount > 0 ? (modelData.sessionCount / maxCount) * parent.width : 0;
                                        }
                                        color: Qt.hsla((index * 0.15) % 1.0, 0.7, 0.5, 1.0)
                                        radius: 5
                                    }
                                }
                            }
                        }
                    }
                }
            }

        }
    }
}
