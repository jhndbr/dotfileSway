pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    Process {
        id: shotProc
        running: false
    }

    function captureRegion() {
        shotProc.command = [Quickshell.env("HOME") + "/.config/quickshell/swayshell/scripts/screenshot.sh", "region"];
        shotProc.running = true;
    }

    function captureFullscreen() {
        shotProc.command = [Quickshell.env("HOME") + "/.config/quickshell/swayshell/scripts/screenshot.sh", "fullscreen"];
        shotProc.running = true;
    }

    function captureWindow() {
        shotProc.command = [Quickshell.env("HOME") + "/.config/quickshell/swayshell/scripts/screenshot.sh", "window"];
        shotProc.running = true;
    }
}
