#!/usr/bin/env python3
"""
Volume Controller for Sway (Debian)
Supports PipeWire/WirePlumber via wpctl with automatic fallback to ALSA ctypes.
Integrates OSD notifications via mako/notify-send.
"""

import sys
import shutil
import subprocess

def notify_osd(summary, value=None):
    try:
        cmd = ["notify-send", "-h", "string:x-canonical-private-synchronous:osd", "-t", "1200"]
        if value is not None:
            cmd.extend(["-h", f"int:value:{value}"])
        cmd.append(summary)
        subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except Exception:
        pass

def run_wpctl(args):
    try:
        res = subprocess.run(["wpctl"] + args, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
        return res.stdout.strip()
    except Exception:
        return ""

def wpctl_get_volume(target="@DEFAULT_AUDIO_SINK@"):
    out = run_wpctl(["get-volume", target])
    # Format: "Volume: 0.50" or "Volume: 0.50 [MUTED]"
    if not out.startswith("Volume:"):
        return None, False
    parts = out.split()
    try:
        val = float(parts[1])
        pct = int(round(val * 100))
        is_muted = "[MUTED]" in out
        return pct, is_muted
    except Exception:
        return None, False

def handle_wpctl(action):
    if action == "up":
        run_wpctl(["set-volume", "-l", "1.0", "@DEFAULT_AUDIO_SINK@", "5%+"])
        pct, muted = wpctl_get_volume()
        if pct is not None:
            if muted:
                # Si estaba silenciado y sube volumen, opcionalmente desmutear
                run_wpctl(["set-mute", "@DEFAULT_AUDIO_SINK@", "0"])
                muted = False
            notify_osd(f"Volumen: {pct}%", pct)
            print(f"{pct}%")
        return True

    elif action == "down":
        run_wpctl(["set-volume", "@DEFAULT_AUDIO_SINK@", "5%-"])
        pct, muted = wpctl_get_volume()
        if pct is not None:
            if muted:
                notify_osd(f"Volumen: Silenciado ({pct}%)", 0)
                print(f"MUTE ({pct}%)")
            else:
                notify_osd(f"Volumen: {pct}%", pct)
                print(f"{pct}%")
        return True

    elif action == "mute":
        run_wpctl(["set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"])
        pct, muted = wpctl_get_volume()
        if pct is not None:
            if muted:
                notify_osd("Volumen: Silenciado", 0)
                print(f"MUTE ({pct}%)")
            else:
                notify_osd(f"Volumen: {pct}%", pct)
                print(f"{pct}%")
        return True

    elif action == "mic-mute":
        run_wpctl(["set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"])
        _, muted = wpctl_get_volume("@DEFAULT_AUDIO_SOURCE@")
        text = "Micrófono: Silenciado" if muted else "Micrófono: Activado"
        notify_osd(text)
        print("MIC MUTE" if muted else "MIC ON")
        return True

    elif action == "get":
        pct, muted = wpctl_get_volume()
        if pct is not None:
            if muted:
                print(f"MUTE ({pct}%)")
            else:
                print(f"{pct}%")
            return True
        return False

    return False

def handle_alsa(action):
    import ctypes
    try:
        asound = ctypes.cdll.LoadLibrary('libasound.so.2')
    except Exception:
        return False

    mixer = ctypes.c_void_p()
    if asound.snd_mixer_open(ctypes.byref(mixer), 0) != 0:
        return False
    if asound.snd_mixer_attach(mixer, b'default') != 0:
        asound.snd_mixer_close(mixer)
        return False
    asound.snd_mixer_selem_register(mixer, None, None)
    asound.snd_mixer_load(mixer)

    if action == 'mic-mute':
        elem = asound.snd_mixer_first_elem(mixer)
        target = None
        while elem:
            name = ctypes.c_char_p(asound.snd_mixer_selem_get_name(ctypes.c_void_p(elem))).value
            if name in (b'Capture', b'Mic'):
                target = elem
                break
            elem = asound.snd_mixer_elem_next(ctypes.c_void_p(elem))
        if target:
            sw = ctypes.c_int()
            asound.snd_mixer_selem_get_capture_switch(ctypes.c_void_p(target), 0, ctypes.byref(sw))
            new_sw = 0 if sw.value else 1
            asound.snd_mixer_selem_set_capture_switch_all(ctypes.c_void_p(target), new_sw)
            status_text = "Micrófono: Silenciado" if new_sw == 0 else "Micrófono: Activado"
            print("MIC MUTE" if new_sw == 0 else "MIC ON")
            notify_osd(status_text)
        asound.snd_mixer_close(mixer)
        return True

    elem = asound.snd_mixer_first_elem(mixer)
    target = None
    while elem:
        name = ctypes.c_char_p(asound.snd_mixer_selem_get_name(ctypes.c_void_p(elem))).value
        if name == b'Master':
            target = elem
            break
        elem = asound.snd_mixer_elem_next(ctypes.c_void_p(elem))

    if not target:
        asound.snd_mixer_close(mixer)
        return False

    elem_p = ctypes.c_void_p(target)
    min_v = ctypes.c_long()
    max_v = ctypes.c_long()
    cur_v = ctypes.c_long()
    sw = ctypes.c_int()

    asound.snd_mixer_selem_get_playback_volume_range(elem_p, ctypes.byref(min_v), ctypes.byref(max_v))
    asound.snd_mixer_selem_get_playback_volume(elem_p, 0, ctypes.byref(cur_v))
    asound.snd_mixer_selem_get_playback_switch(elem_p, 0, ctypes.byref(sw))

    span = max_v.value - min_v.value
    step = int(span * 0.05) or 1

    if action == 'up':
        new_v = min(max_v.value, cur_v.value + step)
        asound.snd_mixer_selem_set_playback_volume_all(elem_p, ctypes.c_long(new_v))
        if sw.value == 0:
            asound.snd_mixer_selem_set_playback_switch_all(elem_p, 1)
        cur_v.value = new_v
        sw.value = 1
    elif action == 'down':
        new_v = max(min_v.value, cur_v.value - step)
        asound.snd_mixer_selem_set_playback_volume_all(elem_p, ctypes.c_long(new_v))
        cur_v.value = new_v
    elif action == 'mute':
        new_sw = 0 if sw.value else 1
        asound.snd_mixer_selem_set_playback_switch_all(elem_p, new_sw)
        sw.value = new_sw

    pct = int(round((cur_v.value - min_v.value) * 100.0 / span)) if span > 0 else 0
    if sw.value == 0:
        print(f"MUTE ({pct}%)")
    else:
        print(f"{pct}%")

    if action in ('up', 'down', 'mute'):
        if sw.value == 0:
            notify_osd("Volumen: Silenciado", 0)
        else:
            notify_osd(f"Volumen: {pct}%", pct)

    asound.snd_mixer_close(mixer)
    return True

def main():
    action = sys.argv[1] if len(sys.argv) > 1 else 'get'

    if shutil.which("wpctl"):
        if handle_wpctl(action):
            return

    handle_alsa(action)

if __name__ == '__main__':
    main()
