#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Uninstaller for GNOME Matugen Material You Themer
# ==============================================================================

BIN_DIR="$HOME/.local/bin"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/gnome-matugen"
SYSTEMD_USER_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
THEME_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/themes/Material-You"

echo "🗑️ Uninstalling GNOME Matugen Themer..."

# 1. Restore GDM theme if customized
if [[ -L "/usr/share/gnome-shell/gnome-shell-theme.gresource" ]]; then
  echo "🔒 Restoring original GDM login screen..."
  if command -v "$BIN_DIR/gnome-matugen-gdm" >/dev/null 2>&1; then
    sudo "$BIN_DIR/gnome-matugen-gdm" --restore || true
  elif [[ -f "/usr/share/gnome-shell/gnome-shell-theme.gresource.bak" ]]; then
    sudo rm -f "/usr/share/gnome-shell/gnome-shell-theme.gresource"
    sudo cp "/usr/share/gnome-shell/gnome-shell-theme.gresource.bak" "/usr/share/gnome-shell/gnome-shell-theme.gresource"
    sudo rm -rf "/etc/gnome-shell"
    echo "✅ Restored stock GDM theme."
  fi
fi

# 2. Stop and disable systemd service
if systemctl --user is-active --quiet matugen-gnome.service 2>/dev/null; then
  echo "⏹️ Stopping systemd service..."
  systemctl --user stop matugen-gnome.service || true
  systemctl --user disable matugen-gnome.service || true
fi

rm -f "$SYSTEMD_USER_DIR/matugen-gnome.service"
systemctl --user daemon-reload || true

# 3. Reset GNOME settings to defaults
echo "🔄 Resetting GNOME theme settings..."
gsettings set org.gnome.shell.extensions.user-theme name '' 2>/dev/null || true
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita' 2>/dev/null || true

# 4. Clean CSS and configuration files generated
rm -f "$HOME/.config/gtk-3.0/gtk.css"
rm -f "$HOME/.config/gtk-4.0/gtk.css"
rm -f "$HOME/.config/qt5ct/colors/MaterialYou.conf"
rm -f "$HOME/.config/qt6ct/colors/MaterialYou.conf"
rm -rf "$HOME/.config/Kvantum/MaterialYou"
rm -f "$HOME/.config/environment.d/qt-theme.conf"
rm -f "$HOME/.local/lib/qt6/plugins/wayland-decoration-client/libadwaita.so"
rm -rf "$THEME_DIR"
rm -rf "$CONFIG_DIR"
rm -f "$BIN_DIR/gnome-matugen-apply"
rm -f "$BIN_DIR/gnome-matugen-daemon"
rm -f "$BIN_DIR/gnome-matugen-gdm"

echo "✅ Uninstallation complete."
