#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Installer for GNOME Matugen Material You Themer
# Full PC Customization & Replication Script for Debian 13 (Trixie) & GNOME 48
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/gnome-matugen"
SYSTEMD_USER_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
THEMES_USER_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/themes"
ICONS_USER_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/icons"

echo "=========================================================="
echo " 🎨  GNOME Matugen Material You - Installer & Setup"
echo "=========================================================="
echo ""

# 1. Install System Dependencies via APT
echo "📦 Step 1: Installing system dependencies..."
if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y \
    sassc \
    gnome-shell-extensions \
    gnome-tweaks \
    qt5ct \
    qt6ct \
    qt-style-kvantum \
    qt-style-kvantum-themes \
    qt6-wayland \
    libgio-2.0-dev-bin \
    inotify-tools \
    libjxl-tools \
    imagemagick \
    fonts-jetbrains-mono \
    curl \
    tar \
    git \
    xz-utils

  # Optional recommended hardware firmware for AMD Ryzen / Realtek Bluetooth
  if lspci 2>/dev/null | grep -qi "Realtek" || lsusb 2>/dev/null | grep -qi "Realtek"; then
    echo "🔍 Realtek hardware detected, ensuring firmware-realtek is installed..."
    sudo apt-get install -y firmware-realtek || true
  fi
else
  echo "⚠️ apt-get not found. Please ensure sassc, gnome-shell-extensions, qt5ct, qt6ct, qt-style-kvantum, and libgio-2.0-dev-bin are installed."
fi

mkdir -p "$BIN_DIR" "$CONFIG_DIR" "$SYSTEMD_USER_DIR" "$THEMES_USER_DIR" "$ICONS_USER_DIR"

# 2. Install Matugen
echo ""
echo "🚀 Step 2: Checking Matugen installation..."
if ! command -v matugen >/dev/null 2>&1 && [[ ! -x "$BIN_DIR/matugen" ]]; then
  echo "📥 Downloading Matugen binary (Linux x86_64)..."
  TMP_DIR="$(mktemp -d)"
  
  if curl -sL -o "$TMP_DIR/matugen.tar.gz" https://github.com/InioX/matugen/releases/download/v4.2.0/matugen-4.2.0-x86_64.tar.gz; then
    tar -xzf "$TMP_DIR/matugen.tar.gz" -C "$TMP_DIR"
    cp "$TMP_DIR/matugen" "$BIN_DIR/matugen"
    chmod +x "$BIN_DIR/matugen"
    echo "✅ Matugen installed to $BIN_DIR/matugen"
  else
    echo "❌ Failed to download Matugen automatically. Please install Matugen manually." >&2
    exit 1
  fi
  rm -rf "$TMP_DIR"
else
  echo "✅ Matugen is already installed."
fi

# 3. Install adw-gtk3 theme for legacy GTK3 applications
echo ""
echo "🎨 Step 3: Checking adw-gtk3 (GTK3 libadwaita theme)..."
if [[ ! -d "/usr/share/themes/adw-gtk3" && ! -d "$THEMES_USER_DIR/adw-gtk3" ]]; then
  echo "📥 Installing adw-gtk3 theme..."
  TMP_ADW="$(mktemp -d)"
  if curl -sL -o "$TMP_ADW/adw-gtk3.tar.xz" "https://github.com/lassekongo83/adw-gtk3/releases/download/v5.3/adw-gtk3v5.3.tar.xz" 2>/dev/null || \
     curl -sL -o "$TMP_ADW/adw-gtk3.tar.xz" "https://github.com/lassekongo83/adw-gtk3/releases/download/v5.2/adw-gtk3v5.2.tar.xz" 2>/dev/null; then
    tar -xf "$TMP_ADW/adw-gtk3.tar.xz" -C "$THEMES_USER_DIR"
    echo "✅ adw-gtk3 installed to $THEMES_USER_DIR"
  else
    echo "⚠️ Could not download pre-built adw-gtk3. GTK3 legacy apps might need adw-gtk3 manually installed."
  fi
  rm -rf "$TMP_ADW"
