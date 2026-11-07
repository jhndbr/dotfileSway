import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import "../components"
import "../services"
import ".."

PanelWindow {
    id: launcherWindow

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
    WlrLayershell.namespace: "swayshell:launcher"
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // Filter desktop entries
    readonly property var allApps: DesktopEntries.applications.values || []

    readonly property var filteredApps: {
        const q = query.toLowerCase().trim();
        if (q.length === 0) {
            return allApps.slice(0, Config.launcherMaxResults || 8);
        }
        const matches = [];
        for (let i = 0; i < allApps.length; i++) {
            const app = allApps[i];
            const name = (app.name || "").toLowerCase();
            const comment = (app.comment || "").toLowerCase();
            const generic = (app.genericName || "").toLowerCase();
            const id = (app.id || "").toLowerCase();
            if (name.includes(q) || comment.includes(q) || generic.includes(q) || id.includes(q)) {
                matches.push(app);
                if (matches.length >= (Config.launcherMaxResults || 8)) break;
            }
        }
        return matches;
    }

    onIsOpenChanged: {
        if (isOpen) {
            query = "";
            selectedIndex = 0;
            searchInput.text = "";
            searchInput.forceActiveFocus();
        }
    }

    function launchSelected() {
        if (filteredApps.length > 0 && selectedIndex >= 0 && selectedIndex < filteredApps.length) {
            const app = filteredApps[selectedIndex];
            if (app) {
                try {
                    if (typeof app.execute === "function") {
                        app.execute();
                    } else if (app.commandLine) {
                        SwayService.exec(app.commandLine);
                    } else if (app.exec) {
                        SwayService.exec(app.exec);
                    }
                } catch (e) {
                    console.warn("[Launcher] Failed to execute:", e);
                    if (app.commandLine) {
                        SwayService.exec(app.commandLine);
                    }
                }
            }
        }
        isOpen = false;
    }

    // Semi-transparent macOS Dimmed backdrop
    Rectangle {
        anchors.fill: parent
        color: isOpen ? Qt.rgba(0, 0, 0, 0.45) : "transparent"

        Behavior on color {
            ColorAnimation { duration: Theme.animNormal }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                launcherWindow.isOpen = false;
            }
        }
    }

    // Floating macOS Spotlight Window
    Rectangle {
        id: modalCard
        width: Math.min(540, parent.width - 32)
        implicitHeight: contentCol.implicitHeight + 20
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.16
        radius: Theme.cardRadius

        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.glassMediumTop }
            GradientStop { position: 1.0; color: Theme.glassMediumBottom }
        }
        border.color: Theme.specularBorder
        border.width: 1

        opacity: launcherWindow.isOpen ? 1 : 0
        scale: launcherWindow.isOpen ? 1 : 0.97

        Behavior on opacity {
            NumberAnimation { duration: Theme.animFast; easing.type: Theme.animEasing }
        }
        Behavior on scale {
            NumberAnimation { duration: Theme.animFast; easing.type: Theme.animEasing }
        }

        // Prevent click dismissal inside card
        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        ColumnLayout {
            id: contentCol
            anchors.fill: parent
            anchors.margins: 10
            spacing: 6

            // Spotlight Search Bar
            RowLayout {
                Layout.fillWidth: true
                implicitHeight: 42
                spacing: 10

                Icon {
                    glyph: "󰍉"
                    color: Theme.accentColor
                    size: 16
                    Layout.alignment: Qt.AlignVCenter
                }

                TextInput {
                    id: searchInput
                    Layout.fillWidth: true
                    text: launcherWindow.query
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 15
                    font.weight: Font.Normal
                    clip: true
                    verticalAlignment: TextInput.AlignVCenter

                    onTextChanged: {
                        launcherWindow.query = text;
                        launcherWindow.selectedIndex = 0;
                    }

                    Keys.onEscapePressed: {
                        launcherWindow.isOpen = false;
                    }

                    Keys.onReturnPressed: {
                        launcherWindow.launchSelected();
                    }

                    Keys.onDownPressed: {
                        if (launcherWindow.filteredApps.length > 0) {
                            launcherWindow.selectedIndex = (launcherWindow.selectedIndex + 1) % launcherWindow.filteredApps.length;
                        }
                    }

                    Keys.onUpPressed: {
                        if (launcherWindow.filteredApps.length > 0) {
                            launcherWindow.selectedIndex = (launcherWindow.selectedIndex - 1 + launcherWindow.filteredApps.length) % launcherWindow.filteredApps.length;
                        }
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Buscar en Spotlight..."
                        color: Theme.textDisabledColor
                        font.family: Theme.fontFamily
                        font.pixelSize: 15
                        visible: parent.text.length === 0 && !parent.activeFocus
                    }
                }

                // Clear button when query exists
                Rectangle {
                    visible: launcherWindow.query.length > 0
                    implicitWidth: 16
                    implicitHeight: 16
                    radius: 8
                    color: Theme.surfaceHover

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: Theme.textSecondary
                        font.pixelSize: 9
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            launcherWindow.query = "";
                            searchInput.text = "";
                            searchInput.forceActiveFocus();
                        }
                    }
                }

                // Shortcut Hint badge: "esc"
                Rectangle {
                    implicitWidth: 32
                    implicitHeight: 20
                    radius: 4
                    color: Theme.surface
                    border.color: Theme.borderColor
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "esc"
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.Medium
                    }
                }
            }

            // Subtle divider line
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Theme.separatorColor
            }

            // Spotlight Results List
            ListView {
                id: resultsList
                Layout.fillWidth: true
                implicitHeight: Math.min(320, contentHeight)
                clip: true
                spacing: 2
                model: launcherWindow.filteredApps

                delegate: Rectangle {
                    id: resultItem
                    required property var modelData
                    required property int index

                    readonly property bool isSelected: index === launcherWindow.selectedIndex

                    width: resultsList.width
                    implicitHeight: 38
                    radius: 6

                    color: isSelected ? Theme.accentColor : (itemMouse.containsMouse ? Theme.surfaceHover : "transparent")

                    Behavior on color {
                        ColorAnimation { duration: Theme.animFast }
                    }

                    readonly property string resolvedAppIcon: {
                        const iconVal = modelData.icon || modelData.id || "";
                        if (iconVal.startsWith("/") || iconVal.startsWith("file://")) {
                            return iconVal.startsWith("file://") ? iconVal : "file://" + iconVal;
                        }
                        const p = Quickshell.iconPath(iconVal, "application-x-executable");
                        return p ? (p.startsWith("/") ? "file://" + p : p) : iconVal;
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 10

                        // Compact, refined icon (24x24 px)
                        Item {
                            implicitWidth: 24
                            implicitHeight: 24
                            Layout.alignment: Qt.AlignVCenter

                            IconImage {
                                id: appIconImg
                                anchors.centerIn: parent
                                width: 24
                                height: 24
                                source: resultItem.resolvedAppIcon
                                visible: resultItem.resolvedAppIcon.length > 0 && status === Image.Ready
                                asynchronous: true
                                smooth: true
                            }

                            // Fallback glyph
                            Text {
                                anchors.centerIn: parent
                                visible: !appIconImg.visible
                                text: "󰣆"
                                font.family: Theme.fontIcons
                                font.pixelSize: 16
                                color: resultItem.isSelected ? "#ffffff" : Theme.accentColor
                            }
                        }

                        // App Title & Description / Category
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                Layout.fillWidth: true
                                text: modelData.name || "Aplicación"
                                color: resultItem.isSelected ? "#ffffff" : Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                text: modelData.comment || modelData.genericName || modelData.id || ""
                                color: resultItem.isSelected ? Qt.rgba(1, 1, 1, 0.75) : Theme.textSecondary
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                elide: Text.ElideRight
                                visible: text.length > 0
                            }
                        }

                        // Return key badge on selected item
                        Rectangle {
                            visible: resultItem.isSelected
                            implicitWidth: 20
                            implicitHeight: 18
                            radius: 3
                            color: Qt.rgba(0, 0, 0, 0.20)
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                anchors.centerIn: parent
                                text: "↵"
                                color: "#ffffff"
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton

                        onClicked: (mouse) => {
                            if (mouse.button === Qt.RightButton) {
                                const appId = modelData.id || modelData.exec || "";
                                if (appId) {
                                    DockService.togglePin(appId);
                                }
                            } else {
                                launcherWindow.selectedIndex = resultItem.index;
                                launcherWindow.launchSelected();
                            }
                        }
                    }
                }
            }
        }
    }
}
