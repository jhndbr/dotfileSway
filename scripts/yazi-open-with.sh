#!/usr/bin/env python3
# ╔══════════════════════════════════════════════════════════════╗
# ║        yazi-open-with.sh — Selector Universal de Apps        ║
# ║        Soporte robusto Wayland · Rutas Absolutas · Wofi      ║
# ╚══════════════════════════════════════════════════════════════╝

import sys
import os
import glob
import re
import subprocess
import configparser

def notify(title, msg):
    try:
        subprocess.run(["dunstify", "-a", "Yazi", "-u", "low", title, msg], check=False)
    except Exception:
        pass

# Filtrar argumentos no vacíos
args = [a.strip() for a in sys.argv[1:] if a.strip()]

if not args:
    notify("Yazi", "No se especificó ningún archivo para abrir")
    sys.exit(1)

# Convertir a rutas absolutas válidas
targets = [os.path.abspath(a) for a in args]
valid_targets = [t for t in targets if os.path.exists(t)]

if not valid_targets:
    notify("Yazi Error", f"El archivo no fue encontrado:\n{targets[0]}")
    sys.exit(1)

primary_target = valid_targets[0]
target_name = os.path.basename(primary_target)
targets_quoted = " ".join([f'"{t}"' for t in valid_targets])

# Directorios estándar de aplicaciones (.desktop)
dirs = [
    os.path.expanduser("~/.local/share/applications"),
    "/usr/local/share/applications",
    "/usr/share/applications",
    "/var/lib/flatpak/exports/share/applications"
]

apps = {}

for d in dirs:
    if not os.path.exists(d):
        continue
    for filepath in glob.glob(os.path.join(d, "*.desktop")):
        basename = os.path.basename(filepath)
        desktop_id = basename[:-8] if basename.endswith(".desktop") else basename
        if desktop_id in apps:
            continue
        try:
            config = configparser.ConfigParser(interpolation=None)
            config.read(filepath, encoding="utf-8")
            if "Desktop Entry" in config:
                entry = config["Desktop Entry"]
                if entry.get("NoDisplay", "false").lower() == "true" or entry.get("Hidden", "false").lower() == "true":
                    continue
                name = entry.get("Name", desktop_id)
                exec_cmd = entry.get("Exec", "")
                if not exec_cmd:
                    continue
                icon = entry.get("Icon", "")
                is_terminal = entry.get("Terminal", "false").lower() == "true"
                apps[desktop_id] = {
                    "name": name,
                    "exec": exec_cmd,
                    "terminal": is_terminal,
                    "icon": icon,
                    "path": filepath
                }
        except Exception:
            pass

if not apps:
    notify("Yazi", "No se encontraron aplicaciones instaladas")
    sys.exit(1)

# Ordenar alfabéticamente
sorted_apps = sorted(apps.items(), key=lambda x: x[1]["name"].lower())

# Formatear lista para Wofi
wofi_lines = [f"{data['name']} [{d_id}]" for d_id, data in sorted_apps]
wofi_input = "\n".join(wofi_lines)

# Lanzar Wofi dmenu
proc = subprocess.Popen(
    [
        "wofi",
        "--dmenu",
        "--prompt", f"  󰏦  Abrir '{target_name}' con...",
        "--cache-file", "/dev/null",
        "--insensitive",
        "--width", "500",
        "--height", "420",
        "--lines", "10"
    ],
    stdin=subprocess.PIPE,
    stdout=subprocess.PIPE,
    text=True
)

stdout, _ = proc.communicate(input=wofi_input)
selected = stdout.strip()

if not selected:
    sys.exit(0)

match = re.search(r"\[(.*)\]$", selected)
if not match:
    sys.exit(0)

desktop_id = match.group(1)
if desktop_id not in apps:
    sys.exit(0)

app_info = apps[desktop_id]
exec_cmd = app_info["exec"]

# Reemplazar códigos de campo de los .desktop (%f, %F, %u, %U, etc.)
has_code = False
for code in ["%f", "%F", "%u", "%U", "%d", "%D", "%n", "%N", "%k", "%v"]:
    if code in exec_cmd:
        exec_cmd = exec_cmd.replace(code, targets_quoted)
        has_code = True

# Si el .desktop no tenía ningún código de argumento, agregamos las rutas al final
if not has_code:
    exec_cmd = f'{exec_cmd} {targets_quoted}'

# Limpiar cualquier parámetro residual %
exec_cmd = re.sub(r"%[a-zA-Z]", "", exec_cmd).strip()

# Si la aplicación requiere terminal, ejecutar dentro de foot
if app_info["terminal"]:
    final_cmd = f'foot --title="{app_info["name"]}" -e {exec_cmd}'
else:
    final_cmd = exec_cmd

# Lanzar proceso independiente con entorno Wayland completo y directorio del archivo
subprocess.Popen(
    final_cmd,
    shell=True,
    cwd=os.path.dirname(primary_target),
    env=os.environ.copy(),
    start_new_session=True
)
