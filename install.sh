#!/usr/bin/env bash
# ====================================================================
# SwayShell Automated Installer & Environment Configurator
# For Debian Trixie (Debian 13) with Sway & Quickshell
# ====================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}   🚀 SwayShell Installer — Debian Trixie + Sway    ${NC}"
echo -e "${CYAN}====================================================${NC}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/swayshell"
DEFAULT_THEME="catppuccin"

SKIP_PKGS=false
if [ "$1" = "--no-pkg" ] || [ "$1" = "--skip-packages" ]; then
    SKIP_PKGS=true
fi

# 1. Limpiar repositorios externos incompatibles
if [ "$SKIP_PKGS" = false ]; then
    echo -e "\n${YELLOW}[1/7] Limpiando repositorios incompatibles (Qt 6.11)...${NC}"
    if [ -f "/etc/apt/sources.list.d/danklinux.list" ] || [ -f "/etc/apt/sources.list.d/home:AvengeMedia:danklinux.list" ]; then
        echo "  -> Eliminando repositorios externos de Qt 6.11..."
        sudo rm -f /etc/apt/sources.list.d/*danklinux*.list /etc/apt/keyrings/*danklinux*.gpg
        sudo apt update
    fi

    echo -e "\n${YELLOW}[2/7] Instalando paquetes y dependencias base del sistema...${NC}"
    sudo apt update
    sudo apt install -y \
        sway \
        swaybg \
        swaylock \
        foot \
        cliphist \
        wl-clipboard \
        grim \
        slurp \
        swappy \
        jq \
        brightnessctl \
        pipewire \
        wireplumber \
        pipewire-pulse \
        pavucontrol \
        qt6ct \
        qt5ct \
        qml6-module-qtquick \
        qml6-module-qtquick-controls \
        qml6-module-qtquick-layouts \
        qml6-module-qtquick-window \
        qml6-module-qtquick-templates \
        fonts-inter \
        fonts-jetbrains-mono \
        fonts-font-awesome \
        xdg-utils \
        git \
        build-essential \
        cmake \
        ninja-build \
        pkg-config

    # 2. Compilar Quickshell nativamente con CLI11, XKB y QMLDIR configurado
    echo -e "\n${YELLOW}[3/7] Verificando e instalando Quickshell...${NC}"
    if ! command -v quickshell >/dev/null 2>&1; then
        echo -e "  Quickshell no detectado en el PATH."
        echo -e "  ${CYAN}Instalando cabeceras de desarrollo de Debian Trixie (Qt 6.8 + CLI11 + XKB)...${NC}"
        
        sudo apt install -y \
            libcli11-dev \
            libxkbcommon-dev \
            libdrm-dev \
            libgbm-dev \
            libegl-dev \
            libgl-dev \
            libvulkan-dev \
            spirv-tools \
            qt6-base-dev \
            qt6-base-private-dev \
            qt6-declarative-dev \
            qt6-declarative-private-dev \
            qt6-shadertools-dev \
            qt6-wayland-dev \
            qt6-wayland-private-dev \
            qt6-svg-dev \
            libwayland-dev \
            wayland-protocols \
            libpipewire-0.3-dev \
            libjemalloc-dev \
            libpam0g-dev \
            libglib2.0-dev \
            libpolkit-agent-1-dev \
            libpolkit-gobject-1-dev

        if [ -f "/tmp/quickshell-build-10827/build/src/quickshell" ]; then
            echo "  -> Reutilizando compilación lista en /tmp/quickshell-build-10827..."
            sudo cmake --install "/tmp/quickshell-build-10827/build"
        else
            BUILD_DIR="/tmp/quickshell-build-$$"
            rm -rf "$BUILD_DIR"
            echo "  -> Clonando Quickshell..."
            git clone --depth 1 --recursive https://github.com/quickshell-mirror/quickshell.git "$BUILD_DIR"

            # En Debian Trixie (wayland-protocols 1.44) aún no existe ext-background-effect-v1.xml (1.46+)
            if [ ! -f "/usr/share/wayland-protocols/staging/ext-background-effect/ext-background-effect-v1.xml" ]; then
                sed -i '/background_effect/d; /_BackgroundEffect/d' "$BUILD_DIR/src/wayland/CMakeLists.txt"
            fi

            echo "  -> Configurando con CMake y Ninja (Qt 6.8, INSTALL_QMLDIR y Wayland nativo)..."
            cmake -B "$BUILD_DIR/build" -S "$BUILD_DIR" -G Ninja \
                -DCMAKE_BUILD_TYPE=Release \
                -DCMAKE_INSTALL_PREFIX=/usr/local \
                -DINSTALL_QMLDIR=/usr/lib/x86_64-linux-gnu/qt6/qml \
                -DCRASH_HANDLER=OFF \
                -DX11=OFF

            echo "  -> Compilando con $(nproc) hilos..."
            cmake --build "$BUILD_DIR/build" -j"$(nproc)"

            echo "  -> Instalando en /usr/local/bin..."
            sudo cmake --install "$BUILD_DIR/build"

            rm -rf "$BUILD_DIR"
        fi
        echo -e "  ${GREEN}[✔] Quickshell compilado e instalado con éxito en $(which quickshell)${NC}"
    else
        echo -e "  ${GREEN}[✔] Quickshell ya está disponible en: $(which quickshell)${NC}"
    fi
else
    echo -e "\n${YELLOW}[*] Saltando paso de paquetes (--no-pkg especificado).${NC}"
fi

# 3. Configurar Variables de Entorno para Wayland & Qt
echo -e "\n${YELLOW}[4/7] Configurando variables de entorno para Wayland y Qt...${NC}"
ENV_FILE="$HOME/.config/environment.d/10-sway-wayland.conf"
mkdir -p "$(dirname "$ENV_FILE")"

cat <<'EOF' > "$ENV_FILE"
# Sway & Wayland Qt Configuration
QT_QPA_PLATFORM="wayland;xcb"
QT_QPA_PLATFORMTHEME="qt6ct"
QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
XDG_CURRENT_DESKTOP="sway"
XDG_SESSION_TYPE="wayland"
MOZ_ENABLE_WAYLAND="1"
EOF
echo -e "  ${GREEN}[✔] Variables guardadas en:${NC} $ENV_FILE"

# 4. Despliegue de SwayShell en ~/.config/quickshell
echo -e "\n${YELLOW}[5/7] Desplegando configuración de Quickshell...${NC}"
mkdir -p "$(dirname "$TARGET_DIR")"

if [ -L "$TARGET_DIR" ] || [ -d "$TARGET_DIR" ]; then
    rm -rf "${TARGET_DIR}.bak"
    mv "$TARGET_DIR" "${TARGET_DIR}.bak"
    echo -e "  (Copia de respaldo previa movida a ${TARGET_DIR}.bak)"
fi

ln -s "$SCRIPT_DIR" "$TARGET_DIR"
echo -e "  ${GREEN}[✔] Enlace creado:${NC} $TARGET_DIR -> $SCRIPT_DIR"

# 5. Configurar activación de DBus para notificaciones
echo -e "\n${YELLOW}[6/7] Registrando servicio de notificaciones en DBus (org.freedesktop.Notifications)...${NC}"
DBUS_SVC_DIR="$HOME/.local/share/dbus-1/services"
mkdir -p "$DBUS_SVC_DIR"
chmod +x "$SCRIPT_DIR/scripts/start-shell.sh"
chmod +x "$SCRIPT_DIR/scripts/notify-fallback.py"

cat <<EOF > "$DBUS_SVC_DIR/org.freedesktop.Notifications.service"
[D-BUS Service]
Name=org.freedesktop.Notifications
Exec=$SCRIPT_DIR/scripts/start-shell.sh
EOF
# Sobrescribir servicio de Plasma si existe para evitar bloqueos de libnotify/Electron
cp "$DBUS_SVC_DIR/org.freedesktop.Notifications.service" "$DBUS_SVC_DIR/org.kde.plasma.Notifications.service"
dbus-send --session --type=method_call --dest=org.freedesktop.DBus / org.freedesktop.DBus.ReloadConfig 2>/dev/null || true
echo -e "  ${GREEN}[✔] DBus service registrado en:${NC} $DBUS_SVC_DIR/org.freedesktop.Notifications.service"

# 6. Aplicar Plantillas de Tema y Configuración de Sway
echo -e "\n${YELLOW}[7/7] Aplicando plantillas de tema y configuración de Sway...${NC}"
chmod +x "$SCRIPT_DIR/scripts/apply-theme.sh"
chmod +x "$SCRIPT_DIR/scripts/screenshot.sh"
"$SCRIPT_DIR/scripts/apply-theme.sh" "$DEFAULT_THEME"

SWAY_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/sway"
mkdir -p "$SWAY_CONFIG_DIR"
cp "$SCRIPT_DIR/sway/config" "$SWAY_CONFIG_DIR/config"
echo -e "  ${GREEN}[✔] Configuración de Sway actualizada en:${NC} $SWAY_CONFIG_DIR/config"

echo -e "\n${GREEN}====================================================${NC}"
echo -e "${GREEN}  ✨ ¡Instalación y Configuración Completadas!       ${NC}"
echo -e "${GREEN}====================================================${NC}"
echo -e "Para iniciar o recargar SwayShell:"
echo -e "  ${BLUE}~/.config/quickshell/swayshell/scripts/start-shell.sh &${NC}\n"
