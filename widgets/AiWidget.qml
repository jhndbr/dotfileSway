import QtQuick
import "../components"
import ".."

Item {
    id: root

    signal aiClicked()

    visible: Config.showAiChat ?? true
    implicitHeight: Config.barHeight - 6
    implicitWidth: 26

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: aiMouse.pressed ? Theme.fillSecondary : (aiMouse.containsMouse ? Theme.fillPrimary : "transparent")
        border.color: aiMouse.containsMouse ? Theme.specularBorderHover : "transparent"
        border.width: 1

        Behavior on color {
            ColorAnimation { duration: Theme.animFast }
        }

        Text {
            anchors.centerIn: parent
            text: "✦"
            color: aiMouse.containsMouse ? Theme.accentColor : Theme.labelPrimary
            font.pixelSize: 13
            font.bold: true

            scale: aiMouse.pressed ? 0.95 : (aiMouse.containsMouse ? 1.20 : 1.0)
            Behavior on scale {
                NumberAnimation { duration: Theme.animFast; easing.type: Theme.animEasing }
            }
            Behavior on color {
                ColorAnimation { duration: Theme.animFast }
            }
        }

        MouseArea {
            id: aiMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.aiClicked();
            }
        }
    }
}
