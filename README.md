# 🚀 Guía de Replicación de Entorno Debian 13 (Trixie) con Sway & Fluent Purple

Este repositorio contiene todos los archivos de configuración, scripts de automatización, temas visuales, fuentes tipográficas, iconos y repositorios necesarios para **replicar de forma exacta e idéntica tu entorno actual en cualquier otra PC con Debian**.

---

## 🎨 Características del Entorno Replicado

- **Sistema Base:** Debian GNU/Linux 13 (Trixie) / Debian 12 (Bookworm).
- **Compositor / Entorno de Ventanas:** Sway (Wayland) con atajos modernos, gestión de espacios de trabajo, smart gaps y reglas flotantes.
- **Estética Visual:** Paleta monocromática oscura con acento **Fluent Purple**:
  - Tema GTK: `Fluent-purple-Dark` (soporte completo para GTK2, GTK3 y libadwaita GTK4).
  - Tema Qt: `Kvantum` (`Fluent-purpleDark`) con integración transparente en reproductores como Strawberry.
  - Conjunto de Iconos: `WhiteSur-purple` (variantes estándar, dark y light).
  - Cursores: `Adwaita` unificado a 24px en Wayland y XWayland.
  - Fuentes del Sistema: `Inter` (interfaz), `JetBrains Mono` (terminal), `Symbols Nerd Font` (iconos y glifos de la barra).
- **Terminal:** `Foot` acelerado por GPU, con transparencia acrílica (88%) y colores personalizados.
- **Lanzador y Menú:** `Wofi` configurado para búsqueda de programas (`drun`), historial de portapapeles y menú del sistema.
- **Notificaciones:** `Mako` con estética translúcida, bordes morados y barras de progreso OSD.
- **Barra de Estado:** `Swaybar` nativa minimalista con `status.sh` (monitorea batería con alerta de descarga, perfil energético, uso de RAM, red, brillo, volumen y reloj).
- **Gestión de Energía para Laptops:**
  - Suspensión profunda (`MemorySleepMode=deep`).
  - Acción inteligente de tapa (`lid.sh` apaga la pantalla integrada si hay monitor externo o suspende si no lo hay).
  - Atenuación progresiva (`dimmer.sh` al 10% a los 2 minutos, DPMS a los 3 min, bloqueo a los 5 min, suspensión a los 10 min).
  - Demonios `power-profiles-daemon` y `thermald` activos.
- **Aplicaciones Integradas:**
  - Gestor de archivos: `Thunar` con tema Fluent, aceleradores y transparencia.
  - Navegador Web: `Brave Browser` (repositorio oficial con clave GPG) y `Firefox ESR`.
  - Audio: `Strawberry Music Player` con integración Qt Kvantum, `Pavucontrol`, `PipeWire` y `WirePlumber`.
  - Visor de Medios: `VLC`, `imv` (Wayland).
  - Documentos: `Zathura` con backend PDF Poppler.
  - Captura y Grabación: `OBS Studio` con captura de pantalla por PipeWire Portal.
  - Notas: `Joplin` (AppImage incluido y configurado).

---

## 📁 Estructura del Paquete de Réplica

```text
entorno-debian/
├── install.sh                  # Script principal automatizado de instalación y configuración
├── README.md                   # Esta documentación completa
├── packages/
│   ├── packages.list           # Lista exhaustiva y limpia de paquetes APT necesarios
│   ├── sources.list.debian     # Respaldo del sources.list con contrib y non-free
│   └── brave/
│       ├── brave-browser-release.sources      # Origen del repositorio de Brave
│       └── brave-browser-archive-keyring.gpg  # Clave GPG oficial de Brave
├── dotfiles/
│   ├── .bashrc_additions       # Variables de entorno Wayland/Qt para ~/.bashrc
│   ├── .bashrc.full            # Copia completa de respaldo del .bashrc original
│   ├── .profile                # Variables de sesión de usuario Wayland
│   ├── .gtkrc-2.0              # Configuración de temas GTK 2
│   ├── config/
│   │   ├── sway/               # Configuración de Sway, scripts auxiliares y fondo
│   │   ├── swaylock/           # Bloqueador de pantalla monocromático
│   │   ├── foot/               # Configuración del emulador de terminal
│   │   ├── wofi/               # Configuración y estilos CSS del menú
│   │   ├── mako/               # Configuración del servidor de notificaciones
│   │   ├── environment.d/      # Variables de entorno para la sesión systemd
│   │   ├── gtk-3.0/ & gtk-4.0/ # Ajustes e integración libadwaita
│   │   ├── fontconfig/         # Alias de fuentes hacia Inter
│   │   ├── Kvantum/            # Tema Qt Fluent-purpleDark
│   │   ├── Thunar/ & xfce4/    # Personalización de barras y vistas de archivos
│   │   ├── strawberry/         # Configuración del reproductor Strawberry
│   │   ├── obs-studio/         # Escenas PipeWire y perfiles
│   │   └── mimeapps.list       # Asociaciones de archivos por defecto
│   ├── local_bin/              # Scripts wrappers (strawberry, thunar, sassc)
│   └── desktop_entries/        # Lanzadores personalizados (.desktop)
├── assets/
│   ├── fonts/                  # Familia Symbols Nerd Font
│   ├── themes/                 # Tema completo Fluent-purple-Dark
│   ├── icons/                  # Familia de iconos WhiteSur-purple (std, dark, light)
│   ├── wallpaper/              # Fondo de pantalla oficial (fondo.jpg)
│   ├── local_usr/              # Librerías y binarios locales (libadwaita-qt6, Kvantum)
│   └── joplin/                 # Joplin.AppImage listo para ejecutar
└── system/
    ├── sleep.conf.d/           # Configuración de suspensión profunda en RAM
    ├── logind.conf.d/          # Manejo de cierre de tapa en laptop
    └── grub.default            # Referencia de parámetros de inicio del kernel
```

