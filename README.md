# Gentoo_GNU+Linux_installation scripts
Bash scripts to automate Gentoo's installation process.

These scripts have not been tested yet.

## How to use

### Prepare
1. clone this repository: `git clone https://github.com/FatGoosee/Gentoo_GNU-Linux_installation-scripts.git`

2. copy src to installation medium
3. Boot into any Linux system that has or can be installed to: `arch-install-scripts` for arch-chroot and genfstab
4. copy src to live os (recommended) or leave them there
5. download stage3-*-systemd stage archive from gentoo mirrors
6. configure: `sLocation="/my/directory/containing-scripts"` in: `gentoo_config_vVERSION.sh`

### Configure and install

1. configure: `gentoo_config_vVERSION.sh` with your favourite editor
2. Then run `bash gentoo_config_vVERSION.sh` with root
3. Lean back and (maybe) relax

## Hints

### Profiles

_**This script uses systemd only!**_

minimal profile can be compared to a base + base-devel archlinux installation

server, kiosk and desktop are based on minimal profile

server adds pipewire, docker, nginx and posresql, the extra option installs nginx on docker instead of the system.

kiosk adds pipewire, gnome-kiosk and flatpak

desktop adds pipewire, gnome and flatpak, the extra option installs phosh alongside

