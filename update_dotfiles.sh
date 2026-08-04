#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║    Script para Sincronizar ~/.config → dotfileSway           ║
# ║    Copia las configuraciones actuales al repositorio         ║
# ╚══════════════════════════════════════════════════════════════╝

set -e

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  🔄 Sincronizando configuraciones a dotfileSway             ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# ── 1. Crear estructura de carpetas ─────────────────────────────
mkdir -p "$DOTFILES_DIR/config"
mkdir -p "$DOTFILES_DIR/wallpapers"
mkdir -p "$DOTFILES_DIR/scripts"

# ── 2. Sincronizar configuraciones del entorno ──────────────────
CONFIGS=(sway waybar wofi dunst foot swaylock kanshi wlogout gammastep gtk-3.0 gtk-4.0 environment.d)

for app in "${CONFIGS[@]}"; do
    if [ -d "$CONFIG_DIR/$app" ]; then
        echo -e "  ${GREEN}→${NC} Actualizando: ${BLUE}$app${NC}"
        mkdir -p "$DOTFILES_DIR/config/$app"
        cp -rf "$CONFIG_DIR/$app/"* "$DOTFILES_DIR/config/$app/" 2>/dev/null || true
    else
        echo -e "  ${YELLOW}⚠${NC}  No encontrado: ${BLUE}$app${NC}"
    fi
done

# ── 3. Sincronizar archivos de home ─────────────────────────────
echo ""
echo -e "${CYAN}🏠 Sincronizando archivos de home...${NC}"
for file in .zshrc .zprofile .gitconfig; do
    if [ -f "$HOME/$file" ]; then
        echo -e "  ${GREEN}→${NC} Actualizando: ${BLUE}$file${NC}"
        cp -f "$HOME/$file" "$DOTFILES_DIR/$file"
    else
        echo -e "  ${YELLOW}⚠${NC}  No encontrado: ${BLUE}$file${NC}"
    fi
done

# ── 4. Sincronizar scripts ──────────────────────────────────────
if [ -d "$HOME/.local/bin" ]; then
    echo ""
    echo -e "${CYAN}⚡ Sincronizando scripts...${NC}"
    for script in screenshot.sh volume.sh brightness.sh color-picker.sh swayidle.sh gammastep-toggle.sh; do
        if [ -f "$HOME/.local/bin/$script" ]; then
            echo -e "  ${GREEN}→${NC} Actualizando: ${BLUE}$script${NC}"
            cp -f "$HOME/.local/bin/$script" "$DOTFILES_DIR/scripts/$script"
        fi
    done
fi

# ── 5. Sincronizar fondo de pantalla ───────────────────────────
WALLPAPER="$HOME/Pictures/1.jpg"
if [ -f "$WALLPAPER" ]; then
    echo ""
    echo -e "  ${GREEN}→${NC} Actualizando fondo de pantalla"
    cp -f "$WALLPAPER" "$DOTFILES_DIR/wallpapers/1.jpg"
fi

# ── 6. Auto-commit si hay repositorio git ──────────────────────
echo ""
if [ -d "$DOTFILES_DIR/.git" ]; then
    echo -e "${CYAN}📝 Verificando cambios en git...${NC}"
    cd "$DOTFILES_DIR"
    if [[ -n $(git status --porcelain) ]]; then
        echo -e "  ${GREEN}→${NC} Cambios detectados, creando commit..."
        git add -A
        git commit -m "🔄 sync: $(date '+%Y-%m-%d %H:%M:%S')" --quiet
        echo -e "  ${GREEN}✓${NC} Commit creado"

        echo -e "${YELLOW}  ¿Hacer push al remoto?${NC}"
        read -rp "    [s/N]: " do_push
        if [[ "$do_push" =~ ^[sS]$ ]]; then
            git push --quiet && echo -e "  ${GREEN}✓${NC} Push completado"
        fi
    else
        echo -e "  ${BLUE}→${NC} Sin cambios, todo al día"
    fi
fi

echo ""
echo -e "${GREEN}"
echo "════════════════════════════════════════════════════════════════"
echo "  ✅ ¡Configuraciones sincronizadas con éxito!"
echo "     Ubicación: $DOTFILES_DIR"
echo "════════════════════════════════════════════════════════════════"
echo -e "${NC}"
