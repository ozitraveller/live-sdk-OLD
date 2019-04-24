live-sdk
========

live-sdk is simple distro build system aimed at creating liveCDs

## Requirements

live-sdk is designed to be used interactively from a terminal.
It requires the following packages to be installed in addition to the
[dependencies required for libdevuansdk](https://github.com/dyne/libdevuansdk/blob/master/README.md#requirements).

zsh cgpt xz-utils gzip gnupg2 schroot debootstrap debhelper makedev curl rsync dpkg-dev squashfs-tools \
gcc-arm-none-eabi parted kpartx qemu-user-static pinthread sudo debmirror reprepro  \
build-essential debhelper dctrl-tools bc debiandoc-sgml xsltproc docbook-xml docbook-xsl \
libbogl-dev libc6-pic libslang2-pic libnewt-pic genext2fs mklibs genisoimage dosfstools syslinux \
syslinux-utils isolinux pxelinux syslinux-common grub-efi-ia32-bin grub-common xorriso tofrodos \
mtools kmod bf-utf-source openssl win32-loader librsvg2-bin sed cpio grub-efi-amd64-bin liblz4-1 \
debmirror rpl e2fslibs-dev nasm gcc-multilib libc6-dev-i386 nasm uuid-dev dialog

`sudo` permissions are required for the user that is running the build.

Find documentation inside the docs directory of libdevuansdk. The 
following packages need to be installed to compile the documentation:

python-markdown ruby-ronn


### Devuan

```
xorriso squashfs-tools live-boot syslinux-common
```

### Gentoo

```
dev-libs/libisoburn sys-fs/squashfs-tools sys-boot/syslinux
```

## Initial setup

After cloning the live-sdk git repository, enter it and issue:

```
git submodule update --init
```

### Updating

To update live-sdk, go to the root dir of the git repo and issue:

```
git pull && git submodule update --init --recursive
```

## Quick start

Edit the `config` file to match your needs. Sensible defaults are
already there. Then run zsh. To avoid issues, it's best to start a
vanilla version, without preloaded config files so it doesn't cause
issues with libdevuansdk/live-sdk functions.

```
; zsh -f -c 'source sdk'
```

Now is the time you choose the OS, architecture, and (optionally) a
blend you want to build the image for.

### Currently supported distros

* `devuan`

```
; load devuan amd64
```

Once initialized, you can run the helper command:

```
; build_iso_dist
```

The image will automatically be build for you. Once finished, you will be
able to find it in the `dist/` directory in live-sdk's root.

For more info, see the `doc/` directory.

## Acknowledgments

Devuan's SDK was originally conceived during a period of residency at the
Schumacher college in Dartington, UK. Greatly inspired by the laborious and
mindful atmosphere of its wonderful premises.

The Devuan SDK is Copyright (c) 2015-2017 by the Dyne.org Foundation

Devuan SDK components were designed, and are written and maintained by:

- Ivan J. <parazyd@dyne.org>
- Denis Roio <jaromil@dyne.org>
- Enzo Nicosia <katolaz@freaknet.org>

This source code is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option)
any later version.

This software is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along
with this source code. If not, see <http://www.gnu.org/licenses/>.


## How to build a blend

In a terminal: 

$ cd ~/live-sdk

Clean the build environment: log files in lve-sdk folder, and any files in log, tmp, dist folders
$ clean

$ sudo su

root># zsh -f

root># source sdk

root># load

There are dialogs here: (use the spacebar to select an item, and arrow keys to move up/down)

1. Devuan
2. Ascii
3. Stable
4. diy-jwm
5. main, contrib, non-free

Then at the # prompt do either:

root># build_iso_dist

or

root># build_iso_dist 2>&1 | tee "Build - $(date "+%d.%m.%Y - %H:%M").log"

This part creates a log file in the live-sdk folder (just dumps everything from the terminal)

2>&1 | tee "Build - $(date "+%d.%m.%Y - %H:%M").log"


# Cleaning the build folders (dist, log, tmp)

In a terminal: 

$ cd ~/live-sdk

$ clean



