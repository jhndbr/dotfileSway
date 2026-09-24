#!/usr/bin/env python3
import json
import html
import os
import subprocess
import sys

STATE_FILE = "/tmp/waybar_media_scroll.json"
MAX_CHARS = 15
PAUSE_TICKS = 3

def get_player_icon(player_name):
    p_lower = player_name.lower()
    if "spotify" in p_lower:
        return "󰓇"
    elif "strawberry" in p_lower:
        return "󰎆"
    elif "brave" in p_lower:
        return "󰊯"
    elif any(b in p_lower for b in ["chrome", "chromium", "edge", "vivaldi"]):
        return "󰊯"
    elif any(f in p_lower for f in ["firefox", "zen", "librewolf", "floorp", "waterfox"]):
        return "󰈹"
    elif "mpv" in p_lower or "celluloid" in p_lower:
        return "󰎆"
    elif "vlc" in p_lower:
        return "󰕼"
    elif "cider" in p_lower or "apple" in p_lower:
        return "󰀥"
    elif "amberol" in p_lower or "lollypop" in p_lower or "audacious" in p_lower or "rhythmbox" in p_lower:
        return "󰎇"
    elif "tidal" in p_lower or "music" in p_lower:
        return "󰐃"
    elif "discord" in p_lower or "vesktop" in p_lower:
        return "󰙯"
    elif "telegram" in p_lower:
        return "󰒓"
    elif "steam" in p_lower or "game" in p_lower or "cs2" in p_lower or "counter-strike" in p_lower:
        return "󰓓"
    elif "meet" in p_lower or "zoom" in p_lower or "call" in p_lower or "teams" in p_lower:
        return "󰕾"
    return "󰎆"

def load_scroll_state():
    try:
        if os.path.exists(STATE_FILE):
            with open(STATE_FILE, "r") as f:
                return json.load(f)
    except Exception:
        pass
    return {"track": "", "offset": 0, "pause": PAUSE_TICKS}

def save_scroll_state(state):
    try:
        with open(STATE_FILE, "w") as f:
            json.dump(state, f)
    except Exception:
        pass

