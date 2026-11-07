pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool connected: false
    property string networkType: "none" // "wifi" | "ethernet" | "none"
    property string connectionName: ""
    property bool wifiEnabled: true

    Process {
        id: wifiToggleProc
        running: false
        onExited: {
            if (!netProc.running) netProc.running = true;
        }
    }

    function toggleWifi() {
        wifiEnabled = !wifiEnabled;
        wifiToggleProc.command = ["nmcli", "radio", "wifi", wifiEnabled ? "on" : "off"];
        wifiToggleProc.running = true;
    }

    function openEditor() {
        Quickshell.execDetached(["nm-connection-editor"]);
    }

    readonly property string iconGlyph: {
        if (!connected) return "󰤭";
        if (networkType === "wifi") return "󰤨";
        if (networkType === "ethernet") return "󰈀";
        return "󰌘";
    }

    Process {
        id: netProc
        command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "device"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                let isConn = false;
                let detectedType = "none";
                let detectedName = "";

                for (let i = 0; i < lines.length; i++) {
                    const parts = lines[i].split(":");
                    if (parts.length >= 3) {
                        const type = parts[0].trim();
                        const state = parts[1].trim();
                        const conn = parts[2].trim();

                        if (state === "connected") {
                            isConn = true;
                            if (type === "wifi") {
                                detectedType = "wifi";
                                detectedName = conn;
                                break;
                            } else if (type === "ethernet") {
                                detectedType = "ethernet";
                                detectedName = conn || "Ethernet";
                            }
                        }
                    }
                }

                root.connected = isConn;
                root.networkType = detectedType;
                root.connectionName = detectedName;
            }
        }
    }

    Timer {
        interval: 30000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            if (!netProc.running) {
                netProc.running = true;
            }
        }
    }
}
