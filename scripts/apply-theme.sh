#!/usr/bin/env bash
# ====================================================================
# SwayShell Master Theme Dispatcher for GTK 2/3/4, Qt 5/6, Foot & Sway
# Built from deep analysis of dots-hyprland, dux-shell & noctalia
# ====================================================================
set -euo pipefail

THEME="${1:-macos-dark}"
CUSTOM_ACCENT="${2:-}"
echo "Applying theme: $THEME (Accent override: ${CUSTOM_ACCENT:-none})"

case "$THEME" in
    macos-dark)
        BG="#1c1c1e"
        SURFACE="#2c2c2e"
        SURFACE_LOW="#161618"
        SURFACE_HIGH="#3a3a3c"
        TEXT="#f5f5f7"
        TEXT_MUTED="#a1a1a6"
        ACCENT="#0a84ff"
        ACCENT_ALT="#5e5ce6"
        SUCCESS="#30d158"
        WARNING="#ffd60a"
        DANGER="#ff453a"
        ACCENT_GNOME="blue"
        FOOT_CURSOR="1c1c1e 0a84ff"
        FOOT_SEL_BG="3a3a3c"
        C0="1c1c1e"; C1="ff453a"; C2="30d158"; C3="ffd60a"
        C4="0a84ff"; C5="bf5af2"; C6="5ac8fa"; C7="f5f5f7"
        C8="636366"; C9="ff6961"; C10="30d158"; C11="ffd60a"
        C12="409cff"; C13="da8fff"; C14="70d7ff"; C15="ffffff"
        ;;
    macos-light)
        BG="#f2f2f7"
        SURFACE="#e5e5ea"
        SURFACE_LOW="#ffffff"
        SURFACE_HIGH="#d1d1d6"
        TEXT="#1d1d1f"
        TEXT_MUTED="#6e6e73"
        ACCENT="#0071e3"
        ACCENT_ALT="#5856d6"
        SUCCESS="#28cd41"
        WARNING="#ff9f0a"
        DANGER="#ff3b30"
        ACCENT_GNOME="blue"
        FOOT_CURSOR="ffffff 0071e3"
        FOOT_SEL_BG="d1d1d6"
        C0="1d1d1f"; C1="ff3b30"; C2="28cd41"; C3="ff9f0a"
        C4="0071e3"; C5="af52de"; C6="5ac8fa"; C7="6e6e73"
        C8="8e8e93"; C9="ff3b30"; C10="28cd41"; C11="ff9f0a"
        C12="0071e3"; C13="af52de"; C14="5ac8fa"; C15="000000"
        ;;
    catppuccin)
        BG="#1e1e2e"
        SURFACE="#313244"
        SURFACE_LOW="#181825"
        SURFACE_HIGH="#45475a"
        TEXT="#cdd6f4"
        TEXT_MUTED="#a6adc8"
        ACCENT="#cba6f7"
        ACCENT_ALT="#89b4fa"
        SUCCESS="#a6e3a1"
        WARNING="#f9e2af"
        DANGER="#f38ba8"
        ACCENT_GNOME="purple"
        FOOT_CURSOR="1e1e2e cba6f7"
        FOOT_SEL_BG="45475a"
        C0="45475a"; C1="f38ba8"; C2="a6e3a1"; C3="f9e2af"
        C4="89b4fa"; C5="f5c2e7"; C6="94e2d5"; C7="bac2de"
        C8="585b70"; C9="f38ba8"; C10="a6e3a1"; C11="f9e2af"
        C12="89b4fa"; C13="f5c2e7"; C14="94e2d5"; C15="a6adc8"
        ;;
    tokyonight)
        BG="#1a1b26"
        SURFACE="#24283b"
        SURFACE_LOW="#16161e"
        SURFACE_HIGH="#2f354a"
        TEXT="#c0caf5"
        TEXT_MUTED="#9aa5ce"
        ACCENT="#7aa2f7"
        ACCENT_ALT="#bb9af7"
        SUCCESS="#9ece6a"
        WARNING="#e0af68"
        DANGER="#f7768e"
        ACCENT_GNOME="blue"
        FOOT_CURSOR="1a1b26 7aa2f7"
        FOOT_SEL_BG="283457"
        C0="15161e"; C1="f7768e"; C2="9ece6a"; C3="e0af68"
        C4="7aa2f7"; C5="bb9af7"; C6="7dcfff"; C7="a9b1d6"
        C8="414868"; C9="f7768e"; C10="9ece6a"; C11="e0af68"
        C12="7aa2f7"; C13="bb9af7"; C14="7dcfff"; C15="c0caf5"
        ;;
    nord)
        BG="#2e3440"
        SURFACE="#3b4252"
        SURFACE_LOW="#242933"
        SURFACE_HIGH="#434c5e"
        TEXT="#eceff4"
        TEXT_MUTED="#d8dee9"
        ACCENT="#88c0d0"
        ACCENT_ALT="#81a1c1"
        SUCCESS="#a3be8c"
        WARNING="#ebcb8b"
        DANGER="#bf616a"
        ACCENT_GNOME="teal"
        FOOT_CURSOR="2e3440 88c0d0"
        FOOT_SEL_BG="434c5e"
        C0="3b4252"; C1="bf616a"; C2="a3be8c"; C3="ebcb8b"
        C4="81a1c1"; C5="b48ead"; C6="88c0d0"; C7="e5e9f0"
        C8="4c566a"; C9="bf616a"; C10="a3be8c"; C11="ebcb8b"
        C12="81a1c1"; C13="b48ead"; C14="8fbcbb"; C15="eceff4"
        ;;
    gruvbox)
        BG="#282828"
        SURFACE="#3c3836"
        SURFACE_LOW="#1d2021"
        SURFACE_HIGH="#504945"
        TEXT="#ebdbb2"
        TEXT_MUTED="#d5c4a1"
        ACCENT="#fabd2f"
        ACCENT_ALT="#fe8019"
        SUCCESS="#b8bb26"
        WARNING="#d79921"
        DANGER="#fb4934"
        ACCENT_GNOME="yellow"
        FOOT_CURSOR="282828 fabd2f"
        FOOT_SEL_BG="504945"
        C0="282828"; C1="cc241d"; C2="98971a"; C3="d79921"
        C4="458588"; C5="b16286"; C6="689d6a"; C7="a89984"
        C8="928374"; C9="fb4934"; C10="b8bb26"; C11="fabd2f"
        C12="83a598"; C13="d3869b"; C14="8ec07c"; C15="ebdbb2"
        ;;
    oled)
        BG="#000000"
        SURFACE="#16161c"
        SURFACE_LOW="#0a0a0d"
        SURFACE_HIGH="#27272a"
        TEXT="#f5f5f7"
        TEXT_MUTED="#a1a1aa"
        ACCENT="#6366f1"
        ACCENT_ALT="#38bdf8"
        SUCCESS="#22c55e"
        WARNING="#eab308"
        DANGER="#ef4444"
        ACCENT_GNOME="purple"
        FOOT_CURSOR="000000 6366f1"
        FOOT_SEL_BG="27272a"
        C0="18181b"; C1="ef4444"; C2="22c55e"; C3="eab308"
        C4="6366f1"; C5="a855f7"; C6="38bdf8"; C7="e4e4e7"
        C8="27272a"; C9="f87171"; C10="4ade80"; C11="fde047"
        C12="818cf8"; C13="c084fc"; C14="67e8f9"; C15="fafafa"
        ;;
    *)
        echo "Unknown theme: $THEME. Available: macos-dark, macos-light, catppuccin, tokyonight, nord, gruvbox, oled"
        exit 1
        ;;
