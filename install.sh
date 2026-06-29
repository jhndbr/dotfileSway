#!/usr/bin/env bash
# =============================================================================
#  install.sh — Dotfiles installer for Void Linux
#  Author: ColexDev (adapted for portability)
#  Usage:  bash install.sh [OPTIONS]
#
#  This script:
#    1. Verifies the system is running Void Linux
#    2. Installs all required xbps packages
#    3. Installs Rust via rustup (optional)
#    4. Compiles and installs suckless tools (dwm, dmenu, slstatus, slock)
#    5. Creates symlinks for all dotfiles
#    6. Sets correct permissions on scripts
#    7. Enables required runit services
#    8. Prints a summary of what was done and what needs manual setup
# =============================================================================

set -euo pipefail

# ─── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GRN='\033[0;32m'
YLW='\033[1;33m'
BLU='\033[0;34m'
CYN='\033[0;36m'
BLD='\033[1m'
RST='\033[0m'

# ─── Flags ───────────────────────────────────────────────────────────────────
DRY_RUN=false
SKIP_SUCKLESS=false
SKIP_RUST=false
SKIP_SERVICES=false
ONLY_SUCKLESS=false

for arg in "$@"; do
    case $arg in
        --dry-run)       DRY_RUN=true ;;
        --no-suckless)   SKIP_SUCKLESS=true ;;
        --no-rust)       SKIP_RUST=true ;;
        --no-services)   SKIP_SERVICES=true ;;
        --only-suckless)
            # Recompila SOLO las suckless tools + symlinks, sin paquetes ni servicios.
            # Ideal para cuando ya tenés el entorno y solo querés aplicar cambios de config.
            ONLY_SUCKLESS=true
            SKIP_RUST=true
            SKIP_SERVICES=true
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "  --dry-run         Show what would be done without making changes"
            echo "  --no-suckless     Skip compiling dwm, dmenu, slstatus, slock"
            echo "  --no-rust         Skip installing Rust via rustup"
            echo "  --no-services     Skip enabling runit services"
            echo "  --only-suckless   Only recompile suckless tools + apply symlinks"
            echo "                    (skip packages, rust, services)"
            echo "                    Use this when you already have the environment and"
            echo "                    want to apply config changes to dwm/slstatus/dmenu/slock"
            exit 0
            ;;
    esac
done

# ─── Helpers ─────────────────────────────────────────────────────────────────
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ERRORS=()

info()    { echo -e "${BLU}[INFO]${RST} $*"; }
success() { echo -e "${GRN}[OK]${RST}   $*"; }
warn()    { echo -e "${YLW}[WARN]${RST} $*"; }
error()   { echo -e "${RED}[ERR]${RST}  $*"; ERRORS+=("$*"); }
step()    { echo -e "\n${BLD}${CYN}━━━ $* ━━━${RST}"; }
dry()     { echo -e "${YLW}[DRY]${RST}  Would run: $*"; }

run() {
    if $DRY_RUN; then
        dry "$*"
    else
        "$@"
    fi
}

pkg_install() {
    if $DRY_RUN; then
        dry "doas xbps-install -y $*"
    else
        doas xbps-install -y "$@" || warn "Some packages may have failed: $*"
    fi
}

# ─── Banner ──────────────────────────────────────────────────────────────────
echo -e "${BLD}"
echo "╔══════════════════════════════════════════════════════╗"
echo "║         Void Linux Dotfiles Installer                ║"
echo "║         ColexDev Setup — DWM + Alacritty + Nvim     ║"
echo "╚══════════════════════════════════════════════════════╝"
echo -e "${RST}"
echo "  Dotfiles location: ${BLD}${DOTFILES_DIR}${RST}"
echo "  Target home:       ${BLD}${HOME}${RST}"
$DRY_RUN      && echo -e "  Mode: ${YLW}${BLD}DRY RUN (sin cambios reales)${RST}"
$ONLY_SUCKLESS && echo -e "  Mode: ${CYN}${BLD}ONLY SUCKLESS — recompilar dwm/dmenu/slstatus/slock${RST}"
echo ""

