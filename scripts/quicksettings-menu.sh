#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║        Menú Centro de Control / Quick Settings (Wofi)        ║
# ║        Alineación precisa, espaciado óptico y 0ms lag        ║
# ╚══════════════════════════════════════════════════════════════╝

SCRIPTS_DIR="$HOME/.local/bin"

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

# Apariencia y Paleta Dinámica (Matugen)
THEME_CONF="$HOME/.config/matugen/theme.conf"
THEME_MODE="dark"
THEME_TYPE="scheme-tonal-spot"
THEME_INDEX="0"
if [ -f "$THEME_CONF" ]; then
    # shellcheck disable=SC1090
    source "$THEME_CONF" 2>/dev/null || true
    [ -n "$MODE" ] && THEME_MODE="$MODE"
    [ -n "$SCHEME_TYPE" ] && THEME_TYPE="$SCHEME_TYPE"
    [ -n "$SOURCE_COLOR_INDEX" ] && THEME_INDEX="$SOURCE_COLOR_INDEX"
fi

if [ "$THEME_MODE" = "light" ]; then
    ITEM_THEME_MODE=$(format_item "󰖙" "Modo de Apariencia" "Claro")
else
    ITEM_THEME_MODE=$(format_item "󰖔" "Modo de Apariencia" "Oscuro")
fi

case "$THEME_TYPE" in
    "scheme-fidelity")    TYPE_LABEL="Fidelidad" ;;
    "scheme-content")     TYPE_LABEL="Contenido" ;;
    "scheme-vibrant")     TYPE_LABEL="Vibrante" ;;
    "scheme-expressive")  TYPE_LABEL="Expresivo" ;;
    "scheme-tonal-spot")  TYPE_LABEL="Tonal Spot" ;;
    "scheme-fruit-salad") TYPE_LABEL="Fruit Salad" ;;
    "scheme-rainbow")     TYPE_LABEL="Arcoíris" ;;
    "scheme-neutral")     TYPE_LABEL="Neutro" ;;
    "scheme-monochrome")  TYPE_LABEL="Monocromo" ;;
    *)                    TYPE_LABEL="${THEME_TYPE#scheme-}" ;;
esac
ITEM_THEME_TYPE=$(format_item "󰏘" "Estilo de Paleta" "$TYPE_LABEL")
ITEM_THEME_INDEX=$(format_item "󰌁" "Variante de Color" "Tono $THEME_INDEX")

# Resolver ruta a set-wallpaper.sh
if [ -x "$HOME/.local/bin/set-wallpaper.sh" ]; then
    WALLPAPER_SCRIPT="$HOME/.local/bin/set-wallpaper.sh"
elif [ -x "$(dirname "${BASH_SOURCE[0]}")/set-wallpaper.sh" ]; then
    WALLPAPER_SCRIPT="$(dirname "${BASH_SOURCE[0]}")/set-wallpaper.sh"
else
    WALLPAPER_SCRIPT="set-wallpaper.sh"
fi

# ── 2. Lista de Opciones Formateada ────────────────────────────
OPCIONES="$(format_item "󰍹" "Pantallas y Monitores" "Configurar")
$ITEM_THEME_MODE
$ITEM_THEME_TYPE
$ITEM_THEME_INDEX
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
$(format_item "󰌌" "Guía de Atajos y Alias" "Ver")
$(format_item "󰞅" "Selector de Emojis" "Copiar")
$(format_item "󰅖" "Limpiar Portapapeles" "Vaciar")"

# ── 3. Lanzar Wofi ──────────────────────────────────────────────
SELECCION=$(echo -e "$OPCIONES" | wofi --dmenu \
    --prompt "  󰒓  Centro de Control" \
    --cache-file /dev/null \
    --insensitive \
    --width 500 \
    --height 580 \
    --lines 17)

# Salir si se canceló
[ -z "$SELECCION" ] && exit 0

# ── 4. Ejecución de Acciones ────────────────────────────────────
case "$SELECCION" in
    *"Modo de Apariencia"*)
        MODE_OPTIONS="$(format_item "󰖔" "Modo Oscuro (Dark)" "$([ "$THEME_MODE" = "dark" ] && echo "Activo")")