esac

if [ -n "$CUSTOM_ACCENT" ]; then
    ACCENT="$CUSTOM_ACCENT"
    FOOT_CURSOR="$BG $CUSTOM_ACCENT"
fi

FONT_SANS="SF Pro 10"
FONT_MONO="JetBrains Mono 10.5"

ICON_THEME="WhiteSur-grey-dark"
for ic in WhiteSur-grey-dark WhiteSur-dark WhiteSur Papirus-Dark breeze-dark Adwaita-dark Adwaita; do
    if [ -d "/usr/share/icons/$ic" ] || [ -d "$HOME/.icons/$ic" ] || [ -d "$HOME/.local/share/icons/$ic" ]; then
        ICON_THEME="$ic"
        break
    fi
done

# --------------------------------------------------------------------
# 1. GTK 3 Configuration & CSS
# --------------------------------------------------------------------
mkdir -p "$HOME/.config/gtk-3.0"
rm -f "$HOME/.config/gtk-3.0/colors.css" "$HOME/.config/gtk-3.0/window_decorations.css" 2>/dev/null || true

cat <<EOF > "$HOME/.config/gtk-3.0/settings.ini"
[Settings]
gtk-theme-name = adw-gtk3-dark
gtk-icon-theme-name = $ICON_THEME
gtk-font-name = $FONT_SANS
gtk-cursor-theme-name = Adwaita
gtk-cursor-theme-size = 24
gtk-toolbar-style = GTK_TOOLBAR_BOTH_HORIZ
gtk-toolbar-icon-size = GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images = 1
gtk-menu-images = 1
gtk-enable-event-sounds = 0
gtk-enable-input-feedback-sounds = 0
gtk-xft-antialias = 1
gtk-xft-hinting = 1
gtk-xft-hintstyle = hintslight
gtk-xft-rgba = rgb
gtk-application-prefer-dark-theme = 1
EOF

