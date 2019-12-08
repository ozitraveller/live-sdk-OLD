#!/bin/sh

#~ 1. sudo apt-get install linux-headers-amd64 linux-headers-4.9.0-9-amd64 build-essential
#~ 2. reboot
#~ 3. sudo apt-get install dkms
#~ 4. cd /media/cdrom0
#~ 5. sudo sh ./VBoxLinuxAdditions.run

# Manual mount and install
# http://blog.oracle48.nl/installing-virtualbox-guest-additions-using-the-command-line/
#-----------------------------
#~ 2. Mount the DVD drive on Guest OS
#~ [guest] # mkdir /mnt/dvd
#~ [guest] # mount -t iso9660 -o ro /dev/dvd /mnt/dvd
#~ 3. Install VBoxLinuxAdditions
#~ [guest] # cd /mnt/dvd
#~ [guest] # ./VBoxLinuxAdditions.run
#~ If you encounter errors here, see: ‘0. Common Errors‘.

#~ 4. Done? Unmount and remove
#~ [guest] # umount /dev/dvd


NOTE: 
apt-get install linux-headers-amd64 linux-headers-4.9.0-9-amd64 build-essential
# reboot
sudo apt-get install dkms



mkdir ~/host
sudo su

mkdir /mnt/dvd
# insert guest-additions cd
mount -t iso9660 -o ro /dev/dvd /mnt/dvd
cd /mnt/dvd
./VBoxLinuxAdditions.run
cd ../..
umount /mnt/dvd




exit 0