else
  echo "✅ adw-gtk3 theme found."
fi

for f in "$THEMES_USER_DIR/adw-gtk3/gtk-3.0/gtk.css" \
         "$THEMES_USER_DIR/adw-gtk3/gtk-3.0/gtk-dark.css" \
         "$THEMES_USER_DIR/adw-gtk3-dark/gtk-3.0/gtk.css" \
         "$THEMES_USER_DIR/adw-gtk3-dark/gtk-3.0/gtk-dark.css"; do
  if [[ -f "$f" ]] && ! grep -q '\.config/gtk-3\.0/gtk\.css' "$f"; then
    echo -e '\n@import url("../../../../.config/gtk-3.0/gtk.css");' >> "$f"
  fi
done

# 4. Install WhiteSur Icon Theme if missing
echo ""
echo "🎭 Step 4: Checking WhiteSur icon theme..."
if [[ ! -d "$ICONS_USER_DIR/WhiteSur-grey-dark" && ! -d "/usr/share/icons/WhiteSur-grey-dark" ]]; then
  echo "📥 Installing WhiteSur-grey-dark icons from source..."
  TMP_ICONS="$(mktemp -d)"
  if git clone --depth=1 https://github.com/vinceliuice/WhiteSur-icon-theme.git "$TMP_ICONS" 2>/dev/null; then
    "$TMP_ICONS/install.sh" -c grey -a || true
    echo "✅ WhiteSur icons installed to $ICONS_USER_DIR"
  else
    echo "⚠️ Could not clone WhiteSur-icon-theme. System icons will be used."
  fi
  rm -rf "$TMP_ICONS"
else
  echo "✅ WhiteSur-grey-dark icon theme found."
fi

# 5. Copy Templates
echo ""
echo "📁 Step 5: Installing Matugen templates..."
rm -rf "$CONFIG_DIR/templates"
cp -r "$SCRIPT_DIR/templates" "$CONFIG_DIR/templates"
echo "✅ Templates installed to $CONFIG_DIR/templates"

# 6. Install Executables
echo ""
echo "⚙️ Step 6: Installing executables..."
cp "$SCRIPT_DIR/bin/gnome-matugen-apply" "$BIN_DIR/gnome-matugen-apply"
cp "$SCRIPT_DIR/bin/gnome-matugen-daemon" "$BIN_DIR/gnome-matugen-daemon"
cp "$SCRIPT_DIR/bin/gnome-matugen-gdm" "$BIN_DIR/gnome-matugen-gdm"
chmod +x "$BIN_DIR/gnome-matugen-apply" "$BIN_DIR/gnome-matugen-daemon" "$BIN_DIR/gnome-matugen-gdm"
echo "✅ Installed gnome-matugen-apply, gnome-matugen-daemon & gnome-matugen-gdm in $BIN_DIR"

# 7. Configure Qt Environment & Applications (qt5ct / qt6ct / Kvantum)
echo ""
echo "⚙️ Step 7: Configuring Qt theming & environment..."
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/environment.d" \
         "${XDG_CONFIG_HOME:-$HOME/.config}/qt5ct" \
         "${XDG_CONFIG_HOME:-$HOME/.config}/qt6ct" \
         "${XDG_CONFIG_HOME:-$HOME/.config}/Kvantum"

cat > "${XDG_CONFIG_HOME:-$HOME/.config}/environment.d/qt-theme.conf" << 'EOF'
QT_QPA_PLATFORMTHEME=qt6ct
QT_PLUGIN_PATH=$HOME/.local/lib/qt6/plugins:/usr/lib/x86_64-linux-gnu/qt6/plugins
EOF

cat > "${XDG_CONFIG_HOME:-$HOME/.config}/Kvantum/kvantum.kvconfig" << 'EOF'
[General]
theme=MaterialYou
EOF

