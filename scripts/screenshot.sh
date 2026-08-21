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
        grim "$FILE" && wl-copy < "$FILE" && notify-send -i "$FILE" "📸 Screenshot" "Pantalla completa guardada y copiada al portapapeles."
        ;;
    "Seleccionar área")
        GEOMETRY=$(slurp -d -b 1c1c1eaa -c ffffffff -s ffffff20 -w 1)
        if [ -n "$GEOMETRY" ]; then
            grim -g "$GEOMETRY" "$FILE" && wl-copy < "$FILE" && notify-send -i "$FILE" "📸 Screenshot" "Área seleccionada guardada y copiada al portapapeles."
        fi
        ;;
    "Ventana activa")
        GEOMETRY=$(swaymsg -t get_tree | jq -r '.. | select(.focused?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')
        if [ -n "$GEOMETRY" ] && [ "$GEOMETRY" != "null" ]; then
            grim -g "$GEOMETRY" "$FILE" && wl-copy < "$FILE" && notify-send -i "$FILE" "📸 Screenshot" "Ventana activa guardada y copiada al portapapeles."
        fi
        ;;
    "Área con delay (3s)")
        notify-send "📸 Screenshot" "Selecciona el área en 3 segundos..."
        sleep 3
        GEOMETRY=$(slurp -d -b 1c1c1eaa -c ffffffff -s ffffff20 -w 1)
        if [ -n "$GEOMETRY" ]; then
            grim -g "$GEOMETRY" "$FILE" && wl-copy < "$FILE" && notify-send -i "$FILE" "📸 Screenshot" "Área capturada y copiada al portapapeles."
        fi
        ;;
esac
