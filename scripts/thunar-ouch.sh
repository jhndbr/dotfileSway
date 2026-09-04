#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║       thunar-ouch.sh — Integración de Ouch con Thunar         ║
# ╚══════════════════════════════════════════════════════════════╝

set -e

ACTION="$1"
shift || true

if [ -z "$ACTION" ] || [ $# -eq 0 ]; then
    notify-send "Ouch" "No se recibieron archivos para procesar." -i dialog-warning -u normal
    exit 1
fi

if ! command -v ouch &>/dev/null; then
    notify-send "Ouch" "La herramienta 'ouch' no está instalada en el sistema." -i dialog-error -u critical
    exit 1
fi

FIRST_FILE="$1"
PARENT_DIR="$(dirname "$FIRST_FILE")"
cd "$PARENT_DIR"

notify_success() {
    local msg="$1"
    notify-send "Ouch" "$msg" -i package-x-generic -u normal
}

notify_error() {
    local msg="$1"
    notify-send "Ouch" "$msg" -i dialog-error -u critical
}

case "$ACTION" in
    extract-here)
        notify-send "Ouch" "Descomprimiendo $([ $# -gt 1 ] && echo "$# archivos..." || echo "$(basename "$FIRST_FILE")...")" -i package-x-generic -t 2000
        if ouch decompress -y --here "$@"; then
            notify_success "Descompresión completada con éxito."
        else
            notify_error "Ocurrió un error al descomprimir con ouch."
            exit 1
        fi
        ;;

    extract-subdir)
        notify-send "Ouch" "Descomprimiendo en carpeta dedicada..." -i package-x-generic -t 2000
        if ouch decompress -y "$@"; then
            notify_success "Archivos extraídos en subcarpetas con éxito."
        else
            notify_error "Ocurrió un error al descomprimir con ouch."
            exit 1
        fi
        ;;

    compress-dialog)
        BASE_NAME="$(basename "$FIRST_FILE")"
        BASE_NO_EXT="${BASE_NAME%.*}"
        [ -z "$BASE_NO_EXT" ] && BASE_NO_EXT="archivo"
        DEFAULT_NAME="${BASE_NO_EXT}.tar.gz"

        if command -v zenity &>/dev/null; then
            ARCHIVE_NAME=$(zenity --entry \
                --title="Comprimir con Ouch" \
                --text="Nombre y formato del archivo comprimido:\n(ej: .tar.gz, .zip, .7z, .tar.zst, .tar.bz2)" \
                --entry-text="$DEFAULT_NAME" \
                --width=420)
        else
            ARCHIVE_NAME="$DEFAULT_NAME"
        fi

        if [ -z "$ARCHIVE_NAME" ]; then
            exit 0
        fi

        # Si el usuario no especificó extensión válida conocida por ouch, agregar .tar.gz por defecto
        if [[ ! "$ARCHIVE_NAME" =~ \.(tar|tar\.gz|tgz|tar\.bz2|tbz2|tar\.xz|txz|tar\.zst|tzst|zip|7z|gz|bz2|xz|zst)$ ]]; then
            ARCHIVE_NAME="${ARCHIVE_NAME}.tar.gz"
        fi

        OUTPUT_FILE="$PARENT_DIR/$ARCHIVE_NAME"

        notify-send "Ouch" "Comprimiendo en '$ARCHIVE_NAME'..." -i package-x-generic -t 2000
        if ouch compress -y "$@" "$OUTPUT_FILE"; then
            notify_success "Archivo comprimido creado: $ARCHIVE_NAME"
        else
            notify_error "Error al comprimir los archivos seleccionados."
            exit 1
        fi
        ;;

    compress-quick-tar)
        BASE_NAME="$(basename "$FIRST_FILE")"
        BASE_NO_EXT="${BASE_NAME%.*}"
        [ -z "$BASE_NO_EXT" ] && BASE_NO_EXT="archivo"
        OUTPUT_FILE="$PARENT_DIR/${BASE_NO_EXT}.tar.gz"

        notify-send "Ouch" "Comprimiendo a ${BASE_NO_EXT}.tar.gz..." -i package-x-generic -t 2000
        if ouch compress -y "$@" "$OUTPUT_FILE"; then
            notify_success "Creado: ${BASE_NO_EXT}.tar.gz"
        else
            notify_error "Error al comprimir a .tar.gz."
            exit 1
        fi
        ;;

    compress-quick-zip)
        BASE_NAME="$(basename "$FIRST_FILE")"
        BASE_NO_EXT="${BASE_NAME%.*}"
        [ -z "$BASE_NO_EXT" ] && BASE_NO_EXT="archivo"
        OUTPUT_FILE="$PARENT_DIR/${BASE_NO_EXT}.zip"

        notify-send "Ouch" "Comprimiendo a ${BASE_NO_EXT}.zip..." -i package-x-generic -t 2000
        if ouch compress -y "$@" "$OUTPUT_FILE"; then
            notify_success "Creado: ${BASE_NO_EXT}.zip"
        else
            notify_error "Error al comprimir a .zip."
            exit 1
        fi
        ;;

    *)
        echo "Uso: $0 {extract-here|extract-subdir|compress-dialog|compress-quick-tar|compress-quick-zip} <archivos...>"
        exit 1
        ;;
esac
