#!/bin/bash

SCRIPT_DIR_ROOT=/installer
INSTALLER_DIR=/$SCRIPT_DIR_ROOT/arch_system_setup-master
PACKAGE_LIST_DIR=$INSTALLER_DIR/packages
PACKAGE_LIST_AUR=$PACKAGE_LIST_DIR/arch_packages_aur.txt
ANSWER_FILE=/arch_answers.txt
CONF_DIR=$INSTALLER_DIR/conf
# source answer file
. $ANSWER_FILE

# copy user configs
function copy_system_configs {
    cp -a $CONF_DIR/etc /etc
}

function copy_user_configs {
    cp -a $CONF_DIR/h/. /home/$USERNAME
}

# configure timezone
ln -s /usr/share/zoneinfo/$TIMEZONE /etc/localtime
# not sure about that
# hwclock --systohc --utc
#enable localizations
for l in "${LOCALIZATIONS[@]}"
do
    sed -i "s/#$l/$l/g" /etc/locale.gen
done
#sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
#sed -i 's/#de_AT.UTF-8 UTF-8/de_AT.UTF-8 UTF-8/g' /etc/locale.gen

locale-gen

echo $SYS_LANGUAGE > /etc/locale.conf
# enable services
systemctl enable $SERVICE_LIST

#enable display manager
systemctl enable $DM

# create initramfs
mkinitcpio -p linux

echo "enter new root password";passwd

# set default font to ttf-droid
# ln -s /etc/fonts/conf.avail/60-ttf-droid-sans-mono-fontconfig.conf /etc/fonts/conf.d/
# ln -s /etc/fonts/conf.avail/65-ttf-droid-kufi-fontconfig.conf /etc/fonts/conf.d/
# ln -s /etc/fonts/conf.avail/65-ttf-droid-sans-fontconfig.conf /etc/fonts/conf.d/
# ln -s /etc/fonts/conf.avail/65-ttf-droid-serif-fontconfig.conf /etc/fonts/conf.d/

# create user
# echo "please enter a username for your account: "; read username
useradd -m -G disk,wheel,uucp,games,lock,kvm,video -s /usr/bin/zsh $USERNAME
echo "get PASSWORD $username: "; passwd $USERNAME

# enable sudo
read -p "uncomment wheel group in /etc/sudoers"; visudo
su - $USERNAME <<'EOF'
# install oh my zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# git config
git config --global user.email "eugen.dahm@gmail.com"
git config --global user.name "Eugen Dahm"
git config --global color.diff "auto"
git config --global color.status "auto"
git config --global color.branch "auto"
git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
git config --global core.editor "emacs -nw"
git config --global core.excludefile "$HOME/.gitignore"
git config --global github.user "FrostbittenKing"
git config --global tar.tar.xz.command "xz -T0 -c"
git config --global push.default "current"
git config --global pull.default "current"
git config --global difftool.latex.cmd "latexdiff $LOCAL $REMOTE"
git config --global difftool.prompt "false"
git config --global alias.ldiff "difftool -t latex"

# install packages from aur
# not sure about noconfirm 
yaourt -S --noconfirm $(cat $PACKAGE_LIST_AUR)
EOF

# TODO configs
# maybe fetch from its own repository, idk
# slim.conf
# .xinitrc
# .Xresources
# .config/awesome
# .config/autostart
# oh-my-zsh .zshrc and meredrica theme
copy_system_configs
copy_user_configs

echo "Please install a bootloader of your choice, or your system won't boot on the next reboot"
echo "see https://wiki.archlinux.org/index.php/Category:Boot_loaders for more info"

