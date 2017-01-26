#!/bin/bash
INSTALLER_DIR=/arch_system_setup-master
PACKAGE_LIST_DIR=$INSTALLER_DIR/packages
PACKAGE_LIST_AUR=$PACKAGE_LIST_DIR/arch_packages_aur.txt
PACKAGE_LIST_OPTIONAL=$PACKAGE_LIST_DIR/arch_packages_optional.txt
ANSWER_FILE=/arch_answers.txt
. $ANSWER_FILE

function finish-install {
    FAILED_PKGS=""
    FAILED_PKGS_OPT=""
    for i in $(cat $PACKAGE_LIST_AUR); do
	yes |  yaourt -S --noconfirm $i 1>/dev/null 2> setup-complete.log
	if [ $? -ne 0 ]; then
	    FAILED_PKGS="$FAILED_PKGS $i"
	fi
    done
    if [ $INSTALL_OPTIONAL_PACKAGES -eq 1 ]; then
	for i in $(cat $PACKAGE_LIST_OPTIONAL); do
	    yes |  yaourt -S --noconfirm $i 1>/dev/null 2>> setup-complete.log
	    if [ $? -ne 0 ]; then
		FAILED_PKGS_OPT="$FAILED_PKGS_OPT $i"
	    fi
	done
    fi
    echo "Following Packages failed from aur: $FAILED_PKGS"
    echo "Following optional Packages failed from aur: $FAILED_PKGS_OPT"
    echo "please review setup-complete.log for more details"
}

function setup-complete {
    rm $HOME/setup-complete.sh
    sed -i '/$HOME\/setup-complete.sh/d' .zlogin
}

finish-install
setup-complete
