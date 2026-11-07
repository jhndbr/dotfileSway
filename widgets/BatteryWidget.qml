import QtQuick
import QtQuick.Layouts
import "../components"
import "../services"
import ".."

Item {
    id: root

    visible: Config.showBattery && BatteryService.available
    implicitHeight: Theme.barHeight - 6
    implicitWidth: batPill.implicitWidth

    readonly property color batColor: {
        if (BatteryService.isCritical) return Theme.danger;
        if (BatteryService.isLow) return Theme.warning;
        if (BatteryService.isCharging) return Theme.success;
        return Theme.text;
    }

    Rectangle {
        id: batPill
        anchors.fill: parent
        radius: Theme.pillRadius - 1
        color: batMouse.containsMouse ? Theme.surfaceHover : "transparent"
        border.color: batMouse.containsMouse ? Theme.borderHover : "transparent"
        border.width: 1
        implicitWidth: batRow.implicitWidth + 12

        Behavior on color {
            ColorAnimation { duration: Theme.animFast }
        }

        RowLayout {
            id: batRow
            anchors.centerIn: parent
            spacing: 5

            // Custom macOS Battery Icon
            Item {
                implicitWidth: 20
                implicitHeight: 11

                // Outer Shell
                Rectangle {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: 18
                    height: 11
                    radius: 3
                    color: "transparent"
                    border.color: root.batColor
                    border.width: 1

                    // Internal Fill
                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.margins: 2
                        width: Math.max(2, (parent.width - 4) * (BatteryService.percent / 100))
                        radius: 1.5
                        color: root.batColor
                    }

                    // Bolt icon if charging
                    Icon {
                        anchors.centerIn: parent
                        glyph: "󰂄"
                        size: 9
                        color: Theme.bgSolid
                        visible: BatteryService.isCharging
                    }
                }

                // Battery Terminal Nipple
                Rectangle {
                    anchors.left: parent.left
                    anchors.leftMargin: 18
                    anchors.verticalCenter: parent.verticalCenter
                    width: 2
                    height: 5
                    radius: 1
                    color: root.batColor
                }
            }

            Text {
                text: BatteryService.percent + "%"
                color: root.batColor
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
            }
        }

        MouseArea {
            id: batMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (typeof barWindow !== "undefined" && barWindow.toggleControlCenter) {
                    barWindow.toggleControlCenter();
                }
            }
        }
    }
}