# =============================================================================
# FASES 1 y 2 — Verificación y doas (se saltan con --only-suckless)
# =============================================================================
if ! $ONLY_SUCKLESS; then

    step "FASE 1: Verificando el sistema"

    # Void Linux check
    if ! command -v xbps-install &>/dev/null; then
        echo -e "${RED}ERROR: Este script solo funciona en Void Linux (xbps-install no encontrado).${RST}"
        exit 1
    fi
    success "Void Linux detectado"

    # Detect libc variant
    if xbps-query -l | grep -q "musl"; then
        VOID_VARIANT="musl"
    else
        VOID_VARIANT="glibc"
    fi
    info "Variante de Void: ${BLD}${VOID_VARIANT}${RST}"

    # Check if running as root (we want to avoid it — use doas)
    if [[ $EUID -eq 0 ]]; then
        warn "Estás ejecutando este script como root. Se recomienda ejecutarlo como usuario normal con doas configurado."
        read -rp "  ¿Continuar de todas formas? [y/N] " _ans
        [[ "${_ans,,}" != "y" ]] && exit 1
    fi

    # Check doas is available
    if ! command -v doas &>/dev/null; then
        warn "doas no encontrado. Intentando instalar con sudo..."
        if command -v sudo &>/dev/null; then
            sudo xbps-install -y opendoas
        else
            echo -e "${RED}ERROR: Ni doas ni sudo están disponibles. Instalá doas primero:${RST}"
            echo "  xbps-install -y opendoas"
            echo "  echo 'permit nopass :wheel' > /etc/doas.conf"
            exit 1
        fi
    fi

    # Check network connectivity
    if ! ping -c 1 -W 3 voidlinux.org &>/dev/null 2>&1; then
        warn "Sin acceso a internet. Algunos pasos pueden fallar."
    fi
    success "Verificación del sistema completada"

    # ─────────────────────────────────────────────────────────────────────────
    step "FASE 2: Configurando doas"

    DOAS_CONF="/etc/doas.conf"
    if [[ ! -f "$DOAS_CONF" ]]; then
        warn "Archivo /etc/doas.conf no encontrado."
        info "Creando configuración básica de doas (permit nopass :wheel)..."
        run doas sh -c "echo 'permit nopass :wheel' > /etc/doas.conf"
        run doas chmod 640 /etc/doas.conf
        success "doas configurado"
    else
        success "doas ya configurado en $DOAS_CONF"
    fi

    # Asegurar que el usuario esté en el grupo wheel
    if ! groups | grep -qw wheel; then
        warn "Tu usuario no está en el grupo 'wheel'. Agregándolo..."
        run doas usermod -aG wheel "$USER"
        warn "Deberás cerrar sesión y volver a entrar para que tome efecto."
    fi

fi  # fin del bloque ONLY_SUCKLESS skip (fases 1 y 2)

# =============================================================================
# FASE 3 — Instalación de paquetes (se salta con --only-suckless)
# =============================================================================
if ! $ONLY_SUCKLESS; then
    step "FASE 3: Instalando paquetes con xbps"

    info "Actualizando repositorios..."
    run doas xbps-install -Su

    # ─── Herramientas base de compilación ────────────────────────────────────
    info "Instalando herramientas de compilación..."
    pkg_install base-devel git make gcc pkg-config

    # ─── Headers X11 (necesarios para compilar suckless) ─────────────────────
    info "Instalando headers de X11..."
    pkg_install \
        libX11-devel \
        libXft-devel \
        libXinerama-devel \
        libXrandr-devel \
        libXrender-devel \
        libXext-devel \
        libXcb-devel

    # ─── X.Org y utilidades gráficas ─────────────────────────────────────────
    info "Instalando X.Org y utilidades gráficas..."
    pkg_install \
        xorg-minimal \
        xorg-server \
        xinit \
        xset \
        xinput \
        xrandr \
        xdg-utils \
        xdg-user-dirs \
        xclip \
        xwallpaper \
        xbanish

    # ─── Terminal y shell ─────────────────────────────────────────────────────
    info "Instalando terminal y herramientas de shell..."
    pkg_install alacritty bash fzf fd exa tmux ripgrep bat

    # ─── Editor ──────────────────────────────────────────────────────────────
    info "Instalando Neovim..."
    pkg_install neovim

    # ─── Audio: PipeWire (con compatibilidad PulseAudio) ─────────────────────
    info "Instalando PipeWire (con soporte pulseaudio via pipewire-pulse)..."
    pkg_install \
        pipewire \
        wireplumber \
        pipewire-pulse \
        alsa-plugins-pipewire \
        pulsemixer \
        alsa-utils \
        pavucontrol

    # ─── Red y tiempo ─────────────────────────────────────────────────────────
    info "Instalando herramientas de red y tiempo..."
    pkg_install ntpsec curl wget networkmanager network-manager-applet

    # ─── Aplicaciones ─────────────────────────────────────────────────────────
    info "Instalando aplicaciones..."
    pkg_install \
        mpv \
        nsxiv \
        qutebrowser \
        firefox \
        keepassxc \
        flameshot \
        ranger \
        zathura \
        zathura-pdf-mupdf

    # ─── Fuentes ─────────────────────────────────────────────────────────────
    info "Instalando fuentes..."
    pkg_install font-source-code-pro noto-fonts-ttf noto-fonts-emoji

    # ─── Herramientas adicionales ─────────────────────────────────────────────
    info "Instalando herramientas adicionales..."
    pkg_install delta bottom chafa ffmpeg screenkey gpg2 xdotool

    # ─── Laptop: gestión de batería ───────────────────────────────────────────
    info "Instalando herramientas de gestión de energía (laptop)..."
    pkg_install tlp acpi acpid

    success "Paquetes instalados"
