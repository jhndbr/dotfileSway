#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║   fix-webapps.sh — Quitar barra de ventana en WebApps Brave  ║
# ╚══════════════════════════════════════════════════════════════╝

set -e

APPS_DIR="$HOME/.local/share/applications"

echo "🔍 Buscando WebApps con barra de ventana forzada (--app-id)..."

# URLs conocidas comunes por si no se extraen automáticamente
declare -A KNOWN_URLS=(
    ["ilbcbhpbmggihnbldpmmbppiclfnifck"]="https://listen.tidal.com"
    ["ficljmaaiddafabdgbkkgkgmogdgkibi"]="https://listen.tidal.com"
)

FIXED=0

for desktop_file in "$APPS_DIR"/brave-*.desktop "$APPS_DIR"/chrome-*.desktop; do
    [ -f "$desktop_file" ] || continue

    if grep -q -- "--app-id=" "$desktop_file"; then
        APP_ID=$(grep -oP '(?<=--app-id=)[a-zA-Z0-9]+' "$desktop_file" | head -n 1)
        NAME=$(grep -m1 '^Name=' "$desktop_file" | cut -d= -f2-)
        echo "  → Encontrada WebApp: $NAME (ID: $APP_ID)"

        URL=""
        if [ -n "${KNOWN_URLS[$APP_ID]}" ]; then
            URL="${KNOWN_URLS[$APP_ID]}"
        else
            # Intentar extraer URL desde LevelDB de Brave Sync Data
            LEVELDB_DIR="$HOME/.config/BraveSoftware/Brave-Origin/Default/Sync Data/LevelDB"
            if [ -d "$LEVELDB_DIR" ]; then
                EXTRACTED_URL=$(strings "$LEVELDB_DIR"/*.ldb "$LEVELDB_DIR"/*.log 2>/dev/null | grep -A 1 "web_apps-dt-$APP_ID" | grep -oP 'https?://[^\s\x00]+' | head -n 1 || true)
                [ -n "$EXTRACTED_URL" ] && URL="$EXTRACTED_URL"
            fi
        fi

        if [ -z "$URL" ]; then
            echo -n "    Introduce la URL de inicio para $NAME: "
            read -r URL
        fi

        if [ -n "$URL" ]; then
            # Reemplazar comando usando --app=URL en vez de --app-id
            sed -i -E "s|--profile-directory=[^ ]+ --app-id=[a-zA-Z0-9]+|--app=$URL|g" "$desktop_file"
            sed -i -E "s|--app-id=[a-zA-Z0-9]+|--app=$URL|g" "$desktop_file"
            echo "    ✓ Convertida a modo App limpio sin barra: $URL"
            FIXED=$((FIXED + 1))
        fi
    fi
done

if [ $FIXED -gt 0 ]; then
    command -v update-desktop-database &>/dev/null && update-desktop-database "$APPS_DIR" 2>/dev/null || true
    echo "✅ Se corrigieron $FIXED WebApps exitosamente."
else
    echo "✓ Todas las WebApps ya están configuradas en modo limpio (sin barra)."
fi
