#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║        Menú de Capturas de Pantalla                         ║
# ╚══════════════════════════════════════════════════════════════╝

# Directorio de capturas
DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
FILE="$DIR/$(date +%Y%m%d_%H%M%S).png"

# Opciones para Wofi
OPCIONES="󰹑    Pantalla completa\n󰒉    Seleccionar área\n󰖲    Ventana activa\n󱎫    Área con delay (3s)"

# Seleccionar a través de Wofi dmenu
SELECCION=$(echo -e "$OPCIONES" | wofi --dmenu \
    --prompt "  󰄀  Captura de Pantalla" \
    --cache-file /dev/null \
    --insensitive \
    --width 360 \
    --height 230 \
    --lines 4)

case "$SELECCION" in
    *"Pantalla completa"*)
        grim "$FILE"
        wl-copy < "$FILE"
        dunstify -a "Screenshot" -r 9940 -i "$FILE" "📸 Captura Guardada" "Pantalla completa copiada al portapapeles"
        ;;
    *"Seleccionar área"*)
        grim -g "$(slurp -d -b 1c1c1eaa -c ffffffff -s ffffff20 -w 1)" - | tee "$FILE" | wl-copy
        dunstify -a "Screenshot" -r 9940 -i "$FILE" "📸 Captura Guardada" "Área seleccionada copiada al portapapeles"
        ;;
    *"Ventana activa"*)
        GEOMETRY=$(swaymsg -t get_tree | jq -r '.. | select(.focused?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')
        if [ -n "$GEOMETRY" ]; then
            grim -g "$GEOMETRY" "$FILE"
            wl-copy < "$FILE"
            dunstify -a "Screenshot" -r 9940 -i "$FILE" "📸 Captura Guardada" "Ventana activa copiada al portapapeles"
        fi
        ;;
    *"Área con delay"*)
        dunstify -a "Screenshot" -r 9940 "⏱️ Captura con Retardo" "Selecciona el área en 3 segundos..."
        sleep 3
        grim -g "$(slurp -d -b 1c1c1eaa -c ffffffff -s ffffff20 -w 1)" - | tee "$FILE" | wl-copy
        dunstify -a "Screenshot" -r 9940 -i "$FILE" "📸 Captura Guardada" "Área capturada y copiada al portapapeles"
        ;;
esac
