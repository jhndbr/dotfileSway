#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║        Emoji Picker — Sway / Wayland                         ║
# ║        Wofi dmenu + wl-clipboard + wtype                     ║
# ╚══════════════════════════════════════════════════════════════╝

# Lista completa de emojis: "EMOJI  descripción buscable"
EMOJI_LIST=$(cat <<'EOF'
😀  risa feliz cara contenta
😃  cara sonriente
😄  sonrisa alegria
😁  sonrisa radiante
😆  carcajada risa fuerte
😅  risa sudor nervio
🤣  rodando risa
😂  lagrimas risa llanto
🙂  sonrisa leve sutil
🙃  al reves invertido
😉  guiño
😊  sonrojado feliz
😇  angel inocente
🥰  amor corazones enamorado
😍  ojos corazon amor enamorado
🤩  deslumbrado estrellas estrella impresionado
😘  beso amor corazon
😗  beso
😚  beso ojos cerrados
😙  beso sonrisa
😋  delicioso rico sabroso lengua
😛  lengua fuera
😜  guino lengua loco
🤪  loco raro zany
😝  lengua ojos cerrados
🤑  dinero millonario rico plata
🤗  abrazo emocionado
🤭  sorpresa disimulo
🤫  silencio calla shh
🤔  pensando hmm reflexion
🤐  callado mudo boca cerrada zipper
🤨  ceja levantada sospecha
😐  neutral serio
😑  sin expresion
😶  sin boca mudo
😏  picaro sonrisa maliciosa
😒  descontento aburrido
🙄  ojos arriba exasperado whatever
😬  mueca incomodo vergüenza
🤥  mentiroso pinocho
😌  relajado tranquilo paz
😔  triste pensativo melancolia
🥱  bostezo cansado aburrido sueño
😴  durmiendo dormir cansado zzz
😷  mascarilla enfermo proteccion
🤒  fiebre enfermo termometro
🤕  herido cabeza vendaje
🤢  nauseas asco vomito
🤮  vomito asco enfermo
🤧  estornudo resfrio mocos
🥵  calor fiebre sudor
🥶  frio congelado
🥴  mareado confundido ebrio
😵  mareo aturdido
🤯  mente explotada sorpresa wow
🧐  monóculo investigando curioso culto
😕  confundido desconcertado
😟  preocupado molesto
😮  sorprendido asombrado
😲  impresionado sorprendido
😳  sonrojado vergüenza asombro
😱  grito miedo horror
😨  temeroso asustado
😰  ansioso sudor preocupacion
😢  llora triste lagrima
😭  llora mucho desconsolado
😤  frustrado vapor enojado
😠  enojado enfadado
😡  furia rojo enojo rabia
🤬  insulto groseria rabia
😈  diablo travieso maldad
👿  diablo malo
💀  calavera muerte
☠️  calavera huesos muerte
💩  caca popo mierda
🤡  payaso
👹  monstruo ogro
👺  monstruo rojo
👻  fantasma halloween
👾  alien videojuego
🤖  robot android ia
🎃  calabaza halloween
😺  gato feliz
😸  gato sonrisa
😹  gato risa lagrimas
😻  gato ojos corazon
😼  gato picardia
😽  gato beso
🙀  gato sorpresa
😿  gato llora
😾  gato enojado
👋  hola adios saludo mano
🤚  mano levantada stop alto
🖐️  mano abierta cinco
✋  mano stop alto
🖖  saludo vulcano star trek
🤙  llamame surfista
👌  ok perfecto bien
🤌  perfecto italiano
✌️  victoria paz dos dedos
🤞  dedos cruzados suerte
🤟  amor te quiero
🤘  rock metal
🤙  llamame guay
👈  izquierda señalar
👉  derecha señalar
👆  arriba señalar
👇  abajo señalar
☝️  uno importante señalar arriba
👍  pulgar arriba bien bueno ok sip
👎  pulgar abajo mal no
✊  puño fuerza
👊  puño golpe
🤛  puño izquierda
🤜  puño derecha
👏  aplauso palmada bravo
🙌  manos arriba celebrar
🤝  apretón manos acuerdo
🙏  manos juntas gracias rezar por favor
✍️  escribir firma mano
💅  uñas arreglarse cool
🤳  selfie foto
💪  fuerza musculo brazo
🦵  pierna
🦶  pie
👂  oreja escuchar
🦻  oreja audifono
👃  nariz oler
🫀  corazon organo
🫁  pulmon organo
🧠  cerebro inteligencia
🦷  diente muela
🦴  hueso
👀  ojos mirando ver espiar
👁️  ojo
👅  lengua gusto
👄  labios beso boca
💋  beso marca labios rouge
❤️  corazon rojo amor querer
🧡  corazon naranja
💛  corazon amarillo
💚  corazon verde
💙  corazon azul
💜  corazon morado lila
🖤  corazon negro
🤍  corazon blanco
🤎  corazon marron cafe
💔  corazon roto desamor
❣️  exclamacion corazon
💕  dos corazones amor
💞  corazones girando amor
💓  corazon latido
💗  corazon rosa crecer
💖  corazon brillante
💝  corazon regalo
💘  corazon flecha cupido
💟  decoracion corazon
☮️  paz simbolo
✝️  cruz cristiana
☯️  yin yang equilibrio
🕉️  om hinduismo
✡️  estrella david judaismo
☪️  media luna islam
🕎  menora judaismo
🔯  estrella david hexagrama
🌙  luna creciente noche
⭐  estrella
🌟  estrella brillante destello
✨  destellos magia brillar
⚡  rayo electricidad energia
🔥  fuego llama caliente hot trending
💥  explosion impacto boom
🌈  arcoiris colores
☁️  nube
⛅  nube sol parcialmente
🌤️  sol nube
☀️  sol soleado calor
🌧️  lluvia nublado
⛈️  tormenta trueno
❄️  nieve copo frio invierno
🌊  ola agua mar
🌸  flor cerezo primavera
🌺  flor hibisco
🌻  girasol flor amarilla
🌹  rosa flor amor
🌷  tulipan flor
🍀  trebol suerte
🌿  hoja planta naturaleza
🍃  hojas viento naturaleza
🎄  arbol navidad diciembre
🐶  perro cachorro mascota
🐱  gato mascota felino
🐭  raton mouse
🐹  hamster
🐰  conejo
🦊  zorro astuto
🐻  oso
🐼  panda
🐨  koala
🐯  tigre fiero
🦁  leon rey melena
🐸  sapo rana
🐵  mono simio
🙈  mono no ver
🙉  mono no escuchar
🙊  mono no hablar
🐔  pollo gallina
🐧  pinguino
🐦  pajaro ave
🦆  pato
🦅  aguila
🦉  buho nocturno sabio
🦇  murcielago batman halloween
🐺  lobo aullido
🦊  zorro
🦝  mapache
🐗  jabali cerdo salvaje
🐴  caballo
🦄  unicornio magico
🐝  abeja miel
🦋  mariposa
🐛  gusano oruga
🐌  caracol lento
🐞  mariquita
🐜  hormiga
🦟  mosquito
🦗  grillo
🕷️  araña halloween
🦂  escorpion
🐢  tortuga lenta
🦎  lagartija reptil
🐍  serpiente vibora
🦕  dinosaurio
🦖  t-rex dinosaurio
🐙  pulpo tentaculos
🦑  calamar
🦐  camaron
🦞  langosta
🦀  cangrejo
🐡  pez globo
🐠  pez tropical
🐟  pez
🐬  delfin
🐳  ballena
🦈  tiburon
🐊  cocodrilo
🐘  elefante
🦏  rinoceronte
🦛  hipopotamo
🐃  buey
🐂  toro
🦬  bisonte
🦌  ciervo
🦙  llama
🐑  oveja
🐐  cabra
🦘  canguro
🦥  perezoso
🦦  nutria
🦨  mofeta
🦡  tejon
🐓  gallo
🦃  pavo
🦚  pavo real colorido
🦜  loro parlanchin
🦢  cisne
🦩  flamenco rosa
🕊️  paloma paz
🐇  conejo mascota
🦝  mapache
🦔  erizo
🐾  huellas patas mascota
🦴  hueso perro
🍎  manzana roja fruta
🍊  naranja mandarina fruta
🍋  limon agrio fruta
🍇  uvas fruta vino
🍓  frutilla fresa fruta roja
🫐  arandano fruta azul
🍒  cerezas fruta dulce
🍑  durazno melocoton fruta
🍍  piña tropical fruta
🥭  mango tropical fruta
🍌  banana platano fruta
🥝  kiwi fruta verde
🍅  tomate rojo vegetal
🥑  aguacate palta verde
🥦  brocoli vegetal verde
🌽  choclo maiz vegetal
🥕  zanahoria vegetal
🧄  ajo vegetal
🧅  cebolla vegetal
🍕  pizza comida rapida
🍔  hamburguesa burger comida rapida
🍟  papas fritas
🌭  hot dog salchicha
🥪  sandwich
🌮  taco mexicano comida
🌯  wrap burrito
🫔  tamal
🥙  kebab pita
🍣  sushi japonesa
🍱  bento japonesa
🍜  ramen fideos sopa
🍝  espagueti pasta italiana
🍛  curry picante
🍲  guiso olla
🥘  paella cazuela
🍗  pollo asado muslo
🍖  costilla carne asada
🥩  carne steak
🥚  huevo
🍳  huevo frito sarten
🧇  waffle desayuno
🥞  pancake panqueque desayuno
🧈  mantequilla manteca
🧀  queso
☕  cafe caliente taza
🍵  te verde taza caliente
🍺  cerveza chopp bar fiesta
🍻  brindis cerveza cheers
🥂  copas brindis champagne celebracion
🍷  vino copa rojo
🥃  whisky bourbon vaso
🧃  jugo zumo cajita
🧉  mate yerba argentina
🥤  gaseosa refresco vaso pajita
🍸  cocktail martini copa
🍹  tropical coctel frutas
🎂  torta cumpleaños pastel fiesta
🍰  porcion torta cumpleaños
🧁  cupcake muffin dulce
🍩  donut rosquilla dulce
🍪  galleta cookie dulce
🍫  chocolate barra dulce
🍬  caramelo dulce
🍭  chupetín piruleta dulce
🍮  flan postre dulce
🍯  miel tarro dulce
🏠  casa hogar
🏡  casa jardin hogar
🏢  edificio oficina ciudad
🏣  correo oficina
🏤  correo europeo
🏥  hospital medicina salud
🏦  banco dinero finanzas
🏨  hotel viaje hospedaje
🏩  hotel amor
🏪  tienda comercio negocio
🏫  escuela colegio educacion
🏬  centro comercial shopping
🏰  castillo medieval
🏯  castillo japones
⛩️  santuario torii japon
🗼  torre eiffel paris
🗽  estatua libertad nueva york
🗿  moai piedra
🚗  auto coche vehiculo
🚕  taxi amarillo
🚙  suv camioneta vehiculo
🚌  colectivo bus transporte
🚎  trolleybus
🏎️  auto formula 1 carrera rapido
🚓  policia patrullero
🚑  ambulancia emergencia
🚒  bomberos camion rojo
🚐  minibus
🛻  pickup camioneta
🚚  camion carga
🚛  camion trailer
🚜  tractor granja
🏍️  moto motocicleta
🛵  scooter moto pequena
🚲  bicicleta bici
🛴  monopatín patinete
🛺  tuk tuk
✈️  avion vuelo viaje
🚀  cohete espacio astronauta
🛸  ovni extraterrestre
🛩️  avion pequeño
🚁  helicoptero
⛵  velero barco vela
🚢  barco crucero
⛴️  ferry barco transporte
🛥️  lancha bote motor
🚤  lancha rapida
🎸  guitarra rock musica
🎹  piano teclado musica
🎺  trompeta jazz musica
🎻  violin clasico musica
🥁  bateria percusion musica
🎷  saxofon jazz musica
🎵  nota musical
🎶  musica notas melodia
🎼  partitura musica
🎤  microfono cantante
🎧  auriculares headphones musica
📺  television tv pantalla
📻  radio
📷  camara foto
📸  camara flash foto
📹  camara video
🎥  pelicula cine video
🎬  claqueta accion cine
🎞️  pelicula rollo cine
📽️  proyector cine
🎭  teatro drama mascaras
🎨  arte pintura paleta
🖌️  pincel pintura arte
🖍️  crayola dibujo
✏️  lapiz escribir
🖊️  boligrafo pluma
📝  memo nota escribir
📖  libro leer
📚  libros biblioteca
📗  libro verde
📘  libro azul
📙  libro naranja
📕  libro rojo
💡  idea bombilla luz
🔦  linterna luz
💰  bolsa dinero plata plata rico
💵  billete dolar dinero
💴  billete yen japon
💶  billete euro europa
💷  billete libra uk
💳  tarjeta credito pago
🏧  cajero automatico atm
💹  grafico dinero mercado
📊  grafico barras estadistica
📈  grafico subiendo crecimiento
📉  grafico bajando perdida
🏆  trofeo ganador campeón primero
🥇  medalla oro primer lugar ganador
🥈  medalla plata segundo lugar
🥉  medalla bronce tercer lugar
⚽  futbol soccer pelota
🏀  basquet basketball
🏈  futbol americano
⚾  baseball pelota
🎾  tenis pelota
🏐  voley volleyball
🏉  rugby pelota oval
🥏  frisbee disco
🎱  billar bola ocho
🏓  ping pong tenis mesa
🏸  badminton volante
🥊  boxeo guante pelear
🥋  karate artes marciales
🏊  nadar natacion
🏄  surf ola mar
🚴  ciclismo bicicleta pedalear
🏋️  pesas gym fitness
🤸  gimnasia acrobacia
⛷️  esqui nieve invierno
🏂  snowboard nieve
🏇  carrera caballo jockey
🎿  esqui alpino
🧗  escalada roca
🤺  esgrima espada
🏌️  golf pelota palo
🤼  lucha wrestling
🤾  handball balonmano
🏹  arco flecha
🛹  skateboard skate
🛷  trineo nieve invierno
🛼  patines ruedas
🪂  paracaidas salto libre
🏊  nadar piscina
🤽  waterpolo
🚣  remo bote kayak
🧘  yoga meditacion paz
💻  laptop computadora programacion
🖥️  monitor escritorio pc
🖨️  impresora
⌨️  teclado escribir
🖱️  mouse raton
💾  diskette guardar
💿  cd disco musica
📀  dvd disco pelicula
📱  celular telefono movil smartphone
☎️  telefono fijo
📞  auricular telefono llamada
📟  biper pager
📠  fax
🔋  bateria carga energia
🪫  bateria baja descargada
🔌  enchufe cable electricidad
💡  bombilla luz idea
🔦  linterna luz
🕯️  vela luz romantico
🪔  lampara aceite
🧯  extinguidor fuego emergencia
🛢️  barril petroleo combustible
💸  dinero volando gasto
💳  tarjeta pago credito
🪙  moneda dinero metal
💎  diamante joya lujo rico
🔑  llave abrir puerta
🗝️  llave vieja vintage
🔐  candado llave cerrado
🔒  candado cerrado seguro
🔓  candado abierto
🔨  martillo herramienta
🪛  destornillador herramienta
🔧  llave inglesa herramienta mecanico
⚙️  engranaje mecanismo configuracion settings
🗜️  prensa tornillo herramienta
🪝  gancho colgar
⛓️  cadena eslabones
🧲  iman magnetico
🔫  pistola agua juguete
🧨  petardo explosivo
💣  bomba explosivo peligro
🪓  hacha herramienta
⚔️  espadas cruzadas guerra medieval
🛡️  escudo defensa proteccion
🪤  trampa ratonera
🔪  cuchillo arma
🗡️  daga arma
🪚  serrucho sierra herramienta
🔩  tornillo tuerca herramienta
🪜  escalera subir
🧱  ladrillo construccion pared
⚗️  alambique quimica experimento
🔭  telescopio astronomia
🔬  microscopio ciencia laboratorio
🩻  rayos x huesos medico
💊  pastilla medicamento medicina
💉  jeringa inyeccion vacuna
🩺  estetoscopio medico doctor
🩼  muleta accidente herido
🩹  curita vendaje herida
🩸  sangre gota
🧬  adn genetica ciencia
🦠  virus bacteria microbio
🧪  tubo ensayo laboratorio quimica
🧫  placa petri laboratorio
🧲  iman ciencia fisica
⚡  rayo electricidad energia rapido
🔥  fuego caliente trending hot viral
❄️  hielo frio congelado nieve
🌊  agua ola mar oceano
🌪️  tornado viento huracan
🌫️  niebla bruma vapor
💨  viento aire soplar
🌡️  termometro temperatura
🎁  regalo presente sorpresa
🎀  lazo regalo decoracion
🎊  confeti celebracion fiesta
🎉  fiesta celebracion cohete
🎈  globo fiesta cumpleanos
🎏  colgante decoracion
🎆  fuegos artificiales noche año nuevo
🎇  bengala fuegos artificiales
🧨  petardo año nuevo
✨  magia brillar estrellitas
🎍  pino decoracion año nuevo japones
🎋  bambu decoracion
🎑  luna otoño festival japones
🎃  calabaza halloween miedo octubre
🎄  arbol navidad diciembre
🎆  fuegos artificiales
🎐  carillon viento decoracion
🎑  paisaje luna
🧧  sobre rojo año nuevo chino
🎎  muñecas japonesas hina
🎏  carpa festival japon
🎗️  cinta concienciacion
🎟️  ticket entrada boleto
🎫  ticket entrada
🎖️  medalla distincion honor
🏅  medalla deporte
🥇  oro primero ganar
🏆  trofeo campeon
🎴  naipes flores carta juego
🀄  mahjong juego chino
🎲  dado juego azar suerte
♟️  ajedrez estrategia tablero
🎯  diana objetivo meta exacto
🎳  bowling bolos juego
🎮  videojuego controller mando jugar
🕹️  joystick videojuego arcade
🎰  tragamonedas casino juego
📌  tachuela marcar ubicacion
📍  pin ubicacion mapa
📎  clip sujetar papeles
🖇️  clips papeles unir
📏  regla medir
📐  escuadra medir angulo
✂️  tijeras cortar
🗃️  archivador cajones ordenar
🗄️  servidor archivo
🗑️  papelera basura borrar eliminar
🔒  seguridad cerrado proteccion
🔓  abierto desbloqueado
🏁  bandera meta final carrera
🚩  bandera roja alerta marcar
🎌  banderas japon cruzadas
🏴  bandera negra pirata
🏳️  bandera blanca rendicion paz
🏳️‍🌈  bandera arcoiris orgullo lgbtq
🌐  globo internet mundo web
🗺️  mapa mundo viaje
🧭  brujula norte orientacion
🗾  mapa japon
EOF
)

# Mostrar en Wofi
SELECTED=$(echo "$EMOJI_LIST" | wofi \
    --dmenu \
    --prompt "  😀  Buscar emoji..." \
    --cache-file /dev/null \
    --insensitive \
    --width 520 \
    --height 460 \
    --lines 12)

if [ -n "$SELECTED" ]; then
    # Extraer solo el emoji (primer caracter unicode, primer campo)
    EMOJI=$(echo "$SELECTED" | awk '{print $1}')

    # Copiar al portapapeles
    echo -n "$EMOJI" | wl-copy

    # Pegar directamente en la ventana activa si wtype está disponible
    if command -v wtype &>/dev/null; then
        sleep 0.1
        wtype "$EMOJI" 2>/dev/null || true
    fi

    # Notificación
    if command -v dunstify &>/dev/null; then
        dunstify \
            -a "Emoji Picker" \
            -r 9921 \
            -t 2000 \
            "$EMOJI  Copiado al portapapeles" \
            "También pegado en la ventana activa"
    fi
fi
