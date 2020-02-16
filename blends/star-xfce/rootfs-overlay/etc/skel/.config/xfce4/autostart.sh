#!/bin/bash
## Xfce autostart.sh
## =================
## When you login to your Xfce session, this autostart script 
## will be executed to set-up your environment and launch any applications
## you want to run at startup.

/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &

pkill conky

## Condition: Start Conky after a slight delay
(sleep 3 && conky -c ~/.conkyrc) &

## star-welcome - post-installation script, will not run in a live session and
## only runs once. Safe to remove.
(sleep 6 && star-welcome --firstrun) &

## Start Thunar Daemon
thunar --daemon &

## Set keyboard settings - 250 ms delay and 25 cps (characters per second) repeat rate.
## Adjust the values according to your preferances.
xset r rate 250 25 &

## Turn on/off system beep
xset b off &

## read xpdf, xterm, uxrvt etc.. config
xrdb -merge ~/.Xresources

exit 0
