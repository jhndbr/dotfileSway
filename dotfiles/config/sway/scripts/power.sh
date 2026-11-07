#!/bin/sh
# Power Profile Manager for Sway (Debian)
# Controls power-profiles-daemon via powerprofilesctl with Wofi menu & OSD notifications

ACTION="${1:-menu}"

notify_osd() {
    MSG="$1"
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -h string:x-canonical-private-synchronous:osd -t 2000 "Perfil de Energía" "$MSG"
    fi
}

get_current() {
    powerprofilesctl get 2>/dev/null || echo "balanced"
}

set_profile() {
    PROFILE="$1"
    if powerprofilesctl set "$PROFILE" 2>/dev/null; then
        case "$PROFILE" in
            performance)
                notify_osd "⚡ Alto Rendimiento activado"
                ;;
            balanced)
                notify_osd "⚖ Modo Equilibrado activado"
                ;;
            power-saver)
                notify_osd "🔋 Ahorro de Energía activado"
                ;;
        esac
    fi
}

case "$ACTION" in
    get)
        CUR=$(get_current)
        case "$CUR" in
            performance) echo "PERF" ;;
            power-saver) echo "SAV" ;;
            *)           echo "BAL" ;;
        esac
        ;;
    toggle)
        CUR=$(get_current)
        case "$CUR" in
            balanced)    set_profile "performance" ;;
            performance) set_profile "power-saver" ;;
            power-saver) set_profile "balanced" ;;
            *)           set_profile "balanced" ;;
        esac
        ;;
    menu)
        CUR=$(get_current)
        MENU_ITEMS="⚡  Alto Rendimiento (performance)\n⚖  Equilibrado (balanced)\n🔋  Ahorro de Energía (power-saver)"
        SELECTED=$(printf "$MENU_ITEMS" | wofi --dmenu --prompt "Perfil de Energía (Actual: $CUR)" --width 380 --height 180 --insensitive --lines 3)
        case "$SELECTED" in
            *"performance"*)
                set_profile "performance"
                ;;
            *"balanced"*)
                set_profile "balanced"
                ;;
            *"power-saver"*)
                set_profile "power-saver"
                ;;
        esac
        ;;
    set)
        [ -n "$2" ] && set_profile "$2"
        ;;
    *)
        echo "Uso: $0 [get|toggle|menu|set <profile>]"
        ;;
esac
