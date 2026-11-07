pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool available: false
    property real brightness: 0.5
    property int brightnessPercent: Math.round(brightness * 100)

    signal brightnessUpdated(real val)

    Process {
        id: readProc
        command: ["sh", "-c", "cat /sys/class/backlight/*/brightness 2>/dev/null; cat /sys/class/backlight/*/max_brightness 2>/dev/null"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                if (text && text.trim().length > 0) {
                    const lines = text.trim().split("\n");
                    const cur = parseFloat(lines[0]);
                    const max = lines.length > 1 ? parseFloat(lines[1]) : 0;
                    if (!isNaN(cur) && !isNaN(max) && max > 0) {
                        const newBrightness = Math.max(0.05, Math.min(1.0, cur / max));
                        if (Math.abs(newBrightness - root.brightness) > 0.005) {
                            root.brightness = newBrightness;
                        }
                        root.available = true;
                    }
                }
            }
        }
    }

    Process {
        id: setProc
        running: false
        onExited: {
            readProc.running = true;
        }
    }

    function setBrightness(percentValue) {
        const clamped = Math.max(0.05, Math.min(1.0, percentValue));
        root.brightness = clamped;
        const targetPercent = Math.round(clamped * 100);
        setProc.command = ["brightnessctl", "s", targetPercent + "%"];
        setProc.running = true;
        root.brightnessUpdated(root.brightness);
    }

    function increaseBrightness(step) {
        const delta = step !== undefined ? step : 0.05;
        setBrightness(brightness + delta);
    }

    function decreaseBrightness(step) {
        const delta = step !== undefined ? step : 0.05;
        setBrightness(brightness - delta);
    }

    // Refresh every 8 seconds only when active
    Timer {
        interval: 8000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            if (!readProc.running && !setProc.running) {
                readProc.running = true;
            }
        }
    }

    Component.onCompleted: {
        readProc.running = true;
    }
}
