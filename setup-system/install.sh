#!/bin/bash

INSTALLER_DIR=/arch_system_setup-master
ANSWER_FILE=/arch_answers.txt
INSTALL_STATUS=/installation_status.txt
CONF_DIR=$INSTALLER_DIR/conf
# source answer file
. $ANSWER_FILE

# copy user configs
function copy_system_configs {
    cp -a $CONF_DIR/etc /
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

echo "Please install a bootloader of your choice, or your system won't boot on the next reboot"
echo "see https://wiki.archlinux.org/index.php/Category:Boot_loaders for more info"
