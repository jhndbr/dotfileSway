#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║      Script de Instalación y Configuración de Sway           ║
# ║      Soporte Inteligente para PC de Escritorio & Laptop      ║
# ╚══════════════════════════════════════════════════════════════╝

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config/dotfiles-backup/$(date +%Y%m%d_%H%M%S)"
CLEAN_INSTALL=false
CLI_DEVICE=""
CLI_KB=""

# ── Parseo de argumentos / flags ────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        -c|--clean|--force|-f)
            CLEAN_INSTALL=true
            shift
            ;;
        --keyboard|--kb)
            CLI_KB="$2"
            shift 2
            ;;
        -h|--help)
            echo "Uso: bash setup.sh [OPCIONES]"
            echo ""
            echo "Opciones:"
            echo "  -c, --clean, -f, --force    Borra las configuraciones previas en ~/.config y scripts"
            echo "                              antes de copiar las nuevas (crea un backup previo)."
            echo "  --keyboard [es|us|us-intl|dual]  Fuerza la distribución de teclado."
            echo "  -h, --help                  Muestra este mensaje de ayuda."
            echo ""
            exit 0
            ;;
        *)
            echo -e "${RED}Opción desconocida: $1${NC}"
            echo "Usa: bash setup.sh --help"
            exit 1
            ;;
    esac
done

echo -e "${CYAN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║      🚀 Instalación de Dotfiles Sway (PC de Escritorio)     ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

if [ "$CLEAN_INSTALL" = true ]; then
    echo -e "${YELLOW}🧹 Modo instalación limpia activado (--clean / --force)${NC}"
    echo -e "${YELLOW}   Las carpetas existentes se borrarán tras generar el backup.${NC}"
    echo ""
fi

# ── 1. Perfil de Dispositivo (PC de Escritorio) ─────────────────
DEVICE_PROFILE="pc"
echo -e "${YELLOW}🖥️  Perfil: ${BLUE}${BOLD}PC de Escritorio (Optimizado)${NC}\n"

# ── 2. Selección de Distribución de Teclado ────────────────────
if [ -n "$CLI_KB" ]; then
    KB_LAYOUT="$CLI_KB"
else
    echo -e "${YELLOW}⌨️  Distribución del teclado para Sway:${NC}"
    echo "     1) Español (es) — Latinoamericano / España"
    echo "     2) Inglés EE.UU. (us) — QWERTY estándar"
    echo "     3) Inglés Internacional (us intl) — Con acentos vía dead keys ('+a = á, ~+n = ñ)"
    echo "     4) Doble distribución (us + es) — Alternar con Alt+Shift"
    read -rp "   Opción [1/2/3/4, Por defecto: 1]: " kb_choice
    kb_choice="${kb_choice:-1}"

    case "$kb_choice" in
        2|us)        KB_LAYOUT="us" ;;
        3|us-intl)   KB_LAYOUT="us-intl" ;;
        4|dual)      KB_LAYOUT="dual" ;;
        *)           KB_LAYOUT="es" ;;
    esac
fi
echo -e "   ${GREEN}✓ Distribución configurada: ${BOLD}$KB_LAYOUT${NC}\n"

# ── 3. Instalación de paquetes ──────────────────────────────────
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

# ── 4. Crear directorios necesarios ─────────────────────────────
mkdir -p ~/.config
mkdir -p ~/Pictures/Screenshots
mkdir -p ~/.local/bin

# ── 5. Backup de configuraciones existentes ─────────────────────
echo -e "${YELLOW}📦 Creando backup en $BACKUP_DIR${NC}"
mkdir -p "$BACKUP_DIR"

CONFIGS=(sway waybar wofi dunst foot swaylock gammastep gtk-3.0 gtk-4.0 environment.d qt5ct qt6ct matugen zed yazi xdg-desktop-portal fontconfig mpv fastfetch cava)

for item in "${CONFIGS[@]}"; do
    if [ -d "$HOME/.config/$item" ]; then
        cp -rf "$HOME/.config/$item" "$BACKUP_DIR/" 2>/dev/null || true
    fi
