#!/bin/bash

CONF_DIR=conf
PACKAGE_LIST_DIR=packages
PACKAGE_LIST_INSTALL=$PACKAGE_LIST_DIR/arch_packages_install.txt
ARCH_SETUP_ZIP=master.zip
SCRIPT_DIR_ROOT=/installer
INSTALLER_DIR=/$SCRIPT_DIR_ROOT/arch_system_setup-master
ANSWER_FILE=arch_answers.txt

function init_setup {
    cat <<EOF > $ANSWER_FILE
ARCH_SETUP_ZIP_URL=https://github.com/FrostbittenKing/arch_system_setup/archive/$ARCH_SETUP_ZIP
ROOT=/mnt
SYSTEM_SETUP_DIR=$ROOT/arch_system_setup-master/setup-system
# list of services to enable
SERVICE_LIST="dhcpcd.service NetworkManager.service"
# change to your favorite Display manager
DM="lxdm.service"
TIMEZONE=Europe/Vienna
LOCALIZATIONS=("en_US.UTF-8 UTF-8" "de_AT.UTF-8 UTF-8")
SYS_LANGUAGE='LANG=en_US.UTF-8'
USERNAME=itachi
EXTERN_CONFIGS_GIT=(git@github.com:FrostbittenKing/awesome-wm-config.git)
EOF
    echo "Answer File $ANSWER_FILE written, please customize it to suit your purpose or restart this shell script"
}

function copy_cfg_to_target {
    cp -r $INSTALLER_DIR $ROOT
    cp $ANSWER_FILE $ROOT
}

# test for initialized answer file
if [ ! -f $ANSWER_FILE ]; then
    init_setup
    exit 0
fi

. $ANSWER_FILE

# needed packages
pacman -Syu --noconfirm
pacman -S --noconfirm unzip
# fetch install package
wget $ARCH_SETUP_ZIP_URL -O $ARCH_SETUP_ZIP
mkdir $SCRIPT_DIR_ROOT
unzip $ARCH_SETUP_ZIP -d $SCRIPT_DIR_ROOT
# copy pacman.conf
cp $INSTALLER_DIR/conf/pacman.conf /etc/pacman.conf

#install packages with pacstrap
cat $INSTALLER_DIR/$PACKAGE_LIST_INSTALL | xargs pacstrap $ROOT

genfstab -U $ROOT >> $ROOT/etc/fstab

# copy necessary files to target mount point
copy_cfg_to_target

arch-chroot $ROOT /bin/bash "$SYSTEM_SETUP_DIR/install.sh"
