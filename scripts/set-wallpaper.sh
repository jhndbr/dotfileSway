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

mkdir -p "$HOME/Pictures"
TARGET_WALLPAPER="$HOME/Pictures/1.jpg"

TMP_IMG="/tmp/matugen_current_wallpaper"
MIME_TYPE=$(file -b --mime-type "$WALLPAPER_INPUT" 2>/dev/null || echo "")
if [[ "$MIME_TYPE" == *"png"* ]]; then
    TMP_IMG="${TMP_IMG}.png"
elif [[ "$MIME_TYPE" == *"jpeg"* || "$MIME_TYPE" == *"jpg"* ]]; then
    TMP_IMG="${TMP_IMG}.jpg"
else
    TMP_IMG="${TMP_IMG}.png"
fi
cp -f "$WALLPAPER_INPUT" "$TMP_IMG" 2>/dev/null || true
CONVERTED_PNG="$TMP_IMG"

if [ "$WALLPAPER_INPUT" != "$TARGET_WALLPAPER" ]; then
    cp -f "$WALLPAPER_INPUT" "$TARGET_WALLPAPER" 2>/dev/null || true
fi

if command -v swaymsg &>/dev/null && pgrep -x sway &>/dev/null; then
    swaymsg "output * bg '$WALLPAPER_INPUT' fill" &
fi

echo "🎨 Generando paleta de colores dinámicas desde: $WALLPAPER_INPUT..."

# ── 2. Extraer colores con Pywal (sin secuencias de escape OSC 4) ─
rm -rf "$HOME/.cache/wal/colors.json" 2>/dev/null || true
wal -i "$CONVERTED_PNG" -n -q -s -t 2>/dev/null || true

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GEN_DANK16=""
if [ -f "$SCRIPT_DIR/generate-dank16.py" ]; then
    GEN_DANK16="$SCRIPT_DIR/generate-dank16.py"
elif [ -f "$HOME/.local/bin/generate-dank16.py" ]; then
    GEN_DANK16="$HOME/.local/bin/generate-dank16.py"
fi

if [ -n "$GEN_DANK16" ]; then
    python3 "$GEN_DANK16" || true
fi

# ── 3. Asegurar estructura de plantillas y configuración Matugen ─
TEMPLATES_DIR="$HOME/.config/matugen/templates"
mkdir -p "$TEMPLATES_DIR"
mkdir -p "$HOME/.config/matugen"
mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
mkdir -p "$HOME/.config/zed/themes"
mkdir -p "$HOME/.config/qt5ct/colors" "$HOME/.config/qt6ct/colors"
mkdir -p "$HOME/.config/kitty" "$HOME/.config/foot" "$HOME/.config/wofi"

# Sincronizar plantillas a ~/.config/matugen/templates desde las ubicaciones posibles
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -d "$SCRIPT_DIR/../templates" ]; then
    cp -rf "$SCRIPT_DIR/../templates/"* "$TEMPLATES_DIR/" 2>/dev/null || true
elif [ -d "$HOME/Documents/dotfileSway/templates" ]; then
    cp -rf "$HOME/Documents/dotfileSway/templates/"* "$TEMPLATES_DIR/" 2>/dev/null || true
elif [ -d "$HOME/Documentos/Github/dotfileSway/templates" ]; then
    cp -rf "$HOME/Documentos/Github/dotfileSway/templates/"* "$TEMPLATES_DIR/" 2>/dev/null || true
elif [ -d "$HOME/dotfileSway/templates" ]; then
    cp -rf "$HOME/dotfileSway/templates/"* "$TEMPLATES_DIR/" 2>/dev/null || true
fi

# Configuración de Matugen vinculando las plantillas de Dank Linux
cat << EOF > "$HOME/.config/matugen/config.toml"
[config]

[templates.gtk3]
input_path = '$TEMPLATES_DIR/gtk-colors.css'
output_path = '$HOME/.config/gtk-3.0/dank-colors.css'

[templates.gtk4]
input_path = '$TEMPLATES_DIR/gtk-colors.css'
output_path = '$HOME/.config/gtk-4.0/dank-colors.css'

[templates.zed]
input_path = '$TEMPLATES_DIR/dank-zed.json'
output_path = '$HOME/.config/zed/themes/dank-zed-theme.json'

[templates.vscode]
input_path = '$TEMPLATES_DIR/vscode-color-theme-dark.json'
output_path = '$HOME/.vscode/extensions/danklinux.dms-theme-0.0.3/themes/dankshell-dark.json'

[templates.qt5ct]
input_path = '$TEMPLATES_DIR/qtct-colors.conf'
output_path = '$HOME/.config/qt5ct/colors/matugen.conf'

