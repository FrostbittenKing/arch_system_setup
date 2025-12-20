#!/bin/bash

INSTALLER_DIR=/arch_system_setup-master
PACKAGE_LIST_DIR=packages
PACKAGE_LIST_INSTALL=$PACKAGE_LIST_DIR/arch_packages_install.txt
ANSWER_FILE=/arch_answers.txt
INSTALL_STATUS=/installation_status.txt
CONF_DIR=$INSTALLER_DIR/conf
# source answer file
. $ANSWER_FILE
# copy user configs
function copy_system_configs {
    cp -a $CONF_DIR/etc /
    sed -i 's/#\ session=.*$/session=\/usr\/bin\/awesome/'      /etc/lxdm/lxdm.conf
    sed -i 's/gtk_theme=.*$/gtk_theme=Clearlooks/'             /etc/lxdm/lxdm.conf
    sed -i 's/theme=.*$/theme=Arch-Dark/'                      /etc/lxdm/lxdm.conf
    # todo fix config
    # cp -a $CONF_DIR/pacman.conf /etc
}
# configure timezone and localizations
function configure_locale_and_timezone
{
    echo "Configure timezone and localization"
    ln -sv /usr/share/zoneinfo/$TIMEZONE /etc/localtime
    # not sure about that
    # hwclock --systohc --utc
    #enable localizations
    for l in "${LOCALIZATIONS[@]}"
    do
	echo "configure locale.gen"
	sed -i "s/#$l/$l/g" /etc/locale.gen
    done

    locale-gen

    if [ ! -f /etc/vconsole.conf ]; then
	echo 'KEYMAP=us' > /etc/vconsole.conf
    fi
    echo $SYS_LANGUAGE > /etc/locale.conf
    echo "LOCALE_CONFIGURED=true" >> $INSTALL_STATUS
}

# configure init ramfs
function configure_initramfs
{
    sed -i 's/HOOKS=.*$/HOOKS=(base udev fsck kms autodetect block encrypt lvm2 filesystems keyboard shutdown)/' /etc/mkinitcpio.conf
    sed -i 's/#COMPRESSION_OPTIONS=.*$/COMPRESSION_OPTIONS=(-T0 -c -z)/'                                         /etc/mkinitcpio.conf
    sed -i 's/#default_uki=.*$/default_uki="\/boot\/archlinux-linux.efi"/'                                        /etc/mkinitcpio.d/linux.preset
    sed -i 's/#default_options=.*$/default_options="--splash=\/usr\/share\/systemd\/bootctl\/splash-arch.bmp"/'  /etc/mkinitcpio.d/linux.preset
    mkinitcpio -p linux
    echo "INITRAMFS_INITIALIZED=true" >> $INSTALL_STATUS
}

# configure users
function configure_users
{
    # root pw
    echo "enter new root password";passwd

    # create user
    # echo "please enter a username for your account: "; read username
    useradd -m -G disk,wheel,uucp,games,lock,kvm,video -s $DEFAULT_SHELL $USERNAME
    echo "get PASSWORD $USERNAME: "; passwd $USERNAME
    
    # enable sudo
    read -p "uncomment wheel group in /etc/sudoers"; visudo
    echo "USERS_CONFIGURED=true" >> $INSTALL_STATUS
}

# install remaining main packages
function install_mandatory_packages
{
    cat $INSTALLER_DIR/$PACKAGE_LIST_INSTALL | xargs pacman -Syu --noconfirm --needed
}

install_mandatory_packages
# configure timezone
configure_locale_and_timezone

# create initramfs
configure_initramfs

# set default font to ttf-droid
# ln -s /etc/fonts/conf.avail/60-ttf-droid-sans-mono-fontconfig.conf /etc/fonts/conf.d/
# ln -s /etc/fonts/conf.avail/65-ttf-droid-kufi-fontconfig.conf /etc/fonts/conf.d/
# ln -s /etc/fonts/conf.avail/65-ttf-droid-sans-fontconfig.conf /etc/fonts/conf.d/
# ln -s /etc/fonts/conf.avail/65-ttf-droid-serif-fontconfig.conf /etc/fonts/conf.d/

