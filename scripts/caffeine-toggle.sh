#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║        Modo Cafeína (Inhibir Reposo y Bloqueo de Pantalla)   ║
# ║        Evita que la pantalla se apague o suspenda con Sway   ║
# ╚══════════════════════════════════════════════════════════════╝

STATE_FILE="$HOME/.cache/caffeine-active"

notify() {
    local title="$1"
    local msg="$2"
    local icon="$3"
    if command -v dunstify &>/dev/null; then
        dunstify -a "Cafeína" -r 9940 -u normal -i "$icon" "$title" "$msg"
    elif command -v notify-send &>/dev/null; then
        notify-send -a "Cafeína" -u normal -i "$icon" "$title" "$msg"
    fi
}

is_active() {
    if [ -f "$STATE_FILE" ] || ! pgrep -x swayidle > /dev/null; then
        return 0
    else
        return 1
    fi
}

enable_caffeine() {
    mkdir -p "$(dirname "$STATE_FILE")"
    touch "$STATE_FILE"
    killall -9 swayidle 2>/dev/null || true
    notify "󰅶 Modo Cafeína Activado" "Pantalla siempre activa (bloqueo y reposo suspendidos)" "preferences-desktop-screensaver"
}

disable_caffeine() {
    rm -f "$STATE_FILE"
    if ! pgrep -x swayidle > /dev/null; then
        if [ -f "$HOME/.local/bin/swayidle.sh" ]; then
            bash "$HOME/.local/bin/swayidle.sh" &>/dev/null &
        else
            exec swayidle -w \
                timeout 300 'swaylock -f' \
                timeout 600 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' \
                timeout 1800 'systemctl suspend' \
                before-sleep 'swaylock -f' \
                lock 'swaylock -f' &>/dev/null &
        fi
    fi
    notify "󰾪 Modo Cafeína Desactivado" "Modo de reposo y bloqueo reactivados" "preferences-desktop-screensaver"
}

case "$1" in
    status)
        if is_active; then
            echo "active"
        else
            echo "inactive"
        fi
        ;;
    enable)
        enable_caffeine
        ;;
    disable)
        disable_caffeine
        ;;
    toggle|*)
        if is_active; then
            disable_caffeine
        else
            enable_caffeine
        fi
        ;;
esac
