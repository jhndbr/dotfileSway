#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║        Estado de configuración de MangoWM                      ║
# ║        Ejecuta 'mango -p' y muestra el resultado               ║
# ╚══════════════════════════════════════════════════════════════╝

output=$(mango -p 2>&1 | sed -r '
    s/\x1b\[[0-9;]*[a-zA-Z]//g
    s/   ╰─/ ╰─/g
    s/^[[:space:]]*//
    s/[[:space:]]*$//
')

if [[ -z "$output" ]]; then
    exit 0
fi

notify-send --urgency=normal --app-name="MangoWM" "Mango Status" "$output"
