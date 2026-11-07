import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import "../components"
import ".."

Item {
    id: root

    readonly property var items: SystemTray.items.values || []
    visible: Config.showTray && items.length > 0
    implicitHeight: Theme.barHeight - 6
    implicitWidth: trayRow.implicitWidth

    property var currentTrayItem: null
    property var activeMenuHandle: null
    property var activeAnchorItem: null

    function toggleMenu(item, anchor) {
        if (trayMenuPopup.visible && currentTrayItem === item) {
            closeMenu();
            return;
        }
        currentTrayItem = item;
        activeAnchorItem = anchor;
        activeMenuHandle = item?.menu ?? null;
        trayMenuPopup.visible = true;
    }

    function closeMenu() {
        trayMenuPopup.visible = false;
        currentTrayItem = null;
        activeAnchorItem = null;
        activeMenuHandle = null;
    }

    RowLayout {
        id: trayRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Repeater {
            model: root.items

            delegate: Rectangle {
                id: trayItemDelegate
                required property var modelData

                readonly property bool isItemActive: trayMouse.containsMouse || (root.currentTrayItem === trayItemDelegate.modelData && trayMenuPopup.visible)

                implicitWidth: 22
                implicitHeight: Config.barHeight - 6
                radius: height / 2
                color: isItemActive ? Theme.fillPrimary : "transparent"
                border.color: isItemActive ? Theme.specularBorderHover : "transparent"
                border.width: 1

                Behavior on color {
                    ColorAnimation { duration: Theme.animFast }
                }

                IconImage {
                    anchors.centerIn: parent
                    width: 15
                    height: 15
                    source: trayItemDelegate.modelData?.icon || ""
                    asynchronous: true
                    smooth: true
                }

                MouseArea {
                    id: trayMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onClicked: (mouse) => {
                        const item = trayItemDelegate.modelData;
                        if (!item) return;

                        try {
                            if (mouse.button === Qt.RightButton) {
                                if (item.hasMenu && item.menu) {
                                    root.toggleMenu(item, trayItemDelegate);
                                } else if (item.display) {
                                    item.display(root.QsWindow.window, 0, 0);
                                } else if (item.secondaryActivate) {
                                    item.secondaryActivate();
                                } else {
                                    item.activate();
                                }
                            } else {
                                if (item.onlyMenu && item.hasMenu && item.menu) {
                                    root.toggleMenu(item, trayItemDelegate);
                                } else {
                                    root.closeMenu();
                                    item.activate();
                                }
                            }
                        } catch (e) {
                            console.warn("[Tray] Click error:", e);
                        }
                    }
                }
            }
        }
    }

    // ==========================================
    // Native macOS-styled Context Menu Popup
    // ==========================================
    PopupWindow {
        id: trayMenuPopup
        visible: false
        color: "transparent"

        anchor {
            window: root.QsWindow.window
            item: root.activeAnchorItem || root
            edges: Config.barPosition === "bottom" ? Edges.Top : Edges.Bottom
            gravity: Config.barPosition === "bottom" ? Edges.Top : Edges.Bottom
        }

        implicitWidth: menuCard.implicitWidth + 8
        implicitHeight: menuCard.implicitHeight + 8

        onClosed: {
            root.closeMenu();
        }

        QsMenuOpener {
            id: menuOpener
            menu: root.activeMenuHandle
        }

        // Soft floating drop shadow
        Rectangle {
            id: menuShadow
            anchors.fill: menuCard
            anchors.margins: -4
            anchors.topMargin: -1
            anchors.bottomMargin: -5
            radius: menuCard.radius + 4
            color: Qt.rgba(0, 0, 0, 0.40)
            z: 0
        }

        // Main macOS Liquid Glass Popover Card (Sin Blur - Transparencia Pura)
        Rectangle {
            id: menuCard
            anchors.centerIn: parent
            implicitWidth: Math.max(160, menuColumn.implicitWidth + 12)
            implicitHeight: menuColumn.implicitHeight + 10
            radius: Theme.radiusSm
            gradient: Gradient {
                GradientStop { position: 0.0; color: Theme.glassMediumTop }
                GradientStop { position: 1.0; color: Theme.glassMediumBottom }
            }
            border.color: Theme.specularBorder
            border.width: 1
            z: 1

            ColumnLayout {
                id: menuColumn
                anchors.fill: parent
                anchors.margins: 5
                spacing: 2

                // Header to navigate back if inside a submenu
                Rectangle {
                    visible: root.activeMenuHandle !== root.currentTrayItem?.menu && root.activeMenuHandle !== null
                    Layout.fillWidth: true
                    implicitHeight: 26
                    radius: 6
                    color: backMouse.containsMouse ? Theme.surfaceHover : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 6
                        Text {
                            text: "‹"
                            font.pixelSize: 14
                            font.bold: true
                            color: Theme.accentColor
                        }
                        Text {
                            text: "Atrás"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.textSecondary
                        }
                    }

                    MouseArea {
                        id: backMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.activeMenuHandle = root.currentTrayItem?.menu;
                        }
                    }
                }

                // Separator if submenu header is visible
                Rectangle {
                    visible: root.activeMenuHandle !== root.currentTrayItem?.menu && root.activeMenuHandle !== null
                    Layout.fillWidth: true
                    implicitHeight: 1
                    color: Theme.separatorColor
                    Layout.topMargin: 2
                    Layout.bottomMargin: 2
                }

                // Repeater of Menu Entries from DBusMenu
                Repeater {
                    id: menuRepeater
                    model: menuOpener.children

                    delegate: Item {
                        id: entryDelegate
                        required property var modelData

                        Layout.fillWidth: true
                        implicitHeight: modelData?.isSeparator ? 7 : 26

                        // Separator line
                        Rectangle {
                            visible: modelData?.isSeparator === true
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6
                            height: 1
                            color: Theme.separatorColor
                        }

                        // Clickable Item Pill
                        Rectangle {
                            visible: modelData?.isSeparator !== true
                            anchors.fill: parent
                            radius: 6
                            color: entryMouse.containsMouse && modelData?.enabled !== false
                                ? Theme.accentColor
                                : "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 6

                                // Checkmark / Radio indicator
                                Item {
                                    implicitWidth: 14
                                    implicitHeight: 14
                                    Layout.alignment: Qt.AlignVCenter

                                    Text {
                                        anchors.centerIn: parent
                                        visible: modelData?.buttonType !== QsMenuButtonType.None && modelData?.checkState === Qt.Checked
                                        text: "✓"
                                        font.pixelSize: 11
                                        font.bold: true
                                        color: entryMouse.containsMouse ? Theme.bgSolid : Theme.accentColor
                                    }

                                    IconImage {
                                        anchors.centerIn: parent
                                        width: 14
                                        height: 14
                                        visible: (modelData?.icon?.length > 0) && (modelData?.buttonType === QsMenuButtonType.None || modelData?.checkState !== Qt.Checked)
                                        source: modelData?.icon || ""
                                        asynchronous: true
                                    }
                                }

                                // Menu label (clean '&' accelerators like in Qt/GTK)
                                Text {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    text: (modelData?.text || "").replace(/&/g, "")
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.weight: Font.Normal
                                    color: modelData?.enabled === false
                                        ? Theme.textDisabled
                                        : (entryMouse.containsMouse ? Theme.bgSolid : Theme.textPrimary)
                                    elide: Text.ElideRight
                                }

                                // Submenu chevron
                                Text {
                                    visible: modelData?.hasChildren === true
                                    Layout.alignment: Qt.AlignVCenter
                                    text: "›"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: entryMouse.containsMouse ? Theme.bgSolid : Theme.textSecondary
                                }
                            }

                            MouseArea {
                                id: entryMouse
                                anchors.fill: parent
                                enabled: modelData?.isSeparator !== true && modelData?.enabled !== false
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    if (modelData?.hasChildren) {
                                        root.activeMenuHandle = modelData;
                                    } else {
                                        try {
                                            modelData.triggered();
                                        } catch (e) {
                                            console.warn("[TrayMenu] Error triggering entry:", e);
                                        }
                                        root.closeMenu();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
