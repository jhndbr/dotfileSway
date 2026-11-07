#!/bin/sh
# Wofi Power Menu - Minimalist, Monochromatic & Modern

OPTIONS="🔒  Bloquear\n💤  Suspender\n⚡  Perfil de Energía\n🚪  Cerrar Sesión\n🔄  Reiniciar\n🛑  Apagar"

CHOSEN=$(printf "$OPTIONS" | wofi --dmenu --prompt "Sistema" --width 280 --height 280 --insensitive --lines 6)

case "$CHOSEN" in
    *"Bloquear"*)
        swaylock -f
        ;;
    *"Suspender"*)
        swaylock -f; systemctl suspend
        ;;
    *"Perfil de Energía"*)
        ~/.config/sway/scripts/power.sh menu
        ;;
    *"Cerrar Sesión"*)
        swaymsg exit
        ;;
    *"Reiniciar"*)
        systemctl reboot
        ;;
    *"Apagar"*)
        systemctl poweroff
        ;;
esac
