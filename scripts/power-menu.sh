#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║        Menú de Apagado / Sesión (reemplazo de wlogout)      ║
# ║        Usa Wofi como selector + MangoWM/Systemd nativo       ║
# ╚══════════════════════════════════════════════════════════════╝

LOCK_CMD="gtklock"

OPCIONES="  Bloquear\n  Cerrar Sesión\n  Suspender\n  Reiniciar\n  Apagar"

SELECCION=$(echo -e "$OPCIONES" | wofi --dmenu \
    --prompt "Sesión" \
    --cache-file /dev/null \
    --insensitive \
    --width 280 \
    --height 260 \
    --lines 5)

case "$SELECCION" in
    *"Bloquear"*)
        $LOCK_CMD
        ;;
    *"Cerrar Sesión"*)
        mmsg -d quit
        ;;
    *"Suspender"*)
        $LOCK_CMD && systemctl suspend
        ;;
    *"Reiniciar"*)
        systemctl reboot
        ;;
    *"Apagar"*)
        systemctl poweroff
        ;;
esac
