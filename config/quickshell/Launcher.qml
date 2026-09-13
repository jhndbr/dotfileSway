import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

PanelWindow {
    id: launcherWindow

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "#80000000"
    visible: false

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "sway-launcher"
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    property string searchText: ""

    function open(): void {
        searchText = ""
        searchInput.text = ""
        visible = true
        searchInput.forceActiveFocus()
    }

    function close(): void {
        visible = false
    }

    function toggle(): void {
        if (visible) close()
        else open()
    }

    // Cerrar al hacer clic en el fondo oscurecido
    MouseArea {
        anchors.fill: parent
        onClicked: launcherWindow.close()
    }

    // Tarjeta central del lanzador
    Rectangle {
        id: card
        width: Math.min(580, parent.width - 40)
        height: Math.min(460, parent.height - 80)
        anchors.centerIn: parent
        color: Theme.bgSurface
        radius: Theme.radiusLg
        border.color: Theme.borderMuted
        border.width: 1

        // Prevenir que clics en la tarjeta cierren el lanzador
        MouseArea {
            anchors.fill: parent
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Campo de búsqueda
            Rectangle {
                Layout.fillWidth: true
                height: 42
                radius: Theme.radiusMd
                color: Theme.bgDark
                border.color: searchInput.activeFocus ? Theme.borderFocus : Theme.borderMuted
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8

                    Text {
                        text: ""
                        font.family: Theme.fontMono
                        font.pixelSize: 13
                        color: Theme.textMuted
                    }

                    TextInput {
                        id: searchInput
                        Layout.fillWidth: true
                        font.family: Theme.fontSans
                        font.pixelSize: 13
                        color: Theme.textMain
                        selectionColor: Theme.accentBlue
                        selectedTextColor: "#ffffff"
                        clip: true

                        Text {
                            anchors.fill: parent
                            text: "Buscar aplicaciones..."
                            font: parent.font
                            color: Theme.textMuted
                            visible: !parent.text && !parent.activeFocus
                        }

                        onTextChanged: {
                            launcherWindow.searchText = text.trim()
                            appList.currentIndex = 0
                        }

                        Keys.onEscapePressed: launcherWindow.close()

                        Keys.onDownPressed: {
                            if (appList.currentIndex < appList.count - 1) {
                                appList.currentIndex++
                            }
                        }

                        Keys.onUpPressed: {
                            if (appList.currentIndex > 0) {
                                appList.currentIndex--
                            }
                        }

                        Keys.onReturnPressed: {
                            if (appList.currentItem && appList.currentItem.appEntry) {
                                appList.currentItem.appEntry.execute()
                                launcherWindow.close()
                            }
                        }
                    }
                }
            }

            // Lista de aplicaciones encontradas
            ListView {
                id: appList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 4
                highlightFollowsCurrentItem: true

                model: {
                    let all = DesktopEntries.applications.values
                    let query = launcherWindow.searchText.toLowerCase()
                    let filtered = []
                    for (let i = 0; i < all.length; i++) {
                        let app = all[i]
                        if (app.noDisplay) continue
                        if (!query || app.name.toLowerCase().includes(query) || (app.comment && app.comment.toLowerCase().includes(query))) {
                            filtered.push(app)
                        }
                    }
                    return filtered
                }

                delegate: Rectangle {
                    id: delegateItem
                    property var appEntry: modelData
                    width: appList.width
                    height: 48
                    radius: Theme.radiusSm
                    color: ListView.isCurrentItem ? Theme.bgSelected : (itemMouse.containsMouse ? Theme.bgHover : "transparent")

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 12

                        IconImage {
                            width: 28
                            height: 28
                            source: modelData.icon ? modelData.icon : "application-x-executable"
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                Layout.fillWidth: true
                                text: modelData.name
                                font.family: Theme.fontSans
                                font.bold: true
                                font.pixelSize: 12
                                color: Theme.textMain
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                text: modelData.comment || modelData.genericName || ""
                                font.family: Theme.fontSans
                                font.pixelSize: 10
                                color: Theme.textMuted
                                elide: Text.ElideRight
                                visible: text.length > 0
                            }
                        }
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            modelData.execute()
                            launcherWindow.close()
                        }
                    }
                }
            }
        }
    }
}