fi  # fin FASE 3

# =============================================================================
# FASE 4 — Instalación de Rust via rustup (se salta con --only-suckless)
# =============================================================================
if ! $SKIP_RUST; then
    step "FASE 4: Instalando Rust via rustup"

    if command -v rustup &>/dev/null; then
        success "Rust ya está instalado ($(rustc --version 2>/dev/null || echo 'versión desconocida'))"
        run rustup update stable
    elif [[ -f "$HOME/.cargo/env" ]]; then
        # shellcheck source=/dev/null
        . "$HOME/.cargo/env"
        success "Rust ya está instalado via cargo"
    else
        info "Descargando e instalando rustup..."
        if $DRY_RUN; then
            dry "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path"
        else
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
            # shellcheck source=/dev/null
            [[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
        fi
        success "Rust instalado"
    fi
else
    info "Saltando instalación de Rust (--no-rust / --only-suckless)"
fi

# =============================================================================
# FASE 5 — Compilar e instalar herramientas suckless
# =============================================================================
if ! $SKIP_SUCKLESS; then
    step "FASE 5: Compilando herramientas suckless"

    SCRATCHPAD_CONFIG="${HOME}/.config/alacritty/scratchpad.toml"
    # Pass the scratchpad path at compile time so dwm knows where to find it
    SUCKLESS_CFLAGS="-DSCRATCHPAD_CONFIG='\"${SCRATCHPAD_CONFIG}\"'"

    build_suckless() {
        local name="$1"
        local dir="${DOTFILES_DIR}/.repos/${name}"

        if [[ ! -d "$dir" ]]; then
            warn "Directorio no encontrado: $dir — saltando $name"
            return
        fi

        info "Compilando ${name}..."
        if $DRY_RUN; then
            dry "cp $dir/config.def.h $dir/config.h"
            dry "cd $dir && make clean && make && doas make install"
        else
            (
                cd "$dir"

                # SIEMPRE copiar config.def.h → config.h antes de compilar.
                # Esto garantiza que los cambios de configuración se aplican,
                # independientemente de los timestamps de los archivos.
                if [[ -f config.def.h ]]; then
                    cp config.def.h config.h
                    info "  config.def.h → config.h (aplicado)"
                fi

                # Limpiar objetos de compilaciones anteriores
                make clean 2>/dev/null || true

                # Compilar (dwm recibe el path del scratchpad via CFLAGS)
                if [[ "$name" == "dwm" ]]; then
                    make CFLAGS="$SUCKLESS_CFLAGS" 2>&1 | tail -5
                else
                    make 2>&1 | tail -5
                fi

                # Instalar en el sistema (reemplaza el binario existente)
                doas make install
            ) && success "${name} compilado e instalado" || error "Falló la compilación de ${name}"
        fi
    }

    build_suckless "dwm"
    build_suckless "dmenu"
    build_suckless "slstatus"
    build_suckless "slock"

    # ─── Reiniciar procesos suckless si hay sesión X activa ──────────────────
    step "FASE 5b: Reiniciando procesos suckless activos"

    if [[ -n "${DISPLAY:-}" ]]; then
        # slstatus se puede reiniciar sin perder la sesión X
        if pgrep -x slstatus &>/dev/null; then
            info "Reiniciando slstatus..."
            if $DRY_RUN; then
                dry "pkill slstatus && sleep 1 && slstatus &"
            else
                pkill slstatus 2>/dev/null || true
                sleep 1
                slstatus &
                disown
                success "slstatus reiniciado con la nueva configuración"
            fi
        else
            info "slstatus no estaba corriendo — se iniciará con el próximo startx"
        fi

        # DWM NO se puede hot-reload — requiere reiniciar la sesión X
        echo ""
        warn "╔══════════════════════════════════════════════════════╗"
        warn "║  DWM requiere reiniciar la sesión X para aplicar    ║"
        warn "║  los cambios de configuración (fuente, colores, etc) ║"
        warn "║                                                      ║"
        warn "║  Salí de DWM con: Super + Shift + 0                 ║"
        warn "║  Luego volvé a entrar al tty1 para recargar.        ║"
        warn "╚══════════════════════════════════════════════════════╝"
    else
        info "No hay sesión X activa — los cambios se aplicarán al próximo startx"
    fi
else
    info "Saltando compilación suckless (--no-suckless)"
fi

# =============================================================================
# FASE 6 — Creación de symlinks de dotfiles
# =============================================================================
step "FASE 6: Creando symlinks de dotfiles"

# Función para crear symlink con backup automático
link_dotfile() {
    local src="$1"
    local dst="$2"
    local dst_dir
    dst_dir="$(dirname "$dst")"

    # Crear directorio destino si no existe
    if [[ ! -d "$dst_dir" ]]; then
        run mkdir -p "$dst_dir"
    fi

    # Si ya existe y apunta al lugar correcto, no hacer nada
    if [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "$src" ]]; then
        info "Symlink ya existe: $dst → $src"
        return
    fi

    # Si existe algo en dst, hacer backup con timestamp
    if [[ -e "$dst" ]] || [[ -L "$dst" ]]; then
        local backup="${dst}.bak.$(date +%Y%m%d_%H%M%S)"
        warn "Backup: $dst → $backup"
        run mv "$dst" "$backup"
    fi

    run ln -sf "$src" "$dst"
    success "Linked: $dst → $src"
}

# Dotfiles principales
link_dotfile "${DOTFILES_DIR}/.bashrc"             "${HOME}/.bashrc"
link_dotfile "${DOTFILES_DIR}/.xinitrc"            "${HOME}/.xinitrc"

# Configuraciones en ~/.config
link_dotfile "${DOTFILES_DIR}/.config/alacritty"   "${HOME}/.config/alacritty"
link_dotfile "${DOTFILES_DIR}/.config/nvim"        "${HOME}/.config/nvim"
link_dotfile "${DOTFILES_DIR}/.config/qutebrowser" "${HOME}/.config/qutebrowser"

# Tmux (si existe en el repo)
if [[ -d "${DOTFILES_DIR}/.config/tmux" ]]; then
    link_dotfile "${DOTFILES_DIR}/.config/tmux"    "${HOME}/.config/tmux"
elif [[ -f "${DOTFILES_DIR}/.tmux.conf" ]]; then
    link_dotfile "${DOTFILES_DIR}/.tmux.conf"      "${HOME}/.tmux.conf"
fi

# Scripts
link_dotfile "${DOTFILES_DIR}/.scripts"            "${HOME}/.scripts"

success "Symlinks creados"

# =============================================================================
# FASE 7 — Permisos de scripts
# =============================================================================
step "FASE 7: Configurando permisos de scripts"

if [[ -d "${DOTFILES_DIR}/.scripts" ]]; then
    if $DRY_RUN; then
        dry "chmod +x ${DOTFILES_DIR}/.scripts/*"
    else
        find "${DOTFILES_DIR}/.scripts" -type f -exec chmod +x {} \;
        success "Scripts en .scripts/ son ahora ejecutables"
    fi
fi

# =============================================================================
# FASE 8 — Habilitar servicios runit (se salta con --only-suckless)
# =============================================================================
if ! $SKIP_SERVICES; then
    step "FASE 8: Habilitando servicios runit"

    enable_service() {
        local svc="$1"
        if [[ -d "/etc/sv/${svc}" ]]; then
            if [[ ! -L "/var/service/${svc}" ]]; then
                run doas ln -sf "/etc/sv/${svc}" "/var/service/${svc}"
                success "Servicio habilitado: ${svc}"
            else
                info "Servicio ya habilitado: ${svc}"
            fi
        else
            warn "Servicio no encontrado en /etc/sv/: ${svc} (puede no estar instalado)"
        fi
    }

    enable_service "dbus"
    enable_service "NetworkManager"
    enable_service "acpid"
    enable_service "tlp"
    enable_service "ntpd"

    info "Nota: PipeWire se maneja desde ~/.xinitrc — no necesita servicio del sistema"
    success "Servicios configurados"
else
    info "Saltando configuración de servicios (--only-suckless / --no-services)"
fi

# =============================================================================
# FASE 9 — Configuración post-instalación
# =============================================================================
step "FASE 9: Configuraciones adicionales"

# Crear archivo ~/.ip vacío para evitar error en .bashrc
if [[ ! -f "${HOME}/.ip" ]]; then
    info "Creando ~/.ip vacío (para el alias del servidor)..."
    run touch "${HOME}/.ip"
    run chmod 600 "${HOME}/.ip"
    success "~/.ip creado"
fi

# Crear directorios XDG estándar
if command -v xdg-user-dirs-update &>/dev/null; then
    run xdg-user-dirs-update
    success "Directorios XDG creados"
fi

# Actualizar cache de fuentes
if command -v fc-cache &>/dev/null; then
    if $DRY_RUN; then
        dry "fc-cache -fv"
    else
        fc-cache -fv &>/dev/null
        success "Cache de fuentes actualizado"
    fi
fi

info "Plugins de Neovim: ejecutá 'nvim' y luego ':PackerSync' para instalarlos"

# =============================================================================
# RESUMEN FINAL
# =============================================================================
echo ""
echo -e "${BLD}${CYN}╔══════════════════════════════════════════════════════╗"
echo "║                   INSTALACIÓN COMPLETA              ║"
echo -e "╚══════════════════════════════════════════════════════╝${RST}"
echo ""

if [[ ${#ERRORS[@]} -gt 0 ]]; then
    echo -e "${RED}${BLD}Errores encontrados:${RST}"
    for err in "${ERRORS[@]}"; do
        echo -e "  ${RED}✗${RST} $err"
    done
    echo ""
fi

echo -e "${GRN}${BLD}✓ Completado:${RST}"
if ! $ONLY_SUCKLESS; then
    echo "  • Paquetes xbps instalados"
fi
echo "  • Herramientas suckless compiladas (dwm, dmenu, slstatus, slock)"
echo "  • Dotfiles vinculados en ~/"
echo "  • Scripts en ~/.scripts/ con permisos de ejecución"
if ! $SKIP_SERVICES; then
    echo "  • Servicios runit habilitados (dbus, NetworkManager, ntpd, tlp, acpid)"
fi
echo "  • ~/.ip creado (vacío)"
echo ""

echo -e "${YLW}${BLD}⚠ Pasos manuales restantes:${RST}"
echo ""
echo "  1. ${BLD}Reiniciar sesión X para aplicar cambios en DWM:${RST}"
echo "     Super + Shift + 0  →  salir de DWM"
echo "     Luego logueate en tty1 (startx se ejecuta automáticamente)"
echo ""
echo "  2. ${BLD}Activar PipeWire en ~/.xinitrc:${RST}"
echo "     Descomenta las líneas:"
echo "       pipewire &"
echo "       pipewire-pulse &"
echo "       wireplumber &"
echo ""
echo "  3. ${BLD}Neovim plugins:${RST}"
echo "     nvim → :PackerSync"
echo ""
echo "  4. ${BLD}Batería en slstatus:${RST}"
echo "     Verificá tu nombre de batería: ls /sys/class/power_supply/"
echo "     Si no es BAT0, editá .repos/slstatus/config.def.h"
echo "     y recompilá con:  bash install.sh --only-suckless"
echo ""
echo "  5. ${BLD}Monitor setup:${RST}"
echo "     Editá ~/.xinitrc y ajustá el bloque xrandr a tu configuración"
echo ""
echo "  6. ${BLD}IP del servidor (opcional):${RST}"
echo "     echo \"export MY_SERVER_IP='1.2.3.4'\" > ~/.ip"
echo ""
echo -e "${BLU}  Repositorio: ${DOTFILES_DIR}${RST}"
echo ""
