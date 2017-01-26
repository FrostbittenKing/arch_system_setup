#!/bin/bash
INSTALLER_DIR=/arch_system_setup-master
PACKAGE_LIST_DIR=$INSTALLER_DIR/packages
PACKAGE_LIST_AUR=$PACKAGE_LIST_DIR/arch_packages_aur.txt
PACKAGE_LIST_OPTIONAL=$PACKAGE_LIST_DIR/arch_packages_optional.txt
ANSWER_FILE=/arch_answers.txt
. $ANSWER_FILE

function finish-install {
yes |  yaourt -S --noconfirm $(cat $PACKAGE_LIST_AUR)
    if [ $INSTALL_OPTIONAL_PACKAGES -eq 1 ]; then
	yaourt -S --noconfirm $(cat $PACKAGE_LIST_OPTIONAL)
    fi
}

function setup-complete {
    rm $HOME/.zlogin
    rm $HOME/setup-complete.sh
}

finish-install
#setup-complete
