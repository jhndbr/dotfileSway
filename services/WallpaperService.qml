pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    Process {
        id: wallProc
        running: false
    }

    function set(path: string): void {
        wallProc.command = [Quickshell.env("HOME") + "/.config/quickshell/swayshell/scripts/set-wallpaper.sh", path];
        wallProc.running = true;
    }

    function next(): void {
        wallProc.command = [Quickshell.env("HOME") + "/.config/quickshell/swayshell/scripts/set-wallpaper.sh", "next"];
        wallProc.running = true;
    }

    function prev(): void {
        wallProc.command = [Quickshell.env("HOME") + "/.config/quickshell/swayshell/scripts/set-wallpaper.sh", "prev"];
        wallProc.running = true;
    }

    function random(): void {
        wallProc.command = [Quickshell.env("HOME") + "/.config/quickshell/swayshell/scripts/set-wallpaper.sh", "random"];
        wallProc.running = true;
    }

    function select(): void {
        wallProc.command = [Quickshell.env("HOME") + "/.config/quickshell/swayshell/scripts/set-wallpaper.sh", "select"];
        wallProc.running = true;
    }

    function restore(): void {
        wallProc.command = [Quickshell.env("HOME") + "/.config/quickshell/swayshell/scripts/set-wallpaper.sh", "restore"];
        wallProc.running = true;
    }
}
