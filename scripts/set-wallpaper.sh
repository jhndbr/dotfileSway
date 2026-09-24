#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║        Gestor Standalone de Wallpaper y Tema Dinámico       ║
# ║        Usa Matugen + Plantillas Dank Linux (Sin DMS)         ║
# ╚══════════════════════════════════════════════════════════════╝

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." 2>/dev/null && pwd || true)"
THEME_CONF="$HOME/.config/matugen/theme.conf"

# Valores por defecto
CURRENT_MODE="dark"
CURRENT_SCHEME="scheme-tonal-spot"
SAVED_WALLPAPER="$HOME/Pictures/1.jpg"

# Leer estado previo si existe
if [ -f "$THEME_CONF" ]; then
    # shellcheck disable=SC1090
    . "$THEME_CONF" 2>/dev/null || true
    [ -n "$MODE" ] && CURRENT_MODE="$MODE"
    [ -n "$SCHEME_TYPE" ] && CURRENT_SCHEME="$SCHEME_TYPE"
    [ -n "$WALLPAPER" ] && SAVED_WALLPAPER="$WALLPAPER"
fi

# ── 1. Parseo de Argumentos CLI ────────────────────────────────
WALLPAPER_ARG=""
CLI_MODE=""
CLI_SCHEME=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -m|--mode)
            CLI_MODE="$2"
            shift 2
            ;;
        -t|-s|--type|--scheme)
            CLI_SCHEME="$2"
            shift 2
            ;;
        -r|--reload)
            shift
            ;;
        -h|--help)
            echo "Uso: set-wallpaper.sh [OPCIONES] [/ruta/a/imagen]"
            echo ""
            echo "Opciones:"
            echo "  -m, --mode [dark|light|toggle]     Modo de color (Oscuro / Claro)"
            echo "  -t, --scheme [tipo]                Esquema Matugen (vibrant, fidelity, expressive, etc.)"
            echo "  -r, --reload                       Recargar tema actual sin cambiar wallpaper"
            echo "  -h, --help                         Mostrar este mensaje de ayuda"
            exit 0
            ;;
        *)
            if [ -z "$WALLPAPER_ARG" ] && [[ "$1" != -* ]]; then
                WALLPAPER_ARG="$1"
            fi
            shift
            ;;
    esac
done

# Procesar cambio de modo
if [ -n "$CLI_MODE" ]; then
    case "$CLI_MODE" in
        toggle)
            if [ "$CURRENT_MODE" = "dark" ]; then
                CURRENT_MODE="light"
            else
                CURRENT_MODE="dark"
            fi
            ;;
        light|dark)
            CURRENT_MODE="$CLI_MODE"
            ;;
        *)
            echo "⚠️  Modo desconocido: $CLI_MODE (usa 'dark', 'light' o 'toggle')"
            ;;
    esac
fi

# Procesar cambio de esquema
if [ -n "$CLI_SCHEME" ]; then
    case "$CLI_SCHEME" in
        scheme-*)
            CURRENT_SCHEME="$CLI_SCHEME"
            ;;
        *)
            CURRENT_SCHEME="scheme-$CLI_SCHEME"
            ;;
    esac
fi

# Validar esquema frente a los esquemas válidos de Matugen
case "$CURRENT_SCHEME" in
    scheme-content|scheme-expressive|scheme-fidelity|scheme-fruit-salad|scheme-monochrome|scheme-neutral|scheme-rainbow|scheme-tonal-spot|scheme-vibrant|scheme-smart)
        ;;
    *)
        echo "⚠️  Esquema '$CURRENT_SCHEME' no reconocido. Usando 'scheme-tonal-spot'."
        CURRENT_SCHEME="scheme-tonal-spot"
        ;;
esac

# Determinar wallpaper a aplicar
if [ -n "$WALLPAPER_ARG" ]; then
    WALLPAPER_INPUT="${WALLPAPER_ARG/#\~/$HOME}"
else
    WALLPAPER_INPUT="$SAVED_WALLPAPER"
fi

