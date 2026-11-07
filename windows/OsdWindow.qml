import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../components"
import "../services"
import ".."

PanelWindow {
    id: osdWindow

    visible: OsdService.showOsd
    color: "transparent"

    anchors {
        bottom: true
    }

    margins {
        bottom: 60
    }

    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "swayshell:osd"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    implicitWidth: 260
    implicitHeight: 48

    GlassCard {
        anchors.fill: parent
        radius: Theme.pillRadius + 6

        opacity: OsdService.showOsd ? 1 : 0
        scale: OsdService.showOsd ? 1 : 0.92

        Behavior on opacity {
            NumberAnimation { duration: Theme.animFast; easing.type: Theme.animEasing }
        }
        Behavior on scale {
            NumberAnimation { duration: Theme.animFast; easing.type: Theme.animEasing }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

            Icon {
                glyph: OsdService.iconGlyph
                color: OsdService.currentMuted ? Theme.danger : Theme.accent
                size: 18
            }

            // Minimalist slider/progress
            Slider {
                Layout.fillWidth: true
                value: OsdService.currentValue
                interactive: false
                progressColor: OsdService.currentMuted ? Theme.danger : Theme.accent
                trackHeight: 6
            }

            Text {
                text: OsdService.currentMuted ? "Mute" : Math.round(OsdService.currentValue * 100) + "%"
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
            }
        }
    }
}