cat <<EOF > "$HOME/.config/gtk-3.0/gtk.css"
/* SwayShell Theme ($THEME) for GTK 3 */
@define-color accent_color $ACCENT;
@define-color accent_bg_color $ACCENT;
@define-color accent_fg_color $BG;
@define-color destructive_color $DANGER;
@define-color destructive_bg_color $DANGER;
@define-color destructive_fg_color $BG;
@define-color success_color $SUCCESS;
@define-color warning_color $WARNING;
@define-color error_color $DANGER;

@define-color window_bg_color $BG;
@define-color window_fg_color $TEXT;
@define-color view_bg_color $SURFACE_LOW;
@define-color view_fg_color $TEXT;
@define-color headerbar_bg_color $SURFACE_LOW;
@define-color headerbar_fg_color $TEXT;
@define-color headerbar_backdrop_color $SURFACE_LOW;
@define-color card_bg_color $SURFACE;
@define-color card_fg_color $TEXT;
@define-color dialog_bg_color $BG;
@define-color dialog_fg_color $TEXT;
@define-color popover_bg_color $SURFACE_LOW;
@define-color popover_fg_color $TEXT;
@define-color sidebar_bg_color $SURFACE_LOW;
@define-color sidebar_fg_color $TEXT;
@define-color secondary_sidebar_bg_color $SURFACE_LOW;
@define-color secondary_sidebar_fg_color $TEXT;

@define-color theme_selected_bg_color $ACCENT;
@define-color theme_selected_fg_color $BG;
@define-color theme_bg_color $BG;
@define-color theme_fg_color $TEXT;
@define-color theme_base_color $SURFACE_LOW;
@define-color theme_text_color $TEXT;
@define-color theme_unfocused_bg_color $BG;
@define-color theme_unfocused_fg_color $TEXT_MUTED;
@define-color theme_unfocused_base_color $SURFACE_LOW;
@define-color theme_unfocused_text_color $TEXT_MUTED;
@define-color borders $SURFACE;
@define-color unfocused_borders $SURFACE;

/* Basic Widget Overrides */
window.background {
    background-color: $BG;
    color: $TEXT;
}

headerbar {
    background-color: $SURFACE_LOW;
    color: $TEXT;
    border-color: $SURFACE;
}

headerbar:backdrop {
    background-color: $BG;
    color: $TEXT_MUTED;
}

button {
    background-color: $SURFACE;
    color: $TEXT;
    border-color: $SURFACE;
    border-radius: 6px;
}

button:hover {
    background-color: $SURFACE_HIGH;
    border-color: $ACCENT;
}

