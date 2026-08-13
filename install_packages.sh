#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║        Instalador de Dependencias Entorno Sway WM            ║
# ║        Optimizado & Robusto para Arch Linux (pacman)         ║
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
    echo "║       📦 Instalador de Dependencias Sway (Arch Linux)       ║"
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
    sway
    swaybg
    swaylock
    swayidle
    waybar
    wofi
    foot
    dunst
    gammastep

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

    # Herramientas CLI Modernas
    bat
    eza
    fd
    ripgrep
    zoxide
    fzf
    jq
    btop
    imagemagick

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

# ── 9. Finalización ─────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  ✅ Instalación de dependencias completada con éxito.        ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║  Podés ejecutar 'bash setup.sh' para aplicar tus dotfiles.   ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
