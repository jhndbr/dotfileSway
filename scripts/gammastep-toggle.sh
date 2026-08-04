#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║        Gammastep Toggle Script                               ║
# ║        Activa / Desactiva el filtro de luz azul               ║
# ╚══════════════════════════════════════════════════════════════╝

if pgrep -x gammastep > /dev/null; then
    pkill -x gammastep
    notify-send -a "Gammastep" -r 9923 "☀️ Luz Cálida" "Filtro de luz azul desactivado"
else
    gammastep -l -34.6:-58.4 -t 6500:3500 -m wayland &
    notify-send -a "Gammastep" -r 9923 "🌙 Luz Cálida" "Filtro de luz azul activado (3500K)"
fi
