# GNOME Matugen Material You Themer 🎨

Automatic, dynamic Material You (Material Design 3) theme generator and system replicator for **GNOME Shell**, **GDM (Login Screen)**, **GTK 4 / Libadwaita**, **GTK 3 (adw-gtk3)**, **Qt 5 / Qt 6 (Kvantum + QAdwaitaDecorations)** on **Debian 13 (Trixie)**, Ubuntu, and modern Linux distributions.

---

## ✨ Features

- 🖼️ **Dynamic Wallpaper Theming**: Extracts color palettes in real-time from your GNOME wallpaper using [Matugen](https://github.com/InioX/matugen).
- 🔒 **GDM Login Screen Theming**: Matches the GDM Display Manager login screen with your active wallpaper and Material You color scheme via dynamic GResource compilation.
- 🐚 **GNOME Shell Customization**:
  - Translucent Material You top panel (`2.1em` height with subtle bottom border).
  - Compact floating dash/dock (`6px` padding, `18px` radius, elevation shadow, surface container tint).
  - Syncs native GNOME 47/48 `accent-color`.
- 🪟 **Unified GTK 3 & GTK 4 / Libadwaita**:
  - Full Libadwaita CSS custom property theming.
  - Pixel-perfect legacy GTK3 styling via `adw-gtk3`.
- ⚙️ **Comprehensive Qt 5 & Qt 6 Support**:
  - Custom dynamic [Kvantum](https://github.com/tsujan/Kvantum) vector theme (`MaterialYou.svg` & `MaterialYou.kvconfig`) eliminating static grey menus and toolbars.
  - Dynamic binary patching of `QAdwaitaDecorations` (`libadwaita.so`) so Qt window titlebars on Wayland seamlessly adapt to wallpaper colors.
  - Palette color synchronization for `qt5ct` and `qt6ct`.
- 🎭 **Icon Theme & Typography**:
  - Pre-configured `WhiteSur-grey-dark` icon theme.
  - Native integration with `JetBrains Mono` monospace font.
- 🔄 **Zero-Config Daemon**:
  - Systemd user service (`matugen-gnome.service`) that automatically reacts to wallpaper changes and dark/light mode toggles.
- 📦 **100% Replicable**:
  - Single automated installer (`install.sh`) that configures dependencies, themes, fonts, environment variables, extensions, and preferences from scratch.

---

## 📋 Requirements

The installer (`install.sh`) automatically manages all dependencies via APT:
- **Debian 13 (Trixie)**, Ubuntu 24.04+, or Debian-based distributions with GNOME 45–48.
- Core packages: `sassc`, `gnome-shell-extensions`, `gnome-tweaks`, `libgio-2.0-dev-bin` (provides `glib-compile-resources`), `imagemagick`, `inotify-tools`, `libjxl-tools`.
- Qt packages: `qt5ct`, `qt6ct`, `qt-style-kvantum`, `qt-style-kvantum-themes`, `qt6-wayland`.
- Typography & Icons: `fonts-jetbrains-mono`, `WhiteSur-icon-theme`.
- [Matugen v4.2+](https://github.com/InioX/matugen) (Auto-downloaded if not present).
- [adw-gtk3](https://github.com/lassekongo83/adw-gtk3) (Auto-downloaded if not present).

---

## 🚀 Quick Start (Replication & Installation)

To install or replicate this complete setup on any PC:

```bash
# 1. Clone repository
git clone https://github.com/<your-user>/matugen-gnome.git
cd matugen-gnome

# 2. Run the automated installer
chmod +x install.sh
./install.sh
```

### What `install.sh` does:
1. Installs all required APT packages, fonts, and utilities.
2. Downloads and sets up Matugen and the `adw-gtk3` theme.
3. Installs the `WhiteSur-grey-dark` icon theme.
4. Deploys Matugen templates to `~/.config/gnome-matugen/templates`.
5. Installs executables into `~/.local/bin/`.
6. Configures Qt Wayland environment variables in `~/.config/environment.d/qt-theme.conf` and pre-sets `qt5ct`/`qt6ct` to Kvantum.
7. Enables GNOME Shell extensions (`user-theme`, `windowsNavigator`).
8. Configures GNOME desktop preferences (dark mode, monospace font, close button layout, focus mode).
9. Configures GDM login screen theming.
10. Enables and starts the background `matugen-gnome.service`.
11. Generates and applies the initial Material You theme.

---

## 🔒 GDM Login Screen Management (`gnome-matugen-gdm`)

Manage the GDM login screen theme:

```bash
# Check GDM integration status
gnome-matugen-gdm --status

# Setup GDM theming (requires sudo once, allows regular user updates thereafter)
sudo gnome-matugen-gdm --setup

# Manually update GDM theme with current wallpaper & colors
gnome-matugen-gdm --update

# Restore stock factory GDM theme
sudo gnome-matugen-gdm --restore
```

> **Note:** Once `--setup` is performed, `gnome-matugen-apply` and `matugen-gnome.service` will update the GDM login screen wallpaper and colors automatically in the background without needing root privileges.

---

## 🛠️ Manual Usage (`gnome-matugen-apply`)

Customize your theme on demand from the terminal:

```bash
# Apply theme using current GNOME wallpaper
gnome-matugen-apply

# Apply theme from a specific wallpaper image
gnome-matugen-apply --image ~/Pictures/wallpaper.jpg

# Apply theme from a custom HEX color
gnome-matugen-apply --color "#3b82f6"

# Force Dark or Light mode
gnome-matugen-apply --mode dark
gnome-matugen-apply --mode light

# Use a specific Material You palette scheme
# (scheme-tonal-spot, scheme-expressive, scheme-fruit-salad, scheme-rainbow, scheme-fidelity, scheme-content)
gnome-matugen-apply --type scheme-fruit-salad

# Adjust color extraction preference
# (saturation, darkness, lightness, value)
gnome-matugen-apply --prefer saturation
```

---

## 🔄 Service Management

```bash
# Check background service status
systemctl --user status matugen-gnome.service

# View live service logs
journalctl --user -u matugen-gnome.service -f

# Restart service
systemctl --user restart matugen-gnome.service
```

---

## 📁 Repository Structure

```
matugen-gnome/
├── bin/
│   ├── gnome-matugen-apply      # Theme generator & synchronizer (GTK, Qt, Shell, GDM)
│   ├── gnome-matugen-daemon     # Background file and gsettings monitor
│   └── gnome-matugen-gdm        # GDM login screen theming & gresource compiler
├── systemd/
│   └── matugen-gnome.service    # Systemd user service unit
├── templates/
│   ├── gnome-shell.scss         # GNOME Shell root stylesheet
│   ├── gnome-shell-colors.scss  # Dynamic color mappings for GNOME Shell
│   ├── gnome-shell-sass/        # Modular GNOME Shell SCSS sources
│   ├── gtk.css                  # GTK3 (adw-gtk3) dynamic color overrides
│   ├── gtk4.css                 # GTK4 / Libadwaita root color variables
│   ├── kvantum.kvconfig         # Kvantum Material You configuration template
│   ├── kvantum.svg              # Kvantum vector graphics template
│   ├── qtct.conf                # Qt5ct / Qt6ct palette template
│   └── qt-decoration.json       # QAdwaitaDecorations Wayland titlebar color tokens
├── install.sh                   # Comprehensive replication & installer script
├── uninstall.sh                 # Complete cleanup & restoration script
├── LICENSE                      # MIT License
└── README.md
```

---

## 🗑️ Uninstallation

To cleanly remove all custom themes, configurations, and restore stock settings:

```bash
./uninstall.sh
```