entry {
    background-color: $SURFACE_LOW;
    color: $TEXT;
    border-color: $SURFACE;
    border-radius: 6px;
}

entry:focus {
    border-color: $ACCENT;
}

notebook > header > tabs > tab:checked {
    border-bottom: 2px solid $ACCENT;
    color: $TEXT;
}
EOF

# --------------------------------------------------------------------
# 2. GTK 4 / Libadwaita Configuration & CSS
# --------------------------------------------------------------------
mkdir -p "$HOME/.config/gtk-4.0"
rm -f "$HOME/.config/gtk-4.0/colors.css" "$HOME/.config/gtk-4.0/window_decorations.css" 2>/dev/null || true

cat <<EOF > "$HOME/.config/gtk-4.0/settings.ini"
[Settings]
gtk-theme-name = adw-gtk3-dark
gtk-icon-theme-name = $ICON_THEME
gtk-font-name = $FONT_SANS
gtk-cursor-theme-name = Adwaita
gtk-cursor-theme-size = 24
gtk-application-prefer-dark-theme = 1
EOF

cat <<EOF > "$HOME/.config/gtk-4.0/gtk.css"
/* SwayShell Theme ($THEME) for GTK 4 / Libadwaita */
@define-color accent_color $ACCENT;
@define-color accent_bg_color $ACCENT;
@define-color accent_fg_color $BG;
@define-color destructive_color $DANGER;
@define-color destructive_bg_color $DANGER;
@define-color destructive_fg_color $BG;
@define-color success_color $SUCCESS;
@define-color warning_color $WARNING;
@define-color error_color $DANGER;

@define-color window_bg_color $BG;
@define-color window_fg_color $TEXT;
@define-color view_bg_color $SURFACE_LOW;
@define-color view_fg_color $TEXT;
@define-color headerbar_bg_color $SURFACE_LOW;
@define-color headerbar_fg_color $TEXT;
@define-color headerbar_backdrop_color $SURFACE_LOW;
@define-color card_bg_color $SURFACE;
@define-color card_fg_color $TEXT;
@define-color dialog_bg_color $BG;
@define-color dialog_fg_color $TEXT;
@define-color popover_bg_color $SURFACE_LOW;
@define-color popover_fg_color $TEXT;
@define-color sidebar_bg_color $SURFACE_LOW;
@define-color sidebar_fg_color $TEXT;
@define-color secondary_sidebar_bg_color $SURFACE_LOW;
@define-color secondary_sidebar_fg_color $TEXT;

@define-color theme_selected_bg_color $ACCENT;
@define-color theme_selected_fg_color $BG;

/* Libadwaita CSS Custom Properties (GTK 4.10+) */
:root {
    --accent-color: $ACCENT;
    --accent-bg-color: $ACCENT;
    --accent-fg-color: $BG;

    --destructive-bg-color: $DANGER;
    --destructive-fg-color: $BG;
    --destructive-color: $DANGER;

    --success-bg-color: $SUCCESS;
    --success-fg-color: $BG;
    --success-color: $SUCCESS;

    --warning-bg-color: $WARNING;
    --warning-fg-color: $BG;
    --warning-color: $WARNING;

    --error-bg-color: $DANGER;
    --error-fg-color: $BG;
    --error-color: $DANGER;

    --window-bg-color: $BG;
    --window-fg-color: $TEXT;

    --view-bg-color: $SURFACE_LOW;
    --view-fg-color: $TEXT;

    --headerbar-bg-color: $SURFACE_LOW;
    --headerbar-fg-color: $TEXT;
    --headerbar-backdrop-color: $BG;

    --popover-bg-color: $SURFACE_LOW;
    --popover-fg-color: $TEXT;

    --card-bg-color: $SURFACE;
    --card-fg-color: $TEXT;

    --dialog-bg-color: $BG;
    --dialog-fg-color: $TEXT;

    --sidebar-bg-color: $SURFACE_LOW;
    --sidebar-fg-color: $TEXT;
    --sidebar-backdrop-color: $BG;
}
EOF

