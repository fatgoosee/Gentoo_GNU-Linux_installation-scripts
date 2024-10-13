#! /bin/bash

sVersion="0.1"

script_error ()
	{
		exit 1
	}

script_log ()
	{
		"$@"
		
		printf "\n\n$?:\n\t\t" >> gentoo_minimal_v${sVersion}.log
		"$@" &>> gentoo_minimal_v${sVersion}.log
	}
	

script_emerge ()
	{
		emerge --autounmask-write --autounmask "$@"
		if [[ $(etc-update --automode -5) == *"Replacing"* ]]
			then
				emerge "$@"
			fi
	}
	


gentoo_source_sync ()
	{
		echo "Syncing sources..."
		sleep 4
		
		script_log source /etc/profile
		script_log systemctl daemon-reload
		script_log emerge-webrsync
		script_log emerge --sync
		script_log emerge --oneshot sys-apps/portage
		script_log emerge --sync
		script_log sed -i "/replace-unmodified=/c\replace-unmodifed=yes" /etc/dispatch-conf.conf
		script_log mkdir /etc/config-archive
		script_log echo "pre-update" >> /etc/portage/conf-update.d
	}
	
gentoo_useflags_set ()
	{
		echo "Setting package useflags..."
		sleep 4
		
		script_log mkdir -p /etc/portage/package.{accept_keywords,license,mask,unmask,use}			
		if [ ${iSystem_profile[0]} != "minimal" ]
			then
				script_log sed -i "s/USE=\"/USE=\"bluetooth ffmpeg extra ieee1394 v4l audit\ /" /etc/portage/make.conf
				if [ ${iSystem_profile[0]} == "desktop" ]
					then
						script_log sed -i "s/USE=\"/USE=\"wayland egl gnome gtk accessibility policykit cups opengl vaapi vulkan zstd gles2 X\ /" /etc/portage/make.conf
						script_log echo "dev-cpp/gtkmm X" > /etc/portage/package.use/gtkmm
					fi
			fi
		script_log echo "sys-kernel/installkernel dracut uki" > /etc/portage/package.use/installkernel
		script_log echo "sys-apps/systemd boot resolvconf timesync" > /etc/portage/package.use/systemd
		script_log echo "net-misc/networkmanager concheck connection-sharing wpa_supplicant modemmanager rp-pppoe nftables ofono wifi systemd-resolved" > /etc/portage/package.use/networkmanager
		script_log echo "net-wireless/wpa_supplicant ap" > /etc/portage/package.use/wpa_supplicant
		script_log echo "sys-apps/firejail chroot dbusproxy file-transfer globalcfg network userns apparmor contrib" > /etc/portage/package.use/firejail
	}
	
gentoo_keywords_accept ()
	{
		if [ ${iGentoo_keywords[0]} == true ]
			then
				echo "Accepting keywords..."
				sleep 4
				
				script_log script_emerge dev-vcs/git dev-vcs/mercurial
				script_log echo "ACCEPT_KEYWORDS=\"${iGentoo_keywords[1]}\"" >> /etc/portage/make.conf
			fi
	}
	
system_mac_install ()
	{
		echo "Setting up Mandatory Based Accesscontrol..."
		sleep 4
		
		script_log script_emerge sys-apps/apparmor sys-apps/apparmor-utils sys-libs/libapparmor sys-apps/firejail
	}
	
system_kernel_install ()
	{
		echo "Installing kernel..."
		sleep 4
		
		script_log script_emerge sys-kernel/linux-firmware sys-kernel/${iSystem_kernel}-kernel sys-kernel/linux-headers sys-apps/fwupd sys-apps/kmod sys-fs/cryptsetup
		script_log eselect kernel set 1
		script_log libtool --finish /usr/lib64
		script_log ln -s /usr/src/$(ls /usr/src/) /usr/src/linux
	}
	
system_packages_base_install ()
	{
		echo "Installing base packages..."
		sleep 4
		
		if [ ${iSystem_shell} == "nu" ]
			then
				script_log script_emerge app-shells/nushell
			fi
		script_log script_emerge sys-apps/dbus app-shells/bash app-shells/bash-completion app-arch/bzip2 sys-apps/file sys-apps/coreutils sys-apps/findutils sys-apps/gawk sys-devel/gcc sys-devel/gettext sys-libs/glibc sys-apps/grep app-arch/gzip sys-apps/iproute2 net-misc/iputils sys-apps/pciutils sys-process/procps sys-process/psmisc sys-apps/sed sys-apps/shadow sys-apps/systemd app-arch/tar sys-apps/util-linux app-arch/xz-utils app-crypt/gnupg
		script_log libtool --finish /usr/lib64
	}
	
