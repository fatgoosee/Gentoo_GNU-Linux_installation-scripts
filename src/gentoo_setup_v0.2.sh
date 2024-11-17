#! /bin/bash

sVersion="0.2"

script_error ()
	{
		umount /mnt/gentoo/boot
		umount /mnt/gentoo/home
		umount /mnt/gentoo
		exit 1
	}
	
script_log ()
	{
		"$@"
		
		printf "\n\n$?:\n\t\t" >> gentoo_setup_v${sVersion}.log
		"$@" &>> gentoo_setup_v${sVersion}.log
	}
	
	
	
disk_part_create ()
	{
		echo "Formatting disk..."
		sleep 4
		
		script_log parted -s /dev/${iDisk_device} mklabel ${iDisk_table}
		script_log parted -s /dev/${iDisk_device} mkpart primary fat32 ${iDisk_part_boot[0]} ${iDisk_part_boot[1]}
		script_log parted -s /dev/${iDisk_device} mkpart primary btrfs ${iDisk_part_root[0]} ${iDisk_part_root[1]}
		script_log parted -s /dev/${iDisk_device} name 1 boot
		script_log parted -s /dev/${iDisk_device} name 2 gentoo
		script_log parted -s /dev/${iDisk_device} set 1 boot on
	}

disk_filesystem_create ()
	{
		echo "Creating filesystem..."
		sleep 4
		
		if [ ${iDisk_encrypt[0]} == true ]
			then
				disk_filesystem_create_encrypt
		else
				iDisk_encrypt_device="${iDisk_device}2"
			fi
		disk_filesystem_create_boot
		disk_filesystem_create_root
		script_log mount /dev/${iDisk_device}1 /mnt/gentoo/boot
		if [ ${iDisk_encrypt[2]} == true ]
			then
				script_log cp crypt_key.luks.gpg /mnt/gentoo/boot
			fi
	}
	
disk_filesystem_create_encrypt ()
	{
		echo "Encrypting filesystem..."
		sleep 4
		
		iDisk_encrypt_device="mapper/luksdev"
		if [ ${iDisk_encrypt[2]} == true ]
			then
				script_log printf "\n\n\ny\ncrypt_key\ncrypt_key@encrypt.system\n\nO\n${iDisk_encrypt[1]}\n${iDisk_encrypt[1]}\n" | gpg --full-generate-key
				script_log printf "${iDisk_encrypt[1]}" | gpg --export-secret-keys crypt_key --output
				sGPG="$(printf \"${iDisk_encrypt[1]}\" | gpg --decrypt crypt_key.luks.gpg)"
				script_log printf "${sGPG}" | cryptsetup luksFormat -q -c aes-xts-plain64 -s 512 /dev/${iDisk_device}2 -
				script_log printf "${sGPG}\n${iDisk_encrypt[1]}\n" | crpytsetup luksAddKey -q /dev/${iDisk_device}2
		else
				script_log printf "${iDisk_encrypt[1]}\n" | cryptsetup luksFormat -q -c aes-xts-plain64 -s 512 /dev/${iDisk_device}2
			fi
		script_log printf "${iDisk_encrypt[1]}\n" | cryptsetup luksOpen /dev/${iDisk_device}2 luksdev
	}

disk_filesystem_create_boot ()
	{
		echo "Creating boot filesystem..."
		sleep 4
		
		script_log mkfs.vfat -F32 /dev/${iDisk_device}1
	}
	
disk_filesystem_create_root ()
	{
		echo "Creating root filesystem..."
		sleep 4
		
		script_log mkfs.btrfs -f -L gentoo /dev/${iDisk_encrpyt_device}
		
		
		echo "Creating btrfs subvolumes..."
		sleep 4
			
		script_log mkdir /mnt/gentoo
		script_log mount /dev/${iDisk_encrypt_device} /mnt/gentoo
		script_log btrfs subvolume create /mnt/gentoo/@
		script_log btrfs subvolume create /mnt/gentoo/@home
		script_log umount -f /mnt/gentoo
		script_log mount -t btrfs -o defaults,noatime,compress=zstd,discard=async,subvol=@ /dev/${iDisk_encrypt_device} /mnt/gentoo
		disk_filesystem_untar_stage3
		script_log mount -t btrfs -o defaults,noatime,compress=zstd,discard=async,subvol=@home /dev/${iDisk_encrypt_device} /mnt/gentoo/home
	}
	
disk_filesystem_untar_stage3 ()
	{
		script_log tar xpvf ${sLocation}/stage3-*.tar.xz -C /mnt/gentoo --xattrs-include='*.*' --numeric-owner
	}
	
system_setup ()
	{
		script_log sed -i '/COMMON_FLAGS=/c\COMMON_FLAGS="-march=native -O2 -pipe"' /mnt/gentoo/etc/portage/make.conf
		script_log echo "" >> /mnt/gentoo/etc/portage/make.conf
		script_log echo "MAKEOPTS=\"${iGentoo_makeopts}\"" >> /mnt/gentoo/etc/portage/make.conf
		script_log echo "USE=\"${iGentoo_globalUseflags} dbus screencast zstd systemd cryptsetup dist-kernel apparmor policykit secureboot\"" >> /mnt/gentoo/etc/portage/make.conf
		script_log echo 'ACCEPT_LICENSE="*"' >> /mnt/gentoo/etc/portage/make.conf
		script_log cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
		script_log cp ${sLocation}/gentoo_config_v${sVersion}.sh /mnt/gentoo
		script_log cp ${sLocation}/gentoo_minimal_v${sVersion}.sh /mnt/gentoo
		script_log cp ${sLocation}/gentoo_${iSystem_profile[0]}_v${sVersion}.sh /mnt/gentoo
		script_log sed -i "/gentoo_setup/c\iDisk_encrypt_device=${iDisk_encrypt_device}" /mnt/gentoo/gentoo_config_v${sVersion}.sh
		script_log echo ". ./gentoo_minimal_v${sVersion}.sh" >> /mnt/gentoo/gentoo_config_v${sVersion}.sh
		script_log genfstab -U /mnt/gentoo >> /mnt/gentoo/etc/fstab
	}
	
echo "Starting installation process..."
disk_part_create
disk_filesystem_create
system_setup

arch-chroot /mnt/gentoo /bin/bash ./gentoo_config_v${sVersion}.sh
