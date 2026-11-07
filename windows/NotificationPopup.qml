import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../components"
import "../services"
import ".."

PanelWindow {
    id: notifWindow

    visible: NotificationService.count > 0
    color: "transparent"

    anchors {
        top: Config.barPosition === "bottom" ? false : true
        bottom: Config.barPosition === "bottom" ? true : false
        right: true
    }

    margins {
        top: Config.barPosition === "top" ? (Config.barHeight + Config.barMarginVertical + 6) : 16
        bottom: Config.barPosition === "bottom" ? (Config.barHeight + Config.barMarginVertical + 6) : 16
        right: 16
    }

    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "swayshell:notifications"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    implicitWidth: 360
    implicitHeight: Math.max(1, notifCol.implicitHeight)

    ColumnLayout {
        id: notifCol
        width: parent.width
        spacing: 10

        Repeater {
            model: NotificationService.notifications

            delegate: GlassCard {
                id: toastCard
                required property var modelData

                Layout.fillWidth: true
                implicitHeight: toastContent.implicitHeight + 20
                radius: Theme.cardRadius

                ColumnLayout {
                    id: toastContent
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 6

                    // Header: App icon + App Name + Close button
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Icon {
                            size: 16
                            iconName: toastCard.modelData.appIcon
                            glyph: "󰂚"
                            color: Theme.accent
                        }

                        Text {
                            Layout.fillWidth: true
                            text: toastCard.modelData.appName
                            color: Theme.textMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        // Close button
                        BasePill {
                            implicitWidth: 20
                            implicitHeight: 20
                            clickable: true
                            defaultBg: "transparent"
                            hoverBg: Theme.surfaceHover
                            radius: 10

                            Icon {
                                anchors.centerIn: parent
                                glyph: "󰅖"
                                color: Theme.textMuted
                                size: 12
                            }

                            onClicked: {
                                NotificationService.dismiss(toastCard.modelData.id);
                            }
                        }
                    }

                    // Summary
                    Text {
                        Layout.fillWidth: true
                        text: toastCard.modelData.summary
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeRegular
                        font.bold: true
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        visible: text.length > 0
                    }

                    // Body
                    Text {
                        Layout.fillWidth: true
                        text: toastCard.modelData.body
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        wrapMode: Text.Wrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                        visible: text.length > 0
                    }

                    // Actions row (if any)
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        visible: toastCard.modelData.actions && toastCard.modelData.actions.length > 0

                        Repeater {
                            model: toastCard.modelData.actions || []

                            delegate: BasePill {
                                id: actionBtn
                                required property var modelData

                                implicitHeight: 24
                                Layout.fillWidth: true
                                clickable: true
                                defaultBg: Theme.surface
                                hoverBg: Theme.accent
                                radius: Theme.pillRadius

                                Text {
                                    anchors.centerIn: parent
                                    text: actionBtn.modelData.text || "Action"
                                    color: actionBtn.hoverable && actionBtn.active ? Theme.bgSolid : Theme.text
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.bold: true
                                }

                                onClicked: {
                                    NotificationService.invokeAction(toastCard.modelData.id, actionBtn.modelData.identifier);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
