#!/bin/bash

INSTALLER_DIR=/arch_system_setup-master
PACKAGE_LIST_DIR=packages
PACKAGE_LIST_INSTALL=$PACKAGE_LIST_DIR/arch_packages_install.txt
PACKAGE_LIST_AUR=$PACKAGE_LIST_DIR/arch_packages_aur.txt
PACKAGE_LIST_OPTIONAL=$PACKAGE_LIST_DIR/arch_packages_optional.txt
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
    grep -q LOCALE_CONFIGURED $INSTALL_STATUS && return
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
    grep -q INITRAMFS_INITIALIZED $INSTALL_STATUS && return
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
    grep -q USERS_CONFIGURED $INSTALL_STATUS && return
    # root pw
    echo "enter new root password";passwd

    # create user
    # echo "please enter a username for your account: "; read username
    useradd -m -G disk,wheel,uucp,games,lock,kvm,video,power,wireshark -s $DEFAULT_SHELL $USERNAME
    echo "get PASSWORD $USERNAME: "; passwd $USERNAME
    
    # enable sudo
    read -p "uncomment wheel group in /etc/sudoers"; visudo
    echo "USERS_CONFIGURED=true" >> $INSTALL_STATUS
}

# install remaining main packages
function install_mandatory_packages
{
    grep -q MAIN_PACKAGES_INSTALLED $INSTALL_STATUS && return
    cat $INSTALLER_DIR/$PACKAGE_LIST_INSTALL | xargs pacman -Syu --noconfirm --needed
    echo "MAIN_PACKAGES_INSTALLED=true" >> $INSTALL_STATUS
}


function copy_my_configs
{
    grep -q MY_CONFIGS_COPIED $INSTALL_STATUS && return
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
    cp $INSTALLER_DIR/$PACKAGE_LIST_AUR .
    cp $INSTALLER_DIR/$PACKAGE_LIST_OPTIONAL .
    cp $ANSWER_FILE .
    chmod +x setup-complete.sh
EOF
    echo "MY_CONFIGS_COPIED=true" >> $INSTALL_STATUS
}

function install_bootloader
{
    CRYPT_DEVICE_UUID_ARG="UUID="$(lsblk  -f -o FSTYPE,UUID | grep 'crypto_LUKS' | tr -s "[:space:]" | cut -f 2 -d ' ')
    EFI_PARTITION_MOUNT_POINT=$(findmnt --fstab -n -o TARGET,PARTLABEL | grep "EFI system partition" | cut -f 1 -d ' ')
    ROOT_DEV_UUID_ARG="UUID="$(findmnt --fstab -n -o TARGET,UUID | grep "/ " | tr -s "[:space:]" | cut -f 2 -d ' ')
    DEFAULT_KERNEL_ARGS="root=$ROOT_DEV_UUID_ARG rootfstype=ext4 add_efi_memmap acpi_os_name=""Windows 2015"" acpi_osi= mem_sleep_default=s2idle \
i915.enable_fbc=1" > /etc/kernel/cmdline
    export CRYPT_DEVICE_UUID_ARG EFI_PARTITION_MOUNT_POINT ROOT_DEV_UUID_ARG DEFAULT_KERNEL_ARGS INSTALL_STATUS
    # default bootloader efistub
    $INSTALLER_DIR/setup-system/install-efistub.sh
    # additional loaders
    for loader in "${BOOTLOADERS}"
    do
	case $loader in
	    refind)
		bash $INSTALLER_DIR/setup-system/install-refind.sh
		;;
	esac
    done
    unset CRYPT_DEVICE_UUID_ARG EFI_PARTITION_MOUNT_POINT ROOT_DEV_UUID_ARG
}
export INSTALLER_DIR ANSWER_FILE CONF_DIR PACKAGE_LIST_AUR PACKAGE_LIST_OPTIONAL

# configure timezone
configure_locale_and_timezone

install_mandatory_packages

# create initramfs
configure_initramfs

configure_users

copy_system_configs

copy_my_configs

# enable services and display manager
systemctl enable $SERVICE_LIST $DM

# TODO configs
# maybe fetch from its own repository, idk
# copy_git_configs

install_bootloader
# configure for uki image
echo "cryptdevice=${CRYPT_DEVICE_UUID_ARG}:crypt_disk root=/dev/arch_system_vg/arch_root_lv rootfstype=ext4 \
add_efi_memmap acpi_os_name=\"Windows 2015\" acpi_osi=  mem_sleep_default=s2idle i915.enable_fbc=1" > /etc/kernel/cmdline


echo "Checkout an alternative bootloader if you don't like refind..."
echo "see https://wiki.archlinux.org/index.php/Category:Boot_loaders for more info"