if [ ! -f "$WALLPAPER_INPUT" ]; then
    if [ -f "$HOME/Pictures/1.jpg" ]; then
        WALLPAPER_INPUT="$HOME/Pictures/1.jpg"
    elif [ -f "$REPO_DIR/wallpapers/1.jpg" ]; then
        WALLPAPER_INPUT="$REPO_DIR/wallpapers/1.jpg"
    else
        echo "❌ Imagen no encontrada: $WALLPAPER_INPUT"
        exit 1
    fi
fi

TARGET_WALLPAPER="$HOME/Pictures/1.jpg"
CONVERTED_PNG="$WALLPAPER_INPUT"

if [ "$WALLPAPER_INPUT" != "$TARGET_WALLPAPER" ]; then
    cp -f "$WALLPAPER_INPUT" "$TARGET_WALLPAPER"
fi

# Guardar estado persistente
mkdir -p "$HOME/.config/matugen"
cat << EOF > "$THEME_CONF"
# Estado de Matugen y Tema Dinámico (Generado automáticamente)
MODE="$CURRENT_MODE"
SCHEME_TYPE="$CURRENT_SCHEME"
WALLPAPER="$WALLPAPER_INPUT"
EOF

# Generar fondo desenfocado para la pantalla de bloqueo (Swaylock Blur)
BLUR_WALLPAPER="$HOME/Pictures/1_blur.png"
if command -v magick &>/dev/null; then
    (magick "$WALLPAPER_INPUT" -filter Gaussian -resize 25% -define filter:sigma=2.5 -resize 400% "$BLUR_WALLPAPER" 2>/dev/null || true) &
fi

if command -v swaymsg &>/dev/null && pgrep -x sway &>/dev/null; then
    swaymsg "output * bg '$WALLPAPER_INPUT' fill" &
fi

echo "🎨 Generando paleta dinámica (Modo: $CURRENT_MODE | Esquema: $CURRENT_SCHEME) desde: $WALLPAPER_INPUT..."

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
mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0" "$HOME/.config/joplin-desktop"
mkdir -p "$HOME/.config/zed/themes"
mkdir -p "$HOME/.config/qt5ct/colors" "$HOME/.config/qt6ct/colors"
mkdir -p "$HOME/.config/kitty" "$HOME/.config/foot" "$HOME/.config/wofi" "$HOME/.config/swayosd"

# Detectar perfil activo de Thunderbird y asegurar carpeta chrome
TB_PROFILE=$(find "$HOME/.thunderbird" -maxdepth 2 -type d -name "*.default-release" 2>/dev/null | head -n 1)
if [ -z "$TB_PROFILE" ]; then
    TB_PROFILE=$(find "$HOME/.thunderbird" -maxdepth 2 -type d -name "*.default*" 2>/dev/null | head -n 1)
fi
if [ -n "$TB_PROFILE" ]; then
    mkdir -p "$TB_PROFILE/chrome"
    if [ ! -f "$TB_PROFILE/chrome/userContent.css" ]; then
        echo '@import "userChrome.css";' > "$TB_PROFILE/chrome/userContent.css"
    fi
fi

# Detectar perfil activo de Firefox y asegurar carpeta chrome y legacy stylesheets
FF_PROFILE=$(find "$HOME/.mozilla/firefox" -maxdepth 2 -type d -name "*.default-release*" 2>/dev/null | head -n 1)
if [ -z "$FF_PROFILE" ]; then
    FF_PROFILE=$(find "$HOME/.mozilla/firefox" -maxdepth 2 -type d -name "*.default*" 2>/dev/null | head -n 1)
fi
if [ -n "$FF_PROFILE" ]; then
    mkdir -p "$FF_PROFILE/chrome"
    if [ ! -f "$FF_PROFILE/chrome/userContent.css" ]; then
        echo '@import "userChrome.css";' > "$FF_PROFILE/chrome/userContent.css"
    fi
    # Asegurar que las hojas de estilo de usuario estén habilitadas en Firefox
    if ! grep -q "toolkit.legacyUserProfileCustomizations.stylesheets" "$FF_PROFILE/user.js" 2>/dev/null; then
        echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >> "$FF_PROFILE/user.js"
    fi
fi

# Sincronizar plantillas a ~/.config/matugen/templates dinámicamente
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." 2>/dev/null && pwd || true)"

if [ -d "$REPO_DIR/templates" ]; then
    cp -rf "$REPO_DIR/templates/"* "$TEMPLATES_DIR/" 2>/dev/null || true
