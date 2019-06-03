#!/usr/bin/env bash

# usbpmount.sh
# Copyright 2016 fsmithred@gmail.com
# License: GPL-3
# This is free software with NO WARRANTY. Use at your own risk!


TITLE="usbpmount-1.0"

#set -x


source /etc/usbpmount.conf


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
	# zenity does not know "--center"
	CENTER="--center"
		
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
	# zenity does not know "--center"
	CENTER=""
	
else

	xterm -fa monaco -fs 12 -hold -e echo "
  Neither Yad nor Zenity is installed, or the version of Yad is too old.
  $yad_zen_message"
    nogui="nogui"
fi
}

warning_dialog () {
	
	$DIALOG --$WARNING --title="$TITLE" --text="$warning_message" \
		${CENTER} --${BUTTON0}="OK"${BUTTON0NUM}
		unset warning_message
}

find_file_manager () {
	
	if [[ -n "$other_file_manager" ]] ; then
		file_manager="$other_file_manager"
	elif [[ $(type -p exo-open) ]] ; then
		file_manager="$(type -p exo-open --launch FileManager)"
	elif [[ $(type -p spacefm) ]] ; then
		file_manager=$(type -p spacefm)
	elif [[ $(type -p rox-filer) ]] ; then
		file_manager="$(type -p rox-filer)"
	elif [[ $(type -p pcmanfm) ]] ; then
		file_manager="$(type -p pcmanfm)"
	elif [[ $(type -p Thunar) ]] ; then
		file_manager="$(type -p Thunar)"
	elif [[ $(type -p nautilus) ]] ; then
		file_manager="$(type -p nautilus)"
	elif [[ $(type -p dolphin) ]] ; then
		file_manager="$(type -p dolphin)"
	elif [[ $(type -p konqueror) ]] ; then
		file_manager="$(type -p konqueror)"
	else
		echo " No suitable file manager found.
 You must set the other_file_manager variable in $configfile
 "
	fi
}

cleanup () {
	rm -f "$tmplist"
	rm -f "$usbpartslist"
}

yad_zenity_compat
find_file_manager



if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
	if [[ $allow_ssh != "yes" ]] ; then
		echo "
		This script will not let you mount
		a removable drive on a remote host.
		"
		warning_message="This script will not let you mount a removable drive on a remote host"
		warning_dialog
		exit 1
	fi
fi


# Get devices: usb, sdcard (mmc) or cdrom. What's missing?

usbdevfulllist=$(/usr/sbin/hwinfo --usb --short|grep "/dev/sd"|awk '{print $0}')
usbdevlist=$(echo "$usbdevfulllist" | awk '/dev\/sd/ { print $1 }')

sdfulllist=$(/usr/sbin/hwinfo --disk --short | awk '/dev\/mmc/ { print $0 }')
sdlist=$(echo "$sdfulllist" | awk '/dev\/mmc/ { print $1 }')

if [[ $(/usr/sbin/hwinfo --cdrom | grep  "Volume ID") ]] ; then
	cdromfulllist=$(/usr/sbin/hwinfo --cdrom --short|grep "/dev/sr"|awk '{print $0}')
	cdromlist=$(echo "$cdromfulllist" | awk '/dev\/sr/ { print $1 }')
fi

# If no devices are plugged in, exit. If one device, don't ask which to use.
if [[ -z "$usbdevlist" ]] && [[ -z "$sdlist" ]] && [[ -z "$cdromlist" ]]; then
	echo -e "\n No removable media found. (USB, SD/MMC and CD/DVD supported.)\n\n Exiting...\n"
	warning_message="No removable media found. (USB, SD/MMC and CD/DVD supported.)\n\n Exiting...\n"
	warning_dialog
	exit 1
elif [[ $(echo "$usbdevlist" | wc -l) = 1 ]] && [[ -z "$sdlist" ]] && [[ -z "$cdromlist" ]]; then
    device="$usbdevlist"
    echo -e "\n\tREMOVABLE DRIVE\n${usbdevfulllist}\n\n"
elif [[ $(echo "$sdlist" | wc -l) = 1 ]] && [[ -z "$usbdevlist" ]] && [[ -z "$cdromlist" ]]; then
	device="$sdlist"
	echo -e "\n\tREMOVABLE DRIVE\n${sdfulllist}\n\n"
