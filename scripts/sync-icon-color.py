#!/usr/bin/env python3

# ╔══════════════════════════════════════════════════════════════╗
# ║  Generador / Sincronizador Dinámico de Color de Iconos Papirus ║
# ║  100% Sin Sudo / Sin Contraseña (Modo Usuario ~/.local/share)  ║
# ╚══════════════════════════════════════════════════════════════╝

import json
import os
import re
import sys
import shutil
import subprocess
import colorsys
import math


SYSTEM_ICONS_DIR = "/usr/share/icons"
USER_ICONS_DIR   = os.path.expanduser("~/.local/share/icons")

THEMES = ["Papirus", "Papirus-Dark", "Papirus-Light"]


def classify_to_papirus(hue_deg, s, v):
    """
    Mapea de forma precisa el tono (Hue 0-360), Saturación y Brillo
    a la paleta de colores de carpetas de Papirus.
    """
    # 1. Grises / Neutros
    if s < 0.12:
        return "black" if v < 0.22 else "grey"

    # 2. Rojos / Carmín (350° a 12°)
    if hue_deg >= 350 or hue_deg < 12:
        return "carmine" if v < 0.40 else "red"

    # 3. Naranjas / Naranja Profundo / Marrón (12° a 42°)
    elif 12 <= hue_deg < 42:
        if s < 0.35 and v < 0.45:
            return "brown"
        elif hue_deg < 24:
            return "deeporange"
        else:
            return "orange"

    # 4. Amarillos / Ámbar (42° a 68°)
    elif 42 <= hue_deg < 68:
        if s < 0.30 and v < 0.55:
            return "palebrown"
        return "yellow"

    # 5. Verdes (68° a 155°)
    elif 68 <= hue_deg < 155:
        return "green"

    # 6. Teal / Azul Verdoso (155° a 185°)
    elif 155 <= hue_deg < 185:
        return "teal"

    # 7. Cyan / Turquesa Puro (185° a 202°)
    elif 185 <= hue_deg < 202:
        return "cyan"

    # 8. Azules (202° a 255°)
    elif 202 <= hue_deg < 255:
        if s < 0.28 and v > 0.50:
            return "nordic"
        elif hue_deg >= 235 and v < 0.50:
            return "indigo"
        else:
            return "blue"

    # 9. Violetas (255° a 290°)
    elif 255 <= hue_deg < 290:
        return "violet"

    # 10. Magentas / Rosas (290° a 350°)
    elif 290 <= hue_deg < 330:
        return "magenta"
    else:
        return "pink"


