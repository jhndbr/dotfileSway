#!/usr/bin/env bash
# SwayShell launcher wrapper
export QT_QPA_PLATFORM="wayland;xcb"
export QT_QPA_PLATFORMTHEME="qt6ct"
export QT_PLUGIN_PATH="$HOME/.local/lib/qt5/plugins${QT_PLUGIN_PATH:+:$QT_PLUGIN_PATH}"
export GTK_THEME="adw-gtk3-dark"
export XDG_CURRENT_DESKTOP="sway"
export XDG_SESSION_TYPE="wayland"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QUICKSHELL_BIN="$(command -v quickshell 2>/dev/null || ([ -x /usr/local/bin/quickshell ] && echo /usr/local/bin/quickshell) || echo "$HOME/.local/bin/quickshell")"
CONFIG_PATH="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/swayshell"

if [ -x "$QUICKSHELL_BIN" ]; then
    if [ "$1" = "ipc" ]; then
        shift
        exec "$QUICKSHELL_BIN" ipc --any-display -p "$CONFIG_PATH" "$@"
    fi

    # Ensure environment is shared with systemd and D-Bus so desktop portals and apps launch instantly
    if [ -n "$WAYLAND_DISPLAY" ]; then
        systemctl --user import-environment WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP XDG_SESSION_TYPE DISPLAY QT_QPA_PLATFORM QT_QPA_PLATFORMTHEME QT_PLUGIN_PATH GTK_THEME 2>/dev/null || true
        dbus-update-activation-environment --systemd WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP XDG_SESSION_TYPE DISPLAY QT_QPA_PLATFORM QT_QPA_PLATFORMTHEME QT_PLUGIN_PATH GTK_THEME 2>/dev/null || true
        systemctl --user restart xdg-desktop-portal 2>/dev/null || true
    fi

    # Liberar el servicio provisional de notificaciones si estaba activo
    pkill -f "notify-fallback.py" 2>/dev/null || true
    pkill -x quickshell 2>/dev/null || true
    sleep 0.2
    exec "$QUICKSHELL_BIN" -n -p "$CONFIG_PATH" "$@"
else
    exec python3 "$SCRIPT_DIR/notify-fallback.py"
fi
