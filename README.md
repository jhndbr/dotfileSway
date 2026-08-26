# dotfileSway

> Configuración completa de **MangoWM** para Arch Linux — Estilo **macOS Monochromatic**
>
> **Estado:** Probado y verificado en una Máquina Virtual (VM) con **Arch Linux Minimal**.

Dotfiles minimalistas, elegantes y funcionales para un entorno de escritorio basado en MangoWM/Wayland.

---

## Características

- **Estética macOS Monochromatic** — Paleta monocromática oscura con acentos blancos
- **MangoWM** — Tiling window manager con gaps, bordes, animaciones fluidas y glassmorphism
- **Waybar** — Barra superior translúcida con módulos completos
- **Wofi** — Launcher estilo Spotlight con fuzzy matching
- **Dunst** — Notificaciones con esquinas redondeadas y glassmorphism
- **Foot** — Terminal rápida con colores pastel
- **Gtklock** — Pantalla de bloqueo GTK4 monocromática
- **Swayidle** — Gestión de inactividad (bloqueo, dpms, suspensión)
- **Gestor de Monitores** — Control de pantallas, modo dual/espejo y resoluciones integrado en Waybar (vía `wlr-randr`)
- **Wofi** — Menú de apagado / sesión visual con glassmorphism
- **Gammastep** — Filtro de luz azul automático
- **GTK 3/4 y Qt 5/6** — Tema oscuro dinámico basado en Adwaita y Fusion
- **Zsh** — Shell con Starship + FZF
- **Scripts** — Wallpaper dinámico, gestión de monitores, capturas de pantalla, volumen, brillo, selector de color y emojis

---

## Estructura

```
dotfileSway/
├── config/
│   ├── mango/          # Configuración del WM (config.conf, bind.conf, rule.conf, etc.)
│   │   ├── waybar/     # Configuración de Waybar específica para MangoWM
│   │   └── scripts/    # Scripts auxiliares (config_check, hide_waybar)
│   ├── waybar/         # Barra + estilos CSS (config por defecto)
│   ├── wofi/           # Launcher + estilos
│   ├── dunst/          # Notificaciones
│   ├── foot/           # Terminal
│   ├── gtklock/       # Pantalla de bloqueo (config.ini)
│   ├── gammastep/      # Filtro luz azul
│   ├── yazi/           # Gestor de archivos TUI
│   ├── gtk-3.0/        # Tema GTK 3
│   ├── gtk-4.0/        # Tema GTK 4
│   ├── qt5ct/          # Configuración de estilo Qt5
│   ├── qt6ct/          # Configuración de estilo Qt6
│   └── environment.d/  # Variables de entorno Qt
├── scripts/
│   ├── monitor-manager.sh # Gestor interactivo de monitores (mmsg + wlr-randr)
│   ├── set-wallpaper.sh   # Gestor de wallpaper y tema dinámico
│   ├── screenshot.sh      # Menú de capturas
│   ├── volume.sh          # Control de volumen + OSD
│   ├── brightness.sh      # Control de brillo + OSD
│   ├── color-picker.sh    # Selector de color
│   ├── emoji-picker.sh    # Selector de emojis
│   └── yazi-open-with.sh  # Selector universal de app para Yazi
├── templates/          # Plantillas de Matugen (mango-colors.conf, etc.)
├── wallpapers/         # Fondos de pantalla
├── .zshrc             # Configuración de Zsh
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

> MangoWM y su cliente IPC `mmsg` se instalan desde el AUR (paquete `mangowm`). El script detecta si ya tenés `yay` o `paru`; si no hay ninguno, te pregunta cuál instalar (compilándolo desde el AUR con `makepkg`) y luego usa ese helper para instalar MangoWM.

### 3. Aplicar configuraciones

```bash
# Instalación estándar (sobrescribe archivos)
bash setup.sh

# Instalación limpia (elimina configuraciones previas tras crear backup)
bash setup.sh --clean
```

El script crea siempre un backup automático de tus configuraciones actuales en `~/.config/dotfiles-backup/` antes de realizar cualquier cambio.

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

1. **Actualización en vivo:** Recarga la configuración de MangoWM (`mmsg -d reload_config`) y aplica el wallpaper con `wbg`.
2. **Persistencia:** Copia la imagen a `~/Pictures/1.jpg` para mantener el fondo predeterminado.
3. **Extracción de colores:** Analiza la imagen con Matugen y Pywal para generar una paleta de colores coherente.
4. **Sincronización del entorno:** Genera y recarga automáticamente los temas para:
   - MangoWM, Waybar y Dunst
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
| `Mod+Shift+Return` / `Mod+Y` | Gestor de archivos (Yazi TUI) |
| `Mod+L` / `Mod+Escape` | Bloquear pantalla (Gtklock) |
| `Mod+Shift+E` | Menú de apagado / sesión (Wofi) |
| `Mod+V` | Historial de portapapeles (Cliphist) |
| `Mod+.` | Selector de Emojis |
| `Mod+W` | Alternar ventana flotante |
| `Mod+F` | Pantalla completa (Fullscreen) |
| `Mod+Shift+C` | Recargar configuración de MangoWM |
| `Mod+h/j/k` / `Mod+Flechas` | Cambiar enfoque entre ventanas (Vim / Flechas) |
| `Mod+Shift+h/j/k` / `Mod+Shift+Flechas` | Mover ventana de posición |
| `Mod+1-9` | Ir al tag 1 al 9 |
| `Mod+Shift+1-9` | Mover ventana al tag 1 al 9 |
| `Mod+B` | Cambiar dirección de división (dwindle) |
| `Mod+E` / `Mod+T` | Aumentar / reducir master (master-stack) |
| `Mod+N` | Cambiar layout (tile → scroller) |
| `Mod+Shift+-` / `Mod+-` | Enviar a Scratchpad / Mostrar Scratchpad |
| `Mod+G` | Toggle global (mostrar en todos los tags) |
| `Mod+O` | Toggle overlay |
| `Mod+I` / `Mod+Shift+I` | Minimizar / Restaurar minimizado |
| `Mod+Grave` | Overview (vista general de tags) |
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
| **WM** | mangowm (AUR, incluye mmsg) |
| **Monitores** | wlr-randr, wlr-dpms |
| **Wallpaper** | wbg (AUR) |
| **Lockscreen** | gtklock (AUR) |
| **Idle** | swayidle (AUR) |
| **UI** | waybar, wofi, dunst |
| **Terminal** | foot |
| **Audio** | pipewire, wireplumber, pavucontrol |
| **Red** | networkmanager, blueman |
| **Screen** | grim, slurp, wl-clipboard, cliphist |
| **Archivos & Apps** | yazi, ffmpegthumbnailer, poppler, chafa, ouch, firefox, mpv, imv, zathura |
| **CLI** | bat, eza, fd, ripgrep, zoxide, fzf |
| **Fuentes** | JetBrains Mono Nerd, Inter, Noto |
| **Shell** | zsh, starship, zsh-autosuggestions, zsh-syntax-highlighting |

---

## Licencia

[MIT](LICENSE)
