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
	
	

gentoo_server_useflags_set ()
	{
		echo "Setting package useflags..."
		sleep 4
		
		script_log echo "media-video/pipewire jack-skd pipewire-alsa gst-plugin-pipewire echo-cancel lv2 modemmanager roc sound-server" > /etc/portage/package.use/pipewire
		script_log echo "app-containers/docker btrfs" > /etc/portage/package.use/docker
	}
	
system_packages_server_install ()
	{
		echo "Installing server packages..."
		sleep 4
		
		if [ ${iSystem_profile[1]} == true ]
			then
				script_log script_emerge app-container/docker app-containers/docker-cli
				script_log libtool --finish /usr/lib64
				script_log systemctl start docker
				script_log printf "net.ipv4.ip_forward=1\nnet.ipv6.ip_forward=1" >> /etc/sysctl.d/local.conf
				script_log docker create -t nginx-01 nginx
		else
				script_log script_emerge app-containers/docker app-containers/docker-cli www-server/nginx
			fi
		script_log script_emerge media-video/wireplumber media-video/pipewire media-libs/libpulse dev-db/postresql net-dns/avahi sys-auth/rtkit
		script_log libtool --finish /usr/lib64
	}
	


gentoo_server_useflags_set
system_packages_server_install


script_finish
. ./gentoo_cleanup_v${sVersion}.sh
