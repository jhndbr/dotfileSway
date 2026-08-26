#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║      Gestor Simple de Monitores para MangoWM & Waybar        ║
# ║      Sin daemons - Rápido, ligero y configurable              ║
# ║      Usa mmsg + wlr-randr (MangoWM no soporta swaymsg)       ║
# ╚══════════════════════════════════════════════════════════════╝

set -eo pipefail

MONITOR_CONF="$HOME/.config/mango/monitor.conf"

notify() {
    local title="$1"
    local msg="$2"
    if command -v dunstify &>/dev/null; then
        dunstify -a "Monitores" -u low -i video-display "$title" "$msg"
    elif command -v notify-send &>/dev/null; then
        notify-send -a "Monitores" -u low -i video-display "$title" "$msg"
    fi
}

# ── Detección de salidas ───────────────────────────────────────
# MangoWM no tiene un get_outputs JSON equivalente a swaymsg.
# Usamos wlr-randr (recomendado por la docs oficial de MangoWM)
# y mmsg -O como respaldo.

get_outputs_raw() {
    if command -v wlr-randr &>/dev/null; then
        wlr-randr 2>/dev/null || true
    fi
}

# Lista de nombres de salida, una por línea
list_output_names() {
    if command -v mmsg &>/dev/null && pgrep -x mango &>/dev/null; then
        mmsg -O 2>/dev/null | grep -vE '^\s*$'
    else
        wlr-randr 2>/dev/null | grep -oE '^[A-Za-z0-9-]+(,|$)' | sed 's/,$//'
    fi
}

# ── 1. Salida JSON para Waybar ──────────────────────────────────
waybar_status() {
    local total=0 active=0
    local names
    names=$(list_output_names)

    if [ -z "$names" ]; then
        echo '{"text":"󰍹","tooltip":"No se detectaron salidas","class":"offline","alt":"offline"}'
        return
    fi

    total=$(echo "$names" | wc -l | tr -d ' ')

    # MangoWM enciende todas las salidas conectadas por defecto; asumimos activas
    # salvo las que wlr-randr marca como (off).
    local off_count=0
    if command -v wlr-randr &>/dev/null; then
        off_count=$(wlr-randr 2>/dev/null | grep -cE '\(off\)' || true)
    fi
    active=$((total - off_count))
    [ "$active" -lt 0 ] && active=0

    local icon="󰍹"
    local class="single"

    if [ "$active" -gt 1 ]; then
        icon="󰍺"
        class="dual"
    elif [ "$total" -gt 1 ] && [ "$active" -eq 1 ]; then
        class="connected"
    fi

    local first_name
    first_name=$(echo "$names" | head -n1)
    if [[ "$first_name" =~ ^eDP|^LVDS ]] && [ "$active" -le 1 ]; then
        icon="󰌢"
        class="laptop"
    fi

    local tooltip="🖥️ Monitores Conectados ($active/$total activos)
───────────────────────────────"

    while IFS= read -r name; do
        [ -z "$name" ] && continue
        local state="ACTIVO"
        if wlr-randr 2>/dev/null | awk -v n="$name" '$1==n' | grep -q '(off)'; then
            state="INACTIVO"
        fi
        tooltip+=$'\n'"• $name [$state]"
    done <<< "$names"

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
    local names
    names=$(list_output_names)
    local count
    count=$(echo "$names" | wc -l | tr -d ' ')

    if [ "$count" -le 1 ]; then
        local name
        name=$(echo "$names" | head -n1)
        if [ -n "$name" ] && command -v wlr-randr &>/dev/null; then
            wlr-randr --output "$name" --pos 0,0 --on 2>/dev/null || true
            notify "Monitor Único" "Configurado $name como pantalla principal"
        fi
    else
        local out1 out2
        out1=$(echo "$names" | sed -n '1p')
        out2=$(echo "$names" | sed -n '2p')
        if command -v wlr-randr &>/dev/null; then
            wlr-randr --output "$out1" --pos 0,0 --on 2>/dev/null || true
            wlr-randr --output "$out2" --pos 1920,0 --on 2>/dev/null || true
        fi
        notify "Dual Monitor Activado" "$out1 (0,0) + $out2 (1920,0)"
    fi

    # Refrescar fondo de pantalla si existe script
    if [ -f "$HOME/.local/bin/set-wallpaper.sh" ]; then
        bash "$HOME/.local/bin/set-wallpaper.sh" &>/dev/null || true
    fi
}