def get_image_vibrant_hsv(img_path):
    """
    Analiza directamente la imagen de fondo de pantalla para extraer
    el tono (Hue) y saturación cromática dominante real de forma rápida.
    """
    try:
        from PIL import Image
        img = Image.open(img_path).convert("RGB")
        img.thumbnail((80, 80))
        import warnings
        with warnings.catch_warnings():
            warnings.simplefilter("ignore")
            pixels = list(img.getdata())

        candidates = []
        for r, g, b in pixels:
            h, s, v = colorsys.rgb_to_hsv(r / 255.0, g / 255.0, b / 255.0)
            # Descartar negro extremo, blanco extremo y grises neutros
            if 0.10 < v < 0.95 and s > 0.16:
                # Ponderar por saturación y balance de luminancia
                weight = (s ** 2) * (1.0 - abs(v - 0.5))
                candidates.append((weight, h * 360.0, s, v))

        if candidates:
            candidates.sort(key=lambda x: x[0], reverse=True)
            top = candidates[:max(1, len(candidates) // 6)]
            # Promedio circular del tono angular
            sin_sum = sum(w * math.sin(math.radians(h)) for w, h, s, v in top)
            cos_sum = sum(w * math.cos(math.radians(h)) for w, h, s, v in top)
            avg_h = (math.degrees(math.atan2(sin_sum, cos_sum))) % 360.0
            total_w = sum(w for w, h, s, v in top)
            avg_s = sum(w * s for w, h, s, v in top) / total_w
            avg_v = sum(w * v for w, h, s, v in top) / total_w
            return avg_h, avg_s, avg_v
    except Exception:
        pass
    return None


def get_papirus_color(hex_color):
    hex_val = hex_color.lstrip("#")
    r, g, b = tuple(int(hex_val[i:i+2], 16) / 255.0 for i in (0, 2, 4))
    h, s, v = colorsys.rgb_to_hsv(r, g, b)
    return classify_to_papirus(h * 360.0, s, v)


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
    o archive para evitar duplicar espacio en disco.
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
    Aplica color_name al tema en theme_path usando papirus-folders
    y asegura que todos los tamaños (incluyendo 16x16 usado en GTK file pickers)
    tengan los enlaces simbólicos correctos.
    """
    result = subprocess.run(
        [papirus_bin, "-C", color_name, "-t", theme_path, "-o"],
        capture_output=True, text=True
    )
    if result.returncode != 0:
        print(f"⚠ papirus-folders error en {theme_path}: {result.stderr.strip()}")

    # papirus-folders omite 16x16 (usado en listas compactas y selectores de archivos GTK).
    # Aseguramos que folder.svg y variantes apunten al color activo en todos los tamaños.
    for size in ["16x16", "22x22", "24x24", "32x32", "48x48", "64x64"]:
        places_dir = os.path.join(theme_path, size, "places")
        if not os.path.isdir(places_dir):
            continue

        target_color_svg = f"folder-{color_name}.svg"
        target_path = os.path.join(places_dir, target_color_svg)
        link_path = os.path.join(places_dir, "folder.svg")
        if os.path.exists(target_path):
            try:
                if os.path.islink(link_path) or os.path.exists(link_path):
                    os.remove(link_path)
                os.symlink(target_color_svg, link_path)
            except Exception as e:
                print(f"⚠ Error actualizando enlace {link_path}: {e}")


def main():
    # 1. Asegurar que los iconos Papirus están instalados en el directorio de usuario
    ensure_user_icons()

    # 2. Priorizar el color de acento generado por Matugen (coherencia con GTK/Waybar/Thunar)
    color_name = None
    ref_desc = ""

    hex_color = get_matugen_accent()
    if hex_color:
        color_name = get_papirus_color(hex_color)
        ref_desc = f"Matugen accent {hex_color}"

    # Si no se obtuvo de Matugen, extraer directamente del wallpaper
    if not color_name:
        image_path = None
        if len(sys.argv) > 1:
            candidate = os.path.expanduser(sys.argv[1])
            if os.path.isfile(candidate):
                image_path = candidate
        if not image_path:
            default_target = os.path.expanduser("~/Pictures/1.jpg")
            if os.path.isfile(default_target):
                image_path = default_target

        if image_path:
            hsv = get_image_vibrant_hsv(image_path)
            if hsv:
                h, s, v = hsv
                color_name = classify_to_papirus(h, s, v)
                r, g, b = colorsys.hsv_to_rgb(h / 360.0, s, v)
                ref_desc = f"#{int(r*255):02x}{int(g*255):02x}{int(b*255):02x} (Hue {h:.1f}°)"

    if not color_name:
        color_name = "blue"
        ref_desc = "default fallback"

    print(f"🎨 Color de carpetas/iconos Papirus: {color_name} (tono principal: {ref_desc})")

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

    # 5. Priorizar el tema activo según el modo (Papirus para light, Papirus-Dark para dark)
    theme_mode = "dark"
    if len(sys.argv) > 2 and sys.argv[2] in ["light", "dark"]:
        theme_mode = sys.argv[2]
    else:
        conf_path = os.path.expanduser("~/.config/matugen/theme.conf")
        if os.path.exists(conf_path):
            try:
                with open(conf_path, "r") as f:
                    for line in f:
                        if line.startswith("MODE="):
                            val = line.split("=", 1)[1].strip().strip('"').strip("'")
                            if val in ["light", "dark"]:
                                theme_mode = val
            except Exception:
                pass

    active_theme = "Papirus" if theme_mode == "light" else "Papirus-Dark"
    other_themes = [t for t in THEMES if t != active_theme]

    active_path = os.path.join(USER_ICONS_DIR, active_theme)
    if os.path.exists(active_path):
        apply_folder_color(papirus_bin, color_name, active_path)
        subprocess.run(["gtk-update-icon-cache", "-f", "-t", "-q", active_path], capture_output=True)

    # 6. Forzar inmediatamente a Thunar y apps GTK a mostrar los nuevos iconos sin demora
    try:
        subprocess.run(["gsettings", "set", "org.gnome.desktop.interface", "icon-theme", "Adwaita"], capture_output=True)
        subprocess.run(["gsettings", "set", "org.gnome.desktop.interface", "icon-theme", active_theme], capture_output=True)
    except Exception:
        pass

    # 7. Guardar el color aplicado en cache
    try:
        with open(cache_file, "w") as f:
            f.write(color_name)
    except Exception:
        pass

    # 8. Actualizar temas secundarios en segundo plano
    for theme in other_themes:
        user_path = os.path.join(USER_ICONS_DIR, theme)
        if os.path.exists(user_path):
            apply_folder_color(papirus_bin, color_name, user_path)
            subprocess.run(["gtk-update-icon-cache", "-f", "-t", "-q", user_path], capture_output=True)


if __name__ == "__main__":
    main()
