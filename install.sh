#!/usr/bin/env bash
# ==============================================================================
# Script de Replicación de Entorno Debian 13 (Trixie) con Sway & Fluent Purple
# ==============================================================================
# Este script automatiza la instalación y configuración completa del entorno
# en una instalación limpia de Debian GNU/Linux.
#
# Componentes principales instalados:
#  - Sway (Gestor de ventanas Wayland minimalista y optimizado para laptops)
#  - Foot (Terminal GPU con paleta Fluent Purple)
#  - Wofi (Lanzador de aplicaciones y menú del sistema)
#  - Mako (Servidor de notificaciones Wayland)
#  - Swaylock + Swayidle (Bloqueo y gestión inteligente de energía/atenuación)
#  - PipeWire + WirePlumber + Pavucontrol (Audio moderno de baja latencia)
#  - Tema Fluent-purple-Dark + Iconos WhiteSur-purple + Kvantum (Qt/GTK unificado)
#  - Fuentes Inter, JetBrains Mono y Symbols Nerd Font
#  - Thunar, Strawberry Music, VLC, Zathura, OBS Studio, Brave Browser
#
# USO:
#   chmod +x install.sh
#   ./install.sh [OPCIONES]
#
# OPCIONES:
#   -y, --yes       Ejecución automática sin confirmaciones interactivas
#   --dry-run       Muestra las acciones que se realizarían sin aplicar cambios
#   -h, --help      Muestra esta ayuda
# ==============================================================================

set -euo pipefail

# Colores para la interfaz de consola
CLR_RESET="\033[0m"
CLR_BOLD="\033[1m"
CLR_RED="\033[1;31m"
CLR_GREEN="\033[1;32m"
CLR_YELLOW="\033[1;33m"
CLR_BLUE="\033[1;34m"
CLR_PURPLE="\033[1;35m"
CLR_CYAN="\033[1;36m"

# Flags de ejecución
AUTO_YES=false
DRY_RUN=false

# Directorio raíz del repositorio de réplica
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Funciones de registro en consola
log_info() {
    echo -e "${CLR_BLUE}[INFO]${CLR_RESET} $1"
}

log_step() {
    echo -e "\n${CLR_PURPLE}${CLR_BOLD}=== $1 ===${CLR_RESET}"
}

log_success() {
    echo -e "${CLR_GREEN}[OK]${CLR_RESET} $1"
}

log_warn() {
    echo -e "${CLR_YELLOW}[AVISO]${CLR_RESET} $1"
}

log_error() {
    echo -e "${CLR_RED}[ERROR]${CLR_RESET} $1" >&2
}

# Procesar argumentos de línea de comandos
while [[ $# -gt 0 ]]; do
    case "$1" in
        -y|--yes)
            AUTO_YES=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            echo "Uso: $0 [-y|--yes] [--dry-run]"
            exit 0
            ;;
        *)
            log_error "Opción desconocida: $1"
            echo "Usa $0 --help para más información."
            exit 1
            ;;
    esac
done

# Función de ejecución segura respetando --dry-run
run_cmd() {
    if [ "$DRY_RUN" = true ]; then
        echo -e "${CLR_CYAN}[DRY-RUN]${CLR_RESET} $*"
    else
        "$@"
    fi
}

# Función para comandos con privilegios root (sudo)
run_sudo() {
    if [ "$DRY_RUN" = true ]; then
        echo -e "${CLR_CYAN}[DRY-RUN-SUDO]${CLR_RESET} $*"
    else
        if [ "$(id -u)" -eq 0 ]; then
            "$@"
        else
            sudo "$@"
        fi
    fi
}

# Confirmación interactiva si no se especificó --yes
confirm() {
    local prompt="$1"
    if [ "$AUTO_YES" = true ]; then
        return 0
    fi
    echo -en "${CLR_YELLOW}[?] ${prompt} [S/n]: ${CLR_RESET}"
    read -r respuesta
    case "$respuesta" in
        [nN][oO]|[nN])
            return 1
            ;;
        *)
            return 0
            ;;
    esac
}

# ------------------------------------------------------------------------------
# 0. Verificaciones Previas e Identificación de Usuario
# ------------------------------------------------------------------------------
log_step "Paso 0: Verificación del Sistema y Usuario"

