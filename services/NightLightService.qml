pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // El estado activo refleja directamente si el proceso wlsunset está corriendo
    readonly property alias active: sunsetProc.running
    property int temperature: 4000

    readonly property string wlsunsetBin: Quickshell.env("HOME") + "/.local/bin/wlsunset"

    Process {
        id: sunsetProc
        command: [
            root.wlsunsetBin,
            "-t", String(root.temperature),
            "-T", String(root.temperature + 1)
        ]
        running: false
    }

    Process {
        id: notifyProc
        running: false
    }

    Process {
        id: initCleanupProc
        running: false
    }

    function toggle() {
        if (!sunsetProc.running) {
            sunsetProc.running = true;

            notifyProc.command = [
                "sh", "-c",
                "which notify-send >/dev/null 2>&1 && notify-send -a 'SwayShell' -i 'preferences-desktop-display' 'Modo Nocturno Activado' 'Luz cálida (" + root.temperature + "K) para descanso visual.' || true"
            ];
            notifyProc.running = true;
        } else {
            sunsetProc.running = false;

            notifyProc.command = [
                "sh", "-c",
                "which notify-send >/dev/null 2>&1 && notify-send -a 'SwayShell' -i 'preferences-desktop-display' 'Modo Nocturno Desactivado' 'Temperatura normal (6500K) restaurada.' || true"
            ];
            notifyProc.running = true;
        }
    }

    Component.onCompleted: {
        // Limpieza única al iniciar la shell para evitar procesos huérfanos anteriores
        initCleanupProc.command = ["sh", "-c", "pkill -x wlsunset 2>/dev/null || true; pkill -9 -f gammastep 2>/dev/null || true"];
        initCleanupProc.running = true;
    }
}
