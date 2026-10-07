#!/usr/bin/env python3
# ╔══════════════════════════════════════════════════════════════╗
# ║        Waybar Workspaces & Window Bridge for MangoWM         ║
# ║        Event-driven IPC daemon & one-shot provider           ║
# ║        Replica el comportamiento de sway/workspaces          ║
# ╚══════════════════════════════════════════════════════════════╝

import sys
import os
import re
import json
import time
import signal
import threading
import subprocess
import fcntl

CACHE_DIR = "/tmp/waybar_mango"
os.makedirs(CACHE_DIR, exist_ok=True)

REWRITE_RULES = [
    (r".*brave.*", "󰊯"),
    (r".*chrome.*", "󰊯"),
    (r".*chromium.*", "󰊯"),
    (r".*firefox.*", "󰈹"),
    (r".*zen.*", "󰈹"),
    (r".*ghostty.*", "󰞷"),
    (r".*foot.*", "󰞷"),
    (r".*kitty.*", "󰄛"),
    (r".*alacritty.*", "󰞷"),
    (r".*wezterm.*", "󰞷"),
    (r".*code.*", "󰨞"),
    (r".*vscodium.*", "󰨞"),
    (r".*zed.*", "󰅩"),
    (r".*jetbrains.*|.*idea.*", "󰅩"),
    (r".*vim.*|.*nvim.*", ""),
    (r".*openplc.*", "󰑣"),
    (r".*antigravity.*", "󰧑"),
    (r".*thunar.*", "󰝰"),
    (r".*nautilus.*", "󰝰"),
    (r".*dolphin.*", "󰝰"),
    (r".*spotify.*", "󰓇"),
    (r".*strawberry.*", "󰎆"),
    (r".*youtube.*music.*", "󰐃"),
    (r".*discord.*|.*vesktop.*", "󰙯"),
    (r".*telegram.*", "󰒓"),
    (r".*thunderbird.*", "󰇮"),
    (r".*tuba.*", "󰈹"),
    (r".*pavucontrol.*", "󰕾"),
    (r".*blueman.*", "󰂯"),
    (r".*mpv.*", "󰎆"),
    (r".*vlc.*", "󰕼"),
    (r".*audacity.*", "󰎇"),
    (r".*obs.*", "󰑋"),
    (r".*steam.*", "󰓓"),
    (r".*pcsx2.*|.*counter-strike.*|.*cs2.*|.*half-life.*", "󰊴"),
    (r".*games.*|.*game.*|.*lutris.*|.*heroic.*", "󰊴"),
    (r".*gimp.*|.*inkscape.*", "󰽉"),
    (r".*libreoffice.*|.*soffice.*", "󰈙"),
    (r".*joplin.*|.*obsidian.*|.*zotero.*", "󱓧"),
    (r".*calibre.*", "󰂿"),
    (r".*zathura.*|.*evince.*", "󰈦"),
    (r".*localsend.*", "󰒍"),
    (r".*qbittorrent.*", "󰇚"),
    (r".*virt-manager.*|.*qemu.*", "󰢹"),
    (r".*timeshift.*", "󰁯"),
    (r".*btop.*|.*htop.*", "󰻠"),
]

def get_icon(appid, title):
    for pattern, icon in REWRITE_RULES:
        if re.search(pattern, appid, re.IGNORECASE) or re.search(pattern, title, re.IGNORECASE):
            return icon
    return "󰖯"

