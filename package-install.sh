#!/bin/bash

PACKAGE_LIST_DIR=packages
PACKAGE_LIST_INSTALL=$PACKAGE_LIST_DIR/arch_packages_install.txt

# copy pacman.conf
pacman.conf /etc/pacman.conf

#install packages with pacstrap
cat $PACKAGE_LIST_INSTALL | xargs pacstrap /mnt


# copy yaourt package list to /mnt/tmp
cp $PACKAGE_LIST_DIR/arch_packages_aur.txt /mnt/tmp
