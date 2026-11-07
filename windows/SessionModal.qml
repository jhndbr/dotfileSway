import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../components"
import "../services"
import ".."

PanelWindow {
    id: sessionWindow

    property bool isOpen: false

    visible: isOpen
    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "swayshell:session"
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // Click outside to dismiss
    MouseArea {
        anchors.fill: parent
        onClicked: {
            sessionWindow.isOpen = false;
        }
    }

    Item {
        anchors.fill: parent
        focus: sessionWindow.isOpen

        Keys.onEscapePressed: {
            sessionWindow.isOpen = false;
        }
    }

    function executeAction(action) {
        sessionWindow.isOpen = false;
        if (action === "about") {
            SwayService.exec("foot -e sh -c 'fastfetch 2>/dev/null || neofetch 2>/dev/null || uname -a; read -p \"Presione enter para salir...\"'");
        } else if (action === "settings") {
            SwayService.exec("kdesystemsettings 2>/dev/null || systemsettings 2>/dev/null || gnome-control-center 2>/dev/null");
        } else if (action === "lock") {
            SwayService.exec("swaylock -f -c 1e1e2e");
        } else if (action === "logout") {
            SwayService.exitSway();
        } else if (action === "suspend") {
            SwayService.exec("systemctl suspend");
        } else if (action === "reboot") {
            SwayService.exec("systemctl reboot");
        } else if (action === "shutdown") {
            SwayService.exec("systemctl poweroff");
        }
    }

    // Authentic Linux / Distro Menu Dropdown (Liquid Glass Transparente)
    Rectangle {
        id: menuCard
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 2
        anchors.leftMargin: 6
        width: 220
        implicitHeight: menuCol.implicitHeight + 12
        radius: Theme.radiusMd

        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.glassMediumTop }
            GradientStop { position: 1.0; color: Theme.glassMediumBottom }
        }
        border.color: Theme.specularBorder
        border.width: 1

        opacity: sessionWindow.isOpen ? 1 : 0
        scale: sessionWindow.isOpen ? 1 : 0.95
        transformOrigin: Item.TopLeft

        Behavior on opacity {
            NumberAnimation { duration: Theme.animFast; easing.type: Theme.animEasing }
        }
        Behavior on scale {
            NumberAnimation { duration: Theme.animFast; easing.type: Theme.animEasing }
        }

        ColumnLayout {
            id: menuCol
            anchors.fill: parent
            anchors.margins: 6
            spacing: 2

            component AppleMenuItem: Rectangle {
                id: itemRoot
                property string itemTitle: ""
                property string itemIcon: ""
                property string itemKey: ""
                property color itemColor: Theme.labelPrimary
                signal triggered()

                Layout.fillWidth: true
                implicitHeight: 28
                radius: 6
                color: itemMouse.containsMouse ? Theme.accentColor : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 8

                    Icon {
                        glyph: itemRoot.itemIcon
                        size: 13
                        color: itemMouse.containsMouse ? "#ffffff" : itemRoot.itemColor
                    }

                    Text {
                        Layout.fillWidth: true
                        text: itemRoot.itemTitle
                        color: itemMouse.containsMouse ? "#ffffff" : Theme.labelPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Font.Medium
                    }

                    Text {
                        text: itemRoot.itemKey
                        color: itemMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.7) : Theme.labelTertiary
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        visible: itemRoot.itemKey.length > 0
                    }
                }

                MouseArea {
                    id: itemMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        itemRoot.triggered();
                    }
                }
            }

            AppleMenuItem {
                itemTitle: "Acerca de este equipo"
                itemIcon: "󰀵"
                onTriggered: sessionWindow.executeAction("about")
            }

            AppleMenuItem {
                itemTitle: "Ajustes del Sistema..."
                itemIcon: "󰒓"
                onTriggered: sessionWindow.executeAction("settings")
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Theme.separator
            }

            AppleMenuItem {
                itemTitle: "Bloquear pantalla"
                itemIcon: "󰌾"
                itemKey: "Ctrl+Cmd+Q"
                onTriggered: sessionWindow.executeAction("lock")
            }

            AppleMenuItem {
                itemTitle: "Cerrar sesión..."
                itemIcon: "󰗽"
                onTriggered: sessionWindow.executeAction("logout")
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Theme.separator
            }

            AppleMenuItem {
                itemTitle: "Reiniciar..."
                itemIcon: "󰑐"
                onTriggered: sessionWindow.executeAction("reboot")
            }

            AppleMenuItem {
                itemTitle: "Apagar equipo..."
                itemIcon: "󰐥"
                itemColor: Theme.danger
                onTriggered: sessionWindow.executeAction("shutdown")
            }
        }
    }
}
