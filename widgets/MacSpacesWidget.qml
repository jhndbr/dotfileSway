import QtQuick
import QtQuick.Layouts
import "../services"
import "../components"
import ".."

Item {
    id: root

    implicitHeight: Theme.barHeight - 6
    implicitWidth: spacesContainer.implicitWidth

    readonly property var wsList: SwayService.workspaces.length > 0 ? SwayService.workspaces : [
        { num: 1, name: "1", focused: true, urgent: false }
    ]

    MouseArea {
        anchors.fill: parent
        onWheel: (wheel) => {
            if (wheel.angleDelta.y > 0) {
                SwayService.prevWorkspace();
            } else if (wheel.angleDelta.y < 0) {
                SwayService.nextWorkspace();
            }
        }
    }

    // Minimal macOS Liquid Glass Spaces Capsule (Sin Blur - Transparencia Pura)
    Rectangle {
        id: spacesContainer
        anchors.verticalCenter: parent.verticalCenter
        implicitHeight: Config.barHeight - 6
        implicitWidth: spacesRow.implicitWidth + 8
        radius: height / 2

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: Theme.glassSmallTop
            }
            GradientStop {
                position: 1.0
                color: Theme.glassSmallBottom
            }
        }

        border.color: Theme.specularBorder
        border.width: 1

        RowLayout {
            id: spacesRow
            anchors.centerIn: parent
            spacing: 2

            Repeater {
                model: root.wsList

                delegate: Rectangle {
                    id: spaceItem
                    required property var modelData
                    required property int index

                    readonly property bool isFocused: modelData.focused === true
                    readonly property bool isUrgent: modelData.urgent === true
                    readonly property string wsLabel: {
                        if (modelData.name && modelData.name.length > 0) {
                            return modelData.name.split(":")[0];
                        }
                        return String(modelData.num ?? (index + 1));
                    }

                    implicitWidth: isFocused ? Math.max(26, labelText.implicitWidth + 12) : Math.max(18, labelText.implicitWidth + 6)
                    implicitHeight: spacesContainer.implicitHeight - 4
                    radius: height / 2

                    color: {
                        if (isUrgent) return Theme.systemRed;
                        if (isFocused) return Theme.accentColor;
                        if (spaceMouse.containsMouse) return Theme.fillPrimary;
                        return "transparent";
                    }

                    border.color: {
                        if (isFocused) return Qt.rgba(1, 1, 1, 0.25);
                        if (spaceMouse.containsMouse) return Theme.specularBorderHover;
                        return "transparent";
                    }
                    border.width: 1

                    Behavior on implicitWidth {
                        NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutQuint }
                    }

                    Behavior on color {
                        ColorAnimation { duration: Theme.animFast }
                    }

                    Text {
                        id: labelText
                        anchors.centerIn: parent
                        text: spaceItem.wsLabel
                        color: {
                            if (spaceItem.isFocused || spaceItem.isUrgent) return "#ffffff";
                            if (spaceMouse.containsMouse) return Theme.labelPrimary;
                            return Theme.labelSecondary;
                        }
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.weight: spaceItem.isFocused ? Font.Bold : Font.Normal
                    }

                    MouseArea {
                        id: spaceMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            SwayService.changeWorkspace(spaceItem.modelData);
                        }
                    }
                }
            }
        }
    }
}
