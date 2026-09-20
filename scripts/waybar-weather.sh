#!/usr/bin/env bash

CACHE_FILE="/tmp/waybar_weather.json"
CACHE_MAX_AGE=900

get_weather_icon() {
    local emoji="$1"
    local cond="$2"
    local hour
    hour=$(date +%H)
    local is_night=false
    if [ "$hour" -ge 20 ] || [ "$hour" -lt 7 ]; then
        is_night=true
    fi

    local cond_lower
    cond_lower=$(echo "$cond" | tr '[:upper:]' '[:lower:]')

    # Mapeo por emoji devuelto por wttr.in
    case "$emoji" in
        *☀️*|*🌞*)
            echo "󰖙" # weather-sunny
            return
            ;;
        *🌙*|*🌛*)
            echo "󰖔" # weather-night
            return
            ;;
        *⛅*)
            if [ "$is_night" = true ]; then
                echo "󰼱" # weather-night-partly-cloudy
            else
                echo "󰖕" # weather-partly-cloudy
            fi
            return
            ;;
        *☁*)
            echo "󰖐" # weather-cloudy
            return
            ;;
        *🌧*|*🌦*)
            echo "󰖖" # weather-pouring
            return
            ;;
        *⛈*|*🌩*|*⚡*)
            echo "󰙾" # weather-lightning-rainy
            return
            ;;
        *❄*|*🌨*)
            echo "󰖘" # weather-snowy
            return
            ;;
        *🌫*)
            echo "󰖑" # weather-fog
            return
            ;;
        *🌪*|*💨*|*🍃*)
            echo "󰖝" # weather-windy
            return
            ;;
    esac

    # Mapeo por condición textual (español e inglés)
    case "$cond_lower" in
        *despejado*|*soleado*|*clear*|*sunny*)
            [ "$is_night" = true ] && echo "󰖔" || echo "󰖙"
            ;;
        *parcialmente*|*partly*)
            [ "$is_night" = true ] && echo "󰼱" || echo "󰖕"
            ;;
        *nublado*|*cubierto*|*cloud*|*overcast*)
            echo "󰖐"
            ;;
        *tormenta*|*trueno*|*thunder*|*storm*)
            echo "󰙾"
            ;;
        *llovizna*|*drizzle*)
            echo "󰖗"
            ;;
        *lluvia*|*aguacero*|*chubasco*|*rain*|*shower*)
            echo "󰖖"
            ;;
        *nieve*|*nevada*|*snow*|*sleet*)
            echo "󰖘"
            ;;
        *niebla*|*neblina*|*bruma*|*fog*|*mist*)
            echo "󰖑"
            ;;
        *viento*|*ventoso*|*wind*)
            echo "󰖝"
            ;;
        *)
            [ "$is_night" = true ] && echo "󰖔" || echo "󰖙"
            ;;
    esac
}

fetch_weather() {
    DATA=$(curl -s --connect-timeout 4 "wttr.in/?format=%c;%t;%C;%h;%w&lang=es" 2>/dev/null)
    if [ -n "$DATA" ] && ! echo "$DATA" | grep -iq "unknown\|html"; then
        IFS=';' read -r EMOJI TEMP COND HUMID WIND <<< "$DATA"
        EMOJI=$(echo "$EMOJI" | xargs)
        TEMP=$(echo "$TEMP" | xargs)
        COND=$(echo "$COND" | xargs)
        HUMID=$(echo "$HUMID" | xargs)
        WIND=$(echo "$WIND" | xargs)
        
        ICON=$(get_weather_icon "$EMOJI" "$COND")
        [ -z "$ICON" ] && ICON="󰖐"
        [ -z "$TEMP" ] && TEMP="--°C"
        
        TOOLTIP="Clima: $COND $TEMP\nHumedad: $HUMID\nViento: $WIND"
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
    ICON="󰖐"
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
