# ╔══════════════════════════════════════════════════════════════╗
# ║        GUÍA RÁPIDA DE ATAJOS Y ALIAS DEL SISTEMA (SWAY + ZSH) ║
# ╚══════════════════════════════════════════════════════════════╝

> **Tecla Modificador ($mod):** `Super` (Tecla Windows / Command)

---

## 🪟 1. Gestión de Ventanas y Sistema (Sway)

| Atajo | Acción |
|---|---|
| `Super + Return` | Abrir terminal (**foot**) |
| `Super + A` | Lanzador de aplicaciones (**Wofi**) |
| `Super + Q` | Cerrar ventana activa |
| `Super + W` | Alternar ventana flotante / tiling |
| `Super + F` | Pantalla completa (Fullscreen) |
| `Super + X` | **Centro de Control** (Quick Settings) |
| `Super + V` | Historial de portapapeles (**Cliphist**) |
| `Super + .` *(Punto)* | Selector de emojis |
| `Super + E` / `Super + Y` | Explorador de archivos (**Yazi**) |
| `Super + L` / `Super + Esc` | Bloquear pantalla (**Swaylock**) |
| `Super + Shift + E` | Menú de apagado y sesión |
| `Super + Shift + C` | **Recargar configuración de Sway** |
| `Super + R` | Modo redimensionar ventana (*Escape* para salir) |

---

## 🖥️ 2. Pantallas y Monitores

| Atajo | Acción |
|---|---|
| `Super + P` / `XF86Display` | Abrir **Menú de Monitores** (Wofi) |
| `Super + M` / `Super + F7` | **Restablecer configuración predeterminada** (Netbook principal en `0 0` + HDMI a la derecha) |

---

## 📸 3. Capturas de Pantalla y Color Picker

| Atajo | Acción |
|---|---|
| `Print` | Pantalla completa (Guardar en `~/Pictures/Screenshots` y Copiar) |
| `Super + Print` | Seleccionar área (**Guardar y Copiar**) |
| `Super + Shift + S` | Seleccionar área (**Solo Copiar** al portapapeles) |
| `Super + Shift + Print` | Abrir **Menú completo de 5 opciones de captura** |
| `Super + Shift + P` | **Selector de Color** (Copia código HEX) |

---

## 🧭 4. Navegación y Distribución de Espacios

| Atajo | Acción |
|---|---|
| `Super + Flechas` | Cambiar foco de ventana (Izquierda/Abajo/Arriba/Derecha) |
| `Super + H / J / K` | Cambiar foco estilo Vim |
| `Super + Shift + Flechas` | Mover ventana en esa dirección |
| `Super + 1..0` | Cambiar al espacio de trabajo (Workspace) 1 al 10 |
| `Super + Shift + 1..0` | Mover ventana al espacio de trabajo 1 al 10 |
| `Super + B` | Dividir horizontalmente (Split H) |
| `Super + Shift + V` | Dividir verticalmente (Split V) |
| `Super + S` | Disposición apilada (Stacking) |
| `Super + T` | Disposición en pestañas (Tabbed) |
| `Super + D` | Alternar modo de división (Toggle split) |
| `Super + Shift + -` | Mover ventana a la zona oculta (**Scratchpad**) |
| `Super + -` | Mostrar / ocultar ventana del **Scratchpad** |

---

## 🖐️ 5. Gestos Táctiles en Touchpad

| Gesto | Acción |
|---|---|
| **Swipe 3 dedos (Izq / Der)** | Cambiar de espacio de trabajo |
| **Swipe 4 dedos (Arriba)** | Alternar ventana flotante |
| **Swipe 4 dedos (Abajo)** | Alternar modo de foco |

---

## 🔊 6. Controles Multimedia y Brillo

| Tecla | Acción |
|---|---|
| `XF86AudioMute` | Silenciar / Activar audio |
| `XF86AudioLowerVolume` | Bajar volumen |
| `XF86AudioRaiseVolume` | Subir volumen |
| `XF86AudioMicMute` | Silenciar / Activar micrófono |
| `XF86AudioPlay / Pause` | Reproducir / Pausar multimedia |
| `XF86AudioNext / Prev` | Siguiente / Anterior pista |
| `XF86MonBrightnessDown / Up` | Disminuir / Aumentar brillo |

---

## 💻 7. Alias de Terminal Zsh

### 📁 Navegación y Listado
- `..` → `cd ..`
- `...` → `cd ../..`
- `....` → `cd ../../..`
- `ls` → Listar con iconos y carpetas primero (`eza`)
- `ll` → Listar detallado con tamaños y permisos
- `la` → Listar todos los archivos (incluyendo ocultos)
- `lt` → Vista en árbol de directorios

### 🛠️ Dotfiles y Sistema
- `dotfiles` → Ir a `~/Documents/dotfileSway`
- `dots-apply` → Ejecutar `setup.sh` para sincronizar dotfiles
- `wallpaper` → Cambiar fondo de pantalla dinámico
- `reload` → Recargar `.zshrc` inmediatamente
- `df` → Ver espacio en disco disponible (`df -h`)
- `free` → Ver consumo de memoria RAM (`free -h`)
- `ip` → Ver IPs con colores (`ip -c`)
- `cleanup` → Limpiar paquetes huérfanos y caché de pacman/yay
- `cache-clear` → Limpiar caché de `~/.cache`

### 📦 Compresión con Ouch
- `x <archivo>` o `extract <archivo>` → Descomprimir cualquier formato (.zip, .tar.gz, .7z, etc.)
- `compress <destino.tar.gz> <archivos>` → Comprimir archivos
- `lszip <archivo>` → Ver contenido de un archivo comprimido

### 🌿 Git Rápido
- `gs` → `git status`
- `gc` → `git commit`
- `gp` → `git push`
- `gpl` → `git pull`
- `gd` → `git diff`
- `gl` → `git log --oneline -20`
- `gco` → `git checkout`
- `gb` → `git branch`

### 🔍 Sway & Logs
- `sway-reload` → Recargar configuración de Sway
- `sway-log` → Ver logs del journal de Sway
- `sway-error` → Ver las últimas 40 advertencias/errores de `~/.sway_error.log`
- `sway-log-full` → Ver el log completo de Sway

---

## 📂 8. Atajos Básicos de Yazi (Explorador)

- `h` / `l` o `←` / `→` → Subir nivel / Abrir carpeta o archivo
- `j` / `k` o `↓` / `↑` → Navegar arriba / abajo
- `Espacio` → Seleccionar archivo
- `/` → Buscar archivos
- `z` → Salto inteligente con fzf / zoxide
- `y` → Copiar
- `x` → Cortar
- `p` → Pegar
- `d` → Enviar a la papelera
- `q` → Salir de Yazi
