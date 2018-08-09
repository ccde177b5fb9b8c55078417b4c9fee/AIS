#!/bin/bash
#
#Minor install script for chrooted environment

set_time() {
	local region=${1}
	local city=${2}
	ln -sf /usr/share/zoneinfo/${region}/${city} /etc/localtime
	hwclock --systohc
}
setup_systemd_boot() {
	local disk = ${1}
	#Bootloader installation. Deafault bootloader is systemd-boot.
	bootctl --path=/boot install

	#Bootloader configuration
	cp /usr/share/systemd/bootctl/* /boot/loader/
	cd /boot/loader/
	mv arch.conf entries
	cd entries
	PARTUUID=$(blkid -o value -s PARTUUID /dev/${disk}2)
	echo "PARTUUID=$PARTUUID"
	sed -i -e 's/PARTUUID=XXXX/PARTUUID='$PARTUUID\
	'/;s/rootfstype=XXXX/rootfstype=ext4/' arch.conf
}

#Time configuration
#Set timezone to Moscow and set the Hardware Clock from the System Clock
set_time "Europe" "Moscow"

#Locale configuration. Set default locale to en_US.UTF-8.
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

#Hostname configuration
echo "ArchVB" >> /etc/hostname 
echo -e "127.0.0.1	localhost.localdomain	localhost\n\
::1		localhost.localdomain	localhost\n\
127.0.1.1	ArchVB.localdomain	ArchVB" >> /etc/hosts

#Install and configure systemd-boot
setup_systemd_boot sda

passwd 
systemctl enable dhcpcd
echo DONE!!
