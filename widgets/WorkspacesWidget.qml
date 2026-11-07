import QtQuick
import QtQuick.Layouts
import "../services"
import "../components"
import ".."

Item {
    id: root

    implicitHeight: Theme.barHeight - 6
    implicitWidth: trackBg.implicitWidth

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

    // Cohesive track background
    Rectangle {
        id: trackBg
        anchors.verticalCenter: parent.verticalCenter
        implicitHeight: 22
        implicitWidth: rowLayout.implicitWidth + 6
        radius: Theme.pillRadius + 1
        color: Theme.surface
        border.color: Theme.border
        border.width: 1

        RowLayout {
            id: rowLayout
            anchors.centerIn: parent
            spacing: 2

            Repeater {
                model: root.wsList

                delegate: Rectangle {
                    id: wsPill
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

                    implicitWidth: {
                        if (isFocused) return Math.max(26, labelText.implicitWidth + 10);
                        if (wsMouse.containsMouse) return Math.max(22, labelText.implicitWidth + 8);
                        return 18;
                    }
                    implicitHeight: 18
                    radius: Theme.pillRadius - 1

                    color: {
                        if (isUrgent) return Theme.danger;
                        if (isFocused) return Theme.accent;
                        if (wsMouse.containsMouse) return Theme.surfaceHover;
                        return "transparent";
                    }

                    border.color: isFocused ? Theme.accentHover : (isUrgent ? Theme.danger : "transparent")
                    border.width: isFocused || isUrgent ? 1 : 0

                    scale: wsMouse.pressed ? 0.94 : 1.0

                    Behavior on implicitWidth {
                        NumberAnimation { duration: Theme.animFast; easing.type: Theme.animEasing }
                    }

                    Behavior on color {
                        ColorAnimation { duration: Theme.animFast }
                    }

                    Behavior on scale {
                        NumberAnimation { duration: 100 }
                    }

                    Text {
                        id: labelText
                        anchors.centerIn: parent
                        text: wsPill.wsLabel
                        color: {
                            if (wsPill.isFocused || wsPill.isUrgent) return Theme.bgSolid;
                            if (wsMouse.containsMouse) return Theme.text;
                            return Theme.textMuted;
                        }
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: wsPill.isFocused
                    }

                    MouseArea {
                        id: wsMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            SwayService.changeWorkspace(wsPill.modelData);
                        }
                    }
                }
            }
        }
    }
}
