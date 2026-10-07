# 🎮 Guía de Optimización Gaming & Rendimiento en MangoWM / Wayland

Esta guía detalla las optimizaciones de bajo nivel y mejores prácticas configuradas en este dotfile para extraer el **máximo rendimiento, menor latencia de entrada y máxima estabilidad** en juegos bajo Arch Linux, MangoWM y gráficos AMD Radeon (APU Vega / GPUs dedicadas).

---

## ⚡ 1. Resumen de Optimizaciones Implementadas

### A. Compositor MangoWM (Bypass de Latencia Wayland)
* **Tearing a pantalla completa (`allow_tearing=2`)**:
  - Wayland por defecto fuerza sincronización vertical doble o triple buffer (VSync), agregando 1-2 cuadros de retardo de entrada (*input lag*).
  - Con `allow_tearing=2`, el escritorio diario se mantiene 100% fluido y sin desgarro, pero **los juegos a pantalla completa desbloquean el renderizado directo sin VSync** para una respuesta instantánea de ratón y teclado.
* **Sincronización DRM Explícita (`syncobj_enable=1`)**:
  - Habilita los objetos de sincronización en línea de tiempo (`drm_syncobj`), eliminando el micro-stuttering y problemas de fotogramas desincronizados en Wayland.
* **Salida Primaria X11 (`primary:1`)**:
  - Configurado en `monitor.conf` (`name:HDMI-A-1,...,primary:1`). Garantiza que juegos bajo XWayland (la gran mayoría de Steam/Proton) detecten el origen de coordenadas correcto y no sufran descalibración del puntero.
* **FreeSync / Adaptive Sync (`vrr:1`)**:
  - Tasa de refresco variable activa a 120Hz sin parpadeos.
* **Reglas de Ventana de Cero Overhead (`rule.conf`)**:
  - Para `steam_app_*`, `gamescope`, `cs2`, `heroic`, `lutris`, `wine`, `proton`, emuladores:
    - `force_tearing:1`: Fuerza modo directo de latencia mínima.
    - `isnoanimation:1`: 0% de uso de CPU/GPU en transiciones.
    - `isnoshadow:1`: Desactiva cálculo de sombras bajo el juego.
    - `noblur:1`: Sin efectos de desenfoque.
    - `idleinhibit_when_focus:1`: Previene que la pantalla se apague al jugar con mando.

---

### B. Driver Gráfico Mesa & AMD Radeon
Ubicado en `~/.config/environment.d/10-wayland.conf` y `~/.config/mango/env.conf`:
* `mesa_glthread=true`: Hilo de renderizado multinúcleo para OpenGL en Mesa. Aumenta drásticamente los FPS (15-30%) en títulos OpenGL, Minecraft, emuladores y juegos antiguos.
* `AMD_VULKAN_ICD=RADV` y `RADV_PERFTEST=aco`: Compilador de shaders ACO de Valve para AMD, compilando shaders mucho más rápido y reduciendo los tirones (*shader compilation stutter*).
* `SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0`: Evita que juegos con SDL2/SDL3 se minimicen bruscamente al perder el foco momentáneamente.

---

### C. Feral GameMode (`~/.config/gamemode.ini`)
Cuando un juego se ejecuta con `gamemoderun`:
1. Cambia el gobernador de la CPU a **Performance** (frecuencias máximas sin caídas por ahorro energético).
2. Asigna prioridad de proceso **renice -10** e **I/O de disco prioritario** al juego.
3. **Pausa automática de notificaciones**: Silencia notificaciones de Dunst para evitar pérdidas de foco o distracciones (`dunstctl set-paused true`). Al cerrar el juego, las restaura automáticamente.

---

### D. MangoHud Moderno (`~/.config/MangoHud/MangoHud.conf`)
* Overlay minimalista y translúcido en la esquina superior izquierda.
* Monitoriza en tiempo real: FPS, frametime graph, temperatura y reloj de GPU AMD, temperatura y carga de CPU Ryzen, VRAM y RAM.
* **Atajo para mostrar/ocultar en juego**: `Shift Derecho + F12`.
* **Atajo para alternar límite de FPS**: `Shift Izquierdo + F1`.

---

## 🚀 2. Cómo Usar las Optimizaciones

### En Steam:
Haz clic derecho en cualquier juego -> **Propiedades** -> **General** -> **Parámetros de lanzamiento**:

```bash
gamemoderun mangohud %command%
```
*(Si no quieres el HUD de estadísticas, simplemente usa: `gamemoderun %command%`)*

Para juegos con problemas de resolución o tasa de refresco, puedes envolverlo en Gamescope:
```bash
gamemoderun gamescope -w 1920 -h 1080 -r 120 -- %command%
```

### En Heroic Games Launcher (Epic Games / GOG):
1. Ve a **Ajustes** -> **Juegos**.
2. Activa la casilla **Usar GameMode**.
3. Activa la casilla **Usar MangoHud**.

### En Lutris:
1. Preferencias -> **Opciones del sistema**.
2. Activa **Habilitar Feral GameMode**.
3. Activa **MangoHud**.

### Desde el Escritorio (MangoWM):
* Presiona **`Super + Shift + G`**: Abre el **Gaming Hub** donde puedes iniciar Steam con GameMode, abrir el monitor de recursos (`btop`) o comprobar el estado de GameMode.
* O desde la terminal:
  ```bash
  game-launch.sh <comando-del-juego>
  ```

---

## 🌐 3. Cómo Compartir esta Configuración con Otros

Para compartir esta configuración con amigos o en tu repositorio público de GitHub:

1. **Estructura Modular**:
   - `config/gamemode.ini`: Perfil de GameMode.
   - `config/MangoHud/MangoHud.conf`: Configuración estética de MangoHud.
   - `config/mango/rule.conf`: Reglas de ventana gaming sin overhead.
   - `config/mango/config.conf`: Configuración de tearing y syncobj de MangoWM.
   - `config/environment.d/10-wayland.conf`: Variables de entorno AMD / Mesa.
   - `scripts/game-launch.sh`: Script utilitario y menú Wofi.

2. **Instalación con un solo comando**:
   Cualquier usuario con Arch Linux puede clonar tu repositorio y ejecutar:
   ```bash
   bash setup.sh
   ```
   El script aplicará automáticamente todas las configuraciones, copiará las reglas de gaming, instalará los scripts en `~/.local/bin` y recargará MangoWM en vivo.

3. **Dependencias recomendadas**:
   ```bash
   sudo pacman -S gamemode mangohud gamescope lib32-gamemode lib32-mangohud
   ```
