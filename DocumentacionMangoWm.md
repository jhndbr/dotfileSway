Archivo de configuración

mangowm utiliza un formato de archivo de configuración simple. Por defecto, busca un archivo de configuración en ~/.config/mango/.

    Localizar configuración predeterminada

    Se proporciona una configuración alternativa en /etc/mango/config.conf. Puede usarla como referencia.

    Crear configuración de usuario

    Copia la configuración predeterminada a tu directorio de configuración local para comenzar a personalizarla.

    mkdir -p ~/.config/mango
    cp /etc/mango/config.conf ~/.config/mango/config.conf

    Iniciar con configuración personalizada (opcional)

    Si prefieres mantener tu configuración en otro lugar, puedes iniciar mango con la -cbandera.

    mango -c /path/to/your_config.conf

Subconfiguración

Para mantener su configuración organizada, puede dividirla en varios archivos e incluirlos usando la sourcepalabra clave.

# Import keybindings from a separate file
source=~/.config/mango/bind.conf

# Relative paths work too
source=./theme.conf

# Optional: ignore if file doesn't exist (useful for shared configs)
source-optional=~/.config/mango/optional.conf

Validar configuración

Puedes comprobar si hay errores en tu configuración sin iniciar mangowm:

mango -c /path/to/config.conf -p

Utilizar con source-optionalpara configuraciones compartidas en diferentes configuraciones.
Variables ambientales

Puedes definir variables de entorno directamente en tu archivo de configuración. Estas se establecen antes de que el gestor de ventanas se inicialice por completo.

    Advertencia: Las variables de entorno definidas aquí se restablecerán cada vez que recargue la configuración.

env=QT_IM_MODULES,wayland;fcitx
env=XMODIFIERS,@im=fcitx

Inicio automático

mangowm puede ejecutar automáticamente comandos o scripts al iniciarse. Hay dos modos de ejecución:
Dominio	Comportamiento	Caso de uso
exec-once	Se ejecuta solo una vez, al iniciar mangowm.	Barras de estado, fondos de pantalla, demonios de notificación
exec	Se ejecuta cada vez que se recarga la configuración.	Scripts que necesitan actualizar la configuración
Ejemplo de configuración

# Start the status bar once
exec-once=waybar

# Set wallpaper
exec-once=swaybg -i ~/.config/mango/wallpaper/room.png

# Reload a custom script on config change
exec=bash ~/.config/mango/reload-settings.sh

mangowm no incluye una herramienta de captura de pantalla integrada. Esto mantiene el compositor ligero. En su lugar, crea tu propio flujo de trabajo a partir de pequeñas utilidades de Wayland y asígnalas a teclas;
Herramienta	Objetivo
grim	Captura la pantalla o una región en un archivo.
slurp	Seleccione interactivamente una región paragrim
wl-copy	Copia las capturas de pantalla directamente al portapapeles.
satty	Anota las capturas de pantalla antes de guardarlas.
wayfreeze	Congela la pantalla antes de la captura.

Instala lo necesario con tu gestor de paquetes o desde el código fuente.

grimEscribe en la ruta de archivo que le indiques, pero no creará directorios que falten . Crea uno primero:

mkdir -p ~/Pictures/Screenshots

Cualquier directorio sirve. ~/Pictures/Screenshots/Es solo una convención.
Enlaces rápidos

Se pueden insertar comandos cortos de un solo paso directamente en config.conf. spawn_shellNo se necesita ningún archivo de script.
Pantalla completa

Captura toda la pantalla.

bind=NONE,Print,spawn_shell,grim $HOME/Pictures/Screenshots/$(date +%Y%m%d%H%M%S).png

Región

Seleccione un área slurpantes de capturar.

bind=SHIFT,Print,spawn_shell,g=$(slurp -d) && [ -n "$g" ] && grim -g "$g" $HOME/Pictures/Screenshots/$(date +%Y%m%d%H%M%S).png

Puntero

Captura la pantalla completa, incluyendo el cursor.

bind=ALT,Print,spawn_shell,grim -c $HOME/Pictures/Screenshots/$(date +%Y%m%d%H%M%S).png

Portapapeles

Captura la imagen en un archivo temporal y la copia al portapapeles; no se guarda ningún archivo.

bind=CTRL,Print,spawn_shell,f=$(mktemp -t screenshot-XXXXXX.png) && grim "$f" && wl-copy < "$f" && rm -f "$f"

Anotar

Captura y abre sattypara dibujar antes de guardar.

bind=SUPER,Print,spawn_shell,f=$HOME/Pictures/Screenshots/$(date +%Y%m%d%H%M%S).png && grim "$f" && satty --filename "$f" --output-filename "$f" --actions-on-enter save-to-file --early-exit

Enlaces de script

Cuando un comando implique lógica de varios pasos, análisis de geometría, FIFOs o congelación de pantalla, muévalo a un script e invóquelo con spawnen lugar de spawn_shell.

Primero, crea el directorio de scripts:

mkdir -p ~/.config/mango/scripts/screenshot

Ventana

Utiliza mmsg(viene con Mango) para capturar la ventana enfocada.

~/.config/mango/scripts/screenshot/window.sh:

#!/usr/bin/env bash
geometry=$(mmsg get focusing-client | jq -r '"\(.x),\(.y) \(.width)x\(.height)"')
[ -z "$geometry" ] && exit 1
grim -g "$geometry" "$HOME/Pictures/Screenshots/$(date +%Y%m%d%H%M%S).png"

bind=CTRL+SHIFT,Print,spawn,$HOME/.config/mango/scripts/screenshot/window.sh

Congelar

Congela la pantalla wayfreezeantes de capturar.

~/.config/mango/scripts/screenshot/freeze.sh:

#!/usr/bin/env bash
pipe=$(mktemp -u).fifo
mkfifo "$pipe"
wayfreeze --after-freeze-timeout 100 --after-freeze-cmd "echo > $pipe" &
wayfreeze_pid=$!
read -r < "$pipe"
grim "$HOME/Pictures/Screenshots/$(date +%Y%m%d%H%M%S).png"
kill "$wayfreeze_pid" 2>/dev/null
rm -f "$pipe"

bind=CTRL+SUPER,Print,spawn,$HOME/.config/mango/scripts/screenshot/freeze.sh

Congelar + Región

Congela y luego selecciona una región con slurp. Se limpia al cancelar.

~/.config/mango/scripts/screenshot/freeze-region.sh:

#!/usr/bin/env bash
pipe=$(mktemp -u).fifo
mkfifo "$pipe"
wayfreeze --after-freeze-timeout 100 --after-freeze-cmd "echo > $pipe" &
wayfreeze_pid=$!
read -r < "$pipe"
geometry=$(slurp -d)
if [[ -z "$geometry" ]]; then
  kill "$wayfreeze_pid" 2>/dev/null
  rm -f "$pipe"
  exit 1
fi
grim -g "$geometry" "$HOME/Pictures/Screenshots/$(date +%Y%m%d%H%M%S).png"
kill "$wayfreeze_pid" 2>/dev/null
rm -f "$pipe"

bind=SHIFT+SUPER,Print,spawn,$HOME/.config/mango/scripts/screenshot/freeze-region.sh

Haz que los tres scripts sean ejecutables:

