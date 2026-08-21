#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║        Caffeine Toggle Script                                ║
# ║        Inhibe la suspensión y bloqueo por inactividad        ║
# ╚══════════════════════════════════════════════════════════════╝

STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/caffeine_active"
SCRIPTS_DIR="$HOME/.local/bin"

notify() {
    local icon="$1"
    local title="$2"
    local msg="$3"
    if command -v dunstify &>/dev/null; then
        dunstify -a "Modo Cafeína" -r 9940 -u low "$icon $title" "$msg"
    elif command -v notify-send &>/dev/null; then
        notify-send -a "Modo Cafeína" -r 9940 "$icon $title" "$msg"
    fi
}

is_active() {
    [ -f "$STATE_FILE" ]
}

enable_caffeine() {
    touch "$STATE_FILE"
    if pgrep -x swayidle >/dev/null; then
        pkill -STOP -x swayidle 2>/dev/null || true
    fi
    notify "󰅶" "Modo Cafeína" "Activado — Pantalla y sesión siempre activas"
}

disable_caffeine() {
    rm -f "$STATE_FILE"
    if pgrep -x swayidle >/dev/null; then
        pkill -CONT -x swayidle 2>/dev/null || true
    else
        if [ -x "$SCRIPTS_DIR/swayidle.sh" ]; then
            "$SCRIPTS_DIR/swayidle.sh" &
        elif [ -x "$(dirname "$0")/swayidle.sh" ]; then
            "$(dirname "$0")/swayidle.sh" &
        fi
    fi
    notify "󰾪" "Modo Cafeína" "Desactivado — Temporizador de inactividad reanudado"
}

case "$1" in
    on|enable)
        enable_caffeine
        ;;
    off|disable)
        disable_caffeine
        ;;
    status)
        if is_active; then
            echo "active"
            exit 0
        else
            echo "inactive"
            exit 1
        fi
        ;;
    *)
        if is_active; then
            disable_caffeine
        else
            enable_caffeine
        fi
        ;;
esac
