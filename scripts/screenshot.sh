#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║        Menú Completo de Capturas de Pantalla (5 Opciones)    ║
# ╚══════════════════════════════════════════════════════════════╝

# Directorio de capturas
DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
FILENAME="$(date +%Y%m%d_%H%M%S).png"
FILE="$DIR/$FILENAME"

# 5 Opciones para Wofi
OPCIONES="󰹑    Pantalla completa (Guardar y Copiar)\n󰒉    Seleccionar área (Solo Copiar al portapapeles)\n󰒉    Seleccionar área (Solo Guardar archivo)\n󰒉    Seleccionar área (Guardar y Copiar)\n󰖲    Ventana activa (Guardar y Copiar)"

# Seleccionar a través de Wofi dmenu
SELECCION=$(echo -e "$OPCIONES" | wofi --dmenu \
    --prompt "  󰄀  Captura de Pantalla" \
    --cache-file /dev/null \
    --insensitive \
    --width 460 \
    --height 275 \
    --lines 5)

[ -z "$SELECCION" ] && exit 0

case "$SELECCION" in
    *"Pantalla completa (Guardar y Copiar)"*)
        grim "$FILE"
        wl-copy < "$FILE"
        dunstify -a "Screenshot" -r 9940 -i "$FILE" "📸 Pantalla Completa" "Guardada en Screenshots/$FILENAME y copiada"
        ;;
    *"Seleccionar área (Solo Copiar al portapapeles)"*)
        GEOM=$(slurp -d -b 1c1c1eaa -c ffffffff -s ffffff20 -w 1)
        if [ -n "$GEOM" ]; then
            grim -g "$GEOM" - | wl-copy
            dunstify -a "Screenshot" -r 9940 "📸 Área Copiada" "Captura copiada al portapapeles (sin guardar archivo)"
        fi
        ;;
    *"Seleccionar área (Solo Guardar archivo)"*)
        GEOM=$(slurp -d -b 1c1c1eaa -c ffffffff -s ffffff20 -w 1)
        if [ -n "$GEOM" ]; then
            grim -g "$GEOM" "$FILE"
            dunstify -a "Screenshot" -r 9940 -i "$FILE" "📸 Área Guardada" "Guardada en Screenshots/$FILENAME (no copiada)"
        fi
        ;;
    *"Seleccionar área (Guardar y Copiar)"*)
        GEOM=$(slurp -d -b 1c1c1eaa -c ffffffff -s ffffff20 -w 1)
        if [ -n "$GEOM" ]; then
            grim -g "$GEOM" - | tee "$FILE" | wl-copy
            dunstify -a "Screenshot" -r 9940 -i "$FILE" "📸 Área Guardada y Copiada" "Guardada en Screenshots/$FILENAME y copiada"
        fi
        ;;
    *"Ventana activa (Guardar y Copiar)"*)
        GEOMETRY=$(swaymsg -t get_tree | jq -r '.. | select(.focused?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')
        if [ -n "$GEOMETRY" ]; then
            grim -g "$GEOMETRY" "$FILE"
            wl-copy < "$FILE"
            dunstify -a "Screenshot" -r 9940 -i "$FILE" "📸 Ventana Activa" "Ventana guardada en Screenshots/$FILENAME y copiada"
        fi
        ;;
esac