---

## 🛠️ Cómo Replicar en la Nueva PC (Paso a Paso)

### Paso 1: Instalar Debian
Instala **Debian 13 (Trixie)** o Debian 12 en la nueva computadora (instalación base / estándar, sin entorno de escritorio pesado o con entorno mínimo).

### Paso 2: Transferir esta Carpeta a la Nueva PC
Puedes comprimir y transferir esta carpeta mediante un pendrive USB o por red local:

```bash
# Para comprimir desde tu PC actual (si deseas moverlo en un solo archivo):
cd ~/Documentos
tar -czvf entorno-debian.tar.gz entorno-debian/
```

En la nueva PC, descomprime la carpeta en `~/Documentos/`:
```bash
cd ~/Documentos
tar -xzvf entorno-debian.tar.gz
cd entorno-debian
```

### Paso 3: Ejecutar el Instalador
El instalador detecta automáticamente el usuario objetivo y adapta todas las rutas internas (evitando problemas de nombres de usuario distintos).

```bash
cd ~/Documentos/entorno-debian

# 1. Asegurar permisos de ejecución:
chmod +x install.sh

# 2. Ejecutar el instalador interactivo:
./install.sh

# O si prefieres una instalación 100% desatendida sin preguntas:
./install.sh --yes
```

> [!NOTE]
> El script solicitará tu contraseña de `sudo` para instalar paquetes del sistema, configurar repositorios y habilitar demonios de energía.

### Paso 4: Reiniciar el Equipo
Al finalizar la ejecución, reinicia el equipo para que los nuevos grupos de usuario (`video`, `audio`, `input`, etc.) y los servicios de sistema tomen efecto:

```bash
sudo reboot
```

### Paso 5: Iniciar el Entorno Sway
Al reiniciar, inicia sesión en la consola TTY con tu usuario y contraseña, y escribe:

```bash
sway
```

¡Listo! Todo tu entorno cargará idéntico al actual.

---

## ⌨️ Atajos de Teclado Principales en Sway

| Atajo | Acción |
| :--- | :--- |
| **`Super + Enter`** | Abrir terminal **Foot** con tema Fluent Purple |
| **`Super + d`** | Abrir lanzador de programas **Wofi** |
| **`Super + 0`** | Menú de apagado, suspensión, bloqueo y perfiles de energía |
| **`Super + c`** | Historial de portapapeles con **cliphist** |
| **`Super + Shift + q`** | Cerrar la ventana activa |
| **`Super + f`** | Pantalla completa (fullscreen) |
| **`Super + Shift + Espacio`** | Alternar modo flotante en ventana activa |
| **`Super + Espacio`** | Alternar foco entre ventanas flotantes y en mosaico |
| **`Super + b`** / **`Super + v`** | División horizontal / vertical para nuevas ventanas |
| **`Super + 1`** a **`9`** | Cambiar al espacio de trabajo (workspace) 1 a 9 |
| **`Super + Shift + 1`** a **`9`** | Mover ventana activa al espacio de trabajo 1 a 9 |
| **`Print`** | Captura de pantalla completa (guardada en `~/Imágenes/Capturas` y al portapapeles) |
| **`Shift + Print`** | Captura de área seleccionada con el cursor |
| **`Teclas Fn de Brillo`** | Subir / bajar brillo de pantalla con notificación OSD en tiempo real |
| **`Teclas Fn de Volumen`** | Subir / bajar / silenciar volumen o micrófono con barra OSD |
| **`Teclas Fn Multimedia`** | Reproducir / pausar / siguiente pista en Strawberry, Brave, Firefox, etc. |

---

## ⚙️ Ajustes Adicionales y Opcionales

### Cambiar el Fondo de Pantalla
Si deseas cambiar el fondo, simplemente reemplaza la imagen en:
`~/.config/sway/wallpaper.jpg` o `~/Imágenes/fondo.jpg`
Y recarga Sway con: **`Super + Shift + c`**

### Parámetros silenciosos de inicio (GRUB)
Si deseas una pantalla de inicio limpia y silenciosa idéntica a la actual:
1. Abre `/etc/default/grub` con permisos de administrador:
   ```bash
   sudo nano /etc/default/grub
   ```
2. Modifica la línea:
   ```ini
   GRUB_CMDLINE_LINUX_DEFAULT="quiet loglevel=3"
   ```
3. Actualiza el cargador de arranque:
   ```bash
   sudo update-grub
   ```

### Disposición de Teclado
Por defecto, la configuración incluye teclado en **Español de España y Latinoamérica**, alternables con **`Alt + Shift`**. Puedes ajustar esto en cualquier momento editando `~/.config/sway/config`:
```sway
input "type:keyboard" {
    xkb_layout "es,latam"
    xkb_options "grp:alt_shift_toggle"
}
```
