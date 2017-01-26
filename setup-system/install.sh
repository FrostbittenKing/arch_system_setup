#!/bin/bash

INSTALLER_DIR=/arch_system_setup-master
ANSWER_FILE=/arch_answers.txt
CONF_DIR=$INSTALLER_DIR/conf
# source answer file
. $ANSWER_FILE

# copy user configs
function copy_system_configs {
    cp -a $CONF_DIR/etc /
    cp -a $CONF_DIR/pacman.conf /etc
}


# configure timezone
ln -s /usr/share/zoneinfo/$TIMEZONE /etc/localtime
# not sure about that
# hwclock --systohc --utc
#enable localizations
for l in "${LOCALIZATIONS[@]}"
do
    sed -i "s/#$l/$l/g" /etc/locale.gen
done

locale-gen

echo $SYS_LANGUAGE > /etc/locale.conf
# create initramfs
mkinitcpio -p linux

echo "enter new root password";passwd

# set default font to ttf-droid
# ln -s /etc/fonts/conf.avail/60-ttf-droid-sans-mono-fontconfig.conf /etc/fonts/conf.d/
# ln -s /etc/fonts/conf.avail/65-ttf-droid-kufi-fontconfig.conf /etc/fonts/conf.d/
# ln -s /etc/fonts/conf.avail/65-ttf-droid-sans-fontconfig.conf /etc/fonts/conf.d/
# ln -s /etc/fonts/conf.avail/65-ttf-droid-serif-fontconfig.conf /etc/fonts/conf.d/

# create user
# echo "please enter a username for your account: "; read username
useradd -m -G disk,wheel,uucp,games,lock,kvm,video -s $DEFAULT_SHELL $USERNAME
echo "get PASSWORD $USERNAME: "; passwd $USERNAME

# enable sudo
read -p "uncomment wheel group in /etc/sudoers"; visudo

copy_system_configs
export INSTALLER_DIR ANSWER_FILE CONF_DIR
su $USERNAME <<'EOF'
. $ANSWER_FILE

function copy_git_configs {
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
#    chown -R $USERNAME.$USERNAME /home/$USERNAME
}

cd /tmp 
copy_user_configs
cd $HOME
# create .zlogin file for last installation steps
echo '$HOME/setup-complete.sh' >> .zlogin
cp $INSTALLER_DIR/setup-system/setup-complete.sh .
chmod +x setup-complete.sh
EOF

# enable services
systemctl enable $SERVICE_LIST

#enable display manager
systemctl enable $DM

# TODO configs
# maybe fetch from its own repository, idk
# copy_git_configs

echo "Please install a bootloader of your choice, or your system won't boot on the next reboot"
echo "see https://wiki.archlinux.org/index.php/Category:Boot_loaders for more info"