if [ -f /etc/os-release ]; then
    . /etc/os-release
    log_info "Sistema detectado: ${PRETTY_NAME:-$NAME}"
    if [[ "${ID:-}" != "debian" && "${ID_LIKE:-}" != *"debian"* ]]; then
        log_warn "Este instalador está diseñado específicamente para Debian GNU/Linux."
        confirm "¿Deseas continuar de todas formas?" || exit 1
    fi
else
    log_warn "No se pudo leer /etc/os-release."
fi

# Determinar el usuario real objetivo (incluso si se ejecutó con sudo)
if [ "$(id -u)" -eq 0 ]; then
    if [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != "root" ]; then
        TARGET_USER="$SUDO_USER"
    else
        echo -en "${CLR_YELLOW}[?] Ingrese el nombre del usuario regular al que se le aplicará la configuración: ${CLR_RESET}"
        read -r TARGET_USER
        if [ -z "$TARGET_USER" ] || ! id "$TARGET_USER" >/dev/null 2>&1; then
            log_error "El usuario '$TARGET_USER' no existe en el sistema."
            exit 1
        fi
    fi
else
    TARGET_USER="$USER"
fi

TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
TARGET_GID="$(id -g "$TARGET_USER")"

log_info "Usuario objetivo: ${CLR_BOLD}${TARGET_USER}${CLR_RESET}"
log_info "Directorio Home:  ${CLR_BOLD}${TARGET_HOME}${CLR_RESET}"
log_info "Directorio base:  ${SCRIPT_DIR}"

if [ ! -d "$TARGET_HOME" ]; then
    log_error "El directorio home $TARGET_HOME no existe."
    exit 1
fi

confirm "¿Deseas iniciar la réplica del entorno para $TARGET_USER?" || {
    log_info "Instalación cancelada por el usuario."
    exit 0
}

# ------------------------------------------------------------------------------
# 1. Configuración de Repositorios APT (contrib, non-free, Brave)
# ------------------------------------------------------------------------------
log_step "Paso 1: Configuración de Repositorios APT"

# Asegurar curl, ca-certificates y gpg
log_info "Instalando paquetes básicos para gestión de repositorios..."
run_sudo apt update -y || true
run_sudo apt install -y curl ca-certificates gpg

# Instalar clave y repositorio de Brave Browser
BRAVE_KEY="$SCRIPT_DIR/packages/brave/brave-browser-archive-keyring.gpg"
BRAVE_SOURCES="$SCRIPT_DIR/packages/brave/brave-browser-release.sources"

if [ -f "$BRAVE_KEY" ] && [ -f "$BRAVE_SOURCES" ]; then
    log_info "Copiando clave y repositorio de Brave Browser..."
    run_sudo mkdir -p /usr/share/keyrings /etc/apt/sources.list.d
    run_sudo cp "$BRAVE_KEY" /usr/share/keyrings/brave-browser-archive-keyring.gpg
    run_sudo cp "$BRAVE_SOURCES" /etc/apt/sources.list.d/brave-browser-release.sources
    run_sudo chmod 644 /usr/share/keyrings/brave-browser-archive-keyring.gpg /etc/apt/sources.list.d/brave-browser-release.sources
else
    log_warn "Archivos de repositorio Brave no encontrados en packages/brave. Descargando clave oficial..."
    run_sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    run_sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
fi

# Verificar si contrib, non-free y non-free-firmware están habilitados
if [ -f /etc/apt/sources.list ]; then
    if ! grep -q "non-free-firmware" /etc/apt/sources.list && ! grep -q "non-free" /etc/apt/sources.list; then
        log_warn "Los componentes 'contrib', 'non-free' y 'non-free-firmware' podrían no estar habilitados."
        if confirm "¿Deseas añadir 'contrib non-free non-free-firmware' a tus repositorios en sources.list?"; then
            run_sudo sed -i -E 's/main$/main contrib non-free non-free-firmware/g' /etc/apt/sources.list
            log_success "Componentes añadidos a /etc/apt/sources.list"
        fi
    fi
fi

log_info "Actualizando índices de paquetes APT..."
run_sudo apt update -y
log_success "Repositorios configurados correctamente."

# ------------------------------------------------------------------------------
# 2. Instalación de Paquetes APT
# ------------------------------------------------------------------------------
log_step "Paso 2: Instalación de Paquetes APT"

PKG_LIST_FILE="$SCRIPT_DIR/packages/packages.list"
if [ ! -f "$PKG_LIST_FILE" ]; then
    log_error "No se encontró el archivo $PKG_LIST_FILE."
    exit 1
fi

