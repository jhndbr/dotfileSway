#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║        Gaming Launcher & Optimizer Wrapper                   ║
# ║        Ejecuta juegos con GameMode + MangoHud + Optimizaciones║
# ╚══════════════════════════════════════════════════════════════╝

set -e

# Exportar variables de aceleración y baja latencia para el proceso hijo
export mesa_glthread=true
export AMD_VULKAN_ICD=RADV
export RADV_PERFTEST=aco
export SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0

# Si se pasaron argumentos, ejecutar el juego directamente con las herramientas instaladas
if [ "$#" -gt 0 ]; then
    CMD=()
    if command -v gamemoderun &>/dev/null; then
        CMD+=(gamemoderun)
    fi
    if command -v mangohud &>/dev/null; then
        CMD+=(mangohud)
    fi
    exec "${CMD[@]}" "$@"
fi

# Si no se pasaron argumentos, abrir menú interactivo Wofi
OPCIONES="🎮  Iniciar Steam (GameMode)\n⚡  Ver Rendimiento / Sensores (btop)\n📊  Diagnóstico GameMode\n🎯  Ejecutar binario con GameMode..."

SELECCION=$(echo -e "$OPCIONES" | wofi --dmenu \
    --prompt "Gaming Hub" \
    --cache-file /dev/null \
    --insensitive \
    --width 340 \
    --height 220 \
    --lines 4)

case "$SELECCION" in
    *"Iniciar Steam"*)
        notify-send -u low -a "Gaming Hub" "🎮 Steam" "Iniciando con GameMode..." 2>/dev/null || true
        gamemoderun steam &>/dev/null &
        ;;
    *"Ver Rendimiento"*)
        foot -e btop &
        ;;
    *"Diagnóstico GameMode"*)
        STATUS=$(gamemoded -s 2>&1 || echo "Error consultando daemon")
        notify-send -a "GameMode" "Estado de GameMode" "$STATUS"
        ;;
    *"Ejecutar binario"*)
        APP=$(wofi --show run --prompt "Ejecutar con GameMode:")
        if [ -n "$APP" ]; then
            gamemoderun mangohud $APP &
        fi
        ;;
esac
