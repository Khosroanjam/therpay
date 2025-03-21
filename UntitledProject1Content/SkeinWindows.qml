import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: skeinwindows
    width: 800
    height: 600

    signal goBack()

    Rectangle {
        anchors.fill: parent
        color: "white"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            Button {
                id: backButton
                text: "BACK"
                font.pixelSize: 16
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop

                background: Rectangle {
                    radius: 10
                    border.color: "blue"
                    border.width: 2
                    color: parent.down ? "lightpink" : "lightblue"
                }

                onClicked: {
                    // استفاده از سیگنال به جای دسترسی مستقیم به StackView
                    skeinwindows.goBack()
                }
            }

            Text {
                text: "صفحه پوست"
                font.pixelSize: 24
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            // محتوای صفحه را اینجا اضافه کنید
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#f0f0f0"
                radius: 10

                DigitalTimer{
                    id: d1
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: parent.width
                    width: parent.width
                    height: parent.height
                }

                Connections {
                               target: digitalTimer
                               function onRunningChanged() {
                                   if (!digitalTimer.running) {
                                       // وقتی تایمر متوقف می‌شود، گیج را به‌روز کنید
                                       gauge.value = (digitalTimer.seconds % 60) * 100 / 60;
                                   }
                               }
                           }

                           Timer {
                               interval: 100
                               running: digitalTimer.running
                               repeat: true
                               onTriggered: {
                                   if (digitalTimer.running) {
                                       gauge.value = (digitalTimer.seconds % 60) * 100 / 60;
                                   }
                               }
                           }
            }
        }
    }
}
