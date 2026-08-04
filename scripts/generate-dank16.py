#!/usr/bin/env python3

# ╔══════════════════════════════════════════════════════════════╗
# ║        Dank16 Context Generator                              ║
# ║        Construye el contexto JSON Dank16 desde Pywal         ║
# ╚══════════════════════════════════════════════════════════════╝

import os
import sys
import json

cache_file = os.path.expanduser("~/.cache/wal/colors.json")

if not os.path.exists(cache_file):
    sys.exit(1)

with open(cache_file, "r") as f:
    data = json.load(f)

colors = data.get("colors", {})
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
