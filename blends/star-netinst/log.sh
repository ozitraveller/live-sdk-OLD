#!/bin/sh

tail -100  /var/log/syslog >> slog

tail -100  /var/log/Xorg.0.log >> x0log

tail -100  /var/log/installer/syslog >> instlog

#~ tail -100  /var/log/lightdm/lightdm.log  >> llog
#~ 
#~ tail -100  /var/log/lightdm/x-0.log >> xlog
#~ 
#~ tail -100  /var/log/lightdm/seat0-greeter.log >> glog

dmesg | tail -100 >> dlog

# /usr/share/X11/xorg.cong.d

# debian (ee) failed to load module vesa (module does not exist 0)
# No drivers available
# No screens found (EE)
