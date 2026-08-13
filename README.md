# dotfileSway

> Configuración completa de **Sway WM** para Arch Linux — Estilo **macOS Monochromatic**
>
> **Estado:** Probado y verificado en una Máquina Virtual (VM) con **Arch Linux Minimal**.

Dotfiles minimalistas, elegantes y funcionales para un entorno de escritorio basado en Sway/Wayland.

---

## Características

- **Estética macOS Monochromatic** — Paleta monocromática oscura con acentos blancos
- **Sway WM** — Tiling window manager con gaps, bordes y reglas inteligentes
- **Waybar** — Barra superior translúcida con módulos completos
- **Wofi** — Launcher estilo Spotlight con fuzzy matching
- **Dunst** — Notificaciones con esquinas redondeadas y glassmorphism
- **Foot** — Terminal rápida con colores pastel
- **Swaylock** — Pantalla de bloqueo monocromática
- **Swayidle** — Gestión de inactividad (bloqueo, dpms, suspensión)
- **Gestor de Monitores** — Control de pantallas, modo dual/espejo y resoluciones integrado en Waybar
- **Wlogout** — Menú de apagado visual con glassmorphism
- **Gammastep** — Filtro de luz azul automático
- **GTK 3/4 y Qt 5/6** — Tema oscuro dinámico basado en Adwaita y Fusion
- **Zsh** — Shell con Oh My Zsh + Starship / Powerlevel10k + FZF
- **Scripts** — Wallpaper dinámico, gestión de monitores, capturas de pantalla, volumen, brillo, selector de color y emojis

---

## Estructura

```
dotfileSway/
├── config/
│   ├── sway/           # Configuración del WM
│   ├── waybar/         # Barra + estilos CSS
│   ├── wofi/           # Launcher + estilos
│   ├── dunst/          # Notificaciones
│   ├── foot/           # Terminal
│   ├── swaylock/       # Pantalla de bloqueo
│   ├── gammastep/      # Filtro luz azul
│   ├── yazi/           # Gestor de archivos TUI
│   ├── gtk-3.0/        # Tema GTK 3
│   ├── gtk-4.0/        # Tema GTK 4
│   ├── qt5ct/          # Configuración de estilo Qt5
│   ├── qt6ct/          # Configuración de estilo Qt6
│   └── environment.d/  # Variables de entorno Qt
├── scripts/
│   ├── monitor-manager.sh # Gestor interactivo de monitores y resoluciones
│   ├── set-wallpaper.sh # Gestor de wallpaper y tema dinámico
│   ├── screenshot.sh   # Menú de capturas
│   ├── volume.sh       # Control de volumen + OSD
│   ├── brightness.sh   # Control de brillo + OSD
│   ├── color-picker.sh # Selector de color
│   ├── emoji-picker.sh # Selector de emojis
│   └── yazi-open-with.sh # Selector universal de app para Yazi
├── wallpapers/         # Fondos de pantalla
├── .zshrc              # Configuración de Zsh
├── .zprofile           # Variables de entorno Wayland
├── .gitconfig          # Configuración de Git
├── setup.sh            # Instalar dotfiles
├── install_packages.sh # Instalar dependencias
└── README.md
```

---

## Instalación

> **Nota de compatibilidad:** Probado y verificado en una instalación minimal de Arch Linux en Máquina Virtual (VM Arch Minimal).

### 1. Clonar el repositorio

```bash
git clone https://github.com/TU_USUARIO/dotfileSway.git ~/Documents/dotfileSway
cd ~/Documents/dotfileSway
```

### 2. Instalar dependencias

```bash
bash install_packages.sh
```

### 3. Aplicar configuraciones

```bash
bash setup.sh
```

El script crea un backup automático de tus configuraciones actuales antes de sobrescribirlas.

---

## Cambiar Wallpaper y Tema Dinámico

Para cambiar el fondo de pantalla y actualizar el esquema de colores de todo el sistema, puedes usar el alias en Zsh:

