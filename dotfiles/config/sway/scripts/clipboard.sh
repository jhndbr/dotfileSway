#!/bin/sh
# Clipboard History selector via cliphist + wofi
# Minimalist, safe against cancellations

SELECTION=$(cliphist list | wofi --dmenu --prompt "Portapapeles" --width 600 --height 350 --insensitive)

if [ -n "$SELECTION" ]; then
    printf "%s\n" "$SELECTION" | cliphist decode | wl-copy
fi
