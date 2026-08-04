#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║        Menú de Capturas de Pantalla                         ║
# ╚══════════════════════════════════════════════════════════════╝

# Directorio de capturas
DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
FILE="$DIR/$(date +%Y%m%d_%H%M%S).png"

# Opciones para Wofi
OPCIONES="Pantalla completa\nSeleccionar área\nVentana activa\nÁrea con delay (3s)"

# Seleccionar a través de Wofi dmenu
SELECCION=$(echo -e "$OPCIONES" | wofi --dmenu --prompt "Captura:" -i)

case "$SELECCION" in
    "Pantalla completa")
        grim "$FILE"
        wl-copy < "$FILE"
        notify-send "Captura Guardada" "Pantalla completa copiada al portapapeles."
        ;;
    "Seleccionar área")
        grim -g "$(slurp)" - | tee "$FILE" | wl-copy
        notify-send "Captura Guardada" "Área seleccionada copiada al portapapeles."
        ;;
    "Ventana activa")
        # Obtener las coordenadas de la ventana enfocada usando swaymsg
        GEOMETRY=$(swaymsg -t get_tree | jq -r '.. | select(.focused?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')
        if [ -n "$GEOMETRY" ]; then
            grim -g "$GEOMETRY" "$FILE"
            wl-copy < "$FILE"
            notify-send "Captura Guardada" "Ventana activa copiada al portapapeles."
        fi
        ;;
    "Área con delay (3s)")
        notify-send "Captura de Pantalla" "Selecciona el área en 3 segundos..."
        sleep 3
        grim -g "$(slurp)" - | tee "$FILE" | wl-copy
        notify-send "Captura Guardada" "Área capturada y copiada al portapapeles."
        ;;
esac
