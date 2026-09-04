# ╔══════════════════════════════════════════════════════════════╗
# ║        Configuración Minimalista & Rápida de Zsh             ║
# ║        Zsh + Starship + Autosuggestions + FZF + Eza          ║
# ╚══════════════════════════════════════════════════════════════╝

# ── 1. Variables de entorno ────────────────────────────────────
export EDITOR="nano"
export VISUAL="nano"
export BROWSER="firefox"
export TERMINAL="foot"
export FILEMANAGER="thunar"
export LANG="es_AR.UTF-8"
export LC_ALL="es_AR.UTF-8"

# XDG Base Directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"
export STARSHIP_CONFIG="$HOME/.config/starship.toml"

# PATH
export PATH="$HOME/.local/bin:$HOME/.local/share/JetBrains/Toolbox/scripts:$PATH"

# ── 2. Autocompletado nativo ultra rápido (Caché 24h) ──────────
setopt EXTENDED_GLOB
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

# ── 4. Atajos de Teclado & Navegación ──────────────────────────
bindkey -e # Modo Emacs estándar
bindkey '^[[A' history-beginning-search-backward # Flecha Arriba: busca lo escrito en el historial
bindkey '^[[B' history-beginning-search-forward  # Flecha Abajo: busca hacia adelante
bindkey '^[[H' beginning-of-line                # Inicio
bindkey '^[[F' end-of-line                      # Fin
bindkey '^[[3~' delete-char                     # Supr (Delete)
bindkey '^[[1;5C' forward-word                  # Ctrl + Flecha Derecha
bindkey '^[[1;5D' backward-word                 # Ctrl + Flecha Izquierda
bindkey '^H' backward-kill-word                 # Ctrl + Backspace
bindkey '^?' backward-delete-char               # Backspace

# ── 5. Plugins (Autosuggestions, Syntax Highlighting, FZF) ─────
# Autosuggestions (sugerencia de comandos en gris basada en el historial)
if [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [ -f ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#6c7086"

# Syntax Highlighting (resaltado de comandos)
if [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ -f ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Keybindings e integración de FZF
if [ -f /usr/share/fzf/key-bindings.zsh ]; then
    source /usr/share/fzf/key-bindings.zsh
    source /usr/share/fzf/completion.zsh 2>/dev/null || true
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info"
    if command -v bat &>/dev/null; then
        export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :300 {} 2>/dev/null || eza --tree --icons -L 2 {} 2>/dev/null || cat {}'"
    fi
fi

# Zoxide (cd inteligente)
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi

# ── 6. Starship Prompt (Inicio Instantáneo) ────────────────────
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

# ── 7. Alias Útiles ────────────────────────────────────────────
# Navegación
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Listado moderno con eza (con iconos y directorios primero)
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

# Bat (cat moderno con sintaxis)
if command -v bat &>/dev/null; then
    alias cat='bat --paging=never --style=plain'
    alias preview='bat --style=numbers --color=always'
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

# Sistema & Hardware
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -sh'
alias free='free -h'
alias ip='ip -c'
alias reload='source ~/.zshrc && echo "✅ .zshrc recargado"'

# Pacman / Yay
alias install='sudo pacman -S'
alias update='sudo pacman -Syu'
alias remove='sudo pacman -Rns'
alias search='pacman -Ss'
alias orphans='sudo pacman -Rns $(pacman -Qtdq) 2>/dev/null || echo "No hay paquetes huérfanos"'

# Dotfiles & Scripts
alias dotfiles='cd ~/Documentos/Github/dotfileSway'
alias dots-apply='bash ~/Documentos/Github/dotfileSway/setup.sh'
alias wallpaper='~/.local/bin/set-wallpaper.sh'
alias fm='thunar'
alias files='thunar'
alias t='thunar'
alias zed='zeditor'

# Ouch — Compresión y Descompresión Inteligente
alias extract='ouch decompress'
alias compress='ouch compress'
alias lszip='ouch list'

# Wrapper para descomprimir rápido: x archivo.tar.gz
x() {
    if [ $# -eq 0 ]; then
        echo "Uso: x <archivo(s)>"
        return 1
    fi
    if command -v ouch &>/dev/null; then
        ouch decompress "$@"
    else
        echo "Ouch no instalado. Usa tar/unzip según corresponda."
    fi
}

# Aplicaciones Personales
alias tidal='cd ~/Documentos/Github/tuidal && uv run tidal_tui'
alias chatia='cd ~/Documentos/Github/chatia && uv run chatia'
alias anti='~/Aplicaciones/Antigravity-x64/antigravity'

# Sway
alias sway-reload='swaymsg reload'
alias sway-log='journalctl --user -b -u sway'
alias sway-error='cat ~/.sway_error.log | grep -E "(ERROR|WARN)" | tail -n 40'
alias sway-log-full='cat ~/.sway_error.log'

# Limpieza
alias cleanup='sudo pacman -Rns $(pacman -Qdtq) 2>/dev/null; yay -Sc --noconfirm 2>/dev/null'
alias cache-clear='rm -rf ~/.cache/*'
