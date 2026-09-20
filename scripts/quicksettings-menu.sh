#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║        Menú Centro de Control / Quick Settings (Wofi)        ║
# ║        Alineación precisa, espaciado óptico y 0ms lag        ║
# ╚══════════════════════════════════════════════════════════════╝

SCRIPTS_DIR="$HOME/.local/bin"
[ ! -d "$SCRIPTS_DIR" ] && SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Función para formatear líneas con espacio uniforme y corchetes alineados
format_item() {
    local icon="$1"
    local label="$2"
    local tag="$3"
    local target_width=30
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

# ── 1. Detecciones ultrarrápidas (< 2ms) ────────────────────────
# Modo Cafeína (Inhibición de reposo)
CAFFEINE_STATE="$HOME/.config/caffeine_active"
if [ -f "$CAFFEINE_STATE" ] || [ -f "${XDG_RUNTIME_DIR:-/tmp}/caffeine_active" ]; then
    ITEM_CAFFEINE=$(format_item "󰅶" "Modo Cafeína" "Activado")
else
    ITEM_CAFFEINE=$(format_item "󰾪" "Modo Cafeína" "Desactivado")
fi

# Luz Nocturna (Gammastep)
if pgrep -x gammastep > /dev/null; then
    ITEM_GAMMA=$(format_item "󰌵" "Luz Nocturna" "Activada")
else
    ITEM_GAMMA=$(format_item "󰌶" "Luz Nocturna" "Desactivada")
fi

# Notificaciones (Dunst)
if command -v dunstctl &>/dev/null && [ "$(dunstctl is-paused 2>/dev/null)" = "true" ]; then
    ITEM_NOTIF=$(format_item "󰂛" "Notificaciones" "Silenciadas")
else
    ITEM_NOTIF=$(format_item "󰂚" "Notificaciones" "Activas")
fi

# Bluetooth (vía rfkill directo del kernel)
if rfkill list bluetooth 2>/dev/null | grep -q "Soft blocked: yes"; then
    ITEM_BT=$(format_item "󰂲" "Bluetooth" "Apagado")
elif rfkill list bluetooth 2>/dev/null | grep -q "Soft blocked: no"; then
    ITEM_BT=$(format_item "󰂯" "Bluetooth" "Encendido")
else
    ITEM_BT=$(format_item "󰂯" "Bluetooth" "Ajustes")
fi

# Perfil de Energía (Solo si powerprofilesctl está activo)
ITEM_POWER=""
if command -v powerprofilesctl &>/dev/null; then
    CURRENT_PROFILE=$(powerprofilesctl get 2>/dev/null || true)
    if [ -n "$CURRENT_PROFILE" ]; then
        ITEM_POWER=$(format_item "󰓅" "Perfil de Rendimiento" "$CURRENT_PROFILE")
    fi
fi

# Distribución de Teclado
KB_LAYOUT="es"
if [ -f "$HOME/.config/sway/inputs.conf" ]; then
    if grep -q 'xkb_layout "us,es"' "$HOME/.config/sway/inputs.conf"; then
        KB_LAYOUT="us+es"
    elif grep -q 'xkb_variant "intl"' "$HOME/.config/sway/inputs.conf"; then
        KB_LAYOUT="us-intl"
    elif grep -q 'xkb_layout "us"' "$HOME/.config/sway/inputs.conf"; then
        KB_LAYOUT="us"
    elif grep -q 'xkb_layout "es"' "$HOME/.config/sway/inputs.conf"; then
        KB_LAYOUT="es"
    fi
fi
ITEM_KB=$(format_item "⌨️" "Distribución Teclado" "$KB_LAYOUT")

# Modo de Tema y Esquema de Color (Matugen)
THEME_CONF="$HOME/.config/matugen/theme.conf"
CURRENT_THEME_MODE="dark"
CURRENT_THEME_SCHEME="scheme-tonal-spot"
if [ -f "$THEME_CONF" ]; then
    . "$THEME_CONF" 2>/dev/null || true
    [ -n "$MODE" ] && CURRENT_THEME_MODE="$MODE"
    [ -n "$SCHEME_TYPE" ] && CURRENT_THEME_SCHEME="$SCHEME_TYPE"
fi

if [ "$CURRENT_THEME_MODE" = "light" ]; then
    ITEM_THEME_MODE=$(format_item "󰃮" "Modo de Color" "Claro")
else
    ITEM_THEME_MODE=$(format_item "󰃭" "Modo de Color" "Oscuro")
fi

case "$CURRENT_THEME_SCHEME" in
    *vibrant*)      SCHEME_LABEL="Vibrant" ;;
    *fidelity*)     SCHEME_LABEL="Fidelity" ;;
    *expressive*)   SCHEME_LABEL="Expressive" ;;
    *fruit-salad*)  SCHEME_LABEL="Fruit Salad" ;;
    *rainbow*)      SCHEME_LABEL="Rainbow" ;;
    *content*)      SCHEME_LABEL="Content" ;;
    *monochrome*)   SCHEME_LABEL="Monochrome" ;;
    *neutral*)      SCHEME_LABEL="Neutral" ;;
    *)              SCHEME_LABEL="Tonal Spot" ;;
