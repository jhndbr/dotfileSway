# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

export PATH="/home/jhon/.local/bin:$PATH"

# Variables de entorno para Wayland y Sway
export XDG_CURRENT_DESKTOP="sway:GNOME"
export XDG_SESSION_DESKTOP=sway
export XDG_SESSION_TYPE=wayland

# Soporte Wayland para aplicaciones Qt (Strawberry, etc.)
export QT_QPA_PLATFORM="wayland;xcb"
export QT_QPA_PLATFORMTHEME="gtk3"
export QT_STYLE_OVERRIDE="kvantum"
export QT_PLUGIN_PATH="/home/jhon/.local/usr/lib/x86_64-linux-gnu/qt6/plugins:$QT_PLUGIN_PATH"
export LD_LIBRARY_PATH="/home/jhon/.local/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH"
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export QT_AUTO_SCREEN_SCALE_FACTOR=1

# Soporte Wayland para Mozilla Firefox
export MOZ_ENABLE_WAYLAND=1

# Soporte Wayland para GTK
export GDK_BACKEND="wayland,x11,*"

# Soporte Wayland para Electron (Joplin, VSCode, etc.)
export ELECTRON_OZONE_PLATFORM_HINT=auto

# Juegos y multimedia
export SDL_VIDEODRIVER=wayland
export CLUTTER_BACKEND=wayland

# Preferencia de tema oscuro para GTK
export GTK_THEME="Fluent-purple-Dark"
