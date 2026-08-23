#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║        Gestor Inteligente de Monitores para Sway             ║
# ║        Netbook siempre principal · Detección Robusta de HDMI ║
# ╚══════════════════════════════════════════════════════════════╝

set -eo pipefail

OUTPUTS_CONF="$HOME/.config/sway/outputs.conf"

notify() {
    local title="$1"
    local msg="$2"
    if command -v dunstify &>/dev/null; then
        dunstify -a "Monitores" -u low -i video-display "$title" "$msg"
    elif command -v notify-send &>/dev/null; then
        notify-send -a "Monitores" -u low -i video-display "$title" "$msg"
    fi
}

get_outputs_json() {
    swaymsg -t get_outputs -r 2>/dev/null || echo "[]"
}

# Obtiene el nombre de la pantalla integrada (Netbook: eDP-1, LVDS-1, etc.)
get_internal_output() {
    local data="$1"
    local internal
    internal=$(echo "$data" | jq -r '.[] | select(.name | test("^(eDP|LVDS|DSI)")) | .name' | head -n 1)
    if [ -z "$internal" ]; then
        internal=$(echo "$data" | jq -r '.[0].name // empty')
    fi
    echo "$internal"
}

# Obtiene la pantalla externa (HDMI, DP, etc.)
get_external_output() {
    local data="$1"
    local internal="$2"
    local external
    external=$(echo "$data" | jq -r --arg int "$internal" '.[] | select(.name != $int and .active == true) | .name' | head -n 1)
    if [ -z "$external" ]; then
        external=$(echo "$data" | jq -r --arg int "$internal" '.[] | select(.name != $int) | .name' | head -n 1)
    fi
    echo "$external"
}

# Obtiene el ancho en píxeles de un monitor dado
get_output_width() {
    local data="$1"
    local name="$2"
    local w
    w=$(echo "$data" | jq -r --arg n "$name" '.[] | select(.name == $n) | .current_mode.width // .modes[0].width // 1920' | head -n 1)
    [ -z "$w" ] && w=1920
    echo "$w"
}

# ── 1. Salida JSON para Waybar ──────────────────────────────────
waybar_status() {
    local data
    data=$(get_outputs_json)

    if [ "$data" = "[]" ] || [ -z "$data" ]; then
        echo '{"text":"󰍹","tooltip":"No se detectaron salidas de Sway","class":"offline","alt":"offline"}'
        return
    fi

    local total active
    total=$(echo "$data" | jq 'length')
    active=$(echo "$data" | jq '[.[] | select(.active == true)] | length')

    local is_mirror=false
    if [ "$active" -gt 1 ]; then
        local x_coords
        x_coords=$(echo "$data" | jq -r '[.[] | select(.active == true) | .rect.x] | unique | length')
        if [ "$x_coords" -eq 1 ]; then
            is_mirror=true
        fi
    fi

    local icon="󰍹"
    local class="single"

    if [ "$is_mirror" = true ]; then
        icon="󰑈"
        class="mirror"
    elif [ "$active" -gt 1 ]; then
        icon="󰍺"
        class="dual"
    elif [ "$total" -gt 1 ] && [ "$active" -eq 1 ]; then
        icon="󰍹"
        class="connected"
    else
        local internal
        internal=$(get_internal_output "$data")
        if [ -n "$internal" ]; then
            icon="󰌢"
            class="laptop"
        else
            icon="󰍹"
            class="single"
        fi
    fi

    local tooltip="🖥️ Monitores Conectados ($active/$total activos)
───────────────────────────────"

    while IFS= read -r line; do
        tooltip+=$'\n'"$line"
    done < <(echo "$data" | jq -r '.[] | "• \(.name) [\(if .active then "ACTIVO" else "INACTIVO" end)]\n  Res: \(.current_mode.width // 0)x\(.current_mode.height // 0) @ \((.current_mode.refresh // 0) / 1000 | floor)Hz\n  Escala: \(.scale // 1.0) | Pos: (\(.rect.x),\(.rect.y))"')

    tooltip+=$'\n'"───────────────────────────────"
    tooltip+=$'\n'"󰌌 Clic izquierdo: Menú de opciones"
    tooltip+=$'\n'"󰌌 Clic derecho: Restablecer predeterminado"

    jq -c -n \
        --arg text "$icon" \
        --arg tooltip "$tooltip" \
        --arg class "$class" \
        --arg alt "$class" \
        '{text: $text, tooltip: $tooltip, class: $class, alt: $alt}'
}