# Pre-configure qt5ct and qt6ct if not already present
for qt_ver in qt5ct qt6ct; do
  conf_file="${XDG_CONFIG_HOME:-$HOME/.config}/$qt_ver/$qt_ver.conf"
  if [[ ! -f "$conf_file" ]] || ! grep -q "style=kvantum" "$conf_file"; then
    cat > "$conf_file" << EOF
[Appearance]
color_scheme_path=$HOME/.config/$qt_ver/colors/MaterialYou.conf
custom_palette=true
icon_theme=WhiteSur-grey-dark
standard_dialogs=default
style=kvantum-dark

[Fonts]
fixed="JetBrains Mono,10,-1,5,400,0,0,0,0,0"
general="Cantarell,10,-1,5,400,0,0,0,0,0"

[Interface]
activate_item_on_single_click=1
buttonbox_layout=3
cursor_flash_time=1200
dialog_buttons_have_icons=0
double_click_interval=400
gui_effects=@Invalid()
keyboard_scheme=2
menus_have_icons=true
show_shortcuts_in_context_menus=true
stylesheets=@Invalid()
toolbutton_style=4
underline_shortcut=1
wheel_scroll_lines=3
EOF
    echo "✅ Initialized $conf_file for $qt_ver"
  fi
done

# 8. Configure GNOME Shell Preferences & Extensions
echo ""
echo "🧩 Step 8: Configuring GNOME desktop preferences..."
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com 2>/dev/null || true
gnome-extensions enable windowsNavigator@gnome-shell-extensions.gcampax.github.com 2>/dev/null || true

gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' || true
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' || true
if [[ -d "$ICONS_USER_DIR/WhiteSur-grey-dark" || -d "/usr/share/icons/WhiteSur-grey-dark" ]]; then
  gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-grey-dark' || true
fi
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrains Mono 11' || true
gsettings set org.gnome.desktop.wm.preferences button-layout ':close' || true
gsettings set org.gnome.desktop.wm.preferences focus-mode 'mouse' || true
gsettings set org.gnome.desktop.interface text-scaling-factor 0.8 || true

# 9. Setup GDM Login Screen Theming
echo ""
echo "🔒 Step 9: Setting up GDM Material You login screen..."
if command -v "$BIN_DIR/gnome-matugen-gdm" >/dev/null 2>&1; then
  sudo "$BIN_DIR/gnome-matugen-gdm" --setup "$USER" || echo "⚠️ GDM theming setup skipped or requires manual authorization."
fi

# 10. Configure Systemd Service
echo ""
echo "🔄 Step 10: Configuring Systemd user service..."
cp "$SCRIPT_DIR/systemd/matugen-gnome.service" "$SYSTEMD_USER_DIR/matugen-gnome.service"
systemctl --user daemon-reload
systemctl --user enable --now matugen-gnome.service
echo "✅ Systemd service enabled and started."

# 11. Add ~/.local/bin to PATH in bashrc if needed
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  if ! grep -q 'PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    echo "ℹ️ Added ~/.local/bin to ~/.bashrc"
  fi
fi

# 12. Apply theme for the first time
echo ""
echo "✨ Step 11: Generating initial Material You theme..."
export PATH="$BIN_DIR:$PATH"
"$BIN_DIR/gnome-matugen-apply" || true

echo ""
echo "=========================================================="
echo " 🎉 Installation Complete!"
echo " GNOME, GTK 3/4, Qt 5/6, Kvantum & GDM are now fully themed."
echo ""
echo " Useful Commands:"
echo "   - Apply theme manually: gnome-matugen-apply"
echo "   - Manage GDM theme:     gnome-matugen-gdm --status"
echo "   - Service status:       systemctl --user status matugen-gnome.service"
echo "   - Service logs:         journalctl --user -u matugen-gnome.service -f"
echo "=========================================================="
