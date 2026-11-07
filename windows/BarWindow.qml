import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../components"
import "../widgets"
import "../services"
import ".."

PanelWindow {
    id: barWindow

    // Per-monitor shell screen
    required property var modelData
    screen: modelData

    signal toggleLauncher()
    signal toggleSession()
    signal toggleCalendar()
    signal toggleClipboard()
    signal toggleControlCenter()
    signal toggleAiChat()
    signal toggleMedia()

    property bool isControlCenterOpen: false
    property bool isCalendarOpen: false

    anchors {
        top: Config.barPosition === "top"
        bottom: Config.barPosition === "bottom"
        left: true
        right: true
    }

    margins {
        top: Config.floatingBar && Config.barPosition === "top" ? (Config.barMarginVertical || 6) : 0
        bottom: Config.floatingBar && Config.barPosition === "bottom" ? (Config.barMarginVertical || 6) : 0
        left: Config.floatingBar ? (Config.barMarginHorizontal || 12) : 0
        right: Config.floatingBar ? (Config.barMarginHorizontal || 12) : 0
    }

    exclusionMode: ExclusionMode.Normal
    exclusiveZone: Config.barHeight + (Config.floatingBar ? (Config.barMarginVertical || 6) : 0)
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "swayshell:bar"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.exclusiveZone: Config.barHeight + (Config.floatingBar ? (Config.barMarginVertical || 6) : 0)

    color: "transparent"
    implicitHeight: Config.barHeight

    // Main macOS style Liquid Glass Menubar container (Sin Blur - Transparencia Pura)
    Rectangle {
        id: barBackground
        anchors.fill: parent
        radius: Config.floatingBar ? Theme.radiusMd : 0

        // Gradiente refractivo vertical con canal alfa calibrado
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: Theme.glassBarTop
            }
            GradientStop {
                position: 1.0
                color: Theme.glassBarBottom
            }
        }

        border.color: Config.floatingBar ? Theme.specularBorder : "transparent"
        border.width: Config.floatingBar ? 1 : 0

        // Micro-bisel especular superior (Plus Lighter rim de 1px)
        Rectangle {
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.horizontalCenter: parent.horizontalCenter
            width: Config.floatingBar ? Math.max(0, parent.width - parent.radius * 1.1) : parent.width
            height: 1
            color: Theme.specularTopRim
            antialiasing: true
        }

        // Divisor inferior sutil delimitador (auténtico macOS)
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: Theme.separator
            visible: !Config.floatingBar
        }

        // ==========================================
        // Left Section: System Logo + Active App Name
        // ==========================================
        RowLayout {
            anchors.left: parent.left
            anchors.leftMargin: Config.floatingBar ? 12 : 10
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            // Botón del Sistema (Apple / Distro Logo) con cápsula Liquid Glass
            Rectangle {
                id: logoPill
                implicitWidth: 26
                implicitHeight: Config.barHeight - 6
                radius: height / 2
                color: logoMouse.pressed ? Theme.fillSecondary : (logoMouse.containsMouse ? Theme.fillPrimary : "transparent")
                border.color: (logoMouse.containsMouse || logoMouse.pressed) ? Theme.specularBorderHover : "transparent"
                border.width: 1

                Behavior on color {
                    ColorAnimation { duration: Theme.animFast }
                }

                Icon {
                    anchors.centerIn: parent
                    glyph: Config.distroLogoIcon || "󰌽"
                    color: logoMouse.containsMouse ? Theme.accentColor : Theme.labelPrimary
                    size: 14
                    scale: logoMouse.pressed ? 0.92 : (logoMouse.containsMouse ? 1.08 : 1.0)

                    Behavior on scale {
                        NumberAnimation { duration: Theme.animFast; easing.type: Theme.animEasing }
                    }
                    Behavior on color {
                        ColorAnimation { duration: Theme.animFast }
                    }
                }

                MouseArea {
                    id: logoMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        barWindow.toggleSession();
                    }
                }
            }

            // Título de la App Activa (macOS App Menubar style)
            MacAppTitleWidget {
                visible: Config.showFocusedWindow
            }
        }

        // ==========================================
        // Center Section: Sway Workspaces (Centered)
        // ==========================================
        Item {
            anchors.centerIn: parent
            implicitWidth: spacesWidget.implicitWidth
            implicitHeight: spacesWidget.implicitHeight

            MacSpacesWidget {
                id: spacesWidget
                anchors.centerIn: parent
                visible: Config.showWorkspaces
            }
        }

        // ==========================================
        // Right Section: Status Cluster + Clock + AI + Control Center
        // ==========================================
        RowLayout {
            anchors.right: parent.right
            anchors.rightMargin: Config.floatingBar ? 12 : 10
            anchors.verticalCenter: parent.verticalCenter
            spacing: 5

            // Media Player Widget
            MediaWidget {
                visible: Config.showMedia
                onOpenMediaModal: barWindow.toggleMedia()
            }

            // Unified Tray Module
            TrayWidget {
                visible: Config.showTray
            }

            // Battery Percentage & Status Widget
            BatteryWidget {
                visible: Config.showBattery && BatteryService.available
            }

            // Date & Time (Clicking opens Calendar Modal)
            ClockWidget {
                visible: Config.showClock
                isActive: barWindow.isCalendarOpen
                onClockClicked: {
                    barWindow.toggleCalendar();
                }
            }

            // AI Assistant Button (Positioned between Clock and Control Center)
            AiWidget {
                visible: Config.showAiChat
                onAiClicked: barWindow.toggleAiChat()
            }

            // Dedicated macOS Control Center Button (Sliders Icon)
            MacControlCenterButton {
                visible: Config.showControlCenter
                isActive: barWindow.isControlCenterOpen
                onClicked: {
                    barWindow.toggleControlCenter();
                }
            }
        }
    }
}
