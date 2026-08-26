#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║        Instalador de Dependencias Entorno MangoWM             ║
# ║        Optimizado & Robusto para Arch Linux (pacman/AUR)      ║
# ╚══════════════════════════════════════════════════════════════╝

set -eo pipefail

# ── Colores y Formato de Logs ─────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}▶ ${1}${NC}"; }
log_success() { echo -e "${GREEN}✓ ${1}${NC}"; }
log_warn()    { echo -e "${YELLOW}⚠ ${1}${NC}"; }
log_error()   { echo -e "${RED}✖ ${1}${NC}"; }

banner() {
    echo -e "${CYAN}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║       📦 Instalador de Dependencias MangoWM (Arch Linux)     ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

banner

# ── 1. Solicitud y Mantenimiento de Privilegios Sudo ───────────
log_info "Verificando permisos de superusuario (sudo)..."
sudo -v

# Mantener sudo activo en segundo plano mientras corre el script
(while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done) &
SUDO_PID=$!
trap 'kill $SUDO_PID 2>/dev/null || true' EXIT

# ── 2. Configuración Regional (Locales) ────────────────────────
log_info "Configurando locales del sistema (es_AR.UTF-8 / en_US.UTF-8)..."
sudo sed -i 's/#es_AR.UTF-8 UTF-8/es_AR.UTF-8 UTF-8/' /etc/locale.gen
sudo sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sudo locale-gen > /dev/null
echo "LANG=es_AR.UTF-8" | sudo tee /etc/locale.conf > /dev/null
log_success "Locales configurados correctamente"

# ── 3. Base Devel & Git ─────────────────────────────────────────
log_info "Verificando herramientas base de compilación (base-devel, git)..."
sudo pacman -S --needed --noconfirm base-devel git

# ── 4. Paquetes Oficiales (Pacman) ──────────────────────────────
# Nota: Se eliminaron paquetes duplicados, Nautilus/gvfs redundantes
PACMAN_PACKAGES=(
    # Entorno Principal Wayland & UI
    # MangoWM + mmsg (IPC) se instalan desde el AUR (ver más abajo)
    waybar
    wofi
    foot
    dunst
    gammastep
    wlr-randr
    wlr-dpms

    # Captura de Pantalla & Portapapeles
    grim
    slurp
    wl-clipboard
    cliphist
    wtype

    # Audio, Red, Montaje USB y Control de Sistema
    networkmanager
    network-manager-applet
    pipewire
    pipewire-pulse
    wireplumber
    pavucontrol
    polkit-gnome
    gnome-keyring
    libsecret
    brightnessctl
    playerctl
    bluez
    bluez-utils
    blueman
    udiskie
    power-profiles-daemon

    # Portales e Integración Wayland / XDG
    xdg-desktop-portal
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gtk
    xdg-utils

    # Gestor de Archivos Yazi & Previews en Terminal
    yazi
    ffmpegthumbnailer
    poppler
    chafa
    p7zip
    ouch

    # Aplicaciones Predeterminadas (Suite Minimal Completa)
    firefox
    mpv
    imv
    zathura
    zathura-pdf-mupdf
    nano

    # Herramientas CLI & Optimización del Sistema
    bat
    eza
    fd
    ripgrep
    zoxide
    fzf
    jq
    btop
    imagemagick
    zram-generator

    # Fuentes Tipográficas
    ttf-jetbrains-mono-nerd
    inter-font
    noto-fonts
    noto-fonts-emoji
    noto-fonts-cjk

    # GTK / Qt / Dynamic Theming & Iconos
    adw-gtk-theme
    papirus-icon-theme
    adwaita-icon-theme
    adwaita-cursors
    nwg-look
    qt5ct
    qt6ct
    matugen

    # Shell & Prompt
    zsh
    starship
    zsh-autosuggestions
    zsh-syntax-highlighting
)

log_info "Instalando paquetes oficiales con pacman..."
sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"
log_success "Paquetes oficiales instalados con éxito"

# ── 4.1 Helper AUR (yay/paru) + MangoWM ─────────────────────────
# MangoWM y su herramienta IPC (mmsg) no están en los repos oficiales:
# se instalan desde el AUR con un helper (yay o paru).

# 4.1.a. Detectar helper AUR existente
AUR_HELPER=""
if command -v yay &>/dev/null; then
    AUR_HELPER="yay"
elif command -v paru &>/dev/null; then
    AUR_HELPER="paru"
fi

# 4.1.b. Si no hay helper, ofrecer instalar yay o paru (solo interactivo)
if [ -z "$AUR_HELPER" ]; then
    log_warn "No se encontró ningún helper del AUR (yay o paru)."
    log_warn "MangoWM se instala desde el AUR, así que necesitás uno de los dos."
    if [ -t 0 ]; then
        echo ""
        echo -e "${CYAN}${BOLD}Elegí un helper del AUR para instalar:${NC}"
        echo -e "  ${BOLD}1)${NC} yay   — El helper más popular y estándar de facto"
        echo -e "  ${BOLD}2)${NC} paru  — Helper más nuevo, escrito en Rust, con funciones extra"
        echo -e "  ${BOLD}3)${NC} Omitir — No instalar helper (MangoWM quedará sin instalar)"
        echo ""
        read -rp "  Opción [1/2/3] (por defecto 1): " aur_choice
        case "${aur_choice:-1}" in
            1)
                AUR_HELPER="yay"
                ;;
            2)
                AUR_HELPER="paru"
                ;;
            3)
                AUR_HELPER=""
                ;;
            *)
                AUR_HELPER="yay"
                ;;
        esac

        # Instalar el helper elegido clonando el repo y compilando con makepkg
        if [ -n "$AUR_HELPER" ]; then
            log_info "Instalando ${AUR_HELPER} desde el AUR..."
            AUR_BUILD_DIR="$(mktemp -d)"
            if git clone "https://aur.archlinux.org/${AUR_HELPER}.git" "$AUR_BUILD_DIR" 2>/dev/null; then
                ( cd "$AUR_BUILD_DIR" && makepkg -si --needed --noconfirm )
            else
                log_error "No se pudo clonar el repo de ${AUR_HELPER}."
                AUR_HELPER=""
            fi
            rm -rf "$AUR_BUILD_DIR"
            # Recalcular binario disponible
            if ! command -v "$AUR_HELPER" &>/dev/null; then
                log_error "La instalación de ${AUR_HELPER} falló."
                AUR_HELPER=""
            fi
        fi
    else
        log_warn "Instalación no interactiva: no se instaló ningún helper AUR."
    fi
