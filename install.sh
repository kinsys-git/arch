#!/bin/bash

variables() {
	clear
	echo "Hostname?: "
	read hostname
	export hostname
	clear
	echo "Boot disk? \(Ex. /dev/sda\): "
	read bootDisk
	export bootDisk
	clear
	echo "User name?: "
	read userName
	export userName
	clear
	echo "(1) Root only"
	echo "(2) Root and boot"
	echo "(3) Root, boot, and home"
	echo "(4) Root and home"
	echo " "
	echo "Enter: "
	read mountChoice
	clear
	echo "Enter your directories for mounting"
	if [ "$mountChoice" = "1" ]
		then
		echo "Root partition: "
		read rootPart
	elif [ "$mountChoice" = "2" ]
		then
		echo "Root partition: "
		read rootPart
		export rootPart
		echo " "
		echo "Boot partition: "
		read bootPart
	elif [ "$mountChoice" = "3" ]
		then
		echo "Root partition: "
		read rootPart
		export rootPart
		echo " "
		echo "Boot partition: "
		read bootPart
		export bootPart
		echo " "
		echo "Home partition: "
		read homePart
	elif [ "$mountChoice" = "4" ]
		then
		echo "Root partition: "
		read rootPart
		export rootPart
		echo " "
		echo "Home partition: "
		read homePart
	fi
	echo "Intel Graphics Drivers? (y/N): "
	read intelGfx
	export intelGfx
	echo "AMD Graphics Drivers? (y/N): "
	read amdGfx
	export amdGfx
	echo "Nvidia Graphics Drivers? (y/N): "
	read nvidiaGfx
	export nvidiaGfx
	clear
	echo "Pick a WM"
	echo "(1) KDE Custom"
	echo "(2) KDE Stock"
	echo "(3) Gnome Shell"
	echo "(4) i3"
	echo "(5) XFCE"
	echo "(Anything else) None"
	echo " "
	echo "Choice?: "
	read wmChoice
	export wmChoice
	clear
	echo "Create swapfile? (Y/n): "
	read swapfileChoice
	export swapfileChoice
	if [ "$swapfileChoice" == Y -o "$swapfileChoice" == y ]
		then
		echo "Where? (Ex. /swapfile or /home/swapfile): "
		read swapfile
		export swapfile
		echo "How big? (Ex. 512M or 4G): "
		read swapsize
		export swapsize
	fi
	clear
	echo "Install pacaur? (Y/n): "
	read pacaurChoice
	export pacaurChoice
}

mounting() {
	clear
	echo "Mounting all directories..."
	if [ "$mountChoice" = "1" ]
		then
		mount $rootPart /mnt
	elif [ "$mountChoice" = "2" ]
		then
		mount $rootPart /mnt
		mkdir /mnt/boot
		mount $bootPart /mnt/boot
	elif [ "$mountChoice" = "3" ]
		then
		mount $rootPart /mnt
		mkdir /mnt/boot
		mkdir /mnt/home
		mount $bootPart /mnt/boot
		mount $homePart /mnt/home
	elif [ "$mountChoice" = "4" ]
		then
		mount $rootPart /mnt
		mkdir /mnt/home
		mount $homePart /mnt/home
	fi	
}


mirrors() {
	clear
	echo "Optimizing mirror list"	
	sed -i '1iServer = https://mirrors.kernel.org/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist
	pacman -Syy reflector --noconfirm
	echo "Updating mirrors"
	reflector --protocol https --sort rate --save /etc/pacman.d/mirrorlist --verbose
}

install() {
	pacstrap /mnt base base-devel
	genfstab -U /mnt >> /mnt/etc/fstab
	if [ "$(uname -m)" = x86_64 ]
		then
		sed -i'' '93,94 s/^#//' /mnt/etc/pacman.conf
	fi
	sed -i '37iILoveCandy' /mnt/etc/pacman.conf
}

passtochroot() {
	cd /mnt/root
	wget https://raw.githubusercontent.com/maelodic/maelo-arch-install-kde/personal/chroot.sh
	chmod +x chroot.sh
	arch-chroot /mnt /bin/bash /root/chroot.sh
}

end() {
	echo "Reboot now? (y/N): "
	read rebchoice
	if [ "$rebchoice" == Y -o "$rebchoice" == y ]
		then
		reboot now
	fi
}

main() {
	variables	#Get information needed from user in the very beginning
	mounting	#Set up mounts
	mirrors		#Set up fastest mirrors for install process
	install 	#Perform the install process
	passtochroot 	#Run what is needed in chroot
	end		#Ask to reboot
}

main

