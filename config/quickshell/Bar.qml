import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.I3
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "."

PanelWindow {
    id: barWindow

    anchors {
        top: true
        left: true
        right: true
    }

    height: 38
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "sway-bar"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: 4
        anchors.bottomMargin: 2
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        color: Theme.bgSurface
        radius: Theme.radiusMd
        border.color: Theme.borderMuted
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 8

            // ── Botón Menú / Lanzador ─────────────────────────
            Rectangle {
                width: 28
                height: 24
                radius: Theme.radiusSm
                color: launcherBtnMouse.containsMouse ? Theme.bgHover : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: ""
                    font.family: Theme.fontMono
                    font.pixelSize: 14
                    color: Theme.textMain
                }

                MouseArea {
                    id: launcherBtnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.toggleLauncher()
                }
            }

            // Separador sutil
            Rectangle {
                width: 1
                height: 16
                color: Theme.borderMuted
            }

            // ── Workspaces de Sway (Quickshell.I3) ────────────
            RowLayout {
                spacing: 4

                Repeater {
                    model: I3.workspaces

                    Rectangle {
                        required property var modelData
                        width: wsLabel.implicitWidth + 14
                        height: 22
                        radius: Theme.radiusSm
                        color: modelData.focused
                               ? Theme.borderFocus
                               : (modelData.urgent ? Theme.accentRed : (wsMouse.containsMouse ? Theme.bgHover : "transparent"))

                        Text {
                            id: wsLabel
                            anchors.centerIn: parent
                            text: modelData.name
                            font.family: Theme.fontMono
                            font.bold: true
                            font.pixelSize: 11
                            color: modelData.focused ? Theme.bgDark : (modelData.urgent ? "#ffffff" : Theme.textMain)
                        }

                        MouseArea {
                            id: wsMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                I3.dispatch("workspace " + modelData.name)
                            }
                        }
                    }
                }
            }

            // Espaciador izquierdo
            Item { Layout.fillWidth: true }

            // ── Reloj y Fecha Central ─────────────────────────
            SystemClock {
                id: clock
                precision: SystemClock.Minutes
            }

            RowLayout {
                spacing: 6

                Text {
                    text: Qt.formatDateTime(clock.date, "ddd d MMM  •  HH:mm")
                    font.family: Theme.fontSans
                    font.pixelSize: 12
                    font.bold: true
                    color: Theme.textMain
                }
            }

            // Espaciador derecho
            Item { Layout.fillWidth: true }

            // ── Volumen de PipeWire ───────────────────────────
            RowLayout {
                spacing: 4

                Rectangle {
                    width: volLayout.implicitWidth + 12
                    height: 24
                    radius: Theme.radiusSm
                    color: volMouse.containsMouse ? Theme.bgHover : "transparent"

                    RowLayout {
                        id: volLayout
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            text: {
                                if (!Pipewire.defaultAudioSink || Pipewire.defaultAudioSink.audio.muted) return "󰝟"
                                let vol = Pipewire.defaultAudioSink.audio.volume
                                if (vol > 0.6) return "󰕾"
                                if (vol > 0.2) return "󰖀"
                                return "󰕿"
                            }
                            font.family: Theme.fontMono
                            font.pixelSize: 13
                            color: (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio.muted) ? Theme.accentRed : Theme.textMuted
                        }

                        Text {
                            text: {
                                if (!Pipewire.defaultAudioSink) return "--%"
                                return Math.round(Pipewire.defaultAudioSink.audio.volume * 100) + "%"
                            }
                            font.family: Theme.fontMono
                            font.pixelSize: 11
                            color: Theme.textMain
                        }
                    }

                    MouseArea {
                        id: volMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (Pipewire.defaultAudioSink) {
                                Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink.audio.muted
                            }
                        }
                        onWheel: wheel => {
                            if (Pipewire.defaultAudioSink) {
                                let delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05
                                let current = Pipewire.defaultAudioSink.audio.volume
                                Pipewire.defaultAudioSink.audio.volume = Math.max(0.0, Math.min(1.5, current + delta))
                            }
                        }
                    }
                }
            }

            // ── Bandeja de Sistema (SystemTray) ───────────────
            RowLayout {
                spacing: 4

                Repeater {
                    model: SystemTray.items

                    Rectangle {
                        required property var modelData
                        width: 22
                        height: 22
                        radius: Theme.radiusSm
                        color: trayMouse.containsMouse ? Theme.bgHover : "transparent"

                        IconImage {
                            anchors.centerIn: parent
                            width: 16
                            height: 16
                            source: modelData.icon
                        }

                        MouseArea {
                            id: trayMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            cursorShape: Qt.PointingHandCursor
                            onClicked: mouse => {
                                if (mouse.button === Qt.RightButton) {
                                    modelData.showMenu()
                                } else {
                                    modelData.activate()
                                }
                            }
                        }
                    }
                }
            }

            // Separador sutil
            Rectangle {
                width: 1
                height: 16
                color: Theme.borderMuted
            }

            // ── Botón de Apagado / Control ────────────────────
            Rectangle {
                width: 26
                height: 24
                radius: Theme.radiusSm
                color: powerBtnMouse.containsMouse ? Theme.accentRed : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "⏻"
                    font.family: Theme.fontMono
                    font.pixelSize: 13
                    font.bold: true
                    color: powerBtnMouse.containsMouse ? "#ffffff" : Theme.textMuted
                }

                MouseArea {
                    id: powerBtnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.togglePower()
                }
            }
        }
    }
}