elif [ -d "$HOME/Documentos/Github/dotfileSway/templates" ]; then
    cp -rf "$HOME/Documentos/Github/dotfileSway/templates/"* "$TEMPLATES_DIR/" 2>/dev/null || true
elif [ -d "$HOME/Documents/dotfileSway/templates" ]; then
    cp -rf "$HOME/Documents/dotfileSway/templates/"* "$TEMPLATES_DIR/" 2>/dev/null || true
fi

# Configuración de Matugen vinculando las plantillas de Dank Linux
VSCODE_TEMPLATE="vscode-color-theme-dark.json"
[ "$CURRENT_MODE" = "light" ] && VSCODE_TEMPLATE="vscode-color-theme-light.json"

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
input_path = '$TEMPLATES_DIR/$VSCODE_TEMPLATE'
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

[templates.cava]
input_path = '$TEMPLATES_DIR/cava-config'
output_path = '$HOME/.config/cava/config'

[templates.swayosd]
input_path = '$TEMPLATES_DIR/swayosd-style.css'
output_path = '$HOME/.config/swayosd/style.css'

[templates.newsboat]
input_path = '$TEMPLATES_DIR/newsboat-colors'
output_path = '$HOME/.config/newsboat/colors'

[templates.btop]
input_path = '$TEMPLATES_DIR/btop.theme'
output_path = '$HOME/.config/btop/themes/dank-theme.theme'

[templates.joplin_chrome]
input_path = '$TEMPLATES_DIR/joplin-userchrome.css'
output_path = '$HOME/.config/joplin-desktop/userchrome.css'

[templates.joplin_style]
input_path = '$TEMPLATES_DIR/joplin-userstyle.css'
output_path = '$HOME/.config/joplin-desktop/userstyle.css'
EOF

if [ -n "$TB_PROFILE" ]; then
cat << EOF >> "$HOME/.config/matugen/config.toml"

[templates.thunderbird]
input_path = '$TEMPLATES_DIR/thunderbird-userchrome.css'
output_path = '$TB_PROFILE/chrome/userChrome.css'
EOF
fi

if [ -n "$FF_PROFILE" ]; then
cat << EOF >> "$HOME/.config/matugen/config.toml"

[templates.firefox]
input_path = '$TEMPLATES_DIR/firefox-userchrome.css'
output_path = '$FF_PROFILE/chrome/userChrome.css'
EOF
fi

# ── 4. Ejecutar Matugen standalone importando dank16.json si existe ───────
echo "🎨 Ejecutando Matugen (Modo: $CURRENT_MODE | Esquema: $CURRENT_SCHEME)..."
if [ -f "/tmp/dank16.json" ]; then
    matugen image "$CONVERTED_PNG" -m "$CURRENT_MODE" -t "$CURRENT_SCHEME" --source-color-index 0 --import-json /tmp/dank16.json
