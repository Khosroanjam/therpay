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

                        // دکمه‌های انتخاب درمان
                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            rowSpacing: 15
                            columnSpacing: 15

                            // دکمه پوست
                            Button {
                                id: skeinButton
                                text: "پوست"
                                font.pixelSize: 14
                                Layout.fillWidth: true
                                Layout.preferredHeight: 120

                                background: Rectangle {
                                    radius: 10
                                    border.color: "blue"
                                    border.width: 2
                                    color: skeinButton.down ? "lightpink" : "lightblue"
                                }

                                Image {
                                    source: "images/Iconarchive-Rose-Pink-Rose-2.512.png"
                                    width: 45
                                    height: 45
                                    anchors.top: parent
                                }

                                transform: Scale {
                                    id: skeinButtonScale
                                    origin.x: skeinButton.width / 2
                                    origin.y: skeinButton.height / 2
                                    xScale: 1.0
                                    yScale: 1.0
                                }

                                SequentialAnimation {
                                    id: skeinButtonAnimate
                                    ParallelAnimation {
                                        NumberAnimation {
                                            target: skeinButtonScale
                                            property: "xScale"
                                            to: 0.5
                                            duration: 100
                                            easing.type: Easing.OutQuad
                                        }

                                        NumberAnimation {
                                            target: skeinButtonScale
                                            property: "yScale"
                                            to: 0.5
                                            duration: 100
                                            easing.type: Easing.OutQuad
                                        }
                                    }

                                    ParallelAnimation {
                                        NumberAnimation {
                                            target: skeinButtonScale
                                            property: "xScale"
                                            to: 1.0
                                            duration: 200
                                            easing.type: Easing.OutBack
                                        }
                                        NumberAnimation {
                                            target: skeinButtonScale
                                            property: "yScale"
                                            to: 1.0
                                            duration: 200
                                            easing.type: Easing.OutBack
                                        }
                                    }
                                }

                                // تایمر برای تاخیر در هدایت به صفحه بعدی
                                Timer {
                                    id: skeinNavigationTimer
                                    interval: 300 // تاخیر 300 میلی‌ثانیه برای اتمام انیمیشن
                                    onTriggered: navigateToTherapy("SkeinWindows.qml")
                                }

                                onClicked: {
                                    skeinButtonAnimate.start()
                                    skeinNavigationTimer.start()
                                }
                            }

                            // دکمه زخم
                            Button {
                                id: woundButton
                                text: "زخم"
                                font.pixelSize: 14
                                Layout.fillWidth: true
                                Layout.preferredHeight: 120

                                background: Rectangle {
                                    radius: 10
                                    border.color: "blue"
                                    border.width: 2
                                    color: woundButton.down ? "lightpink" : "lightblue"
                                }

                                Image {
                                    source: "images/Iconarchive-Rose-Purple-Rose-Blossom.512.png"
                                    width: 45
                                    height: 45
                                    anchors.top: parent
                                }

                                transform: Scale {
                                    id: woundButtonScale
                                    origin.x: woundButton.width / 2
                                    origin.y: woundButton.height / 2
                                    xScale: 1.0
                                    yScale: 1.0
                                }

                                SequentialAnimation {
                                    id: woundButtonAnimate
                                    ParallelAnimation {
                                        NumberAnimation {
                                            target: woundButtonScale
                                            property: "xScale"
                                            to: 0.5
                                            duration: 100
                                            easing.type: Easing.OutQuad
                                        }

                                        NumberAnimation {
                                            target: woundButtonScale
                                            property: "yScale"
                                            to: 0.5
                                            duration: 100
                                            easing.type: Easing.OutQuad
                                        }
                                    }

                                    ParallelAnimation {
                                        NumberAnimation {
                                            target: woundButtonScale
                                            property: "xScale"
                                            to: 1.0
                                            duration: 200
                                            easing.type: Easing.OutBack
                                        }
                                        NumberAnimation {
                                            target: woundButtonScale
                                            property: "yScale"
                                            to: 1.0
                                            duration: 200
                                            easing.type: Easing.OutBack
                                        }
                                    }
                                }

                                // تایمر برای تاخیر در هدایت به صفحه بعدی
                                Timer {
                                    id: woundNavigationTimer
                                    interval: 300 // تاخیر 300 میلی‌ثانیه برای اتمام انیمیشن
                                    onTriggered: navigateToTherapy("WoundTherapy.qml")
                                }

                                onClicked: {
                                    woundButtonAnimate.start()
                                    woundNavigationTimer.start()
                                }
                            }

                            // دکمه جراحی
                            Button {
                                id: surgeryButton
                                text: "جراحی"
                                font.pixelSize: 14
                                Layout.fillWidth: true
                                Layout.preferredHeight: 120

                                background: Rectangle {
                                    radius: 10
                                    border.color: "blue"
                                    border.width: 2
                                    color: surgeryButton.down ? "lightpink" : "lightblue"
                                }

                                Image {
                                    source: "images/Iconarchive-Rose-Red-Rose-Blossom.512.png"
                                    width: 45
                                    height: 45
                                    anchors.top: parent
                                }

                                transform: Scale {
                                    id: surgeryButtonScale
                                    origin.x: surgeryButton.width / 2
                                    origin.y: surgeryButton.height / 2
                                    xScale: 1.0
                                    yScale: 1.0
                                }

                                SequentialAnimation {
                                    id: surgeryButtonAnimate
                                    ParallelAnimation {
                                        NumberAnimation {
                                            target: surgeryButtonScale
                                            property: "xScale"
                                            to: 0.5
                                            duration: 100
                                            easing.type: Easing.OutQuad
                                        }

                                        NumberAnimation {
                                            target: surgeryButtonScale
                                            property: "yScale"
                                            to: 0.5
                                            duration: 100
                                            easing.type: Easing.OutQuad
                                        }
                                    }

                                    ParallelAnimation {
                                        NumberAnimation {
                                            target: surgeryButtonScale
                                            property: "xScale"
                                            to: 1.0
                                            duration: 200
                                            easing.type: Easing.OutBack
                                        }
                                        NumberAnimation {
                                            target: surgeryButtonScale
                                            property: "yScale"
                                            to: 1.0
                                            duration: 200
                                            easing.type: Easing.OutBack
                                        }
                                    }
                                }

                                // تایمر برای تاخیر در هدایت به صفحه بعدی
                                Timer {
                                    id: surgeryNavigationTimer
                                    interval: 300 // تاخیر 300 میلی‌ثانیه برای اتمام انیمیشن
                                    onTriggered: navigateToTherapy("SurgeryTherapy.qml")
                                }

                                onClicked: {
                                    surgeryButtonAnimate.start()
                                    surgeryNavigationTimer.start()
                                }
                            }

                            // دکمه سوختگی
                            Button {
                                id: burnButton
                                text: "سوختگی"
                                font.pixelSize: 14
                                Layout.fillWidth: true
                                Layout.preferredHeight: 120

                                background: Rectangle {
                                    radius: 10
                                    border.color: "blue"
                                    border.width: 2
                                    color: burnButton.down ? "lightpink" : "lightblue"
                                }

                                transform: Scale {
                                    id: burnButtonScale
                                    origin.x: burnButton.width / 2
                                    origin.y: burnButton.height / 2
                                    xScale: 1.0
                                    yScale: 1.0
                                }

                                SequentialAnimation {
                                    id: burnButtonAnimate
                                    ParallelAnimation {
                                        NumberAnimation {
                                            target: burnButtonScale
                                            property: "xScale"
                                            to: 0.5
                                            duration: 100
                                            easing.type: Easing.OutQuad
                                        }

                                        NumberAnimation {
                                            target: burnButtonScale
                                            property: "yScale"
                                            to: 0.5
                                            duration: 100
                                            easing.type: Easing.OutQuad
                                        }
                                    }

                                    ParallelAnimation {
                                        NumberAnimation {
                                            target: burnButtonScale
                                            property: "xScale"
                                            to: 1.0
                                            duration: 200
                                            easing.type: Easing.OutBack
                                        }
                                        NumberAnimation {
                                            target: burnButtonScale
                                            property: "yScale"
                                            to: 1.0
                                            duration: 200
                                            easing.type: Easing.OutBack
                                        }
                                    }
                                }

                                // تایمر برای تاخیر در هدایت به صفحه بعدی
                                Timer {
                                    id: burnNavigationTimer
                                    interval: 300 // تاخیر 300 میلی‌ثانیه برای اتمام انیمیشن
                                    onTriggered: navigateToTherapy("BurnTherapy.qml")
                                }

                                onClicked: {
                                    burnButtonAnimate.start()
                                    burnNavigationTimer.start()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // تابع برای باز کردن صفحه درمان انتخاب شده
    function navigateToTherapy(qmlFile) {
        var component = Qt.createComponent(qmlFile)
        if (component.status === Component.Ready) {
            var therapyPage = component.createObject(null, {
                "patientCodemeli": patientCodemeli,
                "patientName": patientName,
                "patientAge": patientAge,
                "patientGender": patientGender
            })

            // اتصال سیگنال بازگشت
            therapyPage.goBack.connect(function() {
                console.log("بازگشت از صفحه درمان")
                stackView.pop()
            })

            stackView.push(therapyPage)
        } else if (component.status === Component.Error) {
            console.error("خطا در بارگذاری " + qmlFile + ":", component.errorString())
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
        console.log("PlasmaTherapy loaded - patientCodemeli:", patientCodemeli,
                    "patientName:", patientName,
                    "patientAge:", patientAge,
                    "patientGender:", patientGender)
    }
}
