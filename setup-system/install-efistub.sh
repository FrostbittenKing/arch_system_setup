#!/bin/bash
# grab info about the efi disk: the variable contains following columns separated by whitespace: full partition device name (eg: /dev/sda) physical disk name (eg: sda) and partitionNr: (eg 1)
# sample value would look like this: "/dev/nvme0n1p1 nvme0n1 1"
# to reliably create an efi stub entry, we need to extract the second column and append /dev to it, and the third column the partition nr
# sample efibootmgr call: efibootmgr --create --disk /dev/<column2> --part <column 3> ...
EFI_DISK_INFO=$(lsblk -l -n -o PATH,PKNAME,MIN | grep $(blkid | grep $(findmnt --fstab -n -o UUID,TARGET,PARTLABEL | grep "EFI system partition" | cut -f 1 -d ' ') | cut -d ' ' -f 1 | sed -e 's/://') | tr -s "[:space:]")
echo "EFI DISK INFO $EFI_DISK_INFO"
EFI_DISK=$(echo "/dev/"$(echo $EFI_DISK_INFO | cut -f 2 -d ' '))
echo "EFI Disk: $EFI_DISK"
EFI_PARTITION_NR=$(echo $EFI_DISK_INFO | cut -f 3 -d ' ')
echo "EFI Partition Nr: $EFI_PARTITION_NR"

# now we can cobble together the efibootmgr command with the previously extracted information generically
# we expect to have a UKI (unified kernel image), available
efibootmgr --create --disk $EFI_DISK --part $EFI_PARTITION_NR --loader '\EFI\arch\archlinux-linux.efi' --label 'Arch Linux' --unicode
