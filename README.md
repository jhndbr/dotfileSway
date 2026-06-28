# Dotfiles

Dotfiles for a minimal **Void Linux** installation with a suckless workflow.

## Stack

| Component            | Application                                                   |
|----------------------|---------------------------------------------------------------|
| Distro               | [Void Linux](https://voidlinux.org/)                         |
| Window Manager       | [DWM](https://suckless.org/dwm) (custom, with patches)       |
| Terminal Emulator    | [Alacritty](https://alacritty.org/)                          |
| Application Launcher | [dmenu](https://tools.suckless.org/dmenu/) (custom)          |
| Status Bar           | [slstatus](https://tools.suckless.org/slstatus/) (custom)    |
| Screen Locker        | [slock](https://tools.suckless.org/slock/)                   |
| Editor               | [Neovim](https://neovim.io/) (packer + LSP + Treesitter)     |
| File Manager         | [Ranger](https://github.com/ranger/ranger)                   |
| Browser              | [Qutebrowser](https://qutebrowser.org/) / Firefox            |
| Font                 | [Source Code Pro](https://github.com/adobe-fonts/source-code-pro) |
| Image Viewer         | [nsxiv](https://github.com/nsxiv/nsxiv)                      |
| Video Player         | [mpv](https://mpv.io/)                                       |
| Password Manager     | [KeePassXC](https://keepassxc.org/)                          |
| ls alternative       | [exa](https://the.exa.website/)                              |
| sudo alternative     | [doas](https://github.com/Duncaen/OpenDoas)                  |
| Audio                | [PipeWire](https://pipewire.org/) + pipewire-pulse            |
| Task Monitor         | [bottom](https://github.com/ClementTsang/bottom)             |
| Git Diff             | [delta](https://github.com/dandavison/delta)                  |
| Multiplexer          | [tmux](https://github.com/tmux/tmux)                         |

## DWM Patches Applied

- `fullgaps` — configurable gaps between windows
- `swallow` — terminal swallows spawned GUI apps
- `scratchpad` — floating scratchpad terminal
- `movestack` — move windows in the stack
- `alwayscenter` — floating windows always open centered
- `attachbottom` — new windows attach to bottom of stack
- `statusallmons` — show status bar on all monitors

## Quick Install

```bash
git clone https://github.com/ColexDev/dotfiles ~/dotfiles
cd ~/dotfiles
bash install.sh
```

### Install Options

```
bash install.sh [OPTIONS]

  --dry-run       Show what would be done without making changes
  --no-suckless   Skip compiling dwm, dmenu, slstatus, slock
  --no-rust       Skip installing Rust via rustup
  --no-services   Skip enabling runit services
```

### Prerequisites

- Void Linux (glibc or musl)
- Internet connection
- A user in the `wheel` group
- `doas` or `sudo` available (script will try to install `opendoas` if missing)

## What the install script does

1. **Verifies** the system is Void Linux and checks connectivity
2. **Configures doas** — creates `/etc/doas.conf` if missing
3. **Installs packages** via xbps:
   - Build tools (`base-devel`, `gcc`, X11 headers)
   - Shell tools (`fzf`, `fd`, `exa`, `tmux`, `ripgrep`)
   - Audio (`pipewire`, `wireplumber`, `pipewire-pulse`, `pulsemixer`)
   - Apps (`neovim`, `alacritty`, `mpv`, `nsxiv`, `qutebrowser`, `keepassxc`, `flameshot`)
   - Fonts (`font-source-code-pro`, `noto-fonts-ttf`)
   - Laptop tools (`tlp`, `acpi`, `acpid`)
4. **Installs Rust** via rustup
5. **Compiles** dwm, dmenu, slstatus, slock from source
6. **Creates symlinks** for all config files in `$HOME`
7. **Sets permissions** on all scripts in `.scripts/`
8. **Enables runit services** (`dbus`, `NetworkManager`, `ntpd`, `tlp`, `acpid`)

## Post-Install Steps

After running `install.sh`, you need to:

1. **Enable PipeWire** — uncomment these lines in `~/.xinitrc`:
   ```sh
   pipewire &
   pipewire-pulse &
   wireplumber &
   ```

2. **Install Neovim plugins** — run `nvim`, then `:PackerSync`

3. **Configure monitor setup** — edit `~/.xinitrc` and adjust the `xrandr` line

4. **Check battery name** for slstatus:
   ```bash
   ls /sys/class/power_supply/
   ```
   If your battery isn't `BAT0`, edit `.repos/slstatus/config.def.h` and recompile:
   ```bash
   cd .repos/slstatus && make && doas make install
   ```

5. **Optional server IP** — create `~/.ip` with your server's IP:
   ```bash
   echo "export MY_SERVER_IP='1.2.3.4'" > ~/.ip
   ```

6. **Start the environment** — log out and log back into tty1. The `.bashrc` will auto-run `startx`.

## Key Bindings (DWM)

| Binding              | Action                          |
|----------------------|---------------------------------|
| `Super + d`          | Open dmenu launcher             |
| `Super + Enter`      | Open Alacritty terminal         |
| `Super + grave`      | Toggle scratchpad terminal      |
| `Super + j/k`        | Focus next/previous window      |
| `Super + Shift + j/k`| Move window in stack            |
| `Super + h/l`        | Focus next/previous monitor     |
| `Super + comma/period`| Resize master area             |
| `Super + t/f/m`      | Set layout (tile/float/monocle) |
| `Super + Shift + q`  | Kill focused client             |
| `Super + Shift + 0`  | Quit DWM                        |
| `Super + Shift + x`  | Lock screen (slock)             |
| `Super + -/=`        | Decrease/increase gaps          |
| `Super + Shift + ,/.`| Volume down/up                  |
| `Print`              | Screenshot (flameshot)          |
| `1-6`                | Switch to tag                   |
| `Super + 0`          | View all tags                   |

## Structure

```
dotfiles/
├── install.sh              ← Main installer script
├── .bashrc                 ← Bash configuration
├── .xinitrc                ← X11 startup (runs DWM)
├── .config/
│   ├── alacritty/          ← Terminal config (TOML)
│   ├── nvim/               ← Neovim config (Lua + packer)
│   ├── qutebrowser/        ← Browser config
│   └── tmux/               ← Tmux config (if present)
├── .repos/
│   ├── dwm/                ← DWM source with patches
│   ├── dmenu/              ← dmenu source with patches
│   ├── slstatus/           ← slstatus source (custom config)
│   └── slock/              ← slock source
└── .scripts/               ← Custom shell scripts
```
