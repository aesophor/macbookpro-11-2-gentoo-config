## Synopsis
This is my personal gentoo configuration on my MacbookPro 11,2. Feel free to use it.

* Model: `MacbookPro 11,2 (Late 2014)`
* Kernel: `4.9.76-gentoo-r1`
* Disk Encryption: `Yes (LUKS on LVM)`
* Wireless: `broadcom-sta`
* Graphics: `xf86-video-intel`
* Backlight: `light, kbdlight`
* Audio: `amixer`


## Disclaimer
The guide is provided "as is" without warranty of any kind, either expressed or implied, including, but not limited to, the implied warranties of correctness and relevance to a particular subject. The entire risk as to the quality and accuracy of the content is with you. Should the content prove substandard, you assume the cost of all necessary servicing, repair, or correction.


## Base System Installation
### 1. Preparing Installation Media
Download [the latest boot image](https://www.gentoo.org/downloads/) from www.gentoo.org. I recommend that you download the Hybrid ISO (LiveDVD) - 2GiB and boot from text mode. 
After downloading the iso, insert a usb thumb drive and use `lsblk` to confirm the device path. Then run:
```
$ dd if=/path/to/the/iso of=/dev/sdc bs=4M
```

The above command will "write" the iso to your external hard drive from which we will be able to boot later.
Generally speaking, `/dev/sda` should be the built in hard drive, while `/dev/sd{b..z}` should be external storages.


### 2. Partitioning Hard Drive
Note that throughout this guide, we will be using `LUKS on LVM`. If you prefer other partitioning schemes, please refer to other guides.
Use `cfdisk`, `cgdisk`, `fdisk` or whatever tools you like to partition the drive. Then run:
```
# cryptsetup --verbose --cipher aes-xts-plain64 --key-size 256 --hash sha1 --iter-time 1000 --use-random luksFormat /dev/sda2
# cryptsetup luksOpen /dev/sda2 lvm
# pvcreate /dev/mapper/lvm
# vgcreate vgcrypt /dev/mapper/lvm
# lvcreate --size 20G --name root vgcrypt
# lvcreate --extents +100%FREE --name home vgcrypt

# mkfs.ext4 /dev/mapper/vgcrypt-root
# mkfs.ext4 /dev/mapper/vgcrypt-home
```

After all these steps, my `lsblk` output is as follow:
```
$ lsblk
NAME                       MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
sda                          8:0    0 233.8G  0 disk
├─sda1                       8:1    0   200M  0 part                --> EFI Partition
├─sda2                       8:2    0 232.9G  0 part                --> Our Daily-use Partition
│ └─root_sda2-vgcrypt-root 254:0    0 232.9G  0 crypt
│   ├─vgcrypt-root         254:1    0    20G  0 lvm   /
│   └─vgcrypt-home         254:2    0 212.9G  0 lvm   /home
└─sda3                       8:3    0 619.9M  0 part                --> Recovery HD
sdb                          8:16   1 120.9G  0 disk
└─sdb1                       8:17   1 120.9G  0 part                --> Live USB
```


### 3. Getting Internet Connection
I recommend using Ethernet here. Wireless Connection can somehow be tricky to configure (we will cover this later).
Plugin a ethernet adapter with cable attached, and run:
```
# dhcpcd
```

If for whatever reason the connection cannot be established, run `pkill dhcpcd` and try again.
Use `ping -c 3 www.google.com` to check if the connection is working.


### 4. Mounting Partitions

| Partition | Mount Point |
| --- | --- |
| /dev/mapper/vgcrypt-root | /mnt/gentoo |
| /dev/mapper/vgcrypt-home | /mnt/gentoo/home |

Different from Arch Linux, we will mount /dev/mapper/vgcrypt-root on /mnt/gentoo. Run:
```
# mount /dev/mapper/vgcrypt-root /mnt/gentoo
# mkdir -p /mnt/gentoo/home
# mount /dev/mapper/vgcrypt-home /mnt/gentoo/home
```


### 5. Base Installation
cd into `/mnt/gentoo` and retrieve a stage3 tarball. Then extract it:
```
# cd /mnt/gentoo
# wget https://gentoo.osuosl.org/releases/amd64/autobuilds/current-stage3-amd64-systemd/stage3-amd64-systemd-20180302.tar.bz2
# tar xvjpf stage3-*.tar.bz2 --xattrs
# rm stage3-*
```

We also need to download and unpack fresh portage tree:
```
wget http://distfiles.gentoo.org/releases/snapshots/current/portage-latest.tar.xz
tar xvf portage-latest.* -C /mnt/gentoo/usr
rm portage-latest.*
```


### 6. Chrooting into the New System
First copy /etc/resolv.conf to /mnt/gentoo/etc/resolv.conf
```
# cp -L /etc/resolv.conf /mnt/gentoo/etc/resolv.conf
```

Then mount kernel resources
```
# mount -t proc proc /mnt/gentoo/proc
# mount --rbind /sys /mnt/gentoo/sys
# mount --rbind /dev /mnt/gentoo/dev
# mount --make-rslave /mnt/gentoo/sys
# mount --make-rslave /mnt/gentoo/dev
```

Now we are ready to chroot into the new system
```
# chroot /mnt/gentoo /bin/bash
# env-update && source /etc/profile
```


### 7. Automatically Mounting Partitions
Edit `/etc/fstab`
```
# nano /etc/fstab

/dev/mapper/vgcrypt-root	/	ext4		rw,relatime,data=ordered,discard	0 1
/dev/mapper/vgcrypt-home	/home	ext4		rw,relatime,data=ordered,discard	0 2
```

### 8. Configuring the Compiler
Edit `/etc/portage/make.conf`. The following is the content of mine.
```
# nano /etc/portage/make.conf

CFLAGS="-march=native -O2 -pipe"
CXXFLAGS="${CFLAGS}"
CHOST="x86_64-pc-linux-gnu"
MAKEOPTS="-j9"
EMERGE_DEFAULT_OPTS="--jobs 8"

ACCEPT_LICENSE="*"
ACCEPT_KEYWORDS="amd64"

INPUT_DEVICES="evdev mtrack"
VIDEO_CARDS="intel i965"

FEATURES="binpkg-logs clean-logs split-log"
USE="cryptsetup systemd branding -bindist -consolekit truetype unicode"
CPU_FLAGS_X86="aes avx avx2 f16c fma3 mmx mmxext pclmul popcnt sse sse2 sse3 sse4_1 sse4_2 ssse3"

PORTDIR="/usr/portage"
DISTDIR="${PORTDIR}/distfiles"
PKGDIR="${PORTDIR}/packages"

GENTOO_MIRRORS="http://ftp.twaren.net/Linux/Gentoo/"
```

Note that it's `-O2`, not `-02`.

`MAKEOPTS="-j9"` to compile in 9 threads to better utilize multicore CPU and speedup compilation. 
Since we have an 8-core cpu, so core_number+1 = 9.


### 9. Selecting a Profile
In my case, I'm using `KDE + i3-gaps` and `systemd`.
So I chose `[20]  default/linux/amd64/17.0/desktop/plasma/systemd (stable) *`
```
# emerge-webrsync
# eselect profile list
# eselect profile set <profile_id>
```

Now install the packages based on the profile you choose. This will take a while.
```
# emerge --ask --update --deep --newuse @world
```

### 10. Configuring Timezone
```
# ln -sf /usr/share/zoneinfo/Asia/Taiwan /etc/localtime
# hwclock --systohc --utc
```


### 11. Configuring Locale
Uncomment the locales you are going to use in /etc/locale.gen
```
# locale-gen
# eselect locale list
# eselect locale set X (choose one)
```


## Compiling Kernel
### 12. Emerge Kernel Source
I use `genkernel` to configure the kernel with ease.
```
# emerge --ask sys-kernel/gentoo-sources
# echo "sys-kernel/genkernel-next cryptsetup" >> /etc/portage/package.use/genkernel-next
# emerge -av sys-kernel/genkernel-next sys-fs/cryptsetup sys-fs/lvm2
```

Check /etc/genkernel.conf and set the following options.
```
MENU_CONFIG="yes"
MRPROPER="no"
MAKEOPTS="-j9"
LVM="yes"
LUKS="yes"
DMRAID="no"
BUSY_BOX="yes"
UDEV="yes"
MDADM="no"
FIRMWARE="no"
```

**IMPORTANT** MOUNT `/dev/sda1` ON /BOOT BEFORE COMPILING THE KERNEL!
```
# mount /dev/sda1 /boot
# genkernel all
```

You can use my kernel config by copying [it](https://raw.githubusercontent.com/aesophor/MacbookPro11-2-gentoo-config/master/usr/src/linux/.config) into /usr/src/linux/.config

Or if you want to manually configure everything, please refer to the [official wiki](https://wiki.gentoo.org/wiki/Apple_Macbook_Pro_Retina_(early_2013)#Kernel).

* Wireless Driver:    
(placeholder)

* Selecting a profile:    
(placeholder)


