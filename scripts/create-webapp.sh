#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║  create-webapp.sh — Crear WebApp limpia sin barra de ventana ║
# ╚══════════════════════════════════════════════════════════════╝

set -e

NAME="$1"
URL="$2"
ICON="${3:-web-browser}"

if [ -z "$NAME" ] || [ -z "$URL" ]; then
    echo "Uso: create-webapp.sh \"Nombre de la App\" \"https://url-del-sitio.com\" [icono_opcional]"
    echo "Ejemplo: create-webapp.sh \"WhatsApp\" \"https://web.whatsapp.com\""
    exit 1
fi

APPS_DIR="$HOME/.local/share/applications"
mkdir -p "$APPS_DIR"

SLUG=$(echo "$NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
DESKTOP_FILE="$APPS_DIR/webapp-$SLUG.desktop"

# Detectar binario de Brave o Chromium disponible
BROWSER_BIN=""
if command -v brave-origin &>/dev/null; then
    BROWSER_BIN="brave-origin"
elif [ -x "/opt/brave-origin-bin/brave-origin" ]; then
    BROWSER_BIN="/opt/brave-origin-bin/brave-origin"
elif command -v brave-browser &>/dev/null; then
    BROWSER_BIN="brave-browser"
elif command -v brave &>/dev/null; then
    BROWSER_BIN="brave"
elif command -v chromium &>/dev/null; then
    BROWSER_BIN="chromium"
else
    echo "❌ No se encontró Brave ni Chromium instalado."
    exit 1
fi

cat << EOF > "$DESKTOP_FILE"
[Desktop Entry]
Version=1.0
Terminal=false
Type=Application
Name=$NAME
Exec=$BROWSER_BIN --app=$URL
Icon=$ICON
StartupWMClass=$SLUG
Categories=Network;WebBrowser;
EOF

chmod +x "$DESKTOP_FILE"
command -v update-desktop-database &>/dev/null && update-desktop-database "$APPS_DIR" 2>/dev/null || true

echo "✅ WebApp creada exitosamente:"
echo "   Nombre:  $NAME"
echo "   URL:     $URL"
echo "   Archivo: $DESKTOP_FILE"
echo "   Modo:    Limpio (--app, sin barra de título ni marcos redundantes)"