# ── 2. Acciones de Configuración ────────────────────────────────

# Configuración Predeterminada (Netbook como Principal en 0,0 y Externa a la Derecha)
action_default() {
    local data
    data=$(get_outputs_json)
    local internal external
    internal=$(get_internal_output "$data")
    external=$(get_external_output "$data" "$internal")

    if [ -z "$internal" ]; then
        notify "Error" "No se detectó monitor disponible"
        return
    fi

    swaymsg output "$internal" enable pos 0 0

    if [ -n "$external" ]; then
        local w_int
        w_int=$(get_output_width "$data" "$internal")
        swaymsg output "$external" enable pos "$w_int" 0
        notify "󰌢 Configuración Predeterminada" "Netbook ($internal) Principal (0,0) + Externa ($external) Derecha"
    else
        notify "󰌢 Configuración Predeterminada" "Netbook ($internal) activa como pantalla principal"
    fi

    if [ -f "$HOME/.local/bin/set-wallpaper.sh" ]; then
        bash "$HOME/.local/bin/set-wallpaper.sh" &>/dev/null || true
    fi
}

# Extender Externa a la Derecha de la Netbook
action_extend_right() {
    local data
    data=$(get_outputs_json)
    local internal external
    internal=$(get_internal_output "$data")
    external=$(get_external_output "$data" "$internal")

    if [ -z "$external" ]; then
        notify "Aviso" "Solo se detecta la pantalla integrada ($internal)"
        return
    fi

    local w_int
    w_int=$(get_output_width "$data" "$internal")
    swaymsg output "$internal" enable pos 0 0
    swaymsg output "$external" enable pos "$w_int" 0
    notify "󰍺 Pantallas Extendidas" "Netbook ($internal) en (0,0) | Externa ($external) a la derecha"
}

# Extender Externa a la Izquierda de la Netbook
action_extend_left() {
    local data
    data=$(get_outputs_json)
    local internal external
    internal=$(get_internal_output "$data")
    external=$(get_external_output "$data" "$internal")

    if [ -z "$external" ]; then
        notify "Aviso" "Solo se detecta la pantalla integrada ($internal)"
        return
    fi

    local w_ext
    w_ext=$(get_output_width "$data" "$external")
    swaymsg output "$external" enable pos 0 0
    swaymsg output "$internal" enable pos "$w_ext" 0
    notify "󰍺 Pantallas Extendidas" "Externa ($external) en (0,0) | Netbook ($internal) a la derecha"
}

# Modo Espejo (Duplicar Pantallas)
action_mirror() {
    local data
    data=$(get_outputs_json)
    local internal external
    internal=$(get_internal_output "$data")
    external=$(get_external_output "$data" "$internal")

    if [ -z "$external" ]; then
        notify "Aviso" "Solo hay una pantalla conectada"
        return
    fi

    swaymsg output "$internal" enable pos 0 0
    swaymsg output "$external" enable pos 0 0
    notify "󰑈 Modo Espejo" "Netbook ($internal) y Externa ($external) duplicadas en (0,0)"
}

