#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║        Gammastep Toggle Script (Persistente)                 ║
# ║        Activa / Desactiva el filtro de luz azul               ║
# ╚══════════════════════════════════════════════════════════════╝

STATE_FILE="$HOME/.config/gammastep/state"
mkdir -p "$HOME/.config/gammastep"

is_enabled() {
    if [ -f "$STATE_FILE" ]; then
        grep -q "enabled" "$STATE_FILE"
    else
        true # Por defecto activado si no existe archivo
    fi
}

start_gammastep() {
    if ! pgrep -x gammastep > /dev/null; then
        gammastep -l -34.6:-58.4 -t 6500:3500 -m wayland &
    fi
    echo "enabled" > "$STATE_FILE"
    notify-send -a "Gammastep" -r 9923 "🌙 Luz Cálida" "Filtro de luz azul activado (3500K - Permanente)"
}

stop_gammastep() {
    pkill -x gammastep 2>/dev/null || true
    echo "disabled" > "$STATE_FILE"
    notify-send -a "Gammastep" -r 9923 "☀️ Luz Cálida" "Filtro de luz azul desactivado (Permanente)"
}

case "$1" in
    autostart)
        if is_enabled; then
            if ! pgrep -x gammastep > /dev/null; then
                gammastep -l -34.6:-58.4 -t 6500:3500 -m wayland &
            fi
        fi
        ;;
    on|enable)
        start_gammastep
        ;;
    off|disable)
        stop_gammastep
        ;;
    status)
        if pgrep -x gammastep > /dev/null; then
            echo "active"
            exit 0
        else
            echo "inactive"
            exit 1
        fi
        ;;
    *)
        if pgrep -x gammastep > /dev/null; then
            stop_gammastep
        else
            start_gammastep
        fi
        ;;
esac
