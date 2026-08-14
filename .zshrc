# ╔══════════════════════════════════════════════════════════════╗
# ║        Configuración Minimalista & Rápida de Zsh             ║
# ║        Zsh + Starship + Autosuggestions + FZF                ║
# ╚══════════════════════════════════════════════════════════════╝

# ── 1. Variables de entorno ────────────────────────────────────
export EDITOR="nano"
export VISUAL="nano"
export BROWSER="firefox"
export TERMINAL="foot"
export FILEMANAGER="yazi"
export LANG="es_AR.UTF-8"
export LC_ALL="es_AR.UTF-8"

# XDG Base Directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# PATH
export PATH="$HOME/.local/bin:$HOME/.local/share/JetBrains/Toolbox/scripts:$PATH"

# ── 2. Autocompletado nativo ultra rápido (Caché 24h) ──────────
autoload -Uz compinit
mkdir -p "$XDG_CACHE_HOME/zsh"
if [[ -n "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"(#qN.mh+24) ]]; then
    compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
else
    compinit -C -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
fi

# Opciones de autocompletado interactivo
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ── 3. Historial Optimizado ────────────────────────────────────
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY

# ── 4. Plugins (Autosuggestions, Syntax Highlighting, FZF) ─────
# Autosuggestions (sugerencia de comandos en gris basada en el historial)
if [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [ -f ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Syntax Highlighting (resaltado de comandos: verde ok, rojo error)
if [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ -f ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Keybindings de FZF (Ctrl+R para búsqueda de historial flotante)
if [ -f /usr/share/fzf/key-bindings.zsh ]; then
    source /usr/share/fzf/key-bindings.zsh
    source /usr/share/fzf/completion.zsh 2>/dev/null || true
fi

# Zoxide (cd inteligente)
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi

# ── 5. Starship Prompt (Inicio Instantáneo) ────────────────────
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

# ── 6. Alias ───────────────────────────────────────────────────
# Navegación
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Listado (eza si está disponible, sino ls)
if command -v eza &>/dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -lh --icons --group-directories-first'
    alias la='eza -lah --icons --group-directories-first'
    alias lt='eza --tree --icons'
else
    alias ls='ls --color=auto --group-directories-first'
    alias ll='ls -lah'
    alias la='ls -la'
fi

# Git Shortcuts
alias gs='git status'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'
alias gd='git diff'
alias gl='git log --oneline -20'
alias gco='git checkout'
alias gb='git branch'

# Sistema
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -sh'
alias free='free -h'
alias ip='ip -c'
alias reload='source ~/.zshrc && echo "✅ .zshrc recargado"'

# Dotfiles Management
alias dotfiles='cd ~/Documents/dotfileSway'
alias dots-apply='bash ~/Documents/dotfileSway/setup.sh'
alias wallpaper='~/.local/bin/set-wallpaper.sh'
alias fm='yazi'
alias files='yazi'
alias y='yazi'

# Ouch — Compresión y Descompresión Inteligente
alias extract='ouch decompress'
alias compress='ouch compress'
alias lszip='ouch list'

# Wrapper para descomprimir rápido sin complicaciones: x 'archivo(1).tar.gz'
x() {
    if [ $# -eq 0 ]; then
        echo "Uso: x <archivo(s)>"
        return 1
    fi
    ouch decompress "$@"
}

# Aplicaciones Personales
alias tidal='cd ~/Documentos/Github/tuidal && uv run tidal_tui'
alias chatia='cd ~/Documentos/Github/chatia && uv run chatia'
alias anti='~/Aplicaciones/Antigravity/Antigravity-x64/antigravity'

# Sway
alias sway-reload='swaymsg reload'
alias sway-log='journalctl --user -b -u sway'

# Limpieza
alias cleanup='sudo pacman -Rns $(pacman -Qdtq) 2>/dev/null; yay -Sc --noconfirm'
alias cache-clear='rm -rf ~/.cache/*'

# ── 7. Inicio de Sesión (Sway en tty1) ─────────────────────────
if [[ -z $DISPLAY && $(tty) == "/dev/tty1" ]]; then
    exec sway
fi
