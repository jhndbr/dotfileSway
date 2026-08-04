#!/usr/bin/env python3

# ╔══════════════════════════════════════════════════════════════╗
# ║  Generador / Sincronizador Dinámico de Color de Iconos Papirus ║
# ╚══════════════════════════════════════════════════════════════╝

import json
import os
import sys
import colorsys
import subprocess

def get_papirus_color(hex_color):
    hex_val = hex_color.lstrip("#")
    r, g, b = tuple(int(hex_val[i:i+2], 16) / 255.0 for i in (0, 2, 4))
    h, s, v = colorsys.rgb_to_hsv(r, g, b)
    hue_deg = h * 360.0
    if s < 0.15:
        return "grey"
    elif 345 <= hue_deg or hue_deg < 15:
        return "red"
    elif 15 <= hue_deg < 45:
        return "orange"
    elif 45 <= hue_deg < 70:
        return "yellow"
    elif 70 <= hue_deg < 165:
        return "green"
    elif 165 <= hue_deg < 195:
        return "teal"
    elif 195 <= hue_deg < 225:
        return "cyan"
    elif 225 <= hue_deg < 265:
        return "blue"
    elif 265 <= hue_deg < 315:
        return "violet"
    else:
        return "magenta"

def main():
    json_path = "/tmp/dank16.json"
    if not os.path.exists(json_path):
        return

    try:
        with open(json_path, "r") as f:
            data = json.load(f)
        hex_color = data["dank16"]["color4"]["default"]["hex"]
    except Exception:
        hex_color = "#3498db"

    color_name = get_papirus_color(hex_color)
    print(f"🎨 Color de carpetas/iconos seleccionado: {color_name} (hex: {hex_color})")

    papirus_bin = os.path.expanduser("~/.local/bin/papirus-folders")
    if not os.path.exists(papirus_bin):
        papirus_bin = "papirus-folders"

    res = subprocess.run([papirus_bin, "-C", color_name, "-t", "Papirus-Dark"], capture_output=True, text=True)
    if res.returncode != 0:
        subprocess.run([papirus_bin, "-C", color_name, "-t", "Papirus"], capture_output=True, text=True)

if __name__ == "__main__":
    main()
