import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../components"
import "../services"
import ".."

BasePill {
    id: root

    readonly property var activeWindow: ToplevelManager.activeToplevel
    readonly property string winTitle: activeWindow?.title || ""
    readonly property string winAppId: activeWindow?.appId || ""
    readonly property bool hasWindow: winTitle.length > 0

    visible: Config.showFocusedWindow && hasWindow
    implicitHeight: Theme.barHeight - 6
    implicitWidth: Math.min(340, contentRow.implicitWidth + 18)
    clickable: true

    onRightClicked: {
        // Right click closes active window
        SwayService.killActive();
    }

    RowLayout {
        id: contentRow
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 6

        Icon {
            id: appIcon
            size: 13
            iconName: root.winAppId
            glyph: "󰣆"
            color: Theme.accent
        }

        Text {
            Layout.fillWidth: true
            text: root.winTitle
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            font.bold: true
            elide: Text.ElideRight
            maximumLineCount: 1
        }
    }
}
