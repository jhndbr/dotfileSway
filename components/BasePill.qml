import QtQuick
import ".."

Rectangle {
    id: root

    property bool clickable: false
    property bool hoverable: true
    property bool active: false
    property color activeBg: Theme.fillSecondary
    property color defaultBg: Theme.fillTertiary
    property color hoverBg: Theme.fillPrimary
    property color activeBorder: Theme.accentColor
    property color defaultBorder: Theme.specularBorder
    property color hoverBorder: Theme.specularBorderHover
    readonly property bool isHovered: mouseArea.containsMouse
    property bool showSpecularRim: true

    signal clicked(var mouse)
    signal rightClicked(var mouse)
    signal scrolled(int delta)

    radius: Theme.pillRadius
    color: active ? activeBg : (hoverable && mouseArea.containsMouse ? hoverBg : defaultBg)
    border.color: active ? activeBorder : (hoverable && mouseArea.containsMouse ? hoverBorder : defaultBorder)
    border.width: 1

    Behavior on color {
        ColorAnimation { duration: Theme.animFast; easing.type: Theme.animEasing }
    }

    Behavior on border.color {
        ColorAnimation { duration: Theme.animFast; easing.type: Theme.animEasing }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.clickable || root.hoverable
        hoverEnabled: root.hoverable
        cursorShape: root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                root.clicked(mouse);
            } else if (mouse.button === Qt.RightButton) {
                root.rightClicked(mouse);
            }
        }

        onWheel: (wheel) => {
            root.scrolled(wheel.angleDelta.y);
        }
    }
}
