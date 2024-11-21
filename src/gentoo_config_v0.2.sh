#! /bin/bash

# Used for version checks
sVersion="0.2"

# Location where scripts and stage3 archive are stored
sLocation="/mnt/files"

# Gentoo specific configurations
	iGentoo_makeopts="-j8"
	iGentoo_globalUseflags=""
	iGentoo_keywords=(false "**")
		# enabled "accepted keywords"

# Locale configuration
	iLocale_keymap="de"
	iLocale_lang=(2 "en_US." "it_IT.")
		# locale entries "locale 1" "locale 2"
	iLocale_encode="UTF-8"
	
# Disk configuration
	iDisk_device="vda"
	iDisk_encrypt=(false "DoNotShow_Any1YourPa55word!" false)
		# enabled "password" gpg-encrypted-keyfile
	iDisk_table="gpt"
	# Partitions
		iDisk_part_boot=("0%" "512MiB")
			# "filesystem" "start sector" "end sector"
		iDisk_part_root=("512MiB" "100%")
			# "filesystem" "start sector" "end sector"
			
# User configuration
	iUser_default=("Sol" "sol" "DoNotShow_Any1YourPa55word!" "sol@script.no" "Wall Street 11, New York, United States of America")
		# "display name" "username" "password" "email" "location"
	iUser_extra=(0 "Aksinya" "aksinya" "DoNotShow_Any1YourPa55word!" "" "" false "Arvid" "arvid" "DoNotShow_Any1YourPa55word!" "" "" false)
		# user entries "display name" "username" "password" "email" "location" privileged
	iUser_elevation=false
		## a system where a user has an extra admin account
		
# System configuration
	iSystem_hostname="gentoo_gnu+linux"
	iSystem_timezone="Europe/Madrid"
	iSystem_profile=("minimal" false)
		# "minimal", "server", "kiosk" or "desktop" extra	## server and desktop are based on minimal, kiosk is gnome-kiosk (github), desktop is gnome, extra installs programms inside docker for server or installs phosh for desktop
	iSystem_kernel="gentoo"
		# "gentoo" or "vanilla"
	iSystem_secureboot=false
	iSystem_privilege="sudo"
		# "sudo" or "doas"
	iSystem_shell="bash"
		# "bash" or "nu"
		
# Packages			
	iPackages_define=(2 "app-editors/neovim" "dev-vcs/git gpg")
		# package entries "category/packagename useflags"
	iPackages_nixpkgs=false





. ${sLocation}/gentoo_setup_v${sVersion}.sh
