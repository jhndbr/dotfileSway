pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: config

    // Theme selector: "macos-dark" | "macos-light" | "catppuccin" | "tokyonight" | "nord" | "gruvbox" | "oled"
    property string activeTheme: "macos-dark"
    property string customAccentColor: ""

    // macOS / Linux Dock settings
    property bool dockEnabled: true
    property int dockHeight: 54
    property int dockIconSize: 40
    property bool dockMagnification: true
    property bool dockShowTooltips: false    // Suppress app name badges on dock zoom
    property bool dockAutoHide: false
    property int dockMarginBottom: 8
    property var dockPinnedApps: [
        "org.gnome.Nautilus",
        "firefox-esr",
        "brave-browser",
        "foot",
        "dev.zed.Zed"
    ]

    // Bar layout settings
    property string barPosition: "top"        // "top" or "bottom"
    property bool floatingBar: false         // false = edge-to-edge sleek top bar
    property int barHeight: 28               // Sleek compact height
    property int barMarginHorizontal: 0
    property int barMarginVertical: 0
    property int barSpacing: 6

    // Distro / Linux Logo
    property string distroLogoIcon: "󰌽"      // Linux Tux "󰌽" or Debian ""
    property string appleLogoIcon: distroLogoIcon
    property bool showControlCenter: true   // Dedicated macOS Control Center sliders toggle
    property bool showSpotlightButton: false // Search icon removed
    property bool showClipboard: false       // Clipboard icon removed (Mod+V used)

    // Active modules toggles
    property bool showWorkspaces: true
    property bool showFocusedWindow: true
    property bool showMedia: true
    property bool showAiChat: true           // Gemini AI CLI Chat overlay
    property string mediaPosition: "right"   // "right" or "center"
    property bool showTray: true
    property bool showNetwork: false
    property bool showAudio: false
    property bool showBrightness: true       // MSI Notebook backlight control
    property bool showBattery: true          // MSI Notebook battery monitor
    property bool showClock: true
    property bool showPowerButton: true

    // Clock format
    property bool clock24h: false
    property string clockFormat: clock24h ? "hh:mm" : "hh:mm AP"
    property string dateFormat: "ddd, MMM d"

    // Notifications
    property int notificationTimeout: 5500   // ms before auto-dismiss
    property int maxNotificationsVisible: 5

    // OSD (Volume / Brightness)
    property int osdTimeout: 1800             // ms before auto-hide
    property bool showVolumeOsd: true
    property bool showBrightnessOsd: true

    // App Launcher
    property int launcherWidth: 520
    property int launcherMaxResults: 8

    // Storage for theme and accent persistence
    FileView {
        id: settingsStorage
        path: Quickshell.env("HOME") + "/.config/quickshell/swayshell/settings.json"

        onLoaded: {
            const raw = settingsStorage.text();
            if (!raw || !raw.trim()) return;
            try {
                const data = JSON.parse(raw);
                if (data.theme && data.theme.length > 0) {
                    config.activeTheme = data.theme;
                    Theme.activePreset = data.theme;
                }
                if (data.accent && data.accent.length > 0) {
                    config.customAccentColor = data.accent;
                    Theme.userAccent = data.accent;
                }
            } catch (e) {
                console.warn("[Config] Error parsing settings.json:", e);
            }
        }

        onLoadFailed: error => {
            if (error == FileViewError.FileNotFound) {
                saveSettings();
            }
        }
    }

    function saveSettings() {
        try {
            settingsStorage.setText(JSON.stringify({
                "theme": config.activeTheme,
                "accent": config.customAccentColor
            }, null, 2));
        } catch (e) {
            console.warn("[Config] Error saving settings.json:", e);
        }
    }

    // Process to apply GTK, Qt, Foot and Sway theme dynamically
    Process {
        id: themeProc
        running: false
    }

    function applySystemTheme(themeName, accentHex) {
        Theme.activePreset = themeName;
        const acc = (accentHex !== undefined) ? accentHex : config.customAccentColor;
        const cmd = [Quickshell.env("HOME") + "/.config/quickshell/swayshell/scripts/apply-theme.sh", themeName];
        if (acc && acc.length > 0) {
            cmd.push(acc);
        }
        themeProc.command = cmd;
        themeProc.running = true;
    }

    function setAccent(hex) {
        config.customAccentColor = hex;
        Theme.userAccent = hex;
        saveSettings();
        applySystemTheme(activeTheme, hex);
    }

    function setTheme(themeName) {
        config.activeTheme = themeName;
        saveSettings();
    }

    // Keep Theme synced across Quickshell, GTK, Qt & Sway
    onActiveThemeChanged: {
        applySystemTheme(activeTheme, customAccentColor);
    }
    onCustomAccentColorChanged: {
        Theme.userAccent = customAccentColor;
    }
}
