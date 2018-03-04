#!/usr/bin/env sh
# powertop-tune.sh
# 
# auto-tune script based on powertop report.

echo 'min_power' > '/sys/class/scsi_host/host1/link_power_management_policy'
echo '1500' > '/proc/sys/vm/dirty_writeback_centisecs'
echo 'auto' > '/sys/bus/i2c/devices/i2c-5/device/power/control'
echo 'auto' > '/sys/bus/i2c/devices/i2c-0/device/power/control'
echo 'auto' > '/sys/bus/i2c/devices/i2c-2/device/power/control'
echo 'auto' > '/sys/bus/i2c/devices/i2c-4/device/power/control'
echo 'auto' > '/sys/bus/i2c/devices/i2c-1/device/power/control'
echo 'auto' > '/sys/bus/i2c/devices/i2c-3/device/power/control'
echo 'auto' > '/sys/bus/usb/devices/1-8.3/power/control'
echo 'auto' > '/sys/bus/usb/devices/2-4/power/control'
echo 'auto' > '/sys/bus/usb/devices/1-12/power/control'
echo 'auto' > '/sys/bus/pci/devices/0000:00:14.0/power/control'
echo 'auto' > '/sys/bus/pci/devices/0000:00:00.0/power/control'
echo 'auto' > '/sys/bus/pci/devices/0000:00:03.0/power/control'
echo 'auto' > '/sys/bus/pci/devices/0000:00:02.0/power/control'
echo 'auto' > '/sys/bus/pci/devices/0000:04:00.0/power/control'
echo 'auto' > '/sys/bus/pci/devices/0000:00:1f.0/power/control'
echo 'auto' > '/sys/bus/pci/devices/0000:02:00.0/power/control'
echo 'auto' > '/sys/bus/pci/devices/0000:00:16.0/power/control'
echo 'auto' > '/sys/bus/pci/devices/0000:00:1b.0/power/control'
echo 'auto' > '/sys/bus/pci/devices/0000:03:00.0/power/control'
echo 'auto' > '/sys/bus/pci/devices/0000:00:1c.0/power/control'
