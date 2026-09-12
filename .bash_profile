# ╔══════════════════════════════════════════════════════════════╗
# ║              Variables de Entorno — Wayland/MangoWM          ║
# ╚══════════════════════════════════════════════════════════════╝

# Cargar .bashrc si existe
[[ -f ~/.bashrc ]] && . ~/.bashrc

# ── Limpieza de variables residuales ─────────────────────────────
unset ZDOTDIR 2>/dev/null || true

# ── Wayland / MangoWM ───────────────────────────────────────────
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=mango
export XDG_CURRENT_DESKTOP=mango:wlroots

# ── Qt ──────────────────────────────────────────────────────────
export QT_QPA_PLATFORM="wayland;xcb"
export QT_QPA_PLATFORMTHEME=qt6ct
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export QT_AUTO_SCREEN_SCALE_FACTOR=1

# ── GTK ─────────────────────────────────────────────────────────
export GDK_BACKEND="wayland,x11"

# ── Electron / Chromium ─────────────────────────────────────────
export ELECTRON_OZONE_PLATFORM_HINT=auto
export MOZ_ENABLE_WAYLAND=1

# ── Clutter / SDL / Java ────────────────────────────────────────
export CLUTTER_BACKEND=wayland
export SDL_VIDEODRIVER=wayland
export _JAVA_AWT_WM_NONREPARENTING=1

# ── PATH ────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$HOME/.local/share/JetBrains/Toolbox/scripts:$PATH"

# ── Autostart MangoWM / Sway en TTY1 ────────────────────────────
if [ -z "$WAYLAND_DISPLAY" ] && [ -z "$DISPLAY" ]; then
    if [ "$XDG_VTNR" = "1" ] || [ "$(tty 2>/dev/null)" = "/dev/tty1" ]; then
        if command -v mango &>/dev/null; then
            exec mango
        elif command -v mangowm &>/dev/null; then
            exec mangowm
        elif command -v sway &>/dev/null; then
            exec sway
        fi
    fi
fi
