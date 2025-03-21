import QtQuick
import QtQuick.Controls
import QtQuick.Shapes

Item {
    id: root
    width: 400
    height: 300

    // پراپرتی‌های قابل تنظیم
    property real value: 0                      // مقدار فعلی (0 تا 100)
    property real minValue: 0                   // حداقل مقدار
    property real maxValue: 100                 // حداکثر مقدار
    property string valueText: value.toFixed(1) // متن نمایش مقدار
    property string unitText: "%"               // واحد اندازه‌گیری
    property string titleText: "عنوان"          // عنوان گیج

    // پراپرتی‌های رنگ
    property color backgroundColor: "#E0E0E0"   // رنگ پس‌زمینه گیج
    property color progressColor: "#2196F3"     // رنگ پیشرفت گیج
    property color textColor: "#212121"         // رنگ متن

    // پراپرتی‌های سایز
    property int arcWidth: 10                   // ضخامت کمان
    property real startAngle: -180              // زاویه شروع (180- درجه)
    property real endAngle: 0                   // زاویه پایان (0 درجه)
    property real currentAngle: calculateAngle() // زاویه فعلی بر اساس مقدار

    // محاسبه زاویه بر اساس مقدار
    function calculateAngle() {
        return startAngle + (endAngle - startAngle) * (value - minValue) / (maxValue - minValue);
    }

    // تغییر انیمیشن مقدار
    Behavior on value {
        NumberAnimation {
            duration: 500
            easing.type: Easing.OutCubic
        }
    }

    // کامپوننت اصلی گیج
    Shape {
        id: shape
        anchors.fill: parent
        anchors.topMargin: 10

        // کمان پس‌زمینه (نیم دایره خاکستری)
        ShapePath {
            id: backgroundPath
            strokeWidth: arcWidth
            strokeColor: backgroundColor
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height
                radiusX: Math.min(root.width / 2, root.height) - arcWidth / 2
                radiusY: Math.min(root.width / 2, root.height) - arcWidth / 2
                startAngle: root.startAngle
                sweepAngle: root.endAngle - root.startAngle
            }
        }

        // کمان پیشرفت (نیم دایره رنگی)
        ShapePath {
            id: progressPath
            strokeWidth: arcWidth
            strokeColor: progressColor
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height
                radiusX: Math.min(root.width / 2, root.height) - arcWidth / 2
                radiusY: Math.min(root.width / 2, root.height) - arcWidth / 2
                startAngle: root.startAngle
                sweepAngle: root.currentAngle - root.startAngle
            }
        }
    }

    // نمایش مقدار در مرکز
    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -root.height * 0.25
        spacing: 5

        Text {
            id: valueDisplay
            text: root.valueText + root.unitText
            font.pixelSize: Math.min(root.width, root.height) * 0.2
            font.bold: true
            color: root.textColor
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            id: titleDisplay
            text: root.titleText
            font.pixelSize: Math.min(root.width, root.height) * 0.12
            color: root.textColor
            anchors.horizontalCenter: parent.horizontalCenter
            topPadding: 5
        }
    }

    // نشانگرهای مقدار در دو طرف
    Text {
        text: root.minValue.toString()
        font.pixelSize: Math.min(root.width, root.height) * 0.1
        color: root.textColor
        anchors {
            bottom: parent.bottom
            left: parent.left
            leftMargin: 5
        }
    }

    Text {
        text: root.maxValue.toString()
        font.pixelSize: Math.min(root.width, root.height) * 0.1
        color: root.textColor
        anchors {
            bottom: parent.bottom
            right: parent.right
            rightMargin: 5
        }
    }
}
