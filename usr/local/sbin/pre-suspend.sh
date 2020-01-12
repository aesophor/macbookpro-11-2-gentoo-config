#!/usr/bin/env bash
# A shell script to be run before device suspension

if [[ $EUID -ne 0 ]]; then
  echo "[!] This script must be run as root, aborting..."
  exit 1
fi

# 1. Try to unmount SD Card for the user (in case they forget to do so)
#
# WARNING: please manually unmount the SD Card before suspending your device, because
# Apple's internal SD Card Reader cannot persist throughout device suspensions
SD_CARD_NAME=`cat /etc/apple-sd-card/name`

sync; sync; umount -l /mnt/${SD_CARD_NAME}
cryptsetup luksClose ${SD_CARD_NAME}
