import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../components"
import "../services"
import ".."

PanelWindow {
    id: clipWindow

    property bool isOpen: false
    property string query: ""
    property int selectedIndex: 0

    visible: isOpen
    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "swayshell:clipboard"
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    readonly property var allItems: ClipboardService.entries || []

    readonly property var filteredItems: {
        const q = query.toLowerCase().trim();
        if (q.length === 0) return allItems.slice(0, 50);

        const list = [];
        for (let i = 0; i < allItems.length; i++) {
            const item = allItems[i];
            if (item.text.toLowerCase().includes(q)) {
                list.push(item);
                if (list.length >= 50) break;
            }
        }
        return list;
    }

    onIsOpenChanged: {
        if (isOpen) {
            query = "";
            selectedIndex = 0;
            ClipboardService.refresh();
            clipSearchInput.forceActiveFocus();
        }
    }

    function copySelected() {
        if (filteredItems.length > 0 && selectedIndex >= 0 && selectedIndex < filteredItems.length) {
            const item = filteredItems[selectedIndex];
            ClipboardService.copy(item);
        }
        isOpen = false;
    }

    function deleteSelected() {
        if (filteredItems.length > 0 && selectedIndex >= 0 && selectedIndex < filteredItems.length) {
            const item = filteredItems[selectedIndex];
            ClipboardService.deleteEntry(item);
        }
    }

    // Dimmed background
    Rectangle {
        anchors.fill: parent
        color: clipWindow.isOpen ? "#66000000" : "transparent"

        Behavior on color {
            ColorAnimation { duration: Theme.animNormal }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                clipWindow.isOpen = false;
            }
        }
    }

    // Spotlight card
    GlassCard {
        width: Math.min(560, parent.width - 32)
        height: Math.min(520, clipCol.implicitHeight + 24)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.16

        opacity: clipWindow.isOpen ? 1 : 0
        scale: clipWindow.isOpen ? 1 : 0.96

        Behavior on opacity {
            NumberAnimation { duration: Theme.animNormal; easing.type: Theme.animEasing }
        }
        Behavior on scale {
            NumberAnimation { duration: Theme.animNormal; easing.type: Theme.animEasing }
        }

        ColumnLayout {
            id: clipCol
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            // Header & Search
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 42
                    radius: Theme.pillRadius
                    color: Theme.surface
                    border.color: clipSearchInput.activeFocus ? Theme.accent : Theme.border
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 10

                        Icon {
                            glyph: "󰅌"
                            color: clipSearchInput.activeFocus ? Theme.accent : Theme.textMuted
                            size: 16
                        }

                        TextInput {
                            id: clipSearchInput
                            Layout.fillWidth: true
                            text: clipWindow.query
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeRegular
                            clip: true
                            verticalAlignment: TextInput.AlignVCenter

                            onTextChanged: {
                                clipWindow.query = text;
                                clipWindow.selectedIndex = 0;
                            }

                            Keys.onDownPressed: {
                                if (clipWindow.selectedIndex < clipWindow.filteredItems.length - 1) {
                                    clipWindow.selectedIndex++;
                                }
                            }

                            Keys.onUpPressed: {
                                if (clipWindow.selectedIndex > 0) {
                                    clipWindow.selectedIndex--;
                                }
                            }

                            Keys.onReturnPressed: {
                                clipWindow.copySelected();
                            }

                            Keys.onDeletePressed: {
                                clipWindow.deleteSelected();
                            }

                            Keys.onEscapePressed: {
                                clipWindow.isOpen = false;
                            }

                            Text {
                                anchors.fill: parent
                                visible: !clipSearchInput.text && !clipSearchInput.inputMethodComposing
                                text: "Search clipboard history... (Del: borrar, Enter: copiar)"
                                color: Theme.textDisabled
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeRegular
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }

                // Clear history button
                BasePill {
                    implicitHeight: 42
                    implicitWidth: 42
                    clickable: true
                    hoverBg: Theme.danger
                    radius: Theme.pillRadius

                    Icon {
                        anchors.centerIn: parent
                        glyph: "󰆴"
                        color: parent.active ? Theme.bgSolid : Theme.danger
                        size: 16
                    }

                    onClicked: {
                        ClipboardService.wipe();
                    }
                }
            }

            // Results List
            ListView {
                id: clipList
                Layout.fillWidth: true
                implicitHeight: Math.min(380, contentHeight)
                clip: true
                model: clipWindow.filteredItems
                spacing: 4

                delegate: Rectangle {
                    id: clipItemDelegate
                    required property var modelData
                    required property int index

                    readonly property bool isSelected: index === clipWindow.selectedIndex

                    width: clipList.width
                    implicitHeight: 44
                    radius: Theme.pillRadius
                    color: isSelected ? Theme.surfaceActive : (clipItemMouse.containsMouse ? Theme.surfaceHover : "transparent")
                    border.color: isSelected ? Theme.accent : "transparent"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 10

                        Icon {
                            glyph: clipItemDelegate.modelData.isImage ? "󰋩" : "󰅌"
                            color: clipItemDelegate.isSelected ? Theme.accent : Theme.textMuted
                            size: 16
                        }

                        Text {
                            Layout.fillWidth: true
                            text: clipItemDelegate.modelData.text
                            color: clipItemDelegate.isSelected ? Theme.accent : Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeRegular
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }

                        // Delete button
                        BasePill {
                            implicitWidth: 26
                            implicitHeight: 26
                            clickable: true
                            hoverBg: Theme.danger
                            radius: 13
                            visible: clipItemMouse.containsMouse || clipItemDelegate.isSelected

                            Icon {
                                anchors.centerIn: parent
                                glyph: "󰅖"
                                color: Theme.textMuted
                                size: 12
                            }

                            onClicked: {
                                ClipboardService.deleteEntry(clipItemDelegate.modelData);
                            }
                        }
                    }

                    MouseArea {
                        id: clipItemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: {
                            clipWindow.selectedIndex = clipItemDelegate.index;
                        }
                        onClicked: {
                            clipWindow.selectedIndex = clipItemDelegate.index;
                            clipWindow.copySelected();
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: clipWindow.filteredItems.length === 0
                    text: "Portapapeles vacío"
                    color: Theme.textDisabled
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeRegular
                }
            }
        }
    }
}
