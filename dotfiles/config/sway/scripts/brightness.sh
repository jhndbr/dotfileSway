#!/bin/sh
# Screen brightness controller
# Uses brightnessctl (fast & native) with fallback to systemd-logind via busctl

ACTION="${1:-get}"

get_brightness_pct() {
    if command -v brightnessctl >/dev/null 2>&1; then
        brightnessctl -m 2>/dev/null | cut -d',' -f4 | tr -d '%'
    else
        SYS_PATH=$(ls -d /sys/class/backlight/* 2>/dev/null | head -n 1)
        if [ -n "$SYS_PATH" ] && [ -d "$SYS_PATH" ]; then
            MAX=$(cat "$SYS_PATH/max_brightness" 2>/dev/null || echo 100)
            CUR=$(cat "$SYS_PATH/actual_brightness" 2>/dev/null || cat "$SYS_PATH/brightness" 2>/dev/null || echo 50)
            [ "$MAX" -gt 0 ] && echo $(( CUR * 100 / MAX )) || echo "50"
        else
            echo "N/A"
        fi
    fi
}

notify_brightness() {
    PCT="$1"
    if command -v notify-send >/dev/null 2>&1 && [ -n "$PCT" ] && [ "$PCT" != "N/A" ]; then
        notify-send -h string:x-canonical-private-synchronous:osd -h int:value:"$PCT" -t 1200 "Brillo: ${PCT}%"
    fi
}

case "$ACTION" in
    up)
        if command -v brightnessctl >/dev/null 2>&1; then
            brightnessctl set +5% -q
        else
            DEVICE=$(ls /sys/class/backlight/ 2>/dev/null | head -n 1)
            SYS_PATH="/sys/class/backlight/$DEVICE"
            MAX=$(cat "$SYS_PATH/max_brightness" 2>/dev/null || echo 100)
            CUR=$(cat "$SYS_PATH/actual_brightness" 2>/dev/null || echo 50)
            STEP=$(( MAX / 20 ))
            [ "$STEP" -lt 1 ] && STEP=1
            NEW=$(( CUR + STEP ))
            [ "$NEW" -gt "$MAX" ] && NEW=$MAX
            busctl call org.freedesktop.login1 /org/freedesktop/login1/session/auto org.freedesktop.login1.Session SetBrightness ssu "backlight" "$DEVICE" "$NEW" >/dev/null 2>&1
        fi
        PCT=$(get_brightness_pct)
        echo "${PCT}%"
        notify_brightness "$PCT"
        ;;
    down)
        if command -v brightnessctl >/dev/null 2>&1; then
            brightnessctl set 5%- -q
        else
            DEVICE=$(ls /sys/class/backlight/ 2>/dev/null | head -n 1)
            SYS_PATH="/sys/class/backlight/$DEVICE"
            MAX=$(cat "$SYS_PATH/max_brightness" 2>/dev/null || echo 100)
            CUR=$(cat "$SYS_PATH/actual_brightness" 2>/dev/null || echo 50)
            STEP=$(( MAX / 20 ))
            [ "$STEP" -lt 1 ] && STEP=1
            NEW=$(( CUR - STEP ))
            [ "$NEW" -lt "$STEP" ] && NEW=$STEP
            busctl call org.freedesktop.login1 /org/freedesktop/login1/session/auto org.freedesktop.login1.Session SetBrightness ssu "backlight" "$DEVICE" "$NEW" >/dev/null 2>&1
        fi
        PCT=$(get_brightness_pct)
        echo "${PCT}%"
        notify_brightness "$PCT"
        ;;
    get|*)
        PCT=$(get_brightness_pct)
        echo "${PCT}%"
        ;;
esac
