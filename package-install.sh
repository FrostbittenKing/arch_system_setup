#!/bin/bash

CONF_DIR=conf
PACKAGE_LIST_DIR=packages
PACKAGE_LIST_INSTALL=$PACKAGE_LIST_DIR/arch_packages_install.txt
ARCH_SETUP_TAR=master.tar.gz
SCRIPT_DIR_ROOT=/installer
INSTALLER_DIR=$SCRIPT_DIR_ROOT/arch_system_setup-master
ANSWER_FILE=arch_answers.txt
INSTALL_STATUS=installation_status.txt
function init_setup {
    cat <<EOF > $ANSWER_FILE
ARCH_SETUP_TAR_URL=https://github.com/FrostbittenKing/arch_system_setup/archive/refs/heads/$ARCH_SETUP_TAR
ROOT=/mnt
SYSTEM_SETUP_DIR=$ROOT/arch_system_setup-master/setup-system
# list of services to enable
SERVICE_LIST="NetworkManager.service"
# change to your favorite Display manager
DM="lxdm.service"
TIMEZONE=Europe/Vienna
LOCALIZATIONS=("en_US.UTF-8 UTF-8")
SYS_LANGUAGE='LANG=en_US.UTF-8'
USERNAME=itachi
DEFAULT_SHELL=/usr/bin/zsh
EXTERN_CONFIGS_GIT=(https://github.com/FrostbittenKing/awesome-wm-config.git)
YAY_AUR_PKGBUILD_URL='https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=yay'
INSTALL_OPTIONAL_PACKAGES=1
EOF
    echo "removing install status file"
    cat <<EOF > $INSTALL_STATUS
ANSWER_FILE_WRITTEN=true
EOF
    echo "Answer File $ANSWER_FILE written, please customize it to suit your purpose or restart this shell script"
}

function copy_cfg_to_target {
    cp -r $INSTALLER_DIR $ROOT
    cp $ANSWER_FILE $ROOT
    echo "CFG_COPIED_TO_TARGET=true" >> $INSTALL_STATUS
    cp $INSTALL_STATUS $ROOT
}

function get_and_extract_install_archive {
    # fetch install package
    curl -L $ARCH_SETUP_TAR_URL -o $ARCH_SETUP_TAR
    if [ ! -d $SCRIPT_DIR_ROOT ]; then
	mkdir -p $SCRIPT_DIR_ROOT
	tar -xzf $ARCH_SETUP_TAR -C $SCRIPT_DIR_ROOT
    fi
    echo "ARCHIVE_FETCHED=true" >> $INSTALL_STATUS
}

function pacstrap_step {
    cat $INSTALLER_DIR/$PACKAGE_LIST_INSTALL | xargs pacstrap $ROOT
    echo "PACSTRAPPED=true" >> $INSTALL_STATUS
}
# test for initialized answer file
if [ ! -f $ANSWER_FILE ]; then
    init_setup
    exit 0
fi

. $ANSWER_FILE

get_and_extract_install_archive

# TODO: stable version that works over time
# copy pacman.conf
# cp $INSTALLER_DIR/conf/pacman.conf /etc/pacman.conf

#install packages with pacstrap
pacstrap_step

if [ ! -f $ROOT/etc/fstab ]; then
    genfstab -U $ROOT >> $ROOT/etc/fstab
    echo "fstab written..."
fi

# copy necessary files to target mount point
copy_cfg_to_target

arch-chroot $ROOT /bin/bash "$SYSTEM_SETUP_DIR/install.sh"