system_kernel_essentials_install ()
	{
		echo "Installing kernel essentials..."
		sleep 4
		
		script_log script_emerge sys-kernel/dracut sys-kernel/installkernel
		script_log libtool --finish /usr/lib64
	}
	
system_packages_basedevel_install ()
	{
		echo "Installing base development packages..."
		sleep 4
		
		script_log script_emerge dev-build/autoconf dev-build/automake sys-devel/binutils sys-devel/bison dev-util/debugedit sys-apps/fakeroot sys-devel/flex sys-apps/groff dev-build/libtool
		libtool --finish /usr/lib64
		script_log script_emerge sys-devel/m4 dev-build/make sys-devel/patch dev-util/pkgconf sys-apps/texinfo sys-apps/which sys-fs/btrfs-progs dev-build/cmake
		script_log libtool --finish /usr/lib64
		script_log script_emerge sys-process/audit app-misc/neofetch sys-fs/dosfstools sys-fs/cryptsetup net-misc/networkmanager net-dialup/rp-pppoe net-misc/modemmanager net-wireless/wpa_supplicant net-dns/dnsmasq app-admin/${iSystem_privilege} net-misc/openssh sys-process/btop net-firewall/firewalld
		script_log libtool --finish /usr/lib64
	}
	
system_packages_efi_install ()
	{
		echo "Installing efi management packages..."
		sleep 4
		
		script_log script_emerge sys-boot/efibootmgr
		if [ "$(uname -m)" == "x86_64" ]
			then
				script_log echo "sys-firmware/intel-microcode initramfs intel-ucode" > /etc/portage/package.use/intel-microcode
				script_log script_emerge sys-firmware/intel-microcode
			fi
		script_log libtool --finish /usr/lib64
	}
	
system_timezone_set ()
	{
		echo "Setting timezone..."
		sleep 4
		
		script_log ln -sf /usr/share/zoneinfo/${iSystem_timezone} /etc/localtime
		script_log hwclock --systohc
		script_log echo "[Time]" > /etc/systemd/timesyncd.conf
		script_log echo "NTP=0.pool.ntp.org" >> /etc/systemd/timesyncd.conf
		script_log echo "Fallback=0.gentoo.pool.ntp.org" >> /etc/systemd/timesyncd.conf
	}
	
locale_set ()
	{
		echo "Setting locale..."
		sleep 4
		
		script_log echo "KEYMAP=${iLocale_keymap}" >> /etc/conf.d/keymaps
		for ((i = 1 ; i <= ${iLocale_lang[0]} ; i++))
			do
				script_log echo "${iLocale_lang[i]}${iLocale_encode} ${iLocale_encode}" >> /etc/locale.gen
			done
		script_log locale-gen
		script_log echo "LANG=${iLocale_lang[1]}${iLocale_encode}" >> /etc/locale.conf
		script_log env-update
		script_log source /etc/profile
	}
	
world_update ()
	{
		script_log emerge --update --deep --newuse --with-bdeps=y --keep-going @world
		script_log emerge --depclean
	}
	
system_hostname_set ()
	{
		echo "Setting hostname..."
		sleep 4
		
		script_log echo "${iSystem_hostname}" > /etc/hostname
	}
	
system_boot_setup ()
	{
		echo "Installing & configuring system bootmethod..."
		sleep 4
		
		script_log echo "add_dracutmodules+=\" crypt crypt-gpg rootfs-block base dm btrfs systemd-ask-password\"" >> /etc/dracut.conf
		script_log echo "uefi=\"yes\"" >> /etc/dracut.conf
		if [ ${iDisk_encrpyt_device} == "mapper/luksdev" ]
			then
				script_log echo "kernel_cmdline+=\" init=/usr/lib/systemd/systemd root=UUID=$(blkid -o value -s UUID /dev/${iDisk_encrypt_device}) rd.luks.uuid=$(blkid -o value -s UUID /dev/${iDisk_device}2) rootflags=subvol=@ \"" >> /etc/dracut.conf
				if [ ${iDisk_encrpyt[2]} == true ]
					then
						script_log sed -i "kernel_cmdline+=/$/\"/rd.luks.key=/crypt_key.luks.gpg:UUID=$(blkid -o value -s UUID /dev/${iDisk_device}1)\ \""
					fi
		else
				script_log echo "kernel_cmdline+=\" init=/usr/lib/systemd/systemd root=UUID=$(blkid -o value -s UUID /dev/${iDisk_device}2) rootflags=subvol=@ rootfstype=btrfs \"" >> /etc/dracut.conf
			fi
		script_log sed -i "s/kernel_cmdline+=\"/kernel_cmdline+=\"\ apparmor=1 security=apparmor\ /" /etc/dracut.conf
		script_log bootctl install
		script_log rm -f /boot/EFI/Linux/$(ls /boot/EFI/Linux/ | grep -v linux-)
		script_log dracut --regenerate-all --uefi
	}
	
