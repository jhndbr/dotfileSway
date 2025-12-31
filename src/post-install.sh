#!/usr/bin/env bash
#
# Post-Installation Script - Optimizaciones y mejoras adicionales
# Para usar después de la instalación principal
#
# Author: Justus0405 (modificado)
# License: MIT

### COLORES ###
export red="\e[1;31m"
export green="\e[1;32m"
export yellow="\e[1;33m"
export blue="\e[1;34m"
export cyan="\e[1;36m"
export reset="\e[0m"

clear
cat <<"EOF"
╔══════════════════════════════════════════════════════╗
║                                                      ║
║  Post-Instalación - Optimizaciones y Mejoras        ║
║  Para Fedora i3WM                                    ║
║                                                      ║
╚══════════════════════════════════════════════════════╝

EOF

echo -e "${yellow}Este script contiene mejoras opcionales para tu sistema${reset}\n"

# Función para preguntar si/no
ask_yes_no() {
	local prompt="$1"
	while true; do
		read -rp "$prompt [y/N] " response
		case "${response}" in
		[Yy])
			return 0
			;;
		[Nn] | "")
			return 1
			;;
		*)
			echo "Por favor responde 'y' o 'n'"
			;;
		esac
	done
}

# 1. DNF Optimizations
if ask_yes_no "${cyan}¿Optimizar configuración de DNF para descargas más rápidas?${reset}"; then
	echo -e "${green}[INFO]${reset} Optimizando DNF..."
	
	# Backup del archivo original
	sudo cp /etc/dnf/dnf.conf /etc/dnf/dnf.conf.backup
	
	# Añadir configuraciones
	echo "max_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf
	echo "fastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf
	echo "deltarpm=True" | sudo tee -a /etc/dnf/dnf.conf
	
	echo -e "${green}[OK]${reset} DNF optimizado"
fi

# 2. Habilitar TRIM para SSDs
if ask_yes_no "${cyan}¿Habilitar TRIM para SSD? (solo si tienes SSD)${reset}"; then
	echo -e "${green}[INFO]${reset} Habilitando TRIM..."
	sudo systemctl enable fstrim.timer
	sudo systemctl start fstrim.timer
	echo -e "${green}[OK]${reset} TRIM habilitado"
fi

# 3. Reducir swappiness (mejor para sistemas con suficiente RAM)
if ask_yes_no "${cyan}¿Reducir swappiness a 10? (recomendado para 8GB+ RAM)${reset}"; then
	echo -e "${green}[INFO]${reset} Configurando swappiness..."
	echo "vm.swappiness=10" | sudo tee /etc/sysctl.d/99-swappiness.conf
	sudo sysctl -p /etc/sysctl.d/99-swappiness.conf
	echo -e "${green}[OK]${reset} Swappiness configurado a 10"
fi

# 4. Instalar codecs multimedia adicionales
if ask_yes_no "${cyan}¿Instalar codecs multimedia adicionales (H.264, AAC, etc.)?${reset}"; then
	echo -e "${green}[INFO]${reset} Instalando codecs multimedia..."
	sudo dnf install -y gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel
	sudo dnf install -y lame\* --exclude=lame-devel
	sudo dnf group upgrade -y --with-optional Multimedia
	echo -e "${green}[OK]${reset} Codecs instalados"
fi

# 5. Instalar herramientas de desarrollo
if ask_yes_no "${cyan}¿Instalar herramientas de desarrollo adicionales (git, make, gcc)?${reset}"; then
	echo -e "${green}[INFO]${reset} Instalando herramientas de desarrollo..."
	sudo dnf groupinstall -y "Development Tools"
	sudo dnf install -y git curl wget neovim htop
	echo -e "${green}[OK]${reset} Herramientas de desarrollo instaladas"
fi

# 6. Configurar firewall
if ask_yes_no "${cyan}¿Configurar firewall (firewalld)?${reset}"; then
	echo -e "${green}[INFO]${reset} Configurando firewall..."
	sudo systemctl enable firewalld
	sudo systemctl start firewalld
	sudo firewall-cmd --set-default-zone=public
	echo -e "${green}[OK]${reset} Firewall configurado"
