import QtQuick
import Quickshell
import Quickshell.Io
import "."

ShellRoot {
    id: root

    // Métodos globales accesibles desde componentes hijos
    function toggleLauncher() {
        launcher.toggle()
    }

    function togglePower() {
        powerMenu.toggle()
    }

    // Interfaz IPC para control desde Sway y scripts de terminal
    // Uso: quickshell ipc call shell toggleLauncher
    //      quickshell ipc call shell togglePower
    IpcHandler {
        target: "shell"

        function toggleLauncher() {
            launcher.toggle()
        }

        function togglePower() {
            powerMenu.toggle()
        }
    }

    // Barra superior
    Bar {
        id: bar
    }

    // Lanzador de aplicaciones
    Launcher {
        id: launcher
    }

    // Servidor y popups de notificaciones
    NotificationPopup {
        id: notifications
    }

    // Menú de apagado y control del sistema
    PowerMenu {
        id: powerMenu
    }
}
