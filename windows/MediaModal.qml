import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import "../components"
import "../services"
import ".."

PanelWindow {
    id: root

    property bool isOpen: false
    visible: isOpen

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "swayshell:media-controls"
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    // Dismiss on click outside
    MouseArea {
        anchors.fill: parent
        onClicked: root.isOpen = false
    }

    // Soft floating drop shadow behind Media card
    Rectangle {
        id: mediaShadow
        anchors.fill: mediaCard
        anchors.margins: -4
        anchors.topMargin: -1
        anchors.bottomMargin: -6
        radius: mediaCard.radius + 4
        color: Qt.rgba(0, 0, 0, 0.35)
        z: 0
    }

    // Popup card positioned underneath the top bar on the right
    Rectangle {
        id: mediaCard
        anchors.top: Config.barPosition === "top" ? parent.top : undefined
        anchors.bottom: Config.barPosition === "bottom" ? parent.bottom : undefined
        anchors.topMargin: Config.barPosition === "top" ? 2 : 0
        anchors.bottomMargin: Config.barPosition === "bottom" ? 2 : 0
        anchors.right: parent.right
        anchors.rightMargin: 8

        width: 370
        implicitHeight: cardContent.implicitHeight + 24
        radius: Theme.cardRadius
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.glassMediumTop }
            GradientStop { position: 1.0; color: Theme.glassMediumBottom }
        }
        border.color: Theme.specularBorder
        border.width: 1
        clip: true

        // Consume clicks so they don't dismiss the card
        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        // Ambient blurred cover art in background (end4 style)
        Image {
            id: bgArt
            anchors.fill: parent
            source: MprisService.resolvedArtUrl
            fillMode: Image.PreserveAspectCrop
            opacity: 0.18
            visible: MprisService.hasArt && status === Image.Ready
            asynchronous: true
        }

        ColumnLayout {
            id: cardContent
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12

            // Top Row: Album Cover Art + Metadata (Title, Artist, App Source)
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                // Album Art thumbnail with shadow and rounded corners
                Rectangle {
                    implicitWidth: 70
                    implicitHeight: 70
                    radius: 10
                    color: Theme.surface
                    border.color: Theme.border
                    border.width: 1
                    clip: true

                    Image {
                        id: coverArtImg
                        anchors.fill: parent
                        source: MprisService.resolvedArtUrl
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        visible: MprisService.hasArt && status === Image.Ready
                    }

                    Icon {
                        anchors.centerIn: parent
                        glyph: "󰎆"
                        size: 28
                        color: Theme.accent
                        visible: !coverArtImg.visible
                    }
                }

                // Track Metadata & Source App Badge
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3

                    // Source application badge (e.g. Spotify, Brave, Firefox)
                    RowLayout {
                        spacing: 4
                        visible: MprisService.identity.length > 0

                        Rectangle {
                            implicitHeight: 16
                            implicitWidth: idText.implicitWidth + 10
                            radius: 8
                            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.20)
                            border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.40)
                            border.width: 1

                            Text {
                                id: idText
                                anchors.centerIn: parent
                                text: MprisService.identity
                                color: Theme.accent
                                font.family: Theme.fontFamily
                                font.pixelSize: 9
                                font.bold: true
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: MprisService.trackTitle || "Sin reproducción"
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        font.bold: true
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    Text {
                        Layout.fillWidth: true
                        text: MprisService.trackArtist || "Artista desconocido"
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    Text {
                        Layout.fillWidth: true
                        text: MprisService.trackAlbum || ""
                        color: Qt.rgba(Theme.textMuted.r, Theme.textMuted.g, Theme.textMuted.b, 0.70)
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        elide: Text.ElideRight
                        visible: text.length > 0
                        maximumLineCount: 1
                    }
                }
            }

            // Middle Section: Interactive Seekbar with Elapsed & Total Timestamps
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                // Progress Bar (clickable & draggable to seek)
                Rectangle {
                    id: seekTrack
                    Layout.fillWidth: true
                    height: 6
                    radius: 3
                    color: Theme.surfaceHover

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: parent.width * Math.max(0.0, Math.min(1.0, MprisService.progress))
                        radius: 3
                        color: Theme.accent
                    }

                    MouseArea {
                        anchors.fill: parent
                        anchors.topMargin: -8
                        anchors.bottomMargin: -8
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

                // Timestamps Row
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: MprisService.positionFormatted
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: MprisService.lengthFormatted
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                    }
                }
            }

            // Bottom Section: Playback Controls (Prev, Big Play/Pause, Next)
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 16

                Item { Layout.fillWidth: true }

                // Previous Button
                Rectangle {
                    implicitWidth: 34
                    implicitHeight: 34
                    radius: 17
                    color: prevMouse.containsMouse ? Theme.surfaceHover : Theme.surface
                    border.color: Theme.border
                    border.width: 1
                    opacity: MprisService.canGoPrevious ? 1.0 : 0.4

                    Icon {
                        anchors.centerIn: parent
                        glyph: "󰒮"
                        size: 15
                        color: prevMouse.containsMouse ? Theme.accent : Theme.text
                    }

                    MouseArea {
                        id: prevMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: MprisService.previous()
                    }
                }

                // Main Play/Pause Button
                Rectangle {
                    implicitWidth: 42
                    implicitHeight: 42
                    radius: 21
                    color: playMouse.containsMouse ? Theme.accentHover : Theme.accent

                    Icon {
                        anchors.centerIn: parent
                        glyph: MprisService.isPlaying ? "󰏤" : "󰐊"
                        size: 18
                        color: Theme.bgSolid
                    }

                    MouseArea {
                        id: playMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: MprisService.playPause()
                    }
                }

                // Next Button
                Rectangle {
                    implicitWidth: 34
                    implicitHeight: 34
                    radius: 17
                    color: nextMouse.containsMouse ? Theme.surfaceHover : Theme.surface
                    border.color: Theme.border
                    border.width: 1
                    opacity: MprisService.canGoNext ? 1.0 : 0.4

                    Icon {
                        anchors.centerIn: parent
                        glyph: "󰒭"
                        size: 15
                        color: nextMouse.containsMouse ? Theme.accent : Theme.text
                    }

                    MouseArea {
                        id: nextMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: MprisService.next()
                    }
                }

                Item { Layout.fillWidth: true }
            }
        }
    }
}
