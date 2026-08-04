# ╔══════════════════════════════════════════════════════════════╗
# ║              Configuración de Zsh                            ║
# ╚══════════════════════════════════════════════════════════════╝

# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  sudo
  history
  zsh-autosuggestions
  zsh-syntax-highlighting
  colored-man-pages
  command-not-found
  extract
)

source $ZSH/oh-my-zsh.sh

# ╔══════════════════════════════════════════════════════════════╗
# ║              Variables de entorno                            ║
# ╚══════════════════════════════════════════════════════════════╝
export EDITOR="nvim"
export VISUAL="nvim"
export BROWSER="firefox"
export TERMINAL="foot"
export LANG="es_AR.UTF-8"
export LC_ALL="es_AR.UTF-8"

# XDG Base Directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# PATH
export PATH="$HOME/.local/bin:$HOME/.local/share/JetBrains/Toolbox/scripts:$PATH"

# ╔══════════════════════════════════════════════════════════════╗
# ║              History mejorado                                ║
# ╚══════════════════════════════════════════════════════════════╝
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

# ╔══════════════════════════════════════════════════════════════╗
# ║              Alias                                           ║
# ╚══════════════════════════════════════════════════════════════╝
# Navegación
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Listado mejorado
alias ls='ls --color=auto --group-directories-first'
alias ll='ls -lah'
alias la='ls -la'
alias lt='ls --tree'

# Git shortcuts
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

# Dotfiles management
alias dotfiles='cd ~/Documents/dotfileSway'
alias dots-update='bash ~/Documents/dotfileSway/update_dotfiles.sh'
alias dots-apply='bash ~/Documents/dotfileSway/setup.sh'
alias wallpaper='~/.local/bin/set-wallpaper.sh'

# Apps personales
alias tidal='cd /home/dzhon/Documents/Github/tuidal && uv run tidal_tui'
alias chatia='cd /home/dzhon/Documents/Github/chatia && uv run chatia'
alias anti='/home/dzhon/Aplicaciones/Antigravity/Antigravity-x64/antigravity'

# Sway
alias sway-reload='swaymsg reload'
alias sway-log='journalctl --user -b -u sway'

# Limpieza de caché
alias cleanup='sudo pacman -Rns $(pacman -Qdtq) 2>/dev/null; yay -Sc --noconfirm'
alias cache-clear='rm -rf ~/.cache/*'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ╔══════════════════════════════════════════════════════════════╗
# ║              Inicio de sesión (Sway en tty1)                 ║
# ╚══════════════════════════════════════════════════════════════╝
if [[ -z $DISPLAY && $(tty) == "/dev/tty1" ]]; then
    exec sway
fi
