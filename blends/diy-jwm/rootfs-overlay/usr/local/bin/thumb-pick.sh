#!/usr/bin/env bash
#
# thumb-pick.sh
# Copyright 2016 fsmithred@gmail.com
# License: GPL-3
# This is free software with NO WARRANTY. Use at your own risk!



#set -x
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
#  SESSION_TYPE=remote/ssh
	echo "
	This script will not let you mount
	a usb drive on a remote host.
	"
	exit 1
fi


# Get devices: usb, sdcard (mmc) or cdrom. What's missing?

usbdevlist=$(/usr/sbin/hwinfo --usb --short | awk '/dev\/sd/ {print $1}')
usbdevfulllist=$(/usr/sbin/hwinfo --usb --short | awk '/dev\/sd/ {print $0}')

sdfulllist=$(/usr/sbin/hwinfo --disk --short | awk '/dev\/mmc/ { print $0 }')
sdlist=$(echo "$sdfulllist" | awk '/dev\/mmc/ { print $1 }')

if [[ $(/usr/sbin/hwinfo --cdrom | grep  "Volume ID") ]] ; then
	cdromfulllist=$(/usr/sbin/hwinfo --cdrom --short|grep "/dev/sr"|awk '{print $0}')
	cdromlist=$(echo "$cdromfulllist" | awk '/dev\/sr/ { print $1 }')
fi


# If no devices are plugged in, exit. If one device, don't ask which to use.
if [[ -z "$usbdevlist" ]] && [[ -z "$sdlist" ]] && [[ -z "$cdromlist" ]]; then
	echo -e "\n No removable media found. (USB, SD/MMC and CD/DVD supported.)\n\n Exiting...\n"
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
	echo -e "\n\tLIST OF REMOVABLE DRIVES\n${usbdevfulllist}\n${sdfulllist}\n${cdromfulllist}\n\nSelect a device:"
	select opt in $usbdevlist $sdlist $cdromlist ; do
		device=$(echo "$opt" | awk '{ print $1 }')
		break
	done
fi


# put device names and labels in a file for easy selection.
usbpartslist=$(mktemp /tmp/removableparts.XXXX)

# Get partitions on the selected device.
if [[ $device =~ "/dev/sd" ]] ; then
	partition_list=$(lsblk -l | grep ${device##*/}[1-9] | awk '{ print $1 }')
elif [[ $device =~ "/dev/mmc" ]] ; then
	partition_list=$(lsblk -l |grep mmc | awk '/part/ { print $1 }')
elif [[ $device =~ "/dev/sr" ]] ; then
	partition_list="${device##*/}"
fi

printf '%s\n' "$partition_list" | while IFS= read -r line ; do
	label=$(ls -l /dev/disk/by-label | grep $line | awk '{ print $9 }')
	if [[ "$label" =~ "x20" ]] ; then
		unset label
	fi
	if [[ -n "$label" ]] ; then
		echo "${line}_$label" >> "$usbpartslist"
	else 
	echo "$line" >> "$usbpartslist"
	fi 
done


# Mount by label, else mount by name
# If only one partition, don't ask.
if [[ $(echo "$partition_list" | wc -l) = 1 ]] ; then
	part=$(cat "$usbpartslist")
	selected_label=$(echo "$part" | awk -F"_" '{ print $2 }')
	selected_part=$(echo "$part" | awk -F"_" '{ print $1 }')
	if [[ -n "$selected_label" ]] ;	then 
		echo "Mounting $selected_label"
		pmount "$selected_part" "$selected_label"
	else
		echo "Mounting $selected_part"
		pmount "$selected_part"
	fi	
else
	echo "Select a partition to mount:"
	select part in $(cat "$usbpartslist") ; do
		selected_label=$(echo "$part" | awk -F"_" '{ print $2 }')
		selected_part=$(echo "$part" | awk -F"_" '{ print $1 }')
		if [[ -n "$selected_label" ]] ;	then 
			echo "Mounting $selected_label"
			pmount "$selected_part" "$selected_label"
		else
			echo "Mounting $selected_part"
			pmount "$selected_part"
		fi
		break
	done
fi

rm -f "$usbpartslist"

exit 0

