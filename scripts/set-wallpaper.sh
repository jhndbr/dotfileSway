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

# ── 1. Copiar y establecer fondo de pantalla en Sway ────────────
if [ "$WALLPAPER_INPUT" != "$TARGET_WALLPAPER" ]; then
    cp -f "$WALLPAPER_INPUT" "$TARGET_WALLPAPER"
fi

if command -v swaymsg &>/dev/null && pgrep -x sway &>/dev/null; then
    swaymsg "output * bg '$TARGET_WALLPAPER' fill" || true
fi

echo "🎨 Generando paleta de colores dinámicas desde: $TARGET_WALLPAPER..."

# ── 2. Extraer colores con Pywal y generar contexto Dank16 ───────
wal -i "$TARGET_WALLPAPER" -n -q -s -t
python3 "$HOME/.local/bin/generate-dank16.py"

# ── 3. Asegurar estructura de plantillas y configuración Matugen ─
mkdir -p "$HOME/.config/matugen"
mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
mkdir -p "$HOME/.config/zed/themes"
mkdir -p "$HOME/.config/qt5ct/colors" "$HOME/.config/qt6ct/colors"
mkdir -p "$HOME/.config/kitty" "$HOME/.config/foot"

# Configuración de Matugen vinculando las plantillas de Dank Linux
cat << 'EOF' > "$HOME/.config/matugen/config.toml"
[config]

[templates.gtk3]
input_path = '/home/dzhon/Documents/dotfileSway/templates/gtk-colors.css'
output_path = '/home/dzhon/.config/gtk-3.0/dank-colors.css'

[templates.gtk4]
input_path = '/home/dzhon/Documents/dotfileSway/templates/gtk-colors.css'
output_path = '/home/dzhon/.config/gtk-4.0/dank-colors.css'

[templates.zed]
input_path = '/home/dzhon/Documents/dotfileSway/templates/dank-zed.json'
output_path = '/home/dzhon/.config/zed/themes/dank-zed-theme.json'

[templates.vscode]
input_path = '/home/dzhon/Documents/dotfileSway/templates/vscode-color-theme-dark.json'
output_path = '/home/dzhon/.vscode/extensions/danklinux.dms-theme-0.0.3/themes/dankshell-dark.json'

[templates.qt5ct]
input_path = '/home/dzhon/Documents/dotfileSway/templates/qtct-colors.conf'
output_path = '/home/dzhon/.config/qt5ct/colors/matugen.conf'

[templates.qt6ct]
input_path = '/home/dzhon/Documents/dotfileSway/templates/qtct-colors.conf'
output_path = '/home/dzhon/.config/qt6ct/colors/matugen.conf'

[templates.kitty]
input_path = '/home/dzhon/Documents/dotfileSway/templates/kitty.conf'
output_path = '/home/dzhon/.config/kitty/dank-theme.conf'

[templates.foot]
input_path = '/home/dzhon/Documents/dotfileSway/templates/foot.ini'
output_path = '/home/dzhon/.config/foot/foot.ini'
EOF

# ── 4. Ejecutar Matugen standalone ──────────────────────────────
matugen image "$TARGET_WALLPAPER" -m dark --source-color-index 0 --import-json /tmp/dank16.json

# ── 5. Inyectar reglas explícitas para componentes GTK3/GTK4 ────
GTK_OVERRIDES='

/* Reglas explícitas para forzar paleta Matugen en widgets GTK3/GTK4 */
window, .background, headerbar, .titlebar, actionbar, notebook, dialog {
    background-color: @window_bg_color;
    color: @window_fg_color;
}

sidebar, .sidebar, treeview, list, row {
    background-color: @sidebar_bg_color;
    color: @sidebar_fg_color;
}

button.suggested-action, .accent {
    background-color: @accent_bg_color;
    color: @accent_fg_color;
}
'

if [ -f "$HOME/.config/gtk-3.0/dank-colors.css" ]; then
    echo "$GTK_OVERRIDES" >> "$HOME/.config/gtk-3.0/dank-colors.css"
fi

if [ -f "$HOME/.config/gtk-4.0/dank-colors.css" ]; then
    echo "$GTK_OVERRIDES" >> "$HOME/.config/gtk-4.0/dank-colors.css"
fi

# Vinculación de gtk.css
rm -f "$HOME/.config/gtk-3.0/gtk.css" "$HOME/.config/gtk-4.0/gtk.css"
echo '@import url("dank-colors.css");' > "$HOME/.config/gtk-3.0/gtk.css"
echo '@import url("dank-colors.css");' > "$HOME/.config/gtk-4.0/gtk.css"

# ── 6. Sincronizar copias en el repositorio de dotfiles ──────────
DOTFILES_DIR="$HOME/Documents/dotfileSway"
if [ -d "$DOTFILES_DIR" ]; then
    mkdir -p "$DOTFILES_DIR/config/gtk-3.0" "$DOTFILES_DIR/config/gtk-4.0" "$DOTFILES_DIR/config/zed/themes"
    cp -f "$HOME/.config/gtk-3.0/dank-colors.css" "$DOTFILES_DIR/config/gtk-3.0/dank-colors.css"
    cp -f "$HOME/.config/gtk-4.0/dank-colors.css" "$DOTFILES_DIR/config/gtk-4.0/dank-colors.css"
    cp -f "$HOME/.config/zed/themes/dank-zed-theme.json" "$DOTFILES_DIR/config/zed/themes/dank-zed-theme.json"
fi

# ── 7. Refrescar GTK en tiempo real vía D-Bus ───────────────────
unset GTK_THEME 2>/dev/null || true
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3' 2>/dev/null || true
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita' 2>/dev/null || true
sleep 0.1
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3' 2>/dev/null || true

# ── 8. Notificación ──────────────────────────────────────────────
if command -v dunstify &>/dev/null; then
    dunstify -a "DMS Matugen" -r 8812 "🎨 Tema Dinámico Standalone" "GTK, Qt, VSCode, Zed y Terminales actualizados desde el wallpaper"
fi

echo "✅ Tema dinámico Dank aplicado exitosamente sin DMS."
