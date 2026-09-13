#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║        Lanzador de Máquina Virtual para Pruebas (QEMU/KVM)    ║
# ║        Optimizado para Wayland, Sway y Quickshell 3D        ║
# ╚══════════════════════════════════════════════════════════════╝

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
VM_DIR="$REPO_DIR/.vm"

# Parámetros por defecto
RAM="4G"
CPUS="4"
DISK_SIZE="25G"
DISK_IMG="$VM_DIR/arch-vm.qcow2"
ISO_FILE=""
SSH_PORT="2222"
USE_GL=true

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

show_help() {
    echo -e "${CYAN}${BOLD}Uso:${NC} bash scripts/test/run-vm.sh [OPCIONES]"
    echo ""
    echo "Opciones:"
    echo "  --iso <ruta>         Ruta a imagen ISO de instalación (ej. archlinux-x86_64.iso)"
    echo "  --disk <ruta>        Ruta al archivo de disco QCOW2 (por defecto: .vm/arch-vm.qcow2)"
    echo "  --ram <cantidad>     Memoria RAM asignada a la VM (por defecto: 4G)"
    echo "  --cpus <número>      Cantidad de núcleos de CPU (por defecto: 4)"
    echo "  --no-gl              Desactivar aceleración 3D OpenGL (usar si el backend de video falla)"
    echo "  --create-disk        Solo crea el disco virtual QCOW2 si no existe y sale"
    echo "  -h, --help           Muestra esta ayuda"
    echo ""
    echo "Características incluidas:"
    echo "  • Aceleración KVM por hardware"
    echo "  • Gráficos VirtIO con soporte 3D VirGL (necesario para QtQuick / Wayland)"
    echo "  • Carpeta compartida del repositorio dotfileSway (tag: 'dotfiles')"
    echo "  • Reenvío de puerto SSH: localhost:2222 -> VM:22"
    echo ""
    echo "Montar los dotfiles dentro de la VM:"
    echo "  sudo mkdir -p /mnt/dotfiles"
    echo "  sudo mount -t 9p -o trans=virtio,version=9p2000.L dotfiles /mnt/dotfiles"
    echo "  cd /mnt/dotfiles && bash scripts/test/setup-vm.sh"
}

# Parseo de argumentos
while [[ $# -gt 0 ]]; do
    case "$1" in
        --iso)
            ISO_FILE="$2"
            shift 2
            ;;
        --disk)
            DISK_IMG="$2"
            shift 2
            ;;
        --ram)
            RAM="$2"
            shift 2
            ;;
        --cpus)
            CPUS="$2"
            shift 2
            ;;
        --no-gl)
            USE_GL=false
            shift
            ;;
        --create-disk)
            mkdir -p "$VM_DIR"
            if [ ! -f "$DISK_IMG" ]; then
                echo -e "${GREEN}Creando disco virtual $DISK_IMG ($DISK_SIZE)...${NC}"
                qemu-img create -f qcow2 "$DISK_IMG" "$DISK_SIZE"
            else
                echo -e "${YELLOW}El disco $DISK_IMG ya existe.${NC}"
            fi
            exit 0
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Opción desconocida: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

echo -e "${CYAN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║      🚀 Iniciando Entorno de Pruebas VM Sway + Quickshell    ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# 1. Comprobar QEMU
if ! command -v qemu-system-x86_64 &>/dev/null; then
    echo -e "${RED}✗ Error: qemu-system-x86_64 no está instalado en el sistema.${NC}"
    echo "Instálalo ejecutando: sudo pacman -S qemu-desktop virtiofsd"
    exit 1
fi

# 2. Comprobar KVM
KVM_OPTS=""
if [ -w /dev/kvm ]; then
    echo -e "  ${GREEN}✓ Aceleración KVM habilitada (/dev/kvm accesible)${NC}"
    KVM_OPTS="-enable-kvm -cpu host"
else
    echo -e "  ${YELLOW}⚠ Advertencia: KVM no está disponible o no hay permisos en /dev/kvm. Rendimiento reducido.${NC}"
    KVM_OPTS="-cpu max"
