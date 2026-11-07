import QtQuick
import QtQuick.Layouts
import "../components"
import "../services"
import ".."

Item {
    id: root

    visible: Config.showNetwork
    implicitHeight: Theme.barHeight - 6
    implicitWidth: 26

    Rectangle {
        anchors.fill: parent
        radius: Theme.pillRadius - 1
        color: netMouse.containsMouse ? Theme.surfaceHover : "transparent"
        border.color: netMouse.containsMouse ? Theme.borderHover : "transparent"
        border.width: 1

        Behavior on color {
            ColorAnimation { duration: Theme.animFast }
        }

        Icon {
            anchors.centerIn: parent
            glyph: NetworkService.iconGlyph
            color: NetworkService.connected ? (netMouse.containsMouse ? Theme.accent : Theme.text) : Theme.textDisabled
            size: 14
        }

        MouseArea {
            id: netMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onClicked: (mouse) => {
                SwayService.exec("nm-connection-editor");
            }
        }
    }
}
