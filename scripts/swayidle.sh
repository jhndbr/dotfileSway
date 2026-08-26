#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║        Idle Script (compatible con MangoWM)                  ║
# ║        Usa wlr-randr para DPMS y gtklock para bloqueo         ║
# ╚══════════════════════════════════════════════════════════════╝
# Script para iniciar swayidle con los timeouts deseados.
# swayidle es el daemon de idle estándar de wlroots (no depende del WM Sway).
# MangoWM no expone "output * dpms" vía IPC, así que se usa wlr-randr.

exec swayidle -w \
    timeout 300 'gtklock' \
    timeout 600 'wlr-randr --output "*" --off' resume 'wlr-randr --output "*" --on' \
    timeout 1800 'systemctl suspend' \
    before-sleep 'gtklock' \
    lock 'gtklock'
