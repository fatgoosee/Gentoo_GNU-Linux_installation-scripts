#! /bin/bash


echo "Setting up SELinux..."
sleep 4

script_log echo "POLICY_TYPES=\"mls\"" >> /etc/portage/make.conf
script_log echo "tmpfs /tmp tmpfs defaults,noexec,nosuid,rootcontext=system_u:object_r:tmp_t:s0 0 0" >> /etc/fstab
sTMP=$(script_log eselect profile list | grep -e "hardened/selinux/systemd" | grep -v "no-multilib" | cut -b 4-6)
script_log eselect profile set ${sTMP#]*}
script_log sed -i "s/USE=\"/USE=\"ubac unconfined unknown-perms selinux\ /" /etc/portage/make.conf
script_log script_emerge sys-kernel/${iSystem_kernel}-kernel
FEATURES="-selinux" script_log script_emerge --oneshot sec-policy/selinux-base
script_log sed -i "/SELINUX=/c\SELINUX=permissive" /etc/selinux/config
script_log sed -i "/SELINUXTYPE=/c\SELINUXTYPE=mls" /etc/selinux/config
FEATURES="-selinux -sesandbox" script_log script_emerge --oneshot sec-policy/selinux-base sec-policy/selinux-base-policy
FEATURES="-selinux -sesandbox" script_log script_emerge sys-apps/policycoreutils
script_log echo "app-archive/gzip -selinux -sesandbox" > /etc/portage/package.use/gzip
script_log emerge --update --deep --newuse @world
script_log mkdir /mnt/gentoo
script_log mount -o bind / /mnt/gentoo
script_log setfiles -r /mnt/gentoo /etc/selinux/mls/contexts/files/file_contexts /mnt/gentoo/{dev,boot,proc,run,sys,tmp}
script_log umount /mnt/gentoo
script_log rlpkg -a -r
script_log sed -i "/SELINUX=/c\SELINUX=enforcing" /etc/selinux/config
script_log semanage login -a -s users_u ${iUser_default[1]}
script_log restorecon -R -F /home/${iUser_default[1]}
script_log newrole -r sysadm_r
if [ ${iUser_elevation} == true ]
	then
		script_log sed -i "/$%wheel\ ALL=(ALL)/c\%wheel\ ALL=(ALL) NOPASSWD: ALL\ TYPE=sysadm_t\ ROLE=sysadm_r\ ALL" /etc/sudoers
else
	script_log sed -i "/$%wheel\ ALL=(ALL)/c\%wheel\ ALL=(ALL)\ TYPE=sysadm_t\ ROLE=sysadm_r\ ALL" /etc/sudoers
	fi
if [ ${iPackages_nixpkgs} == true ]
	then
		script_log semanage fcontext -a -t etc_t "/nix/store/[^/]+/etc(/.*)?"
		script_log semanage fcontext -a -t lib_t "/nix/store/[^/]+/lib(/.*)?"
		script_log semanage fcontext -a -t systemd_unit_file_t "/nix/store/[^/]+/lib/systemd/system(/.*)?"
		script_log semanage fcontext -a -t man_t "/nix/store/[^/]+/man(/.*)?"
		script_log semanage fcontext -a -t bin_t "/nix/store/[^/]+/s?bin(/.*)?"
		script_log semanage fcontext -a -t usr_t "/nix/store/[^/]+/share(/.*)?"
		script_log semanage fcontext -a -t var_run_t "/nix/var/nix/daemon-socket(/.*)?"
		script_log semanage fcontext -a -t usr_t "/nix/var/nix/profiles(/per-user/[^/]+)?/[^/]+"
		script_log mkdir /etc/systemd/system/nix-daemon.service.d
		script_log echo "[Service]" >> /etc/systemd/system/nix-daemon.service.d/override.conf
		script_log echo "Environment=\"NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt\"" >> /etc/systemd/system/nix-daemon.service.d/override.conf
		script_log setenforce Permissive
	fi
	
exit 0
