#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║        Menú Centro de Control / Quick Settings (Wofi)        ║
# ║        Navaja Suiza: Ajustes, Bluetooth, Audio, Portapapeles ║
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

# 3. Detectar estado de Bluetooth
BT_STATUS="󰂲 Bluetooth [Apagado]"
if command -v bluetoothctl &>/dev/null && bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
    CONNECTED_DEV=$(bluetoothctl devices Connected 2>/dev/null | head -n 1 | cut -d ' ' -f 3-)
    if [ -n "$CONNECTED_DEV" ]; then
        BT_STATUS="󰂱 Bluetooth [Conectado: $CONNECTED_DEV]"
    else
        BT_STATUS="󰂯 Bluetooth [Encendido - Sin conexión]"
    fi
fi

# 4. Detectar perfil de energía
POWER_TEXT=""
if command -v powerprofilesctl &>/dev/null; then
    CURRENT_PROFILE=$(powerprofilesctl get 2>/dev/null || echo "balanced")
    POWER_TEXT="󰓅 Perfil de Energía [Actual: $CURRENT_PROFILE]"
fi

# 5. Construir lista principal de opciones
OPCIONES="󰍹 Gestión de Pantallas y Monitores
$BT_STATUS
󰕾 Cambiar Salida de Audio (Altavoces / Auriculares)
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
😀 Selector de Emojis
󰅖 Borrar Historial de Portapapeles (Limpiar copiado)"

# 6. Ejecutar Wofi
SELECCION=$(echo -e "$OPCIONES" | wofi --dmenu \
    --prompt "Centro de Control" \
    --cache-file /dev/null \
    --insensitive \
    --width 440 \
    --height 400 \
    --lines 10)

# 7. Manejar acción
case "$SELECCION" in
    *"Gestión de Pantallas"*)
        "$SCRIPTS_DIR/monitor-manager.sh" menu
        ;;
    *"Bluetooth"*)
        # Submenú rápido de Bluetooth
        PAIRED_DEVICES=$(bluetoothctl devices 2>/dev/null | sed 's/^Device /󰂱 /')
        BT_MENU="󰂯 Alternar Bluetooth (Encender / Apagar)
󰂰 Abrir Administrador Blueman"
        if [ -n "$PAIRED_DEVICES" ]; then
            BT_MENU="$BT_MENU
$PAIRED_DEVICES"
        fi
        
        BT_SEL=$(echo -e "$BT_MENU" | wofi --dmenu --prompt "Bluetooth" --width 380 --height 280 --lines 6)
        case "$BT_SEL" in
            *"Alternar Bluetooth"*)
                if bluetoothctl show | grep -q "Powered: yes"; then
                    bluetoothctl power off
                    dunstify -a "Bluetooth" -r 9931 "󰂲 Bluetooth" "Bluetooth Desactivado"
                else
                    bluetoothctl power on
                    dunstify -a "Bluetooth" -r 9931 "󰂯 Bluetooth" "Bluetooth Activado"
                fi
                ;;
            *"Blueman"*)
                blueman-manager &
                ;;
            *"󰂱"*)
                DEV_MAC=$(echo "$BT_SEL" | awk '{print $2}')
                DEV_NAME=$(echo "$BT_SEL" | cut -d ' ' -f 3-)
                dunstify -a "Bluetooth" -r 9931 "󰂱 Conectando..." "Intentando conectar con $DEV_NAME"
                bluetoothctl connect "$DEV_MAC"
                ;;
        esac
        ;;
    *"Cambiar Salida de Audio"*)
        # Obtener lista de sinks disponibles
        SINKS=$(pactl list short sinks | awk '{print $1 ": " $2}')
        if [ -n "$SINKS" ]; then
            SINK_SEL=$(echo -e "$SINKS" | wofi --dmenu --prompt "Elegir Salida de Audio" --width 400 --height 200 --lines 4)
            if [ -n "$SINK_SEL" ]; then
                SINK_ID=$(echo "$SINK_SEL" | cut -d ':' -f 1)
                pactl set-default-sink "$SINK_ID"
                dunstify -a "Audio" -r 9932 "🔊 Salida Cambiada" "Salida de audio configurada a: $SINK_SEL"
            fi
        fi
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
    *"Borrar Historial de Portapapeles"*)
        if command -v cliphist &>/dev/null; then
            cliphist wipe
            dunstify -a "Portapapeles" -r 9925 "📋 Portapapeles Limpio" "Se ha borrado el historial de copiado por seguridad"
        fi
        ;;
esac
