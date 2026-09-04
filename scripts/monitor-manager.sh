#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║        Gestor Simple de Monitores para Sway & Waybar         ║
# ║        Sin daemons - Rápido, ligero y configurable           ║
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
        local first_name
        first_name=$(echo "$data" | jq -r '.[0].name // ""')
        if [[ "$first_name" =~ ^eDP|^LVDS ]]; then
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
    tooltip+=$'\n'"󰌌 Clic derecho: Auto-activar pantallas"

    jq -c -n \
        --arg text "$icon" \
        --arg tooltip "$tooltip" \
        --arg class "$class" \
        --arg alt "$class" \
        '{text: $text, tooltip: $tooltip, class: $class, alt: $alt}'
}

# ── 2. Acciones de Configuración ────────────────────────────────
auto_detect() {
    local data
    data=$(get_outputs_json)
    local count
    count=$(echo "$data" | jq 'length')

    if [ "$count" -le 1 ]; then
        local name
        name=$(echo "$data" | jq -r '.[0].name // empty')
        if [ -n "$name" ]; then
            swaymsg output "$name" enable pos 0 0
            notify "Monitor Único" "Configurado $name como pantalla principal"
        fi
    else
        # Primer monitor (generalmente integrado eDP-1)
        local out1 out2
        out1=$(echo "$data" | jq -r '.[0].name')
        out2=$(echo "$data" | jq -r '.[1].name')
        local w1
        w1=$(echo "$data" | jq -r '.[0].current_mode.width // 1920')

        swaymsg output "$out1" enable pos 0 0
        swaymsg output "$out2" enable pos "$w1" 0
        notify "Dual Monitor Activado" "$out1 (0,0) + $out2 ($w1,0)"
    fi

    # Guardar cambios automáticamente
    action_save_config

    # Refrescar fondo de pantalla si existe script
    if [ -f "$HOME/.local/bin/set-wallpaper.sh" ]; then
        bash "$HOME/.local/bin/set-wallpaper.sh" &>/dev/null || true
    fi
}

action_extend_right() {
    local data
    data=$(get_outputs_json)
    local out1 out2 w1
    out1=$(echo "$data" | jq -r '.[0].name')
    out2=$(echo "$data" | jq -r '.[1].name // empty')

    if [ -z "$out2" ]; then
        notify "Aviso" "Solo hay una pantalla conectada"
        return
    fi

    w1=$(echo "$data" | jq -r '.[0].current_mode.width // 1920')
    swaymsg output "$out1" enable pos 0 0
    swaymsg output "$out2" enable pos "$w1" 0
    action_save_config
    notify "Pantallas Extendidas" "Secundaria ($out2) a la derecha de $out1"
}

action_extend_left() {
    local data
    data=$(get_outputs_json)
    local out1 out2 w2
    out1=$(echo "$data" | jq -r '.[0].name')
    out2=$(echo "$data" | jq -r '.[1].name // empty')

    if [ -z "$out2" ]; then
        notify "Aviso" "Solo hay una pantalla conectada"
        return
    fi

    w2=$(echo "$data" | jq -r '.[1].current_mode.width // 1920')
    swaymsg output "$out2" enable pos 0 0
    swaymsg output "$out1" enable pos "$w2" 0
    action_save_config
    notify "Pantallas Extendidas" "Secundaria ($out2) a la izquierda de $out1"
}

action_mirror() {
    local data
    data=$(get_outputs_json)
    local out1 out2
    out1=$(echo "$data" | jq -r '.[0].name')
    out2=$(echo "$data" | jq -r '.[1].name // empty')

    if [ -z "$out2" ]; then
        notify "Aviso" "Solo hay una pantalla conectada"
        return
    fi

    swaymsg output "$out1" enable pos 0 0
    swaymsg output "$out2" enable pos 0 0
    action_save_config
    notify "Modo Espejo" "Pantallas duplicadas en posición 0,0"
}

action_only_primary() {
    local data
    data=$(get_outputs_json)
    local out1 out2
    out1=$(echo "$data" | jq -r '.[0].name')
    out2=$(echo "$data" | jq -r '.[1].name // empty')

    swaymsg output "$out1" enable pos 0 0
    if [ -n "$out2" ]; then
        swaymsg output "$out2" disable
    fi
    action_save_config
    notify "Solo Pantalla Principal" "Activada: $out1"
}

action_only_secondary() {
    local data
    data=$(get_outputs_json)
    local out1 out2
    out1=$(echo "$data" | jq -r '.[0].name')
    out2=$(echo "$data" | jq -r '.[1].name // empty')

    if [ -z "$out2" ]; then
        notify "Aviso" "No hay pantalla secundaria conectada"
        return
    fi

    swaymsg output "$out2" enable pos 0 0
    swaymsg output "$out1" disable
    action_save_config
    notify "Solo Pantalla Secundaria" "Activada: $out2 (Principal desactivada)"
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

    # Seleccionar pantalla
    local chosen_out
    chosen_out=$(echo "$outputs" | wofi --dmenu --prompt "Seleccionar Monitor" --width 300 --height 200 --lines 4)
    [ -z "$chosen_out" ] && return

    # Listar resoluciones disponibles
    local modes
    modes=$(echo "$data" | jq -r --arg name "$chosen_out" '.[] | select(.name == $name) | .modes[] | "\(.width)x\(.height) @ \((.refresh / 1000 | floor))Hz"' | sort -u -r -V)

    if [ -z "$modes" ]; then
        notify "Aviso" "No se pudieron obtener resoluciones automáticas para $chosen_out"
        return
    fi

    local chosen_mode
    chosen_mode=$(echo "$modes" | wofi --dmenu --prompt "Resolución para $chosen_out" --width 320 --height 300 --lines 8)
    [ -z "$chosen_mode" ] && return

    # Extraer ancho y alto
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
        action_save_config
        notify "Resolución Guardada" "$chosen_out: $chosen_mode (Permanente)"
    fi
}

