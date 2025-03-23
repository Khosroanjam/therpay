// VirtualKeyboard.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

FocusScope {
    id: keyboardFocusScope
    width: parent.width
    height: virtualKeyboard.height
    anchors.bottom: parent.bottom
    focus: visible  // وقتی نمایان است، فوکوس را بگیرد
    visible: false  // در ابتدا مخفی باشد
    z: 1000

    // وقتی فوکوس از دست رفت، کیبورد مخفی شود
    onActiveFocusChanged: {
        if (!activeFocus && visible) {
            visible = false
            if (virtualKeyboard.targetInput) {
                virtualKeyboard.targetInput = null
            }
        }
    }

    // تابع نمایش کیبورد
    function show(input) {
        virtualKeyboard.attachTo(input)
        visible = true
        focus = true
    }

    // تابع مخفی کردن کیبورد
    function hide() {
        visible = false
        focus = false
        if (virtualKeyboard.targetInput) {
            virtualKeyboard.targetInput = null
        }
    }

    Rectangle {
        id: virtualKeyboard
        width: parent.width
        height: keyboardLayout.height + 20
        color: "#F0F0F0"
        border.color: "#CCCCCC"
        border.width: 1
        radius: 5

        property Item targetInput: null
        property bool numericOnly: false

        function attachTo(input) {
            targetInput = input
            if (input && input.hasOwnProperty("inputMethodHints")) {
                numericOnly = (input.inputMethodHints & Qt.ImhDigitsOnly) === Qt.ImhDigitsOnly
            } else {
                numericOnly = false
            }
        }

        function insertText(text) {
            if (targetInput && targetInput.hasOwnProperty("text")) {
                var cursorPosition = targetInput.cursorPosition
                var currentText = targetInput.text
                targetInput.text = currentText.substring(0, cursorPosition) + text + currentText.substring(cursorPosition)
                targetInput.cursorPosition = cursorPosition + text.length
            }
        }

        function backspace() {
            if (targetInput && targetInput.hasOwnProperty("text")) {
                var cursorPosition = targetInput.cursorPosition
                var currentText = targetInput.text
                if (cursorPosition > 0) {
                    targetInput.text = currentText.substring(0, cursorPosition - 1) + currentText.substring(cursorPosition)
                    targetInput.cursorPosition = cursorPosition - 1
                }
            }
        }

        // MouseArea برای جلوگیری از از دست دادن فوکوس با کلیک روی کیبورد
        MouseArea {
            anchors.fill: parent
            onClicked: {
                keyboardFocusScope.focus = true
                mouse.accepted = true
            }
        }

        ColumnLayout {
            id: keyboardLayout
            width: parent.width - 20
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                topMargin: 10
            }
            spacing: 8

            // ردیف اول - اعداد
            RowLayout {
                Layout.fillWidth: true
                spacing: 5

                Repeater {
                    model: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60
                        color: keyMouseArea.pressed ? "#DDDDDD" : "white"
                        border.color: "#CCCCCC"
                        border.width: 1
                        radius: 5

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            font.pixelSize: 20
                        }

                        MouseArea {
                            id: keyMouseArea
                            anchors.fill: parent
                            onClicked: {
                                virtualKeyboard.insertText(modelData)
                                keyboardFocusScope.focus = true  // حفظ فوکوس
                            }
                        }
                    }
                }
            }

            // ردیف دوم - حروف (اگر حالت عددی نباشد)
            RowLayout {
                Layout.fillWidth: true
                spacing: 5
                visible: !virtualKeyboard.numericOnly

                Repeater {
                    model: ["ض", "ص", "ث", "ق", "ف", "غ", "ع", "ه", "خ", "ح"]

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60
                        color: keyMouseArea2.pressed ? "#DDDDDD" : "white"
                        border.color: "#CCCCCC"
                        border.width: 1
                        radius: 5

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            font.pixelSize: 20
                        }

                        MouseArea {
                            id: keyMouseArea2
                            anchors.fill: parent
                            onClicked: {
                                virtualKeyboard.insertText(modelData)
                                keyboardFocusScope.focus = true
                            }
                        }
                    }
                }
            }

            // ردیف سوم - حروف (اگر حالت عددی نباشد)
            RowLayout {
                Layout.fillWidth: true
                spacing: 5
                visible: !virtualKeyboard.numericOnly

                Repeater {
                    model: ["ج", "چ", "پ", "ش", "س", "ی", "ب", "ل", "ا", "ت"]

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60
                        color: keyMouseArea3.pressed ? "#DDDDDD" : "white"
                        border.color: "#CCCCCC"
                        border.width: 1
                        radius: 5

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            font.pixelSize: 20
                        }

                        MouseArea {
                            id: keyMouseArea3
                            anchors.fill: parent
                            onClicked: {
                                virtualKeyboard.insertText(modelData)
                                keyboardFocusScope.focus = true
                            }
                        }
                    }
                }
            }

            // ردیف چهارم - حروف (اگر حالت عددی نباشد)
            RowLayout {
                Layout.fillWidth: true
                spacing: 5
                visible: !virtualKeyboard.numericOnly

                Repeater {
                    model: ["ن", "م", "ک", "گ", "ظ", "ط", "ز", "ر", "ذ", "د"]

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60
                        color: keyMouseArea4.pressed ? "#DDDDDD" : "white"
                        border.color: "#CCCCCC"
                        border.width: 1
                        radius: 5

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            font.pixelSize: 20
                        }

                        MouseArea {
                            id: keyMouseArea4
                            anchors.fill: parent
                            onClicked: {
                                virtualKeyboard.insertText(modelData)
                                keyboardFocusScope.focus = true
                            }
                        }
                    }
                }
            }

            // ردیف آخر - کلیدهای ویژه
            RowLayout {
                Layout.fillWidth: true
                spacing: 5

                // کلید فاصله
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: spaceMouseArea.pressed ? "#DDDDDD" : "white"
                    border.color: "#CCCCCC"
                    border.width: 1
                    radius: 5

                    Text {
                        anchors.centerIn: parent
                        text: "فاصله"
                        font.pixelSize: 18
                    }

                    MouseArea {
                        id: spaceMouseArea
                        anchors.fill: parent
                        onClicked: {
                            virtualKeyboard.insertText(" ")
                            keyboardFocusScope.focus = true
                        }
                    }
                }

                // کلید حذف
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: backspaceMouseArea.pressed ? "#DDDDDD" : "white"
                    border.color: "#CCCCCC"
                    border.width: 1
                    radius: 5

                    Text {
                        anchors.centerIn: parent
                        text: "حذف"
                        font.pixelSize: 18
                    }

                    MouseArea {
                        id: backspaceMouseArea
                        anchors.fill: parent
                        onClicked: {
                            virtualKeyboard.backspace()
                            keyboardFocusScope.focus = true
                        }
                    }
                }

                // کلید تایید
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: doneMouseArea.pressed ? "#4CAF50" : "#66BB6A"
                    border.color: "#388E3C"
                    border.width: 1
                    radius: 5

                    Text {
                        anchors.centerIn: parent
                        text: "تایید"
                        color: "white"
                        font.pixelSize: 18
                        font.bold: true
                    }

                    MouseArea {
                        id: doneMouseArea
                        anchors.fill: parent
                        onClicked: {
                            keyboardFocusScope.hide()
                        }
                    }
                }
            }
        }
    }
}