# Solo Pantalla de Netbook (Apagar Externa)
action_only_internal() {
    local data
    data=$(get_outputs_json)
    local internal
    internal=$(get_internal_output "$data")

    if [ -z "$internal" ]; then
        notify "Error" "No se detectó pantalla interna"
        return
    fi

    swaymsg output "$internal" enable pos 0 0

    while IFS= read -r ext; do
        if [ -n "$ext" ]; then
            swaymsg output "$ext" disable
        fi
    done < <(echo "$data" | jq -r --arg int "$internal" '.[] | select(.name != $int) | .name')

    notify "󰌢 Solo Netbook" "Pantalla interna ($internal) activa. Pantalla externa apagada"
}

# Solo Pantalla Externa (Docked / Apagar Netbook)
action_only_external() {
    local data
    data=$(get_outputs_json)
    local internal external
    internal=$(get_internal_output "$data")
    external=$(get_external_output "$data" "$internal")

    if [ -z "$external" ]; then
        notify "Aviso" "No hay pantalla externa conectada"
        return
    fi

    swaymsg output "$external" enable pos 0 0
    if [ -n "$internal" ]; then
        swaymsg output "$internal" disable
    fi
    notify "󰍹 Solo Pantalla Externa" "Externa ($external) activa. Netbook ($internal) apagada"
}

action_resolution_menu() {
    local data
    data=$(get_outputs_json)
    local outputs
    outputs=$(echo "$data" | jq -r '.[].name')

    if [ -z "$outputs" ]; then
        notify "Error" "No se detectaron salidas"
        return
    fi

    local chosen_out
    chosen_out=$(echo "$outputs" | wofi --dmenu --prompt "Seleccionar Monitor" --width 320 --height 200 --lines 4)
    [ -z "$chosen_out" ] && return

    local modes
    modes=$(echo "$data" | jq -r --arg name "$chosen_out" '.[] | select(.name == $name) | .modes[] | "\(.width)x\(.height) @ \((.refresh / 1000 | floor))Hz"' | sort -u -r -V)

    if [ -z "$modes" ]; then
        notify "Aviso" "No se pudieron obtener resoluciones automáticas para $chosen_out"
        return
    fi

    local chosen_mode
    chosen_mode=$(echo "$modes" | wofi --dmenu --prompt "Resolución para $chosen_out" --width 340 --height 300 --lines 8)
    [ -z "$chosen_mode" ] && return

    local res
    res=$(echo "$chosen_mode" | awk '{print $1}')
    local hz
    hz=$(echo "$chosen_mode" | awk '{print $3}' | sed 's/Hz//')

    if [ -n "$res" ]; then
        if [ -n "$hz" ] && [ "$hz" -gt 0 ] 2>/dev/null; then
            swaymsg output "$chosen_out" mode "${res}@${hz}Hz" || swaymsg output "$chosen_out" mode "$res"
        else
            swaymsg output "$chosen_out" mode "$res"
        fi
        notify "Resolución Cambiada" "$chosen_out configurado a $chosen_mode"
    fi
}

action_scale_menu() {
    local data
    data=$(get_outputs_json)
    local outputs
    outputs=$(echo "$data" | jq -r '.[].name')

    [ -z "$outputs" ] && return

    local chosen_out
    chosen_out=$(echo "$outputs" | wofi --dmenu --prompt "Seleccionar Monitor para Escala" --width 320 --height 200 --lines 4)
    [ -z "$chosen_out" ] && return

    local scales="1.0  (100% - Normal)\n1.25 (125% - Escalado sutil)\n1.5  (150% - Escalado medio)\n1.75 (175% - Escalado alto)\n2.0  (200% - HiDPI / 4K)"
    local chosen_scale
    chosen_scale=$(echo -e "$scales" | wofi --dmenu --prompt "Escala para $chosen_out" --width 340 --height 260 --lines 5)
    [ -z "$chosen_scale" ] && return

    local val
    val=$(echo "$chosen_scale" | awk '{print $1}')
    if [ -n "$val" ]; then
        swaymsg output "$chosen_out" scale "$val"
        notify "Escala Aplicada" "$chosen_out: Escala fijada en $val"
    fi
}

