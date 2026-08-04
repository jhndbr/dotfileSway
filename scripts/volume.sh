#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║        Control de Volumen                                   ║
# ╚══════════════════════════════════════════════════════════════╝

SINK="@DEFAULT_SINK@"

# Función para obtener y notificar el estado actual
notificar() {
    # Extraer el porcentaje de volumen
    VOL=$(pactl get-sink-volume $SINK | grep -Po '\d+(?=%)' | head -n 1)
    # Extraer el estado de silencio (yes/no)
    MUTE=$(pactl get-sink-mute $SINK | grep -o 'yes\|no')

    if [ "$MUTE" = "yes" ] || [ "$VOL" -eq 0 ]; then
        ICON="🔇"
        dunstify -a 'Volume' -r 9993 -u low -h string:x-dunst-stack-tag:volume "Volumen: Silenciado" "$ICON"
    else
        ICON="🔊"
        dunstify -a 'Volume' -r 9993 -u low -h int:value:"$VOL" -h string:x-dunst-stack-tag:volume "Volumen: ${VOL}%" "$ICON"
    fi
}

case "$1" in
    up)
        pactl set-sink-volume $SINK +5%
        notificar
        ;;
    down)
        pactl set-sink-volume $SINK -5%
        notificar
        ;;
    mute)
        pactl set-sink-mute $SINK toggle
        notificar
        ;;
    *)
        echo "Uso: $0 {up|down|mute}"
        exit 1
        ;;
esac