esac
ITEM_THEME_SCHEME=$(format_item "󰏘" "Esquema Matugen" "$SCHEME_LABEL")

# ── 2. Lista de Opciones Formateada ────────────────────────────
OPCIONES="$(format_item "󰍹" "Pantallas y Monitores" "Configurar")
$ITEM_THEME_MODE
$ITEM_THEME_SCHEME
$ITEM_BT
$ITEM_KB
$(format_item "󰕾" "Salida de Audio" "Cambiar")
$ITEM_CAFFEINE
$ITEM_GAMMA
$ITEM_NOTIF
$(format_item "󰂞" "Historial de Notificaciones" "Ver")"

if [ -n "$ITEM_POWER" ]; then
    OPCIONES="$OPCIONES
$ITEM_POWER"
fi

OPCIONES="$OPCIONES
$(format_item "󰈊" "Selector de Color" "HEX")
$(format_item "󰄀" "Captura de Pantalla" "Menú")
$(format_item "󰞅" "Selector de Emojis" "Copiar")
$(format_item "󰅖" "Limpiar Portapapeles" "Vaciar")"

# ── 3. Lanzar Wofi ──────────────────────────────────────────────
SELECCION=$(echo -e "$OPCIONES" | wofi --dmenu \
    --prompt "  󰒓  Centro de Control" \
    --cache-file /dev/null \
    --insensitive \
    --width 500 \
    --height 520 \
    --lines 14)

# Salir si se canceló
[ -z "$SELECCION" ] && exit 0

# ── 4. Ejecución de Acciones ────────────────────────────────────
case "$SELECCION" in
    *"Modo de Color"*)
        MODE_OPTIONS="$(format_item "󰃭" "Modo Oscuro" "Dark")
$(format_item "󰃮" "Modo Claro" "Light")
$(format_item "󰔎" "Alternar Modo" "Toggle")"
        MODE_SEL=$(echo -e "$MODE_OPTIONS" | wofi --dmenu \
            --prompt "  󰔎  Modo de Color" \
            --cache-file /dev/null \
            --insensitive \
            --width 420 \
            --height 220 \
            --lines 3)
        case "$MODE_SEL" in
            *"Modo Oscuro"*)
                "$SCRIPTS_DIR/set-wallpaper.sh" --mode dark
                ;;
            *"Modo Claro"*)
                "$SCRIPTS_DIR/set-wallpaper.sh" --mode light
                ;;
            *"Alternar"*)
                "$SCRIPTS_DIR/set-wallpaper.sh" --mode toggle
                ;;
        esac
        ;;
    *"Esquema Matugen"*)
        SCHEME_OPTIONS="$(format_item "󰏘" "Vibrant" "Saturado y vivo")
