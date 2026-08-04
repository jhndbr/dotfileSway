#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║        Control de Brillo                                    ║
# ╚══════════════════════════════════════════════════════════════╝

notificar() {
    # Extraer el porcentaje actual de brillo
    BRIGHT=$(brightnessctl info | grep -oP '\(\K[0-9]+(?=%\))')
    ICON="🔆"
    
    # Enviar notificación a dunst
    dunstify -a 'Brightness' -r 9994 -u low -h int:value:"$BRIGHT" -h string:x-dunst-stack-tag:brightness "Brillo: ${BRIGHT}%" "$ICON"
}

case "$1" in
    up)
        brightnessctl set 5%+
        notificar
        ;;
    down)
        brightnessctl set 5%-
        notificar
        ;;
    *)
        echo "Uso: $0 {up|down}"
        exit 1
        ;;
esac
