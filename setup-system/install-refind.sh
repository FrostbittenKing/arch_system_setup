grep -q BOOTLOADER_INSTALLED $INSTALL_STATUS && return
CRYPT_DEVICE_UUID_ARG="UUID="$(lsblk  -f -o FSTYPE,UUID | grep 'crypto_LUKS' | tr -s "[:space:]" | cut -f 2 -d ' ')
EFI_PARTITION_MOUNT_POINT=$(findmnt --fstab -n -o TARGET,PARTLABEL | grep "EFI system partition" | cut -f 1 -d ' ')
ROOT_DEV_UUID_ARG="UUID="$(findmnt --fstab -n -o TARGET,UUID | grep "/ " | tr -s "[:space:]" | cut -f 2 -d ' ')
# configure refind
# todo for encrypted disk
# cryptdevice=${CRYPT_DEVICE_UUID_ARG}:crypt_disk
# "Boot with standard options"  "root=/dev/arch_system_vg/arch_root_lv rootfstype=ext4 add_efi_memmap acpi_os_name=""Windows 2015"" acpi_osi= mem_sleep_default=s2idle i915.enable_fbc=1 initrd=\EFI\arch\intel-ucode.img initrd=\EFI\arch\initramfs-%v.img"
# "Boot to single-user mode"    "root=/dev/arch_system_vg/arch_root_lv rootfstype=ext4 add_efi_memmap acpi_os_name=""Windows 2015"" acpi_osi= mem_sleep_default=s2idle i915.enable_fbc=1 single"
# "Boot with minimal options"   "root=/dev/arch_system_vg/arch_root_lv rootfstype=ext4 ro"
refind-install
cat <<EOF > /boot/refind_linux.conf
"Boot with standard options"  "root=$ROOT_DEV_UUID_ARG rootfstype=ext4 add_efi_memmap acpi_os_name=""Windows 2015"" acpi_osi= mem_sleep_default=s2idle i915.enable_fbc=1 initrd=\EFI\arch\intel-ucode.img initrd=\EFI\arch\initramfs-%v.img"
EOF
# check if efi partition exists, and afterwards if refind.conf exists
if [ -z $EFI_PARTITION_MOUNT_POINT ]; then
    echo "Error, no efi partition mount point found, cannot install efi boot loader"
else
    local refind_conf_location=$(find $EFI_PARTITION_MOUNT_POINT  -type f -name refind.conf)
    if [ -z $refind_conf_location ]; then
	echo "Error no refind.conf found, please install refind with refind-install"
    else
	# configure extra_kernel_version_strings
	sed -i 's/#extra_kernel_version_strings.*$/extra_kernel_version_strings linux/' $refind_conf_location
    fi
fi
echo "BOOTLOADER_INSTALLED=true" >> $INSTALL_STATUS
