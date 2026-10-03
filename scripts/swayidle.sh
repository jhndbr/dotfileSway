#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║        Swayidle Script                                       ║
# ╚══════════════════════════════════════════════════════════════╝
# Si el modo cafeína está activo, no iniciar el temporizador de inactividad
if [ -f "$HOME/.config/caffeine_active" ] || [ -f "${XDG_RUNTIME_DIR:-/tmp}/caffeine_active" ]; then
    exit 0
fi

# Comando DPMS para MangoWM / Wayland vía wlopm
DPMS_OFF="wlopm --off '*' 2>/dev/null || true"
DPMS_ON="wlopm --on '*' 2>/dev/null || true"


exec swayidle -w \
    timeout 300 'swaylock -f' \
    timeout 600 "$DPMS_OFF" resume "$DPMS_ON" \
    timeout 1800 'systemctl suspend' \
    before-sleep 'swaylock -f' \
    lock 'swaylock -f'

