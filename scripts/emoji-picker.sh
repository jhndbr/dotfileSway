#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║        Visor & Seleccionador de Emojis para Sway             ║
# ║        Estilo Windows / macOS con Wofi + wl-clipboard        ║
# ╚══════════════════════════════════════════════════════════════╝

EMOJI_LIST="😀 Risa feliz
😃 Carita sonriente
😄 Sonrisa ojos felices
😁 Sonrisa radiante
😆 Risa carcajada
😅 Risa sudor frío
🤣 Risa rodando en el suelo
😂 Risa lágrimas de alegría
🙂 Sonrisa leve
🙃 Carita al revés
😉 Guiño
😊 Carita sonrojada
😇 Carita ángel
🥰 Carita con corazones
😍 Ojos de corazón
🤩 Carita deslumbrada
😘 Beso de corazón
😗 Beso
😚 Beso ojos cerrados
😙 Beso sonrisa
😋 Lengua fuera delicioso
😛 Lengua fuera
😜 Guiño lengua fuera
🤪 Carita loca
😝 Lengua fuera ojos cerrados
🤑 Carita dinero
🤗 Carita abrazo
🤭 Mano en la boca
🤫 Carita silencio
🤔 Pensativo
🤐 Boca con cierre
🤨 Ceja levantada
😐 Neutral
😑 Sin expresión
😶 Sin boca
😏 Sonrisa picara
😒 Descontento
🙄 Ojos arriba
😬 Mueca
🤥 Mentiroso
relajado 😌 Relajado
prensado 😔 Pensativo triste
bostezando 🥱 Bostezo
durmiendo 😴 Durmiendo
salud 😷 Mascarilla
fiebre 🤒 Termómetro
herida 🩹 Curita
monóculo 🧐 Monóculo
confundido 😕 Confundido
preocupado 😟 Preocupado
asombrado 😮 Sorprendido
impresionado 😲 Impresionado
ruborizado 😳 Sonrojado
asustado 😱 Grito de miedo
temeroso 😨 Temeroso
ansioso 😰 Ansioso
llorando 😢 Llorando
desconsolado 😭 Llantos
enojado 😠 Enojado
furia 😡 Furia roja
diablo 😈 Diablo sonriente
calavera 💀 Calavera
fuego 🔥 Fuego quemando
100 💯 Cien puntos
estrella ✨ Destellos estrellas
corazón ❤️ Corazón rojo
corazón negro 🖤 Corazón negro
corazón púrpura 💜 Corazón púrpura
corazón azul 💙 Corazón azul
corazón verde 💚 Corazón verde
corazón amarillo 💛 Corazón amarillo
corazón roto 💔 Corazón roto
manos juntas 🙏 Manos juntas por favor / gracias
aplauso 👏 Aplauso
pulgar arriba 👍 Pulgar arriba bien
pulgar abajo 👎 Pulgar abajo mal
puño 👊 Puño cerrado
mano levantada ✋ Mano levantada
victoria ✌️ Signo de victoria
roca 🤘 Signo de rock
fuerza 💡 Idea bombilla
cohete 🚀 Cohete despegar
computadora 💻 Laptop computadora
código 💻 Programación código
café ☕ Café caliente
cerveza 🍺 Cerveza jarra
pizza 🍕 Pizza
hamburguesa 🍔 Hamburguesa
taco 🌮 Taco
sol ☀️ Sol brillante
luna 🌙 Luna creciente
relámpago ⚡ Relámpago
lluvia 🌧️ Lluvia
check ✔️ Visto check verde
cruz ❌ Cruz roja cancelar
alerta ⚠️ Advertencia peligro
nota 🎵 Nota musical
música 🎶 Notas de música
regalo 🎁 Regalo fiesta
fiesta 🎉 Fiesta cañón
ok 👌 Signo OK
saludo 🖐️ Mano abierta"

SELECTED=$(echo "$EMOJI_LIST" | wofi --dmenu --prompt "Emojis" --lines 12 --width 450)

if [ -n "$SELECTED" ]; then
    EMOJI=$(echo "$SELECTED" | awk '{print $1}')
    echo -n "$EMOJI" | wl-copy
    
    if command -v wtype &>/dev/null; then
        wtype "$EMOJI" 2>/dev/null || true
    fi

    if command -v dunstify &>/dev/null; then
        dunstify -a "Emoji Picker" -r 9921 "😀 Emoji Copiado" "$EMOJI pegado en el portapapeles" || true
    fi
fi
