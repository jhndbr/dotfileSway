#!/bin/sh

# Starts status bar
slstatus &

# Allows for faster output when holding down a key
xset r rate 225 75 &

# Sets default browser
xdg-settings set default-web-browser firefox.desktop &

# Sets the sensitivity of my mouse (Logitech MX Master 2S)
# Uncomment and adjust if needed for your specific mouse
# xinput --set-prop "pointer:Logitech MX Master 2S" "Coordinate Transformation Matrix" 0.5 0 0 0 0.5 0 0 0 1 &

# Hides mouse cursor when idle
xbanish -t 2 &

# Sync time (using ntpdate; consider enabling ntpd service instead)
doas ntpdate ntp.ubuntu.com &

# Enable PipeWire audio (pipewire-pulse provides PulseAudio compatibility)
# Uncomment if you use PipeWire:
# pipewire &
# pipewire-pulse &
# wireplumber &

# Enable PulseAudio equalizer if installed
# Uncomment if you use PulseAudio + pulseaudio-equalizer:
# pulseaudio-equalizer enable &

# Multi-monitor setup — customize xrandr for your setup if needed:
# xrandr --output DP-4 --primary --mode 1920x1080 --pos 0x369 --rotate normal \
#        --output DP-2 --mode 1920x1080 --pos 1920x0 --rotate right &

# Launches DWM
exec dwm
