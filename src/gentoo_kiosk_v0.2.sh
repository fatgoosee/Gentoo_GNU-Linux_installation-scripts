#! /bin/bash

sVersion="0.2"

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
		script_log script_emerge dev-vcs/git dev-vcs/mercurial dev-libs/wayland gui-libs/wlroots x11-libs/libxkbcommon
		script_log git clone https://github.com/cage-kiosk/cage.git
		script_log cd /cage
		script_log meson setup build --buildtype=release
		script_log meson compile -C build
		script_log cd
		script_log echo -e "# This is a system unit for launching Cage with auto-login as the\n"\
		"# user configured here. For this to work, wlroots must be built\n"\
		"# with systemd logind support.\n"\
		"\n"\
		"[Unit]\n"\
		"Description=Cage Wayland compositor on %I\n"\
		"# Make sure we are started after logins are permitted. If Plymouth is\n"\
		"# used, we want to start when it is on its way out.\n"\
		"After=systemd-user-sessions.service plymouth-quit-wait.service\n"\
		"# Since we are part of the graphical session, make sure we are started\n"\
		"# before it is complete.\n"\
		"Before=graphical.target\n"\
		"# On systems without virtual consoles, do not start.\n"\
		"ConditionPathExists=/dev/tty0\n"\
		"# D-Bus is necessary for contacting logind, which is required.\n"\
		"Wants=dbus.socket systemd-logind.service\n"\
		"After=dbus.socket systemd-logind.service\n"\
		"# Replace any (a)getty that may have spawned, since we log in\n"\
		"# automatically.\n"\
		"Conflicts=getty@%i.service\n"\
		"After=getty@%i.service\n"\
		"\n"\
		"[Service]\n"\
		"Type=simple\n"\
		"ExecStart=/usr/bin/cage /usr/bin/firefox\n"\
		"Restart=always\n"\
		"User=cage\n"\
		"# Log this user with utmp, letting it show up with commands 'w' and\n"\
		"# 'who'. This is needed since we replace (a)getty.\n"\
		"UtmpIdentifier=%I\n"\
		"UtmpMode=user\n"\
		"# A virtual terminal is needed.\n"\
		"TTYPath=/dev/%I\n"\
		"TTYReset=yes\n"\
		"TTYVHangup=yes\n"\
		"TTYVTDisallocate=yes\n"\
		"# Fail to start if not controlling the virtual terminal.\n"\
		"StandardInput=tty-fail\n"\
		"\n"\
		"# Set up a full (custom) user session for the user, required by Cage.\n"\
		"PAMName=cage\n"\
		"\n"\
		"[Install]\n"\
		"WantedBy=graphical.target\n"\
		"Alias=display-manager.service\n"\
		"DefaultInstance=tty7\n" > /etc/systemd/system/cage@.service
		systemctl enable cage@tty1.service seatd.service
		systemctl set-default graphical.target
		useradd -r -a -G seat cage
		usermod -a -G seat cage
		script_log script_emerge media-video/wireplumber media-video/pipewire media-libs/libpulse dev-db/postresql net-dns/avahi sys-auth/rtkit
		script_log libtool --finish /usr/lib64
	}
	
	
	
gentoo_kiosk_useflags_set
system_packages_kiosk_install
	
script_finish
. ./gentoo_cleanup_v${sVersion}.sh
