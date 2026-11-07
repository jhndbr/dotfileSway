pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var entries: []
    property bool isLoading: false

    signal entriesUpdated()

    Process {
        id: listProc
        command: ["cliphist", "list"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                root.isLoading = false;
                const lines = text.trim().split("\n");
                const parsed = [];
                for (let i = 0; i < lines.length; i++) {
                    const line = lines[i];
                    if (!line || line.length === 0) continue;

                    const tabIdx = line.indexOf("\t");
                    let id = "";
                    let content = line;
                    if (tabIdx !== -1) {
                        id = line.substring(0, tabIdx).trim();
                        content = line.substring(tabIdx + 1);
                    }

                    const isImg = /\[\[.*binary data.*\d+x\d+.*\]\]/.test(content);
                    parsed.push({
                        id: id,
                        text: isImg ? "[Image Data]" : content,
                        raw: line,
                        isImage: isImg
                    });
                }
                root.entries = parsed;
                root.entriesUpdated();
            }
        }
    }

    Process {
        id: copyProc
        running: false
    }

    Process {
        id: delProc
        running: false
        onExited: {
            root.refresh();
        }
    }

    Process {
        id: wipeProc
        command: ["cliphist", "wipe"]
        running: false
        onExited: {
            root.entries = [];
            root.entriesUpdated();
        }
    }

    function refresh() {
        if (!listProc.running) {
            root.isLoading = true;
            listProc.running = true;
        }
    }

    function copy(entry) {
        if (!entry) return;
        const raw = typeof entry === "object" ? entry.raw : entry;
        // Escape single quotes for bash
        const escaped = raw.replace(/'/g, "'\\''");
        copyProc.command = ["bash", "-c", "printf '%s' '" + escaped + "' | cliphist decode | wl-copy"];
        copyProc.running = true;
    }

    function deleteEntry(entry) {
        if (!entry) return;
        const raw = typeof entry === "object" ? entry.raw : entry;
        const escaped = raw.replace(/'/g, "'\\''");
        delProc.command = ["bash", "-c", "printf '%s' '" + escaped + "' | cliphist delete"];
        delProc.running = true;
    }

    function wipe() {
        wipeProc.running = true;
    }

    Component.onCompleted: {
        refresh();
    }
}