# Extraer lista de paquetes filtrando comentarios y líneas vacías
mapfile -t PACKAGES < <(grep -E '^[a-zA-Z0-9_-]+' "$PKG_LIST_FILE")

log_info "Se instalarán ${#PACKAGES[@]} paquetes esenciales desde Debian APT..."
run_sudo apt install -y "${PACKAGES[@]}"

# Instalar Brave Browser
log_info "Instalando Brave Browser..."
run_sudo apt install -y brave-browser || run_sudo apt install -y brave-origin || log_warn "No se pudo instalar Brave Browser automáticamente."

log_success "Todos los paquetes APT fueron instalados con éxito."

# ------------------------------------------------------------------------------
# 3. Configuración de Grupos de Usuario
# ------------------------------------------------------------------------------
log_step "Paso 3: Asignación de Grupos de Usuario"

# Grupos requeridos para brillo, audio, periféricos, bluetooth y video sin root
REQUIRED_GROUPS=("video" "audio" "input" "plugdev" "netdev" "bluetooth")

for grp in "${REQUIRED_GROUPS[@]}"; do
    if getent group "$grp" >/dev/null 2>&1; then
        log_info "Añadiendo a $TARGET_USER al grupo $grp..."
        run_sudo usermod -aG "$grp" "$TARGET_USER"
    else
        log_warn "El grupo $grp no existe en este sistema (ignorado)."
    fi
done

log_success "Permisos de grupos configurados para $TARGET_USER."

# ------------------------------------------------------------------------------
# 4. Optimizaciones del Sistema (Suspensión, Tapa y Servicios)
# ------------------------------------------------------------------------------
log_step "Paso 4: Optimizaciones del Sistema y Gestión de Energía"

# Configuración de suspensión profunda (Deep Sleep)
if [ -d "$SCRIPT_DIR/system/sleep.conf.d" ]; then
    log_info "Instalando configuración de suspensión profunda en /etc/systemd/sleep.conf.d/..."
    run_sudo mkdir -p /etc/systemd/sleep.conf.d
    run_sudo cp "$SCRIPT_DIR/system/sleep.conf.d/"*.conf /etc/systemd/sleep.conf.d/ 2>/dev/null || true
fi

# Configuración de la tapa (Lid Switch)
if [ -d "$SCRIPT_DIR/system/logind.conf.d" ]; then
    log_info "Instalando configuración de tapa en /etc/systemd/logind.conf.d/..."
    run_sudo mkdir -p /etc/systemd/logind.conf.d
    run_sudo cp "$SCRIPT_DIR/system/logind.conf.d/"*.conf /etc/systemd/logind.conf.d/ 2>/dev/null || true
fi

# Habilitar servicios de gestión térmica y de energía para laptop
log_info "Habilitando servicios power-profiles-daemon y thermald..."
run_sudo systemctl enable --now power-profiles-daemon 2>/dev/null || true
run_sudo systemctl enable --now thermald 2>/dev/null || true

log_success "Ajustes de energía y demonios habilitados."

# ------------------------------------------------------------------------------
# 5. Despliegue de Assets (Fuentes, Temas, Iconos, Librerías Qt/Kvantum)
# ------------------------------------------------------------------------------
log_step "Paso 5: Instalación de Fuentes, Temas e Iconos"

# 5.1 Fuentes tipográficas
if [ -d "$SCRIPT_DIR/assets/fonts/NerdFonts" ]; then
    log_info "Instalando fuente Symbols Nerd Font..."
    run_cmd mkdir -p "$TARGET_HOME/.local/share/fonts/NerdFonts"
    run_cmd cp -r "$SCRIPT_DIR/assets/fonts/NerdFonts/"* "$TARGET_HOME/.local/share/fonts/NerdFonts/"
    if [ "$DRY_RUN" = false ]; then
        fc-cache -f "$TARGET_HOME/.local/share/fonts" || true
    fi
    log_success "Fuentes instaladas y caché actualizado."
fi

# 5.2 Tema GTK Fluent-purple-Dark
if [ -d "$SCRIPT_DIR/assets/themes/Fluent-purple-Dark" ]; then
    log_info "Instalando tema Fluent-purple-Dark en ~/.themes y ~/.local/share/themes..."
    run_cmd mkdir -p "$TARGET_HOME/.themes" "$TARGET_HOME/.local/share/themes"
    run_cmd cp -r "$SCRIPT_DIR/assets/themes/Fluent-purple-Dark" "$TARGET_HOME/.themes/"
    run_cmd ln -sfn "$TARGET_HOME/.themes/Fluent-purple-Dark" "$TARGET_HOME/.local/share/themes/Fluent-purple-Dark"
    log_success "Tema GTK instalado."
