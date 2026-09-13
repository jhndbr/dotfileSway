pragma Singleton
import QtQuick

QtObject {
    // Paleta Monocromática estilo macOS / Minimal Dark
    readonly property color bgDark: "#141414"
    readonly property color bgSurface: "#1c1c1e"
    readonly property color bgCard: "#252528"
    readonly property color bgHover: "#323235"
    readonly property color bgSelected: "#3a3a3c"
    readonly property color borderFocus: "#ffffff"
    readonly property color borderMuted: "#2c2c2e"
    readonly property color textMain: "#ffffff"
    readonly property color textMuted: "#8e8e93"
    readonly property color accentRed: "#ff453a"
    readonly property color accentBlue: "#0a84ff"
    readonly property color accentGreen: "#30d158"

    readonly property int radiusSm: 6
    readonly property int radiusMd: 10
    readonly property int radiusLg: 14

    readonly property string fontSans: "Inter, SF Pro Display, JetBrainsMono Nerd Font, sans-serif"
    readonly property string fontMono: "JetBrainsMono Nerd Font, monospace"
}
