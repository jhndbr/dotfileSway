#!/usr/bin/env python3
import json
import html
import subprocess
import sys

def get_player_info():
    try:
        cmd = [
            "playerctl",
            "metadata",
            "--format",
            "{{playerName}}::{{status}}::{{artist}}::{{title}}::{{album}}"
        ]
        res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
        out = res.stdout.strip()
        if not out:
            return {"text": "", "tooltip": "Ningún reproductor activo", "class": "stopped", "alt": "Stopped"}
        
        parts = out.split("::")
        player_name = parts[0] if len(parts) > 0 else "player"
        status = parts[1] if len(parts) > 1 else "Stopped"
        artist = parts[2] if len(parts) > 2 else ""
        title = parts[3] if len(parts) > 3 else ""
        album = parts[4] if len(parts) > 4 else ""

        # Player icon mapping
        p_lower = player_name.lower()
        if "spotify" in p_lower:
            p_icon = "󰓇"
        elif "firefox" in p_lower or "zen" in p_lower or "chrome" in p_lower:
            p_icon = "󰈹"
        elif "mpv" in p_lower:
            p_icon = "󰎆"
        elif "vlc" in p_lower:
            p_icon = "󰕼"
        else:
            p_icon = "󰎆"

        # Status icon
        if status.lower() == "playing":
            s_icon = "󰐊"
        elif status.lower() == "paused":
            s_icon = "󰏤"
        else:
            s_icon = "󰝚"

        if artist and title:
            track = f"{artist} — {title}"
        elif title:
            track = title
        else:
            track = "Reproduciendo"

        # Max length with ellipsis
        if len(track) > 32:
            track_disp = track[:30] + "…"
        else:
            track_disp = track

        text = f"{p_icon}  {track_disp}"
        tooltip = f"<b>{html.escape(player_name.capitalize())}</b> ({html.escape(status)})\n<b>Artista:</b> {html.escape(artist or 'Desconocido')}\n<b>Título:</b> {html.escape(title or 'Sin título')}"
        if album:
            tooltip += f"\n<b>Álbum:</b> {html.escape(album)}"

        return {
            "text": text,
            "tooltip": tooltip,
            "class": status,
            "alt": status
        }
    except Exception as e:
        return {"text": "", "tooltip": str(e), "class": "stopped", "alt": "Stopped"}

if __name__ == "__main__":
    info = get_player_info()
    sys.stdout.write(json.dumps(info) + "\n")