fi

# 5.3 Iconos WhiteSur-purple
if [ -d "$SCRIPT_DIR/assets/icons" ]; then
    log_info "Instalando conjunto de iconos WhiteSur-purple..."
    run_cmd mkdir -p "$TARGET_HOME/.local/share/icons" "$TARGET_HOME/.icons"
    run_cmd cp -r "$SCRIPT_DIR/assets/icons/"* "$TARGET_HOME/.local/share/icons/"
    
    # Crear enlaces simbólicos en ~/.icons para compatibilidad retroactiva
    for ico in WhiteSur-purple WhiteSur-purple-dark WhiteSur-purple-light hicolor; do
        if [ -d "$TARGET_HOME/.local/share/icons/$ico" ]; then
            run_cmd ln -sfn "$TARGET_HOME/.local/share/icons/$ico" "$TARGET_HOME/.icons/$ico"
        fi
    done
    log_success "Iconos instalados y vinculados."
fi

# 5.4 Librerías locales Qt / Kvantum (~/.local/usr)
if [ -d "$SCRIPT_DIR/assets/local_usr" ]; then
    log_info "Instalando librerías y utilidades personalizadas en ~/.local/usr..."
    run_cmd mkdir -p "$TARGET_HOME/.local/usr"
    run_cmd cp -r "$SCRIPT_DIR/assets/local_usr/"* "$TARGET_HOME/.local/usr/"
    log_success "Librerías Qt/Kvantum desplegadas en ~/.local/usr."
fi

# 5.5 Fondo de pantalla
run_cmd mkdir -p "$TARGET_HOME/Imágenes" "$TARGET_HOME/.config/sway"
if [ -f "$SCRIPT_DIR/assets/wallpaper/fondo.jpg" ]; then
    log_info "Instalando fondo de pantalla..."
    run_cmd cp "$SCRIPT_DIR/assets/wallpaper/fondo.jpg" "$TARGET_HOME/Imágenes/fondo.jpg"
    run_cmd cp "$SCRIPT_DIR/assets/wallpaper/fondo.jpg" "$TARGET_HOME/.config/sway/wallpaper.jpg"
    log_success "Fondo de pantalla colocado en ~/Imágenes y ~/.config/sway."
fi

# ------------------------------------------------------------------------------
# 6. Despliegue de Dotfiles y Configuraciones
# ------------------------------------------------------------------------------
log_step "Paso 6: Despliegue de Dotfiles y Adaptación de Rutas"

# 6.1 Crear backup si ya existe ~/.config/sway
if [ -d "$TARGET_HOME/.config/sway" ]; then
    BACKUP_DIR="$TARGET_HOME/.config/sway.backup_$(date +%Y%m%d_%H%M%S)"
    log_info "Creando respaldo de configuración sway previa en $BACKUP_DIR..."
    run_cmd cp -r "$TARGET_HOME/.config/sway" "$BACKUP_DIR"
fi

# 6.2 Copiar ~/.config completo
log_info "Copiando directorios de configuración en ~/.config..."
run_cmd mkdir -p "$TARGET_HOME/.config"
run_cmd cp -r "$SCRIPT_DIR/dotfiles/config/"* "$TARGET_HOME/.config/"

# 6.3 Desplegar scripts y ejecutables en ~/.local/bin
log_info "Copiando scripts de ejecución en ~/.local/bin..."
run_cmd mkdir -p "$TARGET_HOME/.local/bin"
run_cmd cp -r "$SCRIPT_DIR/dotfiles/local_bin/"* "$TARGET_HOME/.local/bin/"

# Crear enlaces simbólicos necesarios en ~/.local/bin
run_cmd ln -sfn "$TARGET_HOME/.local/usr/bin/gsettings" "$TARGET_HOME/.local/bin/gsettings"
if [ -f /usr/bin/imv-wayland ]; then
    run_cmd ln -sfn /usr/bin/imv-wayland "$TARGET_HOME/.local/bin/imv"
elif [ -f /usr/bin/imv ]; then
    run_cmd ln -sfn /usr/bin/imv "$TARGET_HOME/.local/bin/imv"
fi

