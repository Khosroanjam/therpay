import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: plasmaTherapyRoot
    width: parent.width
    height: parent.height

    // سیگنال برای بازگشت به صفحه قبل
    signal goBack()

    // پراپرتی‌های بیمار
    property string patientCodemeli: ""
    property string patientName: ""
    property int patientAge: 0
    property int patientGender: 1

    // مدل داده‌ها برای بیماری‌ها
    property var diseaseModel: []

    // لود کردن لیست بیماری‌ها از دیتابیس
    function loadDiseases() {
        diseaseModel = diseaseBackend.getAllDiseases()
        console.log("تعداد بیماری‌های بارگذاری شده:", diseaseModel.length)
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
                text: "پلاسما تراپی"
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
        Flickable {
            anchors {
                top: header.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            contentHeight: mainContent.height
            clip: true

            ColumnLayout {
                id: mainContent
                width: parent.width
                spacing: 20
                anchors.top: parent.top
                anchors.topMargin: 20
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.right: parent.right
                anchors.rightMargin: 20

                // کارت اطلاعات بیمار
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: patientInfoLayout.height + 40
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

                    ColumnLayout {
                        id: patientInfoLayout
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                            margins: 20
                        }
                        spacing: 10

                        // عنوان
                        Text {
                            text: "اطلاعات بیمار"
                            font {
                                family: "Tahoma"
                                pixelSize: 16
                                bold: true
                            }
                            color: "#2196F3"
                        }

                        // اطلاعات بیمار
                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            rowSpacing: 10
                            columnSpacing: 20

                            Text {
                                text: "کد ملی:"
                                font {
                                    family: "Tahoma"
                                    pixelSize: 14
                                    bold: true
                                }
                                color: "#424242"
                            }

                            Text {
                                text: patientCodemeli
                                font {
                                    family: "Tahoma"
                                    pixelSize: 14
                                }
                                color: "#212121"
                            }

                            Text {
                                text: "نام و نام خانوادگی:"
                                font {
                                    family: "Tahoma"
                                    pixelSize: 14
                                    bold: true
                                }
                                color: "#424242"
                            }

                            Text {
                                text: patientName
                                font {
                                    family: "Tahoma"
                                    pixelSize: 14
                                }
                                color: "#212121"
                            }

                            Text {
                                text: "سن:"
                                font {
                                    family: "Tahoma"
                                    pixelSize: 14
                                    bold: true
                                }
                                color: "#424242"
                            }

                            Text {
                                text: patientAge
                                font {
                                    family: "Tahoma"
                                    pixelSize: 14
                                }
                                color: "#212121"
                            }

                            Text {
                                text: "جنسیت:"
                                font {
                                    family: "Tahoma"
                                    pixelSize: 14
                                    bold: true
                                }
                                color: "#424242"
                            }

                            Text {
                                text: patientGender === 1 ? "مرد" : "زن"
                                font {
                                    family: "Tahoma"
                                    pixelSize: 14
                                }
                                color: "#212121"
                            }
                        }
                    }
                }

                // بخش انتخاب نوع درمان
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: therapyOptionsLayout.height + 40
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

                    ColumnLayout {
                        id: therapyOptionsLayout
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                            margins: 20
                        }
                        spacing: 20

                        // عنوان
                        Text {
                            text: "انتخاب نوع درمان"
                            font {
                                family: "Tahoma"
                                pixelSize: 16
                                bold: true
                            }
                            color: "#2196F3"
                            Layout.alignment: Qt.AlignHCenter
                        }

                        // دکمه‌های انتخاب درمان - بارگذاری پویا از دیتابیس
                        GridLayout {
                            id: diseaseGrid
                            Layout.fillWidth: true
                            columns: 2
                            rowSpacing: 15
                            columnSpacing: 15

                            // دکمه‌ها به صورت پویا اضافه می‌شوند
                            Repeater {
                                model: diseaseModel

                                delegate: Button {
                                    id: diseaseButton
                                    property int diseaseId: modelData.id
                                    property string diseaseName: modelData.name
                                    property string diseaseDescription: modelData.description
                                    property int diseaseMinutes: modelData.default_minutes
                                    property int diseaseSeconds: modelData.default_seconds

                                    text: diseaseName
                                    font.pixelSize: 14
                                    font.family: "Tahoma"
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 120

                                    background: Rectangle {
                                        radius: 10
                                        border.color: "#2196F3"
                                        border.width: 2
                                        color: diseaseButton.down ? "#E3F2FD" : "white"

                                        // نمایش زمان پیش‌فرض درمان
                                        Text {
                                            text: diseaseButton.diseaseMinutes + ":" +
                                                  (diseaseButton.diseaseSeconds < 10 ? "0" : "") +
                                                  diseaseButton.diseaseSeconds
                                            anchors.bottom: parent.bottom
                                            anchors.bottomMargin: 10
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            font.pixelSize: 16
                                            font.bold: true
                                            color: "#1976D2"
                                        }
                                    }

                                    transform: Scale {
                                        id: buttonScale
                                        origin.x: diseaseButton.width / 2
                                        origin.y: diseaseButton.height / 2
                                        xScale: 1.0
                                        yScale: 1.0
                                    }

                                    SequentialAnimation {
                                        id: buttonAnimate
                                        ParallelAnimation {
                                            NumberAnimation {
                                                target: buttonScale
                                                property: "xScale"
                                                to: 0.5
                                                duration: 100
                                                easing.type: Easing.OutQuad
                                            }

                                            NumberAnimation {
                                                target: buttonScale
                                                property: "yScale"
                                                to: 0.5
                                                duration: 100
                                                easing.type: Easing.OutQuad
                                            }
                                        }

                                        ParallelAnimation {
                                            NumberAnimation {
                                                target: buttonScale
                                                property: "xScale"
                                                to: 1.0
                                                duration: 200
                                                easing.type: Easing.OutBack
                                            }
                                            NumberAnimation {
                                                target: buttonScale
                                                property: "yScale"
                                                to: 1.0
                                                duration: 200
                                                easing.type: Easing.OutBack
                                            }
                                        }
                                    }

                                    Timer {
                                        id: navigationTimer
                                        interval: 300
                                        onTriggered: {
                                            navigateToTimer(diseaseButton.diseaseName,
                                                           diseaseButton.diseaseMinutes,
                                                           diseaseButton.diseaseSeconds)
                                        }
                                    }

                                    onClicked: {
                                        buttonAnimate.start()
                                        navigationTimer.start()
                                    }
                                }
                            }
                        }

                        // دکمه اضافه کردن بیماری جدید (برای مدیران)
                    }
                }
            }
        }
    }

    // تابع برای باز کردن صفحه تایمر با زمان پیش‌فرض بیماری انتخاب شده
    function navigateToTimer(diseaseName, minutes, seconds) {
        var component = Qt.createComponent("PlasmaTimer.qml")
        if (component.status === Component.Ready) {
            var timerPage = component.createObject(null, {
                "patientCodemeli": patientCodemeli,
                "patientName": patientName,
                "diseaseName": diseaseName,
                "initialMinutes": minutes,
                "initialSeconds": seconds
            })

            // اتصال سیگنال بازگشت
            timerPage.goBack.connect(function() {
                console.log("بازگشت از صفحه تایمر")
                stackView.pop()
            })

            stackView.push(timerPage)
        } else if (component.status === Component.Error) {
            console.error("خطا در بارگذاری PlasmaTimer.qml:", component.errorString())
            showToast("خطا در بارگذاری صفحه تایمر")
        }
    }

    // تابع برای باز کردن صفحه مدیریت بیماری‌ها
    function navigateToDiseaseManagement() {
        var component = Qt.createComponent("DiseaseManagement.qml")
        if (component.status === Component.Ready) {
            var managementPage = component.createObject(null)

            // اتصال سیگنال بازگشت و به‌روزرسانی
            managementPage.goBack.connect(function() {
                console.log("بازگشت از صفحه مدیریت بیماری‌ها")
                loadDiseases() // به‌روزرسانی لیست بیماری‌ها
                stackView.pop()
            })

            stackView.push(managementPage)
        } else if (component.status === Component.Error) {
            console.error("خطا در بارگذاری DiseaseManagement.qml:", component.errorString())
            showToast("خطا در بارگذاری صفحه مدیریت بیماری‌ها")
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

    // اتصال به سیگنال به‌روزرسانی دیتابیس
    Connections {
        target: diseaseBackend
        function onDiseaseUpdated() {
            console.log("سیگنال به‌روزرسانی بیماری‌ها دریافت شد")
            loadDiseases() // به‌روزرسانی لیست بیماری‌ها
        }
    }

    Component.onCompleted: {
        console.log("PlasmaTherapy loaded - patientCodemeli:", patientCodemeli,
                    "patientName:", patientName,
                    "patientAge:", patientAge,
                    "patientGender:", patientGender)
        loadDiseases() // بارگذاری لیست بیماری‌ها در هنگام بارگذاری صفحه
    }
}