$(format_item "󰏘" "Fidelity" "Fiel al wallpaper")
$(format_item "󰏘" "Expressive" "Acentos coloridos")
$(format_item "󰏘" "Tonal Spot" "Equilibrado (Defecto)")
$(format_item "󰏘" "Fruit Salad" "Contrastante lúdico")
$(format_item "󰏘" "Rainbow" "Multicolor")
$(format_item "󰏘" "Content" "Tonos del contenido")
$(format_item "󰏘" "Neutral" "Tonos discretos")
$(format_item "󰏘" "Monochrome" "Escala de grises")"
        SCHEME_SEL=$(echo -e "$SCHEME_OPTIONS" | wofi --dmenu \
            --prompt "  󰏘  Esquema Matugen" \
            --cache-file /dev/null \
            --insensitive \
            --width 480 \
            --height 380 \
            --lines 9)
        case "$SCHEME_SEL" in
            *"Vibrant"*)     "$SCRIPTS_DIR/set-wallpaper.sh" --scheme scheme-vibrant ;;
            *"Fidelity"*)    "$SCRIPTS_DIR/set-wallpaper.sh" --scheme scheme-fidelity ;;
            *"Expressive"*)  "$SCRIPTS_DIR/set-wallpaper.sh" --scheme scheme-expressive ;;
            *"Tonal Spot"*)  "$SCRIPTS_DIR/set-wallpaper.sh" --scheme scheme-tonal-spot ;;
            *"Fruit Salad"*) "$SCRIPTS_DIR/set-wallpaper.sh" --scheme scheme-fruit-salad ;;
            *"Rainbow"*)     "$SCRIPTS_DIR/set-wallpaper.sh" --scheme scheme-rainbow ;;
            *"Content"*)     "$SCRIPTS_DIR/set-wallpaper.sh" --scheme scheme-content ;;
            *"Neutral"*)     "$SCRIPTS_DIR/set-wallpaper.sh" --scheme scheme-neutral ;;
            *"Monochrome"*)  "$SCRIPTS_DIR/set-wallpaper.sh" --scheme scheme-monochrome ;;
        esac
        ;;
    *"Modo Cafeína"*|*"Cafeína"*)
        "$SCRIPTS_DIR/caffeine-toggle.sh"
        ;;
    *"Pantallas y Monitores"*)
        "$SCRIPTS_DIR/monitor-manager.sh" menu
        ;;
    *"Bluetooth"*)
        BT_IS_BLOCKED=$(rfkill list bluetooth 2>/dev/null | grep -q "Soft blocked: yes" && echo "yes" || echo "no")
        if [ "$BT_IS_BLOCKED" = "no" ]; then
            TOGGLE_TXT="󰂲    Desactivar Bluetooth"
        else
            TOGGLE_TXT="󰂯    Activar Bluetooth"
        fi

        BT_MENU="$TOGGLE_TXT
󰂰    Administrador Blueman"

        if [ "$BT_IS_BLOCKED" = "no" ] && command -v bluetoothctl &>/dev/null; then
            PAIRED_DEVICES=$(bluetoothctl devices 2>/dev/null | sed 's/^Device /󰂱    /')
            if [ -n "$PAIRED_DEVICES" ]; then
                BT_MENU="$BT_MENU
$PAIRED_DEVICES"
            fi
        fi

        BT_SEL=$(echo -e "$BT_MENU" | wofi --dmenu --prompt "  󰂯  Bluetooth" --width 420 --height 280 --lines 6)
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
    *"Salida de Audio"*)
        SINKS=$(pactl list short sinks 2>/dev/null | awk '{print "󰕾    " $1 ": " $2}')
        if [ -n "$SINKS" ]; then
            SINK_SEL=$(echo -e "$SINKS" | wofi --dmenu --prompt "  󰕾  Salida de Audio" --width 480 --height 220 --lines 4)
            if [ -n "$SINK_SEL" ]; then
                SINK_ID=$(echo "$SINK_SEL" | awk '{print $2}' | tr -d ':')
                pactl set-default-sink "$SINK_ID"
                dunstify -a "Audio" -r 9932 -u low "󰕾 Audio" "Salida: $SINK_SEL"
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
    *"Perfil de Rendimiento"*)
        PROFILES="$(format_item "󰓅" "performance" "Alto Rendimiento")
$(format_item "󰾅" "balanced" "Equilibrado")
$(format_item "󰾆" "power-saver" "Ahorro de Batería")"
        PERFIL_SEL=$(echo -e "$PROFILES" | wofi --dmenu --prompt "  󰓅  Perfil de Energía" --width 400 --height 200 --lines 3)
        case "$PERFIL_SEL" in
            *"performance"*) powerprofilesctl set performance && dunstify -a "Energía" -r 9933 -u low "󰓅 Rendimiento" "Perfil: Rendimiento" ;;
            *"balanced"*) powerprofilesctl set balanced && dunstify -a "Energía" -r 9933 -u low "󰾅 Rendimiento" "Perfil: Equilibrado" ;;
            *"power-saver"*) powerprofilesctl set power-saver && dunstify -a "Energía" -r 9933 -u low "󰾆 Rendimiento" "Perfil: Ahorro de Batería" ;;
        esac
        ;;
    *"Distribución Teclado"*|*"Teclado"*)
        "$SCRIPTS_DIR/keyboard-layout.sh" menu
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
    *"Limpiar Portapapeles"*)
        if command -v cliphist &>/dev/null; then
            cliphist wipe
            dunstify -a "Portapapeles" -r 9925 "󰅖 Portapapeles" "Historial de copiado borrado"
        fi
        ;;
esac
