# 🖥️ dotfileSway

> Configuración completa de **Sway WM** para Arch Linux — Estilo **macOS Monochromatic**

Dotfiles minimalistas, elegantes y funcionales para un entorno de escritorio basado en Sway/Wayland.

---

## ✨ Características

- 🎨 **Estética macOS Monochromatic** — Paleta monocromática oscura con acentos blancos
- 🪟 **Sway WM** — Tiling window manager con gaps, bordes y reglas inteligentes
- 📊 **Waybar** — Barra superior translúcida con módulos completos
- 🔍 **Wofi** — Launcher estilo Spotlight con fuzzy matching
- 🔔 **Dunst** — Notificaciones con esquinas redondeadas y glassmorphism
- 🖥️ **Foot** — Terminal rápida con colores pastel
- 🔒 **Swaylock** — Pantalla de bloqueo monocromática
- 💤 **Swayidle** — Gestión de inactividad (bloqueo, dpms, suspensión)
- 🖥️ **Kanshi** — Gestión automática de monitores
- ⏻ **Wlogout** — Menú de apagado visual con glassmorphism
- 🌙 **Gammastep** — Filtro de luz azul automático
- 🎨 **GTK 3/4** — Tema oscuro con Adwaita
- ⚡ **Zsh** — Shell con Oh My Zsh + Powerlevel10k
- 📸 **Scripts** — Screenshot, volumen, brillo, color picker con notificaciones

---

## 📁 Estructura

```
dotfileSway/
├── config/
│   ├── sway/           # Configuración del WM
│   ├── waybar/         # Barra + estilos CSS
│   ├── wofi/           # Launcher + estilos
│   ├── dunst/          # Notificaciones
│   ├── foot/           # Terminal
│   ├── swaylock/       # Pantalla de bloqueo
│   ├── kanshi/         # Multi-monitor
│   ├── wlogout/        # Menú de apagado
│   ├── gammastep/      # Filtro luz azul
│   ├── gtk-3.0/        # Tema GTK 3
│   ├── gtk-4.0/        # Tema GTK 4
│   └── environment.d/  # Variables de entorno Qt
├── scripts/
│   ├── screenshot.sh   # Menú de capturas
│   ├── volume.sh       # Control de volumen + OSD
│   ├── brightness.sh   # Control de brillo + OSD
│   └── color-picker.sh # Selector de color
├── wallpapers/         # Fondos de pantalla
├── .zshrc              # Configuración de Zsh
├── .zprofile           # Variables de entorno Wayland
├── .gitconfig          # Configuración de Git
├── setup.sh            # 🚀 Instalar dotfiles
├── update_dotfiles.sh  # 🔄 Sincronizar desde ~/.config
├── install_packages.sh # 📦 Instalar dependencias
└── README.md
```

---

## 🚀 Instalación

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

> **Nota:** El script crea un backup automático de tus configuraciones actuales antes de sobrescribirlas.

---

## ⌨️ Keybindings Principales

| Atajo | Acción |
|---|---|
| `Mod+Return` | Terminal (foot) |
| `Mod+A` | Lanzador de aplicaciones (Wofi) |
| `Mod+Q` | Cerrar ventana |
| `Mod+E` | Gestor de archivos (Nautilus) |
| `Mod+Escape` | Bloquear pantalla |
| `Mod+Shift+E` | Menú de apagado (wlogout) |
| `Mod+V` | Historial de portapapeles |
| `Mod+F` | Pantalla completa |
| `Mod+W` | Ventana flotante |
| `Mod+R` | Modo resize |
| `Mod+1-0` | Ir a workspace 1-10 |
| `Mod+Shift+1-0` | Mover ventana a workspace |
| `Print` | Screenshot pantalla completa |
| `Mod+Shift+S` | Screenshot de área |
| `Mod+Shift+P` | Selector de color |

---

## 🔄 Sincronización

Para actualizar los dotfiles con los cambios que hagas en `~/.config`:

```bash
bash update_dotfiles.sh
```

Este script copia las configuraciones actuales al repositorio y opcionalmente hace commit + push.

---

## 🛠️ Dependencias

El script `install_packages.sh` instala todo lo necesario:

| Categoría | Paquetes |
|---|---|
| **WM** | sway, swaybg, swaylock, swayidle |
| **UI** | waybar, wofi, dunst, wlogout |
| **Terminal** | foot |
| **Audio** | pipewire, wireplumber, pavucontrol |
| **Red** | networkmanager, blueman |
| **Screen** | grim, slurp, wl-clipboard, cliphist |
| **Archivos** | nautilus, gvfs, gvfs-mtp, gvfs-smb |
| **CLI** | bat, eza, fd, ripgrep, zoxide, fzf |
| **Fuentes** | JetBrains Mono Nerd, Inter, Noto |
| **Shell** | zsh, oh-my-zsh, powerlevel10k |

---

## 📄 Licencia

[MIT](LICENSE)

---

> Hecho con ☕ en Arch Linux
