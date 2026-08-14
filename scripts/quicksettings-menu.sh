#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║        Menú Centro de Control / Quick Settings (Wofi)        ║
# ║        Optimizado para apertura instantánea (0ms lag)        ║
# ╚══════════════════════════════════════════════════════════════╝

SCRIPTS_DIR="$HOME/.local/bin"

# ── 1. Detecciones ultrarrápidas (< 2ms) ────────────────────────
# Luz Nocturna (pgrep es instantáneo en /proc)
if pgrep -x gammastep > /dev/null; then
    GAMMA_TEXT="󰌵 Luz Nocturna  ·  [Activada]"
else
    GAMMA_TEXT="󰌶 Luz Nocturna  ·  [Desactivada]"
fi

# Modo Silencio / Notificaciones (Dunst)
if command -v dunstctl &>/dev/null && [ "$(dunstctl is-paused 2>/dev/null)" = "true" ]; then
    NOTIF_TEXT="󰂛 Notificaciones  ·  [Silenciadas]"
else
    NOTIF_TEXT="󰂚 Notificaciones  ·  [Activas]"
fi

# Bluetooth instantáneo vía rfkill (Lectura directa de kernel sysfs, 0ms)
if rfkill list bluetooth 2>/dev/null | grep -q "Soft blocked: yes"; then
    BT_STATUS="󰂲 Bluetooth  ·  [Apagado]"
elif rfkill list bluetooth 2>/dev/null | grep -q "Soft blocked: no"; then
    BT_STATUS="󰂯 Bluetooth  ·  [Encendido]"
else
    BT_STATUS="󰂯 Bluetooth  ·  [Gestionar]"
fi

# Perfil de energía
POWER_TEXT=""
if command -v powerprofilesctl &>/dev/null; then
    CURRENT_PROFILE=$(powerprofilesctl get 2>/dev/null || echo "balanced")
    POWER_TEXT="󰓅 Rendimiento  ·  [$CURRENT_PROFILE]"
fi

# ── 2. Menú Principal de Opciones con Diseño Pulido ─────────────
OPCIONES="󰍹 Pantallas & Monitores  ·  [Configurar]
$BT_STATUS
󰕾 Audio & Salidas  ·  [Cambiar Dispositivo]
$GAMMA_TEXT
$NOTIF_TEXT
󰂞 Historial de Notificaciones"

if [ -n "$POWER_TEXT" ]; then
    OPCIONES="$OPCIONES
$POWER_TEXT"
fi

OPCIONES="$OPCIONES
󰈊 Selector de Color  ·  [Copiar HEX]
󰄀 Captura de Pantalla  ·  [Menú Rápido]
󰞅 Selector de Emojis
󰅖 Borrar Historial de Portapapeles"

# ── 3. Lanzar Wofi ──────────────────────────────────────────────
SELECCION=$(echo -e "$OPCIONES" | wofi --dmenu \
    --prompt "  󰒓 Centro de Control" \
    --cache-file /dev/null \
    --insensitive \
    --width 480 \
    --height 440 \
    --lines 11)

# Salir si el usuario canceló
[ -z "$SELECCION" ] && exit 0

# ── 4. Acciones Rápidas ────────────────────────────────────────
case "$SELECCION" in
    *"Pantallas & Monitores"*)
        "$SCRIPTS_DIR/monitor-manager.sh" menu
        ;;
    *"Bluetooth"*)
        # Submenú rápido de Bluetooth (solo consulta dispositivos si está activo)
        BT_IS_BLOCKED=$(rfkill list bluetooth 2>/dev/null | grep -q "Soft blocked: yes" && echo "yes" || echo "no")
        if [ "$BT_IS_BLOCKED" = "no" ]; then
            TOGGLE_TXT="󰂲 Desactivar Bluetooth"
        else
            TOGGLE_TXT="󰂯 Activar Bluetooth"
        fi

        BT_MENU="$TOGGLE_TXT
