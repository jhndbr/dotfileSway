# 🌌 SwayShell — Minimalist & Aesthetic Quickshell for Sway

Una shell moderna, ultraligera y personalizable desarrollada en **Quickshell (QtQuick/QML)** diseñada específicamente para el compositor **Sway (Wayland)** en **Debian Trixie (Debian 13)**.

Diseñada bajo una filosofía **estrictamente minimalista**: incluye únicamente los componentes indispensables de un entorno de escritorio sin bloat innecesario, pero con acabados visuales pulidos, glassmorphism suave, soporte para múltiples paletas de colores (Catppuccin, Tokyo Night, Nord, Gruvbox, OLED), integración completa de portapapeles, capturas de pantalla, terminal **Foot** y plantillas para **GTK** y **Qt**.

---

## ✨ Componentes Incluidos

1. **Barra de Estado (Top o Bottom, Flotante o Edge-to-Edge)**:
   - **Workspaces Dinámicos**: Sincronización nativa con Sway IPC (`Quickshell.I3`), indicador de espacio activo, estados de urgencia, scroll para cambiar de espacio.
   - **Ventana Activa**: Muestra el título e icono de la ventana enfocada usando `wlr-foreign-toplevel` (click derecho para cerrar).
   - **Gestor de Portapapeles**: Píldora interactiva con acceso al historial de copiado.
   - **Reproductor Multimedia (MPRIS)**: Título y artista de música/vídeo con controles integrados de reproducción y salto.
   - **Bandeja del Sistema (System Tray)**: Soporte completo para iconos de aplicaciones en segundo plano (Discord, Telegram, Steam, NetworkManager, etc.).
   - **Control de Volumen (Pipewire)**: Nivel en porcentaje, icono dinámico, scroll para ajustar volumen y click para silenciar.
   - **Control de Brillo**: Lectura y ajuste fluido con `brightnessctl`.
   - **Batería (UPower)**: Indicador de carga y porcentaje con alertas visuales de batería baja.
   - **Reloj y Fecha**: Con popup desplegable de calendario mensual interactivo.
   - **Menú de Apagado/Sesión**: Acceso directo con estética minimalista.

2. **Gestor de Portapapeles Flotante (`Super + V`)**:
   - Modal flotante tipo Spotlight integrado con `cliphist` y `wl-clipboard`.
   - Búsqueda en tiempo real dentro del historial copiado.
   - Presiona `Enter` para copiar y `Supr` para borrar un elemento.
   - Botón para vaciar todo el historial.

3. **Herramienta de Capturas de Pantalla (`Print` / `Super + Shift + S`)**:
   - Integración nativa mediante `grim` + `slurp` + `wl-clipboard`.
   - Copia directamente la imagen capturada al portapapeles y la guarda en `~/Pictures/Screenshots/`.
   - Dispara una notificación interactiva con botones para "Ver captura" y "Abrir carpeta".
   - Modos:
     - `Print` o `Super + Shift + S`: Selección de región.
     - `Shift + Print`: Pantalla completa.
     - `Super + Print`: Ventana activa.

4. **Lanzador de Aplicaciones (Spotlight / Raycast Style) (`Super + D`)**:
   - Modal flotante centrado.
   - Búsqueda instantánea de aplicaciones `.desktop` del sistema.
   - Navegación total por teclado (Flechas ↑/↓, Enter para ejecutar, Escape para cerrar).

5. **Terminal Foot Integrado**:
   - Terminal Wayland ultrarrápido y ligero.
   - Plantilla con tipografía (JetBrains Mono / Inter), espaciado suave, cursor animado y paleta de colores sincronizada.

6. **Personalización y Plantillas de Temas (GTK 3/4 & Qt 5/6)**:
   - Plantillas automáticas de colores CSS para GTK 3 y GTK 4 (`~/.config/gtk-3.0/gtk.css` y `~/.config/gtk-4.0/gtk.css`).
   - Plantillas de configuración para `qt5ct` y `qt6ct`.
   - Script maestro `scripts/apply-theme.sh <tema>` para cambiar el tema en todo el sistema simultáneamente.

7. **Sistema de Notificaciones (Toasts)**:
   - Servidor nativo con animaciones de entrada/salida y soporte para acciones.

8. **On-Screen Display (OSD)**:
   - Indicador visual flotante que aparece brevemente al cambiar volumen o brillo por teclas multimedia.

9. **Menú de Energía / Cierre de Sesión (`Super + Shift + E`)**:
   - `L`: Bloquear (`swaylock`) | `E`: Salir de Sway | `S`: Suspender | `R`: Reiniciar | `P`: Apagar | `Esc`: Cancelar.

---

## 📁 Estructura del Proyecto

