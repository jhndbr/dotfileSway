#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║        Swayidle Script                                       ║
# ╚══════════════════════════════════════════════════════════════╝
# Script para iniciar swayidle con los timeouts deseados.

exec swayidle -w \
    timeout 300 'swaylock -f' \
    timeout 600 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' \
    timeout 1800 'systemctl suspend' \
    before-sleep 'swaylock -f' \
    lock 'swaylock -f'
