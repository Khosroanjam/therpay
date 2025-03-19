import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Window {
    visible: true
    width: 800
    height: 600
    title: "Plasma Company"

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
                source: "images/man-icon.png" // Replace with your image URL or local path
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
                            anchors.onTopChanged:  parent
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
                            anchors.onTopChanged:  parent
                        }
                    }
                    Button {
                        text: "جراحی"
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
                            id: pic3
                            source: "images/Iconarchive-Rose-Red-Rose-Blossom.512.png"
                            width: 45
                            height: 45
                            anchors.onTopChanged:  parent
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
}
