#!/usr/bin/env python3
import os
import subprocess
import sys

dict_bars = [" ", "▂", "▃", "▄", "▅", "▆", "▇", "█"]

config_content = """[general]
bars = 8
framerate = 30
autosens = 1
noise_reduction = 0.77

[input]
method = pulse
source = auto

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
bar_delimiter = 59
"""

conf_file = "/tmp/waybar_cava.conf"
with open(conf_file, "w") as f:
    f.write(config_content)

proc = subprocess.Popen(
    ["cava", "-p", conf_file],
    stdout=subprocess.PIPE,
    stderr=subprocess.DEVNULL,
    text=True,
    bufsize=1
)

try:
    for line in proc.stdout:
        line = line.strip()
        if not line:
            continue
        vals = [x for x in line.split(";") if x.isdigit()]
        if not vals:
            continue
        
        is_silent = all(v == "0" for v in vals)
        if is_silent:
            # Baseline visualizer icon when silent
            bars = " ▂ ▂ ▂ "
            css_class = "silent"
            tooltip = "Visualizador CAVA (En espera)"
        else:
            bars = "".join(dict_bars[min(int(v), 7)] for v in vals)
            css_class = "active"
            tooltip = "Visualizador CAVA (Reproduciendo)"

        output = f'{{"text": "{bars}", "tooltip": "{tooltip}", "class": "{css_class}"}}\n'
        sys.stdout.write(output)
        sys.stdout.flush()
except (KeyboardInterrupt, BrokenPipeError):
    pass
finally:
    proc.terminate()
