#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║        Toggle Waybar (Mostrar / Ocultar)                       ║
# ╚══════════════════════════════════════════════════════════════╝

if pgrep -x waybar >/dev/null; then
    pkill waybar
else
    waybar -c "$HOME/.config/mango/waybar/config.jsonc" -s "$HOME/.config/mango/waybar/style.css" >/tmp/waybar.log 2>&1 &
fi