user_setup ()
	{
		echo "Setting up user account(s)..."
		sleep 4
		
		if [ ${iSystem_privilege} == "doas" ]
			then
				user_setup_doas
		else
				user_setup_sudo
			fi
		user_setup_elevation
		script_log groupadd -r audit
		script_log echo "log_group = audit" >> /etc/audit/auditd.conf
		if [ ${iUser_elevation} == true ]
			then
				user_setup_elevation
		else
				useradd -G wheel,users,audit,plugdev -c ${iUsers_default[0]} -m -U ${iUser_default[1]} -p "${iUser_default[2]}"
				for ((i = 2 ; i <= ${iUser_extra[0]} ; i+=3))
					do
						if [ ${iUser_extra[i+2]} == true ]
							then
								sADMIN="wheel,"
						else
								sADMIN=""
							fi
						script_log useradd -G ${sADMIN}users,audit,plugdev -c ${iUser_extra[i-1]} -m -U ${iUser_extra[i]} -p "${iUser_extra[i+1]}"
					done
			fi
		script_log passwd --lock root
	}
	
user_setup_doas ()
	{
		echo "Setting up doas..."
		sleep 4
		
		script_log touch /etc/doas.conf
		script_log chown -c root:root /etc/doas.conf
		script_log chmod -c 0400 /etc/doas.conf
		if [ ${iUser_elevation} == true ]
			then
				script_log echo "permit nopass :wheel" > /etc/doas.conf
		else
				script_log echo "permit persist :wheel" > /etc/doas.conf
			fi
	}
	
user_setup_sudo ()
	{
		echo "Setting up sudo..."
		sleep 4
		
		if [ ${iUser_elevation} == true ]
			then
				script_log echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers
		else
				script_log echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers
			fi
		script_log echo "@includedir /etc/sudoers.d" >> /etc/sudoers
	}
	
user_setup_elevation ()
	{
		echo "Setting up elevation..."
		sleep 4
		
		script_log sed -i "SHELL=/c\SHELL=/usr/bin/${iSystem_shell}" /etc/default/useradd
		script_log useradd -r -G wheel -s /usr/bin/bash elevation -U -p "${iUser_default[2]}"
		bashrc_write
		user_skel_create
		script_log useradd -s /usr/bin/${iSystem_shell} -G elevated,users,audit,plugdev -c ${iUsers_default[0]} -m -U ${iUser_default[1]} -p "${iUser_default[2]}"
		script_log useradd -G wheel -r adm_${iUser_default[1]} -p "${iUser_default[2]}"
		for ((i = 2 ; i <= ${iUser_extra[0]} ; i+=3))
			do
				if [ ${iUser_extra[i+2]} == true ]
					then
						sADMIN="elevated,"
						sADMIN2="wheel"
				else
						sADMIN=""
						sADMIN2=""
					fi
				script_log useradd -G ${sADMIN}users,audit,plugdev -c ${iUser_extra[i-1]} -m -U ${iUser_extra[i]} -p "${iUser_extra[i+1]}"
				script_log useradd -G sADMIN2 -r adm_${iUser_extra[i]} -p "${iUser_extra[i+1]}"
			done
	}
	
bashrc_write ()
	{
		echo "Writing elevationrc..."
		sleep 4
		
		script_log echo -e 'while ()\n'\
		'{\n'\ 
		'eUSERS=$(getent group elevated | cut -d: -f4)\n'\
		'eEND=$(echo $eUSERS | grep -ob "," | grep -oE "[0-9]+" | tail -1)\n'\
		'for ( int i = 0 ; i <= $eEND )\n'\
		'do\n'\
		'eCHAR=$(echo $eUSERS | grep -ob "," | grep -oE "[0-9]+" | tail -1)\n'\
		'eUSERNAME=$(echo eUSERS | cut -c ${eCHAR}-)\n'\
		'eUSERS=$(echo eUSERS | cut -c -${eCHAR})\n'\
		'if [ $(getent group wheel | grep "adm_${eUSERNAME}") != 0 ]\n'\
		'then\n'\
		'useradd -r -G wheel adm_${eUSERNAME}\n'\
		'ePSW=$(grep ${eUSERNAME} | grep -Po ":\K[^;]*")\n'\
		'sed -i "adm_${eUSERNAME}/s/:/:${ePSW}/"\n'\
		'fi\n'\
		'done\n'\
		'}' >> /home/elevation/.bashrc
	}
	
