#!/bin/bash

CONF_DIR=conf
PACKAGE_LIST_DIR=packages
PACKAGE_LIST_INSTALL=$PACKAGE_LIST_DIR/arch_packages_install.txt
ROOT=/mnt
ARCH_SETUP_ZIP=https://github.com/FrostbittenKing/arch_system_setup/archive/master.zip
# copy pacman.conf
$CONF_DIR/pacman.conf /etc/pacman.conf

#install packages with pacstrap
cat $PACKAGE_LIST_INSTALL | xargs pacstrap /mnt

genfstab -U $ROOT >> $ROOT/etc/fstab

# download arch_system_setup
wget $ARCH_SETUP_ZIP -O $ROOT/tmp
arch-chroot