fi

# 4.1.c. Instalar MangoWM y utilidades desde el AUR
# mangowm incluye mmsg (IPC). wbg (wallpaper) y gtklock (lockscreen) son
# alternativas wlroots-native sin "sway" en el nombre. swayidle es el daemon
# de idle estándar de wlroots (no depende del WM Sway).
AUR_PACKAGES=(
    mangowm
    wbg
    gtklock
    swayidle
)

if [ -n "$AUR_HELPER" ]; then
    log_info "Instalando MangoWM + utilidades desde el AUR con ${AUR_HELPER}..."
    "$AUR_HELPER" -S --needed --noconfirm "${AUR_PACKAGES[@]}"
    if command -v mmsg &>/dev/null && command -v mango &>/dev/null; then
        log_success "MangoWM instalado con éxito (incluye mmsg, el cliente IPC)"
    else
        log_error "MangoWM no se instaló correctamente. Verificá el log de ${AUR_HELPER}."
    fi
    log_success "Utilidades AUR instaladas: wbg (wallpaper), gtklock (lockscreen), swayidle (idle)"
else
    log_warn "Sin helper AUR disponible. Instalá manualmente:"
    log_warn "  ${AUR_HELPER:-yay} -S mangowm wbg gtklock swayidle"
    log_warn "  mmsg, el cliente IPC, viene incluido en el paquete mangowm"
fi

log_info "Actualizando caché de fuentes del sistema..."
fc-cache -f > /dev/null 2>&1 || true
log_success "Caché de fuentes actualizada"


# ── 6. Helper Script papirus-folders ───────────────────────────
if ! command -v papirus-folders &>/dev/null; then
    log_info "Instalando script papirus-folders en ~/.local/bin..."
    mkdir -p "$HOME/.local/bin"
    curl -sSLo "$HOME/.local/bin/papirus-folders" https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-folders/master/papirus-folders
    chmod +x "$HOME/.local/bin/papirus-folders"
    log_success "papirus-folders instalado"
fi

# ── 8. Cambiar Shell por Defecto a Zsh ─────────────────────────
CURRENT_SHELL="$(basename "$SHELL")"
ZSH_PATH="$(which zsh 2>/dev/null || echo "/bin/zsh")"

if [ "$CURRENT_SHELL" != "zsh" ] && [ -x "$ZSH_PATH" ]; then
    echo ""
    log_warn "¿Cambiar el shell por defecto a Zsh para $USER?"
    if [ -t 0 ]; then
        read -rp "  [s/N]: " change_shell
        if [[ "$change_shell" =~ ^[sS]$ ]]; then
            chsh -s "$ZSH_PATH" "$USER" || sudo chsh -s "$ZSH_PATH" "$USER"
            log_success "Shell cambiado a Zsh (surtirá efecto al reiniciar sesión)"
        fi
    else
        log_info "Instalación no interactiva detectada: Omitiendo cambio automático de shell"
    fi
fi

# ── 8.1. Habilitar Servicios del Sistema & Usuario ─────────────
log_info "Habilitando servicio power-profiles-daemon..."
sudo systemctl enable --now power-profiles-daemon.service 2>/dev/null || true
log_success "Servicio power-profiles-daemon habilitado"

log_info "Habilitando servicio de Bluetooth..."
sudo systemctl enable --now bluetooth.service 2>/dev/null || true
log_success "Servicio bluetooth habilitado"

log_info "Habilitando servicios de audio Pipewire & Wireplumber..."
systemctl --user enable --now pipewire.service pipewire-pulse.service wireplumber.service 2>/dev/null || true
log_success "Servicios de audio habilitados"

# ── 8.2. Optimización de Memoria & Logs (ZRAM & Journald) ──────
log_info "Configurando compresión de memoria en tiempo real (ZRAM)..."
sudo tee /etc/systemd/zram-generator.conf > /dev/null << 'EOF'
[zram0]
zram-size = ram
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
EOF
sudo systemctl daemon-reload 2>/dev/null || true
sudo systemctl start systemd-zram-setup@zram0.service 2>/dev/null || true
log_success "ZRAM configurado y activado"

log_info "Configurando límites de tamaño para systemd-journald (Ahorro de RAM/Disco)..."
sudo mkdir -p /etc/systemd/journald.conf.d
sudo tee /etc/systemd/journald.conf.d/00-limit-size.conf > /dev/null << 'EOF'
[Journal]
SystemMaxUse=50M
RuntimeMaxUse=20M
EOF
sudo systemctl restart systemd-journald 2>/dev/null || true
log_success "Límites de systemd-journald aplicados"

# ── 9. Finalización ─────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  ✅ Instalación de dependencias completada con éxito.        ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║  Podés ejecutar 'bash setup.sh' para aplicar tus dotfiles.   ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
