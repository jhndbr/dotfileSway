import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import "../components"
import "../services"
import ".."

PanelWindow {
    id: ccWindow

    property bool isOpen: false

    visible: isOpen
    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "swayshell:controlcenter"
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    // Dismiss on click outside
    MouseArea {
        anchors.fill: parent
        onClicked: {
            ccWindow.isOpen = false;
        }
    }

    // Soft floating drop shadow behind Control Center card
    Rectangle {
        id: ccShadow
        anchors.fill: ccCard
        anchors.margins: -4
        anchors.topMargin: -1
        anchors.bottomMargin: -6
        radius: Theme.cardRadius + 4
        color: Qt.rgba(0, 0, 0, 0.35)
        z: 0
    }

    // Main Floating Control Center Card (immediately below top bar)
    Rectangle {
        id: ccCard
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 2
        anchors.rightMargin: 8
        width: 340
        implicitHeight: cardContent.implicitHeight + 24
        radius: Theme.cardRadius

        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.glassMediumTop }
            GradientStop { position: 1.0; color: Theme.glassMediumBottom }
        }
        border.color: Theme.specularBorder
        border.width: 1

        // Prevent click-through dismissal
        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        ColumnLayout {
            id: cardContent
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            // ------------------------------------------
            // Top Section: macOS 2-Column Cluster (Connectivity + Focus/Night Shift)
            // ------------------------------------------
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                // Left Column: Unified Connectivity Card (Wi-Fi & Bluetooth)
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 124
                    radius: Theme.radiusMd
                    color: Theme.fillTertiary
                    border.color: Theme.specularBorder
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 0

                        // Wi-Fi Row
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 4
                                anchors.rightMargin: 6
                                spacing: 10

                                Rectangle {
                                    implicitWidth: 32
                                    implicitHeight: 32
                                    radius: 16
                                    color: NetworkService.connected ? Theme.systemBlue : Theme.fillPrimary

                                    Icon {
                                        anchors.centerIn: parent
                                        glyph: NetworkService.iconGlyph
                                        size: 14
                                        color: NetworkService.connected ? "#ffffff" : Theme.labelSecondary
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1

                                    Text {
                                        text: NetworkService.networkType === "ethernet" ? "Ethernet" : "Wi-Fi"
                                        color: Theme.labelPrimary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSizeSmall
                                        font.weight: Font.DemiBold
                                    }

                                    Text {
                                        text: NetworkService.connected ? (NetworkService.connectionName || "Conectado") : "Desconectado"
                                        color: Theme.labelSecondary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 10
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }

                                Text {
                                    text: "›"
                                    color: Theme.labelTertiary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 17
                                    font.weight: Font.Bold
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onClicked: (mouse) => {
                                    if (mouse.button === Qt.RightButton && NetworkService.networkType === "wifi") {
                                        NetworkService.toggleWifi();
                                    } else {
                                        NetworkService.openEditor();
                                    }
                                }
                            }
                        }

                        // Hairline Divider
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.leftMargin: 46
                            Layout.rightMargin: 8
                            implicitHeight: 1
                            color: Theme.separator
                        }

                        // Bluetooth Row
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 4
                                anchors.rightMargin: 6
                                spacing: 10

                                Rectangle {
                                    implicitWidth: 32
                                    implicitHeight: 32
                                    radius: 16
                                    color: BluetoothService.powered ? Theme.systemBlue : Theme.fillPrimary

                                    Icon {
                                        anchors.centerIn: parent
                                        glyph: BluetoothService.powered ? "󰂯" : "󰂲"
                                        size: 14
                                        color: BluetoothService.powered ? "#ffffff" : Theme.labelSecondary
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1

                                    Text {
                                        text: "Bluetooth"
                                        color: Theme.labelPrimary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSizeSmall
                                        font.weight: Font.DemiBold
                                    }

                                    Text {
                                        text: BluetoothService.powered ? (BluetoothService.alias || "Activo") : "Desactivado"
                                        color: Theme.labelSecondary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 10
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }

                                Text {
                                    text: "›"
                                    color: Theme.labelTertiary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 17
                                    font.weight: Font.Bold
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onClicked: (mouse) => {
                                    if (mouse.button === Qt.RightButton) {
                                        BluetoothService.openManager();
                                    } else {
                                        BluetoothService.togglePower();
                                    }
                                }
                            }
                        }
                    }
                }

                // Right Column: Stacked Focus (DND) & Night Shift Cards
                ColumnLayout {
                    Layout.fillWidth: true
                    implicitHeight: 124
                    spacing: 8

                    // Focus / Concentración (No Molestar)
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: Theme.radiusMd
                        color: NotificationService.doNotDisturb
                            ? Qt.rgba(Theme.systemIndigo.r, Theme.systemIndigo.g, Theme.systemIndigo.b, 0.20)
                            : (dndMouse.containsMouse ? Theme.fillPrimary : Theme.fillTertiary)
                        border.color: NotificationService.doNotDisturb ? Theme.systemIndigo : Theme.specularBorder
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10

                            Rectangle {
                                implicitWidth: 32
                                implicitHeight: 32
                                radius: 16
                                color: NotificationService.doNotDisturb ? Theme.systemIndigo : Theme.fillPrimary

                                Icon {
                                    anchors.centerIn: parent
                                    glyph: NotificationService.doNotDisturb ? "󰍷" : "󰍶"
                                    size: 15
                                    color: NotificationService.doNotDisturb ? "#ffffff" : Theme.systemIndigo
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1

                                Text {
                                    text: "No Molestar"
                                    color: Theme.labelPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.weight: Font.DemiBold
                                }

                                Text {
                                    text: NotificationService.doNotDisturb ? "Silenciado" : "Desactivado"
                                    color: NotificationService.doNotDisturb ? Theme.systemIndigo : Theme.labelSecondary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 10
                                }
                            }
                        }

                        MouseArea {
                            id: dndMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                NotificationService.toggleDnd();
                            }
                        }
                    }

                    // Modo Nocturno (Night Shift)
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: Theme.radiusMd
                        color: NightLightService.active
                            ? Qt.rgba(Theme.systemOrange.r, Theme.systemOrange.g, Theme.systemOrange.b, 0.20)
                            : (nlMouse.containsMouse ? Theme.fillPrimary : Theme.fillTertiary)
                        border.color: NightLightService.active ? Theme.systemOrange : Theme.specularBorder
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10

                            Rectangle {
                                implicitWidth: 32
                                implicitHeight: 32
                                radius: 16
                                color: NightLightService.active ? Theme.systemOrange : Theme.fillPrimary

                                Icon {
                                    anchors.centerIn: parent
                                    glyph: NightLightService.active ? "󰖔" : "󱩌"
                                    size: 15
                                    color: NightLightService.active ? "#ffffff" : Theme.systemOrange
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1

                                Text {
                                    text: "Modo Nocturno"
                                    color: Theme.labelPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.weight: Font.DemiBold
                                }

                                Text {
                                    text: NightLightService.active ? "Cálido (4000K)" : "Desactivado"
                                    color: NightLightService.active ? Theme.systemOrange : Theme.labelSecondary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 10
                                }
                            }
                        }

                        MouseArea {
                            id: nlMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                NightLightService.toggle();
                            }
                        }
                    }
                }
            }

            // ------------------------------------------
            // Row 2: Compact Utility Row (Cafeína & Ventana Flotante)
            // ------------------------------------------
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                // Modo Cafeína
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 46
                    radius: Theme.radiusMd
                    color: CaffeineService.active
                        ? Qt.rgba(Theme.systemGreen.r, Theme.systemGreen.g, Theme.systemGreen.b, 0.20)
                        : (cafMouse.containsMouse ? Theme.fillPrimary : Theme.fillTertiary)
                    border.color: CaffeineService.active ? Theme.systemGreen : Theme.specularBorder
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        Rectangle {
                            implicitWidth: 28
                            implicitHeight: 28
                            radius: 14
                            color: CaffeineService.active ? Theme.systemGreen : Theme.fillPrimary
                            Icon {
                                anchors.centerIn: parent
                                glyph: "󰅶"
                                size: 13
                                color: CaffeineService.active ? "#ffffff" : Theme.systemGreen
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text {
                                text: "Cafeína"
                                color: Theme.labelPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: Font.DemiBold
                            }
                            Text {
                                text: CaffeineService.active ? "Pantalla Activa" : "Desactivada"
                                color: CaffeineService.active ? Theme.systemGreen : Theme.labelSecondary
                                font.family: Theme.fontFamily
                                font.pixelSize: 9
                            }
                        }
                    }

                    MouseArea {
                        id: cafMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            CaffeineService.toggle();
                        }
                    }
                }

                // Sway Floating Toggle
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 46
                    radius: Theme.radiusMd
                    color: fltTileMouse.containsMouse ? Theme.fillPrimary : Theme.fillTertiary
                    border.color: Theme.specularBorder
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        Rectangle {
                            implicitWidth: 28
                            implicitHeight: 28
                            radius: 14
                            color: Theme.fillPrimary
                            Icon {
                                anchors.centerIn: parent
                                glyph: "󰉈"
                                size: 13
                                color: Theme.labelPrimary
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text {
                                text: "Ventana Flotante"
                                color: Theme.labelPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: Font.DemiBold
                            }
                            Text {
                                text: "Alternar Sway"
                                color: Theme.labelSecondary
                                font.family: Theme.fontFamily
                                font.pixelSize: 9
                            }
                        }
                    }

                    MouseArea {
                        id: fltTileMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            SwayService.exec("swaymsg floating toggle");
                        }
                    }
                }
            }

            // ------------------------------------------
            // Middle Section: Pantalla / Brillo (macOS Capsule Slider)
            // ------------------------------------------
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 62
                radius: Theme.radiusMd
                color: Theme.fillTertiary
                border.color: Theme.specularBorder
                border.width: 1
                visible: BrightnessService.available

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    // Title & Brightness Header
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Pantalla"
                            color: Theme.labelPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.DemiBold
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: BrightnessService.brightnessPercent + "%"
                            color: Theme.labelSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                        }
                    }

                    // Thick macOS Capsule Slider Track
                    Rectangle {
                        id: brightTrack
                        Layout.fillWidth: true
                        implicitHeight: 28
                        radius: 14
                        color: Theme.fillPrimary
                        border.color: Theme.specularBorder
                        border.width: 1

                        // Active Fill Capsule
                        Rectangle {
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            width: Math.max(28, parent.width * BrightnessService.brightness)
                            radius: 14
                            color: Theme.accentColor

                            // Embedded Sun Glyph on left
                            Icon {
                                anchors.left: parent.left
                                anchors.leftMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                glyph: "󰃠"
                                size: 13
                                color: "#ffffff"
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: (mouse) => {
                                const ratio = Math.max(0.05, Math.min(1.0, mouse.x / width));
                                BrightnessService.setBrightness(ratio);
                            }
                            onPositionChanged: (mouse) => {
                                if (pressed) {
                                    const ratio = Math.max(0.05, Math.min(1.0, mouse.x / width));
                                    BrightnessService.setBrightness(ratio);
                                }
                            }
                        }
                    }
                }
            }

            // ------------------------------------------
            // Middle Section: Sonido / Volumen & Micrófono (macOS Capsule Slider)
            // ------------------------------------------
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 96
                radius: Theme.radiusMd
                color: Theme.fillTertiary
                border.color: Theme.specularBorder
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    // Title & Volume Header
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Sonido"
                            color: Theme.labelPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.DemiBold
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: AudioService.muted ? "Silenciado" : AudioService.volumePercent + "%"
                            color: AudioService.muted ? Theme.systemRed : Theme.labelSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                        }
                    }

                    // Thick macOS Capsule Slider Track
                    Rectangle {
                        id: audioTrack
                        Layout.fillWidth: true
                        implicitHeight: 28
                        radius: 14
                        color: Theme.fillPrimary
                        border.color: Theme.specularBorder
                        border.width: 1

                        // Active Fill Capsule
                        Rectangle {
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            width: Math.max(28, parent.width * AudioService.volume)
                            radius: 14
                            color: AudioService.muted ? Theme.systemRed : Theme.accentColor

                            // Embedded Speaker Glyph on left
                            Icon {
                                anchors.left: parent.left
                                anchors.leftMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                glyph: AudioService.muted ? "󰖁" : "󰕾"
                                size: 13
                                color: "#ffffff"
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: (mouse) => {
                                const ratio = Math.max(0.0, Math.min(1.0, mouse.x / width));
                                AudioService.setVolume(ratio);
                            }
                            onPositionChanged: (mouse) => {
                                if (pressed) {
                                    const ratio = Math.max(0.0, Math.min(1.0, mouse.x / width));
                                    AudioService.setVolume(ratio);
                                }
                            }
                        }
                    }

                    // Mic Mute & Mezclador Sub-buttons
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 24
                            radius: 8
                            color: AudioService.micMuted
                                ? Qt.rgba(Theme.systemRed.r, Theme.systemRed.g, Theme.systemRed.b, 0.22)
                                : (micMouse.containsMouse ? Theme.fillPrimary : "transparent")
                            border.color: AudioService.micMuted ? Theme.systemRed : Theme.specularBorder
                            border.width: 1

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 5
                                Icon {
                                    glyph: AudioService.micMuted ? "󰍭" : "󰍬"
                                    size: 11
                                    color: AudioService.micMuted ? Theme.systemRed : Theme.labelPrimary
                                }
                                Text {
                                    text: AudioService.micMuted ? "Mic Silenciado" : "Mic Activo"
                                    color: AudioService.micMuted ? Theme.systemRed : Theme.labelPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 10
                                }
                            }

                            MouseArea {
                                id: micMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: AudioService.toggleMicMute()
                            }
                        }

                        Rectangle {
                            implicitWidth: 96
                            implicitHeight: 24
                            radius: 8
                            color: pavuMouse.containsMouse ? Theme.fillPrimary : "transparent"
                            border.color: Theme.specularBorder
                            border.width: 1

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 4
                                Icon { glyph: "󰓃"; size: 11; color: Theme.labelPrimary }
                                Text { text: "Mezclador"; color: Theme.labelPrimary; font.family: Theme.fontFamily; font.pixelSize: 10 }
                            }

                            MouseArea {
                                id: pavuMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    SwayService.exec("pavucontrol");
                                }
                            }
                        }
                    }
                }
            }

            // ------------------------------------------
            // Now Playing Card (Enhanced Media Player)
            // ------------------------------------------
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 92
                radius: 12
                color: Theme.fillTertiary
                border.color: Theme.specularBorder
                border.width: 1
                visible: MprisService.hasPlayer

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    // Top Row: Artwork + Track Info + Transport Controls
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        // Album Art
                        ClippingRectangle {
                            implicitWidth: 44
                            implicitHeight: 44
                            radius: 8
                            color: Theme.surfaceHover
                            antialiasing: true

                            Image {
                                id: ccArtImage
                                anchors.fill: parent
                                source: MprisService.resolvedArtUrl
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: true
                                visible: MprisService.hasArt && status !== Image.Error
                            }

                            Icon {
                                anchors.centerIn: parent
                                glyph: "󰎆"
                                size: 20
                                color: Theme.accentColor
                                visible: !MprisService.hasArt || ccArtImage.status === Image.Error
                            }
                        }

                        // Track Metadata
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            RowLayout {
                                spacing: 4
                                visible: MprisService.identity.length > 0
                                Rectangle {
                                    implicitHeight: 14
                                    implicitWidth: idText.implicitWidth + 8
                                    radius: 7
                                    color: Qt.rgba(Theme.accentColor.r, Theme.accentColor.g, Theme.accentColor.b, 0.20)
                                    Text {
                                        id: idText
                                        anchors.centerIn: parent
                                        text: MprisService.identity
                                        color: Theme.accentColor
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 8
                                        font.weight: Font.DemiBold
                                    }
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: MprisService.trackTitle || "Reproduciendo"
                                color: Theme.labelPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }

                            Text {
                                Layout.fillWidth: true
                                text: MprisService.trackArtist || "Desconocido"
                                color: Theme.labelSecondary
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }
                        }

                        // Transport Controls
                        RowLayout {
                            spacing: 4
                            Layout.alignment: Qt.AlignVCenter

                            BasePill {
                                implicitWidth: 26
                                implicitHeight: 26
                                clickable: true
                                radius: 13
                                Icon { anchors.centerIn: parent; glyph: "󰒮"; size: 11; color: Theme.labelPrimary }
                                onClicked: MprisService.previous()
                            }

                            Rectangle {
                                implicitWidth: 32
                                implicitHeight: 32
                                radius: 16
                                color: Theme.accentColor

                                Icon {
                                    anchors.centerIn: parent
                                    glyph: MprisService.isPlaying ? "󰏤" : "󰐊"
                                    size: 14
                                    color: "#ffffff"
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: MprisService.playPause()
                                }
                            }

                            BasePill {
                                implicitWidth: 26
                                implicitHeight: 26
                                clickable: true
                                radius: 13
                                Icon { anchors.centerIn: parent; glyph: "󰒭"; size: 11; color: Theme.labelPrimary }
                                onClicked: MprisService.next()
                            }
                        }
                    }

                    // Bottom Row: Seekbar & Elapsed/Total Timestamps
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: MprisService.positionFormatted
                            color: Theme.labelSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 9
                        }

                        // Progress Seekbar
                        Rectangle {
                            id: mediaSeekTrack
                            Layout.fillWidth: true
                            implicitHeight: 4
                            radius: 2
                            color: Theme.fillPrimary
                            border.color: Theme.specularBorder
                            border.width: 1

                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: Math.max(0, parent.width * Math.max(0.0, Math.min(1.0, MprisService.progress)))
                                radius: 2
                                color: Theme.accentColor
                            }

                            MouseArea {
                                anchors.fill: parent
                                anchors.topMargin: -6
                                anchors.bottomMargin: -6
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: (mouse) => {
                                    const ratio = Math.max(0.0, Math.min(1.0, mouse.x / width));
                                    MprisService.seek(ratio);
                                }
                                onPositionChanged: (mouse) => {
                                    if (pressed) {
                                        const ratio = Math.max(0.0, Math.min(1.0, mouse.x / width));
                                        MprisService.seek(ratio);
                                    }
                                }
                            }
                        }

                        Text {
                            text: MprisService.lengthFormatted
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 9
                        }
                    }
                }
            }

            // ------------------------------------------
            // Quick Actions Bar (Screenshot, Terminal, Lock, Power)
            // ------------------------------------------
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 28
                    radius: 8
                    color: ssMouse.containsMouse ? Theme.fillPrimary : Theme.fillTertiary
                    border.color: Theme.specularBorder
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 4
                        Icon { glyph: "󰄄"; size: 11; color: Theme.labelPrimary }
                        Text { text: "Captura"; color: Theme.labelPrimary; font.family: Theme.fontFamily; font.pixelSize: 9 }
                    }

                    MouseArea {
                        id: ssMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            ccWindow.isOpen = false;
                            ScreenshotService.captureRegion();
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 28
                    radius: 8
                    color: termMouse.containsMouse ? Theme.fillPrimary : Theme.fillTertiary
                    border.color: Theme.specularBorder
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 4
                        Icon { glyph: "󰞷"; size: 11; color: Theme.labelPrimary }
                        Text { text: "Terminal"; color: Theme.labelPrimary; font.family: Theme.fontFamily; font.pixelSize: 9 }
                    }

                    MouseArea {
                        id: termMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            ccWindow.isOpen = false;
                            SwayService.exec("foot");
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 28
                    radius: 8
                    color: lockMouse.containsMouse ? Theme.fillPrimary : Theme.fillTertiary
                    border.color: Theme.specularBorder
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 4
                        Icon { glyph: "󰌾"; size: 11; color: Theme.labelPrimary }
                        Text { text: "Bloquear"; color: Theme.labelPrimary; font.family: Theme.fontFamily; font.pixelSize: 9 }
                    }

                    MouseArea {
                        id: lockMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            ccWindow.isOpen = false;
                            SwayService.exec("swaylock");
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 28
                    radius: 8
                    color: pwrMouse.containsMouse ? Theme.dangerColor : Theme.fillTertiary
                    border.color: pwrMouse.containsMouse ? Theme.dangerColor : Theme.specularBorder
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 4
                        Icon { glyph: "󰐥"; size: 11; color: pwrMouse.containsMouse ? "#ffffff" : Theme.dangerColor }
                        Text { text: "Apagar"; color: pwrMouse.containsMouse ? "#ffffff" : Theme.labelPrimary; font.family: Theme.fontFamily; font.pixelSize: 9 }
                    }

                    MouseArea {
                        id: pwrMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            ccWindow.isOpen = false;
                            SwayService.exec("systemctl poweroff");
                        }
                    }
                }
            }
        }
    }
}
