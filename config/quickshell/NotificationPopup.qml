import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Services.Notifications

PanelWindow {
    id: notifWindow

    anchors {
        top: true
        right: true
    }

    margins {
        top: 46
        right: 12
    }

    width: 340
    implicitHeight: notifCol.implicitHeight
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "sway-notifications"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    ColumnLayout {
        id: notifCol
        width: parent.width
        spacing: 8

        Repeater {
            model: NotificationServer.notifications

            Rectangle {
                required property var modelData
                Layout.fillWidth: true
                implicitHeight: cardLayout.implicitHeight + 20
                radius: Theme.radiusMd
                color: Theme.bgSurface
                border.color: Theme.borderMuted
                border.width: 1

                // Auto-cerrar tras 6 segundos
                Timer {
                    interval: 6000
                    running: true
                    onTriggered: modelData.dismiss()
                }

                ColumnLayout {
                    id: cardLayout
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 6

                    // Encabezado con Icono, Nombre de App y Botón Cerrar
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        IconImage {
                            width: 18
                            height: 18
                            source: modelData.appIcon || "dialog-information"
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.appName || "Notificación"
                            font.family: Theme.fontSans
                            font.bold: true
                            font.pixelSize: 11
                            color: Theme.textMuted
                            elide: Text.ElideRight
                        }

                        Rectangle {
                            width: 18
                            height: 18
                            radius: Theme.radiusSm
                            color: closeMouse.containsMouse ? Theme.accentRed : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: "✕"
                                font.pixelSize: 10
                                color: closeMouse.containsMouse ? "#ffffff" : Theme.textMuted
                            }

                            MouseArea {
                                id: closeMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: modelData.dismiss()
                            }
                        }
                    }

                    // Título / Resumen
                    Text {
                        Layout.fillWidth: true
                        text: modelData.summary || ""
                        font.family: Theme.fontSans
                        font.bold: true
                        font.pixelSize: 12
                        color: Theme.textMain
                        wrapMode: Text.Wrap
                        visible: text.length > 0
                    }

                    // Contenido / Cuerpo
                    Text {
                        Layout.fillWidth: true
                        text: modelData.body || ""
                        font.family: Theme.fontSans
                        font.pixelSize: 11
                        color: Theme.textMuted
                        wrapMode: Text.Wrap
                        visible: text.length > 0
                    }
                }
            }
        }
    }
}
