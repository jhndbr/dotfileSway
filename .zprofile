# ╔══════════════════════════════════════════════════════════════╗
# ║              Variables de Entorno — Wayland/Sway             ║
# ╚══════════════════════════════════════════════════════════════╝

# ── Wayland / Sway ──────────────────────────────────────────────
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=sway
export XDG_CURRENT_DESKTOP=sway

# ── Qt ──────────────────────────────────────────────────────────
export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORMTHEME=qt6ct
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export QT_AUTO_SCREEN_SCALE_FACTOR=1

# ── GTK ─────────────────────────────────────────────────────────
export GDK_BACKEND=wayland,x11

# ── Electron / Chromium ─────────────────────────────────────────
export ELECTRON_OZONE_PLATFORM_HINT=auto
export MOZ_ENABLE_WAYLAND=1

# ── Clutter ─────────────────────────────────────────────────────
export CLUTTER_BACKEND=wayland

# ── SDL ─────────────────────────────────────────────────────────
export SDL_VIDEODRIVER=wayland

# ── Java ────────────────────────────────────────────────────────
export _JAVA_AWT_WM_NONREPARENTING=1

# ── PATH ────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$HOME/.local/share/JetBrains/Toolbox/scripts:$PATH"
