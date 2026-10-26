#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║       thunar-ouch.sh — Integración de Ouch con Thunar         ║
# ╚══════════════════════════════════════════════════════════════╝

set -e
export PATH="$HOME/.local/bin:$PATH"

ACTION="$1"
shift || true

if [ -z "$ACTION" ] || [ $# -eq 0 ]; then
    notify-send "Ouch" "No se recibieron archivos para procesar." -i dialog-warning -u normal 2>/dev/null || true
    exit 1
fi

if ! command -v ouch &>/dev/null; then
    notify-send "Ouch" "La herramienta 'ouch' no está instalada en el sistema." -i dialog-error -u critical 2>/dev/null || true
    exit 1
fi

FIRST_FILE="$1"
PARENT_DIR="$(dirname "$FIRST_FILE")"
cd "$PARENT_DIR"

notify_success() {
    local msg="$1"
    notify-send "Ouch" "$msg" -i package-x-generic -u normal 2>/dev/null || true
}

notify_error() {
    local msg="$1"
    notify-send "Ouch" "$msg" -i dialog-error -u critical 2>/dev/null || true
}

case "$ACTION" in
    extract-here)
        notify-send "Ouch" "Descomprimiendo $([ $# -gt 1 ] && echo "$# archivos..." || echo "$(basename "$FIRST_FILE")...")" -i package-x-generic -t 2000 2>/dev/null || true
        if ouch decompress -y --here "$@"; then
            notify_success "Descompresión completada con éxito."
        else
            notify_error "Ocurrió un error al descomprimir con ouch."
            exit 1
        fi
        ;;

    extract-subdir)
        notify-send "Ouch" "Descomprimiendo en carpeta dedicada..." -i package-x-generic -t 2000 2>/dev/null || true
        if ouch decompress -y "$@"; then
            notify_success "Archivos extraídos en subcarpetas con éxito."
        else
            notify_error "Ocurrió un error al descomprimir con ouch."
            exit 1
        fi
        ;;

    view)
        if command -v file-roller &>/dev/null; then
            exec file-roller "$FIRST_FILE"
        elif command -v foot &>/dev/null; then
            exec foot -T "Archivador: $(basename "$FIRST_FILE")" -e sh -c 'ouch list "$1" | less -R' _ "$FIRST_FILE"
        else
            notify-send "Ouch" "Instala file-roller o usa la terminal para ver el contenido." -i dialog-information 2>/dev/null || true
        fi
        ;;

    open-archive)
        if command -v file-roller &>/dev/null; then
            exec file-roller "$FIRST_FILE"
        fi

        CHOICE=""
        if command -v zenity &>/dev/null; then
            CHOICE=$(zenity --list \
                --title="Gestor de Archivos Comprimidos" \
                --text="Archivo: <b>$(basename "$FIRST_FILE")</b>\n¿Qué acción deseas realizar?" \
                --radiolist \
                --column="" --column="Clave" --column="Acción" \
                TRUE "extract-subdir" "Extraer en subcarpeta (Recomendado)" \
                FALSE "extract-here" "Extraer directamente aquí" \
                FALSE "view" "Ver contenido de archivos en terminal" \
                --hide-column=2 \
                --width=450 --height=240 2>/dev/null) || exit 0
        else
            CHOICE="extract-subdir"
        fi

        case "$CHOICE" in
            extract-subdir)
                exec "$0" extract-subdir "$FIRST_FILE"
                ;;
            extract-here)
                exec "$0" extract-here "$FIRST_FILE"
                ;;
            view)
                exec "$0" view "$FIRST_FILE"
                ;;
            *)
                exit 0
                ;;
        esac
        ;;

    compress-dialog)
        if [ $# -gt 1 ]; then
            PARENT_BASE="$(basename "$PARENT_DIR")"
            BASE_NO_EXT="${PARENT_BASE:-archivo}"
        else
            BASE_NAME="$(basename "$FIRST_FILE")"
            BASE_NO_EXT="${BASE_NAME%.*}"
            [ -z "$BASE_NO_EXT" ] && BASE_NO_EXT="archivo"
        fi
        DEFAULT_NAME="${BASE_NO_EXT}.tar.gz"

        if command -v zenity &>/dev/null; then
            ARCHIVE_NAME=$(zenity --entry \
                --title="Comprimir con Ouch" \
                --text="Nombre y formato del archivo comprimido:\n(Formatos: .tar.gz, .zip, .7z, .tar.zst, .tar.bz2)" \
                --entry-text="$DEFAULT_NAME" \
                --width=420 2>/dev/null) || exit 0
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

        notify-send "Ouch" "Comprimiendo en '$ARCHIVE_NAME'..." -i package-x-generic -t 2000 2>/dev/null || true
        if ouch compress -y "$@" "$OUTPUT_FILE"; then
            notify_success "Archivo comprimido creado: $ARCHIVE_NAME"
        else
            notify_error "Error al comprimir los archivos seleccionados."
            exit 1
        fi
        ;;

    compress-quick-tar)
        if [ $# -gt 1 ]; then
            PARENT_BASE="$(basename "$PARENT_DIR")"
            BASE_NO_EXT="${PARENT_BASE:-archivo}"
        else
            BASE_NAME="$(basename "$FIRST_FILE")"
            BASE_NO_EXT="${BASE_NAME%.*}"
            [ -z "$BASE_NO_EXT" ] && BASE_NO_EXT="archivo"
        fi
        OUTPUT_FILE="$PARENT_DIR/${BASE_NO_EXT}.tar.gz"

        notify-send "Ouch" "Comprimiendo a ${BASE_NO_EXT}.tar.gz..." -i package-x-generic -t 2000 2>/dev/null || true
        if ouch compress -y "$@" "$OUTPUT_FILE"; then
            notify_success "Creado: ${BASE_NO_EXT}.tar.gz"
        else
            notify_error "Error al comprimir a .tar.gz."
            exit 1
        fi
        ;;

    compress-quick-zip)
        if [ $# -gt 1 ]; then
            PARENT_BASE="$(basename "$PARENT_DIR")"
            BASE_NO_EXT="${PARENT_BASE:-archivo}"
        else
            BASE_NAME="$(basename "$FIRST_FILE")"
            BASE_NO_EXT="${BASE_NAME%.*}"
            [ -z "$BASE_NO_EXT" ] && BASE_NO_EXT="archivo"
        fi
        OUTPUT_FILE="$PARENT_DIR/${BASE_NO_EXT}.zip"

        notify-send "Ouch" "Comprimiendo a ${BASE_NO_EXT}.zip..." -i package-x-generic -t 2000 2>/dev/null || true
        if ouch compress -y "$@" "$OUTPUT_FILE"; then
            notify_success "Creado: ${BASE_NO_EXT}.zip"
        else
            notify_error "Error al comprimir a .zip."
            exit 1
        fi
        ;;

    *)
        echo "Uso: $0 {extract-here|extract-subdir|view|open-archive|compress-dialog|compress-quick-tar|compress-quick-zip} <archivos...>"
        exit 1
        ;;
esac
