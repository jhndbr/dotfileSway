#!/usr/bin/env bash
#
# Script para verificar disponibilidad de paquetes en Fedora
#

RED="\e[1;31m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
BLUE="\e[1;34m"
RESET="\e[0m"

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BLUE}║  Verificador de Paquetes - Fedora                     ║${RESET}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${RESET}"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_DIR="${SCRIPT_DIR}/packages"

# Arrays para almacenar resultados
declare -a AVAILABLE
declare -a UNAVAILABLE
declare -a INSTALLED

verify_package() {
    local pkg="$1"
    local file="$2"
    
    # Verificar si está instalado
    if dnf list --installed "$pkg" &>/dev/null; then
        INSTALLED+=("${file}:${pkg}")
        return 0
    fi
    
    # Verificar si está disponible
    if dnf list --available "$pkg" &>/dev/null; then
        AVAILABLE+=("${file}:${pkg}")
        return 0
    fi
    
    # No disponible
    UNAVAILABLE+=("${file}:${pkg}")
    return 1
}

process_file() {
    local file="$1"
    local filename="$(basename "$file")"
    
    echo -e "\n${BLUE}═══ Verificando: ${filename} ═══${RESET}\n"
    
    local total=0
    local current=0
    
    # Contar total de paquetes
    total=$(grep -v '^\s*#' "$file" | grep -v '^\s*$' | wc -l)
    
    while IFS= read -r package; do
        # Saltar comentarios y líneas vacías
        [[ "$package" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$package" ]] && continue
        
        ((current++))
        printf "\r${YELLOW}Progreso: ${current}/${total}${RESET}"
        
        verify_package "$package" "$filename"
    done < "$file"
    
    printf "\r\033[K"  # Limpiar línea
}

# Procesar archivos
for pkg_file in "$PACKAGES_DIR"/*.txt; do
    if [[ -f "$pkg_file" ]]; then
        process_file "$pkg_file"
    fi
done

# Mostrar resultados
echo -e "\n${BLUE}╔════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BLUE}║  RESUMEN                                               ║${RESET}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${RESET}\n"

echo -e "${GREEN}✓ Paquetes ya instalados: ${#INSTALLED[@]}${RESET}"
if [[ ${#INSTALLED[@]} -gt 0 ]]; then
    for item in "${INSTALLED[@]}"; do
        IFS=: read -r file pkg <<< "$item"
        echo -e "  ${GREEN}●${RESET} ${pkg} ${BLUE}(${file})${RESET}"
    done
fi

echo -e "\n${YELLOW}○ Paquetes disponibles (no instalados): ${#AVAILABLE[@]}${RESET}"
if [[ ${#AVAILABLE[@]} -gt 0 ]]; then
    for item in "${AVAILABLE[@]}"; do
        IFS=: read -r file pkg <<< "$item"
        echo -e "  ${YELLOW}●${RESET} ${pkg} ${BLUE}(${file})${RESET}"
    done
fi

echo -e "\n${RED}✗ Paquetes NO disponibles: ${#UNAVAILABLE[@]}${RESET}"
if [[ ${#UNAVAILABLE[@]} -gt 0 ]]; then
    for item in "${UNAVAILABLE[@]}"; do
        IFS=: read -r file pkg <<< "$item"
        echo -e "  ${RED}●${RESET} ${pkg} ${BLUE}(${file})${RESET}"
    done
    echo ""
    echo -e "${YELLOW}Sugerencia: Busca alternativas con:${RESET}"
    echo -e "${YELLOW}  dnf search <paquete>${RESET}"
fi

echo -e "\n${BLUE}════════════════════════════════════════════════════════${RESET}\n"

# Exit code
if [[ ${#UNAVAILABLE[@]} -gt 0 ]]; then
    exit 1
else
    exit 0
fi