$(format_item "󰖙" "Modo Claro (Light)" "$([ "$THEME_MODE" = "light" ] && echo "Activo")")"
        MODE_SEL=$(echo -e "$MODE_OPTIONS" | wofi --dmenu --prompt "  󰔎  Modo de Apariencia" --width 420 --height 180 --lines 2)
        case "$MODE_SEL" in
            *"Oscuro"*)
                "$WALLPAPER_SCRIPT" --mode dark
                ;;
            *"Claro"*)
                "$WALLPAPER_SCRIPT" --mode light
                ;;
        esac
        ;;
    *"Estilo de Paleta"*)
        PALETTE_OPTIONS="$(format_item "󰓎" "scheme-fidelity" "Fidelidad al Fondo")
$(format_item "󰝤" "scheme-tonal-spot" "Equilibrado (Default)")
$(format_item "󰑮" "scheme-vibrant" "Colores Vivos / Saturados")
$(format_item "󰓥" "scheme-expressive" "Acentos Creativos")
$(format_item "󰅩" "scheme-content" "Matiz del Fondo")
$(format_item "󰌯" "scheme-fruit-salad" "Fresco y Contrastado")
$(format_item "󰌮" "scheme-rainbow" "Gama Cromática")
$(format_item "󰄲" "scheme-neutral" "Sobrio y Desaturado")
$(format_item "󰎞" "scheme-monochrome" "Gris Monocromático")"
        PALETTE_SEL=$(echo -e "$PALETTE_OPTIONS" | wofi --dmenu --prompt "  󰏘  Paleta Material 3" --width 520 --height 430 --lines 9)
        if [ -n "$PALETTE_SEL" ]; then
            SELECTED_TYPE=$(echo "$PALETTE_SEL" | awk '{print $2}')
            if [ -n "$SELECTED_TYPE" ]; then
                "$WALLPAPER_SCRIPT" --type "$SELECTED_TYPE"
            fi
        fi
        ;;
    *"Variante de Color"*)
        VARIANT_OPTIONS="$(format_item "󰌁" "Índice 0" "Color Primario Dominante")
$(format_item "󰌁" "Índice 1" "Color Secundario")
$(format_item "󰌁" "Índice 2" "Color Terciario")
$(format_item "󰌁" "Índice 3" "Color Acento")
$(format_item "󰌁" "Índice 4" "Color Alternativo")"
        VARIANT_SEL=$(echo -e "$VARIANT_OPTIONS" | wofi --dmenu --prompt "  󰌁  Tono Base del Fondo" --width 460 --height 280 --lines 5)
        if [ -n "$VARIANT_SEL" ]; then
            SELECTED_IDX=$(echo "$VARIANT_SEL" | grep -oE 'Índice [0-4]' | awk '{print $2}')
            if [ -n "$SELECTED_IDX" ]; then
                "$WALLPAPER_SCRIPT" --index "$SELECTED_IDX"
            fi
        fi
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
    *"Distribución Teclado"*|*"Teclado"*)
        "$SCRIPTS_DIR/keyboard-layout.sh" menu
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
    *"Selector de Color"*)
        "$SCRIPTS_DIR/color-picker.sh"
        ;;
    *"Captura de Pantalla"*)
        "$SCRIPTS_DIR/screenshot.sh"
        ;;
    *"Guía de Atajos y Alias"*|*"Atajos y Alias"*)
        CHEATSHEET="$HOME/.config/sway/cheatsheet.md"
        [ ! -f "$CHEATSHEET" ] && CHEATSHEET="$HOME/Documents/dotfileSway/config/cheatsheet.md"
        [ ! -f "$CHEATSHEET" ] && CHEATSHEET="$HOME/Documentos/Github/dotfileSway/config/cheatsheet.md"
        if command -v zed &>/dev/null; then
            zed "$CHEATSHEET" &
        elif command -v nano &>/dev/null; then
            foot --title="Guía de Atajos y Alias" -e nano "$CHEATSHEET" &
        else
            xdg-open "$CHEATSHEET" &
        fi
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
