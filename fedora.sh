#!/bin/sh

### configuration section
PACKAGES=(
  dnf-plugins-core
  distribution-gpg-keys
  terminator                                          # splitable terminal
  chromium
  keepassxc                                           # kdbx compatible password manager
  syncthing
  nemo-seahorse                                       # nemo seahorse integration (sign / encrypt)
  #sqlitebrowser                                      # simple browser for sqlite databases
  timeshift
  remmina remmina-plugins-{vnc,rdp,www,spice,secret}  # remote access
  #squashfs-tools
  telegram-desktop
  #dislocker                                          # decrypt windows bitlocker volumes
  VirtualBox
  lpf-spotify-client                                  # spotify installer
  #gparted                                            # graphical partitioning tool
  #grub-customizer                                    # graphical grub configuration
  #audacity
  vlc                                                 # videolan: vlc media player
  totem                                               # gnome video player
  obs-studio
  shotwell                                            # image viewer
  #gimp
  drawing
  flameshot                                           # tool to create and modify screenshots
  binwalk                                             # tool to analyse binary files for embeded files and executable code
  radare2                                             # reverse engeneering tool (required for cutter)
  wfuzz                                               # fuzzing tool
  gobuster                                            # directory and vhost enumeration
  wireshark
)
### end of configuration section

sudo dnf update -y --refresh

# add fusion repositories
sudo dnf install -y \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# install additional software
sudo dnf install -y ${PACKAGES[@]}

# install docker and configure rootless access
#curl https://get.docker.com | sudo bash
#sudo dnf install -y policycoreutils-python-utils docker-compose
#dockerd-rootless-setuptool.sh install

cat <<EOF >> /home/${USER}/.bashrc
alias dc="docker-compose"
export PATH=/usr/bin:$PATH
#export DOCKER_HOST=unix:///run/user/1000/docker.sock
EOF

# install brave
#sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
#sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
#sudo dnf install -y brave-browser

# install element desktop
sudo dnf copr enable -y taw/element
sudo dnf install -y element

# install signal desktop
sudo dnf copr enable -y luminoso/Signal-Desktop
sudo dnf install -y signal-desktop

# add password generator script
sudo wget -q https://raw.githubusercontent.com/felbinger/scripts/master/genpw.sh -O /usr/local/bin/genpw
sudo chmod +x /usr/local/bin/genpw

# change ps1
echo "PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '" | sudo tee -a /{root,home/${USER}}/.bashrc 

# cutter (reverse engeneering)
bash scripts/cutter.sh

# switch desktop environment
sudo dnf install -y cinnamon
sudo dnf swap -y @gnome-desktop @cinnamon-desktop
