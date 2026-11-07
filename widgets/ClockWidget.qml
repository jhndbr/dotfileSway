import QtQuick
import QtQuick.Layouts
import "../components"
import ".."

Item {
    id: root

    signal clockClicked()
    property bool isActive: false

    property var currentTime: new Date()

    Timer {
        interval: 15000
        repeat: true
        running: true
        onTriggered: {
            root.currentTime = new Date();
        }
    }

    visible: Config.showClock
    implicitHeight: Config.barHeight - 6
    implicitWidth: clockPill.implicitWidth

    Rectangle {
        id: clockPill
        anchors.fill: parent
        radius: height / 2
        color: root.isActive
            ? Theme.fillSecondary
            : (clockMouse.containsMouse ? Theme.fillPrimary : "transparent")
        border.color: root.isActive
            ? Theme.specularBorderHover
            : (clockMouse.containsMouse ? Theme.specularBorder : "transparent")
        border.width: 1
        implicitWidth: clockText.implicitWidth + 18

        Behavior on color {
            ColorAnimation { duration: Theme.animFast }
        }

        Text {
            id: clockText
            anchors.centerIn: parent
            // macOS format: "ddd d MMM  hh:mm AP" or 24h
            text: Qt.formatDateTime(root.currentTime, Config.dateFormat + "  " + Config.clockFormat)
            color: root.isActive ? Theme.accentColor : Theme.labelPrimary
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.weight: Font.DemiBold
        }

        MouseArea {
            id: clockMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.clockClicked();
            }
        }
    }
}
