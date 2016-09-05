#!/bin/bash

CONF_DIR=conf
PACKAGE_LIST_DIR=packages
PACKAGE_LIST_INSTALL=$PACKAGE_LIST_DIR/arch_packages_install.txt
ROOT=/mnt
ARCH_SETUP_ZIP=https://github.com/FrostbittenKing/arch_system_setup/archive/master.zip
# fetch install package
wget $ARCH_SETUP_ZIP -O master.zip
mkdir /installer
unzip master.zip /installer
# copy pacman.conf
wget /installer/master/conf/pacman.conf -O /etc/pacman.conf

#install packages with pacstrap
cat /installer/master/$PACKAGE_LIST_INSTALL | xargs pacstrap /mnt

genfstab -U $ROOT >> $ROOT/etc/fstab

# download arch_system_setup
#wget $ARCH_SETUP_ZIP -O $ROOT/tmp
cp -r /installer/master $ROOT/TMP
arch-chroot