chmod +x ~/.config/mango/scripts/screenshot/*.sh

Guion todo en uno

¿Prefieres menos archivos? Un único script con subcomandos cubre todos los modos mencionados. Colócalo en el mismo directorio y úsalo en lugar de los scripts individuales.

~/.config/mango/scripts/screenshot/screenshot.sh:

#!/usr/bin/env bash
set -euo pipefail
mkdir -p "$HOME/Pictures/Screenshots"
filepath="$HOME/Pictures/Screenshots/$(date +%Y%m%d%H%M%S).png"

case "${1:-fullscreen}" in
  region)
    g=$(slurp -d); [ -z "$g" ] && exit 1
    grim -g "$g" "$filepath" ;;
  window)
    g=$(mmsg get focusing-client | jq -r '"\(.x),\(.y) \(.width)x\(.height)"')
    [ -z "$g" ] && exit 1
    grim -g "$g" "$filepath" ;;
  freeze)
    p=$(mktemp -u).fifo; mkfifo "$p"
    wayfreeze --after-freeze-timeout 100 --after-freeze-cmd "echo > $p" & wp=$!
    read -r < "$p"; grim "$filepath"
    kill "$wp" 2>/dev/null; rm -f "$p" ;;
  freeze-region)
    p=$(mktemp -u).fifo; mkfifo "$p"
    wayfreeze --after-freeze-timeout 100 --after-freeze-cmd "echo > $p" & wp=$!
    read -r < "$p"; g=$(slurp -d)
    if [ -z "$g" ]; then kill "$wp" 2>/dev/null; rm -f "$p"; exit 1; fi
    grim -g "$g" "$filepath"
    kill "$wp" 2>/dev/null; rm -f "$p" ;;
  annotate)
    grim "$filepath"; satty --filename "$filepath" --output-filename "$filepath" --actions-on-enter save-to-file --early-exit ;;
  *) grim "$filepath" ;;
esac

Haz que el script sea ejecutable:

chmod +x ~/.config/mango/scripts/screenshot/screenshot.sh

Luego agregue los enlaces a config.conf:

bind=NONE,Print,spawn,$HOME/.config/mango/scripts/screenshot/screenshot.sh fullscreen
bind=SHIFT,Print,spawn,$HOME/.config/mango/scripts/screenshot/screenshot.sh region
bind=CTRL+SHIFT,Print,spawn,$HOME/.config/mango/scripts/screenshot/screenshot.sh window
bind=CTRL+SUPER,Print,spawn,$HOME/.config/mango/scripts/screenshot/screenshot.sh freeze
bind=SHIFT+SUPER,Print,spawn,$HOME/.config/mango/scripts/screenshot/screenshot.sh freeze-region
bind=SUPER,Print,spawn,$HOME/.config/mango/scripts/screenshot/screenshot.sh annotate

Archivo de configuración

mangowm utiliza un formato de archivo de configuración simple. Por defecto, busca un archivo de configuración en ~/.config/mango/.

    Localizar configuración predeterminada

    Se proporciona una configuración alternativa en /etc/mango/config.conf. Puede usarla como referencia.

    Crear configuración de usuario

    Copia la configuración predeterminada a tu directorio de configuración local para comenzar a personalizarla.

    mkdir -p ~/.config/mango
    cp /etc/mango/config.conf ~/.config/mango/config.conf

    Iniciar con configuración personalizada (opcional)

    Si prefieres mantener tu configuración en otro lugar, puedes iniciar mango con la -cbandera.

    mango -c /path/to/your_config.conf

Subconfiguración

Para mantener su configuración organizada, puede dividirla en varios archivos e incluirlos usando la sourcepalabra clave.

# Import keybindings from a separate file
source=~/.config/mango/bind.conf

# Relative paths work too
source=./theme.conf

# Optional: ignore if file doesn't exist (useful for shared configs)
source-optional=~/.config/mango/optional.conf

Validar configuración

Puedes comprobar si hay errores en tu configuración sin iniciar mangowm:

mango -c /path/to/config.conf -p

Utilizar con source-optionalpara configuraciones compartidas en diferentes configuraciones.
Variables ambientales

Puedes definir variables de entorno directamente en tu archivo de configuración. Estas se establecen antes de que el gestor de ventanas se inicialice por completo.

    Advertencia: Las variables de entorno definidas aquí se restablecerán cada vez que recargue la configuración.

env=QT_IM_MODULES,wayland;fcitx
env=XMODIFIERS,@im=fcitx

Inicio automático

mangowm puede ejecutar automáticamente comandos o scripts al iniciarse. Hay dos modos de ejecución:
Dominio	Comportamiento	Caso de uso
exec-once	Se ejecuta solo una vez, al iniciar mangowm.	Barras de estado, fondos de pantalla, demonios de notificación
exec	Se ejecuta cada vez que se recarga la configuración.	Scripts que necesitan actualizar la configuración
Ejemplo de configuración

# Start the status bar once
exec-once=waybar

# Set wallpaper
exec-once=swaybg -i ~/.config/mango/wallpaper/room.png

# Reload a custom script on config change
exec=bash ~/.config/mango/reload-settings.sh

Reglas del monitor

Puede configurar cada salida de pantalla individualmente utilizando la monitorrulepalabra clave.

Sintaxis:

monitorrule=name:Values,Parameter:Values,Parameter:Values

    Información: Si alguno de los campos coincidentes ( name, make, model, serial) está configurado, todos los campos configurados deben coincidir para que se considere una coincidencia. Úselo wlr-randrpara obtener el nombre, la marca, el modelo y el número de serie de su monitor.

Parámetros
Parámetro	Tipo	Valores	Descripción
name	cadena	Cualquier	Coincidencia por nombre de monitor (admite expresiones regulares)
make	cadena	Cualquier	Coincidencia por fabricante del monitor
model	cadena	Cualquier	Coincidencia por modelo de monitor
serial	cadena	Cualquier	Coincidencia por número de serie del monitor
width	entero	0-9999	Ancho del monitor
height	entero	0-9999	Altura del monitor
refresh	flotar	0,001-9999,0	Frecuencia de actualización del monitor
x	entero	0-99999	Posición X
y	entero	0-99999	Posición Y
scale	flotar	0,01-100,0	Escala del monitor
vrr	entero	0, 1	Habilitar frecuencia de actualización variable
hdr	entero	0, 1	Habilitar compatibilidad con HDR
hdr_min_lum	flotar	0,0-10000,0	Control de la luminancia mínima de la pantalla, cd/m² (0 = no configurado)
hdr_max_lum	flotar	0,0-10000,0	Control de la luminancia máxima de la pantalla, también enviada como max_cll, cd/m² (0 = no configurado)
hdr_max_avg_lum	flotar	0,0-10000,0	Nivel máximo de luz promedio por fotograma (max_fall), cd/m² (0 = no definido)
hdr_force	entero	0, 1	Habilitar HDR incluso cuando el EDID no anuncia BT.2020/PQ.
icc	cadena	-	Ruta a un perfil ICC aplicado como transformación de color de salida (por ejemplo /usr/share/color/icc/MyDisplay.icc). Mutuamente excluyente con hdr: cuando ambos están configurados, HDR tiene prioridad y el perfil ICC se ignora. Configurado hdr:0para usar el perfil ICC
rr	entero	0-7	Transformación del monitor
custom	entero	0, 1	Habilitar el modo personalizado (no compatible con todas las pantallas; puede provocar una pantalla en negro).
disable	entero	0, 1	Desactivar el monitor
primary	entero	0, 1	Establezca este monitor como la salida principal X11 (RandR) para XWayland.
Salida primaria

Los clientes X11 —en particular los juegos a pantalla completa que restringen o bloquean el puntero— utilizan la salida principal RandR para determinar su origen de coordenadas. Por lo tanto, la salida principal solo cambia cuando se aplican las reglas del monitor (al iniciar, al conectar o desconectar la salida, al recargar la configuración), y nunca cuando el foco o el puntero se mueven entre monitores.

Añade primary:1a la regla el monitor que quieras que X11 considere principal. Las reglas se comparan en orden y solo la primera que coincida se aplica a un monitor, así que coloca la primary:1regla que corresponda a tu pantalla. Si varias reglas lo solicitan, prevalece la primera. Si no hay ninguna primary:1regla, se usa el monitor de la primera regla que coincida, y el primer monitor conectado cuando ninguna regla coincide.

# Play on the second display: make it the X11 primary output
monitorrule=name:^DP-2$,width:2560,height:1440,refresh:144,x:1920,y:0,primary:1

Transformar valores
Valor	Rotación
0	Sin transformación
1	90° en sentido contrario a las agujas del reloj
2	180° en sentido contrario a las agujas del reloj
3	270° en sentido contrario a las agujas del reloj
4	Giro vertical de 180°
5	Voltear + 90° en sentido contrario a las agujas del reloj
6	Voltear + 180° en sentido contrario a las agujas del reloj
7	Voltear + 270° en sentido contrario a las agujas del reloj

    Importante: Si utiliza aplicaciones XWayland, nunca use coordenadas negativas para la posición de sus monitores. Se trata de un error conocido de XWayland que provoca fallos en los eventos de clic. Siempre coloque sus monitores comenzando 0,0y extendiéndose hacia coordenadas positivas.

    Nota: "nombre" es una expresión regular. Si desea una coincidencia exacta, debe agregar ^y $al principio y al final de la expresión; por ejemplo, ^eDP-1$coincide exactamente con la cadena eDP-1.

Ejemplos

# Laptop display: 1080p, 60Hz, positioned at origin
monitorrule=name:^eDP-1$,width:1920,height:1080,refresh:60,x:0,y:10

# Match by make and model instead of name
monitorrule=make:Chimei Innolux Corporation,model:0x15F5,width:1920,height:1080,refresh:60,x:0,y:0

# Virtual monitor with pattern matching
monitorrule=name:HEADLESS-.*,width:1920,height:1080,refresh:60,x:1926,y:0,scale:1,rr:0,vrr:0

Formato de especificaciones del monitor

Varios comandos ( focusmon, tagmon, disable_monitor, enable_monitor, toggle_monitor, viewcrossmon, tagcrossmon) aceptan una cadena monitor_spec para identificar un monitor.

Formato:

name:xxx&&make:xxx&&model:xxx&&serial:xxx

    Se puede omitir cualquier campo y no hay ningún requisito de orden.
    Si se omiten todos los campos, la cadena se trata directamente como el nombre del monitor (por ejemplo, eDP-1).
    Úselo wlr-randrpara encontrar el nombre, la marca, el modelo y el número de serie de su monitor.

Ejemplos:

# By name (shorthand)
mmsg dispatch toggle_monitor,eDP-1

# By make and model
mmsg dispatch toggle_monitor,make:Chimei Innolux Corporation&&model:0x15F5

# By serial
mmsg dispatch toggle_monitor,serial:12345678

Desgarro (Modo de juego)

La técnica de tearing permite que los juegos eviten la sincronización vertical (VSync) del compositor para lograr una menor latencia.
Configuración	Por defecto	Descripción
allow_tearing	0	Control global de desgarro de pantalla: 0(Desactivar), 1(Activar), 2(Solo pantalla completa).
HDR

    La tecnología HDR solo es compatible con la rama wl-only, ya que requiere el vulkanrenderizador, pero scenefx aún no es compatible.

Configuración	Por defecto	Descripción
hdr_depth	2	Establece la profundidad HDR para la pantalla actual. 0es Predeterminado, 1es HDR8, 2es HDR10.

    Primero debes habilitar HDR en monitorrule, consulta Monitores — Reglas de monitor
    Debes configurarlo env=WLR_RENDERER,vulkanantes de que comience Mango.

por ejemplo (debe volver a iniciar sesión una vez después de configurarlo):

env=WLR_RENDERER,vulkan
monitorrule=name:eDP-1,model:0x15F5,width:1920,height:1080,refresh:60,x:0,y:0,scale:1,vrr:0,rr:0:hdr:1

Activar/desactivar HDR en tiempo de ejecución

monitorruleEstablece el estado al iniciar; togglehdrlo cambia sin recargar la configuración, como lo output <name> hdr on|off|togglehace Sway.

mmsg dispatch togglehdr              # toggle the focused monitor
mmsg dispatch togglehdr,on           # force on
mmsg dispatch togglehdr,off,eDP-1    # a named output
mmsg dispatch togglehdr,toggle,all   # every output at once

Sin argumentos, cambia el monitor enfocado. Recargar la configuración vuelve a aplicar monitorruley sobrescribe la togglehdrúltima configuración establecida.

allSe aplica a todas las salidas habilitadas. En el modo de conmutación, toma una decisión para todas ellas: si alguna está encendida, todas se apagan, en lugar de cambiar el estado de cada salida individualmente. Las salidas que no admiten HDR se omiten sin que se modifique su estado.
Dominar los metadatos de visualización

hdr:1Solo declara los primarios BT.2020 y la función de transferencia PQ, pero deja los campos de visualización de masterización en cero, por lo que el panel no tiene nada con lo que mapear tonos. Configúrelos con los valores de su panel:

monitorrule=name:eDP-1,...,hdr:1,hdr_max_lum:616,hdr_max_avg_lum:400

di-edid-decodeLos imprime bajo el bloque de datos de metadatos estáticos HDR . hdr_max_lum Se envía tanto como el pico de masterización como max_cll. Dejar cualquiera de los tres en 0 deja ese campo sin establecer, que es el comportamiento anterior.

    hdr_min_lumNo tiene efecto en wlroots 0.20.x: el mínimo se escaló de forma incorrecta backend/drm/atomic.cy todos los valores se desbordaron a 0. Se corrigió en la rama principal mediante la confirmación de wlroots f6a01b40, pero no se adaptó a la rama 0.20.

Paneles cuyo EDID oculta el bloque HDR

Algunos paneles declaran HDR solo dentro de una extensión DisplayID 2.0 , con los bloques CTA-861 anidados en un contenedor (etiqueta 0x81). Esto es EDID 1.4 válido, pero wlroots lee la capacidad HDR a través de la ruta CTA de libdisplay-info y devuelve vacío, por lo que hdr:1se ignora silenciosamente en un panel que maneja PQ.

hdr_force:1omite las dos comprobaciones derivadas de EDID:

monitorrule=name:eDP-1,...,hdr:1,hdr_force:1,hdr_max_lum:616,hdr_max_avg_lum:400

No omite la comprobación del renderizador: las transformaciones de color de salida solo existen en el renderizador Vulkan, por lo que WLR_RENDERER=vulkanaún es necesaria.
Configuración

Habilitar globalmente:

allow_tearing=1

Habilitar por ventana:

Utiliza una regla de ventana para forzar el efecto de desgarro de pantalla en juegos específicos.

windowrule=force_tearing:1,title:vkcube

Matriz de comportamiento de desgarro
force_tearing\allow_tearing	DISCAPACITADO (0)	HABILITADO (1)	SOLO PANTALLA COMPLETA (2)
NO ESPECIFICADO (0)	No permitido	Sigue a tearing_hint	Solo la pantalla completa sigue tearing_hint
HABILITADO (1)	No permitido	Permitido	Solo se permite la pantalla completa.
DISCAPACITADO (2)	No permitido	No permitido	No permitido
Compatibilidad de la tarjeta gráfica

    Advertencia: Algunas tarjetas gráficas requieren configurar la WLR_DRM_NO_ATOMICvariable de entorno antes de que Mango se inicie para habilitar correctamente el tearing.

Agrega esto a la configuración y vuelve a iniciar sesión en Mango:

env=WLR_DRM_NO_ATOMIC,1

Compatibilidad con GPU

Si Mango no se muestra correctamente o muestra una pantalla en negro, intente seleccionar una GPU específica:

# Use a single GPU
WLR_DRM_DEVICES=/dev/dri/card1 mango

# Use multiple GPUs
WLR_DRM_DEVICES=/dev/dri/card0:/dev/dri/card1 mango

Algunas GPU tienen problemas de compatibilidad con syncobj syncobj_enable=1, lo que puede provocar que aplicaciones como kittyesta se bloqueen. Configúralo env=WLR_DRM_NO_ATOMIC,1y config.confvuelve a iniciar sesión para solucionarlo.
Gestión de energía

Puedes controlar la alimentación del monitor mediante la mmsgherramienta IPC.

    Aviso: Este comando de suspensión no elimina el monitor, solo apaga la alimentación.

# Turn power off
mmsg dispatch sleep_monitor,eDP-1

# Turn power on
mmsg dispatch wakeup_monitor,eDP-1

# Toggle power
mmsg dispatch sleep_toggle_monitor,eDP-1

También puede utilizarlo wlr-randrpara la gestión de monitores:

# remove a monitor
mmsg dispatch disable_monitor,eDP-1

# add a monitor
mmsg dispatch enable_monitor,eDP-1

# Show all monitors spec
wlr-randr

Escala de pantalla (ejemplo de escala 1.5)

# don't scale xwayland in global to avoid blurry
xwayland_ignore_scale=1
# scale:1.5 to scale native wayland app
monitorrule=name:eDP-1,width:1920,height:1080,refresh:60,x:0,y:0,scale:1.5
# use dpi to scale xwayland(1.5 * 96 = 144)
exec-once=echo "Xft.dpi: 144" | xrdb -merge

Aplicaciones Electron y Chromium borrosas bajo escalado fraccional

Las aplicaciones basadas en Electron (VSCodium, Spotify, Discord, etc.) y los navegadores Chromium pueden verse borrosos cuando el monitor utiliza un escalado fraccional scale(por ejemplo, scale:1.25). Esto se debe a un problema de compatibilidad con el escalado fraccional, y la ventana vuelve a verse nítida una vez que se maximiza o se pone en pantalla completa.

Agregue una regla de ventana para abrir las aplicaciones afectadas maximizadas, lo que corrige el desenfoque:

# VSCodium
windowrule=force_fakemaximize:1,appid:codium

Monitores virtuales

Puedes crear y gestionar pantallas virtuales mediante comandos IPC:

# Create virtual output
mmsg dispatch create_virtual_output

# Destroy all virtual outputs
mmsg dispatch destroy_all_virtual_output

Puede configurar monitores virtuales utilizando wlr-randr:

# Show all monitors
wlr-randr

# Configure virtual monitor
wlr-randr --output HEADLESS-1 --pos 1921,0 --scale 1 --custom-mode 1920x1080@60Hz

Los monitores virtuales se pueden usar para compartir la pantalla con herramientas como Sunshine y Moonlight , lo que permite que otros dispositivos actúen como monitores extendidos.



La configuración global que se muestra a continuación se aplica a todos los dispositivos del tipo correspondiente. Las configuraciones específicas para cada dispositivo se describen en la sección Reglas del dispositivo, al final de esta página.
Configuración del teclado

Controla las tasas de repetición de teclas y las reglas de diseño.
Configuración	Tipo	Por defecto	Descripción
repeat_rate	int	25	Cuántas veces se repite una tecla por segundo.
repeat_delay	int	600	Retardo (ms) antes de que una tecla mantenida pulsada comience a repetirse.
numlockon	0o1	0	Habilitar Bloq Num al iniciar el sistema.
xkb_rules_rules	string	-	Archivo de reglas XKB (por ejemplo, evdev, base). Generalmente se detecta automáticamente.
xkb_rules_model	string	-	Modelo de teclado (por ejemplo, pc104, macbook).
xkb_rules_layout	string	-	Código de distribución del teclado (por ejemplo, us, de, us,de).
xkb_rules_variant	string	-	Variante de diseño (por ejemplo, dvorak, colemak, intl).
xkb_rules_options	string	-	Opciones de XKB (por ejemplo, caps:escape, ctrl:nocaps).

Ejemplo:

repeat_rate=40
repeat_delay=300
numlockon=1
xkb_rules_layout=us,de
xkb_rules_variant=dvorak
xkb_rules_options=caps:escape,ctrl:nocaps

Configuración del ratón

Configuración para ratones externos.
Configuración	Por defecto	Descripción
mouse_natural_scrolling	0	Invertir la dirección de desplazamiento.
mouse_accel_profile	2	0(Ninguno), 1(Plano), 2(Adaptativo).
mouse_accel_speed	0.0	Ajuste de velocidad (-1,0 a 1,0).
mouse_left_handed	0	Intercambia los botones izquierdo y derecho.
mouse_middle_button_emulation	0	Emular el botón central.
mouse_scroll_method	1	1(Dos dedos), 2(Borde), 4(Botón).
mouse_scroll_button	274	El botón utilizado para el desplazamiento del botón (272–279).
mouse_click_method	1	1(Áreas de botones), 2(Clic con el dedo).
mouse_send_events_mode	0	0(Activado), 1(Desactivado), 2(Desactivado en ratón externo).
axis_scroll_factor	1.0	Factor de desplazamiento para la velocidad de desplazamiento del eje (0,1–10,0).
Configuración del panel táctil

Configuración específica para el panel táctil del portátil. Es posible que algunos ajustes requieran volver a iniciar sesión para que surtan efecto.
Configuración	Por defecto	Descripción
disable_trackpad	0	Configurado 1para desactivar completamente el panel táctil.
tap_to_click	1	Pulsa para activar el clic izquierdo.
tap_and_drag	1	Mantén pulsado para arrastrar los elementos.
trackpad_natural_scrolling	0	Invertir la dirección de desplazamiento (desplazamiento natural).
trackpad_accel_profile	2	0(Ninguno), 1(Plano), 2(Adaptativo).
trackpad_accel_speed	0.0	Ajuste de velocidad (-1,0 a 1,0).
trackpad_scroll_button	274	El botón utilizado para el desplazamiento del botón (272–279).
trackpad_scroll_method	1	1(Dos dedos), 2(Borde), 4(Botón).
trackpad_click_method	1	1(Áreas de botones), 2(Clic con el dedo).
trackpad_send_events_mode	0	0(Activado), 1(Desactivado), 2(Desactivado en ratón externo).
drag_lock	1	Bloquear el arrastre después de tocar.
trackpad_disable_while_typing	1	Desactiva el panel táctil mientras escribes.
trackpad_left_handed	0	Intercambia los botones izquierdo y derecho.
trackpad_middle_button_emulation	0	Emular el botón central.
swipe_min_threshold	1	Umbral mínimo de deslizamiento al usar gestos.
gesture_live	1	Impulsa las transiciones de etiquetas/enfoque/vista general mientras los dedos aún se están moviendo ( 1), en lugar de solo después de soltarlos ( 0).
gesture_swipe_distance	300	Recorrido del dedo (px) que corresponde a una transición de página completa.
gesture_swipe_cancel_ratio	0.5	Al soltar el botón después de que la última página se haya arrastrado más allá de esta fracción, se confirma; debajo de ella, la transición se anima hacia atrás.
gesture_swipe_min_speed_to_force	10	Velocidad media por evento (px) que fuerza una confirmación incluso por debajo de la tasa de cancelación (para movimientos rápidos).
button_map	0	0(Izquierda/derecha/centro), 1(Izquierda/centro/derecha).
trackpad_scroll_factor	1.0	Factor de desplazamiento para la velocidad de desplazamiento del panel táctil (0,1–10,0).
Configuración de la pantalla táctil

Configuración para dispositivos con pantalla táctil. La entrada táctil se reenvía a los clientes que admiten el wl_touchprotocolo; de lo contrario, se recurre a la emulación del ratón para que la pantalla táctil siga funcionando con clientes que no la admiten.
Configuración	Por defecto	Descripción
touch_enable	1	Configurado para 0desactivar completamente la compatibilidad con la pantalla táctil.
touch_enable_mouse_emulation	0	Cuando se activa 1, los eventos táctiles que se producen en superficies que no admiten el tacto se emulan como clics/movimientos del botón izquierdo del ratón. Establezca este valor en 0para desactivar la emulación (dichos toques se ignoran).

De forma predeterminada, la pantalla táctil está restringida a la pantalla actual (el monitor que tiene el foco). Para asignar un dispositivo táctil específico a una salida fija, utilice la opción monitor de regla de dispositivo .

Los dispositivos tipo tableta (lápiz) no están restringidos a un monitor de forma predeterminada. Utilice una regla de dispositivo para fijar una tableta a una salida fija con monitor, o configure map_focus_monitor:1para que siga el monitor actualmente enfocado.

Descripciones detalladas:

    scroll_buttonvalores (usar mouse_scroll_button/ trackpad_scroll_button):
        272— Botón izquierdo.
        273— Botón derecho.
        274— Botón central.
        275— Botón lateral.
        276— Botón adicional.
        277— Botón de avance.
        278— Botón de retroceso.
        279— Botón de tarea.

    scroll_methodvalores (usar mouse_scroll_method/ trackpad_scroll_method):
        0— Nunca enviar eventos de desplazamiento (sin desplazamiento).
        1— Desplazamiento con dos dedos: envía eventos de desplazamiento cuando se presionan lógicamente dos dedos sobre el dispositivo.
        2— Desplazamiento por los bordes: envía eventos de desplazamiento cuando un dedo se mueve a lo largo del borde inferior o derecho.
        4— Desplazamiento mediante botón: envía eventos de desplazamiento cuando se mantiene pulsado un botón y el dispositivo se mueve a lo largo de un eje de desplazamiento.

    click_methodvalores (usar mouse_click_method/ trackpad_click_method):
        0— Sin emulación de clics por software.
        1— Áreas de botones: utilice áreas definidas por software en el panel táctil para generar eventos de botones.
        2— Clickfinger: el número de dedos determina qué botón se pulsa.

    mouse_accel_profileo trackpad_scroll_profilevalores:
        0— Sin aceleración.
        1— Plano: sin aceleración dinámica. Velocidad del puntero = velocidad de entrada original × (1 + mouse_accel_speed).
        2— Adaptativo: el movimiento lento produce menos aceleración, el movimiento rápido produce más.

    button_mapvalores:
        0— El toque con 1/2/3 dedos se asigna a izquierda/derecha/centro.
        1— El toque con 1/2/3 dedos se asigna a izquierda/centro/derecha.

    send_events_modevalores (usar mouse_send_events_mode/ trackpad_send_events_mode):
        0— Enviar eventos desde este dispositivo normalmente.
        1— No envíe eventos desde este dispositivo.
        2— Desactive este dispositivo cuando se conecte un dispositivo señalador externo.

Cambio de distribución del teclado

Para vincular varios diseños y alternar entre ellos, defina los diseños xkb_rules_layouty úselos xkb_rules_optionspara establecer una combinación de teclas de alternancia. Luego, vincúlelos switch_keyboard_layoutpara activar un interruptor.

# Define two layouts: US QWERTY and US Dvorak
xkb_rules_layout=us,us
xkb_rules_variant=,dvorak
xkb_rules_options=grp:lalt_lshift_toggle

O bien, vincúlelo manualmente a una tecla:

# Bind Alt+Shift_L to cycle keyboard layout
bind=alt,shift_l,switch_keyboard_layout

Se utiliza mmsg get keyboardlayoutpara consultar el diseño actual.
Editor de métodos de entrada (IME)

Para usar Fcitx5 o IBus, configure estas variables de entorno en su archivo de configuración.

    Información: Para que estos ajustes surtan efecto, es necesario reiniciar el gestor de ventanas.

Para Fcitx5:

env=GTK_IM_MODULE,fcitx
env=QT_IM_MODULE,fcitx
env=QT_IM_MODULES,wayland;fcitx
env=SDL_IM_MODULE,fcitx
env=XMODIFIERS,@im=fcitx
env=GLFW_IM_MODULE,ibus

Para IBus:

env=GTK_IM_MODULE,ibus
env=QT_IM_MODULE,ibus
env=XMODIFIERS,@im=ibus

Reglas del dispositivo (avanzadas)

La configuración global anterior se aplica a todos los dispositivos del tipo correspondiente. Úsela devicerulepara anular los parámetros de un dispositivo específico.

Encontrar nombres de dispositivos:

La forma más sencilla de obtener el nombre de un dispositivo es observarlo: ejecutar

mmsg watch all-devices

Luego, usa el dispositivo (escribe en el teclado, mueve el ratón, desplázate por el panel táctil). Cada evento imprime el nombre del dispositivo que lo activó, para que puedas asociar cada dispositivo físico con su nombre sin tener que adivinar. mmsg get all-devices También muestra todos los dispositivos conectados a la vez si lo prefieres.

Sintaxis:

devicerule=name:<device-name>,option:value,option:value
devicerule=type:<device-type>,option:value

Coloque el impreso namedespués name:(el identifiercampo, vendor:product:name, también funciona). Use type:para coincidir con todos los dispositivos de un tipo: keyboard, pointer, trackpad, touch, switch, tablet, pad. La ortografía histórica touchpadtodavía se acepta como un alias obsoleto para trackpad.

Las coincidencias exactas name:tienen prioridad sobre type:las coincidencias; la primera regla que coincida prevalece. Una regla con opciones de teclado ( kb_*, repeat_*) convierte ese teclado en un teclado independiente con su propio mapa de teclas y configuración de repetición; los dispositivos no coincidentes permanecen en el grupo de teclados compartidos y sincronizados.

Ejemplos:

devicerule=name:AT Translated Set 2 keyboard,kb_layout:ru
devicerule=name:A4Tech USB Mouse,natural_scrolling:1,accel_speed:0.1
devicerule=type:trackpad,tap_to_click:1
devicerule=name:ELAN Touchscreen,monitor:HDMI-A-1

Aplique los cambios mmsg dispatch reload_configo reinicie Mango.
Opciones de reglas

Todas las opciones son opcionales; las opciones no establecidas recurren a la configuración global. kb_*Las opciones de teclado son independientes de la xkb_rules_*configuración global: el mapa de teclas de una regla se compila solo a partir de las opciones que establece (los campos no establecidos usan los valores predeterminados de XKB), por lo que una regla como kb_layout:ptno se ve afectada por una configuración global xkb_rules_variant.
Categoría	Opción	Descripción
Teclado	kb_layout	Código de diseño, por ejemplo us, , ru,de
Teclado	kb_variant	Variante de diseño, por ejemplo dvorak,colemak
Teclado	kb_options	Opciones de XKB, por ejemplocaps:escape
Teclado	kb_rules/kb_model	Archivo/modelo de reglas XKB
Teclado	repeat_rate/repeat_delay	Frecuencia de repetición de teclas / retardo
Puntero	accel_speed	Velocidad del puntero, -1.0a1.0
Puntero	accel_profile	0ninguno, 1plano, 2adaptativo
Puntero	natural_scrolling	1invierte la dirección de desplazamiento
Puntero	left_handed	1Intercambia los botones izquierdo y derecho.
panel táctil	tap_to_click	1permite tocar para hacer clic
panel táctil	tap_and_drag	1Permite tocar y arrastrar
panel táctil	scroll_method	1botón de dos dedos 2en el borde4
panel táctil	disable_while_typing	1desactiva el panel táctil mientras se escribe
Común	middle_button_emulation	1emula el botón central
Común	send_events_mode	0habilitado, 1deshabilitado, 2deshabilitado con ratón externo
Común	scroll_button/ click_method/ drag_lock/button_map	Configuración de libinput, consulte las descripciones a continuación.
Tableta táctil	monitor	Fije el dispositivo táctil o tableta a una salida. Acepta una especificación de monitor ; si no está configurado, sigue la pantalla actual.
Tableta	map_focus_monitor	1Hace que la tableta siga al monitor actualmente enfocado. Desactivado por defecto, por lo que una tableta permanece sin asignar a menos que monitortambién esté configurada.

    Información: Si la distribución del teclado de una regla no se compila (por ejemplo, kb_layout:ru con kb_variant:dvorak), Mango registra un error y recurre a la distribución global en lugar de bloquearse.

Portales XDG

Configure la función de compartir pantalla, el portapapeles, el llavero y los selectores de archivos mediante los portales XDG.
Copiar Markdown
Abierto
Configuración del portal

Puede personalizar la configuración del portal a través de las siguientes rutas:

    Configuración de usuario (Prioridad): ~/.config/xdg-desktop-portal/mango-portals.conf
    Sistema de reserva: /usr/share/xdg-desktop-portal/mango-portals.conf

    Advertencia: Si previamente agregaste esto dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=wlrootsa tu configuración, elimínalo. Mango ahora lo gestiona automáticamente.

Compartir pantalla

Para habilitar el uso compartido de pantalla (OBS, Discord, WebRTC), necesitas xdg-desktop-portal-wlr.

    Instalar dependencias

    pipewire, pipewire-pulse, xdg-desktop-portal-wlr,rofi

        Nota: xdg-desktop-portal-wlr no tiene selector propio. Cuando una aplicación solicita compartir pantalla, inicia una externa e intenta slurp, wmenu, wofi, rofi, bemenu, mewy fuzzelen ese orden. Si ninguna de ellas está instalada, el selector nunca aparece y la función de compartir falla, así que instale al menos una de ellas ( rofies la opción más común). Esto no es necesario si omite el selector como se describe a continuación.

    Opcional: Agregar al inicio automático

    En algunos casos, es posible que el portal no se inicie automáticamente. Puedes añadir esto a tu script de inicio automático para asegurarte de que se inicie:

    /usr/lib/xdg-desktop-portal-wlr &

    Reinicia el ordenador para aplicar los cambios.

Problemas conocidos

    Tencent Meeting solicita una pantalla, pero no sucede nada: xdg-desktop-portal-wlr abre su selector durante SelectSources()y solo responde una vez que se ha seleccionado algo, mientras que Tencent Meeting llama Start()inmediatamente y nunca espera esa respuesta. El frontend del portal rechaza el inicio con Sources not selected, por lo que el selector se cierra sin compartir nada. Seleccione una salida fija y omita el selector:

    # ~/.config/xdg-desktop-portal-wlr/config
    [screencast]
    output_name=eDP-1
    chooser_type=none

    Reemplazar eDP-1con el nombre de salida (ver mmsg get all-monitors). La configuración solo se lee cuando se inicia el portal, así que reinícielo después (volver a iniciar sesión o reiniciar el sistema también funciona):

    systemctl --user restart xdg-desktop-portal-wlr

    Esto se aplica a todas las aplicaciones: la función de compartir pantalla siempre captura la salida y nunca solicita confirmación. Las aplicaciones que sí esperan respuesta (OBS, Firefox, Chromium) también funcionan con el selector predeterminado, así que agréguelo solo si lo necesita. Tencent Meeting solo acierta con el primer intento de compartir por inicio de la aplicación, así que reiníciela antes de compartir.

    Compartir pantalla de ventanas: Algunas aplicaciones pueden tener problemas para compartir ventanas individuales. Consulte el número 184 para obtener soluciones alternativas.

    Retraso en la grabación de pantalla: Si experimenta interrupciones durante la grabación de pantalla, consulte xdg-desktop-portal-wlr#351 .

Administrador del portapapeles

Se utiliza cliphistpara gestionar el historial del portapapeles.

Dependencias: wl-clipboard , cliphist,wl-clip-persist

Configuración de inicio automático:

# Keep clipboard content after app closes
wl-clip-persist --clipboard regular --reconnect-tries 0 &

# Watch clipboard and store history
wl-paste --type text --watch cliphist store &

Llavero de GNOME

Si necesitas almacenar contraseñas o secretos (por ejemplo, para los lanzadores de VS Code o Minecraft), instala gnome-keyring.

Configuración:

Añade lo siguiente a ~/.config/xdg-desktop-portal/mango-portals.conf:

[preferred]
default=gtk
org.freedesktop.impl.portal.ScreenCast=wlr
org.freedesktop.impl.portal.Screenshot=wlr
org.freedesktop.impl.portal.Secret=gnome-keyring
org.freedesktop.impl.portal.Inhibit=none

Selector de archivos

Dependencias: xdg-desktop-portal ,xdg-desktop-portal-gtk

Reinicia el ordenador una vez para aplicar los cambios.

Misceláneas

Configuración avanzada para XWayland, comportamiento de enfoque e integración del sistema.
Copiar Markdown
Abierto
Sistema y hardware
Configuración	Por defecto	Descripción
xwayland_persistence	1	Mantén XWayland en funcionamiento incluso cuando no haya aplicaciones X11 abiertas (reduce el retardo de inicio).
xwayland_ignore_scale	0	Deshabilitar la escala global para xwayland.
syncobj_enable	1	Habilitar drm_syncobjla compatibilidad con la línea de tiempo (ayuda a reducir los tirones/lag en los juegos). Requiere reiniciar.
allow_lock_transparent	0	Permitir que la pantalla de bloqueo sea transparente.
allow_shortcuts_inhibit	1	Permitir que los clientes desactiven los atajos.
auto_reload_config	1	Vigila el archivo de configuración principal y todos los archivos source/ source-optional, y luego recarga inmediatamente después de que cambie cualquiera de ellos.
Enfoque y aportaciones
Configuración	Por defecto	Descripción
focus_on_activate	1	Las ventanas se enfocarán automáticamente cuando soliciten activación.
sloppyfocus	1	El foco sigue al cursor del ratón.
map_focus_monitor	0	Asigna las tabletas al monitor enfocado automáticamente. Cuando está desactivado, una tableta solo se asigna a un monitor si una deviceregla la fija mediante monitor.
warpcursor	1	Cuando el foco cambie mediante el teclado, desplazará el cursor al centro de la ventana.
cursor_hide_timeout	0	Ocultar el cursor después de Nsegundos de inactividad ( 0para desactivar).
cursor_hide_on_keypress	0	Ocultar el cursor al pulsar una tecla.
drag_tile_to_tile	0	Permite arrastrar una ventana en mosaico sobre otra para intercambiar sus posiciones.
drag_tile_small	1	Permite arrastrar temporalmente una ventana en mosaico para reducir su tamaño.
drag_corner	3	Esquina para la detección de arrastrar a mosaico (0: ninguna, 1–3: esquinas, 4: detección automática).
drag_warp_cursor	1	El cursor se distorsiona al arrastrar ventanas para colocarlas en mosaico.
axis_bind_apply_timeout	100	Tiempo de espera (ms) para detectar eventos de desplazamiento consecutivos para las asignaciones de ejes.
disable_middle_paste	0	Desactive la función de pegar con el botón central del ratón desactivando la selección principal completa. Esto solo afecta a las aplicaciones Wayland; las aplicaciones X11 no se ven afectadas. Reinicie las aplicaciones después de volver a activar esta función.
Múltiples monitores y etiquetas
Configuración	Por defecto	Descripción
focus_cross_monitor	0	Permitir que el enfoque direccional atraviese los límites del monitor.
focusdir_only_zone_overlap	1	Cuando está habilitada, la función de enfoque direccional solo selecciona las ventanas que se superponen a la ventana actual en el eje perpendicular (y para izquierda/derecha, x para arriba/abajo); no devuelve nada si ninguna cumple los requisitos.
exchange_cross_monitor	0	Permitir que los exchange_clientdespachadores move_clientalcancen más allá de los límites de los monitores. Con exchange_clientlas dos ventanas intercambiando monitores; con move_clientla ventana se mueve al monitor que contiene al vecino (o que se encuentra en la dirección del movimiento cuando no hay ninguno) y se inserta delante o detrás de ese vecino en lugar de intercambiar con él. Mientras está deshabilitado, ambos despachadores mantienen las ventanas en el monitor actual.
focus_cross_tag	0	Permitir que el foco direccional se extienda a otras etiquetas.
view_current_to_back	0	Al cambiar la etiqueta actual, se vuelve a la etiqueta vista anteriormente.
scratchpad_cross_monitor	0	Comparte el espacio de trabajo del bloc de notas entre todos los monitores.
single_scratchpad	1	Permita que solo se muestre un bloc de notas (con nombre o estándar) a la vez.
tag_num	9	Número de etiquetas/espacios de trabajo (1–31). Al recargar la configuración, los clientes que utilicen etiquetas que superen este número se moverán a la última etiqueta.
tag_gather	0	Cuando 1se utilizan ventanas, las etiquetas ocupadas se compactan en etiquetas consecutivas a partir de la 1, eliminando los espacios en blanco. Por ejemplo, con ventanas en las etiquetas 1, 3 y 9, estas se mueven a las etiquetas 1, 2 y 3, y la vista actual las sigue.
Comportamiento de la ventana
Configuración	Por defecto	Descripción
enable_floating_snap	0	Ajustar las ventanas flotantes a los bordes o a otras ventanas.
snap_distance	30	Distancia máxima (píxeles) para activar el ajuste flotante.
float_full_to_top	0	Permitir que las ventanas de pantalla completa, flotantes y de capa topcompartan una capa para que puedan cubrirse entre sí; cuál termina en la parte superior depende de cuál se abrió o elevó en último lugar. Cuando 0, se dividen en capas separadas: ventanas flotantes debajo, ventanas de pantalla completa encima de ventanas de capa top.
no_border_when_single	0	Eliminar los bordes de las ventanas cuando solo una ventana sea visible en la etiqueta.
smartgaps	0	Desactive los espacios cuando solo haya una ventana presente.
idleinhibit_ignore_visible	0	Permitir que los clientes invisibles (por ejemplo, reproductores de audio en segundo plano) inhiban el estado de inactividad.
idleinhibit_when_fullscreen	0	Mantén la inactividad desactivada mientras una ventana de pantalla completa esté activa.
tag_carousel	0	Habilitar el carrusel de etiquetas (recorrido por las etiquetas).
drag_tile_refresh_interval	8.0	Intervalo (1,0–16,0) para actualizar el tamaño de la ventana en mosaico durante el arrastre. Un valor demasiado pequeño puede provocar retrasos en la aplicación.
drag_floating_refresh_interval	8.0	Intervalo (1,0–16,0) para actualizar el tamaño de la ventana flotante al arrastrarla. Un valor demasiado pequeño puede provocar retrasos en la aplicación.

Tematización

Personaliza el aspecto visual de los bordes, los colores y el cursor.
Copiar Markdown
Abierto
Dimensiones

Controla el tamaño de los bordes y los espacios entre ventanas.
Configuración	Por defecto	Descripción
borderpx	4	Ancho del borde en píxeles.
gappih	5	Espacio interior horizontal (entre ventanas).
gappiv	5	Espacio interior vertical.
gappoh	10	Espacio exterior horizontal (entre las ventanas y los bordes de la pantalla).
gappov	10	Espacio exterior vertical.
Bandera

Los colores se definen en 0xRRGGBBAAformato hexadecimal.

# Background color of the root window
rootcolor=0x323232ff

# Inactive window border
bordercolor=0x444444ff

# Drop shadow when dragging windows
dropcolor=0x8FBA7C55

# Split window border color in manual dwindle layout
splitcolor=0xEB441EFF

# Active window border
focuscolor=0xc66b25ff

# Urgent window border (alerts)
urgentcolor=0xad401fff

Colores específicos de cada estado

También puedes asignar un color a las ventanas según su estado:
Estado	Clave de configuración	Color predeterminado
Maximizado	maximizescreencolor	0x89aa61ff
Bloc de notas	scratchpadcolor	0x516c93ff
Global	globalcolor	0xb153a7ff
Cubrir	overlaycolor	0x14a57cff

    Consejo: Para ajustar el tamaño de la ventana del bloc de notas, consulte la configuración del bloc de notas .

Descripción general Modo de salto
Configuración	Por defecto	Descripción
jump_label_decorate_fg_color	0xc4939dff	color del texto.
jump_label_decorate_bg_color	0x201b14ff	color de fondo.
jump_label_decorate_focus_fg_color	0x201b14ff	Color del texto para resaltar.
jump_label_decorate_focus_bg_color	0xc4939dff	color de fondo para enfocar.
jump_label_decorate_border_color	0x8BAA9Bff	color del borde.
jump_label_decorate_border_width	4	ancho del borde.
jump_label_decorate_corner_radius	5	radio de esquina.
jump_label_decorate_padding_x	10	relleno horizontal.
jump_label_decorate_padding_y	10	relleno vertical.
jump_label_decorate_font_desc	monospace Bold 16	conjunto de fuentes.
Barra de pestañas para el diseño Monocle
Configuración	Por defecto	Descripción
group_bar_height	25	Altura de la barra de pestañas para el diseño monocle.
group_bar_decorate_fg_color	0xc0caf5ff	color del texto.
group_bar_decorate_bg_color	0x1a1b26ff	color de fondo.
group_bar_decorate_focus_fg_color	0x1a1b26ff	Color del texto para resaltar.
group_bar_decorate_focus_bg_color	0x9ece6aff	color de fondo para enfocar.
group_bar_decorate_border_color	0x3b4261ff	color del borde.
group_bar_decorate_border_width	4	ancho del borde.
group_bar_decorate_corner_radius	5	radio de esquina.
group_bar_decorate_padding_x	0	relleno horizontal.
group_bar_decorate_padding_y	0	relleno vertical.
group_bar_decorate_font_desc	monospace Bold 10	conjunto de fuentes.
Barra de pestañas automática
Configuración	Por defecto	Descripción
monocle_tab_mode	0	Combinar automáticamente las ventanas apiladas en una pestaña en el diseño Monocle.
deck_tab_mode	0	Combinar automáticamente las ventanas del área de apilamiento en una pestaña en el diseño de la baraja.
tab_bar_height	25	Altura de la barra de pestañas automáticas.
tab_bar_decorate_fg_color	0xc0caf5ff	color del texto.
tab_bar_decorate_bg_color	0x1a1b26ff	color de fondo.
tab_bar_decorate_focus_fg_color	0x1a1b26ff	Color del texto para resaltar.
tab_bar_decorate_focus_bg_color	0x7aa2f7ff	color de fondo para enfocar.
tab_bar_decorate_border_color	0x3b4261ff	color del borde.
tab_bar_decorate_border_width	4	ancho del borde.
tab_bar_decorate_corner_radius	5	radio de esquina.
tab_bar_decorate_padding_x	0	relleno horizontal.
tab_bar_decorate_padding_y	0	relleno vertical.
tab_bar_decorate_font_desc	monospace Bold 10	conjunto de fuentes.
Fronteras

Controla la apariencia de los bordes de las ventanas.
Tema del cursor

Configura el tamaño y el tema del cursor del ratón.

cursor_size=24
cursor_theme=Adwaita
Status Bar
Configure mangobar and Waybar for mangowm.

Copy Markdown
Open
Recommended: mangobar

We recommend mangobar, a dedicated status bar for mangowm built on wlr-layer-shell. It integrates directly with mangowm over IPC, so it stays in sync with your tags, layouts and windows. It ships with built-in modules for workspaces, layout, window title, keymode, keyboard layout, CPU/memory, brightness, volume, clock, network, battery, system tray, and user-defined custom/<name> modules.

Installation

On Arch Linux, install the AUR package mangobar-git:


yay -S mangobar-git
Or build from source:


git clone https://github.com/mangowm/mangobar.git
cd mangobar
meson setup build -Dprefix=/usr
ninja -C build
sudo ninja -C build install
Usage

Start mangobar in your mangowm configuration:


exec-once=mangobar
It reads its configuration from $MANGOBAR_CONFIG or ~/.config/mangobar/config.jsonc, and its styling from ~/.config/mangobar/style.css. See the mangobar repository for a complete reference and example configuration.

Waybar Module Configuration

config.jsonc

Add the following to your Waybar configuration:


{
  "modules-left": [
    "mango/workspaces",
    "mango/layout",
    "mango/window"
  ],
  "modules-right": [
    "mango/language",
    "mango/keymode",
  ],
  "mango/workspaces": {
      "format": "{icon}",
      "hide-empty": true,
      "on-click": "activate",
      "on-click-right": "toggle",
      "overview-label": "OVERVIEW",
  },
  "mango/keymode": {
  	"format": "{}",
  	// "format-default": " Default",
    // "format-test": " Test",
  },
  "mango/window": {
    "format": "{}",
	  "icon-size": 20
  },
  "mango/layout": {
      "format": "{}",
      // "format-S": "Scroller",
      // "format-T": "Tile",
  },
  "mango/language": {
  "format": "{short}",
  },
}
Styling Example

You can style the tags using standard CSS in style.css.

style.css


#workspaces {
  border-color: #c9b890;
  background: rgba(40, 40, 40, 0.76);
}
#workspaces button {
  background: none;
  color: #ddca9e;
}
#workspaces button.hidden {
  color: #9e906f;
  background-color: transparent;
}
#workspaces button.visible {
  color: #ddca9e;
}
#workspaces button:hover {
  color: #d79921;
}
#workspaces button.active {
  background-color: #ddca9e;
  color: #282828;
}
#workspaces button.urgent {
  background-color: #ef5e5e;
  color: #282828;
}
#workspaces button.overview {
  background-color: #ef5e5e;
  color: #282828;
}
#window {
  background-color: #CA9297;
  color: #282828;
}
window#waybar.empty #window {
    background: none;
    margin: 0px;
    padding: 0px;
}
#layout {
  background-color: #CA9297;
  color: #282828;
}
#language {
  background-color: #CA9297;
  color: #282828;
}
#keymode {
  background-color: #CA9297;
  color: #282828;
}
Complete Configuration Example

Tip: You can find a complete Waybar configuration for mangowm at waybar-config.

Blur

Blur creates a frosted glass effect for transparent windows.

Setting	Default	Description
blur	0	Enable blur for windows.
blur_layer	0	Enable blur for layer surfaces (like bars/docks).
blur_optimized	1	Caches the wallpaper and blur background, significantly reducing GPU usage. Disabling it will significantly increase GPU consumption and may cause rendering lag. Highly recommended.
blur_params_radius	5	The strength (radius) of the blur.
blur_params_num_passes	1	Number of passes. Higher = smoother but more expensive.
blur_params_noise	0.02	Blur noise level.
blur_params_brightness	0.9	Blur brightness adjustment.
blur_params_contrast	0.9	Blur contrast adjustment.
blur_params_saturation	1.2	Blur saturation adjustment.
Warning: Blur has a relatively high impact on performance. If your hardware is limited, it is not recommended to enable it. If you experience lag with blur on, ensure blur_optimized=1 — disabling it will significantly increase GPU consumption and may cause rendering lag. To disable blur entirely, set blur=0.

Shadows

Drop shadows help distinguish floating windows from the background.

Setting	Default	Description
shadows	0	Enable shadows.
layer_shadows	0	Enable shadows for layer surfaces.
shadow_only_floating	1	Only draw shadows for floating windows (saves performance).
shadows_size	10	Size of the shadow.
shadows_blur	15	Shadow blur amount.
shadows_position_x	0	Shadow X offset.
shadows_position_y	0	Shadow Y offset.
shadowscolor	0x000000ff	Color of the shadow.

# Example shadows configuration
shadows=1
layer_shadows=1
shadow_only_floating=1
shadows_size=12
shadows_blur=15
shadows_position_x=0
shadows_position_y=0
shadowscolor=0x000000ff
Opacity & Corner Radius

Control the transparency and roundness of your windows.

Setting	Default	Description
border_radius	0	Window corner radius in pixels.
border_radius_location_default	0	Corner radius location: 0 (all), 1 (top-left), 2 (top-right), 3 (bottom-left), 4 (bottom-right), 5 (closest corner).
no_radius_when_single	0	Disable radius if only one window is visible.
focused_opacity	1.0	Opacity for the active window (0.0 - 1.0).
unfocused_opacity	1.0	Opacity for inactive windows (0.0 - 1.0).

# Window corner radius in pixels
border_radius=0
# Corner radius location (0=all, 1=top-left, 2=top-right, 3=bottom-left, 4=bottom-right)
border_radius_location_default=0
# Disable radius if only one window is visible
no_radius_when_single=0
# Opacity for the active window (0.0 - 1.0)
focused_opacity=1.0
# Opacity for inactive windows
unfocused_opacity=1.0
Dim Overlay

Draws a translucent layer over the content of a window, so it can be shaded without changing the opacity of the application itself. The layer never takes pointer input: clicks and drags always go to the window below it. Its corners follow border_radius, and it is resized together with the window, including while windows are being animated.

Colors use the usual 0xRRGGBBAA format, so the last two digits set the transparency of the overlay.

Setting	Default	Description
dim_enable	0	Enable the dim overlay on windows.
dim_focused_color	0x00000000	Dim color of the focused window.
dim_unfocused_color	0x00000055	Dim color of the unfocused windows.
With just dim_enable=1 the focused window stays untouched and the unfocused windows are shaded with 0x55 (about a third) black.


dim_enable=1
dim_focused_color=0x00000000
dim_unfocused_color=0x0000004d

Animations
Configure smooth transitions for windows and layers.

Copy Markdown
Open
Enabling Animations

mangowm supports animations for both standard windows and layer shell surfaces (like bars and notifications).


animations=1
layer_animations=1
Animation Types

You can define different animation styles for opening and closing windows and layer surfaces.

Available types: slide, zoom, fade, none.


animation_type_open=zoom
animation_type_close=slide
layer_animation_type_open=slide
layer_animation_type_close=slide
Fade Settings

Control the fade-in and fade-out effects for animations.


animation_fade_in=1
animation_fade_out=1
fadein_begin_opacity=0.5
fadeout_begin_opacity=0.5
animation_fade_in — Enable fade-in effect (0: disable, 1: enable)
animation_fade_out — Enable fade-out effect (0: disable, 1: enable)
fadein_begin_opacity — Starting opacity for fade-in animations (0.0–1.0)
fadeout_begin_opacity — Starting opacity for fade-out animations (0.0–1.0)
Zoom Settings

Adjust the zoom ratios for zoom animations.


zoom_initial_ratio=0.4
zoom_end_ratio=0.8
zoom_initial_ratio — Initial zoom ratio
zoom_end_ratio — End zoom ratio
Durations

Control the speed of animations (in milliseconds).

Setting	Type	Default	Description
animation_duration_move	integer	500	Move animation duration (ms)
animation_duration_open	integer	400	Open animation duration (ms)
animation_duration_tag	integer	300	Tag animation duration (ms)
animation_duration_close	integer	300	Close animation duration (ms)
animation_duration_focus	integer	0	Focus change (opacity transition) animation duration (ms)

animation_duration_move=500
animation_duration_open=400
animation_duration_tag=300
animation_duration_close=300
animation_duration_focus=0
Custom Bezier Curves

Bezier curves determine the "feel" of an animation (e.g., linear vs. bouncy). The format is x1,y1,x2,y2.

You can visualize and generate curve values using online tools like cssportal.com or easings.net.

Setting	Type	Default	Description
animation_curve_open	string	0.46,1.0,0.29,0.99	Open animation bezier curve
animation_curve_move	string	0.46,1.0,0.29,0.99	Move animation bezier curve
animation_curve_tag	string	0.46,1.0,0.29,0.99	Tag animation bezier curve
animation_curve_close	string	0.46,1.0,0.29,0.99	Close animation bezier curve
animation_curve_focus	string	0.46,1.0,0.29,0.99	Focus change (opacity transition) animation bezier curve
animation_curve_opafadein	string	0.46,1.0,0.29,0.99	Open opacity animation bezier curve
animation_curve_opafadeout	string	0.5,0.5,0.5,0.5	Close opacity animation bezier curve

animation_curve_open=0.46,1.0,0.29,0.99
animation_curve_move=0.46,1.0,0.29,0.99
animation_curve_tag=0.46,1.0,0.29,0.99
animation_curve_close=0.46,1.0,0.29,0.99
animation_curve_focus=0.46,1.0,0.29,0.99
animation_curve_opafadein=0.46,1.0,0.29,0.99
animation_curve_opafadeout=0.5,0.5,0.5,0.5
Tag Animation Direction

Control the direction of tag switch animations.

Setting	Default	Description
tag_animation_direction	1	Tag animation direction (1: horizontal, 0: vertical)

Layouts
Configure and switch between different window layouts.

Copy Markdown
Open
Supported Layouts

mangowm supports a variety of layouts that can be assigned per tag.

tile
scroller
monocle
grid
deck
center_tile
vertical_tile
right_tile
vertical_scroller
vertical_grid
vertical_deck
dwindle
fair
vertical_fair
Scroller Layout

The Scroller layout positions windows in a scrollable strip, similar to PaperWM.

Configuration

Setting	Default	Description
scroller_structs	20	Width reserved on sides when window ratio is 1.
scroller_default_proportion	0.9	Default width proportion for new windows.
scroller_focus_center	0	Always center the focused window (1 = enable).
scroller_prefer_center	0	Center focused window only if it was outside the view.
scroller_prefer_overspread	1	Allow windows to overspread when there's extra space.
edge_scroller_pointer_focus	1	Focus windows even if partially off-screen.
edge_scroller_focus_allow_speed	0.0	Allow pointer focus to happen if the pointer moves at a speed greater than this value.
scroller_proportion_preset	0.5,0.8,1.0	Presets for cycling window widths.
scroller_ignore_proportion_single	1	Ignore proportion adjustments for single windows.
scroller_default_proportion_single	1.0	Default proportion for single windows in scroller. Requires scroller_ignore_proportion_single=0 to take effect.
Warning: scroller_prefer_overspread, scroller_focus_center, and scroller_prefer_center interact with each other. Their priority order is:

scroller_prefer_overspread > scroller_focus_center > scroller_prefer_center

To ensure a lower-priority setting takes effect, you must set all higher-priority options to 0.


# Example scroller configuration
scroller_structs=20
scroller_default_proportion=0.9
scroller_focus_center=0
scroller_prefer_center=0
scroller_prefer_overspread=1
edge_scroller_pointer_focus=1
edge_scroller_focus_allow_speed=0.0
scroller_default_proportion_single=1.0
scroller_proportion_preset=0.5,0.8,1.0
Master-Stack Layouts

These settings apply to layouts like tile and center_tile.

Setting	Default	Description
new_is_master	1	New windows become the master window.
default_mfact	0.55	The split ratio between master and stack areas.
default_nmaster	1	Number of allowed master windows.
center_master_overspread	0	(Center Tile) Master spreads across screen if no stack exists.
center_when_single_stack	1	(Center Tile) Center master when only one stack window exists.

# Example master-stack configuration
new_is_master=1
smartgaps=0
default_mfact=0.55
default_nmaster=1
tag_num=9
tag_gather=0
Dwindle Layout

The Dwindle layout arranges windows as a binary tree of recursive splits. Each new window splits the focused window's container, producing a spiral-like tiling.

Configuration

Setting	Default	Description
dwindle_split_ratio	0.5	Ratio used for new splits (0.05–0.95).
dwindle_smart_split	0	Pick the split axis from the cursor's position inside the focused window. The new window appears on the cursor's side.
dwindle_hsplit	1	Side-by-side splits: where the new window goes. 0 = follow cursor, 1 = right, 2 = left.
dwindle_vsplit	1	Top/bottom splits: where the new window goes. 0 = follow cursor, 1 = below, 2 = above.
dwindle_preserve_split	0	Keep the sibling's split orientation when a window is closed.
dwindle_smart_resize	0	When dragging to resize, move the split toward the cursor regardless of which side was grabbed.
dwindle_drop_simple_split	1	Drag-to-tile drop preview. 1 = 2-zone preview matching dwindle_split_ratio, 0 = 4-quadrant preview.
dwindle_manual_split	0	Manually split windows mode.

# Example dwindle configuration
dwindle_split_ratio=0.5
dwindle_smart_split=0
dwindle_hsplit=0
dwindle_vsplit=0
dwindle_preserve_split=0
dwindle_smart_resize=0
dwindle_drop_simple_split=1
Switching Layouts

Setting	Default	Description
circle_layout	-	A comma-separated list of layouts switch_layout cycles through,the value sample:tile,scroller.
You can switch layouts dynamically or set a default for specific tags using Tag Rules.

Keybinding Examples:


# Cycle through layouts
circle_layout=grid,scroller,tile
bind=SUPER,n,switch_layout
# Set specific layout
bind=SUPER,t,setlayout,tile
bind=SUPER,s,setlayout,scroller

Rules
Define behavior for specific windows, tags, and layers.

Copy Markdown
Open
Window Rules

Window rules allow you to set specific properties (floating, opacity, size, animations, etc.) for applications based on their appid or title. You can set all parameters in one line, and if you both set appid and title, the window will only follow the rules when appid and title both match.

Format:


# Set window rules that apply to every times when the window is opened
windowrule=Parameter:Values,title:Values
windowrule=Parameter:Values,Parameter:Values,appid:Values,title:Values
# Set window rules that only apply once when the window is opened
windowrule-once=Parameter:Values,title:Values
windowrule-once=Parameter:Values,Parameter:Values,appid:Values,title:Values
State & Behavior Parameters

Parameter	Type	Values	Description
appid	string	Any	Match by application ID, supports regex
title	string	Any	Match by window title, supports regex
isfloating	integer	0 / 1	Force floating state
isfullscreen	integer	0 / 1	Force fullscreen state
isfakefullscreen	integer	0 / 1	Force fake-fullscreen state (window stays constrained)
isglobal	integer	0 / 1	Open as global window (sticky across tags)
isoverlay	integer	0 / 1	Make it always in top layer
isopensilent	integer	0 / 1	Open without focus
istagsilent	integer	0 / 1	Don't focus if client is not in current view tag
force_fakemaximize	integer	0 / 1 (default 1)	The state of client set to fake maximized
ignore_maximize	integer	0 / 1 (default 1)	Don't handle maximize request from client
ignore_minimize	integer	0 / 1 (default 1)	Don't handle minimize request from client
force_tiled_state	integer	0 / 1	Deceive the window into thinking it is tiling, so it better adheres to assigned dimensions
noopenmaximized	integer	0 / 1	Window does not open as maximized mode
single_scratchpad	integer	0 / 1 (default 1)	Only show one out of named scratchpads or the normal scratchpad
allow_shortcuts_inhibit	integer	0 / 1 (default 1)	Allow shortcuts to be inhibited by clients
idleinhibit_when_focus	integer	0 / 1 (default 0)	Automatically keep idle inhibit active when this window is focused
vrr_only_fullscreen	integer	0 / 1 (default 0)	VRR only fullscreen,you need to turn vrr to 0 in monitor rule first
shield_when_capture	integer	0 / 1	Shield window when captured
force_render	integer	0 / 1	Force render frame even if the window is not visible
activation_bypass	integer	0 / 1	Bypass xdg-activation authentication: activation requests for this window are treated as authenticated, so the normal activation behavior applies regardless of token validity
Geometry & Position

Parameter	Type	Values	Description
width	float	0-9999	Window width when it becomes a floating window,if the value below 1, it will be the percentage of the screen width,otherwise it will be the pixel value
height	float	0-9999	Window height when it becomes a floating window,if the value below 1, it will be the percentage of the screen height,otherwise it will be the pixel value
offsetx	integer	-999-999	X offset from center (%), 100 is the edge of screen with outer gap
offsety	integer	-999-999	Y offset from center (%), 100 is the edge of screen with outer gap
monitor	string	Any	Assign to monitor by monitor spec (name, make, model, or serial)
tags	mask	0-9 / 1|3|5	Assign to specific one tag (use 0 for special workspace overlay) or multiple tags (use | to split multiple tags)
no_force_center	integer	0 / 1	Window does not force center
isnosizehint	integer	0 / 1	Don't use min size and max size for size hints
Visuals & Decoration

Parameter	Type	Values	Description
noblur	integer	0 / 1	Window does not have blur effect
isnoborder	integer	0 / 1	Remove window border
isnoshadow	integer	0 / 1	Not apply shadow
isnoradius	integer	0 / 1	Not apply corner radius
isnoanimation	integer	0 / 1	Not apply animation
focused_opacity	integer	0 / 1	Window focused opacity
unfocused_opacity	integer	0 / 1	Window unfocused opacity
allow_csd	integer	0 / 1	Allow client side decoration
confine_pointer	integer	0 / 1	While this window is focused and visible, force the cursor to stay inside it (does not require the client to use the pointer constraints protocol)
Tip: For detailed visual effects configuration, see the Window Effects page for blur, shadows, and opacity settings.

Layout & Scroller

Parameter	Type	Values	Description
scroller_proportion	float	0.1-1.0	Set scroller proportion
scroller_proportion_single	float	0.1-1.0	Set scroller auto adjust proportion when it is single window
Tip: For comprehensive layout configuration, see the Layouts page for all layout options and detailed settings.

Animation

Parameter	Type	Values	Description
animation_type_open	string	zoom, slide, fade, none	Set open animation
animation_type_close	string	zoom, slide, fade, none	Set close animation
nofadein	integer	0 / 1	Window ignores fade-in animation
nofadeout	integer	0 / 1	Window ignores fade-out animation
Tip: For detailed animation configuration, see the Animations page for available types and settings.

Terminal & Swallowing

Parameter	Type	Values	Description
isterm	integer	0 / 1	A new GUI window will replace the isterm window when it is opened
noswallow	integer	0 / 1	The window will not replace the isterm window
Global & Special Windows

Parameter	Type	Values	Description
globalkeybinding	string	[mod combination][-][key]	Global keybinding (only works for Wayland apps)
isunglobal	integer	0 / 1	Open as unmanaged global window (for desktop pets or camera windows)
isnamedscratchpad	integer	0 / 1	0: disable, 1: named scratchpad
Tip: For scratchpad usage, see the Scratchpad page for detailed configuration examples.

Performance & Tearing

Parameter	Type	Values	Description
force_tearing	integer	0 / 1	Set window to tearing state, refer to Tearing
Examples


# Set specific window size and position
windowrule=width:1000,height:900,appid:yesplaymusic,title:Demons
# Global keybindings for OBS Studio
windowrule=globalkeybinding:ctrl+alt-o,appid:com.obsproject.Studio
windowrule=globalkeybinding:ctrl+alt-n,appid:com.obsproject.Studio
windowrule=isopensilent:1,appid:com.obsproject.Studio
# Force tearing for games
windowrule=force_tearing:1,title:vkcube
# Skip xdg-activation authentication for this app
windowrule=activation_bypass:1,appid:org.example.App
windowrule=force_tearing:1,title:Counter-Strike 2
# Named scratchpad for file manager
windowrule=isnamedscratchpad:1,width:1280,height:800,appid:st-yazi
# Custom opacity for specific apps
windowrule=focused_opacity:0.8,appid:firefox
windowrule=unfocused_opacity:0.6,appid:foot
# Disable blur for selection tools
windowrule=noblur:1,appid:slurp
# Position windows relative to screen center
windowrule=offsetx:20,offsety:-30,width:800,height:600,appid:alacritty
# Send to specific tag and monitor
windowrule=tags:9,monitor:HDMI-A-1,appid:discord
# Terminal swallowdby setup
windowrule=isterm:1,appid:st
windowrule=noswallow:1,appid:foot
# Disable client-side decorations
windowrule=allow_csd:1,appid:firefox
# Unmanaged global window (desktop pets, camera)
windowrule=isunglobal:1,appid:cheese
# Named scratchpad toggle
bind=alt,h,toggle_named_scratchpad,st-yazi,none,st -c st-yazi -e yazi
Tag Rules

You can set all parameters in one line. If only id is set, the rule is followed when the id matches. If any of monitor_name, monitor_make, monitor_model, or monitor_serial are set, the rule is followed only if all of the set monitor fields match.

Warning: Layouts set in tag rules have a higher priority than monitor rule layouts.

Format:


tagrule=id:Values,Parameter:Values,Parameter:Values
tagrule=id:Values,monitor_name:eDP-1,Parameter:Values,Parameter:Values
tagrule=id:Values,monitor_make:xxx,monitor_model:xxx,Parameter:Values
tagrule=id:*,Parameter:Values
Tip: See Layouts for detailed descriptions of each layout type.

Parameter	Type	Values	Description
id	integer / wildcard	0-9 / *	Match by tag id, 0 means the ~0 tag. Use * to match all tags at once
monitor_name	string	monitor name	Match by monitor name
monitor_make	string	monitor make	Match by monitor manufacturer
monitor_model	string	monitor model	Match by monitor model
monitor_serial	string	monitor serial	Match by monitor serial number
layout_name	string	layout name	Layout name to set
no_render_border	integer	0 / 1	Disable render border
open_as_floating	integer	0 / 1	New open window will be floating
no_hide	integer	0 / 1	Not hide even if the tag is empty
nmaster	integer	0, 99	Number of master windows
mfact	float	0.1–0.9	Master area factor
scroller_default_proportion	float	0.1-1.0	Set scroller default proportion.
scroller_default_proportion_single	float	0.1-1.0	Set scroller auto adjust proportion when it is single window(only apply when set scroller_ignore_proportion_single to 0)
scroller_ignore_proportion_single	integer	0 / 1	Ignore scroller single proportion setting.
Examples


# Set layout for all tags at once (equivalent to the two rules below)
tagrule=id:*,layout_name:scroller
# Set layout for specific tags
tagrule=id:1,layout_name:scroller
tagrule=id:2,layout_name:scroller
# Limit to specific monitor
tagrule=id:1,monitor_name:eDP-1,layout_name:scroller
tagrule=id:2,monitor_name:eDP-1,layout_name:scroller
# Persistent tags (1-4) with layout assignment
tagrule=id:1,no_hide:1,layout_name:scroller
tagrule=id:2,no_hide:1,layout_name:scroller
tagrule=id:3,monitor_name:eDP-1,no_hide:1,layout_name:scroller
tagrule=id:4,monitor_name:eDP-1,no_hide:1,layout_name:scroller
# Advanced tag configuration with master layout settings
tagrule=id:5,layout_name:tile,nmaster:2,mfact:0.6
tagrule=id:6,monitor_name:HDMI-A-1,layout_name:monocle,no_render_border:1
# set scroller proportion for specific tag
tagrule=id:1,layout_name:scroller,scroller_default_proportion_single:0.5,scroller_ignore_proportion_single:0,scroller_default_proportion:0.9,monitor_name:HDMI-A-1
Tip: For Waybar configuration with persistent tags, see Status Bar documentation.

Layer Rules

You can set all parameters in one line. Target "layer shell" surfaces like status bars (waybar), launchers (rofi), or notification daemons.

Format:


layerrule=layer_name:Values,Parameter:Values,Parameter:Values
Tip: You can use mmsg get last_open_surface to get the last open layer name for debugging.

Parameter	Type	Values	Description
layer_name	string	layer name	Match name of layer, supports regex
animation_type_open	string	slide, zoom, fade, none	Set open animation
animation_type_close	string	slide, zoom, fade, none	Set close animation
noblur	integer	0 / 1	Disable blur
noanim	integer	0 / 1	Disable layer animation
noshadow	integer	0 / 1	Disable layer shadow
shield_when_capture	integer	0 / 1	Shield layer when captured.(it is better to combination with noanim:1)
Tip: For animation types, see Animations. For visual effects, see Window Effects.

Examples


# No blur or animation for slurp selection layer (avoids occlusion and ghosting in screenshots)
layerrule=noanim:1,noblur:1,layer_name:selection
# Zoom animation for Rofi with multiple parameters
layerrule=animation_type_open:zoom,noanim:0,layer_name:rofi
# Disable animations and shadows for notification daemon
layerrule=noanim:1,noshadow:1,layer_name:swaync
# Multiple effects for launcher
layerrule=animation_type_open:slide,animation_type_close:fade,noblur:1,layer_name:wofi


Overview
Configure the overview mode for window navigation.

Copy Markdown
Open
Overview Settings

Setting	Type	Default	Description
hotarea_size	integer	10	Hot area size in pixels.
enable_hotarea	integer	0	Enable hot areas (0: disable, 1: enable).
hotarea_disable_on_fullscreen	integer	1	Disable hot areas while a fullscreen window is focused (0: disable, 1: enable).
hotarea_corner	integer	2	Hot area corner (0: top-left, 1: top-right, 2: bottom-left, 3: bottom-right).
overviewgappi	integer	5	Inner gap in overview mode.
overviewgappo	integer	30	Outer gap in overview mode.
overcircle_center_ratio	float	0.5	Width ratio of the centered window in the overcircle layout (0.1–0.9).
jump_labels	string	HJKLASDFGQWERTYUIOPZXCVBNM	Character sequence used for jump hints in overview mode.
Setting Descriptions

enable_hotarea — Toggles overview when the cursor enters the configured corner.
hotarea_disable_on_fullscreen — When enabled, the hot area does not trigger overview while a fullscreen window is focused.
hotarea_size — Size of the hot area trigger zone in pixels.
hotarea_corner — Corner that triggers the hot area (0: top-left, 1: top-right, 2: bottom-left, 3: bottom-right).
jump_labels — Defines the ordered characters used for jump hints when in overview jump mode. Each visible window is assigned a label in this order, and pressing the corresponding key jumps to that window. The number of labels limits how many windows can be assigned hints at once. A label is matched by keycode, resolved the same way as bind: against the layouts configured with xkb_rules_layout in their configured order, with the reference us layout as fallback. Jump mode therefore also works while a non-latin layout is active.
overcircle opens overview; while overview is open, each trigger cycles focus to the next window on the current monitor. Release a modifier key or run toggleoverview to close it.

By default overview temporarily views every tag on the monitor. Use overcircle with current_next/current_prev, or run toggleoverview,1, to keep the overview restricted to the current tagset's windows.

Mouse Interaction in Overview

When in overview mode:

Left mouse button — Jump to (focus) a window.
Right mouse button — Close a window.

Scratchpad
Manage hidden "scratchpad" windows for quick access.

Copy Markdown
Open
mangowm supports two types of scratchpads: the standard pool (Sway-like) and named scratchpads.

Standard Scratchpad

Any window can be sent to the "scratchpad" pile, which hides it. You can then cycle through them.

Keybindings:


# Send current window to scratchpad
bind=SUPER,i,minimized
# Toggle (show/hide) the scratchpad
bind=ALT,z,toggle_scratchpad
# Retrieve window from scratchpad (restore)
bind=SUPER+SHIFT,i,restore_minimized
Named Scratchpad

Named scratchpads are bound to specific keys and applications. When triggered, mangowm will either launch the app (if not running) or toggle its visibility.

1. Define the Window Rule

You must identify the app using a unique appid or title and mark it as a named scratchpad. The application must support setting a custom appid or title at launch. Common examples:

st -c my-appid — sets the appid
kitty -T my-title — sets the window title
foot --app-id my-appid — sets the appid
Use none as a placeholder when you only want to match by one field.


# Match by appid
windowrule=isnamedscratchpad:1,width:1280,height:800,appid:st-yazi
# Match by title
windowrule=isnamedscratchpad:1,width:1000,height:700,title:kitty-scratch
2. Bind the Toggle Key

Format: bind=MOD,KEY,toggle_named_scratchpad,appid,title,command

Use none for whichever field you are not matching on.


# Match by appid: launch 'st' with class 'st-yazi' running 'yazi'
bind=alt,h,toggle_named_scratchpad,st-yazi,none,st -c st-yazi -e yazi
# Match by title: launch 'kitty' with window title 'kitty-scratch'
bind=alt,k,toggle_named_scratchpad,none,kitty-scratch,kitty -T kitty-scratch
Appearance

You can customize the size of scratchpad windows relative to the screen.


scratchpad_width_ratio=0.8
scratchpad_height_ratio=0.9
scratchpadcolor=0x516c93ff
Special Workspace (Tag 0)

The special workspace (Tag 0) provides an overlay workspace of windows that can be summoned anywhere with full layout support (Scroller, Master/Stack, Dwindle, etc.). When Tag 0 is active, windows from the underlying workspace remain visible in the background, and all windows on the special workspace are displayed above them.

Keybindings


# Toggle the special workspace overlay (Tag 0)
bind=SUPER,s,toggle_special_tag
# Move focused window to/from the special workspace
bind=SUPER+SHIFT,s,tag_special_tag
# Silently send active window to the special workspace without switching
bind=SUPER+CTRL,s,tag_special_silent
Window Rules for Special Workspace

You can automatically assign applications to launch directly on the special workspace using tags:0:


# Automatically open Spotify and Discord in the special workspace
windowrule=tags:0,appid:spotify
windowrule=tags:0,appid:discord
Configuration Options

You can configure background dimming and custom layout gaps for the special workspace:


# Background dim level when special workspace is active (0.0 to 1.0, default 0.5)
special_dim=0.5
# Inner and outer gaps for windows on the special workspace
special_gappih=10
special_gappiv=10
special_gappoh=20
special_gappov=20

Key Bindings
Define keyboard shortcuts and modes.

Copy Markdown
Open
Syntax

Key bindings follow this format:


bind[flags]=MODIFIERS,KEY,COMMAND,PARAMETERS
Modifiers: SUPER, CTRL, ALT, SHIFT, NONE (combine with +, e.g. SUPER+CTRL+ALT).
Key: Key name (from xev or wev) or keycode (e.g., code:24 for q).
Info: bind converts the key name to a keycode, so it keeps working while other layouts are active. The name is resolved against the layouts configured with xkb_rules_layout (device:*:kb_layout is not used here), in the order they are listed, and falls back to the reference us layout when none of them can produce the key name. This means bind=SUPER,h resolves to your own h key on layout variants such as Dvorak, and to the us position when only non-latin layouts are configured. Use code:N to bind a keycode directly, or binds to match the character the active layout produces.

Flags

l: Works even when screen is locked.
s: Uses keysym instead of keycode to bind.
r: Triggers on key release instead of press.
p: Pass key event to client.
c: allow keybind conflict(need set in all conflict key).
Info: c has no effect on the reload_config and load_config_file dispatches, which always stop the current key event.

Examples:


bind=SUPER,Q,killclient
bindl=SUPER,L,spawn,swaylock
# Using keycode instead of key name
bind=ALT,code:24,killclient
# Combining keycodes for modifiers and keys
bind=code:64,code:24,killclient
bind=code:64+code:133,code:24,killclient
# Bind with no modifier
bind=NONE,XF86MonBrightnessUp,spawn,brightnessctl set +5%
# Bind a modifier key itself as the trigger key
bind=alt,shift_l,switch_keyboard_layout
# Allow keybind conflict
bindc=SUPER,a,resizewin,+10,0
bindc=SUPER,a,centerwin
Key Modes (Submaps)

You can divide key bindings into named modes. Rules:

Set keymode=<name> before a group of bind lines — those binds only apply in that mode.
If no keymode is set before a bind, it belongs to the default mode.
The special common keymode applies its binds across all modes.
Info: Key modes also apply to the other input bindings — mousebind, axisbind, gesturebind and switchbind — which share the exact same keymode rules as bind.

Use setkeymode to switch modes, and mmsg get keymode to query the current mode.


# Binds in 'common' apply in every mode
keymode=common
bind=SUPER,r,reload_config
# Default mode bindings
keymode=default
bind=ALT,Return,spawn,foot
bind=SUPER,F,setkeymode,resize
# 'resize' mode bindings
keymode=resize
bind=NONE,Left,resizewin,-10,0
bind=NONE,Right,resizewin,+10,0
bind=NONE,Escape,setkeymode,default
Single Modifier Key Binding

When binding a modifier key itself, use NONE for press and the modifier name for release:


# Trigger on press of Super key
bind=none,Super_L,spawn,rofi -show run
# Trigger on release of Super key
bindr=Super,Super_L,spawn,rofi -show run
Dispatchers List

Window Management

Command	Param	Description
killclient	force	Close the focused window. If force is specified, sends SIGKILL.
togglefloating	-	Toggle floating state.
toggle_all_floating	-	Toggle all visible clients floating state.
togglefullscreen	-	Toggle fullscreen.
togglefakefullscreen	-	Toggle "fake" fullscreen (remains constrained).
togglemaximizescreen	-	Maximize window (keep decoration/bar).
toggleglobal	-	Pin window to all tags.
toggle_render_border	-	Toggle border rendering.
centerwin	-	Center the floating window.
minimized	-	Minimize window to scratchpad.
restore_minimized	-	Restore minimized window to the currently focused tag.
toggle_scratchpad	-	Toggle scratchpad.
toggle_named_scratchpad	appid,title,cmd	Toggle named scratchpad. Launches app if not running, otherwise shows/hides it.
toggle_special_tag	-	Toggle special workspace overlay (tiling scratchpad).
tag_special_tag	-	Move focused window to/from the special workspace overlay.
tag_special_silent	-	Silently move focused window to/from the special workspace overlay.
Focus & Movement

Command	Param	Description
focusid	-	Focus window (can target any window via IPC: mmsg dispatch focusid client,<id>)
focusdir	left/right/up/down	Focus window in direction.
focus_window_or_workspace	left/right/up/down	Focus window in direction; otherwise jump to the nearest adjacent tag that has clients, falling back to the next/previous tag if none.
focusstack	next/prev	Cycle focus within the stack.
overcircle	next/prev/current_next/current_prev	Open overview when closed; while it is open, cycle focus to the next/previous window on the current monitor. current_next/current_prev only show the current tagset's windows in the overview instead of all tags.
focuslast	-	Focus the previously active window.
switcher	next/prev, all_tag_next/all_tag_prev, all_next/all_prev	Open or cycle the thumbnail switcher. next/prev list the current tag's windows, all_tag_next/all_tag_prev list all tags on the current monitor, all_next/all_prev list all monitors and tags. Releasing any modifier key selects.
exchange_client	left/right/up/down	Swap the focused window with its neighbor in direction. Both windows change place, and with exchange_cross_monitor enabled they also swap monitors.
exchange_stack_client	next/prev	Exchange window position in stack.
move_client	left/right/up/down	Move the focused window one step in direction. On the same monitor dwindle re-inserts it next to the neighbor keeping the row/column it came from, every other layout swaps it with the neighbor like exchange_client. When the neighbor lies on another monitor the window moves onto that monitor and is inserted in front of or behind the neighbor on the side it comes from; without a neighbor in that direction it moves onto the monitor lying there. Crossing monitors needs exchange_cross_monitor.
zoom	-	Swap focused window with Master.
Group

Command	Param	Description
groupjoin	left/right/up/down	Join group by direction.
groupfocus	prev/next	Focus group member by direction.
groupleave	-	Leave group.
Tags & Monitors

Command	Param	Description
view	mask[,synctag]	View tag(s). Accepts a tag mask. Additionally, 00 shows all tags, -1 shows the previous tagset. Optional synctag (0/1) syncs the action to all monitors.
viewtoleft	[synctag]	View previous tag. Optional synctag (0/1) syncs to all monitors.
viewtoright	[synctag]	View next tag. Optional synctag (0/1) syncs to all monitors.
view_insert	prev/next	View the adjacent tag if it is empty; otherwise insert an empty tag before/after the current one and switch to it.
viewtoleft_have_client	[synctag]	View left tag and focus client if present. Optional synctag (0/1).
viewtoright_have_client	[synctag]	View right tag and focus client if present. Optional synctag (0/1).
viewcrossmon	mask,monitor_spec	View specified tag(s) on specified monitor. Accepts a tag mask and a monitor spec.
tag	mask[,synctag]	Move window to tag(s). Accepts a tag mask. Optional synctag (0/1) syncs to all monitors.
tagsilent	mask	Move window to tag(s) without focusing it. Accepts a tag mask.
tagtoleft	[synctag]	Move window to left tag. Optional synctag (0/1).
tagtoright	[synctag]	Move window to right tag. Optional synctag (0/1).
tagcrossmon	mask,monitor_spec	Move window to tag(s) on specified monitor. Accepts a tag mask and a monitor spec.
toggletag	mask	Toggle tag(s) on window. Accepts a tag mask. 00 toggles all tags.
toggleview	mask	Toggle view of tag(s). Accepts a tag mask.
comboview	mask	View multiple tags simultaneously. Accepts a tag mask (typically built by pressing keys, e.g., `1
focusmon	left/right/up/down/next/prev/monitor_spec	Focus monitor by direction, by cycling to the next or previous monitor (next/prev), or by monitor spec.
tagmon	left/right/up/down/next/prev/monitor_spec,[keeptag]	Move window to monitor by direction, by cycling to the next or previous monitor (next/prev), or by monitor spec. keeptag is 0 or 1.
Tag Mask Format

A tag mask specifies one or more tags for commands that operate on tags.
It is formed by tag numbers 1–9, optionally combined with |.

3 – single tag 3
1|3|5 – tags 1, 3, and 5
Layouts

Command	Param	Description
setlayout	name	Switch to layout (e.g., scroller, tile).
switch_layout	-	Cycle through available layouts.
incnmaster	+1/-1	Increase/Decrease number of master windows.
setmfact	+0.05	Increase/Decrease master area size.
set_proportion	float	Set scroller window proportion (0.0–1.0).
switch_proportion_preset	-	Cycle proportion presets of scroller window.
scroller_stack	left/right/up/down	Move window inside/outside scroller stack by direction.
incgaps	+/-value	Adjust gap size.
togglegaps	-	Toggle gaps.
dwindle_toggle_split_direction	-	Toggle split direction in dwindle layout.
dwindle_split_horizontal	-	Set split window direction to horizontal in dwindle layout.
dwindle_split_vertical	-	Set split window direction to vertical in dwindle layout.
dwindle_toggle_current_split	-	Toggle split direction of current window in dwindle layout.
System

Command	Param	Description
spawn	cmd	Execute a command.
spawn_shell	cmd	Execute shell command (supports pipes |).
spawn_on_empty	cmd, tagmask	Open command on empty tag.Accepts a cmd string and tagmask
reload_config	-	Hot-reload configuration. Does not support keybind conflict (c flag).
load_config_file	file path	Load configuration from the specified file. Empty path resets to default config location. Does not support keybind conflict (c flag).
quit	-	Exit mangowm.
toggleoverview	[1]	Toggle overview mode. Passing 1 only shows the current tagset's windows in the overview instead of all tags.
enteroverview	-	Enter overview mode.
leaveoverview	-	Leave overview mode.
togglejump	-	Toggle overview with jump mode.
create_virtual_output	-	Create a headless monitor (for VNC/Sunshine).
destroy_all_virtual_output	-	Destroy all virtual monitors.
toggleoverlay	-	Toggle overlay state for the focused window.
toggle_trackpad_enable	-	Toggle trackpad enable.
setkeymode	mode	Set keymode.
switch_keyboard_layout	[index]	Switch keyboard layout. Optional index (0, 1, 2...) to switch to specific layout.
setoption	key,value	Set config option temporarily.
sleep_monitor	monitor_spec	Shutdown monitor power but not remove. Accepts a monitor spec.
wakeup_monitor	monitor_spec	Turn on monitor power. Accepts a monitor spec.
sleep_toggle_monitor	monitor_spec	Toggle monitor power but not remove. Accepts a monitor spec.
disable_monitor	monitor_spec	remove monitor. Accepts a monitor spec.
enable_monitor	monitor_spec	add monitor. Accepts a monitor spec.
toggle_monitor	monitor_spec	Toggle monitor add/remove. Accepts a monitor spec.
Media Controls

Warning: Some keyboards don't send standard media keys. Run wev and press your key to check the exact key name.

Brightness

Requires: brightnessctl


bind=NONE,XF86MonBrightnessUp,spawn,brightnessctl s +2%
bind=SHIFT,XF86MonBrightnessUp,spawn,brightnessctl s 100%
bind=NONE,XF86MonBrightnessDown,spawn,brightnessctl s 2%-
bind=SHIFT,XF86MonBrightnessDown,spawn,brightnessctl s 1%
Volume

Requires: wpctl (WirePlumber)


bind=NONE,XF86AudioRaiseVolume,spawn,wpctl set-volume @DEFAULT_SINK@ 5%+
bind=NONE,XF86AudioLowerVolume,spawn,wpctl set-volume @DEFAULT_SINK@ 5%-
bind=NONE,XF86AudioMute,spawn,wpctl set-mute @DEFAULT_SINK@ toggle
bind=SHIFT,XF86AudioMute,spawn,wpctl set-mute @DEFAULT_SOURCE@ toggle
Playback

Requires: playerctl


bind=NONE,XF86AudioNext,spawn,playerctl next
bind=NONE,XF86AudioPrev,spawn,playerctl previous
bind=NONE,XF86AudioPlay,spawn,playerctl play-pause
Floating Window Movement

Command	Param	Description
smartmovewin	left/right/up/down	Move floating window by snap distance.
smartresizewin	left/right/up/down	Resize floating window by snap distance.
movewin	(x,y)	Move floating window.
resizewin	(width,height)	Resize window.

Mouse & Gestures
Configure mouse buttons, scrolling, gestures, and lid switches.

Copy Markdown
Open
Mouse Bindings

Assign actions to mouse button presses with optional modifier keys.

Info: All of the bindings in this page (mousebind, axisbind, gesturebind, switchbind) support key modes via keymode=<name>, using the exact same rules as bind. See Keys: Key Modes.

Syntax


mousebind=MODIFIERS,BUTTON,COMMAND,PARAMETERS
Modifiers: SUPER, CTRL, ALT, SHIFT, NONE. Combine with + (e.g., SUPER+CTRL).
Buttons: Can be specified in one of the following ways:
Standard Names: btn_left, btn_right, btn_middle, btn_side, btn_extra, btn_forward, btn_back, btn_task
Hardware Codes: code:NUMBER (e.g., code:272, code:273, useful for binding non-standard or extra mouse buttons)
Examples


# Window manipulation
mousebind=SUPER,btn_left,moveresize,curmove
mousebind=SUPER,btn_right,moveresize,curresize
mousebind=SUPER+CTRL,btn_right,killclient
mousebind=NONE,code:273,togglemaximizescreen,0
Axis Bindings

Map scroll wheel movements to actions for workspace and window navigation.

Syntax


axisbind=MODIFIERS,DIRECTION,COMMAND,PARAMETERS
Direction: UP, DOWN, LEFT, RIGHT
Examples


axisbind=SUPER,UP,viewtoleft_have_client
axisbind=SUPER,DOWN,viewtoright_have_client
Gesture Bindings

Enable trackpad swipe gestures for navigation and window management.

Syntax


gesturebind=MODIFIERS,DIRECTION,FINGERS,COMMAND,PARAMETERS
Direction: up, down, left, right
Fingers: 3 or 4
Info: Gestures require proper trackpad configuration. See Input Devices for trackpad settings like tap_to_click and trackpad_disable_while_typing.

Drag previews for bound gestures

gesture_live=1 shows the transition while dragging for these gesturebind commands:


# right drag -> previous tag
gesturebind=none,right,4,viewprev_have_client
# left drag -> next tag
gesturebind=none,left,4,viewnext_have_client
# swipe up -> overview
gesturebind=none,up,4,toggleoverview
# swipe down -> close overview
gesturebind=none,down,4,toggleoverview
Set gesture_live=0 to disable previews and act only on release.

Examples


# 3-finger: Window focus
gesturebind=none,left,3,focusdir,left
gesturebind=none,right,3,focusdir,right
gesturebind=none,up,3,focusdir,up
gesturebind=none,down,3,focusdir,down
# 4-finger: Workspace navigation (right drag -> previous tag, left drag -> next)
gesturebind=none,right,4,viewprev_have_client
gesturebind=none,left,4,viewnext_have_client
gesturebind=none,up,4,toggleoverview
gesturebind=none,down,4,toggleoverview
Switch Bindings

Trigger actions on hardware events like laptop lid open/close.

Syntax


switchbind=FOLD_STATE,COMMAND,PARAMETERS
Fold State: fold (lid closed), unfold (lid opened)
Warning: Disable system lid handling in /etc/systemd/logind.conf:


HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
Examples


switchbind=fold,spawn,swaylock -f -c 000000
switchbind=unfold,spawn,wlr-dpms on

mmsg(1) - User Manual

mmsg is the command-line interface for the Mango compositor's Inter-Process Communication (IPC) system. It allows users and scripts to query the state of the compositor or subscribe to real-time events.

SYNOPSIS

mmsg <command> [arguments...]

DESCRIPTION

mmsg acts as a client that connects to the Mango compositor via a Unix domain socket defined by the MANGO_INSTANCE_SIGNATURE environment variable. It supports two primary modes of operation:

One-shot Request (get): Sends a query to the compositor, receives a single JSON response, and terminates.
Persistent Stream (watch): Subscribes to a specific state, receiving continuous JSON updates whenever that state changes.
ENVIRONMENT VARIABLES

MANGO_INSTANCE_SIGNATURE: Must be set to the path of the Unix socket created by the running Mango instance. This is typically handled automatically when running mmsg from within a terminal spawned by the compositor.
COMMANDS

GET (One-Shot Queries)

Command	Description
get version	Returns the current version of the compositor.
get cursorpos	Returns the global pointer position (x, y) and the monitor under it.
get keymode	Returns the current active keyboard mode (e.g., normal, insert).
get keyboardlayout	Returns the active XKB layout (abbreviated).
get monitor <name>	Returns full JSON details for a specific monitor.
get focusing-client	Returns full JSON details for the client currently in focus.
get client <id>	Returns full JSON details for a client with the given ID.
get tag <mon> <idx>	Queries status of a specific tag on a monitor.
get tags <mon>	Returns a JSON object containing the status of all tags on a monitor.
get all-clients	Returns a JSON array of all active clients.
get all-monitors	Returns a JSON array of all connected monitors.
get all-devices	Returns a JSON array of all physical input devices, grouped by libinput device group (name, types, identifier, vendor, product, interfaces, matched).
get all-layers	Returns a JSON array of all open layer surfaces (monitor, layer, name).
get all-tags	Returns a JSON object containing the status of all tags.
get last_open_surface [<mon>]	Returns the last focused surface name for a monitor,if the mon not set, it will get current monitor.
Example:


mmsg get monitor eDP-1
mmsg get all-clients
mmsg get all-monitors
mmsg get all-devices
mmsg get all-layers
mmsg get cursorpos
WATCH (Event Subscription)

Subscribes the client to real-time updates. When the state changes, the server pushes a new JSON object to the output stream.

watch monitor <name>
watch focusing-client
watch client <id>
watch tags <mon_name>
watch all-monitors
watch all-tags
watch all-clients
watch all-devices — streams the last input device (name, type) that triggered an event
watch keymode
watch keyboardlayout
watch last_open_surface [<mon_name>]
Example:


# watch all monitors
mmsg watch all-monitors
# watch all tags
mmsg watch all-tags
DISPATCH

Allows sending commands to the compositor to alter its state.

dispatch <func_name>,[args...] [client,<id>]
Example:


# operate specific client by id
mmsg dispatch exchange_client,left client,375
# operate current client
mmsg dispatch exchange_client,left
