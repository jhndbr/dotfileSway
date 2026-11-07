pragma Singleton
import QtQuick
import Quickshell
import Quickshell.I3

Singleton {
    id: root

    readonly property var rawWorkspaces: I3.workspaces?.values || []

    // Sorted workspaces
    readonly property var workspaces: {
        const list = Array.from(rawWorkspaces);
        return list.sort((a, b) => {
            const numA = a.num !== undefined && a.num !== -1 ? a.num : 999;
            const numB = b.num !== undefined && b.num !== -1 ? b.num : 999;
            return numA - numB;
        });
    }

    // Active focused workspace
    readonly property var activeWorkspace: rawWorkspaces.find(ws => ws.focused === true) || null
    readonly property int activeWorkspaceNum: activeWorkspace?.num ?? 1
    readonly property string activeWorkspaceName: activeWorkspace?.name ?? "1"

    function changeWorkspace(target) {
        if (target === undefined || target === null) return;
        try {
            if (typeof target === "number") {
                I3.dispatch("workspace number " + target);
            } else if (typeof target === "object" && target.num !== undefined && target.num !== -1) {
                I3.dispatch("workspace number " + target.num);
            } else if (typeof target === "object" && target.name) {
                I3.dispatch("workspace \"" + target.name + "\"");
            } else {
                I3.dispatch("workspace " + target);
            }
        } catch (e) {
            console.warn("[SwayService] Failed to switch workspace:", e);
        }
    }

    function nextWorkspace() {
        try {
            I3.dispatch("workspace next_on_output");
        } catch (e) {
            console.warn("[SwayService] Failed next workspace:", e);
        }
    }

    function prevWorkspace() {
        try {
            I3.dispatch("workspace prev_on_output");
        } catch (e) {
            console.warn("[SwayService] Failed prev workspace:", e);
        }
    }

    function killActive() {
        try {
            I3.dispatch("kill");
        } catch (e) {
            console.warn("[SwayService] Failed kill active:", e);
        }
    }

    function exec(command) {
        try {
            I3.dispatch("exec " + command);
        } catch (e) {
            console.warn("[SwayService] Failed exec:", e);
        }
    }

    function exitSway() {
        try {
            I3.dispatch("exit");
        } catch (e) {
            console.warn("[SwayService] Failed exit sway:", e);
        }
    }
}
