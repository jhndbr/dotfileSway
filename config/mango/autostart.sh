#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║        MangoWM Autostart — macOS Monochromatic Style           ║
# ║        Servicios, daemons y utilidades del entorno             ║
# ╚══════════════════════════════════════════════════════════════╝

set +e

# ── D-Bus / Entorno & Portales XDG ──────────────────────────────
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=mango XDG_SESSION_TYPE=wayland QT_QPA_PLATFORMTHEME=qt6ct &
systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE QT_QPA_PLATFORMTHEME &

# ── Portales XDG (sin estado sucio previo) ──────────────────────
systemctl --user restart xdg-desktop-portal 2>/dev/null &
/usr/lib/xdg-desktop-portal-wlr >/dev/null 2>&1 &

# ── Autenticación, llaves y secretos (Polkit & Keyring) ────────
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
gnome-keyring-daemon --start --components="secrets,ssh,pkcs11" &

# ── Wallpaper ────────────────────────────────────────────────────
wbg "$HOME/Pictures/1.jpg" >/dev/null 2>&1 &

# ── Barra superior (Waybar) ─────────────────────────────────────
waybar -c ~/.config/mango/waybar/config.jsonc -s ~/.config/mango/waybar/style.css >/dev/null 2>&1 &

# ── Notificaciones (Dunst) ──────────────────────────────────────
dunst &

# ── Portapapeles & Automontaje USB ─────────────────────────────
wl-paste --watch cliphist store &
wl-clip-persist --clipboard regular --reconnect-tries 0 2>/dev/null &
udiskie -N &

# ── Idle management (pantalla y reposo) ─────────────────────────
~/.local/bin/swayidle.sh &

# ── Filtro de luz azul (night light) ────────────────────────────
gammastep -l -34.6:-58.4 -t 6500:3500 -m wayland >/dev/null 2>&1 &

# ── Inhibir idle cuando hay audio reproduciéndose ──────────────
sway-audio-idle-inhibit >/dev/null 2>&1 &

# ── OSD de volumen y brillo ─────────────────────────────────────
swayosd-server >/dev/null 2>&1 &

# ── Applets de bandeja (Bluetooth & Red) ────────────────────────
blueman-applet >/dev/null 2>&1 &
nm-applet >/dev/null 2>&1 &

# ── Monitor de batería baja (solo laptops) ─────────────────────
if ls -d /sys/class/power_supply/BAT* >/dev/null 2>&1; then
    ~/.local/bin/battery-alert.sh &
fi