# --------------------------------------------------------------------
# 3. GTK 2 Configuration (~/.gtkrc-2.0)
# --------------------------------------------------------------------
cat <<EOF > "$HOME/.gtkrc-2.0"
# SwayShell Generated Configuration ($THEME)
gtk-theme-name="adw-gtk3-dark"
gtk-icon-theme-name="$ICON_THEME"
gtk-font-name="$FONT_SANS"
gtk-cursor-theme-name="Adwaita"
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=0
EOF

# --------------------------------------------------------------------
# 4. XSettings Configuration (for XWayland & legacy apps)
# --------------------------------------------------------------------
mkdir -p "$HOME/.config/xsettingsd"
cat <<EOF > "$HOME/.config/xsettingsd/xsettingsd.conf"
Net/ThemeName "adw-gtk3-dark"
Net/IconThemeName "$ICON_THEME"
Gtk/CursorThemeName "Adwaita"
Gtk/CursorThemeSize 24
Gtk/FontName "$FONT_SANS"
Net/EnableEventSounds 0
Net/EnableInputFeedbackSounds 0
Gtk/ButtonImages 1
Gtk/MenuImages 1
Gtk/ToolbarStyle 3
Gtk/PrimaryButtonWarpsSlider 1
Gdk/UnscaledDPI 98304
Gdk/WindowScalingFactor 1
EOF

# --------------------------------------------------------------------
# 5. KDE / Qt Frameworks (kdeglobals & KColorScheme)
# --------------------------------------------------------------------
mkdir -p "$HOME/.config" "$HOME/.local/share/color-schemes"

# Convert HEX to RGB CSV
hex_to_rgb() {
    local h="${1#"#"}"
    printf "%d,%d,%d" "0x${h:0:2}" "0x${h:2:2}" "0x${h:4:2}"
}

BG_RGB=$(hex_to_rgb "$BG")
SURFACE_RGB=$(hex_to_rgb "$SURFACE")
SURFACE_LOW_RGB=$(hex_to_rgb "$SURFACE_LOW")
SURFACE_HIGH_RGB=$(hex_to_rgb "$SURFACE_HIGH")
TEXT_RGB=$(hex_to_rgb "$TEXT")
TEXT_MUTED_RGB=$(hex_to_rgb "$TEXT_MUTED")
ACCENT_RGB=$(hex_to_rgb "$ACCENT")
DANGER_RGB=$(hex_to_rgb "$DANGER")
SUCCESS_RGB=$(hex_to_rgb "$SUCCESS")
WARNING_RGB=$(hex_to_rgb "$WARNING")

cat <<EOF > "$HOME/.config/kdeglobals"
[General]
ColorScheme=SwayShell
Name=SwayShell
fixed=JetBrains Mono,11,-1,5,50,0,0,0,0,0
font=SF Pro,10,-1,5,50,0,0,0,0,0
menuFont=SF Pro,10,-1,5,50,0,0,0,0,0
smallestReadableFont=SF Pro,8,-1,5,50,0,0,0,0,0
toolBarFont=SF Pro,10,-1,5,50,0,0,0,0,0

[Icons]
Theme=$ICON_THEME

[KDE]
widgetStyle=kvantum

[Colors:Window]
BackgroundNormal=$BG_RGB
BackgroundAlternate=$SURFACE_LOW_RGB
ForegroundNormal=$TEXT_RGB
ForegroundInactive=$TEXT_MUTED_RGB
ForegroundActive=$ACCENT_RGB
ForegroundLink=$ACCENT_RGB
ForegroundNegative=$DANGER_RGB
ForegroundPositive=$SUCCESS_RGB
DecorationFocus=$ACCENT_RGB
DecorationHover=$ACCENT_RGB

[Colors:View]
BackgroundNormal=$SURFACE_LOW_RGB
BackgroundAlternate=$BG_RGB
ForegroundNormal=$TEXT_RGB
ForegroundInactive=$TEXT_MUTED_RGB
ForegroundActive=$ACCENT_RGB
ForegroundLink=$ACCENT_RGB
ForegroundNegative=$DANGER_RGB
ForegroundPositive=$SUCCESS_RGB
DecorationFocus=$ACCENT_RGB
DecorationHover=$ACCENT_RGB

