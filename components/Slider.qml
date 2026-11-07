import QtQuick
import ".."

Item {
    id: root

    property real value: 0.0
    property real minimumValue: 0.0
    property real maximumValue: 1.0
    property color trackColor: Theme.surfaceHover
    property color progressColor: Theme.accent
    property color highlightColor: Theme.accentHover
    property int trackHeight: 8
    property int radius: trackHeight / 2
    property bool interactive: true

    signal moved(real newValue)

    implicitWidth: 160
    implicitHeight: Math.max(trackHeight, 20)

    readonly property real normalizedValue: Math.max(0.0, Math.min(1.0, (value - minimumValue) / (maximumValue - minimumValue)))

    // Track background
    Rectangle {
        id: track
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: root.trackHeight
        radius: root.radius
        color: root.trackColor

        // Active fill
        Rectangle {
            id: progress
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: Math.max(parent.height, parent.width * root.normalizedValue)
            radius: root.radius
            color: sliderMouse.containsMouse || sliderMouse.pressed ? root.highlightColor : root.progressColor

            Behavior on color {
                ColorAnimation { duration: Theme.animFast }
            }
        }
    }

    MouseArea {
        id: sliderMouse
        anchors.fill: parent
        enabled: root.interactive
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        function updateFromMouse(mouseX) {
            const ratio = Math.max(0.0, Math.min(1.0, mouseX / width));
            const calculated = root.minimumValue + ratio * (root.maximumValue - root.minimumValue);
            root.moved(calculated);
        }

        onPressed: (mouse) => updateFromMouse(mouse.x)
        onPositionChanged: (mouse) => {
            if (pressed) updateFromMouse(mouse.x);
        }
    }
}
