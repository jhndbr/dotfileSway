#!/usr/bin/env bash
# ╔═════════════════════════════════════════════════════════════════════════╗
# ║   🚀 Script Universal de Detección & Configuración de Drivers de PC    ║
# ║   Detecta CPU, GPU (Intel/AMD/Nvidia/VM), Audio, Red, Bluetooth y Power║
# ║   Optimizado para Arch Linux y Entorno Wayland / Sway                  ║
# ╚═════════════════════════════════════════════════════════════════════════╝

set -eo pipefail

# ── Colores ─────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}▶ ${1}${NC}"; }
log_success() { echo -e "${GREEN}✓ ${1}${NC}"; }
log_warn()    { echo -e "${YELLOW}⚠ ${1}${NC}"; }
log_error()   { echo -e "${RED}✖ ${1}${NC}"; }
log_section() { echo -e "\n${CYAN}${BOLD}═══ ${1} ═══${NC}"; }

banner() {
    clear 2>/dev/null || true
    echo -e "${CYAN}${BOLD}"
    echo "╔═══════════════════════════════════════════════════════════════════╗"
    echo "║   🖥️  CONFIGURADOR UNIVERSAL DE HARDWARE & DRIVERS (SWAY)       ║"
    echo "║   Arch Linux • Wayland • Intel • AMD • NVIDIA • VirtualBox/VM     ║"
    echo "╚═══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

banner

# ── 1. Verificación de Permisos Root / Sudo ──────────────────────────────
log_info "Verificando permisos de superusuario (sudo)..."
sudo -v

# Mantener sudo activo en segundo plano
(while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done) &
SUDO_PID=$!
trap 'kill $SUDO_PID 2>/dev/null || true' EXIT

# Asegurar herramientas básicas de inspección
if ! command -v lspci &>/dev/null || ! command -v lsusb &>/dev/null; then
    log_info "Instalando herramientas de diagnóstico (pciutils, usbutils)..."
    sudo pacman -S --needed --noconfirm pciutils usbutils
fi

# ── 2. Detección de Hardware ─────────────────────────────────────────────
log_section "Analizando Hardware del Sistema"

PACKAGES=()
SERVICES=()
POST_ACTIONS=()

# 2.1 Tipo de Entorno (Físico vs Máquina Virtual)
VIRT_TYPE="none"
if command -v systemd-detect-virt &>/dev/null; then
    VIRT_TYPE=$(systemd-detect-virt || echo "none")
fi

echo -e "• ${BOLD}Entorno detectado:${NC} ${MAGENTA}${VIRT_TYPE}${NC}"

# 2.2 Detección de Procesador (CPU Microcode)
CPU_VENDOR="Desconocido"
if grep -q -i "intel" /proc/cpuinfo; then
    CPU_VENDOR="Intel"
    PACKAGES+=(intel-ucode)
    echo -e "• ${BOLD}Procesador (CPU):${NC} ${GREEN}Intel${NC} → Añadido ${CYAN}intel-ucode${NC}"
elif grep -q -i "amd" /proc/cpuinfo; then
    CPU_VENDOR="AMD"
    PACKAGES+=(amd-ucode)
    echo -e "• ${BOLD}Procesador (CPU):${NC} ${GREEN}AMD${NC} → Añadido ${CYAN}amd-ucode${NC}"
else
    echo -e "• ${BOLD}Procesador (CPU):${NC} ${YELLOW}Genérico / Emulado${NC}"
fi

# 2.3 Detección de Tarjetas Gráficas (GPU)
GPU_INFO=$(lspci -nnk 2>/dev/null | grep -iE 'vga|3d|display' || true)
echo -e "\n• ${BOLD}Dispositivos Gráficos Detectados:${NC}"
echo "$GPU_INFO" | while IFS= read -r line; do
    echo -e "  └─ ${CYAN}$line${NC}"
done

HAS_INTEL_GPU=false
HAS_AMD_GPU=false
HAS_NVIDIA_GPU=false
HAS_VM_GPU=false

# Análisis de GPUs
if echo "$GPU_INFO" | grep -qi "intel"; then
    HAS_INTEL_GPU=true
    PACKAGES+=(mesa vulkan-intel intel-media-driver libva-intel-driver libva-utils)
    echo -e "  ${GREEN}✓ Detectada GPU Intel:${NC} Mesa + Vulkan Intel + Drivers de video VA-API"
fi

if echo "$GPU_INFO" | grep -qiE "amd|radeon|advanced micro devices"; then
    HAS_AMD_GPU=true
    PACKAGES+=(mesa vulkan-radeon libva-mesa-driver mesa-vdpau libva-utils)
    echo -e "  ${GREEN}✓ Detectada GPU AMD Radeon:${NC} Mesa + RADV Vulkan + VA-API / VDPAU"
fi

if echo "$GPU_INFO" | grep -qi "nvidia"; then
    HAS_NVIDIA_GPU=true
    # Determinar si el kernel es linux o linux-zen/lts
    KERNEL_NAME=$(uname -r)
    if [[ "$KERNEL_NAME" =~ lts ]]; then
        PACKAGES+=(nvidia-lts nvidia-utils egl-wayland libva-nvidia-driver)
    else
        PACKAGES+=(nvidia-dkms nvidia-utils egl-wayland libva-nvidia-driver dkms linux-headers)
    fi

    # Si hay GPU Intel o AMD además de NVIDIA, es un sistema híbrido (Optimus / Prime)
    if [ "$HAS_INTEL_GPU" = true ] || [ "$HAS_AMD_GPU" = true ]; then
        PACKAGES+=(nvidia-prime)
        echo -e "  ${GREEN}✓ Detectada Gráfica Híbrida (NVIDIA Optimus/Prime):${NC} Añadido nvidia-prime"
    fi
    echo -e "  ${GREEN}✓ Detectada GPU NVIDIA:${NC} Drivers NVIDIA + EGL-Wayland + VA-API"
    POST_ACTIONS+=(configure_nvidia)
fi

# Análisis de Entornos Virtuales
if [ "$VIRT_TYPE" = "oracle" ] || echo "$GPU_INFO" | grep -qi "virtualbox"; then
    HAS_VM_GPU=true
    PACKAGES+=(virtualbox-guest-utils mesa)
    SERVICES+=(vboxservice.service)
    echo -e "  ${GREEN}✓ Detectado VirtualBox:${NC} Drivers Guest + Servicio de integración"
elif [ "$VIRT_TYPE" = "vmware" ] || echo "$GPU_INFO" | grep -qi "vmware"; then
    HAS_VM_GPU=true
    PACKAGES+=(open-vm-tools xf86-video-vmware mesa)
    SERVICES+=(vmtoolsd.service)
    echo -e "  ${GREEN}✓ Detectado VMware:${NC} Open-VM-Tools + Video VMware"
elif [ "$VIRT_TYPE" = "kvm" ] || [ "$VIRT_TYPE" = "qemu" ] || echo "$GPU_INFO" | grep -qiE "qemu|red hat|virtio"; then
    HAS_VM_GPU=true
    PACKAGES+=(qemu-guest-agent spice-vdagent mesa virglrenderer)
    SERVICES+=(qemu-guest-agent.service)
    echo -e "  ${GREEN}✓ Detectado QEMU / KVM:${NC} QEMU Guest Agent + Spice VDAgent + VirGL 3D"
fi

# Si no detectó GPU específica, asegurar paquete base Mesa
if [ "$HAS_INTEL_GPU" = false ] && [ "$HAS_AMD_GPU" = false ] && [ "$HAS_NVIDIA_GPU" = false ]; then
    PACKAGES+=(mesa vulkan-icd-loader libva-utils)
fi

# 2.4 Audio & Firmware de Sonido (SOF / ALSA / PipeWire)
log_section "Configuración de Audio & Sonido"
PACKAGES+=(
    pipewire
    pipewire-pulse
    pipewire-alsa
    pipewire-jack
    wireplumber
    pavucontrol
    alsa-utils
    alsa-ucm-conf
    alsa-firmware
    sof-firmware # Esencial para laptops modernas Intel/AMD con Sound Open Firmware
)
echo -e "• ${BOLD}Stack de Audio:${NC} PipeWire + WirePlumber + Sound Open Firmware (SOF)"

# 2.5 Red & Wireless (Wi-Fi / Ethernet / Firmwares)
log_section "Configuración de Red & Conectividad"
PACKAGES+=(
    networkmanager
    network-manager-applet
    wireless_tools
    wpa_supplicant
    linux-firmware
    iwd
)
SERVICES+=(NetworkManager.service)

# Detección de chips Broadcom Wi-Fi que requieren módulo privativo
if lspci -nn 2>/dev/null | grep -qiE "BCM43[0-9]{2}|Broadcom.*802.11"; then
    log_warn "Detectado chip Broadcom Wi-Fi → Añadiendo broadcom-wl-dkms..."
    PACKAGES+=(broadcom-wl-dkms dkms linux-headers)
fi

echo -e "• ${BOLD}Red:${NC} NetworkManager + Firmwares de conectividad"

# 2.6 Bluetooth
if lsusb 2>/dev/null | grep -qi "bluetooth" || lspci -nn 2>/dev/null | grep -qi "bluetooth" || [ -d "/sys/class/bluetooth" ]; then
    log_section "Dispositivo Bluetooth Detectado"
    PACKAGES+=(bluez bluez-utils blueman)
    SERVICES+=(bluetooth.service)
    echo -e "• ${BOLD}Bluetooth:${NC} BlueZ + Utilidades + Applet Blueman"
fi

# 2.7 Touchpad, Sensores & Energía (Laptops)
IS_LAPTOP=false
CHASSIS_TYPE=$(cat /sys/class/dmi/id/chassis_type 2>/dev/null || echo "0")
# Tipos 8, 9, 10, 14, 30, 31, 32 corresponden a Laptops, Notebooks, Subnotebooks, Convertibles
if [[ "$CHASSIS_TYPE" =~ ^(8|9|10|14|30|31|32)$ ]] || [ -d "/sys/class/power_supply/BAT0" ] || [ -d "/sys/class/power_supply/BAT1" ]; then
    IS_LAPTOP=true
    log_section "Equipo Portátil / Laptop Detectado"
    PACKAGES+=(
        brightnessctl
        power-profiles-daemon
        upower
        acpid
        libinput
    )
    SERVICES+=(power-profiles-daemon.service acpid.service)
    echo -e "• ${BOLD}Laptop Features:${NC} Brillo automático (brightnessctl), Power Profiles Daemon, ACPI & Libinput Touchpad"
else
    PACKAGES+=(libinput brightnessctl power-profiles-daemon)
    SERVICES+=(power-profiles-daemon.service)
fi

# ── 3. Resumen y Confirmación ────────────────────────────────────────────
# Filtrar paquetes duplicados
UNIQUE_PACKAGES=($(echo "${PACKAGES[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

log_section "Resumen de Instalación"
echo -e "${BOLD}Paquetes de controladores y sistema a instalar (${#UNIQUE_PACKAGES[@]}):${NC}"
echo -e "${CYAN}${UNIQUE_PACKAGES[*]}${NC}\n"

echo -e "${BOLD}Servicios a habilitar:${NC}"
echo -e "${MAGENTA}${SERVICES[*]}${NC}\n"

read -rp "▶ ¿Deseas proceder con la instalación y configuración de drivers? [S/n]: " CONFIRM
if [[ "$CONFIRM" =~ ^[nN]$ ]]; then
    log_warn "Instalación cancelada por el usuario."
    exit 0
fi

# ── 4. Instalación de Paquetes ───────────────────────────────────────────
log_section "Instalando Paquetes con Pacman"
sudo pacman -S --needed --noconfirm "${UNIQUE_PACKAGES[@]}"
log_success "Todos los paquetes y controladores han sido instalados"

# ── 5. Post-Configuración de Hardware ────────────────────────────────────

# 5.1 Configuración de NVIDIA para Wayland / Sway
configure_nvidia() {
    log_section "Aplicando Optimizaciones para NVIDIA en Wayland"
    
    # Modprobe KMS (Direct Rendering Manager Modesetting)
    echo "options nvidia_drm modeset=1 fbdev=1" | sudo tee /etc/modprobe.d/nvidia-wayland.conf > /dev/null
    log_success "Activado modesetting DRM en /etc/modprobe.d/nvidia-wayland.conf"

    # Variables de entorno para Sway / Wayland
    mkdir -p "$HOME/.config/environment.d"
    cat << 'EOF' > "$HOME/.config/environment.d/20-nvidia.conf"
# Variables de entorno para compatibilidad NVIDIA en Sway/Wayland
GBM_BACKEND=nvidia-drm
LIBVA_DRIVER_NAME=nvidia
__GLX_VENDOR_LIBRARY_NAME=nvidia
WLR_NO_HARDWARE_CURSORS=1
WLR_RENDERER=vulkan
EOF
    log_success "Variables de entorno NVIDIA creadas en ~/.config/environment.d/20-nvidia.conf"

    # Notificar sobre mkinitcpio
    if [ -f "/etc/mkinitcpio.conf" ]; then
        log_info "Verificando módulos KMS en mkinitcpio..."
        if ! grep -q "nvidia_drm" /etc/mkinitcpio.conf; then
            log_warn "Se recomienda añadir 'nvidia nvidia_modeset nvidia_uvm nvidia_drm' a MODULES en /etc/mkinitcpio.conf"
            read -rp "¿Deseas agregarlos y regenerar initramfs automáticamente? [s/N]: " REGEN_INIT
            if [[ "$REGEN_INIT" =~ ^[sS]$ ]]; then
                sudo sed -i 's/^MODULES=(\(.*\))/MODULES=(\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
                sudo sed -i 's/  */ /g' /etc/mkinitcpio.conf
                sudo mkinitcpio -P
                log_success "initramfs regenerado con soporte NVIDIA KMS"
            fi
        fi
    fi
}

for action in "${POST_ACTIONS[@]}"; do
    "$action"
done

# ── 6. Habilitación de Servicios Systemd ─────────────────────────────────
log_section "Habilitando Servicios de Hardware"

for srv in "${SERVICES[@]}"; do
    log_info "Habilitando $srv..."
    sudo systemctl enable --now "$srv" 2>/dev/null || sudo systemctl enable "$srv" 2>/dev/null || true
    log_success "Servicio $srv activado"
done

# Habilitar servicios de usuario de Pipewire
systemctl --user enable --now pipewire.service pipewire-pulse.service wireplumber.service 2>/dev/null || true
log_success "Servicios de audio PipeWire para el usuario habilitados"

# ── 7. Finalización ──────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}"
echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║  ✅ ¡CONFIGURACIÓN DE HARDWARE & DRIVERS COMPLETADA!              ║"
echo "╠═══════════════════════════════════════════════════════════════════╣"
echo "║  Tu sistema ahora cuenta con todos los controladores necesarios:   ║"
echo "║  • Aceleración gráfica 3D y Vulkan configurados                   ║"
echo "║  • Audio SOF/Pipewire listo para reproducir                       ║"
echo "║  • Red, Bluetooth y perfiles de energía listos                    ║"
echo "║                                                                   ║"
echo "║  👉 Ahora podés ejecutar 'bash setup.sh' para tus dotfiles.       ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

if [ "$HAS_NVIDIA_GPU" = true ]; then
    echo -e "${YELLOW}ℹ Nota para NVIDIA: Se recomienda reiniciar el equipo para cargar los módulos de kernel.${NC}"
fi
