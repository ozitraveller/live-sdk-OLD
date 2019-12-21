#!/usr/bin/env bash

# usb-unmount.sh
# Copyright 2016 fsmithred@gmail.com
# License: GPL-3
# This is free software with NO WARRANTY. Use at your own risk!


TITLE="usb-unmount.sh"


yad_zenity_compat () {
# if yad is installed, use in preference
if [[ -f /usr/bin/yad ]]; then
	yadversion=$(yad --version | cut -d. -f2)
	if (( $yadversion >= 17 )); then

	DIALOG="yad"
	INFO="image=gtk-dialog-info"
	QUESTION="image=gtk-dialog-question"
	WARNING="image=gtk-dialog-warning"
	ERROR="image=gtk-dialog-error"
	RADIOLIST=""

	#buttons
	BUTTON0="button"
	BUTTON1="button"
	BUTTON0NUM=":0"
	BUTTON1NUM=":1"
	# Use these for file-selection window.
	OKBUTTON="--button=OK:0"
	QUITBUTTON="--button=Quit:1"
	EXITBUTTON="--button=Exit:1"

	fi
#cancel button always returns 1 as $?
#ok button always returns 0 as $?
#ok is default (highlighted)
#buttons in yad dialog window may show reversed from zenity window, e.g.
#yad: ok -- cancel (0 -- 1)
#zenity: cancel -- ok (1 -- 0)

elif [[ -f /usr/bin/zenity ]]; then

	# use zenity
	
	DIALOG="zenity"
	INFO="info"
	QUESTION="question"
	WARNING="warning"
	ERROR="error"
	# zenity requires --radiolist on lists to show selected partition.
	RADIOLIST="--radiolist"
	
	#buttons
	BUTTON0="ok-label"
	BUTTON1="cancel-label"
	BUTTON0NUM=""
	BUTTON1NUM=""
	# Zenity doesn't support custom buttons in file-selection window.
	OKBUTTON=""
	QUITBUTTON=""
	EXITBUTTON=""

else

	xterm -fa monaco -fs 12 -hold -e echo "
  Neither Yad nor Zenity is installed, or the version of Yad is too old.
  $yad_zen_message"
    nogui="nogui"
fi
}


warning_dialog () {
	
	$DIALOG --$WARNING --title="$TITLE" --text="$warning_message" \
		--${BUTTON0}="OK"${BUTTON0NUM}
		unset warning_message
}

yad_zenity_compat


if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
#  SESSION_TYPE=remote/ssh
	echo "
	This script will not let you unmount
	a removable drive on a remote host.
	"
	warning_message="This script will not let you unmount a removable drive on a remote host"
	warning_dialog
	exit 1
fi


select_vol () {
	
	media_mounts=$(grep "/media/" /proc/mounts | awk '{ print $2 }')
	
	if [ -n "$media_mounts" ] ; then
		selection=$($DIALOG --list --center --title="$TITLE" --width=400 --height=200 --separator="" --column="" \
			--text="Select a volume to unmount. (One at a time.)\n\n" $media_mounts \
			--${BUTTON0}="OK"${BUTTON0NUM} --${BUTTON1}="Cancel"${BUTTON1NUM})
	
			if [[ $? = 1 ]] ; then
				exit 0
			fi
		unmount_vol
	else
		"$DIALOG" --info --title="$TITLE" --width=250 --text="Nothing mounted under /media." "$OKBUTTON"
		exit 0
		
	fi
}

unmount_vol () {
	
	pumount "$selection" || { warning_message="pumount error" ; warning_dialog ; }
	select_vol

}

select_vol

