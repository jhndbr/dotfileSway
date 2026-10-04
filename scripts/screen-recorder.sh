#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║        Grabador Rápido de Pantalla (wf-recorder + slurp)     ║
# ╚══════════════════════════════════════════════════════════════╝

RECORDINGS_DIR="$HOME/Videos/Capturas"
mkdir -p "$RECORDINGS_DIR"

PID_FILE="${XDG_RUNTIME_DIR:-/tmp}/wf-recorder.pid"

is_recording() {
    pgrep -x wf-recorder > /dev/null
}

stop_recording() {
    pkill -INT -x wf-recorder 2>/dev/null || true
    rm -f "$PID_FILE"
    
    # Enviar notificación de finalización
    local latest_file
    latest_file=$(ls -t "$RECORDINGS_DIR"/*.mp4 2>/dev/null | head -n 1 || true)
    
    if [ -n "$latest_file" ]; then
        if command -v dunstify &>/dev/null; then
            dunstify -a "Grabador" -r 9988 -u normal \
                "🎬 Grabación Finalizada" \
                "Guardado en: $(basename "$latest_file")\nClick para abrir carpeta" \
                --action="open_folder,Abrir Carpeta"
        else
            notify-send -a "Grabador" "🎬 Grabación Finalizada" "Guardado en $RECORDINGS_DIR"
        fi
    else
        notify-send -a "Grabador" "⏹️ Grabación Detenida" "Grabación cancelada o finalizada"
    fi
}

start_recording() {
    local mode="${1:-area}"
    local with_audio="${2:-false}"
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local output_file="$RECORDINGS_DIR/Grabacion_${timestamp}.mp4"

    if ! command -v wf-recorder &>/dev/null; then
        notify-send -a "Grabador" "❌ Error" "wf-recorder no está instalado. Instálalo con: sudo pacman -S wf-recorder"
        exit 1
    fi

    local cmd=("wf-recorder" "-f" "$output_file" "-c" "libx264" "-p" "preset=veryfast" "-p" "crf=23")

    if [ "$with_audio" = "true" ] || [ "$with_audio" = "--audio" ]; then
        # Capturar audio del sistema mediante PipeWire/Pulse
        cmd+=("--audio")
    fi

    if [ "$mode" = "area" ]; then
        if ! command -v slurp &>/dev/null; then
            notify-send -a "Grabador" "❌ Error" "slurp no está instalado"
            exit 1
        fi

        local geometry
        geometry=$(slurp -d -b 1c1c1eaa -c ffffffff -s ffffff20 -w 1 2>/dev/null)
        if [ -z "$geometry" ]; then
            exit 0 # Usuario canceló selección
        fi
        cmd+=("-g" "$geometry")
    fi

    notify-send -a "Grabador" -r 9988 -u low "🔴 Grabando Pantalla..." "Presiona Mod+Alt+R para detener"

    "${cmd[@]}" &
    echo $! > "$PID_FILE"
}

# ── Selector de Acciones ────────────────────────────────────────
case "$1" in
    stop)
        if is_recording; then
            stop_recording
        fi
        ;;
    toggle)
        if is_recording; then
            stop_recording
        else
            start_recording "${2:-area}" "${3:-false}"
        fi
        ;;
    area)
        if is_recording; then
            stop_recording
        else
            start_recording "area" "${2:-false}"
        fi
        ;;
    screen|fullscreen)
        if is_recording; then
            stop_recording
        else
            start_recording "screen" "${2:-false}"
        fi
        ;;
    status)
        if is_recording; then
            echo "recording"
            exit 0
        else
            echo "idle"
            exit 1
        fi
        ;;
    *)
        if is_recording; then
            stop_recording
        else
            start_recording "area" "false"
        fi
        ;;
esac
