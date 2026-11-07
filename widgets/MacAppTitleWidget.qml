import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import "../components"
import "../services"
import ".."

Item {
    id: root

    readonly property var activeWindow: ToplevelManager.activeToplevel
    readonly property string winAppId: activeWindow?.appId || ""
    readonly property string winTitle: activeWindow?.title || ""

    readonly property string resolvedAppName: {
        if (!activeWindow) return "Finder";
        const entry = DockService.findDesktopEntry(winAppId);
        if (entry && entry.name && entry.name.length > 0) return entry.name;
        if (winAppId.length > 0) {
            const parts = winAppId.split(".");
            let n = parts[parts.length - 1];
            if (n.toLowerCase() === "desktop") n = parts[parts.length - 2] || n;
            return n.charAt(0).toUpperCase() + n.slice(1);
        }
        if (winTitle.length > 0) {
            const parts = winTitle.split(" - ");
            return parts[parts.length - 1].trim();
        }
        return "Finder";
    }

    implicitHeight: Config.barHeight - 6
    implicitWidth: Math.min(220, labelText.implicitWidth + 18)

    Rectangle {
        id: pillBg
        anchors.fill: parent
        radius: height / 2
        color: appMouse.pressed ? Theme.fillSecondary : (appMouse.containsMouse ? Theme.fillPrimary : "transparent")
        border.color: appMouse.containsMouse ? Theme.specularBorder : "transparent"
        border.width: 1

        Behavior on color {
            ColorAnimation { duration: Theme.animFast }
        }

        Text {
            id: labelText
            anchors.centerIn: parent
            text: root.resolvedAppName
            color: Theme.labelPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeRegular
            font.weight: Font.Bold
            elide: Text.ElideRight
            maximumLineCount: 1
        }

        MouseArea {
            id: appMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) {
                    SwayService.killActive();
                }
            }
        }
    }
}
