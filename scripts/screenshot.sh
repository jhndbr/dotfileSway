#!/usr/bin/env bash
# ====================================================================
# SwayShell Screenshot Utility (grim + slurp + wl-clipboard + notify)
# ====================================================================

MODE="${1:-region}"
SAVE_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$SAVE_DIR"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
TARGET_FILE="$SAVE_DIR/Screenshot_${TIMESTAMP}.png"

case "$MODE" in
    region)
        GEOM=$(slurp -d -b "#1e1e2ebb" -c "#cba6f7ff" -w 2 2>/dev/null)
        if [ -z "$GEOM" ]; then
            exit 0
        fi
        grim -g "$GEOM" "$TARGET_FILE"
        ;;
    fullscreen)
        sleep 0.2
        grim "$TARGET_FILE"
        ;;
    window)
        # Capture currently focused window in Sway via swaymsg and jq
        if command -v jq >/dev/null 2>&1; then
            GEOM=$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true).rect | "\(.x),\(.y) \(.width)x\(.height)"' 2>/dev/null)
        fi
        if [ -n "$GEOM" ]; then
            grim -g "$GEOM" "$TARGET_FILE"
        else
            grim "$TARGET_FILE"
        fi
        ;;
    *)
        echo "Usage: $0 [region|fullscreen|window]"
        exit 1
        ;;
esac

if [ -f "$TARGET_FILE" ]; then
    # Copy to Wayland clipboard
    if command -v wl-copy >/dev/null 2>&1; then
        wl-copy --type image/png < "$TARGET_FILE"
    fi

    # Send Notification non-blocking
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -i "$TARGET_FILE" \
            -a "SwayShell" \
            -u normal \
            "Captura guardada" \
            "Guardada en $SAVE_DIR y copiada al portapapeles" &
    fi
fi
