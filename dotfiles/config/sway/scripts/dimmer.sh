#!/bin/sh
# Display Dimmer for swayidle
# Dims the screen gently before blanking, restores on user activity

ACTION="${1:-dim}"
STATE_FILE="/tmp/sway_pre_dim_brightness"

case "$ACTION" in
    dim)
        if command -v brightnessctl >/dev/null 2>&1; then
            # Guardar valor actual con brightnessctl
            brightnessctl -s set 10% -q
        else
            SYS_PATH=$(ls -d /sys/class/backlight/* 2>/dev/null | head -n 1)
            if [ -n "$SYS_PATH" ] && [ -f "$SYS_PATH/brightness" ]; then
                cat "$SYS_PATH/brightness" > "$STATE_FILE"
                MAX=$(cat "$SYS_PATH/max_brightness" 2>/dev/null || echo 100)
                LOW=$(( MAX / 10 ))
                [ "$LOW" -lt 1 ] && LOW=1
                DEVICE=$(basename "$SYS_PATH")
                busctl call org.freedesktop.login1 /org/freedesktop/login1/session/auto org.freedesktop.login1.Session SetBrightness ssu "backlight" "$DEVICE" "$LOW" >/dev/null 2>&1
            fi
        fi
        ;;
    restore)
        if command -v brightnessctl >/dev/null 2>&1; then
            brightnessctl -r -q
        elif [ -f "$STATE_FILE" ]; then
            SYS_PATH=$(ls -d /sys/class/backlight/* 2>/dev/null | head -n 1)
            ORIG=$(cat "$STATE_FILE" 2>/dev/null)
            if [ -n "$ORIG" ] && [ -n "$SYS_PATH" ]; then
                DEVICE=$(basename "$SYS_PATH")
                busctl call org.freedesktop.login1 /org/freedesktop/login1/session/auto org.freedesktop.login1.Session SetBrightness ssu "backlight" "$DEVICE" "$ORIG" >/dev/null 2>&1
            fi
            rm -f "$STATE_FILE" 2>/dev/null
        fi
        ;;
esac
