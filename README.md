# Arch Linux install and system config
loosely based on [meredrica's arch system config](https://github.com/meredrica/system), but heavily modified for my purposes
# howto:
## basic config:
The packages folder contains 2 files named arch_packages_install.txt and arch_packages_aur.txt
the first lists all packages from the main repositories that should be installed in sysroot (after execution of arch-chroot)
after the pacstrap minimal initial step in the install script.
the second lists all packages from the aur, which are to be installed after the previous step.

## bootstrap step
1. Boot a current arch linux iso or use the net install
   - https://archlinux.org/download/
   - https://archlinux.org/releng/netboot/ - ipxe-arch.efi can be directly booted from an efi shell
2. download the package-install file: [installer-starter-script](https://raw.githubusercontent.com/FrostbittenKing/arch_system_setup/refs/heads/master/package-install.sh) - attention curl -L (for follow redirect)
3. mount your partitions to /mnt.
   Currently, you need to mount a root partition, an efi partition to /efi and a bind mount from /efi/EFI/arch to /boot.
4. make the package-install.sh file executable
5. ./package-install.sh, which will immediately terminate to write an answers_file.txt (where some stuff is configured and variables defined).
   In the future I I'd like to improve the answer file for more choices. But I'm not sure, maybe that's overengineered.
   
## installation:
after the manual preliminary setup steps including mounting the corresponding partitions to /mnt, and the firest execution of package-install.sh,
execute ./package-install.sh a second time to start the setup process.
finally, inside the sysroot (/mnt), /installer/arch_system_setup-master/setup-system/install.sh is executed,
which configures the system after entering the chroot

## final steps configured by install.sh
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
## login shell
When logging in as a user, the setup-complete.sh script is executed.
This installs yay, the additional package-manager for the AUR, and installs all packages from the arch_packages_aur.txt file (including oh-my-zsh).

## finishing steps
If you don't like refind, install a boot loader of your choice

# todo:
- add routines to copy various config files to their destinations
- checkout my awesome-wm and emacs config from git and copy them to their destinations
