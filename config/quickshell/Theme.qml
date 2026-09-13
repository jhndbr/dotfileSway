pragma Singleton
import QtQuick

QtObject {
    // ╔══════════════════════════════════════════════════════════════╗
    // ║     Quickshell Material 3 Dynamic Tokens (Fallback Base)     ║
    // ║     Sobre-escrito dinámicamente por Matugen con wallpaper    ║
    // ╚══════════════════════════════════════════════════════════════╝

    // Superficies y elevación (Material 3)
    readonly property color bgBar: "#141414"
    readonly property color bgPill: "#1f1f22"
    readonly property color bgPillHover: "#2a2a2d"
    readonly property color bgPillActive: "#3a3a40"
    readonly property color bgCard: "#222225"
    readonly property color bgDark: "#101012"
    readonly property color bgSurface: "#18181b"
    readonly property color bgHover: "#2a2a2e"
    readonly property color bgSelected: "#333338"

    // Colores primarios y acentos
    readonly property color primary: "#d0bcff"
    readonly property color colorOnPrimary: "#381e72"
    readonly property color primaryContainer: "#4f378b"
    readonly property color colorOnPrimaryContainer: "#eaddff"
    
    readonly property color secondary: "#ccc2dc"
    readonly property color colorOnSecondary: "#332d41"
    readonly property color secondaryContainer: "#4a4458"
    readonly property color colorOnSecondaryContainer: "#e8def8"

    readonly property color tertiary: "#efb8c8"
    readonly property color colorOnTertiary: "#492532"

    // Textos
    readonly property color textMain: "#e6e1e5"
    readonly property color textSecondary: "#cac4d0"
    readonly property color textMuted: "#938f99"
    readonly property color colorOnSurface: "#e6e1e5"

    // Bordes
    readonly property color borderFocus: "#d0bcff"
    readonly property color borderMuted: "#49454f"

    // Alertas y errores (evitar colisión con la señal reservada 'error' de QObject)
    readonly property color accentRed: "#ffb4ab"
    readonly property color colorError: "#ffb4ab"
    readonly property color colorOnError: "#690005"
    readonly property color accentBlue: "#a8c7fa"
    readonly property color accentGreen: "#a8dab5"

    // Radios y formas (Material Elevated Pill Architecture)
    readonly property int radiusPill: 999
    readonly property int radiusLg: 14
    readonly property int radiusMd: 10
    readonly property int radiusSm: 6

    // Tipografía idéntica a Waybar
    readonly property string fontSans: "Inter, SF Pro Display, JetBrainsMono Nerd Font, sans-serif"
    readonly property string fontMono: "JetBrainsMono Nerd Font, Symbols Nerd Font, monospace"
}
