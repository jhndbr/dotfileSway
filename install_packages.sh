#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║             Instalador de Dependencias Sway                 ║
# ║             Arch Linux (pacman + yay)                       ║
# ╚══════════════════════════════════════════════════════════════╝

set -e

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  📦 Instalando dependencias del entorno Sway               ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# ── Paquetes principales (pacman) ───────────────────────────────
PACKAGES=(
    # Entorno principal y UI
    sway
    swaybg
    swaylock
    swayidle
    waybar
    wofi
    foot
    dunst
    kanshi
    wlogout

    # Capturas de pantalla e historial de portapapeles
    grim
    slurp
    wl-clipboard
    cliphist

    # Audio, red y control de sistema
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

    # Portales e integración Wayland
    xdg-desktop-portal
    xdg-desktop-portal-wlr

    # Administrador de archivos
    thunar
    gvfs

    # Filtro de luz azul
    gammastep

    # Herramientas CLI modernas
    bat
    eza
    fd
    ripgrep
    zoxide
    fzf
    jq
    htop
    btop
    imagemagick

    # Fuentes
    ttf-jetbrains-mono-nerd
    inter-font
    noto-fonts
    noto-fonts-emoji
    noto-fonts-cjk

    # GTK / Qt / Dynamic Theming
    adwaita-icon-theme
    adwaita-cursors
    nwg-look
    qt5ct
    qt6ct
    matugen
    python-pywal

    # Shell
    zsh
)

echo -e "${BLUE}▶ Instalando paquetes con pacman...${NC}"
echo ""
sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"

# ── Paquetes AUR (con yay) ──────────────────────────────────────
echo ""
if command -v yay &> /dev/null; then
    echo -e "${BLUE}▶ Instalando paquetes AUR con yay...${NC}"

    AUR_PACKAGES=(
        # Shell
        zsh-autosuggestions
        zsh-syntax-highlighting
    )

    yay -S --needed --noconfirm "${AUR_PACKAGES[@]}" 2>/dev/null || true
else
    echo -e "${YELLOW}⚠  yay no está instalado. Para instalar paquetes AUR, instalá yay primero:${NC}"
    echo -e "   ${BLUE}git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si${NC}"
fi

# ── Oh My Zsh ──────────────────────────────────────────────────
echo ""
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${BLUE}▶ Instalando Oh My Zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo -e "${GREEN}✓ Oh My Zsh ya está instalado${NC}"
fi

# ── Powerlevel10k ──────────────────────────────────────────────
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
    echo -e "${BLUE}▶ Instalando Powerlevel10k...${NC}"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
    echo -e "${GREEN}✓ Powerlevel10k ya está instalado${NC}"
fi

# ── Plugins Zsh ────────────────────────────────────────────────
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo -e "${BLUE}▶ Instalando zsh-autosuggestions...${NC}"
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo -e "${BLUE}▶ Instalando zsh-syntax-highlighting...${NC}"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# ── Establecer Zsh como shell por defecto ──────────────────────
if [ "$SHELL" != "$(which zsh)" ]; then
    echo ""
    echo -e "${YELLOW}▶ ¿Cambiar shell por defecto a zsh?${NC}"
    read -rp "  [s/N]: " change_shell
    if [[ "$change_shell" =~ ^[sS]$ ]]; then
        chsh -s "$(which zsh)"
        echo -e "  ${GREEN}✓ Shell cambiado a zsh (requiere re-login)${NC}"
    fi
fi

echo ""
echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  ✅ Todas las dependencias han sido instaladas              ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║  Ejecutá 'bash setup.sh' para aplicar las configuraciones   ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
