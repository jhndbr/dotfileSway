#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║        Script de Instalación Minimal para VM (Quickshell)    ║
# ║        Instala únicamente Sway + Quickshell + Foot           ║
# ╚══════════════════════════════════════════════════════════════╝

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${CYAN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║   📦 Configuración de Pruebas VM: Sway + Quickshell Minimal  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# 1. Comprobar si se necesita montar la carpeta compartida VirtFS
if [ ! -f "$REPO_DIR/config/quickshell/shell.qml" ]; then
    if [ -d "/mnt/dotfiles" ] && [ -f "/mnt/dotfiles/config/quickshell/shell.qml" ]; then
        REPO_DIR="/mnt/dotfiles"
    else
        echo -e "${YELLOW}Intentando montar la carpeta compartida 9p (tag 'dotfiles')...${NC}"
        sudo mkdir -p /mnt/dotfiles
        if sudo mount -t 9p -o trans=virtio,version=9p2000.L dotfiles /mnt/dotfiles 2>/dev/null; then
            REPO_DIR="/mnt/dotfiles"
            echo -e "  ${GREEN}✓ Carpeta compartida montada en /mnt/dotfiles${NC}"
        fi
    fi
fi

if [ ! -f "$REPO_DIR/config/quickshell/shell.qml" ]; then
    echo -e "${RED}✗ Error: No se pudo localizar el repositorio con config/quickshell.${NC}"
    echo "Asegúrate de montar la carpeta compartida con:"
    echo "  sudo mount -t 9p -o trans=virtio,version=9p2000.L dotfiles /mnt/dotfiles"
    exit 1
fi

echo -e "  ${GREEN}✓ Repositorio detectado en: ${BOLD}$REPO_DIR${NC}\n"

# 2. Paquetes ultra minimalistas requeridos (SIN waybar, dunst, wofi ni swayosd)
VM_PACKAGES=(
    # Núcleo Wayland & Shell Unificado
    sway
    swaybg
    swaylock
    quickshell
    foot

    # Drivers y Aceleración 3D para VM
    mesa
    virglrenderer
    qemu-guest-agent
    spice-vdagent

    # Audio Pipewire básico para Quickshell
    pipewire
    wireplumber
    pipewire-pulse

    # Fuentes & Utilidades
    ttf-jetbrains-mono-nerd
    polkit-gnome
    wl-clipboard
    brightnessctl
    matugen
)

echo -e "${YELLOW}▶ ¿Deseas instalar los paquetes esenciales en la VM con pacman?${NC}"
read -rp "  [S/n]: " do_install
do_install="${do_install:-s}"

if [[ "$do_install" =~ ^[sS]$ ]]; then
    echo -e "\n${BLUE}Actualizando repositorios e instalando paquetes...${NC}"
    sudo pacman -Sy --needed --noconfirm "${VM_PACKAGES[@]}"
    echo -e "  ${GREEN}✓ Paquetes instalados correctamente${NC}\n"
fi

# 3. Vincular o copiar configuraciones a ~/.config
echo -e "${BLUE}Configurando enlaces simbólicos en ~/.config...${NC}"
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/Pictures"

# Enlazar sway, quickshell y foot
for app in sway quickshell foot; do
    rm -rf "$HOME/.config/$app"
    mkdir -p "$HOME/.config/$app"
    cp -rf "$REPO_DIR/config/$app/"* "$HOME/.config/$app/"
    echo -e "  ${GREEN}→${NC} Configuración copiada: ${BLUE}$app${NC}"
done

# Copiar scripts auxiliares a ~/.local/bin
if [ -d "$REPO_DIR/scripts" ]; then
    for s in "$REPO_DIR/scripts/"*.sh; do
        [ -f "$s" ] && cp -f "$s" "$HOME/.local/bin/" && chmod +x "$HOME/.local/bin/$(basename "$s")"
    done
    echo -e "  ${GREEN}→${NC} Scripts de control copiados en ${BLUE}~/.local/bin${NC}"
fi

# Fondo de pantalla fallback si no existe
if [ ! -f "$HOME/Pictures/1.jpg" ]; then
    if [ -f "$REPO_DIR/wallpapers/1.jpg" ]; then
        cp -f "$REPO_DIR/wallpapers/1.jpg" "$HOME/Pictures/1.jpg"
    elif [ -f "$REPO_DIR/wallpapers/3.jpg" ]; then
        cp -f "$REPO_DIR/wallpapers/3.jpg" "$HOME/Pictures/1.jpg"
    fi
fi

# Copiar plantillas de Matugen y generar tema inicial
if [ -d "$REPO_DIR/templates" ]; then
    echo -e "  ${GREEN}→${NC} Configurando plantillas dinámicas de ${BLUE}Matugen${NC}..."
    mkdir -p "$HOME/.config/matugen/templates"
    cp -rf "$REPO_DIR/templates/"* "$HOME/.config/matugen/templates/"
fi

if command -v matugen &>/dev/null && [ -f "$HOME/.local/bin/set-wallpaper.sh" ] && [ -f "$HOME/Pictures/1.jpg" ]; then
    echo -e "  ${GREEN}→${NC} Generando paleta de colores dinámica para Quickshell..."
    bash "$HOME/.local/bin/set-wallpaper.sh" "$HOME/Pictures/1.jpg" || true
fi

# 4. Iniciar servicios de audio Pipewire
systemctl --user enable --now pipewire.service wireplumber.service 2>/dev/null || true

echo -e "\n${GREEN}${BOLD}╔══════════════════════════════════════════════════════════════╗"
echo "║  ✅ Entorno VM preparado con éxito.                          ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║  Para iniciar y probar el entorno ejecuta:                   ║"
echo "║      sway                                                    ║"
echo "╚══════════════════════════════════════════════════════════════╝${NC}\n"