```text
sway-shell/
├── shell.qml                  # Punto de entrada ShellRoot + IpcHandler
├── Config.qml                 # Opciones de usuario (toggles de módulos, posición, márgenes)
├── Theme.qml                  # Paletas (Catppuccin, Tokyo Night, Nord, Gruvbox, OLED)
│
├── services/                  # Servicios Wayland/Linux
│   ├── SwayService.qml        # Quickshell.I3 (workspaces, dispatch)
│   ├── AudioService.qml       # Pipewire (volumen, mute)
│   ├── BrightnessService.qml  # brightnessctl
│   ├── BatteryService.qml     # UPower
│   ├── NetworkService.qml     # NetworkManager
│   ├── MprisService.qml       # Reproductores multimedia
│   ├── NotificationService.qml# Servidor de notificaciones
│   ├── ClipboardService.qml   # Integración con cliphist
│   ├── ScreenshotService.qml  # Capturas de pantalla
│   └── OsdService.qml         # Coordinador de popups OSD
│
├── widgets/                   # Widgets modulares de la barra
│   ├── WorkspacesWidget.qml
│   ├── FocusedWindowWidget.qml
│   ├── ClipboardWidget.qml
│   ├── MediaWidget.qml
│   ├── TrayWidget.qml
│   ├── AudioWidget.qml
│   ├── BrightnessWidget.qml
│   ├── BatteryWidget.qml
│   ├── NetworkWidget.qml
│   ├── ClockWidget.qml
│   └── PowerButtonWidget.qml
│
├── windows/                   # Ventanas y capas LayerShell
│   ├── BarWindow.qml          # Barra de estado
│   ├── AppLauncher.qml        # Spotlight launcher
│   ├── ClipboardModal.qml     # Gestor de portapapeles
│   ├── SessionModal.qml       # Menú de energía
│   ├── NotificationPopup.qml  # Toasts de notificación
│   ├── OsdWindow.qml          # OSD de brillo y volumen
│   └── CalendarModal.qml      # Dropdown de calendario
│
├── templates/                 # Plantillas de temas para apps externas
│   ├── foot/foot.ini
│   ├── gtk-3.0/
│   ├── gtk-4.0/
│   ├── qt5ct/
│   └── qt6ct/
│
├── scripts/
│   ├── apply-theme.sh         # Generador y aplicador de temas
│   └── screenshot.sh          # Script de captura, guardado y notificación
│
├── sway/
│   ├── config                 # Configuración de Sway lista para usar
│   └── config.snippet         # Snippet para incluir en un config existente
├── install.sh                 # Instalador y verificador
└── README.md
```

---

## 🚀 Instalación en Debian Trixie

### 1. Instalar dependencias esenciales
```bash
sudo apt update
sudo apt install -y \
    sway \
    foot \
    cliphist \
    wl-clipboard \
    grim \
    slurp \
    swappy \
    jq \
    brightnessctl \
    pipewire \
    wireplumber \
    pipewire-pulse \
    pavucontrol \
    swaylock \
    swaybg \
    qt6ct \
    qt5ct \
    fonts-inter \
    fonts-jetbrains-mono \
    fonts-font-awesome
```

### 2. Quickshell en Debian Trixie
En Debian Trixie (Debian 13), la versión oficial de Qt es **Qt 6.8.2**. Los paquetes `.deb` precompilados de repositorios externos (como OBS/danklinux) se compilan frecuentemente contra Qt 6.11, lo cual genera un conflicto estricto de ABI privada (`qt6-base-private-abi = 6.11.2`).

Por ello, el script [`install.sh`](file:///home/jhon/Documentos/swayshell/sway-shell/install.sh) ahora **compila e instala Quickshell automáticamente desde las fuentes de forma nativa contra el Qt 6.8 de Debian Trixie**:
- Instala los paquetes de desarrollo oficiales (`qt6-base-dev`, `qt6-declarative-dev`, etc.).
- Compila Quickshell con CMake + Ninja con todas las capacidades activadas (Wayland, LayerShell, Pipewire, UPower, Mpris, etc.).
- Instala el binario resultante en `/usr/local/bin/quickshell` de forma limpia y permanente.

### 3. Ejecutar el Instalador
```bash
cd ~/Documentos/swayshell/sway-shell
./install.sh
```
El instalador:
1. Limpia cualquier repositorio externo con conflictos de versión.
2. Instala todas las dependencias del sistema con `apt`.
3. Compila e instala Quickshell automáticamente de manera nativa.
4. Configura variables de entorno Wayland/Qt (`~/.config/environment.d/`).
5. Despliega la configuración de `swayshell`.
6. Genera y aplica las plantillas para Foot, GTK 3/4 y Qt.
7. Instala la configuración de Sway sin colisiones de atajos.

---

## 🎨 Aplicar Temas en Todo el Sistema

Para sincronizar los colores de la barra, Foot, GTK y Qt a otro estilo:

```bash
~/.config/quickshell/swayshell/scripts/apply-theme.sh [catppuccin|tokyonight|nord|gruvbox|oled]
```

Luego en [`Config.qml`](file:///home/jhon/Documentos/swayshell/sway-shell/Config.qml) ajusta:
```qml
property string activeTheme: "catppuccin" // O "tokyonight", "nord", "gruvbox", "oled"
```

---

## ⌨️ Atajos de Teclado en Sway

| Atajo | Acción |
|---|---|
| `Super + Return` | Abrir terminal **Foot** |
| `Super + D` | Abrir / Cerrar Lanzador de Aplicaciones |
| `Super + V` | Abrir / Cerrar Historial del **Portapapeles** |
| `Print` o `Super + Shift + S` | Captura de pantalla de **región** |
| `Shift + Print` | Captura de pantalla **completa** |
| `Super + Print` | Captura de **ventana activa** |
| `Super + Shift + E` | Abrir Menú de Energía y Sesión |
| `Super + C` | Abrir / Cerrar Calendario |
| `Teclas de Volumen` | Ajustar volumen con OSD visual |
| `Teclas de Brillo` | Ajustar brillo con OSD visual |
| `Teclas Multimedia` | Play/Pausa, Siguiente, Anterior |

---

## 💻 Comandos IPC

Todos los módulos se pueden controlar por línea de comandos:

```bash
# Portapapeles
quickshell ipc call clipboard toggle
quickshell ipc call clipboard wipe

# Capturas de pantalla
quickshell ipc call screenshot region
quickshell ipc call screenshot fullscreen
quickshell ipc call screenshot window

# Lanzador y sesión
quickshell ipc call launcher toggle
quickshell ipc call session toggle
quickshell ipc call calendar toggle

# Audio y brillo
quickshell ipc call audio raise
quickshell ipc call audio lower
quickshell ipc call audio mute
quickshell ipc call brightness raise
quickshell ipc call brightness lower
```
