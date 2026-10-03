#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║        MangoWM Autostart — macOS Monochromatic Style         ║
# ║        Servicios, daemons y utilidades del entorno           ║
# ║        Port idéntico al autostart de Sway (pc-note)          ║
# ╚══════════════════════════════════════════════════════════════╝

set +e

# ── D-Bus / Entorno & Portales XDG ──────────────────────────────
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=mango:wlroots XDG_SESSION_TYPE=wayland QT_QPA_PLATFORMTHEME=qt6ct 2>/dev/null &
systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE QT_QPA_PLATFORMTHEME 2>/dev/null &

# ── Servicios de autenticación, llaves y secretos ───────────────
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 >/dev/null 2>&1 &
gnome-keyring-daemon --start --components="secrets,ssh,pkcs11" >/dev/null 2>&1 &

# ── Fondo de Pantalla (swaybg persistente) ──────────────────────
if [ -f "$HOME/Pictures/1.jpg" ]; then
    swaybg -i "$HOME/Pictures/1.jpg" -m fill >/dev/null 2>&1 &
fi

# ── Sincronizador de Workspaces y Ventanas para MangoWM ───────────
pkill -f waybar-mango-workspaces.py 2>/dev/null || true
python3 "$HOME/.local/bin/waybar-mango-workspaces.py" daemon >/dev/null 2>&1 &

# ── Barra Superior (Waybar para MangoWM) ─────────────────────────
pkill -x waybar 2>/dev/null || true
sleep 0.3
waybar -c "$HOME/.config/waybar/config" -s "$HOME/.config/waybar/style.css" >/tmp/waybar-mango.log 2>&1 &


# ── Notificaciones & Feedback OSD ───────────────────────────────
dunst >/dev/null 2>&1 &
if ! pgrep -x swayosd-server >/dev/null; then
    swayosd-server --style "$HOME/.config/swayosd/style.css" >/dev/null 2>&1 &
fi

# ── Portapapeles & Automontaje USB ──────────────────────────────
wl-paste --type text --watch cliphist store >/dev/null 2>&1 &
wl-paste --type image --watch cliphist store >/dev/null 2>&1 &
udiskie -N >/dev/null 2>&1 &

# ── Idle management (pantalla y reposo) ─────────────────────────
~/.local/bin/swayidle.sh >/dev/null 2>&1 &

# ── Filtro de luz azul (gammastep night light) ──────────────────
~/.local/bin/gammastep-toggle.sh autostart >/dev/null 2>&1 &

# ── Monitor de batería baja (solo laptops) ──────────────────────
if ls -d /sys/class/power_supply/BAT* >/dev/null 2>&1; then
    ~/.local/bin/battery-alert.sh >/dev/null 2>&1 &
fi

# Desvincular procesos en segundo plano para que persistan
disown -a 2>/dev/null || true
