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

# 3. Reglas explícitas de corrección visual GTK 3 y GTK 4 (Sin sombras y sintaxis válida GTK)
GTK4_FIXES='
/* ── Focus Outline ── */
* {
  outline-width: 0;
  outline-style: none;
}
*:focus-visible {
  outline-width: 1px;
  outline-style: dashed;
  outline-offset: -3px;
  outline-color: alpha(currentColor, 0.3);
}

/* ── Fondo sólido de ventana para evitar huecos transparentes ── */
window,
window.background,
window.csd,
window.unified,
window.devel,
.background {
  background-color: @window_bg_color;
  color: @window_fg_color;
}

window.csd decoration,
window decoration,
decoration {
  background-color: @window_bg_color;
  border-style: none;
  border-width: 0;
  box-shadow: none;
  margin: 0;
  padding: 0;
}

/* ── Contenedor exterior de Popovers (Transparente sin recuadros grises) ── */
popover,
popover.background,
popover.menu,
.csd popover,
.csd popover.background,
.window-frame {
  background-color: transparent;
  background-image: none;
  border-style: none;
  border-width: 0;
  box-shadow: none;
  text-shadow: none;
  -gtk-icon-shadow: none;
  outline-style: none;
  outline-width: 0;
  padding: 0;
  margin: 0;
}

/* ── Tarjeta de menú interior de Popover ── */
popover > contents,
popover.menu > contents,
.csd popover > contents,
popover contents {
  background-color: @popover_bg_color;
  color: @popover_fg_color;
  border-style: solid;
  border-width: 1px;
  border-color: rgba(255, 255, 255, 0.15);
  border-radius: 8px;
  box-shadow: none;
  padding: 4px;
}

/* ── Eliminar bordes y recuadros en la barra lateral (Carpeta personal, Recientes, etc.) ── */
sidebar,
.sidebar,
navigation-sidebar,
.navigation-sidebar,
placessidebar,
.placessidebar,
sidebar row,
.sidebar row,
navigation-sidebar row,
.navigation-sidebar row,
placessidebar row,
.placessidebar row,
list.navigation-sidebar > row,
sidebar button,
.sidebar button,
navigation-sidebar button,
.navigation-sidebar button {
  border-style: none;
  border-width: 0;
  outline-style: none;
  outline-width: 0;
  box-shadow: none;
}

sidebar row,
.sidebar row,
navigation-sidebar row,
.navigation-sidebar row,
placessidebar row,
.placessidebar row {
  background-color: transparent;
  margin: 2px 4px;
  border-radius: 6px;
}

sidebar row:hover,
.sidebar row:hover,
navigation-sidebar row:hover,
.navigation-sidebar row:hover,
placessidebar row:hover,
.placessidebar row:hover {
  background-color: alpha(currentColor, 0.08);
  border-style: none;
  border-width: 0;
}

sidebar row:selected,
.sidebar row:selected,
navigation-sidebar row:selected,
.navigation-sidebar row:selected,
placessidebar row:selected,
.placessidebar row:selected {
  background-color: alpha(@accent_bg_color, 0.25);
  color: @window_fg_color;
  border-style: none;
  border-width: 0;
}

/* ── Cuadrícula de archivos y carpetas ── */
flowboxchild,
.content-view .tile {
  border-style: none;
  border-width: 0;
  box-shadow: none;
  outline-style: none;
  outline-width: 0;
}

flowboxchild:selected,
.content-view .tile:selected {
  background-color: alpha(currentColor, 0.12);
  border-radius: 12px;
}
'

GTK3_FIXES='
/* ── Focus Outline ── */
* {
  outline-width: 0;
  outline-style: none;
}
*:focus-visible {
  outline-width: 1px;
  outline-style: dashed;
  outline-offset: -3px;
  outline-color: alpha(currentColor, 0.3);
}

/* ── Fondo sólido de ventana para evitar transparencia indeseada ── */
window,
window.background,
window.csd,
.background {
  background-color: @window_bg_color;
  color: @window_fg_color;
}

window.csd decoration,
window decoration,
decoration {
  background-color: @window_bg_color;
  border-style: none;
  border-width: 0;
  box-shadow: none;
  margin: 0;
  padding: 0;
}

/* ── Menús GTK3 ── */
menu,
.menu,
.context-menu,
popover,
popover.background,
menu > contents,
.csd menu,
.csd .menu,
.csd .context-menu,
window.csd,
.window-frame {
  box-shadow: none;
  text-shadow: none;
  -gtk-icon-shadow: none;
}

menu,
.menu,
.context-menu,
.csd menu,
.csd .menu,
.csd .context-menu {
  background-color: @popover_bg_color;
  color: @popover_fg_color;
  border-style: solid;
  border-width: 1px;
  border-color: rgba(255, 255, 255, 0.15);
  border-radius: 8px;
  padding: 4px;
}

/* ── Eliminar recuadros en filas y botones de la barra lateral GTK3 ── */
sidebar row,
.sidebar row,
placessidebar row,
.placessidebar row {
  border-style: none;
  border-width: 0;
  outline-style: none;
  outline-width: 0;
  box-shadow: none;
}
'

mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
rm -f "$HOME/.config/gtk-4.0/gtk-dark.css"
printf '@import url("dank-colors.css");\n%s\n' "$GTK3_FIXES" \
    > "$HOME/.config/gtk-3.0/gtk.css"
printf '@import url("dank-colors.css");\n%s\n' "$GTK4_FIXES" \
    > "$HOME/.config/gtk-4.0/gtk.css"
printf '@import url("dank-colors.css");\n%s\n' "$GTK4_FIXES" \
    > "$HOME/.config/gtk-4.0/gtk-dark.css"

# 4. Recarga en tiempo real enviando evento D-Bus vía gsettings y reinicio de portal
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita' 2>/dev/null || true
sleep 0.1
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' 2>/dev/null || gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3' 2>/dev/null || true
pkill -f xdg-desktop-portal-gtk 2>/dev/null || true

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
