#! /bin/sh
# 2023-05-12
# https://raspberrypi.stackexchange.com/questions/85015/what-pi-model-os-version-is-installed

# Function to print coloured headings
#  delete "tput" lines for plain output
print_head () {
 tput setaf 6
 echo $1
 tput sgr 0
}

if [ -e /etc/rpi-issue ]; then
 print_head "- Original Installation"
 cat /etc/rpi-issue | grep reference
fi

if [ -e /usr/bin/lsb_release ]; then
 print_head "- Current OS"
 lsb_release -irdc
 cat /etc/debian_version
fi
if [ ! -e /usr/share/xsessions ]; then
    print_head "X NOT installed"
fi
print_head "- Kernel"
uname -r
print_head "- Architecture"
uname -m

print_head "- Model"
cat /proc/device-tree/model && echo

print_head "- hostname"
hostname
print_head "- Network"
hostname -I

# Check status of networking
checkactive () {
if [ $(systemctl is-active $1) = 'active' ]; then
    echo $1 'active'
fi
}
checkactive 'systemd-networkd'
checkactive 'dhcpcd'
checkactive 'NetworkManager'

# Get SSID of connected WiFi (WRONG if AP!)
if [ -e /sys/class/net/wlan0 ]; then
    if [ $(systemctl is-active 'NetworkManager') = 'active' ]; then
        nmcli connection show |  awk '/wlan0/ {print $1}'
    else
        wpa_cli -i wlan0 status | grep -w ssid | awk -F'[=]' '{print $2}'
    fi
fi

sudo fdisk -l /dev/mmcblk0 | grep "Disk identifier"

CPUID=$(awk '/Serial/ {print $3}' /proc/cpuinfo | cut -c 9-)
# CPUID=$(vcgencmd otp_dump | grep 28: | cut -c4-)
echo "Serial: " $CPUID
if [ -e /opt/vc/bin/vcgencmd -o /usr/bin/vcgencmd ]; then
#   VERS=$(vcgencmd version  | grep ":")
    VERS=$(sudo vcgencmd version  | grep ":")
    print_head "- Firmware"
    echo $VERS
fi
print_head "- Created"
sudo tune2fs -l $(mount -v | awk '/ on \/ / {print $1}') | grep created