action_scale_menu() {
    local data
    data=$(get_outputs_json)
    local outputs
    outputs=$(echo "$data" | jq -r '.[].name')

    [ -z "$outputs" ] && return

    local chosen_out
    chosen_out=$(echo "$outputs" | wofi --dmenu --prompt "Seleccionar Monitor para Escala" --width 300 --height 200 --lines 4)
    [ -z "$chosen_out" ] && return

    local scales="1.0  (100% - Normal)\n1.25 (125% - Escalado sutil)\n1.5  (150% - Escalado medio)\n1.75 (175% - Escalado alto)\n2.0  (200% - HiDPI / 4K)"
    local chosen_scale
    chosen_scale=$(echo -e "$scales" | wofi --dmenu --prompt "Escala para $chosen_out" --width 340 --height 260 --lines 5)
    [ -z "$chosen_scale" ] && return

    local val
    val=$(echo "$chosen_scale" | awk '{print $1}')
    if [ -n "$val" ]; then
        swaymsg output "$chosen_out" scale "$val"
        action_save_config
        notify "Escala Guardada" "$chosen_out: Escala fijada en $val (Permanente)"
    fi
}

action_save_config() {
    local data
    data=$(get_outputs_json)
    mkdir -p "$(dirname "$OUTPUTS_CONF")"

    {
        echo "# ╔══════════════════════════════════════════════════════════════╗"
        echo "# ║        Configuración Guardada de Monitores                   ║"
        echo "# ║        Generado automáticamente por monitor-manager.sh       ║"
        echo "# ╚══════════════════════════════════════════════════════════════╝"
        echo ""
    } > "$OUTPUTS_CONF"

    while IFS= read -r line; do
        [ -n "$line" ] && echo "$line" >> "$OUTPUTS_CONF"
    done < <(echo "$data" | jq -r '.[] | if .active then "output \(.name) enable mode \(.current_mode.width // 1920)x\(.current_mode.height // 1080)@\((.current_mode.refresh // 60000) / 1000 | floor)Hz pos \(.rect.x) \(.rect.y) scale \(.scale) adaptive_sync on allow_tearing yes max_render_time 1" else "output \(.name) disable" end')

    # Sincronizar con repo si existe
    local repo_outputs="$HOME/Documentos/Github/dotfileSway/config/sway/outputs.conf"
    if [ -f "$repo_outputs" ] && [ "$OUTPUTS_CONF" != "$repo_outputs" ]; then
        cp -f "$OUTPUTS_CONF" "$repo_outputs" 2>/dev/null || true
    fi
}

action_reload_sway() {
    swaymsg reload
    notify "Sway Recargado" "Se recargó la configuración de Sway y monitores"
}

# ── 3. Menú Principal Wofi ──────────────────────────────────────
menu() {
    local data
    data=$(get_outputs_json)
    local total
    total=$(echo "$data" | jq 'length')

    local opciones=""

    if [ "$total" -gt 1 ]; then
        opciones+="󰍺  Extender a la Derecha (Dual)\n"
        opciones+="󰍺  Extender a la Izquierda (Dual)\n"
        opciones+="󰑈  Duplicar Pantallas (Modo Espejo)\n"
        opciones+="󰌢  Solo Pantalla Principal\n"
        opciones+="󰍹  Solo Pantalla Externa (Docked)\n"
    fi

    opciones+="󰁨  Auto-configurar / Detectar Pantallas\n"
    opciones+="󰑮  Configurar Resolución y Refresco\n"
    opciones+="󰹑  Configurar Escala (Scaling)\n"
    opciones+="💾  Guardar Configuración Actual\n"
    opciones+="🔄  Recargar Sway"

    local seleccion
    seleccion=$(echo -e "$opciones" | wofi --dmenu \
        --prompt "Gestión de Monitores" \
        --cache-file /dev/null \
        --insensitive \
        --width 340 \
        --height 340 \
        --lines 9)

    case "$seleccion" in
        *"Extender a la Derecha"*)
            action_extend_right
            ;;
        *"Extender a la Izquierda"*)
            action_extend_left
            ;;
        *"Duplicar Pantallas"*)
            action_mirror
            ;;
        *"Solo Pantalla Principal"*)
            action_only_primary
            ;;
        *"Solo Pantalla Externa"*)
            action_only_secondary
            ;;
        *"Auto-configurar"*)
            auto_detect
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
    auto)
        auto_detect
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
