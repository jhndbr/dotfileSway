pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }

    readonly property bool ready: Pipewire.ready
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    readonly property real volume: sink?.audio.volume ?? 0
    readonly property int volumePercent: Math.round(volume * 100)
    readonly property bool muted: sink?.audio.muted ?? false

    readonly property real micVolume: source?.audio.volume ?? 0
    readonly property bool micMuted: source?.audio.muted ?? false

    readonly property string deviceName: sink?.description || sink?.name || "Default Audio"

    signal volumeUpdated(real newVolume, bool isMuted)

    onVolumeChanged: {
        volumeUpdated(volume, muted);
    }

    onMutedChanged: {
        volumeUpdated(volume, muted);
    }

    function setVolume(val) {
        if (!sink || !sink.audio) return;
        const clamped = Math.max(0.0, Math.min(1.0, val));
        sink.audio.volume = clamped;
    }

    function increaseVolume(step) {
        const delta = step !== undefined ? step : 0.05;
        setVolume(volume + delta);
    }

    function decreaseVolume(step) {
        const delta = step !== undefined ? step : 0.05;
        setVolume(volume - delta);
    }

    function toggleMute() {
        if (!sink || !sink.audio) return;
        sink.audio.muted = !sink.audio.muted;
    }

    function toggleMicMute() {
        if (!source || !source.audio) return;
        source.audio.muted = !source.audio.muted;
    }
}
