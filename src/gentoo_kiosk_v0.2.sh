#! /bin/bash

sVersion="0.2"

script_error ()
	{
		exit 1
	}

script_log ()
	{
		"$@"
		
		printf "\n\n$?:\n\t\t" >> gentoo_kiosk_v${sVersion}.log
		"$@" &>> gentoo_kiosk_v${sVersion}.log
	}
	

script_emerge ()
	{
		emerge --autounmask-write --autounmask "$@"
		if [[ $(etc-update --automode -5) == *"Replacing"* ]]
			then
				emerge "$@"
			fi
	}
	
	
	
gentoo_kiosk_useflags_set ()
	{
		echo "Setting package useflags..."
		sleep 4
		
		script_log sed -i "s/USE=\"/USE=\"wayland egl vulkan\ /" /etc/portage/make.conf
		
		script_log echo "media-video/pipewire jack-skd pipewire-alsa gst-plugin-pipewire echo-cancel lv2 modemmanager roc sound-server" > /etc/portage/package.use/pipewire
		script_log echo "gui-libs/wlroots X x11-backends" > /etc/portage/package.use/wlroots
	}
	
system_packages_kiosk_install ()
	{
		script_log script_emerge dev-vcs/git dev-vcs/mercurial dev-libs/wayland dev-libs/wayland-protocols dev-libs/glib sys-libs/glibc gnome-base/gnome-session gnome-base/gsettings-desktop-schemas media-libs/libglvnd app-i18n/ibus x11-libs/libx11 x11-wm/mutter media-video/wireplumber media-video/pipewire media-libs/libpulse net-dns/avahi sys-auth/rtkit sys-apps/flatpak
		script_log libtool --finish /usr/lib64
		script_log git clone https://gitlab.gnome.org/GNOME/gnome-kiosk.git
		script_log cd /gnome-kiosk
		script_log meson setup ./build .
		script_log meson compile -C ./build
		script_log meson install ./build
		script_log libtool --finish /usr/lib64
		script_log cd
		script_log flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	}
	
	
	
gentoo_kiosk_useflags_set
system_packages_kiosk_install
	
script_finish
. ./gentoo_cleanup_v${sVersion}.sh
