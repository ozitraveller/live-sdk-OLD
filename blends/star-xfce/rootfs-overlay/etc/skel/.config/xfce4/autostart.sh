#!/bin/bash
## Xfce autostart.sh
## =================
## When you login to your CrunchBang Xfce session, this autostart script 
## will be executed to set-up your environment and launch any applications
## you want to run at startup.

/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &

## Condition, only run this script under Xfce
# if [ ! "$(pidof xfwm4)" ]; then
#     exit 0
# fi

## Uncomment if you want to replace tint2 with the default Xfce panel.
#if [ "$(pidof xfce4-panel)" ]; then
#    killall xfce4-panel &
#    tint2 &
#else
#    tint2 &
#fi

pkill conky

## Detect and configure touchpad. See 'man synclient' for more info.
#if egrep -iq 'touchpad' /proc/bus/input/devices; then
#    synclient VertEdgeScroll=1 &
#    synclient TapButton1=1 &
#fi

## Condition: Start xscreensaver, if required.
# if [ ! "$(pidof xscreensaver)" ]; then
#     xscreensaver -no-splash &
# fi

# (sleep 3 && volumeicon --tray) &

## Condition: Start Conky after a slight delay
(sleep 3 && conky -c ~/.conkyrc) &
# if ! egrep -iqR 'conky' ~/.cache/sessions; then
#    (sleep 3s && conky -q) &
# fi

## The following command will set-up a keyboard map selection tool when
## running in a live session.
# cb-setxkbmap-live &

## cb-init - post-installation script, will not run in a live session and
## only runs once. Final config.
# (sleep 8s && cb-init --firstrun) &

## cb-welcome - post-installation script, will not run in a live session and
## only runs once. Safe to remove.
# (sleep 10s && cb-welcome --firstrun) &

## cb-fortune - have Statler say a little adage
# (sleep 120s && cb-fortune) &

## FIXME: there is a known issue whereby Xfce’s keyboard shortcuts do not always
## work. The following is a fix, although it may not be needed on your system;
## feel free to remove it and find out. :)
# (sleep 5s && killall xfce4-settings-helper) &

## Bad Nautilus, minimises the impact of running Nautilus under
## an Xfce session by applying some gconf settings. Safe to delete.
# cb-bad-nautilus &

## Start Thunar Daemon
thunar --daemon &

## Start mixer
# volti &

## Set keyboard settings - 250 ms delay and 25 cps (characters per second) repeat rate.
## Adjust the values according to your preferances.
xset r rate 250 25 &

## Turn on/off system beep
xset b off &

## read xpdf, xterm, uxrvt etc.. config
xrdb -merge ~/.Xresources

exit 0