user_skel_create ()
	{
		echo "Writing skeleton..."
		sleep 4
		
		if [ ${iSystem_shell} == "nu" ]
			then
				script_log mkdir -p /etc/skel/.config/nushell/NOTUPSTREAM
				script_log echo -e 'def elevate [...command: string] {\n'\
				'mut eCmd = "'${iSystem_privilege}'"\n'\
				'for $eCommand in $command {\n'\
				'$eCmd += " " + $eCommand\n'\
				'}\n'\
				'su -c $eCmd (whoami)\n'\
				'}' > /etc/skel/.config/nushell/NOTUPSTREAM/elevation.nu
		else
				script_log echo 'elevate () { su -c "'${iSystem_privilege}' $@" adm_$(whoami) }' >> /etc/skel/.bashrc
			fi
	}
	
packages_defined_install ()
	{
		echo "Installing defined packages..."
		sleep 4
		
		for (( i = 1 ; i <= ${iPackages_define[0]} ; i++))
			do
				sPKG=${iPackages_define[i]# *}
				sFILE=${sPKG#*/}
				script_log echo "${iPackages_define[i]}" > /etc/portage/package.use/${sFILE}
				script_log libtool --finish /usr/lib64
				script_log script_emerge ${sPKG}
			done
	}
	
packages_nixpkgs_install ()
	{
		if [ ${iPackages_nixpkgs} == true ]
			then
				echo "Installing nixpkgs..."
				sleep 4
				
				script_log yes | sh <(curl -L https://nixos.org/nix/install) --daemon
			fi
	}
	
packages_alias_update_create ()
	{
		echo "Creating update alias..."
		sleep 4
		
		sSTARTA="neofetch ; ${iSystem_privilege} emaint -a sync ; ${iSystem_privilege} emerge -uDN @world ; ${iSystem_privilege} etc-update --automod -5 ; ${iSystem_privilege} emerge --depclean ; ${iSystem_privilege} emerge --oneshot sys-apps/portage"
		if [ ${iPackages_nixpkgs} == true ]
			then
				sNIXA=" ; ${iSystem_privilege} nix-env --upgrade"
			fi
		if [ ${iSystem_profile[0]} == "desktop" ]
			then
				sFLATPAKA=" ; flatpak update -y"
			fi
		sINITRAMFSA=" ; ${iSystem_privilege} dracut --regenerate-all --uefi"
		sENDA=" ; fwupdmgr refresh --force ; fwupdmgr update && fwupdmgr install"
		
		if [ ${iSytem_shell} == "nu" ]
			then
				script_log mkdir -p /etc/skel/.config/nushell/NOTUPSTREAM
				script_log echo "alias update = '${sSTARTA}${sNIXA}${sFLATPAKA}${sINITRAMFSA}'" >> /etc/skel/.config/nushell/NOTUPSTREAM/update_alias.nu
				script_log echo "alias update-uefi= '${sSTARTA}${sNIXA}${sFLATPAKA}${sINITRAMFSA}${sEND}'" >> /etc/skel/.config/nushell/NOTUPSTREAM/update_alias.nu
		else
				script_log echo "alias update='${sSTARTA}${sNIXA}${sFLATPAKA}${sINITRAMFSA}'" >> /etc/skel/.bashrc
				script_log echo "alias update-uefi='${sSTARTA}${sNIXA}${sFLATPAKA}${sINITRAMFSA}${sEND}'" >> /etc/skel/.bashrc
			fi
	}
	
script_finish ()
	{
		echo "Finishing installation..."
		sleep 4
		
		script_log systemctl enable firewalld systemd-timesyncd auditd NetworkManager systemd-boot-upgrade apparmor
		if [ ${iSystem_profile[0]} != "minimal" ]
			then
				script_log systemctl enable --global pipewire-pulse.socket wireplumber.service
				if [ ${iSystem_profile[0]} == "server" ]
					then
						script_log systemctl enable docker sshd
				else
						script_log systemctl enable gdm
					fi
			fi
		script_log systemd_machine-id-setup
		script_log systemd-firstboot --locale=${iLocale_lang[1]}${iLocale_encode} --keymap=${iLocale_keymap} --timezone=${iSystem_timezone} --hostname=${iSystem_hostname}
		script_log systemctl preset-all --preset-mode=enable-only
	}
	


gentoo_source_sync
gentoo_useflags_set
system_timezone_set
locale_set
gentoo_keywords_accept
system_mac_install
system_kernel_install
system_packages_base_install
system_kernel_essential_install
system_packages_basedevel_install
system_packages_efi_install
world_update
system_hostname_set
system_boot_setup
user_setup
packages_defined_install
packages_nixpkgs_install
packages_alias_update_create


if [ ${iSystem_profile[0]} != "minimal" ]
	then
		. ./gentoo_${iSystem_profile[0]}_v${sVersion}.sh
else
		script_finish
		. ./gentoo_cleanup_v${sVersion}.sh
	fi
