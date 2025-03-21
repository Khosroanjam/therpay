import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: confirmDialog

    // سیگنال‌ها
    signal accepted()
    signal rejected()

    // پراپرتی‌ها
    property string message: "آیا مطمئن هستید؟"

    // تنظیمات Popup
    modal: true
    closePolicy: Popup.CloseOnEscape
    anchors.centerIn: parent
    width: Math.min(parent.width - 40, 400)
    padding: 20

    // محتوای پاپ‌آپ
    ColumnLayout {
        spacing: 20
        width: parent.width

        // عنوان
        Text {
            text: "تایید"
            font {
                family: "Tahoma"
                pixelSize: 18
                bold: true
            }
            Layout.fillWidth: true
        }

        // پیام
        Text {
            text: confirmDialog.message
            font.family: "Tahoma"
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        // دکمه‌ها
        RowLayout {
            spacing: 10
            Layout.fillWidth: true
            Layout.topMargin: 10

            Button {
                text: "بله"
                Layout.fillWidth: true
                onClicked: {
                    confirmDialog.accepted()
                    confirmDialog.close()
                }
            }

            Button {
                text: "خیر"
                Layout.fillWidth: true
                onClicked: {
                    confirmDialog.rejected()
                    confirmDialog.close()
                }
            }
        }
    }
}
