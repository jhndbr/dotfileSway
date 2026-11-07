import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import "../components"
import "../services"
import ".."

PanelWindow {
    id: dockWindow

    required property var modelData
    screen: modelData

    signal toggleLauncher()

    visible: Config.dockEnabled
    color: "transparent"

    anchors {
        bottom: true
        left: true
        right: true
    }

    // Ample height for parabolic magnification, icon lift and context menus
    implicitHeight: Config.dockHeight + Config.dockMarginBottom + 120

    WlrLayershell.namespace: "swayshell:dock"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // Space reservation for Sway windows (closer gap to dock per user preference)
    exclusiveZone: Config.dockAutoHide ? 0 : (Config.dockHeight + Config.dockMarginBottom - 2)

    // Mask ensures clicks outside the dock container and context menus pass straight to desktop/windows
    mask: Region {
        item: contextMenu.isOpen ? dockWindow.contentItem : (dockRevealed ? dockContainer : edgeTrigger)
    }

    property bool dockRevealed: !Config.dockAutoHide || dockHoverHandler.hovered || edgeHoverHandler.hovered || contextMenu.isOpen

    // Auto-hide delay timer
    Timer {
        id: hideTimer
        interval: 450
        repeat: false
        onTriggered: {
            if (!dockHoverHandler.hovered && !contextMenu.isOpen) {
                dockWindow.dockRevealed = false;
            }
        }
    }

    // Bottom edge trigger when auto-hide is active
    Item {
        id: edgeTrigger
        visible: Config.dockAutoHide && !dockWindow.dockRevealed
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 4

        HoverHandler {
            id: edgeHoverHandler
            onHoveredChanged: {
                if (hovered) dockWindow.dockRevealed = true;
            }
        }
    }

    // Dual subtle ambient drop shadows underneath the dock pill (macOS Elevation)
    Rectangle {
        id: dockShadowDeep
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: dockContainer.anchors.bottomMargin - 6
        width: dockContainer.width + 16
        height: dockContainer.height + 8
        radius: Theme.dockRadius + 6
        color: Qt.rgba(0, 0, 0, 0.22)
        visible: dockWindow.dockRevealed
        z: 0
    }

    Rectangle {
        id: dockShadow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: dockContainer.anchors.bottomMargin - 2
        width: dockContainer.width + 6
        height: dockContainer.height + 4
        radius: Theme.dockRadius + 3
        color: Qt.rgba(0, 0, 0, 0.38)
        visible: dockWindow.dockRevealed
        z: 1
    }

    // Main Floating Glass Dock Pill (Apple Liquid Glass Transparente)
    Rectangle {
        id: dockContainer
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: dockWindow.dockRevealed ? Config.dockMarginBottom : -(Config.dockHeight + 30)

        width: dockLayout.implicitWidth + Theme.dockPadding * 2 + 8
        height: Config.dockHeight
        radius: Theme.dockRadius

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: Theme.glassDock
            }
            GradientStop {
                position: 1.0
                color: Qt.darker(Theme.glassDock, 1.15)
            }
        }

        border.color: Theme.specularBorder
        border.width: 1
        z: 10

        Behavior on anchors.bottomMargin {
            NumberAnimation { duration: Theme.animNormal; easing.type: Theme.animEasing }
        }

        // Global Dock Hover Handler
        HoverHandler {
            id: dockHoverHandler
            onHoveredChanged: {
                if (hovered) {
                    hideTimer.stop();
                    dockWindow.dockRevealed = true;
                } else if (Config.dockAutoHide && !contextMenu.isOpen) {
                    hideTimer.restart();
                }
            }
        }

        RowLayout {
            id: dockLayout
            anchors.centerIn: parent
            spacing: Theme.dockSpacing

            // ------------------------------------------
            // Launchpad Button
            // ------------------------------------------
            Item {
                id: launchpadBtn
                implicitWidth: Config.dockHeight - 12
                implicitHeight: Config.dockHeight - 12

                readonly property real centerX: dockLayout.x + x + width / 2
                readonly property real dist: Math.abs(dockHoverHandler.point.position.x - centerX)
                readonly property real zoomFactor: {
                    if (!dockHoverHandler.hovered || !Config.dockMagnification || contextMenu.isOpen) return 1.0;
                    const maxDist = 135;
                    if (dist >= maxDist) return 1.0;
                    return 1.0 + Math.cos((dist / maxDist) * (Math.PI / 2)) * 0.42;
                }

                property real bounceY: 0
                z: zoomFactor > 1.02 ? Math.round(zoomFactor * 100) : 1

                SequentialAnimation {
                    id: lpBounceAnim
                    loops: 2
                    NumberAnimation { target: launchpadBtn; property: "bounceY"; to: -16; duration: 120; easing.type: Easing.OutQuad }
                    NumberAnimation { target: launchpadBtn; property: "bounceY"; to: 0; duration: 130; easing.type: Easing.InQuad }
                }

                // ONLY the icon zooms and lifts (no rectangular frame background)
                Item {
                    id: lpIconContainer
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height

                    scale: launchpadBtn.zoomFactor
                    y: launchpadBtn.bounceY - (launchpadBtn.zoomFactor - 1.0) * 14
                    transformOrigin: Item.Bottom

                    Behavior on scale {
                        NumberAnimation { duration: 90; easing.type: Easing.OutQuad }
                    }
                    Behavior on y {
                        NumberAnimation { duration: 90; easing.type: Easing.OutQuad }
                    }

                    Icon {
                        anchors.centerIn: parent
                        size: Config.dockIconSize - 2
                        glyph: "󰀻"
                        color: Theme.accent
                    }
                }

                MouseArea {
                    id: lpMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        lpBounceAnim.restart();
                        dockWindow.toggleLauncher();
                    }
                }

                // Tooltip with downward arrow
                Item {
                    id: lpTooltip
                    visible: Config.dockShowTooltips && lpMouse.containsMouse && !contextMenu.isOpen
                    anchors.bottom: parent.top
                    anchors.bottomMargin: 14
                    anchors.horizontalCenter: parent.horizontalCenter
                    implicitWidth: lpBadge.implicitWidth
                    implicitHeight: lpBadge.implicitHeight + 4
                    z: 500

                    Rectangle {
                        id: lpBadge
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        implicitWidth: lpText.implicitWidth + 18
                        implicitHeight: 24
                        radius: 6
                        color: Theme.glassMediumTop
                        border.color: Theme.specularBorder
                        border.width: 1

                        Text {
                            id: lpText
                            anchors.centerIn: parent
                            text: "Launchpad"
                            color: "#ffffff"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.bold: true
                        }
                    }

                    // Caret triangle pointing down
                    Rectangle {
                        anchors.top: lpBadge.bottom
                        anchors.topMargin: -3
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 7
                        height: 7
                        rotation: 45
                        color: Theme.glassMediumTop
                        border.color: Theme.specularBorder
                        border.width: 1
                    }
                }
            }

            // ------------------------------------------
            // Separator 1
            // ------------------------------------------
            Rectangle {
                implicitWidth: 1
                implicitHeight: Config.dockHeight - 22
                color: Theme.separator
            }

            // ------------------------------------------
            // Applications Repeater
            // ------------------------------------------
            Repeater {
                id: appsRepeater
                model: DockService.items

                delegate: Item {
                    id: appItem
                    required property var modelData
                    required property int index

                    implicitWidth: Config.dockHeight - 12
                    implicitHeight: Config.dockHeight - 12

                    readonly property real itemCenterX: dockLayout.x + x + width / 2
                    readonly property real distToCursor: Math.abs(dockHoverHandler.point.position.x - itemCenterX)
                    readonly property real magScale: {
                        if (!dockHoverHandler.hovered || !Config.dockMagnification || contextMenu.isOpen) return 1.0;
                        const maxDist = 135;
                        if (distToCursor >= maxDist) return 1.0;
                        return 1.0 + Math.cos((distToCursor / maxDist) * (Math.PI / 2)) * 0.44;
                    }

                    property real bounceY: 0
                    z: magScale > 1.02 ? Math.round(magScale * 100) : 1

                    SequentialAnimation {
                        id: bounceAnim
                        loops: 2
                        NumberAnimation { target: appItem; property: "bounceY"; to: -18; duration: 120; easing.type: Easing.OutQuad }
                        NumberAnimation { target: appItem; property: "bounceY"; to: 0; duration: 130; easing.type: Easing.InQuad }
                    }

                    readonly property string resolvedIconPath: {
                        const iconVal = modelData.icon || "";
                        if (iconVal.startsWith("/") || iconVal.startsWith("file://")) {
                            return iconVal.startsWith("file://") ? iconVal : "file://" + iconVal;
                        }
                        let p = Quickshell.iconPath(iconVal, "");
                        if (!p && modelData.appId) {
                            p = Quickshell.iconPath(modelData.appId, "");
                        }
                        if (!p) {
                            p = Quickshell.iconPath("application-x-executable", "");
                        }
                        return p ? (p.startsWith("/") ? "file://" + p : p) : "";
                    }

                    // ONLY the icon zooms and lifts (no rectangular frame background)
                    Item {
                        id: appIconContainer
                        anchors.centerIn: parent
                        width: parent.width
                        height: parent.height

                        scale: appItem.magScale
                        y: appItem.bounceY - (appItem.magScale - 1.0) * 15
                        transformOrigin: Item.Bottom

                        Behavior on scale {
                            NumberAnimation { duration: 90; easing.type: Easing.OutQuad }
                        }
                        Behavior on y {
                            NumberAnimation { duration: 90; easing.type: Easing.OutQuad }
                        }

                        // High resolution, crystal-clear crisp icon image (rasterized at 160x160 for high-DPI)
                        Image {
                            id: appImg
                            anchors.centerIn: parent
                            width: Config.dockIconSize
                            height: Config.dockIconSize
                            sourceSize: Qt.size(160, 160)
                            source: appItem.resolvedIconPath
                            visible: appItem.resolvedIconPath.length > 0 && status === Image.Ready
                            asynchronous: true
                            smooth: true
                            mipmap: true
                            fillMode: Image.PreserveAspectFit
                        }

                        // Fallback icon glyph
                        Text {
                            anchors.centerIn: parent
                            visible: !appImg.visible || appItem.resolvedIconPath.length === 0
                            text: "󰣆"
                            color: Theme.accent
                            font.pixelSize: Config.dockIconSize - 6
                            font.family: Theme.fontIcons
                        }
                    }

                    // macOS Glowing LED Running Indicator (stays at dock baseline)
                    Rectangle {
                        id: indicatorDot
                        visible: modelData.isRunning
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        implicitHeight: 4
                        implicitWidth: modelData.isFocused ? 14 : 4
                        radius: 2
                        color: modelData.isFocused ? Theme.accent : Qt.rgba(255, 255, 255, 0.75)

                        Behavior on implicitWidth {
                            NumberAnimation { duration: Theme.animFast; easing.type: Theme.animEasing }
                        }
                        Behavior on color {
                            ColorAnimation { duration: Theme.animFast }
                        }
                    }

                    MouseArea {
                        id: appMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                        onClicked: (mouse) => {
                            if (mouse.button === Qt.LeftButton) {
                                bounceAnim.restart();
                                DockService.activateApp(modelData);
                            } else if (mouse.button === Qt.MiddleButton) {
                                bounceAnim.restart();
                                DockService.launchNewInstance(modelData);
                            } else if (mouse.button === Qt.RightButton) {
                                contextMenu.openFor(modelData, appItem);
                            }
                        }
                    }

                    // Tooltip with caret (disabled when dockShowTooltips is false)
                    Item {
                        visible: Config.dockShowTooltips && appMouse.containsMouse && !contextMenu.isOpen
                        anchors.bottom: parent.top
                        anchors.bottomMargin: 14
                        anchors.horizontalCenter: parent.horizontalCenter
                        implicitWidth: tipBadge.implicitWidth
                        implicitHeight: tipBadge.implicitHeight + 4
                        z: 500

                        Rectangle {
                            id: tipBadge
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            implicitWidth: tipText.implicitWidth + 18
                            implicitHeight: 24
                            radius: 6
                            color: Theme.glassMediumTop
                            border.color: Theme.specularBorder
                            border.width: 1

                            Text {
                                id: tipText
                                anchors.centerIn: parent
                                text: modelData.name
                                color: "#ffffff"
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                font.bold: true
                            }
                        }

                        // Caret triangle
                        Rectangle {
                            anchors.top: tipBadge.bottom
                            anchors.topMargin: -3
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 7
                            height: 7
                            rotation: 45
                            color: Theme.glassMediumTop
                            border.color: Theme.specularBorder
                            border.width: 1
                        }
                    }
                }
            }

            // ------------------------------------------
            // Separator 2
            // ------------------------------------------
            Rectangle {
                implicitWidth: 1
                implicitHeight: Config.dockHeight - 22
                color: Theme.separator
            }

            // ------------------------------------------
            // Trash / Files Button
            // ------------------------------------------
            Item {
                id: trashBtn
                implicitWidth: Config.dockHeight - 12
                implicitHeight: Config.dockHeight - 12

                readonly property real trashCenterX: dockLayout.x + x + width / 2
                readonly property real distTrash: Math.abs(dockHoverHandler.point.position.x - trashCenterX)
                readonly property real zoomTrash: {
                    if (!dockHoverHandler.hovered || !Config.dockMagnification || contextMenu.isOpen) return 1.0;
                    const maxDist = 135;
                    if (distTrash >= maxDist) return 1.0;
                    return 1.0 + Math.cos((distTrash / maxDist) * (Math.PI / 2)) * 0.42;
                }

                property real bounceY: 0
                z: zoomTrash > 1.02 ? Math.round(zoomTrash * 100) : 1

                SequentialAnimation {
                    id: trashBounceAnim
                    loops: 2
                    NumberAnimation { target: trashBtn; property: "bounceY"; to: -16; duration: 120; easing.type: Easing.OutQuad }
                    NumberAnimation { target: trashBtn; property: "bounceY"; to: 0; duration: 130; easing.type: Easing.InQuad }
                }

                readonly property string trashIconPath: {
                    const p = Quickshell.iconPath("user-trash", "");
                    return p ? (p.startsWith("/") ? "file://" + p : p) : "";
                }

                // ONLY the icon zooms and lifts (no rectangular frame background)
                Item {
                    id: trashIconContainer
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height

                    scale: trashBtn.zoomTrash
                    y: trashBtn.bounceY - (trashBtn.zoomTrash - 1.0) * 14
                    transformOrigin: Item.Bottom

                    Behavior on scale {
                        NumberAnimation { duration: 90; easing.type: Easing.OutQuad }
                    }
                    Behavior on y {
                        NumberAnimation { duration: 90; easing.type: Easing.OutQuad }
                    }

                    Image {
                        id: trashImg
                        anchors.centerIn: parent
                        width: Config.dockIconSize - 2
                        height: Config.dockIconSize - 2
                        sourceSize: Qt.size(160, 160)
                        source: trashBtn.trashIconPath
                        visible: trashBtn.trashIconPath.length > 0 && status === Image.Ready
                        asynchronous: true
                        smooth: true
                        mipmap: true
                        fillMode: Image.PreserveAspectFit
                    }

                    Icon {
                        anchors.centerIn: parent
                        visible: !trashImg.visible || trashBtn.trashIconPath.length === 0
                        size: Config.dockIconSize - 2
                        glyph: "󰩹"
                        color: Theme.textMuted
                    }
                }

                MouseArea {
                    id: trashMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        trashBounceAnim.restart();
                        SwayService.exec("nautilus trash:///");
                    }
                }

                // Tooltip
                Item {
                    visible: Config.dockShowTooltips && trashMouse.containsMouse && !contextMenu.isOpen
                    anchors.bottom: parent.top
                    anchors.bottomMargin: 14
                    anchors.horizontalCenter: parent.horizontalCenter
                    implicitWidth: trashBadge.implicitWidth
                    implicitHeight: trashBadge.implicitHeight + 4
                    z: 500

                    Rectangle {
                        id: trashBadge
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        implicitWidth: trashText.implicitWidth + 18
                        implicitHeight: 24
                        radius: 6
                        color: Theme.glassMediumTop
                        border.color: Theme.specularBorder
                        border.width: 1

                        Text {
                            id: trashText
                            anchors.centerIn: parent
                            text: "Papelera"
                            color: "#ffffff"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.bold: true
                        }
                    }

                    Rectangle {
                        anchors.top: trashBadge.bottom
                        anchors.topMargin: -3
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 7
                        height: 7
                        rotation: 45
                        color: Theme.glassMediumTop
                        border.color: Theme.specularBorder
                        border.width: 1
                    }
                }
            }
        }
    }

    // ==========================================
    // macOS Dock Context Menu Card (Liquid Glass Transparente)
    // ==========================================
    Rectangle {
        id: contextMenu

        property bool isOpen: false
        property var activeAppItem: null
        property var activeTargetItem: null

        visible: isOpen
        z: 999
        width: 190
        implicitHeight: menuCol.implicitHeight + 16
        radius: Theme.radiusMd

        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.glassMediumTop }
            GradientStop { position: 1.0; color: Theme.glassMediumBottom }
        }
        border.color: Theme.specularBorder
        border.width: 1

        function openFor(itemData, target) {
            activeAppItem = itemData;
            activeTargetItem = target;
            if (target) {
                const globalPos = target.mapToItem(dockWindow.contentItem, 0, 0);
                x = Math.max(10, Math.min(dockWindow.width - width - 10, globalPos.x + target.width / 2 - width / 2));
                y = globalPos.y - height - 12;
            }
            isOpen = true;
        }

        function close() {
            isOpen = false;
            activeAppItem = null;
            activeTargetItem = null;
        }

        ColumnLayout {
            id: menuCol
            anchors.fill: parent
            anchors.margins: 6
            spacing: 2

            // App Name Header
            Item {
                Layout.fillWidth: true
                implicitHeight: 22
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: contextMenu.activeAppItem ? contextMenu.activeAppItem.name : ""
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                    color: Theme.labelPrimary
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Theme.separator
            }

            // "Abrir nueva ventana"
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 26
                radius: 6
                color: miNewMouse.containsMouse ? Theme.accentColor : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    spacing: 8
                    Icon { glyph: "󰄲"; size: 12; color: miNewMouse.containsMouse ? "#ffffff" : Theme.labelPrimary }
                    Text {
                        text: "Nueva ventana"
                        color: miNewMouse.containsMouse ? "#ffffff" : Theme.labelPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }
                MouseArea {
                    id: miNewMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (contextMenu.activeAppItem) {
                            DockService.launchNewInstance(contextMenu.activeAppItem);
                        }
                        contextMenu.close();
                    }
                }
            }

            // "Mantener en el Dock"
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 26
                radius: 6
                color: miPinMouse.containsMouse ? Theme.accentColor : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    spacing: 8
                    Icon {
                        glyph: (contextMenu.activeAppItem && contextMenu.activeAppItem.isPinned) ? "󰄲" : "󰄱"
                        size: 12
                        color: miPinMouse.containsMouse ? "#ffffff" : Theme.accentColor
                    }
                    Text {
                        text: (contextMenu.activeAppItem && contextMenu.activeAppItem.isPinned) ? "Desanclar del Dock" : "Mantener en el Dock"
                        color: miPinMouse.containsMouse ? "#ffffff" : Theme.labelPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }
                MouseArea {
                    id: miPinMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (contextMenu.activeAppItem) {
                            DockService.togglePin(contextMenu.activeAppItem.appId);
                        }
                        contextMenu.close();
                    }
                }
            }

            // "Cerrar" (si está corriendo)
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 26
                radius: 6
                visible: contextMenu.activeAppItem ? contextMenu.activeAppItem.isRunning : false
                color: miCloseMouse.containsMouse ? Theme.systemRed : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    spacing: 8
                    Icon { glyph: "󰅖"; size: 12; color: miCloseMouse.containsMouse ? "#ffffff" : Theme.systemRed }
                    Text {
                        text: "Cerrar aplicación"
                        color: miCloseMouse.containsMouse ? "#ffffff" : Theme.systemRed
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }
                MouseArea {
                    id: miCloseMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (contextMenu.activeAppItem) {
                            DockService.closeApp(contextMenu.activeAppItem);
                        }
                        contextMenu.close();
                    }
                }
            }
        }
    }
}
