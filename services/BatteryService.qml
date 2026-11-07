pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool available: false
    property int percent: 100
    property real percentage: percent / 100.0
    property string status: "Unknown"
    property bool isCharging: false
    property bool isPluggedIn: isCharging || status === "Full" || status === "Not charging"
    property bool isLow: available && percent <= 20 && !isCharging
    property bool isCritical: available && percent <= 10 && !isCharging

    Process {
        id: batProc
        command: ["sh", "-c", "cat /sys/class/power_supply/BAT*/capacity 2>/dev/null; cat /sys/class/power_supply/BAT*/status 2>/dev/null"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                if (text && text.trim().length > 0) {
                    const lines = text.trim().split("\n");
                    const cap = parseInt(lines[0], 10);
                    if (!isNaN(cap)) {
                        root.percent = cap;
                        root.percentage = Math.max(0.0, Math.min(1.0, cap / 100.0));
                        root.available = true;
                    }
                    if (lines.length > 1) {
                        root.status = lines[1].trim();
                        root.isCharging = (root.status === "Charging");
                    }
                }
            }
        }
    }

    Timer {
        id: pollTimer
        interval: 10000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            if (!batProc.running) {
                batProc.running = true;
            }
        }
    }

    readonly property string iconGlyph: {
        if (!available) return "󰂎";
        if (isCharging) return "󰂄";
        if (percent >= 90) return "󰁹";
        if (percent >= 80) return "󰂂";
        if (percent >= 70) return "󰂁";
        if (percent >= 60) return "󰂀";
        if (percent >= 50) return "󰁿";
        if (percent >= 40) return "󰁾";
        if (percent >= 30) return "󰁽";
        if (percent >= 20) return "󰁼";
        if (percent >= 10) return "󰁻";
        return "󰁺";
    }

    Component.onCompleted: {
        batProc.running = true;
    }
}
