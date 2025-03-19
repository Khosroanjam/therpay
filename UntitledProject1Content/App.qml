import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Window {
    id: rootWindow
    visible: true
    width: 800
    height: 600
    title: "Plasma Company"

    // StackView برای مدیریت صفحات مختلف
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: mainPage
    }

    // صفحه اصلی به عنوان یک کامپوننت
    Component {
        id: mainPage

        Item {
            width: rootWindow.width
            height: rootWindow.height

            RowLayout {
                anchors.fill: parent
                spacing: 0

                // Left Section (30%)
                Rectangle {
                    Layout.preferredWidth: parent.width * 0.3
                    Layout.preferredHeight: parent.height
                    color: "lightgray"
                    Image {
                        id: image
                        source: "images/man-icon.png"
                        anchors.centerIn: parent
                        fillMode: Image.PreserveAspectFit
                    }
                }

                // Right Section (70%)
                Rectangle {
                    Layout.preferredWidth: parent.width * 0.7
                    Layout.preferredHeight: parent.height
                    color: "white"

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10

                        // Center buttons horizontally
                        property int buttonRowSpacing: 10

                        // First Row
                        RowLayout {
                            spacing: buttonRowSpacing
                            Layout.alignment: Qt.AlignHCenter // Align row to the center horizontally

                            Button {
                                id: skeinButton
                                text: "پوست"
                                font.pixelSize: 14
                                background: Rectangle {
                                    radius: 10
                                    border.color: "blue"
                                    border.width: 2
                                    // Change color on press
                                    color: parent.down ? "lightpink" : "lightblue"
                                }

                                Image {
                                    id: pic1
                                    source: "images/Iconarchive-Rose-Pink-Rose-2.512.png"
                                    width: 45
                                    height: 45
                                    anchors.centerIn: parent // تغییر به centerIn برای قرار گرفتن در مرکز
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

                                onClicked: {
                                    skeinButtonAnimate.start()
                                    loadTimer.start()
                                }

                                Layout.preferredWidth: 100
                                Layout.preferredHeight: 100
                            }

                            Button {
                                text: "زخم"
                                font.pixelSize: 14
                                background: Rectangle {
                                    radius: 10
                                    border.color: "blue"
                                    border.width: 2
                                    // Change color on press
                                    color: parent.down ? "lightpink" : "lightblue"
                                }
                                Layout.preferredWidth: 100
                                Layout.preferredHeight: 100
                                Image {
                                    id: pic2
                                    source: "images/Iconarchive-Rose-Purple-Rose-Blossom.512.png"
                                    width: 45
                                    height: 45
                                    anchors.centerIn: parent
                                }
                            }

                            Button {
                                id: surgeryButton
                                text: "جراحی"
                                font.pixelSize: 14
                                background: Rectangle {
                                    radius: 10
                                    border.color: "blue"
                                    border.width: 2
                                    color: parent.down ? "lightpink" : "lightblue"
                                }
                                Layout.preferredWidth: 100
                                Layout.preferredHeight: 100

                                // تبدیل scale برای دکمه
                                transform: Scale {
                                    id: buttonScale
                                    origin.x: surgeryButton.width / 2
                                    origin.y: surgeryButton.height / 2
                                    xScale: 1.0  // مقیاس اولیه
                                    yScale: 1.0  // مقیاس اولیه
                                }

                                Image {
                                    id: pic3
                                    source: "images/Iconarchive-Rose-Red-Rose-Blossom.512.png"
                                    width: 45
                                    height: 45
                                    anchors.centerIn: parent
                                }

                                // انیمیشن مقیاس‌بندی
                                SequentialAnimation {
                                    id: scaleAnimation

                                    // مرحله اول: کوچک شدن دکمه
                                    ParallelAnimation {
                                        NumberAnimation {
                                            target: buttonScale
                                            property: "xScale"
                                            to: 0.8  // کوچک شدن تا 80% اندازه اصلی
                                            duration: 100
                                            easing.type: Easing.OutQuad
                                        }
                                        NumberAnimation {
                                            target: buttonScale
                                            property: "yScale"
                                            to: 0.5  // کوچک شدن تا 80% اندازه اصلی
                                            duration: 100
                                            easing.type: Easing.OutQuad
                                        }
                                    }

                                    // مرحله دوم: برگشت به اندازه اصلی
                                    ParallelAnimation {
                                        NumberAnimation {
                                            target: buttonScale
                                            property: "xScale"
                                            to: 1.0  // برگشت به اندازه اصلی
                                            duration: 200
                                            easing.type: Easing.OutBack  // افکت فنری برای برگشت
                                        }
                                        NumberAnimation {
                                            target: buttonScale
                                            property: "yScale"
                                            to: 1.0  // برگشت به اندازه اصلی
                                            duration: 200
                                            easing.type: Easing.OutBack  // افکت فنری برای برگشت
                                        }
                                    }
                                }

                                // شروع انیمیشن با کلیک روی دکمه
                                onClicked: {
                                    scaleAnimation.start()
                                }
                            }
                        }

                        // Second Row
                        RowLayout {
                            spacing: buttonRowSpacing
                            Layout.alignment: Qt.AlignHCenter // Align row to the center horizontally

                            Button {
                                text: "سوختگی"
                                font.pixelSize: 14
                                background: Rectangle {
                                    radius: 10
                                    border.color: "blue"
                                    border.width: 2
                                    // Change color on press
                                    color: parent.down ? "lightpink" : "lightblue"
                                }
                                Layout.preferredWidth: 100
                                Layout.preferredHeight: 100
                            }
                            Button {
                                text: "Button 5"
                                font.pixelSize: 14
                                background: Rectangle {
                                    radius: 10
                                    border.color: "blue"
                                    border.width: 2
                                    // Change color on press
                                    color: parent.down ? "lightpink" : "lightblue"
                                }
                                Layout.preferredWidth: 100
                                Layout.preferredHeight: 100
                            }
                            Button {
                                text: "Button 6"
                                font.pixelSize: 14
                                background: Rectangle {
                                    radius: 10
                                    border.color: "blue"
                                    border.width: 2
                                    // Change color on press
                                    color: parent.down ? "lightpink" : "lightblue"
                                }
                                Layout.preferredWidth: 100
                                Layout.preferredHeight: 100
                            }
                        }

                        // Third Row
                        RowLayout {
                            spacing: buttonRowSpacing
                            Layout.alignment: Qt.AlignHCenter // Align row to the center horizontally

                            Button {
                                text: "Button 7"
                                font.pixelSize: 14
                                background: Rectangle {
                                    radius: 10
                                    border.color: "blue"
                                    border.width: 2
                                    // Change color on press
                                    color: parent.down ? "lightpink" : "lightblue"
                                }
                                Layout.preferredWidth: 100
                                Layout.preferredHeight: 100
                            }
                            Button {
                                text: "Button 8"
                                font.pixelSize: 14
                                background: Rectangle {
                                    radius: 10
                                    border.color: "blue"
                                    border.width: 2
                                    // Change color on press
                                    color: parent.down ? "lightpink" : "lightblue"
                                }
                                Layout.preferredWidth: 100
                                Layout.preferredHeight: 100
                            }
                            Button {
                                text: "Button 9"
                                font.pixelSize: 14
                                background: Rectangle {
                                    radius: 10
                                    border.color: "blue"
                                    border.width: 2
                                    // Change color on press
                                    color: parent.down ? "lightpink" : "lightblue"
                                }
                                Layout.preferredWidth: 100
                                Layout.preferredHeight: 100
                            }
                        }
                    }
                }
            }

            // تایمر برای تاخیر در بارگذاری صفحه جدید
            Timer {
                id: loadTimer
                interval: 500
                repeat: false
                onTriggered: {
                    console.log("Navigating to SkeinWindows.qml")
                           var component = Qt.createComponent("SkeinWindows.qml")
                           if (component.status === Component.Ready) {
                               var screen = component.createObject(null)
                               screen.goBack.connect(function() {
                                   console.log("بازگشت به صفحه اصلی")
                                   stackView.pop()
                               })
                               stackView.push(screen)
                           } else if (component.status === Component.Error) {
                               console.error("خطا در بارگذاری:", component.errorString())
                           }
                       }
                }
            }
        }
    }