[templates.qt6ct]
input_path = '$TEMPLATES_DIR/qtct-colors.conf'
output_path = '$HOME/.config/qt6ct/colors/matugen.conf'

[templates.kdeglobals]
input_path = '$TEMPLATES_DIR/qtct-colors.conf'
output_path = '$HOME/.config/kdeglobals'

[templates.kitty]
input_path = '$TEMPLATES_DIR/kitty.conf'
output_path = '$HOME/.config/kitty/dank-theme.conf'

[templates.foot]
input_path = '$TEMPLATES_DIR/foot.ini'
output_path = '$HOME/.config/foot/dank-colors.ini'

[templates.swaylock]
input_path = '$TEMPLATES_DIR/swaylock.conf'
output_path = '$HOME/.config/swaylock/config'

[templates.sway]
input_path = '$TEMPLATES_DIR/sway-colors'
output_path = '$HOME/.config/sway/dank-colors'

[templates.dunst]
input_path = '$TEMPLATES_DIR/dunstrc'
output_path = '$HOME/.config/dunst/dunstrc'

[templates.wofi]
input_path = '$TEMPLATES_DIR/wofi-style.css'
output_path = '$HOME/.config/wofi/style.css'
EOF

# ── 4. Ejecutar Matugen standalone importando dank16.json si existe ───────
if [ -f "/tmp/dank16.json" ]; then
    matugen image "$CONVERTED_PNG" -m dark --source-color-index 0 --import-json /tmp/dank16.json
else
    matugen image "$CONVERTED_PNG" -m dark --source-color-index 0
fi

# ── 5. Escribir gtk.css / gtk-dark.css en GTK 3 y GTK 4 ──────────
# El dank-colors.css generado por Matugen aplica outline-style:dashed
# en el selector * global (width=1px, offset=-3px), lo que dibuja
# líneas punteadas en TODOS los widgets. El override a continuación
# anula eso globalmente y solo restaura el outline en :focus-visible.

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
  border-color: alpha(@accent_bg_color, 0.35);
  border-radius: 0px;
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
  margin: 1px 2px;
  border-radius: 0px;
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
  border-radius: 0px;
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
  border-color: alpha(@accent_bg_color, 0.35);
  border-radius: 0px;
  box-shadow: none;
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
  border-radius: 0px;
}
'

rm -f "$HOME/.config/gtk-3.0/gtk.css" \
      "$HOME/.config/gtk-4.0/gtk.css" \
      "$HOME/.config/gtk-4.0/gtk-dark.css"

printf '@import url("dank-colors.css");\n%s\n' "$GTK3_FIXES" \
    > "$HOME/.config/gtk-3.0/gtk.css"
printf '@import url("dank-colors.css");\n%s\n' "$GTK4_FIXES" \
    > "$HOME/.config/gtk-4.0/gtk.css"
printf '@import url("dank-colors.css");\n%s\n' "$GTK4_FIXES" \
    > "$HOME/.config/gtk-4.0/gtk-dark.css"


# ── 6. Sincronizar color de iconos en segundo plano ─────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$HOME/.local/bin/sync-icon-color.py" ]; then
    python3 "$HOME/.local/bin/sync-icon-color.py" &>/dev/null &
elif [ -f "$SCRIPT_DIR/sync-icon-color.py" ]; then
    python3 "$SCRIPT_DIR/sync-icon-color.py" &>/dev/null &
fi

# ── 7. Asegurar estilo Qt en Fusion, Papirus-Dark y kdeglobals ──
sed -i 's/^style=.*/style=Fusion/' "$HOME/.config/qt5ct/qt5ct.conf" 2>/dev/null || true
sed -i 's/^style=.*/style=Fusion/' "$HOME/.config/qt6ct/qt6ct.conf" 2>/dev/null || true
sed -i 's/^icon_theme=.*/icon_theme=Papirus-Dark/' "$HOME/.config/qt5ct/qt5ct.conf" 2>/dev/null || true
sed -i 's/^icon_theme=.*/icon_theme=Papirus-Dark/' "$HOME/.config/qt6ct/qt6ct.conf" 2>/dev/null || true

# ── 8. Recargar componentes del escritorio, Sway y Foot ───────────────
pkill -SIGUSR2 waybar 2>/dev/null || true
pkill -SIGUSR1 foot 2>/dev/null || true
if command -v swaymsg &>/dev/null && pgrep -x sway &>/dev/null; then
    swaymsg reload 2>/dev/null || true
fi
if pgrep -x dunst &>/dev/null; then
    killall dunst 2>/dev/null || true
    dunst &>/dev/null &