[Colors:Button]
BackgroundNormal=$SURFACE_RGB
BackgroundAlternate=$SURFACE_HIGH_RGB
ForegroundNormal=$TEXT_RGB
ForegroundInactive=$TEXT_MUTED_RGB
ForegroundActive=$ACCENT_RGB
DecorationFocus=$ACCENT_RGB
DecorationHover=$ACCENT_RGB

[Colors:Selection]
BackgroundNormal=$ACCENT_RGB
ForegroundNormal=$BG_RGB

[Colors:Tooltip]
BackgroundNormal=$SURFACE_LOW_RGB
ForegroundNormal=$TEXT_RGB

[Colors:Header]
BackgroundNormal=$SURFACE_LOW_RGB
ForegroundNormal=$TEXT_RGB
ForegroundInactive=$TEXT_MUTED_RGB
EOF

# Copy same config as color-scheme
cp "$HOME/.config/kdeglobals" "$HOME/.local/share/color-schemes/SwayShell.colors"

# --------------------------------------------------------------------
# 6. Kvantum Configuration (~/.config/Kvantum)
# --------------------------------------------------------------------
mkdir -p "$HOME/.config/Kvantum"
case "$THEME" in
    macos-dark) KVANTUM_THEME="MaterialAdw" ;;
    macos-light) KVANTUM_THEME="MaterialAdw" ;;
    catppuccin) KVANTUM_THEME="catppuccin-mocha-mauve" ;;
    tokyonight) KVANTUM_THEME="MaterialAdw" ;;
    nord)       KVANTUM_THEME="MaterialAdw" ;;
    gruvbox)    KVANTUM_THEME="MaterialAdw" ;;
    oled)       KVANTUM_THEME="MaterialAdw" ;;
    *)          KVANTUM_THEME="MaterialAdw" ;;
esac

cat <<EOF > "$HOME/.config/Kvantum/kvantum.kvconfig"
[General]
theme=$KVANTUM_THEME
EOF

# --------------------------------------------------------------------
# 7. Qt 5 Configuration (qt5ct)
# --------------------------------------------------------------------
mkdir -p "$HOME/.config/qt5ct/colors"

cat <<EOF > "$HOME/.config/qt5ct/qt5ct.conf"
[Appearance]
color_scheme_path=$HOME/.config/qt5ct/colors/$THEME.conf
custom_palette=true
icon_theme=$ICON_THEME
standard_dialogs=default
style=kvantum

[Fonts]
fixed="JetBrains Mono,11,-1,5,50,0,0,0,0,0"
general="SF Pro,10,-1,5,50,0,0,0,0,0"

[Interface]
activate_item_on_single_click=1
buttonbox_layout=0
cursor_flash_time=1000
dialog_buttons_have_icons=1
double_click_interval=400
gui_effects=@Invalid()
keyboard_scheme=2
menus_have_icons=true
show_shortcuts_in_context_menus=true
toolbutton_style=4
underline_shortcut=1
wheel_scroll_lines=3
EOF

cat <<EOF > "$HOME/.config/qt5ct/colors/$THEME.conf"
[ColorScheme]
active_colors=$TEXT,$SURFACE,$SURFACE_LOW,$BG,$SURFACE_LOW,$TEXT_MUTED,$TEXT,$TEXT,$TEXT,$BG,$BG,$SURFACE_LOW,$ACCENT,$BG,$ACCENT,$DANGER,$SURFACE,$TEXT,$BG,$TEXT
disabled_colors=$TEXT_MUTED,$SURFACE,$SURFACE_LOW,$BG,$SURFACE_LOW,$TEXT_MUTED,$TEXT_MUTED,$TEXT,$TEXT_MUTED,$BG,$BG,$SURFACE_LOW,$SURFACE,$TEXT_MUTED,$ACCENT,$DANGER,$SURFACE,$TEXT_MUTED,$BG,$TEXT
inactive_colors=$TEXT,$SURFACE,$SURFACE_LOW,$BG,$SURFACE_LOW,$TEXT_MUTED,$TEXT,$TEXT,$TEXT,$BG,$BG,$SURFACE_LOW,$ACCENT,$BG,$ACCENT,$DANGER,$SURFACE,$TEXT,$BG,$TEXT
EOF

