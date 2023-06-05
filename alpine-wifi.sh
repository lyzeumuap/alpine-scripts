#!/usr/bin/sh
if ! [ $USER = "root" ]
then
		echo "You must be rooted"
		exit 1
fi
nmpath=/etc/NetworkManager/NetworkManager.conf
if [ -e $nmpath ] && [ -n "$(cat $nmpath | grep ifupdown)" ]
then
		echo "Stage 2"
		rc-update add networkmanager
		rc-update del networking boot
		rc-update del wpa_supplicant boot
else
		if [ -z "$1" ]
		then
				echo "Username not specified"
				exit 1
		fi
		echo "Stage 1"
		apk add networkmanager networkmanager-wifi networkmanager-tui
		rc-service networkmanager start
		rc-update add networkmanager default
		adduser $1 plugdev
		if ! [ -e $nmpath ]
		then
				touch $nmpath
		fi
		if [ -z "$(cat $nmpath)" ]
		then
				echo "[main]" > $nmpath
				echo "dhcp=internal" >> $nmpath
		fi
		echo "plugins=ifupdown,keyfile" >> $nmpath
		echo >> $nmpath
		echo "[ifupdown]" >> $nmpath
		echo "managed=true" >> $nmpath
		echo >> $nmpath
		echo "[device]" >> $nmpath
		echo "wifi.scan-rand-mac-address=yes" >> $nmpath
		echo "wifi.backend=wpa_supplicant" >> $nmpath
		rc-service networking stop
		rc-service wpa_supplicant stop
		rc-service networkmanager restart
fi
