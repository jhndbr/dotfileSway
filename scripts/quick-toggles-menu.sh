#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║        Menú Rápido de Toggles (Luz Nocturna & Cafeína)       ║
# ║        Lanzado por clic derecho en Centro de Control         ║
# ╚══════════════════════════════════════════════════════════════╝

SCRIPTS_DIR="$HOME/.local/bin"
[ ! -d "$SCRIPTS_DIR" ] && SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Formato uniforme
format_item() {
    local icon="$1"
    local label="$2"
    local tag="$3"
    local target_width=24
    local len=${#label}
    local pad=$(( target_width - len ))
    [ $pad -lt 2 ] && pad=2
    local spaces
    spaces=$(printf '%*s' "$pad" '')
    
    if [ -n "$tag" ]; then
        echo "$icon    $label$spaces[$tag]"
    else
        echo "$icon    $label"
    fi
}

# 1. Estado de Luz Nocturna (Gammastep)
if pgrep -x gammastep > /dev/null; then
    ITEM_GAMMA=$(format_item "󰌵" "Luz Nocturna" "Activada")
else
    ITEM_GAMMA=$(format_item "󰌶" "Luz Nocturna" "Desactivada")
fi

# 2. Estado de Modo Cafeína
CAFFEINE_STATE="$HOME/.config/caffeine_active"
if [ -f "$CAFFEINE_STATE" ] || [ -f "${XDG_RUNTIME_DIR:-/tmp}/caffeine_active" ]; then
    ITEM_CAFFEINE=$(format_item "󰅶" "Modo Cafeína" "Activado")
else
    ITEM_CAFFEINE=$(format_item "󰾪" "Modo Cafeína" "Desactivado")
fi

# 3. Notificaciones (Dunst)
if command -v dunstctl &>/dev/null && [ "$(dunstctl is-paused 2>/dev/null)" = "true" ]; then
    ITEM_NOTIF=$(format_item "󰂛" "Notificaciones" "Silenciadas")
else
    ITEM_NOTIF=$(format_item "󰂚" "Notificaciones" "Activas")
fi

# Lista de opciones rápidas
OPCIONES="$ITEM_GAMMA
$ITEM_CAFFEINE
$ITEM_NOTIF
$(format_item "󰒓" "Centro de Control Completo" "Abrir")"

SELECCION=$(echo -e "$OPCIONES" | wofi --dmenu \
    --prompt "  󰒓  Ajustes Rápidos" \
    --cache-file /dev/null \
    --insensitive \
    --width 420 \
    --height 230 \
    --lines 4)

[ -z "$SELECCION" ] && exit 0

case "$SELECCION" in
    *"Luz Nocturna"*)
        if [ -x "$SCRIPTS_DIR/gammastep-toggle.sh" ]; then
            "$SCRIPTS_DIR/gammastep-toggle.sh"
        elif [ -x "$(dirname "$0")/gammastep-toggle.sh" ]; then
            "$(dirname "$0")/gammastep-toggle.sh"
        fi
        pkill -RTMIN+8 waybar 2>/dev/null || true
        ;;
    *"Modo Cafeína"*|*"Cafeína"*)
        if [ -x "$SCRIPTS_DIR/caffeine-toggle.sh" ]; then
            "$SCRIPTS_DIR/caffeine-toggle.sh"
        elif [ -x "$(dirname "$0")/caffeine-toggle.sh" ]; then
            "$(dirname "$0")/caffeine-toggle.sh"
        fi
        pkill -RTMIN+9 waybar 2>/dev/null || true
        ;;
    *"Notificaciones"*)
        if command -v dunstctl &>/dev/null; then
            dunstctl set-paused toggle
        fi
        ;;
    *"Centro de Control"*)
        if [ -x "$SCRIPTS_DIR/quicksettings-menu.sh" ]; then
            "$SCRIPTS_DIR/quicksettings-menu.sh"
        elif [ -x "$(dirname "$0")/quicksettings-menu.sh" ]; then
            "$(dirname "$0")/quicksettings-menu.sh"
        fi
        ;;
esac
