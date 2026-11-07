import QtQuick
import "../components"
import ".."

Item {
    id: root

    signal clipboardClicked()

    visible: Config.showClipboard
    implicitHeight: Theme.barHeight - 6
    implicitWidth: 26

    Rectangle {
        anchors.fill: parent
        radius: Theme.pillRadius - 1
        color: clipMouse.containsMouse ? Theme.surfaceHover : "transparent"
        border.color: clipMouse.containsMouse ? Theme.borderHover : "transparent"
        border.width: 1

        Behavior on color {
            ColorAnimation { duration: Theme.animFast }
        }

        Icon {
            anchors.centerIn: parent
            glyph: "󰅌"
            color: clipMouse.containsMouse ? Theme.accent : Theme.text
            size: 13
        }

        MouseArea {
            id: clipMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.clipboardClicked();
            }
        }
    }
}
