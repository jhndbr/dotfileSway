#!/bin/sh
# Swaybar status script - Minimalist, Elegant, Laptop Optimized
# Displays: Battery, Power Profile, RAM, Network, Brightness, Volume, Keyboard layout, Date & Time.

SCRIPTS_DIR="$(dirname "$0")"

while true; do
    # 1. Batería
    BAT_STR=""
    BAT_PATH=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n 1)
    if [ -n "$BAT_PATH" ] && [ -f "$BAT_PATH/capacity" ]; then
        CAP=$(cat "$BAT_PATH/capacity" 2>/dev/null)
        STAT=$(cat "$BAT_PATH/status" 2>/dev/null)
        case "$STAT" in
            Charging)    STAT_ICON="󰂄" ;;
            Discharging) STAT_ICON="󰁹" ;;
            Full)        STAT_ICON="󰂅" ;;
            *)           STAT_ICON="󰁹" ;;
        esac
        BAT_STR="$STAT_ICON ${CAP}%"

        # Alerta de batería baja (<= 15%)
        if [ "$STAT" = "Discharging" ] && [ -n "$CAP" ] && [ "$CAP" -le 15 ]; then
            if [ ! -f /tmp/bat_warn_sent ]; then
                notify-send -u critical "Batería Baja" "Nivel de batería: ${CAP}%. Conecta el cargador." 2>/dev/null
                touch /tmp/bat_warn_sent
            fi
        elif [ "$STAT" = "Charging" ] || [ -n "$CAP" ] && [ "$CAP" -gt 15 ]; then
            rm -f /tmp/bat_warn_sent 2>/dev/null
        fi
    fi

    # 2. Perfil de Energía (power-profiles-daemon)
    PWR_STR=""
    PWR_VAL=$("$SCRIPTS_DIR/power.sh" get 2>/dev/null)
    if [ -n "$PWR_VAL" ]; then
        case "$PWR_VAL" in
            PERF*) PWR_STR="󰓅 PERF" ;;
            BAL*)  PWR_STR="󰾆 BAL" ;;
            SAVE*) PWR_STR="󰌪 SAVE" ;;
            *)     PWR_STR="󰾆 $PWR_VAL" ;;
        esac
    fi

    # 3. Memoria RAM
    RAM_STR=""
    if [ -f /proc/meminfo ]; then
        RAM_PCT=$(awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{if(t>0) printf "%d", (t-a)*100/t}' /proc/meminfo 2>/dev/null)
        [ -n "$RAM_PCT" ] && RAM_STR="󰍛 ${RAM_PCT}%"
    fi

    # 4. Estado de Red (Ethernet o Wi-Fi)
    NET_STR=""
    if grep -q "1" /sys/class/net/en*/carrier 2>/dev/null || grep -q "1" /sys/class/net/eth*/carrier 2>/dev/null; then
        NET_STR="󰈀 ETH"
    elif [ -f /proc/net/wireless ]; then
        W_QUAL=$(awk 'NR==3 {print int($3)}' /proc/net/wireless 2>/dev/null)
        if [ -n "$W_QUAL" ] && [ "$W_QUAL" -gt 0 ]; then
            NET_STR="󰤨 ${W_QUAL}%"
        else
            NET_STR="󰤨"
        fi
    else
        NET_STR="󰤭 OFFLINE"
    fi

    # 5. Brillo de Pantalla
    BRILLO_STR=""
    if command -v brightnessctl >/dev/null 2>&1; then
        B_PCT=$(brightnessctl -m 2>/dev/null | cut -d',' -f4)
        [ -n "$B_PCT" ] && BRILLO_STR="󰃠 $B_PCT"
    else
        BL_PATH=$(ls -d /sys/class/backlight/* 2>/dev/null | head -n 1)
        if [ -n "$BL_PATH" ] && [ -f "$BL_PATH/actual_brightness" ]; then
            B_CUR=$(cat "$BL_PATH/actual_brightness" 2>/dev/null)
            B_MAX=$(cat "$BL_PATH/max_brightness" 2>/dev/null)
            if [ -n "$B_MAX" ] && [ "$B_MAX" -gt 0 ]; then
                B_CALC=$(( B_CUR * 100 / B_MAX ))
                BRILLO_STR="󰃠 ${B_CALC}%"
            fi
        fi
    fi

    # 6. Volumen de Audio
    VOL_VAL=$("$SCRIPTS_DIR/volume.py" get 2>/dev/null)
    if [ -n "$VOL_VAL" ]; then
        if echo "$VOL_VAL" | grep -q "MUTE"; then
            VOL_STR="󰖁 $VOL_VAL"
        else
            VOL_STR="󰕾 $VOL_VAL"
        fi
    fi

    # 7. Distribución de teclado activa
    LAYOUT_NAME=$(swaymsg -t get_inputs 2>/dev/null | grep -m1 "xkb_active_layout_name" | awk -F '"' '{print $4}')
    case "$LAYOUT_NAME" in
        *"Latin American"*) KB_STR="󰌌 LATAM" ;;
        *"Spanish"*)        KB_STR="󰌌 ES" ;;
        *"English"*)        KB_STR="󰌌 US" ;;
        *)                  KB_STR="󰌌 KB" ;;
    esac

    # 8. Fecha y hora
    DATE_STR=$(date +'󰸗 %a %d/%m  󱑂 %H:%M')

    # Imprimir línea para swaybar
    LINE=""
    for item in "$BAT_STR" "$PWR_STR" "$RAM_STR" "$NET_STR" "$BRILLO_STR" "$VOL_STR" "$KB_STR" "$DATE_STR"; do
        if [ -n "$item" ]; then
            if [ -z "$LINE" ]; then
                LINE="$item"
            else
                LINE="$LINE  |  $item"
            fi
        fi
    done

    echo "$LINE"

    sleep 2
done
