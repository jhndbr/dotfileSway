#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║        Selector de Color (Color Picker)                      ║
# ╚══════════════════════════════════════════════════════════════╝

# Selecciona un punto de la pantalla, lo convierte a ppm y luego obtiene el color en hex
COLOR=$(grim -g "$(slurp -p)" -t ppm - | convert - -format '%[hex:p{0,0}]' info:)

if [ -n "$COLOR" ]; then
    # Añadir prefijo #
    HEX="#${COLOR}"
    
    # Copiar al portapapeles usando wl-clipboard
    echo -n "$HEX" | wl-copy
    
    # Enviar notificación
    dunstify -a 'Color Picker' -r 9995 -u normal "Color copiado" "El color <b>$HEX</b> ha sido copiado al portapapeles."
fi
