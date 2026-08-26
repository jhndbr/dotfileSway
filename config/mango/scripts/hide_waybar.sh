#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║        Toggle Waybar (Mostrar / Ocultar)                       ║
# ╚══════════════════════════════════════════════════════════════╝

if pgrep -x waybar >/dev/null; then
    pkill waybar
else
    waybar -c ~/.config/mango/waybar/config.jsonc -s ~/.config/mango/waybar/style.css >/dev/null 2>&1 &
fi
