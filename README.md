# MacbookPro11,2-gentoo-config

## Synopsis
This is my personal gentoo configuration on my MacbookPro 11,2. Feel free to use it.

**Details**
* Model: `MacbookPro 11,2 (Late 2014)`
* Kernel: `4.9.76-gentoo-r1`
* Disk Encryption: `Yes (LUKS on LVM)`
* Wireless: `broadcom-sta`
* Graphics: `xf86-video-intel`
* Backlight: `light, kbdlight`
* Audio: `amixer`

## Base System Installation
* My `lsblk` output:

`sda1` is the EFI Partition. `sda2` is for daily use. `sda3` is the RecoveryHD.

```
NAME                       MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
sda                          8:0    0 233.8G  0 disk
├─sda1                       8:1    0   200M  0 part
├─sda2                       8:2    0 232.9G  0 part
│ └─root_sda2-vgcrypt-root 254:0    0 232.9G  0 crypt
│   ├─vgcrypt-root         254:1    0    20G  0 lvm   /
│   └─vgcrypt-home         254:2    0 212.9G  0 lvm   /home
└─sda3                       8:3    0 619.9M  0 part
sdb                          8:16   1 120.9G  0 disk
└─sdb1                       8:17   1 120.9G  0 part
```


## Post-Installation
* Wireless Driver:
(placeholder)

* Selecting a profile:
(placeholder)


