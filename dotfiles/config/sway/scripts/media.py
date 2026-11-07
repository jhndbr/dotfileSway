#!/usr/bin/env python3
"""
MPRIS Media Controller for Sway (Debian)
Controls active media players (Firefox, Brave, Strawberry, Spotify, mpv, etc.)
via D-Bus native calls without requiring playerctl.
"""

import sys
import subprocess

def get_mpris_players():
    # If playerctl exists, it can list players; otherwise fallback to busctl
    try:
        out = subprocess.check_output(['busctl', '--user', 'list'], text=True)
        return [line.split()[0] for line in out.splitlines() if 'org.mpris.MediaPlayer2.' in line]
    except Exception:
        return []

def send_command(player, method):
    try:
        subprocess.run([
            'busctl', '--user', 'call',
            player,
            '/org/mpris/MediaPlayer2',
            'org.mpris.MediaPlayer2.Player',
            method
        ], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return True
    except Exception:
        return False

def main():
    if len(sys.argv) < 2:
        print("Usage: media.py <play-pause|play|pause|next|prev|stop>")
        sys.exit(1)

    cmd = sys.argv[1].lower()
    method_map = {
        'play-pause': 'PlayPause',
        'play': 'Play',
        'pause': 'Pause',
        'next': 'Next',
        'prev': 'Previous',
        'previous': 'Previous',
        'stop': 'Stop'
    }

    method = method_map.get(cmd)
    if not method:
        sys.exit(1)

    players = get_mpris_players()
    for player in players:
        # Send command to the first player that succeeds
        if send_command(player, method):
            break

if __name__ == '__main__':
    main()