elif [[ $(echo "$cdromlist" | wc -l) = 1 ]] && [[ -z "$usbdevlist" ]] && [[ -z "$sdlist" ]]; then
	device="$cdromlist"
	echo -e "\n\tREMOVABLE DRIVE\n${cdromfulllist}\n\n"
else
	device=$($DIALOG --width=400 --height=260 ${CENTER} --title="$TITLE" --list --separator="" --column="" \
	--text=$"Detected removable devices:\n\n${usbdevfulllist}\n${sdfulllist}\n${cdromfulllist}\n\nSelect the device you want to mount." ${usbdevlist} ${sdlist} ${cdromlist} \
	--${BUTTON0}="OK"${BUTTON0NUM} --${BUTTON1}="Exit"${BUTTON1NUM})

fi

	if [[ $? = 1 ]] ; then
		exit 0
	fi


# put device names and labels in a file for easy selection
tmplist=$(mktemp /tmp/tmplist.XXXX)
usbpartslist=$(mktemp /tmp/removableparts.XXXX)

# Get partitions on the selected device.
if [[ $device =~ "/dev/sd" ]] ; then
	partition_list=$(lsblk -l | grep ${device##*/}[1-9] | awk '{ print $1 }')
	devicefulllist="$usbdevfulllist"
elif [[ $device =~ "/dev/mmc" ]] ; then
	partition_list=$(lsblk -l |grep mmc | awk '/part/ { print $1 }')
	devicefulllist="$sdfulllist"
elif [[ $device =~ "/dev/sr" ]] ; then
	partition_list="${device##*/}"
	devicefulllist="$cdromfulllist"
fi
echo "$partition_list" > "$tmplist"

while read line ; do
	label=$(ls -l /dev/disk/by-label | grep $line | awk '{ print $9 }')
	if [[ "$label" =~ "x20" ]] ; then
		unset label
	fi
	if [[ -n "$label" ]] ; then
		echo "${line}_$label" >> "$usbpartslist"
	else
		echo "$line" >> "$usbpartslist"
	fi 
done < "$tmplist"


# Mount by label, else mount by device name
# If only one partition, don't ask.
if [[ $(echo "$partition_list" | wc -l) = 1 ]] ; then
	part=$(cat "$usbpartslist")
	selected_label=$(echo "$part" | awk -F"_" '{ print $2 }')
	selected_part=$(echo "$part" | awk -F"_" '{ print $1 }')
	if [[ -n "$selected_label" ]] ;	then 
		echo "Mounting $selected_label"
		pmount "$selected_part" "$selected_label" || { warning_message="pmount error" ; warning_dialog ; }
		"${file_manager}" /media/"$selected_label" &
	else
		echo "Mounting $selected_part"
		pmount "$selected_part" || { warning_message="pmount error" ; warning_dialog ; }
		"${file_manager}" /media/"$selected_part" &
	fi
else
	mountable_parts=$(cat "$usbpartslist")
	part=$($DIALOG --list ${CENTER} --title="$TITLE" --width=400 --height=230 --separator="" --column="" \
		--text="$device\nChoose the partition to mount.\n\n" $mountable_parts \
		--${BUTTON0}="OK"${BUTTON0NUM} --${BUTTON1}="Exit"${BUTTON1NUM})
	
	if [[ $? = 1 ]] ; then
		cleanup
		exit 0
	fi
	
	if [[ -z "$part" ]] ; then
		warning_message="You didn't select a partition to mount."
		warning_dialog
		cleanup
		exit 0
	fi
	
	selected_label=$(echo "$part" | awk -F"_" '{ print $2 }')
	selected_part=$(echo "$part" | awk -F"_" '{ print $1 }')

	if $(grep -q "$selected_part" /proc/mounts) ; then
		warning_message="/dev/$selected_part is already mounted."
		warning_dialog
		cleanup
		exit 0
	fi
	
	if [[ -n "$selected_label" ]] ;	then 
		echo "Mounting $selected_label"
		pmount "$selected_part" "$selected_label"  || { warning_message="pmount error $(cat /tmp/mytemp)" ; warning_dialog ; }
		"${file_manager}" /media/"$selected_label" &
	else
		echo "Mounting $selected_part"
		pmount "$selected_part" || yad --form --field "Password:H"  --separator="" --title "Passphrase" ${CENTER} --image="dialog-password" | pmount "$selected_part" || { warning_message="pmount error" ; warning_dialog ; exit 1 ; }
		"${file_manager}" /media/"$selected_part" &
	fi
fi

cleanup
exit 0
