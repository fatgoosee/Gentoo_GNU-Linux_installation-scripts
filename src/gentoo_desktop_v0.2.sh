#! /bin/bash

sVersion="0.2"

script_error ()
	{
		exit 1
	}

script_log ()
	{
		"$@"
		
		printf "\n\n$?:\n\t\t" >> gentoo_desktop_v${sVersion}.log
		"$@" &>> gentoo_desktop_v${sVersion}.log
	}
	

script_emerge ()
	{
		emerge --autounmask-write --autounmask "$@"
		if [[ $(etc-update --automode -5) == *"Replacing"* ]]
			then
				emerge "$@"
			fi
	}



gentoo_desktop_useflags_set ()
	{
		echo "Setting package useflags..."
		sleep 4
		
		script_log echo "media-video/pipewire jack-sdk pipewire-alsa gst-plugin-pipewire echo-cancel flatpak lv2 modemmanager roc sound-server" Y /etc/portage/package.use/pipewire
		script_log echo "media-libs/mesa gles1 llvm opencl osmesa vdpau vulkan-overlay" > /etc/portage/package.use/mesa
		script_log echo "VIDEO_CARDS=\"nouveau radeon radeonsi amdgpu vc4 virgl\"" >> /etc/portage/make.conf
		script_log echo "media-libs/libcanberra alsa" > /etc/portage/package.use/libcanberra
		script_log echo "dev-libs/libical vala" > /etc/portage/package.use/libical
		script_log echo "dev-cpp/cairomm X" > /etc/portage/package.use/cairomm
	}
	
system_packages_desktop_install ()
	{
		echo "Installing desktop packages..."
		sleep 4
		
		if [ ${iSystem_profile[1]} == true ]
			then
				script_log eselect repository enable guru
				script_log emerge --sync
				script_log script_emerge phosh-base/phosh-base app-mobilephone/usb-tethering
			fi
		script_log script_emerge dev-libs/libical media-video/pipewire media-video/wireplumber media-libs/libpulse gnome-base/gdm x11-themes/gnome-backgrounds gui-apps/gnome-console gnome-base/gnome-control-center sys-apps/gnome-disk-utility gnome-base/gnome-menus net-misc/gnome-remote-desktop gnome-extra/gnome-shell-extensions gnome-extra/gnome-software gnome-extra/gnome-tweaks gnome-extra/gnome-user-docs gnome-extra/gnome-user-share gnome-base/gvfs net-wireless/iwd media-libs/mesa media-libs/libva-compat gnome-base/nautilus app-accessibility/orca net-misc/rygel media-gfx/simple-scan sys-apps/smartmontools gnome-extra/sushi net-misc/wget net-wireless/wireless-tools x11-misc/xdg-user-dirs-gtk sys-apps/flatpak net-dns/avahi sys-auth/rtkit gnome-extra/nm-applet
		script_log flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
		script_log flatpak install org.gnome.baobab org.gnome.Calculator org.gnome.Calendar org.gnome.Characters org.gnome.clocks org.gnome.Connections org.gnome.Contacts org.gnome.font-viewer org.gnome.Logs org.gnome.Maps com.mattjakeman.ExtensionManager net.nokyan.Resources org.gnome.TextEditor org.gnome.Weather org.gnome.Totem org.gnome.Loupe org.gnome.Snapshot org.gnome.Papers org.gnome.Epiphany com.github.tchx84.Flatseal
		script_log libtool --finish /usr/lib64
		script_log env-update
		script_log source /etc/profile
	}
	
system_desktop_gnomestuff ()
	{
		echo "Doing gnome stuff..."
		sleep 4
	
		script_log gpasswd -a ${iUser_default[1]} plugdev
		script_log gpasswd -a ${iUser_default[1]} audit
		for ((i = 2 ; i <= ${iUser_extra[0]} ; i+=3))
			do
				script_log gpasswd -a ${iUser_extra[i]} plugdev
				script_log gpasswd -a ${iUser_extra[i]} audit
			done
		script_log printf "[Desktop Entry]\nType=Application\nName=AppArmor Notify\nComment=Receive on screen notifications of AppArmor denials\nTryExec=aa-notify\nExec=aa-notify -p -s 1 -w 60 -f /var/log/audit/audit.log\nStartupNotify=false\nNoDisplay=true" > /etc/xdg/autostart/apparmor-notify.desktop
	}



gentoo_desktop_useflags_set
system_packages_desktop_install
system_desktop_gnomestuff


script_finish
. ./gentoo_cleanup_v${sVersion}.sh
