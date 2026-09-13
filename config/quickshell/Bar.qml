import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.I3
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Services.Mpris
import Quickshell.Io
import Quickshell.Widgets
import "."

PanelWindow {
    id: barWindow

    anchors {
        top: true
        left: true
        right: true
    }

    height: 32
    color: Theme.bgBar

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "sway-bar"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // Estado del reloj (alternar formato corto / extendido)
    property bool clockFormatAlt: false

    // Estado de Gammastep y Cafeína
    property bool gammastepActive: false
    property bool caffeineActive: false

    // Hardware stats
    property string cpuUsage: "0%"
    property string memUsage: "0%"

    // Título de ventana activa
    function getActiveWindowTitle() {
        for (let i = 0; i < ToplevelManager.toplevels.values.length; i++) {
            let top = ToplevelManager.toplevels.values[i]
            if (top.activated) {
                let app = (top.appId || "").toLowerCase()
                let title = top.title || ""
                if (app.includes("firefox")) return "󰈹  Firefox"
                if (app.includes("zen")) return "󰈹  Zen Browser"
                if (app.includes("foot") || app.includes("terminal")) return "󰞷  Terminal"
                if (app.includes("thunar")) return "󰝰  Thunar"
                if (app.includes("zed")) return "󰅩  Zed Editor"
                if (app.includes("code")) return "󰨞  VS Code"
                if (app.includes("spotify")) return "󰓇  Spotify"
                if (app.includes("discord") || app.includes("vesktop")) return "󰙯  Discord"
                if (app.includes("telegram")) return "󰒓  Telegram"
                if (app.includes("pavucontrol")) return "󰕾  Pavucontrol"
                if (app.includes("mpv")) return "󰎆  MPV"
                if (app.includes("btop")) return "󰻠  btop"
                if (app.includes("calculator")) return "󰃬  Calculadora"
                return title ? (title.length > 24 ? title.substring(0, 24) + "…" : title) : (top.appId || "Ventana")
            }
        }
        return "󰖯  Escritorio"
    }

    // Timer periódico para actualizar estado de hardware, noche y cafeína
    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            checkStatusProc.running = true
        }
    }

    Process {
        id: checkStatusProc
        command: ["bash", "-c", "pgrep -x gammastep >/dev/null && echo 'gamma:1' || echo 'gamma:0'; [ -f $HOME/.config/caffeine_active ] || [ -f ${XDG_RUNTIME_DIR:-/tmp}/caffeine_active ] && echo 'caff:1' || echo 'caff:0'; grep 'cpu ' /proc/stat | awk '{u=($2+$4)*100/($2+$4+$5)} END {printf \"cpu:%.0f%\\n\", u}'; free | grep Mem | awk '{printf \"mem:%.0f%\\n\", $3*100/$2}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                let lines = value.trim().split("\n")
                for (let i = 0; i < lines.length; i++) {
                    let l = lines[i].trim()
                    if (l === "gamma:1") barWindow.gammastepActive = true
                    else if (l === "gamma:0") barWindow.gammastepActive = false
                    else if (l === "caff:1") barWindow.caffeineActive = true
                    else if (l === "caff:0") barWindow.caffeineActive = false
                    else if (l.startsWith("cpu:")) barWindow.cpuUsage = l.substring(4)
                    else if (l.startsWith("mem:")) barWindow.memUsage = l.substring(4)
                }
            }
        }
    }

    // Clima periódico
    property string weatherText: "--°C"
    property string weatherIcon: "☁️"
    Timer {
        interval: 300000 // 5 minutos
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: weatherProc.running = true
    }

    Process {
        id: weatherProc
        command: ["bash", "-c", "curl -s --connect-timeout 3 'wttr.in/?format=%c;%t' 2>/dev/null || echo '☁️;--°C'"]
        stdout: StdioCollector {
            onStreamFinished: {
                let parts = value.trim().split(";")
                if (parts.length >= 2) {
                    barWindow.weatherIcon = parts[0].trim() || "☁️"
                    barWindow.weatherText = parts[1].trim() || "--°C"
                }
            }
        }
    }

    // Contenedor principal horizontal
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 4
        spacing: 5

        // ══════════════════════════════════════════════════════════
        // ║  IZQUIERDA — Menú · Workspaces · Ventana Activa         ║
        // ══════════════════════════════════════════════════════════

        // ── Cápsula: Menú Lanzador (Arch Logo) ────────────────────
        Rectangle {
            height: 24
            width: 28
            radius: Theme.radiusPill
            color: menuMouse.containsMouse ? Theme.bgPillHover : Theme.bgPill

            Text {
                anchors.centerIn: parent
                text: "󰣇"
                font.family: Theme.fontMono
                font.pixelSize: 13
                color: Theme.primary
            }

            MouseArea {
                id: menuMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.toggleLauncher()
            }
        }

        // ── Cápsula: Espacios de Trabajo (Sway Workspaces) ────────
        Rectangle {
            height: 24
            implicitWidth: wsRow.implicitWidth + 8
            radius: Theme.radiusPill
            color: Theme.bgPill

            RowLayout {
                id: wsRow
                anchors.centerIn: parent
                spacing: 3

                Repeater {
                    model: I3.workspaces

                    Rectangle {
                        required property var modelData
                        width: Math.max(20, wsTxt.implicitWidth + 10)
                        height: 18
                        radius: Theme.radiusPill
                        color: modelData.focused
                               ? Theme.primary
                               : (modelData.urgent ? Theme.error : (itemWsMouse.containsMouse ? Theme.bgPillHover : "transparent"))

                        Text {
                            id: wsTxt
                            anchors.centerIn: parent
                            text: modelData.name
                            font.family: Theme.fontSans
                            font.bold: modelData.focused
                            font.pixelSize: 10
                            color: modelData.focused
                                   ? Theme.colorOnPrimary
                                   : (modelData.urgent ? "#ffffff" : Theme.textMain)
                        }

                        MouseArea {
                            id: itemWsMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: I3.dispatch("workspace " + modelData.name)
                        }
                    }
                }
            }
        }

        // ── Cápsula: Nombre e Icono de Ventana Activa ─────────────
        Rectangle {
            height: 24
            implicitWidth: winRow.implicitWidth + 16
            radius: Theme.radiusPill
            color: Theme.bgPill
            visible: true

            RowLayout {
                id: winRow
                anchors.centerIn: parent
                spacing: 6

                Text {
                    text: barWindow.getActiveWindowTitle()
                    font.family: Theme.fontSans
                    font.pixelSize: 10.5
                    font.weight: Font.Medium
                    color: Theme.textMain
                    elide: Text.ElideRight
                }
            }
        }

        // Espaciador izquierdo
        Item { Layout.fillWidth: true }

        // ══════════════════════════════════════════════════════════
        // ║  CENTRO — Clima · Reloj y Fecha                         ║
        // ══════════════════════════════════════════════════════════

        // ── Cápsula: Clima (Weather) ──────────────────────────────
        Rectangle {
            height: 24
            implicitWidth: weatherLayout.implicitWidth + 16
            radius: Theme.radiusPill
            color: weatherMouse.containsMouse ? Theme.bgPillHover : Theme.bgPill

            RowLayout {
                id: weatherLayout
                anchors.centerIn: parent
                spacing: 5

                Text {
                    text: barWindow.weatherIcon
                    font.family: Theme.fontSans
                    font.pixelSize: 11
                }
                Text {
                    text: barWindow.weatherText
                    font.family: Theme.fontSans
                    font.pixelSize: 10.5
                    font.weight: Font.Medium
                    color: Theme.textMain
                }
            }

            MouseArea {
                id: weatherMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Qt.openUrlExternally("https://wttr.in")
            }
        }

        // ── Cápsula: Reloj y Fecha ────────────────────────────────
        SystemClock {
            id: clock
            precision: SystemClock.Minutes
        }

        Rectangle {
            height: 24
            implicitWidth: clockText.implicitWidth + 18
            radius: Theme.radiusPill
            color: clockMouse.containsMouse ? Theme.bgPillHover : Theme.bgPill

            Text {
                id: clockText
                anchors.centerIn: parent
                text: barWindow.clockFormatAlt
                      ? Qt.formatDateTime(clock.date, "dddd d 'de' MMMM, yyyy  ·  HH:mm")
                      : Qt.formatDateTime(clock.date, "ddd d MMM   HH:mm")
                font.family: Theme.fontSans
                font.pixelSize: 10.5
                font.weight: Font.Medium
                color: Theme.textMain
            }

            MouseArea {
                id: clockMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: barWindow.clockFormatAlt = !barWindow.clockFormatAlt
            }
        }

        // Espaciador derecho
        Item { Layout.fillWidth: true }

        // ══════════════════════════════════════════════════════════
        // ║  DERECHA — Multimedia · QuickSettings · Hardware · Power║
        // ══════════════════════════════════════════════════════════

        // ── Cápsula: Mini Reproductor Multimedia (MPRIS) ──────────
        Rectangle {
            id: mediaPill
            height: 24
            visible: Mpris.players.values.length > 0 && !!Mpris.players.values[0].trackTitle
            implicitWidth: mediaRow.implicitWidth + 14
            radius: Theme.radiusPill
            color: mediaMouse.containsMouse ? Theme.bgPillHover : Theme.bgPill

            property var currentPlayer: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null

            RowLayout {
                id: mediaRow
                anchors.centerIn: parent
                spacing: 6

                Text {
                    text: (mediaPill.currentPlayer && mediaPill.currentPlayer.playbackState === MprisPlaybackState.Playing) ? "󰎆" : "󰏤"
                    font.family: Theme.fontMono
                    font.pixelSize: 11
                    color: Theme.primary
                }

                Text {
                    text: {
                        if (!mediaPill.currentPlayer) return ""
                        let title = mediaPill.currentPlayer.trackTitle || ""
                        let artist = mediaPill.currentPlayer.trackArtists ? mediaPill.currentPlayer.trackArtists.join(", ") : ""
                        let full = artist ? (artist + " - " + title) : title
                        return full.length > 24 ? full.substring(0, 24) + "…" : full
                    }
                    font.family: Theme.fontSans
                    font.pixelSize: 10.5
                    color: Theme.textMain
                    elide: Text.ElideRight
                }
            }

            MouseArea {
                id: mediaMouse
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: mouse => {
                    if (!mediaPill.currentPlayer) return
                    if (mouse.button === Qt.RightButton) {
                        mediaPill.currentPlayer.next()
                    } else {
                        mediaPill.currentPlayer.playPause()
                    }
                }
            }
        }

        // ── Cápsula: Centro de Control (Luz Nocturna & Cafeína) ───
        Rectangle {
            height: 24
            implicitWidth: qsRow.implicitWidth + 14
            radius: Theme.radiusPill
            color: Theme.bgPill

            RowLayout {
                id: qsRow
                anchors.centerIn: parent
                spacing: 8

                // Indicador Luz Nocturna
                Text {
                    text: barWindow.gammastepActive ? "󰌵" : "󰌶"
                    font.family: Theme.fontMono
                    font.pixelSize: 12
                    color: barWindow.gammastepActive ? Theme.primary : Theme.textMuted

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            gammaToggleProc.running = true
                            barWindow.gammastepActive = !barWindow.gammastepActive
                        }
                    }
                }

                // Indicador Cafeína
                Text {
                    text: barWindow.caffeineActive ? "󰅶" : "󰾪"
                    font.family: Theme.fontMono
                    font.pixelSize: 12
                    color: barWindow.caffeineActive ? Theme.primary : Theme.textMuted

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            caffToggleProc.running = true
                            barWindow.caffeineActive = !barWindow.caffeineActive
                        }
                    }
                }
            }
        }

        Process { id: gammaToggleProc; command: ["bash", "-c", "~/.local/bin/gammastep-toggle.sh 2>/dev/null || true"] }
        Process { id: caffToggleProc; command: ["bash", "-c", "~/.local/bin/caffeine-toggle.sh 2>/dev/null || true"] }

        // ── Cápsula: Hardware (CPU & RAM) ─────────────────────────
        Rectangle {
            height: 24
            implicitWidth: hwRow.implicitWidth + 14
            radius: Theme.radiusPill
            color: hwMouse.containsMouse ? Theme.bgPillHover : Theme.bgPill

            RowLayout {
                id: hwRow
                anchors.centerIn: parent
                spacing: 8

                RowLayout {
                    spacing: 3
                    Text {
                        text: "󰻠"
                        font.family: Theme.fontMono
                        font.pixelSize: 11
                        color: Theme.primary
                    }
                    Text {
                        text: barWindow.cpuUsage
                        font.family: Theme.fontSans
                        font.pixelSize: 10
                        color: Theme.textMain
                    }
                }

                RowLayout {
                    spacing: 3
                    Text {
                        text: "󰍛"
                        font.family: Theme.fontMono
                        font.pixelSize: 11
                        color: Theme.secondary
                    }
                    Text {
                        text: barWindow.memUsage
                        font.family: Theme.fontSans
                        font.pixelSize: 10
                        color: Theme.textMain
                    }
                }
            }

            MouseArea {
                id: hwMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: btopProc.running = true
            }
        }

        Process { id: btopProc; command: ["foot", "-e", "btop"] }

        // ── Cápsula: Controles (Red & Volumen) ─────────────────────
        Rectangle {
            height: 24
            implicitWidth: ctrlRow.implicitWidth + 14
            radius: Theme.radiusPill
            color: ctrlMouse.containsMouse ? Theme.bgPillHover : Theme.bgPill

            RowLayout {
                id: ctrlRow
                anchors.centerIn: parent
                spacing: 8

                // Red
                RowLayout {
                    spacing: 3
                    Text {
                        text: "󰈀"
                        font.family: Theme.fontMono
                        font.pixelSize: 12
                        color: Theme.primary
                    }
                    Text {
                        text: "LAN"
                        font.family: Theme.fontSans
                        font.pixelSize: 10
                        color: Theme.textMain
                    }
                }

                // Volumen
                RowLayout {
                    spacing: 3
                    Text {
                        text: {
                            if (!Pipewire.defaultAudioSink || Pipewire.defaultAudioSink.audio.muted) return "󰝟"
                            let v = Pipewire.defaultAudioSink.audio.volume
                            if (v > 0.6) return "󰕾"
                            if (v > 0.2) return "󰖀"
                            return "󰕿"
                        }
                        font.family: Theme.fontMono
                        font.pixelSize: 12
                        color: (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio.muted) ? Theme.error : Theme.textMain
                    }

                    Text {
                        text: {
                            if (!Pipewire.defaultAudioSink) return "100%"
                            return Math.round(Pipewire.defaultAudioSink.audio.volume * 100) + "%"
                        }
                        font.family: Theme.fontSans
                        font.pixelSize: 10
                        color: Theme.textMain
                    }
                }
            }

            MouseArea {
                id: ctrlMouse
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton) {
                        if (Pipewire.defaultAudioSink) {
                            Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink.audio.muted
                        }
                    } else {
                        pavuProc.running = true
                    }
                }
                onWheel: wheel => {
                    if (Pipewire.defaultAudioSink) {
                        let delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05
                        let current = Pipewire.defaultAudioSink.audio.volume
                        Pipewire.defaultAudioSink.audio.volume = Math.max(0.0, Math.min(1.5, current + delta))
                    }
                }
            }
        }

        Process { id: pavuProc; command: ["pavucontrol"] }

        // ── Cápsula: Bandeja del Sistema (Tray) ───────────────────
        Rectangle {
            height: 24
            visible: SystemTray.items.values.length > 0
            implicitWidth: trayRow.implicitWidth + 10
            radius: Theme.radiusPill
            color: Theme.bgPill

            RowLayout {
                id: trayRow
                anchors.centerIn: parent
                spacing: 5

                Repeater {
                    model: SystemTray.items

                    Rectangle {
                        required property var modelData
                        width: 18
                        height: 18
                        radius: Theme.radiusSm
                        color: itemTrayMouse.containsMouse ? Theme.bgPillHover : "transparent"

                        IconImage {
                            anchors.centerIn: parent
                            width: 14
                            height: 14
                            source: modelData.icon
                        }

                        MouseArea {
                            id: itemTrayMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            cursorShape: Qt.PointingHandCursor
                            onClicked: mouse => {
                                if (mouse.button === Qt.RightButton) {
                                    modelData.showMenu()
                                } else {
                                    modelData.activate()
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── Cápsula: Botón de Apagado / Control (Power) ───────────
        Rectangle {
            height: 24
            width: 28
            radius: Theme.radiusPill
            color: powerMouse.containsMouse ? Theme.error : Theme.bgPill

            Text {
                anchors.centerIn: parent
                text: "⏻"
                font.family: Theme.fontMono
                font.pixelSize: 12
                font.bold: true
                color: powerMouse.containsMouse ? Theme.colorOnError : Theme.textMuted
            }

            MouseArea {
                id: powerMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.togglePower()
            }
        }
    }
}
