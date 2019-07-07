#!/bin/bash

# Options
# -------
# -i   makes dmenu match menu entries case insensitively.
# -b   defines that dmenu appears at the bottom.
# -l   <lines> activates vertical list mode. The given number of lines will be displayed. Window height will get adjusted.
# -fn  <font> defines the font.
# -nb  <color> defines the normal background color (#RGB, #RRGGBB, and color names are supported).
# -nf  <color> defines the normal foreground color (#RGB, #RRGGBB, and color names are supported).
# -p   <prompt> defines a prompt to be displayed before the input area.
# -sb  <color> defines the selected background color (#RGB, #RRGGBB, and color names are supported).
# -sf  <color> defines the selected foreground color (#RGB, #RRGGBB, and color names are supported).
# -v   prints version information to standard output, then exits.

# http://linux.die.net/man/1/dmenu

# dmenu_run -b -i -nb '#151617' -nf '#d8d8d8' -sb '#d8d8d8' -sf '#151617'

# dmenu_run -fn 10x20 -nf '#398ee7' -nb black -sf black -sb white -l 20
# gruvbox
dmenu_run -fn 10x20 -nf '#1e1e1e' -sf '#1e1e1e' -sb '#f4800d' -nf '#F4800d' -l 20
