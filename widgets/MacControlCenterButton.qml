import QtQuick
import "../components"
import ".."

Item {
    id: root

    signal clicked()
    property bool isActive: false

    visible: Config.showControlCenter
    implicitHeight: Config.barHeight - 6
    implicitWidth: 28

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.isActive
            ? Theme.fillSecondary
            : (btnMouse.pressed ? Theme.fillSecondary : (btnMouse.containsMouse ? Theme.fillPrimary : "transparent"))
        border.color: root.isActive
            ? Theme.specularBorderHover
            : (btnMouse.containsMouse ? Theme.specularBorder : "transparent")
        border.width: 1

        Behavior on color {
            ColorAnimation { duration: Theme.animFast }
        }

        Icon {
            anchors.centerIn: parent
            glyph: "󱂬"
            size: 14
            color: (root.isActive || btnMouse.containsMouse) ? Theme.accentColor : Theme.labelPrimary
            scale: btnMouse.pressed ? 0.92 : 1.0

            Behavior on scale {
                NumberAnimation { duration: Theme.animFast; easing.type: Theme.animEasing }
            }
            Behavior on color {
                ColorAnimation { duration: Theme.animFast }
            }
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