action_extend_right() {
    local names out1 out2
    names=$(list_output_names)
    out1=$(echo "$names" | sed -n '1p')
    out2=$(echo "$names" | sed -n '2p')

    if [ -z "$out2" ]; then
        notify "Aviso" "Solo hay una pantalla conectada"
        return
    fi

    if command -v wlr-randr &>/dev/null; then
        wlr-randr --output "$out1" --pos 0,0 --on 2>/dev/null || true
        wlr-randr --output "$out2" --pos 1920,0 --on 2>/dev/null || true
    fi
    notify "Pantallas Extendidas" "Secundaria ($out2) a la derecha de $out1"
}

action_extend_left() {
    local names out1 out2
    names=$(list_output_names)
    out1=$(echo "$names" | sed -n '1p')
    out2=$(echo "$names" | sed -n '2p')

    if [ -z "$out2" ]; then
        notify "Aviso" "Solo hay una pantalla conectada"
        return
    fi

    if command -v wlr-randr &>/dev/null; then
        wlr-randr --output "$out2" --pos 0,0 --on 2>/dev/null || true
        wlr-randr --output "$out1" --pos 1920,0 --on 2>/dev/null || true
    fi
    notify "Pantallas Extendidas" "Secundaria ($out2) a la izquierda de $out1"
}

action_mirror() {
    local names out1 out2
    names=$(list_output_names)
    out1=$(echo "$names" | sed -n '1p')
    out2=$(echo "$names" | sed -n '2p')

    if [ -z "$out2" ]; then
        notify "Aviso" "Solo hay una pantalla conectada"
        return
    fi

    # Espejo: misma posición para ambas salidas
    if command -v wlr-randr &>/dev/null; then
        wlr-randr --output "$out1" --pos 0,0 --on 2>/dev/null || true
        wlr-randr --output "$out2" --pos 0,0 --on 2>/dev/null || true
    fi
    notify "Modo Espejo" "Pantallas duplicadas en posición 0,0"
}

action_only_primary() {
    local names out1 out2
    names=$(list_output_names)
    out1=$(echo "$names" | sed -n '1p')
    out2=$(echo "$names" | sed -n '2p')

    if [ -n "$out1" ] && command -v wlr-randr &>/dev/null; then
        wlr-randr --output "$out1" --pos 0,0 --on 2>/dev/null || true
    fi
    if [ -n "$out2" ]; then
        wlr-randr --output "$out2" --off 2>/dev/null || true
    fi
    notify "Solo Pantalla Principal" "Activada: $out1"
}

action_only_secondary() {
    local names out1 out2
    names=$(list_output_names)
    out1=$(echo "$names" | sed -n '1p')
    out2=$(echo "$names" | sed -n '2p')

    if [ -z "$out2" ]; then
        notify "Aviso" "No hay pantalla secundaria conectada"
        return
    fi

    if command -v wlr-randr &>/dev/null; then
        wlr-randr --output "$out2" --pos 0,0 --on 2>/dev/null || true
        wlr-randr --output "$out1" --off 2>/dev/null || true
    fi
    notify "Solo Pantalla Secundaria" "Activada: $out2 (Principal desactivada)"
}

