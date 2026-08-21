#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║        Notificador Inteligente de Batería Baja               ║
# ║        Ligero, sin polling agresivo (1 ciclo cada 60s)       ║
# ╚══════════════════════════════════════════════════════════════╝

# Verificar si hay batería en el equipo (si es PC de escritorio, salir)
BAT=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n 1)

if [ -z "$BAT" ]; then
    exit 0
fi

NOTIFIED_15=false
NOTIFIED_5=false

while true; do
    if [ -f "$BAT/capacity" ] && [ -f "$BAT/status" ]; then
        CAPACITY=$(cat "$BAT/capacity")
        STATUS=$(cat "$BAT/status")

        if [ "$STATUS" = "Discharging" ]; then
            if [ "$CAPACITY" -le 5 ] && [ "$NOTIFIED_5" = false ]; then
                dunstify -a "Batería" -u critical -r 9940 \
                    "🪫 BATERÍA CRÍTICA (${CAPACITY}%)" \
                    "Conectá el cargador de inmediato para no perder tu trabajo."
                NOTIFIED_5=true
                NOTIFIED_15=true
            elif [ "$CAPACITY" -le 15 ] && [ "$CAPACITY" -gt 5 ] && [ "$NOTIFIED_15" = false ]; then
                dunstify -a "Batería" -u normal -r 9940 \
                    "⚠️ Batería Baja (${CAPACITY}%)" \
                    "Te queda poca batería. Considerá conectar el cargador."
                NOTIFIED_15=true
            fi
        else
            # Si está cargando o lleno, resetear alertas
            NOTIFIED_15=false
            NOTIFIED_5=false
        fi
    fi
    sleep 60
done
