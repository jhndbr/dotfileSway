#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║        Swayidle Script                                       ║
# ╚══════════════════════════════════════════════════════════════╝
# Si el modo cafeína está activo, no iniciar el temporizador de inactividad
if [ -f "$HOME/.config/caffeine_active" ] || [ -f "${XDG_RUNTIME_DIR:-/tmp}/caffeine_active" ]; then
    exit 0
fi

exec swayidle -w \
    timeout 300 'swaylock -f' \
    timeout 600 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' \
    timeout 1800 'systemctl suspend' \
    before-sleep 'swaylock -f' \
    lock 'swaylock -f'
