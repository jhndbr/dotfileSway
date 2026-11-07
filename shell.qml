//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.I3
import Quickshell.Io

import "./services"
import "./windows"
import "./modules/aichat" as AiChat
import "."

ShellRoot {
    id: root

    // Central Theme initialization
    Component.onCompleted: {
        Theme.activePreset = Config.activeTheme;
        console.log("[SwayShell] Minimalist macOS-style Quickshell for Sway initialized with theme:", Config.activeTheme);
    }

    // Top macOS Status Bar on every monitor
    Variants {
        model: Quickshell.screens

        delegate: BarWindow {
            isControlCenterOpen: ccModal.isOpen
            isCalendarOpen: calendarModal.isOpen
            onToggleLauncher: launcherModal.isOpen = !launcherModal.isOpen
            onToggleSession: sessionModal.isOpen = !sessionModal.isOpen
            onToggleCalendar: calendarModal.isOpen = !calendarModal.isOpen
            onToggleClipboard: clipModal.isOpen = !clipModal.isOpen
            onToggleControlCenter: ccModal.isOpen = !ccModal.isOpen
            onToggleAiChat: aiChatModal.toggle()
            onToggleMedia: mediaModal.isOpen = !mediaModal.isOpen
        }
    }

    // Bottom macOS Dock on every monitor
    Variants {
        model: Quickshell.screens

        delegate: DockWindow {
            onToggleLauncher: launcherModal.isOpen = !launcherModal.isOpen
        }
    }

    // macOS Control Center Modal
    ControlCenterModal {
        id: ccModal
    }

    // Centered Spotlight Application Launcher
    AppLauncher {
        id: launcherModal
    }

    // Clipboard History Modal
    ClipboardModal {
        id: clipModal
    }

    // Power / Session Control Menu
    SessionModal {
        id: sessionModal
    }

    // Toast Notifications Popup
    NotificationPopup {
        id: notifModal
    }

    // On-Screen Display (Volume & Brightness)
    OsdWindow {
        id: osdModal
    }

    // Minimal Dropdown Calendar
    CalendarModal {
        id: calendarModal
    }

    // Antigravity AI Gemini CLI Chat Overlay
    AiChat.Chat {
        id: aiChatModal
    }

    // End4-style Floating Media Controls Modal
    MediaModal {
        id: mediaModal
    }

    // ==========================================
    // IPC Handlers for Sway keybindings & scripts
    // e.g. quickshell ipc call launcher toggle
    // ==========================================

    IpcHandler {
        target: "controlcenter"

        function toggle(): void {
            ccModal.isOpen = !ccModal.isOpen;
        }
        function open(): void {
            ccModal.isOpen = true;
        }
        function close(): void {
            ccModal.isOpen = false;
        }
    }

    IpcHandler {
        target: "dock"

        function toggle(): void {
            Config.dockEnabled = !Config.dockEnabled;
        }
        function autohide(): void {
            Config.dockAutoHide = !Config.dockAutoHide;
        }
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            launcherModal.isOpen = !launcherModal.isOpen;
        }
        function open(): void {
            launcherModal.isOpen = true;
        }
        function close(): void {
            launcherModal.isOpen = false;
        }
    }

    IpcHandler {
        target: "session"

        function toggle(): void {
            sessionModal.isOpen = !sessionModal.isOpen;
        }
        function open(): void {
            sessionModal.isOpen = true;
        }
        function close(): void {
            sessionModal.isOpen = false;
        }
    }

    IpcHandler {
        target: "calendar"

        function toggle(): void {
            calendarModal.isOpen = !calendarModal.isOpen;
        }
        function open(): void {
            calendarModal.isOpen = true;
        }
        function close(): void {
            calendarModal.isOpen = false;
        }
    }

    IpcHandler {
        target: "clipboard"

        function toggle(): void {
            clipModal.isOpen = !clipModal.isOpen;
        }
        function open(): void {
            clipModal.isOpen = true;
        }
        function close(): void {
            clipModal.isOpen = false;
        }
        function wipe(): void {
            ClipboardService.wipe();
        }
    }

    IpcHandler {
        target: "aichat"

        function toggle(): void {
            aiChatModal.toggle();
        }
        function open(): void {
            aiChatModal.show();
        }
        function close(): void {
            aiChatModal.hide();
        }
    }

    IpcHandler {
        target: "screenshot"

        function region(): void {
            ScreenshotService.captureRegion();
        }
        function fullscreen(): void {
            ScreenshotService.captureFullscreen();
        }
        function window(): void {
            ScreenshotService.captureWindow();
        }
    }

    IpcHandler {
        target: "wallpaper"

        function next(): void {
            WallpaperService.next();
        }
        function prev(): void {
            WallpaperService.prev();
        }
        function random(): void {
            WallpaperService.random();
        }
        function select(): void {
            WallpaperService.select();
        }
        function set(path: string): void {
            WallpaperService.set(path);
        }
        function restore(): void {
            WallpaperService.restore();
        }
    }

    IpcHandler {
        target: "audio"

        function raise(): void {
            AudioService.increaseVolume(0.05);
        }
        function lower(): void {
            AudioService.decreaseVolume(0.05);
        }
        function mute(): void {
            AudioService.toggleMute();
        }
        function muteMic(): void {
            AudioService.toggleMicMute();
        }
    }

    IpcHandler {
        target: "brightness"

        function raise(): void {
            BrightnessService.increaseBrightness(0.05);
        }
        function lower(): void {
            BrightnessService.decreaseBrightness(0.05);
        }
    }

    IpcHandler {
        target: "media"

        function toggle(): void {
            mediaModal.isOpen = !mediaModal.isOpen;
        }
        function open(): void {
            mediaModal.isOpen = true;
        }
        function close(): void {
            mediaModal.isOpen = false;
        }
        function playPause(): void {
            MprisService.playPause();
        }
        function next(): void {
            MprisService.next();
        }
        function previous(): void {
            MprisService.previous();
        }
    }
}
