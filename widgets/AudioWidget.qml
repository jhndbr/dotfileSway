import QtQuick
import QtQuick.Layouts
import "../components"
import "../services"
import ".."

Item {
    id: root

    visible: Config.showAudio && AudioService.ready
    implicitHeight: Theme.barHeight - 6
    implicitWidth: audioPill.implicitWidth

    readonly property string iconGlyph: {
        if (AudioService.muted) return "󰖁";
        if (AudioService.volumePercent >= 70) return "󰕾";
        if (AudioService.volumePercent >= 30) return "󰖀";
        if (AudioService.volumePercent > 0) return "󰕿";
        return "󰖁";
    }

    Rectangle {
        id: audioPill
        anchors.fill: parent
        radius: Theme.pillRadius - 1
        color: audioMouse.containsMouse ? Theme.surfaceHover : "transparent"
        border.color: audioMouse.containsMouse ? Theme.borderHover : "transparent"
        border.width: 1
        implicitWidth: audioRow.implicitWidth + 12

        Behavior on color {
            ColorAnimation { duration: Theme.animFast }
        }

        RowLayout {
            id: audioRow
            anchors.centerIn: parent
            spacing: 5

            Icon {
                glyph: root.iconGlyph
                color: AudioService.muted ? Theme.danger : (audioMouse.containsMouse ? Theme.accent : Theme.text)
                size: 13
            }

            Text {
                text: AudioService.muted ? "Mute" : AudioService.volumePercent + "%"
                color: AudioService.muted ? Theme.danger : Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
            }
        }

        MouseArea {
            id: audioMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onClicked: (mouse) => {
                if (mouse.button === Qt.LeftButton) {
                    AudioService.toggleMute();
                } else if (mouse.button === Qt.RightButton) {
                    SwayService.exec("pavucontrol");
                }
            }

            onWheel: (wheel) => {
                if (wheel.angleDelta.y > 0) {
                    AudioService.increaseVolume(0.05);
                } else if (wheel.angleDelta.y < 0) {
                    AudioService.decreaseVolume(0.05);
                }
            }
        }
    }
}
