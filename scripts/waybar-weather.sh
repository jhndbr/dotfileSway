#!/usr/bin/env bash

CACHE_FILE="/tmp/waybar_weather.json"
CACHE_MAX_AGE=900

fetch_weather() {
    DATA=$(curl -s --connect-timeout 4 "wttr.in/?format=%c;%t;%C;%h;%w&lang=es" 2>/dev/null)
    if [ -n "$DATA" ] && ! echo "$DATA" | grep -iq "unknown\|html"; then
        IFS=';' read -r ICON TEMP COND HUMID WIND <<< "$DATA"
        ICON=$(echo "$ICON" | xargs)
        TEMP=$(echo "$TEMP" | xargs)
        COND=$(echo "$COND" | xargs)
        HUMID=$(echo "$HUMID" | xargs)
        WIND=$(echo "$WIND" | xargs)
        
        [ -z "$ICON" ] && ICON="☁️"
        [ -z "$TEMP" ] && TEMP="--°C"
        
        TOOLTIP="Clima: $ICON $TEMP\nCondición: $COND\nHumedad: $HUMID\nViento: $WIND"
        echo "$ICON;$TEMP;$TOOLTIP" > "$CACHE_FILE"
    fi
}

if [ ! -f "$CACHE_FILE" ]; then
    fetch_weather
elif [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0))) -gt $CACHE_MAX_AGE ]; then
    fetch_weather &
fi

if [ -f "$CACHE_FILE" ]; then
    IFS=';' read -r ICON TEMP TOOLTIP < "$CACHE_FILE"
else
    ICON="☁️"
    TEMP="--°C"
    TOOLTIP="Obteniendo clima..."
fi

# Escapar saltos de línea para JSON seguro
SAFE_TOOLTIP=$(echo -e "$TOOLTIP" | sed ':a;N;$!ba;s/\n/\\n/g' | sed 's/"/\\"/g')

if [ "$1" = "text" ]; then
    echo "{\"text\": \"$TEMP\", \"tooltip\": \"$SAFE_TOOLTIP\", \"class\": \"weather-text\"}"
else
    echo "{\"text\": \"$ICON\", \"tooltip\": \"$SAFE_TOOLTIP\", \"class\": \"weather-icon\"}"
fi
