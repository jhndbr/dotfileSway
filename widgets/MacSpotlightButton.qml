import QtQuick
import "../components"
import ".."

Item {
    id: root

    signal clicked()

    visible: Config.showSpotlightButton
    implicitHeight: Theme.barHeight - 6
    implicitWidth: 26

    Rectangle {
        anchors.fill: parent
        radius: Theme.pillRadius - 1
        color: btnMouse.containsMouse ? Theme.surfaceHover : "transparent"
        border.color: btnMouse.containsMouse ? Theme.borderHover : "transparent"
        border.width: 1

        Behavior on color {
            ColorAnimation { duration: Theme.animFast }
        }

        Icon {
            anchors.centerIn: parent
            glyph: "󰍉"
            size: 14
            color: btnMouse.containsMouse ? Theme.accent : Theme.text
        }

        MouseArea {
            id: btnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.clicked();
            }
        }
    }
}