else
    matugen image "$CONVERTED_PNG" -m "$CURRENT_MODE" -t "$CURRENT_SCHEME" --source-color-index 0
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
*:focus,
*:focus-visible {
  outline: none;
  outline-width: 0;
  outline-style: none;
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

/* ── Cuadros de diálogo y MessageDialog (botones legibles) ── */
messagedialog button,
dialog button,
window.dialog button,
.dialog-action-area button,
.dialog-action-box button {
  color: @dialog_fg_color;
  background-color: alpha(currentColor, 0.1);
}
messagedialog button:hover,
dialog button:hover,
window.dialog button:hover,
.dialog-action-area button:hover,
.dialog-action-box button:hover {
  color: @dialog_fg_color;
  background-color: alpha(currentColor, 0.18);
}
'

GTK3_FIXES='
/* ── Focus Outline ── */
* {
  outline-width: 0;
  outline-style: none;
}
*:focus,
*:focus-visible {
  outline: none;
  outline-width: 0;
  outline-style: none;
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

/* ── Menús y Popovers GTK3 ── */
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
.csd .context-menu,
popover,
popover.background,
.csd popover,
.csd popover.background {
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

/* ── Cuadros de diálogo y MessageDialog (botones legibles) ── */
messagedialog button,
dialog button,
.dialog-action-area button,
.dialog-action-box button {
  color: @dialog_fg_color;
  background-color: alpha(currentColor, 0.1);
}
messagedialog button:hover,
dialog button:hover,
.dialog-action-area button:hover,
.dialog-action-box button:hover {
  color: @dialog_fg_color;
  background-color: alpha(currentColor, 0.18);
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
if [ -f "$HOME/.local/bin/sync-icon-color.py" ]; then
    python3 "$HOME/.local/bin/sync-icon-color.py" "$CONVERTED_PNG" "$CURRENT_MODE" &>/dev/null &
elif [ -f "$SCRIPT_DIR/sync-icon-color.py" ]; then
    python3 "$SCRIPT_DIR/sync-icon-color.py" "$CONVERTED_PNG" "$CURRENT_MODE" &>/dev/null &
fi

# ── 7. Asegurar estilo Qt en Fusion, Papirus y kdeglobals ──
if [ "$CURRENT_MODE" = "light" ]; then
    QT_ICON_THEME="Papirus"
else
    QT_ICON_THEME="Papirus-Dark"
fi
sed -i 's/^style=.*/style=Fusion/' "$HOME/.config/qt5ct/qt5ct.conf" 2>/dev/null || true
sed -i 's/^style=.*/style=Fusion/' "$HOME/.config/qt6ct/qt6ct.conf" 2>/dev/null || true
sed -i "s/^icon_theme=.*/icon_theme=$QT_ICON_THEME/" "$HOME/.config/qt5ct/qt5ct.conf" 2>/dev/null || true
sed -i "s/^icon_theme=.*/icon_theme=$QT_ICON_THEME/" "$HOME/.config/qt6ct/qt6ct.conf" 2>/dev/null || true

# ── 8. Recargar componentes del escritorio, Sway y Foot ───────────────
pkill -SIGUSR2 waybar 2>/dev/null || true
pkill -SIGUSR1 foot 2>/dev/null || true
pkill -SIGUSR1 cava 2>/dev/null || true
pkill -f waybar-cava.py 2>/dev/null || true
if command -v swaymsg &>/dev/null && pgrep -x sway &>/dev/null; then
    swaymsg reload 2>/dev/null || true
fi
if pgrep -x dunst &>/dev/null; then
    killall dunst 2>/dev/null || true
    dunst &>/dev/null &
fi
# Reiniciar swayosd-server asegurando que el proceso anterior libere el socket antes de levantar el nuevo
if command -v swaymsg &>/dev/null && pgrep -x sway &>/dev/null; then
    if pgrep -x swayosd-server &>/dev/null; then
        pkill -x swayosd-server 2>/dev/null || true
        for _ in {1..20}; do
            pgrep -x swayosd-server &>/dev/null || break
            sleep 0.05
        done
    fi
    swaymsg "exec swayosd-server --style '$HOME/.config/swayosd/style.css'" 2>/dev/null || true
fi

# ── 9. Sincronizar copias en el repositorio de dotfiles ──────────
DOTFILES_DIR=""
if [ -d "$REPO_DIR/config" ]; then
    DOTFILES_DIR="$REPO_DIR"
elif [ -d "$HOME/Documentos/Github/dotfileSway/config" ]; then
    DOTFILES_DIR="$HOME/Documentos/Github/dotfileSway"
fi

if [ -n "$DOTFILES_DIR" ] && [ -d "$DOTFILES_DIR" ]; then
    mkdir -p "$DOTFILES_DIR/config/gtk-3.0" "$DOTFILES_DIR/config/gtk-4.0" "$DOTFILES_DIR/config/zed/themes" "$DOTFILES_DIR/config/foot" "$DOTFILES_DIR/config/wofi" "$DOTFILES_DIR/scripts" "$DOTFILES_DIR/config/qt5ct" "$DOTFILES_DIR/config/qt6ct"
    cp -f "$HOME/.config/gtk-3.0/dank-colors.css" "$DOTFILES_DIR/config/gtk-3.0/dank-colors.css" 2>/dev/null || true
    cp -f "$HOME/.config/gtk-4.0/dank-colors.css" "$DOTFILES_DIR/config/gtk-4.0/dank-colors.css" 2>/dev/null || true
    cp -f "$HOME/.config/gtk-3.0/settings.ini" "$DOTFILES_DIR/config/gtk-3.0/settings.ini" 2>/dev/null || true
    cp -f "$HOME/.config/gtk-4.0/settings.ini" "$DOTFILES_DIR/config/gtk-4.0/settings.ini" 2>/dev/null || true
    cp -f "$HOME/.config/qt5ct/qt5ct.conf" "$DOTFILES_DIR/config/qt5ct/qt5ct.conf" 2>/dev/null || true
    cp -f "$HOME/.config/qt6ct/qt6ct.conf" "$DOTFILES_DIR/config/qt6ct/qt6ct.conf" 2>/dev/null || true
    cp -f "$HOME/.config/zed/themes/dank-zed-theme.json" "$DOTFILES_DIR/config/zed/themes/dank-zed-theme.json" 2>/dev/null || true
    cp -f "$HOME/.config/foot/foot.ini" "$DOTFILES_DIR/config/foot/foot.ini" 2>/dev/null || true
    cp -f "$HOME/.config/wofi/style.css" "$DOTFILES_DIR/config/wofi/style.css" 2>/dev/null || true
fi

# ── 10. Refrescar GTK, Tipografía e Iconos en tiempo real vía D-Bus ─
unset GTK_THEME 2>/dev/null || true
gsettings set org.gnome.desktop.interface font-name 'Inter 10' 2>/dev/null || true
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 10' 2>/dev/null || true
gsettings set org.gnome.desktop.interface document-font-name 'Inter 10' 2>/dev/null || true

if [ "$CURRENT_MODE" = "light" ]; then
    DESKTOP_ICON_THEME="Papirus"
    DESKTOP_COLOR_SCHEME="prefer-light"
    DESKTOP_GTK_THEME="adw-gtk3"
    DARK_PREF=0
else
    DESKTOP_ICON_THEME="Papirus-Dark"
    DESKTOP_COLOR_SCHEME="prefer-dark"
    DESKTOP_GTK_THEME="adw-gtk3-dark"
    DARK_PREF=1
fi

for ini in "$HOME/.config/gtk-3.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"; do
    if [ -f "$ini" ]; then
        sed -i "s/^gtk-theme-name=.*/gtk-theme-name=$DESKTOP_GTK_THEME/" "$ini" 2>/dev/null || true
        sed -i "s/^gtk-icon-theme-name=.*/gtk-icon-theme-name=$DESKTOP_ICON_THEME/" "$ini" 2>/dev/null || true
        sed -i "s/^gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=$DARK_PREF/" "$ini" 2>/dev/null || true
    fi
done

gsettings set org.gnome.desktop.interface icon-theme "$DESKTOP_ICON_THEME" 2>/dev/null || true
gsettings set org.gnome.desktop.interface color-scheme "$DESKTOP_COLOR_SCHEME" 2>/dev/null || true

# Alternar gtk-theme para forzar a GTK3 y aplicaciones abiertas a recargar el CSS inmediatamente
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita' 2>/dev/null || true
sleep 0.05
gsettings set org.gnome.desktop.interface gtk-theme "$DESKTOP_GTK_THEME" 2>/dev/null || true

# Reiniciar demonio de Thunar para que cargue los estilos y colores nuevos
thunar -q 2>/dev/null || true

# Reiniciar limpiamente xdg-desktop-portal-gtk para recargar los colores del selector de archivos (FileChooser)
if command -v systemctl &>/dev/null && systemctl --user is-active --quiet xdg-desktop-portal-gtk; then
    systemctl --user restart xdg-desktop-portal-gtk 2>/dev/null || true
fi

# Actualizar colores en navegadores / clientes compatibles con Pywalfox (Thunderbird / Firefox)
if command -v pywalfox &>/dev/null; then
    pywalfox update 2>/dev/null || true
fi

# ── 11. Notificación ──────────────────────────────────────────────
SCHEME_CLEAN="${CURRENT_SCHEME#scheme-}"
if command -v dunstify &>/dev/null; then
    dunstify -a "DMS Matugen" -r 8812 "🎨 Tema Dinámico Aplicado" "Modo: ${CURRENT_MODE^} | Esquema: ${SCHEME_CLEAN^}" || true
fi

echo "✅ Tema dinámico aplicado exitosamente: Modo=$CURRENT_MODE, Esquema=$CURRENT_SCHEME"
