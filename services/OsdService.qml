pragma Singleton
import QtQuick
import Quickshell
import ".."

Singleton {
    id: root

    property bool showOsd: false
    property string currentType: "volume" // "volume" | "brightness"
    property real currentValue: 0.0
    property bool currentMuted: false

    readonly property string iconGlyph: {
        if (currentType === "volume") {
            if (currentMuted) return "󰖁";
            if (currentValue >= 0.7) return "󰕾";
            if (currentValue >= 0.3) return "󰖀";
            if (currentValue > 0) return "󰕿";
            return "󰖁";
        } else {
            if (currentValue >= 0.7) return "󰃠";
            if (currentValue >= 0.3) return "󰃟";
            return "󰃞";
        }
    }

    Timer {
        id: hideTimer
        interval: Config.osdTimeout
        repeat: false
        onTriggered: {
            root.showOsd = false;
        }
    }

    function triggerVolume(val, isMuted) {
        if (!Config.showVolumeOsd) return;
        currentType = "volume";
        currentValue = val;
        currentMuted = isMuted;
        showOsd = true;
        hideTimer.restart();
    }

    function triggerBrightness(val) {
        if (!Config.showBrightnessOsd || !BrightnessService.available) return;
        currentType = "brightness";
        currentValue = val;
        currentMuted = false;
        showOsd = true;
        hideTimer.restart();
    }

    Connections {
        target: AudioService
        function onVolumeUpdated(newVol, isMuted) {
            root.triggerVolume(newVol, isMuted);
        }
    }

    Connections {
        target: BrightnessService
        function onBrightnessUpdated(val) {
            root.triggerBrightness(val);
        }
    }
}