def update_all():
    lock_path = f"{CACHE_DIR}/update.lock"
    lock_fd = None
    try:
        lock_fd = open(lock_path, "w")
        fcntl.flock(lock_fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except (BlockingIOError, OSError):
        if lock_fd:
            try:
                lock_fd.close()
            except Exception:
                pass
        return

    pid = os.getpid()
    try:
        try:
            tags_raw = subprocess.check_output(["mmsg", "get", "all-tags"], stderr=subprocess.DEVNULL, timeout=2).decode()
            tags_data = json.loads(tags_raw).get("all_tags", [{}])[0].get("tags", [])
        except Exception:
            tags_data = [{"index": i, "is_active": (i == 1), "is_urgent": False, "client_count": 0} for i in range(1, 10)]

        try:
            clients_raw = subprocess.check_output(["mmsg", "get", "all-clients"], stderr=subprocess.DEVNULL, timeout=2).decode()
            clients_data = json.loads(clients_raw).get("clients", [])
        except Exception:
            clients_data = []

        tag_clients = {i: [] for i in range(1, 10)}
        for c in clients_data:
            for t in c.get("tags", []):
                if t in tag_clients:
                    tag_clients[t].append(c)

        for t in tags_data:
            idx = t.get("index", 1)
            is_active = t.get("is_active", False)
            is_urgent = t.get("is_urgent", False)
            cls_list = tag_clients.get(idx, [])

            icons = [get_icon(c.get("appid", ""), c.get("title", "")) for c in cls_list]
            icons_str = " ".join(icons)

            # Ocultar cualquier espacio que no esté en uso (solo mostrar los activos o con ventanas)
            if not is_active and not cls_list and not is_urgent:
                payload = {"text": "", "alt": str(idx), "tooltip": "", "class": ["empty", "hidden"]}
            else:
                if icons_str:
                    text = f"{idx}  {icons_str}"
                else:
                    text = f"{idx}"

                css_class = []
                if is_active:
                    css_class.append("active")
                if cls_list:
                    css_class.append("occupied")
                else:
                    css_class.append("empty")
                if is_urgent:
                    css_class.append("urgent")

                tooltip = f"Espacio {idx}" + (" (Activo)" if is_active else "")
                if cls_list:
                    tooltip += "\n" + "\n".join("• " + (c.get("appid") or "app") + " - " + (c.get("title") or "")[:35] for c in cls_list)

                payload = {
                    "text": text,
                    "alt": str(idx),
                    "tooltip": tooltip,
                    "class": css_class
                }

            tmp_path = f"{CACHE_DIR}/ws_{idx}_{pid}.tmp"
            dst_path = f"{CACHE_DIR}/ws_{idx}.json"
            try:
                with open(tmp_path, "w", encoding="utf-8") as f:
                    json.dump(payload, f, ensure_ascii=False)
                os.replace(tmp_path, dst_path)
            except OSError:
                pass

        # Window title update
        try:
            win_raw = subprocess.check_output(["mmsg", "get", "focusing-client"], stderr=subprocess.DEVNULL, timeout=2).decode()
            win = json.loads(win_raw)
            if win and "title" in win and win.get("is_visible", True) and not win.get("is_minimized", False):
                icon = get_icon(win.get("appid", ""), win.get("title", ""))
                title = win.get("title", "")
                if len(title) > 42:
                    title = title[:39] + "..."
                win_payload = {
                    "text": f"{icon}  {title}",
                    "tooltip": win.get("title", ""),
                    "class": "focused"
                }
            else:
                win_payload = {"text": "", "class": "empty"}
        except Exception:
            win_payload = {"text": "", "class": "empty"}

        tmp_win = f"{CACHE_DIR}/window_{pid}.tmp"
        dst_win = f"{CACHE_DIR}/window.json"
        try:
            with open(tmp_win, "w", encoding="utf-8") as f:
                json.dump(win_payload, f, ensure_ascii=False)
            os.replace(tmp_win, dst_win)
        except OSError:
            pass
    finally:
        if lock_fd:
            try:
                fcntl.flock(lock_fd, fcntl.LOCK_UN)
                lock_fd.close()
            except Exception:
                pass

def is_cache_fresh():
    ws_file = f"{CACHE_DIR}/ws_1.json"
    if not os.path.exists(ws_file):
        return False
    try:
        return (time.time() - os.path.getmtime(ws_file)) < 0.8
    except Exception:
        return False

def is_daemon_running():
    pid_file = f"{CACHE_DIR}/daemon.pid"
    if not os.path.exists(pid_file):
        return False
    try:
        pid = int(open(pid_file).read().strip())
        if pid == os.getpid():
            return True
        os.kill(pid, 0)
        with open(f"/proc/{pid}/cmdline", "rb") as f:
            cmd = f.read().decode(errors="ignore")
            return "waybar-mango-workspaces" in cmd and "daemon" in cmd
    except Exception:
        return False

def ensure_daemon():
    if not is_daemon_running():
        try:
            subprocess.Popen(
                ["python3", os.path.abspath(__file__), "daemon"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                stdin=subprocess.DEVNULL,
                start_new_session=True
            )
        except Exception:
            pass

def print_ws(idx):
    if not is_cache_fresh():
        update_all()
        ensure_daemon()
    ws_file = f"{CACHE_DIR}/ws_{idx}.json"
    for _ in range(3):
        try:
            if os.path.exists(ws_file):
                with open(ws_file, "r", encoding="utf-8") as f:
                    sys.stdout.write(f.read())
                    sys.stdout.flush()
                return
        except OSError:
            time.sleep(0.01)
    print(json.dumps({"text": "", "class": ["empty", "hidden"]}))

def print_window():
    if not is_cache_fresh():
        update_all()
        ensure_daemon()
    win_file = f"{CACHE_DIR}/window.json"
    for _ in range(3):
        try:
            if os.path.exists(win_file):
                with open(win_file, "r", encoding="utf-8") as f:
                    sys.stdout.write(f.read())
                    sys.stdout.flush()
                return
        except OSError:
            time.sleep(0.01)
    print(json.dumps({"text": "", "class": "empty"}))

def daemon_main():
    # Asegurar instancia única
    pid_file = f"{CACHE_DIR}/daemon.pid"
    if os.path.exists(pid_file):
        try:
            old_pid = int(open(pid_file).read().strip())
            if old_pid != os.getpid():
                os.kill(old_pid, 0)
                with open(f"/proc/{old_pid}/cmdline", "rb") as f:
                    cmd = f.read().decode(errors="ignore")
                    if "waybar-mango-workspaces" in cmd and "daemon" in cmd:
                        return
        except Exception:
            pass

    with open(pid_file, "w") as f:
        f.write(str(os.getpid()))

    pending_update = False
    lock = threading.Lock()

    def request_update():
        nonlocal pending_update
        with lock:
            pending_update = True

    def watcher_thread(cmd):
        while True:
            try:
                proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
                for _ in iter(proc.stdout.readline, ""):
                    request_update()
            except Exception:
                time.sleep(1)

    # Iniciar estado inicial
    update_all()

    # Hilos de observación con unbuffering de línea para latencia cero
    for watch_cmd in [
        ["stdbuf", "-oL", "mmsg", "watch", "all-tags"],
        ["stdbuf", "-oL", "mmsg", "watch", "all-clients"],
        ["stdbuf", "-oL", "mmsg", "watch", "focusing-client"]
    ]:
        t = threading.Thread(target=watcher_thread, args=(watch_cmd,), daemon=True)
        t.start()

    # Periodo de gracia inicial
    time.sleep(0.5)

    # Bucle de debounce y señalización
    while True:
        time.sleep(0.04)
        do_up = False
        with lock:
            if pending_update:
                pending_update = False
                do_up = True
        if do_up:
            update_all()
            subprocess.run(["pkill", "-RTMIN+1", "waybar"], stderr=subprocess.DEVNULL)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        arg = sys.argv[1]
        if arg == "daemon":
            daemon_main()
        elif arg == "window":
            print_window()
        elif arg.isdigit():
            print_ws(int(arg))
        elif arg == "update":
            update_all()
            subprocess.run(["pkill", "-RTMIN+1", "waybar"], stderr=subprocess.DEVNULL)
        else:
            print(json.dumps({"text": arg}))
    else:
        print_ws(1)
