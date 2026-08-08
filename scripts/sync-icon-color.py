#!/usr/bin/env python3

# ╔══════════════════════════════════════════════════════════════╗
# ║  Generador / Sincronizador Dinámico de Color de Iconos Papirus ║
# ║  100% Sin Sudo / Sin Contraseña (Modo Usuario ~/.local/share)  ║
# ╚══════════════════════════════════════════════════════════════╝

import json
import os
import re
import shutil
import subprocess
import colorsys


SYSTEM_ICONS_DIR = "/usr/share/icons"
USER_ICONS_DIR   = os.path.expanduser("~/.local/share/icons")

THEMES = ["Papirus", "Papirus-Dark", "Papirus-Light"]


def get_papirus_color(hex_color):
    hex_val = hex_color.lstrip("#")
    r, g, b = tuple(int(hex_val[i:i+2], 16) / 255.0 for i in (0, 2, 4))
    h, s, v = colorsys.rgb_to_hsv(r, g, b)
    hue_deg = h * 360.0

    if s < 0.12:
        return "grey"
    elif 345 <= hue_deg or hue_deg < 15:
        return "red"
    elif 15 <= hue_deg < 45:
        return "orange"
    elif 45 <= hue_deg < 75:
        return "yellow"
    elif 75 <= hue_deg < 155:
        return "green"
    elif 155 <= hue_deg < 190:
        return "teal"
    elif 190 <= hue_deg < 225:
        return "cyan"
    elif 225 <= hue_deg < 265:
        return "blue"
    elif 265 <= hue_deg < 315:
        return "violet"
    else:
        return "magenta"


def get_matugen_accent():
    css_path = os.path.expanduser("~/.config/gtk-3.0/dank-colors.css")
    if os.path.exists(css_path):
        with open(css_path, "r") as f:
            content = f.read()
        match = re.search(r"@define-color\s+accent_bg_color\s+(#[0-9a-fA-F]{6});", content)
        if match:
            return match.group(1)

    json_path = "/tmp/dank16.json"
    if os.path.exists(json_path):
        try:
            with open(json_path, "r") as f:
                data = json.load(f)
            return data["dank16"]["color4"]["default"]["hex"]
        except Exception:
            pass

    return "#3498db"


def ensure_user_icons():
    """
    Copia los temas Papirus del sistema al directorio del usuario usando hardlinks
    (cp -rl) para evitar duplicar espacio en disco. Esto permite que papirus-folders
    opere sobre el directorio del usuario sin necesitar root.
    """
    os.makedirs(USER_ICONS_DIR, exist_ok=True)
    installed = []

    for theme in THEMES:
        user_path   = os.path.join(USER_ICONS_DIR, theme)
        system_path = os.path.join(SYSTEM_ICONS_DIR, theme)

        if os.path.exists(user_path):
            continue  # ya instalado

        if not os.path.isdir(system_path):
            print(f"⚠ {theme} no encontrado en {SYSTEM_ICONS_DIR}, omitiendo.")
            continue

        print(f"📦 Instalando {theme} en {USER_ICONS_DIR}...")
        try:
            # cp -ra: copia preservando symlinks (-a = archive).
            # Papirus usa symlinks internos en places/ para los folder icons;
            # hardlinks (-l) no funcionan para symlinks entre filesystems distintos.
            result = subprocess.run(
                ["cp", "-ra", system_path, user_path],
                capture_output=True, text=True
            )
            if result.returncode == 0:
                print(f"✓ {theme} instalado en {user_path}")
                installed.append(theme)
            else:
                print(f"❌ Error copiando {theme}: {result.stderr.strip()}")
        except Exception as e:
            print(f"❌ Error instalando {theme}: {e}")

    return installed


def apply_folder_color(papirus_bin, color_name, theme_path):
    """
    Aplica color_name al tema en theme_path usando papirus-folders.
    Al pasar la ruta absoluta con -t, THEME_DIR queda dentro de HOME
    y _is_user_dir() en papirus-folders devuelve true → nunca pide sudo.
    No se usa -u (update-caches) porque esa operación requiere root.
    """
    result = subprocess.run(
        [papirus_bin, "-C", color_name, "-t", theme_path, "-o"],
        capture_output=True, text=True
    )
    if result.returncode != 0:
        print(f"⚠ papirus-folders error en {theme_path}: {result.stderr.strip()}")


def main():
    # 1. Asegurar que los iconos Papirus están instalados en el directorio de usuario
    ensure_user_icons()

    # 2. Determinar el color de acento desde el tema actual
    hex_color  = get_matugen_accent()
    color_name = get_papirus_color(hex_color)
    print(f"🎨 Color de carpetas/iconos Papirus: {color_name} (hex acento: {hex_color})")

    # 3. Cache para evitar re-ejecutar papirus-folders si el color no cambió
    cache_file = "/tmp/papirus_last_color"
    if os.path.exists(cache_file):
        try:
            with open(cache_file, "r") as f:
                if f.read().strip() == color_name:
                    print(f"⚡ Color de carpetas ya actualizado a '{color_name}'.")
                    return
        except Exception:
            pass

    # 4. Localizar el binario papirus-folders
    papirus_bin = os.path.expanduser("~/.local/bin/papirus-folders")
    if not os.path.exists(papirus_bin):
        papirus_bin = "papirus-folders"

    # 5. Aplicar el color a cada tema instalado en el directorio de usuario
    for theme in THEMES:
        user_path = os.path.join(USER_ICONS_DIR, theme)
        if os.path.exists(user_path):
            apply_folder_color(papirus_bin, color_name, user_path)
        else:
            print(f"⚠ {theme} no disponible en {USER_ICONS_DIR}, omitiendo.")

    # 6. Guardar el color aplicado en cache
    try:
        with open(cache_file, "w") as f:
            f.write(color_name)
    except Exception:
        pass


if __name__ == "__main__":
    main()
