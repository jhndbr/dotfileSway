import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: powerWindow

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "#90000000"
    visible: false

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "sway-powermenu"
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    function open(): void {
        visible = true
    }

    function close(): void {
        visible = false
    }

    function toggle(): void {
        if (visible) close()
        else open()
    }

    // Procesos de acción del sistema
    Process { id: lockProc; command: ["swaylock", "-f"] }
    Process { id: suspendProc; command: ["systemctl", "suspend"] }
    Process { id: rebootProc; command: ["systemctl", "reboot"] }
    Process { id: poweroffProc; command: ["systemctl", "poweroff"] }

    // Fondo para cerrar al presionar fuera o pulsar Escape
    MouseArea {
        anchors.fill: parent
        onClicked: powerWindow.close()
    }

    Item {
        anchors.fill: parent
        focus: powerWindow.visible

        Keys.onEscapePressed: powerWindow.close()
    }

    // Tarjeta central
    Rectangle {
        width: 440
        height: 180
        anchors.centerIn: parent
        color: Theme.bgSurface
        radius: Theme.radiusLg
        border.color: Theme.borderMuted
        border.width: 1

        MouseArea {
            anchors.fill: parent
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Menú del Sistema"
                font.family: Theme.fontSans
                font.bold: true
                font.pixelSize: 14
                color: Theme.textMain
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 14

                // Bloquear
                Rectangle {
                    width: 80
                    height: 80
                    radius: Theme.radiusMd
                    color: lockMouse.containsMouse ? Theme.bgHover : Theme.bgDark
                    border.color: Theme.borderMuted
                    border.width: 1

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: ""
                            font.family: Theme.fontMono
                            font.pixelSize: 22
                            color: Theme.textMain
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Bloquear"
                            font.family: Theme.fontSans
                            font.pixelSize: 10
                            color: Theme.textMuted
                        }
                    }

                    MouseArea {
                        id: lockMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            powerWindow.close()
                            lockProc.running = true
                        }
                    }
                }

                // Suspender
                Rectangle {
                    width: 80
                    height: 80
                    radius: Theme.radiusMd
                    color: suspMouse.containsMouse ? Theme.bgHover : Theme.bgDark
                    border.color: Theme.borderMuted
                    border.width: 1

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: ""
                            font.family: Theme.fontMono
                            font.pixelSize: 22
                            color: Theme.textMain
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Suspender"
                            font.family: Theme.fontSans
                            font.pixelSize: 10
                            color: Theme.textMuted
                        }
                    }

                    MouseArea {
                        id: suspMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            powerWindow.close()
                            suspendProc.running = true
                        }
                    }
                }

                // Reiniciar
                Rectangle {
                    width: 80
                    height: 80
                    radius: Theme.radiusMd
                    color: rebtMouse.containsMouse ? Theme.bgHover : Theme.bgDark
                    border.color: Theme.borderMuted
                    border.width: 1

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰜉"
                            font.family: Theme.fontMono
                            font.pixelSize: 22
                            color: Theme.textMain
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Reiniciar"
                            font.family: Theme.fontSans
                            font.pixelSize: 10
                            color: Theme.textMuted
                        }
                    }

                    MouseArea {
                        id: rebtMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            powerWindow.close()
                            rebootProc.running = true
                        }
                    }
                }

                // Apagar
                Rectangle {
                    width: 80
                    height: 80
                    radius: Theme.radiusMd
                    color: pwrMouse.containsMouse ? Theme.accentRed : Theme.bgDark
                    border.color: Theme.borderMuted
                    border.width: 1

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "⏻"
                            font.family: Theme.fontMono
                            font.pixelSize: 22
                            color: pwrMouse.containsMouse ? "#ffffff" : Theme.accentRed
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Apagar"
                            font.family: Theme.fontSans
                            font.pixelSize: 10
                            color: pwrMouse.containsMouse ? "#ffffff" : Theme.textMuted
                        }
                    }

                    MouseArea {
                        id: pwrMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            powerWindow.close()
                            poweroffProc.running = true
                        }
                    }
                }
            }
        }
    }
}
