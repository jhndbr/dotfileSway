#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║        yazi-open-with.sh — Selector Universal de Apps        ║
# ╚══════════════════════════════════════════════════════════════╝

TARGET_FILE="$1"

if [ -z "$TARGET_FILE" ]; then
    notify-send "Yazi Open-With" "No se especificó ningún archivo para abrir" -u critical
    exit 1
fi

# Recopilar apps .desktop válidas mediante Python
APPS_LIST=$(python3 -c "
import os, glob, configparser

dirs = [
    os.path.expanduser('~/.local/share/applications'),
    '/usr/local/share/applications',
    '/usr/share/applications',
    '/var/lib/flatpak/exports/share/applications'
]

apps = {}
for d in dirs:
    if not os.path.exists(d):
        continue
    for filepath in glob.glob(os.path.join(d, '*.desktop')):
        basename = os.path.basename(filepath)
        desktop_id = basename[:-8]
        if desktop_id in apps:
            continue
        try:
            config = configparser.ConfigParser(interpolation=None)
            config.read(filepath, encoding='utf-8')
            if 'Desktop Entry' in config:
                entry = config['Desktop Entry']
                if entry.get('NoDisplay') == 'true' or entry.get('Hidden') == 'true':
                    continue
                name = entry.get('Name', desktop_id)
                apps[desktop_id] = name
        except Exception:
            pass

sorted_apps = sorted(apps.items(), key=lambda x: x[1].lower())
for desktop_id, name in sorted_apps:
    print(f'{name} [{desktop_id}]')
")

if [ -z "$APPS_LIST" ]; then
    notify-send "Yazi Open-With" "No se encontraron aplicaciones instaladas en el sistema"
    exit 1
fi

# Selector gráfico mediante Wofi
SELECTED=$(echo "$APPS_LIST" | wofi --dmenu --prompt "Abrir '$TARGET_FILE' con...")

if [ -n "$SELECTED" ]; then
    DESKTOP_ID=$(echo "$SELECTED" | sed -n 's/.*\[\(.*\)\].*/\1/p')
    
    if command -v gtk-launch &>/dev/null && [ -n "$DESKTOP_ID" ]; then
        gtk-launch "$DESKTOP_ID" "$TARGET_FILE" &
    else
        python3 -c "
import sys, subprocess, configparser, os, glob

desktop_id = '$DESKTOP_ID'
target = '''$TARGET_FILE'''

dirs = [
    os.path.expanduser('~/.local/share/applications'),
    '/usr/local/share/applications',
    '/usr/share/applications',
    '/var/lib/flatpak/exports/share/applications'
]

filepath = None
for d in dirs:
    p = os.path.join(d, desktop_id + '.desktop')
    if os.path.exists(p):
        filepath = p
        break

if filepath:
    config = configparser.ConfigParser(interpolation=None)
    config.read(filepath, encoding='utf-8')
    exec_str = config['Desktop Entry'].get('Exec', '')
    for code in ['%f', '%F', '%u', '%U', '%d', '%D', '%n', '%N', '%k', '%v']:
        exec_str = exec_str.replace(code, f'\"{target}\"')
    subprocess.Popen(exec_str, shell=True, start_new_session=True)
" &
    fi
fi