```bash
wallpaper /ruta/a/tu/imagen.jpg
```

O bien ejecutar el script directamente:

```bash
bash ~/.local/bin/set-wallpaper.sh /ruta/a/tu/imagen.jpg
```

### Flujo del script de wallpaper

1. **Actualización en vivo:** Cambia el wallpaper de Sway al instante mediante `swaymsg`.
2. **Persistencia:** Copia la imagen a `~/Pictures/1.jpg` para mantener el fondo predeterminado.
3. **Extracción de colores:** Analiza la imagen con Matugen y Pywal para generar una paleta de colores coherente.
4. **Sincronización del entorno:** Genera y recarga automáticamente los temas para:
   - Sway, Waybar y Dunst
   - Foot (Terminal)
   - Aplicaciones GTK 3 y GTK 4
   - Aplicaciones Qt 5 y Qt 6
   - Zed y VSCode (si están instalados)
   - Iconos de la interfaz

---

## Keybindings Principales

| Atajo | Acción |
|---|---|
| `Mod+Return` | Abrir terminal (Foot) |
| `Mod+A` | Lanzador de aplicaciones (Wofi) |
| `Mod+Q` | Cerrar ventana |
| `Mod+E` / `Mod+Y` | Gestor de archivos (Yazi TUI) |
| `Mod+L` / `Mod+Escape` | Bloquear pantalla (Swaylock) |
| `Mod+Shift+E` | Menú de apagado (Wlogout) |
| `Mod+V` | Historial de portapapeles (Cliphist) |
| `Mod+.` | Selector de Emojis |
| `Mod+W` | Alternar ventana flotante |
| `Mod+F` | Pantalla completa (Fullscreen) |
| `Mod+R` | Modo redimensionar (Resize mode) |
| `Mod+Shift+C` | Recargar configuración de Sway |
| `Mod+h/j/k/l` / `Mod+Flechas` | Cambiar enfoque entre ventanas (Vim / Flechas) |
| `Mod+Shift+h/j/k/l` / `Mod+Shift+Flechas` | Mover ventana de posición |
| `Mod+1-0` | Ir al workspace 1 al 10 |
| `Mod+Shift+1-0` | Mover ventana al workspace 1 al 10 |
| `Mod+b` / `Mod+Shift+v` | Dividir espacio Horizontal / Vertical |
| `Mod+s` / `Mod+t` / `Mod+d` | Layout Apilado / Pestañas / Toggle Split |
| `Mod+Shift+-` / `Mod+-` | Enviar a Scratchpad / Mostrar Scratchpad |
| `Print` | Captura de pantalla completa (Grim) |
| `Mod+Print` | Capturar área (Guardar y copiar) |
| `Mod+Shift+S` | Capturar área (Solo copiar al portapapeles) |
| `Mod+Shift+Print` | Menú interactivo de screenshots |
| `Mod+P` / `XF86Display` | Menú de gestión de monitores (Extender, resoluciones, escala) |
| `Mod+Shift+P` | Selector de color (Color Picker) |
| `Teclas Multimedia` | Control de volumen, brillo y reproducción multimedia |

---



## Dependencias

El script `install_packages.sh` instala las siguientes dependencias necesarias:

| Categoría | Paquetes |
|---|---|
| **WM** | sway, swaybg, swaylock, swayidle |
| **UI** | waybar, wofi, dunst |
| **Terminal** | foot |
| **Audio** | pipewire, wireplumber, pavucontrol |
| **Red** | networkmanager, blueman |
| **Screen** | grim, slurp, wl-clipboard, cliphist |
| **Archivos & Apps** | yazi, ffmpegthumbnailer, poppler, chafa, ouch, firefox, mpv, imv, zathura |
| **CLI** | bat, eza, fd, ripgrep, zoxide, fzf |
| **Fuentes** | JetBrains Mono Nerd, Inter, Noto |
| **Shell** | zsh, oh-my-zsh, powerlevel10k / starship |

---

## Licencia

[MIT](LICENSE)