configure_users

copy_system_configs

export INSTALLER_DIR ANSWER_FILE CONF_DIR

function copy_my_configs
{
    su $USERNAME <<'EOF'
    . $ANSWER_FILE

    function copy_git_configs {
        if [ ${#EXTERN_CONFIGS_GIT[@]} -eq 0 ]; then
            return 0
        fi
        for grepo in "${EXTERN_CONFIGS_GIT}"
        do
	    git clone $grepo
	    repo_name=${grepo##*/}
            repo_dir=${repo_name%.*}
            cd $repo_dir
            make install
            cd ..
            rm -rf $repo_dir
        done
    }

    function copy_user_configs {
        cp -a $CONF_DIR/h/. $HOME
        copy_git_configs
        # chown -R $USERNAME.$USERNAME /home/$USERNAME
    }

    cd /tmp 
    copy_user_configs
    cd $HOME
    # create .zlogin file for last installation steps
    echo '$HOME/setup-complete.sh' >> .zlogin
    cp $INSTALLER_DIR/setup-system/setup-complete.sh .
    chmod +x setup-complete.sh
EOF
    echo "MY_CONFIGS_COPIED=true" >> $INSTALL_STATUS
}
copy_my_configs

# enable services
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
systemctl enable $SERVICE_LIST

#enable display manager
systemctl enable $DM

# TODO configs
# maybe fetch from its own repository, idk
# copy_git_configs
CRYPT_DEVICE_UUID_ARG=$(blkid | grep crypto_LUKS |  cut -d ' ' -f 2 | sed 's/"//g')
ROOT_DEV_UUID_ARG=$(blkid | grep "Linux filesystem" | cut -d ' ' -f 2 | sed 's/"//g')
# configure refind
# todo for encrypted disk
# cryptdevice=${CRYPT_DEVICE_UUID_ARG}:crypt_disk
# "Boot with standard options"  "root=/dev/arch_system_vg/arch_root_lv rootfstype=ext4 add_efi_memmap acpi_os_name=""Windows 2015"" acpi_osi= mem_sleep_default=s2idle i915.enable_fbc=1 initrd=\EFI\arch\intel-ucode.img initrd=\EFI\arch\initramfs-%v.img"
# "Boot to single-user mode"    "root=/dev/arch_system_vg/arch_root_lv rootfstype=ext4 add_efi_memmap acpi_os_name=""Windows 2015"" acpi_osi= mem_sleep_default=s2idle i915.enable_fbc=1 single"
# "Boot with minimal options"   "root=/dev/arch_system_vg/arch_root_lv rootfstype=ext4 ro"
cat <<EOF > /boot/refind_linux.conf
"Boot with standard options"  "root=$ROOT_DEV_UUID_ARG rootfstype=ext4 add_efi_memmap acpi_os_name=""Windows 2015"" acpi_osi= mem_sleep_default=s2idle i915.enable_fbc=1 initrd=\EFI\arch\intel-ucode.img initrd=\EFI\arch\initramfs-%v.img"
EOF
# configure extra_kernel_version_strings
sed -i 's/#extra_kernel_version_strings.*$/extra_kernel_version_strings linux/' /efi/EFI/refind/refind.conf

# configure for uki image
echo "cryptdevice=${CRYPT_DEVICE_UUID_ARG}:crypt_disk root=/dev/arch_system_vg/arch_root_lv rootfstype=ext4 add_efi_memmap acpi_os_name=\"Windows 2015\" acpi_osi=  mem_sleep_default=s2idle i915.enable_fbc=1" > /etc/kernel/cmdline
refind-install


echo "Please install a bootloader of your choice, or your system won't boot on the next reboot"
echo "see https://wiki.archlinux.org/index.php/Category:Boot_loaders for more info"
