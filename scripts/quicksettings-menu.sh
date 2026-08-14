#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║        Menú Centro de Control / Quick Settings (Wofi)        ║
# ║        Lanza herramientas rápidas y conmuta ajustes         ║
# ╚══════════════════════════════════════════════════════════════╝

SCRIPTS_DIR="$HOME/.local/bin"

# 1. Detectar estado de Gammastep (Luz cálida)
if pgrep -x gammastep > /dev/null; then
    GAMMA_TEXT="󰌵 Luz Cálida [ACTIVADA - Click para apagar]"
else
    GAMMA_TEXT="󰌶 Luz Cálida [DESACTIVADA - Click para encender]"
fi

# 2. Detectar estado de Notificaciones (Dunst)
if command -v dunstctl &>/dev/null && dunstctl is-paused | grep -q 'true'; then
    NOTIF_TEXT="󰂛 Modo Silencio [PAUSADAS - Click para activar]"
else
    NOTIF_TEXT="󰂚 Notificaciones [ACTIVAS - Click para pausar]"
fi

# 3. Detectar perfil de energía
POWER_TEXT=""
if command -v powerprofilesctl &>/dev/null; then
    CURRENT_PROFILE=$(powerprofilesctl get 2>/dev/null || echo "balanced")
    POWER_TEXT="󰓅 Perfil de Energía [Actual: $CURRENT_PROFILE]"
fi

# 4. Construir lista de opciones
OPCIONES="󰍹 Gestión de Pantallas y Monitores
$GAMMA_TEXT
$NOTIF_TEXT
󰂞 Ver Historial de Notificaciones"

if [ -n "$POWER_TEXT" ]; then
    OPCIONES="$OPCIONES
$POWER_TEXT"
fi

OPCIONES="$OPCIONES
󰈊 Selector de Color (Color Picker)
📸 Menú de Captura de Pantalla
😀 Selector de Emojis"

# 5. Ejecutar Wofi
SELECCION=$(echo -e "$OPCIONES" | wofi --dmenu \
    --prompt "Centro de Control" \
    --cache-file /dev/null \
    --insensitive \
    --width 380 \
    --height 340 \
    --lines 8)

# 6. Manejar acción
case "$SELECCION" in
    *"Gestión de Pantallas"*)
        "$SCRIPTS_DIR/monitor-manager.sh" menu
        ;;
    *"Luz Cálida"*)
        "$SCRIPTS_DIR/gammastep-toggle.sh"
        ;;
    *"Modo Silencio"*|*"Notificaciones"*)
        if command -v dunstctl &>/dev/null; then
            dunstctl set-paused toggle
        fi
        ;;
    *"Historial de Notificaciones"*)
        if command -v dunstctl &>/dev/null; then
            dunstctl history-pop
        fi
        ;;
    *"Perfil de Energía"*)
        # Submenú rápido para elegir perfil
        PROFILES="󰓅 performance (Rendimiento)
󰾅 balanced (Equilibrado)
󰾆 power-saver (Ahorro)"
        PERFIL_SEL=$(echo -e "$PROFILES" | wofi --dmenu --prompt "Elegir Perfil" --width 280 --height 180 --lines 3)
        case "$PERFIL_SEL" in
            *"performance"*) powerprofilesctl set performance ;;
            *"balanced"*) powerprofilesctl set balanced ;;
            *"power-saver"*) powerprofilesctl set power-saver ;;
        esac
        ;;
    *"Selector de Color"*)
        "$SCRIPTS_DIR/color-picker.sh"
        ;;
    *"Captura de Pantalla"*)
        "$SCRIPTS_DIR/screenshot.sh"
        ;;
    *"Selector de Emojis"*)
        "$SCRIPTS_DIR/emoji-picker.sh"
        ;;
esac
