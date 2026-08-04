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

# ── Configuración regional (Locales) ───────────────────────────
echo -e "${BLUE}▶ Generando locales del sistema (es_AR.UTF-8 / en_US.UTF-8)...${NC}"
sudo sed -i 's/#es_AR.UTF-8 UTF-8/es_AR.UTF-8 UTF-8/' /etc/locale.gen
sudo sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sudo locale-gen
echo "LANG=es_AR.UTF-8" | sudo tee /etc/locale.conf

# ── Herramientas base de compilación ───────────────────────────
sudo pacman -S --needed --noconfirm base-devel git

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

    # GTK / Qt / Dynamic Theming & Iconos
    adw-gtk-theme
    breeze
    papirus-icon-theme
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

# ── Instalador de papirus-folders ──────────────────────────────
if ! command -v papirus-folders &>/dev/null; then
    echo -e "${BLUE}▶ Instalando script helper papirus-folders...${NC}"
    mkdir -p "$HOME/.local/bin"
    curl -sSLo "$HOME/.local/bin/papirus-folders" https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-folders/master/papirus-folders
    chmod +x "$HOME/.local/bin/papirus-folders"
fi

# ── Helper de AUR (yay) y Paquetes AUR ──────────────────────────
echo ""
echo -e "${BLUE}▶ Verificando instalador de AUR (yay)...${NC}"
if ! command -v yay &> /dev/null; then
    echo -e "${YELLOW}▶ yay no encontrado. Instalando yay-bin desde AUR...${NC}"
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    (cd /tmp/yay-bin && makepkg -si --noconfirm)
    rm -rf /tmp/yay-bin
fi

echo -e "${BLUE}▶ Instalando wlogout y paquetes AUR con yay...${NC}"
AUR_PACKAGES=(
    wlogout
    zsh-autosuggestions
    zsh-syntax-highlighting
    papirus-folders-git
)

yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"

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
