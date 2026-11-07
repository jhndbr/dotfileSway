pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    readonly property var players: Mpris.players.values
    readonly property var activePlayer: {
        const playing = players.find(p => p.playbackState === MprisPlaybackState.Playing);
        if (playing) return playing;
        return players.length > 0 ? players[0] : null;
    }

    readonly property bool hasPlayer: activePlayer !== null && (trackTitle.length > 0 || trackArtist.length > 0)
    readonly property bool isPlaying: activePlayer?.playbackState === MprisPlaybackState.Playing
    readonly property string identity: activePlayer?.identity ?? ""
    readonly property string trackTitle: activePlayer?.trackTitle ?? ""
    readonly property string trackArtist: {
        const a = activePlayer?.trackArtist;
        if (Array.isArray(a)) return a.join(", ");
        return a ?? "";
    }
    readonly property string trackAlbum: activePlayer?.trackAlbum ?? ""
    readonly property string rawArtUrl: activePlayer?.trackArtUrl ?? ""

    readonly property string resolvedArtUrl: {
        const url = rawArtUrl;
        if (!url || url.length === 0) return "";
        if (url.startsWith("file://") || url.startsWith("http://") || url.startsWith("https://") || url.startsWith("data:")) return url;
        if (url.startsWith("/")) return "file://" + url;
        return url;
    }
    readonly property bool hasArt: resolvedArtUrl.length > 0

    // Position & Length in seconds
    readonly property real rawPosition: activePlayer?.position ?? 0
    readonly property real rawLength: activePlayer?.length ?? 0

    readonly property real positionSec: rawPosition > 100000 ? (rawPosition / 1000000) : rawPosition
    readonly property real lengthSec: rawLength > 100000 ? (rawLength / 1000000) : rawLength

    readonly property real progress: lengthSec > 0 ? Math.max(0.0, Math.min(1.0, positionSec / lengthSec)) : 0

    function formatTime(sec) {
        if (!sec || isNaN(sec) || sec <= 0) return "0:00";
        const total = Math.floor(sec);
        const m = Math.floor(total / 60);
        const s = total % 60;
        return m + ":" + (s < 10 ? "0" : "") + s;
    }

    readonly property string positionFormatted: formatTime(positionSec)
    readonly property string lengthFormatted: formatTime(lengthSec)

    // Player capabilities
    readonly property bool canGoNext: activePlayer?.canGoNext ?? true
    readonly property bool canGoPrevious: activePlayer?.canGoPrevious ?? true
    readonly property bool canControl: activePlayer?.canControl ?? true
    readonly property bool canSeek: activePlayer?.canSeek ?? false
    readonly property real volume: activePlayer?.volume ?? 1.0

    function playPause() {
        if (!activePlayer) return;
        try {
            if (typeof activePlayer.togglePlaying === "function") {
                activePlayer.togglePlaying();
            } else if (isPlaying && typeof activePlayer.pause === "function") {
                activePlayer.pause();
            } else if (typeof activePlayer.play === "function") {
                activePlayer.play();
            }
        } catch (e) {
            console.warn("[MprisService] Error toggling play/pause:", e);
        }
    }

    function next() {
        if (activePlayer && typeof activePlayer.next === "function") {
            try { activePlayer.next(); } catch (e) {}
        }
    }

    function previous() {
        if (activePlayer && typeof activePlayer.previous === "function") {
            try { activePlayer.previous(); } catch (e) {}
        }
    }

    function seek(ratio) {
        if (!activePlayer || lengthSec <= 0) return;
        const targetSec = Math.max(0.1, Math.min(ratio * lengthSec, lengthSec * 0.99));
        try {
            if (activePlayer.canSeek) {
                activePlayer.position = targetSec;
            } else if (typeof activePlayer.onSeek === "function") {
                const targetPos = rawLength > 100000 ? (targetSec * 1000000) : targetSec;
                activePlayer.onSeek(Math.round(targetPos));
            } else if (typeof activePlayer.seek === "function") {
                const diff = (targetSec - positionSec);
                const diffPos = rawLength > 100000 ? (diff * 1000000) : diff;
                activePlayer.seek(diffPos);
            }
        } catch (e) {
            console.warn("[MprisService] Error seeking:", e);
        }
    }

    function setVolume(val) {
        if (!activePlayer) return;
        activePlayer.volume = Math.max(0.0, Math.min(1.0, val));
    }

    // Refresh position periodically when playing
    Timer {
        interval: 1000
        repeat: true
        running: root.isPlaying
        onTriggered: {
            if (root.activePlayer && typeof root.activePlayer.positionChanged === "function") {
                root.activePlayer.positionChanged();
            }
        }
    }
}
