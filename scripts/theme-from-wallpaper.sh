#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║        DMS + Matugen Dynamic Theme Generator                 ║
# ║        Genera temas dinámicos para GTK 3/4, Qt5/6, Zed,     ║
# ║        VSCode, Kitty, Foot y Firefox desde el Wallpaper       ║
# ╚══════════════════════════════════════════════════════════════╝

set -e

WALLPAPER="${1:-$HOME/Pictures/1.jpg}"

if [ ! -f "$WALLPAPER" ]; then
    echo "❌ Archivo de imagen no encontrado: $WALLPAPER"
    exit 1
fi

echo "🎨 Generando tema dinámico con DMS/Matugen desde: $WALLPAPER..."

# Ejecutar DMS Matugen para actualizar todos los componentes
dms matugen generate \
    --shell-dir /usr/share/quickshell/dms \
    --state-dir "$HOME/.cache/dms" \
    --config-dir "$HOME/.config/niri/dms" \
    --value "$WALLPAPER" \
    --mode dark 2>/dev/null || true

# Sincronizar copias en el repositorio de dotfiles si existen
DOTFILES_DIR="$HOME/Documents/dotfileSway"
if [ -d "$DOTFILES_DIR" ]; then
    mkdir -p "$DOTFILES_DIR/config/gtk-3.0" "$DOTFILES_DIR/config/gtk-4.0"
    [ -f "$HOME/.config/gtk-3.0/dank-colors.css" ] && cp -f "$HOME/.config/gtk-3.0/dank-colors.css" "$DOTFILES_DIR/config/gtk-3.0/dank-colors.css"
    [ -f "$HOME/.config/gtk-4.0/dank-colors.css" ] && cp -f "$HOME/.config/gtk-4.0/dank-colors.css" "$DOTFILES_DIR/config/gtk-4.0/dank-colors.css"
    [ -f "$HOME/.config/zed/themes/dank-zed-theme.json" ] && mkdir -p "$DOTFILES_DIR/config/zed/themes" && cp -f "$HOME/.config/zed/themes/dank-zed-theme.json" "$DOTFILES_DIR/config/zed/themes/"
fi

# Recargar Pywalfox si está activo
if command -v pywalfox &>/dev/null; then
    pywalfox update 2>/dev/null || true
fi

echo "✅ Tema dinámico generado exitosamente para GTK, Qt, VSCode, Zed y Terminales."

if command -v dunstify &>/dev/null; then
    dunstify -a "DMS Matugen" -r 8812 "🎨 Tema Dinámico Actualizado" "Colores de GTK, Qt, VSCode y Zed sincronizados con el wallpaper"
fi