# --------------------------------------------------------------------
# 8. Qt 6 Configuration (qt6ct)
# --------------------------------------------------------------------
mkdir -p "$HOME/.config/qt6ct/colors"

cat <<EOF > "$HOME/.config/qt6ct/qt6ct.conf"
[Appearance]
color_scheme_path=$HOME/.config/qt6ct/colors/$THEME.conf
custom_palette=true
icon_theme=$ICON_THEME
standard_dialogs=default
style=kvantum

[Fonts]
fixed="JetBrains Mono,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
general="SF Pro,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"

[Interface]
activate_item_on_single_click=1
buttonbox_layout=0
cursor_flash_time=1000
dialog_buttons_have_icons=1
double_click_interval=400
gui_effects=@Invalid()
keyboard_scheme=2
menus_have_icons=true
show_shortcuts_in_context_menus=true
toolbutton_style=4
underline_shortcut=1
wheel_scroll_lines=3
EOF

cat <<EOF > "$HOME/.config/qt6ct/colors/$THEME.conf"
[ColorScheme]
active_colors=$TEXT,$SURFACE,$SURFACE_LOW,$BG,$SURFACE_LOW,$TEXT_MUTED,$TEXT,$TEXT,$TEXT,$BG,$BG,$SURFACE_LOW,$ACCENT,$BG,$ACCENT,$DANGER,$SURFACE,$TEXT,$BG,$TEXT
disabled_colors=$TEXT_MUTED,$SURFACE,$SURFACE_LOW,$BG,$SURFACE_LOW,$TEXT_MUTED,$TEXT_MUTED,$TEXT,$TEXT_MUTED,$BG,$BG,$SURFACE_LOW,$SURFACE,$TEXT_MUTED,$ACCENT,$DANGER,$SURFACE,$TEXT_MUTED,$BG,$TEXT
inactive_colors=$TEXT,$SURFACE,$SURFACE_LOW,$BG,$SURFACE_LOW,$TEXT_MUTED,$TEXT,$TEXT,$TEXT,$BG,$BG,$SURFACE_LOW,$ACCENT,$BG,$ACCENT,$DANGER,$SURFACE,$TEXT,$BG,$TEXT
EOF

# Touch configs to trigger live inotify reload in running Qt apps
touch "$HOME/.config/qt5ct/qt5ct.conf" 2>/dev/null || true
touch "$HOME/.config/qt6ct/qt6ct.conf" 2>/dev/null || true

# --------------------------------------------------------------------
# 9. Foot Terminal Configuration
# --------------------------------------------------------------------
mkdir -p "$HOME/.config/foot"
BG_STRIPPED=$(echo "$BG" | tr -d '#')
TEXT_STRIPPED=$(echo "$TEXT" | tr -d '#')
SEL_BG_STRIPPED=$(echo "$FOOT_SEL_BG" | tr -d '#')
ACCENT_STRIPPED=$(echo "$ACCENT" | tr -d '#')

cat <<EOF > "$HOME/.config/foot/foot.ini"
# SwayShell Generated Configuration ($THEME)
term=xterm-256color
font=JetBrains Mono:size=11, SF Pro:size=11
font-bold=JetBrains Mono:weight=bold:size=11
font-italic=JetBrains Mono:slant=italic:size=11
dpi-aware=yes
pad=16x16

[cursor]
style=beam
color=$FOOT_CURSOR
blink=yes
beam-thickness=1.5

[colors]
alpha=0.92
foreground=$TEXT_STRIPPED
background=$BG_STRIPPED

regular0=$C0
regular1=$C1
regular2=$C2
regular3=$C3
regular4=$C4
regular5=$C5
regular6=$C6
regular7=$C7

