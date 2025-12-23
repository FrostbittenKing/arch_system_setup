#!/bin/bash
# configure refind
# todo for encrypted disk
# cryptdevice=${CRYPT_DEVICE_UUID_ARG}:crypt_disk
# "Boot with standard options"  "root=/dev/arch_system_vg/arch_root_lv rootfstype=ext4 add_efi_memmap acpi_os_name=""Windows 2015"" acpi_osi= mem_sleep_default=s2idle i915.enable_fbc=1 initrd=\EFI\arch\intel-ucode.img initrd=\EFI\arch\initramfs-%v.img"
# "Boot to single-user mode"    "root=/dev/arch_system_vg/arch_root_lv rootfstype=ext4 add_efi_memmap acpi_os_name=""Windows 2015"" acpi_osi= mem_sleep_default=s2idle i915.enable_fbc=1 single"
# "Boot with minimal options"   "root=/dev/arch_system_vg/arch_root_lv rootfstype=ext4 ro"
refind-install
# $DEFAULT_KERNEL_ARGS is fed from the install.sh script
# Also don't forget to configure refind.conf in /efi/EFI/refind or else the below argument %v doesn't work
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
