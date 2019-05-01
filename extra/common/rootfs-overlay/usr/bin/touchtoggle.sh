#!/bin/sh

curstate=`synclient | grep -i TouchpadOff | sed -e"s/.*= //"`
if test "$curstate" = "1"; then
        synclient TouchpadOff=0
else
        synclient TouchpadOff=1
fi
