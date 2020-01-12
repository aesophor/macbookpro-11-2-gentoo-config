#!/usr/bin/env bash
# A shell script to be run after waking up from device suspension

if [[ $EUID -ne 0 ]]; then
  echo "[!] This script must be run as root, aborting..."
  exit 1
fi

# 1. Reset MacBook Pro's internal SD Card Reader by pulling GPIO10 to low
# for 100 ms, and then set it back to high.
gpioke --set-dir 10 1 --set-level 10 0 --sleep 100 --set-level 10 1
sleep 3  # SD Card reader needs a few seconds before it shows up

# 2. Re-mount SD Card
SD_CARD_UUID=`cat /etc/apple-sd-card/uuid`
SD_CARD_NAME=`cat /etc/apple-sd-card/name`
SD_CARD_KEYFILE='/etc/apple-sd-card/luks.key'

cryptsetup luksOpen /dev/disk/by-uuid/${SD_CARD_UUID} ${SD_CARD_NAME} < ${SD_CARD_KEYFILE}
mount /dev/mapper/${SD_CARD_NAME} /mnt/${SD_CARD_NAME}
