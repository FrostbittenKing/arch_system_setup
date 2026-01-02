#!/bin/bash
PACKAGE_LIST_AUR=$HOME/arch_packages_aur.txt
PACKAGE_LIST_OPTIONAL=$HOME/arch_packages_optional.txt
ANSWER_FILE=$HOME/arch_answers.txt
. $ANSWER_FILE

function finish-install {
    FAILED_PKGS=""
    FAILED_PKGS_OPT=""

    # check if yay is installed, and install it if not found
    pacman -Qi yay 2>&1 > /dev/null
    if [ $? -ne 0 ]; then
	mkdir -p /tmp/yay-build
	curl -L $YAY_AUR_PKGBUILD_URL -o /tmp/yay-build/PKGBUILD
	yes | makepkg -Ccfirs -D /tmp/yay-build
    fi
    
    for i in $(cat $PACKAGE_LIST_AUR); do
	yay -S --batchinstall --noredownload --noconfirm --needed $i 1>/dev/null 2>> setup-complete.log
	if [ $? -ne 0 ]; then
	    FAILED_PKGS="$FAILED_PKGS $i"
	fi
    done
    if [ $INSTALL_OPTIONAL_PACKAGES -eq 1 ]; then
	for i in $(cat $PACKAGE_LIST_OPTIONAL); do
	    yay -S --batchinstall --noredownload --noconfirm --needed $i 1>/dev/null 2>> setup-complete.log
	    if [ $? -ne 0 ]; then
		FAILED_PKGS_OPT="$FAILED_PKGS_OPT $i"
	    fi
	done
    fi
    echo "Following Packages failed from aur: $FAILED_PKGS"
    echo "Following optional Packages failed from aur: $FAILED_PKGS_OPT"
    echo "please review setup-complete.log for more details"
    systemctl --user enable podman.socket podman.service gcr-ssh-agent.service
    echo "configure git credentials helper for git+https"
    git config --global credential.helper /usr/lib/git-core/git-credential-libsecret
    yadm clone --bootstrap $YADM_REPO
}

function setup-complete {
    rm $HOME/setup-complete.sh
    rm $PACKAGE_LIST_AUR
    rm $PACKAGE_LIST_OPTIONAL
    sed -i '/$HOME\/setup-complete.sh/d' .zlogin
}

finish-install
setup-complete
