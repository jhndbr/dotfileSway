#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║        Gestor Dinámico de Distribución de Teclado            ║
# ║        Cambia en caliente con mmsg y persiste config         ║
# ╚══════════════════════════════════════════════════════════════╝

CONFIG_FILE="$HOME/.config/mango/inputs.conf"
mkdir -p "$(dirname "$CONFIG_FILE")"

get_current_layout() {
    if [ -f "$CONFIG_FILE" ]; then
        if grep -q 'xkb_rules_layout=us,es' "$CONFIG_FILE"; then
            echo "dual"
        elif grep -q 'xkb_rules_variant=intl' "$CONFIG_FILE"; then
            echo "us-intl"
        elif grep -q 'xkb_rules_layout=us' "$CONFIG_FILE"; then
            echo "us"
        elif grep -q 'xkb_rules_layout=es' "$CONFIG_FILE"; then
            echo "es"
        else
            echo "es"
        fi
    else
        echo "es"
    fi
}

apply_layout() {
    local layout="$1"
    local desc=""
    case "$layout" in
        "es")
            cat > "$CONFIG_FILE" << 'EOF'
# ╔══════════════════════════════════════════════════════════════╗
# ║                    MangoWM Keyboard Layout                     ║
# ║                    Generado por keyboard-layout.sh              ║
# ╚══════════════════════════════════════════════════════════════╝

# ── Teclado Español (Latinoamericano / España) ──────────────────
xkb_rules_layout=es
repeat_delay=300
repeat_rate=50
EOF
            desc="Español (es)"
            ;;

        "us")
            cat > "$CONFIG_FILE" << 'EOF'
# ╔══════════════════════════════════════════════════════════════╗
# ║                    MangoWM Keyboard Layout                     ║
# ║                    Generado por keyboard-layout.sh              ║
# ╚══════════════════════════════════════════════════════════════╝

# ── Teclado Inglés EE.UU. (US Standard) ─────────────────────────
xkb_rules_layout=us
repeat_delay=300
repeat_rate=50
EOF
            desc="Inglés EE.UU. (us)"
            ;;

        "us-intl")
            cat > "$CONFIG_FILE" << 'EOF'
# ╔══════════════════════════════════════════════════════════════╗
# ║                    MangoWM Keyboard Layout                     ║
# ║                    Generado por keyboard-layout.sh              ║
# ╚══════════════════════════════════════════════════════════════╝

# ── Teclado Inglés Internacional (Dead Keys: '+a=á, ~+n=ñ) ─────
xkb_rules_layout=us
xkb_rules_variant=intl
repeat_delay=300
repeat_rate=50
EOF
            desc="US Internacional (tildes con '+a = á)"
            ;;

        "dual")
            cat > "$CONFIG_FILE" << 'EOF'
# ╔══════════════════════════════════════════════════════════════╗
# ║                    MangoWM Keyboard Layout                     ║
# ║                    Generado por keyboard-layout.sh              ║
# ╚══════════════════════════════════════════════════════════════╝

# ── Teclado Dual (US + ES con toggle Alt+Shift) ────────────────
xkb_rules_layout=us,es
xkb_rules_options=grp:alt_shift_toggle
repeat_delay=300
repeat_rate=50
EOF
            desc="US + ES (Alternar con Alt+Shift)"
            ;;
    esac

    if command -v mmsg &>/dev/null && pgrep -x mango &>/dev/null; then
        mmsg -d reload_config 2>/dev/null || true
    fi

    if command -v dunstify &>/dev/null; then
        dunstify -a "Teclado" -r 9950 -u low "⌨️ Teclado" "Distribución: $desc"
    fi
}

show_menu() {
    local cur
    cur=$(get_current_layout)
    
    local op_es="⌨️    Español (es)"
    local op_us="⌨️    Inglés EE.UU. (us)"
    local op_us_intl="⌨️    US Internacional (tildes '+a = á, ñ)"
    local op_dual="⌨️    Doble US + ES (Alternar con Alt+Shift)"

    [ "$cur" = "es" ] && op_es="$op_es    [Activo]"
    [ "$cur" = "us" ] && op_us="$op_us    [Activo]"
    [ "$cur" = "us-intl" ] && op_us_intl="$op_us_intl    [Activo]"
    [ "$cur" = "dual" ] && op_dual="$op_dual    [Activo]"

    local MENU="$op_es
$op_us
$op_us_intl
$op_dual"

    local SEL
    SEL=$(echo -e "$MENU" | wofi --dmenu \
        --prompt "  ⌨️  Distribución de Teclado" \
        --width 480 \
        --height 240 \
        --lines 4 \
        --insensitive)

    case "$SEL" in
        *"Español (es)"*)
            apply_layout "es"
            ;;
        *"Inglés EE.UU. (us)"*)
            apply_layout "us"
            ;;
        *"US Internacional"*)
            apply_layout "us-intl"
            ;;
        *"Doble US + ES"*)
            apply_layout "dual"
            ;;
    esac
}

toggle_layout() {
    local cur
    cur=$(get_current_layout)
    if [ "$cur" = "es" ]; then
        apply_layout "us"
    elif [ "$cur" = "us" ]; then
        apply_layout "us-intl"
    else
        apply_layout "es"
    fi
}

case "$1" in
    "set")
        apply_layout "$2"
        ;;
    "toggle")
        toggle_layout
        ;;
    "current")
        get_current_layout
        ;;
    "menu"|*)
        show_menu
        ;;
esac