bright0=$C8
bright1=$C9
bright2=$C10
bright3=$C11
bright4=$C12
bright5=$C13
bright6=$C14
bright7=$C15

selection-foreground=$TEXT_STRIPPED
selection-background=$SEL_BG_STRIPPED
urls=$ACCENT_STRIPPED

[scrollback]
lines=10000
multiplier=3.0

[key-bindings]
scrollback-up-page=Page_Up
scrollback-down-page=Page_Down
clipboard-copy=Control+Shift+c
clipboard-paste=Control+Shift+v
search-start=Control+Shift+f
font-increase=Control+plus Control+equal
font-decrease=Control+minus
font-reset=Control+0
EOF

# --------------------------------------------------------------------
# 10. GSettings & DConf (Desktop interface & dark mode preference)
# --------------------------------------------------------------------
if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface font-name "$FONT_SANS" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface document-font-name "$FONT_SANS" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface monospace-font-name "$FONT_MONO" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface font-antialiasing 'rgba' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface font-hinting 'slight' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface accent-color "$ACCENT_GNOME" 2>/dev/null || true
    gsettings set org.gnome.desktop.wm.preferences theme 'adw-gtk3-dark' 2>/dev/null || true

    # Live reload trigger for running GTK4 / Libadwaita apps (like dux-shell)
    gsettings set org.gnome.desktop.interface color-scheme 'default' 2>/dev/null || true
    sleep 0.05
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
fi

if command -v dconf >/dev/null 2>&1; then
    dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'" 2>/dev/null || true
    dconf write /org/gnome/desktop/interface/gtk-theme "'adw-gtk3-dark'" 2>/dev/null || true
    dconf write /org/gnome/desktop/interface/icon-theme "'$ICON_THEME'" 2>/dev/null || true
    dconf write /org/gnome/desktop/interface/accent-color "'$ACCENT_GNOME'" 2>/dev/null || true
fi

# --------------------------------------------------------------------
# 11. Synchronize Session Environment
# --------------------------------------------------------------------
mkdir -p "$HOME/.config/environment.d"
cat <<EOF > "$HOME/.config/environment.d/10-sway-wayland.conf"
QT_QPA_PLATFORM="wayland;xcb"
QT_QPA_PLATFORMTHEME="qt6ct"
QT_PLUGIN_PATH="$HOME/.local/lib/qt5/plugins"
QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
GTK_THEME="adw-gtk3-dark"
XDG_CURRENT_DESKTOP="sway"
XDG_SESSION_TYPE="wayland"
MOZ_ENABLE_WAYLAND="1"
EOF

if command -v dbus-update-activation-environment >/dev/null 2>&1; then
    dbus-update-activation-environment --systemd \
        WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP XDG_SESSION_TYPE DISPLAY \
        QT_QPA_PLATFORM QT_QPA_PLATFORMTHEME QT_PLUGIN_PATH GTK_THEME 2>/dev/null || true
fi

if command -v systemctl >/dev/null 2>&1; then
    systemctl --user import-environment \
        WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP XDG_SESSION_TYPE DISPLAY \
        QT_QPA_PLATFORM QT_QPA_PLATFORMTHEME QT_PLUGIN_PATH GTK_THEME 2>/dev/null || true
fi

# --------------------------------------------------------------------
# 12. Dynamic Sway Window Border Colors
# --------------------------------------------------------------------
if [ -n "${SWAYSOCK:-}" ] && command -v swaymsg >/dev/null 2>&1; then
    swaymsg "client.focused $ACCENT $BG $TEXT $ACCENT_ALT $ACCENT" 2>/dev/null || true
    swaymsg "client.focused_inactive $SURFACE $BG $TEXT_MUTED $SURFACE $SURFACE" 2>/dev/null || true
    swaymsg "client.unfocused $BG $BG $TEXT_MUTED $BG $BG" 2>/dev/null || true
    swaymsg "client.urgent $DANGER $BG $TEXT $DANGER $DANGER" 2>/dev/null || true
fi

echo "Theme $THEME successfully applied across GTK 2/3/4, Qt 5/6, Kvantum, Foot & Sway!"
