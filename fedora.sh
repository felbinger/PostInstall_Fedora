#!/bin/sh

### configuration section
DNF_PACKAGES=(
  dnf-plugins-core
  distribution-gpg-keys
  terminator                                           # splitable terminal
  #chromium
  keepassxc                                            # kdbx compatible password manager
  syncthing
  nemo-seahorse                                        # nemo seahorse integration (sign / encrypt)
  #sqlitebrowser                                       # simple browser for sqlite databases
  timeshift
  #remmina remmina-plugins-{vnc,rdp,www,spice,secret}  # remote access
  #squashfs-tools
  #telegram-desktop
  #dislocker                                           # decrypt windows bitlocker volumes
  VirtualBox
  #gparted                                             # graphical partitioning tool
  #grub-customizer                                     # graphical grub configuration
  #audacity
  vlc                                                  # videolan: vlc media player
  #totem                                               # gnome video player
  obs-studio
  shotwell                                             # image viewer
  #gimp
  drawing
  flameshot                                            # tool to create and modify screenshots
  #binwalk                                             # tool to analyse binary files for embeded files and executable code
  #radare2                                             # reverse engeneering tool (required for cutter)
  #wfuzz                                               # fuzzing tool
  #gobuster                                            # directory and vhost enumeration
  #wireshark
)
FLATPAK_PACKAGES=(
  im.riot.Riot                                         # Element Client
  com.jgraph.drawio.desktop                            # draw.io
  com.spotify.Client
  com.bitwarden.desktop
  com.brave.Browser
  org.signal.Signal
  com.anydesk.Anydesk
)

### end of configuration section

sudo dnf update -y --refresh

# add fusion repositories
sudo dnf install -y \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# add flathub
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub

# install additional software
sudo dnf install -y ${DNF_PACKAGES[@]}
flatpak install -y ${FLATPAK_PACKAGES[@]}

# add password generator script
sudo wget -q https://raw.githubusercontent.com/felbinger/scripts/master/genpw.sh -O /usr/local/bin/genpw
sudo chmod +x /usr/local/bin/genpw

# change ps1
echo "PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '" | sudo tee -a /{root,home/${USER}}/.bashrc 

# cutter (reverse engeneering)
#bash scripts/cutter.sh

# switch desktop environment
sudo dnf install -y cinnamon
sudo dnf swap -y @gnome-desktop @cinnamon-desktop
