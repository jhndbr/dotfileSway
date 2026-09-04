#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║        Control de Brillo (PC & Monitores Externos DDC/CI)   ║
# ╚══════════════════════════════════════════════════════════════╝

notify_brightness() {
    local val="$1"
    local icon="🔆"
    if command -v dunstify &>/dev/null; then
        dunstify -a 'Brightness' -r 9994 -u low -h int:value:"$val" -h string:x-dunst-stack-tag:brightness "Brillo: ${val}%" "$icon"
    elif command -v notify-send &>/dev/null; then
        notify-send -a 'Brightness' -r 9994 "Brillo: ${val}%" "$icon"
    fi
}

change_brightness() {
    local dir="$1"
    local step=5
    
    # 1. Si ddcutil está instalado y disponible (Monitores externos HDMI/DisplayPort)
    if command -v ddcutil &>/dev/null; then
        if [ "$dir" = "up" ]; then
            ddcutil setvcp 10 + "$step" --bus=all 2>/dev/null || true
        else
            ddcutil setvcp 10 - "$step" --bus=all 2>/dev/null || true
        fi
        local ddc_val
        ddc_val=$(ddcutil getvcp 10 2>/dev/null | grep -oP 'current value =\s*\K[0-9]+' | head -n 1 || true)
        if [ -n "$ddc_val" ]; then
            notify_brightness "$ddc_val"
            return
        fi
    fi

    # 2. Fallback con brightnessctl
    if command -v brightnessctl &>/dev/null; then
        if [ "$dir" = "up" ]; then
            brightnessctl set "${step}%+" 2>/dev/null || true
        else
            brightnessctl set "${step}%-" 2>/dev/null || true
        fi
        local bctl_val
        bctl_val=$(brightnessctl info 2>/dev/null | grep -oP '\(\K[0-9]+(?=%\))' | head -n 1 || true)
        if [ -n "$bctl_val" ]; then
            notify_brightness "$bctl_val"
            return
        fi
    fi

    # Si no se detectó interfaz de brillo de hardware
    notify_brightness 100
}

case "$1" in
    up)
        change_brightness "up"
        ;;
    down)
        change_brightness "down"
        ;;
    *)
        echo "Uso: $0 {up|down}"
        exit 1
        ;;
esac