󰂰 Administrador Blueman"

        # Cargar dispositivos emparejados solo si bluetooth está encendido
        if [ "$BT_IS_BLOCKED" = "no" ] && command -v bluetoothctl &>/dev/null; then
            PAIRED_DEVICES=$(bluetoothctl devices 2>/dev/null | sed 's/^Device /󰂱 /')
            if [ -n "$PAIRED_DEVICES" ]; then
                BT_MENU="$BT_MENU
$PAIRED_DEVICES"
            fi
        fi

        BT_SEL=$(echo -e "$BT_MENU" | wofi --dmenu --prompt "  󰂯 Bluetooth" --width 400 --height 280 --lines 6)
        case "$BT_SEL" in
            *"Desactivar Bluetooth"*)
                rfkill block bluetooth 2>/dev/null || bluetoothctl power off
                dunstify -a "Bluetooth" -r 9931 -u low "󰂲 Bluetooth" "Bluetooth Desactivado"
                ;;
            *"Activar Bluetooth"*)
                rfkill unblock bluetooth 2>/dev/null || bluetoothctl power on
                dunstify -a "Bluetooth" -r 9931 -u low "󰂯 Bluetooth" "Bluetooth Activado"
                ;;
            *"Blueman"*)
                blueman-manager &
                ;;
            *"󰂱"*)
                DEV_MAC=$(echo "$BT_SEL" | awk '{print $2}')
                DEV_NAME=$(echo "$BT_SEL" | cut -d ' ' -f 3-)
                dunstify -a "Bluetooth" -r 9931 "󰂱 Conectando..." "Conectando con $DEV_NAME"
                bluetoothctl connect "$DEV_MAC" &
                ;;
        esac
        ;;
    *"Audio & Salidas"*)
        SINKS=$(pactl list short sinks 2>/dev/null | awk '{print $1 ": " $2}')
        if [ -n "$SINKS" ]; then
            SINK_SEL=$(echo -e "$SINKS" | wofi --dmenu --prompt "  󰕾 Salida de Audio" --width 460 --height 220 --lines 4)
            if [ -n "$SINK_SEL" ]; then
                SINK_ID=$(echo "$SINK_SEL" | cut -d ':' -f 1)
                pactl set-default-sink "$SINK_ID"
                dunstify -a "Audio" -r 9932 -u low "󰕾 Audio" "Salida cambiada a: $SINK_SEL"
            fi
        fi
        ;;
    *"Luz Nocturna"*)
        "$SCRIPTS_DIR/gammastep-toggle.sh"
        ;;
    *"Notificaciones"*)
        if command -v dunstctl &>/dev/null; then
            dunstctl set-paused toggle
        fi
        ;;
    *"Historial de Notificaciones"*)
        if command -v dunstctl &>/dev/null; then
            dunstctl history-pop
        fi
        ;;
    *"Rendimiento"*)
        PROFILES="󰓅 performance  ·  Alto Rendimiento
󰾅 balanced     ·  Equilibrado
󰾆 power-saver  ·  Ahorro de Batería"
        PERFIL_SEL=$(echo -e "$PROFILES" | wofi --dmenu --prompt "  󰓅 Perfil de Energía" --width 380 --height 200 --lines 3)
        case "$PERFIL_SEL" in
            *"performance"*) powerprofilesctl set performance && dunstify -a "Energía" -r 9933 -u low "󰓅 Rendimiento" "Perfil: Rendimiento" ;;
            *"balanced"*) powerprofilesctl set balanced && dunstify -a "Energía" -r 9933 -u low "󰾅 Rendimiento" "Perfil: Equilibrado" ;;
            *"power-saver"*) powerprofilesctl set power-saver && dunstify -a "Energía" -r 9933 -u low "󰾆 Rendimiento" "Perfil: Ahorro de Batería" ;;
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
            dunstify -a "Portapapeles" -r 9925 "󰅖 Portapapeles" "Historial de copiado borrado"
        fi
        ;;
esac
