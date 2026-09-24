#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║        Menú Rápido de Aplicaciones CLI / TUI para Wofi       ║
# ║        Dotfiles Sway - Dank / Material Design                ║
# ╚══════════════════════════════════════════════════════════════╝

set -e

# Construir lista de aplicaciones disponibles
MENU_ITEMS=()

[ -x "$(command -v newsboat)" ]  && MENU_ITEMS+=("📰  Newsboat — Lector RSS (Tech, Ciberseguridad, Economía)")
[ -x "$(command -v nchat)" ]     && MENU_ITEMS+=("💬  Nchat — Cliente TUI para Telegram y WhatsApp")
[ -x "$(command -v btop)" ]      && MENU_ITEMS+=("📊  Btop — Monitor interactivo de recursos del sistema")
[ -x "$(command -v lazygit)" ]   && MENU_ITEMS+=("🐙  Lazygit — Interfaz gráfica de terminal para Git")
[ -x "$(command -v cava)" ]      && MENU_ITEMS+=("🎵  Cava — Visualizador de audio en tiempo real")
[ -x "$(command -v ncdu)" ]      && MENU_ITEMS+=("💾  Ncdu — Analizador de espacio y uso de disco")
[ -x "$(command -v htop)" ]      && MENU_ITEMS+=("⚡  Htop — Gestor de tareas y procesos ligero")
[ -x "$(command -v fastfetch)" ] && MENU_ITEMS+=("🚀  Fastfetch — Información y especificaciones del sistema")
[ -x "$(command -v cmatrix)" ]   && MENU_ITEMS+=("🟩  Matrix — Efecto visual de lluvia digital Matrix")
[ -x "$(command -v tty-clock)" ] && MENU_ITEMS+=("🕒  Reloj — Reloj digital de terminal con fecha")
[ -x "$(command -v zellij)" ]    && MENU_ITEMS+=("🗂️  Zellij — Multiplexor de terminales y espacios de trabajo")
[ -x "$(command -v w3m)" ]       && MENU_ITEMS+=("🌐  W3m — Navegador web en modo texto")

if [ ${#MENU_ITEMS[@]} -eq 0 ]; then
    notify-send "CLI Apps" "No se encontraron aplicaciones CLI compatibles instaladas."
    exit 1
fi

MENU_TEXT=$(printf "%s\n" "${MENU_ITEMS[@]}")

SELECCION=$(echo "$MENU_TEXT" | wofi --dmenu \
    --prompt "  Aplicaciones CLI" \
    --cache-file /dev/null \
    --insensitive \
    --width 580 \
    --height 420 \
    --lines 11)

[ -z "$SELECCION" ] && exit 0

case "$SELECCION" in
    *"Newsboat"*)
        setsid foot -a "cli-newsboat" -T "Newsboat — Lector RSS" newsboat &
        ;;
    *"Nchat"*)
        setsid foot -a "cli-nchat" -T "Nchat — Mensajería" nchat &
        ;;
    *"Btop"*)
        setsid foot -a "cli-btop" -T "Btop — Monitor de Sistema" btop &
        ;;
    *"Lazygit"*)
        setsid foot -a "cli-lazygit" -T "Lazygit" lazygit &
        ;;
    *"Cava"*)
        setsid foot -a "cli-cava" -T "Cava — Audio" cava &
        ;;
    *"Ncdu"*)
        setsid foot -a "cli-ncdu" -T "Ncdu — Uso de Disco" ncdu "$HOME" &
        ;;
    *"Htop"*)
        setsid foot -a "cli-htop" -T "Htop" htop &
        ;;
    *"Fastfetch"*)
        setsid foot -a "cli-fastfetch" -T "Fastfetch — Info" zsh -c "fastfetch; echo; echo -e '\033[1;34mPresiona cualquier tecla para salir...\033[0m'; read -k 1" &
        ;;
    *"Matrix"*)
        setsid foot -a "cli-cmatrix" -T "CMatrix" cmatrix -b &
        ;;
    *"Reloj"*)
        setsid foot -a "cli-clock" -T "Clock" tty-clock -c -C 4 &
        ;;
    *"Zellij"*)
        setsid foot -a "cli-zellij" -T "Zellij" zellij &
        ;;
    *"W3m"*)
        setsid foot -a "cli-w3m" -T "W3m" w3m "https://duckduckgo.com/lite" &
        ;;
esac
