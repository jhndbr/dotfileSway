#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║        Gestor Standalone de Wallpaper y Tema Dinámico       ║
# ║        Usa Matugen + Plantillas Dank Linux (Sin DMS)         ║
# ╚══════════════════════════════════════════════════════════════╝

set -e

WALLPAPER_INPUT="${1:-$HOME/Pictures/1.jpg}"

if [ ! -f "$WALLPAPER_INPUT" ]; then
    echo "❌ Imagen no encontrada: $WALLPAPER_INPUT"
    exit 1
fi

TARGET_WALLPAPER="$HOME/Pictures/1.jpg"
CONVERTED_PNG="/tmp/wallpaper.png"

# ── 1. Normalizar formato de imagen a PNG para evitar fallos en Matugen ──
if command -v magick &>/dev/null; then
    magick "$WALLPAPER_INPUT" "$CONVERTED_PNG" 2>/dev/null || cp -f "$WALLPAPER_INPUT" "$CONVERTED_PNG"
elif command -v convert &>/dev/null; then
    convert "$WALLPAPER_INPUT" "$CONVERTED_PNG" 2>/dev/null || cp -f "$WALLPAPER_INPUT" "$CONVERTED_PNG"
else
    cp -f "$WALLPAPER_INPUT" "$CONVERTED_PNG"
fi

if [ "$WALLPAPER_INPUT" != "$TARGET_WALLPAPER" ]; then
    cp -f "$WALLPAPER_INPUT" "$TARGET_WALLPAPER"
fi

if command -v swaymsg &>/dev/null && pgrep -x sway &>/dev/null; then
    swaymsg "output * bg '$TARGET_WALLPAPER' fill" || true
fi

echo "🎨 Generando paleta de colores dinámicas desde: $WALLPAPER_INPUT..."

# ── 2. Extraer colores con Pywal (sin secuencias de escape OSC 4) ─
rm -rf "$HOME/.cache/wal/colors.json" 2>/dev/null || true
wal -i "$CONVERTED_PNG" -n -q -s -t || true
if [ -f "$HOME/.local/bin/generate-dank16.py" ]; then
    python3 "$HOME/.local/bin/generate-dank16.py" || true
fi

# ── 3. Asegurar estructura de plantillas y configuración Matugen ─
mkdir -p "$HOME/.config/matugen"
mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
mkdir -p "$HOME/.config/zed/themes"
mkdir -p "$HOME/.config/qt5ct/colors" "$HOME/.config/qt6ct/colors"
mkdir -p "$HOME/.config/kitty" "$HOME/.config/foot"

# Configuración de Matugen vinculando las plantillas de Dank Linux
SCRIPT_DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cat << EOF > "$HOME/.config/matugen/config.toml"
[config]

[templates.gtk3]
input_path = '$SCRIPT_DOTFILES/templates/gtk-colors.css'
output_path = '$HOME/.config/gtk-3.0/dank-colors.css'

[templates.gtk4]
input_path = '$SCRIPT_DOTFILES/templates/gtk-colors.css'
output_path = '$HOME/.config/gtk-4.0/dank-colors.css'

[templates.zed]
input_path = '$SCRIPT_DOTFILES/templates/dank-zed.json'
output_path = '$HOME/.config/zed/themes/dank-zed-theme.json'

[templates.vscode]
input_path = '$SCRIPT_DOTFILES/templates/vscode-color-theme-dark.json'
output_path = '$HOME/.vscode/extensions/danklinux.dms-theme-0.0.3/themes/dankshell-dark.json'

[templates.qt5ct]
input_path = '$SCRIPT_DOTFILES/templates/qtct-colors.conf'
output_path = '$HOME/.config/qt5ct/colors/matugen.conf'

[templates.qt6ct]
input_path = '$SCRIPT_DOTFILES/templates/qtct-colors.conf'
output_path = '$HOME/.config/qt6ct/colors/matugen.conf'

[templates.kdeglobals]
input_path = '$SCRIPT_DOTFILES/templates/qtct-colors.conf'
output_path = '$HOME/.config/kdeglobals'

[templates.kitty]
input_path = '$SCRIPT_DOTFILES/templates/kitty.conf'
output_path = '$HOME/.config/kitty/dank-theme.conf'

[templates.foot]
input_path = '$SCRIPT_DOTFILES/templates/foot.ini'
output_path = '$HOME/.config/foot/dank-colors.ini'

[templates.swaylock]
input_path = '$SCRIPT_DOTFILES/templates/swaylock.conf'
output_path = '$HOME/.config/swaylock/config'

[templates.sway]
input_path = '$SCRIPT_DOTFILES/templates/sway-colors'
output_path = '$HOME/.config/sway/dank-colors'

[templates.dunst]
input_path = '$SCRIPT_DOTFILES/templates/dunstrc'
output_path = '$HOME/.config/dunst/dunstrc'
EOF

