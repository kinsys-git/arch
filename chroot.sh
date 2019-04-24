#!/bin/bash

initpackages() {
	clear
	echo "Initializing packages"
	pacman -Sy
}

hostname() {
	clear
	echo "Setting hostname"
	echo "$hostname" > /etc/hostname
}

timekeeping() {
	clear
	echo "Setting timezone for pacific time and generating locale."
	ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
	echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
	locale-gen
	hwclock --systohc
	locale > /etc/locale.conf
}

makeswap() {
	clear
	if [ "$swapfileChoice" == y -o "$swapfileChoice" == Y ]
		then
	  echo "Creating swapfile."
	  fallocate -l $swapsize $swapfile
	  chmod 600 $swapfile
	  mkswap $swapfile
	  echo " " >> /etc/fstab
	  echo "$swapfile none swap defaults 0 0" >> /etc/fstab
	fi
}

bootloader() {
	clear
	echo "Setting up bootloader"
	mkinitcpio -p linux
	grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ARCH
	grub-mkconfig -o /boot/grub/grub.cfg
}

drivers() {
	clear
	echo "Setting up video drivers"
	if [ "$intelGfx" == Y -o "$intelGfx" == y ]
		then
		pacman -S intel-dri xf86-video-intel --noconfirm --needed
	fi
	if [ "$amdGfx" == Y -o "$amdGfx" == y ]
		then
		pacman -S ati-dri xf86-video-aty --noconfirm --needed
	fi
	if [ "$nvidiaGfx" == Y -o "$nvidiaGfx" == y ]
		then
		pacman -S nvidia lib32-nvidia-utils nvidia-dkms --noconfirm --needed
	fi
}

adduser() {
	clear
	echo "Setting up user"
	useradd -m -G wheel,disk,audio,adm,network,video "$userName"
	echo "$userName ALL=(ALL) ALL" >> /etc/sudoers
}


wminstall() {
	clear
	if [ "$wmChoice" = "1" -o "$wmChoice" = "2" -o "$wmChoice" = "3" -o "$wmChoice" = "4" -o "$wmChoice" = "5" -p "$wmChoice" = "straws" ]
	then
		echo "Setting up WM"
  	if [ "$wmChoice" = "1" ]
  	then
  		pacman -S budgie-desktop gnome sddm --noconfirm --needed
		systemctl enable sddm
  	elif [ "$wmChoice" = "2" ]
  	then
  		pacman -S plasma-meta plasma-nm sddm --noconfirm --needed
		systemctl enable sddm
  	elif [ "$wmChoice" = "3" ]
  	then
  		pacman -S gnome gdm --noconfirm --needed
		systemctl enable sddm
  	elif [ "$wmChoice" = "4" -o "$wmChoice" = "straws" ]
  	then
  		pacman -S i3 dmenu network-manager-applet blueman sddm --noconfirm --needed
		systemctl enable sddm
		systemctl enable bluetooth
  	elif [ "$wmChoice" = "5" ]
  	then
  		pacman -S xfce4 sddm --noconfirm --needed
		systemctl enable sddm
  	else
  		wm = "none"
	  fi
	fi

}

software() {
	clear
	echo "Setting up additional software"
	pacman -S wget \
		rsync \
	       	wpa_supplicant \
	       	bc \
		grub \
	       	efibootmgr \
	       	os-prober \
	       	sudo \
	       	networkmanager \
	       	reflector \
	       	git \
	       	dialog \
	       	vim --noconfirm --needed
}

passwords() {
	clear
	echo "Set root password: "
	passwd
	echo " --- "
	echo "Set $userName password: "
	passwd "$userName"
}


main() {
	initpackages	#Update reps
	hostname	#Setup hostname
	timekeeping	#Set up timzone and generate the locale
	makeswap	#Install swapfile if selected
	drivers 	#Install drivers if previously specified
	adduser		#Add user with sudoers access
	software	#Install additional software
	wminstall   	#Install WM
	bootloader	#Set up grub
	passwords	#Set user and root passwords
	rm /root/chroot.sh
}

main
