#!/bin/bash

PACKAGE_LIST_DIR=packages
PACKAGE_LIST_INSTALL=$PACKAGE_LIST_DIR/arch_packages_install.txt

#add archlinuxfr to pacman.conf
echo -e '[archlinuxfr]
SigLevel = PackageOptional
Server = http://repo.archlinux.fr/$arch
'>> /etc/pacman.conf

#install packages with pacstrap
cat $PACKAGE_LIST_INSTALL | xargs pacstram /mnt
