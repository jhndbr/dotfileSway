pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool active: false

    Process {
        id: inhibitorProc
        command: [
            "systemd-inhibit",
            "--what=idle:sleep:handle-lid-switch",
            "--who=SwayShell",
            "--why=Caffeine Mode Active",
            "sleep", "infinity"
        ]
        running: false
    }

    Process {
        id: cmdProc
        running: false
    }

    function toggle() {
        active = !active;
        if (active) {
            inhibitorProc.running = true;
            cmdProc.command = [
                "sh", "-c",
                "pkill -STOP swayidle 2>/dev/null || true; which notify-send >/dev/null 2>&1 && notify-send -a 'SwayShell' -i 'preferences-desktop-screensaver' 'Modo Cafeína Activado' 'La pantalla permanecerá encendida sin suspenderse.' || true"
            ];
            cmdProc.running = true;
        } else {
            inhibitorProc.running = false;
            cmdProc.command = [
                "sh", "-c",
                "pkill -CONT swayidle 2>/dev/null || true; which notify-send >/dev/null 2>&1 && notify-send -a 'SwayShell' -i 'preferences-desktop-screensaver' 'Modo Cafeína Desactivado' 'Temporizador normal de reposo restaurado.' || true"
            ];
            cmdProc.running = true;
        }
    }
}
