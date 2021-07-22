#!/bin/sh

### configuration section
PACKAGES=(
  "dnf-plugins-core"
  "distribution-gpg-keys"
  "terminator"                                          # splitable terminal
  "chromium"
  "keepassxc"                                           # kdbx compatible password manager
  "syncthing"
  "nemo-seahorse"                                       # nemo seahorse integration (sign / encrypt)
  #"sqlitebrowser"                                      # simple browser for sqlite databases
  "timeshift"
  "remmina remmina-plugins-{vnc,rdp,www,spice,secret}"  # remote access
  #"squashfs-tools"
  "telegram-desktop"
  #"dislocker"                                          # decrypt windows bitlocker volumes
  "VirtualBox"
  "lpf-spotify-client"                                  # spotify installer
  #"gparted"                                            # graphical partitioning tool
  #"grub-customizer"                                    # graphical grub configuration
  #"audacity"
  "vlc"                                                 # videolan: vlc media player
  "totem"                                               # gnome video player
  "obs-studio"
  "shotwell"                                            # image viewer
  #"gimp"
  "drawing"
  "flameshot"                                           # tool to create and modify screenshots
)
### end of configuration section

if [[ $(/usr/bin/id -u) != "0" ]]; then
  echo "Please run the script as root!"
  exit 1
fi

dnf update -y

# add fusion repositories
dnf install -y \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# install additional software
dnf install -y ${PACKAGES[@]}

# install docker and configure rootless access
curl https://get.docker.com | bash
dnf install -y policycoreutils-python-utils docker-compose
dockerd-rootless-setuptool.sh install

cat <<EOF >> .bashrc
alias dc="docker-compose"
export PATH=/usr/bin:$PATH
export DOCKER_HOST=unix:///run/user/1000/docker.sock
EOF

# install brave
dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
dnf install -y brave-browser

# install element desktop
dnf copr enable -y taw/element
dnf install -y element

# install signal desktop
dnf copr enable -y luminoso/Signal-Desktop
dnf install -y signal-desktop

# add password generator script
wget -q https://raw.githubusercontent.com/felbinger/scripts/master/genpw.sh -O /usr/local/bin/genpw
chmod +x /usr/local/bin/genpw

# change ps1
cat <<EOF >> ~/.bashrc
PS1=\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$
EOF

# switch desktop environment
dnf install -y cinnamon
dnf swap -y @gnome-desktop @cinnamon-desktop
