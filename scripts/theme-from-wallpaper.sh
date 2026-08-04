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

# Unset de variable GTK_THEME para permitir que GTK respete los estilos de usuario
unset GTK_THEME 2>/dev/null || true

# 1. Asegurar que GTK use adw-gtk3 (tema base Adwaita personalizable)
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3' 2>/dev/null || true
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true

# 2. Ejecutar DMS Matugen para actualizar todos los componentes (GTK, Qt, Zed, VSCode, Terminales)
dms matugen generate \
    --shell-dir /usr/share/quickshell/dms \
    --state-dir "$HOME/.cache/dms" \
    --config-dir "$HOME/.config/niri/dms" \
    --value "$WALLPAPER" \
    --mode dark 2>/dev/null || true

# 3. Inyectar reglas explícitas en dank-colors.css para forzar fondo/sidebar en todas las apps GTK3 y GTK4
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

# 4. Asegurar que gtk.css en GTK 4 tenga importación directa
mkdir -p "$HOME/.config/gtk-4.0"
echo '@import url("dank-colors.css");' > "$HOME/.config/gtk-4.0/gtk.css"

# 5. Recarga en tiempo real enviando evento D-Bus vía gsettings
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita' 2>/dev/null || true
sleep 0.1
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3' 2>/dev/null || true

# 6. Sincronizar copias en el repositorio de dotfiles si existen
DOTFILES_DIR="$HOME/Documents/dotfileSway"
if [ -d "$DOTFILES_DIR" ]; then
    mkdir -p "$DOTFILES_DIR/config/gtk-3.0" "$DOTFILES_DIR/config/gtk-4.0"
    [ -f "$HOME/.config/gtk-3.0/dank-colors.css" ] && cp -f "$HOME/.config/gtk-3.0/dank-colors.css" "$DOTFILES_DIR/config/gtk-3.0/dank-colors.css"
    [ -f "$HOME/.config/gtk-4.0/dank-colors.css" ] && cp -f "$HOME/.config/gtk-4.0/dank-colors.css" "$DOTFILES_DIR/config/gtk-4.0/dank-colors.css"
    [ -f "$HOME/.config/zed/themes/dank-zed-theme.json" ] && mkdir -p "$DOTFILES_DIR/config/zed/themes" && cp -f "$HOME/.config/zed/themes/dank-zed-theme.json" "$DOTFILES_DIR/config/zed/themes/"
fi

# 7. Recargar Pywalfox si está activo
if command -v pywalfox &>/dev/null; then
    pywalfox update 2>/dev/null || true
fi

echo "✅ Tema dinámico generado y aplicado a GTK, Qt, VSCode, Zed y Terminales."

if command -v dunstify &>/dev/null; then
    dunstify -a "DMS Matugen" -r 8812 "🎨 Tema Dinámico Aplicado" "Colores GTK, Qt, VSCode y Zed recargados desde el wallpaper"
fi