action_save_config() {
    local data
    data=$(get_outputs_json)
    mkdir -p "$(dirname "$OUTPUTS_CONF")"

    {
        echo "# ╔══════════════════════════════════════════════════════════════╗"
        echo "# ║        Configuración Guardada de Monitores                   ║"
        echo "# ╚══════════════════════════════════════════════════════════════╝"
        echo ""
    } > "$OUTPUTS_CONF"

    while IFS= read -r line; do
        echo "$line" >> "$OUTPUTS_CONF"
    done < <(echo "$data" | jq -r '.[] | if .active then "output \(.name) enable mode \(.current_mode.width // 1920)x\(.current_mode.height // 1080)@\((.current_mode.refresh // 60000) / 1000 | floor)Hz pos \(.rect.x) \(.rect.y) scale \(.scale)" else "output \(.name) disable" end')

    notify "Configuración Guardada" "Guardado en ~/.config/sway/outputs.conf"
}

action_reload_sway() {
    swaymsg reload
    notify "Sway Recargado" "Se recargó la configuración de Sway y monitores"
}

# ── 3. Menú Principal Wofi ──────────────────────────────────────
menu() {
    local data
    data=$(get_outputs_json)
    local internal external
    internal=$(get_internal_output "$data")
    external=$(get_external_output "$data" "$internal")

    local opciones=""

    if [ -n "$external" ]; then
        opciones+="󰌢  Predeterminado: Netbook ($internal) Principal + Externa ($external) Derecha\n"
        opciones+="󰍺  Extender: Externa ($external) a la Izquierda de Netbook\n"
        opciones+="󰑈  Duplicar Pantallas (Modo Espejo)\n"
        opciones+="󰌢  Solo Netbook ($internal) (Apagar Externa)\n"
        opciones+="󰍹  Solo Pantalla Externa ($external) (Apagar Netbook)\n"
    else
        opciones+="󰌢  Restablecer Pantalla Netbook ($internal) como Principal\n"
    fi

    opciones+="󰁨  Auto-detectar Monitores\n"
    opciones+="󰑮  Configurar Resolución y Refresco\n"
    opciones+="󰹑  Configurar Escala (Scaling)\n"
    opciones+="💾  Guardar Configuración Actual\n"
    opciones+="🔄  Recargar Sway"

    local seleccion
    seleccion=$(echo -e "$opciones" | wofi --dmenu \
        --prompt "  󰍹  Gestión de Monitores" \
        --cache-file /dev/null \
        --insensitive \
        --width 520 \
        --height 380 \
        --lines 10)

    case "$seleccion" in
        *"Predeterminado"*|*"Restablecer"*)
            action_default
            ;;
        *"a la Izquierda"*)
            action_extend_left
            ;;
        *"Duplicar Pantallas"*)
            action_mirror
            ;;
        *"Solo Netbook"*)
            action_only_internal
            ;;
        *"Solo Pantalla Externa"*)
            action_only_external
            ;;
        *"Auto-detectar"*)
            action_default
            ;;
        *"Configurar Resolución"*)
            action_resolution_menu
            ;;
        *"Configurar Escala"*)
            action_scale_menu
            ;;
        *"Guardar Configuración"*)
            action_save_config
            ;;
        *"Recargar Sway"*)
            action_reload_sway
            ;;
    esac
}

# ── Selector de Comandos ────────────────────────────────────────
case "$1" in
    waybar|status)
        waybar_status
        ;;
    menu)
        menu
        ;;
    default|reset|primary|auto)
        action_default
        ;;
    extend-right)
        action_extend_right
        ;;
    extend-left)
        action_extend_left
        ;;
    mirror)
        action_mirror
        ;;
    only-internal|laptop)
        action_only_internal
        ;;
    only-external|external)
        action_only_external
        ;;
    save)
        action_save_config
        ;;
    reload)
        action_reload_sway
        ;;
    *)
        menu
        ;;
esac
