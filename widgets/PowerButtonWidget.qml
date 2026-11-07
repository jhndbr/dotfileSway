import QtQuick
import "../components"
import ".."

BasePill {
    id: root

    signal powerClicked()

    visible: Config.showPowerButton
    implicitHeight: Theme.barHeight - 6
    implicitWidth: 26
    clickable: true
    hoverBg: Theme.danger
    activeBg: Theme.danger
    activeBorder: Theme.danger

    onClicked: {
        root.powerClicked();
    }

    Icon {
        anchors.centerIn: parent
        glyph: "󰐥"
        color: (root.active || root.isHovered) ? Theme.bgSolid : Theme.danger
        size: 13

        Behavior on color {
            ColorAnimation { duration: Theme.animFast }
        }
    }
}
