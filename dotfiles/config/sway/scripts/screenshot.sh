#!/bin/sh
# Screenshot helper for Sway (Debian)
# Minimalist, saves to ~/Imágenes/Capturas and copies to clipboard

DIR="${XDG_PICTURES_DIR:-$HOME/Imágenes}/Capturas"
mkdir -p "$DIR"
TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
FILE="$DIR/${TIMESTAMP}.png"

MODE="${1:-full}"

notify_shot() {
    MSG="$1"
    IMG="$2"
    if command -v notify-send >/dev/null 2>&1; then
        if [ -n "$IMG" ] && [ -f "$IMG" ]; then
            notify-send -t 2500 -i "$IMG" "Captura de pantalla" "$MSG"
        else
            notify-send -t 2000 "Captura de pantalla" "$MSG"
        fi
    fi
}

case "$MODE" in
    full)
        grim "$FILE"
        if [ -f "$FILE" ]; then
            if command -v wl-copy >/dev/null 2>&1; then
                wl-copy < "$FILE"
            fi
            notify_shot "Pantalla completa guardada y copiada" "$FILE"
        fi
        ;;
    area)
        if command -v slurp >/dev/null 2>&1; then
            GEOM=$(slurp)
            [ -z "$GEOM" ] && exit 0
            grim -g "$GEOM" "$FILE"
        else
            grim "$FILE"
        fi
        if [ -f "$FILE" ]; then
            if command -v wl-copy >/dev/null 2>&1; then
                wl-copy < "$FILE"
            fi
            notify_shot "Área seleccionada guardada y copiada" "$FILE"
        fi
        ;;
    copy-area)
        if command -v slurp >/dev/null 2>&1 && command -v wl-copy >/dev/null 2>&1; then
            GEOM=$(slurp)
            [ -z "$GEOM" ] && exit 0
            grim -g "$GEOM" - | wl-copy
            notify_shot "Área copiada al portapapeles" ""
        elif command -v wl-copy >/dev/null 2>&1; then
            grim - | wl-copy
            notify_shot "Pantalla copiada al portapapeles" ""
        fi
        ;;
    *)
        grim "$FILE"
        ;;
esac