fi

# 3. Preparar directorio y disco virtual
mkdir -p "$VM_DIR"
if [ ! -f "$DISK_IMG" ]; then
    echo -e "  ${BLUE}→ Creando disco virtual nuevo ($DISK_SIZE): $DISK_IMG${NC}"
    qemu-img create -f qcow2 "$DISK_IMG" "$DISK_SIZE"
else
    echo -e "  ${GREEN}✓ Utilizando disco virtual existente: $DISK_IMG${NC}"
fi

# 4. Configurar display y gráficos
DISPLAY_OPTS=""
if [ "$USE_GL" = true ]; then
    # VirtIO GPU con soporte VirGL 3D
    DISPLAY_OPTS="-device virtio-vga-gl -display gtk,gl=on,zoom-to-fit=on"
    echo -e "  ${GREEN}✓ Aceleración 3D VirtIO-GL (GTK) activada para Wayland${NC}"
else
    DISPLAY_OPTS="-vga virtio -display gtk,zoom-to-fit=on"
    echo -e "  ${YELLOW}⚠ Modo gráfico sin aceleración 3D (Software rendering)${NC}"
fi

# 5. Opciones de arranque (ISO o Disco)
BOOT_OPTS=""
if [ -n "$ISO_FILE" ]; then
    if [ ! -f "$ISO_FILE" ]; then
        echo -e "${RED}✗ El archivo ISO no existe: $ISO_FILE${NC}"
        exit 1
    fi
    echo -e "  ${GREEN}✓ Arrancando desde ISO: $ISO_FILE${NC}"
    BOOT_OPTS="-cdrom $ISO_FILE -boot d"
else
    # Buscar ISO en directorio actual o de descargas si el disco está recién creado
    DISK_SIZE_BYTES=$(stat -c%s "$DISK_IMG" 2>/dev/null || echo 0)
    if [ "$DISK_SIZE_BYTES" -lt 500000000 ]; then
        # Disco menor a 500MB (probablemente nuevo/vacío)
        POSSIBLE_ISOS=($(ls -1 "$HOME"/Descargas/*.iso "$HOME"/Downloads/*.iso "$VM_DIR"/*.iso "$REPO_DIR"/*.iso 2>/dev/null || true))
        if [ ${#POSSIBLE_ISOS[@]} -gt 0 ]; then
            ISO_FILE="${POSSIBLE_ISOS[0]}"
            echo -e "  ${YELLOW}ℹ Disco vacío detectado. Usando ISO encontrada: $ISO_FILE${NC}"
            BOOT_OPTS="-cdrom $ISO_FILE -boot d"
        else
            echo -e "  ${YELLOW}ℹ No se especificó --iso. Si la VM no arranca, pasa una ISO con: --iso ruta/arch.iso${NC}"
        fi
    fi
fi

# 6. Configuración de Carpeta Compartida (VirtFS 9p)
SHARE_OPTS="-virtfs local,path=$REPO_DIR,mount_tag=dotfiles,security_model=none,id=dotfiles"
echo -e "  ${GREEN}✓ Carpeta compartida montable como 'dotfiles': $REPO_DIR${NC}"
echo -e "  ${GREEN}✓ Reenvío SSH disponible en puerto: $SSH_PORT${NC}\n"

echo -e "${CYAN}Ejecutando QEMU... Presiona Ctrl+Alt+G para liberar el cursor del mouse de la VM.${NC}\n"

exec qemu-system-x86_64 \
    $KVM_OPTS \
    -m "$RAM" \
    -smp "$CPUS" \
    -drive file="$DISK_IMG",if=virtio,format=qcow2 \
    $BOOT_OPTS \
    $DISPLAY_OPTS \
    $SHARE_OPTS \
    -net nic,model=virtio \
    -net user,hostfwd=tcp::$SSH_PORT-:22 \
    -audiodev pa,id=snd0 \
    -device intel-hda \
    -device hda-output,audiodev=snd0