# ── 4. Ejecutar Matugen standalone importando dank16.json ───────
matugen image "$CONVERTED_PNG" -m dark --source-color-index 0 --import-json /tmp/dank16.json

# ── 5. Vincular gtk.css en GTK 3 y GTK 4 ─────────────────────────
rm -f "$HOME/.config/gtk-3.0/gtk.css" "$HOME/.config/gtk-4.0/gtk.css"
echo '@import url("dank-colors.css");' > "$HOME/.config/gtk-3.0/gtk.css"
echo '@import url("dank-colors.css");' > "$HOME/.config/gtk-4.0/gtk.css"

# ── 6. Sincronizar color de iconos con la paleta de Matugen ─────
if [ -f "$HOME/.local/bin/sync-icon-color.py" ]; then
    python3 "$HOME/.local/bin/sync-icon-color.py" || true
fi

# ── 7. Asegurar estilo Qt en Fusion, Papirus-Dark y kdeglobals ──
sed -i 's/^style=.*/style=Fusion/' "$HOME/.config/qt5ct/qt5ct.conf" 2>/dev/null || true
sed -i 's/^style=.*/style=Fusion/' "$HOME/.config/qt6ct/qt6ct.conf" 2>/dev/null || true
sed -i 's/^icon_theme=.*/icon_theme=Papirus-Dark/' "$HOME/.config/qt5ct/qt5ct.conf" 2>/dev/null || true
sed -i 's/^icon_theme=.*/icon_theme=Papirus-Dark/' "$HOME/.config/qt6ct/qt6ct.conf" 2>/dev/null || true

# ── 8. Recargar componentes del escritorio y Foot ───────────────
pkill -SIGUSR2 waybar 2>/dev/null || true
pkill -SIGUSR1 foot 2>/dev/null || true
if pgrep -x sway &>/dev/null; then
    swaymsg reload 2>/dev/null || true
fi
if pgrep -x dunst &>/dev/null; then
    killall dunst 2>/dev/null || true
    dunst &>/dev/null &
fi

# ── 9. Sincronizar copias en el repositorio de dotfiles ──────────
DOTFILES_DIR="$SCRIPT_DOTFILES"
if [ -d "$DOTFILES_DIR" ]; then
    mkdir -p "$DOTFILES_DIR/config/gtk-3.0" "$DOTFILES_DIR/config/gtk-4.0" "$DOTFILES_DIR/config/zed/themes" "$DOTFILES_DIR/config/foot" "$DOTFILES_DIR/scripts" "$DOTFILES_DIR/config/qt5ct" "$DOTFILES_DIR/config/qt6ct"
    cp -f "$HOME/.config/gtk-3.0/dank-colors.css" "$DOTFILES_DIR/config/gtk-3.0/dank-colors.css"
    cp -f "$HOME/.config/gtk-4.0/dank-colors.css" "$DOTFILES_DIR/config/gtk-4.0/dank-colors.css"
    cp -f "$HOME/.config/gtk-3.0/settings.ini" "$DOTFILES_DIR/config/gtk-3.0/settings.ini"
    cp -f "$HOME/.config/gtk-4.0/settings.ini" "$DOTFILES_DIR/config/gtk-4.0/settings.ini"
    cp -f "$HOME/.config/qt5ct/qt5ct.conf" "$DOTFILES_DIR/config/qt5ct/qt5ct.conf"
    cp -f "$HOME/.config/qt6ct/qt6ct.conf" "$DOTFILES_DIR/config/qt6ct/qt6ct.conf"
    cp -f "$HOME/.config/zed/themes/dank-zed-theme.json" "$DOTFILES_DIR/config/zed/themes/dank-zed-theme.json"
    cp -f "$HOME/.config/foot/foot.ini" "$DOTFILES_DIR/config/foot/foot.ini"
    cp -f "$HOME/.local/bin/sync-icon-color.py" "$DOTFILES_DIR/scripts/sync-icon-color.py"
    cp -f "$HOME/.local/bin/set-wallpaper.sh" "$DOTFILES_DIR/scripts/set-wallpaper.sh" 2>/dev/null || true
fi

# ── 10. Refrescar GTK e Iconos en tiempo real vía D-Bus ──────────
unset GTK_THEME 2>/dev/null || true
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark' 2>/dev/null || true
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3' 2>/dev/null || true
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita' 2>/dev/null || true
sleep 0.1
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3' 2>/dev/null || true

# ── 11. Notificación ──────────────────────────────────────────────
if command -v dunstify &>/dev/null; then
    dunstify -a "DMS Matugen" -r 8812 "🎨 Tema Dinámico Aplicado" "Sway, Waybar, Foot, Qt, Iconos, Swaylock, Wofi y GTK sincronizados" || true
fi

echo "✅ Tema dinámico Dank aplicado exitosamente a todo el escritorio."