done

# Backup archivos individuales de ~/.config si existen
for cfg_file in mimeapps.list starship.toml; do
    if [ -f "$HOME/.config/$cfg_file" ]; then
        cp -f "$HOME/.config/$cfg_file" "$BACKUP_DIR/$cfg_file" 2>/dev/null || true
    fi
done

# Backup archivos de home
for file in .zshrc .zprofile .gitconfig .p10k.zsh .zshenv; do
    if [ -f "$HOME/$file" ]; then
        cp -f "$HOME/$file" "$BACKUP_DIR/$file" 2>/dev/null || true
    fi
done

echo -e "  ${GREEN}✓ Backup creado en $BACKUP_DIR${NC}"

# ── 6. Limpieza previa si se especificó la flag --clean ─────────
if [ "$CLEAN_INSTALL" = true ]; then
    echo ""
    echo -e "${YELLOW}🗑️  Eliminando configuraciones previas para instalación limpia...${NC}"
    for item in "${CONFIGS[@]}" zsh; do
        if [ -d "$HOME/.config/$item" ]; then
            rm -rf "$HOME/.config/$item"
        fi
    done
    rm -f "$HOME/.config/mimeapps.list" 2>/dev/null || true
    rm -f "$HOME/.config/starship.toml" 2>/dev/null || true
    rm -rf "$HOME/.config/matugen/templates" 2>/dev/null || true
    
    for file in .zshrc .zprofile .gitconfig .zshenv; do
        rm -f "$HOME/$file" 2>/dev/null || true
    done

    if [ -d "$SCRIPT_DIR/scripts" ]; then
        for script in "$SCRIPT_DIR/scripts/"*; do
            [ -f "$script" ] && rm -f "$HOME/.local/bin/$(basename "$script")" 2>/dev/null || true
        done
    fi
    echo -e "  ${GREEN}✓ Archivos previos eliminados${NC}"
fi

# ── 7. Copiar carpetas de configuración a ~/.config ─────────────
echo ""
echo -e "${CYAN}⚙️  Instalando configuraciones en ~/.config...${NC}"
for item in "${CONFIGS[@]}"; do
    if [ -d "$SCRIPT_DIR/config/$item" ]; then
        echo -e "  ${GREEN}→${NC} Copiando configuración de ${BLUE}$item${NC}..."
        mkdir -p "$HOME/.config/$item"
        cp -rf "$SCRIPT_DIR/config/$item/"* "$HOME/.config/$item/" 2>/dev/null || true
    fi
done

# ── 8. Distribución de Teclado ──────────────────────────────────
if [ -f "$SCRIPT_DIR/scripts/keyboard-layout.sh" ]; then
    bash "$SCRIPT_DIR/scripts/keyboard-layout.sh" set "$KB_LAYOUT"
    cp -f "$HOME/.config/sway/inputs.conf" "$SCRIPT_DIR/config/sway/inputs.conf" 2>/dev/null || true
    echo -e "  ${GREEN}✓ Distribución de teclado $KB_LAYOUT aplicada${NC}"
fi

# Copiar mimeapps.list
if [ -f "$SCRIPT_DIR/config/mimeapps.list" ]; then
    echo -e "  ${GREEN}→${NC} Copiando aplicaciones predeterminadas (${BLUE}mimeapps.list${NC})..."
    rm -f "$HOME/.config/mimeapps.list" 2>/dev/null || true
    cp -f "$SCRIPT_DIR/config/mimeapps.list" "$HOME/.config/mimeapps.list"
fi

# Copiar starship.toml
if [ -f "$SCRIPT_DIR/config/starship.toml" ]; then
    echo -e "  ${GREEN}→${NC} Copiando configuración de Starship (${BLUE}starship.toml${NC})..."
    mkdir -p "$HOME/.config"
    rm -f "$HOME/.config/starship.toml" 2>/dev/null || true
    cp -f "$SCRIPT_DIR/config/starship.toml" "$HOME/.config/starship.toml"
fi

