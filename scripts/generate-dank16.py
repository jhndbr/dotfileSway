#!/usr/bin/env python3

# ╔══════════════════════════════════════════════════════════════╗
# ║        Dank16 Context Generator                              ║
# ║        Construye el contexto JSON Dank16 desde Pywal         ║
# ╚══════════════════════════════════════════════════════════════╝

import os
import sys
import json

cache_file = os.path.expanduser("~/.cache/wal/colors.json")

default_colors = {
    "color0": "#1e1e2e", "color1": "#f38ba8", "color2": "#a6e3a1", "color3": "#f9e2af",
    "color4": "#89b4fa", "color5": "#f5c2e7", "color6": "#94e2d5", "color7": "#bac2de",
    "color8": "#585b70", "color9": "#f38ba8", "color10": "#a6e3a1", "color11": "#f9e2af",
    "color12": "#89b4fa", "color13": "#f5c2e7", "color14": "#94e2d5", "color15": "#a6adc8"
}

colors = dict(default_colors)

if os.path.exists(cache_file):
    try:
        with open(cache_file, "r") as f:
            data = json.load(f)
            wal_colors = data.get("colors", {})
            if wal_colors:
                colors.update(wal_colors)
    except Exception:
        pass

dank16 = {}

for i in range(16):
    hex_val = colors.get(f"color{i}", "#ffffff")
    stripped = hex_val.lstrip("#")
    entry = {"hex": hex_val, "hex_stripped": stripped}
    dank16[f"color{i}"] = {
        "default": entry,
        "light": entry,
        "dark": entry
    }

ctx = json.dumps({"dank16": dank16})
output_path = "/tmp/dank16.json"

with open(output_path, "w") as f:
    f.write(ctx)

print("✓ Contexto Dank16 generado en /tmp/dank16.json")
