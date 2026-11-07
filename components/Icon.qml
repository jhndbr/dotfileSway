import QtQuick
import Quickshell
import Quickshell.Widgets
import ".."

Item {
    id: root

    property string glyph: ""
    property string iconName: ""
    property string source: ""
    property color color: Theme.text
    property real size: Theme.iconSize

    width: size
    height: size

    readonly property string resolvedSource: {
        if (source.length > 0) return source;
        if (iconName.length > 0) {
            if (iconName.startsWith("/") || iconName.startsWith("file://")) {
                return iconName.startsWith("file://") ? iconName : "file://" + iconName;
            }
            const path = Quickshell.iconPath(iconName, "");
            return path ? (path.startsWith("/") ? "file://" + path : path) : "";
        }
        return "";
    }

    IconImage {
        id: img
        anchors.centerIn: parent
        width: root.size
        height: root.size
        source: root.resolvedSource
        visible: root.resolvedSource.length > 0 && status === Image.Ready
        asynchronous: true
        smooth: true
        mipmap: true
    }

    Text {
        id: txt
        anchors.centerIn: parent
        visible: (!img.visible || root.resolvedSource.length === 0) && root.glyph.length > 0
        text: root.glyph
        color: root.color
        font.pixelSize: root.size
        font.family: Theme.fontIcons
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
