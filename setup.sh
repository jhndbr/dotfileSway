#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║      Script de Instalación y Configuración de Sway           ║
# ║      Aplica dotfiles desde el repositorio a ~/.config        ║
# ╚══════════════════════════════════════════════════════════════╝

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config/dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║      🚀 Instalación de Dotfiles Sway                       ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# ── 1. Instalación de paquetes ──────────────────────────────────
if [ -f "$SCRIPT_DIR/install_packages.sh" ]; then
    echo -e "${YELLOW}▶ ¿Instalar dependencias del sistema?${NC}"
    read -rp "  [s/N]: " install_deps
    if [[ "$install_deps" =~ ^[sS]$ ]]; then
        bash "$SCRIPT_DIR/install_packages.sh"
    else
        echo -e "  ${BLUE}→ Omitiendo instalación de paquetes${NC}"
    fi
fi

echo ""
echo -e "${CYAN}📁 Aplicando configuraciones...${NC}"
echo "────────────────────────────────────────────────────────────"

# ── 2. Crear directorios necesarios ─────────────────────────────
mkdir -p ~/.config
mkdir -p ~/Pictures/Screenshots
mkdir -p ~/.local/bin

# ── 3. Backup de configuraciones existentes ─────────────────────
echo -e "${YELLOW}📦 Creando backup en $BACKUP_DIR${NC}"
mkdir -p "$BACKUP_DIR"

CONFIGS=(sway waybar wofi dunst foot swaylock kanshi wlogout gammastep gtk-3.0 gtk-4.0 environment.d qt5ct qt6ct matugen zed)

for item in "${CONFIGS[@]}"; do
    if [ -d "$HOME/.config/$item" ]; then
        cp -rf "$HOME/.config/$item" "$BACKUP_DIR/" 2>/dev/null || true
    fi
done

# Backup archivos de home
for file in .zshrc .zprofile .gitconfig; do
    if [ -f "$HOME/$file" ]; then
        cp -f "$HOME/$file" "$BACKUP_DIR/$file" 2>/dev/null || true
    fi
done

echo -e "  ${GREEN}✓ Backup creado${NC}"

# ── 4. Copiar carpetas de configuración ─────────────────────────
echo ""
for item in "${CONFIGS[@]}"; do
    if [ -d "$SCRIPT_DIR/config/$item" ]; then
        echo -e "  ${GREEN}→${NC} Copiando configuración de ${BLUE}$item${NC}..."
        mkdir -p "$HOME/.config/$item"
        cp -rf "$SCRIPT_DIR/config/$item/"* "$HOME/.config/$item/" 2>/dev/null || true
    fi
done

if [ -f "$HOME/.config/gtk-3.0/bookmarks" ]; then
    sed -i "s|file:///home/[^/]*|file://$HOME|g" "$HOME/.config/gtk-3.0/bookmarks" 2>/dev/null || true
fi

# ── 5. Copiar archivos de home (.zshrc, .zprofile, .gitconfig, .p10k.zsh) ──
echo ""
echo -e "${CYAN}🏠 Aplicando configuraciones de home...${NC}"
for file in .zshrc .zprofile .gitconfig .p10k.zsh; do
    if [ -f "$SCRIPT_DIR/$file" ]; then
        echo -e "  ${GREEN}→${NC} Copiando ${BLUE}$file${NC}..."
        cp -f "$SCRIPT_DIR/$file" "$HOME/$file"
    fi
done

# Garantizar que .zshrc cargue la configuración de p10k
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "source ~/.p10k.zsh" "$HOME/.zshrc"; then
        echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> "$HOME/.zshrc"
    fi
fi

# ── 6. Copiar scripts a ~/.local/bin ────────────────────────────
if [ -d "$SCRIPT_DIR/scripts" ]; then
    echo ""
    echo -e "${CYAN}⚡ Instalando scripts utilitarios...${NC}"
    for script in "$SCRIPT_DIR/scripts/"*; do
        if [ -f "$script" ]; then
            script_name=$(basename "$script")
            echo -e "  ${GREEN}→${NC} Instalando ${BLUE}$script_name${NC}..."
            cp -f "$script" "$HOME/.local/bin/$script_name"
            chmod +x "$HOME/.local/bin/$script_name"
        fi
    done
fi

# ── 7. Aplicar fondo de pantalla y generar temas dinámicos ─────
if [ -f "$SCRIPT_DIR/wallpapers/1.jpg" ]; then
    echo ""
    echo -e "  ${GREEN}→${NC} Aplicando wallpaper y generando temas dinámicos..."
    bash "$HOME/.local/bin/set-wallpaper.sh" "$SCRIPT_DIR/wallpapers/1.jpg" 2>/dev/null || true
fi

# ── 8. Resultado ────────────────────────────────────────────────
echo ""
echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  ✅ ¡Configuración aplicada exitosamente!                   ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║  Backup guardado en:                                        ║"
echo "║  $BACKUP_DIR"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# ── 9. Intentar recargar Sway si está corriendo ────────────────
if command -v swaymsg &> /dev/null && pgrep -x sway &> /dev/null; then
    echo -e "${YELLOW}🔄 ¿Recargar Sway ahora?${NC}"
    read -rp "  [s/N]: " reload_sway
    if [[ "$reload_sway" =~ ^[sS]$ ]]; then
        swaymsg reload || true
        echo -e "  ${GREEN}✓ Sway recargado${NC}"
    fi
else
    echo -e "${BLUE}💡 Podés iniciar tu sesión con Sway o recargar con Mod+Shift+C.${NC}"
fi