# 6.4 Enlaces de compatibilidad para GTK4 (libadwaita oscuro)
log_info "Vinculando estilos GTK4 de Fluent-purple-Dark..."
run_cmd mkdir -p "$TARGET_HOME/.config/gtk-4.0"
run_cmd ln -sfn "$TARGET_HOME/.themes/Fluent-purple-Dark/gtk-4.0/assets" "$TARGET_HOME/.config/gtk-4.0/assets"
run_cmd ln -sfn "$TARGET_HOME/.themes/Fluent-purple-Dark/gtk-4.0/gtk.css" "$TARGET_HOME/.config/gtk-4.0/gtk.css"
run_cmd ln -sfn "$TARGET_HOME/.themes/Fluent-purple-Dark/gtk-4.0/gtk-dark.css" "$TARGET_HOME/.config/gtk-4.0/gtk-dark.css"

# 6.5 Desplegar lanzadores .desktop
log_info "Instalando accesos directos de aplicaciones en ~/.local/share/applications..."
run_cmd mkdir -p "$TARGET_HOME/.local/share/applications"
run_cmd cp -r "$SCRIPT_DIR/dotfiles/desktop_entries/"* "$TARGET_HOME/.local/share/applications/"

# 6.6 Archivos raíz (.profile, .gtkrc-2.0, .bashrc)
log_info "Configurando .profile, .gtkrc-2.0 y .bashrc..."
run_cmd cp "$SCRIPT_DIR/dotfiles/.profile" "$TARGET_HOME/.profile"
run_cmd cp "$SCRIPT_DIR/dotfiles/.gtkrc-2.0" "$TARGET_HOME/.gtkrc-2.0"

# Añadir variables a .bashrc sin sobrescribir configuraciones personales previas
if [ -f "$SCRIPT_DIR/dotfiles/.bashrc_additions" ]; then
    if ! grep -q "Fluent Purple" "$TARGET_HOME/.bashrc" 2>/dev/null; then
        log_info "Añadiendo variables de entorno Wayland a ~/.bashrc..."
        if [ "$DRY_RUN" = false ]; then
            cat "$SCRIPT_DIR/dotfiles/.bashrc_additions" >> "$TARGET_HOME/.bashrc"
        fi
    fi
fi

# 6.7 Permisos de ejecución
log_info "Asignando permisos de ejecución a scripts..."
run_cmd chmod +x "$TARGET_HOME/.local/bin/"* 2>/dev/null || true
if [ -d "$TARGET_HOME/.config/sway/scripts" ]; then
    run_cmd chmod +x "$TARGET_HOME/.config/sway/scripts/"* 2>/dev/null || true
fi

# 6.8 Adaptar dinámicamente cualquier ruta absoluta (/home/jhon) al nuevo TARGET_HOME
log_info "Adaptando rutas internas al directorio del nuevo usuario ($TARGET_HOME)..."
if [ "$DRY_RUN" = false ]; then
    # Reemplazar /home/jhon por TARGET_HOME en configuraciones críticas
    FILES_TO_ADAPT=(
        "$TARGET_HOME/.config/sway/config"
        "$TARGET_HOME/.config/environment.d/10-wayland.conf"
        "$TARGET_HOME/.profile"
        "$TARGET_HOME/.bashrc"
        "$TARGET_HOME/.local/bin/strawberry"
        "$TARGET_HOME/.local/bin/sassc"
        "$TARGET_HOME/.local/share/applications/joplin.desktop"
        "$TARGET_HOME/.local/share/applications/strawberry.desktop"
        "$TARGET_HOME/.local/share/applications/thunar.desktop"
        "$TARGET_HOME/.config/obs-studio/basic/profiles/Sin Título/basic.ini"
    )

    for file in "${FILES_TO_ADAPT[@]}"; do
        if [ -f "$file" ]; then
            sed -i "s|/home/jhon|$TARGET_HOME|g" "$file"
        fi
    done
fi
log_success "Dotfiles desplegados y rutas adaptadas con éxito."

# ------------------------------------------------------------------------------
# 7. Instalación de Joplin AppImage
# ------------------------------------------------------------------------------
log_step "Paso 7: Configuración de Joplin Notes"

run_cmd mkdir -p "$TARGET_HOME/.joplin"
JOPLIN_TARGET="$TARGET_HOME/.joplin/Joplin.AppImage"

if [ -f "$SCRIPT_DIR/assets/joplin/Joplin.AppImage" ]; then
    log_info "Copiando Joplin.AppImage local desde assets..."
    run_cmd cp "$SCRIPT_DIR/assets/joplin/Joplin.AppImage" "$JOPLIN_TARGET"
    run_cmd chmod +x "$JOPLIN_TARGET"
