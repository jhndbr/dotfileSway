#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║       thunar-terminal.sh — Abrir Foot desde Thunar           ║
# ╚══════════════════════════════════════════════════════════════╝

TARGET="${1:-$PWD}"

if [ -d "$TARGET" ]; then
    exec foot -D "$TARGET"
else
    DIR="$(dirname "$TARGET")"
    exec foot -D "$DIR"
fi