def get_pulse_audio_stream():
    """Fallback universal para cuando hay audio en el sistema (ej. Google Meet, juegos, llamadas) pero sin soporte MPRIS."""
    try:
        res = subprocess.run(["pactl", "list", "sink-inputs"], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
        out = res.stdout
        if not out:
            return None
        blocks = out.split("Sink Input #")
        for b in blocks[1:]:
            lines = b.splitlines()
            corked = False
            muted = False
            app_name = ""
            media_title = ""
            media_name = ""
            binary = ""
            for line in lines:
                line = line.strip()
                if line.startswith("Corked:"):
                    corked = "yes" in line.lower()
                elif line.startswith("Mute:"):
                    muted = "yes" in line.lower()
                elif "application.name =" in line:
                    app_name = line.split("=")[1].strip().strip("\"")
                elif "media.title =" in line:
                    media_title = line.split("=")[1].strip().strip("\"")
                elif "media.name =" in line:
                    media_name = line.split("=")[1].strip().strip("\"")
                elif "application.process.binary =" in line:
                    binary = line.split("=")[1].strip().strip("\"")

            if not corked and not muted:
                app_clean = app_name or binary or ""
                if app_clean.lower() == "cava":
                    continue
                title_clean = media_title or media_name or ""
                if title_clean.lower() in ["playback", "audio stream", "altsink", "bell-window-system"]:
                    title_clean = "Audio"
                return {
                    "app": app_clean or "Audio",
                    "title": title_clean or "Audio",
                    "status": "Playing"
                }
    except Exception:
        pass
    return None

def get_media_info():
    try:
        # 1. Intentar consultar todos los reproductores vía MPRIS (playerctl)
        cmd = [
            "playerctl",
            "-a",
            "metadata",
            "--format",
            "{{playerName}}::{{status}}::{{artist}}::{{title}}::{{album}}"
        ]
        res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
        out = res.stdout.strip()
        lines = [l.strip() for l in out.splitlines() if l.strip()] if out else []

        target_line = None
        # Priorizar el reproductor MPRIS que esté activamente en reproducción (Playing)
        for line in lines:
            parts = line.split("::")
            if len(parts) > 1 and parts[1].lower() == "playing":
                target_line = line
                break

        player_name = ""
        status = ""
        artist = ""
        title = ""
        album = ""

        if target_line:
            parts = target_line.split("::")
            player_name = parts[0] if len(parts) > 0 and parts[0] else "Media"
            status = parts[1] if len(parts) > 1 and parts[1] else "Playing"
            artist = parts[2].strip() if len(parts) > 2 else ""
            title = parts[3].strip() if len(parts) > 3 else ""
            album = parts[4].strip() if len(parts) > 4 else ""
        else:
            # 2. Corrección General: si no hay reproductor MPRIS Playing, comprobar si hay audio activo en PipeWire/PulseAudio (Google Meet, juegos, navegador sin MPRIS)
            pulse = get_pulse_audio_stream()
            if pulse:
                player_name = pulse["app"]
                status = "Playing"
                artist = pulse["app"]
                title = pulse["title"] if pulse["title"] != "Audio" else "Audio en vivo"
                album = ""
            elif lines:
                # 3. Si no hay audio sonando pero hay reproductores pausados, priorizar reproductores dedicados de música
                priority_players = ["strawberry", "spotify", "cider", "amberol", "mpv", "vlc", "audacious", "rhythmbox", "tidal"]
                fallback_line = None
                for line in lines:
                    parts = line.split("::")
                    p_name = parts[0].lower() if len(parts) > 0 else ""
                    if any(p in p_name for p in priority_players):
                        fallback_line = line
                        break
                if not fallback_line:
                    fallback_line = lines[0]

                parts = fallback_line.split("::")
                player_name = parts[0] if len(parts) > 0 and parts[0] else "Media"
                status = parts[1] if len(parts) > 1 and parts[1] else "Paused"
                artist = parts[2].strip() if len(parts) > 2 else ""
                title = parts[3].strip() if len(parts) > 3 else ""
                album = parts[4].strip() if len(parts) > 4 else ""
            else:
                # 4. Sin ningún audio ni reproductor abierto: estado base en reposo (mantiene la píldora unificada)
                return {
                    "text": "󰝚  En reposo",
                    "tooltip": "Sin reproducción de audio activa",
                    "class": "stopped",
                    "alt": "Stopped"
                }

        p_icon = get_player_icon(player_name)

        if artist and title and artist.lower() != title.lower():
            track = f"{artist} — {title}"
        elif title:
            track = title
        elif artist:
            track = artist
        else:
            track = "Reproduciendo"

        # Lógica de Marquesina / Desplazamiento
        state = load_scroll_state()
        prev_track = state.get("track", "")
        offset = state.get("offset", 0)
        pause = state.get("pause", PAUSE_TICKS)

        if track != prev_track:
            offset = 0
            pause = PAUSE_TICKS
            prev_track = track

        if len(track) <= MAX_CHARS:
            track_disp = track
            offset = 0
            pause = PAUSE_TICKS
        else:
            sep = "   •   "
            full_cycle = track + sep
            cycle_len = len(full_cycle)

            if status.lower() == "paused":
                track_disp = (full_cycle * 2)[offset:offset + MAX_CHARS]
            else:
                if pause > 0:
                    track_disp = (full_cycle * 2)[offset:offset + MAX_CHARS]
                    pause -= 1
                else:
                    track_disp = (full_cycle * 2)[offset:offset + MAX_CHARS]
                    offset = (offset + 1) % cycle_len
                    if offset == 0:
                        pause = PAUSE_TICKS

        save_scroll_state({"track": prev_track, "offset": offset, "pause": pause})

        text = f"{p_icon}  {track_disp}"

        tooltip = (
            f"<b>{html.escape(player_name.capitalize())}</b> ({html.escape(status)})\n"
            f"<b>Artista / Fuente:</b> {html.escape(artist or 'Desconocido')}\n"
            f"<b>Título:</b> {html.escape(title or 'Sin título')}"
        )
        if album:
            tooltip += f"\n<b>Álbum:</b> {html.escape(album)}"
        tooltip += "\n\n<i>󰐊 Clic: Play/Pausa · 󰒭 Clic der: Siguiente · 󰒮 Clic medio: Anterior</i>"

        return {
            "text": text,
            "tooltip": tooltip,
            "class": status,
            "alt": status
        }
    except Exception as e:
        return {
            "text": "󰝚  En reposo",
            "tooltip": str(e),
            "class": "stopped",
            "alt": "Stopped"
        }

if __name__ == "__main__":
    info = get_media_info()
    sys.stdout.write(json.dumps(info) + "\n")
