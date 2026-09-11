#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║        Idle Script (compatible con MangoWM)                  ║
# ║        Usa wlr-randr para DPMS y gtklock para bloqueo         ║
# ╚══════════════════════════════════════════════════════════════╝
# Script para iniciar swayidle con los timeouts deseados.
# swayidle es el daemon de idle estándar de wlroots (no depende del WM Sway).
# MangoWM no expone "output * dpms" vía IPC, así que se usa wlr-randr.

MM="$HOME/.local/bin/monitor-manager.sh"
[ -x "$MM" ] || MM="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/monitor-manager.sh"

exec swayidle -w \
    timeout 300 'gtklock' \
    timeout 600 "$MM dpms-off" resume "$MM dpms-on" \
    timeout 1800 'systemctl suspend' \
    before-sleep 'gtklock' \
    lock 'gtklock'
