pragma Singleton
import QtQuick

QtObject {
    // ╔══════════════════════════════════════════════════════════════╗
    // ║     Quickshell Material 3 Dynamic Tokens (Matugen)           ║
    // ║     Generado automáticamente al cambiar de wallpaper         ║
    // ╚══════════════════════════════════════════════════════════════╝

    // Superficies y elevación
    readonly property color bgBar: "#{{colors.surface.default.hex_stripped}}"
    readonly property color bgPill: "#{{colors.surface_container_high.default.hex_stripped}}"
    readonly property color bgPillHover: "#{{colors.surface_container_highest.default.hex_stripped}}"
    readonly property color bgPillActive: "#{{colors.primary_container.default.hex_stripped}}"
    readonly property color bgCard: "#{{colors.surface_container.default.hex_stripped}}"
    readonly property color bgDark: "#{{colors.background.default.hex_stripped}}"
    readonly property color bgSurface: "#{{colors.surface.default.hex_stripped}}"
    readonly property color bgHover: "#{{colors.surface_container_highest.default.hex_stripped}}"
    readonly property color bgSelected: "#{{colors.surface_container_high.default.hex_stripped}}"

    // Colores primarios y acentos
    readonly property color primary: "#{{colors.primary.default.hex_stripped}}"
    readonly property color colorOnPrimary: "#{{colors.on_primary.default.hex_stripped}}"
    readonly property color primaryContainer: "#{{colors.primary_container.default.hex_stripped}}"
    readonly property color colorOnPrimaryContainer: "#{{colors.on_primary_container.default.hex_stripped}}"
    
    readonly property color secondary: "#{{colors.secondary.default.hex_stripped}}"
    readonly property color colorOnSecondary: "#{{colors.on_secondary.default.hex_stripped}}"
    readonly property color secondaryContainer: "#{{colors.secondary_container.default.hex_stripped}}"
    readonly property color colorOnSecondaryContainer: "#{{colors.on_secondary_container.default.hex_stripped}}"

    readonly property color tertiary: "#{{colors.tertiary.default.hex_stripped}}"
    readonly property color colorOnTertiary: "#{{colors.on_tertiary.default.hex_stripped}}"

    // Textos
    readonly property color textMain: "#{{colors.on_surface.default.hex_stripped}}"
    readonly property color textSecondary: "#{{colors.on_surface_variant.default.hex_stripped}}"
    readonly property color textMuted: "#{{colors.outline.default.hex_stripped}}"
    readonly property color colorOnSurface: "#{{colors.on_surface.default.hex_stripped}}"

    // Bordes
    readonly property color borderFocus: "#{{colors.primary.default.hex_stripped}}"
    readonly property color borderMuted: "#{{colors.outline_variant.default.hex_stripped}}"

    // Alertas y errores
    readonly property color accentRed: "#{{colors.error.default.hex_stripped}}"
    readonly property color error: "#{{colors.error.default.hex_stripped}}"
    readonly property color colorOnError: "#{{colors.on_error.default.hex_stripped}}"
    readonly property color accentBlue: "#{{colors.primary.default.hex_stripped}}"
    readonly property color accentGreen: "#{{colors.tertiary.default.hex_stripped}}"

    // Radios y formas (Material Elevated Pill Architecture)
    readonly property int radiusPill: 999
    readonly property int radiusLg: 14
    readonly property int radiusMd: 10
    readonly property int radiusSm: 6

    // Tipografía idéntica a Waybar
    readonly property string fontSans: "Inter, SF Pro Display, JetBrainsMono Nerd Font, sans-serif"
    readonly property string fontMono: "JetBrainsMono Nerd Font, Symbols Nerd Font, monospace"
}
