import QtQuick
import QtQuick.Layouts
import "../components"
import "../services"
import ".."

Item {
    id: root

    signal openMediaModal()

    visible: Config.showMedia && MprisService.hasPlayer
    implicitHeight: Config.barHeight - 6
    implicitWidth: mediaPill.implicitWidth

    function cleanTitle(raw) {
        if (!raw) return "";
        let t = raw.replace(/^ *\([^)]*\) */g, " ");
        t = t.replace(/^ *\[[^\]]*\] */g, " ");
        t = t.replace(/\.(mp3|flac|wav|m4a|ogg)$/i, "");
        return t.trim() || raw;
    }

    readonly property string displayTitle: cleanTitle(MprisService.trackTitle)
    readonly property string displayArtist: MprisService.trackArtist
    readonly property string compactTitle: {
        if (displayTitle.length > 0) return displayTitle;
        if (displayArtist.length > 0) return displayArtist;
        return "Música";
    }

    Rectangle {
        id: mediaPill
        anchors.fill: parent
        radius: height / 2

        // Liquid Glass Translucent Gradient (Sin Blur - Transparencia Pura)
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: pillMouse.containsMouse ? Qt.lighter(Theme.glassSmallTop, 1.25) : Theme.glassSmallTop
            }
            GradientStop {
                position: 1.0
                color: pillMouse.containsMouse ? Qt.lighter(Theme.glassSmallBottom, 1.25) : Theme.glassSmallBottom
            }
        }

        border.color: pillMouse.containsMouse ? Theme.specularBorderHover : Theme.specularBorder
        border.width: 1
        clip: true
        scale: pillMouse.pressed ? 0.96 : 1.0

        implicitWidth: Math.max(68, mediaRow.implicitWidth + 16)

        Behavior on border.color {
            ColorAnimation { duration: Theme.animFast }
        }
        Behavior on scale {
            NumberAnimation { duration: Theme.animFast; easing.type: Theme.animEasing }
        }

        RowLayout {
            id: mediaRow
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 7
            anchors.rightMargin: 8
            spacing: 5

            // Mini Progress Ring con icono dinámico de Play/Pausa
            Item {
                implicitWidth: 14
                implicitHeight: 14
                Layout.alignment: Qt.AlignVCenter

                CircularProgress {
                    id: circProgress
                    anchors.centerIn: parent
                    implicitSize: 14
                    lineWidth: 2
                    value: MprisService.progress
                    colPrimary: Theme.accentColor
                    colSecondary: Theme.fillPrimary
                }

                Item {
                    anchors.centerIn: parent
                    width: 8
                    height: 8

                    Icon {
                        anchors.centerIn: parent
                        glyph: MprisService.isPlaying ? "󰏤" : "󰐊"
                        size: 7
                        color: Theme.accentColor
                    }
                }
            }

            // Título de la pista compacto (recortado con puntos suspensivos para mantener el tamaño reducido)
            Text {
                id: titleText
                Layout.alignment: Qt.AlignVCenter
                Layout.maximumWidth: 78
                text: root.compactTitle
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.DemiBold
                elide: Text.ElideRight
                maximumLineCount: 1
            }
        }

        // Controles con mouse
        MouseArea {
            id: pillMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

            onClicked: (mouse) => {
                if (mouse.button === Qt.MiddleButton) {
                    MprisService.playPause();
                } else if (mouse.button === Qt.RightButton) {
                    MprisService.next();
                } else if (mouse.button === Qt.LeftButton) {
                    root.openMediaModal();
                }
            }

            onWheel: (wheel) => {
                if (wheel.angleDelta.y > 0) {
                    MprisService.previous();
                } else if (wheel.angleDelta.y < 0) {
                    MprisService.next();
                }
            }
        }
    }
}
