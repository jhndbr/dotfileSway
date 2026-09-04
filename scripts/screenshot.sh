#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║        Menú de Capturas de Pantalla                         ║
# ╚══════════════════════════════════════════════════════════════╝

# Directorio de capturas
DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
FILE="$DIR/$(date +%Y%m%d_%H%M%S).png"

# Opciones para Wofi
OPCIONES="Seleccionar área (Guardar y Copiar)\nSeleccionar área (Solo Guardar)\nSeleccionar área (Solo Copiar)\nPantalla completa\nVentana activa\nÁrea con delay (3s)"

# Seleccionar a través de Wofi dmenu
SELECCION=$(echo -e "$OPCIONES" | wofi --dmenu --prompt "Captura de Pantalla:" -i --width 340 --height 270 --lines 6)

case "$SELECCION" in
    "Seleccionar área (Guardar y Copiar)")
        GEOMETRY=$(slurp -d -b 1c1c1eaa -c ffffffff -s ffffff20 -w 1)
        if [ -n "$GEOMETRY" ]; then
            grim -g "$GEOMETRY" "$FILE" && wl-copy < "$FILE" && notify-send -i "$FILE" "📸 Screenshot" "Área guardada en Screenshots y copiada al portapapeles."
        fi
        ;;
    "Seleccionar área (Solo Guardar)")
        GEOMETRY=$(slurp -d -b 1c1c1eaa -c ffffffff -s ffffff20 -w 1)
        if [ -n "$GEOMETRY" ]; then
            grim -g "$GEOMETRY" "$FILE" && notify-send -i "$FILE" "📸 Screenshot" "Área guardada en Screenshots (sin copiar al portapapeles)."
        fi
        ;;
    "Seleccionar área (Solo Copiar)")
        GEOMETRY=$(slurp -d -b 1c1c1eaa -c ffffffff -s ffffff20 -w 1)
        if [ -n "$GEOMETRY" ]; then
            grim -g "$GEOMETRY" - | wl-copy && notify-send "📸 Screenshot" "Área copiada al portapapeles (sin guardar archivo)."
        fi
        ;;
    "Pantalla completa")
        grim "$FILE" && wl-copy < "$FILE" && notify-send -i "$FILE" "📸 Screenshot" "Pantalla completa guardada y copiada al portapapeles."
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