# Registrar yazi.desktop en ~/.local/share/applications
if [ -f "$SCRIPT_DIR/config/yazi/yazi.desktop" ]; then
    echo -e "  ${GREEN}→${NC} Registrando launcher de Yazi (${BLUE}yazi.desktop${NC})..."
    mkdir -p "$HOME/.local/share/applications"
    cp -f "$SCRIPT_DIR/config/yazi/yazi.desktop" "$HOME/.local/share/applications/yazi.desktop"
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi

if [ -d "$SCRIPT_DIR/templates" ]; then
    echo -e "  ${GREEN}→${NC} Copiando plantillas de Matugen..."
    mkdir -p "$HOME/.config/matugen/templates"
    cp -rf "$SCRIPT_DIR/templates/"* "$HOME/.config/matugen/templates/" 2>/dev/null || true
fi

if [ -f "$HOME/.config/gtk-3.0/bookmarks" ]; then
    sed -i "s|file:///home/[^/]*|file://$HOME|g" "$HOME/.config/gtk-3.0/bookmarks" 2>/dev/null || true
fi

# ── 9. Copiar archivos de home (.zshrc, .zprofile, .gitconfig) ──
echo ""
echo -e "${CYAN}🏠 Aplicando configuraciones de home (~)...${NC}"
rm -f "$HOME/.zshenv" 2>/dev/null || true
systemctl --user unset-environment ZDOTDIR 2>/dev/null || true

for file in .zshrc .zprofile .gitconfig; do
    if [ -f "$SCRIPT_DIR/$file" ]; then
        echo -e "  ${GREEN}→${NC} Instalando ${BLUE}$file${NC}..."
        rm -f "$HOME/$file" 2>/dev/null || true
        cp -f "$SCRIPT_DIR/$file" "$HOME/$file"
    fi
done

# Soporte dual: asegurar que ~/.config/zsh tenga copia por si ZDOTDIR está en memoria
mkdir -p "$HOME/.config/zsh"
cp -f "$SCRIPT_DIR/.zshrc" "$HOME/.config/zsh/.zshrc"
cp -f "$SCRIPT_DIR/.zprofile" "$HOME/.config/zsh/.zprofile"

# ── 10. Copiar scripts a ~/.local/bin ───────────────────────────
if [ -d "$SCRIPT_DIR/scripts" ]; then
    echo ""
    echo -e "${CYAN}⚡ Instalando scripts utilitarios en ~/.local/bin...${NC}"
    for script in "$SCRIPT_DIR/scripts/"*; do
        if [ -f "$script" ]; then
            script_name=$(basename "$script")
            echo -e "  ${GREEN}→${NC} Instalando ${BLUE}$script_name${NC}..."
            cp -f "$script" "$HOME/.local/bin/$script_name"
            chmod +x "$HOME/.local/bin/$script_name"
        fi
    done
fi

# ── 11. Aplicar fondo de pantalla y generar temas dinámicos ────
if [ -f "$SCRIPT_DIR/wallpapers/1.jpg" ]; then
    echo ""
    echo -e "  ${GREEN}→${NC} Aplicando wallpaper y generando temas dinámicos..."
    bash "$HOME/.local/bin/set-wallpaper.sh" "$SCRIPT_DIR/wallpapers/1.jpg" 2>/dev/null || true
fi

# ── 12. Resultado ───────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  ✅ ¡Configuración aplicada exitosamente!                   ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║  Perfil de hardware: $DEVICE_PROFILE"
echo "║  Teclado:            $KB_LAYOUT"
echo "║  Backup guardado en: $BACKUP_DIR"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# ── 14. Recargar Sway si está corriendo ─────────────────────────
if command -v swaymsg &> /dev/null && pgrep -x sway &> /dev/null; then
    swaymsg reload || true
    echo -e "  ${GREEN}✓ Sway recargado en vivo con la nueva configuración${NC}"
else
    echo -e "${BLUE}💡 Podés iniciar tu sesión con Sway o recargar con Mod+Shift+C.${NC}"
fi
