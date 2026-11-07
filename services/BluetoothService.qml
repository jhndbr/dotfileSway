pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import ".."

Singleton {
    id: root

    property bool available: false
    property bool powered: false
    property string alias: ""

    // Read Bluetooth controller status
    Process {
        id: statusProc
        command: ["bluetoothctl", "show"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                if (text && text.trim().length > 0 && !text.includes("No default controller")) {
                    root.available = true;
                    root.powered = text.includes("Powered: yes");
                    const m = text.match(/Alias:\s+(.*)/);
                    if (m && m[1]) root.alias = m[1].trim();
                } else {
                    root.available = false;
                    root.powered = false;
                }
            }
        }
    }

    // Toggle Bluetooth power
    Process {
        id: toggleProc
        running: false
        onExited: {
            root.refresh();
        }
    }

    function refresh() {
        if (!statusProc.running) {
            statusProc.running = true;
        }
    }

    function togglePower() {
        toggleProc.command = ["bluetoothctl", "power", powered ? "off" : "on"];
        toggleProc.running = true;
        root.powered = !root.powered;
    }

    function openManager() {
        Quickshell.execDetached(["sh", "-c", "blueman-manager || blueberry || gnome-control-center bluetooth || true"]);
    }

    Timer {
        interval: 30000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