fi

# 7. Limpiar sistema
if ask_yes_no "${cyan}¿Limpiar paquetes no utilizados y cache?${reset}"; then
	echo -e "${green}[INFO]${reset} Limpiando sistema..."
	sudo dnf autoremove -y
	sudo dnf clean all
	echo -e "${green}[OK]${reset} Sistema limpio"
fi

# 8. Instalar fuentes adicionales
if ask_yes_no "${cyan}¿Instalar fuentes adicionales (Microsoft core fonts, etc.)?${reset}"; then
	echo -e "${green}[INFO]${reset} Instalando fuentes..."
	sudo dnf install -y fira-code-fonts 'mozilla-fira*' 'google-roboto*'
	
	# Microsoft fonts (requiere RPM Fusion)
	if dnf repolist | grep -q "rpmfusion"; then
		sudo dnf install -y curl cabextract xorg-x11-font-utils fontconfig
		sudo rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm 2>/dev/null || true
	fi
	
	fc-cache -fv
	echo -e "${green}[OK]${reset} Fuentes instaladas"
fi

# 9. Configurar grub timeout
if ask_yes_no "${cyan}¿Reducir timeout de GRUB a 3 segundos?${reset}"; then
	echo -e "${green}[INFO]${reset} Configurando GRUB..."
	sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=3/' /etc/default/grub
	sudo grub2-mkconfig -o /boot/grub2/grub.cfg
	echo -e "${green}[OK]${reset} GRUB configurado"
fi

# 10. Habilitar DNF automatic updates (opcional)
if ask_yes_no "${cyan}¿Habilitar actualizaciones automáticas de seguridad?${reset}"; then
	echo -e "${green}[INFO]${reset} Configurando actualizaciones automáticas..."
	sudo dnf install -y dnf-automatic
	sudo systemctl enable --now dnf-automatic.timer
	echo -e "${green}[OK]${reset} Actualizaciones automáticas habilitadas"
fi

# 11. Instalar picom (compositor para efectos visuales)
if ask_yes_no "${cyan}¿Instalar picom para sombras y transparencias?${reset}"; then
	echo -e "${green}[INFO]${reset} Instalando picom..."
	sudo dnf install -y picom
	
	# Crear configuración básica
	mkdir -p ~/.config/picom
	cat > ~/.config/picom/picom.conf <<'PICOM_EOF'
# Sombras
shadow = true;
shadow-radius = 12;
shadow-opacity = 0.75;
shadow-offset-x = -12;
shadow-offset-y = -12;

# Desvanecimiento
fading = true;
fade-in-step = 0.03;
fade-out-step = 0.03;
fade-delta = 5;

# Transparencia
inactive-opacity = 0.95;
frame-opacity = 0.9;

# Otros
backend = "glx";
vsync = true;
mark-wmwin-focused = true;
mark-ovredir-focused = true;
detect-rounded-corners = true;
detect-client-opacity = true;
detect-transient = true;
glx-no-stencil = true;
use-damage = true;
PICOM_EOF
	
	echo -e "${green}[OK]${reset} Picom instalado y configurado"
	echo -e "${yellow}[INFO]${reset} Picom ya está en tu i3 config (se inicia automáticamente)"
fi

# 12. Configurar dunst (notificaciones)
if ask_yes_no "${cyan}¿Instalar y configurar dunst para notificaciones?${reset}"; then
	echo -e "${green}[INFO]${reset} Instalando dunst..."
	sudo dnf install -y dunst libnotify
	
	# Crear configuración
	mkdir -p ~/.config/dunst
	cat > ~/.config/dunst/dunstrc <<'DUNST_EOF'
