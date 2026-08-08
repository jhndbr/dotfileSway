#!/usr/bin/env python3

# ╔══════════════════════════════════════════════════════════════╗
# ║  Generador / Sincronizador Dinámico de Color de Iconos Papirus ║
# ║  100% Sin Sudo / Sin Contraseña (Modo Usuario ~/.local/share)  ║
# ╚══════════════════════════════════════════════════════════════╝

import json
import os
import re
import sys
import colorsys
import subprocess

def get_papirus_color(hex_color):
    hex_val = hex_color.lstrip("#")
    r, g, b = tuple(int(hex_val[i:i+2], 16) / 255.0 for i in (0, 2, 4))
    h, s, v = colorsys.rgb_to_hsv(r, g, b)
    hue_deg = h * 360.0

    if s < 0.12:
        return "grey"
    elif 345 <= hue_deg or hue_deg < 15:
        return "red"
    elif 15 <= hue_deg < 45:
        return "orange"
    elif 45 <= hue_deg < 75:
        return "yellow"
    elif 75 <= hue_deg < 155:
        return "green"
    elif 155 <= hue_deg < 190:
        return "teal"
    elif 190 <= hue_deg < 225:
        return "cyan"
    elif 225 <= hue_deg < 265:
        return "blue"
    elif 265 <= hue_deg < 315:
        return "violet"
    else:
        return "magenta"

def get_matugen_accent():
    css_path = os.path.expanduser("~/.config/gtk-3.0/dank-colors.css")
    if os.path.exists(css_path):
        with open(css_path, "r") as f:
            content = f.read()
        match = re.search(r"@define-color\s+accent_bg_color\s+(#[0-9a-fA-F]{6});", content)
        if match:
            return match.group(1)

    json_path = "/tmp/dank16.json"
    if os.path.exists(json_path):
        try:
            with open(json_path, "r") as f:
                data = json.load(f)
            return data["dank16"]["color4"]["default"]["hex"]
        except Exception:
            pass

    return "#3498db"

def main():
    hex_color = get_matugen_accent()
    color_name = get_papirus_color(hex_color)
    print(f"🎨 Color de carpetas/iconos Papirus: {color_name} (hex acento: {hex_color})")

    # Cache para evitar re-ejecutar papirus-folders si el color no cambió
    cache_file = "/tmp/papirus_last_color"
    if os.path.exists(cache_file):
        try:
            with open(cache_file, "r") as f:
                if f.read().strip() == color_name:
                    print(f"⚡ Color de carpetas ya actualizado a '{color_name}'.")
                    return
        except Exception:
            pass

    papirus_bin = os.path.expanduser("~/.local/bin/papirus-folders")
    if not os.path.exists(papirus_bin):
        papirus_bin = "papirus-folders"

    user_icons = os.path.expanduser("~/.local/share/icons/Papirus-Dark")
    cmd_flags = ["-u", "-o"] if os.path.exists(user_icons) else ["-o"]

    subprocess.run([papirus_bin, "-C", color_name, "-t", "Papirus-Dark"] + cmd_flags, capture_output=True, text=True)
    subprocess.run([papirus_bin, "-C", color_name, "-t", "Papirus"] + cmd_flags, capture_output=True, text=True)

    try:
        with open(cache_file, "w") as f:
            f.write(color_name)
    except Exception:
        pass

if __name__ == "__main__":
    main()
