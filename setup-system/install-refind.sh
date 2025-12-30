#!/bin/bash
refind-install
# $DEFAULT_KERNEL_ARGS is fed from the install.sh script
cat <<EOF > /boot/refind_linux.conf
"Boot with standard options"  "$DEFAULT_KERNEL_ARGS initrd=\EFI\arch\intel-ucode.img initrd=\EFI\arch\initramfs-%v.img"
EOF
# check if efi partition exists, and afterwards if refind.conf exists
if [ -z $EFI_PARTITION_MOUNT_POINT ]; then
    echo "Error, no efi partition mount point found, cannot install efi boot loader"
else
    refind_conf_location=$(find $EFI_PARTITION_MOUNT_POINT  -type f -name refind.conf)
    if [ -z $refind_conf_location ]; then
	echo "Error no refind.conf found, please install refind with refind-install"
    else
	# configure extra_kernel_version_strings
	sed -i 's/#extra_kernel_version_strings.*$/extra_kernel_version_strings linux/' $refind_conf_location
    fi
fi