[global]
    monitor = 0
    follow = mouse
    width = 300
    height = 300
    origin = top-right
    offset = 10x50
    scale = 0
    notification_limit = 0
    
    progress_bar = true
    progress_bar_height = 10
    progress_bar_frame_width = 1
    progress_bar_min_width = 150
    progress_bar_max_width = 300
    
    indicate_hidden = yes
    transparency = 10
    separator_height = 2
    padding = 8
    horizontal_padding = 8
    text_icon_padding = 0
    frame_width = 2
    frame_color = "#89b4fa"
    separator_color = frame
    sort = yes
    
    font = JetBrains Mono Nerd Font 10
    line_height = 0
    markup = full
    format = "<b>%s</b>\n%b"
    alignment = left
    vertical_alignment = center
    show_age_threshold = 60
    ellipsize = middle
    ignore_newline = no
    stack_duplicates = true
    hide_duplicate_count = false
    show_indicators = yes
    
    icon_position = left
    min_icon_size = 32
    max_icon_size = 64
    
    sticky_history = yes
    history_length = 20
    
    browser = /usr/bin/xdg-open
    
    title = Dunst
    class = Dunst
    corner_radius = 10
    ignore_dbusclose = false
    
    mouse_left_click = close_current
    mouse_middle_click = do_action, close_current
    mouse_right_click = close_all

[urgency_low]
    background = "#1e1e2e"
    foreground = "#cdd6f4"
    timeout = 5

[urgency_normal]
    background = "#1e1e2e"
    foreground = "#cdd6f4"
    timeout = 10

[urgency_critical]
    background = "#1e1e2e"
    foreground = "#f38ba8"
    frame_color = "#f38ba8"
    timeout = 0
DUNST_EOF
	
	echo -e "${green}[OK]${reset} Dunst instalado y configurado"
	echo -e "${yellow}[INFO]${reset} Dunst ya está en tu i3 config (se inicia automáticamente)"
fi

# 13. Crear script de limpieza periódica
if ask_yes_no "${cyan}¿Crear script de limpieza periódica del sistema?${reset}"; then
	echo -e "${green}[INFO]${reset} Creando script de limpieza..."
	
	cat > ~/limpiar-sistema.sh <<'CLEAN_EOF'
#!/bin/bash
echo "Limpiando sistema..."
sudo dnf autoremove -y
sudo dnf clean all
sudo journalctl --vacuum-time=3d
rm -rf ~/.cache/thumbnails/*
echo "Sistema limpio!"
CLEAN_EOF
	
	chmod +x ~/limpiar-sistema.sh
	echo -e "${green}[OK]${reset} Script creado: ~/limpiar-sistema.sh"
	echo -e "${yellow}[INFO]${reset} Ejecuta ~/limpiar-sistema.sh cuando quieras limpiar el sistema"
fi

# 14. Mostrar información del sistema
echo -e "\n${blue}╔══════════════════════════════════════════════════════╗${reset}"
echo -e "${blue}║  Post-Instalación Completada                        ║${reset}"
echo -e "${blue}╚══════════════════════════════════════════════════════╝${reset}\n"

echo -e "${green}✓ Todas las optimizaciones han sido aplicadas${reset}\n"

echo -e "${cyan}Comandos útiles:${reset}"
echo -e "  ${yellow}• Super + Return${reset}       - Abrir terminal"
echo -e "  ${yellow}• Super + d${reset}            - Launcher (rofi)"
echo -e "  ${yellow}• Super + q${reset}            - Cerrar ventana"
echo -e "  ${yellow}• Super + Shift + p${reset}    - Power menu"
echo -e "  ${yellow}• Super + Shift + x${reset}    - Bloquear pantalla"
echo -e "  ${yellow}• Super + r${reset}            - Modo resize"
echo -e "  ${yellow}• Super + grave (~)${reset}    - Terminal flotante (scratchpad)"
echo -e "  ${yellow}• Super + n${reset}            - Screenshot área (flameshot)"
echo -e "  ${yellow}• Super + m${reset}            - Screenshot pantalla completa"

echo -e "\n${yellow}Recuerda reiniciar tu sistema para aplicar todos los cambios${reset}"

read -rp "Presiona Enter para salir..."
