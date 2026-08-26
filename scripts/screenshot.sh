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
        # MangoWM no expone la geometría de ventana vía IPC.
        # Capturamos la salida (monitor) enfocada con grim -o.
        FOCUSED_OUT=$(mmsg -g -o 2>/dev/null | awk 'NR==1{print $1}')
        if [ -n "$FOCUSED_OUT" ]; then
            grim -o "$FOCUSED_OUT" "$FILE" && wl-copy < "$FILE" && notify-send -i "$FILE" "📸 Screenshot" "Salida activa ($FOCUSED_OUT) guardada y copiada al portapapeles."
        else
            notify-send "📸 Screenshot" "No se pudo determinar la salida activa."
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