action_resolution_menu() {
    if ! command -v wlr-randr &>/dev/null; then
        notify "Error" "wlr-randr no está instalado (requerido por MangoWM)"
        return
    fi

    local names chosen_out
    names=$(list_output_names)
    if [ -z "$names" ]; then
        notify "Error" "No se detectaron salidas"
        return
    fi

    chosen_out=$(echo "$names" | wofi --dmenu --prompt "Seleccionar Monitor" --width 300 --height 200 --lines 4)
    [ -z "$chosen_out" ] && return

    # Listar modos disponibles desde wlr-randr
    local modes
    modes=$(wlr-randr --output "$chosen_out" 2>/dev/null \
        | grep -oE '[0-9]+x[0-9]+@[0-9.]+Hz' \
        | sort -u -r -V)

    if [ -z "$modes" ]; then
        notify "Aviso" "No se pudieron obtener resoluciones para $chosen_out"
        return
    fi

    local chosen_mode
    chosen_mode=$(echo "$modes" | wofi --dmenu --prompt "Resolución para $chosen_out" --width 320 --height 300 --lines 8)
    [ -z "$chosen_mode" ] && return

    # Formato: WxH@RHz
    wlr-randr --output "$chosen_out" --custom-mode "$chosen_mode" 2>/dev/null \
        || wlr-randr --output "$chosen_out" --mode "$chosen_mode" 2>/dev/null || true
    notify "Resolución Cambiada" "$chosen_out configurado a $chosen_mode"
}

action_scale_menu() {
    if ! command -v wlr-randr &>/dev/null; then
        notify "Error" "wlr-randr no está instalado (requerido por MangoWM)"
        return
    fi

    local names chosen_out
    names=$(list_output_names)
    [ -z "$names" ] && return

    chosen_out=$(echo "$names" | wofi --dmenu --prompt "Seleccionar Monitor para Escala" --width 300 --height 200 --lines 4)
    [ -z "$chosen_out" ] && return

    local scales="1.0  (100% - Normal)\n1.25 (125% - Escalado sutil)\n1.5  (150% - Escalado medio)\n1.75 (175% - Escalado alto)\n2.0  (200% - HiDPI / 4K)"
    local chosen_scale
    chosen_scale=$(echo -e "$scales" | wofi --dmenu --prompt "Escala para $chosen_out" --width 340 --height 260 --lines 5)
    [ -z "$chosen_scale" ] && return

    local val
    val=$(echo "$chosen_scale" | awk '{print $1}')
    if [ -n "$val" ]; then
        wlr-randr --output "$chosen_out" --scale "$val" 2>/dev/null || true
        notify "Escala Aplicada" "$chosen_out: Escala fijada en $val"
    fi
}

action_save_config() {
    if ! command -v wlr-randr &>/dev/null; then
        notify "Error" "wlr-randr no está instalado"
        return
    fi

    mkdir -p "$(dirname "$MONITOR_CONF")"

    {
        echo "# ╔══════════════════════════════════════════════════════════════╗"
        echo "# ║        MangoWM Monitor Rules                                   ║"
        echo "# ║        Generado automáticamente por monitor-manager.sh         ║"
        echo "# ╚══════════════════════════════════════════════════════════════╝"
        echo "#"
        echo "# Formato: monitorrule=name:<NAME>,width:W,height:H,refresh:R,x:X,y:Y,scale:S"
        echo "# Descomentar y ajustar según tu hardware (wlr-randr para obtener los datos)."
        echo ""
    } > "$MONITOR_CONF"

    local names
    names=$(list_output_names)
    while IFS= read -r name; do
        [ -z "$name" ] && continue
        local line
        line=$(wlr-randr 2>/dev/null | awk -v n="$name '
            $1==n {
                gsub(/[()]/, "", $0)
                print $0
            }')
        echo "# Salida detectada: $name"
        echo "# $line"
        echo "# monitorrule=name:$name,width:1920,height:1080,refresh:60,x:0,y:0,scale:1"
        echo ""
    done <<< "$names"

    notify "Configuración Guardada" "Guardado en $MONITOR_CONF"
}

action_reload_mango() {
    if command -v mmsg &>/dev/null && pgrep -x mango &>/dev/null; then
        mmsg -d reload_config
        notify "MangoWM Recargado" "Se recargó la configuración de MangoWM y monitores"
    else
        notify "Aviso" "MangoWM no está corriendo"
    fi
}

# ── 3. Menú Principal Wofi ──────────────────────────────────────
menu() {
    local names total
    names=$(list_output_names)
    total=$(echo "$names" | wc -l | tr -d ' ')

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
    opciones+="🔄  Recargar MangoWM"

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
        *"Recargar MangoWM"*)
            action_reload_mango
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
        action_reload_mango
        ;;
    *)
        menu
        ;;
esac
