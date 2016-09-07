# arch_system_setup
# loosely based on https://github.com/meredrica/system, but heavily modified for my purposes
Arch Linux install and system config

#howto:
basic config:
	the packages folder contains 2 files named arch_packages_install.txt and arch_packages_aur.txt
	the first lists all packages from the main repositories that should be installed in the pacstrap step
	the second lists all packages from the aur, which are to be installed during the the configuration step 
	inside the sysroot after the execution of arch-chroot

installation:
	after the manual preliminary setup steps including mounting the corresponding partitions to /mnt,
	execute ./package-install.sh to start the setup process.
	finnally, inside the sysroot (/mnt), /installer/arch_system_setup-master/setup-system/install.sh is executed,
	which configures the system after entering the chroot

final steps configured by install.sh
	- zoneinfo
	- locale-gen
	- enable dhcpcd and slim
	- create initramfs
	- enter new root password
	- create user (itachi)
	- ask for password for user
	- configure:
	  - zsh
	  - git config
	- install aur packages (configured by arch_packages_aur.txt)
	
	
dont forget to install a bootloader like grub

todo:
	- cleanup (ask for username etc.)
	- copy my configuration files (slim,xinitrc etc.)
	