elif [ -f "$JOPLIN_TARGET" ]; then
    log_info "Joplin.AppImage ya existe en $JOPLIN_TARGET."
else
    log_info "Descargando Joplin AppImage oficial (versión recomendada)..."
    if [ "$DRY_RUN" = false ]; then
        curl -fSL "https://github.com/laurent22/joplin/releases/download/v3.4.19/Joplin-3.4.19.AppImage" -o "$JOPLIN_TARGET" || \
        curl -fSL "https://objects.githubusercontent.com/github-production-release-asset-2e65be/108394432/38466b03-7cb7-4a57-8ffb-ba94563a6699" -o "$JOPLIN_TARGET" || \
        log_warn "No se pudo descargar automáticamente Joplin AppImage. Puedes descargarlo luego con el script oficial."
        [ -f "$JOPLIN_TARGET" ] && chmod +x "$JOPLIN_TARGET"
    fi
fi

# ------------------------------------------------------------------------------
# 8. Corrección Final de Propietario y Permisos
# ------------------------------------------------------------------------------
log_step "Paso 8: Ajuste de Permisos y Propietario"

log_info "Asegurando permisos para el usuario $TARGET_USER..."
run_sudo chown -R "$TARGET_USER:$TARGET_GID" \
    "$TARGET_HOME/.config" \
    "$TARGET_HOME/.local" \
    "$TARGET_HOME/.themes" \
    "$TARGET_HOME/.icons" \
    "$TARGET_HOME/.joplin" \
    "$TARGET_HOME/Imágenes" \
    "$TARGET_HOME/.profile" \
    "$TARGET_HOME/.bashrc" \
    "$TARGET_HOME/.gtkrc-2.0" 2>/dev/null || true

log_success "Permisos del sistema y usuario asignados."

# ------------------------------------------------------------------------------
# Resumen y Recomendaciones Finales
# ------------------------------------------------------------------------------
echo -e "\n${CLR_GREEN}${CLR_BOLD}==============================================================================${CLR_RESET}"
echo -e "${CLR_GREEN}${CLR_BOLD}   ¡RÉPLICA DEL ENTORNO COMPLETADA EXITOSAMENTE!${CLR_RESET}"
echo -e "${CLR_GREEN}${CLR_BOLD}==============================================================================${CLR_RESET}\n"

echo -e "El entorno Debian con Sway, temas Fluent Purple y optimizaciones para laptop ha sido configurado."
echo -e "\n${CLR_YELLOW}Próximos pasos recomendados:${CLR_RESET}"
echo -e "  1. ${CLR_BOLD}Reiniciar el equipo${CLR_RESET} para aplicar los grupos de usuario y servicios systemd:"
echo -e "     ${CLR_CYAN}sudo reboot${CLR_RESET}"
echo -e "  2. Al iniciar sesión en la TTY o Display Manager, ejecuta:"
echo -e "     ${CLR_CYAN}sway${CLR_RESET}"
echo -e "\n${CLR_PURPLE}Atajos de teclado clave en Sway:${CLR_RESET}"
echo -e "  - ${CLR_BOLD}Super + Enter${CLR_RESET}        : Abrir terminal Foot (Fluent Purple)"
echo -e "  - ${CLR_BOLD}Super + d${CLR_RESET}            : Lanzador Wofi (drun)"
echo -e "  - ${CLR_BOLD}Super + Shift + q${CLR_RESET}    : Cerrar ventana actual"
echo -e "  - ${CLR_BOLD}Super + e${CLR_RESET}            : Alternar división horizontal/vertical"
echo -e "  - ${CLR_BOLD}Super + f${CLR_RESET}            : Modo pantalla completa"
echo -e "  - ${CLR_BOLD}Super + Shift + Espacio${CLR_RESET}: Ventana flotante"
echo -e "  - ${CLR_BOLD}Super + 0${CLR_RESET}            : Menú de apagado y perfiles de energía (Wofi)"
echo -e "  - ${CLR_BOLD}Super + c${CLR_RESET}            : Historial del portapapeles (cliphist)"
echo -e "  - ${CLR_BOLD}Print / Shift+Print${CLR_RESET}  : Capturas de pantalla (completa / selección)"
echo -e "  - ${CLR_BOLD}Teclas multimedia${CLR_RESET}    : Brillo, Volumen y Reproductor integrados con OSD\n"
