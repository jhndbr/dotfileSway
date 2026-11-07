pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import ".."

Singleton {
    id: root

    property var pinnedAppIds: [
        "org.gnome.Nautilus",
        "firefox-esr",
        "brave-browser",
        "foot",
        "dev.zed.Zed"
    ]

    FileView {
        id: dockStorage
        path: Quickshell.env("HOME") + "/.config/quickshell/swayshell/dock-apps.json"

        onLoaded: {
            const raw = dockStorage.text();
            if (!raw || !raw.trim()) return;
            try {
                const data = JSON.parse(raw);
                if (Array.isArray(data) && data.length > 0) {
                    root.pinnedAppIds = data;
                    Config.dockPinnedApps = data;
                }
            } catch (e) {
                console.warn("[DockService] Error parsing dock-apps.json:", e);
            }
        }

        onLoadFailed: error => {
            if (error == FileViewError.FileNotFound) {
                dockStorage.setText(JSON.stringify(root.pinnedAppIds, null, 2));
            }
        }
    }

    function savePins() {
        try {
            dockStorage.setText(JSON.stringify(pinnedAppIds, null, 2));
        } catch (e) {
            console.warn("[DockService] Error saving dock-apps.json:", e);
        }
    }

    function isPinned(appId) {
        if (!appId) return false;
        const target = appId.toLowerCase();
        return pinnedAppIds.some(id => id.toLowerCase() === target);
    }

    function togglePin(appId) {
        if (!appId) return;
        const target = appId.toLowerCase();
        if (isPinned(target)) {
            pinnedAppIds = pinnedAppIds.filter(id => id.toLowerCase() !== target);
        } else {
            pinnedAppIds = pinnedAppIds.concat([appId]);
        }
        Config.dockPinnedApps = pinnedAppIds;
        savePins();
    }

    function pinApp(appId) {
        if (!appId || isPinned(appId)) return;
        pinnedAppIds = pinnedAppIds.concat([appId]);
        Config.dockPinnedApps = pinnedAppIds;
        savePins();
    }

    function unpinApp(appId) {
        if (!appId) return;
        const target = appId.toLowerCase();
        pinnedAppIds = pinnedAppIds.filter(id => id.toLowerCase() !== target);
        Config.dockPinnedApps = pinnedAppIds;
        savePins();
    }

    function findDesktopEntry(appId) {
        if (!appId) return null;
        let entry = DesktopEntries.heuristicLookup(appId);
        if (entry) return entry;

        const apps = DesktopEntries.applications.values || [];
        const clean = appId.toLowerCase().replace(/[-_.]/g, "");
        for (let i = 0; i < apps.length; i++) {
            const a = apps[i];
            const aId = (a.id || "").toLowerCase().replace(/[-_.]/g, "");
            const aName = (a.name || "").toLowerCase().replace(/[-_.]/g, "");
            if (aId === clean || aName === clean || aId.includes(clean) || clean.includes(aId)) {
                return a;
            }
        }
        return null;
    }

    function getAppName(appId, entry) {
        if (entry && entry.name && entry.name.length > 0) return entry.name;
        if (!appId) return "Application";
        const parts = appId.split(".");
        let name = parts[parts.length - 1];
        if (name.toLowerCase() === "desktop") name = parts[parts.length - 2] || name;
        if (name.toLowerCase() === "nautilus") return "Archivos";
        if (name.toLowerCase() === "foot") return "Terminal";
        if (name.toLowerCase() === "zed") return "Zed";
        if (name.toLowerCase() === "firefox-esr" || name.toLowerCase() === "firefox") return "Firefox";
        if (name.toLowerCase().includes("brave")) return "Brave";
        return name.charAt(0).toUpperCase() + name.slice(1);
    }

    function getAppIcon(appId, entry) {
        if (entry && entry.icon && entry.icon.length > 0) return entry.icon;
        if (appId && appId.length > 0) return appId;
        return "application-x-executable";
    }

    // Dynamic aggregated dock items (both pinned & open)
    readonly property var items: {
        const result = [];
        const liveToplevels = ToplevelManager.toplevels?.values || [];
        const activeTop = ToplevelManager.activeToplevel;

        // 1. Process Pinned Apps first
        for (let i = 0; i < pinnedAppIds.length; i++) {
            const rawId = pinnedAppIds[i];
            const lowerId = rawId.toLowerCase();
            const entry = findDesktopEntry(rawId);

            // Find matching toplevels
            const matchingToplevels = liveToplevels.filter(t => {
                const tId = (t.appId || "").toLowerCase();
                return tId === lowerId ||
                       (tId.length > 0 && lowerId.includes(tId)) ||
                       (tId.length > 0 && tId.includes(lowerId));
            });

            const hasActive = matchingToplevels.some(t => t === activeTop || t.activated === true);

            result.push({
                appId: rawId,
                name: getAppName(rawId, entry),
                icon: getAppIcon(rawId, entry),
                isPinned: true,
                isRunning: matchingToplevels.length > 0,
                isFocused: hasActive,
                toplevels: matchingToplevels,
                desktopEntry: entry
            });
        }

        // 2. Process running unpinned apps
        for (let j = 0; j < liveToplevels.length; j++) {
            const top = liveToplevels[j];
            const rawId = top.appId || "unknown";
            const lowerId = rawId.toLowerCase();

            // Check if already covered by an entry in result
            let alreadyCovered = false;
            for (let k = 0; k < result.length; k++) {
                if (result[k].toplevels && result[k].toplevels.includes(top)) {
                    alreadyCovered = true;
                    break;
                }
            }
            if (alreadyCovered) continue;

            // Check if unpinned entry for this appId already exists in result
            let existing = result.find(item => !item.isPinned && item.appId.toLowerCase() === lowerId);
            if (existing) {
                existing.toplevels.push(top);
                if (top === activeTop || top.activated === true) existing.isFocused = true;
            } else {
                const entry = findDesktopEntry(rawId);
                const isFocused = top === activeTop || top.activated === true;
                result.push({
                    appId: rawId,
                    name: getAppName(rawId, entry),
                    icon: getAppIcon(rawId, entry),
                    isPinned: false,
                    isRunning: true,
                    isFocused: isFocused,
                    toplevels: [top],
                    desktopEntry: entry
                });
            }
        }

        return result;
    }

    function activateApp(item) {
        if (!item) return;
        if (item.toplevels && item.toplevels.length > 0) {
            const activeIdx = item.toplevels.findIndex(t => t.activated === true || t === ToplevelManager.activeToplevel);
            const nextIdx = (activeIdx + 1) % item.toplevels.length;
            const target = item.toplevels[nextIdx];
            if (target && typeof target.activate === "function") {
                target.activate();
            }
        } else if (item.desktopEntry) {
            try {
                if (typeof item.desktopEntry.execute === "function") {
                    item.desktopEntry.execute();
                } else if (item.desktopEntry.commandLine) {
                    SwayService.exec(item.desktopEntry.commandLine);
                }
            } catch (e) {
                console.warn("[DockService] Failed to execute desktop entry:", e);
                SwayService.exec(item.appId);
            }
        } else {
            SwayService.exec(item.appId);
        }
    }

    function launchNewInstance(item) {
        if (!item) return;
        if (item.desktopEntry) {
            try {
                if (typeof item.desktopEntry.execute === "function") {
                    item.desktopEntry.execute();
                    return;
                }
            } catch (e) {}
        }
        SwayService.exec(item.appId);
    }

    function closeApp(item) {
        if (!item || !item.toplevels) return;
        for (let i = 0; i < item.toplevels.length; i++) {
            const t = item.toplevels[i];
            if (t && typeof t.close === "function") {
                t.close();
            }
        }
    }
}
