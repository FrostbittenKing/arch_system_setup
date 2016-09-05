#!/bin/bash

CONF_DIR=conf
PACKAGE_LIST_DIR=packages
PACKAGE_LIST_INSTALL=$PACKAGE_LIST_DIR/arch_packages_install.txt
ROOT=/mnt
ARCH_SETUP_ZIP=https://github.com/FrostbittenKing/arch_system_setup/archive/master.zip
SCRIPT_DIR_ROOT=/installer
INSTALLER_DIR=/$SCRIPT_DIR_ROOT/arch_system_setup-master
# needed packages
pacman -Syu --noconfirm
pacman -S --noconfirm unzip
# fetch install package
wget $ARCH_SETUP_ZIP -O master.zip
mkdir $SCRIPT_DIR_ROOT
unzip master.zip -d $SCRIPT_DIR_ROOT
# copy pacman.conf
cp $INSTALLER_DIR/conf/pacman.conf /etc/pacman.conf

#install packages with pacstrap
cat $INSTALLER_DIR/$PACKAGE_LIST_INSTALL | xargs pacstrap /mnt

genfstab -U $ROOT >> $ROOT/etc/fstab

# download arch_system_setup
#wget $ARCH_SETUP_ZIP -O $ROOT/tmp
cp -r $INSTALLER_DIR $ROOT/tmp
arch-chroot
