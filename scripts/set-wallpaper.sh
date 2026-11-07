#!/usr/bin/env bash
# ====================================================================
# SwayShell Wallpaper Manager
# Seamless switching, randomizer, gallery selector & persistence
# ====================================================================

WALLPAPER_DIR="${HOME}/Pictures/Wallpapers"
STATE_FILE="${HOME}/.config/quickshell/swayshell/wallpaper.current"
LINK_FILE="${HOME}/.config/quickshell/swayshell/wallpaper.png"
DEFAULT_WALL="${WALLPAPER_DIR}/catppuccin-asian-village.png"

mkdir -p "$WALLPAPER_DIR" "$(dirname "$STATE_FILE")"

# Collect valid wallpaper files (png, jpg, jpeg, webp)
get_wallpapers() {
    find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) | sort
}

apply_wallpaper() {
    local target="$1"

    if [ ! -f "$target" ]; then
        echo "Error: Wallpaper file not found: $target" >&2
        return 1
    fi

    echo "Setting wallpaper: $target"

    # Maintain stable symlink for Sway output config
    ln -sf "$target" "$LINK_FILE"

    # Tell Sway directly to update the background natively
    if [ -n "${SWAYSOCK:-}" ] || [ -e "/run/user/$(id -u)/sway-ipc.$(id -u)."*".sock" ]; then
        swaymsg "output * bg '$target' fill" 2>/dev/null || nohup swaybg -i "$target" -m fill >/dev/null 2>&1 &
    else
        nohup swaybg -i "$target" -m fill >/dev/null 2>&1 &
    fi

    # Persist choice
    echo "$target" > "$STATE_FILE"

    # Notify GNOME / Portals
    if command -v gsettings >/dev/null 2>&1; then
        gsettings set org.gnome.desktop.background picture-uri "file://$target" 2>/dev/null || true
        gsettings set org.gnome.desktop.background picture-uri-dark "file://$target" 2>/dev/null || true
    fi

    # Desktop notification with thumbnail
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -a "SwayShell" -i "$target" "Fondo de Pantalla" "Cambiado a: $(basename "$target")" -t 2500 2>/dev/null || true
    fi
}

case "${1:-restore}" in
    restore)
        if [ -f "$STATE_FILE" ] && [ -f "$(cat "$STATE_FILE")" ]; then
            apply_wallpaper "$(cat "$STATE_FILE")"
        elif [ -f "$DEFAULT_WALL" ]; then
            apply_wallpaper "$DEFAULT_WALL"
        else
            first_wall=$(get_wallpapers | head -n 1)
            if [ -n "$first_wall" ]; then
                apply_wallpaper "$first_wall"
            else
                echo "No wallpapers found in $WALLPAPER_DIR. Setting solid background."
                swaybg -o * -c "#1e1e2e" &
            fi
        fi
        ;;

    next)
        mapfile -t walls < <(get_wallpapers)
        if [ ${#walls[@]} -eq 0 ]; then
            echo "No wallpapers in $WALLPAPER_DIR"
            exit 1
        fi

        current=""
        [ -f "$STATE_FILE" ] && current=$(cat "$STATE_FILE")

        next_idx=0
        for i in "${!walls[@]}"; do
            if [ "${walls[$i]}" = "$current" ]; then
                next_idx=$(( (i + 1) % ${#walls[@]} ))
                break
            fi
        done
        apply_wallpaper "${walls[$next_idx]}"
        ;;

    prev)
        mapfile -t walls < <(get_wallpapers)
        if [ ${#walls[@]} -eq 0 ]; then
            echo "No wallpapers in $WALLPAPER_DIR"
            exit 1
        fi

        current=""
        [ -f "$STATE_FILE" ] && current=$(cat "$STATE_FILE")

        prev_idx=$(( ${#walls[@]} - 1 ))
        for i in "${!walls[@]}"; do
            if [ "${walls[$i]}" = "$current" ]; then
                prev_idx=$(( (i - 1 + ${#walls[@]}) % ${#walls[@]} ))
                break
            fi
        done
        apply_wallpaper "${walls[$prev_idx]}"
        ;;

    random)
        mapfile -t walls < <(get_wallpapers)
        if [ ${#walls[@]} -eq 0 ]; then
            echo "No wallpapers in $WALLPAPER_DIR"
            exit 1
        fi
        rand_idx=$(( RANDOM % ${#walls[@]} ))
        apply_wallpaper "${walls[$rand_idx]}"
        ;;

    select)
        if command -v zenity >/dev/null 2>&1; then
            selected=$(zenity --file-selection \
                --title="Seleccionar Fondo de Pantalla" \
                --filename="${WALLPAPER_DIR}/" \
                --file-filter="Imágenes (*.png *.jpg *.jpeg *.webp) | *.png *.jpg *.jpeg *.webp" 2>/dev/null)
            if [ -n "$selected" ] && [ -f "$selected" ]; then
                apply_wallpaper "$selected"
            fi
        else
            echo "zenity not found for visual selector."
            exit 1
        fi
        ;;

    *)
        if [ -f "$1" ]; then
            apply_wallpaper "$1"
        else
            echo "Uso: $0 {restore|next|prev|random|select|<ruta_a_imagen>}"
            exit 1
        fi
        ;;
esac
