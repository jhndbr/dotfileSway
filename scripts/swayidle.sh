#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║        Swayidle Script (compatible con MangoWM)              ║
# ║        Usa wlr-randr para DPMS y swaylock para bloqueo        ║
# ╚══════════════════════════════════════════════════════════════╝
# Script para iniciar swayidle con los timeouts deseados.
# MangoWM no expone "output * dpms" vía IPC, así que se usa wlr-randr.

exec swayidle -w \
    timeout 300 'swaylock -f' \
    timeout 600 'wlr-randr --output "*" --off' resume 'wlr-randr --output "*" --on' \
    timeout 1800 'systemctl suspend' \
    before-sleep 'swaylock -f' \
    lock 'swaylock -f'