fi

# ── 9. Sincronizar copias en el repositorio de dotfiles ──────────
DOTFILES_DIR=""
if [ -d "$SCRIPT_DIR/../config" ]; then
    DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
elif [ -d "$HOME/Documentos/Github/dotfileSway" ]; then
    DOTFILES_DIR="$HOME/Documentos/Github/dotfileSway"
elif [ -d "$HOME/Documents/dotfileSway" ]; then
    DOTFILES_DIR="$HOME/Documents/dotfileSway"
elif [ -d "$HOME/dotfileSway" ]; then
    DOTFILES_DIR="$HOME/dotfileSway"
fi

if [ -n "$DOTFILES_DIR" ] && [ -d "$DOTFILES_DIR" ]; then
    mkdir -p "$DOTFILES_DIR/config/gtk-3.0" "$DOTFILES_DIR/config/gtk-4.0" "$DOTFILES_DIR/config/zed/themes" "$DOTFILES_DIR/config/foot" "$DOTFILES_DIR/config/wofi" "$DOTFILES_DIR/config/sway" "$DOTFILES_DIR/config/dunst" "$DOTFILES_DIR/scripts" "$DOTFILES_DIR/config/qt5ct" "$DOTFILES_DIR/config/qt6ct"
    cp -f "$HOME/.config/gtk-3.0/dank-colors.css" "$DOTFILES_DIR/config/gtk-3.0/dank-colors.css" 2>/dev/null || true
    cp -f "$HOME/.config/gtk-4.0/dank-colors.css" "$DOTFILES_DIR/config/gtk-4.0/dank-colors.css" 2>/dev/null || true
    cp -f "$HOME/.config/gtk-3.0/settings.ini" "$DOTFILES_DIR/config/gtk-3.0/settings.ini" 2>/dev/null || true
    cp -f "$HOME/.config/gtk-4.0/settings.ini" "$DOTFILES_DIR/config/gtk-4.0/settings.ini" 2>/dev/null || true
    cp -f "$HOME/.config/qt5ct/qt5ct.conf" "$DOTFILES_DIR/config/qt5ct/qt5ct.conf" 2>/dev/null || true
    cp -f "$HOME/.config/qt6ct/qt6ct.conf" "$DOTFILES_DIR/config/qt6ct/qt6ct.conf" 2>/dev/null || true
    cp -f "$HOME/.config/zed/themes/dank-zed-theme.json" "$DOTFILES_DIR/config/zed/themes/dank-zed-theme.json" 2>/dev/null || true
    cp -f "$HOME/.config/foot/foot.ini" "$DOTFILES_DIR/config/foot/foot.ini" 2>/dev/null || true
    cp -f "$HOME/.config/foot/dank-colors.ini" "$DOTFILES_DIR/config/foot/dank-colors.ini" 2>/dev/null || true
    cp -f "$HOME/.config/wofi/style.css" "$DOTFILES_DIR/config/wofi/style.css" 2>/dev/null || true
    cp -f "$HOME/.config/sway/dank-colors" "$DOTFILES_DIR/config/sway/dank-colors" 2>/dev/null || true
    cp -f "$HOME/.config/dunst/dunstrc" "$DOTFILES_DIR/config/dunst/dunstrc" 2>/dev/null || true
    cp -f "$HOME/.local/bin/sync-icon-color.py" "$DOTFILES_DIR/scripts/sync-icon-color.py" 2>/dev/null || true
    cp -f "$HOME/.local/bin/set-wallpaper.sh" "$DOTFILES_DIR/scripts/set-wallpaper.sh" 2>/dev/null || true
fi

# ── 10. Refrescar GTK, Tipografía e Iconos en tiempo real vía D-Bus ─
unset GTK_THEME 2>/dev/null || true
gsettings set org.gnome.desktop.interface font-name 'Inter 10' 2>/dev/null || true
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 10' 2>/dev/null || true
gsettings set org.gnome.desktop.interface document-font-name 'Inter 10' 2>/dev/null || true
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark' 2>/dev/null || true
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' 2>/dev/null || gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3' 2>/dev/null || true
pkill -f xdg-desktop-portal-gtk 2>/dev/null || true

# ── 11. Notificación ──────────────────────────────────────────────
if command -v dunstify &>/dev/null; then
    dunstify -a "DMS Matugen" -r 8812 "🎨 Tema Dinámico Aplicado" "Sway, Waybar, Foot, Qt, Iconos, Swaylock, Wofi y GTK sincronizados" || true
fi

echo "✅ Tema dinámico Dank aplicado exitosamente a todo el escritorio."
