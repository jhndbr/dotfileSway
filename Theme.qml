pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: theme

    // Active theme preset (configured via Config.activeTheme)
    property string activePreset: "macos-dark"

    // Optional user-customized accent color (e.g. "#007AFF", "#AF52DE", etc.)
    // Empty string means follow the active preset's accent
    property string userAccent: ""

    // Preset color palettes including macOS Sequoia Dark and Light
    readonly property var presets: ({
        "macos-dark": {
            bg: "#e01c1c1e",             // Apple System Gray 6 with translucent glass
            bgSolid: "#1c1c1e",
            surface: "#24ffffff",         // ~14% white translucent glass
            surfaceElevated: "#33ffffff", // ~20% white translucent glass
            surfaceHover: "#38ffffff",    // ~22% hover
            surfaceActive: "#4dffffff",   // ~30% active
            border: "#29ffffff",          // 16% white border
            borderHover: "#52ffffff",     // 32% white border on hover
            separator: "#1fffffff",       // 12% white separator
            text: "#f5f5f7",              // SF primary label
            textMuted: "#a1a1a6",         // SF secondary label
            textDisabled: "#636366",      // SF tertiary label
            accent: "#0a84ff",            // Apple Blue Dark
            accentHover: "#409cff",
            accentSecondary: "#5e5ce6",   // Apple Indigo
            success: "#30d158",           // Apple Green
            warning: "#ffd60a",           // Apple Yellow
            danger: "#ff453a"             // Apple Red
        },
        "macos-light": {
            bg: "#eef2f2f7",
            bgSolid: "#f2f2f7",
            surface: "#14000000",
            surfaceElevated: "#24000000",
            surfaceHover: "#1f000000",
            surfaceActive: "#33000000",
            border: "#24000000",
            borderHover: "#3d000000",
            separator: "#14000000",
            text: "#1d1d1f",
            textMuted: "#6e6e73",
            textDisabled: "#aeaeb2",
            accent: "#0071e3",
            accentHover: "#0077ed",
            accentSecondary: "#5856d6",
            success: "#28cd41",
            warning: "#ff9f0a",
            danger: "#ff3b30"
        },
        "catppuccin": {
            bg: "#e61e1e2e",
            bgSolid: "#1e1e2e",
            surface: "#33313244",
            surfaceElevated: "#4d313244",
            surfaceHover: "#4d45475a",
            surfaceActive: "#66585b70",
            border: "#26cdd6f4",
            borderHover: "#59cdd6f4",
            separator: "#1acdd6f4",
            text: "#cdd6f4",
            textMuted: "#a6adc8",
            textDisabled: "#6c7086",
            accent: "#cba6f7",
            accentHover: "#b4befe",
            accentSecondary: "#89b4fa",
            success: "#a6e3a1",
            warning: "#f9e2af",
            danger: "#f38ba8"
        },
        "tokyonight": {
            bg: "#e61a1b26",
            bgSolid: "#1a1b26",
            surface: "#3324283b",
            surfaceElevated: "#4d24283b",
            surfaceHover: "#4d2f354d",
            surfaceActive: "#66414868",
            border: "#26c0caf5",
            borderHover: "#59c0caf5",
            separator: "#1ac0caf5",
            text: "#c0caf5",
            textMuted: "#9aa5ce",
            textDisabled: "#565f89",
            accent: "#7aa2f7",
            accentHover: "#bb9af7",
            accentSecondary: "#7dcfff",
            success: "#9ece6a",
            warning: "#e0af68",
            danger: "#f7768e"
        },
        "nord": {
            bg: "#e62e3440",
            bgSolid: "#2e3440",
            surface: "#333b4252",
            surfaceElevated: "#4d3b4252",
            surfaceHover: "#4d434c5e",
            surfaceActive: "#664c566a",
            border: "#26eceff4",
            borderHover: "#59eceff4",
            separator: "#1aeceff4",
            text: "#eceff4",
            textMuted: "#d8dee9",
            textDisabled: "#4c566a",
            accent: "#88c0d0",
            accentHover: "#81a1c1",
            accentSecondary: "#5e81ac",
            success: "#a3be8c",
            warning: "#ebcb8b",
            danger: "#bf616a"
        },
        "gruvbox": {
            bg: "#e6282828",
            bgSolid: "#282828",
            surface: "#333c3836",
            surfaceElevated: "#4d3c3836",
            surfaceHover: "#4d504945",
            surfaceActive: "#66665c54",
            border: "#26ebdbb2",
            borderHover: "#59ebdbb2",
            separator: "#1aebdbb2",
            text: "#ebdbb2",
            textMuted: "#d5c4a1",
            textDisabled: "#7c6f64",
            accent: "#fabd2f",
            accentHover: "#fe8019",
            accentSecondary: "#83a598",
            success: "#b8bb26",
            warning: "#d79921",
            danger: "#fb4934"
        },
        "oled": {
            bg: "#f00b0b0e",
            bgSolid: "#000000",
            surface: "#3316161c",
            surfaceElevated: "#4d16161c",
            surfaceHover: "#4d22222a",
            surfaceActive: "#6630303c",
            border: "#26ffffff",
            borderHover: "#59ffffff",
            separator: "#1affffff",
            text: "#f5f5f7",
            textMuted: "#a1a1aa",
            textDisabled: "#52525b",
            accent: "#6366f1",
            accentHover: "#818cf8",
            accentSecondary: "#38bdf8",
            success: "#22c55e",
            warning: "#eab308",
            danger: "#ef4444"
        }
    })

    // Active color accessors
    readonly property var currentColors: presets[activePreset] || presets["macos-dark"]

    // Modo Oscuro / Claro
    readonly property bool darkMode: activePreset !== "macos-light"

    // ==========================================
    // Apple Liquid Glass Official System Colors (iOS 27 / macOS Tahoe)
    // ==========================================
    readonly property color systemBlue:   darkMode ? "#0091ff" : "#0088ff"
    readonly property color systemGreen:  darkMode ? "#30d158" : "#34c759"
    readonly property color systemRed:    darkMode ? "#ff4245" : "#ff383c"
    readonly property color systemOrange: darkMode ? "#ff9230" : "#ff8d28"
    readonly property color systemYellow: darkMode ? "#ffd600" : "#ffcc00"
    readonly property color systemMint:   darkMode ? "#00dac3" : "#00c8b3"
    readonly property color systemTeal:   darkMode ? "#00d2e0" : "#00c3d0"
    readonly property color systemCyan:   darkMode ? "#3cd3fe" : "#00c0e8"
    readonly property color systemIndigo: darkMode ? "#6d7cff" : "#6155f5"
    readonly property color systemPurple: darkMode ? "#db34f2" : "#cb30e0"
    readonly property color systemPink:   darkMode ? "#ff375f" : "#ff2d55"
    readonly property color systemBrown:  darkMode ? "#b78a66" : "#ac7f5e"

    // ==========================================
    // Centralized Design Tokens (macOS Design System)
    // ==========================================
    readonly property color accentColor: (userAccent && userAccent.length > 0) ? userAccent : currentColors.accent
    readonly property color accentHoverColor: (userAccent && userAccent.length > 0) ? Qt.lighter(accentColor, 1.15) : currentColors.accentHover
    readonly property color accentSecondaryColor: (userAccent && userAccent.length > 0) ? Qt.darker(accentColor, 1.15) : currentColors.accentSecondary
    readonly property color backgroundColor: currentColors.bg
    readonly property color backgroundSolidColor: currentColors.bgSolid
    readonly property color surfaceColor: currentColors.surface
    readonly property color surfaceElevatedColor: currentColors.surfaceElevated || currentColors.surfaceHover
    readonly property color surfaceHoverColor: currentColors.surfaceHover
    readonly property color surfaceActiveColor: currentColors.surfaceActive
    readonly property color textPrimary: currentColors.text
    readonly property color textSecondary: currentColors.textMuted
    readonly property color textDisabledColor: currentColors.textDisabled
    readonly property color separatorColor: currentColors.separator || currentColors.border
    readonly property color borderColor: currentColors.border
    readonly property color borderHoverColor: currentColors.borderHover
    readonly property color successColor: currentColors.success
    readonly property color warningColor: currentColors.warning
    readonly property color dangerColor: currentColors.danger

    // ==========================================
    // Apple Liquid Glass Hierarchy & Translucency (Sin Blur - Pura Transparencia Óptica)
    // ==========================================
    // Jerarquía de Labels Oficiales
    readonly property color labelPrimary:    darkMode ? Qt.rgba(1, 1, 1, 1.0) : Qt.rgba(0, 0, 0, 1.0)
    readonly property color labelSecondary:  darkMode ? Qt.rgba(0.922, 0.922, 0.961, 0.60) : Qt.rgba(0.235, 0.235, 0.263, 0.60)
    readonly property color labelTertiary:   darkMode ? Qt.rgba(0.922, 0.922, 0.961, 0.30) : Qt.rgba(0.235, 0.235, 0.263, 0.30)
    readonly property color labelQuaternary: darkMode ? Qt.rgba(0.922, 0.922, 0.961, 0.16) : Qt.rgba(0.235, 0.235, 0.263, 0.18)

    // Fills Translúcidos para Píldoras, Fondos e Inputs
    readonly property color fillPrimary:    darkMode ? Qt.rgba(1.0, 1.0, 1.0, 0.14) : Qt.rgba(0, 0, 0, 0.08)
    readonly property color fillSecondary:  darkMode ? Qt.rgba(1.0, 1.0, 1.0, 0.22) : Qt.rgba(0, 0, 0, 0.14)
    readonly property color fillTertiary:   darkMode ? Qt.rgba(1.0, 1.0, 1.0, 0.08) : Qt.rgba(0, 0, 0, 0.05)
    readonly property color fillQuaternary: darkMode ? Qt.rgba(1.0, 1.0, 1.0, 0.04) : Qt.rgba(0, 0, 0, 0.03)

    // Separadores Oficiales
    readonly property color separator:       darkMode ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12)
    readonly property color separatorOpaque: darkMode ? "#38383a" : "#c6c6c8"

    // Superficies Translúcidas Liquid Glass (Gradientes Verticales Ópticos)
    // Small UI: Botones, cápsulas de estado, sliders, micro-pills
    readonly property color glassSmallTop: darkMode 
        ? Qt.rgba(0.60, 0.60, 0.64, 0.20) 
        : Qt.rgba(0.97, 0.97, 0.98, 0.65)
    readonly property color glassSmallBottom: darkMode 
        ? Qt.rgba(0.14, 0.14, 0.16, 0.35) 
        : Qt.rgba(0.93, 0.93, 0.95, 0.48)

    // Medium UI: Popovers, menús, centros de control, tarjetas flotantes
    readonly property color glassMediumTop: darkMode 
        ? (activePreset === "macos-dark" ? Qt.rgba(0.16, 0.16, 0.18, 0.76) : Qt.rgba(currentColors.bgSolid.r * 1.15, currentColors.bgSolid.g * 1.15, currentColors.bgSolid.b * 1.15, 0.78))
        : Qt.rgba(0.96, 0.96, 0.98, 0.82)
    readonly property color glassMediumBottom: darkMode 
        ? (activePreset === "macos-dark" ? Qt.rgba(0.09, 0.09, 0.11, 0.84) : Qt.rgba(currentColors.bgSolid.r * 0.9, currentColors.bgSolid.g * 0.9, currentColors.bgSolid.b * 0.9, 0.86))
        : Qt.rgba(0.88, 0.88, 0.91, 0.75)

    // Barra Superior de Menús y Dock Flotante (Gradientes calibrados de alta legibilidad)
    readonly property color glassBarTop: darkMode 
        ? (activePreset === "macos-dark" ? Qt.rgba(0.18, 0.18, 0.22, 0.72) : Qt.rgba(currentColors.bgSolid.r * 1.1, currentColors.bgSolid.g * 1.1, currentColors.bgSolid.b * 1.1, 0.72))
        : Qt.rgba(0.98, 0.98, 1.0, 0.78)
    readonly property color glassBarBottom: darkMode 
        ? (activePreset === "macos-dark" ? Qt.rgba(0.10, 0.10, 0.12, 0.82) : Qt.rgba(currentColors.bgSolid.r * 0.85, currentColors.bgSolid.g * 0.85, currentColors.bgSolid.b * 0.85, 0.82))
        : Qt.rgba(0.90, 0.90, 0.94, 0.80)
    readonly property color glassDock: darkMode 
        ? (activePreset === "macos-dark" ? Qt.rgba(0.20, 0.20, 0.22, 0.58) : Qt.rgba(currentColors.bgSolid.r * 1.2, currentColors.bgSolid.g * 1.2, currentColors.bgSolid.b * 1.2, 0.60))
        : Qt.rgba(0.60, 0.60, 0.62, 0.36)

    // Micro-Bisel Especular Sutil (Plus Lighter Reflection & Contorno Óptico)
    readonly property color specularTopRim:      darkMode ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(1, 1, 1, 0.40)
    readonly property color specularBorder:      darkMode ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(0, 0, 0, 0.12)
    readonly property color specularBorderHover: darkMode ? Qt.rgba(1, 1, 1, 0.32) : Qt.rgba(0, 0, 0, 0.24)

    // Radios Geométricos iOS 27 / macOS Tahoe
    readonly property int radiusXs: 6
    readonly property int radiusSm: 10
    readonly property int radiusMd: 14
    readonly property int radiusLg: 20
    readonly property int radiusXl: 24
    readonly property int radiusCapsule: 27

    // Dimensiones de Controles
    readonly property int btnSmallHeight: 28
    readonly property int btnMediumHeight: 34
    readonly property int btnLargeHeight: 50

    // Aliases for seamless backward compatibility across existing QML widgets
    readonly property color bg: backgroundColor
    readonly property color bgSolid: backgroundSolidColor
    readonly property color surface: surfaceColor
    readonly property color surfaceHover: surfaceHoverColor
    readonly property color surfaceActive: surfaceActiveColor
    readonly property color border: borderColor
    readonly property color borderHover: borderHoverColor
    readonly property color text: textPrimary
    readonly property color textMuted: textSecondary
    readonly property color textDisabled: textDisabledColor
    readonly property color accent: accentColor
    readonly property color accentHover: accentHoverColor
    readonly property color accentSecondary: accentSecondaryColor
    readonly property color success: successColor
    readonly property color warning: warningColor
    readonly property color danger: dangerColor

    // Font Loader for bundled Nerd Font glyphs
    FontLoader {
        id: nerdFontLoader
        source: "./assets/fonts/SymbolsNerdFont-Regular.ttf"
    }

    // Typography: SF Pro with Inter and native system fallbacks
    property string fontFamily: "SF Pro, SF Pro Display, SF Pro Text, Inter, -apple-system, BlinkMacSystemFont, sans-serif"
    property string fontMono: "SF Mono, JetBrainsMono Nerd Font, JetBrains Mono, monospace"
    property string fontIcons: (nerdFontLoader.name.length > 0) ? nerdFontLoader.name : "Symbols Nerd Font, JetBrainsMono Nerd Font, monospace"

    // macOS Typographic Hierarchy
    property int fontSizeTiny: 9
    property int fontSizeSmall: 11
    property int fontSizeRegular: 12
    property int fontSizeMedium: 13
    property int fontSizeLarge: 15
    property int fontSizeTitle: 18

    // Sizing & Radii calibrated to macOS Sonoma / Sequoia
    property int barHeight: 28
    property int barMargin: 0
    property int barRadius: 0
    property int pillRadius: 6
    property int cardRadius: 14
    property int dockRadius: 20
    property int dockPadding: 8
    property int dockSpacing: 6
    property int spacing: 6
    property int padding: 6
    property int iconSize: 13
    property int iconSizeLarge: 20

    // Animations (Apple standard: snappy, natural, easing OutCubic)
    property int animFast: 140
    property int animNormal: 220
    property int animSlow: 320
    property int animEasing: Easing.OutCubic
}
