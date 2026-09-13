#!/usr/bin/env bash
# Helper script para invocar acciones de Quickshell vía IPC

ACTION="${1:-launcher}"

case "$ACTION" in
    launcher)
        if ! quickshell ipc call shell toggleLauncher 2>/dev/null; then
            if ! pgrep -x quickshell >/dev/null; then
                quickshell &
                sleep 0.4
                quickshell ipc call shell toggleLauncher 2>/dev/null || true
            fi
        fi
        ;;
    power)
        if ! quickshell ipc call shell togglePower 2>/dev/null; then
            if ! pgrep -x quickshell >/dev/null; then
                quickshell &
                sleep 0.4
                quickshell ipc call shell togglePower 2>/dev/null || true
            fi
        fi
        ;;
    *)
        echo "Uso: $0 [launcher|power]"
        exit 1
        ;;
esac
