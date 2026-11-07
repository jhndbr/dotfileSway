import QtQuick
import "../components"
import "../services"
import ".."

Item {
    id: root

    visible: BluetoothService.available
    implicitHeight: Theme.barHeight - 6
    implicitWidth: 24

    Rectangle {
        anchors.fill: parent
        radius: Theme.pillRadius - 1
        color: btMouse.containsMouse ? Theme.surfaceHover : "transparent"
        border.color: btMouse.containsMouse ? Theme.borderHover : "transparent"
        border.width: 1

        Behavior on color {
            ColorAnimation { duration: Theme.animFast }
        }

        Icon {
            anchors.centerIn: parent
            glyph: BluetoothService.powered ? "󰂯" : "󰂲"
            size: 13
            color: BluetoothService.powered ? (btMouse.containsMouse ? Theme.accent : Theme.text) : Theme.textDisabled
        }

        MouseArea {
            id: btMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) {
                    BluetoothService.openManager();
                } else {
                    BluetoothService.togglePower();
                }
            }
        }
    }
}
