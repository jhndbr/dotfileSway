#!/bin/sh
# Laptop Lid Event Handler for Sway
# If an external monitor is connected, only disables the laptop screen.
# If no external monitor is connected, locks and suspends the laptop.

ACTION="${1:-close}"

case "$ACTION" in
    close)
        # Contar cuántas salidas activas/conectadas existen
        OUTPUT_COUNT=$(swaymsg -t get_outputs 2>/dev/null | grep -c '"name":')
        if [ "$OUTPUT_COUNT" -gt 1 ]; then
            # Monitor externo activo: apagar sólo la pantalla integrada
            swaymsg "output eDP-1 disable"
        else
            # Sólo pantalla de notebook: bloquear y suspender
            swaylock -f; systemctl suspend
        fi
        ;;
    open)
        # Reactivar pantalla integrada y activar DPMS
        swaymsg "output eDP-1 enable"
        swaymsg "output * dpms on"
        ;;
esac
